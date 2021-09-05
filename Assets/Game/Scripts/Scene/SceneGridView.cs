//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

/// <summary>
/// The scene grid view for edit.
/// </summary>
public sealed class SceneGridView : AbstractSceneGrid
{
    [SerializeField]
    [Tooltip("The cell list of this grid.")]
    private SceneCell[] cells;

    /// <inheritdoc/>
    public override AbstractSceneCell[] Cells
    {
        get
        {
            return this.cells;
        }

        set
        {
            this.cells = value.Cast<AbstractSceneCell, SceneCell>();
        }
    }

    /// <inheritdoc/>
    public override AbstractSceneCell CreateCell()
    {
        return new SceneCell();
    }
}

#endif
