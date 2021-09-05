//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using UnityEngine;

public class MaterialSwitcher : MonoBehaviour
{
    [SerializeField]
    private Renderer renderer;

    [SerializeField]
    private MaterialRecord[] materials;

    /// <summary>
    /// Switch the material by index.
    /// </summary>
    public void Switch(int index)
    {
        if (this.materials == null || 
            index < 0 || 
            index >= this.materials.Length)
        {
            return;
        }

        this.materials[index].Active(this.renderer);
    }

    /// <summary>
    /// Switch the material by name.
    /// </summary>
    public void Switch(string name)
    {
        if (this.materials == null)
        {
            return;
        }

        for (int i = 0; i < this.materials.Length; ++i)
        {
            if (this.materials[i].Name == name)
            {
                this.materials[i].Active(this.renderer);
                return;
            }
        }
    }

    [Serializable]
    private struct MaterialRecord
    {
        [SerializeField]
        private string name;

        [SerializeField]
        private Material[] materials;

        public string Name
        {
            get { return this.name; }
        }

        public void Active(Renderer renderer)
        {
            var nirvanaRenderer = renderer.GetComponent<Nirvana.NirvanaRenderer>();
            if (nirvanaRenderer != null)
            {
                nirvanaRenderer.Materials = this.materials;
            }
            else
            {
                renderer.sharedMaterials = this.materials;
            }
        }
    }
}
