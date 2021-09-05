GuildMiJingRewardView = GuildMiJingRewardView or BaseClass(BaseView)

local COLUMN_NUM = 6
local ROW_NUM = 1
local BAG_PAGE_COUNT = 6
local BAG_MAX_GRID_NUM = 24			-- 最大格子数

function GuildMiJingRewardView:__init()
	self.ui_config = {
		{"uis/views/guildmijing_prefab", "XianMengRewardTips"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.data_list = {}
end


function GuildMiJingRewardView:ReleaseCallBack()
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end

	if self.item_reward_list then
		for k,v in pairs(self.item_reward_list) do
			v:DeleteMe()
		end
	end
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
	self.item_list = nil
	self.data_list = nil
end

function GuildMiJingRewardView:CloseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function GuildMiJingRewardView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.num = 0

	self.toggle_list = {}
	for i = 1, 4 do
		self.toggle_list[i] = self.node_list["PageToggle" .. i]
	end
	self.item_reward_list = {}
	for i = 1, 6 do
		self.item_reward_list[i] = ItemCell.New()
		self.item_reward_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end

	self.item_list = {}
	local list_delegate = self.node_list["PageView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GuildMiJingRewardView:CloseView()
	self:Close()
end

function GuildMiJingRewardView:GetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function GuildMiJingRewardView:RefreshCell(index, cellObj)
	local item_cell = self.item_list[cellObj]
	if item_cell == nil then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cellObj.gameObject)
		self.item_list[cellObj] = item_cell
	end
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / ROW_NUM) + 1 - page * COLUMN_NUM
	local grid_index = page * COLUMN_NUM + cur_colunm 
	if self.data_list == nil or next(self.data_list) == nil then return end
	if grid_index <= #self.data_list then
		item_cell:SetData({item_id = self.data_list[grid_index].item_id, num = self.data_list[grid_index].reward_item_num}, true)
	end
	if self.data_list[grid_index] == nil then
		item_cell:SetItemActive(false)
	else
		item_cell:SetItemActive(true)
	end

	item_cell:SetIconGrayVisible(false)
end

function GuildMiJingRewardView:OnFlush()
	local toggle_num = math.ceil(self.num / BAG_PAGE_COUNT)
	self.node_list["PageView"].list_page_scroll2:SetPageCount(toggle_num)

	for i = 1, 4 do
		self.toggle_list[i]:SetActive(toggle_num >= i)
	end
	if self.data_list then
		local flag = #self.data_list <= 6
		self.node_list["Rewards"]:SetActive(flag)
		self.node_list["PageView"]:SetActive(not flag)
		self.node_list["PageButtons"]:SetActive(not flag)
	end
	if self.node_list["PageView"] and nil ~= self.node_list["PageView"].list_view
		and self.node_list["PageView"].list_view.isActiveAndEnabled then
		self.node_list["PageView"].list_view:Reload()
		self.node_list["PageView"].list_view:JumpToIndex(0) 
	end

	if self.data_list then
		for k,v in pairs(self.item_reward_list) do
			if self.data_list[k] then
				v:SetData(self.data_list[k])
				self.node_list["Item" .. k]:SetActive(true)
			else
				self.node_list["Item" .. k]:SetActive(false)
			end
		end
	end
end

function GuildMiJingRewardView:SetData(data, num)
	self.data_list = {}
	for k, v in ipairs(data) do
		if data[k].item_id ~= 0 then
			local cfg = ItemData.Instance:GetItemConfig(data[k].item_id)
			if cfg and next(cfg) then
				v.color = cfg.color
			else
				v.color = 0
			end
		else
			v.color = 0
		end
		table.insert(self.data_list, v)
	end
	table.sort(self.data_list, SortTools.KeyUpperSorters("color"))
	self.num = num
	self:CalTime()
end

function GuildMiJingRewardView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:Close()
			self.cal_time_quest = nil
		else
			if self.node_list["TxtDescText"] then
				self.node_list["TxtDescText"].text.text = string.format(Language.Tips.PaTaTipsWithRewardBtnTxt, math.floor(timer_cal))
			end
		end
	end, 0)
end