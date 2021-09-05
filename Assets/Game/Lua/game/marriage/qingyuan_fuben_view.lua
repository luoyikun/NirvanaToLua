QingYuanFuBenView = QingYuanFuBenView or BaseClass(BaseView)

function QingYuanFuBenView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "QingYuanFuBenView"}}
	self.time_count = 0
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function QingYuanFuBenView:__delete()
end

function QingYuanFuBenView:LoadCallBack()
	self.award_item_cell = ItemCellReward.New()
	self.award_item_cell:SetInstanceParent(self.node_list["AwardItemCell"])
	-- self.award_item_cell:SetCellSize(96, 96, 1)
	self.node_list["BtnBuyNow"].button:AddClickListener(BindTool.Bind(self.BuyClick, self))

	self.victor_panel = QingYuanVictorPanel.New(self.node_list["VictorPanel"])
	self.victor_panel:SetActive(false)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function QingYuanFuBenView:OnMainUIModeListChange(is_show)
	self.node_list["PanelTaskParent"]:SetActive(not is_show)
end

function QingYuanFuBenView:ExitClick()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

function QingYuanFuBenView:ReleaseCallBack()
	self.data = nil
	if nil ~= self.victor_panel then
		self.victor_panel:DeleteMe()
		self.victor_panel = nil
	end

	if self.award_item_cell then
		self.award_item_cell:DeleteMe()
		self.award_item_cell = nil
	end

	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.time_quest ~= nil  then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function QingYuanFuBenView:OpenCallBack()
	self:Flush()
	if self.time_quest ~= nil  then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	end
	
end

function QingYuanFuBenView:SwitchButtonState(enable)
	self.node_list["PanelTaskParent"]:SetActive(enable)
end

function QingYuanFuBenView:CloseCallBack()
	if self.time_quest ~= nil  then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if nil ~= self.victor_panel then
		self.victor_panel:DeleteMe()
		self.victor_panel = nil
	end
end

function QingYuanFuBenView:BuyClick()
	local cfg = MarriageData.Instance:GetMarriageConditions()
	local gold_need = cfg ~= nil and cfg.lover_fb_double_reward_need_gold or 0

	local function ok_callback()
		MarriageCtrl.Instance:SendQingYuanFBInfoReq(QINGYUAN_FB_OPERA_TYPE.QINGYUAN_FB_OPERA_TYPE_BUY_DOUBLE_REWARD)
	end

	local des = string.format(Language.Common.CostGoldBuyTip, gold_need)
	TipsCtrl.Instance:ShowCommonAutoView("qing_yuan_fuben", des, ok_callback)
end

function QingYuanFuBenView:SetData(data)
	self.data = data

	local time = math.floor(data.per_wave_remain_time - TimeCtrl.Instance:GetServerTime())
	if time > self.time_count then
		self.time_count = time
	end
	if self:IsLoaded() then
		if data.is_finish == 1 then
			time = math.floor(data.kick_out_timestamp - TimeCtrl.Instance:GetServerTime())
		else
			self:Flush()
		end
	end
end

function QingYuanFuBenView:Flush()
	if nil == self.data then return end
	self.refresh_tmp_time = self.data.next_refresh_monster_time - TimeCtrl.Instance:GetServerTime()
	if self.refresh_tmp_time > 0 then
		self.node_list["TxtLeftTime"].text.text = ToColorStr(math.floor(self.refresh_tmp_time), TEXT_COLOR.GREEN)..Language.Marriage.Flush_Monster
	end
	local buff_out_timestamp = self.data.buff_out_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	-- if buff_out_timestamp <= 0 or buff_out_timestamp < server_time then
	--  UI:SetButtonEnabled(self.node_list["BtnBuyNow"], true)
	-- else
	--  UI:SetButtonEnabled(self.node_list["BtnBuyNow"], true)
	-- end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.male_is_buy == 1 and main_role_vo.sex == 1 then
		-- UI:SetButtonEnabled(self.node_list["BtnBuyNow"], false)
		self.node_list["BtnBuyNow"]:SetActive(false)
		self.node_list["tab_has_double"]:SetActive(true)
	elseif self.data.female_is_buy == 1 and main_role_vo.sex == 0 then
		-- UI:SetButtonEnabled(self.node_list["BtnBuyNow"], false)
		self.node_list["BtnBuyNow"]:SetActive(false)
		self.node_list["tab_has_double"]:SetActive(true)
	else
		self.node_list["BtnBuyNow"]:SetActive(true)
		self.node_list["tab_has_double"]:SetActive(false)
		-- UI:SetButtonEnabled(self.node_list["BtnBuyNow"], true)
	end
	-- local cfg = MarriageData.Instance:GetQingYuanFBBuffInfo()
	-- local buff_value = (cfg.buff_gongjing_per / 100).."%"
	-- self.node_list["TxtBuffCost"].text.text = string.format(Language.Marriage.DiamondCost, gold_need, buff_value)
	local curr_wave = self.data.curr_wave >= self.data.max_wave_count and ToColorStr(self.data.curr_wave, TEXT_COLOR.GREEN) or ToColorStr(self.data.curr_wave, TEXT_COLOR.RED)
	self.node_list["TxtLeftWave"].text.text = string.format(Language.Marriage.LeftWave, curr_wave.." / ".. self.data.max_wave_count)
	self:SetTime()
	self:SetBuffLeftTime()

	local id = MarriageData.Instance:GetQingYuanFBReward()[1].stuff_id

	local num = MarriageData.Instance:GetQingYuanFBReward()[1].stuff_num
	-- self.node_list["TxtNum"].text.text = "X" .. num
	local award_data = {}
	award_data.item_id = id
	award_data.num = num
	if (self.data.male_is_buy == 1 and main_role_vo.sex == 1) or (self.data.female_is_buy == 1 and main_role_vo.sex == 0) then
		award_data.num = num * 2
	end
	self.award_item_cell:SetData(award_data)

end

function QingYuanFuBenView:Timer()
	self.time_count = self.time_count - 1
	if self.time_count < 0 then
		return
	end
	self:SetTime()
	self:SetBuffLeftTime()
end

function QingYuanFuBenView:SetTime()
	if self.refresh_tmp_time > 0 then
		return
	end

	local min = math.floor(self.time_count / 60)
	local sec = self.time_count - (min * 60)
	if min < 10 then
		min = "0"..min
	end
	if sec < 10 then
		sec = "0"..sec
	end
	local text = Language.Marriage.Left_Time .. ToColorStr((min..":"..sec), TEXT_COLOR.GREEN)
	self.node_list["TxtLeftTime"].text.text = text
end

function QingYuanFuBenView:SetBuffLeftTime()
	local buff_out_timestamp = self.data.buff_out_timestamp
	local time_str = ""
	local server_time = TimeCtrl.Instance:GetServerTime()
	if buff_out_timestamp <= 0 or buff_out_timestamp < server_time then
		time_str = "00:00"
	else
		local diff_time = buff_out_timestamp - server_time
		diff_time = math.floor(diff_time)
		time_str = TimeUtil.FormatSecond(diff_time, 2)
	end
	self.node_list["TxtBuffLeftTime"].text.text = time_str
end

------------------VictorPanel-----------------
QingYuanVictorPanel = QingYuanVictorPanel or BaseClass(BaseRender)

function QingYuanVictorPanel:__init()
	self.item_list = {}
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell1"])
	self.node_list["Btnconfirm"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
end

function QingYuanVictorPanel:__delete()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.item_cell:DeleteMe()
end

function QingYuanVictorPanel:ShowView(item_num, time)
	self.first = false
	self.time_count = time

	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	self:SetActive(true)
	if item_num > 0 then
		self.item_cell:SetActive(true)
		local item_data = MarriageData.Instance:GetRingUpgradeItem()
		local tmp_data = {}
		tmp_data.item_id = item_data.stuff_id
		tmp_data.num = item_num
		self.item_cell:SetData(tmp_data)
	else
		self.item_cell:SetActive(false)
	end
end

function QingYuanVictorPanel:OnClickYes()
	self:SetActive(false)
	FuBenCtrl.Instance:SendExitFBReq()
end

function QingYuanVictorPanel:SetActive(is_active)
	self.root_node.gameObject:SetActive(is_active)
end

function QingYuanVictorPanel:Timer()
	local time = self.time_count - 1
	if time < 0 then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		return
	end
	self.time_count = time
	self.node_list["TxtCountDown"].text.text = self.time_count
end