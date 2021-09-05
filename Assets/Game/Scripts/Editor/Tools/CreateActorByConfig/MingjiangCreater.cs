using System;
using System.Collections.Generic;
using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
using UnityEditor.Animations;
/// <summary>
/// 命名要加001后缀
/// 要添加Clickable
/// </summary>
public class MingjiangCreater : ActorCreater
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

        savePrefabPath = Path.Combine(dir.FullName, dir.Name + ".prefab");
        savePrefabPath = PathStartWithAsset(savePrefabPath);

        return prefabInst;
    }

    public override void AddComponentsByConfig(GameObject gameObj)
    {
        var optimizer = gameObj.GetOrAddComponent<AnimatorOptimizer>();
        optimizer.SearchPatterns = new[] { "buff_*", "hurt_*", "_*point", "ui", "guadian" };
        optimizer.SearchExposed();
        optimizer.Optimize();
        var actorAttachment = gameObj.GetOrAddComponent<ActorAttachment>();
        actorAttachment.AutoPick();
        gameObj.GetOrAddComponent<AnimatorEventDispatcher>();
    }

    public override AnimatorOverrideController CreateAnimatorOverrideController(DirectoryInfo dir)
    {
        var saveController = new AnimatorOverrideController();
        saveController.runtimeAnimatorController = FindMingjiangControllerTemplate(dir.Parent.Name);

        var clipOverrides = new List<KeyValuePair<AnimationClip, AnimationClip>>();
        saveController.GetOverrides(clipOverrides);
        for (int i = 0; i < clipOverrides.Count; i++)
        {
            var matchClip = MatchAnimationInDir(dir, clipOverrides[i].Key.name);
            clipOverrides[i] = new KeyValuePair<AnimationClip, AnimationClip>(
                clipOverrides[i].Key, matchClip);
        }
        saveController.ApplyOverrides(clipOverrides);

        var saveControllerPath = Path.Combine(dir.FullName, dir.Name + "_controller.overrideController");
        saveControllerPath = PathStartWithAsset(saveControllerPath);
        AssetDatabase.CreateAsset(saveController, saveControllerPath);
        return saveController;
    }

    //根据父文件夹的命名取模板，所以命名必须与控制器对应，否则找不到
    protected AnimatorController FindMingjiangControllerTemplate(string fileName)
    {
        var templateDirPath = Application.dataPath + "/Game/Actors/Shared";
        var templateControllName = "Role" + "Controller.controller";
        var templateControllPath = Path.Combine(templateDirPath, templateControllName);
        var loadControllPath = PathStartWithAsset(templateControllPath);
        var controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(loadControllPath);
        return controller;
    }

    protected override string CustomFilter(string clipName)
    {
        var filter = string.Empty;
        switch (clipName)
        {
            case "chongci":
                filter = "chongci";
                break;
            case "dunxia":
                filter = "dunxia";
                break;
            case "d_attack1":
                filter = "skill1";
                break;
            case "d_attack2":
                filter = "skill2";
                break;
            case "d_attack3":
                filter = "skill3";
                break;
            case "d_attack4":
                filter = "skill4";
                break;
            case "d_caiji":
                filter = "caiji";
                break;
            case "d_combo1_1":
                filter = "attack1";
                break;
            case "d_combo1_1_back":
                filter = "attack_back1";
                break;
            case "d_combo1_2":
                filter = "attack2";
                break;
            case "d_combo1_2_back":
                filter = "attack_back2";
                break;
            case "d_combo1_3":
                filter = "attack3";
                break;
            case "d_combo1_3_back":
                filter = "attack_back3";
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
            case "d_fight_mount_idle":
                filter = "idle_n";
                break;
            case "d_fight_mount_run":
                filter = "idle_n";
                break;
            case "d_fight_mount_run_f":
                filter = "idle_f";
                break;
            case "d_fight_to_fly":
                filter = "idle_to_f";
                break;
            case "d_fight_to_idle":
                filter = "idle_to_n";
                break;
            case "d_idle":
                filter = "idle_n";
                break;
            case "d_idle_fight":
                filter = "idle_f";
                break;
            case "d_idle_to_fight":
                filter = "idle_to_f";
                break;
            case "d_idle_to_run":
                filter = "run_n";
                break;
            case "d_jump":
                filter = "jump";
                break;
            case "d_jump2":
                filter = "jump1";
                break;
            case "d_jump3":
                filter = "jump2";
                break;
            case "d_mount_idle":
                filter = "qm_idle";
                break;
            case "d_mount_jump":
                filter = "qm_run";
                break;
            case "d_mount_run":
                filter = "qm_run";
                break;
//             case "d_run":
//                 filter = "run_n";
                break;
            case "d_run_fight":
                filter = "run_f";
                break;
            case "d_run_to_idle":
                filter = "idle_n";
                break;
            case "hug":
                filter = "hug";
                break;
            case "hug_walk":
                filter = "hug_walk";
                break;
            case "turn":
                filter = "turn";
                break;
            case "walk":
                filter = "walk";
                break;
            case "zhuantou":
                filter = "zhuantou";
                break;

            case "rest":
                filter = "rest";
                break;
            case "d_run":
                filter = "run";
                break;
        }
        return filter;
    }
}
