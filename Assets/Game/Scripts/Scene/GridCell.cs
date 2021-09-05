//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

/// <summary>
/// The cell for the find way grid.
/// </summary>
public struct GridCell
{
    /// <summary>
    /// Gets or sets the point X of this cell.
    /// </summary>
    public int X;

    /// <summary>
    /// Gets or sets the point Y of this cell.
    /// </summary>
    public int Y;

    /// <summary>
    /// Gets or sets the index of this cell.
    /// </summary>
    public int Index;

    /// <summary>
    /// Gets or sets the cost from start point to this cell.
    /// </summary>
    public int G;

    /// <summary>
    /// Gets or sets the cost from this cell to end point.
    /// </summary>
    public int H;

    /// <summary>
    /// Gets or sets the block value(replace the close list).
    /// </summary>
    public bool Block;

    /// <summary>
    /// Gets or sets the direction of this node.
    /// </summary>
    public int Dir;

    /// <summary>
    /// Gets or sets the index of the parent node.
    /// </summary>
    public int Parent;
}
