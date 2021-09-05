//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR
/// <summary>
/// The monster point of this scene.
/// </summary>
[ExecuteInEditMode]
public sealed class SceneMonsterPoint : SceneObject
{
    [SerializeField]
    [Tooltip("The ID of this monster.")]
    private int monsterID;

    [SerializeField]
    [Tooltip("The interval time for the monster spawn, in millisecond.")]
    private int interval = 1000;

    [SerializeField]
    [Tooltip("The number of the monster.")]
    private int num = 1;

    [SerializeField]
    [Tooltip("The total number this monster can be spawn.")]
    private int histroyTotalNum = 0;

    /// <summary>
    /// Gets the monster ID.
    /// </summary>
    public int ID
    {
        get { return this.monsterID; }
    }

    /// <summary>
    /// Gets the monster interval time.
    /// </summary>
    public int Interval
    {
        get { return this.interval; }
    }

    /// <summary>
    /// Gets the monster number.
    /// </summary>
    public int Num
    {
        get { return this.num; }
    }

    /// <summary>
    /// Gets the total history number.
    /// </summary>
    public int HistroyTotalNum
    {
        get { return this.histroyTotalNum; }
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

        this.name = "Monster" + this.monsterID.ToString();
        this.LoadPreview();
    }

    private void LoadPreview()
    {
        PreviewObject previewObj = null;
        int resID = ConfigManager.Instance.GetMonsterResID(this.monsterID);
        if (resID >= 0)
        {
            var bundleName = string.Format("actors/monster/{0}_prefab", resID / 1000);
            var assetName = resID.ToString();
            var previewPrefab= EditorResourceMgr.LoadObject(bundleName, assetName, typeof(GameObject)) as GameObject;
            if (previewPrefab)
            {
                var preview = GameObject.Instantiate(previewPrefab);
                previewObj = this.GetOrAddComponent<PreviewObject>();
                previewObj.SetPreview(preview);
                return;
            }
        }

        Debug.LogWarning("Can not find monster with id: " + this.monsterID);
        previewObj = this.GetComponent<PreviewObject>();
        if (previewObj != null)
        {
            previewObj.ClearPreview();
        }
    }
}

#endif
