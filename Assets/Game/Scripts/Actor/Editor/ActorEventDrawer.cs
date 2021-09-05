//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The property drawer for the property tag ActorEventAttribute.
/// </summary>
[CustomPropertyDrawer(typeof(ActorEventAttribute))]
public class ActorEventDrawer : PropertyDrawer
{
    public static readonly string[] eventNames = new string[]
    {
        "[none]",
        "die",
        "footstep/left",
        "footstep/right",

        "mountstep/1",
        "mountstep/2",
        "mountstep/3",
        "mountstep/4",    

        "attack1/begin",
        "attack1/hit",
        "attack1/end",

        "attack2/begin",
        "attack2/hit",
        "attack2/end",

        "attack3/begin",
        "attack3/hit",
        "attack3/end",

        "attack4/begin",
        "attack4/hit",
        "attack4/end",

        "attack5/begin",
        "attack5/hit",
        "attack5/end",

        "attack6/begin",
        "attack6/hit",
        "attack6/end",

        "attack7/begin",
        "attack7/hit",
        "attack7/end",

        "attack8/begin",
        "attack8/hit",
        "attack8/end",

        "attack9/begin",
        "attack9/hit",
        "attack9/end",

        "attack10/begin",
        "attack10/hit",
        "attack10/end",

        "attack11/begin",
        "attack11/hit",
        "attack11/end",

        "attack12/begin",
        "attack12/hit",
        "attack12/end",

        "attack13/begin",
        "attack13/hit",
        "attack13/end",

        "attack14/begin",
        "attack14/hit",
        "attack14/end",

        "attack15/begin",
        "attack15/hit",
        "attack15/end",

        "magic1_1/begin",
        "magic1_1/end",
        "magic1_2/begin",
        "magic1_2/end",
        "magic1_3/begin",
        "magic1_3/end",
        "magic1_3/hit",

        "magic2_1/begin",
        "magic2_1/end",
        "magic2_2/begin",
        "magic2_2/end",
        "magic2_3/begin",
        "magic2_3/end",
        "magic2_3/hit",

        "combo1_1/begin",
        "combo1_1/hit",
        "combo1_1/end",

        "combo1_2/begin",
        "combo1_2/hit",
        "combo1_2/end",

        "combo1_3/begin",
        "combo1_3/hit",
        "combo1_3/end",

        "combo2_1/begin",
        "combo2_1/hit",
        "combo2_1/end",

        "combo2_2/begin",
        "combo2_2/hit",
        "combo2_2/end",

        "combo2_3/begin",
        "combo2_3/hit",
        "combo2_3/end",

        "combo3_1/begin",
        "combo3_1/hit",
        "combo3_1/end",

        "combo3_2/begin",
        "combo3_2/hit",
        "combo3_2/end",

        "combo3_3/begin",
        "combo3_3/hit",
        "combo3_3/end",

    };

    public static readonly string[] projectileEventNames = new string[] {
        "attack1",
        "attack2",
        "attack3",
        "attack4",
        "attack5",
        "attack6",
        "attack7",
        "attack8",
        "attack9",
        "attack10",
        "attack11",
        "attack12",
        "attack13",
        "attack14",
        "attack15",
        "magic1_1",
        "magic1_2",
        "magic1_3",
        "magic2_1",
        "magic2_2",
        "magic2_3",
        "combo1_1",
        "combo1_2",
        "combo1_3",
        "combo2_1",
        "combo2_2",
        "combo2_3",
        "combo3_1",
        "combo3_2",
        "combo3_3",

    };
    /// <inheritdoc/>
    public override void OnGUI(
        Rect rect, SerializedProperty property, GUIContent label)
    {
        int index = ArrayUtility.IndexOf(eventNames, property.stringValue);
        EditorGUI.BeginChangeCheck();
        index = EditorGUI.Popup(rect, property.displayName, index, eventNames);
        if (EditorGUI.EndChangeCheck())
        {
            property.stringValue = eventNames[index];
        }
    }
}
