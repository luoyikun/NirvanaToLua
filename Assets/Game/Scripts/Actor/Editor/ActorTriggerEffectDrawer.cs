//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for <see cref="ActorTriggerEffect"/>.
/// </summary>
[CustomPropertyDrawer(typeof(ActorTriggerEffect))]
public class ActorTriggerEffectDrawer : PropertyDrawer
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
        var effectAsset = property.FindPropertyRelative("effectAsset");
        var playAtTarget = property.FindPropertyRelative("playAtTarget");
        var referenceNode = property.FindPropertyRelative("referenceNode");
        var isAttach = property.FindPropertyRelative("isAttach");
        var isRotation = property.FindPropertyRelative("isRotation");
        var stopEvent = property.FindPropertyRelative("stopEvent");

        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(rectLine, eventName);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, delay);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, effectAsset);

        rectLine.y += 4 * EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, playAtTarget);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, referenceNode);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, isAttach);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, isRotation);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, stopEvent);

        EditorGUI.EndProperty();
    }

    /// <inheritdoc/>
    public override float GetPropertyHeight(
        SerializedProperty property, GUIContent label)
    {
        return 11 * EditorGUIUtility.singleLineHeight;
    }
}
