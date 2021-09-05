//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana.Editor
{
    using UnityEditor;
    using UnityEngine;

    /// <summary>
    /// The editor for <see cref="QualityControlPostEffects"/>
    /// </summary>
    [CustomEditor(typeof(QualityControlPostEffects))]
    public class QualityControlPostEffectsEditor : Editor
    {
        private QualityConfig qualityConfig;
        private SerializedProperty bloomEnabledLevels;
        private SerializedProperty colorCurveEnabledLevels;
        private SerializedProperty saturationEnabledLevels;
        private SerializedProperty vignetteEnabledLevels;

        /// <inheritdoc/>
        public override void OnInspectorGUI()
        {
            // Try to find the quality config.
            if (this.qualityConfig == null)
            {
                var qualityConfigs = QualityConfig.FindConfigs();
                if (qualityConfigs.Length == 0)
                {
                    EditorGUILayout.HelpBox(
                        "There has no quality config in the project.",
                        MessageType.Error);
                    this.qualityConfig = null;
                }
                else
                {
                    if (qualityConfigs.Length > 1)
                    {
                        EditorGUILayout.HelpBox(
                            "There are more than one quality config.",
                            MessageType.Warning);
                    }

                    this.qualityConfig = qualityConfigs[0];
                }
            }

            // Show the current quality level.
            var levelCount = this.qualityConfig.GetLevelCount();
            if (this.qualityConfig != null)
            {
                var qualityMenu = new string[levelCount];
                for (int i = 0; i < levelCount; ++i)
                {
                    var level = this.qualityConfig.GetLevel(i);
                    qualityMenu[i] = level.Name;
                }

                var currentLevel = QualityConfig.QualityLevel;
                EditorGUI.BeginChangeCheck();
                currentLevel = EditorGUILayout.Popup(
                    "Current Quality:", currentLevel, qualityMenu);
                if (EditorGUI.EndChangeCheck())
                {
                    QualityConfig.QualityLevel = currentLevel;
                }

                EditorGUILayout.Space();
            }

            var control = (QualityControlPostEffects)this.target;
            var postEffects = control.GetComponent<PostEffects>();

            // Draw the editor.
            this.serializedObject.Update();

            // Draw the header.
            GUILayout.BeginHorizontal();
            GUILayout.Label("Effect", GUILayout.MaxWidth(75.0f));
            for (int i = 0; i < levelCount; ++i)
            {
                var level = this.qualityConfig.GetLevel(i);
                GUILayout.Label(level.Name);
            }

            GUILayout.EndHorizontal();

            GUILayoutEx.BeginContents();
            if (postEffects.EnableBloom)
            {
                this.bloomEnabledLevels.arraySize = levelCount;
                this.DrawEnableControl("Bloom", this.bloomEnabledLevels);
            }

            if (postEffects.EnableColorCurve)
            {
                this.colorCurveEnabledLevels.arraySize = levelCount;
                this.DrawEnableControl("ColorCurve", this.colorCurveEnabledLevels);
            }

            if (postEffects.EnableSaturation)
            {
                this.saturationEnabledLevels.arraySize = levelCount;
                this.DrawEnableControl("Saturation", this.saturationEnabledLevels);
            }

            if (postEffects.EnableVignette)
            {
                this.vignetteEnabledLevels.arraySize = levelCount;
                this.DrawEnableControl("Vignette", this.vignetteEnabledLevels);
            }

            GUILayoutEx.EndContents();

            this.serializedObject.ApplyModifiedProperties();
        }

        private void DrawEnableControl(string name, SerializedProperty property)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label(name, GUILayout.MaxWidth(75.0f));
            int levelCount = this.qualityConfig.GetLevelCount();
            for (int i = 0; i < levelCount; ++i)
            {
                var levelEnabled = property.GetArrayElementAtIndex(i);
                levelEnabled.boolValue = GUILayout.Toggle(
                    levelEnabled.boolValue, GUIContent.none);
            }

            GUILayout.EndHorizontal();
        }

        private void OnEnable()
        {
            if (this.target == null)
            {
                return;
            }

            var serObj = this.serializedObject;
            this.bloomEnabledLevels = 
                serObj.FindProperty("bloomEnabledLevels");
            this.colorCurveEnabledLevels = 
                serObj.FindProperty("colorCurveEnabledLevels");
            this.saturationEnabledLevels = 
                serObj.FindProperty("saturationEnabledLevels");
            this.vignetteEnabledLevels = 
                serObj.FindProperty("vignetteEnabledLevels");
        }
    }
}
