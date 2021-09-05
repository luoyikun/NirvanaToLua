//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Used to adapt the difference resolution.
/// </summary>
[RequireComponent(typeof(RectMask2D))]

[ExecuteInEditMode]
public sealed class ResolutionImageAdapter : MonoBehaviour
{
    [SerializeField][ReName("RawImage")]
    private RawImage rawimage;

    private void Start()
    {
        if (this.rawimage != null)
        {
            RectTransform image_size = this.rawimage.GetComponent<RectTransform>();
            image_size.anchorMin = new Vector2(0.5f, 0.5f);
            image_size.anchorMax = new Vector2(0.5f, 0.5f);
            image_size.pivot = new Vector2(0.5f, 0.5f);
            rawimage.SetNativeSize();
        }

        RectTransform parent_size = this.GetComponent<RectTransform>();
        parent_size.anchorMin = new Vector2(0.0f, 0.0f);
        parent_size.anchorMax = new Vector2(1.0f, 1.0f);
        parent_size.pivot = new Vector2(0.5f, 0.5f);

        this.AdaptResolution();
    }

//#if UNITY_EDITOR
    private void Update()
    {
        this.AdaptResolution();
    }
//#endif

    private void AdaptResolution()
    {
#if UNITY_EDITOR
        var prefabType = PrefabUtility.GetPrefabType(this.gameObject);
        if (prefabType == PrefabType.Prefab)
        {
            return;
        }
#endif

        if (this.rawimage == null)
        {
            return;
        }

        RectTransform image_size = this.rawimage.GetComponent<RectTransform>();
        if (image_size.rect.width == 0 || image_size.rect.height == 0)
        {
            return;
        }

        RectTransform parent_size = this.GetComponent<RectTransform>();
        if (parent_size.rect.width == 0 || parent_size.rect.height == 0)
        {
            return;
        }

        Rect resolution_size = parent_size.rect;

        float scale_x = 1.0f;
        if (image_size.rect.width < resolution_size.width)
        {
            scale_x = resolution_size.width / image_size.rect.width;
        }
        float scale_y = 1.0f;
        if (image_size.rect.height < resolution_size.height)
        {
            scale_y = resolution_size.height / image_size.rect.height;
        }

        float scale = Mathf.Max(scale_x, scale_y);
        if (scale != image_size.localScale.x || scale != image_size.localScale.y)
        {
            image_size.localScale = new Vector3(scale, scale, scale);
        }
    }
}
