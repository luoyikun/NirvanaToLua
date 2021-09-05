//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

/// <summary>
/// The grid cell type.只能0-9的类型无法再扩张了
/// </summary>
public enum GridCellType
{
    /// <summary>
    /// The cell is obstacle.
    /// </summary>
    Obstacle = 0,

    /// <summary>
    /// The cell is a way.
    /// </summary>
    Way = 1,

    /// <summary>
    /// The cell is a safe area.
    /// 安全区
    /// </summary>
    Safe = 2,

    /// <summary>
    /// The obstacle cell but support find way.
    /// 障碍区域寻路
    /// </summary>
    ObstacleWay = 3,

    ///<summary>
    /// The cell is water.
    /// 水区域
    ///</summary>
    Water = 4,

    /// <summary>
    /// The road for path finding.
    /// </summary>
    Road = 5,

    /// <summary>
    /// 场景水区域显示人物水波纹
    /// </summary>
    WaterRipple = 6,

    Tunnel = 7,

    Border = 8,

    HighArea = 9,
}
