using UnityEngine;
using UnityEngine.SceneManagement;
using System;
using System.IO;

using UnityObject = UnityEngine.Object;
using System.Collections.Generic;
using Nirvana;
using UnityEngine.UI;

#if UNITY_EDITOR
using UnityEditor;
#endif

public static class EditorResourceMgr
{
#if UNITY_EDITOR
    private static Dictionary<GameObject, int> originalInstanceidMap = new Dictionary<GameObject, int>();
    private static Dictionary<UnityEngine.Object, string> assetPathMap = new Dictionary<UnityEngine.Object, string>();
#endif

    public static GameObject LoadGameObject(string bundleName, string assetName)
    {
#if UNITY_EDITOR
        assetName = Path.GetFileNameWithoutExtension(assetName);
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
        if (assetPaths.Length > 0)
        {
            var assetPath = assetPaths[0];
            return AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);
        }
#endif

        return null;
    }

    public static UnityObject LoadObject(string bundleName, string assetName, Type type)
    {
#if UNITY_EDITOR
        assetName = Path.GetFileNameWithoutExtension(assetName);
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
        if (assetPaths.Length > 0)
        {
            var assetPath = assetPaths[0];
            return AssetDatabase.LoadAssetAtPath(assetPath, type) ;
        }
#endif

        return null;
    }

    public static bool LoadLevelSync(string bundleName, string assetName, LoadSceneMode loadSceneMode)
    {
#if UNITY_EDITOR
        assetName = Path.GetFileNameWithoutExtension(assetName);

        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
        if (assetPaths.Length > 0)
        {
            var assetPath = assetPaths[0];
            if (loadSceneMode == LoadSceneMode.Single)
            {
                EditorApplication.LoadLevelInPlayMode(assetPath);
            }
            else
            {
                EditorApplication.LoadLevelAdditiveInPlayMode(assetPath);
            }

            return true;
        }
#endif

        return false;
    }

    public static AsyncOperation LoadLevelAsync(string bundleName, string assetName, LoadSceneMode loadSceneMode)
    {
#if UNITY_EDITOR
        assetName = Path.GetFileNameWithoutExtension(assetName);
        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundleName, assetName);
        if (assetPaths.Length > 0)
        {
            var assetPath = assetPaths[0];
            if (loadSceneMode == LoadSceneMode.Single)
            {
                return EditorApplication.LoadLevelAsyncInPlayMode(assetPath);
            }
            else
            {
                return EditorApplication.LoadLevelAdditiveAsyncInPlayMode(assetPath);
            }
        }
#endif

        return null;
    }

    public static void CacheOrginalInstanceMapping(GameObject gameobj, GameObject prefab)
    {
#if UNITY_EDITOR
        if (null != prefab)
        {
            originalInstanceidMap.Add(gameobj, prefab.GetInstanceID());
            assetPathMap.Add(gameobj, AssetDatabase.GetAssetPath(prefab.GetInstanceID()));
        }
#endif
    }

    public static void SweepOriginalInstanceIdMap()
    {
#if UNITY_EDITOR
        originalInstanceidMap.RemoveAll((gameobj, originalInstanceId) =>
        {
            if (null == gameobj)
            {
                return true;
            }

            return false;
        });

        assetPathMap.RemoveAll((obj, originalInstanceId) =>
        {
            if (null == obj)
            {
                return true;
            }

            return false;
        });
#endif
    }

    public static int GetOriginalInstanceId(GameObject gameobj)
    {
#if UNITY_EDITOR
        if (null == gameobj) return 0;

        int originalInstanceId;
        if (!originalInstanceidMap.TryGetValue(gameobj, out originalInstanceId))
        {
            return 0;
        }

        return originalInstanceId;
#else
        return 0;
#endif
    }

    public static string GetAssetPath(UnityEngine.Object obj)
    {
#if UNITY_EDITOR
        if (null == obj) return string.Empty;

        string path;
        if (!assetPathMap.TryGetValue(obj, out path))
        {
            return string.Empty;
        }

        return path;
#else
        return string.Empty;
#endif
    }

    public static void OutputAssetPathMap()
    {
#if UNITY_EDITOR
        assetPathMap.RemoveAll((obj, originalInstanceId) =>
        {
            if (null == obj)
            {
                return true;
            }

            return false;
        });

        List<string> lines = new List<string>();
        foreach (var item in assetPathMap)
        {
            lines.Add(item.Value);
        }

        string path = string.Format("{0}/../temp/assetpath_map.txt", Application.dataPath);
        File.WriteAllLines(path, lines.ToArray());
        Debug.LogFormat("保存到路径 {0}", path);
#endif
    }

    public static bool IsCanLoadAssetInGameObj(GameObject gameObj, string bundleName, string assetName)
    {
#if UNITY_EDITOR
        Canvas[] canvas = gameObj.GetComponentsInParent<Canvas>();
        string assetPath = string.Empty;
        for (int i = 0; i < canvas.Length; i++)
        {
            assetPath = GetAssetPath(canvas[i].gameObject);
            if (!string.IsNullOrEmpty(assetPath))
            {
                break;
            }
        }

        if (string.IsNullOrEmpty(assetPath)) return true;

        string inBundleName = AssetDatabase.GetImplicitAssetBundleName(assetPath);
        if (string.IsNullOrEmpty(inBundleName)) return true;

        if (!inBundleName.StartsWith("uis/views/") || !bundleName.StartsWith("uis/views"))
        {
            return true;
        }

        string fixInBundleName = inBundleName;
        fixInBundleName = fixInBundleName.Replace("uis/views/", "");
        if (fixInBundleName.IndexOf('/') >= 0)
        {
            fixInBundleName = fixInBundleName.Substring(0, fixInBundleName.IndexOf('/'));
        }
        fixInBundleName = fixInBundleName.Replace("_prefab", "");

        string fixBundleName = bundleName;
        fixBundleName = fixBundleName.Replace("uis/views/", "");
        if (fixBundleName.IndexOf('/') >= 0)
        {
            fixBundleName = fixBundleName.Substring(0, fixBundleName.IndexOf('/'));
        }

        // 要过滤掉的模块
        if (fixBundleName == "mainui")
        {
            return true;
        }

        // 在commonwidggets下载加其他模块的资源是合法的
        if (fixInBundleName == "commonwidgets" || fixInBundleName == "miscpreload")
        {
            return true;
        }

        if (fixInBundleName == fixBundleName)
        {
            return true;
        }

        Transform parent = gameObj.transform.parent;
        string nodePath = gameObj.name;
        while (parent)
        {
            nodePath = parent.name + "/" + nodePath;
            parent = parent.transform.parent;
            if (parent.name == "UILayer")
            {
                break;
            }
        }

        Debug.LogErrorFormat("[这不是报错，但技术需要立马处理]禁止加载其他模块的资源，你正在尝试在{0}模块下加载{1} {2}", inBundleName, bundleName, assetName);
        Debug.Log(nodePath);

        return false;
#else
        return true;
#endif
    }
}
