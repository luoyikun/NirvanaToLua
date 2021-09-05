using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;

using UnityObject = UnityEngine.Object;

public class FrameAnimCreator : EditorWindow
{
    private static string pathPrefix = "Assets/Game/UIs/";

    private UnityObject dirObj;
    private int frameRate = 30;
    private float frameInterval = 0.06f;

    [MenuItem("自定义工具/帧动画创建工具")]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(FrameAnimCreator), false, "帧动画创建工具");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
        window.minSize = new Vector2(200, 200);
    }

    private void OnGUI()
    {
        EditorGUI.BeginChangeCheck();

        dirObj = EditorGUILayout.ObjectField("UI目录", dirObj, typeof(UnityObject), false);

        if (EditorGUI.EndChangeCheck())
        {
            var path = AssetDatabase.GetAssetPath(dirObj);
            if (!Directory.Exists(path))
            {
                EditorUtility.DisplayDialog("错误", "只能对目录进行处理", "确定");
                dirObj = null;
                return;
            }

            if (!path.StartsWith(pathPrefix))
            {
                EditorUtility.DisplayDialog("错误", "只能对UI目录进行处理", "确定");
                dirObj = null;
                return;
            }
        }

        if (dirObj == null)
        {
            return;
        }

        GUILayout.Space(20);

        frameRate = EditorGUILayout.IntField("帧率: ", frameRate);
        frameInterval = EditorGUILayout.FloatField("每帧动画间隔: ", frameInterval);

        GUILayout.Space(20);
        if (GUILayout.Button("开始处理"))
        {
            var path = AssetDatabase.GetAssetPath(dirObj);

            var files = Directory.GetFiles(path, "*.*", SearchOption.TopDirectoryOnly);
            List<Sprite> sprites = new List<Sprite>();

            foreach (var file in files)
            {
                Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(file);
                if (sprite == null)
                {
                    Debug.Log(file);
                    continue;
                }

                sprites.Add(sprite);
            }

            if (sprites.Count <= 0)
            {
                EditorUtility.DisplayDialog("错误", "没有图片", "确定");
                return;
            }

            sprites.Sort((x, y) => string.CompareOrdinal(x.name, y.name));

            AnimationClip animationClip = new AnimationClip();
            animationClip.frameRate = frameRate;

            EditorCurveBinding curveBinding = new EditorCurveBinding();
            curveBinding.type = typeof(Image);
            curveBinding.propertyName = "m_Sprite";
            curveBinding.path = "";

            int interval = Mathf.CeilToInt(frameInterval * 100.0f * 100 / frameRate);

            ObjectReferenceKeyframe []objRefKeyframes = new ObjectReferenceKeyframe[sprites.Count];
            for (int i = 0; i < sprites.Count; ++i)
            {
                objRefKeyframes[i].time = interval * i / 100.0f;
                objRefKeyframes[i].value = sprites[i];
            }

            AnimationUtility.SetObjectReferenceCurve(animationClip, curveBinding, objRefKeyframes);

            var folderName = Path.GetFileNameWithoutExtension(path);

            AssetDatabase.CreateAsset(animationClip, Path.Combine(path, folderName + ".anim"));

            AssetDatabase.Refresh();
        }
    }
}
