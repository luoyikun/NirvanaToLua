-- 成长基金-TouZiPlanContent
OpenActTouZiPlan = OpenActTouZiPlan or BaseClass(BaseRender)

function OpenActTouZiPlan:__init()
	self.list_data = {}
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate								--间距
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.LeftPage, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.RightPage, self))
	self.dec_num = 0
end

function OpenActTouZiPlan:__delete()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.list_data = {}
	self.dec_num = 0
end

function OpenActTouZiPlan:OnValueChanged()
	if self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition == 0 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(true)
	elseif self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition == 1 then
		self.node_list["BtnRight"]:SetActive(false)
		self.node_list["BtnLeft"]:SetActive(true)
	end
	local num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	if num - self.dec_num <= 3 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(false)
	end
end

function OpenActTouZiPlan:GetNumberOfCells()
	local num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	return num - self.dec_num
end

function OpenActTouZiPlan:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.cell_list[cell]
	if nil == icon_cell then
		icon_cell = TouZiPlanContentCell.New(cell.gameObject)
		self.cell_list[cell] = icon_cell
	end
	icon_cell:SetIndex(data_index)
	local temp_list = {}
	for i = 1, 3 do
		local cfg_index = (data_index - 1) * 3 + i
		if cfg_index >= 1 and cfg_index <= 24 and self.list_data[cfg_index] then
			table.insert(temp_list, self.list_data[cfg_index])
		end
	end
	-- 每一个cell里面需要三个数据表
	icon_cell:SetData(temp_list)
end

function OpenActTouZiPlan:OpenCallBack()
	self:Flush()

	local svr_info = InvestData.Instance:GetTouZiPlanInfo()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local level_cfg = KaifuActivityData.Instance:GetTouZicfg()
	local role_level = PlayerData.Instance:GetRoleVo().level
	-- 如果等级在规定等级段，并且没有看过会给红点，在看过界面或者升级的时候去Fire一次
	if svr_info and cfg_num and level_cfg and role_level then
		for i = 1, cfg_num do
			for k, v in pairs(level_cfg) do
				if v.seq == i - 1 and v.sub_index == 0 then
					-- 在规定等级段
					if role_level >= v.active_level_min and role_level <= v.active_level_max then
						-- 点进界面看过赋值为1
						local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
						local remind = PlayerPrefsUtil.GetInt(main_role_id .. "chengzhangjijin_remind_" .. i)
						PlayerPrefsUtil.SetInt(main_role_id .. "chengzhangjijin_remind_" .. i, 1)
						RemindManager.Instance:Fire(RemindName.KaiFu)						
					end
				end
			end		
		end
	end
end

function OpenActTouZiPlan:OnFlush()
	self.list_data, self.dec_num = KaifuActivityData.Instance:GetNewTouZicfg()
	self.node_list["ListView"].scroller:ReloadData(0)

	local num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	if num - self.dec_num <= 3 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(false)
	end
end

function OpenActTouZiPlan:LeftPage()
	self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition = 0
	self.node_list["BtnLeft"]:SetActive(false)
	self.node_list["BtnRight"]:SetActive(true)
	local num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	if num - self.dec_num <= 3 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(false)
	end	
end

function OpenActTouZiPlan:RightPage()
	self.node_list["ListView"].scroll_rect.horizontalNormalizedPosition = 1
	self.node_list["BtnRight"]:SetActive(false)
	self.node_list["BtnLeft"]:SetActive(true)
	local num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	if num - self.dec_num <= 3 then
		self.node_list["BtnLeft"]:SetActive(false)
		self.node_list["BtnRight"]:SetActive(false)
	end		
end

----------------------------TouZiPlanContentCell-----------------------------
TouZiPlanContentCell = TouZiPlanContentCell or BaseClass(BaseCell)
function TouZiPlanContentCell:__init(instance)
	self.node_list["BtnCanRechage1"].button:AddClickListener(BindTool.Bind(self.OnClickRecharge, self))
end

function TouZiPlanContentCell:__delete()

end

function TouZiPlanContentCell:OnFlush()
	if self.data == nil then
		return
	end

	local reward_seq = 0
	local money = 0
	local reward_money = 0
	local level_1 = 0
	local level_2 = 0
	local level_3 = 0
	local level_min = 0
	local level_max = 0
	local state = 0
	for i,v in ipairs(self.data) do
		reward_seq = v.seq
		money = v.gold
		reward_money = v.reward_gold
		if v.sub_index == 0 then
			level_1 = v.reward_level
		elseif v.sub_index == 1 then
			level_2 = v.reward_level
		elseif v.sub_index == 2 then
			level_3 = v.reward_level
		end
		level_min = v.active_level_min
		level_max = v.active_level_max
		state = KaifuActivityData.Instance:GetTouZiState(reward_seq + 1)
	end
	self.node_list["TextTitle1"].text.text = Language.Activity.GrowUpJiJinType[reward_seq + 1]
	self.node_list["TextMony1"].text.text = string.format(Language.Activity.GouMaiLiDeYuanBao, money)
	self.node_list["TextNext1"].text.text = reward_money
	self.node_list["TextLevel1"].text.text = string.format(Language.Activity.ButtonText5, level_1, level_2, level_3)
	self.node_list["TextCanBuy1"].text.text = string.format(Language.Activity.ButtonText7, level_min, level_max)

	-- state: 0 代表可购买， 1 代表已购买可领取， 2 代表已购买不能领取， 3 代表未购买过期, 4代表等级不够不能购买, 5 代表已领完
	if state == 0 or state == 4 then
		self.node_list["TextBtn1"].text.text = (string.format(Language.Activity.ButtonText4, money / 10))
		UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], true)
		self.node_list["Effect"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["IsGrey"], true)
		self.node_list["BigLevel"]:SetActive(false)
		self.node_list["HasLingQu"]:SetActive(false)
	elseif state == 1 then
		self.node_list["TextBtn1"].text.text = Language.Activity.ButtonText1
		UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], true)
		self.node_list["Effect"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["IsGrey"], true)
		self.node_list["BigLevel"]:SetActive(false)
		self.node_list["HasLingQu"]:SetActive(false)
	elseif state == 2 then
		self.node_list["TextBtn1"].text.text = Language.Activity.ButtonText1
		UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], false)
		self.node_list["Effect"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["IsGrey"], true)
		self.node_list["BigLevel"]:SetActive(false)
		self.node_list["HasLingQu"]:SetActive(false)
	elseif state == 3 then
		self.node_list["TextBtn1"].text.text = Language.Activity.ButtonText3
		UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], false)
		self.node_list["Effect"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["IsGrey"], false)
		self.node_list["BigLevel"]:SetActive(true)
		self.node_list["HasLingQu"]:SetActive(false)
	-- elseif state == 4 then
	-- 	self.node_list["TextBtn1"].text.text = Language.Activity.ButtonText6
	-- 	UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], true)
	-- 	self.node_list["Effect"]:SetActive(false)
	--  UI:SetButtonEnabled(self.node_list["IsGrey"], true)
	--  self.node_list["BigLevel"]:SetActive(false)
	--  self.node_list["HasLingQu"]:SetActive(false)
	elseif state == 5 then
		self.node_list["TextBtn1"].text.text = Language.Activity.ButtonText8
		UI:SetButtonEnabled(self.node_list["BtnCanRechage1"], false)
		self.node_list["Effect"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["IsGrey"], false)
		self.node_list["BigLevel"]:SetActive(false)
		self.node_list["HasLingQu"]:SetActive(true)
	end
end

function TouZiPlanContentCell:OnClickRecharge()
	if self.data == nil then
		return
	end

	local reward_seq = 0
	local money = 0
	local state = 0
	for i,v in ipairs(self.data) do
		reward_seq = v.seq
		money = v.gold
		state = KaifuActivityData.Instance:GetTouZiState(reward_seq + 1)
	end

	if state == 0 then
		RechargeCtrl.Instance:Recharge(money / 10)
	elseif state == 1 then
		InvestCtrl.Instance:SendChongzhiFetchReward(NEW_TOUZIJIHUA_OPERATE_TYPE.NEW_TOUZIJIHUA_OPERATE_FOUNDATION_FETCH, reward_seq)
	elseif state == 2 then
		return
	elseif state == 3 then
		return
	elseif state == 4 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.LevelText)
	elseif state == 5 then
		return
	end
end