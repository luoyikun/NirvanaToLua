using UnityEngine;
using UnityEditor;
using System.IO;
using Nirvana.Editor;

namespace Build
{
    public enum BuildPlatType
    {
        AndroidDev,
        IOSDev,
        WindowsDev,
        Android,
        IOS,
        Windows,
    }

    public enum InstallBundleSize
    {
        sizeL = 0,
        sizeM,
        sizeS,
        sizeXS,
        sizeIOS,
        sizeAll,
    }

    public class BuilderConfig : ScriptableObject
    {
        public static readonly string AssetBundlePath = "AssetBundle";
        public static readonly string LuaAssetBundlePath = "AssetBundle/LuaAssetBundle";

        // 获得AssetBundle的路径
        public static string GetAssetBundlePath(BuildPlatType buildPlatType, string pathSubfix = "AssetBundle")
        {
            if (BuildPlatType.AndroidDev == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundleDev/Android/" + pathSubfix);
            if (BuildPlatType.IOSDev == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundleDev/iOS/" + pathSubfix);
            if (BuildPlatType.WindowsDev == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundleDev/Windows/" + pathSubfix);
            if (BuildPlatType.Android == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundle/Android/" + pathSubfix);
            if (BuildPlatType.IOS == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundle/iOS/" + pathSubfix);
            if (BuildPlatType.Windows == buildPlatType)
                return Path.Combine(Application.dataPath, "../../AssetBundle/Windows/" + pathSubfix);

            return string.Empty;
        }

        public static string GetOutputPlayerPath(BuildPlatType buildPlatType)
        {
            if (BuildPlatType.AndroidDev == buildPlatType || BuildPlatType.Android == buildPlatType)
            {
                return "Build/android/game.apk";
            }

            if (BuildPlatType.WindowsDev == buildPlatType || BuildPlatType.Windows == buildPlatType)
            {
                return "Build/windows/Game.exe";
            }

            return string.Empty;
        }

        public static string GetOutputProjectPath(BuildPlatType buildPlatType)
        {
            if (BuildPlatType.AndroidDev == buildPlatType || BuildPlatType.Android == buildPlatType)
            {
                return "../sdk/android";
            }
            
            else if (BuildPlatType.IOSDev == buildPlatType || BuildPlatType.IOS == buildPlatType)
            {
                return "../sdk/ios/ios";
            }

            return string.Empty;
        }

        public static BuildSetting GetBuildSetting(BuildPlatType buildPlatType)
        {
            string name = string.Empty;
            if (BuildPlatType.AndroidDev == buildPlatType) name = "Android_Dev";
            if (BuildPlatType.WindowsDev == buildPlatType) name = "Windows_Dev";
            if (BuildPlatType.IOSDev == buildPlatType) name = "iOS_Dev";
            if (BuildPlatType.Android == buildPlatType) name = "Android";
            if (BuildPlatType.Windows == buildPlatType) name = "Windows";
            if (BuildPlatType.IOS == buildPlatType) name = "iOS";

            return AssetDatabase.LoadAssetAtPath<BuildSetting>(string.Format("Assets/Game/Deploy/Dev/{0}.asset", name));
        }

        public static BuildDevice GetBuildDevice(BuildPlatType buildPlatType)
        {
            if (BuildPlatType.AndroidDev == buildPlatType || BuildPlatType.Android == buildPlatType)
                return BuildDevice.Android;
            if (BuildPlatType.IOSDev == buildPlatType || BuildPlatType.IOS == buildPlatType)
                return BuildDevice.iOS;
            if (BuildPlatType.WindowsDev == buildPlatType || BuildPlatType.Windows == buildPlatType)
                return BuildDevice.Desktop;

            return BuildDevice.Desktop;
        }

        public static AssetBundleManifest GetAssetBundleMainfest(BuildPlatType buildPlatType)
        {
            AssetBundle.UnloadAllAssetBundles(false);

            string assetBundlePath = GetAssetBundlePath(buildPlatType, AssetBundlePath);
            var manifestPath = Path.GetFullPath(Path.Combine(assetBundlePath, "AssetBundle"));
            var manifestData = File.ReadAllBytes(manifestPath);
            var manifestBundle = AssetBundle.LoadFromMemory(manifestData);
            if (manifestBundle == null)
            {
                Debug.LogErrorFormat("Can not open manifest bundle at path: {0}", assetBundlePath);
                return null;
            }

            return manifestBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        public static AssetBundleManifest GetLuaAssetBundleManifest(BuildPlatType buildPlatType)
        {
            AssetBundle.UnloadAllAssetBundles(false);

            var assetBundlePath = GetAssetBundlePath(buildPlatType, LuaAssetBundlePath);
            var manifestPath = Path.GetFullPath(Path.Combine(assetBundlePath, "LuaAssetBundle"));
            var manifestData = File.ReadAllBytes(manifestPath);

            var manifestBundle = AssetBundle.LoadFromMemory(manifestData);
            if (manifestBundle == null)
            {
                Debug.LogErrorFormat("Can not open lua manifest bundle at path: {0}", assetBundlePath);
                return null;
            }

            return manifestBundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        public static string GetAssetBundleInstallListTxtName(InstallBundleSize sizeType)
        {
            if (InstallBundleSize.sizeL == sizeType) return "install_bundles_l";
            if (InstallBundleSize.sizeM == sizeType) return "install_bundles_m";
            if (InstallBundleSize.sizeS == sizeType) return "install_bundles_s";
            if (InstallBundleSize.sizeXS == sizeType) return "install_bundles_xs";
            if (InstallBundleSize.sizeIOS == sizeType) return "install_bundles_ios";
            if (InstallBundleSize.sizeAll == sizeType) return "install_bundles_all";

            return string.Empty;
        }

        public static string GetAssetBundleIntallFilterTxtName(InstallBundleSize sizeType)
        {
            if (InstallBundleSize.sizeL == sizeType) return "InstallBundles_L";
            if (InstallBundleSize.sizeM == sizeType) return "InstallBundles_M";
            if (InstallBundleSize.sizeS == sizeType) return "InstallBundles_S";
            if (InstallBundleSize.sizeXS == sizeType) return "InstallBundles_XS";
            if (InstallBundleSize.sizeIOS == sizeType) return "InstallBundles_IOS";

            return string.Empty;
        }
    }
}