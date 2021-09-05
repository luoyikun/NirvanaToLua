LittlePetToyBagView = LittlePetToyBagView or BaseClass(BaseView)

-- 常亮定义
local MAX_PAGE_COUNT = 9
local MAX_GRID_NUM = 120
local ROW = 4
local COLUMN = 5

function LittlePetToyBagView:__init()
	self.ui_config = {{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/littlepetview_prefab","ShowBagPetToyView"}}
    self.is_modal = true    
    self.is_any_click_close = true
    self.open_tween = UITween.ShowFadeUp
    self.close_tween = UITween.HideFadeUp
    self.pet_index = 0
    self.data_list = {}
end

function LittlePetToyBagView:__delete()

end

function LittlePetToyBagView:LoadCallBack()
    self.node_list["Bg"].rect.sizeDelta = Vector3(574,530,0)
    self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
    self.node_list["Txt"].text.text = Language.LittlePet.WareHouse
	self.cell_list = {}
	self.data_list = {}

	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LittlePetToyBagView:ReleaseCallBack()
   	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	
	self.list_view = nil
	self.page_count = nil
end

function LittlePetToyBagView:OpenCallBack()
	self:GetItemData()
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

function LittlePetToyBagView:SetData(data)
	self.pet_data = data
	self:Open()
end

function LittlePetToyBagView:CloseCallBack()

end

function LittlePetToyBagView:CloseView()
	self:Close()
end

function LittlePetToyBagView:GetItemData()
	local toy_part = self.pet_data.toy_index
	local max_color = self.pet_data.max_color
	self.data_list = LittlePetData.Instance:GetBagLittlePetToyDataListByToyPart(toy_part, max_color)
end

function LittlePetToyBagView:GetNumOfCells() 
	local diff = #self.data_list - MAX_GRID_NUM
	local more_then_num = ((diff > 0)) and (math.ceil(diff / ROW / COLUMN)) or 0
	return (MAX_GRID_NUM + more_then_num * ROW * COLUMN) / ROW
end

function LittlePetToyBagView:RefreshCell(cell, data_index)
	local group = self.cell_list[cell]
	if group == nil then
		group = LittlePetToyItemGroup.New(cell.gameObject)
		group:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN + column + (page * grid_count)
		local data = self.data_list[index + 1]
		data = data or {}
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ListenClick(i, BindTool.Bind(self.OnClickCell, self, data, group, i))
		group:SetInteractable(i, nil ~= data.item_id)
		group:SetHighLight(i, false)
	end
end

function LittlePetToyBagView:OnClickCell(data, group, group_index)
	if nil == next(data) then return end

    local item_id = data.item_id or 0
	local ok_callback = function ()
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_PUTON
       	local pet_index = self.pet_data.pet_index
        local bag_index = ItemData.Instance:GetItemIndex(item_id)

        LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, pet_index, bag_index)
        self:Close()
	end
	
	-- local cfg = ItemData.Instance:GetItemConfig(item_id)
	-- if nil == cfg then return end

	-- local item_name = cfg.name or ""
	-- local color = cfg.color and ITEM_COLOR[cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
	-- local name = ToColorStr(item_name, color)
	-- local des = string.format(Language.LittlePet.ExchangePetToyRemind, name)
	-- TipsCtrl.Instance:ShowCommonAutoView("ExchangeEquipPetToy", des, ok_callback)
	ok_callback()
	group:ShowHighLight(group_index, false)
end

-------------------------------------------------------------------
LittlePetToyItemGroup = LittlePetToyItemGroup or BaseClass(BaseRender)

function LittlePetToyItemGroup:__init(instance)
	self.cells = {}
	for i = 1, ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item"..i])
	end
end

function LittlePetToyItemGroup:__delete()
	if self.cells then
		for k, v in pairs(self.cells) do
			v:DeleteMe()
		end
		self.cells = {}
	end
end

function LittlePetToyItemGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function LittlePetToyItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function LittlePetToyItemGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
	self.cells[4]:SetToggleGroup(toggle_group)
end

function LittlePetToyItemGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(false)
end

function LittlePetToyItemGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function LittlePetToyItemGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function LittlePetToyItemGroup:SetToggle(i, enable)
	self.cells[i]:SetToggle(enable)
end