//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;
using System.Collections.Generic;
using Nirvana;

/// <summary>
/// The scene renderers record.
/// </summary>
public class SceneRenderers : MonoBehaviour
{
    private static LinkedList<SceneRenderers> sceneRenderersList = 
        new LinkedList<SceneRenderers>();

    private NirvanaRenderer[] renderers;
    private LinkedListNode<SceneRenderers> node;

    public static void OnGameStop()
    {
        sceneRenderersList.Clear();
    }

    public static IEnumerable<SceneRenderers> Instances
    {
        get { return sceneRenderersList; }
    }

	public NirvanaRenderer[] Renderers
    {
        get
        {
            if (this.renderers == null)
            {
                this.renderers = this.GetComponentsInChildren<NirvanaRenderer>(true);
            }

            return this.renderers;
        }
    }

    private void Awake()
    {
        this.node = sceneRenderersList.AddLast(this);
    }

    private void OnDestroy()
    {
        if (this.node != null)
        {
            sceneRenderersList.Remove(this.node);
            this.node = null;
        }
    }
}
