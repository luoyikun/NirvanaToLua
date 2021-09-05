//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using DG.Tweening;
using UnityEngine.UI;

/// <summary>
/// The extensions for text.
/// </summary>
public static class TestExtensions
{
    public static Tweener DoNumberTo(
        this Text text, int from, int to, float duration, Action complete)
    {
        Tweener t = DOTween.To(() => from, x => from = x, to, duration);
        t.OnUpdate(() =>
        {
            if (null != text)
            {
                text.text = from.ToString();
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
