using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 预制体需要添加Clickable
/// 命名添加后缀001
/// 这个模型的控制器不全部相同，d_attack1、d_attack2；d_die、d_die_fly 两个动画一些模型有区别
/// </summary>
public class MonsterCreater : ActorCreater
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
        return prefabInst;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "buff_*", "hurt_*", "ui_*"};
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
                filter = "attack";
                break;
            case "d_dead":
                filter = "dead";
                break;
            case "d_die":
                filter = "die";
                break;
            case "d_die_fly":
                filter = "die";
                break;
            case "d_hurt":
                filter = "hurt";
                break;
            case "d_idle":
                filter = "idle";
                break;
            case "d_run":
                filter = "run";
                break;
        }
        return filter;
    }
}
