using UnityEngine;
using UnityEditor;
using Nirvana;

public class LogConsole : EditorWindow
{
    private LogFile logFile = null;
    private bool isLoging = false;

    [MenuItem("自定义工具/日志控制台", false, 110)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(LogConsole));
        window.titleContent = new GUIContent("LogConsole");
    }

    private void OnGUI()
    {
        if (!Application.isPlaying)
        {
            EditorGUILayout.HelpBox(
             "在游戏启动后才能使用",
             MessageType.Info);

            return;
        }

        if (!this.isLoging)
        {
            if (GUILayout.Button("开始输出"))
            {
                this.StartLog();
            }
        }
        else
        {
            if (GUILayout.Button("停止输出"))
            {
                this.StopLog();
            }
        }

        if (GUILayout.Button("清除"))
        {
            this.ClearLog();
        }

        if (GUILayout.Button("关闭所有"))
        {
            LogSystem.UnActAllLog();
        }

        this.DrawLogActToggle(LogActType.PrefabReferenceCount, "Prefab引用计数");
        this.DrawLogActToggle(LogActType.AssetBundleReferenceCount, "AssetBundle引用计数");
        this.DrawLogActToggle(LogActType.UnloadAssetBundle, "卸载AssetBundle");
        this.DrawLogActToggle(LogActType.LoadIndependAssetBundle, "加载独立AssetBundle");
        this.DrawLogActToggle(LogActType.LoadIndependAssetBundle, "加载依赖AssetBundle");
    }

    private void DrawLogActToggle(LogActType logActType, string showName)
    {
        bool is_act = EditorGUILayout.Toggle("Show Button", LogSystem.IsLogAct(logActType));
        LogSystem.SetLogAct(logActType, is_act);
    }

    private void StartLog()
    {
        if (this.isLoging)
        {
            return;
        }

        this.isLoging = true;
        if (null == this.logFile)
        {
            Debug.Log("Start Log");
            this.logFile = new LogFile(false);
            LogSystem.AddAppender(this.logFile);
        }

        EditorApplication.playmodeStateChanged = () =>
        {
            if (EditorApplication.isPaused)
            {
                return;
            }

            if (EditorApplication.isPlaying)   // 当停止时，状态是播放运行中则停止输出日志
            {
                this.StopLog();
            }
        };
    }

    private void StopLog()
    {
        if (!this.isLoging)
        {
            return;
        }

        this.isLoging = false;
        if (null != this.logFile)
        {
            Debug.Log("Stop Log");
            LogSystem.RemoveAppender(this.logFile);
            this.logFile = null;
        }
    }

    private void ClearLog()
    {
        if (null == this.logFile)
        {
            this.logFile = new LogFile(false);
        }

        Debug.Log("Clear Log");
        this.logFile.ClearLog();
    }
}