using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;

public partial class CheckResources
{
    void LuaWindow(int toolbarID)
    {
        KeyWorldModuleWindow(CheckLuaFolder);
        EditorGUILayout.HelpBox("遍历目录下的所有Lua文件，逐行搜索关键词，保存在存储目录中", MessageType.Info);
    }

    void CheckLuaFolder(DirectoryInfo dir)
    {
        var files = dir.GetFiles("*.lua", SearchOption.AllDirectories);
        if (files.Length > 0)
        {
            foreach (var file in files)
            {
                CheckLuaFile(file);
            }
        }
    }

    void CheckLuaFile(FileInfo file)
    {
        StreamReader sr = file.OpenText();
        StringBuilder sb = new StringBuilder();

        bool isSgin = false;
        int row = 0;
        while (!sr.EndOfStream)
        {
            string line = sr.ReadLine();
            row++;

            isSgin = line.Contains(sign) && !line.Contains("--");

            if (isSgin)
            {
                sb.AppendLine(row + "---" + line);
            }
        }

        sr.Dispose();
        if (!string.IsNullOrEmpty(sb.ToString()))
        {
            file.CreatTxt(search_Dir_Path, record_Dir_Path, sb.ToString());
        }
    }
}

public static class Extension
{
    public static bool Contains(this string txt, List<string> signs)
    {
        foreach (var sign in signs)
        {
            if (txt.Contains(sign))
            {
                return true;
            }
        }
        return false;
    }

    public static void CreatTxt(this FileInfo file, string search_Dir_Path, string record_Dir_Path, string content)
    {
        string[] sign = search_Dir_Path.Split('/');
        int index = file.FullName.IndexOf(sign[sign.Length - 1]);
        string rootDir = file.FullName.Substring(index);
        string targetDir = record_Dir_Path + "/" + rootDir;
        string dirPath = targetDir.Replace(file.Name, string.Empty);
        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }

        string recordPath = dirPath + file.Name.Replace(".lua", ".txt");
        File.WriteAllText(recordPath, content);
    }
}
