//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for <see cref="ActorController.ProjectileData"/>.
/// </summary>
[CustomPropertyDrawer(typeof(ActorController.ProjectileData))]
public class ActorProjectileDrawer : PropertyDrawer
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
        var hurtPosition = property.FindPropertyRelative("HurtPosition");
        var projectile = property.FindPropertyRelative("Projectile");
        var fromPosition = property.FindPropertyRelative("FromPosition");

        var rectLine = new Rect(
            rect.x,
            rect.y,
            rect.width,
            EditorGUIUtility.singleLineHeight);
        EditorGUI.PropertyField(rectLine, action);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, hurtPosition);

        rectLine.y += EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, projectile);

        rectLine.y += 4 * EditorGUIUtility.singleLineHeight;
        EditorGUI.PropertyField(rectLine, fromPosition);

        EditorGUI.EndProperty();
    }

    /// <inheritdoc/>
    public override float GetPropertyHeight(
        SerializedProperty property, GUIContent label)
    {
        return 7 * EditorGUIUtility.singleLineHeight;
    }
}
