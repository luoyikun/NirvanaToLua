//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
using UnityEngine;

#if UNITY_EDITOR

[ExecuteInEditMode]
public sealed class ScenePoint : SceneObject
{
    private void Awake()
    {
        this.LoadPreview();
    }

    private void OnValidate()
    {
        if (Application.isPlaying)
        {
            return;
        }

        this.name = "ScenePoint";
    }

    private void LoadPreview()
    {
        var preview = GameObject.CreatePrimitive(PrimitiveType.Cube);
        preview.transform.localPosition = new Vector3(0, 0.5f, 0);
        preview.hideFlags = HideFlags.HideAndDontSave;
        var previewObj = this.GetOrAddComponent<PreviewObject>();
        previewObj.SetPreview(preview);
    }
}

#endif
