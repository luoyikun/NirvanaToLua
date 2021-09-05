-- 等级投资-LevelInvestment
LEVEL_INVEST_T = {600, 1980, 3280, 6480}

LevelInvestmentView = LevelInvestmentView or BaseClass(BaseRender)

function LevelInvestmentView:__init(instance)
	self.node_list["BtnInvestment"].button:AddClickListener(BindTool.Bind(self.OnClickInvestment, self))
	self.node_list["BtnTip"].button:AddClickListener(BindTool.Bind(self.OnClickLevelInvestTip, self))
	local level_text = ToColorStr(PlayerData.GetLevelString(InvestData.Instance:GetMaxLevel()), TEXT_COLOR.YELLOW)
	self.node_list["TxtRightTop"].text.text = string.format(Language.Vip.InvestTimeLimit, level_text)

	self.plan_type = 0
	self:InitScroller()

	for i = 1, 4 do
		self.node_list["BtnGroupPurchase" .. i].toggle:AddClickListener(BindTool.Bind(self.OnInvestmentCostChange, self, 4 - i))
		self.node_list["TxtGroupNum" .. i].text.text = LEVEL_INVEST_T[5 - i]
		self.node_list["TxtHightGroupNum" .. i].text.text = LEVEL_INVEST_T[5 - i]
	end
	RemindManager.Instance:SetRemindToday(RemindName.Invest)
end

function LevelInvestmentView:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function LevelInvestmentView:InitScroller()
	self.cell_list = {}
	local delegate = self.node_list["List"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #InvestData.Instance:GetPlanAuto(self.plan_type)
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]
		if nil == target_cell then
			self.cell_list[cell] =  LevelInvestmentCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		
		local data = InvestData.Instance:GetPlanAuto(self.plan_type)

		local cell_data = data[data_index]
		target_cell:SetData(cell_data)
	end
end

function LevelInvestmentView:OnInvestmentCostChange(index)
	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	if index < highest_plan then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.YiTouZiGengGaoDangCi)
		return
	end	
	self.plan_type = index
	self:OnFlush()
end

function LevelInvestmentView:OpenCallBack()
	local index = InvestData.Instance:GetActiveHighestPlan()
	index = index ~= -1 and 4 - index or 1
	self.plan_type = 4 - index
	self.node_list["BtnGroupPurchase" .. index].toggle.isOn = true
	self:OnFlush()
	if not InvestData.FIRST_LEVEL_REMIND then
		InvestData.FIRST_LEVEL_REMIND = true
		local kaifu_activity_view = KaifuActivityCtrl.Instance:GetView()
		RemindManager.Instance:Fire(RemindName.KaiFu)
		
		kaifu_activity_view:Flush()
	end
end

function LevelInvestmentView:OnClickInvestment()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	local invest_price = other_cfg["plan_" .. self.plan_type .. "_price"] or 0
	local extrace_price = other_cfg["plan_" .. highest_plan .. "_price"] or 0
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold

	local func = function ()
		if role_gold >= invest_price or (highest_plan > -1 and role_gold >= invest_price - extrace_price) then
			InvestCtrl.Instance:SendTouzijihuaActive(self.plan_type)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end

	local desc = ""
	if highest_plan < 0 then
		desc = string.format(Language.Common.InvestTips, invest_price)
	else
		desc = string.format(Language.Common.ExtraceInvestTips, invest_price - extrace_price)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, desc)
end

function LevelInvestmentView:OnClickLevelInvestTip()
	TipsCtrl.Instance:ShowHelpTipView(156)
end

function LevelInvestmentView:OnFlush()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local gold = GameVoManager.Instance:GetMainRoleVo().gold
	local bind_gold = CommonDataManager.ConverMoney(PlayerData.Instance.role_vo.bind_gold)
	self.node_list["TxtGoldCost"].text.text = CommonDataManager.ConverMoney(gold) or 0
	self.node_list["TxtBindGoldCost"].text.text = bind_gold

	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	local can_invest_level = highest_plan < self.plan_type and InvestData.Instance:CanInvestLevel(self.plan_type)

	local plan_type_flag = highest_plan < self.plan_type
	local invest_level_falg = InvestData.Instance:CanInvestLevel(self.plan_type)

	if highest_plan < 0 then
		self.node_list["TxtInvestmentBtn"].text.text = Language.Activity.LiJiTouZi
	elseif highest_plan >= 3 then
		self.node_list["TxtInvestmentBtn"].text.text = Language.Activity.YiWeiZuiGaoDangCi
	else
		self.node_list["TxtInvestmentBtn"].text.text = Language.Activity.ZhuiJiaTouZi
	end

	for i = 1, 4 do
		if i + highest_plan > 4 then
			self.node_list["BtnGroupPurchase" .. i].toggle.interactable = false
		end
	end

	UI:SetButtonEnabled(self.node_list["BtnInvestment"], can_invest_level)

	local cur_plan = InvestData.Instance:GetActiveHighestPlan()
	self.node_list["TxtDec1"].text.text = cur_plan < 0 and Language.Investment.CurPlan[1] or string.format(Language.Investment.CurPlan[2], other_cfg["plan_" .. cur_plan .. "_price"] or 0)
	
	if self.node_list["List"].scroller.isActiveAndEnabled then
		self.node_list["List"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	self.node_list["TxtHasInvest"].text.text = other_cfg["plan_" .. cur_plan .. "_price"] or 0

	for i = 1, 4 do
		self.node_list["ImgRedPoint" .. i]:SetActive(InvestData.Instance:GetLevelRemind(4 - i))
	end
end

---------------------------------------------------------------
--滚动条格子-InvestmentItem

LevelInvestmentCell = LevelInvestmentCell or BaseClass(BaseCell)

function LevelInvestmentCell:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))
end

function LevelInvestmentCell:__delete()

end

function LevelInvestmentCell:ClickReward()
	if self.data == nil then return end
	InvestCtrl.Instance:SendFetchTouZiJiHuaReward(self.data.type, self.data.seq)
end

function LevelInvestmentCell:OnFlush()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local plan_cost = other_cfg["plan_" .. self.data.type .. "_price"] or 0
	local has_reward = InvestData.Instance:GetNormalInvestHasReward(self.data.type, self.data.seq)
	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	local level = PlayerData.Instance.role_vo.level


	local is_enable = (highest_plan == self.data.type and self.data.need_level <= level and not has_reward)
	UI:SetButtonEnabled(self.node_list["Btn"], is_enable)


	self.node_list["Btn"]:SetActive(not has_reward)
	self.node_list["ImgGet"]:SetActive(has_reward)

	self.node_list["TxtBtn"].text.text = has_reward and Language.Common.YiLingQu or Language.Common.LingQu
	local gold = 0
	if self.data.type > 0  then
		gold = InvestData.Instance:GetHasRewardGoldByTypeAndSeq(self.data.type, self.data.seq)
	end
	self.node_list["TextFanLi"].text.text = self.data.reward_gold_bind - gold

	self.node_list["NodeEffect"]:SetActive(not has_reward and is_enable)

	self.node_list["TextLeiJiFanLi"].text.text = InvestData.Instance:GetLeiJiFanLi(self.data.type, self.data.seq)
	self.node_list["TextShowLevel"].text.text = InvestData.Instance:GetTextShow(self.data.need_level)
end