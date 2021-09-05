using UnityEngine;
using UnityEditor;
using AssetsCheck;
using System.Text;

namespace AssetsCheck
{
    class ParticleSystemSettingChecker : BaseChecker
    {
        // 指定要检查的特效文件夹
        private string[] checkDirs = { "Assets/Game" };

        private float maxPrvwarmTime = 20.0f;

        override public string GetErrorDesc()
        {
            return string.Format("粒子特效的预热时间太长,不要长于{0}", maxPrvwarmTime);
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(asset_path);
                ParticleSystem[] particle_systems = gameobj.GetComponentsInChildren<ParticleSystem>(true);

                CheckItem check_item = new CheckItem();
                check_item.asset = asset_path;
                this.CheckPreWarm(particle_systems, ref check_item);

                if (check_item.prewarmTime > 0)
                {
                    this.outputList.Add(check_item);
                }
            }
        }

        private bool CheckPreWarm(ParticleSystem[] particle_systems, ref CheckItem checkItem)
        {
            for (int i = 0; i < particle_systems.Length; i++)
            {
                ParticleSystem particle_system = particle_systems[i];
                if (particle_system.main.prewarm && particle_system.main.duration > 0.0f)
                {
                    if (checkItem.prewarmTime < particle_system.main.duration)
                    {
                        checkItem.prewarmTime = particle_system.main.duration;
                    }
                }
            }

            return checkItem.prewarmTime < maxPrvwarmTime;
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public float prewarmTime;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);

                if (prewarmTime > 0.0f)
                    builder.Append(string.Format("  prewarmTime={0}", prewarmTime));

                return builder;
            }
        }
    }
}
   