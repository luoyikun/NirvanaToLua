//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
/// <summary>
/// The effect of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneEffect : SceneObject
{
    [SerializeField]
    [Tooltip("The target scene ID.")]
    private AssetID asset;

    [SerializeField]
    [Tooltip("The offset of the effect view.")]
    private Vector3 offset;

    [SerializeField]
    [Tooltip("The rotation of the effect view.")]
    private Vector3 rotation;

    [SerializeField]
    [Tooltip("修改特效大小")]
    private Vector3 scale = Vector3.one;

    /// <summary>
    /// Gets the effect asset.
    /// </summary>
    public AssetID AssetID
    {
        get { return this.asset; }
    }

    /// <summary>
    /// Gets the door offset.
    /// </summary>
    public Vector3 Offset
    {
        get { return this.offset; }
    }

    /// <summary>
    /// Gets the door rotation.
    /// </summary>
    public Vector3 Rotation
    {
        get { return this.rotation; }
    }

    /// <summary>
    /// 获取场景特效Scale参数
    /// </summary>
    public Vector3 Scale
    {
        get { return this.scale; }
    }

    private void Awake()
    {
        this.LoadPreview();
    }

    private void OnValidate()
    {
//         if (Application.isPlaying)
//         {
//             return;
//         }

        this.name = "Effect";
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        if (!this.asset.IsEmpty)
        {
            var previewPrefab = EditorResourceMgr.LoadObject(
            this.asset.BundleName, this.asset.AssetName, typeof(GameObject)) as GameObject;
            if (previewPrefab)
            {
                var preview = GameObject.Instantiate(previewPrefab);
                preview.transform.localPosition = this.offset;
                preview.transform.localRotation = Quaternion.Euler(this.rotation.x, this.rotation.y, this.rotation.z);
                preview.transform.localScale = this.scale;
                var previewObj = this.GetOrAddComponent<PreviewObject>();
                previewObj.SetPreview(preview);
            }
        }
        else
        {
            var previewObj = this.GetComponent<PreviewObject>();
            if (previewObj != null)
            {
                previewObj.ClearPreview();
            }
        }
    }

    public void RefreshAssetBundleName()
    {
        string assetPath = AssetDatabase.GUIDToAssetPath(this.asset.AssetGUID);
        var importer = AssetImporter.GetAtPath(assetPath);
        if (null != importer)
        {
            this.asset.BundleName = importer.assetBundleName;
            this.asset.AssetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);
        }
    }

    public bool IsGameobjectMissing()
    {
        string assetPath = AssetDatabase.GUIDToAssetPath(this.asset.AssetGUID);
        var importer = AssetImporter.GetAtPath(assetPath);
        if (null == importer)
        {
            return true;
        }

        if (this.asset.BundleName != importer.assetBundleName
            || this.asset.AssetName != assetPath.Substring(assetPath.LastIndexOf("/") + 1))
        {
            return true;
        }

        return false;
    }
}

#endif
