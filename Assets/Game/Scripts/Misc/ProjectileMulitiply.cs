//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

public sealed class ProjectileMulitiply : Projectile
{
    [SerializeField]
    private ProjectileObject[] projectileObjects;

    private Transform target;
    private Vector3 targetPosition;
    private Action hited;
    private Action complete;

    /// <inheritdoc/>
    public override void Play(
        Vector3 sourceScale,
        Transform target,
        int layer,
        Action hited,
        Action complete)
    {
        if (this.complete != null)
        {
            complete();
            return;
        }

        this.target = target;
        this.hited = hited;
        this.complete = complete;
        foreach (var projectileObj in this.projectileObjects)
        {
            projectileObj.Play(
                sourceScale, this.transform.position, layer);
        }
    }

    public void Update()
    {
        if (this.complete == null)
        {
            return;
        }

        if (this.target != null)
        {
            this.targetPosition = this.target.position;
        }

        bool isComplete = true;
        foreach (var projectileObj in this.projectileObjects)
        {
            projectileObj.Update(this.targetPosition);
            if (projectileObj.Playing)
            {
                isComplete = false;
            }
            else
            {
                if (this.hited != null)
                {
                    this.hited();
                    this.hited = null;
                }
            }
        }

        if (isComplete)
        {
            this.complete();
            this.complete = null;
        }
    }
}
