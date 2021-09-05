//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The NPC of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneNPC : SceneObject
{
    [SerializeField]
    [Tooltip("The ID of this NPC.")]
    private int npcID;

    [SerializeField]
    [Tooltip("客户端模拟的可移动的NPC")]
    private bool isWalking;

    [SerializeField]
    private Vector2[] paths;

    /// <summary>
    /// Gets the NPC ID.
    /// </summary>
    public int ID
    {
        get { return this.npcID; }
    }

    public bool IsWalking
    {
        get { return this.isWalking; }
    }

    public Vector2[] Paths
    {
        get { return this.paths; }
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

        this.name = "NPC" + this.npcID.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        int resID = ConfigManager.Instance.GetNPCResID(this.npcID);
        if (resID >= 0)
        {
            var bundleName = string.Format("actors/npc/{0}_prefab", resID / 1000);
            var assetName = resID.ToString();
            var previewPrefab = EditorResourceMgr.LoadObject(
                bundleName, assetName, typeof(GameObject)) as GameObject;
            if (previewPrefab)
            {
                var preview = GameObject.Instantiate(previewPrefab);
                var previewObj = this.GetOrAddComponent<PreviewObject>();
                previewObj.SetPreview(preview);
            }
        }
        else
        {
            Debug.LogWarning("Can not find NPC with id: " + this.npcID);
            var previewObj = this.GetComponent<PreviewObject>();
            if (previewObj != null)
            {
                previewObj.ClearPreview();
            }
        }
    }
}

#endif
