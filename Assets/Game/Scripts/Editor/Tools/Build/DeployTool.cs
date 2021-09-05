using Nirvana.Editor;
using Nirvana;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using Build;

class DeployTool
{
    [MenuItem("自定义工具/发布版本/编译Lua代码")]
    public static void BuildLua()
    {
        LuaTool.BuildLuaAll();
    }

    [MenuItem("自定义工具/发布版本/生成强更列表")]
    public static void BuildStrongUpdateLuaFile()
    {
        AssetBundleInstaller.BuildStrongUpdateLuaFile(InstallBundleSize.sizeS);
    }

    [MenuItem("自定义工具/发布版本/打包材质球")]
    public static void RebuildMaterial()
    {
        BuildMaterial.Build();
    }

    [MenuItem("自定义工具/发布版本/检查预加载配置")]
    public static void BuildCheckPreDownloadConfig()
    {
        CheckPreDownloadConfig();
    }

    [MenuItem("自定义工具/发布版本/加密资源")]
    public static void EncryptAssetBundle()
    {
        EncryptMgr.EncryptSteamFiles();
    }

    #region 打包资源
    [MenuItem("自定义工具/发布版本/Windows/打包Lua资源/WindowsDev")]
    public static void BuildWindowDevLua()
    {
        BuildLuaAssets(BuildPlatType.WindowsDev);
    }

    [MenuItem("自定义工具/发布版本/Windows/打包Lua资源/Windows")]
    public static void BuildWindowLua()
    {
        BuildLuaAssets(BuildPlatType.Windows);
    }

    [MenuItem("自定义工具/发布版本/安卓/打包Lua资源/AndroidDev")]
    public static void BuildAndroidDevLua()
    {
        BuildLuaAssets(BuildPlatType.AndroidDev);
    }

    [MenuItem("自定义工具/发布版本/安卓/打包Lua资源/Android")]
    public static void BuildAndroidLua()
    {
        BuildLuaAssets(BuildPlatType.Android);
    }

    [MenuItem("自定义工具/发布版本/IOS/打包Lua资源/IosDev")]
    public static void BuildIosDevLua()
    {
        BuildLuaAssets(BuildPlatType.IOSDev);
    }

    [MenuItem("自定义工具/发布版本/IOS/打包Lua资源/Ios")]
    public static void BuildIosLua()
    {
        BuildLuaAssets(BuildPlatType.IOS);
    }

    [MenuItem("自定义工具/发布版本/WriteFileList")]
    public static void WriteFileList()
    {
        AssetBundleInstaller.WriteFileListTxt();
    }
    #endregion


    #region 打包函数
    [MenuItem("自定义工具/发布版本/安卓/打包Android资源（Dev)")]
    public static void BuildDevAndroid()
    {
        BuildAssets(BuildPlatType.AndroidDev);
    }

    [MenuItem("自定义工具/发布版本/安卓/打包Android本地测试专用")]
    public static void BuildAndroidForTest()
    {
        BuildOptions buildOptions = BuildOptions.AllowDebugging | BuildOptions.ConnectToHost | BuildOptions.ConnectWithProfiler | BuildOptions.Development;
        BuildPipeline.BuildPlayer(new string[] { "Assets/Game/Scenes/main.unity" }, "D:/gz.apk", BuildTarget.Android, buildOptions);
    }

    [MenuItem("自定义工具/发布版本/IOS/打包IOS资源（Dev)")]
    public static void BuildDevIOS()
    {
        BuildAssets(BuildPlatType.IOSDev);
    }

    [MenuItem("自定义工具/发布版本/Windows/打包Windows资源（Dev)")]
    public static void BuildDevWindows()
    {
        BuildAssets(BuildPlatType.WindowsDev);
    }

    [MenuItem("自定义工具/发布版本/安卓/打包Android资源")]
    public static void BuildReleaseAndroid()
    {
        BuildAssets(BuildPlatType.Android);
    }

    [MenuItem("自定义工具/发布版本/IOS/打包IOS资源")]
    public static void BuildReleaseIOS()
    {
        BuildAssets(BuildPlatType.IOS);
    }

    [MenuItem("自定义工具/发布版本/Windows/打包Windows资源")]
    public static void BuildReleaseWindows()
    {
        BuildAssets(BuildPlatType.Windows);
    }

    [MenuItem("自定义工具/发布版本/安卓/生成Android.apk（Dev)")]
    public static void BuildDevAndroidApk()
    {
        BuildPlayer(BuildPlatType.AndroidDev);
    }

    [MenuItem("自定义工具/发布版本/Windows/生成Windows.exe（Dev)")]
    public static void BuildDevWindowsExe()
    {
        BuildPlayer(BuildPlatType.WindowsDev);
    }

    [MenuItem("自定义工具/发布版本/安卓/生成Android.apk")]
    public static void BuildReleaseAndroidApk()
    {
        BuildPlayer(BuildPlatType.Android);
    }

    [MenuItem("自定义工具/发布版本/Windows/生成Windows.exe")]
    public static void BuildReleaseWindowsExe()
    {
        BuildPlayer(BuildPlatType.Windows);
    }

    [MenuItem("自定义工具/发布版本/安卓/打包Android库")]
    public static void BuildAndroidLib()
    {
        ExportProject(BuildPlatType.Android);
    }

    [MenuItem("自定义工具/发布版本/IOS/打包IOS库")]
    public static void BuildIOSLib()
    {
        ExportProject(BuildPlatType.IOS);
    }

    [MenuItem("自定义工具/发布版本/安卓/拷资源进打包目录（Android 中包)")]
    public static void InstallAndroidAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.Android, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/安卓/拷资源进打包目录（Android Dev 中包)")]
    public static void InstallAndroidDevAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.AndroidDev, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/安卓/拷资源进打包目录（Android 全包)")]
    public static void InstallAllAndroidAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.Android, InstallBundleSize.sizeAll); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/IOS/拷资源进打包目录（Ios 中包)")]
    public static void InstallIosAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.IOS, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/IOS/拷资源进打包目录（Ios Dev 中包)")]
    public static void InstallIosDevAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.IOSDev, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/Windows/拷资源进打包目录（Windows 中包)")]
    public static void InstallWindowsAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.Windows, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/Windows/拷资源进打包目录（Windows Dev 中包)")]
    public static void InstallWindowsDevAssetBundles()
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(BuildPlatType.WindowsDev, InstallBundleSize.sizeM); // 拷贝进包列表（中包）
    }

    [MenuItem("自定义工具/发布版本/安卓/计算入包大小（Android L包)")]
    public static void CalcInstallLSize()
    {
        AssetBundleInstaller.CalcTotalSize(BuildPlatType.Android, InstallBundleSize.sizeL);
    }

    [MenuItem("自定义工具/发布版本/安卓/计算入包大小（Android M包)")]
    public static void CalcInstallMSize()
    {
        AssetBundleInstaller.CalcTotalSize(BuildPlatType.Android, InstallBundleSize.sizeM);
    }

    [MenuItem("自定义工具/发布版本/安卓/计算入包大小（Android S包)")]
    public static void CalcInstallSSize()
    {
        AssetBundleInstaller.CalcTotalSize(BuildPlatType.Android, InstallBundleSize.sizeS);
    }

    [MenuItem("自定义工具/发布版本/安卓/计算入包大小（Android XS包)")]
    public static void CalcInstallXSSize()
    {
        AssetBundleInstaller.CalcTotalSize(BuildPlatType.Android, InstallBundleSize.sizeXS);
    }

    [MenuItem("自定义工具/发布版本/安卓/计算入包大小（Android IOS审核包)")]
    public static void CalcInstallIOSSize()
    {
        AssetBundleInstaller.CalcTotalSize(BuildPlatType.Android, InstallBundleSize.sizeIOS);
    }
    #endregion

    [MenuItem("自定义工具/发布版本/test")]
    public static void Test()
    {
        Resources.UnloadUnusedAssets();
        AssetBundleManifest mf = BuilderConfig.GetAssetBundleMainfest(BuildPlatType.Android);

        Test2(mf, "cg/w3_fb_feichuan_prefab");
     }

    private static void Test2(AssetBundleManifest mf, string name)
   {
        string[] aa = mf.GetDirectDependencies(name);
        for (int i = 0; i < aa.Length; i++)
        {
            if (string.IsNullOrEmpty(aa[i]))
            {
                int bb = 0;
            }
            else
            {
                Test2(mf, aa[i]);
            }
        }
    }

    // 打包资源
    private static void BuildAssets(BuildPlatType buildPlatType)
    {
        if (!BuilderConfig.GetBuildDevice(buildPlatType).IsMatchCurrentTarget())
        {
            EditorUtility.DisplayDialog("Error", "平台不一致，请切换到相关平台再执行", "Yes");
            return;
        }

        float start_time = Time.realtimeSinceStartup;

        // 为了生成最新shader文件
        string[] modifyMaterialList;
        BuildMaterial.Build(out modifyMaterialList);
        // 构建强列表(以小包来做强更新列表）
        AssetBundleInstaller.BuildStrongUpdateLuaFile(InstallBundleSize.sizeS);
        // 编译所有lua文件
        LuaTool.BuildLuaAll();

        AssetDatabase.Refresh();

        // 打包AssetBundle（出最终资源包）
        if (!BuildAssetBundle.Build(buildPlatType))
        {
            return;
        }

        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

        BuildAssetBundle.BuildLua(buildPlatType);
        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

        BuilderVersion.WriteVersion(buildPlatType);                                     // 写版本号

        AssetBundleInstaller.WriteInstallBundlesList(buildPlatType);                    // 保存各种规格的进包列表（给sdk）
        AssetBundleInstaller.WriteModifyMaterialList(modifyMaterialList);// 改变过shader的材质球列表

        AssetDatabase.Refresh();

        Debug.LogFormat("Build finish, cost time: {0}", Time.realtimeSinceStartup - start_time);
    }

    private static void BuildLuaAssets(BuildPlatType buildPlatType)
    {
        if (!BuilderConfig.GetBuildDevice(buildPlatType).IsMatchCurrentTarget())
        {
            EditorUtility.DisplayDialog("Error", "平台不一致，请切换到相关平台再执行", "Yes");
            return;
        }

        // 检查预加载配置表
        //CheckPreDownloadConfig();
        // 构建强列表(以小包来做强更新列表）
        AssetBundleInstaller.BuildStrongUpdateLuaFile(InstallBundleSize.sizeS);         
        // 编译所有lua文件
        LuaTool.BuildLuaAll();
        // 构建lua与AssetBundle的查询表
        // BuildLuaBundleLookup.Build();

        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

        BuildAssetBundle.BuildLua(buildPlatType);
        BuilderVersion.WriteLuaVersion(buildPlatType);

        AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
    }

    // 打包APP
    private static void BuildPlayer(BuildPlatType buildPlatType)
    {
        AssetBundleInstaller.CopyInstallBundlesToStreamAsssets(buildPlatType, InstallBundleSize.sizeM); // 拷贝进包列表（中包）

        BuildSetting build_settting = BuilderConfig.GetBuildSetting(buildPlatType);
        string asset_bundle_path = BuilderConfig.GetAssetBundlePath(buildPlatType);
        string output_path = BuilderConfig.GetOutputPlayerPath(buildPlatType);
        build_settting.BuildPlayer(asset_bundle_path, output_path);                    // 构建player
    }

    // 打包工程给sdk
    private static void ExportProject(BuildPlatType buildPlatType)
    {
        BuildSetting build_settting = BuilderConfig.GetBuildSetting(buildPlatType);
        string asset_bundle_path = BuilderConfig.GetAssetBundlePath(buildPlatType);
        string output_path = BuilderConfig.GetOutputProjectPath(buildPlatType);
        build_settting.BuildPlayer(BuilderConfig.GetAssetBundlePath(buildPlatType), output_path, true);
    }

    // 检查预加载文件
    private static void CheckPreDownloadConfig()
    {
        string path = string.Format("{0}/Game/Lua/game/scene/loading/predownload.lua", Application.dataPath);
        string[] lines = File.ReadAllLines(path);

        var manifest = BuilderConfig.GetAssetBundleMainfest(BuildPlatType.Android);
        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            if (line.IndexOf("bundle = \"") >= 0)
            {
                var s = line.IndexOf("\"");
                var e = line.LastIndexOf("\"");
                var bundleName = line.Substring(s + 1, e - s - 1);
                if (!manifest.GetAssetBundleHash(bundleName).isValid)
                {
                    Debug.LogErrorFormat("预下载配置错误：{0}", bundleName);
                }
            }
        }
    }
}


