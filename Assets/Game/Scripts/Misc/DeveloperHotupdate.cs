using LuaInterface;
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public sealed class DeveloperHotupdate : MonoBehaviour
{
    public static string luaDir = Application.dataPath + "/Game/Lua";
    private static Dictionary<string, long> fileModifyTimeDic = new Dictionary<string, long>();

    public static void StartHotupdate()
    {
        if (!Application.isPlaying 
            || null == GameRoot.Instance 
            || null == GameRoot.Instance.LuaState)
        {
            return;
        }

        Debug.Log("Start Hotupdate");
        List<string> hotupdate_file_list = new List<string>();
        GetNeedUpdateList(hotupdate_file_list);

        if (hotupdate_file_list.Count <= 0)
        {
            Debug.Log("Hotupdate Fail");
            return;
        }

        LuaFunction hotupdate_fun = GameRoot.Instance.LuaState.GetFunction("ExecuteHotUpdate");
        if (null == hotupdate_fun)
        {
            Debug.Log("Hotupdate Fail");
            return;
        }

        try
        {
            foreach (string item in hotupdate_file_list)
            {
                hotupdate_fun.Call(item.Replace("/", "."));
            }
            Debug.Log("Hotupdate Succ");
        }
        catch (Exception)
        {
            Debug.Log("Hotupdate Error");
            throw;
        }
    }

    public static void GetNeedUpdateList(List<string> hotupdate_file_list)
    {
        List<string> all_lua_files = new List<string>();
        GetAllLuaFiles(new DirectoryInfo(luaDir), all_lua_files);

        string temp_lua_dir = luaDir.Replace("/", "\\");
        foreach (string full_path in all_lua_files)
        {
            string path = full_path.Replace(temp_lua_dir + "\\", "");
            path = path.Replace("\\", "/");
            path = path.Replace(".lua", "");

            hotupdate_file_list.Add(path);
        }
    }

    public static void GetAllLuaFiles(FileSystemInfo info, List<string> all_lua_files)
    {
        if (!info.Exists) return;

        DirectoryInfo dir = info as DirectoryInfo;
        if (dir == null) return;

        FileSystemInfo[] files = dir.GetFileSystemInfos();
        for (int i = 0; i < files.Length; i++)
        {
            FileInfo file = files[i] as FileInfo;
            if (file != null)
            {
                if (file.Extension == ".lua")
                {
                    long old_modify_time = 0;
                    long new_modify_time = file.LastWriteTime.ToFileTime();

                    if (!fileModifyTimeDic.TryGetValue(file.FullName, out old_modify_time)
                        || old_modify_time != new_modify_time)
                    {
                        all_lua_files.Add(file.FullName);
                        fileModifyTimeDic[file.FullName] = new_modify_time;
                    }
                }
            }
            else
            {
                GetAllLuaFiles(files[i], all_lua_files);
            }
        }
    }

    public static void CacheAllFileModifyTime()
    {
        int time1 = System.DateTime.Now.Millisecond;

        List<string> all_lua_files = new List<string>();
        GetAllLuaFiles(new DirectoryInfo(luaDir), all_lua_files);

        int time2 = System.DateTime.Now.Millisecond;
        Debug.Log("[CacheAllFileModifyTime] cost time:" + (time2 - time1) / 1000);
    }
}
