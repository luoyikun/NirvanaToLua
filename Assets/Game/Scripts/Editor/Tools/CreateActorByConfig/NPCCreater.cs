using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 需要添加Clickable
/// 命名添加后缀001
/// </summary>
public class NPCCreater : ActorCreater
{
    public override GameObject CreatePrefab(DirectoryInfo dir, out string savePrefabPath)
    {
        var fbxPath = GetFBXPathInDir(dir, "_model");
        var loadFBXPath = PathStartWithAsset(fbxPath);

        var modelPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(loadFBXPath);

        var prefabInst = GameObject.Instantiate(modelPrefab);
        var clickableObj = new GameObject("Clickable");
        clickableObj.layer = LayerMask.NameToLayer("Clickable");
        clickableObj.AddComponent<CapsuleCollider>();
        clickableObj.AddComponent<Clickable>();
        clickableObj.transform.SetParent(prefabInst.transform);

        savePrefabPath = Path.Combine(dir.FullName, dir.Name + "001.prefab");
        savePrefabPath = PathStartWithAsset(savePrefabPath);

        //var instance = GameObject.Instantiate(modelPrefab);
        return prefabInst;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "ui" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        var actorAttachment = gameObj.GetOrAddComponent<ActorAttachment>();
        actorAttachment.AutoPick();
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
            case "fangshou":
                filter = "fangshou";
                break;
            case "huanhu":
                filter = "huanhu";
                break;
            case "shuohua":
                filter = "shuohua";
                break;
            case "taishou":
                filter = "taishou";
                break;
            case "wangzhe":
                filter = "wangzhe";
                break;
            case "zhuantou":
                filter = "zhuantou";
                break;
        }
        return filter;
    }
}
