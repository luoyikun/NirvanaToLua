using System;
using System.Collections.Generic;
using UnityEngine;

public sealed class DeveloperQuickLogin : MonoBehaviour
{
    public static string UserName
    {
        get
        {
            return UnityEngine.PlayerPrefs.GetString("quick_login_user_name");
        }

        set
        {
            UnityEngine.PlayerPrefs.SetString("quick_login_user_name", value);
        }
    }

    public static string ServerId
    {
        get
        {
            string serverId = UnityEngine.PlayerPrefs.GetString("quick_login_server_id");
            if (String.IsNullOrEmpty(serverId))
            {
                serverId = "1";
            }

            return serverId;
        }

        set
        {
            UnityEngine.PlayerPrefs.SetString("quick_login_server_id", value);
        }
    }

    public static string Path
    {
        get
        {
            return UnityEngine.PlayerPrefs.GetString("quick_login_screen_shot_path");
        }

        set
        {
            UnityEngine.PlayerPrefs.SetString("quick_login_screen_shot_path", value);
        }
    }
}
