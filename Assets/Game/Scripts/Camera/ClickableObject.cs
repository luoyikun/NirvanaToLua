//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

/// <summary>
/// The object which is clickable.
/// </summary>
public sealed class ClickableObject : MonoBehaviour
{
    private LinkedList<Clickable> clickables = 
        new LinkedList<Clickable>();

    private bool clickable = true;
    private Action clickListener;

    /// <summary>
    /// The the click listener.
    /// </summary>
    public void SetClickListener(Action listener)
    {
        this.clickListener = listener;
    }

    /// <summary>
    /// Set whether this collider is clickable.
    /// </summary>
    public void SetClickable(bool enabled)
    {
        this.clickable = enabled;
        foreach (var clickable in this.clickables)
        {
            clickable.SetClickable(enabled);
        }
    }

    /// <summary>
    /// Trigger a click event.
    /// </summary>
    [NoToLua]
    public void TriggerClick()
    {
        if (this.clickListener != null)
        {
            this.clickListener();
        }
    }

    /// <summary>
    /// Add a new clickable into this object.
    /// </summary>
    [NoToLua]
    public LinkedListNode<Clickable> AddClickable(Clickable clickable)
    {
        clickable.SetClickable(this.clickable);
        return this.clickables.AddLast(clickable);
    }

    /// <summary>
    /// Remove a clickable from this object.
    /// </summary>
    [NoToLua]
    public void RemoveClickable(LinkedListNode<Clickable> node)
    {
        this.clickables.Remove(node);
    }
}
