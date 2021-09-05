using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.SceneManagement;
using UnityEditor.SceneManagement;

public class SceneAttrModify : EditorWindow {

    [MenuItem("自定义工具/场景属性修改")]
    private static void DrawWidonw()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(SceneAttrModify), false, "场景属性修改");
    }


    private Object SceneField;
    private List<string> scenePaths = new List<string>();
    private void OnGUI()
    {
        SceneField = EditorGUILayout.ObjectField(SceneField, typeof(Object), false);

        GUILayout.Space(10);
        if(GUILayout.Button("Realtime Lighting"))
        {
            if (null == SceneField)
            {
                return;
            }

            string FeildPath = AssetDatabase.GetAssetPath(SceneField);
            string[] Guids = AssetDatabase.FindAssets("t:scene", new string[] { FeildPath });
            float nextTime = 0;
            float count = 1;
            foreach (string guid in Guids)
            {
                string scenePath = AssetDatabase.GUIDToAssetPath(guid);
                Scene scene = EditorSceneManager.OpenScene(scenePath);
                if (Lightmapping.realtimeGI)
                {
                    Lightmapping.realtimeGI = false;
                    EditorSceneManager.SaveScene(scene);
                }
                //if (nextTime <= Time.realtimeSinceStartup)
                //{
                //    bool cancel = EditorUtility.DisplayCancelableProgressBar("searching", scenePath, (float)count / Guids.Length);
                //    nextTime = Time.realtimeSinceStartup + 0.1f;
                //    if (cancel)
                //    {
                //        break;
                //    }
                //}
                //count = count + 1;
            }
        }
    }

}
