//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using EnhancedUI.EnhancedScroller;

public sealed class ListViewDelegate : IEnhancedScrollerDelegate
{
    public delegate int NumberOfCellsDelegate();

    public delegate int CellViewSizeDelegate(int dataIndex);

    public delegate EnhancedScrollerCellView CellViewDelegate(
        EnhancedScroller scroller, int dataIndex, int cellIndex);

    public NumberOfCellsDelegate numberOfCellsDel;
    public CellViewSizeDelegate cellViewSizeDel;
    public CellViewDelegate cellViewDel;

    /// <inheritdoc/>
    public int GetNumberOfCells(EnhancedScroller scroller)
    {
        return this.numberOfCellsDel();
    }

    /// <inheritdoc/>
    public float GetCellViewSize(EnhancedScroller scroller, int dataIndex)
    {
        return this.cellViewSizeDel(dataIndex);
    }

    /// <inheritdoc/>
    public EnhancedScrollerCellView GetCellView(EnhancedScroller scroller, int dataIndex, int cellIndex)
    {
        return this.cellViewDel(scroller, dataIndex, cellIndex);
    }
}
