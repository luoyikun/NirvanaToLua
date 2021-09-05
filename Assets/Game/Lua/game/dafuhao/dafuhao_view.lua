
DaFuHaoView = DaFuHaoView or BaseClass(BaseView)

function DaFuHaoView:__init()
	self.ui_config = {{"uis/views/dafuhaoview_prefab", "DaFuHaoView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.play_audio = true
	self.active_close = false
end

function DaFuHaoView:__delete()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function DaFuHaoView:LoadCallBack()
	self.info_view = DaFuHaoInfoView.New(self.node_list["InfoContent"])
	self.change_fight_state_toggle = GlobalEventSystem:Bind(MainUIEventType.FIGHT_STATE_BUTTON, BindTool.Bind(self.ChangeFightStateToggle, self))
end

function DaFuHaoView:ReleaseCallBack()
	if self.info_view then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	if self.change_fight_state_toggle then
		GlobalEventSystem:UnBind(self.change_fight_state_toggle)
		self.change_fight_state_toggle = nil
	end

end

function DaFuHaoView:ChangeFightStateToggle(value)
	self.info_view:SetActive(not value)
end

function DaFuHaoView:CloseCallBack()
	if self.info_view then
		self.info_view:CloseCallBack()
	end

	MainUICtrl.Instance:ShowActivitySkill(false)
	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function DaFuHaoView:OpenCallBack()
	self:Flush()
	if self.info_view then
		self.info_view:OpenCallBack()
	end

	local loader = AllocAsyncLoader(self, "skill_button_loader")
	loader:Load("uis/views/dafuhaoview_prefab", "DaFuHaoSkill", function (obj)
		if IsNil(obj) then
			return
		end

		MainUICtrl.Instance:ShowActivitySkill(obj)
		if nil == self.skill_render then
			self.skill_render = DaFuHaoSkillRender.New(obj)
			self.skill_render:Flush()
		end
	end)
end

function DaFuHaoView:OnClickClose()
	self:Close()
end

function DaFuHaoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "boss" then
			self:SetBossInfo()
		else
			if self.info_view then
				self.info_view:Flush()
			end
			self:SetBossInfo()
		end
	end
end

function DaFuHaoView:SetBossInfo()
	local info = DaFuHaoData.Instance:GetBossFlushData()
	local boss_id = DaFuHaoData.Instance:GetBossID()
	if nil == next(info) then return end

	local boss_flush_time = math.floor(info.next_millionaire_boss_refresh_time - TimeCtrl.Instance:GetServerTime())
	FuBenCtrl.Instance:SetMonsterDiffTime(boss_flush_time)

	if nil ~= boss_id then
		FuBenCtrl.Instance:SetMonsterInfo(boss_id)
	end
	FuBenCtrl.Instance:SetMonsterIconState(true)

	local str = Language.Guild.BossZhan--string.format(Language.ShengXiao.ClickGoTo, 1, 1)
	FuBenCtrl.Instance:ShowMonsterHadFlush(boss_flush_time <= 0 , str)
end


DaFuHaoAutoGatherEvent = {
	func = nil
}

----------------------DaFuHaoSkillRender----------------------
DaFuHaoSkillRender = DaFuHaoSkillRender or BaseClass(BaseRender)
function DaFuHaoSkillRender:__init()
	self.is_auto_gather = true
	self.is_click_gather = true
	self.is_gather_dafuhao = false
	self.dafuhao_skill_rest_times = 0
	self.skill_cd_time = 0
	self.dafuhao_gather_list = {}

	self:BindGlobalEvent(ObjectEventType.START_GATHER, BindTool.Bind(self.OnStartGather, self))
	self:BindGlobalEvent(ObjectEventType.STOP_GATHER, BindTool.Bind(self.OnStopGather, self))
	self:BindGlobalEvent(OtherEventType.DAFUHAO_INFO_CHANGE, BindTool.Bind(self.SetGatherBtnState, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadQuit, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function DaFuHaoSkillRender:__delete()
	if nil ~= self.skill_cd_progress_count_down then
		CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
		self.skill_cd_progress_count_down = nil
	end

	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)

	DaFuHaoAutoGatherEvent.func = nil
end

function DaFuHaoSkillRender:LoadCallBack()
	self.node_list["BtnGather"].button:AddClickListener(BindTool.Bind(self.ClickGather, self))
	self.node_list["BtnGather1"].button:AddClickListener(BindTool.Bind(self.OnClickBingDongSkill, self))
end

-- 开始采集
function DaFuHaoSkillRender:OnStartGather(role_obj_id, gather_obj_id)
	local main_role = Scene.Instance:GetMainRole()
	local obj_id = main_role:GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end
	self.is_gathering = true
end

function DaFuHaoSkillRender:OnStopGather(role_obj_id)
	local obj_id = Scene.Instance:GetMainRole():GetObjId()
	if(obj_id ~= role_obj_id) then
		return
	end

	self.is_gathering = false

	self:SetGatherBtnState()
end

-- 使用冰冻技能
function DaFuHaoSkillRender:OnClickBingDongSkill()
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	local flush_time = dafuhao_info.millionaire_last_perform_skill_time or 0
	local cd = flush_time - TimeCtrl.Instance:GetServerTime()

	-- 技能CD中
	if cd > 0 then --or nil ~= self.skill_cd_progress_count_down or nil ~= self.skill_cd_time_count_down then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SkillCD)
		return
	end

	if DaFuHaoData.Instance:GetSkillRestTimes() <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.NoUseSkillTimes)
		return
	end

	-- local obj_id = GuajiCache.target_obj_id
	-- if obj_id < 0 then
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Society.SelectName)
	-- 	return
	-- end

	-- local obj = Scene.Instance:GetRoleByObjId(obj_id)
	local obj = GuajiCtrl.Instance:SelectFriend()
	if nil == obj then
		TipsCtrl.Instance:ShowSystemMsg(Language.Fight.NoRoleTarget)
		return
	end

	local pos_x, pos_y = obj:GetLogicPos()
	-- local my_x, my_y = Scene.Instance:GetMainRole():GetLogicPos()
	-- local distance = GameMath.GetDistance(my_x, my_y, pos_x, pos_y, false)
	local skill_dis = DaFuHaoData.Instance:GetSkillDistance()

	if not self:CheckRange(pos_x, pos_y, skill_dis) then
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Role.AttackDistanceFar)
		local scene_id = Scene.Instance:GetSceneId()
		MoveCache.end_type = MoveEndType.UseBingDongSkill
		GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y, skill_dis - 1, 0)
		return
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	scene_logic:UseBingDongSkill()
end
-- 检测范围
function DaFuHaoSkillRender:CheckRange(x, y, range)
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	return math.floor((x - self_x) * (x - self_x)) + math.floor((y - self_y) * (y - self_y)) <= range * range
end

function DaFuHaoSkillRender:ClickGather()
	self.is_auto_gather = true
	self.is_click_gather = true
	self:AutoGather()
	self.is_click_gather = false
end

function DaFuHaoSkillRender:AutoGather()
	if self.is_gathering or not self.is_auto_gather then return end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	for k, v in pairs(self.dafuhao_gather_list) do
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
		-- if self.is_auto_gather then
		-- 	print_error("当前范围内无大富豪采集物", self.dafuhao_gather_list[1], "scene_id :", scene_id)
		-- end
		return
	end

	local target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 3, 0)
end

function DaFuHaoSkillRender:OnSceneLoadQuit()
	self:SetGatherBtnState()
end

function DaFuHaoSkillRender:SetGatherBtnState(gather_id)
	if not DaFuHaoData.Instance:IsShowDaFuHao() then
		return
	end

	self:SetDaFuHaoSkill()
	self:GetDafuhaoGather()

	self.node_list["BtnGather"]:SetActive(nil ~= next(self.dafuhao_gather_list))

	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}
	if dafuhao_info.reward_index and dafuhao_info.reward_index < 0 and dafuhao_info.gather_total_times == 10 then
		self.is_auto_gather = false
	end

	DaFuHaoAutoGatherEvent.func = function(is_click_obj)
		self.is_auto_gather = false
		if self.auto_gather_timer then
			GlobalTimerQuest:CancelQuest(self.auto_gather_timer)
			self.auto_gather_timer = nil
		end
	end

	if self.is_auto_gather then
		if not self.auto_gather_timer and not self.is_click_gather then
			self.auto_gather_timer = GlobalTimerQuest:AddDelayTimer(function()
				self:AutoGather()
				if self.auto_gather_timer then
					GlobalTimerQuest:CancelQuest(self.auto_gather_timer)
					self.auto_gather_timer = nil
				end
				end, 0.1)
		end
	end
end

function DaFuHaoSkillRender:GetDafuhaoGather()
	self.dafuhao_gather_list = {}
	local cfg = DaFuHaoData.Instance:GetDaFuHaoCfg().gather_box_cfg or {}
	for k, v in pairs(cfg) do
		for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
			if j:GetGatherId() == v.gather_id then
				local pos_x, pos_y = j:GetLogicPos()
				self.dafuhao_gather_list[#self.dafuhao_gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
			end
		end
	end
end

function DaFuHaoSkillRender:SetDaFuHaoSkill()
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}
	if nil == next(dafuhao_info) then return end
	local cd = dafuhao_info.millionaire_last_perform_skill_time - TimeCtrl.Instance:GetServerTime()
	
	self.dafuhao_skill_rest_times = DaFuHaoData.Instance:GetSkillRestTimes()
	UI:SetGraphicGrey(self.node_list["ImgSkill"], self.dafuhao_skill_rest_times == 0)

	self.node_list["ImgCDMask"]:SetActive((0 ~= cd) and self.dafuhao_skill_rest_times > 0)
	self.node_list["TxtCDMask"]:SetActive(cd and self.dafuhao_skill_rest_times > 0)
	self.node_list["TxtSkillRestTime"].text.text = string.format(Language.Activity.DaFuHaoSkilltime, self.dafuhao_skill_rest_times)

	self:SetSkillCDProgress(cd)
	self:SetSkillCDTime(cd)
end

function DaFuHaoSkillRender:SetSkillCDProgress(cd)
	-- local cd = dafuhao_info.millionaire_last_perform_skill_time - TimeCtrl.Instance:GetServerTime()

	if nil == self.skill_cd_progress_count_down then
		self.skill_cd_progress_count_down = CountDown.Instance:AddCountDown(
			cd, 0.05, function(elapse_time, total_time)
				local progress = (total_time - elapse_time) / total_time
				self.node_list["ImgCDMask"].image.fillAmount = progress

				if progress <= 0 and nil ~= self.skill_cd_progress_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
					self.skill_cd_progress_count_down = nil
				end
			end)
	end
end

function DaFuHaoSkillRender:SetSkillCDTime(cd)
	-- local cd = dafuhao_info.millionaire_last_perform_skill_time - TimeCtrl.Instance:GetServerTime()

	if nil == self.skill_cd_time_count_down then
		self.skill_cd_time = DaFuHaoData.Instance:GetSkillCD()
		self.node_list["ImgCDMask"]:SetActive(0 ~= cd)
		self.node_list["TxtCDMask"].text.text = self.skill_cd_time
		self.node_list["TxtCDMask"]:SetActive(cd ~= 0)


		self.skill_cd_time_count_down = CountDown.Instance:AddCountDown(
			cd, 1.0, function(elapse_time, total_time)
				self.skill_cd_time = math.ceil(total_time - elapse_time)
				-- self.node_list["ImgCDMask"]:SetActive((0 ~= self.skill_cd_time) and DaFuHaoSkillRestTimes)
				self.node_list["TxtCDMask"].text.text = self.skill_cd_time
				self.node_list["TxtCDMask"]:SetActive(self.skill_cd_time ~= 0)

				if math.ceil(total_time - elapse_time) <= 0 and nil ~= self.skill_cd_time_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_time_count_down)
					self.skill_cd_time_count_down = nil
				end
			end)
	end
end


function DaFuHaoSkillRender:OnObjDelete(obj)
	if nil == obj then return end

	if DaFuHaoData.Instance and DaFuHaoData.Instance:IsDaFuHaoGather(obj) then
		self:SetGatherBtnState()
	end
end

function DaFuHaoSkillRender:OnObjCreate(obj)
	if nil == obj then return end

	if DaFuHaoData.Instance and DaFuHaoData.Instance:IsDaFuHaoGather(obj) then
		self:SetGatherBtnState()
	end
end

function DaFuHaoSkillRender:ActivityCallBack(activity_type)
	if activity_type == DaFuHaoDataActivityId.ID then
		self:SetGatherBtnState()
	end
end

function DaFuHaoSkillRender:OnFlush()
	self:SetGatherBtnState()
end