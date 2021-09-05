using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[DisallowMultipleComponent]
[AddComponentMenu("Physics/Visualized Box Collider")]
[RequireComponent(typeof(BoxCollider))]
public class DrawColorBoxColider : MonoBehaviour {

    protected int _layer;
    public Color Color = Color.black;

#if !UNITY_EDITOR
    void Awake()
    {
        Object.Destroy(this);
    }
#else
    BoxCollider Collider;

    void Awake()
    {
        Collider = GetComponent<BoxCollider>();
        enabled = Collider != null;

        _layer = gameObject.layer;

        if (!enabled)
        {
            Debug.LogError(System.DateTime.Now + "对象上找不到 BoxCollider 组件！", this);
        }
    }

    void OnDrawGizmos()
    {
        if (Collider != null)
        {
            var lastColor = Gizmos.color;
            var lastMatrix = Gizmos.matrix;
            var trans = transform;

            Gizmos.color = Color;
            Gizmos.matrix = trans.localToWorldMatrix;
            Gizmos.DrawCube(Collider.center, Collider.size);
            Gizmos.matrix = lastMatrix;
            Gizmos.color = lastColor;
        }
    }
#endif
}
