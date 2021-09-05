//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The fence of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneFence : SceneObject
{
    [SerializeField]
    [Tooltip("The ID of this fence.")]
    private int fenceID;

    [SerializeField]
    [Tooltip("The offset of the door view.")]
    private Vector3 offset;

    [SerializeField]
    [Tooltip("The rotation of the door view.")]
    private Vector3 rotation;

    [SerializeField]
    [Tooltip("The scale of the door view.")]
    private Vector3 scale = Vector3.one;

    /// <summary>
    /// Gets the fence ID.
    /// </summary>
    public int ID
    {
        get { return this.fenceID; }
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
    /// 获取fence scale参数
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
        if (Application.isPlaying)
        {
            return;
        }

        this.name = "Fence" + this.fenceID.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        var previewPrefab = EditorResourceMgr.LoadObject(
            "effects/prefabs", "men_dcq01", typeof(GameObject)) as GameObject;
        if (previewPrefab)
        {
            var preview = GameObject.Instantiate(previewPrefab);
            preview.transform.localPosition = this.offset;
            preview.transform.localScale = this.scale;
            var previewObj = this.GetOrAddComponent<PreviewObject>();
            previewObj.SetPreview(preview);
        }
    }
}

#endif
