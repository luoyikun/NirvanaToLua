
using UnityEngine;
using UnityEngine.UI;

namespace Game
{
    [RequireComponent(typeof(RawImage))]
    [ExecuteInEditMode]
    public class LoadRawImage : MonoBehaviour
    {
        public string BundleName;
        public string AssetName;

        public bool AutoFitNativeSize = false;
        public bool AutoUpdateAspectRatio = false;

        private RawImage rawImage;

#if UNITY_EDITOR
        private bool dirty = false;
#endif

        private void Awake()
        {
            rawImage = this.gameObject.GetComponent<RawImage>();
            rawImage.enabled = false;
        }

        private void OnDestroy()
        {
            if (EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnLoadRawImageDestroy(this);
            }
            else
            {
                rawImage.texture = null;
            }
        }

        private void OnDisable()
        {
            if (EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnLoadRawImageDisable(this);
            }
            else
            {
                rawImage.texture = null;
            }
        }

        private void OnEnable()
        {
            if (EventDispatcher.Instance != null)
            {
                EventDispatcher.Instance.OnLoadRawImageEnable(this);
            }
#if UNITY_EDITOR
            else
            {
                UpdateAsset();
            }
#endif
        }

        public void SetTexture(Texture2D texture)
        {
            DestroyRawImageTexture();

            rawImage.texture = texture;
            rawImage.enabled = true;

            if (AutoFitNativeSize)
            {
                rawImage.SetNativeSize();
            }

            if (AutoUpdateAspectRatio)
            {
                var ratioFitter = rawImage.GetComponent<AspectRatioFitter>();
                if (ratioFitter != null)
                {
                    ratioFitter.aspectRatio = texture.width / (float)texture.height;
                }
            }
        }

        private void DestroyRawImageTexture()
        {
            rawImage.texture = null;
        }

#if UNITY_EDITOR

        private void OnValidate()
        {
            if (rawImage != null && rawImage.texture != null)
            {
                rawImage.texture = null;
            }

            dirty = true;
        }

        private void Update()
        {
            if (dirty)
            {
                dirty = false;
                UpdateAsset();
            }
        }

        public void UpdateAsset()
        {
            if (string.IsNullOrEmpty(BundleName) || string.IsNullOrEmpty(AssetName))
            {
                return;
            }

            var texture = EditorResourceMgr.LoadObject(BundleName, AssetName, typeof(Texture2D)) as Texture2D;
            if (texture == null)
            {
                DestroyRawImageTexture();
            }
            else
            {
                Texture2D cloneTexture = new Texture2D(texture.width, texture.height, texture.format, false);
                cloneTexture.LoadRawTextureData(texture.GetRawTextureData());
                cloneTexture.Apply();

                SetTexture(cloneTexture);
            }

        }
#endif
    }
}
