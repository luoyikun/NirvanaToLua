using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;

namespace AssetsCheck
{
    class AssetRefrence
    {
        // 引用集合，如A资源被B,C资源引用
        private static Dictionary<string, HashSet<string>> refDic = new Dictionary<string, HashSet<string>>();

        // 构建资源的引用关系
        public static void Build(string filter, string[] searchDirs)
        {
            string[] guids = AssetDatabase.FindAssets(filter, searchDirs);
            foreach (var guid in guids)
            {
                var asset_path = AssetDatabase.GUIDToAssetPath(guid);
                string[] depends = AssetDatabase.GetDependencies(asset_path);

                foreach (var depend in depends)
                {
                    HashSet<string> hashset;
                    if (!refDic.TryGetValue(depend, out hashset))
                    {
                        hashset = new HashSet<string>();
                        refDic.Add(depend, hashset);
                    }
                    if (!hashset.Contains(asset_path))
                    {
                        hashset.Add(asset_path);
                    }
                }
            }
        }

        // 获得A资源被哪些资源引用
        public static string[] GetRefAssets(string asset)
        {
            HashSet<string> hashset;
            if (!refDic.TryGetValue(asset, out hashset))
            {
                return new string[] { };
            }

            return hashset.ToArray<string>();
        }

        // 资源是否被引用
        public static bool IsBeRefed(string asset)
        {
            return refDic.ContainsKey(asset);
        }
    }
}
