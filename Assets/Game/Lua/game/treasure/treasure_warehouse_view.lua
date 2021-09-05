TreasureWarehouseView = TreasureWarehouseView or BaseClass(BaseRender)

function TreasureWarehouseView:__init(instance)
	self.warehouse_contain_list = {}
	
	self.node_list["GetAllBtn"].button:AddClickListener(BindTool.Bind(self.OnGetAllClick, self))

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TreasureWarehouseView:__delete()
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

function TreasureWarehouseView:OpenCallBack()
	local up_pos = self.node_list["UpPanel"].transform.anchoredPosition
	local under_pos = self.node_list["GetAllBtn"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["UpPanel"], Vector3(up_pos.x, up_pos.y + 700, up_pos.z))
	UITween.MoveShowPanel(self.node_list["GetAllBtn"], Vector3(under_pos.x, under_pos.y - 100, under_pos.z))
end

--用于功能引导按钮
function TreasureWarehouseView:GetGuideAllBtn()
	if self.node_list["GetAllBtn"] then
		return self.node_list["GetAllBtn"], BindTool.Bind(self.OnGetAllClick, self)
	end
end

function TreasureWarehouseView:GetNumberOfCells()
	return TREASURE_ALL_ROW
end

function TreasureWarehouseView:OnFlush()
	self:ReloadData()
	self:CheckAutoRedPoint()
end

function TreasureWarehouseView:RefreshCell(cell, cell_index)
	local warehouse_contain = self.warehouse_contain_list[cell]
	if warehouse_contain == nil then
		warehouse_contain = TreasureWarehouseContain.New(cell.gameObject, self)
		self.warehouse_contain_list[cell] = warehouse_contain
		warehouse_contain:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	cell_index = cell_index + 1
	local cell_index_list = {}
	cell_index_list = CommonDataManager.GetCellIndexList(cell_index, TREASURE_ROW, TREASURE_COLUMN)
	warehouse_contain:SetGridIndex(cell_index_list)
end

function TreasureWarehouseView:OnGetAllClick()
	TreasureCtrl.Instance:SendQuchuItemReq(0, CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP, 1)
end

function TreasureWarehouseView:ReloadData()
	local page = self.node_list["list_view"].list_page_scroll:GetNowPage()
	if page < 1 then
		self.node_list["list_view"].scroller:ReloadData(0)
	else
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function TreasureWarehouseView:CheckAutoRedPoint()
	if self.node_list["ImgRedPoint"] and ItemData.Instance:GetEmptyNum() > 0 and TreasureData.Instance:GetChestCount() > 0 then
		self.node_list["ImgRedPoint"]:SetActive(true)
	else
		self.node_list["ImgRedPoint"]:SetActive(false)
	end
end
-------------------------------------------------------------------------------
TreasureWarehouseContain = TreasureWarehouseContain  or BaseClass(BaseCell)

function TreasureWarehouseContain:__init()
	self.warehouse_item_list = {}
	for i = 1, TREASURE_COLUMN do
		local handler = function()
			local close_call_back = function()
				self.warehouse_item_list[i].warehouse_item:SetToggle(false)
				self.warehouse_item_list[i].warehouse_item:ShowHighLight(false)
			end
			if self.warehouse_item_list[i] then
				if self.warehouse_item_list[i].warehouse_item:GetData() and self.warehouse_item_list[i].warehouse_item:GetData().item_id ~= nil then
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

function TreasureWarehouseContain:__delete()
	for k,v in pairs(self.warehouse_item_list) do
		if v and self.warehouse_item_list[k] then
			v.warehouse_item:DeleteMe()
		end
	end
	self.warehouse_item_list = {}
end


function TreasureWarehouseContain:SetGridIndex(grid_index_list)
	for i = 1, TREASURE_COLUMN do
		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
		self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
		self.warehouse_item_list[i].grid_index = grid_index_list[i]
		self.warehouse_item_list[i].warehouse_item:SetItemActive(grid_index_list[i] <= TREASURE_MAX_COUNT)
	end
end

function TreasureWarehouseContain:SetToggleGroup(toggle_group)
	for i = 1, TREASURE_COLUMN do
		self.warehouse_item_list[i].warehouse_item:SetToggleGroup(toggle_group)
	end
end

-- function TreasureWarehouseContain:OnFlushItem()
-- 	for i = 1, TREASURE_COLUMN do
-- 		local chest_item = TreasureData.Instance:GetChestItemInfo()[grid_index_list[i] - 1]
-- 		self.warehouse_item_list[i].warehouse_item:SetData(chest_item)
-- 	end
-- end