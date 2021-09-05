//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using Nirvana.Editor;
using UnityEditor;
using UnityEngine;

/// <summary>
/// The custom editor for <see cref="PostEffects"/>.
/// </summary>
[CustomEditor(typeof(PostEffects))]
public sealed class PostEffectsEditor : Editor
{
    private SerializedProperty downSampleShader;
    private SerializedProperty brightPassShader;
    private SerializedProperty blurPassShader;
    private SerializedProperty combinePassShader;
    private SerializedProperty wavePassShader;
    private SerializedProperty motionBlurPassShader;

    private SerializedProperty enableBloom;
    private SerializedProperty bloomBlendMode;
    private SerializedProperty bloomIntensity;
    private SerializedProperty bloomThreshold;
    private SerializedProperty bloomThresholdColor;
    private SerializedProperty bloomBlurSpread;

    private SerializedProperty enableColorCurve;
    private SerializedProperty redChannelCurve;
    private SerializedProperty greenChannelCurve;
    private SerializedProperty blueChannelCurve;

    private SerializedProperty enableSaturation;
    private SerializedProperty saturation;

    private SerializedProperty enableVignette;
    private SerializedProperty vignetteIntensity;

    private SerializedProperty enableBlur;
    private SerializedProperty blurSpread;
    private SerializedProperty waveStrength;

    private SerializedProperty enableMotionBlur;
    private SerializedProperty motionBlurDist;
    private SerializedProperty motionBlurStrength;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();

        // Try to find shaders if missing.
        if (this.downSampleShader.objectReferenceValue == null)
        {
            this.downSampleShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/DownSample");
        }

        if (this.brightPassShader.objectReferenceValue == null)
        {
            this.brightPassShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/BrightPass");
        }

        if (this.blurPassShader.objectReferenceValue == null)
        {
            this.blurPassShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/BlurPass");
        }

        if (this.combinePassShader.objectReferenceValue == null)
        {
            this.combinePassShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/CombinePass");
        }

        if (this.wavePassShader.objectReferenceValue == null)
        {
            this.wavePassShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/WavePass");
        }

        if (this.motionBlurPassShader.objectReferenceValue == null)
        {
            this.motionBlurPassShader.objectReferenceValue =
                Shader.Find("Game/PostEffect/MotionBlurPass");
        }

        // Show the post effect shader.
        this.downSampleShader.isExpanded = EditorGUILayout.ToggleLeft(
            "Show Shaders",
            this.downSampleShader.isExpanded);
        if (this.downSampleShader.isExpanded)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.downSampleShader);
            EditorGUILayout.PropertyField(this.brightPassShader);
            EditorGUILayout.PropertyField(this.blurPassShader);
            EditorGUILayout.PropertyField(this.combinePassShader);
            GUILayoutEx.EndContents();
        }

        // Bloom
        this.enableBloom.boolValue = EditorGUILayout.ToggleLeft(
            this.enableBloom.displayName,
            this.enableBloom.boolValue);
        if (this.enableBloom.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.bloomBlendMode);
            EditorGUILayout.PropertyField(this.bloomIntensity);
            EditorGUILayout.PropertyField(this.bloomThreshold);
            EditorGUILayout.PropertyField(this.bloomThresholdColor);
            EditorGUILayout.PropertyField(this.bloomBlurSpread);
            GUILayoutEx.EndContents();
        }

        // Color curve.
        this.enableColorCurve.boolValue = EditorGUILayout.ToggleLeft(
            this.enableColorCurve.displayName,
            this.enableColorCurve.boolValue);
        if (this.enableColorCurve.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.redChannelCurve);
            EditorGUILayout.PropertyField(this.greenChannelCurve);
            EditorGUILayout.PropertyField(this.blueChannelCurve);
            GUILayoutEx.EndContents();
        }

        // Saturation
        this.enableSaturation.boolValue = EditorGUILayout.ToggleLeft(
            this.enableSaturation.displayName,
            this.enableSaturation.boolValue);
        if (this.enableSaturation.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.saturation);
            GUILayoutEx.EndContents();
        }

        // Vignette
        this.enableVignette.boolValue = EditorGUILayout.ToggleLeft(
            this.enableVignette.displayName,
            this.enableVignette.boolValue);
        if (this.enableVignette.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.vignetteIntensity);
            GUILayoutEx.EndContents();
        }

        // Blur
        this.enableBlur.boolValue = EditorGUILayout.ToggleLeft(
            this.enableBlur.displayName,
            this.enableBlur.boolValue);
        if (this.enableBlur.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.blurSpread);
            EditorGUILayout.PropertyField(this.waveStrength);
            GUILayoutEx.EndContents();
        }

        this.enableMotionBlur.boolValue = EditorGUILayout.ToggleLeft(
            this.enableMotionBlur.displayName,
            this.enableMotionBlur.boolValue);
        if (this.enableMotionBlur.boolValue)
        {
            GUILayoutEx.BeginContents();
            EditorGUILayout.PropertyField(this.motionBlurDist);
            EditorGUILayout.PropertyField(this.motionBlurStrength);
            GUILayoutEx.EndContents();
        }

        this.serializedObject.ApplyModifiedProperties();
    }

    private void OnEnable()
    {
        var serObj = this.serializedObject;
        this.downSampleShader = serObj.FindProperty("downSampleShader");
        this.brightPassShader = serObj.FindProperty("brightPassShader");
        this.blurPassShader = serObj.FindProperty("blurPassShader");
        this.combinePassShader = serObj.FindProperty("combinePassShader");
        this.wavePassShader = serObj.FindProperty("wavePassShader");
        this.motionBlurPassShader = serObj.FindProperty("motionBlurPassShader");

        this.enableBloom = serObj.FindProperty("enableBloom");
        this.bloomBlendMode = serObj.FindProperty("bloomBlendMode");
        this.bloomIntensity = serObj.FindProperty("bloomIntensity");
        this.bloomThreshold = serObj.FindProperty("bloomThreshold");
        this.bloomThresholdColor = serObj.FindProperty("bloomThresholdColor");
        this.bloomBlurSpread = serObj.FindProperty("bloomBlurSpread");

        this.enableColorCurve = serObj.FindProperty("enableColorCurve");
        this.redChannelCurve = serObj.FindProperty("redChannelCurve");
        this.greenChannelCurve = serObj.FindProperty("greenChannelCurve");
        this.blueChannelCurve = serObj.FindProperty("blueChannelCurve");

        this.enableSaturation = serObj.FindProperty("enableSaturation");
        this.saturation = serObj.FindProperty("saturation");

        this.enableVignette = serObj.FindProperty("enableVignette");
        this.vignetteIntensity = serObj.FindProperty("vignetteIntensity");

        this.enableBlur = serObj.FindProperty("enableBlur");
        this.blurSpread = serObj.FindProperty("blurSpread");
        this.waveStrength = serObj.FindProperty("waveStrength");

        this.enableMotionBlur = serObj.FindProperty("enableMotionBlur");
        this.motionBlurDist = serObj.FindProperty("motionBlurDist");
        this.motionBlurStrength = serObj.FindProperty("motionBlurStrength");
    }
}
