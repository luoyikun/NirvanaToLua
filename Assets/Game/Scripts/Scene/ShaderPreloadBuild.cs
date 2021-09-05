//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

#if UNITY_EDITOR

using UnityEditor;
using UnityEngine;
using UnityObject = UnityEngine.Object;

/// <summary>
/// Build the preload shader.
/// </summary>
public sealed class ShaderPreloadBuild : MonoBehaviour
{
    [SerializeField]
    private string[] folders;

    private void Awake()
    {
        if (this.folders == null)
        {
            return;
        }

        var guids = AssetDatabase.FindAssets("t:prefab", this.folders);
        foreach (var guid in guids)
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (prefab)
            {
                GameObject.Instantiate<GameObject>(prefab);
            }
        }
    }
}

#endif
