//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using Nirvana.Editor;
using UnityEditor;
using UnityEngine;

/// <summary>
/// The walkable mode for scene grid editor.
/// </summary>
public class SceneGridGroundMode : ISceneGridMode
{
    private static readonly Color32 ColorWalkable =
        new Color32(0, 128, 0, 96);

    private static readonly Color32 ColorBlock =
        new Color32(128, 0, 0, 96);

    private static readonly Color32 ColorSafty =
        new Color32(0, 0, 128, 96);

    private static readonly Color32 ColorObstacleWay =
        new Color32(192, 128, 0, 168);

    private static readonly Color32 ColorWater =
        new Color32(0, 0, 128, 168);

    private static readonly Color32 ColorRoadWay =
        new Color32(0, 128, 128, 168);

    private static readonly Color32 ColorTunnel =
        new Color32(0, 48, 48, 225);

    private static readonly Color32 ColorBorder =
        new Color32(0, 225, 0, 225);

    private static readonly Color32 ColorHighArea =
        new Color32(225, 45, 0, 225);

    private static readonly Color32 ColorWaterRipple =
        new Color32(51, 195, 255, 225);

    private static SceneCell.GroundType ground =
        SceneCell.GroundType.Walkable;

    private static SceneBrushShape brushShape =
        SceneBrushShape.Rect;

    private static int brushSize = 3;

    public float focusX;
    public float focusY;

    private SceneCellBrush brush =
        new SceneCellBrush();

    /// <summary>
    /// Initializes a new instance of the <see cref="SceneGridGroundMode"/> class.
    /// </summary>
    public SceneGridGroundMode()
    {
        this.brush.BrushShape = brushShape;
        this.brush.BrushSize = brushSize;
    }

    /// <inheritdoc/>
    public Color GetCellColor(AbstractSceneCell cell)
    {
        return GetCollisionColor(cell as SceneCell);
    }

    /// <inheritdoc/>
    public void FocusPosition(AbstractSceneGrid grid, Vector3 position)
    {
        this.brush.FocusPosition(grid, position);

        this.focusX = (int)(position.x / grid.CellSize.x);
        this.focusY = (int)(position.z / grid.CellSize.y);
    }

    public void IncBrushSize(int incSize)
    {
        this.brush.IncBrushSize(incSize);
    }

    /// <inheritdoc/>
    public void DrawBrush(AbstractSceneGrid grid)
    {
        this.brush.DrawBrush(grid);
    }

    /// <inheritdoc/>
    public void PaintCell(AbstractSceneGrid grid)
    {
        this.brush.PaintCell(
            grid,
            (i, j) =>
            {
                var cell = grid.GetCell(i, j) as SceneCell;
                cell.Ground = ground;
                grid.SetCellColor(i, j, GetCollisionColor(cell));
            });
    }

    /// <inheritdoc/>
    public void OnInspectorGUI()
    {
        GUILayout.Label("Brush Shape: ");
        this.brush.OnInspectorGUI();
        brushShape = this.brush.BrushShape;
        EditorGUILayout.Space();

        ground = (SceneCell.GroundType)
            EditorGUILayout.EnumPopup("Ground", ground);
    }

    public void OnSceneGUI()
    {
        if (Event.current.type == EventType.KeyDown)
        {
            if (Event.current.keyCode == (KeyCode.Alpha0))
            {
                ground = SceneCell.GroundType.Block;
            }

            if (Event.current.keyCode == (KeyCode.Alpha9))
            {
                ground = SceneCell.GroundType.Walkable;
            }

            if (Event.current.keyCode == (KeyCode.Alpha8))
            {
                ground = SceneCell.GroundType.Safety;
            }
        }
    }

    /// <summary>
    /// Get the collision color in editor show.
    /// </summary>
    private static Color32 GetCollisionColor(SceneCell cell)
    {
        switch (cell.Ground)
        {
        case SceneCell.GroundType.Walkable:
            return ColorWalkable;
        case SceneCell.GroundType.Block:
            return ColorBlock;
        case SceneCell.GroundType.Safety:
            return ColorSafty;
        case SceneCell.GroundType.ObstacleWay:
            return ColorObstacleWay;
        case SceneCell.GroundType.Water:
			return ColorWater;
		case SceneCell.GroundType.Road:
			return ColorRoadWay;
        case SceneCell.GroundType.Tunnel:
            return ColorTunnel;
        case SceneCell.GroundType.Border:
            return ColorBorder;
        case SceneCell.GroundType.HighArea:
            return ColorHighArea;
        case SceneCell.GroundType.WaterRipple:
            return ColorWaterRipple;
            default:
            return new Color32(0, 0, 0, 1);
        }
    }
}
