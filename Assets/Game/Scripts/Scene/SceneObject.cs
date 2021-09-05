//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using Nirvana;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

#if UNITY_EDITOR
/// <summary>
/// The base class for all editable scene object.
/// It make object snap to scene grid.
/// </summary>
[ExecuteInEditMode]
public class SceneObject : MonoBehaviour
{
    // Record the last position for detect this object move.
    private Vector3 lastPosition;

    // Snap to grid.
    private void Update()
    {
        const float GridSize = 0.5f;
        const float GridSizeInverse = 1.0f / GridSize;

        var x = (0.5f * GridSize) + (Mathf.Floor(transform.position.x * GridSizeInverse) / GridSizeInverse);
        var y = transform.position.y;
        var z = (0.5f * GridSize) + (Mathf.Floor(transform.position.z * GridSizeInverse) / GridSizeInverse);

        if (this.lastPosition != this.transform.position)
        {
            var ray = new Ray(
                this.transform.position + (10000.0f * Vector3.up),
                Vector3.down);
            var hits = Physics.RaycastAll(
                ray, float.PositiveInfinity, 1 << GameLayers.Walkable);

            bool find = false;
            float height = float.NegativeInfinity;
            foreach (var hit in hits)
            {
                if (height < hit.point.y)
                {
                    height = hit.point.y;
                    find = true;
                }
            }

            if (find)
            {
                y = height;
            }

            this.lastPosition = this.transform.position;
        }

        this.transform.position = new Vector3(x, y, z);
    }
}
#endif

