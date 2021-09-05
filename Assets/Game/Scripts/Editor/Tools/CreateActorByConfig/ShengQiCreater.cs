using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 命名添加后缀001
/// </summary>
public class ShengQiCreater : ActorCreater
{
    public override GameObject CreatePrefab(DirectoryInfo dir, out string savePrefabPath)
    {
        var fbxPath = GetFBXPathInDir(dir, "_model");
        var loadFBXPath = PathStartWithAsset(fbxPath);

        var modelPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(loadFBXPath);
        savePrefabPath = Path.Combine(dir.FullName, dir.Name + ".prefab");
        savePrefabPath = PathStartWithAsset(savePrefabPath);

        var instance = GameObject.Instantiate(modelPrefab);
        return instance;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "guadian*" };
        optimizer.SearchExposed();
        optimizer.Optimize();
    }

    protected override string CustomFilter(string clipName)
    {
        var filter = string.Empty;
        switch (clipName)
        {
            case "d_idle":
                filter = "idle";
                break;
        }
        return filter;
    }
}
