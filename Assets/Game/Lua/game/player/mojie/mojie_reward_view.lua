MojieGiftView = MojieGiftView or BaseClass(BaseView)

function MojieGiftView:__init()
	self.ui_config = {{"uis/views/player_prefab", "MojieGiftView"}}

	self.is_modal = true
end

function MojieGiftView:__delete()

end

function MojieGiftView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil
end

function MojieGiftView:LoadCallBack()

	
	self.cell_list = {}
	local list_delegate = self.node_list["GiftList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self:Flush()
end

function MojieGiftView:CloseWindow()
	self:Close()
end

function MojieGiftView:OpenCallBack()
	self:Flush()
end


function MojieGiftView:GetNumberOfCells()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	return #data_list
end

function MojieGiftView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = MojieGiftItem.New(cell.gameObject)
		star_cell.parent_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function MojieGiftView:OnFlush()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	if data_list then
		if #data_list == 1 then
			self.node_list["GiftList"].rect.sizeDelta = Vector2(305, 240)
		elseif #data_list == 2 then
			self.node_list["GiftList"].rect.sizeDelta = Vector2(315, 240)
		elseif #data_list == 3 then
			self.node_list["GiftList"].rect.sizeDelta = Vector2(450, 240)
		else
			self.node_list["GiftList"].rect.sizeDelta = Vector2(605, 240)
		end
	end
	self.node_list["GiftList"].scroller:ReloadData(0)
end

---------------------MojieGiftItem--------------------------------
MojieGiftItem = MojieGiftItem or BaseClass(BaseCell)

function MojieGiftItem:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.parent_view = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

end

function MojieGiftItem:__delete()
	self.parent_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MojieGiftItem:SetItemIndex(index)
	self.item_index = index
end

function MojieGiftItem:OnClickReward()
	-- local max_num = MojieData.Instance:GetMojieGiftNum()
	-- if max_num > 1 then
	-- 	TipsCtrl.Instance:OpenCommonInputView("", BindTool.Bind(self.CountInputEnd, self), nil, 1)
	-- else
		self:CountInputEnd(1)
	-- end
	
end

function MojieGiftItem:CountInputEnd(str)
	local cost_num = tonumber(str)
	local bag_index = MojieData.Instance:GetMojieGiftBagIndex()
	if bag_index ~= -1 then
		PackageCtrl.Instance:SendUseItem(bag_index, cost_num, self.reward_index - 1)
	end
	self.parent_view:Close()
end

function MojieGiftItem:OnFlush()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	if gift_id == -1 then
		return
	end
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	local data = {}
	data = data_list[self.item_index] or {}
	local xianpin_fix = ForgeData.Instance:GetEquipXianPinFixInfo(gift_id)
	local star_num = xianpin_fix and xianpin_fix.show_star or 0
	data.is_from_extreme = star_num
	data.show_rank_attr = star_num > 0 and star_num ~= 3
	data.noindex_show_xianpin = star_num > 0
	data.param = {}
	data.param.xianpin_type_list = {}
	
	if data.noindex_show_xianpin then
		for i = 1, star_num do
			data.param.xianpin_type_list[i] = xianpin_fix["xianpin_type_" .. i]
		end
	end
	if star_num >= 3 then
		data.is_from_extreme = nil
	end
	self.item_cell:SetData(data)

	self.reward_index = data.reward_index or 0
end