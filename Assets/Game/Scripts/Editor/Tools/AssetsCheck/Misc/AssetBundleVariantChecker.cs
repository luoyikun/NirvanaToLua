using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace AssetsCheck
{
    class AssetBundleVariantChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/Effects2"};

        override public string GetErrorDesc()
        {
            return string.Format("禁止使用AssetBundle别名");
        }

        override protected void OnCheck()
        {
            string[] guids = AssetDatabase.FindAssets("t:Object", checkDirs);
            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                AssetImporter importer = AssetImporter.GetAtPath(path);
                if (!string.IsNullOrEmpty(importer.assetBundleVariant))
                {
                    CheckItem item = new CheckItem();
                    item.asset = path;
                    item.assetBundleVariant = importer.assetBundleVariant;
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

                string separator = "    ";
                string path = lines[i].Split(separator.ToCharArray())[0];
                AssetImporter importer = AssetImporter.GetAtPath(path);
                if (null != importer)
                {
                    importer.assetBundleVariant = string.Empty;
                    importer.SaveAndReimport();
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string assetBundleVariant;

            public CheckItem(string asset)
            {
                this.asset = asset;
                this.assetBundleVariant = "";
            }

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(string.Format("{0}   {1}", asset, assetBundleVariant));
                return builder;
            }
        }
    }
}
