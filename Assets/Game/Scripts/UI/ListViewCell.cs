//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using EnhancedUI.EnhancedScroller;

public sealed class ListViewCell : EnhancedScrollerCellView
{
    public RefreshCell refreshCell;

    public delegate void RefreshCell();

    public override void RefreshCellView()
    {
        this.refreshCell();
    }
}
