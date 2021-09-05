using UnityEngine;
using System;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using System.Collections.Generic;
using System.Collections;
[CreateAssetMenu(menuName = "Changetext", fileName = "Changetext")]
public class ChangeText : ScriptableObject
{
    public bool checkColor;
    public int changeColor;
    public Color oldColor;
    public Color newColor;

    public bool checkFont;
    public int changeFont;
    public Font newFont;
    public Font oldFont;
   
    public bool checkSize;
    public int changeSize;
    public int newSize;
    public int oldSize;

    public bool checkShadow;
    public int changeShadow;
    public Color shadowEffectColor;
    public float shadowEffectDistanceX;
    public float shadowEffectDistanceY;
    public bool shadowUseAlpha;

    public bool checkOutline;
    public int changeOutline;
    public Color outlineEffectColor;
    public float outlineEffectDistanceX;
    public float outlineEffectDistanceY;
    public bool outlineUseAlpha;

    public bool Change(GameObject go)
    {
        var text = go.GetComponent<Text>();
        if (this.changeColor == 0)
        {
            if (text.color != this.oldColor)
                return false;
        }
        if (this.changeSize == 0)
        {
            if (this.oldSize != text.fontSize)
                return false;
        }
        if (this.changeFont == 0)
        {
            if (this.oldFont != text.font)
                return false;
        }
        if(this.changeColor == 0)
        {
            text.color = this.newColor;
        }
        if (this.changeFont == 0)
        {
            text.font = this.newFont;
        }
        if (this.changeSize == 0)
        {
            text.fontSize = this.newSize;
        }
        var shadow = go.GetComponent<Shadow>();
        switch (this.changeShadow)
        {
            case 0:
                if (null == shadow)
                {
                    shadow = go.AddComponent<Shadow>();
                }
                shadow.effectColor = this.shadowEffectColor;
                shadow.effectDistance = new Vector2(this.shadowEffectDistanceX, this.shadowEffectDistanceY);
                shadow.useGraphicAlpha = this.shadowUseAlpha;
                break;
            case 1:
                if (null != shadow)
                {
                    GameObject.DestroyImmediate(shadow);
                }
                break;
        }
        var outline = go.GetComponent<Outline>();
        switch (this.changeOutline)
        {
            case 0:
                if (null == outline)
                {
                    outline = go.AddComponent<Outline>();
                }
                outline.effectColor = this.outlineEffectColor;
                outline.effectDistance = new Vector2(this.outlineEffectDistanceX, this.outlineEffectDistanceY);
                outline.useGraphicAlpha = this.outlineUseAlpha;
                break;
            case 1:
                if (null != outline)
                {
                    GameObject.DestroyImmediate(outline);
                }
                break;
        }
        EditorUtility.SetDirty(go);
        Debug.Log("修改成功！Text名字为：" + go.name);
        return true;
    }
}
