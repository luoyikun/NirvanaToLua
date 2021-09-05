//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System.IO;
using Nirvana;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// It used to load scene details.
/// </summary>
public sealed class SceneDetails : MonoBehaviour
{
    [SerializeField]
#if UNITY_EDITOR
    [AssetType(typeof(SceneAsset))]
#endif
    private AssetID detailScene;

    private void Awake()
    {
        this.LoadScene(this.detailScene);
    }

    private void LoadScene(AssetID asset)
    {
        if (!asset.IsEmpty && !this.IsLoaded(asset))
        {
            AssetManager.LoadLevel(
                this.detailScene, LoadSceneMode.Additive);
        }
    }

    private bool IsLoaded(AssetID asset)
    {
        var sceneName = Path.GetFileNameWithoutExtension(
            detailScene.AssetName);
        var scene = SceneManager.GetSceneByName(sceneName);
        Debug.Log(scene.IsValid() + ", " + scene.isLoaded);
        return scene.IsValid();
    }
}
