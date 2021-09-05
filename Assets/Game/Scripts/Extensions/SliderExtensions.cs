//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using DG.Tweening;
using UnityEngine.Events;
using UnityEngine.UI;

/// <summary>
/// The extensions for button.
/// </summary>
public static class SliderExtensions
{
    /// <summary>
    /// Add a new listener to the button.
    /// </summary>
    public static void AddValueChangedListener(
        this Slider slider, UnityAction<float> call)
    {
        slider.onValueChanged.AddListener(call);
    }

    /// <summary>
    /// Tween in linear value.
    /// </summary>
    public static Tweener DoValueLiner(this Slider slider, float from, float to, float duration, Action complete, bool fromNow)
    {
        if (fromNow)
        {
            from = slider.value;
        }

        var t = DOTween.To(() => from, x => from = x, to, duration);
        t.SetEase(Ease.Linear);
        t.OnUpdate(() =>
        {
            if (null != slider)
            {
                slider.value = from;
            }
        });
        t.OnComplete(() =>
        {
            if (null != complete)
            {
                complete();
            }
        });

        return t;
    }
}

