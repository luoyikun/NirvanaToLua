using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class DevelopMode : Editor
{
    public enum MODE
    {
        GUEST = 0,
        DEVELOPER = 1,
    }

    [MenuItem("Nirvana/DevelopMode/Guest")]
    public static void Guest()
    {
        UnityEngine.PlayerPrefs.SetInt("develop_mode", (int)MODE.GUEST);
    }

    [MenuItem("Nirvana/DevelopMode/Guest", true)]
    private static bool GuestValidate()
    {
        Menu.SetChecked("Nirvana/DevelopMode/Guest", (int)MODE.GUEST == UnityEngine.PlayerPrefs.GetInt("develop_mode"));
        return true;
    }

    [MenuItem("Nirvana/DevelopMode/Developer")]
    public static void Developer()
    {
        UnityEngine.PlayerPrefs.SetInt("develop_mode", (int)MODE.DEVELOPER);
    }

    [MenuItem("Nirvana/DevelopMode/Developer", true)]
    private static bool DeveloperValidate()
    {
        Menu.SetChecked("Nirvana/DevelopMode/Developer", (int)MODE.DEVELOPER == UnityEngine.PlayerPrefs.GetInt("develop_mode"));
        return true;
    }
}
