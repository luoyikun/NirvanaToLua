//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

namespace Nirvana
{
    using System;
    using System.Collections.Generic;
#if UNITY_EDITOR
    using UnityEditor;
#endif
    using UnityEngine;
    using UnityEngine.Assertions;

    /// <summary>
    /// The quality used to control the quality.
    /// </summary>
    [CreateAssetMenu(
        fileName = "QualityConfig",
        menuName = "Nirvana/QualityConfig")]
    public sealed class QualityConfig : ScriptableObject
    {
        private static QualityConfig instance;
        private static int qualityLevel = 2;

        [SerializeField]
        private QualityLevel[] levels;

        private static LinkedList<Action> onQualityChanged = new LinkedList<Action>();
        private LinkedListNode<Action> onQualityChangedNode;

        public static void OnGameStop()
        {
            qualityLevel = 2;
            onQualityChanged.Clear();
        }

        /// <summary>
        /// Get the singleton instance.
        /// </summary>
        public static QualityConfig Instance
        {
            get { return instance; }
        }

        /// <summary>
        /// Clear current instance of the quality config.
        /// </summary>
        public static void ClearInstance()
        {
            if (instance != null)
            {
                Resources.UnloadAsset(instance);
                instance = null;
            }
        }

        /// <summary>
        /// Gets or sets the quality level.
        /// </summary>
        public static int QualityLevel
        {
            get
            {
                return qualityLevel;
            }

            set
            {
                if (qualityLevel != value)
                {
                    qualityLevel = value;
                    if (instance != null)
                    {
                        instance.OnQualityLevelChanged();
                    }

                    foreach (var i in onQualityChanged)
                    {
                        i();
                    }
                }
            }
        }

#if UNITY_EDITOR
        /// <summary>
        /// Find the quality config in the project.
        /// </summary>
        public static QualityConfig[] FindConfigs()
        {
            var configAssets = AssetDatabase.FindAssets("t:QualityConfig");
            var configs = new QualityConfig[configAssets.Length];
            for (int i = 0; i < configAssets.Length; ++i)
            {
                var configAsset = configAssets[i];
                var configPath =
                    AssetDatabase.GUIDToAssetPath(configAsset);
                configs[i] =
                    AssetDatabase.LoadAssetAtPath<QualityConfig>(configPath);
            }

            return configs;
        }
#endif

        /// <summary>
        /// Listen the quality changed event.
        /// </summary>
        public static LinkedListNode<Action> ListenQualityChanged(
            Action action)
        {
            return onQualityChanged.AddLast(action);
        }

        /// <summary>
        /// Remove the quality changed event.
        /// </summary>
        /// <param name="node"></param>
        public static void UnlistenQualtiy(LinkedListNode<Action> node)
        {
            onQualityChanged.Remove(node);
        }

        /// <summary>
        /// Gets the level count.
        /// </summary>
        public int GetLevelCount()
        {
            return this.levels.Length;
        }

        /// <summary>
        /// Gets the quality level by index.
        /// </summary>
        public QualityLevel GetLevel(int index)
        {
            return this.levels[index];
        }

        /// <summary>
        /// Gets the quality level by name.
        /// </summary>
        public QualityLevel GetLevel(string name)
        {
            foreach (var level in this.levels)
            {
                if (level.Name == name)
                {
                    return level;
                }
            }

            return null;
        }
        public static void SetOverrideShadowQuality(int level, int shadowQuality)
        {
            if (instance == null)
            {
                return;
            }

            if (level >= 0 && level < instance.levels.Length)
            {
                instance.levels[level].OverrideShadows = (ShadowQuality)shadowQuality;

                if (QualityConfig.QualityLevel == level)
                {
                    instance.levels[level].Active();
                }
            }
        }

#if UNITY_EDITOR
        [InitializeOnLoadMethod]
        private static void EditorStartup()
        {
            EditorApplication.playmodeStateChanged += 
                OnPlaymodeStateChanged;
        }

        private static void OnPlaymodeStateChanged()
        {
            instance = null;
        }
#endif

        private void OnEnable()
        {
            if (Application.isPlaying)
            {
                Assert.IsNull(instance);
                instance = this;

                this.OnQualityLevelChanged();
            }
        }

        private void OnDisable()
        {
            if (Application.isPlaying)
            {
                instance = null;
            }
        }

        private void OnQualityLevelChanged()
        {
            var level = QualityConfig.QualityLevel;
            if (level < this.levels.Length)
            {
                this.levels[level].Active();
            }
        }
    }
}
