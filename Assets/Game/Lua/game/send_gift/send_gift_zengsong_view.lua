local PAGE_COUNT = 21
local PAGE = 20
local SEND_NUM = 7
local FRIEND_TYPE = 1
local GUILD_TYPE = 2

SendGiftZengSongView = SendGiftZengSongView or BaseClass(BaseRender)
function SendGiftZengSongView:__init()
	self.node_list["ButtonSend"].button:AddClickListener(BindTool.Bind(self.OnButtonSend, self))

	self.list_cell = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self.send_cell_list = {}
	for i = 1, SEND_NUM do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		cell:SetFromView(TipsFormDef.FROM_GIFT_VIEW)
		cell:ListenClick(BindTool.Bind(self.OnClickCell, self, i)) 
	 	self.send_cell_list[i] = cell
	end

	self.send_cell_list_data = {}

	self.people_list = {}
	self.scroller_data = {}
	local scroller_delegate = self.node_list["PeopleList"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local friend_cell = self.people_list[cell]
		if friend_cell == nil then
			friend_cell = PeopleListCell.New(cell.gameObject)
			friend_cell.root_node.toggle.group = self.node_list["PeopleList"].toggle_group
			friend_cell.friend_view = self
			--friend_cell:SetClickCallBack(BindTool.Bind(self.GiftOnClick, self))
			self.people_list[cell] = friend_cell
		end
		friend_cell:SetIndex(data_index)
		friend_cell:SetData(self.scroller_data[data_index])
	end
	self.view_port_rect = self.node_list["PeopleList"].transform.parent:GetComponent(typeof(UnityEngine.RectTransform))

	self.node_list["FriendToggle"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, FRIEND_TYPE))
	self.node_list["GuildToggle"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange,self, GUILD_TYPE))

	self.is_jump_from_record_view = false
end

function SendGiftZengSongView:OnToggleChange(send_type)
	self.send_type = send_type
	if self.is_jump_from_record_view == false then
		self.select_index = 1
	elseif self.is_jump_from_record_view == true then
		self.is_jump_from_record_view = false
	end
	if self.send_type == FRIEND_TYPE then
		self.node_list["FriendToggle"].toggle.isOn = true
	elseif self.send_type == GUILD_TYPE then
		self.node_list["GuildToggle"].toggle.isOn = true
	end
	self:Flush("flush_people_listview")
end

function SendGiftZengSongView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function SendGiftZengSongView:GetSelectIndex()
	return self.select_index or 0
end

function SendGiftZengSongView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self:GetSendCellListDataLength() > 0 then
		for i = self:GetSendCellListDataLength(), 1, -1 do
			if self.send_cell_list_data[i] and self.send_cell_list_data[i].item_id == item_id 
				and self.send_cell_list_data[i].in_bag_index == index 
					and new_num < old_num then
				table.remove(self.send_cell_list_data, i)
			end
		end

		for i = 1, SEND_NUM do
		 	self.send_cell_list[i]:SetData(self.send_cell_list_data[i])
		end		
	end

	self:Flush("flush_list_view")
end

function SendGiftZengSongView:LoadCallBack()
	self:Flush("flush_list_view")
end

function SendGiftZengSongView:CloseCallBack()
	self.send_cell_list_data = {}
	for i = 1, SEND_NUM do
		if self.send_cell_list[i] then
	 		self.send_cell_list[i]:SetData(self.send_cell_list_data[i])
	 	end
	end	
end

function SendGiftZengSongView:ShowIndexCallBack()
	if self.is_jump_from_record_view == false then
		self.select_index = 1
		self:OnToggleChange(FRIEND_TYPE)
		self:Flush("all")
	elseif self.is_jump_from_record_view == true then
		local index, open_type = SendGiftData.Instance:GetJumpIndexAndType()
		self.select_index = index
		self:OnToggleChange(open_type)
	end
end

function SendGiftZengSongView:__delete()
	for k,v in pairs(self.list_cell) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.list_cell = nil

	for k,v in pairs(self.send_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.send_cell_list = nil	

	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	

	self.send_cell_list_data = {}

	for _,v in pairs(self.people_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.people_list = {}
	self.view_port_rect = nil
	self.is_jump_from_record_view = false	
end

function SendGiftZengSongView:SetIsFromRecordView(flag)
	self.is_jump_from_record_view = flag
end

function SendGiftZengSongView:InsertSendCellData(data)
	if data and data.in_bag_index then
		if self:GetSendCellListDataLength() < SEND_NUM then
			table.insert(self.send_cell_list_data, data)
		end
	end

	for i = 1, SEND_NUM do
	 	self.send_cell_list[i]:SetData(self.send_cell_list_data[i])
	end

	self:Flush("flush_list_view")	
end

function SendGiftZengSongView:OnClickCell(click_index)
	self:RemoveSendCellDataByIndex(click_index)
end

function SendGiftZengSongView:RemoveSendCellDataByIndex(index)
	if self:GetSendCellListDataLength() > 0 then
		for i = self:GetSendCellListDataLength(), 1, -1 do
			if index == i then
				table.remove(self.send_cell_list_data, i)
			end
		end

		for i = 1, SEND_NUM do
		 	self.send_cell_list[i]:SetData(self.send_cell_list_data[i])
		end

		self:Flush("flush_list_view")			
	end
end

function SendGiftZengSongView:CheckIsGray(in_bag_index, item_id)
	for i = 1, SEND_NUM do
		if self.send_cell_list_data[i] and self.send_cell_list_data[i].in_bag_index and self.send_cell_list_data[i].item_id then
		 	if self.send_cell_list_data[i].in_bag_index == in_bag_index and self.send_cell_list_data[i].item_id == item_id then
		 		return true
		 	end
		end
	end
	return false
end

function SendGiftZengSongView:GetSendCellListDataLength()
	if self.send_cell_list_data and type(self.send_cell_list_data) == "table" then
		return #self.send_cell_list_data
	else
		return 0
	end
end

function SendGiftZengSongView:GetNumberOfCells()
	local data_list = TableCopy(ItemData.Instance:GetBagNoBindItemList())
	local max_num = #data_list
	return math.ceil(max_num / PAGE_COUNT)
end

function SendGiftZengSongView:RefreshCell(cell, data_index)
	-- 构造Cell对象.
	local item = self.list_cell[cell]
	if nil == item then
		item = ZengSongGroup.New(cell)
		self.list_cell[cell] = item
	end
	local data = {}
	local data_list = TableCopy(ItemData.Instance:GetBagNoBindItemList())
	for i = 1, PAGE_COUNT do
		if data_list[data_index * PAGE_COUNT + i] then
			data_list[data_index * PAGE_COUNT + i].in_bag_index = data_list[data_index * PAGE_COUNT + i].index
			table.insert(data, data_list[data_index * PAGE_COUNT + i])
		else
			break
		end
	end
	item:SetData(data)
end

function SendGiftZengSongView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "flush_list_view" then
			self:FlushListView()		
		elseif k == "flush_people_listview" then
			self:FlushPeopleListView()
		elseif k == "all" then
			self:FlushListView()
			self:FlushPeopleListView()
		end
	end	
end

function SendGiftZengSongView:FlushListView()
	local data_list = TableCopy(ItemData.Instance:GetBagNoBindItemList())
	if self.node_list and self.node_list["ListView"] and self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		local count = math.ceil(#data_list / PAGE_COUNT)
		if count <= 0 then
			count = 1
		end		
		for i = 1, PAGE do
			self.node_list["PageToggle" .. i]:SetActive(i <= count)
			if count == 1 then
				self.node_list["PageToggle" .. i]:SetActive(false)
			end
		end
		self.node_list["ListView"].list_page_scroll:SetPageCount(count)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function SendGiftZengSongView:FlushPeopleListView()
	self.scroller_data = SendGiftData.Instance:GetListDataByType(self.send_type)

	if self.node_list and self.node_list["PeopleList"] and self.node_list["PeopleList"].scroller and self.node_list["PeopleList"].scroller.isActiveAndEnabled then
		self.node_list["PeopleList"].scroller:RefreshAndReloadActiveCellViews(true)
		if self.select_index and #self.scroller_data > 0 then
			self.node_list["PeopleList"].scroller:JumpToDataIndex(self.select_index - 1)
		end
	end	
end

function SendGiftZengSongView:OnButtonSend()
	if self:GetSendCellListDataLength() <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.SendGiftView.TipsHelp)
		return	
	end
	if self:GetSendCellListDataLength() > SEND_NUM then
		SysMsgCtrl.Instance:ErrorRemind(Language.SendGiftView.TipsExceed)
		return
	end
	if self:GetSendCellListDataLength() > 0 then
		if self.scroller_data and type(self.scroller_data) == "table" then
			if #self.scroller_data > 0 and self.scroller_data[self.select_index] and self.scroller_data[self.select_index].user_id then
				SendGiftCtrl.Instance:SendCSGiveItemReq(self.scroller_data[self.select_index].user_id, self:GetSendCellListDataLength(), self.send_cell_list_data)
			elseif #self.scroller_data > 0 and self.scroller_data[self.select_index] and self.scroller_data[self.select_index].uid then
				SendGiftCtrl.Instance:SendCSGiveItemReq(self.scroller_data[self.select_index].uid, self:GetSendCellListDataLength(), self.send_cell_list_data)
			elseif #self.scroller_data <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.SendGiftView.TipsNoPeople)
				return
			end
		end
	end
end

----------------------------------------------------------------------------
--ZengSongGroup
----------------------------------------------------------------------------

ZengSongGroup = ZengSongGroup or BaseClass(BaseCell)

function ZengSongGroup:__init()
	self.cell_list = {}
	self.data = {}

	for i = 1, PAGE_COUNT do
		local async_loader = AllocAsyncLoader(self, "item_loader_" .. i)
		async_loader:Load("uis/views/sendgiftview_prefab", "ZengSongItem", function (obj)
			if IsNil(obj) then
				return
			end
			local obj_transform = obj.transform
			obj_transform:SetParent(self.root_node.transform, false)
			local item = ZengSongItem.New(obj)
			table.insert(self.cell_list, item)
			if #self.cell_list == PAGE_COUNT then
				self:SetData(self.data)
			end
		end)
	end
end

function ZengSongGroup:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ZengSongGroup:SetData(data)
	self.data = data
	if #self.cell_list < PAGE_COUNT then return end
	for k,v in pairs(self.cell_list) do
		v:SetData(data[k])
		v:SetIndex(k)
	end
end

---------------------ZengSongItem--------------------------------
ZengSongItem = ZengSongItem or BaseClass(BaseCell)

function ZengSongItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetFromView(TipsFormDef.FROM_GIFT_VIEW)
	self.item_cell:SetInstanceParent(self.node_list["ZengSongItem"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickTips, self))
end

function ZengSongItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ZengSongItem:OnFlush()
	self.item_cell:SetData(self.data)

	if self.data and self.data.in_bag_index and self.data.item_id and SendGiftCtrl.Instance:CheckIsGray(self.data.in_bag_index, self.data.item_id) then
		self.item_cell:SetIconGrayVisible(true)
	else
		self.item_cell:SetIconGrayVisible(false)
	end
end

function ZengSongItem:OnClickTips()
	if not self.data then
		return
	end
	if self.data and self.data.in_bag_index and self.data.item_id and SendGiftCtrl.Instance:CheckIsGray(self.data.in_bag_index, self.data.item_id) then
		self.item_cell:SetIconGrayVisible(true)
		return
	end	
	if SendGiftCtrl.Instance:GetSendCellListDataLength() and SendGiftCtrl.Instance:GetSendCellListDataLength() >= SEND_NUM then
		SysMsgCtrl.Instance:ErrorRemind(Language.SendGiftView.Tips)
		return
	end

	if self.data and self.data.num and self.data.num <= 1 then
		SendGiftCtrl.Instance:InsertSendCellData(self.data)
	else
		SendGiftCtrl.Instance:SetSelectViewData(self.data)
		ViewManager.Instance:Open(ViewName.SendGiftSelectView)
	end
end


----------------------------------------------------------------------------
--PeopleListCell
----------------------------------------------------------------------------

PeopleListCell = PeopleListCell or BaseClass(BaseCell)

function PeopleListCell:__init()
	self.avatar_key = 0
	self.node_list["PeopleListItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function PeopleListCell:__delete()
end

function PeopleListCell:SetRedPoint(state)
	self.node_list["Remind"]:SetActive(state)
end

function PeopleListCell:OnFlush()
	if not self.data or not next(self.data) then return end

	if self.data.gamename then
		self.node_list["NameTxt"].text.text = self.data.gamename
	elseif self.data.role_name then
		self.node_list["NameTxt"].text.text = self.data.role_name
	end

	local role_id = self.data.user_id or self.data.uid
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawImage"], self.node_list["IconImage"], self.data.sex, self.data.prof, false)

	self.node_list["ProfTxt"].text.text = PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1)

	if self.data.is_online ~= 1 then
		UI:SetGraphicGrey(self.node_list["IconImage"], true)
		UI:SetGraphicGrey(self.node_list["RawImage"], true)
		UI:SetGraphicGrey(self.node_list["NameTxt"], true)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], true)
	else
		UI:SetGraphicGrey(self.node_list["IconImage"], false)
		UI:SetGraphicGrey(self.node_list["RawImage"], false)
		UI:SetGraphicGrey(self.node_list["NameTxt"], false)
		UI:SetGraphicGrey(self.node_list["ProfTxt"], false)
	end
	-- 刷新选中特效
	local select_index = self.friend_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function PeopleListCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.friend_view:SetSelectIndex(self.index)
end