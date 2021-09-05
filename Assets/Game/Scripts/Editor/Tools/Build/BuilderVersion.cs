using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Nirvana;

namespace Build
{
    // 记录版本号
    public class BuilderVersion
    {
        public static void WriteLuaVersion(BuildPlatType buildPlatType)
        {
            string outputPath = BuilderConfig.GetAssetBundlePath(buildPlatType, BuilderConfig.LuaAssetBundlePath);


            var manifestPath = Path.GetFullPath(Path.Combine(outputPath, "LuaAssetBundle"));
            var manifestData = File.ReadAllBytes(manifestPath);

            var manifestBundle = AssetBundle.LoadFromMemory(manifestData);
            if (manifestBundle == null)
            {
                Debug.LogError("no lua asset manifest bundle");
                return;
            }

            var manifestAsset = manifestBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
            if(manifestAsset == null)
            {
                Debug.LogError("no lua asset bundle manifest");
                return;
            }

            WriteLuaVersion(manifestAsset, outputPath);
        }

        private static void WriteLuaVersion(AssetBundleManifest manifest, string outputPath)
        {
            if (manifest == null)
            {
                return;
            }

            File.WriteAllText(
                Path.Combine(outputPath, "lua_version.txt"),
                manifest.CalculateVersion());

            var bundles = manifest.GetAllAssetBundles();
            var sizeList = new StringBuilder();
            foreach (var bundle in bundles)
            {
                var fileInfo = new FileInfo(Path.Combine(outputPath, bundle));
                sizeList.AppendFormat("{0} {1}\n", bundle, fileInfo.Length);
            }

            var sizePath = Path.Combine(outputPath, "lua_file_info.txt");
            File.WriteAllText(sizePath, sizeList.ToString());
        }

        public static void WriteVersion(BuildPlatType buildPlatType)
        {
            string output_path = BuilderConfig.GetAssetBundlePath(buildPlatType, "AssetBundle");

            var manifestPath = Path.GetFullPath(Path.Combine(output_path, "AssetBundle"));
            var manifestData = File.ReadAllBytes(manifestPath);
            AssetBundle.UnloadAllAssetBundles(true);
            var manifestBundle = AssetBundle.LoadFromMemory(manifestData);
            if (null == manifestBundle)
            {
                Debug.LogError("no asset mainfest bundle");
                return;
            }

            var manifest = manifestBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
            if (null == manifest)
            {
                Debug.LogError("no asset bundle manifest");
                return;
            }

            WriteVersion(manifest, output_path);
        }

        private static void WriteVersion(AssetBundleManifest manifest, string outputPath)
        {
            if (null == manifest)
            {
                return;
            }

            var bundles = manifest.GetAllAssetBundles();
            var reserveFiles = new HashSet<string>();
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "version.txt")));
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "file_info.txt")));
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "AssetBundle")));
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "AssetBundle.manifest")));
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "AssetBundle.lua")));
            reserveFiles.Add(
                Path.GetFullPath(Path.Combine(outputPath, "AssetBundle.zip")));

            foreach (var bundle in bundles)
            {
                var path = Path.Combine(outputPath, bundle);
                path = Path.GetFullPath(path);
                reserveFiles.Add(path);
                reserveFiles.Add(path + ".manifest");
            }

            var files = Directory.GetFiles(
                outputPath, "*", SearchOption.AllDirectories);
            foreach (var file in files)
            {
                var path = Path.GetFullPath(file);
                if (!reserveFiles.Contains(path) && !path.EndsWith(".meta") && !file.Contains("LuaAssetBundle"))
                {
                    Debug.Log("Remove redundancy asset bundle: " + file);
                    if (File.Exists(path))
                    {
                        File.Delete(path);
                    }
                }
            }

            File.WriteAllText(
                Path.Combine(outputPath, "version.txt"),
                manifest.CalculateVersion());

            var sizeList = new StringBuilder();
            foreach (var bundle in bundles)
            {
                var bundlePath = Path.Combine(outputPath, bundle);
                if (!File.Exists(bundlePath))
                {
                    Debug.LogErrorFormat("bundle not exist : {0}", bundlePath);
                    continue;
                }

                var fileInfo = new FileInfo(bundlePath);
                sizeList.AppendFormat("{0} {1}\n", bundle, fileInfo.Length);
            }

            var sizePath = Path.Combine(outputPath, "file_info.txt");
            File.WriteAllText(sizePath, sizeList.ToString());
        }
    }
}