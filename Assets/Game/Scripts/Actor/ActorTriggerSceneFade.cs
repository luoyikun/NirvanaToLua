//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;
using Nirvana;

/// <summary>
/// Used to trigger to control the scene fade.  
/// </summary>
[Serializable]
public class ActorTriggerSceneFade : ActorTriggerBase
{
    private static bool isFading = false;

    [SerializeField]
    [Tooltip("The camera field of view change.")]
    private Color color = new Color(0.0f, 0.0f, 0.0f, 0.5f);

    [SerializeField]
    [Tooltip("The scene drak fade in time.")]
    private float fadeIn = 0.5f;

    [SerializeField]
    [Tooltip("The scene drak hold time.")]
    private float hold = 1.5f;

    [SerializeField]
    [Tooltip("The scene drak fade in time.")]
    private float fadeOut = 0.5f;

    private float fadeInTime = -1.0f;
    private float holdTime = -1.0f;
    private float fadeOutTime = -1.0f;
    private Color fadeColor;
    private VerticalFog verticalFog;
    private Color verticalFogColor;

    public float FadeIn { get { return fadeIn; } }

    public Color Color { get { return color; } }

    public float Hold { get { return hold; } }

    public float FadeOut { get { return fadeOut; } }

    /// <inheritdoc/>
    public override void UpdateTrigger()
    {
        base.UpdateTrigger();
        if (this.fadeInTime >= 0.0f)
        {
            this.fadeInTime += Time.deltaTime;
            var k = this.fadeInTime / this.fadeIn;

            this.fadeColor = Color.Lerp(Color.white, this.color, k);
            this.SetColor(this.fadeColor);
            if (this.verticalFog)
            {
                this.verticalFog.Color = Color.Lerp(this.verticalFog.Color, this.color, k);
            }

            if (this.fadeInTime >= this.fadeIn)
            {
                this.fadeInTime = -1.0f;
            }
        }
        else if (this.holdTime >= 0.0f)
        {
            this.holdTime += Time.deltaTime;
            if (this.holdTime >= this.hold)
            {
                this.holdTime = -1.0f;
            }
        }
        else if (this.fadeOutTime >= 0.0f)
        {
            this.fadeOutTime += Time.deltaTime;
            var k = this.fadeOutTime / this.fadeOut;

            this.fadeColor = Color.Lerp(
                this.fadeColor, Color.white, k);
            this.SetColor(this.fadeColor);
            if (this.verticalFog)
            {
                this.verticalFog.Color = Color.Lerp(
                    this.verticalFog.Color, this.verticalFogColor, k);
            }

            if (this.fadeOutTime >= this.fadeOut)
            {
                this.fadeOutTime = -1.0f;
                this.DisableColor();
                isFading = false;
            }
        }
    }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        if (!isFading)
        {
            isFading = true;
            this.fadeInTime = 0.0f;
            this.holdTime = 0.0f;
            this.fadeOutTime = 0.0f;
            this.EnableColor();
        }
    }

    private void EnableColor()
    {
        if (Camera.main == null)
        {
            return;
        }
        this.verticalFog = Camera.main.GetComponent<VerticalFog>();
        if (this.verticalFog)
        {
            this.verticalFogColor = this.verticalFog.Color;
        }

        foreach (var instance in SceneRenderers.Instances)
        {
            var renderers = instance.Renderers;
            foreach (var renderer in renderers)
            {
                renderer.SetKeyword((int)ShaderKeyword.ENABLE_MAIN_COLOR);
                renderer.SetKeyword((int)ShaderKeyword.ENABLE_TINT_COLOR);
            }
        }
    }

    private void DisableColor()
    {
        if (this.verticalFog)
        {
            this.verticalFog.Color = this.verticalFogColor;
        }

        foreach (var instance in SceneRenderers.Instances)
        {
            var renderers = instance.Renderers;
            foreach (var renderer in renderers)
            {
                renderer.UnsetKeyword((int)ShaderKeyword.ENABLE_MAIN_COLOR);
                renderer.UnsetKeyword((int)ShaderKeyword.ENABLE_TINT_COLOR);
                renderer.ClearPropertyBlock();
            }
        }
    }

    private void SetColor(Color color)
    {
        foreach (var instance in SceneRenderers.Instances)
        {
            var renderers = instance.Renderers;
            foreach (var renderer in renderers)
            {
                renderer.PropertyBlock.SetColor("_MainColor", color);
                renderer.PropertyBlock.SetColor("_TintColor", color);
            }
        }
    }
}
