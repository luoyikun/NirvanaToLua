//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// Move follow the target.
/// </summary>
public sealed class FollowTarget : MonoBehaviour
{
    [SerializeField]
    private Transform target;

    [SerializeField]
    private AnimationCurve speedCurve;

    [SerializeField]
    private float speed = 1.0f;

    [SerializeField]
    private AnimationCurve jumpCurve;

    [SerializeField]
    private float jumpHeight = 1.0f;

    private Action complete;
    private Vector3 normalPosition;
    private float time;

    /// <summary>
    /// Follow to the target.
    /// </summary>
    public void Follow(Transform target, Action complete)
    {
        this.target = target;
        this.time = 0.0f;
        this.normalPosition = this.transform.position;
        this.complete = complete;
    }

    private void OnEnable()
    {
        this.time = 0.0f;
    }

    private void Update()
    {
        if (this.target == null)
        {
            return;
        }

        this.time += Time.deltaTime;
        var jump = this.jumpHeight * this.jumpCurve.Evaluate(this.time);
        var speed = this.speed * this.speedCurve.Evaluate(this.time);

        var offset = this.target.position - this.transform.position;
        var velocity = offset.normalized * speed;

        var movement = velocity * Time.deltaTime;
        if (offset.sqrMagnitude > movement.sqrMagnitude)
        {
            this.normalPosition += movement;
            this.transform.position = new Vector3(
                this.normalPosition.x,
                this.normalPosition.y + jump, 
                this.normalPosition.z);
        }
        else
        {
            this.transform.position = this.target.position;
            if (this.complete != null)
            {
                this.complete();
            }
        }
    }
}
