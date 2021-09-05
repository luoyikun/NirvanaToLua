using UnityEngine;
using UnityEditorInternal;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

using UnityObject = UnityEngine.Object;

public class UITextureResolutionChecker : EditorWindow
{
    private UnityObject dirObj;

    public List<string> PathList = new List<string>
    {
        "Assets/Game/UIs",
    };

    private SerializedObject pathSerializedObject;
    private SerializedProperty pathListProperty;
    private ReorderableList pathReorderableList;

    private int xResolution = 300;
    private int yResolution = 300;
    private int maxResolution = 600;

    private List<Texture> errorTextures = new List<Texture>();

    private Vector2 scrollPosition = Vector2.zero;
    private int scrollSelection = 0;

    [MenuItem("自定义工具/资源检查/UI图片大小检查", false, 105)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(UITextureResolutionChecker), false, "UI图片大小检查工具");
        window.position = new Rect(Screen.width / 2, 600, 400, 500);
        window.minSize = new Vector2(200, 200);
    }

    private void OnEnable()
    {
        ScriptableObject target = this;
        pathSerializedObject = new SerializedObject(target);
        pathListProperty = pathSerializedObject.FindProperty("PathList");
        pathReorderableList = new ReorderableList(pathSerializedObject, pathListProperty);

        pathReorderableList.drawHeaderCallback =
            rect => GUI.Label(rect, "路径列表:");
        pathReorderableList.elementHeight = EditorGUIUtility.singleLineHeight;
        pathReorderableList.drawElementCallback =
            (rect, index, selected, focused) =>
            {
                var element = this.pathListProperty.GetArrayElementAtIndex(index);
                EditorGUI.PropertyField(rect, element);
            };
    }

    private void OnGUI()
    {
        pathReorderableList.DoLayoutList();

        GUILayout.Space(10);


        // EditorGUILayout.BeginHorizontal();

        xResolution = EditorGUILayout.IntField("宽度", xResolution);
        yResolution = EditorGUILayout.IntField("高度", yResolution);
        maxResolution = EditorGUILayout.IntField("最大分辨率", maxResolution);

        // EditorGUILayout.EndHorizontal();

        GUILayout.Space(10);

        if (GUILayout.Button("查找"))
        {
            errorTextures.Clear();
            scrollSelection = 0;

            string[] guids = AssetDatabase.FindAssets("t:texture", PathList.ToArray());
            foreach (var guid in guids)
            {
                var assetPath = AssetDatabase.GUIDToAssetPath(guid);
                var texture = AssetDatabase.LoadAssetAtPath<Texture>(assetPath);

                if (texture == null)
                {
                    continue;
                }

                if ((texture.width >= xResolution && texture.height >= yResolution )
                    || texture.width > maxResolution || texture.height > maxResolution)
                {
                    errorTextures.Add(texture);
                }
            }
        }

        GUILayout.Space(10);

        if (errorTextures.Count > 0)
        {
            EditorGUILayout.LabelField("有问题的图片: ");

            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.MaxWidth(400));

            foreach (var texture in errorTextures)
            {
                var message = string.Format("{0}x{1}: ", texture.width, texture.height);
                EditorGUILayout.ObjectField(message, texture, typeof(Texture), false);
            }

            EditorGUILayout.EndScrollView();
        }

        pathSerializedObject.ApplyModifiedProperties();
    }
}