//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// Editor for the <see cref="SceneLightSwitch"/>.
/// </summary>
[CustomEditor(typeof(SceneLightSwitch))]
public sealed class SceneLightSwitchEditor : Editor
{
    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.DrawDefaultInspector();

        var lightSwitch = (SceneLightSwitch)this.target;
        if (GUILayout.Button("暖色"))
        {
            lightSwitch.ActiveWarm();
        }

        if (GUILayout.Button("冷色"))
        {
            lightSwitch.ActiveCool();
        }
    }
}
