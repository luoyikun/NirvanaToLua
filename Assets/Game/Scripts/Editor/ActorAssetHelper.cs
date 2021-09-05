using UnityEngine;
using UnityEditor;
using Nirvana;
using System.IO;
using System.Text;
using Newtonsoft.Json;

public static class ActorAssetHelper
{
    private static string pathPrefix = "Assets/Game/Actors/";
    private static string monsterPrefix = pathPrefix + "Monster";
    private static string rolePrefix = pathPrefix + "Role";
    private static string mountPrefix = pathPrefix + "Mount";
    private static string NPCPrefix = pathPrefix + "NPC";
    private static string goddessPrefix = pathPrefix + "Goddess";
    private static string mingjiangPrefix = pathPrefix + "MingJiang";
    private static string pifengPrefix = pathPrefix + "Pifeng";

    public static JsonSerializerSettings IndentedAndAllNameHandling()
    {
        return new JsonSerializerSettings()
        {
            Formatting = Formatting.Indented,
            TypeNameHandling = TypeNameHandling.All,
            ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
        };
    }

    [MenuItem("Assets/改变文件夹名称")]
    public static void ChangeFolderName()
    {
        var path = "Assets/Game/UIs/View";
        var allDirectory = Directory.GetDirectories(path);
        foreach (var directory in allDirectory)
        {
            // var directoryName = Path.GetDirectoryName(directory);
            if (directory.EndsWith("_"))
            {
                AssetDatabase.MoveAsset(directory, directory.Substring(0, directory.Length - 1));
            }
        }
    }

    [MenuItem("Assets/UI图片reimport")]
    public static void ReimportUITexture()
    {
        var dir = "Assets/Game/UIs/UIRes";
        var textureGuids = AssetDatabase.FindAssets("t:Texture", new string[] { dir });

        int count = 0;
        int totalCount = textureGuids.Length;

        foreach (var textureGuid in textureGuids)
        {
            var texturePath = AssetDatabase.GUIDToAssetPath(textureGuid);

            EditorUtility.DisplayProgressBar("reimport ui texture", string.Format("{0}/{1} {2}", count, totalCount, texturePath), count / (float)totalCount);

            TextureImporter importer = AssetImporter.GetAtPath(texturePath) as TextureImporter;
            if (importer)
            {
                if (importer.textureType != TextureImporterType.Sprite)
                {
                    importer.textureType = TextureImporterType.Sprite;
                    importer.SaveAndReimport();
                }
            }

            count++;
        }

        EditorUtility.ClearProgressBar();
    }

    [MenuItem("Assets/输出prefab数据/输出角色模型数据", false, 100)]
    public static void OutPutPrefabData()
    {
        if (EditorApplication.isCompiling)
        {
            EditorUtility.DisplayDialog("警告", "请等待编辑器完成编译再执行此功能", "确定");
            return;
        }

        var dir = "Assets/Game/Actors/Role/1101/1101001";
        var dir1 = "Assets/Game/Actors/Role/1102/1102001";
        var dir2 = "Assets/Game/Actors/Role/1103/1103001";
        var dir3 = "Assets/Game/Actors/Monster";
        var prefabGuids = AssetDatabase.FindAssets("t:prefab", new string[] { dir, dir1, dir2, dir3 });
        foreach (var prefabGuid in prefabGuids)
        {
            var prefabPath = AssetDatabase.GUIDToAssetPath(prefabGuid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            var newObj = GameObject.Instantiate(prefab);
            string filePath = string.Format("{0}/Game/Lua/config/prefab_data/json/{1}_config.json", Application.dataPath, prefab.name);
            PrefabDataConfig config = new PrefabDataConfig();
            var actorCtrl = newObj.GetComponent<ActorController>();
            if (actorCtrl != null)
                CreateCtrlConfig(actorCtrl, config);

            var actorTrigger = newObj.GetComponent<ActorTriggers>();
            if (actorTrigger != null)
                CreateTriggerConfig(actorTrigger, config);

            var actorBlinker = newObj.GetComponent<ActorBlinker>();
            if (actorBlinker != null)
                CreateBlinkConfig(actorBlinker, config);

            string jsonstr = JsonConvert.SerializeObject(config);
            Debug.Log(jsonstr);
            FileInfo file = new FileInfo(filePath);
            StreamWriter sw = file.CreateText();
            sw.WriteLine(jsonstr);
            sw.Close();
            sw.Dispose();
        }
    }

    private static void CreateCtrlConfig(ActorController ctrl, PrefabDataConfig config)
    {
        for (int i = 0; i < ctrl.Projectiles.Length; i++)
        {
            PrefabDataConfig.ProjectileData struct1 = new PrefabDataConfig.ProjectileData();
            var data = ctrl.Projectiles[i];
            struct1.Action = data.Action;
            struct1.HurtPosition = (PrefabDataConfig.HurtPositionEnum)data.HurtPosition;
            struct1.Projectile = data.Projectile;
            struct1.FromPosHierarchyPath = GetHierarchyPath(data.FromPosition);
            config.actorController.projectiles.Add(struct1);
        }

        for (int i = 0; i < ctrl.Hurts.Length; i++)
        {
            PrefabDataConfig.HurtData struct2 = new PrefabDataConfig.HurtData();
            var data = ctrl.Hurts[i];
            struct2.Action = data.Action ?? "";
            struct2.HurtEffect = data.HurtEffect;
            struct2.HurtPosition = (PrefabDataConfig.HurtPositionEnum)data.HurtPosition;
            struct2.HurtRotation = (PrefabDataConfig.HurtRotationEnum)data.HurtRotation;
            struct2.HitCount = data.HitCount;
            struct2.HitInterval = data.HitInterval;
            struct2.HitEffect = data.HitEffect;
            struct2.HitPosition = (PrefabDataConfig.HurtPositionEnum)data.HitPosition;
            struct2.HitRotation = (PrefabDataConfig.HurtRotationEnum)data.HitRotation;
            config.actorController.hurts.Add(struct2);
        }

        config.actorController.beHurtEffecct = ctrl.beHurtEffecct;
        config.actorController.beHurtNodeName = ctrl.beHurtPosition == null ? "" : ctrl.beHurtPosition.name;    //对应节点的名称
        config.actorController.beHurtAttach = ctrl.beHurtAttach;
    }

    private static void CreateTriggerConfig(ActorTriggers ctrl, PrefabDataConfig config)
    {
        for(int i = 0; i < ctrl.Effects.Length; i++)
        {
            var effectStruct = new PrefabDataConfig.TriggerEffect();
            var data = ctrl.Effects[i];
            effectStruct.effectAsset = data.EffectAsset;
            effectStruct.playerAtTarget = data.PlayerAtTarget;
            effectStruct.referenceNodeHierarchyPath = GetHierarchyPath(data.ReferenceNode);
            effectStruct.isAttach = data.IsAttach;
            effectStruct.isRotation = data.IsRotation;
            effectStruct.triggerEventName = data.EventName ?? "";
            effectStruct.triggerDelay = data.Delay;
            effectStruct.triggerStopEvent = data.StopEvent ?? "";
            config.actorTriggers.effects.Add(effectStruct);
        }

        for(int i = 0; i < ctrl.Halts.Length; i++)
        {
            var data = ctrl.Halts[i];
            var halt = new PrefabDataConfig.TriggerHalt();
            halt.haltEventName = data.EventName ?? "";
            halt.haltDelay = data.Delay;
            halt.haltContinueTime = data.HaltTime;
            config.actorTriggers.halts.Add(halt);
        }

        for(int i = 0; i < ctrl.Sounds.Length; i++)
        {
            var sound = new PrefabDataConfig.TriggerSound();
            var data = ctrl.Sounds[i];
            sound.soundEventName = data.EventName ?? "";
            sound.soundDelay = data.Delay;
            sound.soundAudioAsset = data.AudioAsset;
            config.actorTriggers.sounds.Add(sound);
        }

        for (int i = 0; i < ctrl.CameraFOVs.Length; i++)
        {
            var data = ctrl.CameraFOVs[i];
            var cameraFov = new PrefabDataConfig.CameraFOV();
            cameraFov.fovEventName = data.EventName ?? "";
            cameraFov.fovDelay = data.Delay;
            cameraFov.fovFiledOfView = data.FiledOfView;
            cameraFov.duration = data.Duration;
            config.actorTriggers.cameraFOVs.Add(cameraFov);
        }

        for(int i = 0; i < ctrl.SceneFades.Length; i++)
        {
            var fade = new PrefabDataConfig.SceneFade();
            var data = ctrl.SceneFades[i];
            fade.fadeEventName = data.EventName ?? "";
            fade.fadeDelay = data.Delay;
            var color = new PrefabDataConfig.FadeColor();
            color.colorR = data.Color.r;
            color.colorG = data.Color.g;
            color.colorB = data.Color.b;
            color.colorA = data.Color.a;
            fade.fadeColor = color;
            fade.fadeIn = data.FadeIn;
            fade.fadeHold = data.Hold;
            fade.fadeOut = data.FadeOut;
            config.actorTriggers.sceneFades.Add(fade);
        }

        for(int i = 0; i < ctrl.FootSteps.Length; i++)
        {
            var footStep = new PrefabDataConfig.FootStep();
            var data = ctrl.FootSteps[i];
            footStep.footStepEventName = data.EventName ?? "";
            footStep.footStepDelay = data.Delay;
            footStep.footNodeHierarchyPath = GetHierarchyPath(data.FootNode);
            footStep.footprint = data.FootPrint;
            footStep.footStepDust = data.FootStepDust;
            footStep.footAsset = data.AudioAsset;
            config.actorTriggers.footsteps.Add(footStep);
        }
    }

    private static void CreateBlinkConfig(ActorBlinker blink, PrefabDataConfig config)
    {
        config.actorBlinker.blinkFadeIn = blink.FadeIn;
        config.actorBlinker.blinkFadeHold = blink.FadeHold;
        config.actorBlinker.blinkFadeOut = blink.FadeOut;
    }

    [MenuItem("Assets/删除控件/删除prefab上的组件", false, 100)]
	public static void RemoveSimpleShadowComponent()
    {
        //var dir = "Assets/Game/Actors/Role/1101";
        //var dir1 = "Assets/Game/Actors/Role/1102";
        //var dir2 = "Assets/Game/Actors/Role/1103";
        //var dir3 = "Assets/Game/Actors/Monster";
        var npc = "Assets/Game/Actors/NPC";

        var prefabGuids = AssetDatabase.FindAssets("t:prefab", new string[] { npc });
        foreach (var prefabGuid in prefabGuids)
        {
            var prefabPath = AssetDatabase.GUIDToAssetPath(prefabGuid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);

            var simpleShadowComponent = prefab.GetComponentInChildren<SimpleShadow>();
            if (simpleShadowComponent != null)
                GameObject.DestroyImmediate(simpleShadowComponent, true);

            //var optimizer = prefab.GetComponentInChildren<AnimatorOptimizer>();
            //if (optimizer != null)
            //    GameObject.DestroyImmediate(optimizer, true);

            var clickObject = prefab.GetComponentInChildren<ClickableObject>();
            if (clickObject != null)
                GameObject.DestroyImmediate(clickObject, true);

            var timeLine = prefab.GetComponentInChildren<ActorTimelineEvent>();
            if (timeLine != null)
                GameObject.DestroyImmediate(timeLine, true);

            var actorBlinker = prefab.GetComponentInChildren<ActorBlinker>();
            if (actorBlinker != null)
                GameObject.DestroyImmediate(actorBlinker, true);

            var actorCtrl = prefab.GetComponentInChildren<ActorController>();
            if (actorCtrl != null)
                GameObject.DestroyImmediate(actorCtrl, true);

            //var animEvent = prefab.GetComponentInChildren<AnimatorEventDispatcher>();
            //if (animEvent != null)
            //    GameObject.DestroyImmediate(animEvent, true);

            var actorTrigger = prefab.GetComponentInChildren<ActorTriggers>();
            if (actorTrigger != null)
                GameObject.DestroyImmediate(actorTrigger, true);

            var materialSwitcher = prefab.GetComponentInChildren<MaterialSwitcher>();
            if (materialSwitcher != null)
                GameObject.DestroyImmediate(materialSwitcher, true);

            var actorFadeout = prefab.GetComponentInChildren<ActorFadeout>();
            if (actorFadeout != null)
                GameObject.DestroyImmediate(actorFadeout, true);

            var actorEffect = prefab.GetComponentInChildren<ActorAttachEffect>();
            if (actorEffect != null)
                GameObject.DestroyImmediate(actorEffect, true);

            var newObj = GameObject.Instantiate(prefab);

			PrefabUtility.ReplacePrefab(newObj, prefab);
		}

		AssetDatabase.Refresh();
	}


    private static bool checkPath(string prefix, string path)
    {
        if (!path.StartsWith(prefix))
        {
            var message = string.Format("prefab路径需要放在: {0}下面", prefix);

            EditorUtility.DisplayDialog("错误", message, "确定");
            return false;
        }

        return true;
    }

    private static bool checkPrefab(GameObject obj)
    {
        if (obj == null || PrefabUtility.GetPrefabType(obj) != PrefabType.Prefab)
        {
            EditorUtility.DisplayDialog("错误", "只能自动给prefab添加控件", "确定");
            return false;
        }

        return true;
    }

    private static bool commonCheck(string prefix)
    {
        var asset = Selection.activeGameObject;
        var path = AssetDatabase.GetAssetPath(asset);

        if (!checkPrefab(asset))
        {
            return false;
        }

        if (!checkPath(prefix, path))
        {
            return false;
        }

        return true;
    }

    private static T addComponent<T>(GameObject obj) where T: Component
    {
        T component = obj.GetComponent<T>();
        if (component != null)
        {
            return component;
        }

        return obj.AddComponent<T>();
    }

    private static void addSimpleShadow(GameObject obj)
    {
        SimpleShadow simpleShadow = addComponent<SimpleShadow>(obj);
        simpleShadow.ShadowMaterial = AssetDatabase.LoadAssetAtPath<Material>("Assets/Game/Actors/Shared/Shadow.mat");
    }

    private static void addAnimatorOptimizerComponent(GameObject asset, string []searchPatterns)
    {
        AnimatorOptimizer animatorOptimizer = addComponent<AnimatorOptimizer>(asset);
        animatorOptimizer.SearchPatterns = searchPatterns;
        animatorOptimizer.SearchExposed();
        animatorOptimizer.Optimize();
    }

    private static void addCommonComponent(GameObject asset, string []searchPatterns)
    {
        addAnimatorOptimizerComponent(asset, searchPatterns);

        addComponent<ClickableObject>(asset);
        addSimpleShadow(asset);

        addComponent<ActorBlinker>(asset);
        addComponent<ActorTriggers>(asset);
        addComponent<ActorController>(asset);
    }

    [MenuItem("Assets/添加控件/自动添加Monster控件", false, 100)]
    public static void AutoAddMonsterComponent()
    {
        if(!commonCheck(monsterPrefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        addCommonComponent(asset, new string[] { "buff_*", "ui_*", "hurt_*" });

        ActorAttachment actorAttachment = addComponent<ActorAttachment>(asset);
        actorAttachment.AutoPick();

        EditorUtility.SetDirty(asset);
    }

    private static void addRoleComponent(string prefix)
    {
        if (!commonCheck(prefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        AnimatorOptimizer animatorOptimizer = addComponent<AnimatorOptimizer>(asset);
        animatorOptimizer.SearchPatterns = new string[] { "buff_.*", "hurt_.*", "_.*point", "ui", "guadian" };
        animatorOptimizer.SearchExposed();
        animatorOptimizer.Optimize();

        ActorAttachment actorAttachment = addComponent<ActorAttachment>(asset);
        actorAttachment.AutoPick();

        addComponent<ActorBlinker>(asset);
        addComponent<ActorTriggers>(asset);
        addComponent<ActorTimelineEvent>(asset);
        addComponent<ActorController>(asset);
        addComponent<ClickableObject>(asset);
        addComponent<AnimatorEventDispatcher>(asset);

        addSimpleShadow(asset);

        EditorUtility.SetDirty(asset);
    }

    [MenuItem("Assets/添加控件/自动添加Role控件", false, 200)]
    public static void AutoAddRoleComponent()
    {
        addRoleComponent(rolePrefix);
    }

    [MenuItem("Assets/添加控件/自动添加Mount控件", false, 300)]
    public static void AutoAddMountComponent()
    {
        if (!commonCheck(mountPrefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        addCommonComponent(asset, new string[] { "mount_point", "guadian" });
        addComponent<LimitSceneEffects>(asset);

        EditorUtility.SetDirty(asset);
    }


    [MenuItem("Assets/添加控件/自动添加NPC控件", false, 400)]
    public static void AutoAddNPCComponent()
    {
        if (!commonCheck(NPCPrefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        addAnimatorOptimizerComponent(asset, new string[] { "ui" });

        ActorAttachment actorAttachment = addComponent<ActorAttachment>(asset);
        actorAttachment.AutoPick();

        addSimpleShadow(asset);
        addComponent<ClickableObject>(asset);

        EditorUtility.SetDirty(asset);
    }


    [MenuItem("Assets/添加控件/自动添加goddess控件", false, 500)]
    public static void AutoAddGoddessComponent()
    {
        if (!commonCheck(goddessPrefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        addCommonComponent(asset, new string[] { "ui_*", "wing_point", "weapon_point", "effect_*", "texiao_guadian01", "ui" });

        ActorAttachment actorAttachment = addComponent<ActorAttachment>(asset);
        actorAttachment.AutoPick();

        addComponent<AnimatorEventDispatcher>(asset);
        addComponent<QualityControlActive>(asset);

        EditorUtility.SetDirty(asset);
    }

    [MenuItem("Assets/添加控件/自动添加mingjiang控件", false, 600)]
    public static void AutoAddMingJiangComponent()
    {
        addRoleComponent(pifengPrefix);
    }

    [MenuItem("Assets/添加控件/自动添加pifeng控件", false, 700)]
    public static void AutoAddpifengComponent()
    {
        if (!commonCheck(pifengPrefix))
        {
            return;
        }

        var asset = Selection.activeGameObject;

        addAnimatorOptimizerComponent(asset, new string[] { "wing_point", "guadian_*" });
        addComponent<AttachObject>(asset);
        addComponent<LimitSceneEffects>(asset);

        EditorUtility.SetDirty(asset);
    }

    [MenuItem("Assets/UnmarkAssetBundleName")]
    public static void UnmarkAssetBundle()
    {
        Object obj = Selection.activeObject;
        var dir = AssetDatabase.GetAssetPath(obj);
        Debug.Log("Reimport dir: " + dir);

        var files = Directory.GetFiles(dir, "*.*", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            if (!file.EndsWith(".meta"))
            {
                AssetImporter importer = AssetImporter.GetAtPath(file);
                if (importer != null)
                {
                    importer.assetBundleName = string.Empty;
                    // importer.assetBundleVariant = string.Empty;
                    importer.SaveAndReimport();
                }
            }
        }
    }

    public static string GetHierarchyPath(Transform tran)
    {
        var sb = new StringBuilder();
        sb.Append(tran.name);
        var node = tran.parent;

        while (node != null && node.parent != null)
        {
            sb.Insert(0, node.name + '/');
            node = node.parent;
        }

        return sb.ToString();
    }
}
