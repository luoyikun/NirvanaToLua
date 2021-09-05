BuyExpView = BuyExpView or BaseClass(BaseView)

function BuyExpView:__init()
	self.ui_config = {"uis/views/serveractivity/buyexpview_prefab", "BuyExpView"}
	self.play_audio = true
end

function BuyExpView:__delete()

end

function BuyExpView:ReleaseCallBack()
	self.act_time = nil
	self.is_show_coppery = nil
	self.is_show_silver = nil
	self.is_show_obj = nil
	for i=1,3 do
		self.gold_list[i] = nil
		self.level_list[i] = nil
		self.button_gray_list = nil
	end
	self.gold_list = {}
	self.level_list = {}
	self.button_gray_list = {}
	if self.time_quest then
      GlobalTimerQuest:CancelQuest(self.time_quest)
      self.time_quest = nil
    end
end

function BuyExpView:LoadCallBack()
	self.act_time = self:FindVariable("act_time")
	self.is_show_coppery = self:FindVariable("is_show_coppery")
	self.is_show_silver = self:FindVariable("is_show_silver")
	self.is_show_obj = self:FindVariable("is_show_obj")
	self.gold_list = {}
	self.level_list = {}
	self.button_gray_list = {}
	for i=1,3 do
		self.gold_list[i] = self:FindVariable("gold_"..i)
		self.level_list[i] = self:FindVariable("level_"..i)
		self.button_gray_list[i] = self:FindVariable("button_gray_"..i)
	end

	self:ListenEvent("Close",BindTool.Bind(self.Close,self))
	self:ListenEvent("OnClickBuy1",BindTool.Bind(self.OnClickBuy1,self))
	self:ListenEvent("OnClickBuy2",BindTool.Bind(self.OnClickBuy2,self))
	self:ListenEvent("OnClickBuy3",BindTool.Bind(self.OnClickBuy3,self))
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
		self.is_show_coppery:SetValue(false)
		self.is_show_silver:SetValue(false)
	elseif world_level - level == 2 then
		self.is_show_coppery:SetValue(false)
		self.is_show_silver:SetValue(true)
		self.is_show_obj:SetValue(false)
		self.is_show_obj:SetValue(true)
	else
		self.is_show_coppery:SetValue(true)
		self.is_show_silver:SetValue(true)
		self.is_show_obj:SetValue(false)
		self.is_show_obj:SetValue(true)
	end

	local is_purchased = BuyExpData.Instance:GetRAExpRefineInfo().had_buy
	-- local act_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BUYEXP)
	-- local time = TimeUtil.Format2TableDHMS(act_time)
	-- self.act_time:SetValue(string.format(Language.ConsumeReward.ResTime2,time.hour,time.min,time.s))
	local cfg_list = BuyExpData.Instance:GetCanBuyLevelAndGold()
	for i=1,3 do
		self.level_list[i]:SetValue(string.format(Language.HefuActivity.BuyExpStr,cfg_list["level_"..i]))
		self.gold_list[i]:SetValue(cfg_list["gold_num_"..i])
		self.button_gray_list[i]:SetValue(is_purchased == 0)
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
  local time_type = 1
  if time > 3600 * 24 then
    time_type = 7
  elseif time > 3600 then
    time_type = 1
  else
    time_type = 4
  end

  self.act_time:SetValue(TimeUtil.FormatSecond2Str(time))
end
