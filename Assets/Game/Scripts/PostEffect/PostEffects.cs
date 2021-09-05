//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using UnityEngine;
using DG.Tweening;

/// <summary>
/// The post effect used to control all post effects into one stack. It 
/// combine different post effects into one pass, to minimize the drawcall, 
/// and reduce the pixel shader payload.
/// </summary>
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public sealed class PostEffects : MonoBehaviour
{
    private static int threshholdID = -1;
    private static int offsetsID = -1;
    private static int bloomTexID = -1;
    private static int bloomIntensityID = -1;
    private static int saturationID = -1;
    private static int curveTexID = -1;
    private static int vignetteIntensityID = -1;
    private static int waveStengthID = -1;
    private static int motionBlurDistID = -1;
    private static int motionBlurStrengthID = -1;

    [SerializeField]
    [Tooltip("The shader for down sample.")]
    private Shader downSampleShader;

    [SerializeField]
    [Tooltip("The shader for bright pass.")]
    private Shader brightPassShader;

    [SerializeField]
    [Tooltip("The shader for blur pass.")]
    private Shader blurPassShader;

    [SerializeField]
    [Tooltip("The shader for combine pass.")]
    private Shader combinePassShader;

    [SerializeField]
    [Tooltip("The shader for wave pass.")]
    private Shader wavePassShader;

    [SerializeField]
    private Shader motionBlurPassShader;

    [SerializeField]
    [Tooltip("Whether to enable the bloom.")]
    private bool enableBloom;

    [SerializeField]
    [Tooltip("The bloom blend mode.")]
    private BloomBlendMode bloomBlendMode =
        BloomBlendMode.Add;

    [SerializeField]
    [Tooltip("The bloom intensity.")]
    private float bloomIntensity = 0.5f;

    [SerializeField]
    [Tooltip("The bloom threshold.")]
    [Range(-0.05f, 4.0f)]
    private float bloomThreshold = 0.5f;

    [SerializeField]
    [Tooltip("The bloom threshold color.")]
    private Color bloomThresholdColor = Color.white;

    [SerializeField]
    [Tooltip("The bloom blur spread.")]
    [Range(0.1f, 10.0f)]
    private float bloomBlurSpread = 2.5f;

    [SerializeField]
    [Tooltip("Whether to enable saturation control.")]
    private bool enableColorCurve;

    [SerializeField]
    [Tooltip("The color correction curve for red channel.")]
    private AnimationCurve redChannelCurve =
        new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

    [SerializeField]
    [Tooltip("The color correction curve for green channel.")]
    private AnimationCurve greenChannelCurve =
        new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

    [SerializeField]
    [Tooltip("The color correction curve for blue channel.")]
    private AnimationCurve blueChannelCurve =
        new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

    [SerializeField]
    [Tooltip("Whether to enable saturation control.")]
    private bool enableSaturation;

    [SerializeField]
    [Tooltip("The saturation for the image.")]
    [Range(0.0f, 5.0f)]
    private float saturation = 1.0f;

    [SerializeField]
    [Tooltip("Whether to enable vignette.")]
    private bool enableVignette;

    [SerializeField]
    [Tooltip("The intensity for vignette.")]
    private float vignetteIntensity = 0.375f;

    [SerializeField]
    [Tooltip("Whether to enable blur the screen.")]
    private bool enableBlur;

    [SerializeField]
    private bool enableMotionBlur;
    [SerializeField]
    private float motionBlurDist = 0.3f;
    [SerializeField]
    private float motionBlurStrength = 3.5f;

    [SerializeField]
    [Tooltip("The blur spread.")]
    [Range(0.0f, 10.0f)]
    private float blurSpread = 2.5f;

    [SerializeField]
    [Tooltip("The wave strength.")]
    [Range(0.0f, 1.0f)]
    private float waveStrength = 0.02f;

    private new Camera camera;

    private bool rebuildResource = true;
    private Texture2D curveTex;
    private Material downSampleMaterial;
    private Material brightPassMaterial;
    private Material blurPassMaterial;
    private Material combinePassMaterial;
    private Material wavePassMaterial;
    private Material motionBlurPassMaterial;

    /// <summary>
    /// The bloom blend mode.
    /// </summary>
    private enum BloomBlendMode
    {
        /// <summary>
        /// Blend the bloom with the image using screen mode.
        /// </summary>
        Screen = 0,

        /// <summary>
        /// Blend the bloom with the image using add mode.
        /// </summary>
        Add = 1,
    }

    private static int ThreshholdID
    {
        get
        {
            if (threshholdID == -1)
            {
                threshholdID = Shader.PropertyToID("_Threshhold");
            }

            return threshholdID;
        }
    }

    private static int OffsetsID
    {
        get
        {
            if (offsetsID == -1)
            {
                offsetsID = Shader.PropertyToID("_Offsets");
            }

            return offsetsID;
        }
    }

    private static int WaveStrengthID
    {
        get
        {
            if (waveStengthID == -1)
            {
                waveStengthID = Shader.PropertyToID("_WaveStrength");
            }

            return waveStengthID;
        }
    }

    private static int BloomTexID
    {
        get
        {
            if (bloomTexID == -1)
            {
                bloomTexID = Shader.PropertyToID("_BloomTex");
            }

            return bloomTexID;
        }
    }

    private static int BloomIntensityID
    {
        get
        {
            if (bloomIntensityID == -1)
            {
                bloomIntensityID = Shader.PropertyToID("_BloomIntensity");
            }

            return bloomIntensityID;
        }
    }

    private static int SaturationID
    {
        get
        {
            if (saturationID == -1)
            {
                saturationID = Shader.PropertyToID("_Saturation");
            }

            return saturationID;
        }
    }

    private static int CurveTexID
    {
        get
        {
            if (curveTexID == -1)
            {
                curveTexID = Shader.PropertyToID("_CurveTex");
            }

            return curveTexID;
        }
    }

    private static int VignetteIntensityID
    {
        get
        {
            if (vignetteIntensityID == -1)
            {
                vignetteIntensityID = Shader.PropertyToID("_VignetteIntensity");
            }

            return vignetteIntensityID;
        }
    }

    private static int MotionBlurDistID
    {
        get
        {
            if (motionBlurDistID == -1)
            {
                motionBlurDistID = Shader.PropertyToID("_fSampleDist");
            }

            return motionBlurDistID;
        }
    }

    private static int MotionBlurStrengthID
    {
        get
        {
            if (motionBlurStrengthID == -1)
            {
                motionBlurStrengthID = Shader.PropertyToID("_fSampleStrength");
            }

            return motionBlurStrengthID;
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable bloom.
    /// </summary>
    public bool EnableBloom
    {
        get
        {
            return this.enableBloom;
        }

        set
        {
            if (this.enableBloom != value)
            {
                this.enableBloom = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable color curve.
    /// </summary>
    public bool EnableColorCurve
    {
        get
        {
            return this.enableColorCurve;
        }

        set
        {
            if (this.enableColorCurve != value)
            {
                this.enableColorCurve = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable saturation.
    /// </summary>
    public bool EnableSaturation
    {
        get
        {
            return this.enableSaturation;
        }

        set
        {
            if (this.enableSaturation != value)
            {
                this.enableSaturation = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }

    /// <summary>
    /// Gets or sets a value indicating whether enable Vignette.
    /// </summary>
    public bool EnableVignette
    {
        get
        {
            return this.enableVignette;
        }

        set
        {
            if (this.enableVignette != value)
            {
                this.enableVignette = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }


    /// <summary>
    /// Gets or sets a value indicating whether enable blur.
    /// </summary>
    public bool EnableBlur
    {
        get
        {
            return this.enableBlur;
        }

        set
        {
            if (this.enableBlur != value)
            {
                this.enableBlur = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }

    /// <summary>
    /// Gets or sets a value control the blur spread.
    /// </summary>
    public float BlurSpread
    {
        get
        {
            return this.blurSpread;
        }

        set
        {
            this.blurSpread = value;
        }
    }

    /// <summary>
    /// Gets or sets a value control the blur spread.
    /// </summary>
    public float WaveStrength
    {
        get
        {
            return this.waveStrength;
        }

        set
        {
            this.waveStrength = value;
        }
    }

    /// <summary>
    /// Do change the blur spread by animation.
    /// </summary>
    public void DoBlurSpread(float endValue, float duration)
    {
        DOTween.To(
            () => this.blurSpread,
            v =>
            {
                this.blurSpread = v;
            },
            endValue,
            duration);
    }

    /// <summary>
    /// Do change the wave by animation.
    /// </summary>
    public void DoWave(float endValue, float duration)
    {
        DOTween.To(
            () => this.waveStrength,
            v =>
            {
                this.waveStrength = v;
            },
            endValue,
            duration);
    }

    public bool EnableMotionBlur
    {
        get
        {
            return this.enableMotionBlur; ;
        }

        set
        {
            if (this.enableMotionBlur != value)
            {
                this.enableMotionBlur = value;
                this.rebuildResource = true;
                this.CheckEnabled();
            }
        }
    }

    public float MotionBlurDist
    {
        set
        {
            this.motionBlurDist = value;
        }
    }

    public float MotionBlurStrength
    {
        set
        {
            this.motionBlurStrength = value;
        }
    }

    public void DoMotionBlurStrength(float endValue, float duration)
    {
        DOTween.To(
            () => this.motionBlurStrength,
            v =>
            {
                this.motionBlurStrength = v;
            },
            endValue,
            duration);
    }

    private void Awake()
    {
        this.camera = this.GetComponent<Camera>();
    }

    private void OnEnable()
    {
        this.CheckSupport();
        if (this.enabled)
        {
            this.SetupResource();
            this.rebuildResource = false;
            this.CheckEnabled();
        }
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
        this.rebuildResource = true;
    }
#endif

    private void CheckSupport()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            Debug.LogWarning(
                "The system does not support image effects.");
            this.enabled = false;
            return;
        }

        if (this.combinePassShader == null || 
            !this.combinePassShader.isSupported)
        {
            Debug.LogWarning(
                "The system does not support the combine pass shader.");
            this.enabled = false;
            return;
        }

        if (this.enableBloom)
        {
            if (this.downSampleShader == null || !this.downSampleShader.isSupported)
            {
                Debug.LogWarning(
                    "The system does not support the down sample shader, turn off the bloom.");
                this.enableBloom = false;
            }
        }

        if (this.enableBloom)
        {
            if (this.brightPassShader == null || !this.brightPassShader.isSupported)
            {
                Debug.LogWarning(
                    "The system does not support the bright pass shader, turn off the bloom.");
                this.enableBloom = false;
            }
        }

        if (this.enableBloom)
        {
            if (this.blurPassShader == null || !this.blurPassShader.isSupported)
            {
                Debug.LogWarning(
                    "The system does not support the blur pass shader, turn off the bloom.");
                this.enableBloom = false;
            }
        }
    }

    private void SetupResource()
    {
        if (this.enableBloom)
        {
            if (this.downSampleMaterial == null)
            {
                this.downSampleMaterial = new Material(this.downSampleShader);
            }

            if (this.brightPassMaterial == null)
            {
                this.brightPassMaterial = new Material(this.brightPassShader);
            }

            if (this.blurPassMaterial == null)
            {
                this.blurPassMaterial = new Material(this.blurPassShader);
            }
        }

        if (this.enableBlur)
        {
            if (this.blurPassMaterial == null)
            {
                this.blurPassMaterial = new Material(this.blurPassShader);
            }

            if (this.wavePassMaterial == null)
            {
                this.wavePassMaterial = new Material(this.wavePassShader);
            }
        }

        if (this.combinePassMaterial == null)
        {
            this.combinePassMaterial = new Material(this.combinePassShader);
        }

        if (this.enableBloom)
        {
            switch (this.bloomBlendMode)
            {
            case BloomBlendMode.Add:
                this.combinePassMaterial.EnableKeyword("_BLOOM_ADD");
                this.combinePassMaterial.DisableKeyword("_BLOOM_SCREEN");
                break;
            case BloomBlendMode.Screen:
                this.combinePassMaterial.DisableKeyword("_BLOOM_ADD");
                this.combinePassMaterial.EnableKeyword("_BLOOM_SCREEN");
                break;
            }
        }
        else
        {
            this.combinePassMaterial.DisableKeyword("_BLOOM_ADD");
            this.combinePassMaterial.DisableKeyword("_BLOOM_SCREEN");
        }

        if (this.enableColorCurve)
        {
            if (this.curveTex == null)
            {
                this.curveTex = new Texture2D(256, 4, TextureFormat.ARGB32, false, true);
                this.curveTex.hideFlags = HideFlags.DontSave;
                this.curveTex.wrapMode = TextureWrapMode.Clamp;
                this.curveTex.filterMode = FilterMode.Bilinear;
            }

            if (this.redChannelCurve != null && 
                this.greenChannelCurve != null && 
                this.blueChannelCurve != null)
            {
                for (int i = 0; i < 256; ++i)
                {
                    var k = (float)i / 256;

                    var rCh = Mathf.Clamp(this.redChannelCurve.Evaluate(k), 0.0f, 1.0f);
                    var gCh = Mathf.Clamp(this.greenChannelCurve.Evaluate(k), 0.0f, 1.0f);
                    var bCh = Mathf.Clamp(this.blueChannelCurve.Evaluate(k), 0.0f, 1.0f);

                    this.curveTex.SetPixel(i, 0, new Color(rCh, rCh, rCh));
                    this.curveTex.SetPixel(i, 1, new Color(gCh, gCh, gCh));
                    this.curveTex.SetPixel(i, 2, new Color(bCh, bCh, bCh));
                }

                this.curveTex.Apply();
            }

            this.combinePassMaterial.EnableKeyword("_COLOR_CURVE");
        }
        else
        {
            this.combinePassMaterial.DisableKeyword("_COLOR_CURVE");
        }

        if (this.enableSaturation)
        {
            this.combinePassMaterial.EnableKeyword("_SATURATION");
        }
        else
        {
            this.combinePassMaterial.DisableKeyword("_SATURATION");
        }

        if (this.enableVignette)
        {
            this.combinePassMaterial.EnableKeyword("_VIGNETTE_INTENSITY");
        }
        else
        {
            this.combinePassMaterial.DisableKeyword("_VIGNETTE_INTENSITY");
        }

        if (this.enableMotionBlur)
        {
            if (this.motionBlurPassMaterial == null)
            {
                this.motionBlurPassMaterial = new Material(this.motionBlurPassShader);
            }
        }
    }

    private void CheckEnabled()
    {
        this.enabled = this.EnableBloom
                        || this.EnableColorCurve
                        || this.EnableSaturation
                        || this.EnableSaturation
                        || this.EnableVignette
                        || this.EnableBlur
                        || this.enableMotionBlur;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!this.enableBloom &&
            !this.enableSaturation &&
            !this.enableColorCurve &&
            !this.enableVignette &&
            !this.enableBlur &&
            !this.enableMotionBlur)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if (this.rebuildResource)
        {
            this.SetupResource();
            rebuildResource = false;
        }

        RenderTexture blur4 = null;
        if (this.enableBloom)
        {
            var doHdr = this.camera.allowHDR;
            //var rtFormat = (doHdr) ? RenderTextureFormat.ARGBHalf : 
            //    RenderTextureFormat.Default;
            var rtFormat = RenderTextureFormat.Default;
            var rtW2 = source.width / 2;
            var rtH2 = source.height / 2;
            var rtW4 = source.width / 4;
            var rtH4 = source.height / 4;

            float widthOverHeight = (1.0f * source.width) / (1.0f * source.height);
            float oneOverBaseSize = 1.0f / 512.0f;

            // downsample
            var halfRezColorDown = RenderTexture.GetTemporary(rtW2, rtH2, 0, rtFormat);
            Graphics.Blit(source, halfRezColorDown);

            var quarterRezColor = RenderTexture.GetTemporary(rtW4, rtH4, 0, rtFormat);
            Graphics.Blit(halfRezColorDown, quarterRezColor, this.downSampleMaterial, 0);
            RenderTexture.ReleaseTemporary(halfRezColorDown);

            // cut colors (thresholding)
            var secondQuarterRezColor = RenderTexture.GetTemporary(rtW4, rtH4, 0, rtFormat);
            var threshColor = this.bloomThreshold * this.bloomThresholdColor;
            this.brightPassMaterial.SetVector(ThreshholdID, threshColor);
            Graphics.Blit(quarterRezColor, secondQuarterRezColor, this.brightPassMaterial, 0);
            RenderTexture.ReleaseTemporary(quarterRezColor);

            // vertical blur
            blur4 = RenderTexture.GetTemporary(rtW4, rtH4, 0, rtFormat);
            var offset = new Vector4(0.0f, this.bloomBlurSpread * oneOverBaseSize, 0.0f, 0.0f);
            this.blurPassMaterial.SetVector(OffsetsID, offset);
            Graphics.Blit(secondQuarterRezColor, blur4, this.blurPassMaterial, 0);
            RenderTexture.ReleaseTemporary(secondQuarterRezColor);
            secondQuarterRezColor = blur4;

            // horizontal blur
            blur4 = RenderTexture.GetTemporary(rtW4, rtH4, 0, rtFormat);
            offset = new Vector4((this.bloomBlurSpread / widthOverHeight) * oneOverBaseSize, 0.0f, 0.0f, 0.0f);
            this.blurPassMaterial.SetVector(OffsetsID, offset);
            Graphics.Blit(secondQuarterRezColor, blur4, this.blurPassMaterial, 0);
            RenderTexture.ReleaseTemporary(secondQuarterRezColor);

            this.combinePassMaterial.SetTexture(BloomTexID, blur4);
            this.combinePassMaterial.SetFloat(BloomIntensityID, this.bloomIntensity);
        }

        // Do combine pass.
        if (this.enableSaturation)
        {
            this.combinePassMaterial.SetFloat(SaturationID, this.saturation);
        }

        if (this.enableColorCurve)
        {
            this.combinePassMaterial.SetTexture(CurveTexID, this.curveTex);
        }

        if (this.enableVignette)
        {
            this.combinePassMaterial.SetFloat(
                VignetteIntensityID, this.vignetteIntensity);
        }

        if (this.enableBloom || 
            this.enableSaturation ||
            this.enableColorCurve ||
            this.enableVignette)
        {
            if (this.enableBlur && !enableMotionBlur)
            {
                var temp1 = RenderTexture.GetTemporary(
                    source.width, source.height, 0, RenderTextureFormat.Default);
                var temp2 = RenderTexture.GetTemporary(
                    source.width, source.height, 0, RenderTextureFormat.Default);
                Graphics.Blit(source, temp1, this.combinePassMaterial, 0);

                float widthOverHeight = (1.0f * source.width) / (1.0f * source.height);
                float oneOverBaseSize = 1.0f / 512.0f;

                // vertical blur
                var offset = new Vector4(0.0f, this.blurSpread * oneOverBaseSize, 0.0f, 0.0f);
                this.blurPassMaterial.SetVector(OffsetsID, offset);
                Graphics.Blit(temp1, temp2, this.blurPassMaterial, 0);

                // horizontal blur
                offset = new Vector4((this.blurSpread / widthOverHeight) * oneOverBaseSize, 0.0f, 0.0f, 0.0f);
                this.wavePassMaterial.SetVector(OffsetsID, offset);
                this.wavePassMaterial.SetVector(WaveStrengthID, new Vector4(this.waveStrength, this.waveStrength));
                Graphics.Blit(temp2, destination, this.wavePassMaterial, 0);

                RenderTexture.ReleaseTemporary(temp1);
                RenderTexture.ReleaseTemporary(temp2);
            }
            else
            {
                Graphics.Blit(source, destination, this.combinePassMaterial, 0);
            }
        }
        else if (!enableMotionBlur)
        {
            var temp = RenderTexture.GetTemporary(
                source.width, source.height, 0, RenderTextureFormat.Default);

            float widthOverHeight = (1.0f * source.width) / (1.0f * source.height);
            float oneOverBaseSize = 1.0f / 512.0f;

            // vertical blur
            var offset = new Vector4(0.0f, this.blurSpread * oneOverBaseSize, 0.0f, 0.0f);
            this.blurPassMaterial.SetVector(OffsetsID, offset);
            Graphics.Blit(source, temp, this.blurPassMaterial, 0);

            // horizontal blur
            offset = new Vector4((this.blurSpread / widthOverHeight) * oneOverBaseSize, 0.0f, 0.0f, 0.0f);
            this.wavePassMaterial.SetVector(OffsetsID, offset);
            this.wavePassMaterial.SetVector(WaveStrengthID, new Vector4(this.waveStrength, this.waveStrength));
            Graphics.Blit(temp, destination, this.wavePassMaterial, 0);

            RenderTexture.ReleaseTemporary(temp);
        }
        
        if (blur4 != null)
        {
            RenderTexture.ReleaseTemporary(blur4);
        }

        if (enableMotionBlur)
        {
            this.motionBlurPassMaterial.SetFloat(
                MotionBlurDistID, this.motionBlurDist);

            this.motionBlurPassMaterial.SetFloat(
                MotionBlurStrengthID, this.motionBlurStrength);

            Graphics.Blit(source, destination, this.motionBlurPassMaterial, 0);
        }
    }
}
