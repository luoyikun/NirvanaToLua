FuBenInfoExpView = FuBenInfoExpView or BaseClass(BaseView)

local ALL_WAVE = 3
function FuBenInfoExpView:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "ExpFBInFoView"}}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.FloatText
	self.camera_mode = UICameraMode.UICameraLow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.fight_effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind1(self.Flush, self))
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
end

function FuBenInfoExpView:LoadCallBack()
	self.node_list["HuodejingyanTxt"]:SetActive(true)
	self.node_list["ExpFBRewardTxt"]:SetActive(true)
	self.first_open = true
end

function FuBenInfoExpView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	if self.node_list and self.node_list["TaskParentNode"] then
		self.node_list["TaskParentNode"]:SetActive(state)
	end
end

function FuBenInfoExpView:__delete()
	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end
end

function FuBenInfoExpView:ReleaseCallBack()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	-- 清理变量和对象

	self.time = nil
	self.first_open = true
	self.upgrade_timer_quest=nil
end

function FuBenInfoExpView:CloseCallBack()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode")
	if attck_mode ~= nil then
		MainUICtrl.Instance:SendSetAttackMode(attck_mode)
	end
end

function FuBenInfoExpView:OnClickOpenBuff()
	TipsCtrl.Instance:TipsExpInSprieFuBenView()
end

function FuBenInfoExpView:OnClickOpenPotion()
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FuBenInfoExpView:OpenCallBack()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	MainUICtrl.Instance:SetViewState(false)
	FuBenData.Instance:SetExpFbFlag(false)

	local fb_view = FuBenCtrl.Instance:GetFuBenView()
	if fb_view:IsOpen() then
		fb_view:Close()
	end
	self:Flush()
end

function FuBenInfoExpView:OnFlush()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	if exp_fb_info == nil or next(exp_fb_info) == nil then return end
	
	self.node_list["LeiJiTxt"].text.text = string.format(Language.FuBen.LeiJIKill, exp_fb_info.kill_allmonster_num)
	self.node_list["JingYanTxt"].text.text = string.format(Language.FuBen.JingYan, FightData.Instance:GetMainRoleDrugAddExp())
	local team_info = ScoietyData.Instance:GetTeamInfo()
	local team_member_list = team_info.team_member_list or {}
	local team_user_list = ScoietyData.Instance:GetTeamUserList()
	local member_list = {}
	for k, v in ipairs(team_user_list) do
		for i, j in ipairs(team_member_list) do
			if v == j.role_id then
				table.insert(member_list, j)
			end
		end
	end
	local cfg = exp_fb_info.team_member_num
	local exp = 0
	if cfg == 1 then
		exp = 0
 	elseif cfg == 2 then
		exp = 15
	elseif cfg == 3 then
		exp = 30
	elseif cfg == 4 then
		exp = 45
	end
	
	local cur_process = exp_fb_info.wave >= ALL_WAVE and exp_fb_info.wave or ToColorStr(exp_fb_info.wave, TEXT_COLOR.RED)
	self.node_list["TeamTxt"].text.text = string.format(Language.FuBen.TeamExp, exp)
	self.node_list["CurrentTxt"].text.text = string.format(Language.FuBen.CurProcess, cur_process, ALL_WAVE)
	self.node_list["ShanghaiTxt"].text.text = string.format(Language.FuBen.ShanghaiTxt, FuBenData.Instance:GetInSpireDamage())

	local count = self:ChangeNum(exp_fb_info.exp)
	self.node_list["ExpFBRewardTxt"].text.text = count
	local start_time = exp_fb_info.start_time or 0
	local sever_time = TimeCtrl.Instance:GetServerTime()
	local fb_time = FuBenData.Instance:GetExpFBTime()
	self.time = start_time - sever_time + 8 or 0
	if self.time > 0 then
		self:SetAutoTalkTime()
		self.node_list["HuodejingyanTxt"]:SetActive(false)
		self.node_list["ExpFBRewardTxt"]:SetActive(false)
	end
	local exp_show = exp_fb_info.exp
	if exp_fb_info.expfb_history_enter_times == 1 then
		local other_cfg = FuBenData.Instance:GetExpFBOtherCfg()
		if other_cfg and other_cfg.baodi_exp1 then
			exp_show = exp_show >= other_cfg.baodi_exp1 and exp_show or other_cfg.baodi_exp1
		end
	end
	local data_list= {exp_show, exp_fb_info.kill_allmonster_num, exp_fb_info.exp_percent}
	local is_Exit = FuBenData.Instance:GetExpFbFlag()
	if exp_fb_info.is_finish == 1 and self.first_open then
		if self.upgrade_timer_quest == nil then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				self.first_open = false
				if is_Exit then
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expexip", {data = data_list})
				else
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "expfinish", {data = data_list})
				end

			end, 1)
		end
	end
end

function FuBenInfoExpView:ChangeNum(count)
	if count > 99999999 then
		count_1 = math.floor(count / 100000000)
		count_1 = count_1* 100000000
		count_1 = (count - count_1) / 10000
		count_1 = math.floor(count_1)
		count_1 = count_1 .. Language.Common.Wan
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
		count = count .. count_1
	else
		count = tostring(count)
	end
	return count
end

function FuBenInfoExpView:SetAutoTalkTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(self.time, 1, BindTool.Bind(self.CountDown, self))
end

function FuBenInfoExpView:CountDown(elapse_time, total_time)
	self.node_list["Timetxt"].text.text = math.floor(total_time - elapse_time)
	if total_time - elapse_time < 6 then
		self.node_list["TimetxtNode"]:SetActive(true)
	end
	if elapse_time >= total_time then
		self.node_list["TimetxtNode"]:SetActive(false)
		self.node_list["HuodejingyanTxt"]:SetActive(true)
		self.node_list["ExpFBRewardTxt"]:SetActive(true)
	end
end