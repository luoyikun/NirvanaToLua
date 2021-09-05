using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LockRotation : MonoBehaviour
{
    private Transform parentTransform;
    private float offY = 0;

    /// <summary>
    /// Set the parent transform.
    /// </summary>
    public void SetParentTransform(Transform transform)
    {
        this.parentTransform = transform;
    }

    /// <summary>
    /// Set the off y.
    /// </summary>
    public void SetOffY(float y)
    {
        this.offY = y;
    }

    // Update is called once per frame
    private void Update()
    {
        this.transform.rotation = this.DoRotation(this.transform.rotation);
    }

    private Quaternion DoRotation(Quaternion rotation)
    {
        if (this.parentTransform != null)
        {
            var parentRotation = this.parentTransform.rotation;
            rotation = Quaternion.Euler(0, -parentRotation.y + this.offY, 0);
        }

        return rotation;
    }
}