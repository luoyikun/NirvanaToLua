
using UnityEngine;
using UnityEditor;
using UnityObject = UnityEngine.Object;
using System.IO;
using System.Collections.Generic;

public class AssetMarkerHelper : EditorWindow
{
    private UnityObject dirObject;

    [MenuItem("Tools/Bundle Marker", false, 110)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(AssetMarkerHelper), false, "Bundle Marker");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(300, 300);
    }

    private void OnGUI()
    {
        dirObject = EditorGUILayout.ObjectField("目录：", dirObject, typeof(UnityObject), false);

        GUILayout.Space(10);

        if (GUILayout.Button("mark"))
        {
            if (dirObject == null)
            {
                return;
            }

            var needMarkAssets = GetNeedMarkAssets();

            int count = 0;
            foreach (var needMarkAsset in needMarkAssets)
            {
                var progress = count / (float)needMarkAssets.Count;
                EditorUtility.DisplayProgressBar("标记bundle名字", string.Format("{0}/{1}", count, needMarkAssets.Count), progress);
                AssetBundleMarkRule.MarkAssetBundle(needMarkAsset);
                count++;
            }


            EditorUtility.ClearProgressBar();
        }

        GUILayout.Space(20);

        if (GUILayout.Button("unmark unused assets"))
        {
            if (dirObject == null)
            {
                return;
            }

            var needMarkAssets = GetNeedMarkAssets();
            AssetDatabase.RemoveUnusedAssetBundleNames();

            var dir = AssetDatabase.GetAssetPath(dirObject);

            List<string> needUnmarkAssets = new List<string>();

            var bundleNames = AssetDatabase.GetAllAssetBundleNames();
            foreach (var bundleName in bundleNames)
            {
                var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(bundleName);
                foreach (var assetPath in assetPaths)
                {
                    if (!needMarkAssets.Contains(assetPath) && assetPath.StartsWith(dir))
                    {
                        needUnmarkAssets.Add(assetPath);
                    }
                }
            }

            for (int i = 0; i < needUnmarkAssets.Count; ++i)
            {
                var needUnmarkAsset = needUnmarkAssets[i];
                AssetImporter importer = AssetImporter.GetAtPath(needUnmarkAsset);

                EditorUtility.DisplayProgressBar("Unmark AssetBundle name", string.Format("{0}/{1} {2}", i, needUnmarkAssets.Count, needUnmarkAsset), i / (float)needUnmarkAssets.Count);

                if (!string.Equals(importer.assetBundleName, string.Empty))
                {
                    importer.assetBundleName = string.Empty;
                    importer.SaveAndReimport();
                }
            }

            EditorUtility.ClearProgressBar();
        }

        GUILayout.Space(10);

        if (GUILayout.Button("Reimport Model"))
        {
            var guids = AssetDatabase.FindAssets("t:model", new string[] { AssetDatabase.GetAssetPath(dirObject) });

            HashSet<string> files = new HashSet<string>();

            foreach (var guid in guids)
            {
                files.Add(AssetDatabase.GUIDToAssetPath(guid));
            }

            int count = 0; 
            foreach (var file in files)
            {
                EditorUtility.DisplayProgressBar("Reimport Model", string.Format("{0}/{1} {2}", count, files.Count, file), count / (float)files.Count);

                ImporterUtils.ClearLabel(AssetDatabase.LoadMainAssetAtPath(file));
                ModelImporter importer = AssetImporter.GetAtPath(file) as ModelImporter;
                if (importer && !importer.isReadable)
                {
                    importer.SaveAndReimport();
                }

                count++;
            }

            EditorUtility.ClearProgressBar();
        }
    }

    private HashSet<string> GetNeedMarkAssets()
    {
        var path = AssetDatabase.GetAssetPath(dirObject);

        string[] assetPath = new string[]
        {
                path
        };

        HashSet<string> needMarkAssets = new HashSet<string>();

        var prefabs = AssetDatabase.FindAssets("t:prefab", assetPath);
        foreach (var prefab in prefabs)
        {
            needMarkAssets.Add(AssetDatabase.GUIDToAssetPath(prefab));
        }

        var scenes = AssetDatabase.FindAssets("t:scene", assetPath);
        foreach (var scene in scenes)
        {
            needMarkAssets.Add(AssetDatabase.GUIDToAssetPath(scene));
        }

        var textures = AssetDatabase.FindAssets("t:Texture", new string[] { "Assets/Game/UIs" });
        foreach (var texture in textures)
        {
            needMarkAssets.Add(AssetDatabase.GUIDToAssetPath(texture));
        }

        var files = Directory.GetFiles("Assets/Game/UIs/RawImages", "*.*", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            if (file.EndsWith(".meta"))
            {
                continue;
            }

            needMarkAssets.Add(file);
        }

        files = Directory.GetFiles("Assets/Game/Shaders", "*.*", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            if (file.EndsWith(".meta") || file.EndsWith(".cs") || file.EndsWith(".asset"))
            {
                continue;
            }

            needMarkAssets.Add(file);
        }

        files = Directory.GetFiles("Assets/Game/Audios", "*.*", SearchOption.AllDirectories);
        foreach (var file in files)
        {
            if (file.EndsWith(".meta"))
            {
                continue;
            }
            needMarkAssets.Add(file);
        }

        return needMarkAssets;
    }
}
