using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

/// <summary>
/// 批量修改UI字体脚本，脚本位于Endit文件夹，欢迎各位大神随时对此功能优化
/// </summary>
public class EditorFont : EditorWindow
{
	//window菜单下
	[MenuItem("Nirvana/替换字体")]
	private static void ShowWindow()
	{
		// EditorFont cw = EditorWindow.GetWindow<EditorFont>(false, "替换字体--G16换皮用=，=");
		EditorWindow.GetWindow<EditorFont>(false, "替换字体---G16");
	}
		
	// 旧的字体
	static Font default_font = null;
	//切换到新的字体
	static Font to_change_font = null;

	/// <summary>
	/// ui绘制
	/// </summary>
	private void OnGUI()
	{
		GUILayout.Space(10);
		GUILayout.Label("要替换的字体（旧）:");
		default_font = (Font)EditorGUILayout.ObjectField(default_font, typeof(Font), true, GUILayout.MinWidth(100f));

		GUILayout.Space(10);
		GUILayout.Label("目标字体（新）:");
		to_change_font = (Font)EditorGUILayout.ObjectField(to_change_font, typeof(Font), true, GUILayout.MinWidth(100f));

		GUILayout.Space(20);
		if (GUILayout.Button("遍历修改所有的Text"))
		{
			CheckSceneSetting();
		}

		GUILayout.Space(30);
		if (GUILayout.Button("选中单个修改"))
		{
			Change();
		}
	}
	/// <summary>
	/// 选中处理
	/// </summary>
	public static void Change()
	{
		//获取所有UILabel组件
		if (Selection.objects == null || Selection.objects.Length == 0) return;
		Object[] labels = Selection.GetFiltered(typeof(Text), SelectionMode.Deep);
		foreach (Object item in labels)
		{
			ChangeFontHandler(item);
		}
	}

	/// <summary>
	/// 替换字体
	/// </summary>
	/// <param name="item"></param>
	public static void ChangeFontHandler(Object item, Object prefab = null) {
		if (default_font != null && to_change_font != null)
		{
			Text label = (Text)item;
			if (label.font != null && label.font.name != "" && label.font.name == default_font.name)
			{
				label.font = to_change_font;
				EditorUtility.SetDirty(item);
				if (prefab != null)
				{
					Debug.Log("Prefab：" + prefab.name +"----已替换的text的名字是：" + label.name);
				}
				else
				{
					Debug.Log("已替换的text的名字是" + label.name);
				}
			}
		}
		else
		{
			Debug.LogError("操作错误");
		}
	}

	/// <summary>
	/// 批量替换字体
	/// </summary>
	static void CheckSceneSetting()
	{
		var assets = AssetDatabase.FindAssets("t:prefab");
		foreach (var guid in assets)
		{
			var path = AssetDatabase.GUIDToAssetPath(guid);
			var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
			if (prefab != null)
			{
				var texts = prefab.transform.GetComponentsInChildren<Text>(true);
				foreach (var text in texts)
				{
					// if (default_font != null && text.font != null && text.font.name == default_font.name)
					// {
					// 	Debug.Log("Prefab：" + prefab.name +"----准备替换的Text的名字是：" + text.name);
					// }
					ChangeFontHandler(text, prefab);
				}
			}
			else
			{
				Debug.LogError("未知错误，无法找到prefab");
			}
		}
	}
}


