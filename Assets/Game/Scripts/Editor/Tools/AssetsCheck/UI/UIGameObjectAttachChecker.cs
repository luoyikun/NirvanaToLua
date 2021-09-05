using UnityEngine;
using UnityEditor;
using Nirvana;
using System.Text;

namespace AssetsCheck
{
    // 在UI上直接拖进粒子系统会造成文件的增大，打开界面会更慢
    // 因此有要求所有用到粒子系统的都用GameObjectAttach加载特效的方式来做
    class UIGameObjectAttachChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };

        override public string GetErrorDesc()
        {
            return string.Format("使用了UI特效，却没有用GameObjectAttach的方式来做");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                ParticleSystem[] particle_systems = gameobj.GetComponentsInChildren<ParticleSystem>(true);
                for (int i = 0; i < particle_systems.Length; i++)
                {
                    if (!this.HasAttacherInParent(particle_systems[i].transform))
                    {
                        CheckItem item = new CheckItem();
                        item.asset = path;
                        this.outputList.Add(item);
                    }
                }
            }
        }

        private bool HasAttacherInParent(Transform transform)
        {
            Transform temp_transform = transform.parent;

            while(temp_transform)
            {
                if (null != temp_transform.GetComponent<Game.GameObjectAttach>())
                {
                    return true;
                }

                temp_transform = temp_transform.parent;
            }

            return false;
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public int width;
            public int height;

            public string MainKey
            {
                get { return string.Format("{0}", asset); }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(this.asset);
                return builder;
            }
        }
    }
}
