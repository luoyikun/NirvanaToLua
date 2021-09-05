-- 周卡投资-MonthCardInvestment
MonthCardInvestmentView = MonthCardInvestmentView or BaseClass(BaseRender)

function MonthCardInvestmentView:__init(instance)
	self.node_list["BtnInvestment"].button:AddClickListener(BindTool.Bind(self.OnClickInvestment, self))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OnClickMonthCardInvest, self))

	self:InitScroller()
	self:RightPanelShow()

	self.cell_data_list = {}
	RemindManager.Instance:SetRemindToday(RemindName.MonthInvest)
end

function MonthCardInvestmentView:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	self.cell_data_list = {}
end

function MonthCardInvestmentView:OpenCallBack()
	if not InvestData.FIRST_MONTH_REMIND then
		InvestData.FIRST_MONTH_REMIND = true
		local kaifu_activity_view = KaifuActivityCtrl.Instance:GetView()
		RemindManager.Instance:Fire(RemindName.KaiFu)
		kaifu_activity_view:Flush()
	end
end


function MonthCardInvestmentView:InitScroller()
	self.cell_list = {}
	local data = InvestData.Instance:GetNewPlanAuto()
	local delegate = self.node_list["List"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  MonthCardInvestmentCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end

		local cell_data = self.cell_data_list[data_index]
		target_cell:SetData(cell_data)
	end
end

function MonthCardInvestmentView:OnClickInvestment()
	local invest_price = InvestData.Instance:GetInvestPrice()
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local func = function ()
		if role_gold >= invest_price then
			InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_BUY, 0)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.InvestTips, invest_price))
end

function MonthCardInvestmentView:OnClickMonthCardInvest()
	TipsCtrl.Instance:ShowHelpTipView(157)
end

function MonthCardInvestmentView:OnFlush()
	local invest_info = InvestData.Instance:GetInvestInfo()
	local enable = invest_info.buy_time == nil or invest_info.buy_time <= 0 or InvestData.Instance:GetMonthCardAllReward()

	self.cell_data_list = InvestData.Instance:GetItemCellData()

	self.node_list["TxtInvestmentBtn"].text.text = Language.Activity.LiJiTouZi
	if not enable then
		self.node_list["TxtInvestmentBtn"].text.text = Language.Activity.YiTouZi
	end
	UI:SetButtonEnabled(self.node_list["BtnInvestment"], enable)

	if self.node_list["List"].scroller.isActiveAndEnabled then
		self.node_list["List"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MonthCardInvestmentView:RightPanelShow()
	local price_cfg = InvestData.Instance:GetNewPlanAuto()
	local newplan_cfg = InvestData.Instance:GetNewPlanCfg()
	self.node_list["TxtGoldCost"].text.text = newplan_cfg[1].new_plan_price
	local txt_gold = InvestData.Instance:GetTouZi()
	self.node_list["TextDay"].text.text = txt_gold
	self.node_list["TextTouZiGet"].text.text = newplan_cfg[1].new_plan_reward
	local reward_count = InvestData.Instance:GetDayFanli(7)
	self.node_list["TextTotal"].text.text = reward_count + newplan_cfg[1].new_plan_reward
end

---------------------------------------------------------------
--滚动条格子-MonthInvestmentItem

MonthCardInvestmentCell = MonthCardInvestmentCell or BaseClass(BaseCell)

function MonthCardInvestmentCell:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))
end

function MonthCardInvestmentCell:__delete()

end

function MonthCardInvestmentCell:ClickReward()
	if self.data == nil then return end

	if self.data.day_index < 0 then
		InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_FIRST, 0)
	else
		InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_FETCH, self.data.day_index)
	end
end

function MonthCardInvestmentCell:OnFlush()
	local has_reward = InvestData.Instance:GetMonthCardHasReward(self.data.day_index)
	local can_reward = InvestData.Instance:GetMonthCardCanReward(self.data.day_index)
	if has_reward then
		self.node_list["ImgGet"]:SetActive(true)
		self.node_list["Btn"]:SetActive(false)
	else
		self.node_list["ImgGet"]:SetActive(false)
		self.node_list["Btn"]:SetActive(true)
	end
	self.node_list["NodeEffect"]:SetActive(can_reward and not has_reward)
	UI:SetButtonEnabled(self.node_list["Btn"], can_reward and not has_reward)
	local newplan_cfg = InvestData.Instance:GetNewPlanCfg()

	if self.data.day_index == -1 then
		self.node_list["TextLeiJiFanLi"].text.text = self.data.new_plan_reward
		self.node_list["TextFanLi"].text.text = self.data.new_plan_reward
		self.node_list["TextDay"].text.text =  Language.Activity.TouZiLiFan
	else
		if newplan_cfg[1] and newplan_cfg[1].new_plan_reward then
			local reward_count = InvestData.Instance:GetDayFanli(self.data.day_index)
			self.node_list["TextLeiJiFanLi"].text.text = reward_count + newplan_cfg[1].new_plan_reward
		end
		self.node_list["TextFanLi"].text.text = self.data.reward_gold_bind 
		self.node_list["TextDay"].text.text = string.format(Language.Activity.DayCount, Language.Common.NumToChs[self.data.day_index + 1])
	end
end