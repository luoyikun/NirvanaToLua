using UnityEngine;
using UnityEditor;

public class InitializeOnLoad {
    [InitializeOnLoadMethod]
    public static void AutoSetCacheServer()
    {
        var			myCacheServerIp					= "192.168.9.50";

        var			cacheServerIpPrefKey			= "CacheServerIPAddress";
        var			cacheServerEnabledPrefKey		= "CacheServerEnabled";

        var			ip = EditorPrefs.GetString( cacheServerIpPrefKey, string.Empty ).Trim();
        var			state = EditorPrefs.GetBool( cacheServerEnabledPrefKey );

        if( ip == myCacheServerIp && state )
            return;

        if( ip != string.Empty && ip != myCacheServerIp || true )
            Debug.LogErrorFormat( "Cache Server地址已从 {0} 变更为 {1}！", ip, myCacheServerIp );
        else
            Debug.LogWarningFormat( "配置Cache Server: {0}", myCacheServerIp );

        EditorPrefs.SetString( cacheServerIpPrefKey, myCacheServerIp );
        EditorPrefs.SetBool( cacheServerEnabledPrefKey, true );
    }
}
