using UnityEngine;
using Nirvana;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Game
{
    [ExecuteInEditMode]
    public class GameObjectAttach : MonoBehaviour
    {
        private bool isDisableEffect = false;

        public string BundleName
        {
            get { return this.asset.BundleName; }
            set { this.asset.BundleName = value; }
        }

        public string AssetName
        {
            get { return this.asset.AssetName; }
            set { this.asset.AssetName = value; }
        }

#if UNITY_EDITOR
        public string AssetGuid
        {
            get { return this.asset.AssetGUID; }
            set { this.asset.AssetGUID = value; }
        }
#endif

        [SerializeField]
        private AssetID asset;
        /// <summary>
        /// 获取或设置asset
        /// </summary>
        public AssetID Asset
        {
            get
            {
                return this.asset;
            }

            set
            {
                if (!this.asset.Equals(value))
                {
                    this.asset = value;
                }
            }
        }


        public bool IsSyncLayer = true;

#if UNITY_EDITOR
        private GameObject previewGameObj;
#endif

        private void OnDestroy()
        {
            if (EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnGameObjAttachDestroyed(this);
            }
        }

        private void OnDisable()
        {
#if UNITY_EDITOR
            DestroyAttachObj();
#endif

            if (EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnGameObjAttachDisable(this);
            }
        }

        private void OnEnable()
        {
#if UNITY_EDITOR
            CreateAttachObj();
#endif

            if (this.isDisableEffect)
            {
                return;
            }

            Scheduler.Delay(() =>
            {
                if (null != this && this.enabled && !this.isDisableEffect)
                {
                    if (EventDispatcher.Instance != null)
                    {
                        EventDispatcher.Instance.OnGameObjAttachEnable(this);
                    }
                }
            });
        }

        public void SetIsSceneOptimize(bool isDisableEffect)
        {
            this.isDisableEffect = isDisableEffect;

            if (isDisableEffect && EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnGameObjAttachDisable(this);
            }
        }

        public bool IsSceneOptimize()
        {
            return this.isDisableEffect;
        }

#if UNITY_EDITOR

        private bool dirty = false;

        private void OnValidate()
        {
            dirty = true;
        }

        private void Update()
        {
            if (GameRoot.Instance != null)
            {
                return;
            }

            if (dirty)
            {
                dirty = false;
                CreateAttachObj();
            }
        }

        private void DestroyAttachObj()
        {
            var previewObject = this.gameObject.GetComponent<Nirvana.PreviewObject>();
            if (previewObject)
            {
                previewObject.ClearPreview();
            }

            if (previewGameObj != null)
            {
                Destroy(previewGameObj);
                previewGameObj = null;
            }
        }

        private void CreateAttachObj()
        {
            DestroyAttachObj();

            if (GameRoot.Instance == null)
            {
                if (!string.IsNullOrEmpty(BundleName) &&
                    !string.IsNullOrEmpty(AssetName))
                {
                    var asset = EditorResourceMgr.LoadGameObject(BundleName, AssetName);
                    if (asset != null)
                    {
                        var go = Instantiate<GameObject>(asset);
                        if (Application.isPlaying)
                        {
                            go.transform.SetParent(this.transform, false);
                            previewGameObj = go;
                        }
                        else
                        {
                            var previewObj = this.gameObject.GetComponent<Nirvana.PreviewObject>() ?? this.gameObject.AddComponent<Nirvana.PreviewObject>();
                            previewObj.SimulateInEditMode = true;
                            previewObj.SetPreview(go);
                        }
                    }
                }
            }
        }

        public void RefreshAssetBundleName()
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(this.AssetGuid);
            var importer = AssetImporter.GetAtPath(assetPath);
            if (null != importer)
            {
                this.BundleName = importer.assetBundleName;
                this.AssetName = assetPath.Substring(assetPath.LastIndexOf("/") + 1);
            }
        }

        public bool IsGameobjectMissing()
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(this.AssetGuid);
            var importer = AssetImporter.GetAtPath(assetPath);
            if (null == importer)
            {
                return true;
            }

            if (this.BundleName != importer.assetBundleName
                || this.AssetName != assetPath.Substring(assetPath.LastIndexOf("/") + 1))
            {
                return true;
            }

            return false;
        }
#endif

    }
}
