LingKunBattleDetailView = LingKunBattleDetailView or BaseClass(BaseView)

local FIELD_NUM = 4

local CFG_INDEX ={
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 1,
}

function LingKunBattleDetailView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/lingkunbattleview_prefab", "LingKunDetailContent"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.act_id = ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB
	self.reward_list = {}

end


function LingKunBattleDetailView:LoadCallBack(index, index_nodes)
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnList"].button:AddClickListener(BindTool.Bind(self.OnClickMonsterList, self))
	self.node_list["BtnEnterAct"].button:AddClickListener(BindTool.Bind(self.OnEnterCrossScene, self))
	-- FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Boss, BindTool.Bind(self.GetUiCallBack, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ShowHelpTipView, self))

	self.node_list["TitleText"].text.text = Language.LingKunBattle.TitleName
	self.is_can_enter = true
	for i = 1 , FIELD_NUM + 1 do 
		self.node_list["ToggleEnter" .. i].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self, i))
	end
	
	for i = 1 , FIELD_NUM do
		self.node_list["TxtNum" .. i].text.text = string.format(Language.LingKunBattle.PlayerNum, 20)
	end

	-- local cfg = LingKunBattleData.Instance:GetRewardCfg(2)
	local act_info = ActivityData.Instance:GetActivityInfoById(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB)
	local tab_list = Split(act_info.item_label, ":")
	if nil == act_info then
		return
	end
	for i = 1 , 4 do 
		self.reward_list[i] = ItemCell.New()
		self.reward_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.reward_list[i]:SetShowOrangeEffect(true)
		if tab_list[i] then
			tab_list[i] = tonumber(tab_list[i])
		end
		if act_info["reward_item" .. i] and next(act_info["reward_item" .. i]) and act_info["reward_item" .. i].item_id ~= 0 then
			self.reward_list[i].root_node:SetActive(true)
			self.reward_list[i]:SetData(act_info["reward_item" .. i])
			if tab_list[i]then
				self.reward_list[i]:SetShowZhuanShu(tab_list[i] == 1)
			end
		else
			self.reward_list[i]:SetInteractable(false)
			self.reward_list[i].root_node:SetActive(false)
		end
	end

	local min_level = tonumber(act_info.min_level)
	local level_str = PlayerData.GetLevelString(min_level)
	-- local time_des = ActivityData.Instance:GetChineseWeek(act_info) or ""
	local time_des = ActivityData.Instance:GetLimintOpenDayTextByActId(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB, act_info)
	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	self.node_list["TxtExplain"].text.text = detailexplain
end

function LingKunBattleDetailView:OpenCallBack()
	LingKunBattleCtrl.Instance:SendLingKunOperate()
	self.select_index = 1
	self.node_list["ToggleEnter" .. self.select_index].toggle.isOn = true
	self:Flush()
end

-- function LingKunBattleDetailView:CloseCallBack()
-- 	if nil ~= self.CountDownTimer then
-- 		CountDown.Instance:RemoveCountDown(self.CountDownTimer)
-- 		self.CountDownTimer = nil
-- 	end
-- end

function LingKunBattleDetailView:ShowHelpTipView()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end



function LingKunBattleDetailView:ReleaseCallBack()
	for k , v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	if nil ~= self.CountDownTimer then
		CountDown.Instance:RemoveCountDown(self.CountDownTimer)
		self.CountDownTimer = nil
	end
end

function LingKunBattleDetailView:FlushCountDown()
	-- if nil ~= self.CountDownTimer then
	-- 	CountDown.Instance:RemoveCountDown(self.CountDownTimer)
	-- 	self.CountDownTimer = nil
	-- end

	local act_cfg = ActivityData.Instance:GetClockActivityByID(3087)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(3087)
	if activity_info == nil or next(activity_info) == nil then
		return
	end
	local next_time = activity_info.next_time
	local open_time = 0
	local end_time = 0
	local open_time_list = Split(act_cfg.open_time, "|")
	local open_time_table = Split(open_time_list[#open_time_list], ":")
	if open_time_table and open_time_table[1] and open_time_table[2] then
		open_time = tonumber(open_time_table[1]) * 60 + tonumber(open_time_table[2])
		open_time = open_time * 60
	end
	local end_time_list = Split(act_cfg.end_time, "|")
	local end_time_table = Split(end_time_list[#end_time_list], ":")
	if end_time_table and end_time_table[1] and end_time_table[2] then
		end_time = tonumber(end_time_table[1]) * 60 + tonumber(end_time_table[2])
		end_time = end_time * 60
	end
	local real_time = end_time - open_time

	local ServerTimes = TimeCtrl.Instance:GetServerTime()
	local left_time = next_time - ServerTimes
	local limit_time = LingKunBattleData.Instance:GetEnterLimitTime()
	local diff_time = real_time - left_time
	diff_time = limit_time - diff_time
	local RemindDes = ""

	local complete_func = function()
		if nil ~= self.CountDownTimer then
			CountDown.Instance:RemoveCountDown(self.CountDownTimer)
			self.CountDownTimer = nil
		end

		for i = 1, FIELD_NUM do
			if self.node_list and self.node_list["Status" .. i] then
				if activity_info.status == 1 then
					self.node_list["Status" .. i].text.text = string.format(Language.LingKunBattle.EnterStatus, Language.LingKunBattle.HadOpen)
				else
					self.node_list["Status" .. i].text.text = string.format(Language.LingKunBattle.EnterStatus, Language.LingKunBattle.HasClose)
				end
			end
		end
	end

	if diff_time > 0 and activity_info.status == 2 then
		if nil == self.CountDownTimer then
			local diff_func = function(elapse_time, total_time)
				if elapse_time >= total_time then
					if nil ~= self.CountDownTimer then
						CountDown.Instance:RemoveCountDown(self.CountDownTimer)
						self.CountDownTimer = nil
					end
					return
				end
				local last_time = math.floor(total_time - elapse_time + 0.5)
				local FinalTime = TimeUtil.FormatSecond(last_time, 2)
				RemindDes = string.format(Language.LingKunBattle.CloseTime, FinalTime)
				for i = 1, FIELD_NUM do
					if self.node_list and self.node_list["Status" .. i] then
						self.node_list["Status" .. i].text.text = RemindDes
					end
				end
			end

			diff_func(0, diff_time)
			self.CountDownTimer = CountDown.Instance:AddCountDown(diff_time, 1, diff_func, complete_func)
		end
	else
		complete_func()
	end
end

function LingKunBattleDetailView:CloseWindow()
	self:Close()
end

function LingKunBattleDetailView:OnEnterCrossScene()

	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)

	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end

	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) and not ActivityData.Instance:IsAchieveLevelInLimintConfigById(self.act_id) 
	and ActivityData.Instance:GetActivityStatuByType(self.act_id) == nil and ActivityData.Instance:GetActivityStatuByType(self.act_id).status ~= ACTIVITY_STATUS.OPEN then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		return
	end

	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB, self.select_index)
end

function LingKunBattleDetailView:OnFlush(param_t)
	self:FlushCountDown()
	self:FlushPlayerNum()
	local act_info = ActivityData.Instance:GetActivityInfoById(3087)
	self.open_day_list = Split(act_info.open_day, ":")
	self:SetTitleTime(act_info)
end

function LingKunBattleDetailView:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		for _, v in ipairs(self.open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				end
				break
			end
		end
	end
	self.node_list["TxtTitleTime"].text.text = time_str
end

function LingKunBattleDetailView:OnClickMonsterList()
	ViewManager.Instance:Open(ViewName.LingKunBattleBossView)
end

function LingKunBattleDetailView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end


function LingKunBattleDetailView:OnToggleChange(index)
	self.select_index = index ~= 5 and index or 0

	self.node_list["ToggleEnter" .. index].toggle.isOn = true

	LingKunBattleCtrl.Instance:SendLingKunOperate()
	-- local cfg = LingKunBattleData.Instance:GetRewardCfg(CFG_INDEX[index])
	-- for i = 1 , 2 do 
	-- 	self.reward_list[i]:SetData(cfg[i])
	-- end
end

function LingKunBattleDetailView:FlushPlayerNum()
	local count_list = LingKunBattleData.Instance:GetLingKunFBPlayerInfo().role_num
	local is_enter_main_zone = LingKunBattleData.Instance:GetLingKunFBPlayerInfo().is_enter_main_zone
	local main_enter_status = false
	-- local side_enter_status = false
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB) then
		main_enter_status = is_enter_main_zone == 1
		-- side_enter_status = self.is_can_enter and is_enter_main_zone == 0
	else
		main_enter_status = false
		-- side_enter_status = false
	end

	-- local side_entet_text = side_enter_status and Language.LingKunBattle.CanEnter or Language.LingKunBattle.HasClose
	for i = 1 , FIELD_NUM do
		self.node_list["TxtNum" .. i].text.text = string.format(Language.LingKunBattle.PlayerNum, count_list[i + 1] or 0)
		-- self.node_list["Status" .. i].text.text = string.format(Language.LingKunBattle.EnterStatus, side_entet_text)
	end
	local num = count_list[1] or 0
	local str = is_enter_main_zone == 1 and string.format(Language.LingKunBattle.PlayerNum,num) or Language.LingKunBattle.WarningTip
	self.node_list["TxtNum" .. 5].text.text = str

	local enter_text = main_enter_status and Language.LingKunBattle.CanEnter or Language.LingKunBattle.HasClose
	self.node_list["Status" .. 5].text.text = string.format(Language.LingKunBattle.EnterStatus, enter_text)
end



function LingKunBattleDetailView:ShowTrunTableInfo()

end

function LingKunBattleDetailView:ShowIndexCallBack(index, index_nodes)

end

function LingKunBattleDetailView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function LingKunBattleDetailView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.miku_boss then
		self.node_list["TabMiku"].toggle.isOn = true
	end
end

function LingKunBattleDetailView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.miku_boss then
			if self.node_list["TabMiku"].gameObject.activeInHierarchy then
				if self.node_list["TabMiku"].toggle.isOn then
					return NextGuideStepFlag
				else
					local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.miku_boss)
					return self.tab_miku_boss, callback
				end
			end
		end
	elseif ui_name == GuideUIName.BossGuideFatigue then
		if self.fatigue_guide and self.fatigue_guide.gameObject.activeInHierarchy then
			return self.fatigue_guide
		end
	end
end