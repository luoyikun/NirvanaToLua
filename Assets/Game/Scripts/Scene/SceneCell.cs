//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The scene cell used by this game.
/// </summary>
[Serializable]
public sealed class SceneCell : AbstractSceneCell
{
    [SerializeField]
    [Tooltip("The ground type for this cell.")]
    private GroundType ground = GroundType.Walkable;

    /// <summary>
    /// The collision type of this cell.只能0-9的类型无法再扩张了
    /// </summary>
    public enum GroundType
    {
        /// <summary>
        /// This cell is block.
        /// 禁止行走区域
        /// </summary>
        Block = 0,

        /// <summary>
        /// This cell is walkable.
        /// 可行走区域
        /// </summary>
        Walkable = 1,

        /// <summary>
        /// This cell is safety area.
        /// 安全区
        /// </summary>
        Safety = 2,

        /// <summary>
        /// The obstacle cell but support find way.
        /// 障碍区域寻路
        /// </summary>
        ObstacleWay = 3,

        /// <summary>
        /// The cell is water.
        /// 水区域
        /// </summary>
        Water = 4,

        /// <summary>
        /// The road for path finding.
        /// </summary>
        Road = 5,

        /// <summary>
        /// 水波纹区域
        /// </summary>
        WaterRipple = 6,

        Tunnel = 7,

        Border = 8,

        HighArea = 9,
    }

    /// <summary>
    /// Gets or sets the ground type of this cell.
    /// </summary>
    public GroundType Ground
    {
        get { return this.ground; }
        set { this.ground = value; }
    }
}

#endif
