using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ChangeTexture : EditorWindow {
    private int anisoLevel;
    [MenuItem("自定义工具/ChangeTexture")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<ChangeTexture>(false, "ChangeTexture");
    }

    private void OnGUI()
    {
        this.anisoLevel = EditorGUILayout.IntSlider("Aniso Level: ", this.anisoLevel, 0, 16);
        if (GUILayout.Button("Change"))
        {
            this.Change();
        }
    }

    private void Change()
    {
        var selectAssets = Selection.GetFiltered(typeof(DefaultAsset), SelectionMode.Assets);
        if (selectAssets.Length <= 0)
        {
            this.ShowNotification(new GUIContent("没有选中"));
            return;
        }
        string[] filters = new string[selectAssets.Length];
        for (int i = 0; i < selectAssets.Length; ++i)
        {
            DefaultAsset asset = selectAssets[i] as DefaultAsset;
            var assetPath = AssetDatabase.GetAssetPath(asset);
            filters[i] = assetPath;
        }
        string[] guids = AssetDatabase.FindAssets("t:Texture", filters);
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
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(path);
            ti.anisoLevel = this.anisoLevel;
            AssetDatabase.ImportAsset(path);
            if (nextTime <= Time.realtimeSinceStartup)
            {
                bool cancel = EditorUtility.DisplayCancelableProgressBar("替换中", path, (float)i / endIndex);
                nextTime = Time.realtimeSinceStartup + 0.1f;
                if (cancel)
                {
                    break;
                }
            }
        }
        EditorUtility.ClearProgressBar();
    }
}
