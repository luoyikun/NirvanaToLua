//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;

/// <summary>
/// Used to trigger footstep when animation event triggered.  
/// </summary>
[Serializable]
public sealed class ActorTriggerFootstep : ActorTriggerBase
{
    [SerializeField]
    [Tooltip("The foot node.")]
    private Transform footNode;

    [SerializeField]
    [Tooltip("The footprint data.")]
    private Footprint footprint;

    [SerializeField]
    [Tooltip("The footstep dust.")]
    private EffectControl footsetpDust;

    [SerializeField]
    [Tooltip("The audio used to play on footstep.")]
    [AssetType(typeof(AudioItem))]
    private AssetID audioAsset;

    public AssetID AudioAsset
    {
        get
        {
            return audioAsset;
        }
        set
        {
            audioAsset = value;
        }
    }

    public Transform FootNode { get { return footNode; } }

    public Footprint FootPrint { get { return footprint; } }

    public EffectControl FootStepDust { get { return footsetpDust; } }

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        // Play the footstep sound.
        if (!this.audioAsset.IsEmpty)
        {
            if (this.footNode != null)
            {
                AudioManager.PlayAndForget(this.audioAsset, this.footNode);
            }
            else
            {
                AudioManager.PlayAndForget(this.audioAsset, source);
            }
        }

        // Play the dust effect.
        if (this.footsetpDust != null && this.footNode != null)
        {
            var dust = GameObjectPool.Instance.Spawn(this.footsetpDust, null);
            dust.gameObject.SetLayerRecursively(this.Actor.layer);
            dust.transform.SetPositionAndRotation(
                this.footNode.transform.position, 
                this.footNode.transform.rotation);
            dust.transform.localScale = this.footNode.transform.lossyScale;
            dust.FinishEvent += () =>
            {
                GameObjectPool.Instance.Free(dust.gameObject);
            };

            dust.Reset();
            dust.Play();
        }

        // Add a footprint.
        if (this.footNode != null)
        {
            RaycastHit hitInfo;
            if (Physics.Raycast(
                    this.footNode.position,
                    Vector3.down,
                    out hitInfo,
                    Mathf.Infinity,
                    1 << GameLayers.Walkable))
            {
                FootprintManager.Instance.AddFootprint(
                    hitInfo.point,
                    source.forward,
                    source.right, 
                    footprint);
            }
        }
    }
}
