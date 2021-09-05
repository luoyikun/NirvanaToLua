//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections;
using System.Collections.Generic;
using Nirvana;
using UnityEngine;

/// <summary>
/// Used to play effect when animation event triggered.  
/// </summary>
[Serializable]
public sealed class ActorTriggerEffect : ActorTriggerBase
{
    private static Nirvana.Logger logger =
        LogSystem.GetLogger("ActorTriggerEffect");

    [SerializeField]
    [Tooltip("The effect prefab")]
    [AssetType(typeof(EffectControl))]
    private AssetID effectAsset;

    [SerializeField]
    [Tooltip("Whether to play at target.")]
    private bool playAtTarget;

    [SerializeField]
    [Tooltip("The reference node for the effect to play.")]
    private Transform referenceNode;

    [SerializeField]
    [Tooltip("Whether attach to the reference node.")]
    private bool isAttach;

    [SerializeField]
    [Tooltip("Whether rotation to the reference node.")]
    private bool isRotation;

    [SerializeField]
    [ActorEvent]
    [Tooltip("The event name stop this effect.")]
    private string stopEvent;

    // The stop event handle.
    private SignalHandle stopHandle;

    // All running effect.
    private LinkedList<EffectControl> effects =
        new LinkedList<EffectControl>();

    public AssetID EffectAsset
    {
        get { return this.effectAsset;  }
        set { this.effectAsset = value;  }
    }

    public bool PlayerAtTarget { get { return playAtTarget; } }

    public Transform ReferenceNode { get { return referenceNode; } }

    public bool IsAttach { get { return isAttach; } }

    public bool IsRotation { get { return isRotation; } }

    public string StopEvent { get { return stopEvent; } }

    /// <summary>
    /// Stop all effects.
    /// </summary>
    public void StopEffects()
    {
        foreach (var effect in this.effects)
        {
            if (effect != null)
            {
                effect.Stop();
            }
        }
    }

    /// <inheritdoc/>
    public override void Init(
        ActorTriggers actorTriggers, 
        AnimatorEventDispatcher dispatcher, 
        IActorTarget target)
    {
        base.Init(actorTriggers, dispatcher, target);
        this.stopHandle = dispatcher.ListenEvent(
            this.stopEvent,
            (param, stateInfo) =>
            {
                this.StopEffects();
            });
    }

    /// <inheritdoc/>
    public override void Destroy()
    {
        base.Destroy();
        if (this.stopHandle != null)
        {
            this.stopHandle.Dispose();
            this.stopHandle = null;
        }
    }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        Scheduler.RunCoroutine(this.OnEventTriggeredImpl(
            source, target, stateInfo));
    }

    private IEnumerator OnEventTriggeredImpl(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        if (this.effectAsset.IsEmpty)
        {
            logger.LogWarning("Missing effect trigger's prefab.");
            yield break;
        }

        // Find the reference node.
        Transform reference = null;
        Transform deliverer = null;
        if (this.playAtTarget)
        {
            reference = target;
            deliverer = (this.referenceNode != null) ?
                this.referenceNode : source.transform;
        }
        else
        {
            reference = (this.referenceNode != null) ?
                this.referenceNode : source.transform;
            deliverer = (this.referenceNode != null) ?
              this.referenceNode : source.transform;
        }

        if (reference == null || deliverer == null)
        {
            yield break;
        }

        // Load the effect.
        var wait = GameObjectPool.Instance.SpawnAsset(this.effectAsset);
        yield return wait;

        if (this == null)
        {
            yield break;
        }

        if (wait.Error != null)
        {
            logger.LogWarning(
                "Load prefab {0} failed: {1}.", this.effectAsset, wait.Error);
            yield break;
        }

        // Instantiate this effect.
        var instance = wait.Instance;
        if (instance == null)
        {
            logger.LogWarning(
                "The prefab {0} get instance from pool failed.", this.effectAsset);
            yield break;
        }

        instance.SetLayerRecursively(this.Actor.layer);
        var effect = instance.GetComponent<EffectControl>();
        if (effect == null)
        {
            logger.LogWarning(
                "The prefab {0} does not has EffectControl.", this.effectAsset);
            yield break;
        }

        // Setup the transform.
        if (this.isAttach)
        {
            effect.transform.SetParent(reference);
            if (this.isRotation)
            {
                var direction = reference.position - deliverer.position;
                direction.y = 0.0f;
                effect.transform.SetPositionAndRotation(
                    reference.position, Quaternion.LookRotation(direction));
            }
            else
            {
                effect.transform.localPosition = Vector3.zero;
                effect.transform.localRotation = Quaternion.identity;
            }
            effect.transform.localScale = reference.localScale;
        }
        else
        {
            effect.transform.SetPositionAndRotation(
                reference.position, reference.rotation);
            effect.transform.localScale = reference.lossyScale;
        }

        // Record and check the effect finish.
        var node = this.effects.AddLast(effect);
        effect.FinishEvent += () =>
        {
            this.effects.Remove(node);
            GameObjectPool.Instance.Free(effect.gameObject);
        };

        // Start to play.
        effect.Reset();
        effect.PlaybackSpeed = stateInfo.speedMultiplier;
        effect.Play();
    }
}
