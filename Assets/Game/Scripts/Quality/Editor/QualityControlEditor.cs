//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana.Editor
{
    using UnityEditor;
    using UnityEditorInternal;
    using UnityEngine;

    /// <summary>
    /// The editor for <see cref="QualityConfig"/>
    /// </summary>
    [CustomEditor(typeof(QualityConfig))]
    public class QualityConfigEditor : Editor
    {
        private QualityConfig qualityConfig;
        private SerializedProperty levels;
        private ReorderableList levelList;

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
            if (this.qualityConfig != null)
            {
                var levelCount = this.qualityConfig.GetLevelCount();
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

            // Draw the editor.
            this.serializedObject.Update();
            this.levelList.DoLayoutList();
            if (this.levelList.index != -1 && this.levels.arraySize > 0)
            {
                var selected = this.levels.GetArrayElementAtIndex(
                this.levelList.index);
                if (selected != null)
                {
                    GUILayoutEx.BeginContents();
                    this.OnDrawQualityLevel(selected);
                    GUILayoutEx.EndContents();

                    if (GUILayout.Button("Active"))
                    {
                        var config = (QualityConfig)this.target;
                        var level = config.GetLevel(this.levelList.index);
                        if (level != null)
                        {
                            level.Active();
                        }
                    }
                }
            }

            this.serializedObject.ApplyModifiedProperties();
        }

        private void OnEnable()
        {
            if (this.target == null)
            {
                return;
            }

            this.levels = this.serializedObject.FindProperty("levels");

            this.levelList = new ReorderableList(
                this.serializedObject, this.levels);
            this.levelList.drawHeaderCallback += 
                rect => GUI.Label(rect, "Quality List:");
            this.levelList.drawElementCallback +=
                (rect, index, isActive, isFocused) =>
                {
                    var element = this.levels.GetArrayElementAtIndex(index);
                    GUI.Label(rect, element.displayName);
                };
        }

        private void OnDrawQualityLevel(SerializedProperty property)
        {
            var name = property.FindPropertyRelative("name");
            EditorGUILayout.PropertyField(name);
            EditorGUILayout.Space();

            GUILayout.Label("Rendering", EditorStyles.boldLabel);
            this.OnDrawQualityRendering(property);
            EditorGUILayout.Space();

            GUILayout.Label("Shadows", EditorStyles.boldLabel);
            this.OnDrawQualityShadows(property);
            EditorGUILayout.Space();

            GUILayout.Label("Others", EditorStyles.boldLabel);
            this.OnDrawQualityOthers(property);
            EditorGUILayout.Space();
        }

        private void OnDrawQualityRendering(SerializedProperty property)
        {
            var pixelLightCount =
                property.FindPropertyRelative("pixelLightCount");
            var masterTextureLimit =
                property.FindPropertyRelative("masterTextureLimit");
            var anisotropicFiltering =
                property.FindPropertyRelative("anisotropicFiltering");
            var antiAliasing =
                property.FindPropertyRelative("antiAliasing");
            var softParticles =
                property.FindPropertyRelative("softParticles");
            var softVegetation =
                property.FindPropertyRelative("softVegetation");
            var realtimeReflectionProbes =
                property.FindPropertyRelative("realtimeReflectionProbes");
            var billboardsFaceCameraPosition =
                property.FindPropertyRelative("billboardsFaceCameraPosition");
            
            EditorGUILayout.PropertyField(pixelLightCount);
            EditorGUILayout.PropertyField(masterTextureLimit);
            EditorGUILayout.PropertyField(anisotropicFiltering);
            EditorGUILayout.PropertyField(antiAliasing);
            EditorGUILayout.PropertyField(softParticles);
            if (softParticles.boolValue)
            {
                this.SoftParticlesHintGUI();
            }

            EditorGUILayout.PropertyField(softVegetation);
            EditorGUILayout.PropertyField(realtimeReflectionProbes);
            EditorGUILayout.PropertyField(billboardsFaceCameraPosition);
        }

        private void OnDrawQualityShadows(SerializedProperty property)
        {
            var shadows =
                property.FindPropertyRelative("shadows");
            var shadowResolution =
                property.FindPropertyRelative("shadowResolution");
            var shadowProjection =
                property.FindPropertyRelative("shadowProjection");
            var shadowDistance =
                property.FindPropertyRelative("shadowDistance");
            var shadowNearPlaneOffset =
                property.FindPropertyRelative("shadowNearPlaneOffset");
            var shadowCascades =
                property.FindPropertyRelative("shadowCascades");
            var shadowCascade2Split =
                property.FindPropertyRelative("shadowCascade2Split");
            var shadowCascade4Split =
                property.FindPropertyRelative("shadowCascade4Split");

            EditorGUILayout.PropertyField(shadows);
            if (shadows.enumValueIndex != (int)ShadowQuality.Disable)
            {
                EditorGUILayout.PropertyField(shadowResolution);
                EditorGUILayout.PropertyField(shadowProjection);
                EditorGUILayout.PropertyField(shadowDistance);
                EditorGUILayout.PropertyField(shadowNearPlaneOffset);
                EditorGUILayout.PropertyField(shadowCascades);
                if (shadowCascades.intValue == 2)
                {
                    EditorGUILayout.PropertyField(shadowCascade2Split);
                }
                else if (shadowCascades.intValue == 4)
                {
                    EditorGUILayout.PropertyField(shadowCascade4Split);
                }
            }
        }

        private void OnDrawQualityOthers(SerializedProperty property)
        {
            var blendWeights =
                property.FindPropertyRelative("blendWeights");
            var vSyncCount =
                property.FindPropertyRelative("vSyncCount");
            var lodBias =
                property.FindPropertyRelative("lodBias");
            var maximumLODLevel =
                property.FindPropertyRelative("maximumLODLevel");
            var particleRaycastBudget =
                property.FindPropertyRelative("particleRaycastBudget");
            var maxQueuedFrames =
                property.FindPropertyRelative("maxQueuedFrames");
            var asyncUploadTimeSlice =
                property.FindPropertyRelative("asyncUploadTimeSlice");
            var asyncUploadBufferSize =
                property.FindPropertyRelative("asyncUploadBufferSize");

            EditorGUILayout.PropertyField(blendWeights);
            EditorGUILayout.PropertyField(vSyncCount);
            EditorGUILayout.PropertyField(lodBias);
            EditorGUILayout.PropertyField(maximumLODLevel);
            EditorGUILayout.PropertyField(particleRaycastBudget);
            EditorGUILayout.PropertyField(maxQueuedFrames);
            EditorGUILayout.PropertyField(asyncUploadTimeSlice);
            EditorGUILayout.PropertyField(asyncUploadBufferSize);
        }

        private void SoftParticlesHintGUI()
        {
            Camera main = Camera.main;
            if (main != null)
            {
                var actualRenderingPath = main.actualRenderingPath;
                if (actualRenderingPath != RenderingPath.DeferredLighting && 
                    actualRenderingPath != RenderingPath.DeferredShading)
                {
                    if ((main.depthTextureMode & DepthTextureMode.Depth) == DepthTextureMode.None)
                    {
                        EditorGUILayout.HelpBox(
                            "Soft Particles require using Deferred Lighting or making camera render the depth texture.", 
                            MessageType.Warning, 
                            false);
                    }
                }
            }
        }
    }
}
