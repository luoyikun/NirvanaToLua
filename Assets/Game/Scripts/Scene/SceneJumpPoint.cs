//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;
using Nirvana;
using System;
#if UNITY_EDITOR

/// <summary>
/// The door of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneJumpPoint : SceneObject
{
    private enum JumpTypeEnum {普通, 飞行器};
    private enum IsShowEnum {隐藏, 显示};
    private enum JumpActEnum {随机, 跳跃1, 跳跃2, 跳跃3 };
    private enum JumpTongBuEnum { 不同步, 同步};

    [SerializeField]
    private Vector3 offset = Vector3.zero;

    [SerializeField]
    private int id;

    [SerializeField]
    private SceneJumpPoint target;

    [SerializeField]
    private JumpTypeEnum jumpType = 0;

    [SerializeField]
    private int range = 5;

    [SerializeField]
    private int airCraftId = 0;

    [SerializeField]
    private IsShowEnum isShow = 0;

    [SerializeField]
    private float jumpSpeed = 2f;

    [SerializeField]
    private JumpActEnum jumpAct = 0;

    [SerializeField]
    private JumpTongBuEnum tongBu = 0;

    [SerializeField]
    private float jumpTime = 1f;

    [SerializeField]
    private float jumpCameraFOV = 0f;

    [SerializeField]
    private float jumpCameraRotation = 0f;

    [SerializeField]
    private bool playCG = false;

    [SerializeField]
    private CG[] cgs;

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

        // Setup name.
        this.name = "Jumppoint" + this.id.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        if (this.isShow == 0)
            return;
        var bundleName = "effects2/prefab/misc/tiaoyuedian_prefab";
        var assetName = "tiaoyuedian";
        var previewPrefab = EditorResourceMgr.LoadObject(
            bundleName, assetName, typeof(GameObject)) as GameObject;
        if (previewPrefab)
        {
            var preview = GameObject.Instantiate(previewPrefab);
            var previewObj = this.GetOrAddComponent<PreviewObject>();
            preview.transform.localPosition = this.offset;
            previewObj.SetPreview(preview);
        }
    }
    /// <summary>
    /// Gets the jump point ID.
    /// </summary>
    public int ID
    {
        get { return this.id; }
    }

    /// <summary>
    /// Gets the target ID.
    /// </summary>
    public int TargetID
    {
        get
        {
            if (this.target != null)
            {
                return this.target.ID;
            }

            return -1;
        }
    }

    public int JumpType
    {
        get { return (int)this.jumpType; }
    }

    public int AirCraftId
    {
        get { return this.airCraftId; }
    }
    /// <summary>
    /// Gets the range of this jumppoint.
    /// </summary>
    public int Range
    {
        get { return this.range; }
    }

    public int IsShow
    {
        get { return (int)this.isShow; }
    }

    public float JumpSpeed
    {
        get { return this.jumpSpeed; }
    }

    public int JumpAct
    {
        get { return (int)this.jumpAct; }
    }

    public int TongBu
    {
        get { return (int)this.tongBu; }
    }

    public float JumpTime
    {
        get { return this.jumpTime; }
    }

    public float JumpCameraFOV
    {
        get { return this.jumpCameraFOV; }
    }

    public float JumpCameraRotation
    {
        get { return this.jumpCameraRotation; }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(transform.position, Mathf.Sqrt(range));
    }

    public Vector3 Offset
    {
        get { return this.offset; }
    }

    public bool PlayCG
    {
        get { return this.playCG; }
    }

    public CG[] CGs
    {
        get { return this.cgs; }
    }

    [Serializable]
    public struct CG
    {
        public int prof;
        [AssetType(typeof(CGController))]
        public AssetID cgController;
        public Vector2 position;
        public float rotationY;
    }
}

#endif
