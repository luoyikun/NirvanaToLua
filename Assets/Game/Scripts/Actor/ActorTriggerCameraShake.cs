//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

/// <summary>
/// Used to trigger camera shake when animation event triggered.  
/// </summary>
[Serializable]
public sealed class ActorTriggerCameraShake : ActorTriggerBase
{
    [SerializeField]
    [Tooltip("The camera shake duration.")]
    private float duration = 0.25f;

    [SerializeField]
    [Tooltip("The camera shake intensity.")]
    private Vector3 intensity = new Vector3(0.0f, 0.25f, 0.25f);

    [SerializeField]
    [Tooltip("The damper for this shake.")]
    private AnimationCurve damper = AnimationCurve.Linear(
        0.0f, 1.0f, 1.0f, 0.0f);

    public float Duration { get { return duration; } }

    public Vector3 Intensity { get { return intensity; } }

    public AnimationCurve Damper { get { return damper; } }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        if (Camera.main != null && Camera.main.isActiveAndEnabled)
        {
            //var shake = Camera.main.GetOrAddComponent<CameraShake>();
            //CameraShake.Shake(this.duration, this.intensity, this.damper);
        }
    }
}
