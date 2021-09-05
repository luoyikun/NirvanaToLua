//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

/// <summary>
/// The editor for <see cref="AttachObject"/>
/// </summary>
[CustomEditor(typeof(AttachObject))]
public class AttachObjectEditor : Editor
{
    private static readonly string[] ProfList =
        new string[] { "男剑士", "男琴师", "女双剑", "女枪炮", "其他" };

    private SerializedProperty physiqueConfig;
    private ReorderableList physiqueConfigList;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();
        this.physiqueConfigList.DoLayoutList();
        this.serializedObject.ApplyModifiedProperties();

        var attach = (AttachObject)this.target;
        var prefabType = PrefabUtility.GetPrefabType(attach);
        if (Application.isPlaying && prefabType != PrefabType.Prefab)
        {
            var newAttached = EditorGUILayout.ObjectField(
                "Attached: ", attach.Attached, typeof(Transform), true) as Transform;
            attach.Attached = newAttached;
            attach.LocalPosition = EditorGUILayout.Vector3Field(
                "Local Position", attach.LocalPosition);
            var eulerAngles = EditorGUILayout.Vector3Field(
                "Local Rotation", attach.LocalRotation.eulerAngles);
            attach.LocalRotation = Quaternion.Euler(eulerAngles);
        }
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        // Access all property.
        this.physiqueConfig = this.serializedObject.FindProperty("physiqueConfig");

        // Create list editor.

        this.physiqueConfigList = new ReorderableList(
            this.serializedObject, this.physiqueConfig);
        this.physiqueConfigList.drawHeaderCallback =
            rect => GUI.Label(rect, "职业缩放:");
        this.physiqueConfigList.elementHeight = 4 * EditorGUIUtility.singleLineHeight;
        this.physiqueConfigList.drawElementCallback =
            (rect, index, selected, focused) =>
            {
                var element = this.physiqueConfig.GetArrayElementAtIndex(index);
                var prof = element.FindPropertyRelative("Prof");
                var position = element.FindPropertyRelative("Position");
                var rotation = element.FindPropertyRelative("Rotation");
                var scale = element.FindPropertyRelative("Scale");

                // Start rect line.
                var rectLine = new Rect(
                    rect.x,
                    rect.y,
                    rect.width,
                    EditorGUIUtility.singleLineHeight);

                int profIndex;
                switch (prof.intValue)
                {
                case 1001:
                    profIndex = 0;
                    break;
                case 1002:
                    profIndex = 1;
                    break;
                case 1003:
                    profIndex = 2;
                    break;
                case 1004:
                    profIndex = 3;
                    break;
                default:
                    profIndex = 4;
                    break;
                }
                profIndex = EditorGUI.Popup(
                    rectLine, profIndex, ProfList);
                switch (profIndex)
                {
                case 0:
                    prof.intValue = 1001;
                    break;
                case 1:
                    prof.intValue = 1002;
                    break;
                case 2:
                    prof.intValue = 1003;
                    break;
                case 3:
                    prof.intValue = 1004;
                    break;
                default:
                    prof.intValue = 0;
                    break;
                }

                rectLine.y += EditorGUIUtility.singleLineHeight;
                EditorGUI.PropertyField(rectLine, position);

                rectLine.y += EditorGUIUtility.singleLineHeight;
                EditorGUI.PropertyField(rectLine, rotation);

                rectLine.y += EditorGUIUtility.singleLineHeight;
                EditorGUI.PropertyField(rectLine, scale);
            };
    }
}
