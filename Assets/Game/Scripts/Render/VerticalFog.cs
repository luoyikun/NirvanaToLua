//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// The vertical fog support, it must add to a camera.
    /// </summary>
    [ExecuteInEditMode]
    [DisallowMultipleComponent]
    //[RequireComponent(typeof(Camera))]
    public sealed class VerticalFog : MonoBehaviour
    {
        private static int? verticalFogColorKey;
        private static int? verticalFogParamKey;

        [SerializeField]
        [Tooltip("The color of the fog.")]
        private Color color = new Color(0.35f, 0.35f, 0.65f, 1.0f);

        [SerializeField]
        [Tooltip("The density of the fog.")]
        private float density = 0.5f;

        [SerializeField]
        [Tooltip("The start height of the fog.")]
        private float startHeight = 0;

        [SerializeField]
        [Tooltip("The end height of the fog.")]
        private float endHeight = -5;

        private Color vfogColorKeeper;
        private float vfogDensityKeeper;
        private float vfogStartHeightKeeper;
        private float vfogEndHeightKeeper;

        private Color vfogColorFrom;
        private float vfogDensityFrom;
        private float vfogStartHeightFrom;
        private float vfogEndHeightFrom;

        private Color vfogColorTo;
        private float vfogDensityTo;
        private float vfogStartHeightTo;
        private float vfogEndHeightTo;

        private float transmitLeftTime = -1.0f;
        private float transmitTotalTime = -1.0f;

        private LinkedList<AreaAtmosphere> atmosphereStack =
            new LinkedList<AreaAtmosphere>();

        /// <summary>
        /// Gets the shader property ID: _VerticalFogColor
        /// </summary>
        public static int VerticalFogColorKey
        {
            get
            {
                if (!verticalFogColorKey.HasValue)
                {
                    verticalFogColorKey = Shader.PropertyToID("_VerticalFogColor");
                }

                return verticalFogColorKey.Value;
            }
        }

        /// <summary>
        /// Gets the shader property ID: _VerticalFogParam
        /// </summary>
        public static int VerticalFogParamKey
        {
            get
            {
                if (!verticalFogParamKey.HasValue)
                {
                    verticalFogParamKey = Shader.PropertyToID("_VerticalFogParam");
                }

                return verticalFogParamKey.Value;
            }
        }

        /// <summary>
        /// Gets or sets the fog color.
        /// </summary>
        public Color Color
        {
            get { return this.color; }
            set { this.color = value; }
        }

        /// <summary>
        /// Gets or sets the fog density.
        /// </summary>
        public float Density
        {
            get { return this.density; }
            set { this.density = value; }
        }

        /// <summary>
        /// Gets or sets the fog start height.
        /// </summary>
        public float StartHeight
        {
            get { return this.startHeight; }
            set { this.startHeight = value; }
        }

        /// <summary>
        /// Gets or sets the fog end height.
        /// </summary>
        public float EndHeight
        {
            get { return this.endHeight; }
            set { this.endHeight = value; }
        }

        public LinkedListNode<AreaAtmosphere> AddAreaAtmosphere(
            AreaAtmosphere atmosphere)
        {
            var node = this.atmosphereStack.AddLast(atmosphere);
            this.UpdateAtmosphere();
            return node;
        }

        public void RemoveAreaAtmosphere(
            LinkedListNode<AreaAtmosphere> node)
        {
            this.atmosphereStack.Remove(node);
            this.UpdateAtmosphere();
        }

        public void OnPreRender()
        {
            if (this.enabled)
            {
                this.UpdateShaderSetting();
            }
        }

        public void OnPostRender()
        {
            Shader.DisableKeyword("ENABLE_VERTICAL_FOG");
        }

        private void UpdateShaderSetting()
        {
            Shader.EnableKeyword("ENABLE_VERTICAL_FOG");
            Shader.SetGlobalColor(
                VerticalFogColorKey, this.color);
            var mistParam = new Vector4(
                this.density,
                this.startHeight,
                this.endHeight,
                0.0f);
            Shader.SetGlobalVector(
                VerticalFogParamKey, mistParam);
        }

        private void Update()
        {
            if (this.transmitLeftTime < 0.0f)
            {
                return;
            }

            this.transmitLeftTime -= Time.deltaTime;
            var k = 1.0f - (this.transmitLeftTime / this.transmitTotalTime);

            this.color = Color.Lerp(
                this.vfogColorFrom, this.vfogColorTo, k);
            this.density = Mathf.Lerp(
                this.vfogDensityFrom, this.vfogDensityTo, k);
            this.startHeight = Mathf.Lerp(
                this.vfogStartHeightFrom, this.vfogStartHeightTo, k);
            this.endHeight = Mathf.Lerp(
                this.vfogEndHeightFrom, this.vfogEndHeightTo, k);
        }

        private void UpdateAtmosphere()
        {
            if (atmosphereStack.Count == 1)
            {
                vfogColorKeeper = this.color;
                vfogDensityKeeper = this.density;
                vfogStartHeightKeeper = this.startHeight;
                vfogEndHeightKeeper = this.endHeight;
            }

            vfogColorFrom = this.color;
            vfogDensityFrom = this.density;
            vfogStartHeightFrom = this.startHeight;
            vfogEndHeightFrom = this.endHeight;

            if (atmosphereStack.Count > 0)
            {
                var top = atmosphereStack.Last.Value;
                vfogColorTo = top.VFogColor;
                vfogDensityTo = top.VFogDensity;
                vfogStartHeightTo = top.VFogStartHeight;
                vfogEndHeightTo = top.VFogEndHeight;
                transmitLeftTime = top.TransmitTime;
                transmitTotalTime = top.TransmitTime;
            }
            else
            {
                vfogColorTo = vfogColorKeeper;
                vfogDensityTo = vfogDensityKeeper;
                vfogStartHeightTo = vfogStartHeightKeeper;
                vfogEndHeightTo = vfogEndHeightKeeper;
                transmitLeftTime = transmitTotalTime;
            }
        }
    }
}
