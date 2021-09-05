TeamExpBuyTips = TeamExpBuyTips or BaseClass(BaseView)
-- 多人经验本购买次数
function TeamExpBuyTips:__init()
	self.ui_config = {{"uis/views/fubenview_prefab", "ExpBuyCountTips"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true									-- 是否模态
	self.is_any_click_close = true							-- 是否点击其它地方要关闭界面
	self.fb_type = 0
end

function TeamExpBuyTips:__delete()

end

function TeamExpBuyTips:ReleaseCallBack()
	if self.delay_flush then
		GlobalTimerQuest:CancelQuest(self.delay_flush)
		self.delay_flush = nil
	end
end

function TeamExpBuyTips:LoadCallBack(index, loaded_times)
	self.node_list["BtnYes"].button:AddClickListener(BindTool.Bind(self.OnClickYes, self))
	self.node_list["BtnNo"].button:AddClickListener(BindTool.Bind(self.OnClickGoToVip, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCancel, self))
end

function TeamExpBuyTips:OpenCallBack()

end

function TeamExpBuyTips:ShowIndexCallBack()
	self:Flush()
end

function TeamExpBuyTips:OnClickCancel()
	self:Close()
end

function TeamExpBuyTips:OnClickGoToVip()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TeamExpBuyTips:OnClickYes()
	if self.ok_func ~= nil then
		self.ok_func()
	end
	if self.max_buy_times - self.totla_buy_times  <= 0  then
		self:OnClickCancel()
		return
	end

	if self.delay_flush then
		GlobalTimerQuest:CancelQuest(self.delay_flush)
		self.delay_flush = nil
	end
	local func = function()
		self:Flush()
	end
	self.delay_flush = GlobalTimerQuest:AddDelayTimer(func, 0.1)
	 
end

function TeamExpBuyTips:CloseCallBack()
	self.ok_func = nil
end

-- pay_money 需要的元宝
-- buy_times 今天购买的次数
-- max_times 最大购买次数
-- show_next 是否显示下一级VIP信息 callback
function TeamExpBuyTips:SetData(pay_money, buy_times, max_times, next_max_times, vip_power_id, callback, tableback, text_type, desc)
	if not self.ok_func then
		self.ok_func = callback
	end
	self.pay_money = pay_money or 0
	self.totla_buy_times = buy_times or 0
	self.max_buy_times = max_times or 0
	self.next_max_times = next_max_times or 0
	self.vip_power_id = vip_power_id or 0
	self.setdata_func = tableback or nil
	self.text_type = text_type or 0
	self.desc = desc or "%s"
	if self.root_node ~= nil then
		self:Flush()
	end
end

function TeamExpBuyTips:OnFlush(param_t, index)
	if self.ok_func == nil then return end

	if self.setdata_func then
		local data = self.setdata_func()
		self.pay_money = data[1]
		self.totla_buy_times = data[2]
		self.max_buy_times = data[3]
		self.next_max_times = data[4]
	end

	if self.max_buy_times - self.totla_buy_times > 0 then
		local str = ""
		if self.text_type == 0 then
			str = string.format(Language.FuBen.CopperBuyNum, self.pay_money)
		elseif self.text_type == 1 then
			str = string.format(self.desc, ToColorStr(self.pay_money, TEXT_COLOR.GOLD))
		end
		self.node_list["TipContent"].text.text = str
	else
		self.node_list["TipContent"].text.text = Language.FuBen.MaxBuyTimes
		-- self:OnClickCancel()
	end

	local role_info = GameVoManager.Instance:GetMainRoleVo()
	local vip_level = PlayerData.Instance.role_vo.vip_level
	-- local next_level, next_times = VipPower.Instance:GetMinVipLevelLimit(self.vip_power_id, self.max_buy_times + 1)
	local next_level, next_times = VipPower.Instance:GetNextVipLevelLimint(self.vip_power_id, vip_level)
	self.node_list["TextCurLevle"].text.text = string.format(Language.Vip.RewardOf, role_info.vip_level)
	self.node_list["NextCurLevle"].text.text = string.format(Language.Vip.RewardOf, next_level)
	self.node_list["TextCurCount"].text.text = string.format(Language.FuBen.CopperBuyTips, self.max_buy_times - self.totla_buy_times, self.max_buy_times)
	self.node_list["NextCurCount"].text.text = string.format(Language.FuBen.CopperBuyTips2, next_times)
	
	local max_level = VipData.Instance:GetVipMaxLevel()
	self.node_list["NextBg"]:SetActive(next_level >= 0)
	self.node_list["NextVip"]:SetActive(next_level >= 0 )
end
