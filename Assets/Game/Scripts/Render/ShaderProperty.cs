//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;

/// <summary>
/// The property ID for shader.
/// </summary>
public static class ShaderProperty
{
    private static int? srcBlend;
    private static int? dstBlend;
    private static int? mainColor;
    private static int? rimIntensity;
    private static int? rimFresnel;

    /// <summary>
    /// Gets the shader property ID: _SrcBlend
    /// </summary>
    public static int SrcBlend
    {
        get
        {
            if (!srcBlend.HasValue)
            {
                srcBlend = Shader.PropertyToID("_SrcBlend");
            }

            return srcBlend.Value;
        }
    }

    /// <summary>
    /// Gets the shader property ID: _DstBlend
    /// </summary>
    public static int DstBlend
    {
        get
        {
            if (!dstBlend.HasValue)
            {
                dstBlend = Shader.PropertyToID("_DstBlend");
            }

            return dstBlend.Value;
        }
    }

    /// <summary>
    /// Gets the shader property ID: _MainColor
    /// </summary>
    public static int MainColor
    {
        get
        {
            if (!mainColor.HasValue)
            {
                mainColor = Shader.PropertyToID("_MainColor");
            }

            return mainColor.Value;
        }
    }

    /// <summary>
    /// Gets the shader property ID: _RimIntensity
    /// </summary>
    public static int RimIntensity
    {
        get
        {
            if (!rimIntensity.HasValue)
            {
                rimIntensity = Shader.PropertyToID("_RimIntensity");
            }

            return rimIntensity.Value;
        }
    }

    /// <summary>
    /// Gets the shader property ID: _RimFresnel
    /// </summary>
    public static int RimFresnel
    {
        get
        {
            if (!rimFresnel.HasValue)
            {
                rimFresnel = Shader.PropertyToID("_RimFresnel");
            }

            return rimFresnel.Value;
        }
    }
}
