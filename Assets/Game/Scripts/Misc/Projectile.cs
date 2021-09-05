//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// The projectile.
/// </summary>
public abstract class Projectile : MonoBehaviour
{
    /// <summary>
    /// Play this projectile.
    /// </summary>
    public abstract void Play(
        Vector3 sourceScale,
        Transform target,
        int layer,
        Action hited,
        Action complete);
}
