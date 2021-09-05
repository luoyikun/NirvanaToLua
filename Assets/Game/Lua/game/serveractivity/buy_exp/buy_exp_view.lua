BuyExpView = BuyExpView or BaseClass(BaseView)

function BuyExpView:__init()
	self.ui_config = {{"uis/views/serveractivity/buyexpview_prefab", "BuyExpView"}}
	self.play_audio = true
	self.is_modal = true
	-- self.is_any_click_close = true
end

function BuyExpView:__delete()

end

function BuyExpView:ReleaseCallBack()
	for i=1,3 do
		self.gold_list[i] = nil
		self.level_list[i] = nil
		self.button_gray_list = nil
	end
	self.gold_list = {}
	self.level_list = {}

	if self.time_quest then
      GlobalTimerQuest:CancelQuest(self.time_quest)
      self.time_quest = nil
    end
end

function BuyExpView:LoadCallBack()
	self.gold_list = {}
	self.level_list = {}
	for i=1,3 do
		self.gold_list[i] = self.node_list["TextGold" .. i]
		self.level_list[i] = self.node_list["TextLevel" .. i]
	end

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickClose,self))
	self.node_list["ButtonBuy1"].button:AddClickListener(BindTool.Bind(self.OnClickBuy1,self))
	self.node_list["ButtonBuy2"].button:AddClickListener(BindTool.Bind(self.OnClickBuy2,self))
	self.node_list["ButtonBuy3"].button:AddClickListener(BindTool.Bind(self.OnClickBuy3,self))
	-- local aaa = BuyExpData.Instance:GetCanBuyLevelAndGold()
end

function BuyExpView:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP,
							CSA_EXP_REFINE_OPERA_TYPE.CSA_EXP_REFINE_OPERA_TYPE_GET_INFO)

	if self.time_quest == nil then
   		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
    	self:FlushNextTime()
 	end
end

function BuyExpView:OnFlush()
	local other_cfg = BuyExpData.Instance:GetOtherCongig()
	local world_level = RankData.Instance:GetWordLevel() - other_cfg.buy_exp_level_limit
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if world_level - level == 1 then
		self.node_list["ShowCoppery"]:SetActive(false)
		self.node_list["ShowSilver"]:SetActive(false)
	elseif world_level - level == 2 then
		self.node_list["ShowCoppery"]:SetActive(true)
		self.node_list["ShowSilver"]:SetActive(true)
	else
		self.node_list["ShowCoppery"]:SetActive(true)
		self.node_list["ShowSilver"]:SetActive(true)
	end

	local is_purchased = BuyExpData.Instance:GetRAExpRefineInfo().had_buy
	local cfg_list = BuyExpData.Instance:GetCanBuyLevelAndGold()
	for i=1,3 do
		self.level_list[i].text.text = string.format(Language.HefuActivity.BuyExpStr,cfg_list["level_"..i])
		self.gold_list[i].text.text = cfg_list["gold_num_"..i]
		UI:SetButtonEnabled(self.node_list["ButtonBuy1"], is_purchased == 0)
	end
end

function BuyExpView:OnClickClose()
	self:Close()
end

function BuyExpView:OnClickBuy1()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP,CSA_EXP_REFINE_OPERA_TYPE.CSA_EXP_REFINE_OPERA_TYPE_BUY_EXP,0)
end

function BuyExpView:OnClickBuy2()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP,CSA_EXP_REFINE_OPERA_TYPE.CSA_EXP_REFINE_OPERA_TYPE_BUY_EXP,1)
end

function BuyExpView:OnClickBuy3()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP,CSA_EXP_REFINE_OPERA_TYPE.CSA_EXP_REFINE_OPERA_TYPE_BUY_EXP,2)
end


function BuyExpView:FlushNextTime()
	local time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["TextTime"].text.text = time_str
end
