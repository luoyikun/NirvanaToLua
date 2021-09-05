//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using Nirvana.Editor;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

/// <summary>
/// The editor for <see cref="ActorController"/>
/// </summary>
[CustomEditor(typeof(ActorController))]
public class ActorControllerEditor : Editor
{
    private static readonly string[] LocomotionEnum = new string[] {
        "Normal", "Fly", "Mount" };
    private static readonly string[] StatusEnum = new string[] {
        "Idle", "Move", "Death" };
    private static Vector3? targetPosition;

    private SerializedProperty projectiles;
    private SerializedProperty hurts;
    private SerializedProperty areaCollider;
    private SerializedProperty beHurtEffecct;
    private SerializedProperty beHurtPosition;
    private SerializedProperty beHurtAttach;

    private ReorderableList projectileList;
    private ReorderableList hurtList;

    private GameObject targetPoint;

    private GameObject TargetPoint
    {
        get
        {
            if (this.targetPoint == null)
            {
                this.targetPoint = new GameObject("Target Point");
                this.targetPoint.hideFlags = 
                    HideFlags.HideInHierarchy | HideFlags.HideInInspector;
                if (targetPosition.HasValue)
                {
                    this.targetPoint.transform.position = targetPosition.Value;
                }
            }

            return this.targetPoint;
        }
    }

    /// <inheritdoc/>
    public override void OnInspectorGUI()
    {
        this.serializedObject.Update();
        this.projectileList.DoLayoutList();
        this.hurtList.DoLayoutList();
        EditorGUILayout.PropertyField(this.areaCollider);
        EditorGUILayout.PropertyField(this.beHurtEffecct);
        EditorGUILayout.PropertyField(this.beHurtPosition);
        EditorGUILayout.PropertyField(this.beHurtAttach);
        this.serializedObject.ApplyModifiedProperties();

        var controller = (ActorController)this.target;
        if (controller.isActiveAndEnabled)
        {
            GUILayout.Label("Preview:");
            GUILayoutEx.BeginContents();
            if (Application.isPlaying)
            {
                this.DrawPreviewGUI();
            }
            else
            {
                GUILayout.Label("You must preview in playing mode.");
            }

            GUILayoutEx.EndContents();
        }
    }

    private void DrawPreviewGUI()
    {
        var controller = this.target as ActorController;
        var animator = controller.GetComponent<Animator>();
        controller.Target = this.TargetPoint.transform;

        this.DrawPreviewStatus(controller, animator);

        var animatorCtrl = animator.runtimeAnimatorController;
        var overrideController = animatorCtrl as AnimatorOverrideController;
        if (overrideController == null)
        {
            EditorGUILayout.HelpBox(
                "The animator controller is error.",
                MessageType.Error);
        }
        else
        {
            this.DrawPreviewAttack(controller, animator, overrideController);
            this.DrawPreviewCombo(controller, animator, overrideController);
            this.DrawPreviewMagic(controller, animator, overrideController);
        }
    }

    private void DrawPreviewStatus(
        ActorController controller, Animator animator)
    {
        // Locomotion status.
        int locomotion = 0;
        if (animator.GetLayerWeight(1) > 0.5f)
        {
            locomotion = 1;
        }
        if (animator.GetLayerWeight(2) > 0.5f)
        {
            locomotion = 2;
        }

        if (animator.layerCount >= 5)
        {
            EditorGUI.BeginChangeCheck();
            int layer = GUILayout.Toolbar(locomotion, LocomotionEnum);
            if (EditorGUI.EndChangeCheck())
            {
                switch (layer)
                {
                case 0:
                    animator.SetLayerWeight(0, 1.0f);
                    animator.SetLayerWeight(1, 0.0f);
                    animator.SetLayerWeight(2, 0.0f);
                    break;
                case 1:
                    animator.SetLayerWeight(1, 1.0f);
                    animator.SetLayerWeight(2, 0.0f);
                    break;
                case 2:
                    animator.SetLayerWeight(2, 1.0f);
                    break;
                }
            }
        }

        // Actor speed.
        EditorGUI.BeginChangeCheck();
        // Status control.
        EditorGUI.BeginChangeCheck();
        var status = animator.GetInteger("status");
        status = GUILayout.Toolbar(status, StatusEnum);
        if (EditorGUI.EndChangeCheck())
        {
            animator.SetInteger("status", status);
        }

        EditorGUILayout.BeginHorizontal();
        bool fight = animator.GetBool("fight");
        EditorGUI.BeginChangeCheck();
        fight = GUILayout.Toggle(fight, "fight");
        if (EditorGUI.EndChangeCheck())
        {
            animator.SetBool("fight", fight);
        }

        if (GUILayout.Button("Death Fly"))
        {
            animator.SetTrigger("death_fly");
            animator.SetInteger("status", 2);
        }

        if (GUILayout.Button("Death Immediately"))
        {
            animator.SetTrigger("death_imm");
            animator.SetInteger("status", 2);
        }

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Jump"))
        {
            animator.SetTrigger("jump");
        }

        if (GUILayout.Button("Jump2"))
        {
            animator.SetTrigger("jump2");
        }

        if (animator.GetBool("jump1_ctrl"))
        {
            if (GUILayout.Button("Jump1 End"))
            {
                animator.SetBool("jump1_ctrl", false);
            }
        }
        else
        {
            if (GUILayout.Button("Jump1 Start"))
            {
                animator.SetBool("jump1_ctrl", true);
            }
        }

        if (animator.GetBool("jump2_ctrl"))
        {
            if (GUILayout.Button("Jump2 End"))
            {
                animator.SetBool("jump2_ctrl", false);
            }
        }
        else
        {
            if (GUILayout.Button("Jump2 Start"))
            {
                animator.SetBool("jump2_ctrl", true);
            }
        }

        EditorGUILayout.EndHorizontal();
        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Hurt & Blink"))
        {
            animator.SetTrigger("hurt");
            controller.PlayBeHurt();
            controller.Blink();
        }

        EditorGUILayout.EndHorizontal();
    }

    private void DrawPreviewAttack(
        ActorController controller, 
        Animator animator, 
        AnimatorOverrideController overrideController)
    {
        GUILayout.BeginHorizontal();
        this.DrawAttack(controller, animator, overrideController, 1);
        this.DrawAttack(controller, animator, overrideController, 2);
        this.DrawAttack(controller, animator, overrideController, 3);
        this.DrawAttack(controller, animator, overrideController, 4);
        this.DrawAttack(controller, animator, overrideController, 5);
        this.DrawAttack(controller, animator, overrideController, 6);
        this.DrawAttack(controller, animator, overrideController, 7);
        this.DrawAttack(controller, animator, overrideController, 8);
        this.DrawAttack(controller, animator, overrideController, 9);
        this.DrawAttack(controller, animator, overrideController, 10);
        this.DrawAttack(controller, animator, overrideController, 11);
        this.DrawAttack(controller, animator, overrideController, 12);
        this.DrawAttack(controller, animator, overrideController, 13);
        this.DrawAttack(controller, animator, overrideController, 14);
        this.DrawAttack(controller, animator, overrideController, 15);
        GUILayout.EndHorizontal();
    }

    private void DrawAttack(
        ActorController controller,
        Animator animator,
        AnimatorOverrideController overrideController,
        int index)
    {
        var defaultAttack = string.Format("d_attack{0}", index);
        if (overrideController[defaultAttack])
        {
            var hasAttack = overrideController[defaultAttack].name != defaultAttack;
            if (!hasAttack)
            {
                return;
            }
        }

        var triggerName = string.Format("attack{0}", index);
        if (GUILayout.Button(string.Format("Attack{0}", index)))
        {
            animator.SetBool("fight", true);
            var eventName = string.Format("attack{0}/hit", index);
            this.PlayAction(controller, animator, triggerName, eventName);
        }
    }

    private void DrawPreviewCombo(
        ActorController controller,
        Animator animator,
        AnimatorOverrideController overrideController)
    {
        this.DrawCombo(controller, animator, overrideController, 1);
        this.DrawCombo(controller, animator, overrideController, 2);
        this.DrawCombo(controller, animator, overrideController, 3);
    }

    private void DrawCombo(
        ActorController controller,
        Animator animator,
        AnimatorOverrideController overrideController,
        int index)
    {
        var defaultCombo1 = string.Format("d_combo{0}_1", index);
        var defaultCombo2 = string.Format("d_combo{0}_2", index);
        var defaultCombo3 = string.Format("d_combo{0}_3", index);

        var hasCombo1 = overrideController[defaultCombo1].name != defaultCombo1;
        var hasCombo2 = overrideController[defaultCombo2].name != defaultCombo2;
        var hasCombo3 = overrideController[defaultCombo3].name != defaultCombo3;
        if (!hasCombo1 && !hasCombo2 && !hasCombo3)
        {
            return;
        }

        var triggerName1 = string.Format("combo{0}_1", index);
        var triggerName2 = string.Format("combo{0}_2", index);
        var triggerName3 = string.Format("combo{0}_3", index);
        var eventName1 = string.Format("combo{0}_1/hit", index);
        var eventName2 = string.Format("combo{0}_2/hit", index);
        var eventName3 = string.Format("combo{0}_3/hit", index);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button(string.Format("Combo{0}", index)))
        {
            animator.SetBool("fight", true);
            if (hasCombo1)
            {
                this.PlayAction(controller, animator, triggerName1, eventName1);
            }

            if (hasCombo2)
            {
                this.PlayAction(controller, animator, triggerName2, eventName2);
            }

            if (hasCombo3)
            {
                this.PlayAction(controller, animator, triggerName3, eventName3);
            }
        }

        GUI.enabled = hasCombo1;
        if (GUILayout.Button(string.Format("Combo{0}_1", index)))
        {
            animator.SetBool("fight", true);
            this.PlayAction(controller, animator, triggerName1, eventName1);
        }

        GUI.enabled = hasCombo2;
        if (GUILayout.Button(string.Format("Combo{0}_2", index)))
        {
            animator.SetBool("fight", true);
            this.PlayAction(controller, animator, triggerName2, eventName2);
        }

        GUI.enabled = hasCombo3;
        if (GUILayout.Button(string.Format("Combo{0}_3", index)))
        {
            animator.SetBool("fight", true);
            this.PlayAction(controller, animator, triggerName3, eventName3);
        }

        GUI.enabled = true;
        GUILayout.EndHorizontal();
    }

    private void DrawPreviewMagic(
        ActorController controller,
        Animator animator,
        AnimatorOverrideController overrideController)
    {
        this.DrawMagic(controller, animator, overrideController, 1);
        this.DrawMagic(controller, animator, overrideController, 2);
    }

    private void DrawMagic(
        ActorController controller,
        Animator animator,
        AnimatorOverrideController overrideController,
        int index)
    {
        var defaultMagic1 = string.Format("d_magic{0}_1", index);
        var defaultMagic2 = string.Format("d_magic{0}_2", index);
        var defaultMagic3 = string.Format("d_magic{0}_3", index);

        var magic1Clip = overrideController[defaultMagic1];
        var magic2Clip = overrideController[defaultMagic2];
        var magic3Clip = overrideController[defaultMagic3];
        if (!magic1Clip || !magic2Clip || !magic3Clip)
        {
            return;
        }

        var hasMagic1 = overrideController[defaultMagic1].name != defaultMagic1;
        var hasMagic2 = overrideController[defaultMagic2].name != defaultMagic2;
        var hasMagic3 = overrideController[defaultMagic3].name != defaultMagic3;
        if (!hasMagic1 || !hasMagic2 || !hasMagic3)
        {
            return;
        }

        var triggerStartName = string.Format("magic{0}_1", index);
        var triggerReleaseName = string.Format("magic{0}_3", index);
        var eventName = string.Format("magic{0}_3/hit", index);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button(string.Format("Magic{0} Start", index)))
        {
            animator.SetBool("fight", true);
            animator.SetTrigger(triggerStartName);
        }

        if (GUILayout.Button(string.Format("Magic{0} Release", index)))
        {
            animator.SetTrigger(triggerReleaseName);
            animator.WaitEvent(
                eventName,
                (param, info) =>
                {
                    var target = this.TargetPoint.transform;
                    controller.PlayProjectile(
                        name,
                        target,
                        target,
                        () =>
                        {
                            if (controller != null)
                            {
                                controller.PlayHurtShow(
                                    name,
                                    target,
                                    target,
                                    () => { });
                            }
                        });
                });
        }

        GUI.enabled = true;
        GUILayout.EndHorizontal();
    }

    private void PlayAction(
        ActorController controller, 
        Animator animator, 
        string name, 
        string hitEvent)
    {
        animator.SetTrigger(name);
        animator.WaitEvent(
            hitEvent,
            (param, info) =>
            {
                var target = this.TargetPoint.transform;
                controller.PlayProjectile(
                    name,
                    target,
                    target, 
                    () =>
                    {
                        if (controller != null)
                        {
                            controller.PlayHurtShow(
                                name,
                                target,
                                target,
                                () => { });
                        }
                    });
            });
    }

    private void OnEnable()
    {
        if (this.target == null)
        {
            return;
        }

        // Access all property.
        this.projectiles =
            this.serializedObject.FindProperty("projectiles");
        this.hurts =
            this.serializedObject.FindProperty("hurts");
        this.areaCollider =
            this.serializedObject.FindProperty("areaCollider");
        this.beHurtEffecct =
            this.serializedObject.FindProperty("beHurtEffecct");
        this.beHurtPosition =
            this.serializedObject.FindProperty("beHurtPosition");
        this.beHurtAttach =
            this.serializedObject.FindProperty("beHurtAttach");

        // Create list editor.
        this.projectileList = new ReorderableList(
            this.serializedObject, this.projectiles);
        this.projectileList.SetupListFoldable("Projectiles:");

        this.hurtList = new ReorderableList(
            this.serializedObject, this.hurts);
        this.hurtList.SetupListFoldable("Hurts:");
    }

    private void OnDisable()
    {
        if (Application.isPlaying && this.targetPoint != null)
        {
            GameObject.Destroy(this.targetPoint);
            this.targetPoint = null;
        }
    }

    private void OnSceneGUI()
    {
        if (!targetPosition.HasValue)
        {
            var controller = (ActorController)this.target;
            var position = controller.transform.position + 
                (5.0f * Vector3.forward);
            targetPosition = position;
        }

        targetPosition = Handles.PositionHandle(
            targetPosition.Value, Quaternion.identity);
        Handles.Label(targetPosition.Value, "Target Point");
        if (this.targetPoint != null)
        {
            var transfrom = this.targetPoint.transform;
            transfrom.position = targetPosition.Value;
        }
    }
}
