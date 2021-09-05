using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Nirvana;
using System;

[RequireComponent(typeof(Canvas))]
[RequireComponent(typeof(GraphicRaycaster))]
public class UIOverrideOrder : MonoBehaviour, IOverrideOrder
{
    private Canvas groupCanvas;

    private void Start()
    {
        groupCanvas = OverrideOrderGroupMgr.Instance.AddToGroup(this);
    }

    private void OnDestroy()
    {
        OverrideOrderGroupMgr.Instance.RemoveFromGroup(groupCanvas, this);
    }

    protected void OnTransformParentChanged()
    {
        if (Application.isPlaying)
        {
            OverrideOrderGroupMgr.Instance.SetGroupCanvasDirty(this.groupCanvas);
        }
    }

    public GameObject Target
    {
        get { return this.gameObject; }
    }

    public void SetOverrideOrder(int order, int orderInterval, int maxOrder, out int incOrder)
    {
        incOrder = 0;
        Canvas canvas = this.GetComponent<Canvas>();
        if (null != canvas)
        {
            canvas.overrideSorting = true;
            if (order > maxOrder)
            {
                order = maxOrder;
            }
            canvas.sortingOrder = order;
            incOrder = 1;
        }
    }
}
