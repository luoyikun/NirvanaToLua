using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 命名加后缀001
/// </summary>
public class MountCreater : ActorCreater
{
    public override GameObject CreatePrefab(DirectoryInfo dir, out string savePrefabPath)
    {
        var fbxPath = GetFBXPathInDir(dir, "_model");
        var loadFBXPath = PathStartWithAsset(fbxPath);

        var modelPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(loadFBXPath);
        savePrefabPath = Path.Combine(dir.FullName, dir.Name + "001.prefab");
        savePrefabPath = PathStartWithAsset(savePrefabPath);
        
        var instance = GameObject.Instantiate(modelPrefab);
        return instance;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "mount_point", "guadian" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        var actorAttachment = gameObj.GetOrAddComponent<ActorAttachment>();
        actorAttachment.AutoPick();
        gameObj.GetOrAddComponent<ActorFadeout>();
    }

    protected override string CustomFilter(string clipName)
    {
        var filter = string.Empty;
        switch (clipName)
        {
            case "d_idle":
                filter = "idle";
                break;
            case "d_rest":
                filter = "rest";
                break;
            case "d_run":
                filter = "run";
                break;
        }
        return filter;
    }
}
