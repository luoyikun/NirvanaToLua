using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using Nirvana;

using UnityObject = UnityEngine.Object;

public class ActorComponentFinder : EditorWindow
{
    private UnityObject dirObject;
    private List<AnimatorTimelineBehaviour> results = new List<AnimatorTimelineBehaviour>();
    private Vector2 mousePos = Vector2.zero;

    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(ActorComponentFinder), false, "ActorComponentFinder");
        window.position = new Rect(Screen.width / 2, 400, 400, 600);
        window.minSize = new Vector2(500, 600);
    }

    private void OnGUI()
    {
        dirObject = EditorGUILayout.ObjectField("目录: ", dirObject, typeof(UnityObject), false);

        GUILayout.Space(10);

        if (GUILayout.Button("查找"))
        {
            if (dirObject == null)
            {
                return;
            }

            results.Clear();

            var path = AssetDatabase.GetAssetPath(dirObject);
            var prefabGuids = AssetDatabase.FindAssets("t:prefab", new string[] { path });

            int count = 0;
            foreach (var guid in prefabGuids)
            {
                var progress = count / (float)prefabGuids.Length;

                EditorUtility.DisplayProgressBar("查找中", string.Format("{0}/{1}", count, prefabGuids.Length), progress);
                var prefabPath = AssetDatabase.GUIDToAssetPath(guid);
                var obj = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);

                /*var components = obj.GetComponentsInChildren<AnimatorTimelineBehaviour>();
                foreach (var component in components)
                {
                    results.Add(component);
                }*/
            }

            EditorUtility.ClearProgressBar();
        }

        GUILayout.Space(10);

        if (results.Count <= 0)
        {
            return;
        }

        mousePos = EditorGUILayout.BeginScrollView(mousePos, GUILayout.MaxHeight(300));

        foreach (var obj in results)
        {
            // EditorGUILayout.ObjectField(obj, typeof(AnimatorTimelineBehaviour))
        }

        EditorGUILayout.EndScrollView();
    }
}
