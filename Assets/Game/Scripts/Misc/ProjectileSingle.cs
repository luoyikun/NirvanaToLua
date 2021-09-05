//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

public sealed class ProjectileSingle : Projectile
{
    [SerializeField]
    private float speed = 5.0f;

    [SerializeField]
    private float acceleration = 10.0f;

    [SerializeField]
    private AnimationCurve moveXCurve = AnimationCurve.Linear(0.0f, 1.0f, 1.0f, 1.0f);

    [SerializeField]
    private float moveXMultiplier = 0.0f;

    [SerializeField]
    private AnimationCurve moveYCurve = AnimationCurve.Linear(0.0f, 1.0f, 1.0f, 1.0f);

    [SerializeField]
    private float moveYMultiplier = 0.0f;

    [SerializeField]
    private EffectControl hitEffect;

    [SerializeField]
    private bool hitEffectWithRotation = true;

    private Vector3 sourceScale;
    private Transform target;
    private int layer;
    private Action hited;
    private Action complete;

    private Vector3 startPosition;
    private Vector3 normalPosition;
    private float currentSpeed;

    private EffectControl effect;
    private Vector3 targetPosition;

    /// <inheritdoc/>
    public override void Play(
        Vector3 sourceScale, 
        Transform target, 
        int layer, 
        Action hited, 
        Action complete)
    {
        this.sourceScale = sourceScale;
        this.target = target;
        this.layer = layer;
        this.hited = hited;
        this.complete = complete;

        this.startPosition = this.transform.position;
        this.normalPosition = this.transform.position;
        this.currentSpeed = this.speed;

        if (this.effect != null)
        {
            this.effect.Reset();
            this.effect.Play();
        }
    }

    private void Awake()
    {
        this.effect = this.GetComponent<EffectControl>();
    }

    public void Update()
    {
        if (this.hited == null && this.complete == null)
        {
            return;
        }

        if (this.target != null)
        {
            this.targetPosition = this.target.position;
        }

        // Acceleration
        this.currentSpeed += this.acceleration * Time.deltaTime;

        // Movement
        var offset = this.targetPosition - this.normalPosition;
        var total = targetPosition - this.startPosition;
        var radio = 1.0f - offset.magnitude / total.magnitude;

        var direction = offset.normalized;
        var velocity = direction * this.currentSpeed;

        var movement = velocity * Time.deltaTime;
        if (movement.sqrMagnitude >= offset.sqrMagnitude)
        {
            this.transform.position = this.targetPosition;
            if (this.hitEffect != null)
            {
                if (EventDispatcher.Instance != null)
                {
                    EventDispatcher.Instance.OnProjectileSingleEffect(hitEffect, this.transform.position, this.transform.rotation, this.hitEffectWithRotation, this.sourceScale, this.layer);
                }
                else
                {
                    this.effect = null;
                }
            }

            if (this.hited != null)
            {
                var hited = this.hited;
                this.hited = null;
                hited();
            }

            if (this.complete != null)
            {
                var complete = this.complete;
                this.complete = null;
                complete();
            }
        }
        else
        {
            this.normalPosition += movement;
            var movementPosition = this.normalPosition;
            var movementUp = Vector3.up;
            var movementRight = Vector3.Cross(direction, movementUp);

            if (!Mathf.Approximately(this.moveXMultiplier, 0.0f))
            {
                var moveX =
                    this.moveXMultiplier * this.moveXCurve.Evaluate(radio);
                movementPosition += movementRight * moveX;
            }

            if (!Mathf.Approximately(this.moveYMultiplier, 0.0f))
            {
                var moveY =
                    this.moveYMultiplier * this.moveYCurve.Evaluate(radio);
                movementPosition += movementUp * moveY;
            }

            this.transform.position = movementPosition;
            this.transform.LookAt(targetPosition);
        }
    }
}
