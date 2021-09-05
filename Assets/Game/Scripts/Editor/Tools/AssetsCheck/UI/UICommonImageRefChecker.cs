using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace AssetsCheck
{
    // 公共图集理论上不应该只被一个模块使用，出现这种情况很可能是技术在做功能时随便把图放到images里
    class UICommonImageRefChecker : BaseChecker
    {
        // 指定要检查的文件夹
        private string[] checkDirs = { "Assets/Game/UIs/Views" };

        private string[] images = { "Assets/Game/UIs/Images4" };
        private int minRefModuleCount = 1;

        override public string GetErrorDesc()
        {
            return string.Format("资源放在公共图集里，但却只存在有一个模块对此引用");
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

        override protected void OnFix(string[] lines)
        {
            Dictionary<string, string[]> ref_dic = new Dictionary<string, string[]>();
            this.GetLessCountRefDic(ref_dic, minRefModuleCount);

            foreach (var kv in ref_dic)
            {
                string images_path = this.GetImagePath(kv.Value);
                if (!string.IsNullOrEmpty(images_path))
                {
                    string file_name = kv.Key.Substring(kv.Key.LastIndexOf("/") + 1);
                    AssetDatabase.MoveAsset(kv.Key, images_path + "/" + file_name);
                }
            }
        }

        private string GetImagePath(string[] paths)
        {
            for (int i = 0; i < paths.Length; i++)
            {
                string path = paths[i];
                while (path.LastIndexOf("/") >= 0)
                {
                    path = path.Substring(0, path.LastIndexOf("/"));
                    if (Directory.Exists(Application.dataPath + string.Format("/{0}/Images", path.Replace("Assets/", ""))))
                    {
                        return path + "/Images";
                    }
                }
            }

            return string.Empty;
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

                if (refBundleNames.Count  > 0 && refBundleNames.Count  <= minRefCount)   // 少于N个引用，理论上不应该在common里
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