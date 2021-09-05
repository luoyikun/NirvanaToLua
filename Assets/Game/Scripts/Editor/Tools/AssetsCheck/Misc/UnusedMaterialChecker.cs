using UnityEngine;
using UnityEditor;
using System.Text;

namespace AssetsCheck
{
    // 检查出没用被引用的材质球，材质球一般都是直接引用的
    class UnusedMaterialChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game"};

        override public string GetErrorDesc()
        {
            return string.Format("存在无用资源");
        }

        override protected void OnCheck()
        {
            // 先构建引用关系
            AssetRefrence.Build("t:prefab", checkDirs);
            AssetRefrence.Build("t:scene", checkDirs);

            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                if (path.StartsWith("Assets/Game/Shaders/"))
                {
                    continue;
                }
                if (path.StartsWith("Assets/Game/Misc/"))
                {
                    continue;
                }

                if (!AssetRefrence.IsBeRefed(path))
                {
                    this.outputList.Add(new CheckItem(path));
                }
            }
        }

       override  protected void OnFix(string[] lines)
        {
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                AssetDatabase.DeleteAsset(lines[i]);
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
                builder.Append(asset);
                return builder;
            }
        }
    }
}