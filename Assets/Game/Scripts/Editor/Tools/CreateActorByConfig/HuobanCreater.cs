using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 生成的预制体名加后缀001
/// </summary>
public class HuobanCreater : ActorCreater
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
        optimizer.SearchPatterns = new[] { "ui_*", "wing_point", "weapon_point", "effect_body_point", "buff_*", "guadian_*" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        var actorAttachment = gameObj.GetOrAddComponent<ActorAttachment>();
        actorAttachment.AutoPick();
        gameObj.GetOrAddComponent<AnimatorEventDispatcher>();
    }

    protected override string CustomFilter(string clipName)
    {
        var filter = string.Empty;
        switch (clipName)
        {
            case "d_attack1":
                filter = "attack1";
                break;
            case "d_attack11":
                filter = "skill1";
                break;
            case "d_idle":
                filter = "idle";
                break;
            case "d_run":
                filter = "run";
                break;
            case "sit":
                filter = "sit";
                break;
        }
        return filter;
    }
}
