using Game;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ActorRender : MonoBehaviour
{
    [SerializeField]
    private List<RenderItem> renderList = new List<RenderItem>();

    private bool isLowMaterial = false;
    private bool isCastShadow = false;
    private bool isDisableAllAttachEffect = false;

    private GameObjectAttach[] allAttachEffects;

    public void SetRenderList(List<RenderItem> renderList)
    {
        this.renderList = renderList;
    }

    public void SetIsLowMaterial(bool isLowMaterial, bool ignore_set)
    {
        if (this.isLowMaterial == isLowMaterial && !ignore_set)
        {
            return;
        }

        this.isLowMaterial = isLowMaterial;
        foreach (var item in renderList)
        {
            if (null != item.renderer && null != item.HighMaterial && null != item.lowMaterial)
            {
                item.renderer.material = isLowMaterial ? item.lowMaterial : item.HighMaterial;
            }

        }
    }

    /// <summary>
    /// 设置材质球(比如隐身后影子材质球这些)
    /// </summary>
    /// <param name="material">材质球</param>
    public void SetRenderMaterial(Material material)
    {
        if (null == material)
        {
            return;
        }
        foreach (var item in renderList)
        {
            if (null != item.renderer)
            {
                item.renderer.material = material;
            }
        }
    }

    public void SetIsCastShadow(bool isCastShadow)
    {
        this.isCastShadow = isCastShadow;
        foreach (var item in renderList)
        {
            if (null != item.renderer)
            {
                item.renderer.shadowCastingMode = isCastShadow ? ShadowCastingMode.On : ShadowCastingMode.Off;
            }
        }
    }

    public void SetIsDisableAllAttachEffects(bool isDisableAllAttachEffect)
    {
       if (this.isDisableAllAttachEffect == isDisableAllAttachEffect)
        {
            return;
        }

        this.isDisableAllAttachEffect = isDisableAllAttachEffect;
        if (null == this.allAttachEffects)
        {
            this.allAttachEffects = this.GetComponentsInChildren<GameObjectAttach>();
        }

        for (int i = 0; i < this.allAttachEffects.Length; i++)
        {
            if (null != this.allAttachEffects[i])
            {
                this.allAttachEffects[i].SetIsSceneOptimize(isDisableAllAttachEffect);
            }
        }
    }

    [Serializable]
    public struct RenderItem
    {
        public Renderer renderer;
        public Material HighMaterial;
        public Material lowMaterial;
    }
}
