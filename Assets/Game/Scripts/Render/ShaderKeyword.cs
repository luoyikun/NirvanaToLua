//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

/// <summary>
/// The keywords for Nirvana shader.
/// </summary>
public enum ShaderKeyword
{
    /// <summary>
    /// Enable the main color.
    /// </summary>
    ENABLE_MAIN_COLOR,

    /// <summary>
    /// Enable the tint color.
    /// </summary>
    ENABLE_TINT_COLOR,

    /// <summary>
    /// Enable the rim feature.
    /// </summary>
    ENABLE_RIM,
}

/// <summary>
/// The extensions for Nirvana shader.
/// </summary>
public static class ShaderKeywordExtensions
{
    /// <summary>
    /// Register all keyword when the game is launch.
    /// </summary>
#if UNITY_EDITOR
    [InitializeOnLoadMethod]
#endif
    [RuntimeInitializeOnLoadMethod]
    public static void Initialize()
    {
        ShaderKeywords.SetKeywordName(
            (int)ShaderKeyword.ENABLE_MAIN_COLOR, "ENABLE_MAIN_COLOR");
        ShaderKeywords.SetKeywordName(
           (int)ShaderKeyword.ENABLE_TINT_COLOR, "ENABLE_TINT_COLOR");
        ShaderKeywords.SetKeywordName(
            (int)ShaderKeyword.ENABLE_RIM, "ENABLE_RIM");
    }
}
