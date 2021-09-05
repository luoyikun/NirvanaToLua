
using System;
using DG.Tweening;
using UnityEngine.UI;

public static class CanvasGroupExtensions
{
    public static Tweener DoAlpha(
        this UnityEngine.CanvasGroup canvasGroup, float initial, float to, float duration)
    {
        Tweener t = DOTween.To(() => initial, x => canvasGroup.alpha = x, to, duration);
        return t;
    }
}
