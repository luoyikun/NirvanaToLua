BigFaceView = BigFaceView or BaseClass(BaseRender)

function BigFaceView:__init()

	self.cell_list = {}
	self.node_list["BtnSumAttr"].button:AddClickListener(BindTool.Bind(self.ClickAtrr, self))
	self.node_list["BtnLevelUp"].button:AddClickListener(BindTool.Bind(self.ClickLevelUp, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.item_cell = {}
	self.data_list = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtZhanLi"])
	for i = 1, 2 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.node_list["Cell" .. i]
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end

	self.scroller_is_load = false

	local active_group = CoolChatData.Instance:GetActiveGroupByLevel() or {}
	self.last_has_active_num = #active_group

	self.total_attr = CommonStruct.Attribute()
	self:InitScroller()
	self:FlushBigFaceView()
end

function BigFaceView:__delete()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.fight_text = nil
end

function BigFaceView:OpenCallBack()
	self:JumpTo()
end

function BigFaceView:InitScroller()
	local scroller_delegate = self.node_list["Scroller"].page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self.node_list["Scroller"].list_view:Reload()
end

function BigFaceView:GetMaxCellNum()
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local group_cfg = big_face_cfg.group
		return #group_cfg or 0
	end
	return 0
end

function BigFaceView:RefreshCellList(index, cellObj)
	self.scroller_is_load = true
	if self.load_call_back then
		GlobalTimerQuest:AddDelayTimer(self.load_call_back, 0.01)
		self.load_call_back = nil
	end
	local big_face_cell = self.cell_list[cellObj]
	if big_face_cell == nil then
		big_face_cell = BigFaceCellView.New(cellObj)
		self.cell_list[cellObj] = big_face_cell
	end
	local temp = self.data_list[index + 1]
	local data = {}
	if temp then
		for k,v in pairs(temp) do
			if k ~= "limit_level" then
				table.insert(data, k)
			end
		end
	end
	big_face_cell:SetLevel(temp.limit_level)
	big_face_cell:SetData(data)
end

function BigFaceView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(6)
end

function BigFaceView:FlushBigFaceView()
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	local max_level = CoolChatData.Instance:GetBigFaceMaxLevel() or 0
	if max_level <= big_face_level then
		self.node_list["TxtBtn"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnLevelUp"], false)
	else
		self.node_list["TxtBtn"].text.text = Language.Common.UpGrade
		UI:SetButtonEnabled(self.node_list["BtnLevelUp"], true)
	end
	self.node_list["TxtLevel"].text.text = "Lv." .. big_face_level 
	self.total_attr = CoolChatData.Instance:GetBigFaceTotalAttr()
	local capability = CommonDataManager.GetCapability(self.total_attr) or 0
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = capability
	end
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	if big_face_cfg then
		local level_cfg = big_face_cfg.level_cfg
		if level_cfg then
			local cfg = level_cfg[big_face_level + 1]
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
				elseif base_prof == 4 then
					prof_item = TableCopy(cfg.prof_four_item) --cfg.prof_four_item
				end
				need_num = prof_item.num or 0
				has_num = ItemData.Instance:GetItemNumInBagById(prof_item.item_id) or 0
				if has_num < need_num then
					self.node_list["TxtCell2"].text.text = ToColorStr(has_num, COLOR.RED) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
				else
					self.node_list["TxtCell2"].text.text = ToColorStr(has_num, COLOR.GREEN) .. ToColorStr( " / "  .. need_num, COLOR.GREEN)
				end
				if max_level <= big_face_level then
					self.node_list["TxtCell2"].text.text = ToColorStr( "- / - ")
				end
				prof_item.num = 1
				self.item_cell[2].cell:SetData(prof_item)
				if cfg.is_need_prof_item == 0 then
					self.item_cell[2].obj:SetActive(false)
				else
					self.item_cell[2].obj:SetActive(true)
				end
			end
		end
		local group_cfg = big_face_cfg.group or {}
		local total_index = #group_cfg or 0
		self.data_list = {}
		local active_group = CoolChatData.Instance:GetActiveGroupByLevel() or {}
		local has_active_num = #active_group
		if has_active_num > self.last_has_active_num then
			self.last_has_active_num = has_active_num
			self:JumpTo()
		end
		for i = 1, total_index do
			self.data_list[i] = CoolChatData.Instance:GetBigFaceByGroupId(i)
			self.data_list[i].limit_level = CoolChatData.Instance:GetBigFaceActiveLevel(i) or 0
		end
	end
	for k,v in pairs(self.cell_list) do
		v:FlushActive()
	end
	local hp = self.total_attr.max_hp or self.total_attr.maxhp or 0
	local gong_ji = self.total_attr.gong_ji or self.total_attr.gongji or 0
	local fang_yu = self.total_attr.fang_yu or self.total_attr.fangyu or 0
	local ming_zhong = self.total_attr.ming_zhong or self.total_attr.mingzhong or 0
	local shan_bi = self.total_attr.shan_bi or self.total_attr.shanbi or 0
	local bao_ji = self.total_attr.bao_ji or self.total_attr.baoji or 0
	local jian_ren = self.total_attr.jian_ren or self.total_attr.jianren or 0
	self.node_list["Txthp"].text.text = string.format(Language.Tips.Attribute.Hp,hp)
	self.node_list["Txtgongji"].text.text = string.format(Language.Tips.Attribute.Gongji,gong_ji)
	self.node_list["TxtFangyu"].text.text = string.format(Language.Tips.Attribute.Fangyu,fang_yu)
	self.node_list["TxtBaoji"].text.text = string.format(Language.Tips.Attribute.Baoji,bao_ji)
	self.node_list["TxtKangbao"].text.text = string.format(Language.Tips.Attribute.KangBao,jian_ren)
	self.node_list["TxtMingzhong"].text.text = string.format(Language.Tips.Attribute.Mingzhong,ming_zhong)
	self.node_list["TxtShanbi"].text.text = string.format(Language.Tips.Attribute.Shanbi,shan_bi)

end

function BigFaceView:ClickAtrr()
	TipsCtrl.Instance:ShowAttrView(self.total_attr)
end

function BigFaceView:ClickLevelUp()
	CoolChatCtrl.Instance:SendBigChatFaceUpLevelReq()
end

function BigFaceView:JumpTo()
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	if big_face_cfg then
		local group_cfg = big_face_cfg.group or {}
		local total_index = #group_cfg or 0
		local cur_index = 0
		for i = 1, total_index do
			local limit_level = CoolChatData.Instance:GetBigFaceActiveLevel(i) or 0
			if limit_level > big_face_level then
				break
			end
			cur_index = i
		end
		if cur_index > 0 and total_index ~= 0 and cur_index ~= total_index then
			cur_index = cur_index - 1
			if cur_index > total_index - 3 then
				cur_index = total_index - 3
			end
			self:JumpToIndex(cur_index)
		else
			self:JumpToIndex(0)
		end
	end
end

function BigFaceView:JumpToIndex(index)
	self.node_list["Scroller"].list_view:JumpToIndex(index)
end

--------------------------------------------------------------BigFaceCellView-------------------------------------------------------------
BigFaceCellView = BigFaceCellView or BaseClass(BaseCell)

function BigFaceCellView:__init()
	self.icon_cell = {}
	self.level = 0
	for i = 1, 5 do
		self.icon_cell[i] = {}
		self.icon_cell[i].obj = self.node_list["Icon" .. i]
		self.icon_cell[i].cell = BigFaceIconImgCell.New(self.icon_cell[i].obj)
	end
end

function BigFaceCellView:__delete()
	for i = 1, 5 do
		if self.icon_cell[i].cell then
			self.icon_cell[i].cell:DeleteMe()
			self.icon_cell[i].cell = nil
		end
	end
end

function BigFaceCellView:OnFlush()
	for i = 1, 5 do
		local data = self.data[i]
		if data then
			self.icon_cell[i].obj:SetActive(true)
			self.icon_cell[i].cell:SetData(data)
		else
			self.icon_cell[i].obj:SetActive(false)
		end
	end

	self:FlushActive()
end

function BigFaceCellView:FlushActive()
	local level = CoolChatData.Instance:GetBigFaceLevel() or 0
	if level >= self.level then
		self.node_list["ImgHasActive"]:SetActive(true)
		self.node_list["ImgNotActive"]:SetActive(false)
		self.node_list["NotActiveBg"]:SetActive(false)
	else
		self.node_list["ImgHasActive"]:SetActive(false)
		self.node_list["ImgNotActive"]:SetActive(true)
		self.node_list["NotActiveBg"]:SetActive(true)
	end
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0
	big_face_level = big_face_level > self.level and self.level or big_face_level
	if big_face_level < self.level then
		big_face_level = ToColorStr(big_face_level, TEXT_COLOR.RED)
	end
	self.node_list["TxtLevel"].text.text = string.format(Language.Chat.BigFaceActiveLevel, big_face_level, self.level)

end

function BigFaceCellView:SetLevel(level)
	self.level = level
end


----------------------------------
------------
BigFaceIconImgCell = BigFaceIconImgCell or BaseClass(BaseRender)

function BigFaceIconImgCell:__init()
	self.node_list["BtnIcon"].button:AddClickListener(BindTool.Bind(self.ClickIcon, self))
	self.is_gray = false
end

function BigFaceIconImgCell:__delete()
	self.group_view = nil
end

function BigFaceIconImgCell:SetIndex(index)
	self.index = index
end

function BigFaceIconImgCell:HideIcon(Value)
	self.node_list["PanelFrame"]:SetActive(not Value)
end

function BigFaceIconImgCell:ReloadIcon()
	local num = self.data - 1
	local PrefabName = string.format("Image%s", num)
	
	local async_loader = AllocAsyncLoader(self, "ReloadIcon_loader")
	async_loader:Load("uis/icons/bigface/face_" .. (num + 100) .. "_prefab", PrefabName, function(obj)
		if not IsNil(obj) then
			obj.transform:SetParent(self.node_list["PanelFrame"].transform, false)
			UI:SetGraphicGrey(self.node_list["PanelFrame"].gameObject.transform:GetChild(0) , self.is_gray)
		end
	end)
end

function BigFaceIconImgCell:SetData(data)
	if not data or data == 0 then self:HideIcon(true) return end
	self:HideIcon(false)
	self.data = data
	self:ReloadIcon()
end

function BigFaceIconImgCell:SetGray(state)
	self.is_gray = state or false
end

function BigFaceIconImgCell:ClickIcon()
	if not self.data or not self.index then return end
	if not CoolChatData.Instance:GetActiveStatusByIndex(self.data) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Expression.NotActive)
		return
	end
	local face_id = self.index + COMMON_CONSTS.BIGCHATFACE_ID_FIRST
	if self.group_view then
		self.group_view:CallBack(face_id)
	end
end
