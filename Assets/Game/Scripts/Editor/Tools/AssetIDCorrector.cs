using UnityEngine;
using UnityEditor;
using Nirvana;

public class AssetIDCorrector : EditorWindow
{
    private GameObject gameObject;
    private string originBundleName;
    private string originAssetName;

    private string newBundleName;
    private string newAssetName;

    [MenuItem("Tools/AssetID修正器", false, 160)]
    public static void ShowWindow()
    {
        EditorWindow window = EditorWindow.GetWindow(typeof(AssetIDCorrector), false, "AssetID修正器");
        window.position = new Rect(Screen.width / 2, 400, 400, 300);
    }

    private void OnGUI()
    {
        gameObject = EditorGUILayout.ObjectField("GameObject: ", gameObject, typeof(GameObject), false) as GameObject;

        originBundleName = EditorGUILayout.TextField("原始bundleName: ", originBundleName);
        originAssetName = EditorGUILayout.TextField("原始assetName: ", originAssetName);

        GUILayout.Space(10);

        newBundleName = EditorGUILayout.TextField("新bundleName: ", newBundleName);
        newAssetName = EditorGUILayout.TextField("新assetName: ", newAssetName);

        GUILayout.Space(10);

        if (GUILayout.Button("修正"))
        {
            if (gameObject == null || string.IsNullOrEmpty(originBundleName)|| string.IsNullOrEmpty(originAssetName)
                || string.IsNullOrEmpty(newBundleName) || string.IsNullOrEmpty(newAssetName))
            {
                EditorUtility.DisplayDialog("错误", "请填写完整的信息", "确定");
                return;
            }

            bool flag = false;
            var gameObjAttaches = gameObject.GetComponentsInChildren<Game.GameObjectAttach>();

            foreach (var gameObjAttach in gameObjAttaches)
            {
                if (gameObjAttach.BundleName == originBundleName && gameObjAttach.AssetName == originAssetName)
                {
                    gameObjAttach.BundleName = newBundleName;
                    gameObjAttach.AssetName = newAssetName;
                    flag = true;
                }
            }

            if (flag)
            {
                GameObject newObj = GameObject.Instantiate<GameObject>(gameObject);
                PrefabUtility.ReplacePrefab(newObj, gameObject, ReplacePrefabOptions.ReplaceNameBased);
                GameObject.DestroyImmediate(newObj);

                EditorUtility.DisplayDialog("成功", "恭喜，替换成功", "确定");
            }
            else
            {
                EditorUtility.DisplayDialog("错误", "没找到相应的AssetID", "确定");
            }

        }
    }
}
