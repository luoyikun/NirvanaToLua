TianshenhutiEqSelectView = TianshenhutiEqSelectView or BaseClass(BaseView)

local COLUMN = 6
local PAGE_NUM = 4		-- 一页格子数
local FROM_COMPOSE = "from_compose"

function TianshenhutiEqSelectView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tianshenhutiview_prefab", "ComposeSelectView"}
	}
	self.play_audio = true
	self.fight_info_view = true
	self.had_data_list = {}
	self.list_data = {}
	self.from_view = ""
	self.max_pagg_count = 0
	self.now_page = 1
	self.index = 1
	self.is_compose = false

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TianshenhutiEqSelectView:__delete()

end

function TianshenhutiEqSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function TianshenhutiEqSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TianshenhutiEqSelectView:LoadCallBack()
	self.cell_list = {}
	self.node_list["Bg"].rect.sizeDelta = Vector3(650,570,0)
	self.node_list["Txt"].text.text = Language.Tianshenhuti.TianShenSelect
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnClickUp, self))
	self.node_list["BtnDown"].button:AddClickListener(BindTool.Bind(self.OnClickDown, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["EnoughToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
end

function TianshenhutiEqSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function TianshenhutiEqSelectView:OpenCallBack()
	self.list_data = TianshenhutiData.Instance:GetCanComposeDataList(self.from_view == FROM_COMPOSE)
	self:SetPageData()

	if self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function TianshenhutiEqSelectView:SetSelectIndex(index)
	self.index = index
end

function TianshenhutiEqSelectView:GetNumberOfCells()
	return math.ceil(TianshenhutiData.Instance:GetBagListCount() / 6)
end

function TianshenhutiEqSelectView:OnSelectToggleChange(is_on)
-- 
end

function TianshenhutiEqSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function TianshenhutiEqSelectView:SetHadSelectData(data_list)    --已经选择的
	self.had_data_list = data_list or {}
end

function TianshenhutiEqSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function TianshenhutiEqSelectView:OnClickUp()
	local now_page = self.node_list["ListView"].list_page_scroll2:GetNowPage() + 1
	if now_page > 1 then
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(now_page - 2)
	end
end

function TianshenhutiEqSelectView:OnClickDown()
	local now_page = self.node_list["ListView"].list_page_scroll2:GetNowPage() + 1
	if now_page < self.max_pagg_count then
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(now_page)
	end
end

function TianshenhutiEqSelectView:SetPageData()
	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.node_list["ListView"].list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1
	self.node_list["TxtPage"].text.text = 1 .. " / " .. self.max_pagg_count
end

function TianshenhutiEqSelectView:OnValueChanged(normalizedPosition)
	local now_page = self.node_list["ListView"].list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.now_page = now_page
		self.node_list["TxtPage"].text.text = now_page .. " / " .. self.max_pagg_count
	end
end

function TianshenhutiEqSelectView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = TianshenhutiEqSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i - 1
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self, data))
	end
end

function TianshenhutiEqSelectView:ItemCellClick(data)
	if self.call_back ~= nil then
		self.call_back(data)
		self.call_back = nil
	end
	TianshenhutiData.Instance:AddComposeSelect(self.index, data)
	self:Close()
end

function TianshenhutiEqSelectView:CloseWindow()
	self:Close()
end

function TianshenhutiEqSelectView:OnFlush(param_list)
end


-------------------TianshenhutiEqSelectGroup-----------------------
TianshenhutiEqSelectGroup = TianshenhutiEqSelectGroup or BaseClass(BaseRender)
function TianshenhutiEqSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ItemCell.New()
		-- bag_item:SetInstanceParent(self:FindObj("Item" .. i))
		bag_item:SetInstanceParent(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function TianshenhutiEqSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TianshenhutiEqSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function TianshenhutiEqSelectGroup:SetData(i, data)
	if data then
		local cfg = TianshenhutiData.Instance:GetEquipCfg(data.item_id or 0)
		if cfg then
			local item_data = {item_id = cfg.item_id}
			self.item_list[i]:SetData(item_data)
		end
	end
end

function TianshenhutiEqSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function TianshenhutiEqSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function TianshenhutiEqSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:ListenClick(callback)
end



