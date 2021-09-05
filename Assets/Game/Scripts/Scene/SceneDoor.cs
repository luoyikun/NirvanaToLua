//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The door of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneDoor : SceneObject
{
    [SerializeField]
    [Tooltip("The ID of this door.")]
    private int doorID;

    [SerializeField]
    [Tooltip("The type of door.")]
    [EnumLabel("Door Type")]
    private DoorTypeEnum doorType;

    [SerializeField]
    [Tooltip("The role level for this door.")]
    private int limitLevel;

    [SerializeField]
    [Tooltip("The target scene ID.")]
    private int targetSceneID;

    [SerializeField]
    [Tooltip("The target door ID.")]
    private int targetDoorID;

    [SerializeField]
    [Tooltip("The offset of the door view.")]
    private Vector3 offset;

    [SerializeField]
    [Tooltip("The rotation of the door view.")]
    private Vector3 rotation;


    [SerializeField]
    [Tooltip("修改Door的Scale大小")]
    private Vector3 scale = Vector3.one;

    private enum DoorTypeEnum : int
    {
        [EnumLabel("普通")]
        Normal = 0,

        [EnumLabel("副本")]
        FuBen = 1,

        [EnumLabel("团队副本")]
        TeamFuBen = 10,

        [EnumLabel("不可见")]
        Invisible = 100,
    }

    /// <summary>
    /// Gets the door ID.
    /// </summary>
    public int ID
    {
        get { return this.doorID; }
    }

    /// <summary>
    /// Gets the door type.
    /// </summary>
    public int DoorType
    {
        get { return (int)this.doorType; }
    }

    /// <summary>
    /// Gets the limit level of this door.
    /// </summary>
    public int LimitLevel
    {
        get { return this.limitLevel; }
    }

    /// <summary>
    /// Gets the target scene ID.
    /// </summary>
    public int TargetSceneID
    {
        get { return this.targetSceneID; }
    }

    /// <summary>
    /// Gets the target door ID.
    /// </summary>
    public int TargetDoorID
    {
        get { return this.targetDoorID; }
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
    /// 获取Door的Scale参数.
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

        this.name = "Door" + this.doorID.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        var previewPrefab = EditorResourceMgr.LoadObject(
            "effects/prefab/misc_prefab", "portal_01", typeof(GameObject)) as GameObject;
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
