using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class FindImage : EditorWindow
{
    static List<Object> list = new List<Object>();
    Vector2 scrollerPos = new Vector2();
    float width = 0;
    float height = 0;
    [MenuItem("自定义工具/查找图片")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<FindImage>(false, "FindSprite");
    }
    private void OnGUI()
    {
        GUILayout.Space(10);
        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Width");
        width = EditorGUILayout.FloatField(width);
        GUILayout.Label("Height");
        height = EditorGUILayout.FloatField(height);
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(10);
        if (GUILayout.Button("Find"))
        {
            SearchImage();
        }
        scrollerPos = EditorGUILayout.BeginScrollView(scrollerPos);
        foreach (var obj in list)
        {
            EditorGUILayout.ObjectField(obj, typeof(Sprite), true);
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
        string[] guids = AssetDatabase.FindAssets("t:Sprite", new string[] { "Assets/Game" });
        int endIndex = guids.Length;
        if(endIndex < 1)
        {
            this.ShowNotification(new GUIContent("No Sprite"));
            return;
        }
        float nextTime = 0;
        bool hasFind = false;
        for(int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var sprite = AssetDatabase.LoadAssetAtPath(path, typeof(Sprite)) as Sprite;
            if (sprite.rect.width == width && sprite.rect.height == height)
            {
                list.Add(sprite);
                hasFind = true;
            }
            if(nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("查找中", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if(cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
        if(!hasFind)
        {
            this.ShowNotification(new GUIContent("没有找到符合的Sprite"));
        }
    }
}
