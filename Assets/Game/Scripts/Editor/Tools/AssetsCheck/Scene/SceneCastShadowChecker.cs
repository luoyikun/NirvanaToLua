using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;
using System.Text;

namespace AssetsCheck
{
    class SceneCastShadowChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Environments" };

        override public string GetErrorDesc()
        {
            return string.Format("场景上的对象不能开启投射阴影");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:prefab", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject gameobj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
                var components = gameobj.GetComponentsInChildren<Renderer>(true);
                for (int i = 0; i < components.Length; i++)
                {
                    if (ShadowCastingMode.Off !=  components[i].shadowCastingMode)
                    {
                        CheckItem item = new CheckItem();
                        item.asset = path;
                        this.outputList.Add(item);
                    }
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
                if (null == gameobj)
                {
                    continue;
                }

                var components = gameobj.GetComponentsInChildren<Renderer>(true);
                for (int j = 0; j < components.Length; j++)
                {
                    if (ShadowCastingMode.Off != components[j].shadowCastingMode)
                    {
                        components[j].shadowCastingMode = ShadowCastingMode.Off;
                    }
                }
            }

            AssetDatabase.SaveAssets();
        }

        struct CheckItem : ICheckItem
        {
            public string asset;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);
                return builder;
            }
        }
    }
}
