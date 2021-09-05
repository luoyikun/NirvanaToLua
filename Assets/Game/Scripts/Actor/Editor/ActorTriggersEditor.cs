//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana.Editor;
using UnityEditor;
using UnityEditorInternal;

/// <summary>
/// The editor for <see cref="ActorTriggers"/>
/// </summary>
[CustomEditor(typeof(ActorTriggers))]
public class ActorTriggersEditor : Editor
{
    private SerializedProperty effects;
    private SerializedProperty halts;
    private SerializedProperty sounds;
    private SerializedProperty cameraShakes;
    private SerializedProperty cameraFOVs;
    private SerializedProperty sceneFades;
    private SerializedProperty footsteps;

    private ReorderableList effectList;
    private ReorderableList haltList;
    private ReorderableList soundList;
    private ReorderableList cameraShakeList;
    private ReorderableList cameraFOVList;
    private ReorderableList sceneFadeList;
    private ReorderableList footstepList;

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();
        this.effectList.DoLayoutList();
        this.haltList.DoLayoutList();
        this.soundList.DoLayoutList();
        this.cameraShakeList.DoLayoutList();
        this.cameraFOVList.DoLayoutList();
        this.sceneFadeList.DoLayoutList();
        this.footstepList.DoLayoutList();
        this.serializedObject.ApplyModifiedProperties();
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        // Access all properties.
        this.effects = this.serializedObject.FindProperty("effects");
        this.halts = this.serializedObject.FindProperty("halts");
        this.sounds = this.serializedObject.FindProperty("sounds");
        this.cameraShakes = this.serializedObject.FindProperty("cameraShakes");
        this.cameraFOVs = this.serializedObject.FindProperty("cameraFOVs");
        this.sceneFades = this.serializedObject.FindProperty("sceneFades");
        this.footsteps = this.serializedObject.FindProperty("footsteps");

        // Create list editor.
        this.effectList = new ReorderableList(
            this.serializedObject, this.effects);
        this.effectList.SetupListFoldable("Effects:");

        this.haltList = new ReorderableList(
            this.serializedObject, this.halts);
        this.haltList.SetupListFoldable("Halts:");

        this.soundList = new ReorderableList(
            this.serializedObject, this.sounds);
        this.soundList.SetupListFoldable("Sounds:");

        this.cameraShakeList = new ReorderableList(
            this.serializedObject, this.cameraShakes);
        this.cameraShakeList.SetupListFoldable("Camera Shakes:");

        this.cameraFOVList = new ReorderableList(
            this.serializedObject, this.cameraFOVs);
        this.cameraFOVList.SetupListFoldable("Camera FOVs:");

        this.sceneFadeList = new ReorderableList(
            this.serializedObject, this.sceneFades);
        this.sceneFadeList.SetupListFoldable("Scene Fades:");

        this.footstepList = new ReorderableList(
            this.serializedObject, this.footsteps);
        this.footstepList.SetupListFoldable("Footsteps:");
    }
}
