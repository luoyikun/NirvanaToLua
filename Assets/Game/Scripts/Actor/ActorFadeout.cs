//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

/// <summary>
/// The description of ActorFadeout.
/// </summary>
public sealed class ActorFadeout : MonoBehaviour
{
    [SerializeField]
    private RenderItem[] items;

    [SerializeField]
    private GameObject effect;

    [SerializeField]
    private GameObject fadeinEffect;

    private float fadeout = -1.0f;
    private float fadeoutTotal = -1.0f;

    private float fadein = -1.0f;
    private float fadeinTotal = -1.0f;

    private Action fadeoutCallback;
    private Action fadeinCallback;

    /// <summary>
    /// Blink this character.
    /// </summary>
    private void Awake()
    {
        foreach (var i in this.items)
        {
            i.Origins = i.Renderer.Materials;
        }
    }

    public void Fadeout(float time, Action callback)
    {
        this.fadeout = time;
        this.fadeoutTotal = time;
        this.fadeoutCallback = callback;

        if (this.fadein > 0)
        {   
            this.ClearCache();
            this.fadein = -1.0f;
            this.fadeinTotal = -1.0f;
            if (this.fadeinCallback != null)
            {
                this.fadeinCallback();
                this.fadeinCallback = null;
            }
        }

        foreach (var i in this.items)
        {
            i.Renderer.Materials = i.Materials;

            if (this.effect != null)
            {
                var skinned = i.Renderer.GetComponent<SkinnedMeshRenderer>();
                if (skinned != null)
                {
                    i.Effect = GameObject.Instantiate(effect);
                    i.Particles = i.Effect.GetComponentsInChildren<ParticleSystem>();
                    foreach (var ps in i.Particles)
                    {
                        var shape = ps.shape;
                        shape.skinnedMeshRenderer = skinned;
                    }
                }
            }
        }
    }

    public void Fadein(float time, Action callback)
    {
        this.fadein = time;
        this.fadeinTotal = time;
        this.fadeinCallback = callback;

        if(this.fadeout > 0)
        {
            this.ClearCache();
            this.fadeout = -1.0f;
            this.fadeoutTotal = -1.0f;
            if (this.fadeoutCallback != null)
            {
                this.fadeoutCallback();
                this.fadeoutCallback = null;
            }
        }

        foreach (var i in this.items)
        {
            i.Renderer.Materials = i.Materials;

            if (this.fadeinEffect != null)
            {
                var skinned = i.Renderer.GetComponent<SkinnedMeshRenderer>();
                if (skinned != null)
                {
                    i.Effect = GameObject.Instantiate(fadeinEffect);
                    i.Particles = i.Effect.GetComponentsInChildren<ParticleSystem>();
                    foreach (var ps in i.Particles)
                    {
                        var shape = ps.shape;
                        shape.skinnedMeshRenderer = skinned;
                    }
                }
            }
        }
    }

    private void ClearCache()
    {
        foreach (var i in this.items)
        {
            i.Renderer.Materials = i.Origins;
            i.Renderer.PropertyBlock.SetColor(
                ShaderProperty.MainColor,
                Color.white);
            if (i.Particles != null)
            {
                foreach (var ps in i.Particles)
                {
                    if (null != ps)
                    {
                        ps.Stop();
                    }
                }

                if (null != i.Effect)
                {
                    GameObject.Destroy(i.Effect, 0.5f);
                }

                i.Particles = null;
            }
        }
    }
    private void Update()
    {
        if (this.fadeout > 0.0f)
        {
            float value = this.fadeout / this.fadeoutTotal;
            foreach (var i in this.items)
            {
                i.Renderer.PropertyBlock.SetColor(
                    ShaderProperty.MainColor, 
                    new Color(1, 1, 1, value));
            }

            this.fadeout -= Time.deltaTime;
            if (this.fadeout < 0)
            {
                if (this.fadeoutCallback != null)
                {
                    this.fadeoutCallback();
                    this.fadeoutCallback = null;
                }
                this.ClearCache();
                this.fadeout = -1.0f;
                this.fadeoutTotal = -1.0f;
            }
        }
        else if (this.fadein > 0.0f)
        {
            float value = 1 - this.fadein / this.fadeinTotal;
            foreach (var i in this.items)
            {
                i.Renderer.PropertyBlock.SetColor(
                    ShaderProperty.MainColor,
                    new Color(1, 1, 1, value));
            }

            this.fadein -= Time.deltaTime;
            if (this.fadein < 0)
            {
                if (this.fadeinCallback != null)
                {
                    this.fadeinCallback();
                    this.fadeinCallback = null;
                }
                this.ClearCache();
                this.fadein = -1.0f;
                this.fadeinTotal = -1.0f;
            }
        }
    }

    [Serializable]
    private class RenderItem
    {
        public NirvanaRenderer Renderer;

        public Material[] Materials;

        [NonSerialized]
        public Material[] Origins;

        [NonSerialized]
        public GameObject Effect;

        [NonSerialized]
        public ParticleSystem[] Particles;
    }
}
