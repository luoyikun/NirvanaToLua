using UnityEngine;
using System;
/// <summary>
/// 重写变量名能让变量在inspect面板显示中文字符
/// </summary>
[AttributeUsage(AttributeTargets.Field)]
public class ReNameAttribute : PropertyAttribute
{
    public string label;        //要显示的字符
    public ReNameAttribute(string label)
    {
        //获取你想要绘制的标签名字
        this.label = label;
    }
}

