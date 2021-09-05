using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;
using Nirvana;

public class AssetIDReferenceFinder : EditorWindow
{
    HashSet<GameObject> GoList = new HashSet<GameObject>();
    string AssetName;

    [MenuItem("Tools/查找资源引用", false, 130)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(AssetIDReferenceFinder), false, "查找资源引用");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
    }

    private void OnGUI()
    {
        AssetName = EditorGUILayout.TextField("资源名称: ", AssetName);
        if (GUILayout.Button("查找"))
        {
            GoList.Clear();
            var allGo =  FindObjectsOfType<GameObject>();
            Debug.Log(AssetName + " " + allGo.Length);

            foreach (var go in allGo)
            {
                List<string> depPaths = (from dep in EditorUtility.CollectDependencies(new UnityEngine.Object[] { go })
                                         let path = AssetDatabase.GetAssetPath(dep)
                                         where !string.IsNullOrEmpty(path) && path.IndexOf("Assets/") == 0
                                         select path
                                 ).Distinct().ToList();

                foreach (var depPath in depPaths)
                {
                    if (Path.GetFileName(depPath).ToLower().Contains(AssetName.ToLower()))
                    {
                        GoList.Add(go);
                        break;
                    }
                }

                UIVariableTable []uiVariableTables = go.GetComponents<UIVariableTable>();
                foreach (var uiVariables in uiVariableTables)
                {
                    bool flag = false;
                    foreach (var uiVariable in uiVariables.Variables)
                    {
                        if (uiVariable.Type == UIVariableType.Asset)
                        {
                            AssetID assetID = uiVariable.GetAsset();
                            if (assetID.AssetName.ToLower().Contains(AssetName.ToLower()))
                            {
                                GoList.Add(go);
                                flag = true;
                                break;
                            }
                        }
                    }

                    if (flag)
                    {
                        break;
                    }
                }

                Game.GameObjectAttach[] goObjectAttach = go.GetComponents<Game.GameObjectAttach>();
                foreach (var com in goObjectAttach)
                {
                    if (com.AssetName.ToLower().Contains(AssetName.ToLower()))
                    {
                        GoList.Add(go);
                    }
                }
            }
        }

        GUILayout.Space(20);

        foreach (var go in GoList)
        {
            EditorGUILayout.ObjectField(go, typeof(GameObject), false);
        }
    }
}
