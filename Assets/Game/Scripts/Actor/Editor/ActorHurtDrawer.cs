//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for <see cref="ActorController.HurtData"/>.
/// </summary>
[CustomPropertyDrawer(typeof(ActorController.HurtData))]
public class ActorHurtDrawer : PropertyDrawer
{
    /// <inheritdoc/>
    public override void OnGUI(
        Rect rect, SerializedProperty property, GUIContent label)
    {
        // Using BeginProperty / EndProperty on the parent property means 
        // that prefab override logic works on the entire property.
        EditorGUI.BeginProperty(rect, label, property);

        // Find properties.
        var action = property.FindPropertyRelative("Action");
        var hurtEffect = property.FindPropertyRelative("HurtEffect");
        var hurtPosition = property.FindPropertyRelative("HurtPosition");
        var hurtRotation = property.FindPropertyRelative("HurtRotation");
        var hitCount = property.FindPropertyRelative("HitCount");
        var hitInterval = property.FindPropertyRelative("HitInterval");
        var hitEffect = property.FindPropertyRelative("HitEffect");
        var hitPosition = property.FindPropertyRelative("HitPosition");
        var hitRotation = property.FindPropertyRelative("HitRotation");

        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(rectLine, action);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hurtEffect);

        rectLine.y += 4 * EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hurtPosition);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hurtRotation);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hitCount);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hitInterval);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hitEffect);

        rectLine.y += 4 * EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hitPosition);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hitRotation);

        EditorGUI.EndProperty();
    }

    /// <inheritdoc/>
    public override float GetPropertyHeight(
        SerializedProperty property, GUIContent label)
    {
        return 16 * EditorGUIUtility.singleLineHeight;
    }
}
