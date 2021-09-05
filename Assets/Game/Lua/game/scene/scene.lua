require("game/scene/scene_config")
require("game/scene/scene_data")
require("game/scene/scene_protocal")
require("game/scene/camera")
require("game/scene/optimize/scene_optimizes")
require("game/scene/widget/guide_arrow")
require("game/scene/loading/scene_loading")
require("game/scene/loading/predownload")
require("game/scene/loading/freedownload")
require("game/scene/scene_logic/scene_logic")
require("game/scene/follow_ui/follow_ui")
require("game/scene/follow_ui/character_follow")
require("game/scene/follow_ui/role_follow")
require("game/scene/follow_ui/monster_follow")
require("game/scene/sceneobj/scene_obj")
require("game/scene/sceneobj/character")
require("game/scene/sceneobj/role")
require("game/scene/sceneobj/main_role")
require("game/scene/sceneobj/follow_obj")
require("game/scene/sceneobj/monster")
require("game/scene/sceneobj/tower")
require("game/scene/sceneobj/door")
require("game/scene/sceneobj/jump_point")
require("game/scene/sceneobj/effect_obj")
require("game/scene/sceneobj/fall_item")
require("game/scene/sceneobj/gather_obj")
require("game/scene/sceneobj/npc")
require("game/scene/sceneobj/truck_obj")
require("game/scene/sceneobj/map_move_obj")
require("game/scene/sceneobj/spirit_obj")
require("game/scene/sceneobj/goddess_obj")
require("game/scene/sceneobj/trigger_obj")
require("game/scene/sceneobj/event_obj")
require("game/scene/sceneobj/marry_obj")
require("game/scene/sceneobj/fight_mount_obj")
require("game/scene/sceneobj/ming_ren_role")
require("game/scene/sceneobj/boat_obj")
require("game/scene/sceneobj/couple_halo_obj")
require("game/scene/sceneobj/test_role")
require("game/scene/sceneobj/imp_guard_obj")
require("game/scene/sceneobj/walk_npc")
require("game/scene/sceneobj/defense_obj")
require("game/scene/sceneobj/substitutes")
require("game/scene/sceneobj/pet_obj")
require("game/scene/sceneobj/city_owner_statue")
require("game/scene/sceneobj/city_owner_role_obj")
require("game/scene/sceneobj/lingchong_obj")
require("game/scene/sceneobj/flypet_obj")
require("game/scene/sceneobj/baby_obj")

local GameRootTransform = GameObject.Find("GameRoot").transform
local develop_mode = require("editor/develop_mode")

Scene = Scene or BaseClass(BaseController)
DownAngleOfCamera = 180

function Scene:__init()
	if Scene.Instance then
		print_error("[Scene] Attempt to create singleton twice!")
		return
	end
	Scene.Instance = self

	self.data = SceneData.New()
	self.predownload = PreDownload.New()
	self.freedownload = FreeDownload.New()
	self.scene_optimize = SceneOptimize.New()

	self.start_loading_time = nil
	self.is_scene_visible = true
	self.scene_loading = SceneLoading.New()
	self.camera = Camera.New()
	self.guide_arrow = nil

	self.main_role = MainRole.New(GameVoManager.Instance:GetMainRoleVo())
	self.obj_list = {}
	self.instanceid_list = {}
	self.obj_group_list = {}

	self.is_delete_fallitem = false
	self.is_in_update = false
	self.delay_handle_funcs = {}
	-- 场景移动对象
	self.obj_move_info_list = {}

	self.main_role_pos_x = 0
	self.main_role_pos_y = 0
	self.last_check_fall_item_time = 0
	self.next_can_reduce_mem_time = 0
	self.enter_scene_count = 0

	self.act_scene_id = 0
	self.setcamera_scene_id = 0
	self.scene_logic = nil
	self.is_first_enter_scene = false
	self.frist_send_msg = true
	self.camera_follow_obj = nil
	self.is_can_move = true
	self.is_cg_hide_npc = false 					-- cg时创建npc是否隐藏
	self:RegisterAllProtocols()						-- 注册所有需要响应的协议
	self:RegisterAllEvents()						-- 注册所有需要监听的事件

	-- 场景特效
	self.effect_list = {}

	-- 温泉皮艇
	self.boat_list = {}
	self.boat_delay_list = {}

	self.couple_halo_obj_list = {}
	self.shield_npc_id_list = {}
	self.block_shield_area = {}

	self.cg_obj_list = {}

	self.city_statue = nil						-- 攻城战城主雕像
	-- 监听游戏设置改变
	self:BindGlobalEvent(
		SettingEventType.SHIELD_OTHERS,
		BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SELF_SKILL_EFFECT,
		BindTool.Bind1(self.OnShieldSelfEffectChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_SAME_CAMP,
		BindTool.Bind1(self.OnShieldRoleChanged, self))
	self:BindGlobalEvent(
		SettingEventType.SKILL_EFFECT,
		BindTool.Bind1(self.OnShieldSkillEffectChanged, self))
	self:BindGlobalEvent(
		SettingEventType.CLOSE_GODDESS,
		BindTool.Bind1(self.OnShieldGoddessChanged, self))
	self:BindGlobalEvent(
		SettingEventType.CLOSE_SHOCK_SCREEN,
		BindTool.Bind1(self.OnShieldCameraShakeChanged, self))
	self:BindGlobalEvent(SettingEventType.CLOSE_TITLE,
		BindTool.Bind(self.SettingChange, self, SETTING_TYPE.CLOSE_TITLE))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_ENEMY,
		BindTool.Bind1(self.OnShieldEnemy, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_SPIRIT,
		BindTool.Bind1(self.OnShieldSpirit, self))
	self:BindGlobalEvent(
		SettingEventType.MAIN_CAMERA_MODE_CHANGE,
		BindTool.Bind1(self.UpdateCameraMode, self))
	self:BindGlobalEvent(
		SettingEventType.MAIN_CAMERA_SETTING_CHANGE,
		BindTool.Bind1(self.UpdateCameraSetting, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_LINGCHONG,
		BindTool.Bind1(self.OnShieldLingChong, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_FLYPET,
		BindTool.Bind1(self.OnShieldFlyPet, self))
	self:BindGlobalEvent(
		SettingEventType.SHIELD_ADVANCE,
		BindTool.Bind1(self.OnShieldAdvance, self))

	self.click_handler = BindTool.Bind(self.OnSceneObjClick, self)
	EasyTouch.On_SimpleTap = EasyTouch.On_SimpleTap + self.click_handler
	Runner.Instance:AddRunObj(self, 6)

	self.effect_cd = 0
	-- 1自由视角，0固定视角
	self.camera_state = 0
		-- EasyTouch.On_Swipe = EasyTouch.On_Swipe + OnSwipe
		-- EasyTouch.On_Pinch = EasyTouch.On_Pinch + OnPinch

	self.quality_node = QualityConfig.ListenQualityChanged(function()
		self:OnQualityChanged()
	end)
end

function Scene:__delete()
	self.scene_optimize:DeleteMe()
	self.freedownload:DeleteMe()
	self.predownload:DeleteMe()
	self.data:DeleteMe()
	self.camera:DeleteMe()
	self.scene_loading:DeleteMe()

	if self.quality_node ~= nil then
		QualityConfig.UnlistenQualtiy(self.quality_node)
		self.quality_node = nil
	end
	if self.clear_cg_obj_time then
		GlobalTimerQuest:CancelQuest(self.clear_cg_obj_time)
		self.clear_cg_obj_time = nil
	end

	if nil ~= self.clickHandle and nil ~= ClickManager.Instance then
		ClickManager.Instance:UnlistenClickGround(self.clickHandle)
		self.clickHandle = nil
	end

	if self.turn_timer then
		GlobalTimerQuest:CancelQuest(self.turn_timer)
		self.turn_timer = nil
	end

	self:DelateAllObj()
	self:ClearScene()
	self:ClearCgObj()

	if self.camera_follow_obj then
		ResPoolMgr:Release(self.camera_follow_obj)
		self.camera_follow_obj = nil
	end
	MainCameraFollow = nil
	MainCamera = nil
	CAMERA_TYPE = -1

	EasyTouch.On_SimpleTap = EasyTouch.On_SimpleTap - self.click_handler
	Scene.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function Scene:UpdateHeroLight()
	if IsNil(self.scene_hero_light) then
		self.scene_hero_light = GameObject.Find("Main/Hero light")
	end

	if not IsNil(self.scene_hero_light) then
		self.scene_hero_light:SetActive(0 == QualityConfig.QualityLevel)
	end
end

--  0.高配 1.中配 2.低配 3.超低配
function Scene:OnQualityChanged()
	self:UpdateHeroLight()
end

function Scene:OnSceneObjClick(guesture)
	if (self.main_role and self.main_role:GetIsFlying()) or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	if not IsNil(MainCamera) then
		local screen_pos = Vector3(guesture.position.x, guesture.position.y, 0)
		local ray = MainCamera:ScreenPointToRay(screen_pos)
		local hits = UnityEngine.Physics.RaycastAll(ray)
		local distance = 99999
		local owner = nil
		for i = 0, hits.Length - 1 do
			if hits[i].distance < distance then
				distance = hits[i].distance
				local id = self:FindRootParentInstanceID(hits[i].transform)
				if nil ~= id then
					local client_obj = self.instanceid_list[id]
					if client_obj then
						local obj = self:GetObj(client_obj)
						if obj:GetVo().npc_id and obj:GetVo().npc_id == GuildData.Instance:GetMoneyTreeID() then
							return
						end
						if obj then
							owner = obj.draw_obj:GetPart(SceneObjPart.Main)
						end
					end
				end
			end
		end

		if nil ~= owner then
			owner:OnClickListener()
			self.is_click_obj = true
		end
	end
end

function Scene:FindRootParentInstanceID(transform)
	if nil == transform then
		return nil
	end

	local move_obj = transform:GetComponent(typeof(MoveableObject))
	if nil == move_obj then
		return self:FindRootParentInstanceID(transform.parent)
	else
		return transform:GetInstanceID()
	end
end

function Scene:SetSceneVisible(visible)
	self.is_scene_visible = visible
	if not IsNil(MainCamera) then
		MainCamera.enabled = self.is_scene_visible
	end
end

function Scene:ClearScene()
	self.scene_config = nil
	for _, v in pairs(self.obj_list) do
		if v ~= self.main_role then
			self:Fire(ObjectEventType.OBJ_DELETE, v)
			v:DeleteMe()
		end
	end
	if self.main_role then
		self.main_role:ResetIsEnterScene()
	end

	self.obj_list = {}
	self.instanceid_list = {}
	self.obj_group_list = {}
	self.boat_list = {}

	self.is_in_update = false
	self:DeleteAllMoveObj()
	self:DelGuideArrow()
	self:DelSceneEffect()

	if nil ~= self.scene_logic then
		self.scene_logic:DeleteMe()
		self.scene_logic = nil
	end

	for k,v in pairs(self.boat_delay_list) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.boat_delay_list = {}
	self.scene_hero_light = nil
end

function Scene:DelateAllObj()
	for _, v in pairs(self.obj_list) do
		self:Fire(ObjectEventType.OBJ_DELETE, v)
		v:DeleteMe()
	end
	self.obj_list = {}
	self.instanceid_list = {}
end

function Scene:DeleteAllMoveObj()
	-- develop模式会触发CheckDeleteMe的检查，会导致卡顿，所以这里跳过Delete操作
	if not develop_mode:IsDeveloper() then
		for k, v in pairs(self.obj_move_info_list) do
			v:DeleteMe()
		end
	end
	self.obj_move_info_list = {}
end

function Scene:RegisterAllEvents()
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
end

function Scene:Update(now_time, elapse_time)
	self.is_in_update = true

	if nil ~= self.scene_logic then
		self.scene_logic:Update(now_time, elapse_time)
	end

	for k, v in pairs(self.obj_list) do
		v:Update(now_time, elapse_time)
	end

	for k, v in pairs(self.obj_move_info_list) do
		v:Update(now_time, elapse_time)
	end
	self.is_in_update = false

	if now_time >= self.last_check_fall_item_time + 0.2 then
		self.last_check_fall_item_time = now_time
		self:PickAllFallItem()
	end

	-- 调用延时函数
	if next(self.delay_handle_funcs) then
		local delay_funcs = self.delay_handle_funcs
		self.delay_handle_funcs = {}
		for _, v in pairs(delay_funcs) do
			v()
		end
	end

	if self:IsSceneLoading() then
		return
	end

	local pos_x, pos_y = self.main_role:GetLogicPos()
	if self.main_role_pos_x ~= pos_x or self.main_role_pos_y ~= pos_y then
		self.main_role_pos_x, self.main_role_pos_y = pos_x, pos_y
		self:CheckClientObj()
		self:CheckJump()
	end
end

function Scene:LockCameraInQingGongGuide(state)
	if IsNil(MainCameraFollow) then
		return
	end
	MainCameraFollow.AllowRotation = not state
	MainCameraFollow.AllowXRotation = not state  
	MainCameraFollow.AllowYRotation = not state
	if state then
		MainCameraFollow.Distance = 15
		MainCameraFollow:ChangeAngle(Vector2(15, 0))
	end
end

function Scene:IsSceneLoading()
	return self.scene_loading:IsSceneLoading()
end

function Scene:IsEnterScene()
	return nil ~= self.is_enter_scene
end

function Scene:ResetIsEnterScene()
	self.is_enter_scene = nil
end

function Scene:OpenSceneLoading()
	self.scene_loading:Open()
end

function Scene:IsFirstEnterScene()
	return self.is_first_enter_scene
end

function Scene:OnChangeScene(scene_id)
	print("[Scene] OnChangeScene", scene_id)

	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_config then
		print_log("scene_config not find, scene_id:" .. scene_id)
		return
	end

	self.is_first_enter_scene = nil == self.scene_config
	self.old_scene_type = nil ~= self.scene_config and self.scene_config.scene_type or SceneType.Common
	if self.scene_logic ~= nil then
		self.scene_logic:Out(self.old_scene_type, scene_config.scene_type)
	end

	self:ClearScene()

	self.scene_config = scene_config
	GameMapHelper.SetOrigin(self.scene_config.origin_x, self.scene_config.origin_y)
	MoveableObject.SetLogicMap(self.scene_config.origin_x, self.scene_config.origin_y, Config.SCENE_TILE_WIDTH, Config.SCENE_TILE_HEIGHT)

	self.scene_logic = SceneLogic.Create(self.scene_config.scene_type, scene_id)

	AStarFindWay:Init(self.scene_config.mask, self.scene_config.width, self.scene_config.height)

	self:StartLoadScene(scene_id)

	-- 只有第一次进入游戏拉取世界仙盟聊天记录,其他情况不再拉取
	if self.frist_send_msg then
		-- 初始化收费聊天(方法里已经做了判断是否开启收费语音的)
		AudioService.Instance:InitFeesAudio()

		self.frist_send_msg = false
		self.is_enter_scene = true
		PlayerCtrl.Instance:SendReqAllInfo(1)
	else
		if nil == self.is_enter_scene then
			self.is_enter_scene = true
			PlayerCtrl.Instance:SendReqAllInfo()

			-- 这里需要调用是因为SendReqAllInfo返回后重新创建MainRole。并同时去掉跟随物。
			-- 这会导致进入跨服时用原服的obj id去删除跨服中新创建出来的obj.
			if nil ~= self.main_role then
				self.main_role:DeleteAllFollowObjs()
			end
		else
			self:CreateMainRole()
		end
	end

	if self.main_role then
		self.main_role:ChangeFakeTruck()
	end
	MainUICtrl.Instance:FlushView("on_line")
end

-- 打开加载条加载场景
function Scene:StartLoadScene(scene_id)
	if not self:IsSceneLoading() and self.act_scene_id == scene_id then
		self:OnLoadSceneMainComplete(scene_id)
		-- self:OnLoadSceneDetailComplete(scene_id)
		return
	end

	AssetBundleMgr:ReqHighLoad()
	self.scene_loading:SetStartLoadingCallback(BindTool.Bind(self.OnLoadStart, self))
	self.scene_loading:Start(scene_id, BindTool.Bind(self.OnMainLoadEnd, self), BindTool.Bind(self.OnLoadEnd, self), BindTool.Bind(self.OnLoadCompleteEnd, self))
end

-- 加载开始
function Scene:OnLoadStart(scene_id)
	print("[Scene] OnLoadStart ", scene_id)
	self.start_loading_time = Status.NowTime
	ReportManager:Step(Report.STEP_CHANGE_SCENE_BEGIN, scene_id)

	self:CreateCameraFollow()

	ViewManager.Instance:Close(ViewName.Login)
	if LoginCtrl.Instance then
		LoginCtrl.Instance:ClearScenes()
	end

	AudioManager.PlayAndForget("audios/sfxs/npcvoice/shared", "mute_voice") 	-- 播放npc对话静音
	AudioManager.PlayAndForget("audios/sfxs/uis", "MuteUIVoice") 			-- 播放ui静音
	self.predownload:Stop()
	self.freedownload:Stop()
end

function Scene:CreateCameraFollow()
	if nil == MainCameraFollow or nil == self.camera_follow_obj then
		self.camera_follow_obj = ResPoolMgr:TryGetGameObject("scenes_prefab", "CameraFollow")
		self.camera_follow_obj.transform:SetParent(GameRootTransform, false)
		MainCameraFollow = self.camera_follow_obj:GetComponent(typeof(CameraFollow))
		MainCameraFollow:SetIsFlyState(true)

		self.camera_default_setting = {}
		self.camera_default_setting.OriginAngle = MainCameraFollow.OriginAngle
		self.camera_default_setting.Distance = MainCameraFollow.Distance
	end
end

function Scene:OnMainLoadEnd(scene_id)
	self.act_scene_id = scene_id

	if nil == MainCameraFollow or nil == self.camera_follow_obj then
		self:CreateCameraFollow()
	end

	if MainCameraFollow then
		local camera_focal_point = GameObject.New("CamerafocalPoint")
		MainCameraFollow:CreateFocalPoint(camera_focal_point)
	end

	MainCamera = self.camera_follow_obj:GetComponentInChildren(typeof(UnityEngine.Camera))
	if nil ~= MainCamera and not IsNil(MainCamera) then
		self:OnLoadSceneMainComplete(scene_id)
	end
end

-- 进度条结束关掉面板的时候调用
function Scene:OnLoadCompleteEnd(scene_id)
	if self.scene_logic then
		self.scene_logic:SceneLoadEnd(scene_id)
	end
end

-- 加载结束(进度条做了延迟处理所以这不是立马关闭面板的)
function Scene:OnLoadEnd(scene_id)
	local loading_time = Status.NowTime - self.start_loading_time
	ReportManager:Step(Report.STEP_CHANGE_SCENE_COMPLETE, scene_id, loading_time)
	print("[Scene] OnLoadEnd ", scene_id, loading_time)

	AssetBundleMgr:ReqLowLoad()
	if not IsNil(self.camera_follow_obj) then
		local cameraculling_distance = self.camera_follow_obj:GetComponentInChildren(typeof(CameraCullingDistance))
		if not IsNil(cameraculling_distance) then
			cameraculling_distance:UpdateDistances()
		end
	end

	-- self:OnLoadSceneDetailComplete(scene_id)
	self.predownload:Start()
	self.freedownload:Start()

	self:SceneTreeTask()
	self:SetCurFixedCamera(scene_id)
	self:SetShiqiaoIsShield(scene_id)
	self:SetMountNpcIsShield()
end

function Scene:OnLoadSceneMainComplete(scene_id)
	if IsNil(MainCamera) or IsNil(MainCamera) then
		self:OnMainLoadEnd(scene_id)
		return
	end

	MainCamera.enabled = self.is_scene_visible
	self:UpdateCameraMode()
	
	DownAngleOfCamera = 180 + MainCamera.transform.eulerAngles.y

	local new_scene_type = self.scene_config.scene_type
	self.scene_logic:Enter(self.old_scene_type, new_scene_type)

	for k, v in pairs(self.obj_list) do
		v:OnLoadSceneComplete()
	end

	-- 创建场景特效
	if nil ~= self.scene_config.effects then
		self.effect_loader_list = {}
		for k, v in pairs(self.scene_config.effects) do
			self.effect_loader_list[k] = AllocAsyncLoader(self, "scene_effect" .. k)
			self.effect_loader_list[k]:SetIsUseObjPool(true)
			self.effect_loader_list[k]:SetIsInQueueLoad(true)
			self.effect_loader_list[k]:Load(v.bundle, v.asset, function(prefab)
				if IsNil(prefab) then
					print_error("Scene effects lost!", self.scene_config.name, self.scene_config.id, v.bundle, v.asset)
					return
				end
				
				local moveable_obj = prefab:GetOrAddComponent(typeof(MoveableObject))
				if moveable_obj then
					local wx, wy = GameMapHelper.LogicToWorld(v.x, v.y)
					moveable_obj:SetPosition(Vector3(wx, 0, wy))
					moveable_obj:SetOffset(Vector3(v.offset[1], v.offset[2], v.offset[3]))
				end

				prefab.transform.localEulerAngles = Vector3(v.rotation[1], v.rotation[2], v.rotation[3])
				if v.scale then
					prefab.transform.localScale = Vector3(v.scale[1], v.scale[2], v.scale[3])
				end
			end)
		end
	end

	-- 创建npc和传送门
	self:CreateNpcList()
	-- self:CreatMingRenList()
	self:CreateDoorList()
	self:CreateCityOnwerStatue()
	self:CheckWorshipAct()
	self:CheckGuildYunBiaoAct()
	self:UpdateHeroLight()

	self.is_in_door = true

	self:Fire(SceneEventType.SCENE_LOADING_STATE_QUIT, self.old_scene_type, new_scene_type)
	self:Fire(SceneEventType.SCENE_ALL_LOAD_COMPLETE, self.scene_config.id)

	if nil ~= ClickManager.Instance then
		if nil ~= self.clickHandle and nil ~= ClickManager.Instance then
			ClickManager.Instance:UnlistenClickGround(self.clickHandle)
			self.clickHandle = nil
		end

		local joinstick_region = MainUICtrl.Instance:GetJoystickRegion()
		if nil ~= joinstick_region then
			ClickManager.Instance:SetResearveArea(joinstick_region.rect)
		end

		self.clickHandle = ClickManager.Instance:ListenClickGround(function(hit)
			if self.main_role:GetIsFlying() or MarriageData.Instance:GetOwnIsXunyou() then
				return
			end
			if self.is_click_obj then
				self.is_click_obj = false
				return
			end
			-- 当前场景无法移动
			local logic = Scene.Instance:GetSceneLogic()
			if logic and not logic:CanCancleAutoGuaji() then
				self:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
				TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
				return
			end

			if not FunctionGuide.Instance:GetIsGuide() then
				self:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)
			end

			if (GuajiCache.guaji_type ~= GuajiType.None or MoveCache.is_valid or AtkCache.is_valid)
				and (self.last_click_ground_time == nil or Status.NowTime - self.last_click_ground_time > 5) then
				self.last_click_ground_time = Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.ClickGoundAgainStopAuto)
				return
			end
			self.last_click_ground_time = Status.NowTime
			-- 点击到地面，移动
			self:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)

			TASK_GUILD_AUTO = false
			TASK_RI_AUTO = false
			TASK_HUAN_AUTO = false
			TASK_ZHUANZHI_AUTO = false
			local x, y = GameMapHelper.WorldToLogic(hit.point.x, hit.point.z)
			local is_block = AStarFindWay:IsBlock(x, y)
			if self.main_role and not AtkCache.is_valid and not is_block then
				self.main_role:DoMoveByClick(x, y, 0)
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			end

			local asset = is_block and "Movement_Unwalkable" or "Movement_Walkable"
			local bundle_name, asset_name = ResPath.GetMiscEffect(asset)
			EffectManager.Instance:PlayControlEffect(self, bundle_name, asset_name, Vector3(hit.point.x, hit.point.y + 0.25, hit.point.z))
		end)
	else
		print_log("This scene does not has ClickManager.")
	end
end

function Scene:OnLoadSceneDetailComplete(scene_id)
	--self:Fire(SceneEventType.SCENE_ALL_LOAD_COMPLETE)
end

----------------------------------------------------
-- Get begin
----------------------------------------------------
function Scene:GetMainRole()
	return self.main_role
end

function Scene:GetSceneId()
	return self.scene_config and self.scene_config.id or 0
end

function Scene:GetSceneForbidPk()
	return self.scene_config and self.scene_config.is_forbid_pk and self.scene_config.is_forbid_pk == 1
end

function Scene:GetSceneTownPos()
	return self.scene_config.scenex or 0, self.scene_config.sceney or 0
end

function Scene:GetSceneName()
	return self.scene_config and self.scene_config.name or ""
end

function Scene:GetSceneLogic()
	return self.scene_logic
end

function Scene:GetSceneType()
	return self.scene_config and self.scene_config.scene_type or 0
end

function Scene:GetSceneMosterList()
	return self.scene_config and self.scene_config.monsters or nil
end

function Scene:GetObj(obj_id)
	return self.obj_list[obj_id]
end

function Scene:GetObjInstanceID(instance_id)
	return self.instanceid_list[instance_id]
end

function Scene:GetObjByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		return self.obj_group_list[obj_type][obj_key]
	end
	return nil
end

function Scene:GetNpcByNpcId(npc_id)
	return self:GetObjByTypeAndKey(SceneObjType.Npc, npc_id)
end

function Scene:GetGatherByGatherId(gather_id)
	for k, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id then
			return v
		end
	end

	return nil
end

function Scene:GetGatherByGatherIdAndPosInfo(gather_id, x, y)
	for k, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		local pos_x, pos_y = v:GetLogicPos()
		if v:GetGatherId() == gather_id and pos_x == x and pos_y == y then
			return v
		end
	end
	return nil
end

function Scene:GetObjList()
	return self.obj_list
end

function Scene:GetObjInstanceList()
	return self.instanceid_list
end

local empty_table = {}
function Scene:GetObjListByType(obj_type)
	return self.obj_group_list[obj_type] or empty_table
end

function Scene:GetRoleList()
	return self.obj_group_list[SceneObjType.Role] or empty_table
end

function Scene:GetMingRenList()
	return self.obj_group_list[SceneObjType.MingRen] or empty_table
end

function Scene:GetMonsterList()
	return self.obj_group_list[SceneObjType.Monster] or empty_table
end

function Scene:GetNpcList()
	return self.obj_group_list[SceneObjType.Npc] or empty_table
end

function Scene:GetSpiritList()
	return self.obj_group_list[SceneObjType.SpriteObj] or empty_table
end

function Scene:GetImpGuardList()
	return self.obj_group_list[SceneObjType.ImpGuardObj] or empty_table
end

-- 获取场景进入点坐标
function Scene:GetEntrance(scene_id, to_scene_id)
	local list = ConfigManager.Instance:GetAutoConfig("entrance_auto").entrance_list
	local x, y = nil, nil
	for k,v in pairs(list) do
		if v.scene_id == scene_id and v.to_scene_id == to_scene_id then
			local door_id = v.door_id
			local config = ConfigManager.Instance:GetSceneConfig(to_scene_id)
			if config ~= nil and config.doors ~= nil then
				for i,j in pairs(config.doors) do
					if j.id == door_id then
						x, y = j.x, j.y
						break
					end
				end
			end
			break
		end
	end
	return x, y
end

function Scene:GetRoleByObjId(obj_id)
	local obj = self.obj_list[obj_id]
	if nil ~= obj and obj:IsRole() then
		return obj
	end
	return nil
end

function Scene:GetObjByInstanceId(instance_id)
	local obj_id = self.instanceid_list[instance_id]
	return self:GetRoleByObjId(obj_id)
end

function Scene:GetObjectByObjId(obj_id)
	return self.obj_list[obj_id]
end

function Scene:GetObjByUId(uid)
	for k,v in pairs(self.obj_list) do
		if v.vo.role_id == uid then
			return v
		end
	end
end

function Scene:GetRoleObjByUId(uid)
	for k,v in pairs(self.obj_list) do
		if v:IsRole() and v.vo.role_id == uid then
			return v
		end
	end
end

function Scene:GetObjMoveInfoList()
	return self.obj_move_info_list
end

function Scene:DelMoveObj(obj_id)
	if self.obj_move_info_list[obj_id] then
		self.obj_move_info_list[obj_id]:DeleteMe()
	end
	self.obj_move_info_list[obj_id] = nil
end

function Scene:GetSceneAssetName()
	return self.scene_config.asset_name
end

function Scene:GetMainRoleIsMove()
	return self.is_can_move
end

function Scene:SetMainRoleIsMove(is_can_move)
	self.is_can_move = is_can_move
end

----------------------------------------------------
-- Get end
----------------------------------------------------

----------------------------------------------------
-- Create begin
----------------------------------------------------
function Scene:CreateMainRole()
	if self.main_role then
		for k, v in pairs(self.obj_list) do
			if v:IsMainRole() then
				self.obj_list[k] = nil
				break
			end
		end

		self.main_role:DeleteMe()
		self.main_role = nil
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == vo then
		print_log("Scene:CreateMainRole vo nil")
		return nil
	end

	self.main_role = self:CreateObj(vo, SceneObjType.MainRole)
	self.main_role:CreateShadow()
	self.main_role:RegisterShadowUpdate()
	local settingData = SettingData.Instance
	local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)

	-- 屏蔽自己技能特效
	local shield_self_effect = settingData:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	-- main_part:EnableEffect(not shield_self_effect)
	-- main_part:EnableFootsteps(not shield_self_effect)
	local actor_trigger = self.main_role:GetActorTrigger()
	if actor_trigger then
		actor_trigger:EnableEffect(not shield_self_effect)
		-- actor_trigger:EnableFootsteps(false)

		-- 是否关闭震屏效果
		local close_camera_shake = settingData:GetSettingData(SETTING_TYPE.CLOSE_SHOCK_SCREEN)
		actor_trigger:EnableCameraShake(not close_camera_shake)
	end

	-- 屏蔽女神

	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	self.main_role:SetGoddessVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config and self.scene_config.id == 1110 then
		local follow_ui = self.main_role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end

	RobertManager.Instance:OnMainRoleCreate()

	return self.main_role
end

function Scene:CreateRole(vo)
	local role = self:CreateObj(vo, SceneObjType.Role)

	if role and role:IsRole() then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(vo)
			self:Fire(ObjectEventType.TEAM_HP_CHANGE, vo)
		end
	end
	if role then
		local settingData = SettingData.Instance
		-- local main_part = role.draw_obj:GetPart(SceneObjPart.Main)
		local is_scene_role_shield = SceneData.Instance:IsSceneRoleShield()
		if is_scene_role_shield then
			local follow_ui = role:GetFollowUi()
			follow_ui:IsRoleFollowHide(true)
			follow_ui:UpdateRootNodeVisible()
		else
			role:CreateShadow()
			role:RegisterShadowUpdate()
		end

		-- 屏蔽其他玩家
		local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
		role:SetRoleVisible(not shield_others)
		-- 屏蔽友方玩家
		if not shield_others then
			local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
			if not self:IsEnemy(role) then
				role:SetRoleVisible(not shield_same_camp)
			end
		end

		-- 屏蔽女神
		local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
		role:SetGoddessVisible(not shield_goddess)


		--屏蔽血条(跨服温泉)
		if self.scene_config and self.scene_config.id == 1110 then
			if role then
				local follow_ui = role.draw_obj:GetSceneObj():GetFollowUi()
				follow_ui:SetHpVisiable(false)
			end
		end

		-- 屏蔽他人技能特效
		-- local shield_skill_effect = settingData:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
		-- main_part:EnableEffect(not shield_skill_effect)
		-- main_part:EnableFootsteps(not shield_skill_effect)
		local actor_trigger = role:GetActorTrigger()
		if actor_trigger then
			-- 屏蔽他人技能特效
			local shield_skill_effect = settingData:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
			actor_trigger:EnableEffect(not shield_skill_effect)
			-- actor_trigger:EnableFootsteps(not shield_skill_effect)
		end
	end
	return role
end

function Scene:CreateTestRole(vo)
	local role = self:CreateObj(vo, SceneObjType.TestRole)

	if role and role:IsRole() then
		if ScoietyData.Instance.have_team then
			ScoietyData.Instance:ChangeTeamList(vo)
			self:Fire(ObjectEventType.TEAM_HP_CHANGE, vo)
		end
	end

	local settingData = SettingData.Instance
	local main_part = role.draw_obj:GetPart(SceneObjPart.Main)

	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	role:SetRoleVisible(not shield_others)

	-- 屏蔽友方玩家
	if not shield_others then
		local shield_same_camp = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)
		if not self:IsEnemy(role) then
			role:SetRoleVisible(not shield_same_camp)
		end
	end

	-- 屏蔽女神
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	role:SetGoddessVisible(not shield_goddess)


	--屏蔽血条(跨服温泉)
	if self.scene_config and self.scene_config.id == 1110 then
		local follow_ui = role.draw_obj:GetSceneObj():GetFollowUi()
		follow_ui:SetHpVisiable(false)
	end


	local actor_trigger = role:GetActorTrigger()
	if actor_trigger then
		-- 屏蔽他人技能特效
		local shield_skill_effect = settingData:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
		actor_trigger:EnableEffect(not shield_skill_effect)
		-- main_part:EnableFootsteps(not shield_skill_effect)
	end

	return role
end

function Scene:CreateMonster(vo)
	return self:CreateObj(vo, SceneObjType.Monster)
end

function Scene:CreateDoor(vo)
	self:CreateObj(vo, SceneObjType.Door)
end

function Scene:CreateJumpPoint(vo)
	self:CreateObj(vo, SceneObjType.JumpPoint)
end

function Scene:CreateEffectObj(vo)
	return self:CreateObj(vo, SceneObjType.EffectObj)
end

function Scene:CreateSubstitutesObj(vo)
	return self:CreateObj(vo, SceneObjType.Substitutes)
end

function Scene:CreateFallItem(vo)
	if self.fallitem_vo_list == nil then
		self.fallitem_vo_list = {}
	end
	if self.fall_item_countdown and CountDown.Instance:HasCountDown(self.fall_item_countdown) then
		table.insert(self.fallitem_vo_list, vo)
	else
		local function UpdateCallBack()
			if next(self.fallitem_vo_list) == nil then
				CountDown.Instance:RemoveCountDown(self.fall_item_countdown)
				return
			end
			if self.is_delete_fallitem then
				return
			end
			local vo = table.remove(self.fallitem_vo_list, 1)
			if vo.scene_id ~= nil and vo.scene_id == Scene.Instance:GetSceneId() then
				self:CreateObj(vo, SceneObjType.FallItem)
			end
		end
		local function InspectCallBack()
			if next(self.fallitem_vo_list) ~= nil then
				self.fall_item_countdown = CountDown.Instance:AddCountDown(5, 0.05, UpdateCallBack, InspectCallBack)
			end
		end
		table.insert(self.fallitem_vo_list, vo)
		InspectCallBack()
	end
end

function Scene:DeleteNotCreatedFallObj(obj_id)
	self.is_delete_fallitem = true
	if self.fallitem_vo_list ~= nil then
		for k, vo in ipairs(self.fallitem_vo_list) do
			if vo.obj_id == obj_id then
				table.remove(self.fallitem_vo_list, k)
			end
		end
	end
	self.is_delete_fallitem = false
end

function Scene:CreateZhuaGuiNpc(vo)
	self:CreateObj(vo, SceneObjType.EventObj)
end

function Scene:CreateGatherObj(vo)
	self:CreateObj(vo, SceneObjType.GatherObj)
end

function Scene:CreateMarryObj(vo)
	self:CreateObj(vo, SceneObjType.MarryObj)
end

function Scene:CreateNpc(vo)
	local npc = self:CreateObj(vo, SceneObjType.Npc)
	npc:CreateShadow()
	npc:RegisterShadowUpdate()
	if not CgManager.Instance:IsCgIng() and self.main_role
		and self.main_role.vo.task_appearn == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC
		and self.main_role.vo.task_appearn_param_1 == vo.npc_id then
		npc:GetDrawObj():SetVisible(false)
		if npc.select_effect then
			npc.select_effect:SetActive(false)
		end
		npc:ReloadUIName()
		return
	end
end

function Scene:CreateTruckObj(vo)
	return self:CreateObj(vo, SceneObjType.TruckObj)
end

function Scene:CreateFakeTruckObj(vo)
	return self:CreateObj(vo, SceneObjType.FakeTruckObj)
end

function Scene:CreateSpiritObj(vo)
	return self:CreateObj(vo, SceneObjType.SpriteObj)
end

function Scene:CreatePetObj(vo)
	return self:CreateObj(vo, SceneObjType.PetObj)
end

function Scene:CreateBabyObj(vo)
	return self:CreateObj(vo, SceneObjType.Baby)
end

function Scene:CreateImpGuardObj(vo)
	return self:CreateObj(vo, SceneObjType.ImpGuardObj)
end

function Scene:CreateGoddessObj(vo)
	return self:CreateObj(vo, SceneObjType.GoddessObj)
end

function Scene:CreateLingChongObj(vo)
	return self:CreateObj(vo, SceneObjType.LingChongObj)
end

function Scene:CreateFlyPetObj(vo)
	return self:CreateObj(vo, SceneObjType.FlyPetObj)
end

function Scene:CreateFightMountObj(vo)
	return self:CreateObj(vo, SceneObjType.FightMount)
end

function Scene:CreateTriggerObj(vo)
	return self:CreateObj(vo, SceneObjType.Trigger)
end

function Scene:CreateMingRenObj(vo)
	if math.abs(vo.pos_x - self.main_role_pos_x) <= 60 and math.abs(vo.pos_y - self.main_role_pos_y) <= 60 then
		if nil == self:GetObjByTypeAndKey(SceneObjType.MingRen, vo.role_id) then
			return self:CreateObj(vo, SceneObjType.MingRen)
		end
	else
		self:DeleteObjByTypeAndKey(SceneObjType.MingRen, vo.role_id)
	end
end

function Scene:FlushMingRenList()
	local list = self:GetMingRenList()
	if list and #list ~= 0 then
		for k,v in pairs(list) do
			if v then
				v:FlushAppearance()
			end
		end
	else
		-- self:CreatMingRenList()
	end
end

-- 根据角色创建Truck
function Scene:CreateTruckObjByRole(role)
	local truck_obj = nil
	local role_vo = role:GetVo()
	if role_vo.husong_color > 0 and role_vo.husong_taskid > 0 then
		local truck_vo = GameVoManager.Instance:CreateVo(TruckObjVo)
		truck_vo.pos_x, truck_vo.pos_y = role:GetLogicPos()
		truck_vo.pos_x = truck_vo.pos_x + 2
		truck_vo.truck_color = role_vo.husong_color
		truck_vo.owner_role_id = role_vo.role_id
		truck_vo.owner_obj_id = role_vo.obj_id
		truck_vo.hp = 100
		truck_vo.move_speed = role:GetVo().move_speed
		truck_vo.name = role_vo.name .. Language.Common.BiaoChe

		truck_obj = self:CreateTruckObj(truck_vo)
		-- if nil ~= truck_obj then
		-- 	role:SetTruckObjId(truck_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return truck_obj
end

function Scene:CreateFakeTruckObjByRole(role)
	local role_vo = role:GetVo()
	local truck_vo = GameVoManager.Instance:CreateVo(TruckObjVo)
	truck_vo.pos_x, truck_vo.pos_y = role:GetLogicPos()
	truck_vo.pos_x = truck_vo.pos_x + 2
	truck_vo.truck_color = 1
	truck_vo.owner_role_id = role_vo.role_id
	truck_vo.owner_obj_id = role_vo.obj_id
	truck_vo.hp = 100
	truck_vo.move_speed = role:GetVo().move_speed
	truck_vo.name = role_vo.name .. Language.Common.BiaoChe

	local fake_truck_obj = self:CreateFakeTruckObj(truck_vo)
	return fake_truck_obj
end

-- 根据角色创建Spirit
function Scene:CreateSpiritObjByRole(role)
	local spirit_obj = nil
	local role_vo = role:GetVo()
	if role_vo.used_sprite_id and role_vo.used_sprite_id > 0 then
		local spirit_vo = GameVoManager.Instance:CreateVo(SpriteObjVo)
		spirit_vo.pos_x, spirit_vo.pos_y = role:GetLogicPos()
		spirit_vo.pos_x = spirit_vo.pos_x + 5
		spirit_vo.name = role_vo.name .. Language.Common.Sprite

		spirit_vo.owner_role_id = role_vo.role_id
		spirit_vo.owner_obj_id = role_vo.obj_id
		spirit_vo.used_sprite_id = role_vo.used_sprite_id
		spirit_vo.move_speed = role:GetVo().move_speed
		spirit_vo.spirit_name = role_vo.sprite_name
		-- spirit_vo.show_hp = 100
		if role_vo.appearance then 	-- 服务端说协议顺序没问题，只能先暂时做个判断
			spirit_vo.lingzhu_used_imageid = role_vo.appearance.lingzhu_used_imageid or 0
		end
		spirit_vo.hp = 100
		spirit_obj = self:CreateSpiritObj(spirit_vo)
		-- if nil ~= spirit_obj then
		-- 	role:SetTruckObjId(spirit_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return spirit_obj
end

-- 根据角色创建Pet
function Scene:CreatePetObjByRole(role)
	local pet_obj = nil
	local role_vo = role:GetVo()
	if role_vo.pet_id and role_vo.pet_id > 0 then
		local pet_vo = GameVoManager.Instance:CreateVo(PetObjVo)
		pet_vo.pos_x, pet_vo.pos_y = role:GetLogicPos()
		pet_vo.pos_x = pet_vo.pos_x + 4
		pet_vo.name = role_vo.name .. Language.Common.LittlePet
		pet_vo.owner_role_id = role_vo.role_id
		pet_vo.owner_obj_id = role_vo.obj_id
		pet_vo.pet_id = role_vo.pet_id
		pet_vo.hp = 100
		pet_vo.move_speed = role:GetVo().move_speed
		pet_vo.pet_name = role_vo.pet_name
		pet_vo.owner_is_mainrole = role:IsMainRole()
		pet_obj = self:CreatePetObj(pet_vo)
	end
	return pet_obj
end

-- 根据角色创建宝宝
function Scene:CreateBabyObjByRole(role)
	local pet_obj = nil
	local role_vo = role:GetVo()
	if role_vo.baby_id and role_vo.baby_id > 0 then
		local baby_vo = GameVoManager.Instance:CreateVo(BabyObjVo)
		baby_vo.pos_x, baby_vo.pos_y = role:GetLogicPos()
		baby_vo.pos_x = baby_vo.pos_x + 4
		baby_vo.name = role_vo.name .. Language.Common.Baby
		baby_vo.owner_role_id = role_vo.role_id
		baby_vo.owner_obj_id = role_vo.obj_id
		baby_vo.baby_id = role_vo.baby_id
		baby_vo.hp = 100
		baby_vo.move_speed = role:GetVo().move_speed
		baby_vo.baby_name = role_vo.baby_name
		baby_vo.owner_is_mainrole = role:IsMainRole()
		pet_obj = self:CreateBabyObj(baby_vo)
	end
	return pet_obj
end

-- 根据角色创建小鬼
function Scene:CreateImpGuardObjByRole(role)
	local imp_guard_obj = nil
	local role_vo = role:GetVo()
	if role_vo.imp_guard_id and role_vo.imp_guard_id > 0 then
		local imp_guard_vo = GameVoManager.Instance:CreateVo(ImpGuardObjVo)
		local imp_guard_cfg = EquipData.IsXiaoguiEqType(role_vo.imp_guard_id)
		imp_guard_vo.pos_x, imp_guard_vo.pos_y = role:GetLogicPos()
		imp_guard_vo.pos_x = imp_guard_vo.pos_x + 5
		imp_guard_vo.name = role_vo.name .. Language.Player.ImpProtect

		imp_guard_vo.owner_role_id = role_vo.role_id
		imp_guard_vo.owner_obj_id = role_vo.obj_id
		imp_guard_vo.imp_guard_id = role_vo.imp_guard_id
		imp_guard_vo.move_speed = role:GetVo().move_speed
		-- imp_guard_vo.spirit_name = role_vo.sprite_name
		-- imp_guard_vo.show_hp = 100
		imp_guard_vo.hp = 100
		imp_guard_obj = self:CreateImpGuardObj(imp_guard_vo)
		-- if nil ~= imp_guard_obj then
		-- 	role:SetTruckObjId(imp_guard_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return imp_guard_obj
end

function Scene:CreateGoddessObjByRole(role)
	local goddess_obj = nil
	local role_vo = role:GetVo()
	local goddess_vo = GameVoManager.Instance:CreateVo(GoddessObjVo)
	goddess_vo.pos_x, goddess_vo.pos_y = role:GetLogicPos()
	goddess_vo.pos_x = goddess_vo.pos_x + 2
	goddess_vo.owner_role_id = role_vo.role_id
	goddess_vo.owner_obj_id = role_vo.obj_id
	goddess_vo.hp = 100
	goddess_vo.move_speed = role_vo.move_speed
	goddess_vo.use_xiannv_id = role_vo.use_xiannv_id
	goddess_vo.goddess_wing_id = role_vo.appearance.shenyi_used_imageid
	goddess_vo.goddess_shen_gong_id = role_vo.appearance.shengong_used_imageid
	goddess_vo.xiannv_huanhua_id = role_vo.xiannv_huanhua_id
	goddess_vo.owner_role = role
	goddess_vo.name = role_vo.name .. Language.Advance.OwnGoddess
	goddess_obj = self:CreateGoddessObj(goddess_vo)
	return goddess_obj
end

--创建灵宠
function Scene:CreateLingChongObjByRole(role)
	local role_vo = role:GetVo()
	local vo = GameVoManager.Instance:CreateVo(LingChongObjVo)
	vo.pos_x, vo.pos_y = role:GetLogicPos()
	vo.hp = 100
	vo.owner_role_id = role_vo.role_id
	vo.owner_obj_id = role_vo.obj_id
	vo.owner_is_mainrole = role:IsMainRole()
	vo.move_speed = role_vo.move_speed
	vo.lingchong_used_imageid = role_vo.lingchong_used_imageid or 0
	vo.linggong_used_imageid = role_vo.linggong_used_imageid or 0
	vo.lingqi_used_imageid = role_vo.lingqi_used_imageid or 0
	vo.name = role_vo.name .. Language.Advance.OwnLingTong
	local lingchong_obj = self:CreateLingChongObj(vo)
	return lingchong_obj
end

--创建飞宠
function Scene:CreateFlyPetObjByRole(role)
	if not role then return end
	
	local role_vo = role:GetVo()
	local vo = GameVoManager.Instance:CreateVo(FlyPetObjVo)
	vo.pos_x, vo.pos_y = role:GetLogicPos()
	vo.owner_role_id = role_vo.role_id
	vo.owner_obj_id = role_vo.obj_id
	vo.owner_is_mainrole = role:IsMainRole()
	vo.move_speed = role_vo.move_speed
	vo.flypet_used_imageid = role_vo.appearance.flypet_used_imageid or 0
	vo.owner_role = role
	vo.name = role_vo.name .. Language.Advance.OwnFlyPet
	local flypet_obj = self:CreateFlyPetObj(vo)
	return flypet_obj
end

function Scene:CreateSubstitutesObjByCharacter(character)
	local substitutes_obj = nil
	local character_vo = character:GetVo()
	local substitutes_vo = GameVoManager.Instance:CreateVo(MonsterVo)
	substitutes_vo.pos_x, substitutes_vo.pos_y = character:GetLogicPos()
	substitutes_vo.pos_x = substitutes_vo.pos_x + 2
	substitutes_vo.owner_obj_id = character_vo.obj_id
	substitutes_vo.hp = 100
	substitutes_vo.move_speed = character_vo.move_speed
	substitutes_vo.name = character_vo.name .. Language.Common.Shadow

	substitutes_obj = self:CreateSubstitutesObj(substitutes_vo)
	return substitutes_obj
end

function Scene:CreateFightMountObjByRole(role)
	local fight_mount_obj = nil
	local role_vo = role:GetVo()
	if role_vo.fight_mount_appeid and role_vo.fight_mount_appeid > 0 then
		local fight_mount_vo = GameVoManager.Instance:CreateVo(MultiMountObjVo)
		fight_mount_vo.pos_x, fight_mount_vo.pos_y = role:GetLogicPos()
		fight_mount_vo.mount_id = role_vo.fight_mount_appeid
		fight_mount_vo.mount_res_id = role_vo.fight_mount_appeid
		fight_mount_vo.fight_mount_appeid = role_vo.fight_mount_appeid
		fight_mount_vo.name = role_vo.name .. Language.JinJieReward.SystemName[JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT]
		fight_mount_vo.hp = 100
		fight_mount_vo.owner_role_id = role_vo.role_id
		fight_mount_vo.owner_obj_id = role_vo.obj_id
		fight_mount_vo.move_speed = role:GetVo().move_speed
		fight_mount_obj = self:CreateFightMountObj(fight_mount_vo)
		-- if nil ~= fight_mount_obj then
		-- 	role:SetTruckObjId(fight_mount_obj:GetObjId())
		-- end
		--role:SetSpecialIcon("hs_" .. role_vo.husong_color)
		--if role:IsMainRole() then
		--	YunbiaoCtrl.Instance:IconHandler(1)
		--end
	end
	return fight_mount_obj
end

function Scene:SetIsCgHideNpc(bool)
	self.is_cg_hide_npc = bool
end
-- 创建NPC列表
function Scene:CreateNpcList()
	if nil ~= self.scene_config.npcs then
		for k, v in pairs(self.scene_config.npcs) do
			local is_create_walk_npc = false
			if v.is_walking == 1 then
				for _, path_pos in pairs(v.paths) do
					if math.abs(path_pos.x - self.main_role_pos_x) <= 45 and math.abs(path_pos.y - self.main_role_pos_y) <= 45 then
						is_create_walk_npc = true
						break
					end
				end
			end
			if math.abs(v.x - self.main_role_pos_x) <= 45 and math.abs(v.y - self.main_role_pos_y) <= 45 or is_create_walk_npc then
				if nil == self:GetObjByTypeAndKey(SceneObjType.Npc, v.id) then
					if TaskData.Instance and TaskData.Instance:GetIsShowMountTaskNpc(self:GetSceneId(), v.id) then
						break
					end
					local vo = GameVoManager.Instance:CreateVo(NpcVo)
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.npc_id = v.id
					vo.rotation_y = v.rotation_y
					vo.is_walking = v.is_walking or 0
					vo.paths = v.paths or {}
					self:CreateNpc(vo)
					-- 屏弊npc只是不显示，仍然创建，避免影响新手任务
					if (CgManager.Instance:IsCgIng() and self.is_cg_hide_npc) or nil ~= self.shield_npc_id_list[v.id] then
						self:ShieldNpc(v.id)
					end
				end
			else
				self:DeleteObjByTypeAndKey(SceneObjType.Npc, v.id)
			end
		end
	end
end

-- 创建传送门列表
function Scene:CreateDoorList()
	if nil ~= self.scene_config.doors then
		for k, v in pairs(self.scene_config.doors) do
			if v.type ~= SceneDoorType.INVISIBLE then
				if SceneType.GongChengZhan == Scene.Instance:GetSceneType() then
					if CityCombatData.Instance:GetIsPoQiang() == 1 or (not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENGZHAN)) then
						self:DeleteObjByTypeAndKey(SceneObjType.Door, v.id)
						return
					end
				end
				if math.abs(v.x - self.main_role_pos_x) <= 45 and math.abs(v.y - self.main_role_pos_y) <= 45 then
					if nil == self:GetObjByTypeAndKey(SceneObjType.Door, v.id) then
						local vo = GameVoManager.Instance:CreateVo(DoorVo)
						vo.name = "door" .. v.id
						vo.pos_x = v.x
						vo.pos_y = v.y
						vo.door_id = v.id
						vo.offset = v.offset
						vo.rotation = v.rotation
						vo.scale = v.scale

						--攻城战单独处理传送阵名字
						if v.target_scene_id == 1002 then
							vo.target_name = CityCombatData.Instance:GetDorrName()
						else
							local target_config = ConfigManager.Instance:GetSceneConfig(v.target_scene_id)
							if target_config ~= nil then
								vo.target_name = target_config.name
							end
						end
						-- 品质副本和装备副本(须臾幻境)中打完boss再显示传送阵
						if Scene.Instance:GetSceneType() == SceneType.ChallengeFB then
							local quality_fb_info = FuBenData.Instance:GetPassLayerInfo()
							if (next(quality_fb_info) and quality_fb_info.is_pass ~= 0) then
								self:CreateDoor(vo)
							end
						elseif SceneType.TeamSpecialFB == Scene.Instance:GetSceneType() then
							if not self:IsNeedDelayCreateDoor() then
								self:CreateDoor(vo)
							end
						else
							self:CreateDoor(vo)
						end
					end
				else
					self:DeleteObjByTypeAndKey(SceneObjType.Door, v.id)
				end
			end
		end
	end
end

-- 创建跳跃点列表
function Scene:CreateJumpPointList()
	if nil ~= self.scene_config.jumppoints then
		local jumppoints = {}
		for k, v in pairs(self.scene_config.jumppoints) do
			if math.abs(v.x - self.main_role_pos_x) <= 160 and math.abs(v.y - self.main_role_pos_y) <= 160 then
				if nil == self:GetObjByTypeAndKey(SceneObjType.JumpPoint, v.id) then
					local vo = GameVoManager.Instance:CreateVo(JumpPointVo)
					vo.name = "jumppoint" .. v.id
					vo.pos_x = v.x
					vo.pos_y = v.y
					vo.range = v.range
					vo.id = v.id
					vo.target_id = v.target_id
					vo.jump_type = v.jump_type
					vo.air_craft_id = v.air_craft_id
					vo.is_show = v.is_show
					vo.jump_speed = v.jump_speed
					vo.jump_act = v.jump_act
					vo.jump_tong_bu = v.jump_tong_bu
					vo.jump_time = v.jump_time
					vo.camera_fov = v.camera_fov
					vo.camera_rotation = v.camera_rotation
					vo.play_cg = v.play_cg or 0
					vo.cgs = v.cgs or {}
					jumppoints[v.id] = vo
					self:CreateJumpPoint(vo)
				end
			else
				self:DeleteObjByTypeAndKey(SceneObjType.JumpPoint, v.id)
			end
		end

		-- 链接所有跳跃点
		for k,v in pairs(jumppoints) do
			v.target_vo = jumppoints[v.target_id]
		end
	end
end

-- 创建城主雕像列表
function Scene:CreateCityOnwerStatue()
	local pos_x, pos_y = CityCombatData.Instance:GetWorshipStatuePosParam()
	local worship_scene_id = CityCombatData.Instance:GetWorshipScenIdAndPosXYAndRang()
	local cur_scene_id = self:GetSceneId()
	if pos_x < 0 or pos_y < 0 or worship_scene_id < 0 then
		return
	end

	local cond_1 = math.abs(pos_x - self.main_role_pos_x) <= 50
	local cond_2 = math.abs(pos_y - self.main_role_pos_y) <= 50
	if cond_1 and cond_2 and worship_scene_id == cur_scene_id then
		if nil == self.city_statue then
			local vo = GameVoManager.Instance:CreateVo(CityOwnerStatueVo)
			vo.pos_x = pos_x
			vo.pos_y = pos_y
			self.city_statue = self:CreateObj(vo, SceneObjType.CityOwnerStatue)
		end
	else
		if nil ~= self.city_statue then
			self:DeleteObjsByType(SceneObjType.CityOwnerStatue)
			self.city_statue = nil
		end
	end
end

function Scene:CheckWorshipAct()
	local is_show_mobai = CityCombatCtrl.Instance:CheckShowMoBaiSkillIcon()
	CityCombatCtrl.Instance:ShowMoBaiSkillIcon(is_show_mobai)
end

function Scene:CheckGuildYunBiaoAct()
	local is_guild_yunbiao = GuildCtrl.Instance:CheckGuildYunBiaoState()
	GuildCtrl.Instance:SetGuildYunbiaoSkillState(is_guild_yunbiao)
end

function Scene:GetCityStatue()
	return self.city_statue
end

-- 创建温泉皮艇
function Scene:CreateBoatByCouple(boy_obj_id, girl_obj_id, boy_obj, action_type, delete_time)
	local boy_boat_obj_id = self.boat_list[boy_obj_id]
	local girl_boat_obj_id = self.boat_list[girl_obj_id]

	self:DeleteBoatByRole(boy_obj_id)
	self:DeleteBoatByRole(girl_obj_id)
	local vo = GameVoManager.Instance:CreateVo(BoatObjVo)
	vo.boy_obj_id = boy_obj_id
	vo.girl_obj_id = girl_obj_id
	if nil ~= boy_obj then
		vo.pos_x, vo.pos_y = boy_obj:GetLogicPos()
	end
	vo.action_type = action_type
	local boat_obj = self:CreateObj(vo, SceneObjType.BoatObj)
	self.boat_list[boy_obj_id] = boat_obj:GetObjId()
	self.boat_list[girl_obj_id] = boat_obj:GetObjId()

	local quest1 = self.boat_delay_list[boy_obj_id]
	if nil ~= quest1 then
		GlobalTimerQuest:CancelQuest(quest1)
		self.boat_delay_list[boy_obj_id] = nil
	end
	local quest2 = self.boat_delay_list[girl_obj_id]
	if nil ~= quest2 then
		GlobalTimerQuest:CancelQuest(quest2)
		self.boat_delay_list[girl_obj_id] = nil
	end

	if delete_time then
		local delay_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:DeleteBoatByRole(boy_obj_id)
			self:DeleteBoatByRole(girl_obj_id)
		end, delete_time)
		self.boat_delay_list[boy_obj_id] = delay_timer_quest
		self.boat_delay_list[girl_obj_id] = delay_timer_quest
	end
end

-- 删除温泉皮艇
function Scene:DeleteBoatByRole(role_obj_id)
	local boat_obj_id = self.boat_list[role_obj_id]
	if nil ~= boat_obj_id then
		local boat_obj = self:GetObjectByObjId(boat_obj_id)
		if nil ~= boat_obj then
			local boy_obj_id = boat_obj.vo.boy_obj_id
			local girl_obj_id = boat_obj.vo.girl_obj_id
			if nil ~= boy_obj_id then
				self.boat_list[boy_obj_id] = nil
			end
			if nil ~= girl_obj_id then
				self.boat_list[girl_obj_id] = nil
			end
		end
		self:DeleteObj(boat_obj_id, 0)
	end
end

function Scene:CreateCoupleHaloObj(target_1_role_id, target_2_role_id, halo_type)
	local target_1_halo_obj = self.couple_halo_obj_list[target_1_role_id]
	local target_2_halo_obj = self.couple_halo_obj_list[target_2_role_id]
	if target_1_halo_obj ~= nil or target_2_halo_obj ~= nil then
		return
	end
	local vo = GameVoManager.Instance:CreateVo(CoupleHaloObjVo)
	vo.target_1_role_id = target_1_role_id
	vo.target_2_role_id = target_2_role_id
	vo.halo_type = halo_type
	local couple_halo_obj = self:CreateObj(vo, SceneObjType.CoupleHaloObj)
	self.couple_halo_obj_list[target_1_role_id] = couple_halo_obj
	self.couple_halo_obj_list[target_2_role_id] = couple_halo_obj
end

function Scene:DeleteCoupleHaloObj(role_obj_id)
	local couple_halo_obj = self.couple_halo_obj_list[role_obj_id]
	if couple_halo_obj then
		local vo = couple_halo_obj:GetVo()
		local target_1_role_id = vo.target_1_role_id
		local target_2_role_id = vo.target_2_role_id

		local couple_halo_obj_id = couple_halo_obj:GetObjId()
		self:DeleteObj(couple_halo_obj_id, 0)

		self.couple_halo_obj_list[target_1_role_id] = nil
		self.couple_halo_obj_list[target_2_role_id] = nil
	end
end

function Scene:GetBoatByRole(role_obj_id)
	local boat_obj_id = self.boat_list[role_obj_id]
	if nil ~= boat_obj_id then
		return self:GetObjectByObjId(boat_obj_id)
	end
end

local client_obj_id_inc = 0x10000
function Scene:CreateObj(vo, obj_type)

	if vo.obj_id < 0 then
		client_obj_id_inc = client_obj_id_inc + 1
		vo.obj_id = client_obj_id_inc
	end

	if self.obj_list[vo.obj_id] then
		return nil
	end

	if self.obj_move_info_list[vo.obj_id] then
		self.obj_move_info_list[vo.obj_id]:OnScene(true)
	end

	local obj = nil
	if obj_type == SceneObjType.Role then
		obj = Role.New(vo)
		obj:SetFollowLocalPosition(0)
	elseif obj_type == SceneObjType.MainRole then
		obj = MainRole.New(vo)
		obj:SetFollowLocalPosition(0)
	elseif obj_type == SceneObjType.Monster then
		local monster_id = vo.monster_id
		if ClashTerritoryData.Instance:IsTowerId(monster_id) or FuBenData.Instance:GetIsDefenseTower(monster_id) then
			obj = Tower.New(vo)
		else
			obj = Monster.New(vo)
		end
		local scene_id = Scene.Instance:GetSceneId()
		local can_shield = true
		for k,v in pairs(GameEnum.NOT_SHIELD_ENEMY_SCENE_ID) do
			if v == scene_id then
				can_shield = false
			end
		end
		if can_shield then
			local settingData = SettingData.Instance
			local is_shield = settingData:GetSettingData(SETTING_TYPE.SHIELD_ENEMY)
			if self.scene_logic:CanShieldMonster() and (nil == obj.IsBoss or not obj:IsBoss()) then
				obj.draw_obj:SetVisible(not is_shield)
				obj.draw_obj:SetObjType(SceneObjType.Monster)
				local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
				if is_shield then
					follow_ui:SetHpBarLocalPosition(0, 80, 0)
				else
					follow_ui:SetHpBarLocalPosition(0, -5, 0)
				end
			end
		end
		if not self.scene_logic:CanShieldMonster() and (nil == obj.IsBoss or not obj:IsBoss())then	--加一个判断(不能屏蔽怪物的场景怪物的血条会和名字重叠)
			local follow_ui = obj.draw_obj:GetSceneObj():GetFollowUi()
			follow_ui:SetHpBarLocalPosition(0, -5, 0)
		end
	elseif obj_type == SceneObjType.Door then
		obj = Door.New(vo)
	elseif obj_type == SceneObjType.JumpPoint then
		obj = JumpPoint.New(vo)
	elseif obj_type == SceneObjType.EffectObj then
		obj = EffectObj.New(vo)
	elseif obj_type == SceneObjType.FallItem then
		obj = FallItem.New(vo)
	elseif obj_type == SceneObjType.GatherObj then
		obj = GatherObj.New(vo)
	elseif obj_type == SceneObjType.MarryObj then
		obj = MarryObj.New(vo)
	elseif obj_type == SceneObjType.TruckObj or obj_type == SceneObjType.FakeTruckObj then
		obj = TruckObj.New(vo)
	elseif obj_type == SceneObjType.Npc then
		if vo.is_walking and vo.is_walking == 1 then
			obj = WalkNpc.New(vo)
		else
			obj = Npc.New(vo)
		end
	elseif obj_type == SceneObjType.SpriteObj then
		obj = SpiritObj.New(vo)
	elseif obj_type == SceneObjType.PetObj then
		obj = PetObj.New(vo)
	elseif obj_type == SceneObjType.Baby then
		obj = Baby.New(vo)
	elseif obj_type == SceneObjType.GoddessObj then
		obj = Goddess.New(vo)
	elseif obj_type == SceneObjType.EventObj then
		obj = EventObj.New(vo)
	elseif obj_type == SceneObjType.FightMount then
		obj = FightMountObj.New(vo)
	elseif obj_type == SceneObjType.Substitutes then
		obj = Substitutes.New(vo)
	elseif obj_type == SceneObjType.Trigger then
		obj = TriggerObj.New(vo)
	elseif obj_type == SceneObjType.MingRen then
		obj = MingRenRole.New(vo)
	elseif obj_type == SceneObjType.BoatObj then
		obj = BoatObj.New(vo)
	elseif obj_type == SceneObjType.CoupleHaloObj then
		obj = CoupleHaloObj.New(vo)
	elseif obj_type == SceneObjType.CityOwnerStatue then
		obj = CityOwnerStatue.New(vo)
	elseif obj_type == SceneObjType.CityOwnerObj then
		obj = CityOwnerObj.New(vo)
	elseif obj_type == SceneObjType.TestRole then
		obj = TestRole.New(vo)
		obj:SetFollowLocalPosition(0)
	elseif obj_type == SceneObjType.DefenseObj then
		obj = DefenseObj.New(vo)
	elseif obj_type == SceneObjType.ImpGuardObj then
		-- obj = ImpGuardObj.New(vo)
	elseif obj_type == SceneObjType.LingChongObj then
		obj = LingChongObj.New(vo)
	elseif obj_type == SceneObjType.FlyPetObj then
		obj = FlyPetObj.New(vo)
	end
	obj.draw_obj:SetObjType(obj_type)
	obj:Init(self)
	self.obj_list[vo.obj_id] = obj

	self.instanceid_list[obj.draw_obj:GetTransfrom():GetInstanceID()] = vo.obj_id

	if obj:GetObjKey() then
		if nil == self.obj_group_list[obj_type] then
			self.obj_group_list[obj_type] = {}
		end
		self.obj_group_list[obj_type][obj:GetObjKey()] = obj
	end

	if obj:IsJumpPoint() then
		obj:UpdateJumppointRotate()
	end

	self:Fire(ObjectEventType.OBJ_CREATE, obj)

	return obj
end
----------------------------------------------------
-- Create end
----------------------------------------------------

----------------------------------------------------
-- Delete begin
----------------------------------------------------
function Scene:DeleteObjByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		local obj = self.obj_group_list[obj_type][obj_key]
		if nil ~= obj then
			self:DeleteObj(obj:GetObjId(), 0)
		end
	end
end

function Scene:DeleteObjsByType(obj_type)
	if nil ~= self.obj_group_list[obj_type] then
		local t = self.obj_group_list[obj_type]
		if nil ~= t then
			for _, v in pairs(t) do
				self:DeleteObj(v:GetObjId(), 0)
			end
		end
	end
end

function Scene:DeleteObj(obj_id, delay_time)
	delay_time = delay_time or 0
	if self.is_in_update then
		if self.obj_list[obj_id] then
			-- update过程延迟删除
			table.insert(self.delay_handle_funcs, BindTool.Bind(self.DelObjHelper, self, obj_id, delay_time))
		end
	else
		self:DelObjHelper(obj_id, delay_time)
	end
end

function Scene:DelObjHelper(obj_id, delay_time)
	local del_obj = self.obj_list[obj_id]
	if del_obj == nil or del_obj == self.main_role then
		return
	end

	self.obj_list[obj_id] = nil
	for k,v in pairs(self.instanceid_list) do
		if obj_id == v then
			self.instanceid_list[k] = nil
		end
	end
	
	if del_obj:GetObjKey() ~= nil and self.obj_group_list[del_obj:GetType()] ~= nil then
		self.obj_group_list[del_obj:GetType()][del_obj:GetObjKey()] = nil
	end

	self:Fire(ObjectEventType.OBJ_DELETE, del_obj)

	if delay_time > 0 then
		GlobalTimerQuest:AddDelayTimer(function()
			del_obj:DeleteMe()
		end, delay_time)
	else
		del_obj:DeleteMe()
	end

	-- if self.obj_move_info_list[obj_id] ~= nil and del_obj:GetObjKey() ~= nil then
	-- 	print_log("self.obj_move_info_list DelObjHelper :", obj_id)
	-- 	self.obj_move_info_list[obj_id] = nil
	-- end
end

----------------------------------------------------
-- Delete end
----------------------------------------------------

-- 是否友方
function Scene:IsFriend(target_obj)
	return self.scene_logic:IsFriend(target_obj, self.main_role)
end

-- 是否敌方
function Scene:IsEnemy(target_obj, ignore_table)
	return self.scene_logic:IsEnemy(target_obj, self.main_role, ignore_table)
end

-- 选取最近的对象
function Scene:SelectObjHelper(obj_type, x, y, distance_limit, select_type, ignore_table)
	local obj_list = self:GetObjListByType(obj_type)
	local target_obj = nil
	local target_distance = distance_limit
	local target_x, target_y, distance = 0, 0, 0
	local can_select = true
	local target_obj_reserved = nil
	local target_distance_reserved = distance_limit
	local scene_type = Scene.Instance:GetSceneType()

	for _, v in pairs(obj_list) do
		if v:IsCharacter() then
			can_select = true
			if SelectType.Friend == select_type and not v:IsMainRole() then
				can_select = self.scene_logic:IsFriend(v, self.main_role)
			elseif SelectType.Enemy == select_type then
				can_select = self.scene_logic:IsEnemy(v, self.main_role, ignore_table)
			end

			target_x, target_y = v:GetLogicPos()
			if scene_type == SceneType.QunXianLuanDou then
				--处理仙魔战场挂机需求
				if ElementBattleData.Instance:CheckIsEnemyInTowerRange(target_x, target_y) and (GuajiCache.guaji_type == GuajiType.Auto or GuajiCache.guaji_type == GuajiType.HalfAuto) then
					can_select = false
				end
			end

			if can_select then
				distance = GameMath.GetDistance(x, y, target_x, target_y, false)
				-- 优先寻找非障碍区的
				if not AStarFindWay:IsBlock(target_x, target_y) then
					if distance < target_distance then
						target_obj = v
						target_distance = distance
					end
				else
					if distance < target_distance_reserved then
						target_obj_reserved = v
						target_distance_reserved = distance
					end
				end
			end
		end
	end

	if nil == target_obj then
		return target_obj_reserved, target_distance_reserved
	end
	return target_obj, target_distance
end

--选择指定id的最近的怪物
function Scene:SelectMinDisMonster(monster_id, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetMonsterList()) do
		if v:GetMonsterId() == monster_id and not v:IsRealDead() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					target_obj = target_obj or v
				else
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj
end

function Scene:GetGatherObj(target_distance, target_x, target_y, distance)
	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					return target_obj or v, target_distance, target_x, target_y
				else
					return v, distance, target_x, target_y
				end
			end
		end
	end
end

--选择指定id的最近的采集物
function Scene:SelectMinDisGather(gather_id, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					target_obj = target_obj or v
				else
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj
end

--获取指定id的最近的采集物的距离
function Scene:GetMinDisGather(gather_id, distance_limit)
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local target_x, target_y, distance = 0, 0, 0
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetObjListByType(SceneObjType.GatherObj)) do
		if v:GetGatherId() == gather_id and not v:IsDeleted() then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if not v:IsInBlock() then
					target_distance = distance
				end
			end
		end
	end
	return target_distance
end

-- --选择指定id的最近的采集物(返回x,y) 若没找到视野内的目标,返回视野外的目标点
-- function Scene:SelectMinDisGather(gather_id, distance_limit)
-- 	local target_obj = nil
-- 	local target_distance = distance_limit or 50
-- 	target_distance = target_distance * target_distance
-- 	local target_x, target_y, distance = 0, 0, 0
-- 	local main_role_x, main_role_y = self.main_role:GetLogicPos()
-- 	target_obj, distance, target_x, target_y = self:GetGatherObj(target_distance, target_x, target_y, distance, gather_id)
-- 	if target_obj == nil then
-- 		for k,v in pairs(self.obj_move_info_list) do
-- 			if gather_id == v.obj_id then
-- 				return  v.pos_x, v.pos_y
-- 			end
-- 		end
-- 	end

-- 	return target_x, target_y
-- end

-- 拾取所有物品
local others_item_tips_time = 0
local bag_full_tips_time = 0
function Scene:PickAllFallItem()
	if self.main_role and self.main_role:IsRealDead() then
		return
	end

	local fall_item_list = self:GetObjListByType(SceneObjType.FallItem)
	if not next(fall_item_list) then
		return
	end
	-- local auto_pick_item = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY)
	local auto_pick_item = EquipData.Instance:GetImpGuardActiveInfo()
	local empty_num = ItemData.Instance:GetEmptyNum()

	local item_objid_list = {}
	local auto_pick_color = 0

	local pick_item_num = 0
	local has_others_item = false
	for k, v in pairs(fall_item_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.vo.item_id)
		if not v:IsPicked() and v:IsDropDone() then
			local dis = v:GetAutoPickupMaxDis()
			if dis > 0 then
				-- 红包、绑定元宝之类的
					dis = dis * dis
					local x, y = self.main_role:GetLogicPos()
					if GameMath.GetDistance(x, y, v:GetVo().pos_x, v:GetVo().pos_y, false) < dis then
						if v:GetVo().owner_role_id <= 0 or v:GetVo().owner_role_id == self.main_role:GetRoleId() then
							pick_item_num = pick_item_num + 1
							v:RecordIsPicked()
							table.insert(item_objid_list, v:GetObjId())
						else
							if v.others_tips_time == nil or v.others_tips_time < Status.NowTime then
								v.others_tips_time = Status.NowTime + 10
								has_others_item = true
							end
						end
					end
			elseif (v:GetVo().owner_role_id <= 0 or v:GetVo().owner_role_id == self.main_role:GetRoleId()) and
				Status.NowTime >= v:GetVo().create_time + 1 and
				((auto_pick_item and item_cfg and item_cfg.color > auto_pick_color) or v:GetVo().is_buff_falling == 1) then
				-- 自己的物品

				v:RecordIsPicked()
				table.insert(item_objid_list, v:GetObjId())
				if not v:IsCoin() then
					pick_item_num = pick_item_num + 1
				end
			end

			if empty_num <= pick_item_num then
				break
			end
		end
	end

	if 0 == empty_num and #item_objid_list > 0 then
		if bag_full_tips_time < Status.NowTime and (auto_pick_item or GoldMemberData.Instance:GetVIPSurplusTime() <= 0) then
			bag_full_tips_time = Status.NowTime + 2
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.BagFull)
		end
		return
	end


	local scene_id = Scene.Instance:GetSceneId()
	if not (BossData.Instance:IsCrossBossScene(scene_id) or BossData.Instance:IsShenYuBossScene(scene_id)) then
		if has_others_item and others_item_tips_time < Status.NowTime and #item_objid_list == 0 then
			others_item_tips_time = Status.NowTime + 1
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotMyItem)
		end
	end


	if next(item_objid_list) then
		Scene.ScenePickItem(item_objid_list)
	end
end

-- 寻找跳跃点
function Scene:FindJumpPoint(x, y)
	local temp_table = {}
	for k,v in pairs(self:GetObjListByType(SceneObjType.JumpPoint)) do
		if v.vo.target_id ~= 0 and v.vo.range > 0 then
			local vx, vy = v:GetLogicPos()
			local point_distance = GameMath.GetDistance(x, y, vx, vy, false)
			if point_distance <= v.vo.range then
				table.insert(temp_table, v)
			end
		end
	end
	return temp_table
end

-- 跳跃到目的地
function Scene:JumpTo(vo, to_point)
	local target_point = self:GetObjByTypeAndKey(SceneObjType.JumpPoint, to_point.vo.target_id)
	self.main_role:JumpTo(vo, to_point, target_point, function()
		if to_point.vo.target_id and to_point.vo.target_id > -1 then
			if target_point then
				-- 延迟到下一帧执行
				CountDown.Instance:AddCountDown(0.01, 0.01, function()
					self:JumpTo(to_point.vo, target_point)
				end)
				return
			end
		end

		-- 只需要在最后一个跳跃点完成时同步位置
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		Scene.SendSyncJump(self:GetSceneId(), to_point.vo.pos_x, to_point.vo.pos_y, scene_key)
		-- if self:GetSceneType() == SceneType.Common and not GuajiCtrl.Instance:IsSpecialCommonScene() then
		-- 	TaskCtrl.Instance:SendFlyByShoe(self:GetSceneId(), to_point.vo.pos_x, to_point.vo.pos_y, scene_key, true)
		-- end
		Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
		self.main_role:SetJump(false)
		self.main_role.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		self:Fire(OtherEventType.JUMP_STATE_CHANGE, false)

		if self.main_role.fight_mount_res_id ~= nil and self.main_role.fight_mount_res_id > 0 then
			self.main_role:ChangeModel(SceneObjPart.FightMount, ResPath.GetFightMountModel(self.main_role.fight_mount_res_id))
		elseif self.main_role.mount_res_id ~= nil and self.main_role.mount_res_id > 0 and not self.main_role:IsMultiMountPartner() then
			if self.main_role.is_sit_mount == 1 then
				self.main_role:ChangeModel(SceneObjPart.FightMount, ResPath.GetMountModel(self.main_role.mount_res_id))
			else
				self.main_role:ChangeModel(SceneObjPart.Mount, ResPath.GetMountModel(self.main_role.mount_res_id))
			end
		end
	end)
end

function Scene:CheckJump()
	if self.main_role:IsJump() or self.main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return false
	end

	if self.main_role:IsQingGong() then
		return false
	end

	local x, y = self.main_role:GetLogicPos()

	local jumppoint_obj_list = self:FindJumpPoint(x, y)
	if #jumppoint_obj_list < 1 then
		return false
	end

	if jumppoint_obj_list[1].vo.id == self.main_role.jumping_id then
		return false
	end

	local target_point = self:GetObjByTypeAndKey(SceneObjType.JumpPoint, jumppoint_obj_list[1].vo.target_id)
	if not target_point then
		return false
	end

	if self.main_role.vo.husong_taskid > 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.CanNotJump)
		return false
	end

	--是双骑跟随者不做跳跃
	if self.main_role:IsMultiMountPartner() then
		return false
	end

	self:JumpTo(jumppoint_obj_list[1].vo, target_point)

	return true
end

function Scene:CheckClientObj()
	if nil == self.scene_config then
		return
	end

	self:CreateNpcList()
	self:CreateDoorList()
	self:CreateJumpPointList()
	-- self:CreatMingRenList()
	self:CreateCityOnwerStatue()
	self:CheckWorshipAct()
	self:CheckGuildYunBiaoAct()
	
	-- 是否传送
	local door_obj = nil
	for k, v in pairs(self:GetObjListByType(SceneObjType.Door)) do
		local door_x, door_y = v:GetLogicPos()
		if GameMath.GetDistance(self.main_role_pos_x, self.main_role_pos_y, door_x, door_y, false) < 4 * 4 then
			door_obj = v
			break
		end
	end

	if nil ~= door_obj and false == self.is_in_door and not self.main_role:IsQingGong() then
		self.is_in_door = true
		self.main_role:ChangeToCommonState()

		-- 离开副本
		if door_obj:GetDoorType() == SceneDoorType.FUBEN then
			FuBenCtrl.Instance:SendLeaveFB()
		else
			self.SendTransportReq(door_obj:GetDoorId())
		end
	else
		self.is_in_door = (nil ~= door_obj)
	end
end

function Scene:GetCurFbSceneCfg()
	local fb_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
	return fb_config.fb_scene_cfg_list[self:GetSceneType()] or
			fb_config.fb_scene_cfg_list[SceneType.Common]
end

--@scene_id 传送点所在场景，@to_scene_id 传送要去的场景
function Scene:GetSceneDoorPos(scene_id, to_scene_id)
	local scene = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene ~= nil then
		for i,j in pairs(scene.doors) do
			if j.target_scene_id == to_scene_id then
				return j.x, j.y
			end
		end
	end
	return nil, nil
end

-- 根据npc_id获取该npc所在的场景信息 @{scene, x, y, id}
function Scene:GetSceneNpcInfo(npc_cfg_id)
	local scene_npc_cfg = nil
	local scene_id = 0
	for k,v in pairs(Config_scenelist) do
		if v.sceneType == SceneType.Common then
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.id)
			if scene_cfg ~= nil and scene_cfg.npcs ~= nil then
				for i, j in pairs(scene_cfg.npcs) do
					if j.id == npc_cfg_id then
						scene_npc_cfg = j
						scene_id = v.id
						break
					end
				end
			end
			if scene_npc_cfg ~= nil then
				break
			end
		end
	end
	if scene_npc_cfg ~= nil then
		local info = {}
		info.scene = scene_id
		info.x = scene_npc_cfg.x
		info.y = scene_npc_cfg.y
		info.id = npc_cfg_id
		return info
	end
end

function Scene:OnShieldSelfEffectChanged(value)
	-- local main_part = self.main_role.draw_obj:GetPart(SceneObjPart.Main)
	-- main_part:EnableEffect(not value)
	-- main_part:EnableFootsteps(not value)
	if self.main_role == nil then return end
	
	local actor_trigger = self.main_role:GetActorTrigger()
	if actor_trigger then
		actor_trigger:EnableEffect(not value)
		-- actor_trigger:EnableFootsteps(not value)
	end
end

function Scene:OnShieldGoddessChanged(value, is_cg)
	local is_cg = is_cg or false
	local settingData = SettingData.Instance
	local shield_goddess = settingData:GetSettingData(SETTING_TYPE.CLOSE_GODDESS)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetGoddessVisible(not shield_goddess and not is_cg)
		end
	end
end

function Scene:OnShieldRoleChanged(value)
	local settingData = SettingData.Instance
	local shield_others = settingData:GetSettingData(SETTING_TYPE.SHIELD_OTHERS)
	local shield_friend = settingData:GetSettingData(SETTING_TYPE.SHIELD_SAME_CAMP)

	if shield_others or shield_friend then
		for _, v in pairs(self.obj_list) do
			-- if v:IsRole() and not v:IsMainRole() and (v.vo.role_id ~= self.main_role.vo.multi_mount_other_uid)) then
			if v:IsRole() and not v:IsMainRole() and not v:IsMainRoleParnter() then
				self.is_shield = shield_others or (shield_friend and not self:IsEnemy(v))
				if self.is_shield == v:IsRoleVisible() then
					v:SetRoleVisible(not self.is_shield)
					if self.is_shield then
						v:SetFollowLocalPosition(100)
					else
						v:SetFollowLocalPosition(0)
					end
				end
			end
		end
		return
	else
		for _, v in pairs(self.obj_list) do
			if v:IsRole() and not v:IsMainRole() and not v:IsRoleVisible() then
				v:SetRoleVisible(true)
				v:SetFollowLocalPosition(0)
			end
		end
	end
end

function Scene:GetIsShield()
	return self.is_shield
end

function Scene:OnShieldSkillEffectChanged(value)
	if IsLowMemSystem then
		value = true
	end
	for _, v in pairs(self.obj_list) do
		if v:IsRole() and not v:IsMainRole() then
			-- local main_part = v.draw_obj:GetPart(SceneObjPart.Main)
			-- main_part:EnableEffect(not value)
			-- main_part:EnableFootsteps(not value)
			local actor_trigger = v:GetActorTrigger()
			if actor_trigger then
				actor_trigger:EnableEffect(not value)
				-- actor_trigger:EnableFootsteps(not value)
			end
		end
	end
end

-- 是否关闭震屏效果
function Scene:OnShieldCameraShakeChanged(value)
	local actor_trigger = self.main_role:GetActorTrigger()
	if actor_trigger then
		actor_trigger:EnableCameraShake(not value)
	end
end

function Scene:SettingChange(setting_type, switch)
	switch = not switch
	if setting_type == SETTING_TYPE.CLOSE_TITLE then
		local obj_list = self:GetObjListByType(SceneObjType.Role)
		if obj_list then
			for k,v in pairs(obj_list) do
				v:SetTitleVisible(switch)
			end
		end
	end
	self:GetMainRole():SetTitleVisible(switch)
end

--屏蔽怪物
function Scene:OnShieldEnemy(value)
	if nil == self.scene_logic then
		return
	end

	local scene_id = self:GetSceneId()
	for k,v in pairs(GameEnum.NOT_SHIELD_ENEMY_SCENE_ID) do
		if v == scene_id then
			return
		end
	end
	if not self.scene_logic:CanShieldMonster() then
		print_warning("当前场景不能屏蔽怪物  scene_id: ", scene_id)
		return
	end
	for k,v in pairs(self:GetMonsterList()) do
		if nil == v.IsBoss or not v:IsBoss() then
			v.draw_obj:SetVisible(not value)
			if v.draw_obj:GetObjType() == SceneObjType.Monster then
				v.draw_obj:GetSceneObj():_FlushFollowTarget()
			end
			local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
			if value then
				follow_ui:SetHpBarLocalPosition(0, 80, 0)
			else
				follow_ui:SetHpBarLocalPosition(0, -5, 0)
			end
		end
	end
end

--屏蔽精灵
function Scene:OnShieldSpirit(value)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetSpriteVisible(not value)
		end
	end
end

--屏蔽灵童
function Scene:OnShieldLingChong(value)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetLingChongVisible(not value)
		end
	end
end

--屏蔽飞宠
function Scene:OnShieldFlyPet(value)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:SetFlyPetVisible(not value)
		end
	end
end

--屏蔽形象
function Scene:OnShieldAdvance()
	for _, v in pairs(self.obj_list) do
		if v:IsRole() or v:IsMainRole() then
			v:UpdateModel()
		end
	end
end


-- 激活引导箭头指向某点
function Scene:ActGuideArrowTo(x, y)
	if nil == self.guide_arrow then
		self.guide_arrow = GuideArrow.New()
	end
	self.guide_arrow:SetMoveArrowTo(x, y)
end

function Scene:DelGuideArrow()
	if nil ~= self.guide_arrow then
		self.guide_arrow:DeleteMe()
		self.guide_arrow = nil
	end
end

function Scene:DelSceneEffect()
	if nil ~= self.effect_loader_list then
		for k,v in pairs(self.effect_loader_list) do
			v:DeleteMe()
		end
		self.effect_loader_list = nil
	end
end

function Scene:ShieldNpc(npc_id)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(false)
		npc_obj:GetFollowUi():Hide()
		if npc_obj.select_effect then
			npc_obj.select_effect:SetActive(false)
		end
	end
	self.shield_npc_id_list[npc_id] = true
end

function Scene:UnShieldNpc(npc_id)
	local npc_obj = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_obj then
		npc_obj:GetDrawObj():SetVisible(true)
		npc_obj:GetFollowUi():Show()
	end

	self.shield_npc_id_list[npc_id] = nil
end

function Scene:SetEnterSceneCount()
	self.enter_scene_count = self.enter_scene_count + 1
end

function Scene:GetEnterSceneCount()
	return self.enter_scene_count
end

function Scene:SetHoldCameraMode(param2)
	if IsNil(MainCameraFollow) then
		return
	end
	local point = Vector2(20, 130)
	if param2 == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
		point = Vector2(20, -80)
	end
	MainCameraFollow.AllowRotation = true
	MainCameraFollow.AllowXRotation = false
	MainCameraFollow.AllowYRotation = true
	MainCameraFollow.Distance = 5
	MainCameraFollow:ChangeAngle(point) --抱美人写死视角
end

function Scene:UpdateCameraMode(param, param2)
	local guide_flag_list = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_KEY_FLAG)
	local flag = guide_flag_list.item_id
	if param and param == 2 then
		CAMERA_TYPE = param
		self:SetHoldCameraMode(param2)
		return
	end
	self:SetCameraMode(flag)
end

function Scene:SetCameraMode(value)
	value = value or 0
	if CAMERA_TYPE == value then
		return
	end
	if nil == MainCameraFollow or nil == MainCamera then
		return
	end

	CAMERA_TYPE = value

	self:UpdateCameraSetting()

	Scheduler.Delay(function()
		self.main_role:UpdateCameraFollowTarget(false)
	end)
end

--默认摄像机距离和角度
local DefaultDistance = 14
local DefaultAnble = Vector2(40, 0)
function Scene:UpdateCameraSetting()
	if IsNil(MainCameraFollow) then
		return
	end
	if IS_AUDIT_VERSION then
		return
	end
	if CAMERA_TYPE == CameraType.Free then
		MainCameraFollow.AllowRotation = true
		MainCameraFollow.AllowXRotation = true
		MainCameraFollow.AllowYRotation = true

		local rotation_x = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_X).item_id
		local rotation_y = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_ROTATION_Y).item_id
		local distance = SettingData.Instance:GetSettingDataListByKey(HOT_KEY.CAMERA_DISTANCE).item_id
		rotation_x = rotation_x == 0 and self.camera_default_setting.OriginAngle.x or rotation_x
		rotation_y = rotation_y == 0 and self.camera_default_setting.OriginAngle.y or rotation_y
		distance = distance == 0 and self.camera_default_setting.Distance or distance

		MainCameraFollow.Distance = distance
		if rotation_x > 180 then	--大于180时就应该是负值了
			rotation_x = rotation_x - 360
		end
		MainCameraFollow:ChangeAngle(Vector2(rotation_x, rotation_y))
	elseif CAMERA_TYPE == CameraType.Fixed then
		MainCameraFollow.AllowRotation = true
		MainCameraFollow.AllowXRotation = false
		MainCameraFollow.AllowYRotation = true

		MainCameraFollow.Distance = DefaultDistance
		MainCameraFollow:ChangeAngle(DefaultAnble)
	end
end

local MaxZoom = 10
local LeastZoom = 2
local MaxDistance = 15
local LeastDistance = 3
function Scene:UpdateCameraDistance()
	if IsNil(MainCameraFollow) or PlayerData.Instance:IsHoldAngle() then
		return
	end
	if Scene.Instance:GetSceneType() == SceneType.Common and MainCameraFollow.Distance <= LeastDistance then
		MainUIData.IsSetCameraZoom = false
		MainCameraFollow.ZoomSmoothing = LeastZoom
		MainCameraFollow.Distance = MaxDistance
		GlobalTimerQuest:AddDelayTimer(function ()
			if IsNil(MainCameraFollow) then
				return
			end
			MainCameraFollow.ZoomSmoothing = MaxZoom
			MainUIData.IsSetCameraZoom = true
		end,8)
	end
end

-- 是否显示天气效果
function Scene:ShowWeather()
	local flag = false
	if self.scene_config then
		if self.scene_config.show_weather and self.scene_config.show_weather == 1 then
			flag = true
		end
	end
	return flag
end

-- 进引导副本需要写死视角
function Scene:SetGuideFixedCamera(rotation_x, rotation_y, distance)
	if IsNil(MainCameraFollow) then
		return
	end
	if IS_AUDIT_VERSION then
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type and scene_type == SceneType.Audit_Version_LongCheng then
			local prof = PlayerData.Instance:GetRoleBaseProf()
			rotation_x = AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].ROTATION_X or 0
			rotation_y = AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].ROTATION_Y or 0
			distance = AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].DISTANCE
		end
	end

	MainCameraFollow:ChangeAngle(Vector2(rotation_x, rotation_y))
	MainCameraFollow.Distance = distance or MaxDistance
end

function Scene:IsNeedDelayCreateDoor()
	local scene_type = Scene.Instance:GetSceneType()
	if FuBenData.Instance:IsTeamSpecialNeedDelayCreateDoor() then
		return true
	end

	return false
end

--吃鸡盛宴
function Scene:CreateEnterPartyNpc(npc_vo_list)
	if npc_vo_list == nil then
    	return
  	end
	self:ClearEnterPartyNpc()
	for k,v in pairs(npc_vo_list) do
		self:CreateObj(v, SceneObjType.Npc)
	end
end

function Scene:ClearEnterPartyNpc()
	for k,v in pairs(self.obj_list) do
		if v.draw_obj then
			if v.draw_obj:GetObjType() == SceneObjType.Npc then
				if FestivalSinglePartyData.Instance:IsSinglePartyNpc(v:GetNpcId()) then
					self:DeleteObj(v:GetObjId(), 0)
				end
			end
		end
	end
end

-- CG屏蔽各种宠物
function Scene:OnShieldRolePet(value)
	for _, v in pairs(self.obj_list) do
		if v:IsRole() then
			v:SetLingChongVisible(value)
			v:SetFlyPetVisible(value)
		end
	end
end

-- 树苗任务
function Scene:SceneTreeTask()
	local gather_list = self:GetObjListByType(SceneObjType.GatherObj)
	for k,v in pairs(gather_list) do
		local tesk_tree = TaskData.Instance:GetGatherIdTree(v:GetGatherId())
		if tesk_tree and tesk_tree.task_id and tesk_tree.gather_id then
			local is_complete = TaskData.Instance:GetShuTaskState(tesk_tree.task_id)
			local current_count = TaskData.Instance:GetProgressNum(tesk_tree.task_id)

			local task_cfg = TaskData.Instance:GetTaskConfig(tesk_tree.task_id)
			local current_count = TaskData.Instance:GetProgressNum(tesk_tree.task_id)

			if is_complete or current_count >= 2 then
				local key = ActionStatus.Status2
				if not self.is_change_shu_task then
					key = ActionStatus.Status2Stop
				end
				v:SetGatherTrigger(key)
				if is_complete then
					local bundle, asset = "actors/gather/6201_prefab", "6201002_TX"
					v:SetEffectShow(bundle, asset)
				end
			else
				if current_count > 0 and current_count < task_cfg.c_param2 then
					local key = ActionStatus.Status1
					if not self.is_change_shu_task then
						key = ActionStatus.Status1Stop
					end
					v:SetGatherTrigger(key)
				end
			end
		end
	end
	self.is_change_shu_task = true
end

function Scene:SetCurFixedCamera(scene_id)
	local fb_scene_cfg = SceneData.Instance:GetFbSceneCfg(scene_id)
	-- if fb_scene_cfg and fb_scene_cfg.is_scene_action 
	-- 	and fb_scene_cfg.is_scene_action ~= "" 
	-- 	and fb_scene_cfg.is_scene_action == 1 then
	-- 	return
	-- end

	if self.main_role then
		local pos_x, pos_y = self.main_role:GetLogicPos()
		local move_cfg = FuBenData.Instance:GetMoveViewCamearCfg(scene_id, pos_x, pos_y)
		if move_cfg then
			if self:GetSceneType() ~= 0 and self.setcamera_scene_id == scene_id then
				return
			end
			self.setcamera_scene_id = scene_id
			self:SetTimeCameraTurn(move_cfg.dis_x, move_cfg.star_x, move_cfg.stop_x, move_cfg.is_speedx_up, move_cfg.dis_y, move_cfg.star_y, move_cfg.stop_y, move_cfg.is_speedy_up, move_cfg.time)
			return
		end
		local camear_cfg = FuBenData.Instance:GetOrdCamearCfg(scene_id, pos_x, pos_y)
		if camear_cfg then
			local rotation_x = CAMERA_TYPE == CameraType.Fixed and DefaultAnble.x or camear_cfg.rotation_x
			self:SetGuideFixedCamera(rotation_x, camear_cfg.rotation_y)
		end
		self.setcamera_scene_id = scene_id
	end
end

-- 获取速度
function Scene:GetCameraTurnInfo(dis, star, stop, is_speed_up, time)
	local distance = 0
	local value = 0
	local addtime = 0
	if dis == 1 then
		distance = stop - star
	else
		distance = star - stop
	end
	if is_speed_up == 1 then
		value = 0
	else
		value = (distance*2) / time
	end
	addtime = (distance*2) / (time*time)
	return value, addtime
end

function Scene:FlushFightCamera(stop_x)
	if CAMERA_TYPE == CameraType.Free and not IsNil(MainCamera) then
		local x = MainCamera.transform.parent.transform.localEulerAngles.x
		local y = MainCamera.transform.parent.transform.localEulerAngles.y
		local star_x = x
		local stop_x = stop_x or DefaultAnble.x
		if star_x > 80 then
			star_x = star_x - 360
		end
		if stop_x > 80 then
			stop_x = stop_x - 360
		end

		-- 两个一样会引起BUG！！！
		if star_x == stop_x then
			return
		end

		local dis_x = stop_x > star_x and 1 or -1
		local time = stop_x > star_x and stop_x - star_x or star_x - stop_x
		self:SetTimeCameraTurn(dis_x, star_x, stop_x, -1, 1, y, y, 1, time*3, true)
	end
end

function Scene:SetTimeCameraTurn(dis_x, star_x, stop_x, is_speedx_up, dis_y, star_y, stop_y, is_speedy_up, time, iscanmove)
	-- self.is_can_move = iscanmove or false
	self.x_end = false
	self.y_end = false
	self.time = time or 0

	self.dis_x = dis_x or 0
	self.star_x = star_x or 0
	self.stop_x = stop_x or 0
	self.is_speedx_up = is_speedx_up or 0

	self.dis_y = dis_y or 0
	self.star_y = star_y or 0
	self.stop_y = stop_y or 0
	self.is_speedy_up = is_speedy_up or 0

	self.x_value, self.addtime_x = self:GetCameraTurnInfo(self.dis_x, self.star_x, self.stop_x, self.is_speedx_up, self.time)
	self.y_value, self.addtime_y = self:GetCameraTurnInfo(self.dis_y, self.star_y, self.stop_y, self.is_speedy_up, self.time)
	if self.turn_timer then
		GlobalTimerQuest:CancelQuest(self.turn_timer)
		self.turn_timer = nil
	end
	self.turn_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTurnTime, self), 0.01)
end

function Scene:FlushTurnTime()
	local star_y = self.star_y
	if star_y > 210 then	--大于210时就应该是负值了
		star_y = star_y - 360
	end
	self:SetGuideFixedCamera(self.star_x, star_y)

	if self.x_value <= 0 then
		self.x_value = 0
	end
	if self.dis_x == 1 then
		self.star_x = self.star_x + self.x_value
		if self.star_x >= self.stop_x then
			self.star_x = self.stop_x
			self.x_end = true
		end
	else
		self.star_x = self.star_x - self.x_value
		if self.star_x <= self.stop_x then
			self.star_x = self.stop_x
			self.x_end = true
		end
	end
	if self.is_speedx_up == 1 then
		self.x_value = self.x_value + self.addtime_x
	else
		self.x_value = self.x_value - self.addtime_x
	end

	if self.y_value <= 0 then
		self.y_value = 0
	end
	if self.dis_y == 1 then
		self.star_y = self.star_y + self.y_value
		if self.star_y >= self.stop_y then
			self.star_y = self.stop_y
			self.y_end = true
		end
	else
		self.star_y = self.star_y - self.y_value
		if self.star_y <= self.stop_y then
			self.star_y = self.stop_y
			self.y_end = true
		end
	end
	if self.is_speedy_up == 1 then
		self.y_value = self.y_value + self.addtime_y
	else
		self.y_value = self.y_value - self.addtime_y
	end

	if self.x_end and self.y_end then
		if self.turn_timer then
			GlobalTimerQuest:CancelQuest(self.turn_timer)
			self.turn_timer = nil
		end
		-- self.is_can_move = true
	end
end

--设置吊桥是否显示
function Scene:SetShiqiaoIsShield(scene_id)
	if scene_id == 101 then
		local shiqiao_qiao = GameObject.Find("ShiQiao")
		if shiqiao_qiao then
			local shiqiao_visible = shiqiao_qiao.transform:Find("ShiQiaoVisible")
			if shiqiao_visible and shiqiao_visible.gameObject then
				local is_complete = TaskData.Instance:GetTaskIsCompleted(TaskData.Instance:GetShiQiaoShowTask())
				-- 屏蔽掉桥禁止行走的先。
				-- self:CheckBlockShieldArea(is_complete)
				shiqiao_visible.gameObject:SetActive(is_complete)
			end
		end
	end
end

function Scene:SetMountNpcIsShield()
	local npc_id = 107
	if TaskData.Instance and TaskData.Instance:GetIsShowMountTaskNpc(self:GetSceneId(), npc_id) then
		self:DeleteObjByTypeAndKey(SceneObjType.Npc, npc_id)
	end
end

function Scene:CheckBlockShieldArea(is_complete)
	if nil == self.block_shield_area[1] then
		self.block_shield_area[1] = {}
		local width, height = 29, 20
		local pos_x, pos_y = 250, 213
		for i = 1, width do
			for j = 1, height do
				table.insert(self.block_shield_area[1], {x = pos_x + i, y = pos_y + j})
			end
		end
	end

	if nil == self.block_shield_area[2] then
		self.block_shield_area[2] = {}
		local width, height = 29, 10
		local pos_x, pos_y = 250, 351
		for i = 1, width do
			for j = 1, height do
				table.insert(self.block_shield_area[2], {x = pos_x + i, y = pos_y + j})
			end
		end
	end

	for i = 1, #self.block_shield_area do
		for k, v in pairs(self.block_shield_area[i]) do
			if is_complete then
				AStarFindWay:RevertBlockInfo(v.x, v.y)
			else
				AStarFindWay:SetBlockInfo(v.x, v.y, 2)
			end
		end
	end

	-- local x, y = main_role:GetLogicPos()
	-- if GameMath.IsInRect(x, y, pos_x, pos_y, width, height) then
	-- end
end

-- 此场景是否可以使用轻功
function Scene:IsQingGongScene()
	-- 暂时先写死这些场景
	if self.act_scene_id >= 101 and self.act_scene_id <= 109 then
		return true
	else
		return false
	end
end

-- 此场景是否可以使用变身
function Scene:IsBianShenScene()
	-- 暂时先写死这些场景 策划要求
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Field1v1 or scene_type == SceneType.KF_Arena then
		return false
	else
		return true
	end
end

function Scene:CreateCgObj(list, call_back)
	local i = 1
	for k, v in pairs(list) do
		local obj = nil
		obj = Role.New(v)
		obj:SetFollowLocalPosition(0)
		obj:Init(self)
		obj.draw_obj:SetObjType(SceneObjType.Role)
		obj.draw_obj:SetLoadComplete(function (part, callback_obj)
			if part == SceneObjPart.Main then
				if 0 == obj:GetVo().role_id then -- 假人
					obj.draw_obj:SetVisible(false)
					obj:HideFollowUi()
				end
				if call_back then
					call_back(k)
				end
			end
		end)

		self.cg_obj_list[i] = obj
		i = i + 1
	end
	if self.clear_cg_obj_time then
		GlobalTimerQuest:CancelQuest(self.clear_cg_obj_time)
		self.clear_cg_obj_time = nil
	end
	-- self.clear_cg_obj_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ClearCgObj, self), 30)
end

function Scene:ResetCgObjListPos()
	for _, v in pairs(self.cg_obj_list) do
		local logic_pos_x, logic_pos_y = v:GetLogicPos()
		v:SetLogicPos(logic_pos_x, logic_pos_y)
		if nil ~= v.draw_obj and v.draw_obj.root then
			v.draw_obj.root.transform.localScale = Vector3(2.7, 2.7, 2.7)
			v.draw_obj.root.transform.localRotation = Quaternion.Euler(0, 100, 0)
		end
	end
end

function Scene:GetCgObjList()
	return self.cg_obj_list
end

function Scene:ClearCgObj()
	for _, v in pairs(self.cg_obj_list) do
		v:DeleteMe()
	end
	self.cg_obj_list = {}
end

function Scene:ClearUnuseCgObj()
	for i = #self.cg_obj_list, 1, -1 do
		if 0 == self.cg_obj_list[i]:GetVo().role_id then
			self.cg_obj_list[i]:DeleteMe()
			table.remove(self.cg_obj_list, i)
		end
	end
end

function Scene:IsCanHideRoleFollowUIInLimitCount(max_count)
	local show_count = 0
	local role_list = Scene.Instance:GetRoleList()
	for k,v in pairs(role_list) do
		local follow_ui = v:GetFollowUi()
		if nil ~= follow_ui and follow_ui:IsShow() then
			show_count = show_count + 1
			if show_count > max_count then
				return true
			end
		end
	end

	return false
end
