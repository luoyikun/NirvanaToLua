using UnityEngine;
using System.Collections.Generic;
using Nirvana;

[System.Serializable]
public class CameraLayerInfo
{
    public int layer;
    public float distance;
    public CameraLayerInfo(int l, float d)
    {
        layer = l;
        distance = d;
    }
};

public class CameraCullingDistance : MonoBehaviour
{
    public List<CameraLayerInfo> CullDistances = new List<CameraLayerInfo>();
    private Camera _camera;

    void Start()
    {
        _camera = GetComponent<Camera>();
        this.UpdateDistances();
    }

    public void UpdateDistances()
    {
        float[] distances = new float[32];
        for (int i = 0; i < CullDistances.Count; ++i)
        {
            CameraLayerInfo info = CullDistances[i];
            if (info.distance > 0)
            {
                distances[info.layer] = info.distance;
            }
        }

        if (_camera)
        {
            _camera.layerCullDistances = distances;
        }
    }

    public void SetDistance(int layer, float distance)
    {
        if (distance < 0)
        {
            return;
        }

        bool hasValue = false;
        for (int i = 0; i < CullDistances.Count; ++i)
        {
            CameraLayerInfo info = CullDistances[i];
            if (info.layer == layer)
            {
                info.distance = distance;
                hasValue = true;
                break;
            }
        }
        if (!hasValue)
        {
            CullDistances.Add(new CameraLayerInfo(layer, distance));
        }
        UpdateDistances();
    }
}
