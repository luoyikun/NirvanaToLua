//------------------------------------------------------------------------------
// This file is part of MistLand project in Nirvana.
// Copyright © 2016-2016 Nirvana Technology Co., Ltd.
// All Right Reserved.
//------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using Nirvana.Editor;
using UnityEditor;
using UnityEngine;

/// <summary>
/// The lua tool used to build data for lua.
/// </summary>
public static class LuaTool
{
    private static Dictionary<string, long> recordDic = new Dictionary<string, long>();

    private static void ReadRecord(bool isLuajit)
    {
        recordDic.Clear();

        string path = isLuajit ?
                         Application.dataPath + "/../Build/log/compile_luajit.txt" :
                         Application.dataPath + "/../Build/log/compile_lua.txt";

        if (!File.Exists(path))
        {
            return;
        }

        string[] lines = File.ReadAllLines(path);
        for (int i = 0; i < lines.Length; i++)
        {
            if (string.IsNullOrEmpty(lines[i]))
            {
                continue;
            }

            string[] ary = lines[i].Split(' ');
            recordDic.Add(ary[0], long.Parse(ary[1]));
        }
    }

    private static void WriteRecord(bool isLuajit)
    {
        string path = isLuajit ?
                       Application.dataPath + "/../Build/log/compile_luajit.txt" :
                       Application.dataPath + "/../Build/log/compile_lua.txt";

        string dir_name = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir_name))
        {
            Directory.CreateDirectory(dir_name);
        }

        List<string> list = new List<string>();
        foreach (var item in recordDic)
        {
            list.Add(string.Format("{0} {1}", item.Key, item.Value));
        }

        File.WriteAllLines(path, list.ToArray());
        recordDic.Clear();
    }

    /// <summary>
    /// Compile all kinds of lua bundle.
    /// </summary>
    [MenuItem("Nirvana/Lua/Build All")]
    public static void BuildLuaAll()
    {
        BuidLuaBundleImpl(false);
        BuidLuaBundleJitImpl(false);
    }

    /// <summary>
    /// Compile the lua source file into bundle.
    /// </summary>
    [MenuItem("Nirvana/Lua/Build Bundle")]
    public static void BuidLuaBundle()
    {
        BuidLuaBundleImpl(false);
    }

    /// <summary>
    /// Compile the lua source file into bundle with jit.
    /// </summary>
    [MenuItem("Nirvana/Lua/Build Bundle Jit")]
    public static void BuidLuaBundleJit()
    {
        BuidLuaBundleJitImpl(false);
    }

    /// <summary>
    /// Compile all kinds of lua bundle.
    /// </summary>
    [MenuItem("Nirvana/Lua/Rebuild All")]
    public static void RebuildLuaAll()
    {
        BuidLuaBundleImpl(true);
        BuidLuaBundleJitImpl(true);
    }

    /// <summary>
    /// Compile the lua source file into bundle.
    /// </summary>
    [MenuItem("Nirvana/Lua/Rebuild Bundle")]
    public static void RebuidLuaBundle()
    {
        BuidLuaBundleImpl(true);
    }

    /// <summary>
    /// Compile the lua source file into bundle with jit.
    /// </summary>
    [MenuItem("Nirvana/Lua/Rebuild Bundle Jit")]
    public static void RebuidLuaBundleJit()
    {
        BuidLuaBundleJitImpl(true);
    }

    private static void BuidLuaBundleImpl(bool rebuild)
    {
        recordDic.Clear();
        if (!rebuild)
        {
            ReadRecord(false);
        }

        var bundlePath = Path.Combine(
            Application.dataPath, "Game/LuaBundle");
        var luaFiles = Directory.GetFiles(
                LuaConst.luaDir, "*.lua", SearchOption.AllDirectories);
        var toluaFiles = Directory.GetFiles(
            LuaConst.toluaDir, "*.lua", SearchOption.AllDirectories);

        using (var progress = new ProgressIndicator("Build Bundle for lua."))
        {
            progress.SetTotal(luaFiles.Length + toluaFiles.Length + 1);
            if (progress.Show("Start build bundle for lua."))
            {
                return;
            }

            var sourceTable = new Dictionary<string, bool>(
                StringComparer.Ordinal);
            if (CompileLuaBytesFiles(
                LuaConst.luaDir,
                luaFiles,
                bundlePath,
                rebuild,
                sourceTable,
                progress))
            {
                return;
            }

            if (CompileLuaBytesFiles(
                LuaConst.toluaDir,
                toluaFiles,
                bundlePath,
                rebuild,
                sourceTable,
                progress))
            {
                return;
            }

            if (RemoveDeletedSource(bundlePath, sourceTable, progress))
            {
                return;
            }

            AssetDatabase.Refresh();
        }

        WriteRecord(false);
    }

    private static void BuidLuaBundleJitImpl(bool rebuild)
    {
        recordDic.Clear();
        if (!rebuild)
        {
            ReadRecord(true);
        }

        var bundlePath = Path.Combine(
            Application.dataPath, "Game/LuaBundleJit");
        var luaFiles = Directory.GetFiles(
                LuaConst.luaDir, "*.lua", SearchOption.AllDirectories);
        var toluaFiles = Directory.GetFiles(
            LuaConst.toluaDir, "*.lua", SearchOption.AllDirectories);

        using (var progress = new ProgressIndicator("Build Bundle for lua jit."))
        {
            progress.SetTotal(luaFiles.Length + toluaFiles.Length + 1);
            if (progress.Show("Start build bundle for lua jit."))
            {
                return;
            }

            var sourceTable = new Dictionary<string, bool>(
                StringComparer.Ordinal);
            if (CompileLuaJitBytesFiles(
                LuaConst.luaDir,
                luaFiles,
                bundlePath,
                rebuild,
                sourceTable,
                progress))
            {
                return;
            }

            if (CompileLuaJitBytesFiles(
                LuaConst.toluaDir,
                toluaFiles,
                bundlePath,
                rebuild,
                sourceTable,
                progress))
            {
                return;
            }

            if (RemoveDeletedSource(
                bundlePath,
                sourceTable,
                progress))
            {
                return;
            }

            AssetDatabase.Refresh();
        }

        WriteRecord(true);
    }

    private static long GetTimeStamp(DateTime time)
    {
        DateTime startTime = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        return (long)(time - startTime).TotalMilliseconds;
    }


    private static bool IsNeedComplile(string file, string toFile)
    {
        if (!recordDic.ContainsKey(file) 
            || !recordDic.ContainsKey(toFile))
        {
            return true;
        }

        long record_write_time = recordDic[file];
        long write_time = GetTimeStamp(File.GetLastWriteTime(file));
        if (record_write_time != write_time)
        {
            return true;
        }

        record_write_time = recordDic[toFile];
        write_time = GetTimeStamp(File.GetLastWriteTime(toFile));
        if (record_write_time != write_time)
        {
            return true;
        }

        return false;
    }

    private static bool CompileLuaBytesFiles(
        string sourceDir,
        string[] sourceFiles,
        string destDir,
        bool rebuild,
        Dictionary<string, bool> sourceTable,
        ProgressIndicator progress)
    {
        if (!Directory.Exists(sourceDir))
        {
            return true;
        }

        // Compile source files into destination directory.
        foreach (var file in sourceFiles)
        {
            var uri1 = new Uri(file);
            var uri2 = new Uri(sourceDir + "/");
            var relativePath = uri2.MakeRelativeUri(uri1).OriginalString;
            if (progress.Show("Compile: {0}", relativePath))
            {
                return true;
            }

            sourceTable.Add(relativePath, true);

            var dest = Path.Combine(destDir, relativePath + ".bytes");
            var dir = Path.GetDirectoryName(dest);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            if (IsNeedComplile(file, dest))
            {
                DietLua(file, dest);

                if (recordDic.ContainsKey(file))
                {
                    recordDic.Remove(file);
                }
                recordDic.Add(file, GetTimeStamp(File.GetLastWriteTime(file)));

                if (recordDic.ContainsKey(dest))
                {
                    recordDic.Remove(dest);
                }
                recordDic.Add(dest, GetTimeStamp(File.GetLastWriteTime(dest)));
            }

            progress.AddProgress();
        }

        return false;
    }

    private static bool CompileLuaJitBytesFiles(
        string sourceDir,
        string[] sourceFiles,
        string destDir,
        bool rebuild,
        Dictionary<string, bool> sourceTable,
        ProgressIndicator progress)
    {
        if (!Directory.Exists(sourceDir))
        {
            return true;
        }

        // Compile source files into destination directory.
        foreach (var file in sourceFiles)
        {
            var uri1 = new Uri(file);
            var uri2 = new Uri(sourceDir + "/");
            var relativePath = uri2.MakeRelativeUri(uri1).OriginalString;
            if (progress.Show("Compile: {0}", relativePath))
            {
                return true;
            }

            sourceTable.Add(relativePath, true);

            var dest = Path.Combine(destDir, relativePath + ".bytes");
            var dir = Path.GetDirectoryName(dest);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            if (IsNeedComplile(file, dest))
            {
                CompileLuaJit(file, dest);

                if (recordDic.ContainsKey(file))
                {
                    recordDic.Remove(file);
                }
                recordDic.Add(file, GetTimeStamp(File.GetLastWriteTime(file)));

                if (recordDic.ContainsKey(dest))
                {
                    recordDic.Remove(dest);
                }
                recordDic.Add(dest, GetTimeStamp(File.GetLastWriteTime(dest)));
            }

            progress.AddProgress();
        }

        return false;
    }

    private static bool RemoveDeletedSource(
        string destDir,
        Dictionary<string, bool> sourceTable,
        ProgressIndicator progress)
    {
        var destFiles = Directory.GetFiles(
            destDir, "*.lua.bytes", SearchOption.AllDirectories);
        foreach (var file in destFiles)
        {
            var uri1 = new Uri(file);
            var uri2 = new Uri(destDir + "/");
            var relativePath = uri2.MakeRelativeUri(uri1).OriginalString;
            if (progress.Show("Check delete: {0}", relativePath))
            {
                return true;
            }

            var key = relativePath.Remove(relativePath.Length - 6, 6);
            if (!sourceTable.ContainsKey(key))
            {
                File.Delete(file);
                var metaFile = file.Remove(file.Length - 6, 6) + ".meta";
                if (File.Exists(metaFile))
                {
                    File.Delete(metaFile);
                }
            }
        }

        progress.AddProgress();
        return false;
    }

    private static void DietLua(string sourceFile, string targetFile)
    {
        var executable = Path.GetFullPath("Tools/lua.exe");
        var argument = string.Format(
            "LuaSrcDiet.lua --basic {0} -o {1}", sourceFile, targetFile);
        var workingDirectory = Path.GetFullPath("Tools/LuaSrcDiet-0.11.2");
        RunProcess(executable, argument, workingDirectory);
    }

    private static void CompileLuaJit(string sourceFile, string targetFile)
    {
        var workingDirectory = Path.GetFullPath("Tools");
        var relativePath = RelativePath(workingDirectory, sourceFile);

        var executable = Path.GetFullPath("Tools/luajit.exe");
        var argument = string.Format("-b -g {0} {1}", relativePath, targetFile);
        RunProcess(executable, argument, workingDirectory);
    }

    private static void RunProcess(
        string executable,
        string argument,
        string workingDirectory,
        Func<string, bool> filter = null)
    {
        var startInfo = new ProcessStartInfo(executable, argument);
        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;
        startInfo.RedirectStandardOutput = true;
        startInfo.RedirectStandardError = true;
        startInfo.StandardOutputEncoding = Encoding.UTF8;
        startInfo.StandardErrorEncoding = Encoding.UTF8;
        startInfo.WorkingDirectory = workingDirectory;

        using (var proc = Process.Start(startInfo))
        {
            proc.OutputDataReceived += (sender, e) =>
            {
                var text = e.Data.Trim();
                if (!string.IsNullOrEmpty(text))
                {
                    if (filter != null)
                    {
                        if (filter(text))
                        {
                            UnityEngine.Debug.Log(text);
                        }
                    }
                    else
                    {
                        UnityEngine.Debug.Log(text);
                    }
                }
            };

            proc.ErrorDataReceived += (sender, e) =>
            {
                var text = e.Data.Trim();
                if (!string.IsNullOrEmpty(text))
                {
                    if (filter != null)
                    {
                        if (filter(text))
                        {
                            UnityEngine.Debug.LogError(text);
                        }
                    }
                    else
                    {
                        UnityEngine.Debug.LogError(text);
                    }
                }
            };

            proc.BeginOutputReadLine();
            proc.WaitForExit();
            proc.Close();
        }
    }

    private static bool IsSubPathOf(this string path, string basePath)
    {
        var normalizedPath = Path.GetFullPath(
            path.Replace('/', '\\'));
        var normalizedBasePath = Path.GetFullPath(
            basePath.Replace('/', '\\'));

        return normalizedPath.StartsWith(
            normalizedBasePath, StringComparison.OrdinalIgnoreCase);
    }

    private static string RelativePath(
        string absolutePath, string relativeTo)
    {
        var absDirs = absolutePath.Split('\\', '/');
        var relDirs = relativeTo.Split('\\', '/');

        // Get the shortest of the two paths
        int length = Mathf.Min(absDirs.Length, relDirs.Length);

        // Find common root
        int lastCommonRoot = -1;
        for (int i = 0; i < length; ++i)
        {
            if (absDirs[i] == relDirs[i])
            {
                lastCommonRoot = i;
            }
            else
            {
                break;
            }
        }

        // If we didn't find a common prefix then throw
        if (lastCommonRoot == -1)
        {
            throw new ArgumentException("Paths do not have a common base");
        }

        //Build up the relative path
        var relativePath = new StringBuilder();

        // Add on the ..
        for (int i = lastCommonRoot + 1; i < absDirs.Length; ++i)
        {
            if (absDirs[i].Length > 0)
            {
                relativePath.Append("../");
            }
        }

        // Add on the folders
        for (int i = lastCommonRoot + 1; i < relDirs.Length - 1; ++i)
        {
            relativePath.Append(relDirs[i] + "/");
        }

        relativePath.Append(relDirs[relDirs.Length - 1]);
        return relativePath.ToString();
    }
}
