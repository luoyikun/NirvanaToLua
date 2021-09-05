using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

public class DynamicReferenceTexture : EditorWindow
{
    [MenuItem("自定义工具/导出动态引用UI资源")]
    static void Init()
    {
        DynamicReferenceTexture myWindow = (DynamicReferenceTexture)EditorWindow.GetWindow(typeof(DynamicReferenceTexture), false, "导出动态引用UI资源");//创建窗口
        myWindow.Show();//展示
    }

    private string OutPutDir;

    private string[] checkPrefabDirs = 
    {
        "Assets/Game",
    };

    private string[] checkDirs = 
    {
        "Assets/Game/UIs/Images3",
        "Assets/Game/UIs/Images4",
        "Assets/Game/UIs/Views",
    };

    private Dictionary<string, string> textureGuidDir = new Dictionary<string, string>();

    void OnGUI()
    {
        EditorGUILayout.Space();

        if (GUILayout.Button("导出"))
        {
            CheckAndOutPut();
        }

        EditorGUILayout.Space();

        EditorGUILayout.HelpBox("导出到AssetCheck/DynamicReferenceTexture.txt\n\n当前只检查Images2,Images3,Images4,Views目录", MessageType.Info, true);
    }

    void CheckAndOutPut()
    {
        OutPutDir = Path.Combine(Application.dataPath, "../AssetsCheck");

        bool cancel = false;

        string[] prefab_guids = AssetDatabase.FindAssets("t:prefab", checkPrefabDirs);
        string[] texture_guids = AssetDatabase.FindAssets("t:texture2d", checkDirs);
        foreach (var texture_guid in texture_guids)
        {
            textureGuidDir.Add(texture_guid, texture_guid);
        }

        #region !!!!!!!!!!
        int startIndex = 0;
        int max_length = prefab_guids.Length;

        for (int i = startIndex; i < max_length; i++)
        {
            string prefab_guid = prefab_guids[i];
            var prefab_path = AssetDatabase.GUIDToAssetPath(prefab_guid);
            var dependencies = AssetDatabase.GetDependencies(prefab_path);

            foreach (var dependencie in dependencies)
            {
                //MatchCollection mc = Regex.Matches(dependencie, @"");
                //foreach (var m in mc)
                //{
                //    Debug.LogError("!!!!!!!!!!!!!!");
                //    Debug.LogError(m.);
                //    Debug.LogError(dependencie);
                //}
                //return;

                var guid = AssetDatabase.AssetPathToGUID(dependencie);

                foreach (var textureGuids in textureGuidDir)
                {
                    if (textureGuids.Key == guid)
                    {
                        textureGuidDir.Remove(guid);
                        break;
                    }
                }
            }
            cancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", prefab_path, (float)i / (float)max_length);
            if (cancel)
            {
                break;
            }
        }
        EditorUtility.ClearProgressBar();
        if (!Directory.Exists(OutPutDir))
        {
            Directory.CreateDirectory(OutPutDir);
        }

        StringBuilder builder = new StringBuilder();

        int count = 0;
        int max_count = textureGuidDir.Count;
        foreach (var dir in textureGuidDir)
        {
            var path = AssetDatabase.GUIDToAssetPath(dir.Key);
            //var texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
            //AssetDatabase.SetLabels(texture, new string[] { "DynamicReference" });
            //AssetDatabase.ClearLabels(texture);
            //EditorUtility.SetDirty(texture);
            builder.Append(path);
            builder.Append("\n");
            cancel = EditorUtility.DisplayCancelableProgressBar("写入文件中", path, (float)count / (float)max_count);
            count = count + 1;
            if (cancel)
            {
                break;
            }
        }
        EditorUtility.ClearProgressBar();
        File.WriteAllText(Path.Combine(OutPutDir, "DynamicReferenceTexture.txt"), builder.ToString());
        #endregion
    }
}
