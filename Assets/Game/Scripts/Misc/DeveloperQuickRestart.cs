using LuaInterface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public sealed class DeveloperQuickRestart : MonoBehaviour
{
    public static void Restart()
    {
        if (!Application.isPlaying
            || null == GameRoot.Instance
            || null == GameRoot.Instance.LuaState)
        {
            return;
        }

        Debug.Log("Start Hotupdate");
        List<string> hotupdate_file_list = new List<string>();
        DeveloperHotupdate.GetNeedUpdateList(hotupdate_file_list);
    
        LuaFunction quick_restart_fun = GameRoot.Instance.LuaState.GetFunction("ExecuteQuickRestart");
        if (null == quick_restart_fun)
        {
            Debug.Log("QuickRestart Fail");
            return;
        }

        try
        {
            string reload_files = string.Empty;
            int count = hotupdate_file_list.Count;
            for (int i = 0; i < count; i++)
            {
                reload_files += hotupdate_file_list[i].Replace("/", ".") + (i != count ? "|" : "");
            }
   
            quick_restart_fun.Call(reload_files);
            Debug.Log("QuickRestart Succ");
        }
        catch (Exception)
        {
            Debug.Log("QuickRestart Error");
            throw;
        }
    }

}