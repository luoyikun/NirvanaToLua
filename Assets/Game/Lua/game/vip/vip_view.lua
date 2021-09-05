require("game/vip/vip_content_view")
require("game/vip/recharge_content_view")
-- require("game/vip/level_investment_view")
-- require("game/vip/month_investment_view")
VipView = VipView or BaseClass(BaseView)

function VipView:__init()
	VipView.Instance = self
	self.ui_config = {
		{"uis/views/vipview_prefab", "VipPanelView"},
		{"uis/views/vipview_prefab", "Panel"},
	}

	self.full_screen = false
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Openchognzhi)
	end

	self.play_audio = true
	self.def_index = 1
	self.is_modal = true
end

function VipView:__delete()
	VipView.Instance = nil
end

function VipView:LoadCallBack()
	self.node_list["Name"].text.text = Language.Common.Recharge
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseBtnClick, self))
	self.node_list["BtnRecharge"].button:AddClickListener(BindTool.Bind(self.RechargeClick, self))
	self.node_list["BtnVip"].button:AddClickListener(BindTool.Bind(self.VipClick, self))

	self.toggle_list = {}
	for i = 1, 4 do
		self.toggle_list[i] = self.node_list["Toggle" .. i]
		self.toggle_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, i))
	end

	if IS_AUDIT_VERSION then
		self.node_list["ToggleGroup2"]:SetActive(false)
		if ResMgr.ExistedInStreaming("AgentAssets/Recharge/recharge_vip_bg.png") then
			self.node_list["vip_bg"]:SetActive(false)
			self.node_list["vip_bg_url"]:SetActive(true)

			local path = ResUtil.GetAgentAssetPath("AgentAssets/Recharge/recharge_vip_bg.png")
			self.node_list["vip_bg_url"].raw_image:LoadURLSprite(path)
		end
	end

	self.rechange_content_view = RechargeContentView.New(self.node_list["RechargeContentPanel"])
	-- self.level_investment_view = LevelInvestmentView.New(self.node_list["LevelInvestment"])
	-- self.month_investment_view = MonthCardInvestmentView.New(self.node_list["MonthCardInvestment"])
	self.vip_content_view = VipContentView.New(self.node_list["VipContentPanel"])

	self.is_first_open = true
	self.max_vip_level = VipData.Instance:GetVipMaxLevel()
end

function VipView:OnCloseBtnClick()
	self:Close()
end

function VipView:OpenCallBack()
	self:ShowOrHideTab()
	self.event_quest = GlobalEventSystem:Bind(
		OpenFunEventType.OPEN_TRIGGER,
		BindTool.Bind(self.ShowOrHideTab, self))

	if VipData.Instance:GetOpenType() == OPEN_VIP_RECHARGE_TYPE.VIP then
		self.node_list["NodeVipTopFrame"]:SetActive(not IS_AUDIT_VERSION)
		self.node_list["NodeRechargeTopFrame"]:SetActive(false)
	elseif VipData.Instance:GetOpenType() == OPEN_VIP_RECHARGE_TYPE.RECHANRGE then
		self.node_list["NodeVipTopFrame"]:SetActive(false)
		self.node_list["NodeRechargeTopFrame"]:SetActive(not IS_AUDIT_VERSION)
	end
end

function VipView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(show_list) do
		self.toggle_list[k]:SetActive(v)
	end
end

function VipView:ReleaseCallBack()
	if self.vip_content_view then
		self.vip_content_view:DeleteMe()
		self.vip_content_view = nil
	end

	if self.rechange_content_view then
		self.rechange_content_view:DeleteMe()
		self.rechange_content_view = nil
	end

	-- if self.level_investment_view then
	-- 	self.level_investment_view:DeleteMe()
	-- 	self.level_investment_view = nil
	-- end

	-- if self.month_investment_view then
	-- 	self.month_investment_view:DeleteMe()
	-- 	self.month_investment_view = nil
	-- end

	-- 清理变量和对象
	if self.toggle_list and self.toggle_list[OPEN_VIP_RECHARGE_TYPE.RECHANRGE] and self.toggle_list[OPEN_VIP_RECHARGE_TYPE.RECHANRGE].toggle then
		self.toggle_list[OPEN_VIP_RECHARGE_TYPE.RECHANRGE].toggle.isOn = true
	end
	self.toggle_list = {}
end

function VipView:OnToggleChange(index, isOn)
	if self.toggle_list and self.toggle_list[index] and isOn and VipData and VipData.Instance then
		VipData.Instance:SetOpenType(index)
		self.def_index = index
		self:ChangeToIndex(index)
	end
end

function VipView:ShowIndexCallBack(index)
	self.toggle_list[index].toggle.isOn = true
	self.node_list["di"]:SetActive(true)
	self.node_list["di2"]:SetActive(false)
	if index == OPEN_VIP_RECHARGE_TYPE.RECHANRGE then
		self.node_list["NodeVipTopFrame"]:SetActive(false)
		self.node_list["NodeRechargeTopFrame"]:SetActive(not IS_AUDIT_VERSION)
		-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
		self:CalTimeToFlush()
		self.node_list["di"]:SetActive(false)
		self.node_list["di2"]:SetActive(true)

	elseif index == OPEN_VIP_RECHARGE_TYPE.LEVEL_INVEST then
		self.level_investment_view:OpenCallBack()
		self.level_investment_view:Flush()
		-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.LEVEL_INVEST)

	elseif index == OPEN_VIP_RECHARGE_TYPE.MONTH_INVEST then
		self.month_investment_view:Flush()
		-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.MONTH_INVEST)

	elseif index == OPEN_VIP_RECHARGE_TYPE.VIP then
		self.node_list["di"]:SetActive(false)
		self.node_list["di2"]:SetActive(true)
		self.node_list["NodeVipTopFrame"]:SetActive(not IS_AUDIT_VERSION)
		self.node_list["NodeRechargeTopFrame"]:SetActive(false)
		-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		self:CalTimeToFlush()

	else
		self.toggle_list[1].toggle.isOn = true
		self:CalTimeToFlush()
	end

	self:Flush()

end

function VipView:CloseCallBack()
	self.is_first_open = true
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.NONE)
	self.vip_content_view:SetActive(true)
	self.rechange_content_view:SetActive(true)
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function VipView:RechargeClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	self.rechange_content_view:SetActive(true)
	self.vip_content_view:SetActive(false)
	if VipData.Instance:GetOpenType() == OPEN_VIP_RECHARGE_TYPE.RECHANRGE then
		self.node_list["NodeVipTopFrame"]:SetActive(false)
		self.node_list["NodeRechargeTopFrame"]:SetActive(not IS_AUDIT_VERSION and true)
	end
	self.toggle_list[OPEN_VIP_RECHARGE_TYPE.RECHANRGE].toggle.isOn = true
end

function VipView:VipClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	self.rechange_content_view:SetActive(false)
	self.vip_content_view:SetActive(true)
	if VipData.Instance:GetOpenType() == OPEN_VIP_RECHARGE_TYPE.VIP then
		self.node_list["NodeVipTopFrame"]:SetActive(true)
		self.node_list["NodeRechargeTopFrame"]:SetActive(not IS_AUDIT_VERSION and false)
	end
	self:CalTimeToFlush()
end

function VipView:VipPowerClick()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	self.vip_content_view:OpenCallBack()
	self.rechange_content_view:SetActive(false)
	self.vip_content_view:SetActive(true)
	if self.is_first_open then
		local vip_level = VipData.Instance:GetVipInfo().vip_level
		self.vip_content_view:SetCurrentVipId(vip_level)
		self.vip_content_view:FlushRewardState()
	end
	self.vip_content_view:JumpToCurrentVip()
	self.is_first_open = false
end

function VipView:CalTimeToFlush()
	local open_type = VipData.Instance:GetOpenType()
	self.toggle_list[open_type].toggle.isOn = true
	if open_type == OPEN_VIP_RECHARGE_TYPE.VIP then
		
		self:VipPowerClick()
		local vip_level = VipData.Instance:GetVipInfo().vip_level
		for i = 1, vip_level do
			if VipData.Instance:GetIsVipRewardByVipLevel(i) then
				vip_level = i
				break
			end
		end
		self.vip_content_view:SetCurrentVipId(vip_level)
		self.vip_content_view:FlushRewardState()
		
	elseif open_type == OPEN_VIP_RECHARGE_TYPE.RECHANRGE then
		self:RechargeClick()
	end
end

function VipView:OpenTeToggle()
	self.toggle_list[2].toggle.isOn = true
end


function VipView:OnFlush(param_list)
	local index = self:GetShowIndex()
	if index == 1 or index == 4 then
		local current_vip_id = VipData.Instance:GetVipInfo().vip_level
		self.node_list["TxtVip"].text.text = current_vip_id
		self.node_list["TxtVip2"].text.text = current_vip_id

		if current_vip_id < self.max_vip_level then
			self.node_list["TxtAll1"]:SetActive(true)
			self.node_list["TxtAllText1"]:SetActive(true)
			self.node_list["NodeAllText"]:SetActive(true)
			self.node_list["TxtProgress"]:SetActive(true)
			self.node_list["NodeAllText2"]:SetActive(true)
			self.node_list["Txt"]:SetActive(true)

			self.node_list["TxtDesc"]:SetActive(false)
			self.node_list["TxtDesc2"]:SetActive(false)
		else
			self.node_list["TxtAll1"]:SetActive(false)
			self.node_list["TxtAllText1"]:SetActive(false)
			self.node_list["NodeAllText"]:SetActive(false)
			self.node_list["TxtProgress"]:SetActive(false)
			self.node_list["NodeAllText2"]:SetActive(false)
			self.node_list["Txt"]:SetActive(false)
			self.node_list["TxtDesc"]:SetActive(true)
			self.node_list["TxtDesc2"]:SetActive(true)
		end
		local total_exp = VipData.Instance:GetVipExp(current_vip_id)
		local passlevel_consume = VipData.Instance:GetVipExp(current_vip_id - 1)
		local current_exp = VipData.Instance:GetVipInfo().vip_exp + passlevel_consume
		if current_vip_id < self.max_vip_level then
			self.node_list["TxtRechargeNextVip"].text.text = current_vip_id + 1
			self.node_list["TxtVIPTopNextVip"].text.text = current_vip_id + 1


			self.node_list["TxtAll1"].text.text = total_exp - current_exp
			self.node_list["TxtAllText1"].text.text = total_exp - current_exp
		end
		if current_vip_id == self.max_vip_level then
			self.node_list["SliderProgress"].slider.value = 1
			self.node_list["SliderProgress2"].slider.value = 1
		else
			self.node_list["SliderProgress"].slider.value = current_exp / total_exp
			self.node_list["SliderProgress2"].slider.value = current_exp / total_exp

			self.node_list["TxtProgress"].text.text = string.format("%s/%s", current_exp, total_exp)
			self.node_list["Txt"].text.text = string.format("%s/%s", current_exp, total_exp)
		end
		self.rechange_content_view:OnFlush()
	elseif index == 2 then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if cur_day > -1 then
			PlayerPrefsUtil.SetInt("level_invest_remind_day", cur_day)
			RemindManager.Instance:Fire(RemindName.Invest)
		end
		self.level_investment_view:Flush()
	elseif index == 3 then 
		self.month_investment_view:Flush()
	end

	self.node_list["ImgRedPointToggle2"]:SetActive(InvestData.Instance:GetNormalInvestRemind() > 0)
	self.node_list["ImgRedPointToggle3"]:SetActive(InvestData.Instance:GetMonthInvestRemind() > 0)
	self.node_list["ImgRedPointToggle1"]:SetActive(RechargeData.Instance:DayRechangeCanReward())
	self.node_list["ImgRedPointToggle4"]:SetActive(VipData.Instance:GetIsGetVipRewardFlag() > 0)
end

function VipView:FlushRewardState()
	if self.vip_content_view and not IsNil(self.vip_content_view:GetListView().scroller) then
		self.vip_content_view:FlushRewardState()
	end
end