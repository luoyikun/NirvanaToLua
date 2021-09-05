//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

/// <summary>
/// The point for a grid point.
/// </summary>
public struct GridPoint
{
    /// <summary>
    /// Initializes a new instance of the <see cref="GridPoint"/> struct.
    /// </summary>
    public GridPoint(int x, int y)
    {
        this.X = x;
        this.Y = y;
    }

    /// <summary>
    /// Gets or sets the x axis point.
    /// </summary>
    public int X { get; set; }

    /// <summary>
    /// Gets or sets the y axis point.
    /// </summary>
    public int Y { get; set; }
}
