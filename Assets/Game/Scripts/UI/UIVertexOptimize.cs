using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class UIVertexOptimize : BaseMeshEffect
{
    struct Triangle
    {
        public UIVertex v1;
        public UIVertex v2;
        public UIVertex v3;
    }

    public override void ModifyMesh(VertexHelper vh)
    {
        List<UIVertex> verts = new List<UIVertex>();
        vh.GetUIVertexStream(verts);
        OptimizeVert(ref verts);
        vh.Clear();
        vh.AddUIVertexTriangleStream(verts);
    }

    void OptimizeVert(ref List<UIVertex> vertices)
    {
        List<Triangle> tris = new List<Triangle>();
        for (int i = 0; i < vertices.Count - 3; i += 3)
        {
            tris.Add(new Triangle() { v1 = vertices[i], v2 = vertices[i + 1], v3 = vertices[i + 2] });
        }
        vertices = tris.Distinct().SelectMany(tri =>new[]{tri.v1, tri.v2, tri.v3}).ToList();
    }
}