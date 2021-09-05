//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using HedgehogTeam.EasyTouch;
using UnityEngine;
using UnityEngine.Assertions;

/// <summary>
/// Click manager used to control the click and ray cast to the scene objects.
/// </summary>
[RequireComponent(typeof(Camera))]
public sealed class ClickManager : MonoBehaviour
{
    private static RaycastHit[] clickableHits = new RaycastHit[20];
    private static RaycastHit[] sceneHits = new RaycastHit[20];

    private Rect reserve_rect;
    // Look camera
    private Camera lookCamera;

    // The click event.
    private ClickGroundDelegate clickGroundEvent;

    /// <summary>
    /// The click ground delegate.
    /// </summary>
    public delegate void ClickGroundDelegate(RaycastHit hit);

    /// <summary>
    /// Gets the singleton instance.
    /// </summary>
    public static ClickManager Instance { get; private set; }

    /// <summary>
    /// Listen when player click the ground.
    /// </summary>
    public ClickGroundDelegate ListenClickGround(ClickGroundDelegate clickDelegate)
    {
        return this.clickGroundEvent += clickDelegate;
    }

    /// <summary>
    /// Unlisten the click ground event.
    /// </summary>
    public void UnlistenClickGround(ClickGroundDelegate clickDelegate)
    {
        this.clickGroundEvent -= clickDelegate;
    }

    /// <summary>
    /// Set reserve area.
    /// </summary>
    public void SetResearveArea(RectTransform rect_transform)
    {
        reserve_rect = Rect.MinMaxRect(rect_transform.offsetMin.x, rect_transform.offsetMin.y, rect_transform.offsetMax.x, rect_transform.offsetMax.y);
    }

    private void Awake()
    {
        Assert.IsNull(Instance);
        Instance = this;
        this.lookCamera = this.GetComponent<Camera>();

        EasyTouch.On_SimpleTap += this.HandleOnTap;
    }

    private void OnDestroy()
    {
        Instance = null;
    }

    private void HandleOnTap(Gesture gesture)
    {
        if (this.lookCamera == null)
        {
            return;
        }

        if (null != reserve_rect && reserve_rect.Contains(gesture.position))
        {
            return;
        }

        var ray = this.lookCamera.ScreenPointToRay(new Vector3(
            gesture.position.x, gesture.position.y, 0.0f));

        // Process Selectable
        int count = Physics.RaycastNonAlloc(ray, clickableHits, Mathf.Infinity, 1 << GameLayers.Clickable);
        if (this.ProcessClickableHit(ray, count))
        {
            return;
        }

        // Process Scene
        count = Physics.RaycastNonAlloc(ray, sceneHits, Mathf.Infinity, 1 << GameLayers.Walkable);
        if (this.ProcessSceneHit(ray, count))
        {
            return;
        }
    }

    private bool ProcessClickableHit(Ray ray, int count)
    {
        float distance = float.PositiveInfinity;
        ClickableObject owner = null;
        for (int i = 0; i < count; i++)
        {
            var hit = clickableHits[i];
            if (hit.distance < distance)
            {
                var clickable = hit.collider.GetComponent<Clickable>();
                if (clickable != null)
                {
                    var target = clickable.Owner;
                    if (target == null)
                    {
                        continue;
                    }

                    owner = target;
                    distance = hit.distance;
                }
            }
        }

        if (owner != null)
        {
            owner.TriggerClick();
            return true;
        }

        return false;
    }

    private bool ProcessSceneHit(Ray ray, int count)
    {
        float distance = float.PositiveInfinity;
        bool hasFind = false;
        var hitIndex = 0;
        for (int i = 0; i < count; i++)
        {
            var hit = sceneHits[i];
            if (hit.distance < distance)
            {
                hitIndex = i;
                hasFind = true;
                distance = hit.distance;
            }
        }

        if (hasFind && this.clickGroundEvent != null && hitIndex < sceneHits.Length)
        {
            this.clickGroundEvent(sceneHits[hitIndex]);
            return true;
        }

        return false;
    }
}
