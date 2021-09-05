//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ActorAttachEffect))]
public sealed class ActorAttachEffectEditor : Editor
{
    public override void OnInspectorGUI()
    {
        this.DrawDefaultInspector();

        if (Application.isPlaying)
        {
            if (GUILayout.Button("Play"))
            {
                ActorAttachEffect attach_effect = (ActorAttachEffect)this.target;
                attach_effect.PlayEffect();
            }
        }
    }
}

