//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.IO;
using System.Collections.Generic;
using LuaInterface;
using Nirvana;
using UnityEngine;
using UnityEngine.Assertions;
using System.Text.RegularExpressions;

/// <summary>
/// The lua bundle loader.
/// </summary>
public sealed class LuaBundleLoader : LuaFileUtils
{
#if UNITY_IOS || UNITY_STANDALONE
    private const string AssetBundlePrefix = "lua/";
    private const string AssetPrefxi = "Assets/Game/LuaBundle/";
    private const string AssetBundleLookupFile = "lua_bundle_lookup";
#else
    private const string AssetBundlePrefix = "luajit/";
    private const string AssetPrefxi = "Assets/Game/LuaBundleJit/";
    private const string AssetBundleLookupFile = "luajit_bundle_lookup";
#endif

    private Dictionary<string, string> lookup = new Dictionary<string, string>(StringComparer.Ordinal);
    private Dictionary<string, AssetBundle> assetBundleDict = new Dictionary<string, AssetBundle>();

    private Dictionary<string, string> resAliasPathMap = new Dictionary<string, string>();

    private bool isLoadAliasResPath = false;

    /// <summary>
    /// Initializes a new instance of the <see cref="LuaBundleLoader"/> class.
    /// </summary>
    public LuaBundleLoader()
    {
        LuaFileUtils.instance = this;
        this.beZip = false;
    }

    /// <summary>
    /// Prune all lua bundles.
    /// </summary>
    public void PruneLuaBundles()
    {
        foreach (var key in this.assetBundleDict.Keys)
        {
            var bundle = this.assetBundleDict[key];
            bundle.Unload(true);
        }

        this.assetBundleDict.Clear();
    }

    public void AddLuaBundle(string luaFile, string luaBundle)
    {
        if (!this.lookup.ContainsKey(luaFile))
        {
            string addLuaBundle = luaBundle;
            this.lookup.Add(luaFile.ToLower(), addLuaBundle);
        }
    }

    public void SetupLuaLoader(LuaState luaState)
    {
        Debugger.Log("Start setup lua lookup");
        string initCode =
            @"
                local LUA_ASSET_BUNDLE_PREFIX
                local LUA_ASSET_PREFIX

                if UNITY_IOS or UNITY_STANDALONE then
                    LUA_ASSET_BUNDLE_PREFIX = 'lua/'
                    LUA_ASSET_PREFIX = 'Assets/Game/LuaBundle/'
                else
                    LUA_ASSET_BUNDLE_PREFIX = 'luajit/'
                    LUA_ASSET_PREFIX = 'Assets/Game/LuaBundleJit/'
                end

                local LUA_ASSET_PREFIX_LEN = string.len(LUA_ASSET_PREFIX) + 1

                local SysFile = System.IO.File
                local UnityApplication = UnityEngine.Application
                local UnityAppStreamingAssetsPath = UnityEngine.Application.streamingAssetsPath
                local _sformat = string.format

               if not UNITY_EDITOR then
                    local cacheDir = EncryptMgr.GetEncryptPath('BundleCache');
                    local cache_path = _sformat('%s/%s', UnityApplication.persistentDataPath, cacheDir)

                    local lua_assetbundle = 'LuaAssetBundle/LuaAssetBundle.lua'
                    local lua_assetbundle_data
                    
                    if SysFile.Exists(_sformat('%s/%s', cache_path, lua_assetbundle)) then
                        lua_assetbundle_data = SysFile.ReadAllText(_sformat('%s/%s', cache_path, lua_assetbundle))
                    else
                        local alias_path =  GameRoot.GetAliasResPath('AssetBundle/'..lua_assetbundle)
                        
                        if  EncryptMgr.IsEncryptAsset() then
                            lua_assetbundle_data = EncryptMgr.ReadEncryptFile(_sformat('%s/%s', UnityAppStreamingAssetsPath, alias_path));
                            print('SetupLuaLoader load1 ', alias_path)
                        else
                            lua_assetbundle_data = StreamingAssets.ReadAllText(alias_path)
                        end
                    end
                    
                    local pattern = LUA_ASSET_BUNDLE_PREFIX.. '.+'
                    local lua_bundle_infos = loadstring(lua_assetbundle_data)().bundleInfos

                    for bundle_name, bundle_info in pairs(lua_bundle_infos) do
                        if string.match(bundle_name, pattern) then
                            local hash = bundle_info.hash
                            -- TODO: hash
                            local path = _sformat('%s/LuaAssetBundle/%s-%s', cache_path, bundle_name, hash)
                            if not SysFile.Exists(path) then
                                local alias_path = GameRoot.GetAliasResPath(_sformat('AssetBundle/LuaAssetBundle/%s-%s', bundle_name, hash))
                                path = _sformat('%s/%s', UnityAppStreamingAssetsPath, alias_path)
                            end

                            for _, lua_file in ipairs(bundle_info.deps) do
                                AddLuaBundle(lua_file, path)
                            end
                        end
                    end
               end

                AddLuaBundle = nil";

        luaState.DoString(initCode, "LuaState.cs", true);

        Debugger.Log(string.Format("setup lua lookup complete, lua count:{0}", lookup.Count));
    }

    private string GetLuaFileFullPath(string fileName)
    {
        if (!fileName.EndsWith(".lua"))
        {
            fileName += ".lua";
        }

        if (!fileName.EndsWith(".bytes"))
        {
            fileName += ".bytes";
        }

        var filePath = AssetPrefxi + fileName;
        return filePath.ToLower();
    }

    public bool IsLuaFileExist(string fileName)
    {
#if !UNITY_EDITOR
        var filePath = GetLuaFileFullPath(fileName);

        var bundleName = string.Empty;
        if (!this.lookup.TryGetValue(filePath, out bundleName))
        {
            return false;
        }

        return true;
#else
        string path = FindFile(fileName);
        if (!string.IsNullOrEmpty(path) && File.Exists(path))
        {
            return true;
        }

        return false;
#endif
    }

    /// <inheritdoc/>
    public override byte[] ReadFile(string fileName)
    {
#if !UNITY_EDITOR
        return ReadAssetBundleFile(fileName);
#else
        return base.ReadFile(fileName);
#endif
    }

    private byte[] ReadAssetBundleFile(string fileName)
    {
        var filePath = GetLuaFileFullPath(fileName);
        filePath = filePath.ToLower();
        var bundlePath = string.Empty;
        if (!this.lookup.TryGetValue(filePath, out bundlePath))
        {
            Debug.LogErrorFormat(
                "Load lua file failed: {0}, bundle is not existed.",
                filePath);
            return null;
        }

        AssetBundle assetBundle;
        if (!this.assetBundleDict.TryGetValue(bundlePath, out assetBundle))
        {
            string realBundlePath = bundlePath;
            if (EncryptMgr.IsEncryptAsset())
            {
                string cacheDirName = EncryptMgr.GetEncryptPath("/BundleCache/");
                // 如果不是在缓存目录则需要解压lua到特定的文件夹再读取
                if (bundlePath.IndexOf(cacheDirName) < 0)
                {
                    string relativeBundleName = Regex.Replace(bundlePath, Application.streamingAssetsPath, "");
                    string relativePath = string.Format("DecryptLuaCache/{0}", relativeBundleName);
                    relativePath = EncryptMgr.GetEncryptPath(relativePath);

                    string decryptTargetPath = string.Format("{0}/{1}", Application.persistentDataPath, relativePath);
                    if (EncryptMgr.DecryptAssetBundle(bundlePath, decryptTargetPath))
                    {
                        realBundlePath = decryptTargetPath;
                    }
                }
            }

           assetBundle = AssetBundle.LoadFromFile(realBundlePath);
      
            if (null == assetBundle)
            {
                Debug.LogErrorFormat("[LuaBundleLoader] ReadAssetBundleFile, not exists assetbundle, {0}", bundlePath);
                return null;
            }

            this.assetBundleDict.Add(bundlePath, assetBundle);
        }

        var textAsset = assetBundle.LoadAsset<TextAsset>(filePath);

        if (textAsset == null)
        {
            Debug.LogErrorFormat(
                "Load lua file failed: {0}, can not load asset fomr bundle.",
                fileName);
            return null;
        }

        var buffer = textAsset.bytes;
        Resources.UnloadAsset(textAsset);
        return buffer;
    }

    public void LoadAliasResPathMap()
    {
#if UNITY_IOS
        //string path = Path.Combine(Application.streamingAssetsPath, "AssetBundle/res_alias_path_map.txt");

        if (string.IsNullOrEmpty(ChannelAgent.GetAliasPathMapPath()))
        {
            return;
        }

        string fullPath =  Path.Combine(Application.streamingAssetsPath, ChannelAgent.GetAliasPathMapPath());
        if (!File.Exists(fullPath))
        {
            Debug.LogErrorFormat("[LuaBundleLoader] not exists {0}", fullPath);
            return;
        }

        Debug.LogFormat("[LuaBundleLoader] start load aliasres path {0}", fullPath);
        this.isLoadAliasResPath = true;

        string data = EncryptMgr.ReadEncryptFile(fullPath);
        string[] lines = null;
        if (!string.IsNullOrEmpty(data))
        {
            lines = data.Split('\n');
        }
        else
        {
            lines = File.ReadAllLines(fullPath);
        }

        for (int i = 0; i < lines.Length; i++)
        {
            string[] ary = lines[i].Split(' ');
            if (ary.Length != 2)
            {
                Debug.LogErrorFormat("[LoadAliasResPathMap] error {0}", lines[i]);
                continue;
            }

            string originalPath = ary[0];
            string newPath = ary[1];
            resAliasPathMap[originalPath] = newPath;
        }

        Debug.LogFormat("[LoadAliasResPathMap] load succ, count: {0}", resAliasPathMap.Count);
#endif
    }

    public string GetAliasResPath(string path)
    {
        if (!isLoadAliasResPath)
        {
            return path;
        }

        string aliasPath = "";
        if (!resAliasPathMap.TryGetValue(path, out aliasPath))
        {
            return path;
        }

        return aliasPath;
    }

}
