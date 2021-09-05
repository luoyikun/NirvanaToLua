using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Nirvana;

public class CheckCgCamera : EditorWindow
{
    [MenuItem("自定义工具/检测设置Cg摄像机层级")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(CheckCgCamera), false, "检测设置Cg摄像机层级");
    }

    private UnityEngine.Object OnCheckFolder;               //检测模型文件夹目录

    private string[] _GetFiles(string path, bool recursive = true)
    {
        List<string> withExtensions = new List<string>() { ".prefab" };

        var resultList = new List<string>();
        string[] files = Directory.GetFiles(path, "*.*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);

        foreach (var strPath in files)
        {
            if (withExtensions.Contains(Path.GetExtension(strPath).ToLower()))
            {
                resultList.Add(strPath.Replace('\\', '/'));
            }
        }

        return resultList.ToArray();
    }

    // 修改CG层级
    private void ChangeHandler(UnityEngine.Object OnCheckFolder)
    {
        if (!OnCheckFolder)
        {
            Debug.LogError("文件夹获取错误，请检查!");
            return;
        }
        string strCheckFolderPath = AssetDatabase.GetAssetPath(OnCheckFolder);
        string[] lsFiles = _GetFiles(strCheckFolderPath);
        foreach (var path in lsFiles)
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab != null)
            {
                var m_cameras = prefab.transform.GetComponentsInChildren<Camera>(true);
                foreach (var camera in m_cameras)
                {
                    if (camera)
                    {
                        camera.depth = 100;
                    }
                }
                var go = GameObject.Instantiate(prefab);
                PrefabUtility.ReplacePrefab(go, prefab);
                DestroyImmediate(go);
            }
            else
            {
                Debug.LogError("未知错误，无法找到prefab");
            }
        }
    }

    void OnGUI()
    {

        if (OnCheckFolder == null)
        {
            OnCheckFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/CG");
        }
        OnCheckFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckFolder, typeof(UnityEngine.Object), false);
        if (GUILayout.Button("搜索Cg并修改", GUILayout.Width(300)))
        {
            this.ChangeHandler(OnCheckFolder);
        }

        GUILayout.Space(30);

        GUILayout.Label("使用说明：\r\n这工具主要是用来批量修改CG的层级用的。" +
            "\r\n因为项目用了3个摄像机层级都比较高，" + 
            "\r\n可能因为没把CG层级设高一些的话会给某些UI面板挡住CG，" + 
            "\r\n所以提供此工具批量去修改方便某些人遗漏一些摄像机");
    }
}
