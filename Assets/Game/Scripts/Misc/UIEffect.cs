using Nirvana;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIEffect : MaskableGraphic, IOverrideOrder
{
    public bool IsIgnoreTimeScale = false;

    private Transform rootCanvasTransform;
    private Canvas groupCanvas;
    private List<Material> materialList = new List<Material>();
    private Dictionary<Renderer, int> renderDic = new Dictionary<Renderer, int>();

    private ParticleSystem[] particleSystems;
    private float deltaTime;
    private float timeAtLastFrame;
    private bool isCliped = false;

    protected override void Awake()
    {
        base.Awake();

        if (Application.isPlaying)
        {
            this.ResetRootCanvas();
        }

        Renderer[] renderers = this.GetComponentsInChildren<Renderer>(true);
        for (int i = 0; i < renderers.Length; i++)
        {
            renderDic.Add(renderers[i], renderers[i].sortingOrder);
        }

        particleSystems = this.GetComponentsInChildren<ParticleSystem>(true);
    }

    void Update()
    {
        this.UpdateEffectInTimeScaleZero();
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();

        if (Application.isPlaying)
        {
            OverrideOrderGroupMgr.Instance.RemoveFromGroup(this.groupCanvas, this);

            foreach (var material in this.materialList)
            {
                GameObject.Destroy(material);
            }

            this.materialList.Clear();
        }
    }


    protected override void OnTransformParentChanged()
    {
        base.OnTransformParentChanged();
        if (Application.isPlaying)
        {
            this.ResumeClipState();
            this.ResetRootCanvas();
            OverrideOrderGroupMgr.Instance.SetGroupCanvasDirty(this.groupCanvas);
        }
    }

    protected override void OnPopulateMesh(VertexHelper toFill)
    {
        toFill.Clear();
    }

    public GameObject Target
    {
        get { return this.gameObject; }
    }

    void UpdateEffectInTimeScaleZero()
    {
        if (!IsIgnoreTimeScale)
            return;

        if (null == particleSystems)
            return;

        deltaTime = Time.realtimeSinceStartup - timeAtLastFrame;
        timeAtLastFrame = Time.realtimeSinceStartup;
        if (Mathf.Abs(Time.timeScale) < 1e-6)
        {
            for (int i = 0; i < particleSystems.Length; i++)
            {
                particleSystems[i].Simulate(deltaTime, false, false);
                particleSystems[i].Play();
            }
        }
    }

    public void SetOverrideOrder(int order, int orderInterval, int maxOrder, out int incOrder)
    {
        incOrder = 0;
        foreach (var item in renderDic)
        {
            Renderer render = item.Key;
            int orginalOrder = item.Value;
            if (null == render)
            {
                continue;
            }

            // 计算出render的最高order,如果超出则使用最高order
            var newOrder = order + orginalOrder % orderInterval;
            if (newOrder >= maxOrder)
            {
                newOrder = maxOrder;
            }

            render.sortingOrder = newOrder;

            // 存起此批render使用了多少order
            if (newOrder - order > incOrder)
            {
                incOrder = newOrder - order;
            }
        }
    }

    public void ResetMaterial()
    {
        this.materialList.Clear();

        Renderer[] renderers = this.GetComponentsInChildren<Renderer>();
        for (int i = 0; i < renderers.Length; i++)
        {
            Material[] materials = renderers[i].materials;
            for (int m = 0; m < materials.Length; m++)
            {
                this.materialList.Add(materials[m]);
            }
        }
    }

    private void ResumeClipState()
    {
        if (this.isCliped)
        {
            this.isCliped = false;
            foreach (var material in this.materialList)
            {
                material.DisableKeyword("ENABLE_UI_CLIP");
                material.DisableKeyword("ENABLE_MODLE_TO_WORLD_POS");
            }
        }
    }

    public void ResetRootCanvas()
    {
        CanvasScaler canvasScaler = this.GetComponentInParent<CanvasScaler>();
        if (null != canvasScaler)
        {
            if (null ==this.rootCanvasTransform || this.rootCanvasTransform != canvasScaler.transform)
            {
                if (null != this.groupCanvas)
                {
                    OverrideOrderGroupMgr.Instance.RemoveFromGroup(this.groupCanvas, this);
                }
                this.groupCanvas = OverrideOrderGroupMgr.Instance.AddToGroup(this);
            }

            this.rootCanvasTransform = canvasScaler.transform;

            Canvas canvas = canvasScaler.GetComponent<Canvas>();
            if (null != canvas && canvas.worldCamera)
            {
                if (0 != ((1 << GameLayers.UIEffect1) & canvas.worldCamera.cullingMask))
                {
                    this.gameObject.SetLayerRecursively(GameLayers.UIEffect1);
                }

                if (0 != ((1 << GameLayers.UIEffect2) & canvas.worldCamera.cullingMask))
                {
                    this.gameObject.SetLayerRecursively(GameLayers.UIEffect2);
                }

                if (0 != ((1 << GameLayers.UIEffect3) & canvas.worldCamera.cullingMask))
                {
                    this.gameObject.SetLayerRecursively(GameLayers.UIEffect3);
                }
            }
        }
    }

    public override void SetClipRect(Rect clipRect, bool validRect)
    {
        if (null == this.rootCanvasTransform)
        {
            return;
        }

        base.SetClipRect(clipRect, validRect);

        if (validRect)
        {
            if (0 == this.materialList.Count)
            {
                this.ResetMaterial();
            }

            this.isCliped = true;
            foreach (var material in this.materialList)
            {
                material.EnableKeyword("ENABLE_UI_CLIP");
                material.EnableKeyword("ENABLE_MODLE_TO_WORLD_POS");

                Vector3 minWorldPos = this.rootCanvasTransform.TransformPoint(new Vector2(clipRect.x, clipRect.y));
                Vector3 maxWorldPos = this.rootCanvasTransform.TransformPoint(new Vector2(clipRect.x + clipRect.width, clipRect.y + clipRect.height));
                Vector4 rect = new Vector4(minWorldPos.x, minWorldPos.y, maxWorldPos.x, maxWorldPos.y);
                material.SetVector("_ClipRect", rect);
            }
        }
        else
        {
            material.DisableKeyword("ENABLE_UI_CLIP");
        }
    }
}