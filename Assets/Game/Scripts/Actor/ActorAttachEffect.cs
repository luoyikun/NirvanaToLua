using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Nirvana;
using UnityEngine;
using System.Collections;

public sealed class ActorAttachEffect : MonoBehaviour
{
    [SerializeField]
    [Tooltip("The effect prefab")]
    [AssetType(typeof(EffectControl))]
    private AssetID effectAsset;

    [SerializeField]
    private Transform attachTransform;

    [SerializeField]
    private Vector3 scale = new Vector3(1.0f, 1.0f, 1.0f);

    public bool playOnAwake = false;

    private GameObject effect;

    private void OnEnable()
    {
        if (this.playOnAwake)
        {
            this.PlayEffect();
        }
        else
        {
            this.StopEffect();
        }
    }

    public AssetID EffectAsset
    {
        get { return this.effectAsset;  }
        set { this.effectAsset = value;  }
    }

    public void PlayEffect()
    {
        this.StopEffect();
        Scheduler.RunCoroutine(this.DoPlayEffect());
    }

    public void StopEffect()
    {
        if (null != this.effect)
        {
            GameObjectPool.Instance.Free(this.effect.gameObject);
            this.effect = null;
        }
    }

    private IEnumerator DoPlayEffect()
    {
        if (this.effectAsset.IsEmpty || null == this.attachTransform)
        {
            yield break;
        }

        var wait = GameObjectPool.Instance.SpawnAsset(this.effectAsset);
        yield return wait;

        if (this == null)
        {
            yield break;
        }

        this.effect = wait.Instance;
        this.effect.SetLayerRecursively(this.transform.gameObject.layer);
        this.effect.transform.SetParent(this.attachTransform, false);
        this.effect.transform.localScale = this.scale;
    }
}

