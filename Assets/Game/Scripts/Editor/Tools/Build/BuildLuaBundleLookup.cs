using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text;
using System.Collections.Generic;

namespace Build
{
    // 构建lua 与 AssetBundle的关系表（多对一的关系，知道lua名需要查询到所在ab）
    public class BuildLuaBundleLookup
    {
        public static void Build()
        {
            WriteLookupFile(false);
            WriteLookupFile(true);
        }

        private static void WriteLookupFile(bool isLuajit)
        {
            string lookup_path = isLuajit ? "Assets/Game/LuaBundleJit" : "Assets/Game/LuaBundle";
            string[] guids = AssetDatabase.FindAssets("t:textasset", new string[] { lookup_path });
            Dictionary<string, string> lua_lookup = new Dictionary<string, string>();

            for (int i = 0; i < guids.Length; i++)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[i]);
                var importer = AssetImporter.GetAtPath(path);
                lua_lookup.Add(path.ToLower(), importer.assetBundleName);
            }

            var lookup_sb = new StringBuilder();
            foreach (var kv in lua_lookup)
            {
                lookup_sb.AppendFormat("{0} {1}\n", kv.Key, kv.Value);
            }

            string file_name = isLuajit ? "luajit_bundle_lookup.txt" : "lua_bundle_lookup.txt";
            string file_path = Application.dataPath + "/../" + lookup_path + "/" + file_name;
            File.WriteAllText(file_path, lookup_sb.ToString());
        }
    }
}