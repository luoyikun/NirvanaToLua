using LuaInterface;
using Nirvana;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

public class EncryptMgr
{
    private static  byte[] encryptKey;
    private static bool isEncryptAsset = false;
    private static bool isEncryptPath = false;
    
    public static void InitEncryptKey()
    {
        string key = ChannelAgent.GetEncryptKey();
        //key = "1";
        if (string.IsNullOrEmpty(key))
        {
            isEncryptAsset = false;
            return;
        }

        encryptKey = CalcEncryptKey(key);
        isEncryptAsset = true;
        isEncryptPath = true;
    }

    public static void SetIsEncryptPath(bool _isEncryptPath)
    {
        isEncryptPath = _isEncryptPath;
    }

    private static byte[] CalcEncryptKey(string key)
    {
        string[] keyAry = key.Split(',');
        var encryptKey = new byte[keyAry.Length];
        for (int i = 0; i < keyAry.Length; i++)
        {
            encryptKey[i] = Convert.ToByte(keyAry[i]);
        }

        return encryptKey;
    }

    public static bool IsEncryptAsset()
    {
        return isEncryptAsset;
    }

#if UNITY_EDITOR
    [NoToLua]
    public static void EncryptSteamFiles()
    {
        string path = Path.Combine(Application.streamingAssetsPath, "file_list.txt");
        byte[] encryptKey = CalcEncryptKey("1");
        string[] lines = File.ReadAllLines(path);
        EncryptStream fileStream = null;

        foreach (var line in lines)
        {
            string abPath = Path.Combine(Application.streamingAssetsPath, line);
            var abData = File.ReadAllBytes(abPath);
            fileStream = new EncryptStream(abPath, FileMode.Create);
            fileStream.SetEncryptKey(encryptKey);
            fileStream.Write(abData, 0, abData.Length);
            fileStream.Close();
            fileStream.Dispose();
        }

        var data = File.ReadAllBytes(path);
        fileStream = new EncryptStream(path, FileMode.Create);
        fileStream.SetEncryptKey(encryptKey);
        fileStream.Write(data, 0, data.Length);
        fileStream.Dispose();
    }
#endif

    private static Dictionary<string, string> encrpytPathMapO2N = new Dictionary<string, string>();
    private static Dictionary<string, string> encrpytPathSetN2O = new Dictionary<string, string>();
    public static string GetEncryptPath(string path)
    {
        if (!isEncryptPath || !isEncryptAsset)
        {
            return path;
        }

        if (encrpytPathMapO2N.ContainsKey(path))
        {
            return encrpytPathMapO2N[path];
        }

        string[] ary = path.Split('/');
        StringBuilder builder = new StringBuilder();
        for (int m = 0; m < ary.Length; m++)
        {
            string name = ary[m];
            if (string.IsNullOrEmpty(name))
            {
                continue;
            }

            if (m != 0)
            {
                builder.Append("/");
            }

            byte[] bytes = System.Text.Encoding.Default.GetBytes(name);
            for (int n = 0; n < bytes.Length; n++)
            {
                bytes[n] ^= encryptKey[n % encryptKey.Length];
            }

            int i = 0;
            int total = 0;
            while (i + 4 <= bytes.Length)
            {
                int num = bytes[i + 3] & 0xFF;
                num |= ((bytes[i + 2] << 8) & 0xFF00);
                num |= ((bytes[1 + 1] << 16) & 0xFF0000);
                num |= ((bytes[i] << 24) & 0xFF0000);
                i = i + 4;
                total += num;
            }

            string newName = total == 0 ? name : WordLibrary.GetEnWord(total);
            builder.Append(newName + "_" + name);
            //builder.Append(newName);
        }

        string newPath = builder.ToString();
        encrpytPathMapO2N.Add(path, newPath);

        if (encrpytPathSetN2O.ContainsKey(newPath))
        {
            Debug.LogErrorFormat("[EncryptMgr]GetEncryptPath calc new path error! {0} {1} {2}", path, newPath, encrpytPathSetN2O[newPath]);
        }
        else
        {
            encrpytPathSetN2O.Add(newPath, path);
        }

        return newPath;
    }

    public static string ReadEncryptFile(string path)
    {
        if (!isEncryptAsset)
        {
            return string.Empty;
        }

        if (!File.Exists(path))
        {
            return string.Empty;
        }

        int size = Convert.ToInt32(new FileInfo(path).Length);
        EncryptStream fileStream = new EncryptStream(path, FileMode.Open, FileAccess.Read, FileShare.None, size, false);
        fileStream.SetEncryptKey(encryptKey);
        byte[] buffer = new byte[size];
        int length = fileStream.Read(buffer, 0, buffer.Length);

        fileStream.Close();
        fileStream.Dispose();

        return Encoding.UTF8.GetString(buffer, 0, length);
    }

    public static bool DecryptAssetBundle(string path, string targetPath)
    {
        if (!isEncryptAsset)
        {
            return false;
        }

        if (!File.Exists(path))
        {
            return false;
        }

        if (File.Exists(targetPath))
        {
            return true;
        }

        string dirName = Path.GetDirectoryName(targetPath);
        if (!Directory.Exists(dirName))
        {
            Directory.CreateDirectory(dirName);
        }

        var data = File.ReadAllBytes(path);
        var fileStream = new EncryptStream(targetPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None, data.Length, false);
        fileStream.SetEncryptKey(encryptKey);
        fileStream.Write(data, 0, data.Length);
        fileStream.Close();
        fileStream.Dispose();

        return true;
    }

    public static string DecryptAgentAssets(string path)
    {
        if (!isEncryptAsset)
        {
            return string.Empty;
        }

        if (!File.Exists(path))
        {
            return string.Empty;
        }

        if (!path.StartsWith(Application.streamingAssetsPath))
        {
            return string.Empty;
        }

        string relativePath = Regex.Replace(path, Application.streamingAssetsPath, "");
        string targetPath = string.Format("{0}/AgentAssets/{1}", Application.persistentDataPath, relativePath);
        if (File.Exists(targetPath))
        {
            return targetPath;
        }

        string dirName = Path.GetDirectoryName(targetPath);
        if (!Directory.Exists(dirName))
        {
            Directory.CreateDirectory(dirName);
        }

        var data = File.ReadAllBytes(path);
        var fileStream = new EncryptStream(targetPath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.None, data.Length, false);
        fileStream.SetEncryptKey(encryptKey);
        fileStream.Write(data, 0, data.Length);
        fileStream.Close();
        fileStream.Dispose();
        return targetPath;
    }
}
