TipsTreasureWarehouseView = TipsTreasureWarehouseView or BaseClass(BaseView)

function TipsTreasureWarehouseView:__init(instance)
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tipstreasurewarecontent_prefab", "WareContent"},
	}
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsTreasureWarehouseView:LoadCallBack(instance)
	self.warehouse_contain_list = {}
	self.node_list["GetAllBtn"].button:AddClickListener(BindTool.Bind(self.OnGetAll, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(1100, 700, 0)
	self.node_list["Txt"].text.text = Language.Activity.WareHose

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsTreasureWarehouseView:__delete()
	
end

function TipsTreasureWarehouseView:ReleaseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	for _,v in pairs(self.warehouse_contain_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.warehouse_contain_list = {}
end

function TipsTreasureWarehouseView:OpenCallBack()
	local up_pos = self.node_list["UpPanel"].transform.anchoredPosition
	local under_pos = self.node_list["GetAllBtn"].transform.anchoredPosition
	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
end

-- --用于功能引导按钮
-- function TipsTreasureWarehouseView:GetGuideAllBtn()
-- 	if self.node_list["GetAllBtn"] then
-- 		return self.node_list["GetAllBtn"], BindTool.Bind(self.OnGetAllClick, self)
-- 	end
-- end

function TipsTreasureWarehouseView:GetNumberOfCells()
	return TREASURE_ALL_ROW
end

function TipsTreasureWarehouseView:OnFlush()
	self:ReloadData()
	-- self:CheckAutoRedPoint()
end

function TipsTreasureWarehouseView:RefreshCell(cell, cell_index)
	local warehouse_contain = self.warehouse_contain_list[cell]
	if warehouse_contain == nil then
		warehouse_contain = TreasureWarehouseCell.New(cell.gameObject, self)
		self.warehouse_contain_list[cell] = warehouse_contain
		warehouse_contain:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = CommonDataManager.GetCellIndexList(cell_index, TREASURE_ROW, TREASURE_COLUMN)
	warehouse_contain:SetGridIndex(cell_index_list)
end

function TipsTreasureWarehouseView:OnGetAll()
	TreasureCtrl.Instance:SendQuchuItemReq(0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 1)
end

function TipsTreasureWarehouseView:ReloadData()
	local page = self.node_list["list_view"].list_page_scroll:GetNowPage()
	if page < 1 then
		self.node_list["list_view"].scroller:ReloadData(0)
	else
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TipsTreasureWarehouseView:CheckAutoRedPoint()
	if self.node_list["ImgRedPoint"] and ItemData.Instance:GetEmptyNum() > 0 and TreasureData.Instance:GetChestCount() > 0 then
		self.node_list["ImgRedPoint"]:SetActive(true)
	else
		self.node_list["ImgRedPoint"]:SetActive(false)
	end
end
-------------------------------------------------------------------------------
TreasureWarehouseCell = TreasureWarehouseCell  or BaseClass(BaseCell)

function TreasureWarehouseCell:__init()
	self.warehouse_item_list = {}
	for i = 1, TREASURE_COLUMN do
		if self.warehouse_item_list then
			local handler = function()
				local close_call_back = function()
					self.warehouse_item_list[i].warehouse_item:SetToggle(false)
					self.warehouse_item_list[i].warehouse_item:ShowHighLight(false)
				end
				if self.warehouse_item_list[i] then
					if self.warehouse_item_list[i].warehouse_item:GetData().item_id ~= nil then
						self.warehouse_item_list[i].warehouse_item:ShowHighLight(true)
					else
						self.warehouse_item_list[i].warehouse_item:SetToggle(false)
						self.warehouse_item_list[i].warehouse_item:ShowHighLight(false)
					end
					TipsCtrl.Instance:OpenItem(self.warehouse_item_list[i].warehouse_item:GetData(), TipsFormDef.FROM_BAOXIANG, nil, close_call_back)
				end
			end
			self.warehouse_item_list[i] = {}
			self.warehouse_item_list[i].warehouse_item = ItemCell.New()
			self.warehouse_item_list[i].warehouse_item:SetFromView(TipsFormDef.FROM_XUNBAO_QUCHU)
			self.warehouse_item_list[i].warehouse_item:SetInstanceParent(self.node_list["item_" .. i])
			self.warehouse_item_list[i].grid_index = 0
			self.warehouse_item_list[i].warehouse_item:ListenClick(handler)
		end
	end
end

function TreasureWarehouseCell:__delete()
	for _,v in pairs(self.warehouse_item_list) do
		if v then
			v.warehouse_item:DeleteMe()
		end
	end
	self.warehouse_item_list = {}
end


function TreasureWarehouseCell:SetGridIndex(grid_index_list)
	for i = 1, TREASURE_COLUMN do
		if self.warehouse_item_list then
			local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
			self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
			self.warehouse_item_list[i].grid_index = grid_index_list[i]
			self.warehouse_item_list[i].warehouse_item:SetItemActive(grid_index_list[i] <= TREASURE_MAX_COUNT)
		end

		
	end
end

function TreasureWarehouseCell:SetToggleGroup(toggle_group)
	for i = 1, TREASURE_COLUMN do
		if self.warehouse_item_list  then
			self.warehouse_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
		end
	end
end

-- function TreasureWarehouseCell:OnFlushItem()
-- 	for i = 1, TREASURE_COLUMN do
-- 		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
-- 		self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
-- 	end
-- end