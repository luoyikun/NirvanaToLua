//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using LuaInterface;
using Nirvana;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// The description of PageViewSimpleDelegate.
/// </summary>
[RequireComponent(typeof(ListView))]
public sealed class PageViewSimpleDelegate : MonoBehaviour, IEndDragHandler
{
    [SerializeField]
    [Tooltip("The cell prefab")]
    private GameObject cellPrefab;

    private ScrollRect scrollRect;
    private ListView listView;

    private static readonly int MaxFreeGameObjCount = 100;
    private List<GameObject> freeGameObjList = new List<GameObject>();

    [SerializeField]
    private bool highSensitivity;

    public delegate int NumberOfCellsDelegate();
    public delegate void CellRefreshDelegate(int index, GameObject go);
    public delegate void CellRecycleDelegate(int index, GameObject go);

    public NumberOfCellsDelegate NumberOfCellsDel { get; set; }
    public CellRefreshDelegate CellRefreshDel { get; set; }

    /// <inheritdoc/>
    [NoToLua]
    public void OnEndDrag(PointerEventData eventData)
    {
        if (!this.highSensitivity)
        {
            return;
        }


        var pageView = this.listView as PageView;
        if (pageView == null)
        {
            return;
        }

        if (this.listView.IsJumping)
        {
            return;
        }

        if (this.scrollRect == null)
        {
            this.scrollRect = this.GetComponent<ScrollRect>();
        }

        if (this.scrollRect.velocity.x > 5.0f)
        {
            var current = pageView.ActiveCellsMiddleIndex;
            var index = current - 1;
            pageView.JumpToIndex(index, 0.0f, 1.0f);
        }
        else if (this.scrollRect.velocity.x < -5.0f)
        {
            var current = pageView.ActiveCellsMiddleIndex;
            var index = current + 1;
            pageView.JumpToIndex(index, 0.0f, 1.0f);
        }
    }

    private GameObject Spawn()
    {
        var index = freeGameObjList.Count - 1;
        if (index >= 0)
        {
            var gameObj = freeGameObjList[index];
            freeGameObjList.RemoveAt(index);

            gameObj.SetActive(true);

            return gameObj;
        }

        return Instantiate(this.cellPrefab);
    }

    private void Free(GameObject go)
    {
        if (freeGameObjList.Count >= MaxFreeGameObjCount)
        {
            Destroy(go);
            Debug.LogError(string.Format("MaxFreeGameObjCount = {0}, need expanded !", MaxFreeGameObjCount));
        }
        else
        {
            freeGameObjList.Add(go);
            go.SetActive(false);
        }
    }

    private void Awake()
    {
        this.listView = this.GetComponent<ListView>();
        this.listView.CellCountDel = () => this.NumberOfCellsDel();
        this.listView.GetCellDel = index =>
        {
            var go = Spawn();
            try
            {
                this.CellRefreshDel(index, go);
            }
            catch (Exception e)
            {
                Debug.LogError(e);
            }

            return go;
        };
        this.listView.RecycleCellDel = (index, go) =>
        {
            Free(go);
        };
    }
}
