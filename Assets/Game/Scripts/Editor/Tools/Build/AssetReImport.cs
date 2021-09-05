using UnityEngine;
using UnityEditor;
using System.IO;

namespace Build
{
    public class AssetReImport
    {
        public static void ReImport()
        {
            ReImportComplieLua();
            ReImportReBuildMaterial();
        }

        private static void ReImportComplieLua()
        {
            string[] checkDirs =
{
                "Assets/Game/LuaBundle",
                "Assets/Game/LuaBundleJit",
            };

            string[] guids = AssetDatabase.FindAssets("t:textasset", checkDirs);
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                AssetImporter importer = AssetImporter.GetAtPath(path);
                if (string.IsNullOrEmpty(importer.assetBundleName))
                {
                    importer.SaveAndReimport();
                }
            }
        }

        private static void ReImportReBuildMaterial()
        {
            string[] checkDirs =
{
                "Assets/Game/Shaders/Materials",
            };

            string[] guids = AssetDatabase.FindAssets("t:material", checkDirs);
            foreach (var guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                AssetImporter importer = AssetImporter.GetAtPath(path);
                if (string.IsNullOrEmpty(importer.assetBundleName))
                {
                    importer.SaveAndReimport();
                }
            }
        }
    }
}