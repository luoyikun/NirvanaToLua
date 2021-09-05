//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System;
    using UnityEngine;

    [Serializable]
    public sealed class ProjectileObject
    {
        [SerializeField]
        private EffectControl effectPrefab;

        [SerializeField]
        private float delay = 0.0f;

        [SerializeField]
        private float speedBase = 5.0f;

        [SerializeField]
        private AnimationCurve speedCurve = 
            AnimationCurve.Linear(0.0f, 1.0f, 1.0f, 1.0f);

        [SerializeField]
        private float speedMultiplier = 5.0f;

        [SerializeField]
        private AnimationCurve moveXCurve = 
            AnimationCurve.Linear(0.0f, 1.0f, 1.0f, 1.0f);

        [SerializeField]
        private float moveXMultiplier = 1.0f;

        [SerializeField]
        private AnimationCurve moveYCurve = 
            AnimationCurve.Linear(0.0f, 1.0f, 1.0f, 1.0f);

        [SerializeField]
        private float moveYMultiplier = 1.0f;

        [SerializeField]
        private Vector3 targetOffset = Vector3.zero;

        [SerializeField]
        private EffectControl hitEffect;

        private Vector3 sourceScale;
        private float delayTime;
        private int layer;
        private EffectControl effect;
        private Vector3 startPosition;
        private Vector3 normalPosition;
        private bool playing;
        private bool started;

        public bool Playing
        {
            get { return this.playing; }
        }

        public void Play(Vector3 sourceScale, Vector3 position, int layer)
        {
            this.sourceScale = sourceScale;
            this.layer = layer;
            this.normalPosition = position;
            this.startPosition = position;
            this.delayTime = this.delay;
            this.playing = true;
            this.started = false;
        }

        public void Update(Vector3 targetPosition)
        {
            if (!this.playing)
            {
                return;
            }

            if (!this.started)
            {
                this.delayTime -= Time.deltaTime;
                if (this.delayTime <= 0.0f)
                {
                    var effectInstance = GameObjectPool.Instance.Spawn(
                        this.effectPrefab, null);
                    effectInstance.FinishEvent += () => 
                        GameObjectPool.Instance.Free(effectInstance.gameObject);
                    effectInstance.Reset();
                    effectInstance.Play();

                    this.effect = effectInstance;
                    this.started = true;
                }
                else
                {
                    return;
                }
            }

            targetPosition += this.targetOffset;
            var offset = targetPosition - this.normalPosition;
            var total = targetPosition - this.startPosition;
            var radio = 1.0f - offset.magnitude / total.magnitude;

            var direction = offset.normalized;
            var speed = this.speedBase + 
                this.speedMultiplier * this.speedCurve.Evaluate(radio);
            var velocity = direction * speed;

            var movement = velocity * Time.deltaTime;
            if (offset.sqrMagnitude > movement.sqrMagnitude)
            {
                this.normalPosition += movement;
                var movementPosition = this.normalPosition;
                var movementUp = Vector3.up;
                var movementRight = Vector3.Cross(direction, movementUp);

                if (!Mathf.Approximately(this.moveXMultiplier, 0.0f))
                {
                    var moveX = 
                        this.moveXMultiplier * this.moveXCurve.Evaluate(radio);
                    movementPosition += movementRight * moveX;
                }

                if (!Mathf.Approximately(this.moveYMultiplier, 0.0f))
                {
                    var moveY = 
                        this.moveYMultiplier * this.moveYCurve.Evaluate(radio);
                    movementPosition += movementUp * moveY;
                }

                this.effect.transform.position = movementPosition;
                this.effect.transform.LookAt(targetPosition);
            }
            else
            {
                this.effect.transform.position = targetPosition;
                this.effect.Stop();
                if (this.hitEffect != null)
                {
                    var effect = GameObjectPool.Instance.Spawn(hitEffect, null);
                    effect.transform.SetPositionAndRotation(
                        this.effect.transform.position, 
                        this.effect.transform.rotation);

                    effect.transform.localScale = this.sourceScale;
                    effect.gameObject.SetLayerRecursively(this.layer);

                    effect.FinishEvent += 
                        () => GameObjectPool.Instance.Free(effect.gameObject);
                    effect.Reset();
                    effect.Play();
                }
                this.playing = false;
            }
        }
    }
}
