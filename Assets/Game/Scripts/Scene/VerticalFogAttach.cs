//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
//------------------------------------------------------------------------------

using UnityEngine;

[RequireComponent(typeof(Camera))]

public sealed class VerticalFogAttach : MonoBehaviour
{
    private Nirvana.VerticalFog vertical_fog;

    private void Start()
    {
        Nirvana.VerticalFog[] objs = GameObject.FindObjectsOfType<Nirvana.VerticalFog>();
        if (objs.Length > 1)
        {
            foreach (var obj in objs)
            {
                Debug.LogError(string.Format("Single VerticalFog Expected! Multi In{0}", obj.name));
            }
            return;
        }

        if (objs.Length >= 1)
        {
            vertical_fog = objs[0];
        }
    }

    private void OnPreRender()
    {
        if (null != vertical_fog)
        {
            vertical_fog.OnPreRender();
        }
    }

    private void OnPostRender()
    {
        if (null != vertical_fog)
        {
            vertical_fog.OnPostRender();
        }
    }
}

