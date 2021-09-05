using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

public partial class CheckResources : EditorWindow
{
    [MenuItem("自定义工具/资源检查/关键字检查")]
    static void ShowWindos()
    {
        GetWindow<CheckResources>();
    }

    private string[] toolbars = new string[] {"字体", "图片", "Lua文件"};
    private int toolbarID = 0;
    private Rect toolbarWindowRect = new Rect(5, 25, 600, 250);

    private static string search_Dir_Path;
    private static string record_Dir_Path = @"E:";

    private Vector2 scroll;         //滑动条
    private static List<string> sign = new List<string>();     //保存关键词的数组
    
    void OnGUI()
    {
        EditorGUI.BeginChangeCheck();
        {
            toolbarID = GUILayout.Toolbar(toolbarID, toolbars);
        }
        if (EditorGUI.EndChangeCheck())
        {
            Init();
        }

        BeginWindows();
        {
            switch (toolbarID)
            {
                case 0:
                    GUILayout.Window(0, toolbarWindowRect, FontWindow, "字体");
                    break;
                case 1:
                    GUILayout.Window(1, toolbarWindowRect, TextureWindow, "图片");
                    break;
                case 2:
                    GUILayout.Window(2, toolbarWindowRect, LuaWindow, "Lua文件");
                    break;
            }
        }
        EndWindows();
    }

    void OnInspectorUpdate()
    {
        this.Repaint();
    }

    void Init()
    {
        scroll = Vector2.zero;
        sign.Clear();
        switch (toolbarID)
        {
            case 0:
                search_Dir_Path = Application.dataPath;
                break;
            case 1:
                search_Dir_Path = Application.dataPath + "/Game/UIs/Views";
                break;
            case 2:
                search_Dir_Path = Application.dataPath + "/Game/Lua/game";
                break;

        }
    }

    #region 关键词索引的通用函数
    void KeyWorldModuleWindow(Action<DirectoryInfo> executeFunc)
    {
        EditorGUILayout.BeginHorizontal();
        {
            search_Dir_Path = EditorGUILayout.TextField("要查询的目录:", search_Dir_Path);
            if (GUILayout.Button("...", GUILayout.Width(20)))
            {
                search_Dir_Path = EditorUtility.OpenFolderPanel("查询目标文件夹", "查询目标文件夹", "查询目标文件夹");
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        {
            record_Dir_Path = EditorGUILayout.TextField("存储结果的目录:", record_Dir_Path);
            if (GUILayout.Button("...", GUILayout.Width(20)))
            {
                record_Dir_Path = EditorUtility.OpenFolderPanel("存储结果的目录", "存储结果的目录", "存储结果的目录");
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        scroll = EditorGUILayout.BeginScrollView(scroll);
        {
            {
                for (int i = 0; i < sign.Count; i++)
                {
                    sign[i] = EditorGUILayout.TextField((i + 1).ToString() + ".搜索关键词:", sign[i]);
                }
            }
        }
        EditorGUILayout.EndScrollView();

        EditorGUILayout.BeginHorizontal();
        {
            if (GUILayout.Button("添加关键词", GUILayout.Width(100)))
            {
                string keyword = string.Empty;
                sign.Add(keyword);
            }
            if (GUILayout.Button("移除关键词", GUILayout.Width(100)))
            {
                sign.RemoveAt(sign.Count - 1);
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        {

            if (GUILayout.Button("开始检测", GUILayout.Width(100)))
            {
                if (sign.Count < 1)
                {
                    EditorGUILayout.HelpBox("关键词不能为空", MessageType.Error, true);
                    return;
                }

                foreach (var keyword in sign)
                {
                    if (string.IsNullOrEmpty(keyword))
                    {
                        EditorGUILayout.HelpBox("关键词不能为空", MessageType.Error, true);
                        return;
                    }
                }
                DirectoryInfo dir = new DirectoryInfo(search_Dir_Path);
                executeFunc(dir);

                EditorUtility.DisplayDialog("Title", "Check Over!!!", "Ok");
            }
        }
        EditorGUILayout.EndHorizontal();
    }

    private string GetNameByHierarchy(GameObject gameObj, string separator)
    {
        var sb = new StringBuilder();
        sb.Insert(0, gameObj.name);
        var node = gameObj.transform.parent;

        while (node != null)
        {
            sb.Insert(0, node.name + separator);
            node = node.parent;
        }

        return sb.ToString();
    } 
    #endregion
}
