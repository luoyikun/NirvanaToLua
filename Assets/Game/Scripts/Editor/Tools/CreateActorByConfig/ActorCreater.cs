using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
/// <summary>
/// 所有生成模型资源的父类，相当于抽象工厂
/// 主要功能为创建预制体、生成动画控制器、生成材质球
/// </summary>
public abstract class ActorCreater
{
    //public string materialSharedPath = "Assets/Game/Actors/Shared/Shadow.mat";
    public virtual GameObject CreatePrefab(DirectoryInfo dir, out string savePrefabPath)
    {
        var fbxPath = GetFBXPathInDir(dir, "_model");
        var loadFBXPath = PathStartWithAsset(fbxPath);

        var modelPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(loadFBXPath);
        savePrefabPath = Path.Combine(dir.FullName, dir.Name + ".prefab");
        savePrefabPath = PathStartWithAsset(savePrefabPath);
        var instance = GameObject.Instantiate(modelPrefab);
        return instance;
    }

    public abstract void AddComponentsByConfig(GameObject gameObj);

    #region 生成动画控制器部分
    public virtual AnimatorOverrideController CreateAnimatorOverrideController(DirectoryInfo dir)
    {
        var saveController = new AnimatorOverrideController();
        saveController.runtimeAnimatorController = FindControllerTemplate(dir.Parent.Name);

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
    protected AnimatorController FindControllerTemplate(string fileName)
    {
        var templateDirPath = Application.dataPath + "/Game/Actors/Shared";
        var templateControllName = fileName + "Controller.controller";
        var templateControllPath = Path.Combine(templateDirPath, templateControllName);
        var loadControllPath = PathStartWithAsset(templateControllPath);
        var controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(loadControllPath);
        return controller;
    }

    protected AnimationClip MatchAnimationInDir(DirectoryInfo dir, string clipName)
    {
        var filter = CustomFilter(clipName);
        var clipFBXPath = GetFBXPathInDir(dir, filter);
        if (string.IsNullOrEmpty(clipFBXPath))
        {
            Debug.LogWarning(dir.FullName + "have not " + clipName + "Animation FBX file!!!");
            return null;
        }

        var loadClipFBXPath = PathStartWithAsset(clipFBXPath);
        var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(loadClipFBXPath);
        return clip;
    }
    #endregion
    
    #region 生成材质球部分
    public virtual Material CreateMaterial(DirectoryInfo dir)
    {
        var saveMaterialPath = Path.Combine(dir.FullName, dir.Name + "_material.mat");
        saveMaterialPath = PathStartWithAsset(saveMaterialPath);
        var material = new Material(Shader.Find("Game/Standard"));
        material.mainTexture = FindTextureInDir(dir);
        material.SetOverrideTag("RenderType", "Opaque");
        material.SetInt("_CullMode", 2);    // 设置为back
        material.SetInt("_SrcBlend", 1);
        AssetDatabase.CreateAsset(material, saveMaterialPath);
        return material;
        //var sharedMaterial = AssetDatabase.LoadAssetAtPath<Material>(materialSharedPath);
        //var material = new Material(sharedMaterial);
        //material.shader = Shader.Find("Game/Standard");
        //material.mainTexture = FindTextureInDir(dir);
        //AssetDatabase.CreateAsset(material, saveMaterialPath);
        //return material;
    }

    protected Texture FindTextureInDir(DirectoryInfo dir)
    {
        var picturesFiles = dir.GetFiles("*.tga");
        if (picturesFiles.Length >= 1)
        {
            var loadTexturePath = PathStartWithAsset(picturesFiles[0].FullName);
            var texture = AssetDatabase.LoadAssetAtPath<Texture>(loadTexturePath);
            return texture;
        }
        Debug.LogError(dir.FullName + " have not tga file!!!");
        return null;
    } 
    #endregion

    #region 功能类
    public string PathStartWithAsset(string path)
    {
        var safePath = path.Replace("\\", "/");
        int index = safePath.IndexOf("Assets/");
        path = safePath.Substring(index);
        return path;
    }

    protected string GetFBXPathInDir(DirectoryInfo dir, string filter)
    {
        if (string.IsNullOrEmpty(filter))
        {
            return null;
        }

        var files = dir.GetFiles("*.FBX");
        foreach (var file in files)
        {
            if (file.Name.Contains("@"))//当为动画FBX时分离处理
            {
                var fileNameSplits = file.Name.Split('@');
                var clipName = fileNameSplits[1].Replace(".FBX", string.Empty);
                if (clipName == filter)
                {
                    return file.FullName;
                }
            }
            else//当为_model时间
            {
                if (file.Name.Contains(filter))
                {
                    return file.FullName;
                }
            }
        }
        return null;
    }

    protected abstract string CustomFilter(string clipName);
    #endregion
}
