using UnityEngine;
using UnityEditor;
using System.Text;
using System.Collections.Generic;

namespace AssetsCheck
{
    class UIIconmageRefChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };

        private string[] images = { "Assets/Game/UIs/Icons" };
        private int minRefModuleCount = 1;

        override public string GetErrorDesc()
        {
            return string.Format("物品，技能图标类的资源不允许被其他模块直接引用");
        }

        override protected void OnCheck()
        {
            Dictionary<string, string[]> ref_dic = new Dictionary<string, string[]>();
            this.GetLessCountRefDic(ref_dic, minRefModuleCount);

            foreach (var kv in ref_dic)
            {
                CheckItem item = new CheckItem();
                item.asset = kv.Key;
                item.refs = kv.Value;
                this.outputList.Add(item);
            }
        }

        // 计算少于某个数量的引用
        private void GetLessCountRefDic(Dictionary<string, string[]> refDic, int minRefCount)
        {
            AssetRefrence.Build("t:prefab", checkDirs);

            string[] guids = AssetDatabase.FindAssets("t:texture2d", images);
            Dictionary<string, string[]> asset_dic = new Dictionary<string, string[]>();
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                asset_dic.Add(asset_path, AssetRefrence.GetRefAssets(asset_path));
            }

            foreach (var kv in asset_dic)
            {
                string[] refpath = kv.Value;
                HashSet<string> refBundleNames = new HashSet<string>();
                for (int i = 0; i < refpath.Length; i++)
                {
                    string bundle_name = AssetImporter.GetAtPath(refpath[i]).assetBundleName;
                    if (!string.IsNullOrEmpty(bundle_name))
                    {
                        refBundleNames.Add(bundle_name);
                    }
                }

                if (refBundleNames.Count > 0 && refBundleNames.Count <= minRefCount) 
                {
                    refDic.Add(kv.Key, kv.Value);
                }
            }
        }

        struct CheckItem : ICheckItem
        {
            public string asset;
            public string[] refs;

            public string MainKey
            {
                get { return this.asset; }
            }

            public StringBuilder Output()
            {
                StringBuilder builder = new StringBuilder();
                builder.Append(asset);
                for (int i = 0; i < refs.Length; i++)
                {
                    builder.Append("\n");
                    builder.Append(string.Format("      被 {0} 引用", refs[i]));
                }

                return builder;
            }
        }
    }
}