//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using UnityEngine;

[ExecuteInEditMode]
public class AttachTransform : MonoBehaviour
{
    [SerializeField]
    public Transform target;

    [SerializeField]
    public Vector3 offset;

    [SerializeField]
    public Vector3 rotation;

    private void LateUpdate()
    {
        if (this.target != null)
        {
            var rot = Quaternion.Euler(this.rotation);
            this.transform.rotation = this.target.rotation * rot;
            this.transform.position =
                this.target.position +
                this.target.rotation * this.offset;
        }
    }
}
