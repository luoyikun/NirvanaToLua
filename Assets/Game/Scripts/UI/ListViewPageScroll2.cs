//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using EnhancedUI.EnhancedScroller;
using Nirvana;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// This is the page view for a scroll.
/// </summary>
[RequireComponent(typeof(ScrollRect))]
public sealed class ListViewPageScroll2 : MonoBehaviour, IBeginDragHandler, IEndDragHandler
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

    [SerializeField]
    private bool withoutToggle = false;

    public event Action JumpToPageEvent;

    private UnityAction<bool>[] pageToggleEvents;
    private ScrollRect scrollRect;
    private ListView listView;
    private float dragBeginPosition;
    private float dragBeginTime;
    private int dragBeginPage;
    private int pageCount;
    private int currentPage;

    public void JumpToPage(int page)
    {
        if (this.listView == null || page >= this.pageCount)
        {
            return;
        }

        this.currentPage = page;
        var jumpIndex = page * this.pageCellNumber;

        if (this.withoutToggle)
        {
            this.listView.JumpToIndex(jumpIndex, 0.0f, 1.0f);
            if (this.JumpToPageEvent != null)
            {
                this.JumpToPageEvent();
            }
            return;
        }

        var toggle = this.pageToggles[page];
        var toggleEvent = this.pageToggleEvents[page];
        this.listView.JumpToIndex(jumpIndex, 0.0f, 1.0f);

        toggle.onValueChanged.RemoveListener(toggleEvent);
        toggle.isOn = true;
        toggle.onValueChanged.AddListener(toggleEvent);

        if (this.JumpToPageEvent != null)
        {
            this.JumpToPageEvent();
        }
    }

    public void JumpToPageImmidate(int page)
    {
        if (this.listView == null || page >= this.pageCount)
        {
            return;
        }

        this.currentPage = page;
        var jumpIndex = page * this.pageCellNumber;
        var toggle = this.pageToggles[page];
        var toggleEvent = this.pageToggleEvents[page];
        this.listView.JumpToIndex(jumpIndex);

        toggle.onValueChanged.RemoveListener(toggleEvent);
        toggle.isOn = true;
        toggle.onValueChanged.AddListener(toggleEvent);

        if (this.JumpToPageEvent != null)
        {
            this.JumpToPageEvent();
        }
    }

    public void JumpToPageImmidateWithoutToggle(int page)
    {
        if (this.listView == null || page >= this.pageCount)
        {
            return;
        }

        this.currentPage = page;
        var jumpIndex = page * this.pageCellNumber;
        this.listView.JumpToIndex(jumpIndex);

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

    /// <inheritdoc/>
    public void OnBeginDrag(PointerEventData eventData)
    {
        if (this.scrollRect.horizontal)
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
        if (this.scrollRect.horizontal)
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
        if (this.scrollRect.horizontal)
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
        this.listView = this.GetComponent<ListView>();
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
