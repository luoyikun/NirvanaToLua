//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using UnityEngine;
    using UnityEngine.UI;

    /// <summary>
    /// Make the ui shader clipable.
    /// </summary>
    public sealed class UIClipModifier : MonoBehaviour, IMaterialModifier
    {
        /// <inheritdoc/>
        public Material GetModifiedMaterial(Material baseMaterial)
        {
            var mat = new Material(baseMaterial);
            mat.EnableKeyword("ENABLE_UI_CLIP");
            return mat;
        }
    }
}
