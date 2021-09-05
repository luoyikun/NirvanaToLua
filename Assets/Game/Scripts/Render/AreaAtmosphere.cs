//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections.Generic;
using Nirvana;
using UnityEngine;

/// <summary>
/// The area atmosphere.
/// </summary>
public sealed class AreaAtmosphere : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The reference for vertical fog.")]
    private VerticalFog verticalFog;

    [SerializeField]
    [Tooltip("The color of the fog.")]
    private Color vfogColor = new Color(0.35f, 0.35f, 0.65f, 1.0f);

    [SerializeField]
    [Tooltip("The density of the fog.")]
    private float vfogDensity = 0.5f;

    [SerializeField]
    [Tooltip("The start height of the fog.")]
    private float vfogStartHeight = 0;

    [SerializeField]
    [Tooltip("The end height of the fog.")]
    private float vfogEndHeight = -5;

    [SerializeField]
    [Tooltip("The transmit time.")]
    private float transmitTime = 0.5f;

    private int enterCount = 0;
    private LinkedListNode<AreaAtmosphere> node;

    /// <summary>
    /// Gets the vertical fog color.
    /// </summary>
    public Color VFogColor
    {
        get { return this.vfogColor; }
    }

    /// <summary>
    /// Gets the vertical fog density.
    /// </summary>
    public float VFogDensity
    {
        get { return this.vfogDensity; }
    }

    /// <summary>
    /// Gets the vertical start height.
    /// </summary>
    public float VFogStartHeight
    {
        get { return this.vfogStartHeight; }
    }

    /// <summary>
    /// Gets the vertical end height.
    /// </summary>
    public float VFogEndHeight
    {
        get { return this.vfogEndHeight; }
    }

    /// <summary>
    /// Gets the transmit time.
    /// </summary>
    public float TransmitTime
    {
        get { return this.transmitTime; }
    }

    private void Start()
    {
        this.gameObject.layer = GameLayers.AreaAtmosphere;
        if (this.verticalFog == null)
        {
            this.verticalFog = Camera.main.GetComponent<VerticalFog>();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        ++this.enterCount;
        if (this.enterCount == 1)
        {
            if (this.verticalFog != null)
            {
                this.node = this.verticalFog.AddAreaAtmosphere(this);
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        --this.enterCount;
        if (this.enterCount <= 0 && 
            this.verticalFog != null && 
            this.node != null)
        {
            this.verticalFog.RemoveAreaAtmosphere(this.node);
        }
    }
}
