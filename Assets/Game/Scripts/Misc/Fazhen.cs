//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

/// <summary>
/// The Fazhen.
/// </summary>
public sealed class Fazhen : MonoBehaviour
{
    [SerializeField]
    private Vector2 originalSize;

    [SerializeField]
    private Animator animator;

    private float originalSpeed = 1.0f;
    private float originalTime = 0.0f;

    public Fazhen()
    {
        
    }

    private void Awake()
    {
        if (null == this.animator)
        {
            return;
        }

        AnimatorStateInfo state_info = this.animator.GetCurrentAnimatorStateInfo(0);
        this.originalSpeed = state_info.speed;
        this.originalTime = state_info.length;
    }

    private void OnEnable()
    {
        //this.transform.localScale = new Vector3(1, , 1, 1);
    }

    public void SetSize(Vector2 size)
    {
        if (size.Equals(Vector2.zero) || this.originalSize.Equals(Vector3.zero))
        {
            return;
        }

        Vector3 new_scale = this.transform.localScale;
        new_scale.x = size.x / this.originalSize.x;
        new_scale.y = size.y / this.originalSize.y;
        new_scale.z = new_scale.y;

        this.transform.localScale = new_scale;
    }

    public void SetRotateY(float angle)
    {
        Vector3 euler = this.transform.eulerAngles;
        euler.y = angle;
        this.transform.eulerAngles = euler;
    }

    public void Play(float elapse_time, float total_time)
    {
        if (null == this.animator || total_time <= float.Epsilon)
        {
            return;
        }

        if (elapse_time <= float.Epsilon)
        {
            elapse_time = 0;
        }

        AnimatorStateInfo state_info = this.animator.GetCurrentAnimatorStateInfo(0);

        this.animator.speed = this.originalTime / total_time * this.originalSpeed;
        this.animator.Play(state_info.fullPathHash, 0, elapse_time / total_time);
    }
}
