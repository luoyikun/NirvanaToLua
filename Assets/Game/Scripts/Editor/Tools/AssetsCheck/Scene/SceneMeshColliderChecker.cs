using UnityEngine;
using UnityEditor;
using System.Text;

namespace AssetsCheck
{
    class SceneMeshColliderChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Environments" };

        override public string GetErrorDesc()
        {
            return string.Format("场景不要用网格碰撞器，费性能");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                if (null != gameobj.GetComponentInChildren<MeshCollider>(true))
                {
                    CheckItem item = new CheckItem();
                    item.asset = path;
                    this.outputList.Add(item);
                }
            }
        }

        override protected void OnFix(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(lines[i]);
                if (null != gameobj)
                {
                    var components = gameobj.GetComponentsInChildren<MeshCollider>(true);
                    for (int j = 0; j < components.Length; j++)
                    {
                        GameObject.DestroyImmediate(components[j], true);
                    }
                }
            }

            AssetDatabase.SaveAssets();
        }

        struct CheckItem : ICheckItem
        {
            public string asset;

            public CheckItem(string asset)
            {
                this.asset = asset;
            }

            public string MainKey
            {
                get { return this.asset; }
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
