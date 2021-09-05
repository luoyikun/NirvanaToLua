//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using EnhancedUI.EnhancedScroller;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using System;

/// <summary>
/// This is the page view for a scroll.
/// </summary>
[RequireComponent(typeof(ScrollRect))]
public sealed class ListViewPageScroll : MonoBehaviour, IBeginDragHandler, IEndDragHandler
{
    [SerializeField]
    [Tooltip("The page toggles.")]
    private Toggle[] pageToggles;

    [SerializeField]
    [Tooltip("The number of cell per page.")]
    private int pageCellNumber = 5;

    [SerializeField]
    [Tooltip("The touch delta to switch page.")]
    private float touchDelta = 75.0f;

    [SerializeField]
    [Tooltip("The touch speed to switch page.")]
    private float touchSpeed = 150.0f;

    public event Action JumpToPageEvent;

    private UnityAction<bool>[] pageToggleEvents;
    private ScrollRect scrollRect;
    private EnhancedScroller scroller;
    private float dragBeginPosition;
    private float dragBeginTime;
    private int dragBeginPage;
    private int pageCount;
    private int currentPage;

    public void JumpToPage(int page)
    {
        if (this.scroller == null || page >= this.pageCount)
        {
            return;
        }

        this.currentPage = page;
        var jumpIndex = page * this.pageCellNumber;
        var toggle = this.pageToggles[page];
        var toggleEvent = this.pageToggleEvents[page];
        this.scroller.JumpToDataIndexForce(
            jumpIndex,
            0,
            0,
            false,
            EnhancedScroller.TweenType.linear,
            0.2f,
            () =>
            {
                toggle.onValueChanged.RemoveListener(toggleEvent);
                toggle.isOn = true;
                toggle.onValueChanged.AddListener(toggleEvent);
            });

        if (this.JumpToPageEvent != null)
        {
            this.JumpToPageEvent();
        }
    }

    public int GetNowPage()
    {
        return this.currentPage;
    }

    public void SetPageCellNumBer(int num)
    {
        if (num <= 0)
        {
            return;
        }
        this.pageCellNumber = num;
    }

    public void SetPageCount(int count)
    {
        this.pageCount = count;
    }

    public void JumpToPageImmidate(int page)
    {
        if (this.scroller == null || page >= this.pageCount)
        {
            return;
        }

        var jumpIndex = page * this.pageCellNumber;
        var toggle = this.pageToggles[page];
        var toggleEvent = this.pageToggleEvents[page];
        this.scroller.JumpToDataIndex(
            jumpIndex,
            0,
            0,
            false,
            EnhancedScroller.TweenType.immediate,
            0.0f,
            () =>
            {
                toggle.onValueChanged.RemoveListener(toggleEvent);
                toggle.isOn = true;
                toggle.onValueChanged.AddListener(toggleEvent);
            });
    }

    /// <inheritdoc/>
    public void OnBeginDrag(PointerEventData eventData)
    {
        if (this.scroller.scrollDirection == EnhancedScroller.ScrollDirectionEnum.Horizontal)
        {
            this.dragBeginPosition = eventData.position.x;
        }
        else
        {
            this.dragBeginPosition = eventData.position.y;
        }

        this.dragBeginTime = Time.realtimeSinceStartup;
        this.dragBeginPage = this.GetCurrentPage();
    }

    /// <inheritdoc/>
    public void OnEndDrag(PointerEventData eventData)
    {
        float dragEndPosition;
        if (this.scroller.scrollDirection == EnhancedScroller.ScrollDirectionEnum.Horizontal)
        {
            dragEndPosition = eventData.position.x;
        }
        else
        {
            dragEndPosition = eventData.position.y;
        }

        float delta = dragEndPosition - this.dragBeginPosition;
        var speed = delta / (Time.realtimeSinceStartup - this.dragBeginTime);

        if (Mathf.Abs(delta) > this.touchDelta || 
            Mathf.Abs(speed) > this.touchSpeed)
        {
            int page;
            if (delta > 0)
            {
                page = this.dragBeginPage - 1;
                page = Mathf.Clamp(page, 0, this.pageCount - 1);
            }
            else if (delta < 0)
            {
                page = this.dragBeginPage + 1;
                page = Mathf.Clamp(page, 0, this.pageCount - 1);
            }
            else
            {
                page = this.dragBeginPage;
            }

            this.JumpToPage(page);
        }
        else
        {
            this.JumpToPage(this.dragBeginPage);
        }
    }

    private int GetCurrentPage()
    {
        float scrollPosition;
        if (this.scroller.scrollDirection == EnhancedScroller.ScrollDirectionEnum.Horizontal)
        {
            scrollPosition = this.scrollRect.normalizedPosition.x;
        }
        else
        {
            scrollPosition = 1.0f - this.scrollRect.normalizedPosition.y;
        }

        if (scrollPosition <= 0)
        {
            return 0;
        }
        else if (scrollPosition >= 1)
        {
            return this.pageCount - 1;
        }
        else
        {
            float pageSize = 1.0f / this.pageCount;
            float pageIndex = scrollPosition / pageSize;
            return (int)Mathf.Floor(pageIndex);
        }
    }

    private void Awake()
    {
        this.scrollRect = this.GetComponent<ScrollRect>();
        this.scroller = this.GetComponent<EnhancedScroller>();
        this.pageCount = this.pageToggles.Length;

        // Listen the page toggles.
        this.pageToggleEvents = new UnityAction<bool>[this.pageToggles.Length];
        for (int i = 0; i < this.pageToggles.Length; ++i)
        {
            var toggle = this.pageToggles[i];
            int index = i;
            this.pageToggleEvents[i] = isOn =>
            {
                if (isOn)
                {
                    this.JumpToPage(index);
                }
            };

            toggle.onValueChanged.AddListener(this.pageToggleEvents[i]);
        }
    }
}
