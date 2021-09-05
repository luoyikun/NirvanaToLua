//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System;
    using UnityEngine;

    /// <summary>
    /// The quality config for a quality level.
    /// </summary>
    [Serializable]
    public sealed class QualityLevel
    {
        [SerializeField]
        private string name;

        [SerializeField]
        [Tooltip("Number of pixel lights to use.")]
        private int pixelLightCount = 1;

        [SerializeField]
        [Tooltip("Base texture level.")]
        [EnumInt("Full Res", 0)]
        [EnumInt("Half Res", 1)]
        [EnumInt("Quarter Res", 2)]
        [EnumInt("Eighth Res", 3)]
        private int masterTextureLimit = 0;

        [SerializeField]
        [Tooltip("When to enable anisotropic texturing.")]
        private AnisotropicFiltering anisotropicFiltering =
            AnisotropicFiltering.Enable;

        [SerializeField]
        [Tooltip("Screen anti aliasing.")]
        [EnumInt("Disabled", 0)]
        [EnumInt("2x Multi Sampling", 2)]
        [EnumInt("4x Multi Sampling", 4)]
        [EnumInt("8x Multi Sampling", 8)]
        private int antiAliasing = 0;

        [SerializeField]
        [Tooltip("Use soft blending for particles?")]
        private bool softParticles = false;

        [SerializeField]
        [Tooltip("Use soft blending for vegetation when using terrain?")]
        private bool softVegetation = false;

        [SerializeField]
        [Tooltip("Allow real-time rendering of Reflection Probes?")]
        private bool realtimeReflectionProbes = false;

        [SerializeField]
        [Tooltip("Make billboards face towards camera position. Otherwise they face towards camera plane. This makes billboards look nicer when camera rotates but is more expensive to render.")]
        private bool billboardsFaceCameraPosition = true;

        [SerializeField]
        [Tooltip("Shadow quality.")]
        private ShadowQuality shadows = ShadowQuality.All;

        [SerializeField]
        [Tooltip("Shadow resolution.")]
        private ShadowResolution shadowResolution = ShadowResolution.VeryHigh;

        [SerializeField]
        [Tooltip("Shadow projection.")]
        private ShadowProjection shadowProjection = ShadowProjection.CloseFit;

        [SerializeField]
        [Tooltip("Shadow distance.")]
        private float shadowDistance = 20;

        [SerializeField]
        [Tooltip("Offset shadow near panel too account for large triangles being distorted by shadow pancaking.")]
        private float shadowNearPlaneOffset = 2;

        [SerializeField]
        [Tooltip("Number of cascades for directional light shadows.")]
        [EnumInt("No Cascades", 0)]
        [EnumInt("Two Cascades", 2)]
        [EnumInt("Four Cascades", 4)]
        private int shadowCascades = 0;

        [SerializeField]
        private float shadowCascade2Split = 0.33f;

        [SerializeField]
        private Vector3 shadowCascade4Split = new Vector3(0.067f, 0.2f, 0.467f);

        [SerializeField]
        [Tooltip("Bone count for mesh skinning.")]
        private BlendWeights blendWeights = BlendWeights.FourBones;

        [SerializeField]
        [Tooltip("Limit refresh rate to avoid tearing.")]
        [EnumInt("Don't Sync", 0)]
        [EnumInt("Every V Blank", 1)]
        [EnumInt("Every Second V Black", 2)]
        private int vSyncCount = 1;

        [SerializeField]
        private float lodBias = 2;

        [SerializeField]
        private int maximumLODLevel = 0;

        [SerializeField]
        [Tooltip("Number of rays to cast for approximate world collisions.")]
        private int particleRaycastBudget = 4096;

        [SerializeField]
        private int maxQueuedFrames = 2;

        [SerializeField]
        [Tooltip("Async Upload TimeSlice in Milliseconds.")]
        private int asyncUploadTimeSlice = 2;

        [SerializeField]
        [Tooltip("Async Upload Ring Buffer Size in MB.")]
        private int asyncUploadBufferSize = 4;

        private int overrideShadowQuality = -1;

        /// <summary>
        /// Gets the name of this quality level.
        /// </summary>
        public string Name
        {
            get { return this.name; }
        }
        public ShadowQuality OverrideShadows
        {
            set { overrideShadowQuality = (int)value; }
        }

        /// <summary>
        /// Active this quality config.
        /// </summary>
        public void Active()
        {
            // Rendering
            QualitySettings.pixelLightCount = this.pixelLightCount;
            QualitySettings.masterTextureLimit = this.masterTextureLimit;
            QualitySettings.anisotropicFiltering = this.anisotropicFiltering;
            QualitySettings.antiAliasing = this.antiAliasing;
            QualitySettings.softParticles = this.softParticles;
            QualitySettings.softVegetation = this.softVegetation;
            QualitySettings.realtimeReflectionProbes =
                this.realtimeReflectionProbes;
            QualitySettings.billboardsFaceCameraPosition =
                this.billboardsFaceCameraPosition;

            // Shadows
            QualitySettings.shadows = -1 != overrideShadowQuality ? (ShadowQuality)this.overrideShadowQuality : this.shadows;

            QualitySettings.shadowResolution = this.shadowResolution;
            QualitySettings.shadowProjection = this.shadowProjection;
#if UNITY_EDITOR
            this.shadowDistance = 140;
#else
             QualitySettings.shadowDistance = this.shadowDistance;
#endif

            QualitySettings.shadowNearPlaneOffset = this.shadowNearPlaneOffset;
            QualitySettings.shadowCascades = this.shadowCascades;
            QualitySettings.shadowCascade2Split = this.shadowCascade2Split;
            QualitySettings.shadowCascade4Split = this.shadowCascade4Split;

            // Other
            QualitySettings.blendWeights = this.blendWeights;
            QualitySettings.vSyncCount = this.vSyncCount;
            QualitySettings.lodBias = this.lodBias;
            QualitySettings.maximumLODLevel = this.maximumLODLevel;
            QualitySettings.particleRaycastBudget = this.particleRaycastBudget;
            QualitySettings.maxQueuedFrames = this.maxQueuedFrames;
            QualitySettings.asyncUploadBufferSize = this.asyncUploadBufferSize;
            QualitySettings.asyncUploadTimeSlice = this.asyncUploadTimeSlice;
        }
    }
}
