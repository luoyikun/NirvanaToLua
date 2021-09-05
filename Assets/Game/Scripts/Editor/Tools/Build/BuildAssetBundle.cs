using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Nirvana;
using Newtonsoft.Json;
using NewtonsoftJsonEx;

using UnityObject = UnityEngine.Object;
using DictHashSet = System.Collections.Generic.Dictionary<string, System.Collections.Generic.HashSet<string>>;
using System.Text;

namespace Build
{
    // 生成AssetBundle
    public static class BuildAssetBundle
    {
        class ManifestBundleInfo
        {
            public List<string> deps = new List<string>();
            public string hash;
            public long size;
        }

        // 导出manifest文件到lua文件用
        class ManifestInfo
        {
            public Dictionary<string, ManifestBundleInfo> bundleInfos = new Dictionary<string, ManifestBundleInfo>();
            public string manifestHashCode;
        }

        // 记录assetbundle和assetbundle关联的asset信息
        class BuildInfo
        {
            public BuildInfo(string bundleName)
            {
                AssetBundleName = bundleName;
                AssetHashSet = new HashSet<string>();
            }

            public BuildInfo(string bundleName, string asset)
            {
                AssetBundleName = bundleName;
                AssetHashSet = new HashSet<string>();
                AssetHashSet.Add(asset);
            }

            public string AssetBundleName;
            public HashSet<string> AssetHashSet;
        }

        // 记录asset放在了哪个assetbundle里面
        class BuildAssetInfo
        {
            public BuildAssetInfo(string assetName, string assetBundleName)
            {
                AssetName = assetName;
                AssetBundleName = assetBundleName;
                parentAssetSet = new HashSet<string>();
                parentAbSet = new HashSet<string>();
            }

            public string AssetName;
            public string AssetBundleName;
            public HashSet<string> parentAssetSet;
            public HashSet<string> parentAbSet;
        }

        static Dictionary<string, BuildAssetInfo> BuildAssetInfoDict = new Dictionary<string, BuildAssetInfo>();
        static Dictionary<string, BuildInfo> BuildInfoDict = new Dictionary<string, BuildInfo>();
        static DictHashSet DependenceInfo = new DictHashSet();
        static Dictionary<string, string> AssetToBundleNameDict = new Dictionary<string, string>();

        public static List<string> GetDependencies(string path)
        {
            var files = AssetDatabase.GetDependencies(path);
            return new List<string>(files);
        }

        public static string GetAssetBundleName(string assetName)
        {
            if (assetName.EndsWith(".shader"))
            {
                return "shaders";
            }

            assetName = GetSafePath(assetName);
            var relativePath = assetName.Substring(AssetBundleMarkRule.BaseDir.Length + 1);
            return relativePath.Substring(0, relativePath.Length - Path.GetExtension(relativePath).Length);
        }

        // 构建每个文件的引用关系,这样可知道每个文件被哪些文件引用
        public static void CalcBuildAssetInfo(Dictionary<string, string> dict)
        {
            foreach (var item in dict)
            {
                string assetPath = item.Key;
                string bundleName = item.Value;

                assetPath = GetSafePath(assetPath);
                List<string> dependencies = GetDependencies(assetPath);
                foreach (var dep in dependencies)
                {
                    string depPath = dep.ToLower();

                    BuildAssetInfo buildAssetInfo;
                    if (!BuildAssetInfoDict.TryGetValue(depPath, out buildAssetInfo))
                    {
                        buildAssetInfo = new BuildAssetInfo(depPath, bundleName);
                        BuildAssetInfoDict.Add(depPath, buildAssetInfo);
                    }

                    if (!buildAssetInfo.parentAbSet.Contains(bundleName) 
                        && !assetPath.EndsWith(".unity"))
                    {
                        buildAssetInfo.parentAbSet.Add(bundleName);
                    }

                    buildAssetInfo.parentAssetSet.Add(assetPath);
                }
            }
        }

        // 获得资源引用者的数量
        private static int GetAssetReferCount(string asset)
        {
            BuildAssetInfo buildAssetInfo;
            if (BuildAssetInfoDict.TryGetValue(asset, out buildAssetInfo))
            {
                return buildAssetInfo.parentAssetSet.Count;
            }

            return 0;
        }

        // 获得资源引用者的共同AB名字，如果引用者AB名不同，则返回空
        private static string GetAssetRefersAbName(string asset)
        {
            BuildAssetInfo buildAssetInfo;
            if (!BuildAssetInfoDict.TryGetValue(asset, out buildAssetInfo) 
                || buildAssetInfo.parentAssetSet.Count <= 0
                || buildAssetInfo.parentAbSet.Count != 1)
            {
                return string.Empty;
            }

            string[] keys = buildAssetInfo.parentAbSet.ToArray<string>();
            string bundleName = keys[0];
            return bundleName;
        }

        public static void GetAssetBuildInfo(string asset, string referBundleName)
        {
            asset = GetSafePath(asset);

            List<string> dependencies = GetDependencies(asset);

            foreach (var dep in dependencies)
            {
                string depPath = dep.ToLower();
                int referCount = GetAssetReferCount(depPath);
                string bundleName;
                AssetToBundleNameDict.TryGetValue(depPath, out bundleName);

                // mat 和 shader不单独打包
                if (depPath.EndsWith(".cs") || depPath.EndsWith(".dll") || depPath.EndsWith(".prefab"))
                {
                    continue;
                }

                // 如果不是强指定的AB名字
                bool isNeeToBuildAB = true;
               if (string.IsNullOrEmpty(bundleName))
                {
                    // 很小的资源类型直接打进prefab
                    if (depPath.EndsWith(".mat")
                        || depPath.EndsWith(".overridecontroller")
                        || depPath.EndsWith(".controller")
                        || depPath.EndsWith(".playable"))
                    {
                        isNeeToBuildAB = false;
                        continue;
                    }

                    // 动画类型, 模型类型
                    // a. 50K内，直接打进prefab)
                    // b. 500k内且引用 < 3 打进prefab
                    // c. 2M内且引用为1 打进prefab
                    // d. 3M以内的引用数量为多个，但引用者都是属于同个AB包，则也直接指定同样的AB名
                    // e. 单独打包
                    if (string.IsNullOrEmpty(bundleName) &&
                        (depPath.EndsWith(".anim") || depPath.EndsWith(".fbx")))
                    {
                        FileInfo fileInfo = new FileInfo(Application.dataPath + "/../" + dep);

                        if (fileInfo.Length <= 50 * 1024)
                        {
                            isNeeToBuildAB = false;
                        }
                        else if (fileInfo.Length <= 500 * 1024 && referCount <= 5)
                        {
                            isNeeToBuildAB = false;
                        }
                        else if (fileInfo.Length <= 2 * 1024 * 1024 && referCount == 1)
                        {
                            isNeeToBuildAB = false;
                        }
                        else if (fileInfo.Length <= 3 * 1024 * 1024)
                        {
                            bundleName = GetAssetRefersAbName(depPath);
                        }
                    }

                    // 纹理类型
                    if (string.IsNullOrEmpty(bundleName) && depPath.EndsWith(".tga"))
                    {
                        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(depPath);
                        if (texture.width <= 256 && texture.height <= 256)
                        {
                            if (referCount <= 20) isNeeToBuildAB = false;
                            else bundleName = "texture_bundle";
                        }
                        else if (texture.width <= 512 && texture.height <= 512)
                        {
                            if (referCount <= 10) isNeeToBuildAB = false;
                            else bundleName = "texture_bundle";
                        }
                        else if (texture.width <= 1024 && texture.height <= 1024)
                        {
                            if (1 == referCount)
                            {
                                isNeeToBuildAB = false;
                            }
                            else
                            {
                                bundleName = GetAssetRefersAbName(depPath);
                            }
                        }
                    }

                    // 如果是特效文件夹里的SpriteUI，则根据spritePackingTage来打包
                    if (string.IsNullOrEmpty(bundleName) && dep.StartsWith(AssetBundleMarkRule.EffectTexturesDir))
                    {
                        TextureImporter importer = AssetImporter.GetAtPath(depPath) as TextureImporter;
                        if (null != importer && !string.IsNullOrEmpty(importer.spritePackingTag))
                        {
                            bundleName = importer.spritePackingTag + "_atlas";
                        }
                    }
                }

                // 单独打包,  没有指定ab名字，则根据规则计算ab名字
                if (isNeeToBuildAB)
                {
                    if (string.IsNullOrEmpty(bundleName))
                    {
                        bundleName = GetAssetBundleName(depPath);
                    }
                    AddAssetToBuild(depPath, bundleName);
                }
            }
        }

        public static void AddAssetToBuild(string asset, string bundleName)
        {
            bundleName = GetSafePath(bundleName);
            asset = GetSafePath(asset);

            BuildInfo buildInfo;// = new BuildInfo(bundleName, asset);

            if (!BuildInfoDict.TryGetValue(bundleName, out buildInfo))
            {
                buildInfo = new BuildInfo(bundleName, asset);
                BuildInfoDict.Add(bundleName, buildInfo);
            }
            else
            {
                buildInfo.AssetHashSet.Add(asset);
            }
        }

        public static bool Build(BuildPlatType buildPlatType)
        {
            return Build(BuilderConfig.GetAssetBundlePath(buildPlatType, BuilderConfig.AssetBundlePath));
        }

        public static void BuildLua(BuildPlatType buildPlatType)
        {
            BuildLua(BuilderConfig.GetAssetBundlePath(buildPlatType, BuilderConfig.LuaAssetBundlePath));
        }

        private static bool Build(string outPath)
        {
            Debug.Log("Start Build " + EditorApplication.timeSinceStartup);
            BuildAssetInfoDict.Clear();
            BuildInfoDict.Clear();
            DependenceInfo.Clear();
            AssetToBundleNameDict.Clear();

            AssetDatabase.RemoveUnusedAssetBundleNames();
            var bundleNames = AssetDatabase.GetAllAssetBundleNames();

            Dictionary<string, string> prefabDict = new Dictionary<string, string>();
            Dictionary<string, string> sceneDict = new Dictionary<string, string>();
            Dictionary<string, string> uiTextureDict = new Dictionary<string, string>();
            Dictionary<string, string> miscDict = new Dictionary<string, string>();

            // 获得所有有标记assetbundle名字的资源
            foreach (var bundleName in bundleNames)
            {
                var assets = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
                foreach (var asset in assets)
                {
                    if (!asset.StartsWith(AssetBundleMarkRule.BaseDir))
                    {
                        continue;
                    }

                    if (asset.EndsWith(".prefab"))
                    {
                        prefabDict.Add(asset, bundleName);
                    }
                    else if (asset.EndsWith(".unity"))
                    {
                        sceneDict.Add(asset, bundleName);
                    }
                    else if (asset.StartsWith(AssetBundleMarkRule.UIDir))
                    {
                        TextureImporter importer = AssetImporter.GetAtPath(asset) as TextureImporter;
                        if (importer != null)
                        {
                            uiTextureDict.Add(asset, bundleName);
                        }
                    }
                    if (!asset.EndsWith(".cs") && !asset.EndsWith(".dll") && !bundleName.StartsWith("luajit/") && !bundleName.StartsWith("lua/"))
                    {
                        // 这里不打lua的ab包，放到其他地方打
                        miscDict.Add(asset, bundleName);
                    }

                    AssetToBundleNameDict.Add(asset.ToLower(), bundleName);
                }
            }

            CalcBuildAssetInfo(miscDict);
            CalcBuildAssetInfo(uiTextureDict);
            CalcBuildAssetInfo(prefabDict);
            CalcBuildAssetInfo(sceneDict);

            foreach (var asset in miscDict.Keys)
            {
                var bundleName = miscDict[asset];
                GetAssetBuildInfo(asset, bundleName);
                AddAssetToBuild(asset, bundleName);
            }

            foreach (var uiTexture in uiTextureDict.Keys)
            {
                var bundleName = uiTextureDict[uiTexture];
                AddAssetToBuild(uiTexture, bundleName);
            }

            foreach (var prefab in prefabDict.Keys)
            {
                var bundleName = prefabDict[prefab];
                GetAssetBuildInfo(prefab, bundleName);
                AddAssetToBuild(prefab, bundleName);
            }

            foreach (var scene in sceneDict.Keys)
            {
                var bundleName = sceneDict[scene];
                GetAssetBuildInfo(scene, bundleName);
                AddAssetToBuild(scene, bundleName);
            }

            List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
            foreach (var key in BuildInfoDict.Keys)
            {
                var buildInfo = BuildInfoDict[key];
                AssetBundleBuild build = new AssetBundleBuild();
                build.assetBundleName = FixAssetBundleName(buildInfo.AssetBundleName);
                build.assetNames = buildInfo.AssetHashSet.ToArray();

                if (!String.IsNullOrEmpty(build.assetBundleName))
                {
                    assetBundleBuildList.Add(build);
                }
            }

            if (!Directory.Exists(outPath))
            {
                Directory.CreateDirectory(outPath);
            }

            bool check_flag = true;
            for (int i = 0; i < assetBundleBuildList.Count; i++)
            {
                string path = Path.Combine(outPath, assetBundleBuildList[i].assetBundleName);
                if (Directory.Exists(path))
                {
                    Debug.LogErrorFormat("Build AssetBundle fail, because exist same name folder {0}", path);
                    check_flag = false;
                }
            }

            if (!check_flag)
            {
                return false;
            }

            Debug.Log("Start Build AssetBundle " + EditorApplication.timeSinceStartup);
            AssetBundleManifest mainfest = BuildPipeline.BuildAssetBundles(outPath, assetBundleBuildList.ToArray(), BuildAssetBundleOptions.ChunkBasedCompression, EditorUserBuildSettings.activeBuildTarget);
            if (mainfest)
            {
                Debug.Log("Build AssetBundle succ " + EditorApplication.timeSinceStartup);
                ExportManifestToLua(mainfest, Path.Combine(outPath, "AssetBundle.lua"));

                // 压缩AssetBundle文件成zip格式的压缩包
                ZipUtils.ZipFile(Path.Combine(outPath, "AssetBundle.lua"), outPath);
                return true;
            }
            else
            {
                Debug.Log("Build AssetBundle fail " + EditorApplication.timeSinceStartup);
                return false;
            }
        }

        private static void BuildLua(string outPath)
        {
            AssetDatabase.RemoveUnusedAssetBundleNames();

            Dictionary<string, BuildInfo> buildInfoDict = new Dictionary<string, BuildInfo>();


            var bundleNames = AssetDatabase.GetAllAssetBundleNames();
            foreach (var bundleName in bundleNames)
            {
                if (!bundleName.StartsWith("lua/") && !bundleName.StartsWith("luajit/"))
                {
                    continue;
                }

                var assets = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
                foreach (var asset in assets)
                {
                    BuildInfo buildInfo;
                    if (!buildInfoDict.TryGetValue(bundleName, out buildInfo))
                    {
                        buildInfo = new BuildInfo(bundleName);
                        buildInfoDict.Add(bundleName, buildInfo);
                    }

                    buildInfo.AssetHashSet.Add(asset);
                }
            }

            List<AssetBundleBuild> assetBundles = new List<AssetBundleBuild>();
            foreach (var bundleName in buildInfoDict.Keys)
            {
                AssetBundleBuild assetBundleBuild = new AssetBundleBuild();

                assetBundleBuild.assetBundleName = bundleName;
                assetBundleBuild.assetNames = buildInfoDict[bundleName].AssetHashSet.ToArray();

                assetBundles.Add(assetBundleBuild);
            }

            if (!Directory.Exists(outPath))
            {
                Directory.CreateDirectory(outPath);
            }

            AssetBundleManifest manifest = BuildPipeline.BuildAssetBundles(
                outPath,
                assetBundles.ToArray(),
                BuildAssetBundleOptions.ChunkBasedCompression,
                EditorUserBuildSettings.activeBuildTarget);

            if (manifest)
            {
                Debug.Log("Build Lua AssetBundle succ " + EditorApplication.timeSinceStartup);
                ExportManifestInfoToLua(manifest, Path.Combine(outPath, "LuaAssetBundle.lua"));

                // 压缩LuaAssetBundle文件成zip格式的压缩包
                ZipUtils.ZipFile(Path.Combine(outPath, "LuaAssetBundle.lua"), outPath);
            }
            else
            {
                Debug.Log("Build Lua AssetBundle fail " + EditorApplication.timeSinceStartup);
            }
        }

        /// <summary>
        /// 写出资源热更文件
        /// </summary>
        public static void ExportManifestToLua(AssetBundleManifest manifest, string outPath)
        {
            ManifestInfo manifestInfo = new ManifestInfo();
            var baseDir = Path.GetDirectoryName(outPath);

            var allAssetBundles = manifest.GetAllAssetBundles();
            foreach (var assetBundle in allAssetBundles)
            {
                if (!String.IsNullOrEmpty(assetBundle))
                {
                    ManifestBundleInfo manifestBundleInfo = new ManifestBundleInfo();
                    manifestInfo.bundleInfos.Add(assetBundle, manifestBundleInfo);

                    manifestBundleInfo.hash = manifest.GetAssetBundleHash(assetBundle).ToString();

                    FileInfo fileInfo = new FileInfo(Path.Combine(baseDir, assetBundle));
                    if (fileInfo.Exists)
                    {
                        manifestBundleInfo.size = fileInfo.Length;
                    }

                    var dependencies = manifest.GetAllDependencies(assetBundle);
                    for (int i = 0; i < dependencies.Length; ++ i)
                    {
                        if (!string.IsNullOrEmpty(dependencies[i]))
                        {
                            manifestBundleInfo.deps.Add(dependencies[i]);
                        }
                    }
                }
            }

            manifestInfo.manifestHashCode = manifest.CalculateVersion();

            var jsonStr = JsonConvert.SerializeObject(manifestInfo, JSONEditorHelper.RTJsonSerializerSettings);
            var luaStr = "local empty = {}\nreturn\n" + JSon2Lua.IndentedJSonString2Lua(jsonStr, "empty");

            var directory = Path.GetDirectoryName(outPath);
            if (!Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }

            File.WriteAllText(outPath, luaStr);
        }

        /// <summary>
        /// 写出Lua热更文件
        /// </summary>
        private static void ExportManifestInfoToLua(AssetBundleManifest manifest, string outPath)
        {
            ManifestInfo manifestInfo = new ManifestInfo();
            var baseDir = Path.GetDirectoryName(outPath);

            var allAssetBundles = manifest.GetAllAssetBundles();
            foreach (var assetBundle in allAssetBundles)
            {
                if (!String.IsNullOrEmpty(assetBundle))
                {
                    ManifestBundleInfo manifestBundleInfo = new ManifestBundleInfo();
                    manifestInfo.bundleInfos.Add(assetBundle, manifestBundleInfo);

                    manifestBundleInfo.hash = manifest.GetAssetBundleHash(assetBundle).ToString();

                    FileInfo fileInfo = new FileInfo(Path.Combine(baseDir, assetBundle));
                    if (fileInfo.Exists)
                    {
                        manifestBundleInfo.size = fileInfo.Length;
                    }

                    var assets = AssetDatabase.GetAssetPathsFromAssetBundle(assetBundle);
                    manifestBundleInfo.deps.AddRange(assets);
                }
            }

            manifestInfo.manifestHashCode = manifest.CalculateVersion();

            var jsonStr = JsonConvert.SerializeObject(manifestInfo, JSONEditorHelper.RTJsonSerializerSettings);
            var luaStr = "local empty = {}\nreturn\n" + JSon2Lua.IndentedJSonString2Lua(jsonStr, "empty");

            var directory = Path.GetDirectoryName(outPath);
            if (!Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }

            /// fix bug code
            string fixCode = File.ReadAllText(string.Format("{0}/Game/FixBug/fixcode_20190420.txt", Application.dataPath)) + "\n\n";
            luaStr = fixCode + luaStr;
            File.WriteAllText(outPath, luaStr);
        }


        private static void RemoveRepeatFromBuildInfoDic(string assetName)
        {
            foreach (var item in BuildInfoDict)
            {
                if (item.Value.AssetHashSet.Contains(assetName))
                {
                    item.Value.AssetHashSet.Remove(assetName);
                }
            }
        }

        private static void CollectFolderPrefabs(string folder, Dictionary<string, List<string>> prefabDict)
        {
            folder = GetSafePath(folder);
            var files = Directory.GetFiles(folder, "*.prefab", SearchOption.TopDirectoryOnly);
            List<string> folderPrefabs = new List<string>(files);
            prefabDict.Add(folder, folderPrefabs);

            var subFolders = Directory.GetDirectories(folder);
            foreach (var subFolder in subFolders)
            {
                CollectFolderPrefabs(subFolder, prefabDict);
            }
        }

        private static string GetSafePath(string path)
        {
            return path.ToLower().Replace("\\", "/");
        }

        private static string FixAssetBundleName(string bundleName)
        {
            bundleName = bundleName.Replace(" ", "");
            bundleName = bundleName.Replace("—", "-");
            bundleName = Regex.Replace(bundleName, "[\u4E00-\u9FA5]+", ""); //去除汉字

            return bundleName;
        }
    }
}
