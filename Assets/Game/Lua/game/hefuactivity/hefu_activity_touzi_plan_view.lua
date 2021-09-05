HeFuTouZiView = HeFuTouZiView or BaseClass(BaseRender)

function HeFuTouZiView:__init()
	HefuActivityData.Instance:IsOpenHeFuTouZi()
	for i = 1, 7 do
		self.node_list["button_" .. i].button:AddClickListener(BindTool.Bind(self.ClickReward, self, i))
	end

	self.node_list["ButtonBuy"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self, i))
end

function HeFuTouZiView:__delete()
end

function HeFuTouZiView:OpenCallBack()
	self:Flush()
end

function HeFuTouZiView:ClickBuy()
	local info = HefuActivityData.Instance:GetTouZiInfo()
	if nil == info or nil == next(info) or info.csa_touzijihua_buy_flag == 1 then
		return
	end

	local reward_cfg = HefuActivityData.Instance:GetHeFuTouZiCfg()
	local buy_money = reward_cfg.touzi_jihua_buy_cost or 0

	RechargeCtrl.Instance:Recharge(buy_money / 10)
end

function HeFuTouZiView:ClickReward(index)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI, 1 , index - 1)
end

function HeFuTouZiView:OnFlush()
	local info = HefuActivityData.Instance:GetTouZiInfo()
	if nil == info or nil == next(info) then
		return
	end

	local reward_cfg = HefuActivityData.Instance:GetHeFuTouZiCfg()
	local buy_money = reward_cfg.touzi_jihua_buy_cost or 0
	local reward_money_now = reward_cfg.touzi_jihua_buy_reward_gold or 0
	local login_day = info.csa_touzjihua_login_day or 0
	local csa_touzijihua_total_fetch_flag = bit:d2b(info.csa_touzijihua_total_fetch_flag)
	if login_day > 7 then
		login_day = 7
	end

	-- self.node_list["TextMoney"].text.text = buy_money
	self.node_list["reward_now"].text.text = reward_money_now
	self.node_list["spend_money"].text.text = string.format(Language.Activity.ButtonText10,buy_money / 10)
	local is_active = info.csa_touzijihua_buy_flag == 0
	UI:SetButtonEnabled(self.node_list["ButtonBuy"], is_active)
	UI:SetGraphicGrey(self.node_list["ButtonBuy"], not is_active)

	if info.csa_touzijihua_buy_flag == 1 then
		self.node_list["spend_money"].text.text = Language.Activity.ButtonText2

		UI:SetButtonEnabled(self.node_list["ButtonBuy"], false)
		UI:SetGraphicGrey(self.node_list["ButtonBuy"], true)
		for i= 1, 7 do
			if i <= login_day then
				self.node_list["button_" .. i]:SetActive(true)
			else
				self.node_list["button_" .. i]:SetActive(false)
			end
		end

		for i = 1, login_day do
			if csa_touzijihua_total_fetch_flag[32 - i + 1] == 0 then
				UI:SetButtonEnabled(self.node_list["button_" .. i], true)
				UI:SetGraphicGrey(self.node_list["button_" .. i], false)
				self.node_list["button_text_" .. i].text.text = Language.Activity.ButtonText1
			elseif csa_touzijihua_total_fetch_flag[32 - i + 1] == 1 then
				UI:SetButtonEnabled(self.node_list["button_" .. i], false)
				UI:SetGraphicGrey(self.node_list["button_" .. i], true)
				self.node_list["button_text_" .. i].text.text = Language.Activity.ButtonText9
			end
		end
	else
		UI:SetButtonEnabled(self.node_list["ButtonBuy"], true)
		UI:SetGraphicGrey(self.node_list["ButtonBuy"], false)
	end

	for i = 1, 7 do
		local reward = HefuActivityData.Instance:TouZiRewardDay(i) or 0
		self.node_list["reward_day_" .. i].text.text = reward
	end
end