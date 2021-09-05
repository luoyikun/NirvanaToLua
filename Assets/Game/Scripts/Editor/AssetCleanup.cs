using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class AssetCleanup : Editor
{
    public static Dictionary<string, bool> usedDic = new Dictionary<string, bool>();

    [MenuItem("Nirvana/Yifan/RefreshAssetDatabase")]
    public static void RefreshAssetDatabase()
    {
        usedDic = new Dictionary<string, bool>();

        UnityEngine.Object[] selects = Selection.GetFiltered<UnityEngine.Object>(SelectionMode.DeepAssets);
        foreach (var asset in selects)
        {
            if (asset is GameObject)
            {
                string path = AssetDatabase.GetAssetPath(asset);
                Debug.Log("check obj:" + path);

                string[] depends = AssetDatabase.GetDependencies(path);
                foreach (var temp_path in depends)
                {
                    usedDic[temp_path] = true;
                }
            }
        }
    }

    [MenuItem("Nirvana/Yifan/FindUnUseAsset")]
    public static void FindUnUseAsset()
    {
        if (usedDic.Count <= 0)
        {
            Debug.LogError("database is empty, please execute Nirvana/Yifan/RefreshAssetDatabase before");
            return;
        }

        UnityEngine.Object[] selects = Selection.GetFiltered<UnityEngine.Object>(SelectionMode.DeepAssets);

        Debug.Log("---------------------------------result---------------------------------");
        List<UnityEngine.Object> unused_assets = new List<UnityEngine.Object>();

        foreach (var asset in selects)
        {
            if (asset is Texture2D || asset is GameObject)
            {
                string path = AssetDatabase.GetAssetPath(asset);
                if (!usedDic.ContainsKey(path))
                {
                    unused_assets.Add(asset);
                    Debug.Log(path);
                }
            }
        }

        Selection.objects = unused_assets.ToArray();
    }

    [MenuItem("Nirvana/Yifan/FindUseAsset")]
    public static void FindUseAsset()
    {
        if (usedDic.Count <= 0)
        {
            Debug.LogError("database is empty, please execute Nirvana/Yifan/RefreshAssetDatabase before");
            return;
        }

        UnityEngine.Object[] selects = Selection.GetFiltered<UnityEngine.Object>(SelectionMode.DeepAssets);

        Debug.Log("---------------------------------result---------------------------------");
        List<UnityEngine.Object> unused_assets = new List<UnityEngine.Object>();

        foreach (var asset in selects)
        {
            if (asset is Texture2D || asset is GameObject)
            {
                string path = AssetDatabase.GetAssetPath(asset);
                if (usedDic.ContainsKey(path))
                {
                    unused_assets.Add(asset);
                    Debug.Log(path);
                }
            }
        }

        Selection.objects = unused_assets.ToArray();
    }

    [MenuItem("Nirvana/Yifan/FindMeshCollider")]
    public static void FindMeshCollider()
    {
        UnityEngine.Object[] selects = Selection.GetFiltered<UnityEngine.Object>(SelectionMode.DeepAssets);

        foreach (var asset in selects)
        {
            if (asset is GameObject)
            {
                GameObject obj = asset as GameObject;
                string path = AssetDatabase.GetAssetPath(asset);
                if (obj.GetComponentsInChildren<MeshCollider>(true).Length > 0)
                {
                    Debug.Log(path);
                }
            }
        }
    }

    [MenuItem("Nirvana/Yifan/ClearFolderBundle")]
    public static void ClearFolderBundle()
    {
        var assets = AssetDatabase.GetAllAssetPaths();

        foreach (var asset in assets)
        {
            if (AssetDatabase.IsValidFolder(asset))
            {
                var importer = AssetImporter.GetAtPath(asset);
                if (!string.IsNullOrEmpty(importer.assetBundleName))
                {
                    importer.assetBundleName = null;
                    importer.SaveAndReimport();
                }
            }
        }
    }

}
