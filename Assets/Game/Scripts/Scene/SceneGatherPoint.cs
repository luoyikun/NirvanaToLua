//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The gather point of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneGatherPoint : SceneObject
{
    [SerializeField]
    [Tooltip("The ID of this gather point.")]
    private int gatherID;

    [SerializeField]
    [Tooltip("The index of this gather point.")]
    private int index;

    [SerializeField]
    [Tooltip("The interval for create gather point.")]
    private int interval = 4000;

    [SerializeField]
    [Tooltip("The gather time for create gather point.")]
    private int gatherTime = 2000;

    [SerializeField]
    [Tooltip("The time to disappear after gathered.")]
    private int disappearAfterGather = 0;

    [SerializeField]
    [Tooltip("evil add.")]
    private int evilAdd = 0;

    /// <summary>
    /// Gets the gather ID.
    /// </summary>
    public int ID
    {
        get { return this.gatherID; }
    }

    /// <summary>
    /// Gets the gather index.
    /// </summary>
    public int Index
    {
        get { return this.index; }
    }

    /// <summary>
    /// Gets the gather interval.
    /// </summary>
    public int Interval
    {
        get { return this.interval; }
    }

    /// <summary>
    /// Gets the gather time.
    /// </summary>
    public int GatherTime
    {
        get { return this.gatherTime; }
    }

    /// <summary>
    /// Gets the disappear after gather.
    /// </summary>
    public int DisappearAfterGather
    {
        get { return this.disappearAfterGather; }
    }

    /// <summary>
    /// Gets the evil add.
    /// </summary>
    public int EvilAdd
    {
        get { return this.evilAdd; }
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

        this.name = "Gather" + this.gatherID.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        PreviewObject previewObj = null;
        int resID = ConfigManager.Instance.GetGatherResID(this.gatherID);
        Debug.LogFormat("gather, {0}, {1}", this.gatherID, resID);
        if (resID >= 0)
        {
            var bundleName = string.Format("actors/gather/{0}_prefab", resID / 1000);
            var assetName = resID.ToString();
            var previewPrefab = EditorResourceMgr.LoadObject(
                bundleName, assetName, typeof(GameObject)) as GameObject;
            if (previewPrefab)
            {
                var preview = GameObject.Instantiate(previewPrefab);
                previewObj = this.GetOrAddComponent<PreviewObject>();
                previewObj.SetPreview(preview);
                return;
            }
        }

        Debug.LogWarning("Can not find Gather with id: " + this.gatherID);
        previewObj = this.GetComponent<PreviewObject>();
        if (previewObj != null)
        {
            previewObj.ClearPreview();
        }
    }
}

#endif
