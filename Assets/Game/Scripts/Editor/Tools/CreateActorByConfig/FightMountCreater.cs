using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 该类的模型命名后缀要加001
/// </summary>
public class FightMountCreater : ActorCreater
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
        optimizer.SearchPatterns = new[] { "mount_point", "gaudian_*" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        gameObj.GetOrAddComponent<AttachObject>();
    }

    protected override string CustomFilter(string clipName)
    {
        return "action";
    }
}
