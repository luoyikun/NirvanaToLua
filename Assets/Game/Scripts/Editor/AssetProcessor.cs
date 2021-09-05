
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;

public static class AssetProcessor
{
    private static bool DoUnmarkStaticBatching(Transform trans)
    {
        bool ret = false;

        var flag = GameObjectUtility.GetStaticEditorFlags(trans.gameObject);
        if ((flag & StaticEditorFlags.BatchingStatic) != 0)
        {
            flag = flag & (~StaticEditorFlags.BatchingStatic);
            ret = true;
        }
        GameObjectUtility.SetStaticEditorFlags(trans.gameObject, flag);

        for (int i = 0; i < trans.childCount; ++i)
        {
            var childTransform = trans.GetChild(i);
            if (DoUnmarkStaticBatching(childTransform))
            {
                ret = true;
            }
        }

        return ret;
    }

    [MenuItem("Assets/UnmarkStaticBatching")]
    public static void UnmarkStaticBatcing()
    {
        if (DoUnmarkStaticBatching(Selection.activeTransform))
        {
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }

        Selection.activeGameObject.tag = "StaticBatching";
    }
}

