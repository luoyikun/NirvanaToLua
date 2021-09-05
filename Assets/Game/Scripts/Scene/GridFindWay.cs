//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine.Assertions;
using SevenZip.Compression.LZMA;
using UnityEngine;

/// <summary>
/// The grid for find way.
/// </summary>
public sealed class GridFindWay
{
    private int width;
    private int height;
    private byte[] blocks;
    private int blockSize;
    private byte[] dynamicBlocks;
    private int dynamicBlockSize;

    private GridCell[] cells;
    private int cellSize;

    private Decoder decoder;

    private Queue<int> openList = new Queue<int>();

    private int endX;
    private int endY;
    private List<GridPoint> inflexPoints = new List<GridPoint>();

    /// <summary>
    /// Gets the row of the grid.
    /// </summary>
    public int Width
    {
        get { return this.width; }
    }

    /// <summary>
    /// Gets the column of the grid.
    /// </summary>
    public int Height
    {
        get { return this.height; }
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="GridFindWay"/> class with
    /// preallocated width and height.
    /// </summary>
    public GridFindWay(int width, int height)
    {
        var size = width * height;

        this.cellSize = size;
        this.cells = new GridCell[this.cellSize];

        this.blockSize = size;
        this.blocks = new byte[this.blockSize];

        this.dynamicBlockSize = size;
        this.dynamicBlocks = new byte[this.dynamicBlockSize];
    }

    /// <summary>
    /// Load the level data.
    /// </summary>
    public void LoadData(int width, int height, string mask)
    {
        // Decompress the mask.
        var compress = Convert.FromBase64String(mask);
        using (var compressStream = new MemoryStream())
        using (var decompressStream = new MemoryStream())
        {
            compressStream.Write(compress, 0, compress.Length);
            compressStream.Position = 0;
            if (this.decoder == null)
            {
                this.decoder = new Decoder();
            }

            var properties = new byte[5];
            if (compressStream.Read(properties, 0, 5) != 5)
            {
                throw (new Exception("input .lzma is too short"));
            }

            this.decoder.SetDecoderProperties(properties);
            this.decoder.Code(
                compressStream, 
                decompressStream, 
                compressStream.Length, 
                -1, 
                null);
            decompressStream.Flush();
            Assert.AreEqual(width * height, decompressStream.Length);

            this.blockSize = (int)decompressStream.Length;
            if (this.blocks == null ||
                this.blockSize > this.blocks.Length)
            {
                this.blocks = new byte[decompressStream.Length];
            }

            decompressStream.Seek(0, SeekOrigin.Begin);
            decompressStream.Read(this.blocks, 0, this.blockSize);

            // Record the data.
            this.width = width;
            this.height = height;
            
            this.dynamicBlockSize = width * height;
            if (this.dynamicBlocks == null || 
                this.dynamicBlockSize > this.dynamicBlocks.Length)
            {
                this.dynamicBlocks = new byte[this.dynamicBlockSize];
            }

            this.cellSize = width * height;
            if (this.cells == null ||
                this.cellSize > this.cells.Length)
            {
                this.cells = new GridCell[width * height];
            }

            // Setup the cell table.
            for (int x = 0; x < width; ++x)
            {
                for (int y = 0; y < height; ++y)
                {
                    int index = x + y * width;
                    this.cells[index].Index = index;
                    this.cells[index].X = x;
                    this.cells[index].Y = y;
                }
            }
        }
    }

    /// <summary>
    /// Try to find a way from start position to end position.
    /// </summary>
    public bool FindWay(int startX, int startY, int endX, int endY, bool ignoreHighArea)
    {
        if (startX < 0 || startX >= this.width ||
            startY < 0 || startY >= this.height)
        {
            return false;
        }

        if (endX < 0 || endX >= this.width ||
            endY < 0 || endY >= this.height)
        {
            return false;
        }

        if(startX == endX && startY == endY)
        {
            return false;
        }

        if (this.IsBlock(startX, startY, ignoreHighArea) || this.IsBlock(endX, endY, ignoreHighArea))
        {
            return false;
        }

        this.endX = endX;
        this.endY = endY;
        this.ResetAStar();

        var cellIndex = startX + startY * this.width;
        for (int i = 0; i < 1000000; ++i)
        {
            this.cells[cellIndex].Block = true;
            var cell = this.cells[cellIndex];

            if (this.DoAStar(cell, endX, endY, 1, 0, 0, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, 0, 1, 1, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, -1, 0, 2, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, 0, -1, 3, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, -1, 1, 4, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, 1, 1, 5, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, 1, -1, 6, ignoreHighArea))
            {
                return true;
            }

            if (this.DoAStar(cell, endX, endY, -1, -1, 7, ignoreHighArea))
            {
                return true;
            }

            bool cantFind = true;
            for (int j = 0; j < 10000; ++j)
            {
                if (this.openList.Count <= 0)
                {
                    break;
                }

                var nextOpen = this.openList.Dequeue();
                var nextCell = this.cells[nextOpen];
                if (!nextCell.Block)
                {
                    cellIndex = nextOpen;
                    cantFind = false;
                    break;
                }
            }

            if (cantFind)
            {
                return false;
            }
        }

        return false;
    }

    /// <summary>
    /// Generate the inflex points.
    /// </summary>
    /// <param name="range"></param>
    public void GenerateInflexPoints(int range)
    {
        this.inflexPoints.Clear();

        var curIndex = this.endX + this.endY * this.width;
        if (range > 0)
        {
            var lastIndex = curIndex;
            for (int i = 0; i < 10000; ++i)
            {
                if (curIndex < 0)
                {
                    break;
                }

                var curCell = this.cells[curIndex];
                var disX = curCell.X - this.endX;
                var disY = curCell.Y - this.endY;
                if (range * range < disX * disX + disY * disY)
                {
                    break;
                }

                lastIndex = curIndex;
                curIndex = curCell.Parent;
            }

            curIndex = lastIndex;
        }

        var curDir = -1;
        for (int i = 1; i < 10000; ++i)
        {
            if (curIndex < 0)
            {
                break;
            }

            var curCell = this.cells[curIndex];
            if (curCell.Dir != curDir)
            {
                this.inflexPoints.Add(new GridPoint(curCell.X, curCell.Y));
                curDir = curCell.Dir;
            }

            curIndex = curCell.Parent;
        }

        for (int i = 0; i < this.inflexPoints.Count - 2;)
        {
            var p1 = this.inflexPoints[i];
            var p3 = this.inflexPoints[i + 2];
            if (this.IsWayLine(p1.X, p1.Y, p3.X, p3.Y))
            {
                this.inflexPoints[i + 1] = new GridPoint(-1, -1);
                i += 2;
            }
            else
            {
                ++i;
            }
        }

        this.inflexPoints.RemoveAll(p => p.X < 0 || p.Y < 0);
    }

    /// <summary>
    /// Gets the path length.
    /// </summary>
    public int GetPathLenth()
    {
        return this.inflexPoints.Count;
    }

    /// <summary>
    /// Gets the path point at specify index.
    /// </summary>
    public void GetPathPoint(int index, out int x, out int y)
    {
        var p = this.inflexPoints[this.inflexPoints.Count - 1 - index];
        x = p.X;
        y = p.Y;
    }

    /// <summary>
    /// Check whether the specify position is water.
    /// </summary>
    public bool IsWaterWay(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return false;
        }

        var index = x + y * this.width;
        var cell = this.blocks[index];
        if (cell == (int)GridCellType.Water)
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// Check whether the specify position is blocked.
    /// </summary>
    public bool IsBlock(int x, int y, bool ignoreHighArea = false)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return true;
        }

        var index = x + y * this.width;
        if (this.dynamicBlocks[index] > 0)
        {
            return true;
        }

        var cell = this.blocks[index];

        return cell == (int)GridCellType.Obstacle ||
            cell == (int)GridCellType.ObstacleWay ||
            cell == (int)GridCellType.Border ||
            (!ignoreHighArea && cell == (int)GridCellType.HighArea);
    }

    /// <summary>
    /// Check whether the specify position is ObstacleWay.
    /// </summary>
    public bool IsObstacleWay(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return true;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.ObstacleWay;
    }

    /// <summary>
    /// Check whether the specify position is a safe area.
    /// </summary>
    public bool IsInSafeArea(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return true;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.Safe;
    }

    /// <summary>
    /// 检测位置是否水波纹区域
    /// </summary>
    public bool IsWaterRipple(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return false;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.WaterRipple;
    }

    public bool IsTunnelArea(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return false;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.Tunnel;
    }

    public bool IsBorder(int x, int y)
    {
        // 可以飞出边界
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return false;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.Border;
    }

    public bool IsHighArea(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return true;
        }

        var index = x + y * this.width;
        return this.blocks[index] == (int)GridCellType.HighArea;
    }

    /// <summary>
    /// Find the closest point from target that can stand.
    /// </summary>
    public void GetTargetXY(
        int x,
        int y,
        int endX,
        int endY,
        int range,
        out int targetX,
        out int targetY,
        out int targetRange)
    {
        var deltaPosX = x - endX;
        var deltaPosY = y - endY;

        var distanceSqr = deltaPosX * deltaPosX + deltaPosY * deltaPosY;
        if (distanceSqr <= range * range)
        {
            targetX = x;
            targetY = y;
            targetRange = 0;
            return;
        }

        targetX = endX;
        targetY = endY;
        targetRange = range;
        var distance = Math.Sqrt(distanceSqr);
        var normalizeX = deltaPosX / distance;
        var normalizeY = deltaPosY / distance;

        for (int i = 1; i < range; ++i)
        {
            var tx = (int)Math.Round(endX + normalizeX * i);
            var ty = (int)Math.Round(endY + normalizeY * i);
            if (this.IsBlock(tx, ty))
            {
                break;
            }

            targetX = tx;
            targetY = ty;
            targetRange = range - i;
        }
    }

    /// <summary>
    /// Gets the line end.
    /// </summary>
    public void GetLineEndXY(
        int x,
        int y,
        int endX,
        int endY,
        out int targetX,
        out int targetY,
        bool ignoreHighArea = false)
    {
        var deltaPosX = endX - x;
        var deltaPosY = endY - y;

        var distanceSqr = deltaPosX * deltaPosX + deltaPosY * deltaPosY;
        if (distanceSqr <= 0)
        {
            targetX = x;
            targetY = y;
            return;
        }

        targetX = x;
        targetY = y;
        var distance = Math.Sqrt(distanceSqr);
        var normalizeX = deltaPosX / distance;
        var normalizeY = deltaPosY / distance;

        for (int i = 1; i < distance; ++i)
        {
            var tx = (int)Math.Round(x + normalizeX * i);
            var ty = (int)Math.Round(y + normalizeY * i);
            if (this.IsBlock(tx, ty, ignoreHighArea))
            {
                break;
            }

            targetX = tx;
            targetY = ty;
        }
    }

    /// <summary>
    /// Gets the line end.
    /// </summary>
    public void GetLineEndXY2(
        int x,
        int y,
        int endX,
        int endY,
        out int targetX,
        out int targetY,
        bool ignoreHighArea = false)
    {
        var deltaPosX = x - endX;
        var deltaPosY = y - endY;

        var distanceSqr = deltaPosX * deltaPosX + deltaPosY * deltaPosY;
        if (distanceSqr <= 0)
        {
            targetX = x;
            targetY = y;
            return;
        }

        targetX = x;
        targetY = y;
        var distance = Math.Sqrt(distanceSqr);
        var normalizeX = deltaPosX / distance;
        var normalizeY = deltaPosY / distance;

        for (int i = 0; i < distance; ++i)
        {
            var tx = (int)Math.Round(endX + normalizeX * i);
            var ty = (int)Math.Round(endY + normalizeY * i);
            if (!this.IsBlock(tx, ty, ignoreHighArea))
            {
                targetX = tx;
                targetY = ty;
                break;
            }
        }
    }

    /// <summary>
    /// Whether can walk directly.
    /// </summary>
    public bool IsWayLine(int x, int y, int endX, int endY, bool ignoreHighArea = false)
    {
        if (this.IsBlock(endX, endY, ignoreHighArea))
        {
            return false;
        }

        var deltaPosX = endX - x;
        var deltaPosY = endY - y;

        var distanceSqr = deltaPosX * deltaPosX + deltaPosY * deltaPosY;
        if (distanceSqr <= 0)
        {
            return true;
        }

        var distance = Math.Sqrt(distanceSqr);
        var normalizeX = deltaPosX / distance;
        var normalizeY = deltaPosY / distance;

        for (int i = 1; i < distance; ++i)
        {
            var tx = (int)Math.Round(x + normalizeX * i);
            var ty = (int)Math.Round(y + normalizeY * i);
            //var cellType = this.GetCellType(tx, ty);
            if (this.IsBlock(tx, ty, ignoreHighArea))
            {
                return false;
            }
        }

        return true;
    }

    /// <summary>
    /// Set the dynamic block cell.
    /// cell_type 2 参数用来设置禁止行走但允许寻路之类的情况
    /// </summary>
    public void SetBlock(int x, int y, int cell_type = 0)
    {
        var cellIndex = x + y * this.width;
        if (this.dynamicBlocks == null ||
            cellIndex < 0 ||
            cellIndex >= this.dynamicBlockSize)
        {
            return;
        }
        if (cell_type == 2)
        {
            this.dynamicBlocks[cellIndex] = 2;
        }
        else
        {
            this.dynamicBlocks[cellIndex] = 1;
        }
    }

    /// <summary>
    /// Revert the dynamic block cell.
    /// </summary>
    public void RevertBlock(int x, int y)
    {
        var cellIndex = x + y * this.width;
        if (this.dynamicBlocks == null ||
            cellIndex < 0 ||
            cellIndex >= this.dynamicBlockSize)
        {
            return;
        }

        this.dynamicBlocks[cellIndex] = 0;
    }

    private void ResetAStar()
    {
        this.openList.Clear();
        for (int i = 0; i < this.cellSize; ++i)
        {
            this.cells[i].G = 0;
            this.cells[i].H = 0;
            this.cells[i].Block = false;
            this.cells[i].Parent = -1;
            this.cells[i].Dir = -1;
        }
    }

    private bool DoAStar(
        GridCell cell,
        int endX,
        int endY,
        int offsetX,
        int offsetY,
        int nextDir,
        bool ignoreHighArea)
    {
        int x = cell.X + offsetX;
        int y = cell.Y + offsetY;

        // Check the new (x,y) is not beyond the board.
        if (x < 0 || x > this.width || y < 0 || y > this.height)
        {
            return false;
        }

        // Check not the blocked, and not in the close list.
        var cellType = this.GetCellType(x, y);
        if (cellType == GridCellType.Obstacle || (!ignoreHighArea && cellType == GridCellType.HighArea))
        {
            return false;
        }

        int nextIndex = x + y * this.width;
        var nextCell = this.cells[nextIndex];
        if (nextCell.Block)
        {
            return false;
        }

        if (x == endX && y == endY)
        {
            nextCell.Parent = cell.Index;
            nextCell.Dir = nextDir;
            this.cells[nextIndex] = nextCell;
            return true;
        }

        // Calculate the G: cost from start point to thie cell.
        var g = cell.G;
        if (cellType == GridCellType.Road)
        {
            g += 10000;
        }
        else
        {
            g += 15000;
        }

        if (nextCell.G == 0 || nextCell.G > g)
        {
            // Update the g and parent.
            nextCell.G = g;
            nextCell.Dir = nextDir;
            nextCell.Parent = cell.Index;
            if (nextCell.H == 0)
            {
                nextCell.H = 10000 * Manhattan(x, y, endX, endY);
            }

            this.cells[nextIndex] = nextCell;
            this.openList.Enqueue(nextIndex);
        }

        return false;
    }

    /// <summary>
    /// Calculate the H.
    /// </summary>
    private static int Manhattan(int x, int y, int endX, int endY)
    {
        return (int)(Math.Abs(endX - x) + Math.Abs(endY - y));
    }

    /// <summary>
    /// Gets the cell type.
    /// </summary>
    public GridCellType GetCellType(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return GridCellType.Obstacle;
        }

        var index = x + y * this.width;
        if (this.dynamicBlocks[index] == 1)
        {
            return GridCellType.Obstacle;
        }
        else if (this.dynamicBlocks[index] == 2)
        {
            return GridCellType.ObstacleWay;
        }

        return (GridCellType)this.blocks[index];
    }

    /// <summary>
    /// Check whether the specify position is blocked.
    /// </summary>
    public bool IsBlockFindWay(int x, int y)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return true;
        }

        var index = x + y * this.width;
        if (this.dynamicBlocks[index] == 1)
        {
            return true;
        }

        return this.blocks[index] == (int)GridCellType.Obstacle;
    }

    /// <summary>
    /// 获取格子类型是否相等(根据传进来的类型)
    /// </summary>
    public bool GetCellTypeIsSame(int x, int y, int cell_type = 0)
    {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height)
        {
            return false;
        }

        var index = x + y * this.width;
        return this.blocks[index] == cell_type;
    }

    // 寻找最近的一个合法的坐标
    public void FindNearestValidPoint(int x, int y, int range, out int out_x, out int out_y)
    {
        if (!IsBlock(x, y))
        {
            out_x = x;
            out_y = y;
            return;
        }

        for (int i = 1; i <= range; ++i)
        {
            if (IsValidPos(x, y, 1, 0, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, 1, 1, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, 0, 1, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, -1, 0, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, -1, -1, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, 0, -1, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, 1, -1, i, out out_x, out out_y))
                return;
            if (IsValidPos(x, y, -1, 1, i, out out_x, out out_y))
                return;
        }

        out_x = x;
        out_y = y;
    }

    private bool IsValidPos(int x, int y, int offsetX, int offsetY, int index, out int out_x, out int out_y)
    {
        out_x = offsetX * index + x;
        out_y = offsetY * index + y;
        return !IsBlock(out_x, out_y);
    }
}
