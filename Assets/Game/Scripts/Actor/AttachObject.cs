//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using LuaInterface;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

/// <summary>
/// 可挂接物体.
/// </summary>
public sealed class AttachObject : MonoBehaviour
{
    [SerializeField]
    private PhysiqueConfig[] physiqueConfig;

#if UNITY_EDITOR
    private int prof;
#endif
    private Transform attached;
    private Vector3 localPosition;
    private Quaternion localRotation;
    private bool isRotationZero = false;

#if UNITY_EDITOR
    /// <summary>
    /// Gets the attached transform.
    /// </summary>
    [NoToLua]
    public Transform Attached
    {
        get { return this.attached; }
        set { this.attached = value; }
    }

    /// <summary>
    /// Gets the local position.
    /// </summary>
    [NoToLua]
    public Vector3 LocalPosition
    {
        get { return this.localPosition; }
        set { this.localPosition = value; }
    }

    /// <summary>
    /// Gets the local rotation.
    /// </summary>
    [NoToLua]
    public Quaternion LocalRotation
    {
        get { return this.localRotation; }
        set { this.localRotation = value; }
    }
#endif

    /// <summary>
    /// 主要用来弄战斗坐骑那个转的时候会重置形象的问题
    /// </summary>
    public bool IsRotationZero
    {
        get { return this.isRotationZero; }
        set { this.isRotationZero = value; }
    }

    public void SetAttached(Transform attached)
    {
        this.attached = attached;
        if (LayerMask.NameToLayer("Default") != this.attached.gameObject.layer)
        {
            this.gameObject.SetLayerRecursively(this.attached.gameObject.layer);
        }

    }

    public void CleanAttached()
    {
        this.attached = null;
    }

    public void SetTransform(int prof)
    {
#if UNITY_EDITOR
        this.prof = prof;
#endif
        if (this.physiqueConfig != null)
        {
            foreach (var i in this.physiqueConfig)
            {
                if (i.Prof == prof)
                {
                    var rotation = Quaternion.Euler(i.Rotation);
                    this.transform.localPosition = i.Position;
                    this.transform.localRotation = rotation;
                    this.transform.localScale = i.Scale;
                    this.localPosition = this.transform.localPosition;
                    this.localRotation = rotation;
                    break;
                }
            }
        }
    }

    private void Awake()
    {
        this.localPosition = this.transform.localPosition;
        this.localRotation = this.transform.localRotation;
        if (null != this.GetComponentInChildren<TrailRenderer>())
        {
            this.GetOrAddComponent<TrailRendererController>();
        }

        EffectOrderGroup.RefreshRenderOrder(this.gameObject);
    }

    private void LateUpdate()
    {
        if (isRotationZero)
        {
            this.transform.rotation = Quaternion.Euler(Vector3.zero);
        }

        if (this.attached == null)
        {
            return;
        }

        var offset = new Vector3(
            this.attached.transform.lossyScale.x * this.localPosition.x,
            this.attached.transform.lossyScale.y * this.localPosition.y,
            this.attached.transform.lossyScale.z * this.localPosition.z);
        var position = this.attached.transform.position +
            this.attached.transform.rotation * offset;
        var rotation = this.attached.transform.rotation * this.localRotation;
        this.transform.SetPositionAndRotation(position, rotation);
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        var prefabType = PrefabUtility.GetPrefabType(this.gameObject);
        if (Application.isPlaying && prefabType != PrefabType.Prefab)
        {
            this.SetTransform(this.prof);
        }
    }
#endif

    [Serializable]
    public struct PhysiqueConfig
    {
        public int Prof;
        public Vector3 Position;
        public Vector3 Rotation;
        public Vector3 Scale;
    }

    public PhysiqueConfig[] GetPhysiqueConfig()
    {
        if (this.physiqueConfig != null)
        {
            PhysiqueConfig[] PhyNew = new PhysiqueConfig[this.physiqueConfig.Length];
            for (int i = 0; i < this.physiqueConfig.Length; ++i)
            {
                PhyNew[i] = this.physiqueConfig[i];
            }
            return PhyNew;
        }
        return null;
    }

    public void ChangeTransformAllProf(PhysiqueConfig[] new_phy)
    {
        if (this.physiqueConfig != null)
        {
            for (int i = 0; i < this.physiqueConfig.Length; ++i)
            {
                for (int j = 0; j < new_phy.Length; ++j)
                {
                    if (this.physiqueConfig[i].Prof == new_phy[j].Prof)
                    {
                        this.physiqueConfig[i].Position = new_phy[j].Position;
                        this.physiqueConfig[i].Rotation = new_phy[j].Rotation;
                        this.physiqueConfig[i].Scale = new_phy[j].Scale;
                        continue;
                    }
                }
            }
        }
    }
}