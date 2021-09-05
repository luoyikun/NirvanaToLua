using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class BuildPackage : EditorWindow
{
    private static List<Object> objectList = new List<Object>();
    private static List<string> custonNameList = new List<string>();
    private static Vector2 scrollerPos = Vector2.zero;

    public static string[] rules = new string[]
    {
        "Assets/Game/Effects Assets/Game/Effects2",
    };

    [MenuItem("自定义工具/资源拷贝/打包资源")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<BuildPackage>(false, "打包资源");
    }

    private void OnGUI()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Insert"))
        {
            objectList.Add(new Object());
            custonNameList.Add(string.Empty);
        }
        if (GUILayout.Button("Remove"))
        {
            if (objectList.Count > 0)
            {
                objectList.RemoveAt(objectList.Count - 1);
                custonNameList.RemoveAt(custonNameList.Count - 1);
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();
        if (GUILayout.Button("Build"))
        {
            UnityPost.PackageRuler.Rules = rules;
            UnityPost.Sender.BuildPackage(objectList.ToArray(), custonNameList.ToArray());
        }
        EditorGUILayout.Space();

        scrollerPos = EditorGUILayout.BeginScrollView(scrollerPos);
        for (int i = 0; i < objectList.Count; ++i)
        {
            EditorGUILayout.BeginHorizontal();
            objectList[i] = EditorGUILayout.ObjectField(objectList[i], typeof(Object), false);
            custonNameList[i] = EditorGUILayout.TextArea(custonNameList[i]);
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }
}

public class ReceivePackage : EditorWindow
{
    private static RuntimeAnimatorController animatorController;

    [MenuItem("自定义工具/资源拷贝/接收资源")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<ReceivePackage>(false, "接收资源");
    }

    private void OnGUI()
    {
        //animatorController = EditorGUILayout.ObjectField(animatorController, typeof(RuntimeAnimatorController), false) as RuntimeAnimatorController;
        EditorGUILayout.Space();
        if (GUILayout.Button("Receive"))
        {
            Receive();
        }
    }

    public static void Receive()
    {
        UnityPost.PackageRuler.Rules = BuildPackage.rules;
        var targetPath = EditorUtility.OpenFolderPanel("选择文件夹", "Assets\\Game\\Actors", "");
        if (null != animatorController)
        {
            UnityPost.Receiver.Animator = animatorController;
        }

        string[] newFiles;
        if (UnityPost.Receiver.ReceivePackage(targetPath, out newFiles))
        {
            FixGameObjectAttach(newFiles);
        }
    }

    private static void FixGameObjectAttach(string[] assetPaths)
    {
        foreach (var path in assetPaths)
        {
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            if (null != obj)
            {
                var attachs = obj.GetComponentsInChildren<Game.GameObjectAttach>();
                foreach (var attach in attachs)
                {
                    attach.RefreshAssetBundleName();
                }
            }
        }
    }


}
