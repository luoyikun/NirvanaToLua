//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

/// <summary>
/// Used to trigger a camera animation when animation event triggered.  
/// </summary>
[Serializable]
public sealed class ActorTriggerCameraFOV : ActorTriggerBase
{
    [SerializeField]
    [Tooltip("The camera field of view change.")]
    private float filedOfView = -5;

    [SerializeField]
    [Tooltip("The camera fov fade in time.")]
    private float duration = 0.5f;

    private Camera mainCamera;
    private CameraFollow cameraFollow;
    private float fadeTime;

    public float FiledOfView { get { return filedOfView; } }

    public float Duration { get { return duration; } }
    /// <inheritdoc/>
    public override void UpdateTrigger()
    {
        // base.UpdateTrigger();
        // if (this.mainCamera == null || this.cameraFollow == null)
        // {
        //     return;
        // }

        // if (this.fadeTime >= 0.0f)
        // {
        //     this.fadeTime += Time.deltaTime;
        //     var k = this.fadeTime / this.duration;
        //     this.cameraFollow.FieldOfView = Mathf.Lerp(
        //         this.cameraFollow.FieldOfView, this.filedOfView, k);

        //     if (this.fadeTime >= this.duration)
        //     {
        //         this.fadeTime = -1.0f;
        //     }
        // }
    }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        this.mainCamera = Camera.main;
        if (this.mainCamera != null && this.mainCamera.isActiveAndEnabled)
        {
            this.cameraFollow = this.mainCamera.GetComponentInParent<CameraFollow>();
            this.fadeTime = 0.0f;
        }
    }
}
