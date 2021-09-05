//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using Nirvana;
using UnityEngine;
using UnityEngine.Assertions;

/// <summary>
/// The actor time line event.
/// </summary>
[RequireComponent(typeof(Animator))]
public sealed class ActorTimelineEvent : MonoBehaviour
{
    [SerializeField]
    private EventTime[] eventTimes;

    private Animator animator;

    private void Awake()
    {
        this.animator = this.GetComponent<Animator>();
        Assert.IsNotNull(this.animator);
    }

    private void OnEnable()
    {
        this.RefreshEventTimeline();
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        this.RefreshEventTimeline();
    }
#endif

    private void RefreshEventTimeline()
    {
        if (this.animator != null && 
            this.animator.runtimeAnimatorController != null)
        {
            var lookup = new Dictionary<string, float>(this.eventTimes.Length);
            foreach (var eventTime in this.eventTimes)
            {
                lookup.Add(eventTime.EventName, eventTime.NormalizedTime);
            }

            var timelineBehaviours = 
                this.animator.GetBehaviours<AnimatorTimelineBehaviour>();
            foreach (var behaviour in timelineBehaviours)
            {
                this.ReplaceTimeline(behaviour, lookup);
            }
        }
    }

    private void ReplaceTimeline(
        AnimatorTimelineBehaviour behaviour, 
        IDictionary<string, float> lookup)
    {
        var timtlineEvents = behaviour.TimelineEvents;
        foreach (var timtlineEvent in timtlineEvents)
        {
            float time;
            if (lookup.TryGetValue(timtlineEvent.EventName, out time))
            {
                timtlineEvent.NormalizedTime = time;
            }
        }
    }

    [Serializable]
    private struct EventTime
    {
        public string EventName;
        public float NormalizedTime;
    }
}
