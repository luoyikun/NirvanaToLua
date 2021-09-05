//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// The clickable collider.
/// </summary>
[RequireComponent(typeof(Collider))]
public sealed class Clickable : MonoBehaviour
{
    [Tooltip("The owner of this clickable object.")]
    [SerializeField]
    private ClickableObject owner;

    private Collider[] colliders;
    private LinkedListNode<Clickable> node;

    /// <summary>
    /// Gets the clickable owner.
    /// </summary>
    public ClickableObject Owner
    {
        get { return this.owner; }
        set { this.owner = value; }
    }

    /// <summary>
    /// Set whether this collider is clickable.
    /// </summary>
    public void SetClickable(bool enabled)
    {
        if (this.colliders != null)
        {
            foreach (var collider in this.colliders)
            {
                collider.enabled = enabled;
            }
        }
    }

    private void Awake()
    {
        this.colliders = this.GetComponents<Collider>();
        if (this.owner != null)
        {
            this.node = this.owner.AddClickable(this);
        }
    }

    private void OnDestroy()
    {
        if (this.owner != null && this.node != null)
        {
            this.owner.RemoveClickable(this.node);
        }
    }
}
