using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class RemoveMatKeyword : EditorWindow
{
    private string needRemoveKeywordStr = string.Empty;
    private HashSet<string> needRemoveKeywords = new HashSet<string>();

    [MenuItem("自定义工具/资源/移除材质球keyword")]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(RemoveMatKeyword), false, "移除材质球keyword");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(150, 200);
    }

    private void OnGUI()
    {
        needRemoveKeywordStr = EditorGUILayout.TextField("需要移除的keyword", needRemoveKeywordStr);
        GUILayout.Space(10);

        if (GUILayout.Button("移除"))
        {
            needRemoveKeywords.Clear();
            var keywords = needRemoveKeywordStr.Split(' ');
            foreach (var keyword in keywords)
            {
                needRemoveKeywords.Add(keyword);
            }

            if (needRemoveKeywords.Count <= 0)
            {
                return;
            }

            var matGuids = AssetDatabase.FindAssets("t:material");
            var count = 0;
            foreach (var matGuid in matGuids)
            {
                var matPath = AssetDatabase.GUIDToAssetPath(matGuid);

                doRemove(matPath);

                EditorUtility.DisplayProgressBar("移除keyword", string.Format("{0}/{1} {2}", count, matGuids.Length, matPath), count / (float)matGuids.Length);

                count++;
            }

            EditorUtility.ClearProgressBar();
        }
    }

    private void doRemove(string matPath)
    {

        var mat = AssetDatabase.LoadAssetAtPath<Material>(matPath);
        var keywords = mat.shaderKeywords;
        var newKeywords = new List<string>();

        var flag = false;

        foreach (var keyword in keywords)
        {
            if (needRemoveKeywords.Contains(keyword))
            {
                flag = true;
            }
            else
            {
                newKeywords.Add(keyword);
            }
        }

        if (flag)
        {
            var newMat = new Material(mat);
            newMat.shaderKeywords = newKeywords.ToArray();

            EditorUtility.CopySerialized(newMat, mat);
            AssetDatabase.SaveAssets();
        }
    }
}
