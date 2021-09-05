KaifuActivityPanelFifteen = KaifuActivityPanelFifteen or BaseClass(BaseRender)
--活跃投资 panel15
local  type_seq = {
	[0] = "boss",
	[1] = "active",
	[2] = "competition",
}

--做转换,由于服务端0是boss  1是活跃,所以这里要按策划需求改做转换
KAIFU_INVEST_TAB_TO_TYPE = {
	[0] = KAIFU_INVEST_TYPE.ACTIVE,
	[1] = KAIFU_INVEST_TYPE.BOSS,
	[2] = KAIFU_INVEST_TYPE.COMPETITION
}

local MAX_TOGGLE_NUM = 3

local TOTAL_DAY_NUM = 7

function KaifuActivityPanelFifteen:__init()
	self.target_list = {}
	for i = 1, TOTAL_DAY_NUM do
		self.target_list[i] = TargetCell.New(self.node_list["CellRewardItem" .. i], i)
	end

	for i = 1, MAX_TOGGLE_NUM do
		self.node_list["ToggleActive" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickTab, self, i - 1))
	end

	self.node_list["BtnGetReward"].button:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["BtnGoToBoss"].button:AddClickListener(BindTool.Bind(self.OnClickBoss, self))
	self.node_list["BtnGoToGet"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	--默认打开第一个
	self.tab_index = 0
end

function KaifuActivityPanelFifteen:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	self.target_list = nil
end

function KaifuActivityPanelFifteen:OpenCallBack()
	self:ChooseTab()
	self:Flush()
end

function KaifuActivityPanelFifteen:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function KaifuActivityPanelFifteen:InitData()
	local invest_type = KAIFU_INVEST_TAB_TO_TYPE[self.tab_index]
	self.state = KaifuActivityData.Instance:GetInvestStateByType(invest_type)
	local cfg = KaifuActivityData.Instance:GetInvestCfgByType(invest_type)
	local data = KaifuActivityData.Instance:GetInvestData()
	local target_info = KaifuActivityData.Instance:GetInvestTargetInfoByType(invest_type)

	self.consume = cfg.consume
	self.reward_gold_num = cfg.reward_gold_bind
	self.active_text = cfg.active_reward_limit
	self.reward_item = target_info
	self.finish_num = KaifuActivityData.Instance:GetFinishNum(invest_type)
	self.recive_num = KaifuActivityData.Instance:GetReciveNum()[type_seq[invest_type]]

	if self.state == INVEST_STATE.complete then
		self.button_text = Language.Activity.FlagAlreadyReceive
	elseif self.state == INVEST_STATE.outtime or self.state == INVEST_STATE.no_invest then
		self.button_text = Language.Activity.FlagImmediateInvestment
	else
		self.button_text = Language.Activity.FlagCanAlreadyReceive
	end

	self.remind_text = string.format(Language.KaiFuInvestRemind[invest_type],KaifuActivityData.Instance:GetParam(invest_type))
	--等待策划目前的需求更改,有可能是完成后不再显示时间,先注释
	local least_time = KaifuActivityData.Instance:GetLeastTime(invest_type + 1)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(least_time, 1, function ()
		least_time = least_time - 1
		local time_tab = TimeUtil.Format2TableDHMS(least_time)
		self:SetTime(time_tab)
	end)
end

function KaifuActivityPanelFifteen:ChooseTab()
	for i = 0, MAX_TOGGLE_NUM - 1 do
		if KaifuActivityData.Instance:ShowInvestTypeRedPoint(i) then
			self.tab_index = i
			for k = 0, MAX_TOGGLE_NUM - 1 do
				if k == i then
					self.node_list["ToggleActive" .. k + 1].toggle.isOn = true
				else
					self.node_list["ToggleActive" .. k + 1].toggle.isOn = false
				end
			end
			return
		else
			self.tab_index = 0
			--没的话默认选第一个
			for k = 0, MAX_TOGGLE_NUM - 1 do
				if k == self.tab_index then
					self.node_list["ToggleActive" .. k + 1].toggle.isOn = true
				else
					self.node_list["ToggleActive" .. k + 1].toggle.isOn = false
				end
			end
		end
	end
end

function KaifuActivityPanelFifteen:OnFlush()
	self:InitData()
	self:SetDataView()
	self:ShowView()
end

function KaifuActivityPanelFifteen:SetDataView()
	self.node_list["TxtInverstNum"].text.text = self.consume
	self.node_list["TxtRewardGoldNum"].text.text = self.reward_gold_num
	for k, v in pairs(self.target_list) do
		local invest_type  = KAIFU_INVEST_TAB_TO_TYPE[self.tab_index]
		v:SetData(self.reward_item[k].reward_item[0], self.reward_item[k].param, invest_type, self.recive_num + 1)
	end
	self.node_list["TxtActiveNum"].text.text = self.active_text
	self.node_list["TxtInBtn"].text.text = self.button_text
	if self.state == INVEST_STATE.outtime then
		self.node_list["TxtLastTime"].text.text = Language.Activity.ActivityTouZiEndTips
	end
	self.node_list["TxtRemind"].text.text = self.remind_text
end

function KaifuActivityPanelFifteen:SetTime(time_tab)
	if time_tab.day > 0 then
		self.node_list["TxtLastTime"].text.text = string.format(Language.Activity.ActivityTime6, time_tab.day, time_tab.hour)
	else
		local time_str = string.format("%02d:%02d:%02d", time_tab.hour, time_tab.min, time_tab.s)
		self.node_list["TxtLastTime"].text.text = string.format(Language.Activity.ActivityTime1, time_str)
	end
end

function KaifuActivityPanelFifteen:ShowView()
	if self.state == INVEST_STATE.no_invest or self.state == INVEST_STATE.finish then
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], true)
	else
		UI:SetButtonEnabled(self.node_list["BtnGetReward"], false)
	end

	for i = 1, MAX_TOGGLE_NUM do
		self.node_list["ImgRedPoint" .. i]:SetActive(KaifuActivityData.Instance:ShowInvestTypeRedPoint(i - 1))
	end

	for i = 1, self.recive_num do
		self.target_list[i]:ShowGet()
	end
	if self.state == INVEST_STATE.finish or self.state == INVEST_STATE.no_finish then

		local invest_type = KAIFU_INVEST_TAB_TO_TYPE[self.tab_index]
		if invest_type == KAIFU_INVEST_TYPE.BOSS then
			self.node_list["BtnGoToBoss"]:SetActive(true)
			self.node_list["BtnGoToGet"]:SetActive(false)
		elseif invest_type == KAIFU_INVEST_TYPE.ACTIVE then
			self.node_list["BtnGoToBoss"]:SetActive(false)
			self.node_list["BtnGoToGet"]:SetActive(true)
		else
			self.node_list["BtnGoToBoss"]:SetActive(false)
			self.node_list["BtnGoToGet"]:SetActive(false)
		end

		self.node_list["TxtRemind"]:SetActive(true)
	else
		self.node_list["TxtRemind"]:SetActive(true)
		self.node_list["BtnGoToBoss"]:SetActive(false)
		self.node_list["BtnGoToGet"]:SetActive(false)
	end

end

function KaifuActivityPanelFifteen:OnClickTab(tab_index)
	if tab_index == self.tab_index then return end
	self.tab_index = tab_index
	self:Flush()
end

function KaifuActivityPanelFifteen:OnClickButton()
	local invest_type = KAIFU_INVEST_TAB_TO_TYPE[self.tab_index]
	if self.state == INVEST_STATE.no_invest then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(2176, 1, invest_type, 0)
	elseif self.state == INVEST_STATE.finish then
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(2176, 2, invest_type, self.recive_num)
	end
end

function KaifuActivityPanelFifteen:OnClickBoss()
	ViewManager.Instance:Close(ViewName.KaifuActivityView)
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

function KaifuActivityPanelFifteen:OnClickActive()
	ViewManager.Instance:Close(ViewName.KaifuActivityView)
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

----------------------------奖励格子----------------------------
TargetCell = TargetCell or BaseClass(BaseRender)

function TargetCell:__init(instance,i)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["CellRewardItem"])
	self.index = i
end

function TargetCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function TargetCell:SetData(data, text, invest_type, next_recive_num)
	self.item:SetData(data)
	
	local title_str = string.format(Language.KaiFuInvest[invest_type], text)
	self.node_list["TxtCellTitle"].text.text = title_str
	self.node_list["NodeHasGetContent"]:SetActive(false)
	
	if self.index == next_recive_num then
		self.node_list["ImgFrameHighLight"]:SetActive(true)
	else
		self.node_list["ImgFrameHighLight"]:SetActive(false)
	end
end

function TargetCell:ShowGet()
	self.node_list["NodeHasGetContent"]:SetActive(true)
end