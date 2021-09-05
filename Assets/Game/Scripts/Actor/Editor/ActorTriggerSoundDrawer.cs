//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for <see cref="ActorTriggerSound"/>.
/// </summary>
[CustomPropertyDrawer(typeof(ActorTriggerSound))]
public class ActorTriggerSoundDrawer : PropertyDrawer
{
    /// <inheritdoc/>
    public override void OnGUI(
        Rect rect, SerializedProperty property, GUIContent label)
    {
        // Using BeginProperty / EndProperty on the parent property means 
        // that prefab override logic works on the entire property.
        EditorGUI.BeginProperty(rect, label, property);

        // Find properties.
        var eventName = property.FindPropertyRelative("eventName");
        var delay = property.FindPropertyRelative("delay");
        var audioAsset = property.FindPropertyRelative("audioAsset");

        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(rectLine, eventName);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, delay);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, audioAsset);

        EditorGUI.EndProperty();
    }

    /// <inheritdoc/>
    public override float GetPropertyHeight(
        SerializedProperty property, GUIContent label)
    {
        return 6 * EditorGUIUtility.singleLineHeight;
    }
}
