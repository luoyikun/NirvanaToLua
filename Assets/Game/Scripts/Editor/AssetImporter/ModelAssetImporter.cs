
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine.Rendering;

class ModelAssetImporter : AssetPostprocessor
{
    private static string SceneEnviromentDir = "Assets/Game/Environments/";

    public void OnPreprocessModel()
    {
        var modelImporter = assetImporter as ModelImporter;
        modelImporter.importMaterials = false;

        var model = AssetDatabase.LoadMainAssetAtPath(modelImporter.assetPath);
        if (null != model)
        {
            if (ImporterUtils.IsIgnoreImportRule(model))
            {
                return;
            }
        }

        AutoAnimationClip(modelImporter);
        modelImporter.importMaterials = false;

        if (modelImporter.assetPath.StartsWith(AssetBundleMarkRule.ActorsDir))
        {
            modelImporter.preserveHierarchy = true;
            SetAnimationClipLoop(modelImporter);
        }

        ProcessGlobalScele(modelImporter);
        ProcessIsReadable(modelImporter, model);
        ProcessOptimizeMesh(modelImporter);
        ProcessMeshCompression(modelImporter);
        ProcessTangents(modelImporter);
        ProcessMaterials(modelImporter);
    }

    public void OnPostprocessModel(GameObject model)
    {
        Renderer[] renders = model.GetComponentsInChildren<Renderer>();
        string path = AssetDatabase.GetAssetPath(model);
        ProcessRenderMaterial(renders, path);
        ProcessRenderShadow(renders, path);
    }

    // 处理render去掉材质球
    private static void ProcessRenderMaterial(Renderer[] renders, string path)
    {
        foreach (var render in renders)
        {
            render.sharedMaterials = new Material[render.sharedMaterials.Length];
        }
    }

    // 去掉阴影
    private static void ProcessRenderShadow(Renderer[] renders, string path)
    {
        if (path.StartsWith(SceneEnviromentDir))
        {
            return;
        }

        foreach (var render in renders)
        {
            render.receiveShadows = false;
            render.shadowCastingMode = ShadowCastingMode.Off;
        }
    }

    private static void ProcessGlobalScele(ModelImporter assetImporter)
    {
        assetImporter.globalScale = 1;
    }

    private static void ProcessIsReadable(ModelImporter assetImporter, Object model)
    {
        if (assetImporter.assetPath.StartsWith(SceneEnviromentDir))
        {
            assetImporter.isReadable = true;
            return;
        }

        if (null == model || ImporterUtils.CheckLabel(model, ImporterUtils.ReadableLabel))
        {
            return;
        }

        assetImporter.isReadable = false;
    }

    private static void ProcessOptimizeMesh(ModelImporter assetImporter)
    {
        assetImporter.optimizeMesh = true;
    }

    private static void ProcessMeshCompression(ModelImporter assetImporter)
    {
        if (assetImporter.meshCompression < ModelImporterMeshCompression.Medium)
        {
            assetImporter.meshCompression = ModelImporterMeshCompression.Medium;
        }

        assetImporter.animationCompression = ModelImporterAnimationCompression.Optimal;
    }

    private static void ProcessTangents(ModelImporter assetImporter)
    {
        assetImporter.importTangents = ModelImporterTangents.None;
    }

    private static void ProcessMaterials(ModelImporter assetImporter)
    {
        assetImporter.importMaterials = false;
    }

    static void AutoAnimationClip(ModelImporter importer)
    {
        var fileDir = Path.GetDirectoryName(importer.assetPath);
        var fileName = Path.GetFileNameWithoutExtension(importer.assetPath);
        var filePath = Path.Combine(fileDir, fileName + ".split");
        if (!File.Exists(filePath))
        {
            return;
        }

        if (importer.importedTakeInfos.Length == 0)
        {
            return;
        }

        var takeName = importer.importedTakeInfos[0].name;
        using (var reader = File.OpenText(filePath))
        {
            var clipAnimations = new List<ModelImporterClipAnimation>();
            while (!reader.EndOfStream)
            {
                var line = reader.ReadLine();
                if (string.IsNullOrEmpty(line))
                {
                    continue;
                }

                var tokens = line.Split(new char[] { ' ', '\t' }, System.StringSplitOptions.RemoveEmptyEntries);
                if (tokens.Length != 4)
                {
                    Debug.LogWarningFormat(
                        "The animation split file {0} format error: {1}",
                        fileName,
                        line);
                    continue;
                }

                var name = tokens[0];
                if (string.IsNullOrEmpty(name))
                {
                    Debug.LogWarningFormat(
                        "The animation split file {0} format error: {1}",
                        fileName,
                        line);
                    continue;
                }

                float start;
                if (!float.TryParse(tokens[1], out start))
                {
                    Debug.LogWarningFormat(
                        "The animation split file {0} format error: {1}",
                        fileName,
                        line);
                    continue;
                }

                float end;
                if (!float.TryParse(tokens[2], out end))
                {
                    Debug.LogWarningFormat(
                        "The animation split file {0} format error: {1}",
                        fileName,
                        line);
                    continue;
                }

                bool loop;
                if (!bool.TryParse(tokens[3], out loop))
                {
                    Debug.LogWarningFormat(
                        "The animation split file {0} format error: {1}",
                        fileName,
                        line);
                    continue;
                }

                var clip = new ModelImporterClipAnimation();
                clip.name = name;
                clip.firstFrame = start;
                clip.lastFrame = end;
                clip.loopTime = loop;
                clip.takeName = takeName;
                clipAnimations.Add(clip);
            }
            importer.clipAnimations = clipAnimations.ToArray();
        }
    }

    static void SetAnimationClipLoop(ModelImporter modelImporter)
    {
        string path = AssetDatabase.GetAssetPath(modelImporter);
        bool isLoop = CheckIsLoop(path);

        var clipAnimations = modelImporter.clipAnimations;
        foreach (var takeInfo in clipAnimations)
        {
            if (isLoop && takeInfo.loopTime == false)
            {
                takeInfo.loopTime = true;
            }
        }

        modelImporter.clipAnimations = clipAnimations;
    }

    static bool CheckIsLoop(string path)
    {
        var splits = path.Split('@');
        var aniNameSuffix = splits[splits.Length - 1];//取得@后面的动画名
        var aniNameNotSuffix = aniNameSuffix.Split('.')[0];//去掉后缀

        //动画包含下列关键词的动画循环
        if (aniNameNotSuffix.Contains("idle") ||
            aniNameNotSuffix.Contains("run") ||
            aniNameNotSuffix.Contains("walk") ||
            aniNameNotSuffix.Contains("mid"))
        {
            return true;
        }

        //动画名等于下列名的循环
        switch (aniNameNotSuffix)
        {
            case "fishing":
                return true;
            case "hug":
                return true;
            case "caiji":
                return true;
            case "chongci":
                return true;
            case "dunxia":
                return true;
        }
        return false;
    }
}

