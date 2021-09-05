//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections;
using Nirvana;
using UnityEngine;

/// <summary>
/// The base class to receive any animation event.
/// </summary>
[Serializable]
public abstract class ActorTriggerBase
{
    [SerializeField]
    [ActorEvent]
    [Tooltip("The event name for this trigger.")]
    private string eventName;

    [SerializeField]
    [Tooltip("The delay time for this trigger.")]
    private float delay;

    private SignalHandle signalHandle;
    private Transform transform;
    private bool enabled = true;
    private IActorTarget target;

    public bool Enalbed
    {
        get { return this.enabled; }
        set { this.enabled = value; }
    }

    public string EventName { get { return eventName; } }

    public float Delay { get { return delay; } }

    /// <summary>
    /// Gets or sets the actor triggers.
    /// </summary>
    protected ActorTriggers ActorTriggers { get; private set; }

    /// <summary>
    /// Gets the actor object.
    /// </summary>
    protected GameObject Actor
    {
        get { return this.transform.gameObject; }
    }

    /// <summary>
    /// Initialize this event trigger.
    /// </summary>
    public virtual void Init(
        ActorTriggers actorTriggers, 
        AnimatorEventDispatcher dispatcher, 
        IActorTarget target)
    {
        this.ActorTriggers = actorTriggers;
        this.transform = dispatcher.transform;
        this.target = target;

        this.signalHandle = dispatcher.ListenEvent(
            this.eventName,
            this.OnAnimatorEvent);
    }

    /// <summary>
    /// Destroy this event trigger.
    /// </summary>
    public virtual void Destroy()
    {
        if (this.signalHandle != null)
        {
            this.signalHandle.Dispose();
            this.signalHandle = null;
        }
    }

    /// <summary>
    /// Update each frame.
    /// </summary>
    public virtual void Update()
    {
        if (this.enabled)
        {
            this.UpdateTrigger();
        }
    }

    /// <summary>
    /// Update each frame.
    /// </summary>
    public virtual void UpdateTrigger()
    {
    }

    /// <summary>
    /// Receive the event triggered.
    /// </summary>
    protected abstract void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo);

    private void OnAnimatorEvent(string param, AnimatorStateInfo stateInfo)
    {
        if (this.enabled)
        {
            if (this.delay <= 0.0f)
            {
                this.OnEventTriggered(
                    this.transform, this.target.Target, stateInfo);
            }
            else
            {
                Scheduler.RunCoroutine(this.DelayTrigger(
                    this.transform, this.target.Target, stateInfo));
            }
        }
    }

    private IEnumerator DelayTrigger(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        yield return new WaitForSeconds(this.delay);

        if (this == null || 
            this.transform == null || 
            this.transform.gameObject == null || 
            !this.transform.gameObject.activeInHierarchy)
        {
            yield break;
        }

        this.OnEventTriggered(source, target, stateInfo);
    }
}
