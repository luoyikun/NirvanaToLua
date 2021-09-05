using UnityEngine;
using UnityEditor;
using System.IO;
using Nirvana.Editor;
using System.Text;
using System.Collections.Generic;
using System;
using Nirvana;

namespace Build
{
    public static class AssetBundleInstaller
    {
        // 构建强更列表文件
        public static void BuildStrongUpdateLuaFile(InstallBundleSize sizeType)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("return {");

            string file_name = BuilderConfig.GetAssetBundleIntallFilterTxtName(sizeType);
            string path = Path.Combine(Application.dataPath, string.Format("Game/Deploy/Install/{0}.txt", file_name));
            string[] lines = File.ReadAllLines(path);
            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i];
                if (string.IsNullOrEmpty(line))
                {
                    continue;
                }

                if (line.IndexOf("//") >= 0)
                {
                    continue;
                }

                if (line.EndsWith("/"))
                {
                    builder.Append(string.Format("\n    \"^{0}*\",", line));
                }
                else
                {
                    builder.Append(string.Format("\n    \"^{0}\",", line));
                }
            }
            builder.Append("\n}");

            File.WriteAllText(Path.Combine(Application.dataPath, "Game/Lua/config/config_strong_update.lua"), builder.ToString());
        }

        public static void CalcTotalSize(BuildPlatType buildPlatType)
        {
            CalcTotalSize(buildPlatType, InstallBundleSize.sizeL);
            CalcTotalSize(buildPlatType, InstallBundleSize.sizeM);
            CalcTotalSize(buildPlatType, InstallBundleSize.sizeS);
            CalcTotalSize(buildPlatType, InstallBundleSize.sizeXS);
            CalcTotalSize(buildPlatType, InstallBundleSize.sizeIOS);
        }

        // 计算入包大小
        public static void CalcTotalSize(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            Dictionary<string, Hash128> install_list = GetInstallBundlesList(buildPlatType, sizeType);

            long total_size = 0;
            string bundle_dir = BuilderConfig.GetAssetBundlePath(buildPlatType);
            foreach (var kv in install_list)
            {
                string path = Path.Combine(bundle_dir, kv.Key);

                if (Directory.Exists(path))
                {
                    total_size += DirectoryUtil.GetDirectoryLength(path);
                }

                if (File.Exists(path))
                {
                    FileInfo file_info = new FileInfo(path);
                    total_size += file_info.Length;
                }
            }

            int size = Convert.ToInt32(total_size * 1.0f / 1024 / 1024);
            Debug.LogFormat("{0} : {1}M", sizeType, size);

            CheckInstallTxtList(buildPlatType, sizeType);
        }

        // 检查配置
        private static void CheckInstallTxtList(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            HashSet<string> un_match_set = new HashSet<string>();
            GetFilterBundleSet(BuilderConfig.GetAssetBundleMainfest(buildPlatType), sizeType, un_match_set);
            GetFilterBundleSet(BuilderConfig.GetLuaAssetBundleManifest(buildPlatType), sizeType);
            Resources.UnloadUnusedAssets();

            foreach (var item in un_match_set)
            {
                Debug.LogErrorFormat("没找到对应资源：{0}", item);
            }  
        }

        // 建生成各种规格的AssetBundle列表，给sdk用
        public static void WriteInstallBundlesList(BuildPlatType buildPlatType)
        {
            InstallBundleSize[] size_list = 
            {
                InstallBundleSize.sizeL,
                InstallBundleSize.sizeM,
                InstallBundleSize.sizeS,
                InstallBundleSize.sizeXS,
                InstallBundleSize.sizeIOS,
                InstallBundleSize.sizeAll,
            };

            for (int i = 0; i < size_list.Length; i++)
            {
                Dictionary<string, Hash128> install_list = GetInstallBundlesList(buildPlatType, size_list[i]);
                var builder = new StringBuilder();
                foreach (var kv in install_list)
                {
                    if (!String.IsNullOrEmpty(kv.Key))
                    {
                        builder.Append(kv.Key);
                        builder.Append(' ');
                        builder.Append(kv.Value);
                        builder.Append('\n');
                    }
                }

                string assetbundle_path = BuilderConfig.GetAssetBundlePath(buildPlatType);
                string file_name = BuilderConfig.GetAssetBundleInstallListTxtName(size_list[i]);
                var path = Path.Combine(assetbundle_path, string.Format("../{0}.txt", file_name));
                File.WriteAllText(path, builder.ToString());
            }
        }

        // 拷要安装的bundle文件进行StreamAsssets（生成apk时用的是这个目录）
        public static void CopyInstallBundlesToStreamAsssets(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            // 先删除旧目录
            var target_path = "Assets/StreamingAssets/AssetBundle";
            if (Directory.Exists(target_path))
            {
                Directory.Delete(target_path, true);
            }
            Directory.CreateDirectory(target_path);

            // 先删除旧lua目录
            var lua_target_path = Path.Combine(target_path, "LuaAssetBundle");
            Directory.CreateDirectory(lua_target_path);

            // 拷版本号文件
            string bundle_path = BuilderConfig.GetAssetBundlePath(buildPlatType);
            var versionPath = Path.GetFullPath(Path.Combine(bundle_path, "version.txt"));
            File.Copy(versionPath, Path.Combine(target_path, "version.txt"));

            // 拷mainfest文件
            var manifestPath = Path.GetFullPath(Path.Combine(bundle_path, "AssetBundle"));
            File.Copy(manifestPath, Path.Combine(target_path, "AssetBundle"));
            var assetBundleLuaPath = Path.GetFullPath(Path.Combine(bundle_path, "AssetBundle.lua"));
            File.Copy(assetBundleLuaPath, Path.Combine(target_path, "AssetBundle.lua"));

            // 拷Lua mainfest文件
            var luaManifestPath = Path.GetFullPath(Path.Combine(bundle_path, "LuaAssetBundle/LuaAssetBundle"));
            File.Copy(luaManifestPath, Path.Combine(lua_target_path, "LuaAssetBundle"));
            var path = Path.GetFullPath(Path.Combine(bundle_path, "LuaAssetBundle/LuaAssetBundle.lua"));
            File.Copy(path, Path.Combine(lua_target_path, "LuaAssetBundle.lua"));

            // 拷进包AssetBundle文件
            CopyInstallBundles(buildPlatType, sizeType, bundle_path, target_path);

            // 写file_txt文件
            WriteFileListTxt();

            Resources.UnloadUnusedAssets();
        }

        private static void AddManifestBundlesToList(AssetBundleManifest manifest, List<string> list)
        {
            string[] all_assets = manifest.GetAllAssetBundles();
            for (int i = 0; i < all_assets.Length; i++)
            {
                list.Add(string.Format("{0} {1}", all_assets[i], manifest.GetAssetBundleHash(all_assets[i])));
            }
        }

        private static void CopyInstallBundles(BuildPlatType buildPlatType, InstallBundleSize sizeType, string bundlePath, string targetPath)
        {
            Debug.LogFormat("Start Copy Install Bundles:{0}, {1}", sizeType, bundlePath);

            List<string> errorList = new List<string>();
            string[] lines = new string[] { };
            if (InstallBundleSize.sizeAll == sizeType)
            {
                List<string> list = new List<string>();
                AddManifestBundlesToList(BuilderConfig.GetAssetBundleMainfest(buildPlatType), list);
                AddManifestBundlesToList(BuilderConfig.GetLuaAssetBundleManifest(buildPlatType), list);
                lines = list.ToArray();
            }
            else
            {
                string file_name = BuilderConfig.GetAssetBundleInstallListTxtName(sizeType);
                var install_list_txt_path = Path.Combine(bundlePath, string.Format("../{0}.txt", file_name));
                lines = File.ReadAllLines(install_list_txt_path);
            }
          
            bool luajit = (BuildPlatType.Android == buildPlatType || BuildPlatType.AndroidDev == buildPlatType) ;
            for (int i = 0; i < lines.Length; i++)
            {
                if (string.IsNullOrEmpty(lines[i]))
                {
                    continue;
                }

                string[] ary = lines[i].Split(' ');
                if (2 != ary.Length)
                {
                    errorList.Add(lines[i]);
                    Debug.LogErrorFormat("CopyInstallBundlesToStreamAsssets Error! {0}", lines[i]);
                    continue;
                }

                string bundle_name = ary[0];
                string hash = ary[1];

                var src = "";
                var path = "";

                if (bundle_name.StartsWith("lua"))
                {
                    if (bundle_name.IndexOf("jit", 3, 3) > 0)
                    {
                        if (luajit)
                        {
                            src = Path.Combine(bundlePath, "LuaAssetBundle/" + bundle_name);
                            path = Path.Combine(targetPath, "LuaAssetBundle/" + bundle_name);
                        }
                        else
                        {
                            continue;
                        }
                    }
                    else
                    {
                        if (!luajit)
                        {
                            src = Path.Combine(bundlePath, "LuaAssetBundle/" + bundle_name);
                            path = Path.Combine(targetPath, "LuaAssetBundle/" + bundle_name);
                        }
                        else
                        {
                            continue;
                        }
                    }
                }
                else
                {
                    src = Path.Combine(bundlePath, bundle_name);
                    path = Path.Combine(targetPath, bundle_name);
                }

                var pathDir = Path.GetDirectoryName(path);
                if (!Directory.Exists(pathDir))
                {
                    Directory.CreateDirectory(pathDir);
                }

                if (File.Exists(src))
                {
                    File.Copy(src, path + "-" + hash, true);
                }
                else
                {
                    Debug.LogErrorFormat("File Copy Error {0}, file is not exist", src);
                }
            }

            if (0 == errorList.Count)
            {
                Debug.Log("拷贝成功!");
            }
            else
            {
                File.WriteAllLines(Path.Combine(Application.streamingAssetsPath, "error.txt"), errorList.ToArray());
            }
        }

        public static void WriteFileListTxt()
        {
            var fileList = new StringBuilder();
            AssetDatabase.Refresh();
            var guids = AssetDatabase.FindAssets("*", new string[] { "Assets/StreamingAssets" });
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (AssetDatabase.IsValidFolder(path))
                {
                    continue;
                }

                if (Path.GetFileName(path) == "file_list.txt")
                {
                    continue;
                }

                var uri1 = new Uri(Application.streamingAssetsPath + "/");
                var uri2 = new Uri(Path.GetFullPath(path));
                var relPath = uri1.MakeRelativeUri(uri2).ToString();

                fileList.Append(relPath);
                fileList.Append('\n');
            }

            var fileListPath = Path.Combine(Application.streamingAssetsPath, "file_list.txt");
            File.WriteAllText(fileListPath, fileList.ToString());
        }

        // 获得进包列表
        private static Dictionary<string, Hash128> GetInstallBundlesList(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            if (InstallBundleSize.sizeAll == sizeType)
            {
                return GetAllInstallBundlesList(buildPlatType, sizeType);
            }
            else
            {
                return GetInstallBundlesSizeList(buildPlatType, sizeType);
            }
        }

        // 获得进包列表(所有进包)
        private static Dictionary<string, Hash128> GetAllInstallBundlesList(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            var install_list = new Dictionary<string, Hash128>();

            AssetBundleManifest manifest = BuilderConfig.GetAssetBundleMainfest(buildPlatType);
            if (null == manifest)
            {
                Debug.Log("not found manifest");
                return install_list;
            }

            string[] bundles = manifest.GetAllAssetBundles();
            for (int i = 0; i < bundles.Length; i++)
            {
                install_list.Add(bundles[i], manifest.GetAssetBundleHash(bundles[i]));
            }

            // Lua的AssetBundleManifest
            AssetBundleManifest luaManifest = BuilderConfig.GetLuaAssetBundleManifest(buildPlatType);
            if (null == luaManifest)
            {
                Debug.Log("not found lua manifest");
                return install_list;
            }

            bundles = luaManifest.GetAllAssetBundles();
            foreach (var bundle in bundles)
            {
                install_list.Add(bundle, luaManifest.GetAssetBundleHash(bundle));
            }

            Resources.UnloadUnusedAssets();

            return install_list;
        }

        // 获得进包列表（从配置中过滤出，并计算出依赖列表）
        private static Dictionary<string, Hash128> GetInstallBundlesSizeList(BuildPlatType buildPlatType, InstallBundleSize sizeType)
        {
            var install_list = new Dictionary<string, Hash128>();

            AssetBundleManifest manifest = BuilderConfig.GetAssetBundleMainfest(buildPlatType);
            if (null == manifest)
            {
                Debug.Log("not found manifest");
                return install_list;
            }

            HashSet<string> bundle_set = GetFilterBundleSet(manifest, sizeType);
            HashSet<string> depend_bundle_set = GetDependAssetBundles(manifest, bundle_set);

            AssetBundleManifest luaManifest = BuilderConfig.GetLuaAssetBundleManifest(buildPlatType);
            HashSet<string> lua_bundle_set = GetLuaAssetBundles(buildPlatType, luaManifest);

            bundle_set.UnionWith(depend_bundle_set);
            bundle_set.UnionWith(lua_bundle_set);

            foreach (var bundle_name in bundle_set)
            {
                if (lua_bundle_set.Contains(bundle_name))
                {
                    install_list.Add("LuaAssetBundle/" + bundle_name, luaManifest.GetAssetBundleHash(bundle_name));
                }
                else
                {
                    install_list.Add(bundle_name, manifest.GetAssetBundleHash(bundle_name));
                }
                
            }

            Resources.UnloadUnusedAssets();
            return install_list;
        }

        // 根据进包配置过滤出AssetBundle集合
        private static HashSet<string> GetFilterBundleSet(AssetBundleManifest manifest, InstallBundleSize sizeType, HashSet<string> unMatchLineSet = null)
        {
            string file_name = BuilderConfig.GetAssetBundleIntallFilterTxtName(sizeType);
            string path = Path.Combine(Application.dataPath, string.Format("Game/Deploy/Install/{0}.txt", file_name));
            string[] lines = File.ReadAllLines(path);

            string[] allbundles = manifest.GetAllAssetBundles();

            HashSet<string> bundle_set = new HashSet<string>();

            for (int i = 0; i < lines.Length; i++)
            {
                bool is_illegal = true;
                string line = lines[i];

                for (int j = 0; j < allbundles.Length; j++)
                {
                    string bundle = allbundles[j];
                    if (string.IsNullOrEmpty(line)
                        || line.IndexOf("//") >= 0)
                    {
                        is_illegal = false;
                        continue;
                    }

                    if (line.EndsWith("/"))
                    {
                        if (bundle.StartsWith(line))
                        {
                            bundle_set.Add(bundle);
                            is_illegal = false;
                        }
                    }
                    else
                    {
                        if (bundle == line)
                        {
                            bundle_set.Add(bundle);
                            is_illegal = false;
                        }
                    }
                }

                if (is_illegal && null != unMatchLineSet)
                {
                    unMatchLineSet.Add(line);
                }
            }

            return bundle_set;
        }

        // 获得依赖集合
        private static HashSet<string> GetDependAssetBundles(AssetBundleManifest manifest, HashSet<string> bundelsSet)
        {
            HashSet<string> depend_set = new HashSet<string>();
            foreach (var item in bundelsSet)
            {
                string[] depends = manifest.GetAllDependencies(item);
                for (int i = 0; i < depends.Length; i++)
                {
                    depend_set.Add(depends[i]);
                }
            }

            return depend_set;
        }

        // 平台不同，进的lua文件不同
        private static HashSet<string> GetLuaAssetBundles(BuildPlatType buildPlatType, AssetBundleManifest manifest)
        {
            string lua_str = (BuildPlatType.Android == buildPlatType || BuildPlatType.AndroidDev == buildPlatType) ? "luajit/" : "lua/";
            string[] allbundles = manifest.GetAllAssetBundles();

            HashSet<string> bundle_set = new HashSet<string>();
            for (int i = 0; i < allbundles.Length; i++)
            {
                if (allbundles[i].StartsWith(lua_str))
                {
                    bundle_set.Add(allbundles[i]);
                }
            }

            return bundle_set;
        }

        public static void WriteModifyMaterialList(string[] modifyMaterialList)
        {
            var path = Path.Combine(Application.dataPath, "../MaterialList.txt");
            for (int i = 0; i < modifyMaterialList.Length; i++)
            {
                modifyMaterialList[i] = Path.Combine(Application.dataPath, string.Format("../{0}", modifyMaterialList[i]));
            }
            File.WriteAllLines(path, modifyMaterialList);
        }
    }
}
