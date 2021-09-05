using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class OcclusionObject : MonoBehaviour {
    [SerializeField]
    private OcclusionItme[] items;

    public OcclusionItme[] Items
    {
        get { return this.items; }
    }

    [Serializable]
    public struct OcclusionItme
    {
        public GameObject renderer;
        public Material occlusionMaterial;
    }
}
