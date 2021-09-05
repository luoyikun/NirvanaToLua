SendGiftRecordView = SendGiftRecordView or BaseClass(BaseRender)
function SendGiftRecordView:__init()
	self.list_data = {}
	self.cell_list = {}
	local list_simple_delegate = self.node_list["RecordList"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	for i = 1, 2 do
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
	end
end

function SendGiftRecordView:__delete()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil
end

function SendGiftRecordView:ShowIndexCallBack()
	SendGiftData.Instance:SetSelectToggle(2)
	local toggle_num = SendGiftData.Instance:GetSelectToggleNum()
	self:OnClickToggle(toggle_num)
	self:Flush()
end

function SendGiftRecordView:CloseCallBack()
	SendGiftData.Instance:SetSelectToggle(2)
end

function SendGiftRecordView:GetNumberOfCell()
	return
end

function SendGiftRecordView:GetNumberOfCell()
	return #self.list_data or 0
end

function SendGiftRecordView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local drop_cell = self.cell_list[cell]
	if nil == drop_cell then
		drop_cell = SendGiftRecordItem.New(cell.gameObject)
		self.cell_list[cell] = drop_cell
	end

	drop_cell:SetData(self.list_data[data_index])
end

function SendGiftRecordView:OnFlush()
	self.list_data = SendGiftData.Instance:GetGiveItemRecord() or {}
	local flag = #self.list_data > 0
	self.node_list["BG"]:SetActive(not flag)
	self.node_list["RecordList"]:SetActive(flag)
	if flag then
		if self.node_list["RecordList"] and self.node_list["RecordList"].scroller then
			self.node_list["RecordList"].scroller:ReloadData(0)
		end
	end
end

function SendGiftRecordView:OnClickToggle(i)
	SendGiftData.Instance:SetSelectToggle(i)
	SendGiftCtrl.Instance:SendGiveItemOpera(GIVE_ITEM_OPERA_TYPE.GIVE_ITEM_OPERA_TYPE_INFO, i - 1)
	if self.node_list["Toggle" .. i] and self.node_list["Toggle" .. i].toggle then
		self.node_list["Toggle" .. i].toggle.isOn = true
	end
end

-------------------------SendGiftRecordItem---------------------
SendGiftRecordItem = SendGiftRecordItem or BaseClass(BaseCell)
function SendGiftRecordItem:__init()
	
end

function SendGiftRecordItem:__delete()
	
end

function SendGiftRecordItem:OnFlush()
	if nil == self.data or nil == next(self.data) then
		return
	end

	local time_str = os.date("%m/%d %X", self.data.timestamp)

	local sex = SendGiftData.Instance:GetNameById(self.data.uid) or ""	
	local index, open_type = SendGiftData.Instance:GetRoleindexByUid(self.data.uid)
	local color = sex == 1 and TEXT_COLOR.BLUE_4 or TEXT_COLOR.PINK
	local name_str = ToColorStr(self.data.role_name, color)
	local num = ToColorStr(self.data.item_num, TEXT_COLOR.GREEN)
	local str = ""
	local record_type = SendGiftData.Instance:GetIsGiveRecord()
	local link_type = 0
	if record_type == 1 then
		link_type = CHAT_LINK_TYPE.SEND_GTFT_RECORD
		str = string.format(Language.Society.SendGiftRecord[1],time_str, name_str, self.data.item_id, num, link_type, index, open_type)
	else
		link_type = CHAT_LINK_TYPE.SEND_GTFT_RECORD_CONTINUE
		str = string.format(Language.Society.SendGiftRecord[0],time_str, name_str, self.data.item_id, num, link_type, index, open_type)
	end
	RichTextUtil.ParseRichText(self.node_list["rich_text"].rich_text, str)
end
