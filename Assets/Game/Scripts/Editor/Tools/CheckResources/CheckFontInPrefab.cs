using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public partial class CheckResources
{
    void FontWindow(int toolbarID)
    {
        EditorGUILayout.BeginHorizontal();
        {
            record_Dir_Path = EditorGUILayout.TextField("存储Font的目录:", record_Dir_Path);
            if (GUILayout.Button("...", GUILayout.Width(20)))
            {
                record_Dir_Path = EditorUtility.OpenFolderPanel("存储Font的目录", "存储Font的目录", "存储Font的目录");
            }
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        if (GUILayout.Button("开始查询"))
        {
            CheckFont();
        }
        EditorGUILayout.HelpBox("遍历Assets下所有预制体，查找引用过的Font文件，保存在存储目录中", MessageType.Info);
    }

    private void CheckFont()
    {
        var font_GamesDic = new Dictionary<Font, List<GameObject>>();

        var prefabIDs = AssetDatabase.FindAssets("t:prefab", new string[] { "Assets/Game/UIs/Views" });
        foreach (var id in prefabIDs)
        {
            var path = AssetDatabase.GUIDToAssetPath(id);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            var textComponents = prefab.GetComponentsInChildren<Text>(true);
            foreach (var textComponent in textComponents)
            {
                var font = textComponent.font;
                if (font == null)
                {
                    continue;
                }
                // 排除常用字体，不然引用太多了，生成txt太慢
                if (font.name == "HuaKangYuanTi")
                {
                    continue;
                }

                if (!font_GamesDic.ContainsKey(font))
                {
                    font_GamesDic[font] = new List<GameObject>();
                }

                font_GamesDic[font].Add(textComponent.gameObject);
            }
        }

        var sb = new StringBuilder();

        foreach (var pair in font_GamesDic)
        {
            string fontFilePath = record_Dir_Path + "/" + pair.Key.name + ".txt";

            if (!File.Exists(fontFilePath))
            {
                File.Create(fontFilePath).Dispose();
            }

            foreach (var gameObj in pair.Value)
            {
                sb.Length = 0;
                sb.Append("Path: ");
                sb.AppendLine(AssetDatabase.GetAssetPath(gameObj));
                sb.Append("Hierarchy: ");
                sb.AppendLine(GetNameByHierarchy(gameObj, "/"));

                string lastContent = File.ReadAllText(fontFilePath);
                if (!string.IsNullOrEmpty(lastContent))
                {
                    sb.Insert(0, lastContent + "\r\n");
                }
                File.WriteAllText(fontFilePath, sb.ToString());
            }
        }

        EditorUtility.DisplayDialog("Title", "Matching Font Over", "Ok");
    }
}
