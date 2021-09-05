using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Fazhen))]
public class FazhenEditor : Editor
{
    public override void OnInspectorGUI()
    {
        this.DrawDefaultInspector();

        Fazhen fazhen = (Fazhen)this.target;

        if (GUILayout.Button("AccessSize"))
        {
            if (!fazhen.GetComponent<BoxCollider>())
            {
                fazhen.gameObject.AddComponent<BoxCollider>();
            }
        }

        if (GUILayout.Button("Play"))
        {
            fazhen.Play(5, 10);
        }
    }
}
