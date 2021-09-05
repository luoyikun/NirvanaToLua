HotInfoView = HotInfoView or BaseClass(BaseView)

function HotInfoView:__init()
	self.ui_config = {{"uis/views/chatroom_prefab", "HotSpringInfoView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_show_shuangxiu = false
	self.is_safe_area_adapter = true
	self.distance = 0
end

function HotInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self:RemoveCountDown()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.gather_timer_quest then
		GlobalTimerQuest:CancelQuest(self.gather_timer_quest)
		self.gather_timer_quest = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	self.target_obj = nil
end

function HotInfoView:LoadCallBack()
	self.rank_data = {}
	self.target_vo = {}

	self.is_open_table = true

	self.node_list["TxtMyExp"].text.text = ""

	self.imteraction_add = HotStringChatData.Instance:GetInteractionAdd()

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.HotSpringInfoState, self))
	
	self.node_list["BtnShunagXiu"].button:AddClickListener(BindTool.Bind(self.OnClickShuangXiu, self))
	self.node_list["Toggle2"].toggle:AddClickListener(BindTool.Bind(self.OnClickRank, self))
	self.node_list["BtnSnowBall"].button:AddClickListener(BindTool.Bind(self.OnClickThrowSnowBall, self))
	self.node_list["BtnMassage"].button:AddClickListener(BindTool.Bind(self.OnClickMassage, self))
	self.node_list["BtnFollow"].button:AddClickListener(BindTool.Bind(self.OnClickFollow, self))
	self.node_list["BtnGather"].button:AddClickListener(BindTool.Bind(self.OnGatherThing, self))

	self.node_list["TxtExpUp"].text.text = string.format(Language.HotString.SecretExpUp, 0)

	self.main_role_arrive = BindTool.Bind(self.OnMainRoleArrive, self)

	local skill_cfg1 = HotStringChatData.Instance:GetSkillCfgByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
	self.massage_cold_down_time = skill_cfg1.cold_down_time or 0
	self.distance1 = skill_cfg1.skill_distance or COMMON_CONSTS.SELECT_OBJ_DISTANCE
	local skill_cfg2 = HotStringChatData.Instance:GetSkillCfgByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL)
	self.snowball_cold_down_time = skill_cfg2.cold_down_time or 0
	self.distance2 = skill_cfg2.skill_distance or COMMON_CONSTS.SELECT_OBJ_DISTANCE
	self:InitScroller()
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSkillCD, self), 0.1)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))

	self.node_list["Toggle1"].toggle.isOn = true
end


function HotInfoView:OpenCallBack()
	self.eh_move_start = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_START, BindTool.Bind1(self.OnMainRoleMoveStart, self))
	self.obj_delete = GlobalEventSystem:Bind(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self.click_shuang_xiu = GlobalEventSystem:Bind(ObjectEventType.CLICK_SHUANGXIU,
		BindTool.Bind(self.ClickTargetShuangXiu, self))
	self:FlushRankList()
	self:FlushSkillInfo()
	self:FlushSkillActive()
	self:FlushGatherInfo()
	if self:IsAnswering() then
		self:SetToggleIsOn(2, true)
	end
end

function HotInfoView:CloseCallBack()
	if self.eh_move_start then
		GlobalEventSystem:UnBind(self.eh_move_start)
		self.eh_move_start = nil
	end

	if self.obj_delete then
		GlobalEventSystem:UnBind(self.obj_delete)
		self.obj_delete = nil
	end
	if self.click_shuang_xiu then
		GlobalEventSystem:UnBind(self.click_shuang_xiu)
		self.click_shuang_xiu = nil
	end
end

function HotInfoView:PortraitToggleChange(state)
	self.is_open_table = state
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_HOT_SPRING)
	self.node_list["SkillControl"]:SetActive(state and is_open)
end

function HotInfoView:OnGatherThing()

	local time = HotStringChatData.Instance:GetRemainGatherTime()

	if time <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.HotString.TimeHasRunningOut)
		return 
	end 

	self.gather_list = {}
	local cfg = HotStringChatData.Instance:GetHotSpringGatherCfg() or {}
	for k, v in pairs(cfg) do
		for i, j in pairs(Scene.Instance:GetObjListByType(SceneObjType.GatherObj)) do
			if j:GetGatherId() == v.gather_id then
				local pos_x, pos_y = j:GetLogicPos()
				self.gather_list[#self.gather_list + 1] = {x = pos_x, y = pos_y, id = j:GetGatherId(), obj_id = j:GetObjKey()}
			end
		end
	end

	local scene_id = Scene.Instance:GetSceneId()
	local target_distance = 1000 * 1000
	local main_role = Scene.Instance:GetMainRole()
	local p_x, p_y = main_role:GetLogicPos()
	local min_x, min_y, id = 0, 0, 0
	local can_gather = false
	for k, v in pairs(self.gather_list) do
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
		local min, second = self:GatherNotReflush()
		if min <= 0 and second <= 0 then
			local str = string.format(Language.HotString.AroundNotGatherObj)
			TipsCtrl.Instance:ShowSystemMsg(str)
		else
			local str = string.format(Language.HotString.TimeNotGatherObj, min, second)
			TipsCtrl.Instance:ShowSystemMsg(str)
		end
		return
	end

	if HotStringChatData.Instance:GetRepairState() then
		HotStringChatCtrl.Instance:DelPartnerReq()
		HotStringChatData.Instance:ClearpartnerId()
		HotStringChatData.Instance:SetIsStartGather(true)
	end

	target = {scene = scene_id, x = min_x, y = min_y, id = id}
	MoveCache.end_type = MoveEndType.GatherById
	MoveCache.param1 = target.id
	GuajiCache.target_obj_id = target.id
	GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, 2, 1)
end

function HotInfoView:GatherNotReflush()
	local time = HotStringChatData.Instance:GetFlushGatherTime() or 0
	local rest_time = time - TimeCtrl.Instance:GetServerTime()
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	return time_tab.min, time_tab.s
end

-- HotStringChatData:GetFlushGatherTime()
-- -- HotStringChatData:GetUseGatherTime()
-- 	-- return self.gather_times



-- 寻找合适双修的角色
function HotInfoView:FindRole(x, y, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit
	local target_x, target_y, distance = 0, 0, 0
	local can_select = true

	local near_role_list = Scene.Instance:GetRoleList()
	for _, v in pairs(near_role_list) do
		can_select = true
		-- 如果已经有双修对象
		if v.vo.special_param >= 0 and v.vo.special_param < 65535 then
			can_select = false
		end

		if can_select then
			target_x, target_y = v:GetLogicPos()
			distance = GameMath.GetDistance(x, y, target_x, target_y, false)
			if not AStarFindWay:IsBlock(target_x, target_y) then
				if distance < target_distance then
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj, target_distance
end

--点击排名面板
function HotInfoView:OnClickRank()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:ReloadData(0)
	end
end

--点击双修按钮
function HotInfoView:OnClickShuangXiu()
	-- 自己已经在双修了
	if HotStringChatData.Instance:GetRepairState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.IsRepairs)
		return
	end
	HotStringChatData.Instance:SetChooseAnswer(-1)
	local distance = 0
	local target_obj = GuajiCtrl.Instance:GetSelectObj()
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	if nil == target_obj or not target_obj:IsRole() then
		target_obj = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
	end
	if nil == target_obj then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.NotReqairPartner)
		return
	end
	if nil == self.target_obj or self.target_obj ~= target_obj then
		-- target_obj, distance = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
		self.target_obj = target_obj
		self.target_vo = target_obj.vo
		if self.target_vo.special_param and self.target_vo.special_param >= 0 and self.target_vo.special_param < 65535 then
			return 
		end
	-- else
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		distance = u3d.v2Length(delta_pos)
		self.distance = distance
	end

	if self.distance <= 4 then
		HotStringChatCtrl.Instance:AddPartner(self.target_obj:GetObjId())
	else
		MoveCache.end_type = MoveEndType.FollowObj
		GuajiCtrl.Instance:SetArriveCallBack(self.main_role_arrive)
		MoveCache.param1 = self.target_obj:GetObjId()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
	end
end

--点击人物设置(取消)双修目标
function HotInfoView:ClickTargetShuangXiu(target_obj, target_vo, click_type)
	if nil == target_obj or nil == target_vo then
		return
	end

	if click_type == "select" then
		self.target_vo = target_vo
		self.target_obj = target_obj
	elseif click_type == "cancel" then
		self.target_vo = {}
		self.target_obj = nil
	end
end

function HotInfoView:SwitchButtonState(enable)
	self.node_list["PanelTrackAndMapInfo"]:SetActive(enable)
end

function HotInfoView:HotSpringInfoState(enable)
	self.node_list["HotSpringInfoView"]:SetActive(enable)
end


-- 主角开始移动
function HotInfoView:OnMainRoleMoveStart()
	if HotStringChatData.Instance:GetRepairState() then
		HotStringChatCtrl.Instance:DelPartnerReq()
		HotStringChatData.Instance:ClearpartnerId()
		self.target_obj = nil
		self.target_vo = {}
	end
end

-- 主角结束移动
function HotInfoView:OnMainRoleArrive()
	if self.target_obj then
		local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		local distance = u3d.v2Length(delta_pos)
		if distance <= 4 then
			if HotStringChatData.Instance:GetRepairState() then
				TipsCtrl.Instance:ShowSystemMsg(Language.HotString.TargetIsShuangXiu)
			else
				HotStringChatCtrl.Instance:AddPartner(self.target_vo.obj_id)
			end
			self.target_vo = {}
			self.target_obj = nil
		end
	end
end

function HotInfoView:OnObjDelete(obj)
	if obj == self.target_obj then
		self.target_vo = {}
		self.target_obj = nil
	end
end

function HotInfoView:CloseWindow()
	self:Close()
end

function HotInfoView:FlushRankList()
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		self.node_list["TxtMyRank1"].text.text = rank_info.self_rank <= 0 and Language.HotString.NotOnTheRank or string.format(Language.WenQuan.Rank, rank_info.self_rank)
		self.node_list["TxtMyRank2"].text.text = rank_info.self_rank <= 0 and Language.HotString.NotOnTheRank or string.format(Language.WenQuan.Rank, rank_info.self_rank)
		self.node_list["TxtRightPercent"].text.text = rank_info.self_score <= 0 and  string.format(Language.WenQuan.JiFen,0) or string.format(Language.WenQuan.JiFen,rank_info.self_score)
		if self.node_list["Scroller"].scroller.isActiveAndEnabled then
			self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function HotInfoView:FlushRoleInfo()
	local role_info = HotStringChatData.Instance:GetRoleAnswerInfo()
	if role_info then
		local total_count = role_info.question_right_count + role_info.question_wrong_count
		local right_percent = 0
		if total_count ~= 0 then
			right_percent = math.floor((role_info.question_right_count / total_count) * 100)
		end

		self:FlushSkillInfo()
		self:FlushGatherInfo()
	end
end

function HotInfoView:FlushJingYan()
	local jing_yan = HotStringChatData.Instance:GetJingYan()
	self.node_list["TxtMyExp"].text.text = string.format(Language.WenQuan.JingYan, CommonDataManager.ConverMoney(jing_yan))
	self.node_list["MyExp0"].text.text = string.format(Language.WenQuan.JingYan, CommonDataManager.ConverMoney(jing_yan))
end

function HotInfoView:OnChangeRepair()
	local jing_yan = HotStringChatData.Instance:GetShuangXiuJingYan()
	local str = jing_yan and jing_yan or (self.imteraction_add / 100 or 0)
	self.node_list["TxtExpUp"].text.text = string.format(Language.HotString.SecretExpUp, str)
	self.node_list["MyExpUp0"].text.text = string.format(Language.HotString.SecretExpUp, str)

end

function HotInfoView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "jing_yan" then
			self:FlushJingYan()
			self:OnChangeRepair()
		elseif k == "rank" then
			self:FlushRankList()
		elseif k == "question" then
			self:CheckIsAnswering()
		elseif k == "role_info" then
			self:FlushRoleInfo()
			self:FlushGatherInfo()
		elseif k == "skill" then
			self:FlushSkillInfo()
		elseif k == "time_info" then
			self:FlushTimeInfo()
		end
	end
	self:SetCountDown()
end

-- 检查是否正在答题中
function HotInfoView:CheckIsAnswering()
	local flag = false
	local question_info = HotStringChatData.Instance:GetQuestionInfo()
	if question_info then
		local current_count = question_info.broadcast_question_total or 0
		local total_question_count = HotStringChatData.Instance:GetTotalQuestionCount() or 0
		if current_count > 0 and current_count < total_question_count then
			flag = true
		elseif current_count == total_question_count then
			local rest_time = question_info.curr_question_end_time - TimeCtrl.Instance:GetServerTime()
			if rest_time > 0 then
				flag = true
			end
		end
	end
	self.node_list["BtnFollow"]:SetActive(flag)
end

-- 检查是否正在答题中
function HotInfoView:IsAnswering()
	local flag = false
	local question_info = HotStringChatData.Instance:GetQuestionInfo()
	if question_info then
		local current_count = question_info.broadcast_question_total or 0
		local total_question_count = HotStringChatData.Instance:GetTotalQuestionCount() or 0
		if current_count > 0 and current_count < total_question_count then
			flag = true
		elseif current_count == total_question_count then
			local rest_time = question_info.curr_question_end_time - TimeCtrl.Instance:GetServerTime()
			if rest_time > 0 then
				flag = true
			end
		end
	end
	return flag
end

function HotInfoView:SetCountDown()
	if not self.count_down then
		self.node_list["TxtRestTime"].text.text = string.format(Language.WenQuan.Time, "00:00")
		local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_HOT_SPRING) or {}
		local end_time = activity_info.next_time or 0
		local total_time = end_time - TimeCtrl.Instance:GetServerTime()
		if total_time > 0 then
			self:DiffTime(0, total_time)
			self.count_down = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.DiffTime, self))
		end
	end
end

function HotInfoView:DiffTime(elapse_time, total_time)
	local left_time = math.floor(total_time - elapse_time)
	local the_time_text = TimeUtil.FormatSecond(left_time, 2)
	self.node_list["TxtRestTime"].text.text = string.format(Language.WenQuan.Time, the_time_text)
	if left_time <= 0 then
		self:RemoveCountDown()
	end
end

function HotInfoView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function HotInfoView:OnClickMassage()
	if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SkillsCountNotEnough)
		return
	end
	local target_obj, distance = self:FindSkillRole()
	if target_obj then
		if distance <= self.distance1 then
			HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
		else
			MoveCache.end_type = MoveEndType.FollowObj
			GuajiCtrl.Instance:SetArriveCallBack(function ()
				GuajiCtrl.Instance:StopGuaji()
				HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE)
			end)
			MoveCache.param1 = target_obj:GetObjId()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
		end
	end
end

function HotInfoView:OnClickThrowSnowBall()
	if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SkillsCountNotEnough)
		return
	end
	local target_obj, distance = self:FindSkillRole()
	if target_obj then
		if distance <= self.distance2 then
			HotStringChatCtrl.Instance:CSHSUseSkillReq(target_obj:GetObjId(), HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.HotString.SnowBallNeedClose)
		end
	end
end

-- 寻找可以施放技能的角色
function HotInfoView:FindSkillRole()
	-- 自己已经在双修了
	if HotStringChatData.Instance:GetRepairState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.CannotUseSkill)
		return
	end
	local target_obj = GuajiCtrl.Instance:GetSelectObj()
	local distance = 0
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	if nil == target_obj or not target_obj:IsRole() then
		target_obj = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
	end
	-- if nil == self.target_obj then
	-- 	-- target_obj, distance = self:FindRole(self_x, self_y, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
	-- 	target_obj = GuajiCtrl.Instance:GetSelectObj()
		if not target_obj then
			SysMsgCtrl.Instance:ErrorRemind(Language.Answer.NoSelect)
			return
		end
	-- 	self.target_obj = target_obj
	-- 	self.target_vo = target_obj.vo
	-- else
	-- 	local target_x, target_y = self.target_obj:GetLogicPos()
	-- 	local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
	-- 	distance = u3d.v2Length(delta_pos)
	-- end

	-- if nil == self.target_obj or self.target_obj ~= target_obj then
		self.target_obj = target_obj
		self.target_vo = target_obj.vo
		local target_x, target_y = self.target_obj:GetLogicPos()
		local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
		local distance = u3d.v2Length(delta_pos)
		self.distance = distance
	-- end
	return self.target_obj, self.distance
end

function HotInfoView:UpdateSkillCD()
	local skill_info = HotStringChatData.Instance:GetSkillInfo()
	if skill_info then
		if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) > 0 then
			local time = skill_info.skill_1_can_perform_time - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				UI:SetGraphicGrey(self.node_list["Img1"], true)
				self.node_list["TxtCd1"]:SetActive(true)
				self.node_list["TxtCd1"].text.text = math.ceil(time)
				if self.massage_cold_down_time > 0 then
					self.node_list["ImgMask1"]:SetActive(true)
					self.node_list["ImgMask1"]:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = time / self.massage_cold_down_time
				end
			else
				UI:SetGraphicGrey(self.node_list["Img1"], false)
				self.node_list["TxtCd1"].text.text = 0
				self.node_list["TxtCd1"]:SetActive(false)
				self.node_list["ImgMask1"]:SetActive(false)
			end
		else
			UI:SetGraphicGrey(self.node_list["Img1"], true)
		end
		if HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) > 0 then
			local time = skill_info.skill_2_can_perform_time - TimeCtrl.Instance:GetServerTime()
			if time > 0 then
				UI:SetGraphicGrey(self.node_list["Img2"], true)
				self.node_list["TxtCd2"]:SetActive(true)
				self.node_list["TxtCd2"].text.text = math.ceil(time)
				if self.snowball_cold_down_time > 0 then
					self.node_list["ImgMask2"]:SetActive(true)
					self.node_list["ImgMask2"]:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = time / self.snowball_cold_down_time
				end
			else
				UI:SetGraphicGrey(self.node_list["Img2"], false)
				self.node_list["TxtCd2"].text.text = 0
				self.node_list["TxtCd2"]:SetActive(false)
				self.node_list["ImgMask2"]:SetActive(false)
			end
		else
			UI:SetGraphicGrey(self.node_list["Img2"], true)
		end
	end
end

function HotInfoView:FlushGatherInfo()
	self.node_list["Count3"].text.text = HotStringChatData.Instance:GetRemainGatherTime() or 0
end

function HotInfoView:FlushSkillInfo()
	self.node_list["Count1"].text.text = HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) or 0
	self.node_list["Count2"].text.text = HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) or 0
	self.node_list["AnmoNum"].text.text = string.format(Language.HotString.AnMoTips, HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE) or 0) 
	self.node_list["XueqiuNum"].text.text = string.format(Language.HotString.XueQiuTips,  HotStringChatData.Instance:GetRestSkillTimesByType(HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL) or 0) 
	self.node_list["BuhuoNum"].text.text = string.format(Language.HotString.BuHuoTips,  HotStringChatData.Instance:GetRemainGatherTime() or 0) 
end

function HotInfoView:FlushSkillActive()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_HOT_SPRING)
	if self.node_list and self.node_list["SkillControl"] then
		self.node_list["SkillControl"]:SetActive(is_open)
	end
end

function HotInfoView:FlushTimeInfo()
	local gather_time = HotStringChatData.Instance:GetFlushGatherTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_stamp = math.floor(gather_time - server_time)
	if nil ~= self.gather_timer_quest or time_stamp <= 0 then
		GlobalTimerQuest:CancelQuest(self.gather_timer_quest)
	end

	if time_stamp > 0 then
		self.gather_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushSideBroadCast,self), time_stamp - 10)
	end
end

function HotInfoView:FlushSideBroadCast()
	local RemindDes = Language.HotString.GatherObjShow
	TipsCtrl.Instance:ShowActivityNoticeMsg(RemindDes)
end

function HotInfoView:SetToggleIsOn(index, is_on)
	for i = 1, 2 do
		if index == i then
			if self.node_list and self.node_list["Toggle" .. index] and self.node_list["Toggle" .. index].toggle.isActiveAndEnabled then
				self.node_list["Toggle" .. index].toggle.isOn = is_on
			end
		else
			if self.node_list and self.node_list["Toggle" .. index] and self.node_list["Toggle" .. index].toggle.isActiveAndEnabled then
				self.node_list["Toggle" .. index].toggle.isOn = not is_on
			end
		end
	end
	if self.node_list and self.node_list["RedPoint"] then
		if index == 2 and is_on == true then
			self.node_list["RedPoint"]:SetActive(true)
		else
			self.node_list["RedPoint"]:SetActive(false)
		end
	end
end

----------------------------------------InitScroller---------------------------------------------------

--初始化滚动条
function HotInfoView:InitScroller()
	self.cell_list = {}
	local scroller_delegate = self.node_list["Scroller"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function HotInfoView:GetRoomNumberOfCells()
	local count = 0
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		count = rank_info.rank_count or 0
	end
	return count
end

--滚动条刷新
function HotInfoView:GetRoomCellView(cellObj, data_index)
	local cell = self.cell_list[cellObj]
	if cell == nil then
		self.cell_list[cellObj] = HotRankCell.New(cellObj)
		cell = self.cell_list[cellObj]
	end
	cell:SetIndex(data_index + 1)
	local rank_info = HotStringChatData.Instance:GetRankInfo()
	if rank_info then
		local data = rank_info.rank_list[data_index + 1]
		cell:SetData(data)
	end
end

-- 点击跟随榜首
function HotInfoView:OnClickFollow()
	GuajiCtrl.Instance:StopGuaji()
	HotStringChatCtrl.Instance:SendFirstPos()
end

---------------------HotRankCell-----------------------------
HotRankCell = HotRankCell or BaseClass(BaseCell)

function HotRankCell:__init()
end

function HotRankCell:__delete()

end

function HotRankCell:OnFlush()
	if self.data then
		self.node_list["Name"].text.text = self.data.name
		self.node_list["Score"].text.text = self.data.score
	end
	self.node_list["Rank"].text.text = self.index or 0

	if self.index <= 3 then
		self.node_list["Rank"]:SetActive(false)
		self.node_list["RankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImage"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["Rank"]:SetActive(true)
		self.node_list["RankImage"]:SetActive(false)
	end
end