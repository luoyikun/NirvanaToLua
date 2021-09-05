BubbleView = BubbleView or BaseClass(BaseRender)

function BubbleView:__init()

	self.bubble_data = {}
	self.cell_list = {}
	self.select_index = 1

	self.item_cell = {}
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.node_list["Cell" .. i]
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end


	local scroller_delegate = self.node_list["ListBubble"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self.cur_attr = BubbleAttrGroup.New(self.node_list["attr1"])
	self.next_attr = BubbleAttrGroup.New(self.node_list["attr2"])

	self.node_list["BtnSumAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAtrr, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["BtnSelect"].button:AddClickListener(BindTool.Bind(self.OnClickSelectBubble, self))
end

function BubbleView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
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

function BubbleView:GetMaxCellNum()
	return #self.bubble_data or 0
end

function BubbleView:RefreshCellList(cell, data_index)
	data_index = data_index + 1

	local bubble_cell = self.cell_list[cell]
	if bubble_cell == nil then
		bubble_cell = BubbleCell.New(cell.gameObject)
		bubble_cell.root_node.toggle.group = self.node_list["ListBubble"].toggle_group
		bubble_cell.bubble_view = self
		self.cell_list[cell] = bubble_cell
	end

	bubble_cell:SetIndex(data_index)
	bubble_cell:SetData(self.bubble_data[data_index])
end

function BubbleView:OnClickAtrr()
	local attr_data = CoolChatData.Instance:GetBubbleAttribute()
	TipsCtrl.Instance:ShowAttrView(attr_data)
end

function BubbleView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(8)
end

-- 升级气泡框
function BubbleView:OnClickButton()
	CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_UP_LEVEL, self.bubble_data[self.select_index].seq - 1, 0, 0)
end

-- 选择气泡框
function BubbleView:OnClickSelectBubble()
	if self.select_index <= 0 then return end
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local select_seq = CoolChatData.Instance:GetSelectSeq()

	if seq - 1 == select_seq then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, -1, 0, 0)
		return
	end

	if select_data.is_activate then
		CoolChatCtrl.Instance:SendPersonalizeWindowOperaReq(PERSONALIZE_WINDOW_OPERA_TYPE.PERSONALIZE_WINDOW_BUBBLE_USE, self.bubble_data[self.select_index].seq - 1, 0, 0)
		return
	end
end

function BubbleView:SetBubbleName()
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local name = select_data.name
	local bubble_level = self.bubble_data[self.select_index].level or 0
	name = "Lv." .. bubble_level .. " " .. name
	self.node_list["TxtTitle"].text.text = name
end

function BubbleView:ChangeAni()
	local index = self.bubble_data[self.select_index].seq
	local PrefabName = "BubbleChat" .. index

	local async_loader = AllocAsyncLoader(self, "effect_loader")
	async_loader:Load("uis/chatres/bubbleres/bubble" .. index .. "_prefab", PrefabName, function(obj)
		if not IsNil(obj) then
			obj.transform:SetParent(self.node_list["AniObj"].transform, false)
		end
	end)
end

function BubbleView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BubbleView:GetSelectIndex()
	return self.select_index
end

function BubbleView:ChangeNeedItemText()
	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local item_data = select_data.item1
end

function BubbleView:ChangeButtonName()
	if self.select_index <= 0 then
		return
	end

	local select_data = CoolChatData.Instance:GetBubbleDataByIndex(self.select_index)
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local select_seq = CoolChatData.Instance:GetSelectSeq()
	if nil == select_data or nil == seq or nil == select_seq then
		return
	end 

	local max_level = CoolChatData.Instance:GetBubbleMaxLevel(seq)
	local bubble_level = self.bubble_data[self.select_index].level or 0
	if nil == max_level or nil == bubble_level then
		return
	end
	local cur_attr = CoolChatData.Instance:GetAttrData(bubble_level, seq - 1)
	self.cur_attr:SetData(cur_attr)
	local next_attr = CoolChatData.Instance:GetAttrData(bubble_level + 1, seq - 1)
	if bubble_level >= max_level then
		self.next_attr:SetData(cur_attr)
	else
		self.next_attr:SetData(next_attr)
	end
	self.node_list["BtnSelect"]:SetActive(bubble_level > 0)

	if bubble_level >= max_level then
		self.node_list["TxtBtnUpGrade"].text.text = Language.ChatWin.BubbleMaxLevel
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
	elseif bubble_level <= 0 then
		self.node_list["TxtBtnUpGrade"].text.text = Language.ChatWin.JiHuo
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
	else
		self.node_list["TxtBtnUpGrade"].text.text = Language.ChatWin.BubbleActive
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
	end

	self.node_list["TxtBtnSelect"].text.text = Language.ChatWin.BubbleSelect
	UI:SetButtonEnabled(self.node_list["BtnSelect"], true)
	if not select_data.is_activate then
		UI:SetButtonEnabled(self.node_list["BtnSelect"], false)
		return
	end

	if seq - 1 == select_seq then
		self.node_list["TxtBtnSelect"].text.text = Language.ChatWin.BubbleCancelSelect
	end
end

function BubbleView:FlushBubbleView(param)
	self.bubble_data = CoolChatData.Instance:GetBubbleInfo()
	if param and param.item_id then
		local index, num = CoolChatData.Instance:GetIndexDataByItemId(param.item_id)
		if index then
			self.select_index = num
			num = num > 5 and num or num - 1
			self.node_list["ListBubble"].scroller:ReloadData(num / #self.bubble_data)
		end
	end

	if self.node_list["ListBubble"].scroller.isActiveAndEnabled then
		self.node_list["ListBubble"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:ChangeAni()
	self:SetBubbleName()
	self:ChangeButtonName()
	self:FlushItem()
end

function BubbleView:FlushItem()
	local bubble_level = self.bubble_data[self.select_index].level or 0

	local cfg = CoolChatData.Instance:GetBubbleCfgByLevel(self.bubble_data[self.select_index].seq, bubble_level)
	if cfg then
		local item = TableCopy(cfg.common_item)
		if item.item_id > 0 then
			self.item_cell[1].obj:SetActive(true)
			item.num = 1
			self.item_cell[1].cell:SetData(item)
			local need_num = cfg.common_item.num or 0
			local has_num = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0
			if has_num < need_num then
				self.node_list["TxtCell1"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
			else
				self.node_list["TxtCell1"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
			end
		else
			self.item_cell[1].obj:SetActive(false)
		end
		local prof = Scene.Instance:GetMainRole().vo.prof
		local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
		local prof_item = TableCopy(cfg.prof_one_item)
		if base_prof == 2 then
			prof_item = TableCopy(cfg.prof_two_item)
		elseif base_prof == 3 then
			prof_item = TableCopy(cfg.prof_three_item)
		end
		need_num = prof_item.num or 0
		has_num = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
		if has_num < need_num then
			self.node_list["TxtCell2"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
		else
			self.node_list["TxtCell2"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
		end
		prof_item.num = 1
		self.item_cell[2].cell:SetData(prof_item)
		if cfg.is_need_prof_item == 0 then
			self.item_cell[2].obj:SetActive(false)
		else
			self.item_cell[2].obj:SetActive(true)
		end
	end
	local seq = CoolChatData.Instance:GetSeqByIndex(self.select_index)
	local max_level = CoolChatData.Instance:GetBubbleMaxLevel(seq)
	local bubble_level = self.bubble_data[self.select_index].level or 0
	if bubble_level >= max_level then
		self.node_list["TxtCell2"].text.text = Language.Chat.MaxLevel
	end
end

-----------------------------BubbleCell---------------------------------------------
BubbleCell = BubbleCell or BaseClass(BaseCell)
function BubbleCell:__init()
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self))
	--监听事件
	self.node_list["BubbleItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function BubbleCell:__delete()

end

function BubbleCell:OnToggleChange()
	if self.root_node.toggle.isOn then
		self.node_list["TxtPanel"].text.text = self.data.name
		self.node_list["TxtLimitLevel"].text.text = string.format("LV.%s", self.data.level)
	else
		self.node_list["TxtPanel"].text.text = self.data.name
		self.node_list["TxtLimitLevel"].text.text = string.format("LV.%s", self.data.level)
	end

end

function BubbleCell:OnFlush()
	if not next(self.data) then return end
	local item_id = self.data.item1 and self.data.item1.item_id or -1
	local item_data = ItemData.Instance:GetItemConfig(item_id)
	local bubble, asset = ResPath.GetRightBubbleIcon(self.data.seq)
	self.node_list["ImgIcon"].image:LoadSprite(bubble, asset)
	self.node_list["Img1"]:SetActive((self.data.select_seq + 1) == self.data.seq)
	if item_data then
		local bundle1, asset1 = ResPath.GetQualityIcon(item_data.color)
		self.node_list["Quality"].image:LoadSprite(bundle1, asset1)
		self.node_list["Quality"]:SetActive(true)
		UI:SetGraphicGrey(self.node_list["Quality"], not self.data.is_activate)
	end
	self.node_list["Lock"]:SetActive(not self.data.is_activate)
	--self.node_list["TxtLimitLevel"]:SetActive(not self.data.is_activate)
	UI:SetGraphicGrey(self.node_list["ImgIcon"], not self.data.is_activate)
	self:OnToggleChange()

	self.node_list["ImgRed"]:SetActive(false)
	if self.data.level < CoolChatData.Instance:GetBubbleMaxLevel(self.data.seq) then
		local cfg = CoolChatData.Instance:GetBubbleCfgByLevel(self.data.seq, self.data.level)
		if cfg then
			-- local need_num1 = cfg.common_item.num or 0
			-- local has_num1 = ItemData.Instance:GetItemNumInBagById(cfg.common_item.item_id) or 0

			local prof = Scene.Instance:GetMainRole().vo.prof
			local base_prof = PlayerData.Instance:GetRoleBaseProf(prof)
			local prof_item = cfg.prof_one_item
			if base_prof == 2 then
				prof_item = cfg.prof_two_item
			elseif base_prof == 3 then
				prof_item = cfg.prof_three_item
			elseif base_prof == 4 then
				prof_item = cfg.prof_four_item
			end
			local need_num2 = prof_item.num or 0
			local has_num2 = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
			-- if has_num1 >= need_num1 and has_num2 >= need_num2 then
			if has_num2 >= need_num2 then
				self.node_list["ImgRed"]:SetActive(true)
			end
		end
	end

	-- 刷新选中特效
	local select_index = self.bubble_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function BubbleCell:ClickItem()
	self.root_node.toggle.isOn = true
	local select_index = self.bubble_view:GetSelectIndex()
	if select_index == self.index then
		return
	end
	self.bubble_view:SetSelectIndex(self.index)
	self.bubble_view:ChangeAni()
	self.bubble_view:SetBubbleName()
	self.bubble_view:ChangeButtonName()
	self.bubble_view:FlushItem()
end


BubbleAttrGroup = BubbleAttrGroup or BaseClass(BaseRender)

function BubbleAttrGroup:__init()

	self.attrs = {}
	for i = 1, 3 do
		self.attrs[i] = BubbleAttr.New(self.node_list["attr_" .. i])
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Number"])
end

function BubbleAttrGroup:__delete()
	self.fight_text = nil
end

function BubbleAttrGroup:SetData(data)
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

BubbleAttr = BubbleAttr or BaseClass(BaseRender)

function BubbleAttr:__init()

end

function BubbleAttr:__delete()
	
end

function BubbleAttr:SetData(value)
	if value == nil then
		return
	end
	self.node_list["Attr"].text.text = value
end