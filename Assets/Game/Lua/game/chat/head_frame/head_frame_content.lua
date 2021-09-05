HeadFrameContent = HeadFrameContent or BaseClass(BaseRender)

function HeadFrameContent:__init()
	self.cell_list = {}
	self.select_index = 0

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell1"])

	self.cur_attr = HeadFrameAttrGroup.New(self.node_list["attr1"])
	self.next_attr = HeadFrameAttrGroup.New(self.node_list["attr2"])

	local scroller_delegate = self.node_list["list"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)
	self.list_data = HeadFrameData.Instance:GetListData()
	local use_seq = HeadFrameData.Instance:GetUseFrame()

	for i,v in ipairs(self.list_data) do
		if v.seq == use_seq then
			self.select_index = v.seq
			break
		end
	end
	self.node_list["list"].scroller:ReloadData((self.select_index) / (HeadFrameData.Instance:GetMaxNum() - 1))
	-- self.list.scroller:ReloadData(1)
	if self.list_data then
		self.select_index = self.list_data[1].seq
	end
	
	self:ShowHl()

	--监听事件
	self.node_list["ButtonAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAtrr, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["BtnSelect"].button:AddClickListener(BindTool.Bind(self.OnClickSelect, self))
end

function HeadFrameContent:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.cur_attr then
		self.cur_attr:DeleteMe()
		self.cur_attr = nil
	end

	if self.next_attr then
		self.next_attr:DeleteMe()
		self.next_attr = nil
	end

end

function HeadFrameContent:GetMaxCellNum()
	return HeadFrameData.Instance:GetMaxNum() or 0
end

function HeadFrameContent:RefreshCellList(cell, data_index)
	data_index = data_index + 1

	local head_frame_cell = self.cell_list[cell]
	if head_frame_cell == nil then
		head_frame_cell = HeadFrameCell.New(cell.gameObject)
		head_frame_cell.root_node.toggle.group = self.node_list["list"].toggle_group
		head_frame_cell.parent_view = self
		self.cell_list[cell] = head_frame_cell
	end
	local data = HeadFrameData.Instance:GetListData()
	head_frame_cell:SetIndex(data_index)
	head_frame_cell:SetData(data[data_index])
	head_frame_cell:SetClickCallBack(BindTool.Bind(self.ClickCell, self))
	self:ShowHl()
end

function HeadFrameContent:OnClickAtrr()
	local attr_data = HeadFrameData.Instance:GetHeadFrameAttribute()
	TipsCtrl.Instance:ShowAttrView(attr_data)
end

function HeadFrameContent:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(10)
end

function HeadFrameContent:OnClickButton()
	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_UP_LEVEL, self.cur_data.seq)
end

-- tag
function HeadFrameContent:OpenCallBack(param)
	self:Flush()
end

function HeadFrameContent:ShowHl()
	for k,v in pairs(self.cell_list) do
		v:ShowHl(self.select_index)
	end
end

function HeadFrameContent:OnFlush()
	self:ConstructData()
	self:SetInfo()
end

function HeadFrameContent:SetSelectIndex(item_cfg)
	if item_cfg and item_cfg.item_id then
		local index, num = HeadFrameData.Instance:GetIndexDataByItemId(item_cfg.item_id)
		if index then
			self.select_index = index
			num = num > 5 and num or num - 1
			local data_list = HeadFrameData.Instance:GetListData()
			self.node_list["list"].scroller:ReloadData(num / #data_list)
		end
	end
	self:Flush()

end

function HeadFrameContent:ConstructData()
	self.cur_data = HeadFrameData.Instance:GetChooseData(self.select_index)
	local role = GameVoManager.Instance:GetMainRoleVo()
	CommonDataManager.NewSetAvatar(role.role_id, self.node_list["raw_image_obj"], self.node_list["AvatarImage"], self.node_list["raw_image_obj"], role.sex, role.prof, true)
end


function HeadFrameContent:GetSelectIndex()
	return self.select_index
end


function HeadFrameContent:SetInfo()
	if self.cur_data == nil then
		return
	end
	self.item_cell:SetData({item_id = self.cur_data.item1.item_id})
	local need_num = self.cur_data.need_num
	-- local has_num = self.cur_data.cur_num					--不知道为啥数据拿得比消耗早
	local has_num = ItemData.Instance:GetItemNumInBagById(self.cur_data.item1.item_id)
	local select_seq = HeadFrameData.Instance:GetUseFrame()
	if has_num < need_num then
		self.node_list["ItemNumber"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
	else
		self.node_list["ItemNumber"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
	end
	local cur_attr = HeadFrameData.Instance:GetAttrData(self.cur_data.level, self.cur_data.seq)
	self.cur_attr:SetData(cur_attr)
	local next_attr = HeadFrameData.Instance:GetAttrData(self.cur_data.level + 1, self.cur_data.seq)
	if self.cur_data.level >= self.cur_data.max_level then
		self.next_attr:SetData(cur_attr)
		self.node_list["ItemNumber"].text.text = "- / -"
	else
		self.next_attr:SetData(next_attr)
	end

	self.node_list["TitleText"].text.text = self.cur_data.name
	self.node_list["AvatarImage1"].image:LoadSprite(ResPath.GetHeadFrameIcon(self.cur_data.seq))
	self.node_list["BtnSelect"]:SetActive(self.cur_data.level > 0)

	if self.cur_data.level > 0 and self.cur_data.level < self.cur_data.max_level then
		self.node_list["ButtonText"].text.text = Language.ChatWin.BubbleActive
		UI:SetButtonEnabled(self.node_list["Button"], true)
	elseif self.cur_data.level <= 0 then
		self.node_list["ButtonText"].text.text = Language.ChatWin.JiHuo
		UI:SetButtonEnabled(self.node_list["Button"], true)
	else
		self.node_list["ButtonText"].text.text = Language.ChatWin.BubbleMaxLevel
		UI:SetButtonEnabled(self.node_list["Button"], false)
	end

	self.node_list["TxtBtnSelect"].text.text = Language.ChatWin.BubbleSelect
	UI:SetButtonEnabled(self.node_list["BtnSelect"], true)
	if not self.cur_data.is_active then
		UI:SetButtonEnabled(self.node_list["BtnSelect"], false)
		return
	end

	if self.cur_data.seq == select_seq then
		self.node_list["TxtBtnSelect"].text.text = Language.ChatWin.BubbleCancelSelect
	end

	self.node_list["list"].scroller:RefreshAndReloadActiveCellViews(false)
end

function HeadFrameContent:ClickCell(data)
	if HeadFrameData.Instance:GetUseFrame() == data.seq and self.select_index == data.seq then
		--CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, -1)
		self.select_index = data.seq
		self:ShowHl()
		self:Flush()
		return
	end
	
	-- if data.level > 0 and HeadFrameData.Instance:GetUseFrame() ~= data.seq then
	-- 	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, data.seq)
	-- end
	self.select_index = data.seq
	self:ShowHl()
	self:Flush()
end


function HeadFrameContent:OnClickSelect()
	if self.select_index < 0 then return end
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local select_seq = HeadFrameData.Instance:GetUseFrame()

	if self.cur_data.seq == select_seq then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, -1)
		return
	end

	if self.cur_data.is_active then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_FRAME_USE, self.select_index)
		return
	end
end



-----------------------------HeadFrameCell---------------------------------------------
HeadFrameCell = HeadFrameCell or BaseClass(BaseCell)
function HeadFrameCell:__init()
	self.node_list["toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function HeadFrameCell:__delete()
	if self.parent_view then
		self.parent_view = nil
	end
end

function HeadFrameCell:OnFlush()
	self:SetInfo()
end

function HeadFrameCell:SetInfo()
	if nil == self.data then
		return
	end
	self.node_list["Text"].text.text = string.format("LV.%s", self.data.level)
	local is_need = self.data.level <= 0
	local item_id = self.data.item1 and self.data.item1.item_id or -1
	local item_data = ItemData.Instance:GetItemConfig(item_id)
	if item_data then
		local bundle1, asset1 = ResPath.GetQualityIcon(item_data.color)
		self.node_list["Quality"].image:LoadSprite(bundle1, asset1)
		self.node_list["Quality"]:SetActive(true)
		UI:SetGraphicGrey(self.node_list["Quality"], is_need)
	end
	self.node_list["Lock"]:SetActive(is_need)
	
	UI:SetGraphicGrey(self.node_list["IconImage"], is_need)
	self.node_list["ButtonText"].text.text = self.data.name
	local bundle, asset = ResPath.GetItemIcon(self.data.image)
	self.node_list["IconImage"].image:LoadSprite(bundle, asset)

	local has_num = ItemData.Instance:GetItemNumInBagById(self.data.item1.item_id)
	local flag = has_num >= self.data.need_num and self.data.level < self.data.max_level
	self.node_list["FrameItemImage"]:SetActive(flag)
	-- self.node_list["FrameItemImage"]:SetActive(self.data.is_can_up)				--数据拿得不对
	local is_use = HeadFrameData.Instance:GetUseFrame()
	self.node_list["ButtonImage"]:SetActive(is_use == self.data.seq)
end

function HeadFrameCell:ShowHl(select_index)
	local data = HeadFrameData.Instance:GetListData()
	if data then
		local seq = data[self.index].seq
		self.node_list["toggle"].toggle.isOn = select_index == seq
	end
	
end

function HeadFrameCell:OnClick()
	if self.click_callback then
		self.click_callback(self.data)
	end
end

function HeadFrameCell:SetClickCallBack(func)
	self.click_callback = func
end


HeadFrameAttrGroup = HeadFrameAttrGroup or BaseClass(BaseRender)

function HeadFrameAttrGroup:__init()

	self.attrs = {}
	for i = 1, 3 do
		self.attrs[i] = HeadFrameAttr.New(self.node_list["attr_" .. i])
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Number"])
end

function HeadFrameAttrGroup:__delete()
	self.fight_text = nil
end

function HeadFrameAttrGroup:SetData(data)
	if data == nil then
		return
	end
	self.node_list["Number1"].text.text = data.level
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = data.power
	end
	for i = 1, 3 do
		self.attrs[i]:SetData(data.attrs[i])
		--self.attrs[i]:SetImage(i)
	end
end

HeadFrameAttr = HeadFrameAttr or BaseClass(BaseRender)

function HeadFrameAttr:__init()

end

function HeadFrameAttr:__delete()
	
end

function HeadFrameAttr:SetData(value)
	if value == nil then
		return
	end
	self.node_list["Attr"].text.text = value
end

-- function HeadFrameAttr:SetImage(i)
-- 	local bundle, asset = ResPath.GetBaseAttrIcon(GameEnum.AttrList[i])
-- 	self.node_list["Icon"].image:LoadSprite(bundle, asset)
-- end