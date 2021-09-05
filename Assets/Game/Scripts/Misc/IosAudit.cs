using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;

public class IosAudit
{
    // 颜色格式： #00FFF4FF
    public static void ChangeUISkinColor(GameObject gameobj, string hex)
    {
        if (null == gameobj)
        {
            return;
        }

        Image[] images = gameobj.transform.GetComponentsInChildren<Image>(true);
        RawImage[] raw_images = gameobj.transform.GetComponentsInChildren<RawImage>(true);

        if (images.Length <= 0 || raw_images.Length <= 0)
        {
            return;
        }

        byte br = byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber);
        byte bg = byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
        byte bb = byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber);
        byte cc = byte.Parse(hex.Substring(6, 2), System.Globalization.NumberStyles.HexNumber);
        float r = br / 255f;
        float g = bg / 255f;
        float b = bb / 255f;
        float a = cc / 255f;
        Color color = new Color(r, g, b, a);

        for (int i = 0; i < images.Length; i++)
        {
            images[i].color = color;
        }

        for (int i = 0; i < raw_images.Length; i++)
        {
            raw_images[i].color = color;
        }
    }
}
