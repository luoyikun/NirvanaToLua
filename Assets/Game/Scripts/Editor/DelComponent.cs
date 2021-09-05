using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class DelComponent : Editor
{
    [MenuItem("Nirvana/Yifan/DelAudioListener")]
    public static void DelAudioListener()
    {
        Debug.Log("DelAudioListener");

        Object[] selects = Selection.GetFiltered<Object>(SelectionMode.DeepAssets);
        foreach (var asset in selects)
        {
            if (asset is GameObject)
            {
                DestoryComponent<AudioListener>((GameObject)asset);
                DestoryComponent<FlareLayer>((GameObject)asset);
                DestoryComponent<GUILayer>((GameObject)asset);
            }
        }
    }

    private static void DestoryComponent<T>(GameObject obj)  where T : UnityEngine.Object
    {
        T[] listeners = obj.GetComponentsInChildren<T>(true);

        foreach (T component in listeners)
        {
            Object.DestroyImmediate(component, true);
        }
    }
}
