using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class DestroyAssetInPrefab : Editor {

    [MenuItem("Tools/Destory All Component/All Prefab ResolutionAdpter")]
    static void DestroyResolutionAdapter()
    {
        var ids = AssetDatabase.FindAssets("t:prefab");
        foreach (var id in ids)
        {
            var path = AssetDatabase.GUIDToAssetPath(id);
            var gameObj = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            var adapters = gameObj.GetComponentsInChildren<ResolutionAdapter>(true);
            foreach (var adapter in adapters)
            {
                DestroyImmediate(adapter, true);
            }
        }
    }
}
