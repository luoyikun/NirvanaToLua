using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Nirvana;
using System;

public sealed class OverrideOrderGroupMgr : Singleton<OverrideOrderGroupMgr>
{
    private Dictionary<Canvas, OverrideOrderGroupItem> overrideOrderDic = new Dictionary<Canvas, OverrideOrderGroupItem>();
    private int groupCanvasOrderInterval = 10;

    public OverrideOrderGroupMgr()
    {
        
    }

    public void OnGameStartup()
    {
        Scheduler.AddFrameListener(this.Update);
    }

    public void OnGameStop()
    {
        overrideOrderDic.Clear();
    }

    public void SetGroupCanvasOrderInterval(int groupCanvasOrderInterval)
    {
        if (groupCanvasOrderInterval <= 0) return;

        this.groupCanvasOrderInterval = groupCanvasOrderInterval;
    }

    public Canvas AddToGroup(IOverrideOrder overrideOrder)
    {
        CanvasScaler canvasScaler = overrideOrder.Target.GetComponentInParent<CanvasScaler>();
        if (null == canvasScaler)
        {
            return null;
        }

        Canvas groupCanvas = canvasScaler.GetComponent<Canvas>();
        if (null == groupCanvas)
        {
            return null;
        }

        OverrideOrderGroupItem group;
        if (!overrideOrderDic.ContainsKey(groupCanvas))
        {
            group = new OverrideOrderGroupItem();
            group.groupCanvas = groupCanvas;
            group.groupOverrideOrder = groupCanvas.sortingOrder;
            overrideOrderDic.Add(groupCanvas, group);
        }
        else
        {
            group = overrideOrderDic[groupCanvas];
        }

        group.orderSet.Add(overrideOrder);
        group.isDirtry = true;

        return groupCanvas;
    }

    public void RemoveFromGroup(Canvas groupCanvas, IOverrideOrder overrideOrder)
    {
        if (null == groupCanvas || null == overrideOrder)
        {
            return;
        }

        OverrideOrderGroupItem group;
        if (overrideOrderDic.TryGetValue(groupCanvas, out group))
        {
            group.orderSet.Remove(overrideOrder);
            if (0 == group.orderSet.Count)
            {
                overrideOrderDic.Remove(groupCanvas);
            }

            group.isDirtry = true;
        }
    }

    public void SetGroupCanvasDirty(Canvas groupCanvas)
    {
        if (null == groupCanvas)
        {
            return;
        }

        OverrideOrderGroupItem groupItem;
        if (overrideOrderDic.TryGetValue(groupCanvas, out groupItem))
        {
            groupItem.isDirtry = true;
        }
    }

    public void Update()
    {
        this.ObserveGroupCanvasOrderChange();
        this.RefreshAllOrder();
    }

    private void ObserveGroupCanvasOrderChange()
    {
        foreach (var kv in this.overrideOrderDic)
        {
            if (null != kv.Value.groupCanvas && kv.Value.groupOverrideOrder != kv.Value.groupCanvas.sortingOrder)
            {
                kv.Value.groupOverrideOrder = kv.Value.groupCanvas.sortingOrder;
                kv.Value.isDirtry = true;
            }
        }
    }

    private void RefreshAllOrder()
    {
        foreach (var item in this.overrideOrderDic)
        {
            if (null == item.Key || !item.Value.isDirtry)
            {
                continue;
            }

            item.Value.isDirtry = false;
            this.RefreshOrder(item.Value);
        }
    }

    private void RefreshOrder(OverrideOrderGroupItem orderGroup)
    {
        orderGroup.groupCanvas.overrideSorting = true;
        int maxOrder = orderGroup.groupCanvas.sortingOrder + this.groupCanvasOrderInterval - 1;
        int order = orderGroup.groupCanvas.sortingOrder + 1;
        List<IOverrideOrder> orderList = this.SortOrderSet(orderGroup);
        
        foreach (var item in orderList)
        {
            int incOrder = 0;
            item.SetOverrideOrder(order, this.groupCanvasOrderInterval, maxOrder, out incOrder);
            order += incOrder;

            if (order > maxOrder)
            {
                order = maxOrder;
            }
        }
    }

    private List<IOverrideOrder> SortOrderSet(OverrideOrderGroupItem orderGroup)
    {
        Dictionary<Transform, IOverrideOrder> filterDic = new Dictionary<Transform, IOverrideOrder>();
        foreach (var item in orderGroup.orderSet)
        {
            if (null != item.Target.transform)
            {
                filterDic.Add(item.Target.transform, item);
            }
        }

        List<IOverrideOrder> orderList = new List<IOverrideOrder>();
        this.RecursionTransform(orderGroup.groupCanvas.transform, orderList, filterDic);

        return orderList;
    }

    private void RecursionTransform(Transform transform, List<IOverrideOrder> orderList, Dictionary<Transform, IOverrideOrder> filterDic)
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            Transform child = transform.GetChild(i);
            if (filterDic.ContainsKey(child))
            {
                orderList.Add(filterDic[child]);
            }

            if (child.childCount > 0)
            {
                this.RecursionTransform(child, orderList, filterDic);
            }
        }
    }
}

public class OverrideOrderGroupItem
{
    public Canvas groupCanvas;
    public int groupOverrideOrder;
    public HashSet<IOverrideOrder> orderSet = new HashSet<IOverrideOrder>();
    public bool isDirtry = false;

    public bool IsInvalid()
    {
        return null == groupCanvas;
    }
}

public interface IOverrideOrder
{
    GameObject Target { get; }
    void SetOverrideOrder(int order, int orderInterval, int maxOrder, out int incOrder);
}
