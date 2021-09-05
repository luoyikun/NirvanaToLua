//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System;
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// The quality control for <see cref="PostEffects"/>
    /// </summary>
    [RequireComponent(typeof(PostEffects))]
    public sealed class QualityControlPostEffects : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("The quality control for bloom.")]
        private bool[] bloomEnabledLevels;

        [SerializeField]
        [Tooltip("The quality control for color curve.")]
        private bool[] colorCurveEnabledLevels;

        [SerializeField]
        [Tooltip("The quality control for saturation.")]
        private bool[] saturationEnabledLevels;

        [SerializeField]
        [Tooltip("The quality control for saturation.")]
        private bool[] vignetteEnabledLevels;

        private PostEffects postEffects;
        private LinkedListNode<Action> listenNode;

        private void Awake()
        {
            this.postEffects = this.GetComponent<PostEffects>();
            this.listenNode = QualityConfig.ListenQualityChanged(
                this.OnQualityLevelChanged);
            this.OnQualityLevelChanged();
        }

        private void OnDestroy()
        {
            if (this.listenNode != null)
            {
                QualityConfig.UnlistenQualtiy(this.listenNode);
                this.listenNode = null;
            }
        }

        private void OnQualityLevelChanged()
        {
            var level = QualityConfig.QualityLevel;
            this.RefreshBloom(level);
            this.RefreshColorCurve(level);
            this.RefreshSaturation(level);
            this.RefreshVignette(level);
        }

        private void RefreshBloom(int level)
        {
            bool enabled = false;
            if (level < this.bloomEnabledLevels.Length)
            {
                enabled = this.bloomEnabledLevels[level];
            }

            this.postEffects.EnableBloom = enabled;
        }

        private void RefreshColorCurve(int level)
        {
            bool enabled = false;
            if (level < this.colorCurveEnabledLevels.Length)
            {
                enabled = this.colorCurveEnabledLevels[level];
            }

            this.postEffects.EnableColorCurve = enabled;
        }

        private void RefreshSaturation(int level)
        {
            bool enabled = false;
            if (level < this.saturationEnabledLevels.Length)
            {
                enabled = this.saturationEnabledLevels[level];
            }

            this.postEffects.EnableSaturation = enabled;
        }

        private void RefreshVignette(int level)
        {
            bool enabled = false;
            if (level < this.vignetteEnabledLevels.Length)
            {
                enabled = this.vignetteEnabledLevels[level];
            }

            this.postEffects.EnableVignette = enabled;
        }
    }
}
