//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.IO;
using Nirvana;
using UnityEditor;
using UnityEngine;
using UnityObject = UnityEngine.Object;

public enum ActorType
{
    [EnumLabel("宝具")]
    BaoJu,

    [EnumLabel("掉落物")]
    FallItem,

    [EnumLabel("战斗坐骑")]
    FightMount,

    [EnumLabel("锻造")]
    Forge,

    [EnumLabel("采集物")]
    Gather,

    [EnumLabel("女神")]
    Goddess,

    [EnumLabel("神弓")]
    GoddessWeapon,

    [EnumLabel("神翼")]
    GoddessWing,

    [EnumLabel("勋章")]
    Medal,

    [EnumLabel("怪物")]
    Monster,

    [EnumLabel("坐骑")]
    Mount,

    [EnumLabel("NPC")]
    NPC,

    [EnumLabel("宠物")]
    Pet,

    [EnumLabel("旗帜")]
    QiZhi,

    [EnumLabel("角色")]
    Role,

    [EnumLabel("精灵")]
    Spirit,

    [EnumLabel("武器")]
    Weapon,

    [EnumLabel("翅膀")]
    Wing,

    [EnumLabel("未知")]
    Unknown,
}

public class ActorWizard : ScriptableWizard
{
    [SerializeField]
    private UnityObject folder;

    [SerializeField]
    [EnumLabel]
    private ActorType type;

    [Header("资源")]
    [SerializeField]
    private GameObject model;

    [SerializeField]
    private List<AnimationClip> animations = new List<AnimationClip>();

    [SerializeField]
    private Material material;

    [SerializeField]
    private Avatar avatar;

    private string path;
    private string id;

    [MenuItem("Nirvana/Create Actor %L")]
    static void CreateActor()
    {
        DisplayWizard<ActorWizard>("Create Actor", "Create", "Cancel");
    }

    private void OnWizardUpdate()
    {
        this.path = string.Empty;
        this.id = string.Empty;
        this.model = null;
        this.animations.Clear();
        this.avatar = null;
        this.material = null;

        if (this.folder == null)
        {
            this.helpString = "拖一个角色目录到面板";
            this.errorString = string.Empty;
            return;
        }

        this.helpString = string.Empty;
        this.path = AssetDatabase.GetAssetPath(this.folder);
        if (string.IsNullOrEmpty(this.path))
        {
            this.errorString = "目录不正确.";
            return;
        }

        if (!AssetDatabase.IsValidFolder(this.path))
        {
            this.errorString = "设置的不是一个目录.";
            return;
        }

        var regex1 = new Regex("Assets/Game/Actors/(.*)/(.*)");
        var match1 = regex1.Match(this.path);
        if (!match1.Success || match1.Groups.Count != 3)
        {
            this.errorString = "不是一个角色目录.";
            return;
        }

        var type = match1.Groups[1].Value;
        if (type.StartsWith("Role"))
        {
            type = "Role";
        }

        if (type.StartsWith("Weapon"))
        {
            type = "Weapon";
        }

        this.id = match1.Groups[2].Value;
        switch (type)
        {
        case "BaoJu":
            this.type = ActorType.BaoJu;
            this.OnUpdateBaoJu(this.path, this.id);
            break;
        case "FallItem":
            this.type = ActorType.FallItem;
            this.OnUpdateFallItem(this.path, this.id);
            break;
        case "FightMount":
            this.type = ActorType.FightMount;
            this.OnUpdateFightMount(this.path, this.id);
            break;
        case "Forge":
            this.type = ActorType.Forge;
            this.OnUpdateForge(this.path, this.id);
            break;
        case "Gather":
            this.type = ActorType.Gather;
            this.OnUpdateGather(this.path, this.id);
            break;
        case "Goddess":
            this.type = ActorType.Goddess;
            this.OnUpdateGoddess(this.path, this.id);
            break;
        case "GoddessWeapon":
            this.type = ActorType.GoddessWeapon;
            this.OnUpdateGoddessWeapon(this.path, this.id);
            break;
        case "GoddessWing":
            this.type = ActorType.GoddessWing;
            this.OnUpdateGoddessWing(this.path, this.id);
            break;
        case "Medal":
            this.type = ActorType.Medal;
            this.OnUpdateMedal(this.path, this.id);
            break;
        case "Monster":
            this.type = ActorType.Monster;
            this.OnUpdateMonster(this.path, this.id);
            break;
        case "Mount":
            this.type = ActorType.Mount;
            this.OnUpdateMount(this.path, this.id);
            break;
        case "NPC":
            this.type = ActorType.NPC;
            this.OnUpdateNPC(this.path, this.id);
            break;
        case "Pet":
            this.type = ActorType.Pet;
            this.OnUpdatePet(this.path, this.id);
            break;
        case "QiZhi":
            this.type = ActorType.QiZhi;
            this.OnUpdateQiZhi(this.path, this.id);
            break;
        case "Role":
            this.type = ActorType.Role;
            this.OnUpdateRole(this.path, this.id);
            break;
        case "Spirit":
            this.type = ActorType.Spirit;
            this.OnUpdateSpirit(this.path, this.id);
            break;
        case "Weapon":
            this.type = ActorType.Weapon;
            this.OnUpdateWeapon(this.path, this.id);
            break;
        case "Wing":
            this.type = ActorType.Wing;
            this.OnUpdateWing(this.path, this.id);
            break;
        default:
            this.type = ActorType.Unknown;
            this.errorString = "不认识的角色目录.";
            return;
        }

        this.errorString = string.Empty;
    }

    private void OnWizardCreate()
    {
        switch (this.type)
        {
        case ActorType.BaoJu:
            this.OnCreateBaoJu(this.path, this.id);
            break;
        case ActorType.FallItem:
            this.OnCreateFallItem(this.path, this.id);
            break;
        case ActorType.FightMount:
            this.OnCreateFightMount(this.path, this.id);
            break;
        case ActorType.Forge:
            this.OnCreateForge(this.path, this.id);
            break;
        case ActorType.Gather:
            this.OnCreateGather(this.path, this.id);
            break;
        case ActorType.Goddess:
            this.OnCreateGoddess(this.path, this.id);
            break;
        case ActorType.GoddessWeapon:
            this.OnCreateGoddessWeapon(this.path, this.id);
            break;
        case ActorType.GoddessWing:
            this.OnCreateGoddessWing(this.path, this.id);
            break;
        case ActorType.Medal:
            this.OnCreateMedal(this.path, this.id);
            break;
        case ActorType.Monster:
            this.OnCreateMonster(this.path, this.id);
            break;
        case ActorType.Mount:
            this.OnCreateMount(this.path, this.id);
            break;
        case ActorType.NPC:
            this.OnCreateNPC(this.path, this.id);
            break;
        case ActorType.Pet:
            this.OnCreatePet(this.path, this.id);
            break;
        case ActorType.QiZhi:
            this.OnCreateQiZhi(this.path, this.id);
            break;
        case ActorType.Role:
            this.OnCreateRole(this.path, this.id);
            break;
        case ActorType.Spirit:
            this.OnCreateSpirit(this.path, this.id);
            break;
        case ActorType.Weapon:
            this.OnCreateWeapon(this.path, this.id);
            break;
        case ActorType.Wing:
            this.OnCreateWing(this.path, this.id);
            break;
        }
    }

    private void OnUpdateBaoJu(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateFallItem(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateFightMount(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateForge(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateGather(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateGoddess(string path, string id)
    {
        this.FindBasicAssets(path, id);

        // 共享目录获取动画.
        var animationPath = "Assets/Game/Actors/Goddess/SharedAnimations/nvshen_Animations.FBX";
        if (this.animations.Count == 0)
        {
            var animationAssets = AssetDatabase.LoadAllAssetsAtPath(animationPath);
            foreach (var asset in animationAssets)
            {
                var animation = asset as AnimationClip;
                if (animation == null)
                {
                    continue;
                }

                if (animation.name == "__preview__Take 001")
                {
                    continue;
                }

                this.animations.Add(animation);
            }
        }

        // 共享目录获取Avatar.
        if (this.avatar == null)
        {
            this.avatar = AssetDatabase.LoadAssetAtPath<Avatar>(animationPath);
        }
    }

    private void OnUpdateGoddessWeapon(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateGoddessWing(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateMedal(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateMonster(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateMount(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateNPC(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdatePet(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateQiZhi(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateRole(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateSpirit(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateWeapon(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnUpdateWing(string path, string id)
    {
        this.FindBasicAssets(path, id);
    }

    private void OnCreateBaoJu(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle_n"},
            { "d_idle_fight", "idle_f"},
            { "d_rest", "rest"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/BaoJuController.controller", 
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id;

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "guadian*_" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        prefab.AddComponent<ActorController>();
        prefab.AddComponent<ActorTriggers>();
        prefab.AddComponent<ActorBlinker>();
        prefab.AddComponent<ActorTimelineEvent>();

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);

        var prefabL = GameObject.Instantiate(this.model);
        prefabL.name = id + "_L";

        var prefabLRenderer = prefabL.GetComponentInChildren<NirvanaRenderer>();
        if (prefabLRenderer != null && this.material != null)
        {
            prefabLRenderer.Materials = new Material[] { this.material };
        }

        var prefabLAnimator = prefabL.AddComponent<Animator>();
        prefabLAnimator.runtimeAnimatorController = controller;
        prefabLAnimator.avatar = this.avatar;

        var prefabLOptimizer = prefabL.AddComponent<AnimatorOptimizer>();
        prefabLOptimizer.SearchPatterns = new string[] { "guadian*_" };
        prefabLOptimizer.SearchExposed();
        prefabLOptimizer.Optimize();

        this.AddUICamera(
            prefabL, 
            "UICamera", 
            new Vector3(-0.25f, 1.439f, 2.442f), 
            new Vector3(11.862f, 180.0f, 0.0f));

        this.ReplacePrefab(prefabL, Path.Combine(path, prefabL.name + ".prefab"));
        GameObject.DestroyImmediate(prefabL);
    }

    private void OnCreateFallItem(string path, string id)
    {
        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateFightMount(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle"},
            { "d_jump", "idle"},
            { "d_jump_to_idle", "idle"},
            { "d_jump_to_run", "idle"},
            { "d_rest", "idle"},
            { "d_run", "idle"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/MountController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id + "001";

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "mount_point", "gaudian_*" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        prefab.AddComponent<AttachObject>();

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(5.43f, 2.39f, 0.0f),
            new Vector3(18.61f, -90.0f, 0.0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateForge(string path, string id)
    {
        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateGather(string path, string id)
    {
        var prefab = new GameObject(id + "001");
        var attachment = prefab.AddComponent<ActorAttachment>();
        var clickableObject = prefab.AddComponent<ClickableObject>();

        var mesh = GameObject.Instantiate(this.model);
        mesh.name = "Mesh";
        mesh.transform.SetParent(prefab.transform, true);

        var renderer = mesh.GetComponentInChildren<NirvanaRenderer>();
        if (renderer != null && this.material != null)
        {
            renderer.Materials = new Material[] { this.material };
        }

        var topPoint = new GameObject("TopPoint");
        topPoint.transform.SetParent(prefab.transform);
        topPoint.transform.localPosition = new Vector3(0f, 1.29f, 0f);
        topPoint.transform.localRotation = Quaternion.identity;
        topPoint.transform.localScale = Vector3.one;

        var clickable = new GameObject("Clickable");
        clickable.transform.SetParent(prefab.transform);
        clickable.AddComponent<BoxCollider>();
        var click = clickable.AddComponent<Clickable>();
        click.Owner = clickableObject;

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateGoddess(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "cj_rest_1", "cj_rest_1"},
            { "cj_rest_2", "cj_rest_2"},
            { "cj_rest_3", "cj_rest_3"},
            { "cj_rest_4", "cj_rest_4"},
            { "d_attack1", "fly_atk"},
            { "d_attack2", "fly_atk"},
            { "d_run", "fly_run"},
            { "fly_idle", "fly_idle"},
            { "idle", "idle"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/GoddessController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id;

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "ui_.*", "wing_point", "weapon_point", "effect_body_point" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        prefab.AddComponent<ActorAttachment>();
        prefab.AddComponent<ActorTriggers>();
        prefab.AddComponent<ActorBlinker>();
        prefab.AddComponent<ActorController>();
        prefab.AddComponent<SimpleShadow>();
        prefab.AddComponent<AnimatorEventDispatcher>();

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(0.019f, 2.429f, 3.03f),
            new Vector3(11.862f, 180f, 0.0f));

        this.AddUICamera(
            prefab,
            "UICamera2",
            new Vector3(0.068f, 1.99f, 3.723f),
            new Vector3(11.862f, 180f, 0.0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);

        var prefabL = GameObject.Instantiate(this.model);
        prefabL.name = id + "_L";

        var prefabLRenderer = prefabL.GetComponentInChildren<NirvanaRenderer>();
        if (prefabLRenderer != null && this.material != null)
        {
            prefabLRenderer.Materials = new Material[] { this.material };
        }

        var prefabLAnimator = prefabL.AddComponent<Animator>();
        prefabLAnimator.runtimeAnimatorController = controller;
        prefabLAnimator.avatar = this.avatar;

        var prefabLOptimizer = prefabL.AddComponent<AnimatorOptimizer>();
        prefabLOptimizer.SearchPatterns = new string[] { "ui_.*", "wing_point", "weapon_point", "effect_body_point" };
        prefabLOptimizer.SearchExposed();
        prefabLOptimizer.Optimize();

        var attachment = prefabL.AddComponent<ActorAttachment>();
        attachment.AutoPick();

        prefabL.AddComponent<ActorTriggers>();
        prefabL.AddComponent<ActorBlinker>();
        prefabL.AddComponent<ActorController>();
        prefabL.AddComponent<SimpleShadow>();
        prefabL.AddComponent<AnimatorEventDispatcher>();

        this.AddUICamera(
            prefabL,
            "UICamera",
            new Vector3(0.019f, 2.429f, 3.03f),
            new Vector3(11.862f, 180f, 0.0f));

        this.AddUICamera(
            prefabL,
            "UICamera2",
            new Vector3(0.068f, 1.99f, 3.723f),
            new Vector3(11.862f, 180f, 0.0f));

        this.ReplacePrefab(prefabL, Path.Combine(path, prefabL.name + ".prefab"));
        GameObject.DestroyImmediate(prefabL);
    }

    private void OnCreateGoddessWeapon(string path, string id)
    {
        var controller = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(
            "Assets/Game/Actors/GoddessWeapon/Shared/shengong_Controller.overrideController");
        this.avatar = AssetDatabase.LoadAssetAtPath<Avatar>(
            "Assets/Game/Actors/GoddessWeapon/Shared/shengong_animation.FBX");

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id;

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "effect_weapon_point", "weapon_point" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        prefab.AddComponent<AttachObject>();

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(-3.114f, 0.16f, -0.2f),
            new Vector3(0f, 90f, -30f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);

        var prefabL = GameObject.Instantiate(this.model);
        prefabL.name = id + "_L";

        var prefabLRenderer = prefabL.GetComponentInChildren<NirvanaRenderer>();
        if (prefabLRenderer != null && this.material != null)
        {
            prefabLRenderer.Materials = new Material[] { this.material };
        }

        var prefabLAnimator = prefabL.AddComponent<Animator>();
        prefabLAnimator.runtimeAnimatorController = controller;
        prefabLAnimator.avatar = this.avatar;

        var prefabLOptimizer = prefabL.AddComponent<AnimatorOptimizer>();
        prefabLOptimizer.SearchPatterns = new string[] { "effect_weapon_point", "weapon_point" };
        prefabLOptimizer.SearchExposed();
        prefabLOptimizer.Optimize();

        prefabL.AddComponent<AttachObject>();

        this.AddUICamera(
            prefabL,
            "UICamera",
            new Vector3(-3.114f, 0.16f, -0.2f),
            new Vector3(0f, 90f, -30f));

        this.ReplacePrefab(prefabL, Path.Combine(path, prefabL.name + ".prefab"));
        GameObject.DestroyImmediate(prefabL);
    }

    private void OnCreateGoddessWing(string path, string id)
    {
        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateMedal(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_rest", "action"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/XunZhangController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id;

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "guadian*_" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(0f, 0f, 2.5f),
            new Vector3(0f, 180f, 0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateMonster(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_attack1", "attack"},
            { "d_dead", "dead"},
            { "d_die", "die"},
            { "d_hurt", "beat"},
            { "d_idle", "idle"},
            { "d_run", "run"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/MonsterController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id + "001";

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "buff_.*", "hurt_.*", "ui_.*" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        var clickableObject = prefab.AddComponent<ClickableObject>();

        var attachment = prefab.AddComponent<ActorAttachment>();
        attachment.AutoPick();

        prefab.AddComponent<ActorTriggers>();
        prefab.AddComponent<ActorBlinker>();
        prefab.AddComponent<ActorController>();

        var clickable = new GameObject("Clickable");
        clickable.transform.SetParent(prefab.transform);
        clickable.AddComponent<CapsuleCollider>();
        var click = clickable.AddComponent<Clickable>();
        click.Owner = clickableObject;

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(0.009f, 1.036f, 3.536f),
            new Vector3(0f, 180f, 0f));

        this.AddUICamera(
            prefab,
            "UICamera2",
            new Vector3(0.009f, 1.225f, 3.415f),
            new Vector3(0f, 180f, 0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateMount(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle"},
            { "d_jump", "jump"},
            { "d_jump_to_idle", "jump_to_idle"},
            { "d_jump_to_run", "jump_to_run"},
            { "d_rest", "rest"},
            { "d_run", "run"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/MountController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id + "001";

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "mount_point", "guadian_.*" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        prefab.AddComponent<AttachObject>();

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(8.9f, 3.09f, 2.19f),
            new Vector3(5f, 253.18f, 0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateNPC(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle"},
            { "d_rest", "action"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/NpcController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id + "001";

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        var prefabAnimator = prefab.AddComponent<Animator>();
        prefabAnimator.runtimeAnimatorController = controller;
        prefabAnimator.avatar = this.avatar;

        var prefabOptimizer = prefab.AddComponent<AnimatorOptimizer>();
        prefabOptimizer.SearchPatterns = new string[] { "ui_name" };
        prefabOptimizer.SearchExposed();
        prefabOptimizer.Optimize();

        var clickableObject = prefab.AddComponent<ClickableObject>();
        var attachment = prefab.AddComponent<ActorAttachment>();
        attachment.AutoPick();
        prefab.AddComponent<SimpleShadow>();

        var clickable = new GameObject("Clickable");
        clickable.transform.SetParent(prefab.transform);
        clickable.AddComponent<CapsuleCollider>();
        var click = clickable.AddComponent<Clickable>();
        click.Owner = clickableObject;

        this.AddUICamera(
            prefab,
            "UICamera",
            new Vector3(0f, 1.98f, 4.62f),
            new Vector3(11.862f, 180f, 0f));

        this.AddUICamera(
            prefab,
            "UICamera2",
            new Vector3(0f, 1.549f, 5.05f),
            new Vector3(0f, 180f, 0f));

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreatePet(string path, string id)
    {
        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateQiZhi(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle_n"},
            { "d_idle_fight", "idle_f"},
            { "d_rest", "rest"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/QiZhiController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateRole(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle_n"},
            { "d_idle_fight", "idle_f"},
            { "d_rest", "rest"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/RoleController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateSpirit(string path, string id)
    {
        var lookup = new Dictionary<string, string>()
        {
            { "d_idle", "idle_n"},
            { "d_idle_fight", "idle_f"},
            { "d_rest", "rest"},
        };

        var controller = this.CreateAnimatorController(
            "Assets/Game/Actors/Shared/SpiritController.controller",
            Path.Combine(path, id + "_controller.overrideController"),
            lookup);

        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void OnCreateWeapon(string path, string id)
    {
        var prefab = GameObject.Instantiate(this.model);
        prefab.name = id + "01";
        prefab.transform.localPosition = Vector3.zero;
        prefab.transform.localRotation = Quaternion.identity;
        prefab.transform.localScale = Vector3.one;

        var prefabRenderer = prefab.GetComponentInChildren<NirvanaRenderer>();
        if (prefabRenderer != null && this.material != null)
        {
            prefabRenderer.Materials = new Material[] { this.material };
        }

        prefab.AddComponent<AttachObject>();

        this.ReplacePrefab(prefab, Path.Combine(path, prefab.name + ".prefab"));
        GameObject.DestroyImmediate(prefab);
    }

    private void OnCreateWing(string path, string id)
    {
        EditorUtility.DisplayDialog("提示", "还没有实现处理这种类型", "知道了");
    }

    private void FindBasicAssets(string path, string id)
    {
        // 查找模型.
        var modelPath = Path.Combine(path, string.Format("{0}_model.FBX", id));
        if (!File.Exists(modelPath))
        {
            modelPath = Path.Combine(path, string.Format("{0}_body.FBX", id));
        }

        this.model = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);
        if (this.model == null)
        {
            this.errorString = "找不到模型";
            return;
        }

        // 查找动画.
        var animationPath = Path.Combine(path, string.Format("{0}_animation.FBX", id));
        var animationAssets = AssetDatabase.LoadAllAssetsAtPath(animationPath);
        foreach (var asset in animationAssets)
        {
            var animation = asset as AnimationClip;
            if (animation == null)
            {
                continue;
            }

            if (animation.name == "__preview__Take 001")
            {
                continue;
            }

            this.animations.Add(animation);
        }

        // 获取Avatar.
        this.avatar = AssetDatabase.LoadAssetAtPath<Avatar>(animationPath);

        // 搜索材质.
        var materialGUIDs = AssetDatabase.FindAssets("t:material", new string[] { path });
        if (materialGUIDs.Length > 0)
        {
            foreach (var guid in materialGUIDs)
            {
                var materialPath = AssetDatabase.GUIDToAssetPath(guid);
                if (materialPath.StartsWith(id))
                {
                    this.material = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
                    break;
                }
            }

            if (this.material == null)
            {
                var materialPath = AssetDatabase.GUIDToAssetPath(materialGUIDs[0]);
                this.material = AssetDatabase.LoadAssetAtPath<Material>(materialPath);
            }
        }
    }

    private AnimatorOverrideController CreateAnimatorController(
        string basePath, string path, IDictionary<string, string> lookup)
    {
        var baseController = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(basePath);
        var controller = new AnimatorOverrideController(baseController);
        foreach (var srcClip in baseController.animationClips)
        {
            foreach (var clip in this.animations)
            {
                var testName = srcClip.name;
                if (!lookup.TryGetValue(srcClip.name, out testName))
                {
                    continue;
                }

                if (testName == clip.name)
                {
                    controller[srcClip.name] = clip;
                    break;
                }
            }
        }

        var target = AssetDatabase.LoadAssetAtPath<UnityObject>(path);
        if (target != null)
        {
            EditorUtility.CopySerialized(controller, target);
            AssetDatabase.SaveAssets();
        }
        else
        {
            AssetDatabase.CreateAsset(controller, path);
        }

        return controller;
    }

    private void AddUICamera(GameObject root, string name, Vector3 position, Vector3 rotation)
    {
        var uicamera = new GameObject(name);
        uicamera.SetActive(false);
        uicamera.transform.SetParent(root.transform);
        uicamera.transform.localPosition = position;
        uicamera.transform.localEulerAngles = rotation;
        uicamera.transform.localScale = Vector3.one;

        var camera = uicamera.AddComponent<Camera>();
        camera.fieldOfView = 30.0f;
    }

    private void ReplacePrefab(GameObject prefab, string path)
    {
        var target = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        if (target != null)
        {
            PrefabUtility.ReplacePrefab(prefab, target);
        }
        else
        {
            path = path.Replace('\\', '/');
            PrefabUtility.CreatePrefab(path, prefab);
        }
    }
}
