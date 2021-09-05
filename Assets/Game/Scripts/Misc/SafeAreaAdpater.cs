using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Nirvana;

[RequireComponent(typeof(RectTransform))]
public class SafeAreaAdpater : MonoBehaviour
{
    public enum Mode
    {
        NORMAL = 0,
        INPHONE_XL,
        INPHONE_XR,
    }

    private RectTransform rectTransform;

    private static Vector2 referenceResolution;          // 参考分辨率
    private static Rect referenceSafeArea = new Rect();  // 参考分辨率下的当全区
    private static Rect screenSafeArea = new Rect();    
    private float lastCheckSafeAreaTime = 0;     

    private void Awake()
    {
        this.rectTransform = this.GetComponent<RectTransform>();
        this.rectTransform.anchorMin = new Vector2(0, 0);
        this.rectTransform.anchorMax = new Vector2(1, 1);

        // 获得参考分辨率
        if (referenceResolution.Equals(Vector2.zero))
        {
            CanvasScaler canvas = this.GetComponentInParent<CanvasScaler>();
            if (null != canvas)
            {
                referenceResolution = canvas.referenceResolution;
            }
        }

        this.AdjustLayout();
    }

    private void Update()
    {
        if (this.CheckSafeAreaChange())
        {
            this.AdjustLayout();
        }
    }

    private bool CheckSafeAreaChange()
    {
        if (0 != lastCheckSafeAreaTime && Time.time < lastCheckSafeAreaTime + 0.5)
        {
            return false;
        }

        lastCheckSafeAreaTime = Time.time;
        if (this.rectTransform.offsetMin.x < 0)
        {
            return false;
        }

        Rect safe_area;
        float factor_x = 1.0f, factor_y = 1.0f;
        int resolution_width = 0, resolution_height = 0;

#if UNITY_EDITOR
        Mode mode = (Mode)UnityEngine.PlayerPrefs.GetInt("safe_area_mode");
        if (Mode.INPHONE_XL == mode)  // 如iphonex留海在左边
        {
            safe_area = new Rect(132, 63, Screen.width - 132, Screen.height - 63);
        }
        else if (Mode.INPHONE_XR == mode)  // 如iphonex留海在右边
        {
            safe_area = new Rect(0, 63, Screen.width - 132, Screen.height - 63);
        }
        else
        {
            safe_area = new Rect(0, 0, Screen.width, Screen.height);
        }

        resolution_width = Screen.width;
        resolution_height = Screen.height;
#else
        DeviceTool.GetScreenSafeAreaFix(out safe_area, out resolution_width, out resolution_height);
        resolution_width = 0 != resolution_width ? resolution_width : Screen.width;
        resolution_height = 0 != resolution_height ? resolution_height : Screen.height;


#endif
        factor_x = referenceResolution.x / resolution_width;
        factor_y = referenceResolution.y / resolution_height;

        string log = string.Format("{0}，{1}，{2}，{3}，{4}，{5}，{6}，{7}，{8}，{9}，{10}，{11}",
                                                        referenceResolution.x,
                                                        referenceResolution.y,
                                                        resolution_width,
                                                        resolution_height,
                                                        Screen.currentResolution.width,
                                                        Screen.currentResolution.height,
                                                        safe_area.x,
                                                        safe_area.y,
                                                        safe_area.width,
                                                        safe_area.height,
                                                        factor_x,
                                                        factor_y
                                                        );

        //Debug.LogError("SafeAreaAdpater:" + log);
        // Back Req Check SafeArea:1334_768_2436_1125_1558_720_132_63_2172_1062

        // if (screenSafeArea.Equals(safe_area))
        // {
        //     return false;
        // }  
        if (safe_area.width == Screen.width && safe_area.height == Screen.height)
        {
            return false;
        }

        // 返回的安全区域是首尾留边的，所以在有安全区域的情况下 安全区域的坐标不可能为0
        if (this.rectTransform.offsetMin.x == safe_area.x * factor_x && this.rectTransform.offsetMin.y == safe_area.y * factor_y)
        {
            return false;
        }

        // screenSafeArea = safe_area;

        referenceSafeArea = new Rect(safe_area.x * factor_x,
                                     safe_area.y * factor_y,
                                     safe_area.width * factor_x,
                                     safe_area.height * factor_y);
        return true;
    }

    public void AdjustLayout()
    {
        if (0 == referenceSafeArea.width 
            || 0 == referenceSafeArea.height)
        {
            return;
        }

        this.rectTransform.offsetMin = new Vector2(referenceSafeArea.x, referenceSafeArea.y);
        this.rectTransform.offsetMax = new Vector2(referenceSafeArea.x + referenceSafeArea.width - referenceResolution.x,
                                                    referenceSafeArea.y + referenceSafeArea.height - referenceResolution.y);

    }

    public static SafeAreaAdpater Bind(GameObject go)
    {
        var safeAreaAdpater = go.GetComponent<SafeAreaAdpater>() ?? go.AddComponent<SafeAreaAdpater>();
        return safeAreaAdpater;
    }
}
