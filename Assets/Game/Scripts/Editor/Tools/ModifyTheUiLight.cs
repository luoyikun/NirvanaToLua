using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.SceneManagement;

public class ModifyTheUiLight : BaseEditorWindow
{
    private List<GameObject> list = new List<GameObject>();
    private Vector2 scrollerPos = new Vector2();
    private Object selectObj;

    [MenuItem("自定义工具/批量修改UiLight")]
	public static void ShowWindow()
	{
		EditorWindow.GetWindow(typeof(ModifyTheUiLight), false, "修改UiLight");
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

	void OnGUI()
	{
		if (OnCheckFolder == null)
		{
			OnCheckFolder = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>("Assets/Game/UIs/Views");
		}
		OnCheckFolder = EditorGUILayout.ObjectField("拖入搜索目录", OnCheckFolder, typeof(UnityEngine.Object), false);

        if (GUILayout.Button("搜索View文件夹UILight", GUILayout.Width(300)))
        {
            this.SearchUILight();
        }

        if (GUILayout.Button("删除View文件夹UILight", GUILayout.Width(300)))
        {
            this.DestroyUILight();
        }

        if (GUILayout.Button("搜索Actors整个文件夹并修改为None", GUILayout.Width(300)))
		{
			this.ChangeHandler(OnCheckFolder);
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

    private void SearchUILight()
    {
        this.list.Clear();
        this.Search();
    }

    private void Search()
    {
        string strCheckFolderPath = AssetDatabase.GetAssetPath(OnCheckFolder);

        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { strCheckFolderPath });
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
        var lights = obj.GetComponentsInChildren<Light>(true);
        foreach (var light in lights)
        {
            list.Add(light.gameObject);
        }
    }

    private void DestroyUILight()
    {
        string strCheckFolderPath = AssetDatabase.GetAssetPath(OnCheckFolder);

        string[] guids = AssetDatabase.FindAssets("t:Prefab", new string[] { strCheckFolderPath });
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

            this.list.Clear();
            this.Check(obj);

            foreach (var light in list)
            {
                DestroyImmediate(light.gameObject, true);
            }

            if (list.Count > 0)
            {
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }

            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("delete", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }

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
				var lights = prefab.transform.GetComponentsInChildren<Light>(true);
				bool is_open = false;
				foreach (var light in lights)
				{
					var m_light = light.GetComponent<Light>();
					if (m_light)
					{
						is_open = true;
						m_light.shadows = LightShadows.None;
					}
				}
				//if (is_open)
				//{
				//	var go = GameObject.Instantiate(prefab);
				//	PrefabUtility.ReplacePrefab(go, prefab);
				//	DestroyImmediate(go);
				//}
			}
			else
			{
				Debug.LogError("未知错误，无法找到prefab");
			}
		}
	}
}
