using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public static class AssetBundleMarkRule
{
    public static readonly string BaseDir = "Assets/Game";
    public static readonly string FixBugDir = "Assets/Game/FixBug";
    public static readonly string UIDir = BaseDir + "/UIs";
    public static readonly string RawImageDir = UIDir + "/RawImages";
    public static readonly string ImageDir = UIDir + "/Images";
    public static readonly string Image2Dir = UIDir + "/Images2";
    public static readonly string MainUIImageDir = UIDir + "/Views/MainUI/";
    public static readonly string ShaderDir = BaseDir + "/Shaders";
    public static readonly string AutoShaderDir = BaseDir + "/Shaders/Materials";
    public static readonly string AudioDir = BaseDir + "/Audios";
    public static readonly string EnvironmentsDir = BaseDir + "/Environments";
    public static readonly string ActorsDir = BaseDir + "/Actors";
    public static readonly string RoleDir = ActorsDir + "/Role";
    public static readonly string WeaponDir = ActorsDir + "/Weapon";
    public static readonly string LuaBundleDir = BaseDir + "/LuaBundle";
    public static readonly string LuaBundleJitDir = BaseDir + "/LuaBundleJit";
    public static readonly string FontDir = UIDir + "/Fonts";
    public static readonly string TTFDir = UIDir + "/TTF";
    public static readonly string MiscQingGongDir = BaseDir + "/Misc/QingGong";
    public static readonly string EffectTexturesDir = BaseDir + "/Effects/Textures";
    public static readonly string EffectsActorMountFazhenPefabDir = BaseDir + "/Effects/Prefab/Actor/Mount";

    // boss mingjiang
    public static readonly string EffectsPrefabDir = BaseDir + "/Effects/";
    public static readonly string EffectsPrefabBossDir = BaseDir + "/Effects/Prefab/BOSS/";
    public static readonly string EffectsPrefabMingjiangDir = BaseDir + "/Effects/Prefab/Mingjiang/";

    public static readonly string IGNORE_MARK = "ignore_mark";
    private static readonly Regex LogicRegex = new Regex(@".+logic\d+\.unity");
    private static readonly Regex SceneNameRegex = new Regex(@".+_");

    private static char[] PathSeperator = new char[]
    {
        '/',
        '\\',
    };

    private static string GetRelativeDirPath(string path, string basePath)
    {
        var relativePath = path.Substring(basePath.Length + 1).Replace("\\", "/");
        return Path.GetDirectoryName(relativePath).ToLower();
    }

    private static string GetReleativeFilePath(string path, string basePath)
    {
        return path.Substring(basePath.Length + 1).Replace("\\", "/").ToLower();
    }

    public static string GetRoleBundleName(string mainDir, string assetPath)
    {
        var paths = assetPath.Split(PathSeperator);
        var parentDirName = paths[paths.Length - 2];
        if (string.CompareOrdinal(parentDirName, mainDir) != 0)
        {
            return string.Format("actors/{0}/{1}_prefab", mainDir, parentDirName);
        }
        else
        {
            return GetRelativeDirPath(assetPath, BaseDir);
        }
    }

    public static string GetAssetBundleName(string asset)
    {
        if (!asset.StartsWith(BaseDir))
        {
            return string.Empty;
        }

        if (AssetDatabase.IsValidFolder(asset))
        {
            return string.Empty;
        }

        string bundleName = string.Empty;

        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetFontName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetPrefabName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetAudioName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetSceneName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetUiName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetShaderName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetLuaBundleName(asset);
        if (string.IsNullOrEmpty(bundleName)) bundleName = TryGetSpecialFileName(asset);            // 其他特殊没有规则的文件

        return IGNORE_MARK == bundleName ? string.Empty : bundleName.ToLower();
    }

    private static string TryGetFontName(string asset)
    {
        if (asset.StartsWith(TTFDir))
        {
            return "uis/ttf_bundle";
        }
        else if (asset.StartsWith(FontDir))
        {
            if (AssetDatabase.GetMainAssetTypeAtPath(asset) == typeof(Font)
                || asset.EndsWith("FontAtlas.png")
                || asset.EndsWith("FontAtlas.mat"))
            {
                return "uis/fonts_bundle";
            }
            else
            {
                return IGNORE_MARK;
            }
        }

        return string.Empty;
    }

    private static string TryGetPrefabName(string asset)
    {
        if (asset.EndsWith(".prefab"))
        {
            if (asset.StartsWith(RoleDir))
            {
                return GetRoleBundleName("role", asset);
            }
            else if (asset.StartsWith(WeaponDir))
            {
                return GetRoleBundleName("weapon", asset);
            }
            else if (asset.StartsWith(EffectsPrefabDir))
            {
                if (!asset.StartsWith(EffectsPrefabBossDir) &&
                !asset.StartsWith(EffectsPrefabMingjiangDir))
                {
                    return GetRelativeDirPath(asset, BaseDir) + string.Format("/{0}_prefab", Path.GetFileNameWithoutExtension(asset).ToLower());
                }
                else
                {
                    return GetRelativeDirPath(asset, BaseDir) + "_prefab";
                }
            }

            else if (!asset.StartsWith(EnvironmentsDir))
            {
                return GetRelativeDirPath(asset, BaseDir) + "_prefab";
            }
        }

        return string.Empty;
    }

    private static string TryGetAudioName(string asset)
    {
        if (asset.StartsWith(AudioDir))
        {
            if (Path.GetDirectoryName(asset) != AudioDir)
            {
                return GetRelativeDirPath(asset, BaseDir);
            }
        }

        return string.Empty;
    }

    private static string TryGetSceneName(string asset)
    {
        if (asset.EndsWith(".unity") && !LogicRegex.IsMatch(asset.ToLower()))
        {
            var bundleName = GetRelativeDirPath(asset, BaseDir);
            if (bundleName.StartsWith("scenes/map/"))
            {
                bundleName = "scenes/map/" + Path.GetFileNameWithoutExtension(asset).ToLower();
            }
            else
            {
                bundleName = bundleName + "/" + Path.GetFileNameWithoutExtension(asset).ToLower();
            }
            return bundleName;
        }

        return string.Empty;
    }

    private static string TryGetUiName(string asset)
    {
        if (asset.StartsWith(UIDir))
        {
            var importer = AssetImporter.GetAtPath(asset);
            if (asset.StartsWith(RawImageDir))
            {
                return "uis/rawimages/" + Path.GetFileNameWithoutExtension(asset);
            }
            if (asset.StartsWith(Image2Dir) && !asset.Contains("/nopack/"))
            {
                return "uis/images2_atlas";
            }
            if (asset.StartsWith(ImageDir) && !asset.Contains("/nopack/"))
            {
                return "uis/images_atlas";
            }
            if (asset.StartsWith(MainUIImageDir) && !asset.Contains("/nopack/"))
            {
                return "uis/views/mainui/images_atlas";
            }
            else if (importer as TextureImporter)
            {
                return "uis/" + GetRelativeDirPath(asset, UIDir) + "_atlas";
            }
        }

        return string.Empty;
    }

    private static string TryGetShaderName(string asset)
    {
        if (asset.StartsWith(ShaderDir) && !asset.EndsWith(".txt"))
        {
            if (asset.StartsWith(AutoShaderDir))
            {
                string dirName = Path.GetDirectoryName(asset);
                dirName = dirName.Substring(dirName.LastIndexOf("/") + 1);
                return "autoshaders/" + dirName.ToLower();
            }
            return "shaders";
        }

        return string.Empty;
    }


    private static string TryGetLuaBundleName(string asset)
    {
        if (asset.StartsWith(LuaBundleJitDir))
        {
            return "luajit/" + GetLuaBundleName(asset, LuaBundleJitDir);
        }

        if (asset.StartsWith(LuaBundleDir))
        {
            return "lua/" + GetLuaBundleName(asset, LuaBundleDir);
        }

        return string.Empty;
    }

    private static string TryGetSpecialFileName(string asset)
    {
        if (asset.EndsWith("QualityConfig.asset"))
        {
            return "misc/quality";
        }
        else if (asset.Contains("Misc/Material"))
        {
            return "misc/material";
        }
        else if (asset.EndsWith("toonylighting.psd"))
        {
            return "misc/psd";
        }
        else if (asset.StartsWith(MiscQingGongDir))
        {
            return "misc/qinggong";
        }

        return string.Empty;
    }

    private static string GetLuaBundleName(string asset, string luaBundleDir)
    {
        string bundle_name = string.Empty;
        string relative_dir_path = GetRelativeDirPath(asset, luaBundleDir);

        if (string.IsNullOrEmpty(relative_dir_path))
        {
            if (asset.Contains("lua_bundle_lookup") || asset.Contains("luajit_bundle_lookup"))
            {
                bundle_name = "lua_lookup";
            }
            else
            {
                bundle_name = "main";
            }
        }
        else
        {
            string relative_file_path = GetReleativeFilePath(asset, luaBundleDir);
            string[] names = relative_file_path.Split('/');

            if ("config" == names[0])
            {
                // 配置 (每个配置一个ab包）
                if (2 == names.Length)
                {
                    bundle_name = "config/" + names[1];
                }
                else
                {
                    bundle_name = "config/" + names[names.Length - 2] + "/" + names[names.Length - 1];
                }
            }
            else if ("protocolcommon" == names[0])
            {
                // 协议 (每个配置一个ab包）
                bundle_name = "protocol/" + names[names.Length - 1];
            }
            else if ("game" == names[0])
            {
                // 功能模块 (每个配置一个ab包）
                bundle_name = "game/" + names[1];
            }
            else
            {
                bundle_name = names[0];
            }
        }

        return bundle_name.Replace(".lua.bytes", "");
    }

    public static void MarkAssetBundle(string asset)
    {
        if (asset.EndsWith(".cs"))
        {
            return;
        }

        if (asset.StartsWith(FixBugDir))
        {
            return;
        }

        if (!asset.StartsWith(BaseDir))
        {
            return;
        }

        var importer = AssetImporter.GetAtPath(asset);
        if (!importer)
        {
            return;
        }

        var bundleName = GetAssetBundleName(asset);

        if (!string.Equals(importer.assetBundleName, bundleName))
        {
            importer.assetBundleName = bundleName;
            importer.SaveAndReimport();
        }
    }
}
