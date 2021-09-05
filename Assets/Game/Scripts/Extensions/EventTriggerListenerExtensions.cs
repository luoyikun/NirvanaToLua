//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

/// <summary>
/// The extensions for EventTriggerListener.
/// </summary>
public static class EventTriggerListenerExtensions
{
    /// <summary>
    /// Add a new listener to begin drag event.
    /// </summary>
    public static void AddBeginDragListener(
        this EventTriggerListener listener, 
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.BeginDragEvent += call;
    }

    /// <summary>
    /// Add a new listener to cancel event.
    /// </summary>
    public static void AddCancelListener(
        this EventTriggerListener listener,
        EventTriggerListener.BaseEventDelegate call)
    {
        listener.CancelEvent += call;
    }

    /// <summary>
    /// Add a new listener to deselect event.
    /// </summary>
    public static void AddDeselectListener(
        this EventTriggerListener listener,
        EventTriggerListener.BaseEventDelegate call)
    {
        listener.DeselectEvent += call;
    }

    /// <summary>
    /// Add a new listener to drag event.
    /// </summary>
    public static void AddDragListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.DragEvent += call;
    }

    /// <summary>
    /// Add a new listener to drop event.
    /// </summary>
    public static void AddDropListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.DropEvent += call;
    }

    /// <summary>
    /// Add a new listener to end drag event.
    /// </summary>
    public static void AddEndDragListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.EndDragEvent += call;
    }

    /// <summary>
    /// Add a new listener to move event.
    /// </summary>
    public static void AddMoveListener(
        this EventTriggerListener listener,
        EventTriggerListener.AxisEventDelegate call)
    {
        listener.MoveEvent += call;
    }

    /// <summary>
    /// Add a new listener to pointer click event.
    /// </summary>
    public static void AddPointerClickListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.PointerClickEvent += call;
    }

    /// <summary>
    /// Add a new listener to pointer down event.
    /// </summary>
    public static void AddPointerDownListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.PointerDownEvent += call;
    }

    /// <summary>
    /// Add a new listener to pointer enter event.
    /// </summary>
    public static void AddPointerEnterListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.PointerEnterEvent += call;
    }

    /// <summary>
    /// Add a new listener to pointer exit event.
    /// </summary>
    public static void AddPointerExitListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.PointerExitEvent += call;
    }

    /// <summary>
    /// Add a new listener to pointer up event.
    /// </summary>
    public static void AddPointerUpListener(
        this EventTriggerListener listener,
        EventTriggerListener.PointerEventDelegate call)
    {
        listener.PointerUpEvent += call;
    }

    /// <summary>
    /// Add a new listener to select event.
    /// </summary>
    public static void AddSelectListener(
        this EventTriggerListener listener,
        EventTriggerListener.BaseEventDelegate call)
    {
        listener.SelectEvent += call;
    }

    /// <summary>
    /// Add a new listener to update selected event.
    /// </summary>
    public static void AddUpdateSelectedListener(
        this EventTriggerListener listener,
        EventTriggerListener.BaseEventDelegate call)
    {
        listener.UpdateSelectedEvent += call;
    }
}

