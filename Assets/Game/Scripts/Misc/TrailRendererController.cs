using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrailRendererController : MonoBehaviour
{
    private List<TrailRendererItem> trailRendererList = new List<TrailRendererItem>();

    private void Update ()
    {
        if (this.trailRendererList.Count > 0)
        {
            this.RefreshTrailRender();
        }
    }

    private void OnEnable()
    {
        this.trailRendererList.Clear();

        TrailRenderer[] renderers = this.GetComponentsInChildren<TrailRenderer>();
        for (int i = 0; i < renderers.Length; i++)
        {
            TrailRendererItem item = new TrailRendererItem();
            item.renderer = renderers[i];
            item.renderer.Clear();
            this.trailRendererList.Add(item);
        }
    }

    public void RefreshTrailRender()
    {
        for (int i = this.trailRendererList.Count - 1; i >= 0; --i)
        {
            TrailRendererItem item = this.trailRendererList[i];
            if (null == item.renderer)
            {
                this.trailRendererList.RemoveAt(i);
                continue;
            }

            Vector3 now_pos = item.renderer.transform.position;
            if ((now_pos - item.lastPosition).sqrMagnitude >= 4 * 4)
            {
                item.renderer.Clear();
            }
            item.lastPosition = now_pos;
        }
    }
}

class TrailRendererItem
{
    public TrailRenderer renderer;
    public Vector3 lastPosition;
}

