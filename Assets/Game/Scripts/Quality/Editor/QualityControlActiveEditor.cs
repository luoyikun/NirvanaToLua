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
    /// The editor for <see cref="QualityControlActive"/>
    /// </summary>
    [CustomEditor(typeof(QualityControlActive))]
    public class QualityControlActiveEditor : Editor
    {
        private QualityConfig qualityConfig;
        private SerializedProperty controls;
        private ReorderableList controlList;

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
            this.controlList.DoLayoutList();
            this.serializedObject.ApplyModifiedProperties();
        }

        private void OnEnable()
        {
            if (this.target == null)
            {
                return;
            }

            var serObj = this.serializedObject;
            this.controls = serObj.FindProperty("controls");

            this.controlList = new ReorderableList(
                this.serializedObject, this.controls);
            this.controlList.elementHeight =
                3.5f * EditorGUIUtility.singleLineHeight;
            this.controlList.drawElementCallback +=
                (rect, index, isActive, isFocused) =>
                {
                    this.DrawControl(
                        this.controls, 
                        rect, 
                        index, 
                        isActive, 
                        isFocused);
                };
        }

        private void DrawControl(
            SerializedProperty property,
            Rect rect, 
            int index, 
            bool isActive, 
            bool isFocused)
        {
            var element = this.controls.GetArrayElementAtIndex(index);

            var target = element.FindPropertyRelative("Target");
            var enabledLevels = element.FindPropertyRelative("EnabledLevels");

            var rectLine = new Rect(
                rect.x,
                rect.y,
                rect.width,
                EditorGUIUtility.singleLineHeight);
            EditorGUI.PropertyField(rectLine, target, GUIContent.none);

            rectLine.y += EditorGUIUtility.singleLineHeight;
            if (this.qualityConfig == null)
            {
                var origin = GUI.color;
                GUI.color = Color.red;
                GUI.Label(rectLine, "Missing quality config.");
                GUI.color = origin;
            }
            else
            {
                int levelCount = this.qualityConfig.GetLevelCount();
                enabledLevels.arraySize = levelCount;

                float itemWidth = rectLine.width / levelCount;
                var rectItem = new Rect(
                    rectLine.x,
                    rectLine.y,
                    itemWidth,
                    EditorGUIUtility.singleLineHeight);
                // Draw the header.
                for (int i = 0; i < levelCount; ++i)
                {
                    var level = this.qualityConfig.GetLevel(i);
                    GUI.Label(rectItem, level.Name);
                    rectItem.x += itemWidth;
                }

                // Draw the toggle
                rectItem.y += EditorGUIUtility.singleLineHeight;
                rectItem.x = rectLine.x;
                for (int i = 0; i < levelCount; ++i)
                {
                    var levelEnabled = enabledLevels.GetArrayElementAtIndex(i);
                    levelEnabled.boolValue = GUI.Toggle(
                        rectItem, levelEnabled.boolValue, GUIContent.none);
                    rectItem.x += itemWidth;
                }
            }
        }
    }
}
