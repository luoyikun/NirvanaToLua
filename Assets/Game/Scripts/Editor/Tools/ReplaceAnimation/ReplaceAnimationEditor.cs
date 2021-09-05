using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class ReplaceAnimationEditor : Editor {
    
    private static string Dir_Path = "/Game/Actors/Monster";
    private static string bindDirPath = @"F:\Unity Project\UI Project\u3d_proj\Assets\@TianTianCi\Monster\3003";

    [MenuItem("Tools/AnimationEditor/ReplaceAnimation")]
    static void Execute()
    {
        Dir_Path = EditorUtility.OpenFolderPanel("旧的动画文件目录", "旧的动画文件目录", "旧的动画文件目录");
        if (string.IsNullOrEmpty(Dir_Path))
        {
            return;
        }
        bindDirPath = EditorUtility.OpenFolderPanel("新的动画文件目录", "新的动画文件目录", "新的动画文件目录");
        if (string.IsNullOrEmpty(bindDirPath))
        {
            return;
        }

        DirectoryInfo dir = new DirectoryInfo(Dir_Path);
        DirectoryInfo bindDir = new DirectoryInfo(bindDirPath);
        DoAllAnimation(dir, bindDir);
    }

    static void DoAllAnimation(DirectoryInfo dir, DirectoryInfo bindDir)
    {
        originNode = new Node();
        BindTwoDirectory(originNode, dir, bindDir);
        AnalysisNode(originNode);
        AssetDatabase.Refresh();
        EditorUtility.DisplayDialog("提示", "替换动画资源完毕", "确定");
    }

    static void BindTwoDirectory(Node node, DirectoryInfo dir, DirectoryInfo bindDir)
    {
        node.currentDir = dir;
        node.bindDir = bindDir;
        node.ChildrenNode = new List<Node>();

        DirectoryInfo[] childrenDir = dir.GetDirectories();
        DirectoryInfo[] bindChildrenDir = bindDir.GetDirectories();

        if (childrenDir.Length > 0 && bindChildrenDir.Length > 0)
        {
            foreach (DirectoryInfo childDir in childrenDir)
            {
                foreach (DirectoryInfo bindChildDir in bindChildrenDir)
                {
                    if (childDir.Name == bindChildDir.Name)
                    {
                        Node childNode = new Node();
                        BindTwoDirectory(childNode, childDir, bindChildDir);
                        node.ChildrenNode.Add(childNode);
                    }
                }
            }
        }
    }

    static void AnalysisNode(Node node)
    {
        //Debug.Log(node.currentDir.FullName + "---" + node.bindDir.FullName);
        if (node.currentDir != null && node.bindDir != null)
        {
            DoSingleAnimation(node.currentDir, node.bindDir);
            Debug.Log(node.currentDir.FullName + " Replace Over!!!");
        }
        
        foreach (Node child in node.ChildrenNode)
        {
            AnalysisNode(child);
        }
    }

    static void DoSingleAnimation(DirectoryInfo dir, DirectoryInfo bindDir)
    {
        AnimatorOverrideController overrideController = GetOverriderControllerInFolder(dir);
        if (overrideController == null)
        {
            Debug.LogWarning(dir.FullName + " have not one OverrideController!!!");
            return;
        }

        List<KeyValuePair<AnimationClip, AnimationClip>> clipOverrides = new List<KeyValuePair<AnimationClip, AnimationClip>>();
        overrideController.GetOverrides(clipOverrides);

        //先保存 AnimatorOverrideController的名字，避免删除复制文件后丢失
        Dictionary<AnimationClip, string> overrideName = new Dictionary<AnimationClip, string>();
        foreach (KeyValuePair<AnimationClip, AnimationClip> clipOverride in clipOverrides)
        {
            if (clipOverride.Value == null)
            {
                overrideName.Add(clipOverride.Key, string.Empty);
            }
            else
            {
                overrideName.Add(clipOverride.Key, clipOverride.Value.name);
            }
            
        }
        
        List<string> bindModelsPath = HandleBindDirectory(dir, bindDir);
        List<AnimationClip> bindClipList = new List<AnimationClip>();

        foreach (var path in bindModelsPath)
        {
            string fullPath = path.Replace("\\", "/");
            int index = fullPath.IndexOf("Assets/");
            string loadPath = fullPath.Substring(index);
            
            AnimationClip animationClip = AssetDatabase.LoadAssetAtPath<AnimationClip>(loadPath);
            bindClipList.Add(animationClip);
        }
        
        for (int i = 0; i < clipOverrides.Count; i++)
        {
            //根据保存下来的name找到对应的AnimationClip
            AnimationClip replaceClip = GetAnimationClip(bindClipList, overrideName[clipOverrides[i].Key]);
            if (replaceClip == null)
            {
                replaceClip = clipOverrides[i].Value;
            }

            clipOverrides[i] = new KeyValuePair<AnimationClip, AnimationClip>(clipOverrides[i].Key, replaceClip);
        }
        overrideController.ApplyOverrides(clipOverrides);
    }

    #region DoSingleAnimationNeedFunction
    static AnimatorOverrideController GetOverriderControllerInFolder(DirectoryInfo dir)
    {
        FileInfo[] files = dir.GetFiles("*.overrideController");
        if (files.Length == 1)
        {
            string fullPath = files[0].FullName.Replace("\\", "/");
            int index = fullPath.IndexOf("Assets/");
            string loadPath = files[0].FullName.Substring(index);
            AnimatorOverrideController overriderController =
                AssetDatabase.LoadAssetAtPath<AnimatorOverrideController>(loadPath);
            return overriderController;
        }
        return null;
    }
    
    static List<string> HandleBindDirectory(DirectoryInfo dir, DirectoryInfo bindDir)
    {
        List<string> modelFullPathList = new List<string>();

        FileInfo[] files = bindDir.GetFiles("*.FBX");
        if (files.Length > 0)
        {
            foreach (FileInfo file in files)
            {
                string copyFilePath = dir.FullName + "\\" + file.Name;
                if (File.Exists(copyFilePath))
                {
                    string oldMetaPath = copyFilePath + ".meta";
                    string newMetaPath = file.FullName + ".meta";
                    File.Copy(newMetaPath, oldMetaPath, true);
                }
                file.CopyTo(copyFilePath, true);

                modelFullPathList.Add(copyFilePath);
            }
            AssetDatabase.Refresh();
        }
        return modelFullPathList;
    }

    static AnimationClip GetAnimationClip(List<AnimationClip> clipList, string targetName)
    {
        foreach (var clip in clipList)
        {
            if (clip.name == targetName)
            {
                return clip;
            }

            //为了将idle_n替换为idle
            if (targetName == "idle_n" && clip.name == "idle")
            {
                return clip;
            }

            //为了将rest更换成zhankai添加的额外操作
            if (targetName == "rest" && clip.name == "zhankai")
            {
                return clip;
            }

            //将 skick1back, skick1mid, skick1pre替换为 attack1back, attack1mid, attack1pre
            if (targetName == "skick1back" && clip.name == "attack1back")
            {
                return clip;
            }
            if (targetName == "skick1mid" && clip.name == "attack1mid")
            {
                return clip;
            }
            if (targetName == "skick1pre" && clip.name == "attack1pre")
            {
                return clip;
            }
        }
        return null;
    } 
    #endregion

    private static Node originNode;
    public class Node
    {
        public DirectoryInfo currentDir;
        public DirectoryInfo bindDir;
        public List<Node> ChildrenNode;
    }
}