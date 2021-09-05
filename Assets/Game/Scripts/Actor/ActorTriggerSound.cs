//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using Nirvana;
using UnityEngine;
using System.Collections;

[Serializable]
public sealed class ActorTriggerSound : ActorTriggerBase
{
    private static Nirvana.Logger logger =
        LogSystem.GetLogger("ActorSoundTrigger");

    [SerializeField]
    [Tooltip("The audio used to play.")]
    [AssetType(typeof(AudioItem))]
    private AssetID audioAsset;
    static private int curSoundCount = 0;

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

    /// <inheritdoc/>
    protected override void OnEventTriggered(
        Transform source, Transform target, AnimatorStateInfo stateInfo)
    {
        if (this.audioAsset.IsEmpty)
        {
            logger.LogWarning("Missing audio trigger's prefab.");
            return;
        }
        if (source.GetComponent<ActorController>().IsMainRole)
        {
            AudioManager.PlayAndForget(this.audioAsset, source);
        }
        else
        {
            if (curSoundCount < 2)
            {
                ScriptablePool.Instance.Load(this.audioAsset, obj =>
                {
                    if (null == obj)
                    {
                        logger.LogWarning("Not correct audioAsset");
                        return;
                    }
                    var item = obj as AudioItem;
                    if (null == item)
                    {
                        logger.LogWarning("Cannot convert audioAsset");
                        return;
                    }
                    var audioPlayer = AudioManager.Play(item, source);
                    ++curSoundCount;
                    Scheduler.RunCoroutine(this.SoundCoroutine(audioPlayer.WaitFinish()));
                });
            }
        }
    }
    private IEnumerator SoundCoroutine(IEnumerator ienumerator)
    {
        yield return ienumerator;
        --curSoundCount;
    }
}
