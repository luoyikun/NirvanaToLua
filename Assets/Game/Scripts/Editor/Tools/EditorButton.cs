using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using Nirvana;

public class EditorButton : EditorWindow
{
    [MenuItem("自定义工具/替换按钮点击效果")]
    private static void ShowWindow()
    {
        EditorWindow.GetWindow<EditorButton>(false, "替换按钮点击效果");
    }

    RuntimeAnimatorController controller = null;
    Vector2 scrollPos = new Vector2(0, 0);
    List<GameObject> gos = new List<GameObject>();

    private bool isChangeButton;
    private Object folder;

    private void OnGUI()
    {
        isChangeButton = EditorGUILayout.Toggle("是否修改Button", isChangeButton);
        if (isChangeButton)
        {
            GUILayout.Space(10);
            GUILayout.Label("AnimatorController:");
            controller = (RuntimeAnimatorController)EditorGUILayout.ObjectField(controller, typeof(RuntimeAnimatorController), true, GUILayout.MinWidth(100f));

            GUILayout.Space(20);
            if (GUILayout.Button("修改Button"))
            {
                ChangeButton();
                Repaint();
            }

            if (GUILayout.Button("修改Toggle"))
            {
                ChangeToggle();
                Repaint();
            }

            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
            foreach (var go in gos)
            {
                EditorGUILayout.ObjectField(go, typeof(GameObject), true);
            }
            EditorGUILayout.EndScrollView();
        }
        
        EditorGUILayout.LabelField("删除动画控件");
        EditorGUILayout.HelpBox("遍历目标文件夹及子文件夹下的Button控件，" +
                                "删除Animator组件，设置Button的Transition为None，"+
                                "添加ButtonClickScale脚本", MessageType.Info);

        EditorGUILayout.BeginHorizontal();
        {
            folder = EditorGUILayout.ObjectField("目标文件夹:", folder, typeof(Object), false, GUILayout.Width(250));
            var folderPath = AssetDatabase.GetAssetPath(folder);
            if (folderPath.Contains("."))
            {
                EditorGUILayout.HelpBox("选中的可能不是一个文件夹，请确认", MessageType.Error);
            }

            if (GUILayout.Button("开始操作", GUILayout.Width(150)))
            {
                var dir = new DirectoryInfo(folderPath);
                DoSingleDirectory(dir);
                AssetDatabase.SaveAssets();
                EditorUtility.DisplayDialog("", "全部替换完成", "确定");
            }
        }
        EditorGUILayout.EndHorizontal();
    }

    #region 修改Button
    private void ChangeButton()
    {
        if (null == controller)
        {
            Debug.LogError("No AnimatorController!!");
            return;
        }
        
        GameObject[] gameObjects = Selection.gameObjects;
        if (gameObjects == null || gameObjects.Length == 0)
        {
            Debug.LogWarning("No Select!!");
            return;
        }

        //清除修改列表
        gos.Clear();

        foreach(var go in gameObjects)
        {
            var buttons = go.GetComponentsInChildren<Button>(true);
            foreach(var button in buttons)
            {
                ChangeButtonHandler(button.gameObject);
            }
        }
    }

    private void ChangeButtonHandler(GameObject go)
    {
        var button = go.GetComponent<Button>();
        button.transition = Selectable.Transition.Animation;
        button.animationTriggers.disabledTrigger = "Disabled";
        button.animationTriggers.highlightedTrigger = "Highlighted";
        button.animationTriggers.normalTrigger = "Normal";
        button.animationTriggers.pressedTrigger = "Pressed";
        //var preserve = go.GetComponent<Nirvana.PreserveAnimatorOnDisable>();
        //if (null == preserve)
        //{
        //    preserve = go.AddComponent<Nirvana.PreserveAnimatorOnDisable>();
        //}
        var animator = go.GetComponent<Animator>();
        if (null == animator)
        {
            animator = go.AddComponent<Animator>();
        }
        animator.runtimeAnimatorController = controller;

        var recttrans = go.GetComponent<RectTransform>();
        if (null != recttrans)
        {
            recttrans.pivot = new Vector2(0.5f, 0.5f);
        }

        EditorUtility.SetDirty(go);

        gos.Add(go);
        //Debug.Log("修改成功！按钮名字为：" + go.name);
    }
    #endregion

    #region 修改Toggle
    private void ChangeToggle()
    {
        if (null == controller)
        {
            Debug.LogError("No AnimatorController!!");
            return;
        }

        GameObject[] gameObjects = Selection.gameObjects;
        if (gameObjects == null || gameObjects.Length == 0)
        {
            Debug.LogWarning("No Select!!");
            return;
        }

        //清除修改列表
        gos.Clear();

        foreach (var go in gameObjects)
        {
            var toggles = go.GetComponentsInChildren<Toggle>(true);
            foreach (var toggle in toggles)
            {
                ChangeToggleHandler(toggle.gameObject);
            }
        }
    }

    private void ChangeToggleHandler(GameObject go)
    {
        var toggle = go.GetComponent<Toggle>();
        toggle.transition = Selectable.Transition.Animation;
        toggle.animationTriggers.disabledTrigger = "Disabled";
        toggle.animationTriggers.highlightedTrigger = "Highlighted";
        toggle.animationTriggers.normalTrigger = "Normal";
        toggle.animationTriggers.pressedTrigger = "Pressed";

        var animator = go.GetComponent<Animator>();
        if (null == animator)
        {
            animator = go.AddComponent<Animator>();
        }
        animator.runtimeAnimatorController = controller;

        var recttrans = go.GetComponent<RectTransform>();
        if (null != recttrans)
        {
            recttrans.pivot = new Vector2(0.5f, 0.5f);
        }

        EditorUtility.SetDirty(go);

        gos.Add(go);
    }
    #endregion

    private void DoSingleDirectory(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.prefab", SearchOption.AllDirectories);
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                var safePath = file.FullName.Replace("\\", "/");
                int index = safePath.IndexOf("Assets/");
                var  loadPath = safePath.Substring(index);
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(loadPath);

                var buttons = prefab.GetComponentsInChildren<Button>(true);
                foreach (var button in buttons)
                {
                    var gameObj = button.gameObject;
                    var buttonClickScale = gameObj.GetComponent<ButtonClickScale>();
                    
                    if (button.transition == Selectable.Transition.Animation ||
                        buttonClickScale != null)
                    {
                        button.transition = Selectable.Transition.None;
                        var animator = gameObj.GetComponent<Animator>();
                        if (animator != null)
                        {
                            DestroyImmediate(animator, true);
                        }
                        gameObj.GetOrAddComponent<ButtonClickScale>();
                    }
                    
                }
            }
        }
    }
}
