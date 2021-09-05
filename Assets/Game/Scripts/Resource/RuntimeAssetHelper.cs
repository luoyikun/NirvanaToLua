using UnityEngine.Networking;
using System.IO;

public static class RuntimeAssetHelper
{
    public static void InsureDirectory(string path)
    {
        var dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }
    }

    public static void WriteWebRequestData(string path, UnityWebRequest unityWebRequest)
    {
        InsureDirectory(path);
        File.WriteAllBytes(path, unityWebRequest.downloadHandler.data);
    }

    public static bool TryWriteWebRequestData(string path, UnityWebRequest unityWebRequest)
    {
        if (unityWebRequest.downloadHandler.data.Length <= 0)
        {
            UnityEngine.Debug.LogErrorFormat("[RuntimeAssetHelper] TryWriteWebRequestData fail, length is 0, {0}", path);
            return false;
        }

        bool succ = true;
        try
        {
            InsureDirectory(path);
            File.WriteAllBytes(path, unityWebRequest.downloadHandler.data);
        }
        catch (System.Exception)
        {
            UnityEngine.Debug.LogErrorFormat("[RuntimeAssetHelper] TryWriteWebRequestData fail, write fail, {0}", path);
            succ = false;
        }

        return succ;
    }

    public static string IntToString(int value, string format)
    {
        return value.ToString(format);
    }
}
