using UnityEngine;
using UnityEditor;
using System.Text;

namespace AssetsCheck
{
    class SceneModelChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Environments",
                                        "Assets/Game/CG"};

        override public string GetErrorDesc()
        {
            return string.Format("1.场景相关的模型网格没有压缩 2.isReadable被开启 3.没有开启optimizeMesh 4.没有开启weldVertices");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:model", checkDirs);

            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                ModelImporter importer = AssetImporter.GetAtPath(path) as ModelImporter;

                CheckItem item = new CheckItem();
                item.asset = path;

                item.meshCompression = importer.meshCompression;
                item.readWriteEnabled = importer.isReadable;
                item.optimizeMesh = importer.optimizeMesh;
                item.weldVertices = importer.weldVertices;

                if (item.meshCompression < ModelImporterMeshCompression.Medium
                    || item.readWriteEnabled
                    || !item.optimizeMesh
                    || !item.weldVertices)
                {
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

                string spearator = "    ";
                string path = lines[i].Split(spearator.ToCharArray())[0];
                ModelImporter importer = AssetImporter.GetAtPath(path) as ModelImporter;
                if (null != importer)
                {
                    importer.meshCompression = ModelImporterMeshCompression.Medium;
                    importer.isReadable = false;
                    importer.optimizeMesh = true;
                    importer.weldVertices = true;
                    importer.SaveAndReimport();
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public ModelImporterMeshCompression meshCompression;
            public bool readWriteEnabled;
            public bool optimizeMesh;
            public bool weldVertices;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);

                if (meshCompression <= ModelImporterMeshCompression.Medium)
                    builder.Append(string.Format("   meshCompression={0}", meshCompression));
                if (readWriteEnabled)
                    builder.Append("   readWriteEnabled=true");
                if (!optimizeMesh)
                    builder.Append("   optimizeMesh=false");
                if (!weldVertices)
                    builder.Append("   weldVertices=false");

                return builder;
            }
        }
    }
}
