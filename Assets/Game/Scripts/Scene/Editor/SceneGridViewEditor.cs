//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana.Editor;
using UnityEditor;
using UnityEngine;

/// <summary>
/// Editor for the <see cref="SceneGridView"/>.
/// </summary>
[CustomEditor(typeof(SceneGridView))]
public class SceneGridViewEditor : SceneGridEditor
{
    private static readonly GUIContent[] ModeItems =
        new GUIContent[]
        {
            new GUIContent("Ground", "Switch into ground edit mode."),
        };

    private ModeType modeType = ModeType.GroundMode;
    private SceneGridGroundMode groundMode;

    /// <summary>
    /// The view type.
    /// </summary>
    public enum ModeType
    {
        /// <summary>
        /// Walkable edit mode.
        /// </summary>
        GroundMode,
    }

    /// <inheritdoc/>
    protected override ISceneGridMode EditMode
    {
        get
        {
            switch (this.modeType)
            {
                case ModeType.GroundMode:
                    if (this.groundMode == null)
                    {
                        this.groundMode = new SceneGridGroundMode();
                    }

                    return this.groundMode;
                default:
                    return null;
            }
        }
    }

    /// <inheritdoc/>
    protected override bool DrawEditMode()
    {
        var modeType = (ModeType)GUILayout.Toolbar(
            (int)this.modeType, ModeItems);
        if (modeType != this.modeType)
        {
            this.modeType = modeType;
            return true;
        }

        return false;
    }
}
