TipsAwardItem = TipsAwardItem or BaseClass(BaseView)

function TipsAwardItem:__init()
	self.ui_config = {
		{"uis/views/fubenview_prefab", "AwardItemTips"}
	}
	-- self.camera_mode = UICameraMode.UICameraLow
	-- self.view_layer = UiLayer.MainUILow
	self.is_modal = false
	self.is_any_click_close = true
end

function TipsAwardItem:ReleaseCallBack()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function TipsAwardItem:LoadCallBack()
	local list_view_delegate = self.node_list["List"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.cell_list = {}
	self.item_list = {}
	for i = 1,5 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ItemCell" .. i]) 
		table.insert(self.item_list, item_cell)
	end
end

function TipsAwardItem:OpenCallBack()
	self:Flush()
end

function TipsAwardItem:OnClickClose()
	self:Close()
end

function TipsAwardItem:OnFlush()
	self.node_list["List"].scroller:ReloadData(0)
	local data = FuBenData.Instance:GetFBDropItemInfo()
	local num = FuBenData.Instance:GetFBDropInfoItemNum()
	local flag = num < 5
	self.node_list["BG"]:SetActive(flag)
	self.node_list["Scroll"]:SetActive(not flag)

	if data and num < 5 then
		for k,v in pairs(self.item_list) do
			if data[k] then
				v:SetData(data[k])
				v:SetParentActive(true)
			else
				v:SetParentActive(false)
			end
		end
	end
end

function TipsAwardItem:GetNumberOfCells()
	local num = FuBenData.Instance:GetFBDropInfoItemNum()
	return num
end

function TipsAwardItem:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = AwardItemCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data = FuBenData.Instance:GetFBDropItemInfo()
	if data then
		group_cell:SetData(data[data_index + 1])
	end
end
----------AwardItemCell----------
AwardItemCell = AwardItemCell or BaseClass(BaseCell)
function AwardItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
end

function AwardItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AwardItemCell:OnFlush()
	if nil == self.data then return end
	-- local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	-- if item_cfg == nil then return end
	-- local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. item_cfg.name .."</color>"
	-- self.node_list["Name"].text.text = name_str
	self.item_cell:SetData(self.data)
end