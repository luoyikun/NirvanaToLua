LevelRewardView = LevelRewardView or BaseClass(BaseRender)

function LevelRewardView:__init()
	self.cell_list = {}
	self.scroller_data = WelfareData.Instance:GetLevelRewardList()
	self:InitSroller()
	self.new_delay_flush_timer = nil

	self.next_can_flush_time = 0
end

function LevelRewardView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function LevelRewardView:InitSroller()
	local scroller_delegate = self.node_list["Scroller"].page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
end

function LevelRewardView:NumberOfCellsDel()
	return #self.scroller_data
end

function LevelRewardView:CellRefreshDel(index, cellObj)
	index = index + 1
	local reward_cell = self.cell_list[cellObj]
	if not reward_cell then
		reward_cell = LevelRewardItemCell.New(cellObj)
		reward_cell:SetClickCallback(function ()
			self.next_can_flush_time = 0
		end)
		self.cell_list[cellObj] = reward_cell
	end
	reward_cell:SetData(self.scroller_data[index])
end

function LevelRewardView:Flush()
	if self.new_delay_flush_timer ~= nil then
		return
	end

	if Status.NowTime < self.next_can_flush_time then
		return
	end

	self.next_can_flush_time = Status.NowTime + 3

	self.new_delay_flush_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.new_delay_flush_timer = nil
		self.scroller_data = WelfareData.Instance:GetLevelRewardList()
		if self.node_list["Scroller"].list_view.isActiveAndEnabled then
			self.node_list["Scroller"].list_view:Reload()
			self.node_list["Scroller"].list_view:JumpToIndex(0)
		end
	end, 0)
end

-----------------------LevelRewardItemCell---------------------------------
LevelRewardItemCell = LevelRewardItemCell or BaseClass(BaseCell)

function LevelRewardItemCell:__init()
	self.item_cell_list = {}
	local child_count = self.node_list["ItemList"].transform.childCount
	for i = 0, child_count - 1 do
		local child_item_obj = self.node_list["ItemList"].transform:GetChild(i).gameObject
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(child_item_obj)
		table.insert(self.item_cell_list, item_cell)
	end

	self.click_callback = nil
	self.node_list["BtnClickGet"].button:AddClickListener(BindTool.Bind(self.ClickGet, self))
	self.node_list["ListHasRight"]:SetActive(false)
	self.node_list["ListHasAllRight"]:SetActive(false)
end

function LevelRewardItemCell:__delete()
	for k, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.click_callback = nil
end

function LevelRewardItemCell:SetClickCallback(click_callback)
	self.click_callback = click_callback
end

function LevelRewardItemCell:ClickGet()
	WelfareCtrl.Instance:SendGetLevelReward(self.data.level)
	if nil ~= self.click_callback then
		self.click_callback()
	end
end

function LevelRewardItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_reach = main_vo.level >= self.data.level

	local index = self.data.index
	local get_flag = WelfareData.Instance:GetLevelRewardFlag(index)
	local is_get = get_flag == 1

	local has_get_count = WelfareData.Instance:GetHasGetCountByIndex(index)
	local left_count = self.data.limit_num - has_get_count
	left_count = left_count < 0 and 0 or left_count
	local is_all_get = self.data.is_limit_num == 1 and left_count == 0

	if self.data.is_limit_num == 1 then
		local color = left_count == 0 and "ff3939" or "89F201"
		local outline = left_count == 0 and "4d161680" or "004b0080"
		-- RichTextUtil.
		local str = string.format(Language.OutLine.LeftCount, left_count, color, outline)
		RichTextUtil.ParseRichText(self.node_list["TxtLeftCount"].rich_text, str, 22)
		self.node_list["TxtLeftCount"].text.text = ""
	end
	self.node_list["RewardText"]:SetActive(self.data.is_limit_num == 1)

	if (not is_get) and is_reach and (not is_all_get) then
		self.node_list["TxtBtn"].text.text = Language.Common.LingQu 
		UI:SetButtonEnabled(self.node_list["BtnClickGet"], true)
		self.node_list["Effect"]:SetActive(true)
		self.node_list["BtnClickGet"]:SetActive(true)
		self.node_list["ListHasAllRight"]:SetActive(false)
		self.node_list["ListHasRight"]:SetActive(false)
	else
		self.node_list["Effect"]:SetActive(false)
	end

	if is_get then
		-- UI:SetButtonEnabled(self.node_list["BtnClickGet"], false)
		-- self.node_list["TxtBtn"].text.text = Language.Common.YiLingQu
		self.node_list["BtnClickGet"]:SetActive(false)
		self.node_list["ListHasAllRight"]:SetActive(false)
		self.node_list["ListHasRight"]:SetActive(true)
	else
		self.node_list["ListHasRight"]:SetActive(false)
		self.node_list["BtnClickGet"]:SetActive(true)
		self.node_list["ListHasAllRight"]:SetActive(false)
		if is_all_get then
			-- UI:SetButtonEnabled(self.node_list["BtnClickGet"], false)
			-- self.node_list["TxtBtn"].text.text = Language.Common.IsAllGet
			self.node_list["BtnClickGet"]:SetActive(false)
			self.node_list["ListHasRight"]:SetActive(false)
			self.node_list["ListHasAllRight"]:SetActive(true)
		end
	end

	if (not is_reach) and (not is_all_get) and (not is_get) then
		UI:SetButtonEnabled(self.node_list["BtnClickGet"], false)
		self.node_list["TxtBtn"].text.text = Language.Common.WEIDACHENG 
	end

	self.node_list["TxtLevel"].text.text = string.format(Language.Welfare.LevelReward, self.data.level)

	local reward_item_list = self.data.reward_item[0]

	local gift_reward_list = ItemData.Instance:GetGiftItemListByProf(reward_item_list.item_id)
	for k, v in ipairs(self.item_cell_list) do
		local reward_item_data = gift_reward_list[k]
		if reward_item_data then
			v:SetGiftItemId(reward_item_list.item_id)
			v:SetActive(true)
			v:SetData(reward_item_data)
		else
			v:SetActive(false)
		end
	end
end