//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine.Events;
using UnityEngine.UI;

/// <summary>
/// The extensions for button.
/// </summary>
public static class ButtonExtensions
{
    /// <summary>
    /// Add a new listener to the button.
    /// </summary>
    public static void AddClickListener(this Button button, UnityAction call)
    {
        button.onClick.RemoveAllListeners();
        button.onClick.AddListener(call);
    }
}
