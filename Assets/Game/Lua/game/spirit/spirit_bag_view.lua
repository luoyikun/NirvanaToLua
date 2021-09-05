SpiritBagView = SpiritBagView or BaseClass(BaseView)

-- 常亮定义
local MAX_PAGE_COUNT = 9
local MAX_GRID_NUM = 96
local ROW = 4
local COLUMN = 4

function SpiritBagView:__init()
	self.ui_config = {{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/spiritview_prefab","ShowBagSpiritView"}}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

function SpiritBagView:__delete()

end

function SpiritBagView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(460,530,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.JingLing.SpriteBag

	self.spirit_cells = {}

	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.SpiritBagView, BindTool.Bind(self.GetUiCallBack, self))
end

function SpiritBagView:ReleaseCallBack()
	if self.spirit_cells ~= nil then
		for k, v in pairs(self.spirit_cells) do
			v:DeleteMe()
		end
	end
	self.list_view = nil
	self.page_count = nil
	self.cur_bag_index = nil
end

function SpiritBagView:OpenCallBack()
		-- 计算页数
	local num = self:GetNumOfCells()
	local count = math.ceil(num / COLUMN)
	for i = 1, MAX_PAGE_COUNT do
		if count < i then 
			self.node_list["PageToggle" .. i]:SetActive(false)
		else
			self.node_list["PageToggle" .. i]:SetActive(true)
		end
	end
	self.list_view.list_page_scroll:SetPageCount(count)
	self.list_view.scroller:ReloadData(0)
	self:Flush()
end

function SpiritBagView:OpenBagView()
	self:Open()
end

function SpiritBagView:CloseCallBack()

end

function SpiritBagView:CloseView()
	self:Close()
end

function SpiritBagView:GetNumOfCells() 
	return MAX_GRID_NUM / ROW
end

function SpiritBagView:RefreshCell(cell, data_index)
	local group = self.spirit_cells[cell]
	if group == nil then
		group = SpiritBagGroup.New(cell.gameObject)
		self.spirit_cells[cell] = group
	end
	group:SetToggleGroup(self.list_view.toggle_group)
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN + column + (page * grid_count)
		local data = nil
		data = SpiritData.Instance:GetBagpiritList()[index + 1]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ShowHighLight(i, not data.locked)
		group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
		group:SetInteractable(i, nil ~= data.item_id)

		if data_index == 0 and i == 1 then --用于功能引导
			self.guide_cell = group
			self.guide_data = {}
			self.guide_data.index = index
			self.guide_data.i = i
			self.guide_data.data = data
		end
	end
end

function SpiritBagView:GetGuideCell()
	if self.guide_cell and self.guide_data then
		return self.guide_cell:GetGuideCell(), BindTool.Bind(self.HandleBagOnClick, self, self.guide_data.data, self.guide_cell, self.guide_data.i, self.guide_data.index)
	end
end
-- 点击格子事件
function SpiritBagView:HandleBagOnClick(data, group, group_index, data_index)
	local page = math.ceil((data.index + 1) / COLUMN)
	if data.locked then
		return
	end
	self.cur_bag_index = data_index
	group:SetHighLight(group_index, self.cur_bag_index == data.index and nil ~= data.item_id)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	local close_callback = function()
		group:SetHighLight(group_index, false)
		self.cur_bag_index = -1
	end
	if nil ~= item_cfg1 then
		local equip_index = SpiritData.Instance:GetSelectSpiritIndex() - 1 <= 0 and 0 or SpiritData.Instance:GetSelectSpiritIndex() - 1
		PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index, item_cfg1.need_gold)
		SpiritCtrl.Instance:CloseSpiritBagView()
	end
end


function SpiritBagView:OnFlush()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		SpiritData.Instance:GetBagBestSpirit()
		self.cur_bag_index = -1
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

function SpiritBagView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.SpiritUse then
		return self:GetGuideCell()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- 背包格子
SpiritBagGroup = SpiritBagGroup or BaseClass(BaseRender)

function SpiritBagGroup:__init(instance)
	self.cells = {}
	for i = 1, ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item"..i])
	end
end

function SpiritBagGroup:GetGuideCell()
	if self.cells[1] then
		return self.cells[1].root_node
	end
end

function SpiritBagGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpiritBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function SpiritBagGroup:SetHighLight(i, enable)
	local is_hight = enable or false
	if self.cells[i] then
		self.cells[i]:SetHighLight(is_hight)
	end
end

function SpiritBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end