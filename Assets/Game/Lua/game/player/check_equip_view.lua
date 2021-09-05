CheckEquipView = CheckEquipView or BaseClass(BaseView)

INDEXTOSTAR = {
	[1] = 0,
	[2] = 0,
	[3] = 1,
	[4] = 2,
	[5] = 3,
	[6] = 0,
}
function CheckEquipView:__init()
	self.ui_config = {{"uis/views/player_prefab", "CheckEquipView"}}
	
end

function CheckEquipView:__delete()

end

function CheckEquipView:ReleaseCallBack()
	self.equip_id1 = 0
	self.equip_id2 = 0
	self.equip_id3 = 0
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end

	-- 清理变量和对象
	-- self.equip_name_list = nil
	self.cell_list = nil
	self.capability_list = nil
	self.list_view = nil
end

function CheckEquipView:LoadCallBack()

	self.equip_id1 = 0
	self.equip_id2 = 0
	self.equip_id3 = 0
	self.cell_list = {}
	self.capability_list = {}

	for i = 1, 6 do
		self.capability_list[i] = self.node_list["TxtPoweNumber" .. i]
		self.node_list["ImgRedZeroStarIcon" .. i].event_trigger_listener:AddPointerClickListener(self.OnEquipDetail,self, 1)
	end

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))

	self:OnValueChanged()
	self.node_list["DecsList"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	local list_delegate = self.node_list["DecsList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

end

function CheckEquipView:GetNumberOfCells()
	return #ForgeData.Instance:GetShowXianPinCfg()
end

function CheckEquipView:OnValueChanged()
	local position = self.list_view.scroller.ScrollPosition
	local disable_height = self.list_view.scroller.ScrollSize						--listview不可见的画布长度
	self.node_list["ImgTopLine"]:SetActive(position < disable_height)
end

function CheckEquipView:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = ShowDecsItem.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local all_cfg = ForgeData.Instance:GetShowXianPinCfg()
	decs_item:SetData({decs = all_cfg[data_index + 1]})
end

function CheckEquipView:OnEquipDetail(i)
	local star = INDEXTOSTAR[i]
	local show_item_id = 0
	local is_show_star =  star > 0
	local data = {}
	if i == 1 then
		show_item_id = self.equip_id2
	-- elseif i == 2 or i == 3 then
	-- 	show_item_id = self.equip_id2

	elseif i == 6 then	-- 点击红水晶
		show_item_id = 27591
	else
		show_item_id = self.equip_id3
	end
	data.item_id = show_item_id
	data.show_star_num = star
	data.speacal_from = is_show_star
	data.param = CommonStruct.ItemParamData()
	if star == 1 then
		data.param.xianpin_type_list = {58}
	elseif star == 2 then
		data.param.xianpin_type_list = {58, 59}
	elseif star == 3 then
		data.param.xianpin_type_list = {58, 59, 60}
	end
	TipsCtrl.Instance:OpenItem(data)
end

function CheckEquipView:OnClose()
	self:Close()
end

function CheckEquipView:ShowIndexCallBack(index)
	self:Flush()
end

function CheckEquipView:OnFlush()
	self.equip_id1, self.equip_id2, self.equip_id3 = PlayerData.Instance:GetCheckCfg()
	if self.equip_id1 == 0 then return end
	local item_cfg_1 = ItemData.Instance:GetItemConfig(self.equip_id1)	-- 紫色
	local item_cfg_2 = ItemData.Instance:GetItemConfig(self.equip_id2)	-- 橙色
	local item_cfg_3 = ItemData.Instance:GetItemConfig(self.equip_id3)	-- 红色
	self.node_list["ImgRedZeroStarIcon1"].image:LoadSprite(ResPath.GetItemIcon(item_cfg_2.icon_id))
	self.node_list["ImgRedZeroStarIcon2"].image:LoadSprite(ResPath.GetItemIcon(item_cfg_2.icon_id))
	for i = 1, 6 do
		local star = INDEXTOSTAR[i]
		local show_item_id = 0
		local is_show_star =  star > 0
		local data = {}

		if i == 1 then
			show_item_id = self.equip_id1
		elseif i == 2 or i == 3 then
			show_item_id = self.equip_id2
		else
			show_item_id = self.equip_id3
		end
		data.item_id = show_item_id
		data.show_star_num = star
		data.speacal_from = is_show_star
		data.param = CommonStruct.ItemParamData()
		if star == 1 then
			data.param.xianpin_type_list = {58}
		elseif star == 2 then
			data.param.xianpin_type_list = {58, 59}
		elseif star == 3 then
			data.param.xianpin_type_list = {58, 59, 60}
		end

		local capability = EquipData.Instance:GetEquipLegendFightPowerByData(data, false, true)
		self.node_list["TxtPoweNumber0"].text.text = capability
		self.node_list["TxtPoweNum0"].text.text = capability
		self.node_list["TxtPoweNumber1"].text.text = capability
		self.node_list["TxtPoweNumber2"].text.text = capability
		self.node_list["TxtPoweNumber3"].text.text = capability
		self.node_list["TxtPoweNum1"].text.text = capability

		if data.speacal_from and data.param and data.param.xianpin_type_list then
			local valtrue_data = TableCopy(data, 3)
			for i = 1, 2 do
				if nil ~= valtrue_data.param.xianpin_type_list[i] then
					table.remove(valtrue_data.param.xianpin_type_list, i)
				end
			end
			capability = EquipData.Instance:GetEquipLegendFightPowerByData(valtrue_data, false, true)
			self.node_list["TxtPoweNumber0"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
			self.node_list["TxtPoweNum0"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
			self.node_list["TxtPoweNumber1"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
			self.node_list["TxtPoweNumber2"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
			self.node_list["TxtPoweNumber3"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
			self.node_list["TxtPoweNum1"].text.text = (capability + 60000) * math.pow(1.2, data.show_star_num)
		end
	end
end

---------------------ShowDecsItem--------------------------------
ShowDecsItem = ShowDecsItem or BaseClass(BaseCell)

function ShowDecsItem:__init(instance)
end

function ShowDecsItem:__delete()

end

function ShowDecsItem:OnFlush()
	if self.data == nil then return end
	self.node_list["Text"].text.text = self.data.decs
end