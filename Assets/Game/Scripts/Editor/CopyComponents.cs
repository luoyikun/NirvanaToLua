using UnityEngine;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class CopyComponents : EditorWindow
{
    static Component[] copiedComponents;
    [MenuItem("GameObject/Copy Components")]
    static void Copy()
    {
        copiedComponents = Selection.activeGameObject.GetComponents<Component>();
    }

    [MenuItem("GameObject/Paste Components")]
    static void Paste()
    {
        foreach (var targetGameObject in Selection.gameObjects)
        {
            if (!targetGameObject || copiedComponents == null) continue;
            foreach (var copiedComponent in copiedComponents)
            {
                if (!copiedComponent) continue;
                UnityEditorInternal.ComponentUtility.CopyComponent(copiedComponent);
                UnityEditorInternal.ComponentUtility.PasteComponentAsNew(targetGameObject);
            }
        }
    }
}
