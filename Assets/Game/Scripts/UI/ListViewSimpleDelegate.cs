//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using EnhancedUI.EnhancedScroller;
using Nirvana;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// The simple interface for the list view with just one kind of cell.
/// </summary>
[RequireComponent(typeof(EnhancedScroller))]
public sealed class ListViewSimpleDelegate : MonoBehaviour, IEnhancedScrollerDelegate
{
    [SerializeField]
    [Tooltip("The cell prefab")]
    private ListViewCell cellPrefab;

    private EnhancedScroller scroller;
    private RectTransform cellPrefabRect;
#if UNITY_EDITOR
    private ListViewCell cellPreview;
#endif

    public delegate int NumberOfCellsDelegate();

    public delegate int CellSizeDelegate(int dataIndex);

    public delegate void CellRefreshDelegate(
        ListViewCell cell, int dataIndex, int cellIndex);

    public ListViewCell CellPrefab
    {
        get { return this.cellPrefab; }
        set { this.cellPrefab = value; }
    }

    public NumberOfCellsDelegate NumberOfCellsDel { get; set; }
    public CellSizeDelegate CellSizeDel { get; set; }
    public CellRefreshDelegate CellRefreshDel { get; set; }

    /// <inheritdoc/>
    public int GetNumberOfCells(EnhancedScroller scroller)
    {
        if(this.NumberOfCellsDel != null)
        {
            return this.NumberOfCellsDel();
        }

        return 0;
    }

    /// <inheritdoc/>
    public float GetCellViewSize(EnhancedScroller scroller, int dataIndex)
    {
        if(this.CellSizeDel != null)
        {
            try
            {
                return this.CellSizeDel(dataIndex);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        }

        if (this.cellPrefabRect != null)
        {
            if (this.scroller.scrollDirection == EnhancedScroller.ScrollDirectionEnum.Horizontal)
            {
                return this.cellPrefabRect.rect.width;
            }
            else
            {
                return this.cellPrefabRect.rect.height;
            }
        }

        return 10.0f;
    }

    /// <inheritdoc/>
    public EnhancedScrollerCellView GetCellView(
        EnhancedScroller scroller, int dataIndex, int cellIndex)
    {
        var cell = scroller.GetCellView(this.cellPrefab) as ListViewCell;
        cell.refreshCell = () =>
        {
            try
            {
                this.CellRefreshDel(cell, dataIndex, cellIndex);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }
        };

        try
        {
            this.CellRefreshDel(cell, dataIndex, cellIndex);
        }
        catch (Exception e)
        {
            Debug.LogError(e);
        }

        return cell;
    }

    /// <summary>
    /// Create a new prefab.
    /// </summary>
    public ListViewCell CreateCell()
    {
        return GameObject.Instantiate(this.cellPrefab);
    }

    private void Awake()
    {
        this.scroller = this.GetComponent<EnhancedScroller>();
        this.scroller.Delegate = this;
        this.cellPrefabRect = (RectTransform)this.cellPrefab.transform;
    }
}
