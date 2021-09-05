using System;
using System.Collections;
using System.IO;
using Nirvana;
using UnityEngine;
using UnityEngine.Networking;
using System.Collections.Generic;

public static class UtilU3d
{
    private static Dictionary<string, System.Object> cacheDataDic = new Dictionary<string, System.Object>();

    public static void CacheData(string key, System.Object value)
    {
        cacheDataDic[key] = value;
    }

    public static void DelCacheData(string key, System.Object value)
    {
        cacheDataDic[key] = null;
    }

    public static System.Object GetCacheData(string key)
    {
        return cacheDataDic.ContainsKey(key) ? cacheDataDic[key] : null;
    }

    public static void SetFilterLogType(LogType logType)
    {
        Debug.unityLogger.filterLogType = logType;
    }

    /*public static void PrefabLoad(
        string bundleName, string fileName, Action<GameObject> complete)
    {
        PrefabPool.Instance.Load(
            new AssetID(bundleName, fileName),
            prefab =>
            {
                if (null == prefab)
                {
                    Debug.LogErrorFormat(
                        "PrefabLoad:Load fail bundleName: {0}, fileName: {1}",
                        bundleName,
                        fileName);
                    complete(null);
                    return;
                }

                var obj = GameObject.Instantiate(prefab) as GameObject;
                if (null == obj)
                {
                    Debug.LogErrorFormat(
                        "PrefabLoad:Instantiate fail bundleName: {0}, fileName: {1}",
                        bundleName,
                        fileName);
                    complete(null);
                    return;
                }

                obj.name = obj.name.Replace("(Clone)", string.Empty);
                complete(obj);
                PrefabPool.Instance.Free(prefab);
            });
    }*/

    public static void RequestGet(string url)
    {
        GameRoot.Instance.StartCoroutine(
            RequestGetHelper(url));
    }

    public static void RequestGet(
        string url, Action<bool, string> complete)
    {
        GameRoot.Instance.StartCoroutine(
            RequestGetHelper(url, complete));
    }

    public static void Download(
        string url, string path, Action<bool, string> complete)
    {
        GameRoot.Instance.StartCoroutine(
            DownloadHelper(url, path, complete));
    }

    public static bool Upload(
        string url, string path, Action<bool, string> complete)
    {
        try
        {
            using (var file = File.OpenRead(path))
            {
                var bodyData = new byte[file.Length];
                file.Read(bodyData, 0, bodyData.Length);
                GameRoot.Instance.StartCoroutine(
                    UploadHelper(url, bodyData, complete));
                return true;
            }
        }
        catch (Exception ex)
        {
            Debug.LogError("Upload Exception:" + ex.Message);
            return false;
        }
    }

    private static IEnumerator RequestGetHelper(string url)
    {
        using (var www = UnityWebRequest.Get(url))
        {
            yield return www.SendWebRequest();
        }
    }

    private static IEnumerator RequestGetHelper(
        string url, Action<bool, string> complete)
    {
        using (var www = UnityWebRequest.Get(url))
        {
            yield return www.SendWebRequest();

            if (www.isNetworkError
                || www.isHttpError)
            {
                complete(false, www.error);
            }
            else
            {
                complete(true, www.downloadHandler.text);
            }
        }
    }

    private static IEnumerator DownloadHelper(
        string url, string path, Action<bool, string> complete)
    {
        using (var www = UnityWebRequest.Get(url))
        {
            yield return www.SendWebRequest();

            if (www.isNetworkError
                || www.isHttpError)
            {
                complete(false, www.error);
            }
            else
            {
                try
                {
                    var dir = Path.GetDirectoryName(path);
                    if (!Directory.Exists(dir))
                    {
                        Directory.CreateDirectory(dir);
                    }

                    using (var file = File.Create(path))
                    {
                        var data = www.downloadHandler.data;
                        file.Write(data, 0, data.Length);
                    }

                    complete(true, string.Empty);
                }
                catch (Exception ex)
                {
                    Debug.LogError("DownloadHelper Exception:" + ex.Message);
                    complete(false, "Exception");
                }
            }
        }
    }

    private static IEnumerator UploadHelper(
        string url, byte[] bodyData, Action<bool, string> complete)
    {
        using (var www = UnityWebRequest.Put(url, bodyData))
        {
            yield return www.SendWebRequest();

            if (www.isNetworkError)
            {
                complete(false, www.error);
            }
            else
            {
                complete(true, string.Empty);
            }
        }
    }

   public static float WatchFunRunTime(Action action, float log_time = 0, string format = "")
    {
        System.Diagnostics.Stopwatch sw = new System.Diagnostics.Stopwatch();
        sw.Start();
        action();
        sw.Stop();
        if (sw.ElapsedMilliseconds >= log_time)
        {
            Debug.Log(string.Format("{0} WatchFunRunTime :  {1}", format, sw.ElapsedMilliseconds));
        }
       
        return sw.ElapsedMilliseconds;
    }

    /*public static bool AudioPlayerIsPlaying(IAudioPlayer IAudioPlayer)
    {
        return IAudioPlayer.IsPlaying;
    }

    public static void StopAudioPlayer(IAudioPlayer IAudioPlayer)
    {
        IAudioPlayer.Stop();
    }*/

    public static void Screenshot(string path, System.Action<bool, string> callback, int size = 1)
    {
        Scheduler.RunCoroutine(CaptureScreenshot(path, callback, size));
    }

    private static IEnumerator CaptureScreenshot(string path, System.Action<bool, string> callback, int size)
    {
        string newPath = path;
    #if !UNITY_EDITOR
        newPath = path.Replace(Application.persistentDataPath + "/", "");
    #endif
        UnityEngine.ScreenCapture.CaptureScreenshot(newPath, size);
        float time = Time.time;
        bool b = false;
        yield return new WaitUntil(() =>
        {
            b = System.IO.File.Exists(newPath);
            return b || ((Time.time - time) > 1f);
        });
        string str = newPath;
        if (b == false)
        {
            str = "截屏出错！";
        }
        if (callback != null)
        {
            callback(b, str);
        }
    }

    public static void DeleteFile(string path)
    {
        bool isExist = File.Exists(path);
        if (isExist)
        {
            File.Delete(path);
        }
    }

    //强制重设摄像机
    public static void ForceReSetCamera()
    {
        var mainCamera = Camera.main;
        if (mainCamera != null && mainCamera.isActiveAndEnabled)
        {
            var cameraFollow = mainCamera.GetComponentInParent<CameraFollow>();
            if (null != cameraFollow)
            {
                cameraFollow.FieldOfView = 0;
            }  
        }
    }

    // 路径 和 限制最大字节 返回 1文件不存在 2文件过大
    public static int IsFileInfoLimit(string path, int length)
    {
        if (!File.Exists(path))
        {
            return 1;
        }
        FileInfo fileInfo = new FileInfo(path);
        if (fileInfo.Length <= length)
        {
            return 0;
        }
        return 2;
    }

    // 返回KB
    public static int GetFileInfoLength(string path)
    {
        if (!File.Exists(path))
        {
            return -1;
        }
        FileInfo fileInfo = new FileInfo(path);
        long legnth_kb = fileInfo.Length / 1024;
        int legnth = (int)legnth_kb;
        return legnth;
    }
}
