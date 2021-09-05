//-----------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//-----------------------------------------------------------------------------

using System.Collections.Generic;
using Nirvana;
using UnityEngine;

/// <summary>
/// The actor blinker used to play blink on an actor.
/// </summary>
public sealed class ActorBlinker : MonoBehaviour
{
    [SerializeField]
    private float fadeIn = 0.01f;

    [SerializeField]
    private float fadeHold = 0.05f;

    [SerializeField]
    private float fadeOut = 0.25f;

    private float blinkFadeIn = -1.0f;
    private float blinkFadeInTotal = -1.0f;
    private float blinkFadeHold = -1.0f;
    private float blinkFadeOut = -1.0f;
    private float blinkFadeOutTotal = -1.0f;
    private List<NirvanaRenderer> renderers = 
        new List<NirvanaRenderer>();

    public float FadeIn { get { return fadeIn; } }

    public float FadeHold { get { return fadeHold; } }

    public float FadeOut { get { return fadeOut; } }
    /// <summary>
    /// Blink this character.
    /// </summary>
    public void Blink(float fadeIn, float fadeHold, float fadeOut)
    {
        this.blinkFadeIn = fadeIn;
        this.blinkFadeInTotal = fadeIn;
        this.blinkFadeHold = fadeHold;
        this.blinkFadeOut = fadeOut;
        this.blinkFadeOutTotal = fadeOut;

        foreach (var renderer in this.renderers)
        {
            renderer.UnsetKeyword((int)ShaderKeyword.ENABLE_RIM);
        }

        this.GetComponentsInChildren(this.renderers);
        foreach (var renderer in this.renderers)
        {
            renderer.SetKeyword((int)ShaderKeyword.ENABLE_RIM);
        }
    }

    private void Update()
    {
        if (this.blinkFadeIn > 0.0f)
        {
            float value = 1 - (this.blinkFadeIn / this.blinkFadeInTotal);
            foreach (var renderer in this.renderers)
            {
                renderer.PropertyBlock.SetFloat(
                    ShaderProperty.RimIntensity, 3.5f * value);
            }

            this.blinkFadeIn -= Time.deltaTime;
        }
        else if (this.blinkFadeHold > 0.0f)
        {
            this.blinkFadeHold -= Time.deltaTime;
        }
        else if (this.blinkFadeOut > 0.0f)
        {
            float value = this.blinkFadeOut / this.blinkFadeOutTotal;
            foreach (var renderer in this.renderers)
            {
                renderer.PropertyBlock.SetFloat(
                    ShaderProperty.RimIntensity, 3.5f * value);
            }

            this.blinkFadeOut -= Time.deltaTime;
            if (this.blinkFadeOut <= 0.0f)
            {
                foreach (var renderer in this.renderers)
                {
                    renderer.UnsetKeyword((int)ShaderKeyword.ENABLE_RIM);
                }

                this.renderers.Clear();
            }
        }
    }
}
