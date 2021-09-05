//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityObject = UnityEngine.Object;

    /// <summary>
    /// The quality control used to control the enable and disable for specify 
    /// components by quality setting.
    /// </summary>
    public sealed class QualityControlActive : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("The quality control items.")]
        private ControlItem[] controls;

        private int overrideLevel = -1;
        private LinkedListNode<Action> listenNode;

        /// <summary>
        /// Set an override quality level to skip the global quality level.
        /// </summary>
        public void SetOverrideLevel(int level)
        {
            this.overrideLevel = level;
            this.OnQualityLevelChanged(level);
        }

        /// <summary>
        /// Reset the override level and use the global quality level.
        /// </summary>
        public void ResetOverrideLevel()
        {
            var level = QualityConfig.QualityLevel;
            if (this.overrideLevel != level)
            {
                this.OnQualityLevelChanged(level);
            }

            this.overrideLevel = -1;
        }

        private void Awake()
        {
            this.listenNode = QualityConfig.ListenQualityChanged(
                this.OnQualityLevelChanged);
            this.OnQualityLevelChanged();
        }

        private void OnDestroy()
        {
            if (this.listenNode != null)
            {
                QualityConfig.UnlistenQualtiy(this.listenNode);
                this.listenNode = null;
            }
        }

        private void OnQualityLevelChanged()
        {
            if (this.overrideLevel < 0)
            {
                var level = QualityConfig.QualityLevel;
                this.OnQualityLevelChanged(level);
            }
        }

        private void OnQualityLevelChanged(int level)
        {
            foreach (var control in this.controls)
            {
                bool enabled = false;
                if (level < control.EnabledLevels.Length)
                {
                    enabled = control.EnabledLevels[level];
                }

                if (control.Target != null)
                {
                    var behaviour = control.Target as Behaviour;
                    if (behaviour != null)
                    {
                        behaviour.enabled = enabled;
                    }
                    else
                    {
                        var gameObject = control.Target as GameObject;
                        if (gameObject != null)
                        {
                            gameObject.SetActive(enabled);
                        }
                    }
                }
            }
        }

        [Serializable]
        public struct ControlItem
        {
            public UnityObject Target;
            public bool[] EnabledLevels;
        }
    }
}
