using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

public class FindMissingImage : BaseEditorWindow
{
    private List<GameObject> list = new List<GameObject>();
    private Vector2 scrollerPos = new Vector2();
    private Object selectObj;
    private bool skipHideObject = false;
    private UnityEngine.Object targetFile;

    [MenuItem("自定义工具/查找图片丢失")]

    private static void ShowWindow()
    {
        EditorWindow.GetWindow<FindMissingImage>(false, "查找图片丢失");
    }

    private void OnGUI()
    {
        EditorGUILayout.Space();
        this.skipHideObject = EditorGUILayout.Toggle("跳过隐藏的Object", this.skipHideObject);
        EditorGUILayout.Space();
        targetFile = EditorGUILayout.ObjectField("添加文件夹:", targetFile, typeof(UnityEngine.Object), true) as UnityEngine.Object;
        EditorGUILayout.Space();
       
        if (GUILayout.Button("search"))
        {
            this.list.Clear();
            this.Search();
        }
        this.scrollerPos = EditorGUILayout.BeginScrollView(this.scrollerPos);
        var count = this.list.Count;
        if (count > 0)
        {
            EditorGUILayout.TextArea("数量: " + count);
        }
        foreach (var obj in this.list)
        {
            var style = EditorStyles.textField;
            if (obj == this.selectObj)
                style = EditorStyles.whiteLabel;
            if (GUILayout.Button(obj.name, style))
            {
                this.selectObj = obj;
                PingObj(obj);
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void Search()
    {
        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] {AssetDatabase.GetAssetPath(targetFile)});
        int endIndex = guids.Length;
        if (endIndex < 1)
        {
            return;
        }
        float nextTime = 0;
        for (int i = 0; i < endIndex; i++)
        {
            var guid = guids[i];
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var obj = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;
            this.Check(obj);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

    private void Check(GameObject obj)
    {   
        var images = obj.GetComponentsInChildren<Image>(!this.skipHideObject);
        foreach (var image in images)
        {
            if (CheckMissingSprite(image.sprite))
            {
                list.Add(image.gameObject);
            }
        }
    }

    private static bool CheckMissingSprite(Sprite sprite)
    {
        var instanceID = sprite.GetInstanceID();
        if (instanceID == 0)
            return false;
        var instance = AssetDatabase.LoadAssetAtPath(AssetDatabase.GetAssetPath(instanceID), typeof(Sprite));
        if (null == instance)
        {
            return true;
        }
        return false;
    }
}
