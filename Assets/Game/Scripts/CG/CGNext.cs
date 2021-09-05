//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using UnityEngine;
using UnityEngine.Playables;

/// <summary>
/// 用于等待CG结束并播放下一段CG.
/// </summary>
public sealed class CGNext : MonoBehaviour
{
    [SerializeField]
    private PlayableDirector current;

    [SerializeField]
    private PlayableDirector next;

    private double duration;

    private void Awake()
    {
        if (this.current != null)
        {
            this.duration = this.current.duration;
        }
    }

    private void Update()
    {
        if (this.current == null || this.next == null)
        {
            return;
        }

        if (this.current.state == PlayState.Playing)
        {
            var delta = this.current.time - this.duration;
            if (Math.Abs(delta) < 0.0001)
            {
                this.current.gameObject.SetActive(false);
                this.next.gameObject.SetActive(true);
                this.current.Stop();
                this.next.Play();
                Debug.Log("Play: " + this.next.name);
            }
        }
    }
}
