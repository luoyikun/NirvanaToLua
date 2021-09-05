//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;

/// <summary>
/// The interface to get the actor target.
/// </summary>
public interface IActorTarget
{
    /// <summary>
    /// Gets the actor target.
    /// </summary>
    Transform Target { get; }
}
