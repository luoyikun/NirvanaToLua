using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;

namespace AssetsCheck
{
    class ActorModelChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Actors" };

        override public string GetErrorDesc()
        {
            return string.Format("1.角色相关模型网格没有压缩 2.isReadable被开启 3.没有开启optimizeMesh 4.没有开启weldVertices");
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

                if (item.meshCompression <= ModelImporterMeshCompression.Off
                    || item.readWriteEnabled 
                    || !item.optimizeMesh
                    || !item.weldVertices)
                {
                    this.outputList.Add(item);
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
                if (meshCompression <= ModelImporterMeshCompression.Off)
                        builder.Append(string.Format("   meshCompression={0}", meshCompression));

                if (readWriteEnabled) builder.Append("   readWriteEnabled=true");
                if (!optimizeMesh) builder.Append("   optimizeMesh=false");
                if (!weldVertices) builder.Append("   weldVertices=false");

                return builder;
            }
        }
    }
}
