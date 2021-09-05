using Nirvana;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class UIDrag : MonoBehaviour, IDragHandler, IBeginDragHandler, IEndDragHandler, IDropHandler
{
    public delegate void DropCallBackAction(System.Object dragData, GameObject dragGo);

    [SerializeField]
    private bool isCanDrag;

    [SerializeField]
    private bool isCanDrop;

    private System.Object dragData;
    private Action beginDragCallback;
    private Action endDragCallback;
    private DropCallBackAction dropCallback;
    private Vector3 orginalPos;
    private bool isOnTouch;

    public void SetDragData(System.Object dragData)
    {
        this.dragData = dragData;
    }

    public System.Object GetDragData()
    {
        return this.dragData;
    }

    public void SetIsCanDrag(bool isCanDrag)
    {
        this.isCanDrag = isCanDrag;
    }

    public void SetIsCanDrop(bool isCanDrop)
    {
        this.isCanDrop = isCanDrop;
    }

    public void ListenBeginDragCallback(Action callback)
    {
        this.beginDragCallback += callback;
    }

    public void UnListenBeginDragCallback(Action callback)
    {
        this.beginDragCallback -= callback;
    }

    public void ListenEndDragCallback(Action callback)
    {
        this.endDragCallback += callback;
    }

    public void UnListenEndDragCallback(Action callback)
    {
        this.endDragCallback -= callback;
    }

    public void ListenDropCallback(DropCallBackAction callback)
    {
        this.dropCallback += callback;
    }

    public void UnListenDropCallback(DropCallBackAction callback)
    {
        this.dropCallback -= callback;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        if (!this.isCanDrag)
        {
            return;
        }

        Canvas canvas = this.gameObject.AddComponent<Canvas>();
        canvas.overrideSorting = true;
        canvas.sortingOrder = 999999;

        this.isOnTouch = true;

        this.orginalPos = this.transform.position;

        if (null != this.beginDragCallback)
        {
            this.beginDragCallback();
        }
        Debug.Log("OnBeginDrag");
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!this.isCanDrag)
        {
            return;
        }

        Vector3 pos;
        RectTransform rect = this.GetComponent<RectTransform>();
        if (RectTransformUtility.ScreenPointToWorldPointInRectangle(rect, eventData.position, eventData.pressEventCamera, out pos))
        {
            if (!this.isOnTouch)
            {
                if (null != this.endDragCallback)
                {
                    this.endDragCallback();
                }
            }
            else
            {
                rect.transform.position = pos;
            }
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if (!this.isCanDrag)
        {
            return;
        }

        this.Resume();

        if (null != this.endDragCallback)
        {
            this.endDragCallback();
        }
        this.isOnTouch = false;

        Debug.Log("OnEndDrag");
    }

    public void OnDrop(PointerEventData eventData)
    {
        UIDrag ui_drag = eventData.pointerDrag.GetComponent<UIDrag>();
        if (!this.isCanDrop || null == ui_drag)
        {
            return;
        }

        if (null != this.dropCallback)
        {
            this.dropCallback(ui_drag.GetDragData(), ui_drag.gameObject);
        }

        Debug.Log("OnDrop");
    }

    public void Resume()
    {
        if (!this.orginalPos.Equals(Vector3.zero))
        {
            this.transform.position = this.orginalPos;
        }

        Canvas canvas = this.GetComponent<Canvas>();
        if (null != canvas)
        {
            GameObject.Destroy(canvas);
        }
    }
}
