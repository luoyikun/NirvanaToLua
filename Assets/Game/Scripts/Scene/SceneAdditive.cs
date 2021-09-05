//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

namespace Game
{
    using Nirvana;
#if UNITY_EDITOR
    using UnityEditor;
#endif
    using UnityEngine;
    using UnityEngine.SceneManagement;

    /// <summary>
    /// The scene used to load scene additive.
    /// </summary>
    public sealed class SceneAdditive : MonoBehaviour
    {
        [SerializeField]
#if UNITY_EDITOR
        [AssetType(typeof(SceneAsset))]
#endif
        private AssetID sceneAsset;

        private bool loading;
        private Scene scene;

        private static void ActiveScene(Scene scene, bool active)
        {
            var objs = scene.GetRootGameObjects();
            foreach (var obj in objs)
            {
                obj.SetActive(active);
            }
        }

        private string GetSceneName()
        {
            var sceneName = this.sceneAsset.AssetName;
            if (sceneName.EndsWith(".unity"))
            {
                sceneName = sceneName.Substring(
                    0, sceneName.Length - 6);
            }

            return sceneName;
        }

        private void OnEnable()
        {
            if (this.loading)
            {
                return;
            }

            var sceneName = this.GetSceneName();
            if (!this.scene.IsValid())
            {
                this.scene = SceneManager.GetSceneByName(sceneName);
            }

            if (this.scene.IsValid())
            {
                ActiveScene(this.scene, true);
                return;
            }

            this.loading = true;
            AssetManager.LoadLevel(
                this.sceneAsset,
                LoadSceneMode.Additive,
                () =>
                {
                    this.loading = false;
                    this.scene = SceneManager.GetSceneByName(sceneName);
                    if (this.scene.IsValid())
                    {
                        if (this == null)
                        {
                            SceneManager.UnloadSceneAsync(this.scene);
                        }
                        else
                        {
                            ActiveScene(this.scene, this.enabled);
                        }
                    }
                });
        }

        private void OnDisable()
        {
            if (this.scene.IsValid())
            {
                ActiveScene(this.scene, false);
            }
        }

        private void OnDestroy()
        {
            if (this.scene.IsValid())
            {
                SceneManager.UnloadSceneAsync(this.scene);
            }
        }
    }
}
