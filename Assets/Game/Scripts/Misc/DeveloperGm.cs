using System;
using System.Collections.Generic;
using UnityEngine;

public sealed class DeveloperGm : MonoBehaviour
{
    private static int history_index = 0;
    private static List<string> historyList = new List<string>();
    public static string GmContent { get; set; }
    private static bool is_reloaded = false;

    public static bool OnKeyUp()
    {
        if (!is_reloaded)
        {
            is_reloaded = true;
            ReloadHistory();
        }

        if (Event.current.keyCode == KeyCode.UpArrow)
        {
            if (history_index > 0)
            {
                GmContent = historyList[--history_index];
            }
            return true;
        }
        else if (Event.current.keyCode == KeyCode.DownArrow)
        {
            if (history_index < historyList.Count - 1)
            {
                GmContent = historyList[++history_index];
            }
            return true;
        }
        else if (Event.current.keyCode == KeyCode.Return || Event.current.keyCode == KeyCode.KeypadEnter)
        {
            ExecuteGm();
            return true;
        }

        return false;
    }

    public static string GetLastGm()
    {
        if (!is_reloaded)
        {
            is_reloaded = true;
            ReloadHistory();
        }

        return historyList.Count > 0 ? historyList[historyList.Count - 1] : string.Empty;
    }

    private static void ReloadHistory()
    {
        int history_count = UnityEngine.PlayerPrefs.GetInt("history_gm_count");
        for (int i = 0; i < history_count; i++)
        {
            string gm = UnityEngine.PlayerPrefs.GetString("history_gm_" + i);
            if (!string.IsNullOrEmpty(gm))
            {
                historyList.Add(gm);
            }
            history_index = historyList.Count - 1;
        }
    }

    public static void ExecuteGm()
    {
        if (0 == historyList.Count || !historyList[historyList.Count - 1].Equals(GmContent))
        {
            if (historyList.Count > 20)
            {
                historyList.RemoveAt(0);
            }
            historyList.Add(GmContent);
        }
        history_index = historyList.Count - 1;

        if (!Application.isPlaying || null == GameRoot.Instance || GmContent.Equals(String.Empty))
        {
            return;
        }

        UnityEngine.PlayerPrefs.SetInt("history_gm_count", historyList.Count);
        UnityEngine.PlayerPrefs.SetString("history_gm_" + history_index, GmContent);

        GameRoot.Instance.ExecuteGm(GmContent);
    }
}
