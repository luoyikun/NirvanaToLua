using UnityEditor;
using UnityEngine;

public class EditorProgressBar : EditorWindow
{
    private static EditorWindow window;
    public static int Progress;
    public static int allFile;
    private int lastValue;
    private static double time;

    public static void ShowWindow(int num)
    {
        allFile = num;
        Progress = 0;
        time = EditorApplication.timeSinceStartup;
        if (window == null)
        {
            window = GetWindowWithRect<EditorProgressBar>(new Rect(Vector2.one * 500, Vector2.one));
        }
        window.Show();
    }

    void OnGUI()
    {
        EditorUtility.DisplayProgressBar("OneKeyEditorVariable", "当前进行到第" + Progress + "个文件", (float)Progress / allFile);

        if (Progress >= allFile ||
            lastValue == Progress && EditorApplication.timeSinceStartup - time >= 5)
        {
            window.Close();
        }

        if (lastValue != Progress)
        {
            time = EditorApplication.timeSinceStartup;
        }

        lastValue = Progress;


        //测试，当没有外部更改时用着模拟一秒的操作
        //if (lastValue == Progress && EditorApplication.timeSinceStartup - time >= 0.2f)
        //{
        //    Progress++;
        //}
    }

    void OnInspectorUpdate() //更新
    {
        Repaint();  //重新绘制
    }
}
