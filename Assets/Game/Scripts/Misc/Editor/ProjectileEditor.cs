//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana.Editor;
using UnityEditor;
using UnityEngine;

/// <summary>
/// The editor for <see cref="Projectile"/>
/// </summary>
[CustomEditor(typeof(Projectile), true)]
public class ProjectileEditor : Editor
{
    private GameObject testHurtPoint;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (Application.isPlaying)
        {
            if (GUILayout.Button("Play"))
            {
                var projectile = (Projectile)this.target;
                projectile.Play(
                    testHurtPoint.transform.lossyScale,
                    this.testHurtPoint.transform,
                    testHurtPoint.layer,
                    () => { }, 
                    () => { });
            }
        }
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        if (PrefabType.Prefab != PrefabUtility.GetPrefabType(this.target))
        {
            if (this.testHurtPoint == null)
            {
                var projectile = this.target as Projectile;

                this.testHurtPoint = new GameObject("Test Hurt Point");
                this.testHurtPoint.hideFlags = 
                    HideFlags.HideInInspector | HideFlags.DontSave;
                this.testHurtPoint.transform.localPosition = 
                    projectile.transform.position + (7.0f * Vector3.forward);
                IconManager.SetIcon(
                    this.testHurtPoint, IconManager.LabelIcon.Red);
            }
        }
    }

    private void OnDisable()
    {
        if (this.testHurtPoint != null)
        {
            if (Application.isPlaying)
            {
                GameObject.Destroy(this.testHurtPoint);
            }
            else
            {
                GameObject.DestroyImmediate(this.testHurtPoint);
            }

            this.testHurtPoint = null;
        }
    }

    private void OnSceneGUI()
    {
        // Control Hurt Point
        this.testHurtPoint.transform.position = Handles.PositionHandle(
            this.testHurtPoint.transform.position, this.testHurtPoint.transform.rotation);
    }
}
