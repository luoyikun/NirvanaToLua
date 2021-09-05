
using UnityEngine.Networking;

public static class WebRequestExteions
{
    /// <summary>
    /// Add a new listener to the toggle.
    /// </summary>
    public static double GetByteDownloads(this UnityWebRequest webRequest)
    {
        return webRequest.downloadedBytes;
    }
}