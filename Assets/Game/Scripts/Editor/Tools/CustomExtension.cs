using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using NUnit.Framework;
using UnityEngine;

public static class CustomExtension
{
    /// <summary>
    /// GameObject Extension
    /// </summary>
    public static bool Contains<T>(this GameObject gameObj) where T:Component
    {
        T t = gameObj.GetComponent<T>();
        return t;
    }
}
