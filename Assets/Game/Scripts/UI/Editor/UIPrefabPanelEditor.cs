//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEditor;

[CustomEditor(typeof(UIPrefabPanel))]
public class UIPrefabPanelEditor : Editor
{
    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        EditorGUI.BeginChangeCheck();
        this.DrawDefaultInspector();
        if (EditorGUI.EndChangeCheck())
        {
            var panel = (UIPrefabPanel)this.target;
            panel.Refresh();
        }
    }
}
