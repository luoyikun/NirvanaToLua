MainUIViewReminding = MainUIViewReminding or BaseClass(BaseRender)

ShengDiFuBenAutoGatherEvent = {
	func = nil
}
MainUIViewReminding.SHOW_SHOT_LEVEL = 67
function MainUIViewReminding:__init()
	self.be_atk_icon = MainBeAtkIcon.New(self.node_list["BeAtkSmallParts"])
	self.gather_bar = self.node_list["GatherBar"].slider
	self.xunlu_act = false
	self.is_shengdi_auto_gather = false
	self.atk_icon_show_time = 0
	self.is_auto_rotation_camera = false
	self.show_arrow = true

	self:BindGlobalEvent(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_AUTO_XUNLU,
		BindTool.Bind(self.OnMainRoleAutoXunluChange, self))
	self:BindGlobalEvent(ObjectEventType.GATHER_TIMER,
		BindTool.Bind(self.OnSetGatherTime, self))
	self:BindGlobalEvent(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self:BindGlobalEvent(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))

	self:BindGlobalEvent(OtherEventType.SHENGDI_FUBEN_INFO_CHANGE,
		BindTool.Bind(self.SetGatherBtnStateTwo, self))

	self:BindGlobalEvent(OtherEventType.POWER_CHANGE_VIEW_OPEN,
		BindTool.Bind(self.PowerChangeViewOpen, self))

	self:BindGlobalEvent(OtherEventType.JUMP_STATE_CHANGE,
		BindTool.Bind(self.OnJumpStateChange, self))
	self:BindGlobalEvent(SettingEventType.MAIN_CAMERA_MODE_CHANGE,
		BindTool.Bind1(self.CameraModeChange, self))

	self.node_list["BtnShot"].button:AddClickListener(BindTool.Bind(self.ClickFly, self))

	self:FlushFirstCharge()
end

-- 自动寻路状态改变
local scene_cfg = nil
function MainUIViewReminding:OnMainRoleAutoXunluChange(auto)
	self.is_auto_rotation_camera = auto or false
	if self.is_auto_rotation_camera and not FunctionGuide.Instance:GetIsGuide() then
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)
	end
	MainUIData.UserOperation = false
	self:SetAutoRotation()
	scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if 0 == scene_cfg.is_show_navigation then
		auto = false
	end
	if PlayerData.Instance.role_vo.husong_taskid > 0 then
		auto = false
	end
	self:CheckShowShot()
	if self.xunlu_act == auto then return end
	self.xunlu_act = auto
	local main_role = Scene.Instance:GetMainRole()
	if auto == true and SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_USE_FLY_SHOE) and not self:GetNoShowAutoFly() and TaskData.Instance:GetCanFly() then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if VipPower.Instance:GetParam(VipPowerId.scene_fly) > 0 and MoveCache.cant_fly == false then
			self:ClickFly()
		else
			local shot_id = MapData.Instance:GetFlyShoeId()
			local num = ItemData.Instance:GetItemNumInBagById(shot_id)
			if num > 0 and MoveCache.cant_fly == false then
				self:ClickFly()
			else
				local buy_type = ShopData.Instance:CheckCanBuyItem(shot_id)

				if buy_type and buy_type == SHOP_BIND_TYPE.BIND and MoveCache.cant_fly == false then
					TaskCtrl.Instance:SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
				elseif buy_type and buy_type == SHOP_BIND_TYPE.NO_BIND and MoveCache.cant_fly == false then
					TaskCtrl.Instance:SendFlyByShoe(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, nil, true)
				end
			end
		end
	end
	self.node_list["XunLu"]:SetActive(auto and not self.pc_view_open and not main_role:GetIsFlying() and not main_role:IsQingGong())
end

-- 挂机类型改变
function MainUIViewReminding:OnGuajiTypeChange(guaji_type)
	-- if(guaji_type == GuajiType.HalfAuto) then
	-- 	self.node_list["GuaJi"]:SetActive(false)
	-- 	-- if not self.node_list["XunLu"]:GetActive() then
	-- 	-- 	self.node_list["XunLu"]:SetActive(true)
	-- 	-- end
	-- 	self.xunlu_act = true
	-- elseif(guaji_type == GuajiType.Auto) then
	-- 	-- self.node_list["GuaJi"]:SetActive(true)
	-- 	self.node_list["XunLu"]:SetActive(false)
	-- 	self.xunlu_act = false
	-- else
	-- 	self.node_list["GuaJi"]:SetActive(false)
	-- 	self.node_list["XunLu"]:SetActive(false)
	-- 	self.xunlu_act = false
	-- end
end

-- 跳跃改变
function MainUIViewReminding:OnJumpStateChange(jump_state)
	self:CheckShowShot()
end

function MainUIViewReminding:CheckShowShot()
	self.node_list["BtnShot"]:SetActive(not self:GetNoShowAutoFly())
	-- 客户端加的假的引导点一次就消失
	if self.show_arrow and TaskData.Instance:GetTaskIsAccepted(FLY_ARROW_TASK) then
		self.node_list["Arrow"]:SetActive(true)
	end
end

function MainUIViewReminding:GetNoShowAutoFly()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	return PlayerData.Instance.role_vo.level < MainUIViewReminding.SHOW_SHOT_LEVEL 
	or Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2
	or MoveCache.cant_fly == true
	or BossData.IsBossScene()
	or scene_cfg and scene_cfg.pb_fly == 1
	or Scene.Instance:GetMainRole():GetIsFlying()
end

function MainUIViewReminding:__delete()
	self.is_shengdi_auto_gather = nil

	if self.be_atk_icon ~= nil then
		self.be_atk_icon:DeleteMe()
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	
	if self.delay_show_fish then
		GlobalTimerQuest:CancelQuest(self.delay_show_fish)
		self.delay_show_fish = nil
	end

	-- GlobalEventSystem:UnBind(self.obj_del_event)
	-- self.obj_del_event = nil

	-- GlobalEventSystem:UnBind(self.obj_creat)
	-- self.obj_creat = nil

	-- if self.activity_call_back then
	-- 	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
	-- 	self.activity_call_back = nil
	-- end

	ShengDiFuBenAutoGatherEvent.func = nil
end

function MainUIViewReminding:SetBeAtkIconState(role_vo)
	-- 策划要求跨服中不弹 --后来策划要求弹出
	-- if IS_ON_CROSSSERVER then
	-- 	return
	-- end
	self.be_atk_icon:SetData(role_vo)
end



-- 开始采集
function MainUIViewReminding:OnStartGather(role_obj_id, gather_obj_id)
	MainUICtrl.Instance:FlushView("clear_manual_time")
	local main_role = Scene.Instance:GetMainRole()
	local obj_id = main_role:GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.node_list["GatherBar"]:SetActive(true)
	-- self.node_list["XunLu"]:SetActive(false)
	self.isOn = true
	local name = nil
	local describe = ""
	local config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
	local gather_obj = Scene.Instance:GetObjectByObjId(gather_obj_id)

	local id = nil
	if gather_obj then
		id = gather_obj:GetGatherId()
		local cfg = ConfigManager.Instance:GetAutoConfig("qingyuanshengdiconfig_auto").gather or {}
		for k,v in pairs(cfg) do
			if v.gather_id == id then
				self.is_shengdi_auto_gather = true
				break
			else
				self.is_shengdi_auto_gather = false
			end
		end
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.KF_Fish then
			--钓鱼特殊处理
			FishingCtrl.Instance:HideFishing(true)
		end
		if scene_type == SceneType.HotSpring then
			-- 温泉答题捕鱼
			gather_obj.draw_obj:GetPart(SceneObjPart.Main):SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.BeHug)
			gather_obj.draw_obj:SetVisible(false)

			if self.delay_show_fish then
				GlobalTimerQuest:CancelQuest(self.delay_show_fish)
				self.delay_show_fish = nil
			end
			self.delay_show_fish = GlobalTimerQuest:AddDelayTimer(function() 
				if gather_obj and gather_obj.draw_obj then
					gather_obj.draw_obj:SetVisible(true)
					if self.delay_show_fish then
						GlobalTimerQuest:CancelQuest(self.delay_show_fish)
						self.delay_show_fish = nil
					end
				end
			end, 0.5)
		end
	end
	if config and id then
		local gather_config = config[id]
		if gather_config then
			name = gather_config.show_name
			describe = gather_config.describe
		end
	end
	name = name or Language.Common.DefaultGather
	describe = describe == "" and Language.Common.IsGather .. name or describe
	if id == GuildBonfireData.Instance:GetBonfireOtherCfg().gathar_id then
		self.node_list["TxtGather"].text.text = Language.Guild.Praying
	else
		self.node_list["TxtGather"].text.text = describe
	end
end

-- 停止采集
function MainUIViewReminding:OnStopGather(role_obj_id)
	MainUICtrl.Instance:FlushView("guaji_manual_state")
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.node_list["GatherBar"]:SetActive(false)
	-- self.node_list["XunLu"]:SetActive(self.xunlu_act or false)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.KF_Fish then
		FishingCtrl.Instance:HideFishing(false)
	end
	if scene_type == SceneType.HotSpring then
		local cfg = HotStringChatData.Instance:GetHotSpringGatherCfg() or {}
		for k, v in pairs(cfg) do
			for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
				if j:GetGatherId() == v.gather_id then
					j.draw_obj:GetPart(SceneObjPart.Main):SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)
				end
			end
		end
	end 

	self.gather_bar.value = 0
	self.isOn = false
	if self.tweener then
		self.tweener:Pause()
	end
	if self.tween1 then
		self.tween1:Pause()
	end
	self:SetGatherBtnStateTwo()
end

function MainUIViewReminding:OnSetVisibleGath()
	self.node_list["GatherBar"]:SetActive(false)
end

-- 设置采集时间
function MainUIViewReminding:OnSetGatherTime(gather_time)
	if not gather_time then return end
	if not self.isOn then
		return
	end
	-- if gather_time > 0.2 then
	-- 	gather_time = gather_time - 0.2
	-- end
	self.gather_bar.value = 0
	self.tweener = self.gather_bar:DOValue(1, gather_time, false)
	self.tweener:SetEase(DG.Tweening.Ease.Linear)

	self.node_list["GatherBarRotaObj"].transform.rotation = Vector3(0, 0, 0)
	self.tween1 = self.node_list["GatherBarRotaObj"].transform:DORotate(
			Vector3(0, 0, -360),
			gather_time,
			DG.Tweening.RotateMode.FastBeyond360)
	self.tween1:SetEase(DG.Tweening.Ease.Linear)
end

function MainUIViewReminding:PowerChangeViewOpen(is_open)
	self.pc_view_open = is_open
	local main_role = Scene.Instance:GetMainRole()
	self.node_list["XunLu"]:SetActive(self.xunlu_act and not self.pc_view_open and not main_role:GetIsFlying() and not main_role:IsQingGong())
end

-- 点击跟随榜首
function MainUIViewReminding:OnClickFollow()
	GuajiCtrl.Instance:StopGuaji()
	HotStringChatCtrl.Instance:SendFirstPos()
end

function MainUIViewReminding:GetShengDiFuBenGather()
	self.shengdi_fuben_gather_list = {}
	local cfg = MarriageData.Instance:GetGatherCfg() or {}
	for k, v in pairs(cfg) do
		for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
			if j:GetGatherId() == v.gather_id then
				local pos_x, pos_y = j:GetLogicPos()
				self.shengdi_fuben_gather_list[#self.shengdi_fuben_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
			end
		end
	end
end

function MainUIViewReminding:SetGatherBtnStateTwo(gather_id)
	self:GetShengDiFuBenGather()

	if MarriageData.Instance:IsGatherTimesLimit() then
		self.is_shengdi_auto_gather = false
	end
	ShengDiFuBenAutoGatherEvent.func = function(is_click_obj)
		self.is_shengdi_auto_gather = false
		if self.shengdi_auto_gather_timer then
			GlobalTimerQuest:CancelQuest(self.shengdi_auto_gather_timer)
			self.shengdi_auto_gather_timer = nil
		end
	end
	if self.is_shengdi_auto_gather then
		if not self.shengdi_auto_gather_timer and not self.is_click_gather then
			self.shengdi_auto_gather_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:AutoGatherTwo()
				if self.shengdi_auto_gather_timer then
					GlobalTimerQuest:CancelQuest(self.shengdi_auto_gather_timer)
					self.shengdi_auto_gather_timer = nil
				end
			end, 0.1)
		end
	end
end

function MainUIViewReminding:ClickFly()
	self.show_arrow = false
	self.node_list["Arrow"]:SetActive(false)
	local logic = Scene.Instance:GetSceneLogic()
	if logic and not logic:CanCancleAutoGuaji() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Rune.CanNotCancleGuaji)
		return
	end

	if not TaskData.Instance:GetCanFly() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Task.TaskTaskNoFly)
		return
	end
	self:FlyToPos(MoveCache.scene_id, MoveCache.x, MoveCache.y)
end

function MainUIViewReminding:FlyToPos(scene_id, x, y)
	TaskCtrl.Instance:SendFlyByShoe(scene_id, x, y)
end

function MainUIViewReminding:AutoGatherTwo()
	if self.isOn or not self.is_shengdi_auto_gather then return end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	for k, v in pairs(self.shengdi_fuben_gather_list) do
		if not AStarFindWay:IsBlock(v.x, v.y) then
			local distance = GameMath.GetDistance(p_x, p_y, v.x, v.y, false)
			if distance < target_distance then
				min_x = v.x
				min_y = v.y
				target_distance = distance
				id = v.id
			end
			can_gather = true
		end
	end
	if not can_gather then
		return
	end

	local target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 4, 0)
end

function MainUIViewReminding:FlushFirstCharge()
	if self.node_list["TxtShouChong"] then
		local is_first = DailyChargeData.Instance:GetFirstChongzhiOpen()
		self.node_list["TxtShouChong"]:SetActive(is_first)
	end
end

function MainUIViewReminding:CameraModeChange()
	self:SetAutoRotation()
end

function MainUIViewReminding:SetAutoRotation(is_auto)
	if nil ~= is_auto then
		self.is_auto_rotation_camera = is_auto
	end
	if not IsNil(MainCameraFollow) then
		local scene_id = Scene.Instance:GetSceneId()
		local is_quality_id = false
		if scene_id >= 1700 and scene_id <= 2150 then	-- 品质副本和组队本不要转视角
			is_quality_id = true
		end
		
		if not CgManager.Instance:IsCgIng() and Scene.Instance:GetMainRoleIsMove() and 
			not PlayerData.Instance:IsHoldAngle() and not MainUIData.UserOperation and
			(Scene.Instance:GetMainRole():IsMove() or Scene.Instance:GetMainRole():IsFightStateByRole()) and
			not is_quality_id then
			MainCameraFollow.AutoRotation = self.is_auto_rotation_camera
		else
			MainCameraFollow.AutoRotation = false
		end
	end
end