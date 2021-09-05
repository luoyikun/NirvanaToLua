//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using UnityEngine;

    /// <summary>
    /// The description of LookTarget.
    /// </summary>
    [ExecuteInEditMode]
    public sealed class LookTarget : MonoBehaviour
    {
        [SerializeField]
        private Transform target;
        
        private void LateUpdate()
        {
            if (this.target != null)
            {
                this.transform.LookAt(this.target);
            }
        }
    }
}
