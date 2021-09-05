using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public sealed class UICameraPostEffect : MonoBehaviour
{
    public Shader shader;

    private Material material;

    private void OnEnable()
    {
        UpdateMaterial();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (this.material == null)
        {
            Graphics.Blit(source, destination);
            return;
        }

        Graphics.Blit(source, destination, this.material);
    }

    private void OnValidate()
    {
        UpdateMaterial();
    }

    private void UpdateMaterial()
    {
        Camera camera = GetComponent<Camera>();
        var cameraClearColor = camera.backgroundColor;

        if (this.material)
        {
            if (Application.isPlaying)
            {
                Destroy(this.material);
            }
            else
            {
                DestroyImmediate(this.material);
            }
        }

        if (shader)
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;

            material.SetColor("_CameraColor", cameraClearColor);
        }
    }
}
