//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// The description of SceneLightSwitcher.
/// </summary>
public sealed class SceneLightSwitch : MonoBehaviour
{
    [SerializeField]
    private LightData warm;

    [SerializeField]
    private LightData cool;

    public void ActiveWarm()
    {
        this.cool.Deactive();
        this.warm.Active();
    }

    public void ActiveCool()
    {
        this.warm.Deactive();
        this.cool.Active();
    }

    [Serializable]
    public class LightData
    {
        [SerializeField]
        private AmbientMode ambientMode;

        [SerializeField]
        private float ambientIntensity;

        [SerializeField]
        private Color ambientLight;

        [SerializeField]
        private Color ambientSkyColor;

        [SerializeField]
        private Color ambientEquatorColor;

        [SerializeField]
        private Color ambientGroundColor;

        [SerializeField]
        private Cubemap customReflection;

        [SerializeField]
        private bool fog;

        [SerializeField]
        private GameObject lightGroup;

        public void Active()
        {
            RenderSettings.ambientMode = this.ambientMode;
            RenderSettings.ambientIntensity = this.ambientIntensity;
            RenderSettings.ambientLight = this.ambientLight;
            RenderSettings.ambientSkyColor = this.ambientSkyColor;
            RenderSettings.ambientEquatorColor = this.ambientEquatorColor;
            RenderSettings.ambientGroundColor = this.ambientGroundColor;
            RenderSettings.customReflection = this.customReflection;
            RenderSettings.fog = this.fog;
            if (this.lightGroup != null)
            {
                this.lightGroup.SetActive(true);
            }
        }

        public void Deactive()
        {
            if (this.lightGroup != null)
            {
                this.lightGroup.SetActive(false);
            }
        }
    }
}
