using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    // 检查出没有静态引用并且没有标记动态引用的资源。包括prefab, mat, texture, textAsset
    class UnusedAssetChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views",
                                        "Assets/Game/UIs/Images2",
                                        "Assets/Game/UIs/Images3"};

        override public string GetErrorDesc()
        {
            return string.Format("存在无用资源");
        }

        override protected void OnCheck()
        {
            // 先构建引用关系
            AssetRefrence.Build("t:prefab", checkDirs);
            AssetRefrence.Build("t:material", checkDirs);

            string[] guids = AssetDatabase.FindAssets("t:Object", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                if (!AssetDatabase.IsValidFolder(path) && 
                    !AssetRefrence.IsBeRefed(path))
                {
                    string[] labels = AssetDatabase.GetLabels(AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path));
                    if (0 == labels.Length  || labels[0] != "Dynamic Reference")
                    {
                        this.outputList.Add(new CheckItem(path));
                    }
                }
            }
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
