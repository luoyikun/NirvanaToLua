using System;
using System.Collections.Generic;
using UnityEngine;

public class UI3DCameraScriptable : ScriptableObject
{
    public List<CameraSize> sizeList = new List<CameraSize>();
}

[Serializable]
public class CameraSize
{
    public string Name = string.Empty;
    public List<CameraModule> moduleList = new List<CameraModule>();
}

[Serializable]
public class CameraModule
{
    public string Name = string.Empty;
    public Vector3 Postion = Vector3.zero;
    public Vector3 EulerAngles = Vector3.zero;
    public float FieldOfView = 30;
}
