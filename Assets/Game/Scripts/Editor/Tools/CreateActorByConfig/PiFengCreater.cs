using System.Collections;
using System.Collections.Generic;
using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 命名添加后缀001
/// Controllor使用Shared文件中的
/// 动画资源使用Shared文件中的
/// </summary>
public class PiFengCreater : ActorCreater
{
    //private const string PiFengAvatarPath = "Assets/Game/Actors/PiFeng/10000Shared/pifeng@action.FBX";
    private const string PiFengControlllerPath = "Assets/Game/Actors/PiFeng/10000Shared/PiFeng_Controller.overrideController";

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

    public override AnimatorOverrideController CreateAnimatorOverrideController(DirectoryInfo dir)
    {
        var controller =
            AssetDatabase.LoadAssetAtPath<AnimatorOverrideController>(PiFengControlllerPath);
        return controller;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "wing_point", "guadian_*" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        gameObj.GetOrAddComponent<AttachObject>();
    }

    protected override string CustomFilter(string clipName)
    {
        throw new System.NotImplementedException();
    }
}
