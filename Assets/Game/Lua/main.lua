package.cpath = package.cpath .. ';C:/Users/LuoYikun/AppData/Roaming/JetBrains/IntelliJIdea2020.3/plugins/intellij-emmylua/classes/debugger/emmy/windows/x64/?.dll'
local dbg = require('emmy_core')
dbg.tcpListen('localhost', 9966)

GameObject = UnityEngine.GameObject
MainCamera = UnityEngine.Camera.main
_ = I18N.GetString
IS_AUDIT_VERSION = false				-- 开启IOS审核
IS_AUDIT_MINI_GAME = false				-- 开启IOS小游戏
AUDIT_TIME_STAMP = -1					-- IOS审核时间戳（在这个时间之前都是单机版游戏，不请求任何东西）
IS_SINGLE_GAME = false					-- 开启单机游戏（不联网，不上报）
IS_MSG_ENCRYPT = false					-- 协议是否加密

CAMERA_TYPE = -1 						-- 摄像机视角模式 0-固定视角 1-自由视角
MainCameraFollow = nil					-- MainCamera上的camera_follow组件
JUST_BACK_FROM_CROSS_SERVER = false		-- 从跨服回来时的处理标记
SHIELD_VOICE = false 					-- 是否屏蔽语音聊天
FIGHTSTATE_CAMERA = true				-- 战斗状态的时候摄像机缓慢调节到最佳状态
IS_FEES_VOICE = false					-- 是否使用收费语音录制(语音翻译转文字)

CTRL_STATE = {
	START = 0, 
	UPDATE = 1,
	finish = 2,
	NONE = 3,
}

socket = require("socket")
mime = require("mime")
cjson = require("cjson.safe")
require("init/http_client")
require("systool/gameobject")
require("systool/baseclass")
require("systool/u3dobj")
require("systool/bindtool")
require("resmanager/load_util")
require("audit/ios_audit_adapter")

local quick_login = require("editor/quick_login")
local quick_restart = require("editor/quick_restart")
local develop_mode = require("editor/develop_mode")

local ctrl_list = {}
function Sleep(n)
	socket.select(nil, nil, n)
end

IsLowMemSystem = UnityEngine.SystemInfo.systemMemorySize <= 1500
GAME_FPS = 60

IsGameStop = false

function GameStart()
    IsGameStop = false
	UnityEngine.Application.targetFrameRate = GAME_FPS
	UnityEngine.Shader.globalMaximumLOD = 200

	UnityEngine.Screen.sleepTimeout =
		UnityEngine.SleepTimeout.NeverSleep
		
	if quick_login:IsOpenQuick() then
		quick_login:Start()
		return
	end

	PushCtrl(require("init/init_ctrl"))
end

function GameUpdate()
	if IsGameStop then
		return
	end

	local time = UnityEngine.Time.unscaledTime
	GlobalUnityTime = time

	local delta_time = UnityEngine.Time.unscaledDeltaTime
	for k, v in pairs(ctrl_list) do
		v:Update(time, delta_time)
	end

	quick_login:Update(time, delta_time)
	develop_mode:Update(time, delta_time)

	if nil ~= BundleCache then
		BundleCache:Update(time, delta_time)
	end

	if ResMgr and (UNITY_EDITOR or ResMgr:GetDownloadingURL()) then
		ResMgr:Update(time, delta_time)
	end
end

function GameStop()
	IsGameStop = true

	for k, v in pairs(ctrl_list) do
		v:Stop()
	end

	quick_login:Stop()
	develop_mode:OnGameStop()

	if nil ~= ResPoolMgr then
		ResPoolMgr:OnGameStop()
		ResPoolMgr = nil
	end

	if nil ~= AudioManager then
		AudioManager:OnGameStop()
		AudioManager = nil
	end

	if nil ~= AssetBundleMgr then
		AssetBundleMgr:OnGameStop()
		AssetBundleMgr = nil
	end

	if nil ~= BundleCache then
		BundleCache:OnGameStop()
		BundleCache = nil
	end
	
end

local gamePaused = false;
function GameFocus(hasFocus)
	gamePaused = not hasFocus

	if nil ~= GlobalEventSystem then
		GlobalEventSystem:Fire(SystemEventType.GAME_FOCUS, hasFocus)
	end
end

function GamePause(pauseStatus)
	gamePaused = pauseStatus

	if nil ~= GlobalEventSystem then
		GlobalEventSystem:Fire(SystemEventType.GAME_PAUSE, pauseStatus)
	end
end

function ExecuteGm(gm)
	quick_login:ExecuteGm(gm)
end

function CheckMemoryLeak()

end

function ExecuteHotUpdate(lua_name)
	print("[ExecuteHotUpdate]", lua_name)
	_G.package.loaded[lua_name] = nil
	require(lua_name)
end

function ExecuteQuickRestart(reload_files)
	quick_restart:Restart(reload_files)
end

function Collectgarbage(param)
	return collectgarbage(param) or -1
end

function PushCtrl(ctrl)
	ctrl_list[ctrl] = ctrl
end

function PopCtrl(ctrl)
	ctrl_list[ctrl] = nil
end

function EnableGameObjAttachEvent(list)
	if not IsGameStop then
		GameObjAttachEventHandle.EnableGameObjAttachEvent(list)
	end
end

function DisableGameObjAttachEvent(list)
	if not IsGameStop then
		GameObjAttachEventHandle.DisableGameObjAttachEvent(list)
	end
end

function DestroyGameObjAttachEvent(list)
	if not IsGameStop then
		GameObjAttachEventHandle.DestroyGameObjAttachEvent(list)
	end
end

function EnableLoadRawImageEvent(list)
	if not IsGameStop then
		LoadRawImageEventhandle.EnableLoadRawImageEvent(list)
	end
end

function DisableLoadRawImageEvent(list)
	if not IsGameStop then
		LoadRawImageEventhandle.DisableLoadRawImageEvent(list)
	end
end

function DestroyLoadRawImageEvent(list)
	if not IsGameStop then
		LoadRawImageEventhandle.DestroyLoadRawImageEvent(list)
	end
end

function ProjectileSingleEffectEvent(hit_effect, position, rotation, hit_effect_with_rotation, source_scale, layer)
	if not IsGameStop then
		EffectEventHandle.ProjectileSingleEffectEvent(hit_effect, position, rotation, hit_effect_with_rotation, source_scale, layer)
	end
end

function UIMouseClickEffectEvent(effectInstance, effects, canvas, mouse_click_transform)
	if not IsGameStop then
		EffectEventHandle.UIMouseClickEffectEvent(effectInstance, effects, canvas, mouse_click_transform)
	end
end

function PlayAudio(bundle_name, asset_name)
	if not IsGameStop then
		AudioManager.PlayAndForget(bundle_name, asset_name)
	end
end

-- 限制屏幕分辨率的尺寸.
local orginal_screen_width = 0
local orginal_screen_height = 0
function LimitScreenResolution(limit)
	local screen = UnityEngine.Screen
	if 0 == orginal_screen_width then
		orginal_screen_width = screen.width
	end

	if 0 == orginal_screen_height then
		orginal_screen_height = screen.height
	end

	if orginal_screen_width <= 0 or orginal_screen_height <= 0 then
		return
	end

	if orginal_screen_width > orginal_screen_height then
		if orginal_screen_height > limit then
			local radio = orginal_screen_width / orginal_screen_height
			screen.SetResolution(math.floor(limit * radio), limit, true)
		else
			screen.SetResolution(orginal_screen_width, orginal_screen_height, true)
		end
	else
		if orginal_screen_width > limit then
			local radio = orginal_screen_width / orginal_screen_height
            screen.SetResolution(limit, math.floor(limit * radio), true)
		else
			screen.SetResolution(orginal_screen_width, orginal_screen_height, true)
		end
	end
end


if not UnityEngine.Debug.isDebugBuild then
	print_log = function() end
	print = function() end
end

math.randomseed(os.time())
GameStart()