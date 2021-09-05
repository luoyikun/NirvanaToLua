//------------------------------------------------------------------------------
// Copyright (c) 2018-2018 Nirvana Technology Co. Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

using System;
using System.Collections;
using LuaInterface;
using Nirvana;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.IO.Compression;
using System.IO;

/// <summary>
/// Used to start the game.
/// </summary>
public sealed class GameRoot : MonoBehaviour
{
    [SerializeField]
    private GameObject loadingPrefab;
    private GameObject loading;

    private LuaState luaState;
    private LuaBundleLoader luaLoader;

    private LuaFunction luaUpdate;
    private LuaFunction luaStop;
    private LuaFunction luaFocus;
    private LuaFunction luaPause;
    private LuaFunction luaExecuteGm;
    private LuaFunction luaCollectgarbage;
    private LuaFunction luaCheckMemoryLeak;

    private LuaFunction luaPlayAudio;

    private LuaLooper looper = null;
    private bool isDestroying = false;

    /// <summary>
    /// Gets the singleton instance.
    /// </summary>
    public static GameRoot Instance { get; private set; }

    /// <summary>
    /// The stop event for lua.
    /// </summary>
    [NoToLua]
    public event Action StopEvent;

    [NoToLua]
    public event Action UpdateEvent;

    /// <summary>
    /// The lua state.
    /// </summary>
    [NoToLua]
    public LuaState LuaState
    {
        get
        {
            return luaState;
        }
    }

    public void Restart()
    {
        Scheduler.Clear();

        if (this.luaState != null)
        {
            if (this.luaStop != null)
            {
                this.luaStop.Call();
            }

            if (this.StopEvent != null)
            {
                this.StopEvent();
            }
            var oldState = this.luaState;
            this.luaState = null;
            Scheduler.Delay(() =>
                {
                    oldState.Dispose();

                    GameObject.Destroy(this.gameObject);
                    GameObject.Destroy(this.loading);

                    AssetBundle.UnloadAllAssetBundles(true);
                    Resources.UnloadUnusedAssets();

                    SceneManager.LoadScene(0);
                }
            );
            this.luaLoader = null;
        }

        DG.Tweening.DOTween.KillAll(false);
        OverrideOrderGroupMgr.Instance.OnGameStop();
        CameraCullObjMgr.Instance.OnGameStop();
        FontTextureReBuild.Instance.OnGameStop();
        EffectOrderGroup.OnGameStop();
        SceneRenderers.OnGameStop();
        RichTextGroup.ClearPool();

        AssetBundle.UnloadAllAssetBundles(true);
        Resources.UnloadUnusedAssets();

        GC.Collect();

        if (this.looper != null)
        {
            GameObject.Destroy(this.looper);
        }
    }

    public void PruneLuaBundles()
    {
        luaLoader.PruneLuaBundles();
    }

    public void SetBuglyUserID(string userID)
    {
        //BuglyAgent.SetUserId(userID);
    }

    public void SetBuglySceneID(int sceneID)
    {
        //BuglyAgent.SetScene(sceneID);
    }

    /// <summary>
    /// 限制屏幕分辨率的尺寸.
    /// </summary>
    public void LimitScreenResolution(int limit)
    {
        if (Screen.width > Screen.height)
        {
            if (Screen.height > limit)
            {
                var radio = (float)Screen.width / Screen.height;
                Screen.SetResolution((int)(limit * radio), limit, true);
            }
        }
        else
        {
            if (Screen.width > limit)
            {
                var radio = (float)Screen.width / Screen.height;
                Screen.SetResolution(limit, (int)(limit * radio), true);
            }
        }
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaOpen_Socket_Core(IntPtr l)
    {
        return LuaDLL.luaopen_socket_core(l);
    }

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    private static int LuaOpen_Mime_Core(IntPtr l)
    {
        return LuaDLL.luaopen_mime_core(l);
    }

    private void Awake()
    {
        this.UpdateLogEnable();

        Debugger.Log("game root awake");
        // 创建Loading界面.
        this.loading = GameObject.Find("Loading");
        if (this.loading == null)
        {
            this.loading = GameObject.Instantiate(this.loadingPrefab);
            this.loading.name = this.loading.name.Replace("(Clone)", string.Empty);
            GameObject.DontDestroyOnLoad(this.loading);
        }

        // 初始化bugly
        //this.InitBuglySDK();

        // 永久存在的单件.
        Instance = this;
        GameObject.DontDestroyOnLoad(this.gameObject);

        // 初始化日志工具.
        LogSystem.AddAppender(new LogUnity());

        // 监听低内存更新
        Application.lowMemory -= this.OnLowMemory;
        Application.lowMemory += this.OnLowMemory;

        // 监听下载事件
#if UNITY_EDITOR
        AssetManager.DownloadStartEvent +=
            url => Debug.Log("##DownloadStart: " + url);
        AssetManager.DownloadFinishEvent +=
            url => Debug.Log("##DownloadFinish: " + url);
#endif
    }

    private void InitBuglySDK()
    {
#if _DEBUG
        // 开启SDK的日志打印，发布版本请务必关闭
        BuglyAgent.ConfigDebugMode(true);
#endif

        // 配置标识参数, 必须在InitWithAppId之前调用.
        BuglyAgent.ConfigDefault(
            ChannelAgent.GetChannelID(),
            Application.version,
            string.Empty,
            0);

#if UNITY_IOS
        BuglyAgent.InitWithAppId("415b174bb2");
#elif UNITY_ANDROID
        BuglyAgent.InitWithAppId("4e2be47f19");
#endif

        // 如果你确认已在对应的iOS工程或Android工程中初始化SDK，那么在脚本中只
        // 需启动C#异常捕获上报功能即可
        BuglyAgent.EnableExceptionHandler();
    }

    private void OnDestroy()
    {
        Instance = null;
    }

    private void Start()
    {
#if UNITY_EDITOR
        UnityEngine.PlayerPrefs.SetInt("develop_mode", 1);  // 编辑器
        DeveloperHotupdate.CacheAllFileModifyTime();

        string path = Path.Combine(Application.dataPath, "../AssetsCheck/ErrorStatistics.txt");
        if (File.Exists(path))
        {
            string[] lines = File.ReadAllLines(path);
            if (lines.Length > 0)
            {
                Debug.LogError("检查结果显示存在不规范资源，请尽快解决！");
                for (int i = 0; i < lines.Length; i++)
                {
                    Debug.LogError(lines[i]);
                }
            }
        }
#endif

#if UNITY_IOS
        UnzipAssetBundle unzip = new UnzipAssetBundle();
        unzip.Start(()=>
        {
            this.StartGame();
        });
		return;

#endif

        this.StartGame();
    }

    private void StartGame()
    {
        // 初始化资源管理器.
        Debugger.Log("gameroot start game");

        OverrideOrderGroupMgr.Instance.OnGameStartup();

        EncryptMgr.InitEncryptKey();

        // 构造Lua脚本加载器.
        this.luaLoader = new LuaBundleLoader();
        this.luaLoader.LoadAliasResPathMap();

        // 初始化Lua虚拟机.
        this.luaState = new LuaState();

        this.luaState.OpenLibs(LuaDLL.luaopen_struct);
#if UNITY_STANDALONE_OSX || UNITY_EDITOR_OSX
        luaState.OpenLibs(LuaDLL.luaopen_bit);
#endif
        this.OpenLuaSocket();
        this.OpenCJson();
        LuaLog.OpenLibs(this.luaState);

        this.luaState.LuaPushFunction(AddLuaBundle);
        this.luaState.LuaSetGlobal("AddLuaBundle");

        this.luaState.LuaSetTop(0);
        LuaBinder.Bind(this.luaState);
        DelegateFactory.Init();
        LuaCoroutine.Register(this.luaState, this);

        looper = this.gameObject.AddComponent<LuaLooper>();
        looper.luaState = this.luaState;

#if UNITY_EDITOR
        SetGlobalBoolean("UNITY_EDITOR", true);
        var simulateAssetBundle = (UnityEditor.EditorPrefs.GetInt("SimulateAssetBundlesMode", 1) == 1);
        SetGlobalBoolean("GAME_ASSETBUNDLE", !simulateAssetBundle);
#else
        SetGlobalBoolean("GAME_ASSETBUNDLE", true);
#endif

#if UNITY_EDITOR_WIN
        SetGlobalBoolean("UNITY_EDITOR_WIN", true);
#endif

#if UNITY_STANDALONE_WIN
        SetGlobalBoolean("UNITY_STANDALONE_WIN", true);
#endif

#if UNITY_IOS
        SetGlobalBoolean("UNITY_IOS", true);
#endif

#if UNITY_ANDROID
        SetGlobalBoolean("UNITY_ANDROID", true);
#endif

#if UNITY_STANDALONE
        SetGlobalBoolean("UNITY_STANDALONE", true);
#endif

        this.luaLoader.SetupLuaLoader(this.luaState);
        this.luaState.Start();

        try
        {
            Debugger.Log("startup lua");
            // 执行启动文件.
            this.luaState.DoFile("startup.lua");

            // 获取Update函数
            this.luaUpdate = this.luaState.GetFunction("GameUpdate");
            this.luaStop = this.luaState.GetFunction("GameStop");
            this.luaFocus = this.luaState.GetFunction("GameFocus");
            this.luaPause = this.luaState.GetFunction("GamePause");
            this.luaExecuteGm = this.luaState.GetFunction("ExecuteGm");
            this.luaCheckMemoryLeak = this.LuaState.GetFunction("CheckMemoryLeak");
            this.luaCollectgarbage = this.luaState.GetFunction("Collectgarbage");

            var eventDispatcher = EventDispatcher.Instance;

            eventDispatcher.EnableGameObjAttachFunc = this.luaState.GetFunction("EnableGameObjAttachEvent");
            eventDispatcher.DisableGameObjAttachFunc = this.luaState.GetFunction("DisableGameObjAttachEvent");
            eventDispatcher.DestroyGameObjAttachFunc = this.luaState.GetFunction("DestroyGameObjAttachEvent");

            eventDispatcher.EnableLoadRawImageFunc = this.luaState.GetFunction("EnableLoadRawImageEvent");
            eventDispatcher.DisableLoadRawImageFunc = this.luaState.GetFunction("DisableLoadRawImageEvent");
            eventDispatcher.DestroyLoadRawImageFunc = this.luaState.GetFunction("DestroyLoadRawImageEvent");


            eventDispatcher.ProjectileSingleEffectFunc = this.luaState.GetFunction("ProjectileSingleEffectEvent");
            eventDispatcher.UIMouseClickEffectFunc = this.luaState.GetFunction("UIMouseClickEffectEvent");

            this.luaPlayAudio = this.luaState.GetFunction("PlayAudio");
            ClickSound.OnClick = LuaPlayAudio;

        }
        catch (LuaException exp)
        {
            Debug.LogError(exp.Message);
        }
    }

    private void Update()
    {
        if (this.isDestroying)
        {
            return;
        }

        if (this.luaState != null)
        {
            this.luaState.Collect();
            this.luaUpdate.Call();
        }

        FontTextureReBuild.Instance.Update();

#if UNITY_EDITOR
        if (null != this.UpdateEvent)
        {
            this.UpdateEvent();
        }
#endif
    }

    private void OnApplicationFocus(bool hasFocus)
    {
        if (this.luaState != null)
        {
            this.luaFocus.Call(hasFocus);
        }
    }

    private void OnApplicationPause(bool pauseStatus)
    {
        if (this.luaState != null)
        {
            this.luaPause.Call(pauseStatus);
        }
    }

    private void SetGlobalBoolean(string key, bool value)
    {
        this.luaState.LuaPushBoolean(value);
        this.luaState.LuaSetGlobal(key);
    }

#if UNITY_EDITOR
    private void OnApplicationQuit()
    {
        if (this.luaState != null)
        {
            if (this.luaStop != null)
            {
                this.luaStop.Call();
            }

            if (this.StopEvent != null)
            {
                this.StopEvent();
            }

            this.luaState.Dispose();
            this.luaState = null;
        }
    }
#endif

    [MonoPInvokeCallback(typeof(LuaCSFunction))]
    // private int AddLuaBundle(IntPtr l)
    private static int AddLuaBundle(IntPtr l)
    {
        int len;
        string luaFile = LuaDLL.luaL_checklstring(l, 1, out len);
        string bundleName = LuaDLL.luaL_checklstring(l, 2, out len);

        GameRoot.Instance.luaLoader.AddLuaBundle(luaFile, bundleName);

        return 0;
    }

    public static bool IsLuaFileExist(String path)
    {
        return GameRoot.Instance.luaLoader.IsLuaFileExist(path);
    }

    public static string GetAliasResPath(String path)
    {
        return GameRoot.Instance.luaLoader.GetAliasResPath(path);
    }

    private void LuaPlayAudio(string bundleName, string assetName)
    {
        this.luaPlayAudio.Call(bundleName, assetName);
    }

    private void OpenLuaSocket()
    {
        LuaConst.openLuaSocket = true;
        this.luaState.BeginPreLoad();
        this.luaState.RegFunction("socket.core", LuaOpen_Socket_Core);
        this.luaState.RegFunction("mime.core", LuaOpen_Mime_Core);
        this.luaState.EndPreLoad();
    }

    private void OpenCJson()
    {
        this.luaState.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
        this.luaState.OpenLibs(LuaDLL.luaopen_cjson);
        this.luaState.LuaSetField(-2, "cjson");

        this.luaState.OpenLibs(LuaDLL.luaopen_cjson_safe);
        this.luaState.LuaSetField(-2, "cjson.safe");
    }

    public void UpdateLogEnable(bool isForceClose = false)
    {
        if (isForceClose)
        {
            Debug.unityLogger.logEnabled = false;
            Debugger.useLog = false;
            return;
        }

        if (!Debug.isDebugBuild
            || !ChannelAgent.GetOutlog())
        {
            Debugger.useLog = false;
            Debug.unityLogger.filterLogType = LogType.Error;
            return;
        }

        Debugger.useLog = true;
        Debug.unityLogger.filterLogType = LogType.Log;
    }

    private void OnLowMemory()
    {
        Collectgarbage("collect");

        if (this.luaState != null)
        {
            this.luaState.Collect();
        }

#if !UNITY_EDITOR
        GC.Collect();
#endif
    }

    /// <summary>
    /// Reduce the memory.
    /// </summary>
    public void ReduceMemory()
    {
        ScriptablePool.Instance.ClearAllUnused();
        //         Collectgarbage("collect");
        // 
        //         // Clear lua memory.
        //         if (this.luaState != null)
        //         {
        //             this.luaState.Collect();
        //         }

        // Clear the unity memory.
        //   Resources.UnloadUnusedAssets();
    }

    [NoToLua]
    public void ExecuteGm(string gm)
    {
        if (null != this.luaExecuteGm)
        {
            this.luaExecuteGm.Call(gm);
        }
    }

    [NoToLua]
    public double Collectgarbage(string param)
    {
        if (null != this.luaCollectgarbage)
        {
            return this.luaCollectgarbage.Invoke<string, double>(param);
        }
        return 0;
    }

#if UNITY_EDITOR
    [NoToLua]
    public void LuaCheckMemoryLeak()
    {
        if (null != this.luaCheckMemoryLeak)
        {
            this.luaCheckMemoryLeak.Call();
        }
    }

    private static string notice;
    private static float timer;
    [NoToLua]
    public static void ShowMessage(string str, float time)
    {
        notice = str;
        timer = Time.realtimeSinceStartup + time;
    }

    private void OnGUI()
    {
        if (timer > Time.realtimeSinceStartup)
        {
            Rect area = new Rect(Screen.width / 2 - 100, Screen.height / 2 - 50, 200, 100);
            GUI.Box(area, "");
            GUI.Label(area, notice, MessageStyle.NoticeStyle);
        }
    }

    [NoToLua]
    public static class MessageStyle
    {
        public static GUIStyle NoticeStyle { get; private set; }
        static MessageStyle()
        {
            NoticeStyle = new GUIStyle(GUI.skin.label)
            {
                fontSize = 40,
                alignment = TextAnchor.MiddleCenter,
                padding = new RectOffset(0, 0, 0, 0),
            };
        }
    }
#endif

}
