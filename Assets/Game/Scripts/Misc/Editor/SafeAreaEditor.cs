using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

[CustomEditor(typeof(SafeAreaAdpater))]
public class SafeAreaEditor : Editor
{

    [MenuItem("Nirvana/SafeArea/Normal")]
    public static void Normal()
    {
        UnityEngine.PlayerPrefs.SetInt("safe_area_mode", (int)SafeAreaAdpater.Mode.NORMAL);
    }

    [MenuItem("Nirvana/SafeArea/Normal", true)]
    private static bool NormalValidate()
    {
        Menu.SetChecked("Nirvana/SafeArea/Normal", (int)SafeAreaAdpater.Mode.NORMAL == UnityEngine.PlayerPrefs.GetInt("safe_area_mode"));
        return true;
    }

    [MenuItem("Nirvana/SafeArea/IphoneXL")]
    public static void IphoneXL()
    {
        UnityEngine.PlayerPrefs.SetInt("safe_area_mode", (int)SafeAreaAdpater.Mode.INPHONE_XL);
    }

    [MenuItem("Nirvana/SafeArea/IphoneXL", true)]
    private static bool IphoneXLValidate()
    {
        Menu.SetChecked("Nirvana/SafeArea/IphoneXL", (int)SafeAreaAdpater.Mode.INPHONE_XL == UnityEngine.PlayerPrefs.GetInt("safe_area_mode"));
        return true;
    }

    [MenuItem("Nirvana/SafeArea/IphoneXR")]
    public static void IphoneXR()
    {
        UnityEngine.PlayerPrefs.SetInt("safe_area_mode", (int)SafeAreaAdpater.Mode.INPHONE_XR);
    }

    [MenuItem("Nirvana/SafeArea/IphoneXR", true)]
    private static bool IphoneXRValidate()
    {
        Menu.SetChecked("Nirvana/SafeArea/IphoneXR", (int)SafeAreaAdpater.Mode.INPHONE_XR == UnityEngine.PlayerPrefs.GetInt("safe_area_mode"));
        return true;
    }


    private void OnEnable()
    {
        SafeAreaAdpater adapter = this.target as SafeAreaAdpater;
        RectTransform rt = adapter.GetComponent<RectTransform>();
        rt.anchorMin = new Vector2(0, 0);
        rt.anchorMax = new Vector2(1, 1);
        rt.offsetMin = new Vector2(0, 0);
        rt.offsetMax = new Vector2(0, 0);
    }
}
