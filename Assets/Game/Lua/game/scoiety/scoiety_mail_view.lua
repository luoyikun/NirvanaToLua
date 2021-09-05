ScoietyMailView = ScoietyMailView or BaseClass(BaseRender)
function ScoietyMailView:__init()
	self.item_list = {}
	self.select_data = {}

	self.node_list["BtnDelRead"].button:AddClickListener(BindTool.Bind(self.ClickDelRead, self))
	self.node_list["BtnGetAll"].button:AddClickListener(BindTool.Bind(self.ClickGetAllReward, self))
	self.node_list["BtnGet"].button:AddClickListener(BindTool.Bind(self.ClickGetReward, self))
	self.node_list["IconWrite"].button:AddClickListener(BindTool.Bind(self.ClickWrite, self))
	self.node_list["IconDel"].button:AddClickListener(BindTool.Bind(self.ClickDel, self))

	self.node_list["GetTimeText"].text.text = ""

		-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	local scroller_delegate = self.node_list["MailList"].list_simple_delegate

		--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local mail_cell = self.cell_list[cell]
		if mail_cell == nil then
			mail_cell = ScrollerMailCell.New(cell.gameObject)
			mail_cell.root_node.toggle.group = self.node_list["MailList"].toggle_group
			mail_cell.mail_view = self
			self.cell_list[cell] = mail_cell
		end
		mail_cell:SetIndex(data_index)
		mail_cell:SetData(self.scroller_data[data_index])
	end

	for i = 1, 5 do
		local item_cell = ItemCell.New()
		item_cell:SetFromView(TipsHandleDef.CANGKUEQUIP_EXCHANGE)
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

end

function ScoietyMailView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function ScoietyMailView:ClearItem()
	for k, v in ipairs(self.item_list) do
		if v then
			v:SetData(nil)
		end
	end
end

function ScoietyMailView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "mail_left" then
			self:FlushLeft()
		elseif k == "mail_right" then
			self:FlushRight()
		elseif k == "mail_all" then
			self:FlushMailView()
		elseif k == "mail_fetch" then
			self:FlushMailFetch()
		end
	end
end

function ScoietyMailView:CloseMailView()
	self:ClearSelect()
end

function ScoietyMailView:ItemClick(cell)
	local data = cell:GetData()
	TipsCtrl.Instance:OpenItem(data)
end

function ScoietyMailView:ClickDelRead()
	local mail_list = ScoietyData.Instance:GetMailList()
	if not mail_list.mails or not next(mail_list.mails) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoMail)
		return
	end
	ScoietyCtrl.Instance:MailCleanReq()
end

function ScoietyMailView:ClickGetAllReward()
	local mail_list = ScoietyData.Instance:GetMailList()
	if not mail_list.mails or not next(mail_list.mails) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoMail)
		return
	end
	ScoietyCtrl.Instance:MailOneKeyFetchAttachmentReq()
end

function ScoietyMailView:ClickWrite()

end

function ScoietyMailView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyMailView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyMailView:SetContent(des)
	local list_num = #self.scroller_data or 0
	if self.node_list["RichText"] and des == "" then
		if list_num == 0 then
			self.node_list["RichText"].rich_text:Clear()
			self.node_list["GetTimeText"].text.text = des
		end
		self.node_list["ItemList"]:SetActive(false)
	end
end

function ScoietyMailView:SetSelectMailIndex(index)
	self.mail_index = index
end

function ScoietyMailView:ClickGetReward()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoSelect)
		return
	end
	if not ScoietyData.Instance:IsNotGet(self.mail_index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoFuJian)
		return
	end
	local param_t = {}
	param_t.mail_index = self.mail_index
	ScoietyCtrl.Instance:MailFetchAttachmentReq(param_t)
end

function ScoietyMailView:ClickDel()
	if not self.select_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NoSelect)
		return
	end
	if ScoietyData.Instance:IsNotGet(self.mail_index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.CanNotDelwithFujian)
		return
	end

	ScoietyCtrl.Instance:MailDeleteReq(self.mail_index)
end

function ScoietyMailView:ClearSelect()
	-- 清除选中
	self.select_index = nil
	self.select_data = {}
	self.item_count = 0
	self:SetContent("")
	if self.node_list["WriteText"] then
		self.node_list["WriteText"].text.text = Language.Society.WriteText1
	end
	self:ClearItem()
end

function ScoietyMailView:SetSelectData(data)
	self.select_data = data
end

function ScoietyMailView:SetActive(value)
	self.root_node:SetActive(value)
end

function ScoietyMailView:FlushMailView()
	self:JumpToFirst()
end

function ScoietyMailView:JumpToFirst()
	self:FlushLeft()
	if next(self.scroller_data) ~= nil then
		self.select_index = 1
		for i,v in ipairs(self.scroller_data) do
			if i == self.select_index then
				v.mail_status.is_read = 1
				self:SetSelectData(v)
				self:SetSelectIndex(i)
				self:SetSelectMailIndex(v.mail_index)
				if v.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
					ScoietyData.Instance:SetIsPriviteMail(true)
					ScoietyData.Instance:SetSendName(v.mail_status.sender_name)
				else
					ScoietyData.Instance:SetIsPriviteMail(false)
					ScoietyData.Instance:SetSendName("")
				end
				ScoietyCtrl.Instance:MailReadReq(v.mail_index)
			end
		end
	end
	self.node_list["MailList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ScoietyMailView:FlushMailFetch()
	self:FlushLeft()
	if next(self.scroller_data) ~= nil then
		self.select_index = 1
		for i,v in ipairs(self.scroller_data) do
			if 1 == v.has_attachment then
				self.select_index = i
				v.mail_status.is_read = 1
				self:SetSelectData(v)
				self:SetSelectIndex(i)
				self:SetSelectMailIndex(v.mail_index)
				if v.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
					ScoietyData.Instance:SetIsPriviteMail(true)
					ScoietyData.Instance:SetSendName(v.mail_status.sender_name)
				else
					ScoietyData.Instance:SetIsPriviteMail(false)
					ScoietyData.Instance:SetSendName("")
				end
				ScoietyCtrl.Instance:MailReadReq(v.mail_index)
				break
			end
		end
	end
	self.node_list["MailList"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ScoietyMailView:FlushLeft()
	local mail_index_list = ScoietyData.Instance:GetMailIndexList()
	local main_list = {}
	for k, v in ipairs(mail_index_list) do
		local mail = ScoietyData.Instance:GetMailByIndex(v)
		table.insert(main_list, mail)
	end
	self.scroller_data = main_list
	self:ClearSelect()
	self.node_list["MailList"].scroller:ReloadData(0)
end

function ScoietyMailView:SetItemData(data_list)
	if data_list then
		local temp_list = {}
		self.item_count = 0
		for k, v in ipairs(data_list) do
			if v.item_id ~= 0 then
				table.insert(temp_list, v)
			end
		end
		for k, v in ipairs(self.item_list) do
			if temp_list[k] then
				self.item_count = self.item_count + 1
				v:SetNotShowRedPoint(true)
				v:SetData(temp_list[k])
				v:SetInteractable(true)
			else
				v:SetData(nil)
				v:SetInteractable(false)
			end
			v:SetHighLight(false)
		end
	end
end

function ScoietyMailView:SetSpecialItem(content_info)
	if self.item_count >= 5 then
		return
	end

	for k,v in pairs(content_info.virtual_item_list) do
		if v.virtual_item_type and v.virtual_item_type >= 0 and v.virtual_num and v.virtual_num > 0 then
			if ScoietyData.MailVirtualItem[v.virtual_item_type] then
				local item_data = {}
				self.item_count = self.item_count + 1
				item_data.item_id = ScoietyData.MailVirtualItem[v.virtual_item_type]
				item_data.num = v.virtual_num
				if self.item_list[self.item_count] then
					self.item_list[self.item_count]:SetNotShowRedPoint(true)
					self.item_list[self.item_count]:SetData(item_data)
					if j == FuBenDataExpItemId.ItemId then
						self.item_list[self.item_count]:SetInteractable(false)
					else
						self.item_list[self.item_count]:SetInteractable(true)
					end
				end
			end
			if self.item_count >= 5 then
				return
			end
		end
	end

	local function add_item(item_id, num)
		self.item_count = self.item_count + 1
		local item_data = {}
		item_data.item_id = item_id
		item_data.num = num
		if self.item_list[self.item_count] then
			self.item_list[self.item_count]:SetNotShowRedPoint(true)
			self.item_list[self.item_count]:SetData(item_data)
			self.item_list[self.item_count]:SetInteractable(true)
		end
	end

	if content_info.coin_bind > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_BIND_COIN], content_info.coin_bind)
	end

	if content_info.gold > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_GOLD], content_info.gold)
	end

	if content_info.gold_bind > 0 then
		add_item(ScoietyData.MailVirtualItem[MAIL_VIRTUAL_ITEM_BIND_GOLD], content_info.gold_bind)
	end

	if self.item_count > 5 then
		self.item_count = 5
	end
end

function ScoietyMailView:FlushRight()
	local detail_info = ScoietyData.Instance:GetMailDetail()
	local content_info = detail_info.content_param
	RichTextUtil.ParseRichText(self.node_list["RichText"].rich_text, content_info.contenttxt, 22, TEXT_COLOR.LOWBLUE, nil, nil, 24)
	if next(self.select_data) then
		local mail_status = self.select_data.mail_status
		local recv_time = os.date("%Y-%m-%d  %X", mail_status.recv_time)
		self.node_list["GetTimeText"].text.text = recv_time
		if ScoietyData.Instance:GetIsPriviteMail() then
			self.node_list["WriteText"].text.text = Language.Society.WriteText2
		else
			self.node_list["WriteText"].text.text = Language.Society.WriteText1
		end
	end

	self:SetItemData(content_info.item_list)
	self:SetSpecialItem(content_info)

	if self.item_count > 0 then
		self.node_list["ItemList"]:SetActive(true)
	else
		self.node_list["ItemList"]:SetActive(false)
	end
end

----------------------------------------------------------------------------
--ScrollerMailCell 		邮件滚动条格子
----------------------------------------------------------------------------

ScrollerMailCell = ScrollerMailCell or BaseClass(BaseCell)

function ScrollerMailCell:__init()
	self.node_list["MailItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function ScrollerMailCell:__delete()

end

function ScrollerMailCell:OnFlush()
	if not self.data or not next(self.data) then return end
	self.mail_status = self.data.mail_status

	--local title_text = ""
	self.node_list["CornerTag"].gameObject:SetActive(false)
	self.node_list["CornerTag1"].gameObject:SetActive(false)
	self.node_list["CornerTag2"].gameObject:SetActive(false)
	self.node_list["CornerTag3"].gameObject:SetActive(false)
	self.node_list["CornerTag4"].gameObject:SetActive(false)

	self.node_list["UnRead"].gameObject:SetActive(false)
	self.node_list["Read"].gameObject:SetActive(false)

	if self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
		--self.node_list["CornerTag2"].gameObject:SetActive(true)
		self.node_list["UnRead"].gameObject:SetActive(true)
		subject = self.data.subject

	elseif self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_SYSTEM or self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_CHONGZHI then
		--self.node_list["CornerTag"].gameObject:SetActive(true)
		self.node_list["UnRead"].gameObject:SetActive(true)
		subject = Language.Society.TitleSystem

	elseif self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_GUILD then
		--self.node_list["CornerTag3"].gameObject:SetActive(true)
		self.node_list["UnRead"].gameObject:SetActive(true)
		subject = Language.Society.TitleGuild
	end
	
	self.node_list["NameTxt"].text.text = subject
	if self.mail_status.is_read == 1 then
		self:SetGray(true)
	else
		self:SetGray(false)
	end

	if self.data.has_attachment == 1 then
		self:SetPointVisible(true)
	else
		self:SetPointVisible(false)
	end

	-- 刷新选中特效
	local select_index = self.mail_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif not self.root_node.toggle.isOn and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
	self:DecideShowRead()
end

function ScrollerMailCell:ClickItem()
	self.root_node.toggle.isOn = true
	if self.index == self.mail_view:GetSelectIndex() then
		return
	end
	self.mail_status.is_read = 1
	self:SetGray(true)
	self.mail_view:SetSelectData(self.data)
	self.mail_view:SetSelectIndex(self.index)
	self.mail_view:SetSelectMailIndex(self.data.mail_index)
	if self.mail_status.kind == MAIL_TYPE.MAIL_TYPE_PERSONAL then
		ScoietyData.Instance:SetIsPriviteMail(true)
		ScoietyData.Instance:SetSendName(self.mail_status.sender_name)
	else
		ScoietyData.Instance:SetIsPriviteMail(false)
		ScoietyData.Instance:SetSendName("")
	end
	ScoietyCtrl.Instance:MailReadReq(self.data.mail_index)
	self:DecideShowRead()
end

function ScrollerMailCell:SetPointVisible(value)
	self.node_list["Point"]:SetActive(value)
end

function ScrollerMailCell:SetGray(value)
	if value then
		self.node_list["ComeTxt"].text.color = Color.New(0.75, 0.75, 0.75, 1)
		self.node_list["XinTxt"].text.color = Color.New(0.75, 0.75, 0.75, 1)
	end
end

function ScrollerMailCell:DecideShowRead()  				
	if 1 == self.mail_status.is_read then						--判断是否改变为已读
		--self.node_list["CornerTag4"]:SetActive(true)
		self.node_list["Read"].gameObject:SetActive(true)
	else 
		--self.node_list["CornerTag4"]:SetActive(false)
		self.node_list["Read"].gameObject:SetActive(false) 
	end
end