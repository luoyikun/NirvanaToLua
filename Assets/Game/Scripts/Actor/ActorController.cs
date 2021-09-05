//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections;
using Nirvana;
using UnityEngine;
using UnityEngine.Assertions;
using Random = UnityEngine.Random;

/// <summary>
/// The controller for an actor.
/// </summary>
[RequireComponent(typeof(Animator))]
public sealed class ActorController : MonoBehaviour
{
    [SerializeField]
    private ProjectileData[] projectiles;

    [SerializeField]
    private HurtData[] hurts;

    [SerializeField]
    private Collider areaCollider;

    [SerializeField]
    [AssetType(typeof(EffectControl))]
    public AssetID beHurtEffecct;

    [SerializeField]
    public Transform beHurtPosition;

    [SerializeField]
    public bool beHurtAttach;

    private ActorBlinker actorBlinker;
    private ActorTriggers actorTriggers;

    private bool isMainRole = true;
    private Transform target;
    private Animator animator;
    private float speed;

    public ProjectileData[] Projectiles
    {
        get { return projectiles; }
    }

    public HurtData[] Hurts
    {
        get { return hurts; }
    }

    /// <summary>
    /// The hurt position to play hurt effect.
    /// </summary>
    public enum HurtPositionEnum
    {
        /// <summary>
        /// The root of the monster.
        /// </summary>
        Root,

        /// <summary>
        /// The hurt point of the monster.
        /// </summary>
        HurtPoint,
    }

    /// <summary>
    /// The hurt rotation to play hurt effect
    /// </summary>
    public enum HurtRotationEnum
    {
        /// <summary>
        /// Use the target rotation
        /// </summary>
        Target,

        /// <summary>
        /// Use the hit direction.
        /// </summary>
        HitDirection,
    }

    /// <summary>
    /// Set the target of this actor.
    /// </summary>
    public Transform Target
    {
        get
        {
            return this.target;
        }

        set
        {
            this.target = value;
            var triggers = this.GetComponent<ActorTriggers>();
            if (triggers != null)
            {
                triggers.Target = this.target;
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether this actor is main role.
    /// </summary>
    public bool IsMainRole
    {
        get
        {
            return this.isMainRole;
        }

        set
        {
            if (this.isMainRole != value)
            {
                this.isMainRole = value;
                if (this.areaCollider != null)
                {
                    this.areaCollider.gameObject.layer =
                        this.IsMainRole ? GameLayers.MainRole : 0;
                }
            }
        }
    }

    /// <summary>
    /// Whether to enable the effect trigger.
    /// </summary>
    /// <param name="enable"></param>
    public void EnableEffect(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableEffect = enable;
        }
    }

    /// <summary>
    /// Whether to enable the halt trigger.
    /// </summary>
    /// <param name="enable"></param>
    public void EnableHalt(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableHalt = enable;
        }
    }

    /// <summary>
    /// Whether to enable the camera shake trigger.
    /// </summary>
    public void EnableCameraShake(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableCameraShake = enable;
        }
    }

    /// <summary>
    /// Whether to enable the camera trigger.
    /// </summary>
    public void EnableCameraFOV(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableCameraFOV = enable;
        }
    }

    /// <summary>
    /// Whether to enable the scene fade.
    /// </summary>
    public void EnableSceneFade(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableSceneFade = enable;
        }
    }

    /// <summary>
    /// Whether to enable the footsteps trigger.
    /// </summary>
    /// <param name="enable"></param>
    public void EnableFootsteps(bool enable)
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.EnableFootsteps = enable;
        }
    }

    /// <summary>
    /// Stop all effects.
    /// </summary>
    public void StopEffects()
    {
        if (this.actorTriggers)
        {
            this.actorTriggers.StopEffects();
        }
    }

    /// <summary>
    /// Blink this character.
    /// </summary>
    public void Blink()
    {
        //if (this.actorBlinker != null)
        //{
        //    this.actorBlinker.Blink();
        //}
    }

    /// <summary>
    /// Play the projectile for an action.
    /// </summary>
    public void PlayProjectile(
        string action,
        Transform root,
        Transform hurtPoint,
        Action hited)
    {
        bool find = false;
        foreach (var projectile in this.projectiles)
        {
            if (projectile.Action != action)
            {
                continue;
            }

            if (projectile.Projectile.IsEmpty)
            {
                continue;
            }

            this.PlayProjectileImpl(projectile, root, hurtPoint, hited);
            find = true;
            break;
        }

        if (!find)
        {
            if (hited != null)
            {
                hited();
            }
        }
    }

    /// <summary>
    /// Play the skill action of specify point.
    /// </summary>
    public void PlayHurtShow(string skillAction, Transform root, Transform hurtPoint, Action perHit)
    {
        bool found = false;
        foreach (var hurt in this.hurts)
        {
            if (hurt.Action != skillAction)
            {
                continue;
            }

            if (!hurt.HurtEffect.IsEmpty)
            {
                Scheduler.RunCoroutine(this.PlayHurtEffect(
                    hurt, root, hurtPoint));
            }

            if (hurt.HitCount > 0)
            {
                Scheduler.RunCoroutine(this.PlayHitEffect(
                    hurt, root, hurtPoint, perHit));
            }
            else
            {
                perHit();
            }

            found = true;
            break;
        }

        if (!found)
        {
            perHit();
        }
    }

    /// <summary>
    /// Play the skill action of specify point.
    /// </summary>
    public void PlayHurt(
        string skillAction,
        Action<float> perHit)
    {
        bool found = false;
        foreach (var hurt in this.hurts)
        {
            if (hurt.Action != skillAction)
            {
                continue;
            }

            if (hurt.HitCount > 0)
            {
                Scheduler.RunCoroutine(this.PlayHit(
                    hurt, perHit));
            }
            else
            {
                perHit(1.0f);
            }

            found = true;
            break;
        }

        if (!found)
        {
            perHit(1.0f);
        }
    }

    /// <summary>
    /// Play the be hurt effect.
    /// </summary>
    public void PlayBeHurt()
    {
        if (!this.beHurtEffecct.IsEmpty)
        {
            this.StartCoroutine(
                this.PlayBeHitEffect(
                    this.beHurtEffecct, this.beHurtPosition, this.beHurtAttach));
        }
    }

    private void PlayProjectileImpl(
        ProjectileData projectile,
        Transform root,
        Transform hurtPoint,
        Action hited)
    {
        if (this.actorTriggers.EnableEffect)
        {
            var fromPosition = this.transform.position;
            if (projectile.FromPosition != null)
            {
                fromPosition = projectile.FromPosition.position;
            }
            Scheduler.RunCoroutine(this.PlayProjectileWithEffect(
                projectile, hurtPoint, fromPosition, hited));
        }
        else
        {
            Scheduler.RunCoroutine(this.PlayProjectileWithoutEffect(hited));
        }
    }

    private IEnumerator PlayProjectileWithEffect(
        ProjectileData projectile,
        Transform hurtPoint,
        Vector3 fromPosition,
        Action hited)
    {
        var wait = GameObjectPool.Instance.SpawnAsset(projectile.Projectile);
        yield return wait;

        if (this == null)
        {
            yield break;
        }

        if (!string.IsNullOrEmpty(wait.Error))
        {
            Debug.LogError(wait.Error);
            hited();
            yield break;
        }

        var go = wait.Instance;
        var instance = go.GetComponent<Projectile>();
        instance.transform.position = fromPosition;
        instance.transform.localScale = this.transform.lossyScale;
        instance.gameObject.SetLayerRecursively(this.gameObject.layer);
        instance.Play(
            this.transform.lossyScale,
            hurtPoint,
            this.gameObject.layer,
            () =>
            {
                if (hited != null)
                {
                    hited();
                }
            },
            () => GameObjectPool.Instance.Free(instance.gameObject));
    }

    private IEnumerator PlayProjectileWithoutEffect(Action hited)
    {
        yield return new WaitForSeconds(0.5f);

        if (this == null)
        {
            yield break;
        }

        hited();
    }

    private IEnumerator PlayHurtEffect(
        HurtData data, Transform root, Transform hurtPoint)
    {
        var wait = GameObjectPool.Instance.SpawnAsset(data.HurtEffect);
        yield return wait;

        if (this == null)
        {
            yield break;
        }

        var gameObject = wait.Instance;
        var instance = gameObject.GetComponent<EffectControl>();
        if (instance == null)
        {
            GameObjectPool.Instance.Free(gameObject);
            yield break;
        }

        instance.Reset();

        Transform targetPos = root;
        if (data.HurtPosition == HurtPositionEnum.HurtPoint)
        {
            targetPos = hurtPoint;
        }

        if (data.HurtRotation == HurtRotationEnum.Target)
        {
            instance.transform.SetPositionAndRotation(
                targetPos.position, targetPos.rotation);
        }
        else
        {
            var direction = targetPos.position - this.transform.position;
            direction.y = 0.0f;
            instance.transform.SetPositionAndRotation(
                targetPos.position,
                Quaternion.LookRotation(direction));
        }

        instance.FinishEvent += () =>
        {
            GameObjectPool.Instance.Free(gameObject);
        };
        instance.Play();
    }

    private IEnumerator PlayHitEffect(
        HurtData data,
        Transform root,
        Transform hurtPoint,
        Action perHit)
    {
        for (int i = 0; i < data.HitCount; ++i)
        {
            if (!data.HitEffect.IsEmpty)
            {
                var wait = GameObjectPool.Instance.SpawnAsset(data.HitEffect);
                yield return wait;

                if (this == null)
                {
                    yield break;
                }

                var gameObject = wait.Instance;
                var instance = gameObject.GetComponent<EffectControl>();
                if (instance == null)
                {
                    yield break;
                }

                if (root == null || hurtPoint == null)
                {
                    GameObjectPool.Instance.Free(gameObject);
                    yield break;
                }

                instance.Reset();

                Transform targetPos = root;
                if (data.HurtPosition == HurtPositionEnum.HurtPoint)
                {
                    targetPos = hurtPoint;
                }

                if (data.HurtRotation == HurtRotationEnum.Target)
                {
                    instance.transform.SetPositionAndRotation(
                        targetPos.position, targetPos.rotation);
                }
                else
                {
                    var direction = targetPos.position - this.transform.position;
                    direction.y = 0.0f;
                    instance.transform.SetPositionAndRotation(
                        targetPos.position,
                        Quaternion.LookRotation(direction));
                }

                instance.FinishEvent += () =>
                {
                    GameObjectPool.Instance.Free(gameObject);
                };
                instance.Play();
            }
            
            perHit();
            yield return new WaitForSeconds(data.HitInterval);
        }
    }

    private IEnumerator PlayBeHitEffect(
        AssetID asset,
        Transform position,
        bool attached)
    {
        if (position == null)
        {
            position = this.transform;
        }

        var wait = GameObjectPool.Instance.SpawnAsset(asset);
        yield return wait;

        var gameObject = wait.Instance;
        var instance = gameObject.GetComponent<EffectControl>();
        if (instance == null)
        {
            yield break;
        }

        instance.Reset();
        if (attached)
        {
            instance.transform.SetParent(position, false);
        }
        else
        {
            instance.transform.SetPositionAndRotation(
                position.position, position.rotation);
        }
        
        instance.FinishEvent += () =>
        {
            if (gameObject != null)
            {
                GameObjectPool.Instance.Free(gameObject);
            }
        };
        instance.Play();
    }

    private IEnumerator PlayHit(
        HurtData data,
        Action<float> perHit)
    {
        var random = new int[data.HitCount];
        var total = 0;
        for (int i = 0; i < random.Length; ++i)
        {
            random[i] = Random.Range(10, 99);
            total += random[i];
        }

        for (int i = 0; i < data.HitCount; ++i)
        {
            //var part = 0.5f * 1.0f / data.HitCount;
            //var percent = part + part * (random[i] / (float)total);

            // 貌似上面算法有问题 算出的最终百分比的战斗力不对， 所以改用下面的
            var percent = random[i] / (float)total;
            perHit(percent);
            yield return new WaitForSeconds(data.HitInterval);

            if (this == null)
            {
                break;
            }
        }
    }

    private void Awake()
    {
        this.animator = this.GetComponent<Animator>();
        Assert.IsNotNull(this.animator);

        this.actorBlinker = this.GetComponent<ActorBlinker>();
        this.actorTriggers = this.GetComponent<ActorTriggers>();
    }

    [Serializable]
    public struct ProjectileData
    {
        [SerializeField]
        public string Action;

        [SerializeField]
        public HurtPositionEnum HurtPosition;

        [SerializeField]
        [AssetType(typeof(Projectile))]
        public AssetID Projectile;

        [SerializeField]
        public Transform FromPosition;
    }

    [Serializable]
    public struct HurtData
    {
        [SerializeField]
        public string Action;

        [SerializeField]
        [AssetType(typeof(EffectControl))]
        public AssetID HurtEffect;

        [SerializeField]
        public HurtPositionEnum HurtPosition;

        [SerializeField]
        public HurtRotationEnum HurtRotation;

        [SerializeField]
        public int HitCount;

        [SerializeField]
        public float HitInterval;

        [SerializeField]
        [AssetType(typeof(EffectControl))]
        public AssetID HitEffect;

        [SerializeField]
        public HurtPositionEnum HitPosition;

        [SerializeField]
        public HurtRotationEnum HitRotation;
    }
}
