using Newtonsoft.Json;
using Nirvana;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class SkillConfigEditor : EditorWindow
{
    private Animator _animator;
    private int _prefabId;
    private int _selectTriggerToolbal = 0;

    private int _selectEffectId = -1;
    private Vector2 _effectListScroll;

    private int _selectHaltId = -1;
    private Vector2 _haltsScroll;

    private int _selectSoundId = -1;
    private Vector2 _soundScroll;


    private int _selectActorToolbal = 0;

    private int _selectProjectileId = 0;
    private Vector2 _projectileScroll;

    private int _selectHurtId = 0;
    private Vector2 _hurtScroll;

    private int _timeLineId = 0;
    private Vector2 _timeLineScroll;

    private int _selectShakeId = 0;
    private Vector2 _shakeScroll;

    private int _selectFovId = 0;
    private Vector2 _fovScroll;

    private int _selectFadeId = 0;
    private Vector2 _fadeScroll;

    private int _selectFootStepId = 0;
    private Vector2 _footStepScroll;

    private Rect _upWindowRect = new Rect(230, 130, 300, 200);
    private Rect _middleRect = new Rect(210, 540, 330, 280);
    private Rect _blinkRect = new Rect(660, 530, 300, 100);
    private Rect _timeLineRect = new Rect(660, 660, 300, 300);
    private Rect _buttonRect = new Rect(660, 90, 700, 400);
    private Rect _timeLineInfoRect = new Rect(1000, 650, 300, 200);
    private Rect _deleteBtnRect_1 = new Rect(550, 120, 100, 30);
    private Rect _deleteBtnRect_2 = new Rect(550, 540, 100, 30);
    private readonly string[] _toolBarNames = new string[] { "effects", "halts", "sounds", "camerashakes", "camera fovs", "scenefades", "footstep" };
    private readonly string[] _actorToolbarNames = new string[] { "projectiles", "hurts", "others" };
    private readonly string[] HurtPosition = new string[] { "Root", "Hurt Root"};
    private readonly string[] HitRotation = new string[] { "Target", "HitDirection" };
    private readonly string[] StatusEnum = new string[] { "Idle", "Move", "Death"};
    private readonly string[] LocomotionEnum = new string[] { "Normal", "Fly", "Mount" };
    private readonly string[] OtherbtnNameList = new string[] { "", "", "", "冲刺", "钓鱼", "采集", "抱", "抱走", "蹲下", "转头1", "展示", "欢呼", "围观", "放手", "抬手", "说话", "凝望1", "凝望2", "转头2", "转身", "行走", "坐"};
    private readonly string[] QingGongbtnNameList = new string[] {"轻功Down", "轻功1", "轻功2", "轻功3", "轻功Land", "轻功Land2" };
    private readonly string[] QingGongTriggerNameList = new string[] { "Down", "1", "2", "3", "Land", "Land2" };
    private readonly string[] QingGongTriggerEventList = new string[] { "qinggong_down", "qinggong_pre1", "qinggong_pre2", "qinggong_pre3",  "QingGongLandExit", "QingGongLandExit" };
    private HashSet<string> _actionList = new HashSet<string>();
    private HashSet<string> _listenedList = new HashSet<string>();  //已经注册过的事件

    // All running effect.
    private LinkedList<EffectControl> effects = new LinkedList<EffectControl>();

    private List<string> _effectBtnName = new List<String>();
    private bool _isInitEvent = false;
    private string _selectEventName = string.Empty;
    private int _couSoundCount = 0;
    private GUIStyle _style;
    private GUIStyle _activeStyle;
    private Texture2D _btnTexture;

    private const int _scrollWidth = 200;
    private const int _scollHeight = 350;

    private bool isGenerateActorController;
    private bool isGenerateActorTriggers;
    private bool isGenerateActorBlinker;

    private AnimatorEventDispatcher _dispatcher;
    #region Data
    private PrefabDataConfig _dataConfig;
    #endregion

    private enum TriggerToolbar
    {
        Effects = 0,
        Halts = 1,
        Sounds = 2,
        CamerasShakes = 3,
        CameraFovs = 4,
        SceneFades = 5,
        FootStep = 6
    }

    private enum ActorToolbar
    {
        Projectiles = 0,
        Hurts = 1,
        Others = 2
    }

    private enum Status
    {
        Sprint = 3,     //冲刺
        Fishing = 4,
        Collect = 5,    //采集
        Hug = 6,        //抱
        HugWalk = 7,     //抱走
        Crouch = 8,     //蹲下
        TurnHead = 9,    //转头
        Show = 10,       //展示
        Cheer = 11,      //欢呼
        OnLookers = 12,  //围观
        LegGo = 13,     //放手
        RaiseHand = 14, //抬手
        Speaking = 15,  //说话
        FixedGaze1 = 16, //凝望1
        FixedGaze2 = 17,    //凝望2
        TurnHead2 = 18,     //转头2
        TuanBody = 19,      //转身
        Walk = 20,          //行走
        Sit = 21,           //坐下
    }

    private void ReadByJson()
    {
        var jsonPath = GetConfigPath("json");
        if (!File.Exists(jsonPath))
        {
            File.Create(jsonPath).Dispose();
            AssetDatabase.Refresh();
        }
        var jsonContents = File.ReadAllText(jsonPath);
        _dataConfig = JsonConvert.DeserializeObject<PrefabDataConfig>(jsonContents);

        isGenerateActorBlinker = true;
        isGenerateActorController = true;
        isGenerateActorTriggers = true;
        if (_dataConfig == null)
        {
            _dataConfig = new PrefabDataConfig();
        }
        if (_dataConfig.actorController == null)
        {
            _dataConfig.actorController = new PrefabDataConfig.ActorControllerData();
            isGenerateActorController = false;
        }
        if (_dataConfig.actorBlinker == null)
        {
            _dataConfig.actorBlinker = new PrefabDataConfig.ActorBlinkerData();
            isGenerateActorBlinker = false;
        }
        if (_dataConfig.actorTriggers == null)
        {
            _dataConfig.actorTriggers = new PrefabDataConfig.ActorTriggersData();
            isGenerateActorTriggers = false;
        }
    }

    [MenuItem("自定义工具/技能配置编辑器")]
    public static void ShowWindow()
    {
        var window = EditorWindow.GetWindow<SkillConfigEditor>(false, "技能配置编辑器");
    }

    private void OnEnable()
    {
        _style = new GUIStyle();
        _style.normal.textColor = Color.black;

        _activeStyle = new GUIStyle();
        _activeStyle.normal.textColor = Color.red;
    }

    private void OnGUI()
    {
        if (_btnTexture == null)
        {
            _btnTexture = GUI.skin.button.normal.background;
            _style.normal.background = _btnTexture;
            _activeStyle.normal.background = _btnTexture;
        }

        GUILayout.Label("选择模型");
        EditorGUI.BeginChangeCheck();
        {
            _animator = (Animator)EditorGUILayout.ObjectField(_animator, typeof(Animator), true, GUILayout.MinWidth(100f));
            if (EditorGUI.EndChangeCheck())
            {
                int id = 0;
                int.TryParse(_animator.transform.name.Split('(')[0], out id);

                _prefabId = id;
                ReadByJson();
            }
            if (_animator == null) return;
        }

        if(!_isInitEvent)
        {
            InitEvent();
            _isInitEvent = true;
        }

        GUILayout.BeginVertical();
        GUILayout.Label("保存配置数据");
        if (GUILayout.Button("保存"))
        {
            if (!isGenerateActorController)
            {
                _dataConfig.actorController = null;
            }
            if (!isGenerateActorBlinker)
            {
                _dataConfig.actorBlinker = null;
            }
            if (!isGenerateActorTriggers)
            {
                _dataConfig.actorTriggers = null;
            }

            string jsonstr = JsonConvert.SerializeObject(_dataConfig);
            File.WriteAllText(GetConfigPath("json"), jsonstr);
            var luaConfig = JsonToLua.Convert(jsonstr).Replace("[none]", string.Empty);
            File.WriteAllText(GetConfigPath("lua"), luaConfig);
            AssetDatabase.Refresh();
            InitEvent();
            ReadByJson();
        }
        DoTriggerWindow();
        GUILayout.EndVertical();
    }

    private string jsonFolder = "../EditorJson/prefab_data/";
    private string saveFolder = "/Game/Lua/config/prefab_data/";
    private string GetConfigPath(string suffix)
    {
        var originPrefab = PrefabUtility.GetPrefabParent(_animator.gameObject);
        var prefabPath = AssetDatabase.GetAssetPath(originPrefab);

        var actorList = GetActorList();
        var actorName = actorList.Find(name => prefabPath.Contains(name + "/"));

        var configPath = "";
        if (suffix.Equals("json"))
        {
            configPath = Path.Combine(Application.dataPath, jsonFolder + "json/" + actorName);
            
        }
        else if (suffix.Equals("lua"))
        {
            configPath = Application.dataPath + saveFolder + "config/" + actorName;
        }
        if (!Directory.Exists(configPath))
        {
            Directory.CreateDirectory(configPath);
            AssetDatabase.Refresh();
        }

        configPath = configPath + "/" + _animator.gameObject.name + "_config." + suffix;
        return configPath;
    }

    private string actorFolder = "Assets/Game/Actors";
    private List<string> GetActorList()
    {
        var actorList = new List<string>();
        var actorsDir = new DirectoryInfo(actorFolder);
        var dirs = actorsDir.GetDirectories();
        foreach (var dir in dirs)
        {
            actorList.Add(dir.Name);
        }
        return actorList;
    }

    private void InitEvent()
    {
        _dispatcher = _animator.GetOrAddComponent<AnimatorEventDispatcher>();
        if (_dispatcher == null) return;

        if(_dataConfig.actorTriggers == null) return;

        // 添加特效侦听类型
        foreach(var effect in _dataConfig.actorTriggers.effects)
        {
            if(!_actionList.Contains(effect.triggerEventName))
                _actionList.Add(effect.triggerEventName);

            if (!_actionList.Contains(effect.triggerStopEvent))
                _actionList.Add(effect.triggerStopEvent);
        }

        // 添加声音侦听类型
        foreach (var sound in _dataConfig.actorTriggers.sounds)
        {
            if (!_actionList.Contains(sound.soundEventName))
                _actionList.Add(sound.soundEventName);
        }

        // 添加震屏侦听类型
        foreach (var shake in _dataConfig.actorTriggers.cameraShakes)
        {
            if (!_actionList.Contains(shake.eventName))
                _actionList.Add(shake.eventName);
        }

        // 添加特效侦听类型
        foreach (var footStep in _dataConfig.actorTriggers.footsteps)
        {
            if (!_actionList.Contains(footStep.footStepEventName))
                _actionList.Add(footStep.footStepEventName);
        }
        
        foreach (var eventName in _actionList)
        {
            if (!_listenedList.Contains(eventName))
            {
                _listenedList.Add(eventName);
                _dispatcher.ListenEvent(eventName, (str, state) =>
                {
                    PlayEvent(eventName);
                });
            }
        }
    }

    #region Trigger
    private void DoTriggerWindow()
    {
        BeginWindows();
        isGenerateActorTriggers = EditorGUILayout.Toggle("生成ActorTriggers表", isGenerateActorTriggers, GUILayout.MaxWidth(200));
        if (isGenerateActorTriggers)
        {
            _selectTriggerToolbal = GUILayout.Toolbar(_selectTriggerToolbal, _toolBarNames, GUILayout.MaxWidth(600));
            switch ((TriggerToolbar)_selectTriggerToolbal)
            {
                case TriggerToolbar.Effects:
                    DoEffectsWindow();
                    GUILayout.Window(0, _upWindowRect, DoEffectItem, "特效信息");
                    break;
                case TriggerToolbar.Halts:
                    DoHaltsWindow();
                    GUILayout.Window(1, _upWindowRect, DoHaltItem, "halts信息");
                    break;
                case TriggerToolbar.Sounds:
                    DoSoundsWindow();
                    GUILayout.Window(2, _upWindowRect, DoSoundItem, "sounds信息");
                    break;
                case TriggerToolbar.CamerasShakes:
                    DoCamerasShakesWindow();
                    GUILayout.Window(12, _upWindowRect, DoShakeItem, "CamerasShakes信息");
                    break;
                case TriggerToolbar.CameraFovs:
                    DoCameraFOVs();
                    GUILayout.Window(9, _upWindowRect, DoCameraFovItem, "CameraFOV信息");
                    break;
                case TriggerToolbar.SceneFades:
                    DoSceneFades();
                    GUILayout.Window(10, _upWindowRect, DoSceneFadeItem, "SceneFade信息");
                    break;
                case TriggerToolbar.FootStep:
                    DoFootStepWindow();
                    GUILayout.Window(11, _upWindowRect, DoFootStepItem, "FootStep信息");
                    break;
            }
        }

        isGenerateActorController = EditorGUILayout.Toggle("生成ActorController表", isGenerateActorController, GUILayout.MaxWidth(200));
        if (isGenerateActorController)
        {
            _selectActorToolbal = GUILayout.Toolbar(_selectActorToolbal, _actorToolbarNames, GUILayout.MaxWidth(600));
            switch ((ActorToolbar)_selectActorToolbal)
            {
                case ActorToolbar.Projectiles:
                    DeProjectilesWindow();
                    GUILayout.Window(3, _middleRect, DoProhectileItem, "projectile信息");
                    break;
                case ActorToolbar.Hurts:
                    DoHurtsWindow();
                    GUILayout.Window(4, _middleRect, DoHurtItem, "hurt信息");
                    break;
                case ActorToolbar.Others:
                    DoOthers();
                    break;
            }
        }

        GUILayout.Window(5, _blinkRect, Blinker, "Blinker");
        GUILayout.Window(6, _timeLineRect, TimeLineEvent, "TimeLine");
        GUILayout.Window(7, _buttonRect, DoButtonWindow, "Button");
        GUILayout.Window(8, _timeLineInfoRect, CreateTimeLineItem, "timeLine信息");
        EndWindows();
    }

    #region Effects
    private void DoEffectsWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加特效", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.TriggerEffect effect = new PrefabDataConfig.TriggerEffect();
            _dataConfig.actorTriggers.effects.Add(effect);
            _effectBtnName.Add(effect.effectBtnName);
        }

        DoEffectList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除特效", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectEffectId == -1 || _dataConfig.actorTriggers.effects.Count == 0) return;

            _dataConfig.actorTriggers.effects.RemoveAt(_selectEffectId);
            _selectEffectId = _dataConfig.actorTriggers.effects.Count == 0 ? -1 : _dataConfig.actorTriggers.effects.Count - 1;
        }
        GUILayout.EndArea();
    }


    private void DoEffectList()
    {
        _effectListScroll = EditorGUILayout.BeginScrollView(_effectListScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.effects.Count; i++)
        {
            if (GUILayout.Button(GetBtnName(_dataConfig.actorTriggers.effects[i].effectBtnName)))
            {
                _selectEffectId = i;
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoEffectItem(int windowId)
    {
        if (_selectEffectId == -1 || _selectEffectId >= _dataConfig.actorTriggers.effects.Count) return;

        var effect = _dataConfig.actorTriggers.effects[_selectEffectId];

        effect.triggerEventName = SelectActionName(effect.triggerEventName);

        if (string.IsNullOrEmpty(effect.effectBtnName))
        {
            effect.effectBtnName = "按钮";
        }
        effect.effectBtnName = EditorGUILayout.TextField("按钮名称", effect.effectBtnName);
        effect.triggerDelay = EditorGUILayout.FloatField("Delay", effect.triggerDelay);
        effect.triggerFreeDelay = EditorGUILayout.FloatField("延迟删除特效", effect.triggerFreeDelay);
        EditorGUI.BeginChangeCheck();
        EffectControl effectGo = GetEffectCtrl(effect.effectGoName, effect.effectAsset.GetAssetPath());
        if (EditorGUI.EndChangeCheck())
        {
            effect.effectAsset = GetAssetID(effectGo);
            effect.effectGoName = effectGo == null ? "" : effectGo.name;
        }
        effect.playerAtTarget = EditorGUILayout.Toggle("play at Target", effect.playerAtTarget);

        Transform node = string.IsNullOrEmpty(effect.referenceNodeHierarchyPath)?null:_animator.transform.Find(effect.referenceNodeHierarchyPath);
        node = EditorGUILayout.ObjectField("referenceNode", node, typeof(Transform), true) as Transform;
        effect.referenceNodeHierarchyPath = node ? GetHierarchyPath(node) : string.Empty;

        effect.isRotation = EditorGUILayout.Toggle("Is Rotation", effect.isRotation);
        effect.isAttach = EditorGUILayout.Toggle("Is Attach", effect.isAttach);
        effect.triggerStopEvent = SelectActionName(effect.triggerStopEvent, "Stop Event");

        var data = effect;
        _dataConfig.actorTriggers.effects[_selectEffectId] = data;
        GUILayout.Label("--------------------------------------------------");
    }
    #endregion

    #region Halts
    private void DoHaltsWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加halts", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.TriggerHalt halt = new PrefabDataConfig.TriggerHalt();
            _dataConfig.actorTriggers.halts.Add(halt);
        }
        DoHaltsList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除halts", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectHaltId == -1 || _dataConfig.actorTriggers.halts.Count == 0) return;

            _dataConfig.actorTriggers.halts.RemoveAt(_selectHaltId);
            _selectHaltId = _dataConfig.actorTriggers.halts.Count == 0 ? -1 : _dataConfig.actorTriggers.halts.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoHaltsList()
    {
        _haltsScroll = EditorGUILayout.BeginScrollView(_haltsScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.halts.Count; i++)
        {
            if (GUILayout.Button(GetBtnName(_dataConfig.actorTriggers.halts[i].haltBtnName)))
                _selectHaltId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoHaltItem(int windowId)
    {
        if (_selectHaltId == -1 || _selectHaltId >= _dataConfig.actorTriggers.halts.Count) return;

        var halt = _dataConfig.actorTriggers.halts[_selectHaltId];
        halt.haltBtnName = EditorGUILayout.TextField("按钮名称", halt.haltBtnName);
        halt.haltEventName = SelectActionName(halt.haltEventName, "事件名称");
        halt.haltDelay = EditorGUILayout.FloatField("延迟时间", halt.haltDelay);
        halt.haltContinueTime = EditorGUILayout.FloatField("持续时间", halt.haltContinueTime);
        _dataConfig.actorTriggers.halts[_selectHaltId] = halt;
    }
    #endregion

    #region Sounds
    private void DoSoundsWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加sound", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.TriggerSound sound = new PrefabDataConfig.TriggerSound();
            _dataConfig.actorTriggers.sounds.Add(sound);
        }
        DoSoundsList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除sound", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectSoundId == -1 || _dataConfig.actorTriggers.sounds.Count == 0) return;

            _dataConfig.actorTriggers.sounds.RemoveAt(_selectSoundId);
            _selectSoundId = _dataConfig.actorTriggers.sounds.Count == 0 ? -1 : _dataConfig.actorTriggers.sounds.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoSoundsList()
    {
        _soundScroll = EditorGUILayout.BeginScrollView(_soundScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.sounds.Count; i++)
        {
            if (GUILayout.Button("sound" + i))
                _selectSoundId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoSoundItem(int windowId)
    {
        if (_selectSoundId == -1 || _selectSoundId >= _dataConfig.actorTriggers.sounds.Count) return;

        var sound = _dataConfig.actorTriggers.sounds[_selectSoundId];
        sound.soundEventName = SelectActionName(sound.soundEventName);
        sound.soundDelay = EditorGUILayout.FloatField("Delay", sound.soundDelay);
        EditorGUI.BeginChangeCheck();
        AudioItem go = GetAudioItem(sound.soundAudioGoName, sound.soundAudioAsset.GetAssetPath());
        if (EditorGUI.EndChangeCheck())
        {
            sound.soundAudioAsset = GetAssetID(go);
            sound.soundAudioGoName = go.name;
        }

        _dataConfig.actorTriggers.sounds[_selectSoundId] = sound;
    }
    #endregion

    #region CmaeraShakes
    private void DoCamerasShakesWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加Shake", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.CameraShakeData cameraShakeData = new PrefabDataConfig.CameraShakeData();
            _dataConfig.actorTriggers.cameraShakes.Add(cameraShakeData);
        }
        _shakeScroll = EditorGUILayout.BeginScrollView(_shakeScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.cameraShakes.Count; i++)
        {
            if (GUILayout.Button(GetBtnName(_dataConfig.actorTriggers.cameraShakes[i].CameraShakeBtnName)))
                _selectShakeId = i;
        }
        EditorGUILayout.EndScrollView();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除Shake", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectShakeId == -1 || _dataConfig.actorTriggers.cameraShakes.Count == 0) return;

            _dataConfig.actorTriggers.cameraShakes.RemoveAt(_selectShakeId);
            _selectShakeId = _dataConfig.actorTriggers.cameraShakes.Count == 0 ? -1 : _dataConfig.actorTriggers.cameraShakes.Count - 1;
        }
        GUILayout.EndArea();

    }

    private void DoShakeItem(int windowId)
    {
        if (_selectShakeId == -1 || _selectShakeId >= _dataConfig.actorTriggers.cameraShakes.Count) return;

        var cameraShake = _dataConfig.actorTriggers.cameraShakes[_selectShakeId];


        if (string.IsNullOrEmpty(cameraShake.CameraShakeBtnName))
        {
            cameraShake.CameraShakeBtnName = "按钮";
        }
        cameraShake.CameraShakeBtnName = EditorGUILayout.TextField("按钮名称", cameraShake.CameraShakeBtnName);
        cameraShake.eventName = SelectActionName(cameraShake.eventName);
        cameraShake.numberOfShakes = EditorGUILayout.IntField("震屏次数", cameraShake.numberOfShakes);
        cameraShake.distance = EditorGUILayout.FloatField("震屏距离", cameraShake.distance);
        cameraShake.speed = EditorGUILayout.FloatField("震屏时间(毫秒)", cameraShake.speed);
        cameraShake.delay = EditorGUILayout.FloatField("延迟时间", cameraShake.delay);
        cameraShake.decay = EditorGUILayout.FloatField("衰减值(0-1的值)", cameraShake.decay);
    }
    #endregion

    #region Fovs
    private void DoCameraFOVs()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加FOV", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.CameraFOV cameraFov = new PrefabDataConfig.CameraFOV();
            _dataConfig.actorTriggers.cameraFOVs.Add(cameraFov);
        }
        DoCameraFovList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除FOV", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectFovId == -1 || _dataConfig.actorTriggers.cameraFOVs.Count == 0) return;

            _dataConfig.actorTriggers.cameraFOVs.RemoveAt(_selectFovId);
            _selectFovId = _dataConfig.actorTriggers.cameraFOVs.Count == 0 ? -1 : _dataConfig.actorTriggers.cameraFOVs.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoCameraFovList()
    {
        _fovScroll = EditorGUILayout.BeginScrollView(_fovScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.cameraFOVs.Count; i++)
        {
            if (GUILayout.Button("fov" + i))
                _selectFovId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoCameraFovItem(int windowId)
    {
        if (_selectFovId == -1 || _selectFovId >= _dataConfig.actorTriggers.cameraFOVs.Count) return;

        var fov = _dataConfig.actorTriggers.cameraFOVs[_selectFovId];

        fov.fovEventName = SelectActionName(fov.fovEventName);
        fov.fovDelay = EditorGUILayout.FloatField("Delay", fov.fovDelay);
        fov.fovFiledOfView = EditorGUILayout.FloatField("Filed Of View", fov.fovFiledOfView);
        fov.duration = EditorGUILayout.FloatField("Duration", fov.duration);

        _dataConfig.actorTriggers.cameraFOVs[_selectFovId] = fov;
    }
    #endregion

    #region SceneFade
    private void DoSceneFades()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加Fade", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.SceneFade sceneFade = new PrefabDataConfig.SceneFade();
            _dataConfig.actorTriggers.sceneFades.Add(sceneFade);
        }
        DoFadeList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除Fade", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectFadeId == -1 || _dataConfig.actorTriggers.sceneFades.Count == 0) return;

            _dataConfig.actorTriggers.sceneFades.RemoveAt(_selectFadeId);
            _selectFadeId = _dataConfig.actorTriggers.sceneFades.Count == 0 ? -1 : _dataConfig.actorTriggers.sceneFades.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoFadeList()
    {
        _fadeScroll = EditorGUILayout.BeginScrollView(_fadeScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.sceneFades.Count; i++)
        {
            if (GUILayout.Button("fov" + i))
                _selectFadeId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoSceneFadeItem(int windowId)
    {
        if (_selectFadeId == -1 || _selectFadeId >= _dataConfig.actorTriggers.sceneFades.Count) return;

        var fade = _dataConfig.actorTriggers.sceneFades[_selectFadeId];
        fade.fadeEventName = SelectActionName(fade.fadeEventName);
        fade.fadeDelay = EditorGUILayout.FloatField("Delay", fade.fadeDelay);
        fade.fadeIn = EditorGUILayout.FloatField("Fade In", fade.fadeIn);
        fade.fadeOut = EditorGUILayout.FloatField("Fade Out", fade.fadeOut);
        fade.fadeHold = EditorGUILayout.FloatField("Hold", fade.fadeHold);

        if (fade.fadeColor == null)
        {
            fade.fadeColor = new PrefabDataConfig.FadeColor();
        }
        Color color = new Color(fade.fadeColor.colorR, fade.fadeColor.colorG, fade.fadeColor.colorB, fade.fadeColor.colorA);
        EditorGUI.BeginChangeCheck();
        color = EditorGUILayout.ColorField("Color", color);
        if(EditorGUI.EndChangeCheck())
        {
            fade.fadeColor.colorA = color.a;
            fade.fadeColor.colorB = color.b;
            fade.fadeColor.colorG = color.g;
            fade.fadeColor.colorR = color.r;
        }
        _dataConfig.actorTriggers.sceneFades[_selectFadeId] = fade;
    }
    #endregion

    #region FootStep
    private void DoFootStepWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加footStep", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.FootStep footStep= new PrefabDataConfig.FootStep();
            _dataConfig.actorTriggers.footsteps.Add(footStep);
        }
        DoFootStepList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_1);
        if (GUILayout.Button("删除footStep", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectFootStepId == -1 || _dataConfig.actorTriggers.footsteps.Count == 0) return;

            _dataConfig.actorTriggers.footsteps.RemoveAt(_selectFootStepId);
            _selectFootStepId = _dataConfig.actorTriggers.footsteps.Count == 0 ? -1 : _dataConfig.actorTriggers.footsteps.Count - 1;
        }
        GUILayout.EndArea();
    }
    
    private void DoFootStepList()
    {
        _footStepScroll = EditorGUILayout.BeginScrollView(_footStepScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorTriggers.footsteps.Count; i++)
        {
            if (GUILayout.Button("footStep" + i))
                _selectFootStepId = i;
        }
        EditorGUILayout.EndScrollView();
    }
    
    private void DoFootStepItem(int windowId)
    {
        if (_selectFootStepId == -1 || _selectFootStepId >= _dataConfig.actorTriggers.footsteps.Count) return;

        var foot = _dataConfig.actorTriggers.footsteps[_selectFootStepId];
        foot.footStepEventName = SelectActionName(foot.footStepEventName);
        foot.footStepDelay = EditorGUILayout.FloatField("Delay", foot.footStepDelay);

        Transform footNode =string.IsNullOrEmpty(foot.footNodeHierarchyPath)?null:_animator.transform.Find(foot.footNodeHierarchyPath);
        footNode = EditorGUILayout.ObjectField("Foot Node", footNode, typeof(Transform), true) as Transform;
        foot.footNodeHierarchyPath = footNode ? GetHierarchyPath(footNode) : string.Empty;

        EditorGUI.BeginChangeCheck();
        foot.footprint = EditorGUILayout.ObjectField("Footprint", foot.footprint, typeof(Footprint), true) as Footprint;
        EffectControl go = GetEffectCtrl(foot.footAssetGoName, foot.footAsset.GetAssetPath(), "Footsetp Dust");
        AudioItem audioGo = GetAudioItem(foot.footAudioName, foot.footAsset.GetAssetPath());

        if (EditorGUI.EndChangeCheck())
        {
            foot.footAsset = GetAssetID(go);
            foot.footAudioAsset = GetAssetID(audioGo);
        }

        _dataConfig.actorTriggers.footsteps[_selectFootStepId] = foot;
    }
    #endregion
    #endregion

    #region Actor Controller
    #region Projectile
    private void DeProjectilesWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加projectile", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.ProjectileData data = new PrefabDataConfig.ProjectileData();
            _dataConfig.actorController.projectiles.Add(data);
        }
        DoProjectilesList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_2);
        if (GUILayout.Button("删除projectile", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectProjectileId == -1 || _dataConfig.actorController.projectiles.Count == 0) return;

            _dataConfig.actorController.projectiles.RemoveAt(_selectProjectileId);
            _selectProjectileId = _dataConfig.actorController.projectiles.Count == 0 ? -1 : _dataConfig.actorController.projectiles.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoProjectilesList()
    {
        _projectileScroll = EditorGUILayout.BeginScrollView(_projectileScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorController.projectiles.Count; i++)
        {
            if (GUILayout.Button(_dataConfig.actorController.projectiles[i].ProjectileBtnName))
                _selectProjectileId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void DoProhectileItem(int windowId)
    {
        if(_dataConfig.actorController == null) return;
        if (_selectProjectileId == -1 || _selectProjectileId >= _dataConfig.actorController.projectiles.Count) return;

        var data = _dataConfig.actorController.projectiles[_selectProjectileId];
        int eventIdx = 0;
        if (!string.IsNullOrEmpty(data.Action))
        {
            for (int i = 0; i < ActorEventDrawer.projectileEventNames.Length; i++)
            {
                if (data.Action == ActorEventDrawer.projectileEventNames[i])
                    eventIdx = i;
            }
        }
        eventIdx = EditorGUILayout.Popup("Event Name", eventIdx, ActorEventDrawer.projectileEventNames);
        if (string.IsNullOrEmpty(data.ProjectileBtnName))
        {
            data.ProjectileBtnName = "按钮";
        }
        data.ProjectileBtnName = EditorGUILayout.TextField("按钮名称", data.ProjectileBtnName);
        data.Action = ActorEventDrawer.projectileEventNames[eventIdx];
        data.HurtPosition = (PrefabDataConfig.HurtPositionEnum)EditorGUILayout.Popup("Hurt Position", (int)data.HurtPosition, HurtPosition);
        data.DelayProjectileEff = EditorGUILayout.FloatField("延迟播放特效", data.DelayProjectileEff);
        data.DeleProjectileDelay = EditorGUILayout.FloatField("延迟删除特效", data.DeleProjectileDelay);
        
        Transform node =string.IsNullOrEmpty(data.ProjectilNodeHierarchyPath)?null:_animator.transform.Find(data.ProjectilNodeHierarchyPath);
        node = EditorGUILayout.ObjectField("特效释放点", node, typeof(Transform), true) as Transform;
        data.ProjectilNodeHierarchyPath = node? GetHierarchyPath(node): string.Empty;

        Projectile go = null;
        string guid = "";
        EditorGUI.BeginChangeCheck();
        if (string.IsNullOrEmpty(data.ProjectilGoName))
        {
            go = EditorGUILayout.ObjectField("特效", go, typeof(Projectile), true) as Projectile;
        }
        else
        {
            guid = AssetDatabase.AssetPathToGUID(data.Projectile.GetAssetPath());
            var prefabPath = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            go = EditorGUILayout.ObjectField("特效", prefab, typeof(Projectile), true) as Projectile;
        }
        
        if(EditorGUI.EndChangeCheck())
        {
            if (go == null)
            {
                data.ProjectilGoName = string.Empty;
                data.Projectile = AssetID.Empty;
            }
            else
            {
                var path = AssetDatabase.GetAssetPath(go);
                guid = AssetDatabase.AssetPathToGUID(path);
                var importer = AssetImporter.GetAtPath(path);
                AssetID assetId = new AssetID(importer.assetBundleName, go.name);
                data.Projectile = assetId;
                data.Projectile.AssetGUID = guid;
                data.ProjectilGoName = go.name;
            }
        }
        
        Transform tran =string.IsNullOrEmpty(data.FromPosHierarchyPath)?null:_animator.transform.Find(data.FromPosHierarchyPath);
        tran = EditorGUILayout.ObjectField("From Position", tran, typeof(Transform), true) as Transform;
        data.FromPosHierarchyPath = tran ? GetHierarchyPath(tran) : string.Empty;

        _dataConfig.actorController.projectiles[_selectProjectileId] = data;
    }
    #endregion

    #region Hurts
    private void DoHurtsWindow()
    {
        GUILayout.BeginVertical();
        if (GUILayout.Button("增加hurt", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            PrefabDataConfig.HurtData data = new PrefabDataConfig.HurtData();
            _dataConfig.actorController.hurts.Add(data);
        }
        DoHurtList();
        GUILayout.EndVertical();

        GUILayout.BeginArea(_deleteBtnRect_2);
        if (GUILayout.Button("删除hurt", GUILayout.Width(100f), GUILayout.Height(30f)))
        {
            if (_selectHurtId == -1 || _dataConfig.actorController.hurts.Count == 0) return;

            _dataConfig.actorController.hurts.RemoveAt(_selectHurtId);
            _selectHurtId = _dataConfig.actorController.hurts.Count == 0 ? -1 : _dataConfig.actorController.hurts.Count - 1;
        }
        GUILayout.EndArea();
    }

    private void DoHurtList()
    {
        _hurtScroll = EditorGUILayout.BeginScrollView(_hurtScroll, GUILayout.Width(_scrollWidth), GUILayout.Height(_scollHeight));
        for (int i = 0; i < _dataConfig.actorController.hurts.Count; i++)
        {
            if (GUILayout.Button(_dataConfig.actorController.hurts[i].HurtBtnName))
                _selectHurtId = i;
        }
        EditorGUILayout.EndScrollView();
    }


    EffectControl hurtGo = null;
    EffectControl hitGo = null;
    string hitGUID = "";
    string hurtGUID = "";
    private void DoHurtItem(int windowId)
    {
        if (_selectHurtId == -1 || _selectHurtId >= _dataConfig.actorController.hurts.Count) return;

        var data = _dataConfig.actorController.hurts[_selectHurtId];

        int eventIdx = 0;
        if (!string.IsNullOrEmpty(data.Action))
        {
            for (int i = 0; i < ActorEventDrawer.projectileEventNames.Length; i++)
            {
                if (data.Action == ActorEventDrawer.projectileEventNames[i])
                    eventIdx = i;
            }
        }
        data.HurtBtnName = EditorGUILayout.TextField("按钮名称", data.HurtBtnName);
        if (string.IsNullOrEmpty(data.HurtBtnName))
        {
            data.HurtBtnName = "按钮";
        }

        eventIdx = EditorGUILayout.Popup("Action", eventIdx, ActorEventDrawer.projectileEventNames);
        data.Action = ActorEventDrawer.projectileEventNames[eventIdx];
        
        EditorGUI.BeginChangeCheck();
        if (string.IsNullOrEmpty(data.HurtEffectGoName))
        {
            hurtGo = EditorGUILayout.ObjectField("Hurt Effect", hurtGo, typeof(EffectControl), false) as EffectControl;
        }
        else
        {
            hurtGUID = AssetDatabase.AssetPathToGUID(data.HurtEffect.GetAssetPath());
            var prefabPath = AssetDatabase.GUIDToAssetPath(hurtGUID);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            hurtGo = EditorGUILayout.ObjectField("Hurt Effect", prefab, typeof(EffectControl), false) as EffectControl;
        }
        data.HurtPosition = (PrefabDataConfig.HurtPositionEnum)EditorGUILayout.Popup("Hurt Position", (int)data.HurtPosition, HurtPosition);
        data.HurtRotation = (PrefabDataConfig.HurtRotationEnum)EditorGUILayout.Popup("Hurt Rotation", (int)data.HurtRotation, HitRotation);
        data.HitCount = EditorGUILayout.IntField("Hit Count", data.HitCount);
        data.HitInterval = EditorGUILayout.DelayedFloatField("Hit Interval", data.HitInterval);
        
        if (string.IsNullOrEmpty(data.HitEffectGoName))
        {
            hitGo = EditorGUILayout.ObjectField("Hit Effect", hitGo, typeof(EffectControl), false) as EffectControl;
        }
        else
        {
            hitGUID = AssetDatabase.AssetPathToGUID(data.HitEffect.GetAssetPath());
            var prefabPath = AssetDatabase.GUIDToAssetPath(hitGUID);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            hitGo = EditorGUILayout.ObjectField("Hit Effect", prefab, typeof(EffectControl), false) as EffectControl;
        }
        data.HitPosition = (PrefabDataConfig.HurtPositionEnum)EditorGUILayout.Popup("Hit Position", (int)data.HitPosition, HurtPosition);
        data.HitRotation = (PrefabDataConfig.HurtRotationEnum)EditorGUILayout.Popup("Hit Rotation", (int)data.HitRotation, HitRotation);
        
        EditorGUILayout.Space();

        data.DelayHurtEffect = EditorGUILayout.FloatField("延迟播放HurtEffect", data.DelayHurtEffect);
        data.HurtFreeDelay = EditorGUILayout.FloatField("延迟删除HurtEffect", data.HurtFreeDelay);

        data.DelayHitEffect = EditorGUILayout.FloatField("延迟播放HitEffect", data.DelayHitEffect);
        data.HitFreeDelay = EditorGUILayout.FloatField("延迟删除HitEffect", data.HitFreeDelay);
        
        if (EditorGUI.EndChangeCheck())
        {
            if (hurtGo == null || hitGo == null)
            {
                return;
            }

            var path = AssetDatabase.GetAssetPath(hurtGo);
            hurtGUID = AssetDatabase.AssetPathToGUID(path);
            var importer = AssetImporter.GetAtPath(path);
            AssetID assetId = new AssetID(importer.assetBundleName, hurtGo.name);
            data.HurtEffect = assetId;
            data.HurtEffect.AssetGUID = hurtGUID;
            data.HurtEffectGoName = hurtGo.name;

            var path1 = AssetDatabase.GetAssetPath(hitGo);
            hitGUID = AssetDatabase.AssetPathToGUID(path1);
            var importer1 = AssetImporter.GetAtPath(path1);
            AssetID assetId1 = new AssetID(importer1.assetBundleName, hitGo.name);
            data.HitEffect = assetId1;
            data.HitEffect.AssetGUID = hitGUID;
            data.HitEffectGoName = hitGo.name;
        }

        _dataConfig.actorController.hurts[_selectHurtId] = data;
    }
    #endregion

    #region Others
    private void DoOthers()
    {
        _dataConfig.actorController.beHurtAttach = EditorGUILayout.Toggle("Be Hurt Attach", _dataConfig.actorController.beHurtAttach);
        _dataConfig.actorController.hurtEffectFreeDelay = EditorGUILayout.FloatField("延迟删除特效时间", _dataConfig.actorController.hurtEffectFreeDelay, GUILayout.Width(100));
        Transform tran = null;
        if (!string.IsNullOrEmpty(_dataConfig.actorController.beHurtNodeName))
            tran = _animator.transform.Find(_dataConfig.actorController.beHurtNodeName);

        EditorGUI.BeginChangeCheck();
        EffectControl go = null;
        string guid = "";
        if (string.IsNullOrEmpty(_dataConfig.actorController.hurtEffectName))
        {
            go = EditorGUILayout.ObjectField("Reference", go, typeof(EffectControl), false, GUILayout.Width(200), GUILayout.Height(20)) as EffectControl;
        }
        else
        {
            guid = AssetDatabase.AssetPathToGUID(_dataConfig.actorController.beHurtEffecct.GetAssetPath());
            var prefabPath = AssetDatabase.GUIDToAssetPath(guid);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            go = EditorGUILayout.ObjectField("Reference", prefab, typeof(EffectControl), false) as EffectControl;
        }

        tran = EditorGUILayout.ObjectField("Be Hurt Position", tran, typeof(Transform), false, 
            GUILayout.Width(200), GUILayout.Height(20)) as Transform;
        _dataConfig.actorController.beHurtNodeName = tran == null ? "" : tran.name;
        if (EditorGUI.EndChangeCheck())
        {
            if(string.IsNullOrEmpty(_dataConfig.actorController.hurtEffectName))
            {
                var path = AssetDatabase.GetAssetPath(go);
                guid = AssetDatabase.AssetPathToGUID(path);
                var importer = AssetImporter.GetAtPath(path);
                AssetID assetId = new AssetID(importer.assetBundleName, go.name);
                assetId.AssetGUID = guid;
                _dataConfig.actorController.hurtEffectName = go.name;
            }
        }

    }
    #endregion
    #endregion

    #region ActorBlinker
    private void Blinker(int windowId)
    {
        isGenerateActorBlinker = EditorGUILayout.Toggle("生成ActorBlinker表", isGenerateActorBlinker, GUILayout.MaxWidth(200));
        if (isGenerateActorBlinker)
        {
            _dataConfig.actorBlinker.blinkFadeIn = EditorGUILayout.FloatField("Fade In", _dataConfig.actorBlinker.blinkFadeIn);
            _dataConfig.actorBlinker.blinkFadeOut = EditorGUILayout.FloatField("Fade Out", _dataConfig.actorBlinker.blinkFadeOut);
            _dataConfig.actorBlinker.blinkFadeHold = EditorGUILayout.FloatField("Fade Hold", _dataConfig.actorBlinker.blinkFadeHold);

            if (GUILayout.Button("Blinker", GUILayout.Width(50), GUILayout.Height(30)))
            {
                var blinker = _animator.transform.GetOrAddComponent<ActorBlinker>();
                blinker.Blink(_dataConfig.actorBlinker.blinkFadeIn, _dataConfig.actorBlinker.blinkFadeHold, _dataConfig.actorBlinker.blinkFadeOut);
            }
        }
    }
    #endregion

    #region TimeLine
    private void TimeLineEvent(int windowId)
    {
        if (GUILayout.Button("增加Time Line", GUILayout.Width(100), GUILayout.Height(30)))
        {
            PrefabDataConfig.TimeLineData timeLine = new PrefabDataConfig.TimeLineData();
            _dataConfig.TimeLineList.Add(timeLine);
        }

        if (GUILayout.Button("删除Time Line", GUILayout.Width(100), GUILayout.Height(30)))
        {
            if (_timeLineId == -1 || _timeLineId >= _dataConfig.TimeLineList.Count) return;

            _dataConfig.TimeLineList.RemoveAt(_timeLineId);
            _timeLineId = _dataConfig.TimeLineList.Count - 1;
        }
        _timeLineScroll = EditorGUILayout.BeginScrollView(_timeLineScroll, GUILayout.Width(200), GUILayout.Height(200));
        for (int i = 0; i < _dataConfig.TimeLineList.Count; i++)
        {
            if (GUILayout.Button(_dataConfig.TimeLineList[i].TimeLineBtnName))
                _timeLineId = i;
        }
        EditorGUILayout.EndScrollView();
    }

    private void CreateTimeLineItem(int windowId)
    {
        if (_timeLineId == -1 || _timeLineId >= _dataConfig.TimeLineList.Count) return;

        PrefabDataConfig.TimeLineData timeLine = _dataConfig.TimeLineList[_timeLineId];
        int eventIdx = 0;
        if (!string.IsNullOrEmpty(timeLine.TimeLineEvent))
        {
            for (int i = 0; i < ActorEventDrawer.eventNames.Length; i++)
            {
                if (timeLine.TimeLineEvent == ActorEventDrawer.eventNames[i])
                    eventIdx = i;
            }
        }
        if (string.IsNullOrEmpty(timeLine.TimeLineBtnName))
        {
            timeLine.TimeLineBtnName = "按钮";
        }
        timeLine.TimeLineBtnName = EditorGUILayout.TextField("按钮名称", timeLine.TimeLineBtnName);

        eventIdx = EditorGUILayout.Popup("Event Name", eventIdx, ActorEventDrawer.eventNames);
        timeLine.TimeLineEvent = ActorEventDrawer.eventNames[eventIdx];
        timeLine.NormalizedTime = EditorGUILayout.FloatField("Normalized Time", timeLine.NormalizedTime);
        _dataConfig.TimeLineList[_timeLineId] = timeLine;
        EditorGUILayout.LabelField("------------------");
        GUILayout.Space(10);
    }
    #endregion

    #region ButtonEvent
    private void DoButtonWindow(int windowId)
    {
        var animatorCtrl = _animator.runtimeAnimatorController;
        var overrideController = animatorCtrl as AnimatorOverrideController;
        EditorGUILayout.BeginVertical();

            EditorGUILayout.BeginHorizontal();
            for (int i = 1; i <= 5; i++)
            {
                OnAttackBtnClick(i, overrideController);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            for (int i = 6; i <= 10; i++)
            {
                OnAttackBtnClick(i, overrideController);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            for (int i = 11; i <= 15; i++)
            {
                OnAttackBtnClick(i, overrideController);
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoStateToolBar();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoOtherButton(3, 13);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoOtherButton(13, OtherbtnNameList.Length);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoComboBtn(overrideController);
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.BeginHorizontal();
            DoEvenPpointComboBtn(overrideController);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoMagicBtn(overrideController);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoSkillButton(overrideController);
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoJumpButton();
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            DoQingGongButton();
            EditorGUILayout.EndHorizontal();

        EditorGUILayout.EndVertical();
    }

    private void OnAttackBtnClick(int idx, AnimatorOverrideController overrideController)
    {
        var defaultAttack = string.Format("d_attack{0}", idx);
        if (overrideController[defaultAttack])
        {
            var hasAttack = overrideController[defaultAttack].name != defaultAttack;
            if (!hasAttack)
                return;
        }

        var triggerName = string.Format("attack{0}", idx);
        if (GUILayout.Button(string.Format("attack{0}", idx), GUILayout.Width(100), GUILayout.Height(30)))
        {
            _animator.SetBool("fight", true);
            var eventName = string.Format("attack{0}/hit", idx);
            _selectEventName = eventName;
            PlayProjectileAction(triggerName);
            _animator.SetBool("fight", false);
        }
    }

    private void DoStateToolBar()
    {
        EditorGUI.BeginChangeCheck();
        EditorGUI.BeginChangeCheck();
        var status = _animator.GetInteger("status");
        status = GUILayout.Toolbar(status, StatusEnum);
        if (EditorGUI.EndChangeCheck())
            _animator.SetInteger("status", status);

        int locomotion = 0;

        if (_animator.GetLayerWeight(1) > 0.5f)
            locomotion = 1;

        if (_animator.GetLayerWeight(2) > 0.5f)
            locomotion = 2;

        if (_animator.layerCount >= 5)
        {
            EditorGUI.BeginChangeCheck();
            int layer = GUILayout.Toolbar(locomotion, LocomotionEnum);
            if (EditorGUI.EndChangeCheck())
            {
                switch (layer)
                {
                    case 0:
                        _animator.SetLayerWeight(0, 1.0f);
                        _animator.SetLayerWeight(1, 0.0f);
                        _animator.SetLayerWeight(2, 0.0f);
                        break;
                    case 1:
                        _animator.SetLayerWeight(1, 1.0f);
                        _animator.SetLayerWeight(2, 0.0f);
                        break;
                    case 2:
                        _animator.SetLayerWeight(1, 0.0f);
                        _animator.SetLayerWeight(2, 1.0f);
                        break;
                }
            }
        }
    }

    private void DoOtherButton(int min, int max)
    {
        EditorGUILayout.BeginHorizontal();
        for (int i = min; i < max; i++)
        {
            if (string.IsNullOrEmpty(OtherbtnNameList[i])) continue; 

            if (GUILayout.Button(OtherbtnNameList[i]))
            {
                _animator.SetInteger("status", i);
            }
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DoJumpButton()
    {
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Jump"))
        {
            _animator.SetTrigger("jump");
        }

        if (GUILayout.Button("Jump2"))
        {
            _animator.SetTrigger("jump2");
        }

        if (GUILayout.Button("Jump3"))
        {
            _animator.SetTrigger("jump3");
        }
        EditorGUILayout.EndHorizontal();
    }

    private void DoSkillButton(AnimatorOverrideController overrideController)
    {
        for(int i = 1; i < 7; i ++)
        {
            if(GUILayout.Button(string.Format("Skill_{0}", i)))
            {
                var name = string.Format("d_attack1{0}", i);
                _animator.SetBool("fight", true);
                if (overrideController[name] != null && overrideController[name].name != name)
                {
                    _animator.SetTrigger(string.Format("skill{0}",i));
                }
                _animator.SetBool("fight", false);
            }
        }
    }

    private void OoComboHandler(AnimatorOverrideController overrideController, int i, int j)
    {
        var name = string.Format("d_combo{0}_{1}", i, j);
        _animator.SetBool("fight", true);
        if (overrideController[name] != null && overrideController[name].name != name)
        {
            var eventName = string.Format("combo{0}_{1}/hit", i, j);
            var actionName = string.Format("combo{0}_{1}", i, j);
            _selectEventName = eventName;
            PlayProjectileAction(actionName);
        }
        _animator.SetBool("fight", false);
    }

    private void DoComboBtn(AnimatorOverrideController overrideController)
    {
        for(int i = 1; i < 4; i++)
        {
            for(int j = 1; j < 4; j++)
            {
                if (GUILayout.Button(string.Format("combo{0}_{1}", i, j, GUILayout.Width(70), GUILayout.Height(20))))
                {
                    OoComboHandler(overrideController, i, j);
                }
            }
        }
    }

    private void DoEvenPpointComboBtn(AnimatorOverrideController overrideController)
    {
        if (GUILayout.Button("combo1_1-3点击"))
        {
            for (int j = 0; j < 4; j++)
            {
                OoComboHandler(overrideController, 1, j);
            }
        }
        if (GUILayout.Button("combo2_1-3点击"))
        {
            for (int j = 0; j < 4; j++)
            {
                OoComboHandler(overrideController, 2, j);
            }
        }
        if (GUILayout.Button("combo3_1-3点击"))
        {
            for (int j = 0; j < 4; j++)
            {
                OoComboHandler(overrideController, 3, j);
            }
        }
    }

    private void DoMagicBtn(AnimatorOverrideController overrideController)
    {
        for(int i = 1; i < 3; i++)
        {
            if (GUILayout.Button(string.Format("Magic{0}", i, GUILayout.Width(70), GUILayout.Height(20))))
            {
                var name = string.Format("d_magic{0}_1", i);
                _animator.SetBool("fight", true);
                if(overrideController[name] != null && overrideController[name].name != name)
                {
                    var eventName = string.Format("magic{0}_1/hit", i);
                    var actionName = string.Format("magic{0}_1", i);
                    _selectEventName = eventName;
                    PlayProjectileAction(actionName);
                }
            }
            if(GUILayout.Button(string.Format("Magic{0} Release", i, GUILayout.Width(70), GUILayout.Height(20))))
            {
                var name = string.Format("d_magic{0}_3", i);
                _animator.SetBool("fight", true);

                if (overrideController[name] != null && overrideController[name].name != name)
                {
                    var eventName = string.Format("magic{0}_3/hit", i);
                    var actionName = string.Format("magic{0}_3", i);
                    _selectEventName = eventName;
                    PlayProjectileAction(actionName);
                }
            }
        }
    }

    // 轻功按钮
    private void DoQingGongButton()
    {
        EditorGUILayout.BeginHorizontal();
        for (int i = 0; i < 6; i++)
        {
            if (GUILayout.Button(QingGongbtnNameList[i]))
            {
               _animator.SetTrigger("QingGong" + QingGongTriggerNameList[i]);

               var triggerName = QingGongTriggerEventList[i];
               PlayProjectileEffect(triggerName);
            }

        }
         EditorGUILayout.EndHorizontal();
    }

    #region PlayEventList
    private void PlayEvent(string eventName)
    {

        foreach (var effect in _dataConfig.actorTriggers.effects)
        {
            if (effect.triggerEventName == eventName)
            {
                if (effect.triggerDelay > 0f)
                    Scheduler.RunCoroutine(DelayPlayEffect(effect.triggerDelay, effect));
                else
                    Scheduler.RunCoroutine(PlayEffects(effect));
            }

            if (effect.triggerStopEvent == eventName)
            {
                this.StopEffects();
            }
        }

        foreach(var sound in _dataConfig.actorTriggers.sounds)
        {
            if (sound.soundEventName == eventName)
            {
                if (sound.soundDelay > 0f)
                    Scheduler.RunCoroutine(PlaySoundDelay(sound.soundDelay, sound));
                else
                    PlaySound(sound);
            }
        }

        foreach (var shake in _dataConfig.actorTriggers.cameraShakes)
        {
            if (shake.eventName == eventName)
            {
                if (shake.delay > 0f)
                    Scheduler.RunCoroutine(PlayCameraShakeDelay(shake.delay, shake));
                else
                    PlayCameraShake(shake);
            }
        }

        foreach (var footstep in _dataConfig.actorTriggers.footsteps)
        {
            if (footstep.footStepEventName == eventName)
            {
                if (footstep.footStepDelay > 0f)
                    Scheduler.RunCoroutine(PlayFootStepDelay(footstep.footStepDelay, footstep));
                else
                    PlayFootStep(footstep);
            }
        }
    }
    #endregion

    /// <summary>
    /// 删除所有特效.
    /// </summary>
    private void StopEffects()
    {
        foreach (var effect in this.effects)
        {
            if (effect != null)
            {
                effect.Stop();
            }
        }
    }


    #region 播放Effects特效
    private IEnumerator DelayPlayEffect(float delay, PrefabDataConfig.TriggerEffect effect)
    {
        yield return new WaitForSeconds(delay);
        Scheduler.RunCoroutine(PlayEffects(effect));
    }

    private IEnumerator PlayEffects(PrefabDataConfig.TriggerEffect effect)
    {
        Transform reference = null;
        Transform deliverer = null;
        if (effect.playerAtTarget)
        {
            reference = _animator.transform;
            if (string.IsNullOrEmpty(effect.referenceNodeHierarchyPath))
                deliverer = _animator.transform;
            else
            {
                var node = _animator.transform.Find(effect.referenceNodeHierarchyPath);
                deliverer = node != null ? node : _animator.transform;
            }
        }
        else
        {
            var node = _animator.transform.Find(effect.referenceNodeHierarchyPath);
            reference = node == null ? _animator.transform : node;
            deliverer = node == null ? _animator.transform : node;
        }

        if (this == null || reference == null || deliverer == null)
            yield break;

        WaitSpawnGameObject wait = null;
        try
        {
            wait = GameObjectPool.Instance.SpawnAsset(effect.effectAsset);
        }catch(Exception ex)
        {

        }

        yield return wait == null ? null : wait;

        if (wait.Error != null)
        {
            Debug.LogError(wait.Error);
            yield break;
        }

        var instance = wait.Instance;
        if (instance == null)
        {
            Debug.LogError("特效为空,请检查");
            yield break;
        }

        instance.SetLayerRecursively(_animator.gameObject.layer);
        var ctrl = instance.GetComponent<EffectControl>();
        if (ctrl == null)
        {
            Debug.LogError("EffectControl为空,请检查");
            yield break;
        }

        if(effect.isAttach)
        {
            ctrl.transform.SetParent(reference);
            if(effect.isRotation)
            {
                var direction = reference.position - deliverer.position;
                direction.y = 0.0f;
                ctrl.transform.SetPositionAndRotation(reference.position, Quaternion.LookRotation(direction));
            }
            else
            {
                ctrl.transform.localPosition = Vector3.zero;
                ctrl.transform.localRotation = Quaternion.identity;
            }
            ctrl.transform.localScale = reference.localScale;
        }
        else
        {
            ctrl.transform.SetPositionAndRotation(
                reference.position, reference.rotation);
            ctrl.transform.localScale = reference.lossyScale;
        }

        // Record and check the effect finish.
        var eff_node = this.effects.AddLast(ctrl);
        ctrl.FinishEvent += () => 
        {
            this.effects.Remove(eff_node);
            Scheduler.RunCoroutine(FreeGameObject(ctrl.gameObject, effect.triggerFreeDelay));
        };

        ctrl.Reset();
        ctrl.Play();
    }
    #endregion

    #region 播放Projectil特效
    private void PlayProjectileAction(string name)
    {
        _animator.SetTrigger(name);
        _animator.WaitEvent(string.Format("{0}/begin", name), (param, info) =>
        {
            var target = _animator.transform;
            PlayProjectile(name, () =>
            {
                PlayHurtShow(name, target, target, null);
            });
        });
    }

    private void PlayProjectileEffect(string name)
    {
        _animator.WaitEvent(string.Format("{0}/begin", name), (param, info) =>
        {
            var target = _animator.transform;
            PlayProjectile(name, () =>
            {
                PlayHurtShow(name, target, target, null);
            });
        });
    }

    private void PlayProjectile(string action, Action hited)
    {
        foreach (var projectile in _dataConfig.actorController.projectiles)
        {
            if (projectile.Action != action ||
                projectile.Projectile.IsEmpty)
                continue;
            
            var hurtPoint = _animator.transform.Find(projectile.ProjectilNodeHierarchyPath);
            var fromtran = _animator.transform.Find(projectile.FromPosHierarchyPath);
            var fromPosition = _animator.transform.position;
            if (fromtran != null)
                fromPosition = fromtran.position;

            if (projectile.DelayProjectileEff > 0f)
            {
                Scheduler.RunCoroutine(DelayPlayProjectileEffect(
                    projectile, hurtPoint, fromPosition, hited));
            }
            else
            {
                Scheduler.RunCoroutine(PlayProjectileWithEffect(
                    projectile, hurtPoint, fromPosition, hited));
            }
        }
    }

    private IEnumerator DelayPlayProjectileEffect(
        PrefabDataConfig.ProjectileData projectile,
        Transform hurtPoint,
        Vector3 fromPosition,
        Action hited)
    {
        yield return new WaitForSeconds(projectile.DelayProjectileEff);

        Scheduler.RunCoroutine(PlayProjectileWithEffect(
               projectile, hurtPoint, fromPosition, hited));
    }

    private IEnumerator PlayProjectileWithEffect(
        PrefabDataConfig.ProjectileData projectile,
        Transform hurtPoint,
        Vector3 fromPosition,
        Action hited)
    {
        var wait = GameObjectPool.Instance.SpawnAsset(projectile.Projectile);
        yield return wait;

        if (this == null)
            yield break;

        if (!string.IsNullOrEmpty(wait.Error))
        {
            Debug.LogError(wait.Error);
            hited();
            yield break;
        }

        var go = wait.Instance;
        if (go == null) yield break;

        var projectileSingle = go.GetComponent<Projectile>();
        if (projectileSingle != null)
        {
            projectileSingle.transform.position = fromPosition;
            projectileSingle.transform.localScale = _animator.transform.lossyScale;
            projectileSingle.gameObject.SetLayerRecursively(_animator.gameObject.layer);
            projectileSingle.Play(
                _animator.transform.lossyScale,
                hurtPoint,
                _animator.gameObject.layer,
                () =>
                {
                    if (hited != null)
                    {
                        hited();
                    }
                },
                () => { Scheduler.RunCoroutine(FreeGameObject(projectileSingle.gameObject, projectile.DeleProjectileDelay));});
        }
    }
    #endregion

    #region 播放Hurt特效
    private void PlayHurtShow(string skillAction, Transform root, Transform hurtPoint, Action perHit)
    {
        foreach (var hurt in _dataConfig.actorController.hurts)
        {
            if (hurt.Action != skillAction)
                continue;

            if (!hurt.HurtEffect.IsEmpty)
            {
                if (hurt.DelayHurtEffect > 0f)
                {
                    Scheduler.RunCoroutine(DelayPlayHurtEffect(
                   hurt, root, hurtPoint));
                }
                else
                {
                    Scheduler.RunCoroutine(PlayHurtEffect(
                   hurt, root, hurtPoint));
                }
            }

            if (hurt.HitCount > 0)
            {
                if (hurt.DelayHitEffect > 0f)
                {
                    Scheduler.RunCoroutine(DelayPlayHitEffect(hurt, root, hurtPoint, perHit));
                }
                else
                {
                    Scheduler.RunCoroutine(PlayHitEffect(hurt, root, hurtPoint, perHit));
                }
            }
            else
            {
                if (perHit != null)
                    perHit();
            }
        }
    }

    private IEnumerator DelayPlayHurtEffect(
         PrefabDataConfig.HurtData data,
        Transform root,
        Transform hurtPoint)
    {
        yield return new WaitForSeconds(data.DelayHurtEffect);
        PlayHurtEffect(data, root, hurtPoint);
    }

    private IEnumerator PlayHurtEffect(
        PrefabDataConfig.HurtData data,
        Transform root,
        Transform hurtPoint)
    {
        var wait = GameObjectPool.Instance.SpawnAsset(data.HurtEffect);
        yield return wait;

        if (this == null)
        {
            yield break;
        }

        var gameObject = wait.Instance;
        var instance = gameObject.GetComponent<EffectControl>();
        if (instance == null)
        {
            GameObjectPool.Instance.Free(gameObject);
            yield break;
        }

        instance.Reset();

        Transform targetPos = root;
        if (data.HurtPosition == PrefabDataConfig.HurtPositionEnum.HurtPoint)
            targetPos = hurtPoint;

        if (data.HurtRotation == PrefabDataConfig.HurtRotationEnum.Target)
            instance.transform.SetPositionAndRotation(
                targetPos.position, targetPos.rotation);
        else
        {
            var direction = targetPos.position - _animator.transform.position;
            direction.y = 0.0f;
            instance.transform.SetPositionAndRotation(
                targetPos.position,
                Quaternion.LookRotation(direction));
        }

        instance.FinishEvent += () =>
        {
            Scheduler.RunCoroutine(FreeGameObject(gameObject, data.HurtFreeDelay));
        };
        instance.Play();
    }

    private IEnumerator DelayPlayHitEffect(
        PrefabDataConfig.HurtData data,
        Transform root,
        Transform hurtPoint,
        Action perHit)
    {
        yield return new WaitForSeconds(data.DelayHitEffect);
        PlayHitEffect(data, root, hurtPoint, perHit);
    }

    private IEnumerator PlayHitEffect(
        PrefabDataConfig.HurtData data,
        Transform root,
        Transform hurtPoint,
        Action perHit)
    {
        for (int i = 0; i < data.HitCount; ++i)
        {
            if (!data.HitEffect.IsEmpty)
            {
                var wait = GameObjectPool.Instance.SpawnAsset(data.HitEffect);
                yield return wait;

                if (this == null)
                    yield break;

                var gameObject = wait.Instance;
                var instance = gameObject.GetComponent<EffectControl>();
                if (instance == null)
                    yield break;

                if (root == null || hurtPoint == null)
                {
                    GameObjectPool.Instance.Free(gameObject);
                    yield break;
                }

                instance.Reset();

                Transform targetPos = root;
                if (data.HurtPosition == PrefabDataConfig.HurtPositionEnum.HurtPoint)
                    targetPos = hurtPoint;

                if (data.HurtRotation == PrefabDataConfig.HurtRotationEnum.Target)
                    instance.transform.SetPositionAndRotation(
                        targetPos.position, targetPos.rotation);
                else
                {
                    var direction = targetPos.position - _animator.transform.position;
                    direction.y = 0.0f;
                    instance.transform.SetPositionAndRotation(
                        targetPos.position,
                        Quaternion.LookRotation(direction));
                }

                instance.FinishEvent += () =>
                {
                    Scheduler.RunCoroutine(FreeGameObject(gameObject, data.HitFreeDelay));
                };
                instance.Play();
            }

            if (perHit != null)
                perHit();
            yield return new WaitForSeconds(data.HitInterval);
        }
    }
    #endregion

    #region 播放Halt特效
    private void PlayHalt()
    {

    }
    #endregion

    #region 播放Sound
    private IEnumerator PlaySoundDelay(float delay, PrefabDataConfig.TriggerSound sound)
    {
        yield return new WaitForSeconds(sound.soundDelay);
        PlaySound(sound);
    }

    private void PlaySound(PrefabDataConfig.TriggerSound sound)
    {
        var eventName = string.Format("{0}/begin", _selectEventName.Split('/')[0]);
        if (_couSoundCount < 2)
        {
            ScriptablePool.Instance.Load(sound.soundAudioAsset, obj =>
            {
                if (null == obj)
                {
                    Debug.LogWarning("Not correct audioAsset");
                    return;
                }
                var item = obj as AudioItem;
                if (null == item)
                {
                    Debug.LogWarning("Cannot convert audioAsset");
                    return;
                }
                var audioPlayer = AudioManager.Play(item, _animator.transform);
                ++_couSoundCount;
                Scheduler.RunCoroutine(this.SoundCoroutine(audioPlayer.WaitFinish()));
            });
        }
    }

    private IEnumerator SoundCoroutine(IEnumerator ienumerator)
    {
        yield return ienumerator;
        --_couSoundCount;
    }
    #endregion


    #region 震屏
    private IEnumerator PlayCameraShakeDelay(float delay, PrefabDataConfig.CameraShakeData shake)
    {
        yield return new WaitForSeconds(shake.delay);
        PlayCameraShake(shake);
    }

    private void PlayCameraShake(PrefabDataConfig.CameraShakeData shake)
    {
        if (Camera.main != null && Camera.main.isActiveAndEnabled)
        {
            CameraShake.Shake(shake.numberOfShakes, Vector3.one, Vector3.zero, shake.distance, shake.speed, shake.decay, 1.0f, true);
        }
    }
    #endregion

    #region 播放FootStep
    private IEnumerator PlayFootStepDelay(float delay, PrefabDataConfig.FootStep footStep)
    {
        yield return new WaitForSeconds(delay);
        PlayFootStep(footStep);
    }

    private void PlayFootStep(PrefabDataConfig.FootStep footStep)
    {
        var eventName = string.Format("{0}/begin", _selectEventName.Split('/')[0]);
        if (footStep.footStepEventName == eventName)
        {
            if (!footStep.footAudioAsset.IsEmpty)
            {
                if (string.IsNullOrEmpty(footStep.footNodeHierarchyPath))
                {
                    AudioManager.PlayAndForget(footStep.footAudioAsset, _animator.transform);
                }
                else
                {
                    var node = _animator.transform.Find(footStep.footNodeHierarchyPath);
                    AudioManager.PlayAndForget(footStep.footAudioAsset, node);
                }
            }

            if (footStep.footStepDust != null && !string.IsNullOrEmpty(footStep.footNodeHierarchyPath))
            {
                var dust = GameObjectPool.Instance.Spawn(footStep.footStepDust, null);
                dust.gameObject.SetLayerRecursively(_animator.gameObject.layer);
                var node = _animator.transform.Find(footStep.footNodeHierarchyPath);
                if (node == null)
                {
                    Debug.LogError(string.Format("找不到子节点{0}", footStep.footAudioName));
                    return;
                }

                dust.transform.SetPositionAndRotation(
                    node.transform.position,
                    node.transform.rotation);
                dust.transform.localScale = node.transform.lossyScale;
                dust.FinishEvent += () =>
                {
                    GameObjectPool.Instance.Free(dust.gameObject);
                };

                dust.Reset();
                dust.Play();

                RaycastHit hitInfo;
                if (Physics.Raycast(
                        node.position,
                        Vector3.down,
                        out hitInfo,
                        Mathf.Infinity,
                        1 << GameLayers.Walkable))
                {
                    FootprintManager.Instance.AddFootprint(
                        hitInfo.point,
                        _animator.transform.forward,
                        _animator.transform.right,
                        footStep.footprint);
                }
            }
        }
    }
    #endregion
    #endregion

    private IEnumerator FreeGameObject(GameObject go, float delay)
    {
        if (delay <= 0f)
        {
            GameObjectPool.Instance.Free(go);
        }else
        {
            yield return new WaitForSeconds(delay);
            GameObjectPool.Instance.Free(go);
        }
    }

    private string GetBtnName(string name)
    {
        return string.IsNullOrEmpty(name) ? "按钮" : name;
    }

    private EffectControl GetEffectCtrl(string effectName, string path, string name = "特效")
    {
        EffectControl go = null;
        if (string.IsNullOrEmpty(effectName))
        {
            go = EditorGUILayout.ObjectField(name, go, typeof(EffectControl), true) as EffectControl;
        }
        else
        {
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            go = EditorGUILayout.ObjectField(name, prefab, typeof(EffectControl), true) as EffectControl;
        }
        return go;
    }

    private AssetID GetAssetID(UnityEngine.Object go)
    {
        var path = AssetDatabase.GetAssetPath(go);
        var guid = AssetDatabase.AssetPathToGUID(path);
        var importer = AssetImporter.GetAtPath(path);
        AssetID assetId = new AssetID(importer == null ? "" : importer.assetBundleName, go == null ? "" : go.name);
        assetId.AssetGUID = guid;
        return assetId;
    }

    private string SelectActionName(string actionName, string name = "Event Name")
    {
        int eventIdx = 0;
        if (!string.IsNullOrEmpty(actionName))
        {
            for (int i = 0; i < ActorEventDrawer.eventNames.Length; i++)
            {
                if (actionName == ActorEventDrawer.eventNames[i])
                    eventIdx = i;
            }
        }
        eventIdx = EditorGUILayout.Popup(name, eventIdx, ActorEventDrawer.eventNames);
        return ActorEventDrawer.eventNames[eventIdx];
    }

    private AudioItem GetAudioItem(string audioName, string path, string name = "Audio Asset")
    {
        AudioItem go = null;
        if (string.IsNullOrEmpty(audioName))
        {
            go = EditorGUILayout.ObjectField("Audio Asset", go, typeof(AudioItem), true) as AudioItem;
        }
        else
        {
            var prefab = AssetDatabase.LoadAssetAtPath<AudioItem>(path);
            go = EditorGUILayout.ObjectField(name, prefab, typeof(AudioItem), true) as AudioItem;
        }

        return go;
    }
    public string GetHierarchyPath(Transform tran)
    {
        if (tran == _animator.transform)
        {
            return string.Empty;
        }

        var sb = new StringBuilder();
        sb.Append(tran.name);
        var node = tran.parent;

        while (node != null && node != _animator.transform)
        {
            sb.Insert(0, node.name + '/');
            node = node.parent;
        }

        return sb.ToString();
    }
}
