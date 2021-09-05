//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// Used to halt the time when animation event triggered.
/// </summary>
[Serializable]
public sealed class ActorTriggerHalt : ActorTriggerBase
{
    [SerializeField]
    [Tooltip("The halt time for this action.")]
    private float haltTime;

    [SerializeField]
    [Tooltip("The slow down rate for this action.")]
    private float slowDown;

    private float leftTime = -1.0f;

    /// <summary>
    /// Reset to normal.
    /// </summary>
    public void Reset()
    {
        Time.timeScale = 1.0f;
        this.leftTime = -1.0f;
    }

    public float HaltTime { get { return haltTime; } }

    public float SlowDown { get { return slowDown; } }

    public float LeftTime { get { return leftTime; } }

    /// <inheridoc/>
    public override void UpdateTrigger()
    {
        if (this.leftTime > 0.0f)
        {
            this.leftTime -= Time.unscaledDeltaTime;
            if (this.leftTime <= 0.0f)
            {
                Time.timeScale = 1.0f;
                this.leftTime = -1.0f;
            }
        }
    }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        if (this.haltTime > 0.0f)
        {
            this.leftTime = this.haltTime;
            Time.timeScale = this.slowDown;
        }
    }
}
