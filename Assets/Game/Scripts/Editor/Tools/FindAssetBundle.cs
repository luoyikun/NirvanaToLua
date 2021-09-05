using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class FindAssetBundle : EditorWindow
{
    private string assetBundleName = "";
    private List<string> list = new List<string>();
    Vector2 scrollerPos = new Vector2();
    private string selectPath;

    [MenuItem("自定义工具/FindAssetBundle")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<FindAssetBundle>(false, "FindAssetBundle");
    }

    private void OnGUI()
    {
        assetBundleName = EditorGUILayout.TextField(assetBundleName);
        if (GUILayout.Button("Search"))
        {
            SearchImage();
        }
        GUILayout.Space(10);
        scrollerPos = EditorGUILayout.BeginScrollView(scrollerPos);
        foreach (var path in list)
        {
            var style = EditorStyles.textField;
            if (path == this.selectPath)
                style = EditorStyles.whiteLabel;
            if (GUILayout.Button(path, style))
            {
                this.selectPath = path;
                EditorGUIUtility.PingObject(AssetDatabase.LoadAssetAtPath(path, typeof(Object)));
            }
        }
        EditorGUILayout.EndScrollView();
    }

    void SearchImage()
    {
        list.Clear();
        this.Search();
        this.Repaint();
    }
    void Search()
    {
        var paths = AssetDatabase.GetAssetPathsFromAssetBundle(assetBundleName);
        foreach (var path in paths)
        {
            list.Add(path);
        }
    }
}
