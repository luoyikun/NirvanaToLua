using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class DeveloperWindow : EditorWindow
{
    private int oldKeyboardControl = 0;
    private int screenShotSize = 1;
    private string path = "";

    [MenuItem("Window/Yifan/Developer")]
    private static void ShowQuickLoginView()
    {
        EditorWindow.GetWindow<DeveloperWindow>(false, "Developer");
    }

    private void OnGUI()
    {
        // quicklogin
        {
            DeveloperQuickLogin.UserName = EditorGUILayout.TextField("UserName", DeveloperQuickLogin.UserName);
            DeveloperQuickLogin.ServerId = EditorGUILayout.TextField("ServerId", DeveloperQuickLogin.ServerId);

            EditorGUILayout.BeginHorizontal();
            if (!EditorApplication.isPlaying && GUILayout.Button("QuickLogin"))
            {
                UnityEngine.PlayerPrefs.SetString("is_quick_login", "1");
                EditorApplication.ExecuteMenuItem("Edit/Play");
                this.Repaint();
            }

            if (EditorApplication.isPlaying && GUILayout.Button("QuickRestart"))
            {
                DeveloperQuickRestart.Restart();
            }

            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        // gm
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("GM：", GUILayout.Width(25));
            GUI.SetNextControlName("GM");
            
            if (string.IsNullOrEmpty(DeveloperGm.GmContent))
            {
                DeveloperGm.GmContent = DeveloperGm.GetLastGm();
            }
            DeveloperGm.GmContent = EditorGUILayout.TextField("", DeveloperGm.GmContent, GUILayout.MinWidth(1), GUILayout.Height(20));
            if (GUILayout.Button("发送命令", GUILayout.Width(100)))
            {
                DeveloperGm.ExecuteGm();
            }
            this.CheckGmKeyBoard();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.PrefixLabel("Gm命令输出:");

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Gmlist"))
            {
                DeveloperGm.GmContent = "/cmd gmlist 4";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("GmAdditem"))
            {
                DeveloperGm.GmContent = "/gm additem:101 1 0";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("GmActiveNextState"))
            {
                DeveloperGm.GmContent = "/gm activitynextstate:6";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }


            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("添加怪物"))
            {
                DeveloperGm.GmContent = "/gm addmonster:2 1";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("修改等级"))
            {
                DeveloperGm.GmContent = "/gm setrolelevel:998";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("修改名字"))
            {
                DeveloperGm.GmContent = "/gm rename:测试";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("修改在线时长"))
            {
                DeveloperGm.GmContent = "/gm addonlinetime:1440";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("跳任务"))
            {
                DeveloperGm.GmContent = "/gm jumptotrunk:50";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            EditorGUILayout.EndHorizontal();


            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("修改血量"))
            {
                DeveloperGm.GmContent = "/gm changemaxhp:99999999";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("修改攻击"))
            {
                DeveloperGm.GmContent = "/gm changegongji:99999999";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            if (GUILayout.Button("修改移速"))
            {
                DeveloperGm.GmContent = "/gm changespeed:4000";
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;
                this.Repaint();
            }
            EditorGUILayout.EndHorizontal();


            EditorGUILayout.Space();
            EditorGUILayout.PrefixLabel("Gm命令直接执行:");

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("干掉怪物"))
            {
                if (Application.isPlaying)
                {
                    GameRoot.Instance.ExecuteGm("/gm delallmonster:");
                }
            }
            if (GUILayout.Button("跳天数"))
            {
                if (Application.isPlaying)
                {
                    GameRoot.Instance.ExecuteGm("/gm addday:1");
                }
            }
            if (GUILayout.Button("清空背包"))
            {
                if (Application.isPlaying)
                {
                    GameRoot.Instance.ExecuteGm("/gm clearbag:");
                }
            }
            if (GUILayout.Button("恢复血量"))
            {
                if (Application.isPlaying)
                {
                    GameRoot.Instance.ExecuteGm("/gm recover:");
                }
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();
            EditorGUILayout.PrefixLabel("特殊功能:");
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("检查内存泄漏"))
            {
                GameRoot.Instance.LuaCheckMemoryLeak();
            }
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.Space();

        if (EditorApplication.isPlaying)
        {
            DeveloperQuickLogin.Path = EditorGUILayout.TextField("Path: ", DeveloperQuickLogin.Path);
            if (DeveloperQuickLogin.Path == "")
                DeveloperQuickLogin.Path = UnityEngine.Application.persistentDataPath;
            EditorGUILayout.BeginHorizontal();
            this.screenShotSize = EditorGUILayout.IntSlider("Size: ", this.screenShotSize, 1, 4);
            if (GUILayout.Button("ScreenShot"))
            {
                var newPath = DeveloperQuickLogin.Path + "/" + System.DateTime.UtcNow.ToFileTime().ToString() + ".jpg";
                this.ScreenShot(newPath, this.screenShotSize);
            }
            EditorGUILayout.EndHorizontal();
        }
    }

    private void CheckGmKeyBoard()
    {
        if (this.oldKeyboardControl > 0)
        {
            GUIUtility.keyboardControl = this.oldKeyboardControl;
            this.oldKeyboardControl = 0;
        }

        if (GUI.GetNameOfFocusedControl() == "GM" && Event.current.type == EventType.KeyUp)
        {
            if (DeveloperGm.OnKeyUp())
            {
                this.oldKeyboardControl = GUIUtility.keyboardControl;
                GUIUtility.keyboardControl = 0;

                this.Repaint();
            }
        }
    }

    private static void ExecuteTestLua()
    {
        if (Application.isPlaying)
        {
            return;
        }

        LuaState luaState = new LuaState();
        luaState.Start();
        luaState.OpenLibs(LuaDLL.luaopen_struct);
        LuaLog.OpenLibs(luaState);

        luaState.LuaSetTop(0);
        LuaBinder.Bind(luaState);
        DelegateFactory.Init();

        try
        {
            // 执行启动文件.
            luaState.DoFile("editor/testlua.lua");
        }
        catch (LuaException exp)
        {
            Debug.LogError(exp.Message);
        }
    }

    private void ScreenShot(string path, int size = 1)
    {
        UtilU3d.Screenshot(path, null, size);
    }
}