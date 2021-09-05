//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

/// <summary>
/// The editor for <see cref="ActorFadeout"/>
/// </summary>
[CustomEditor(typeof(ActorFadeout))]
public sealed class ActorFadeoutEditor : Editor
{
    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.DrawDefaultInspector();
        if (Application.isPlaying)
        {
            if (GUILayout.Button("Fadeout"))
            {
                var fadeout = (ActorFadeout)this.target;
                fadeout.Fadeout(2.0f, null);
            }
        }
    }
}

