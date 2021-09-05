//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for <see cref="ActorTriggerSceneFade"/>.
/// </summary>
[CustomPropertyDrawer(typeof(ActorTriggerSceneFade))]
public class ActorTriggerSceneFadeDrawer : PropertyDrawer
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
        var color = property.FindPropertyRelative("color");
        var fadeIn = property.FindPropertyRelative("fadeIn");
        var hold = property.FindPropertyRelative("hold");
        var fadeOut = property.FindPropertyRelative("fadeOut");

        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(rectLine, eventName);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, delay);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, color);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, fadeIn);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hold);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, fadeOut);

        EditorGUI.EndProperty();
    }

    /// <inheritdoc/>
    public override float GetPropertyHeight(
        SerializedProperty property, GUIContent label)
    {
        return 6 * EditorGUIUtility.singleLineHeight;
    }
}
