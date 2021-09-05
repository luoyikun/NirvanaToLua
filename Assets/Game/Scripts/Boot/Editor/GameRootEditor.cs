//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(GameRoot))]
public class GameRootEditor : Editor
{
    public override void OnInspectorGUI()
    {
        this.DrawDefaultInspector();
        if (Application.isPlaying)
        {
            if (GUILayout.Button("Reduce Memory"))
            {
                var root = (GameRoot)this.target;
                root.ReduceMemory();
            }
        }
    }
}
