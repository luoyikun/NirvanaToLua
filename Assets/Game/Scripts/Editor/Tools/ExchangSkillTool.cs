using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

using UnityObject = UnityEngine.Object;

public class ExchangSkillTool : EditorWindow
{

    [MenuItem("自定义工具/资源导入工具/增加缺失控件")]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(ExchangSkillTool), false, "增加缺失控件");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(150, 200);
    }

    private GameObject baseModelObject;
    private UnityObject objectFile;
    private string baseModelPath;



    private void OnGUI()
    {
        baseModelObject = EditorGUILayout.ObjectField("原模型:", baseModelObject, typeof(GameObject), false) as GameObject;
        objectFile = EditorGUILayout.ObjectField("替换目录:", objectFile, typeof(UnityObject), false);

        if(GUILayout.Button("替换"))
        {
            if(objectFile == null)
            {
                ShowError("没有文件");
            }


            ClickButton(objectFile);
        }
    }

    private void ClickButton(UnityEngine.Object source)
    {
        if (!source)
        {
            Debug.Log("It's not source");
            return;
        }

        string strCheckFolderPath = AssetDatabase.GetAssetPath(source);
        string[] modelFiles = _GetFiles(strCheckFolderPath, ".prefab");
        string[] baseModelFiles = _GetFiles(strCheckFolderPath, ".prefab", "base.prefab");

        foreach (var path in modelFiles)
        {
            if(path.Contains("Shared"))
            {
                return;
            }
            var new_prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (new_prefab != null)
            {
                var dir = Directory.GetParent(Directory.GetParent(path).ToString()).ToString();
                //获取基础模型
                #region
                if (baseModelPath == "" || baseModelPath != dir)
                {
                    foreach (var basePath in baseModelFiles)
                    {
                        if(dir == Directory.GetParent(Directory.GetParent(basePath).ToString()).ToString())
                        {
                            baseModelObject = AssetDatabase.LoadAssetAtPath<GameObject>(basePath);
                        }
                    }
                }
                #endregion

                if (new_prefab.name != Path.GetFileName(Directory.GetParent(path).ToString())) continue;
                var old_obj = PrefabUtility.InstantiatePrefab(baseModelObject) as GameObject;
                var new_obj = PrefabUtility.InstantiatePrefab(new_prefab) as GameObject;

                if(new_prefab.GetComponent<ActorTriggers>() != null)
                {
                    var baseCom = baseModelObject.GetComponent<ActorTriggers>();
                    var newCom = new_prefab.GetComponent<ActorTriggers>();
                    UnityEditorInternal.ComponentUtility.CopyComponent(baseCom);
                    UnityEditorInternal.ComponentUtility.PasteComponentValues(newCom);

                    var baseCom2 = baseModelObject.GetComponent<ActorController>();
                    var newCom2 = new_prefab.GetComponent<ActorController>();
                    UnityEditorInternal.ComponentUtility.CopyComponent(baseCom2);
                    UnityEditorInternal.ComponentUtility.PasteComponentValues(newCom2);

                    DestroyImmediate(old_obj);
                    DestroyImmediate(new_obj);
                }
            }
        }

    }

    private string[] _GetFiles(string path, string extensionNam, string fileName = "", bool recursive = true)
    {
        List<string> withExtensions = new List<string>() { extensionNam };

        var resultList = new List<string>();
        string[] files = Directory.GetFiles(path, "*.*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);

        foreach (var strPath in files)
        {
            if (withExtensions.Contains(Path.GetExtension(strPath)))
            {
                if (strPath.Contains(fileName))
                {
                    resultList.Add(strPath.Replace('\\', '/'));
                }
            }
        }
        return resultList.ToArray();
    }


    private void ShowError(string message)
    {
        EditorUtility.DisplayDialog("错误", message, "确定");
    }
}
