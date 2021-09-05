//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using Nirvana.Editor;
using UnityEditor;
using UnityEditor.Callbacks;

/// <summary>
/// Used to locate the lua source code.
/// </summary>
public static class LuaLogLocator
{
    private static HashSet<int> instanceIDTable;
    private static Regex regex1;
    private static Regex regex2;
    private static Regex regex3;
    private static Regex regex4;
    private static bool searchSublime;
    private static string sublimeText;

    private static string SublimeText
    {
        get
        {
            if (!searchSublime)
            {
                searchSublime = true;
                var paths = new string[]
                {
                    "C:\\Sublime Text 3\\sublime_text.exe",
                    "C:\\Program Files\\Sublime Text 3\\sublime_text.exe",
                    "C:\\Program Files (x86)\\Sublime Text 3\\sublime_text.exe",
                    "D:\\Sublime Text 3\\sublime_text.exe",
                    "D:\\Program Files\\Sublime Text 3\\sublime_text.exe",
                    "D:\\Program Files (x86)\\Sublime Text 3\\sublime_text.exe",
                    "E:\\Sublime Text 3\\sublime_text.exe",
                    "E:\\Program Files\\Sublime Text 3\\sublime_text.exe",
                    "E:\\Program Files (x86)\\Sublime Text 3\\sublime_text.exe",
                    "F:\\Sublime Text 3\\sublime_text.exe",
                    "F:\\Program Files\\Sublime Text 3\\sublime_text.exe",
                    "F:\\Program Files (x86)\\Sublime Text 3\\sublime_text.exe",
                };

                foreach (var path in paths)
                {
                    if (File.Exists(path))
                    {
                        sublimeText = path;
                        return sublimeText;
                    }
                }
            }

            return sublimeText;
        }
    }

    private static void AddLocateMonoScript(string path)
    {
        var locateObj = AssetDatabase.LoadAssetAtPath<MonoScript>(path);
        if (locateObj != null)
        {
            instanceIDTable.Add(locateObj.GetInstanceID());
        }
        else
        {
            UnityEngine.Debug.LogWarning("Can not load: " + path);
        }
    }

    [OnOpenAsset(0)]
    private static bool OnOpenAsset(int instanceID, int line)
    {
        if (line < 0)
        {
            return false;
        }

        if (instanceIDTable == null)
        {
            instanceIDTable = new HashSet<int>();
            AddLocateMonoScript("Assets/Game/Scripts/Lua/LuaLog.cs");
            AddLocateMonoScript("Assets/Game/Scripts/Lua/Editor/LuaTool.cs");
            AddLocateMonoScript("Assets/Game/Scripts/Boot/GameRoot.cs");
            AddLocateMonoScript("Assets/ToLua/ToLua/Core/ToLua.cs");
            AddLocateMonoScript("Assets/ToLua/ToLua/Core/LuaFunction.cs");
            AddLocateMonoScript("Assets/ToLua/ToLua/Core/LuaState.cs");
            AddLocateMonoScript("Assets/ToLua/ToLua/Core/LuaStatePtr.cs");
        }

        if (!instanceIDTable.Contains(instanceID))
        {
            return false;
        }

        var condition = ConsoleWindow.Instance.CurrentCondition;
        if (string.IsNullOrEmpty(condition))
        {
            return false;
        }

        if (regex1 == null)
        {
            regex1 = new Regex(@"\[.*""(.*)""\]:(.*?):");
        }

        var match1 = regex1.Match(condition);
        if (match1.Success && match1.Groups.Count > 2)
        {
            var fileName = match1.Groups[1].Value;
            var filePath = GetFilePath(fileName);
            var fileLine = int.Parse(match1.Groups[2].Value);
            return OpenFile(filePath, fileLine);
        }

        if (regex2 == null)
        {
            regex2 = new Regex(@"\[(.*):(.*?)\]:");
        }

        var match2 = regex2.Match(condition);
        if (match2.Success && match2.Groups.Count > 2)
        {
            var fileName = match2.Groups[1].Value;
            var filePath = GetFilePath(fileName);
            var fileLine = int.Parse(match2.Groups[2].Value);
            return OpenFile(filePath, fileLine);
        }

        if (regex3 == null)
        {
            regex3 = new Regex(@"^(.*).lua:(.*):(.*?):");
        }

        var match3 = regex3.Match(condition);
        if (match3.Success && match3.Groups.Count > 3)
        {
            var filePath = match3.Groups[1].Value;
            var fileLine = int.Parse(match3.Groups[2].Value);
            return OpenFile(filePath, fileLine);
        }

        if (regex4 == null)
        {
            regex4 = new Regex(@"^Checking (.*).lua (.*?) warning");
        }

        var match4 = regex4.Match(condition);
        if (match4.Success && match4.Groups.Count > 2)
        {
            var filePath = match4.Groups[1].Value;
            var fileLine = 0;
            return OpenFile(filePath, fileLine);
        }

        return false;
    }

    private static string GetFilePath(string fileName)
    {
        return Path.Combine("Assets/Game/Lua", fileName);
    }

    private static bool OpenFile(string filePath, int fileLine)
    {
        if (!filePath.EndsWith(".lua"))
        {
            filePath += ".lua";
        }

        if (string.IsNullOrEmpty(SublimeText))
        {
            var script = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(filePath);
            return AssetDatabase.OpenAsset(script, fileLine);
        }
        else
        {
            var fullPath = Path.GetFullPath(filePath);
            if (File.Exists(fullPath))
            {
                var cmd = string.Format("\"{0}\":{1}", fullPath, fileLine);
                Process.Start(SublimeText, cmd);
                return true;
            }

            return false;
        }
    }
}
