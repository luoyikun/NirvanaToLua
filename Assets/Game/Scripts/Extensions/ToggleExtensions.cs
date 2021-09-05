//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------
using Nirvana;
using UnityEngine.Events;
using UnityEngine.UI;

/// <summary>
/// The extensions for Toggle.
/// </summary>
public static class ToggleExtensions
{
    /// <summary>
    /// Add a new listener to the toggle.
    /// </summary>
    public static void AddValueChangedListener(
        this Toggle toggle, UnityAction<bool> call)
    {
        toggle.onValueChanged.AddListener(call);
    }

    /*
    /// <summary>
    /// Add a new listener to the toggle.
    /// </summary>
    public static void AddClickListener(
        this Toggle toggle, UnityAction<bool> call)
    {
        toggle.onValueChanged.RemoveAllListeners();

        bool value = false;
        toggle.onValueChanged.AddListener(
            (bool arg) =>
            {
                if (value)
                {
                    return;
                }

                value = true;
                if (arg) call(arg);
                value = false;
            });
    }
    */

    /// <summary>
    /// Add a click listener to the toggle.
    /// </summary>
    public static void AddClickListener(
        this Toggle toggle, ToggleClickHandler.PointerEventDelegate call)
    {
        var toggle_click_handler = toggle.gameObject.GetOrAddComponent<ToggleClickHandler>();
        toggle_click_handler.RemoveAllListeners();
        if (null != call)
        {
            toggle_click_handler.AddClickListener(call);
        }
    }
}
