WantEquipView = WantEquipView or BaseClass(BaseView)

function WantEquipView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/chatview_prefab", "WantEquipView"}
	}
	self.play_audio = true
	self.is_modal = true	
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.equip_cell = {}
	self.select_data = nil
end

function WantEquipView:__delete()

end

function WantEquipView:ReleaseCallBack()
	for k,v in pairs(self.equip_cell) do
		v:DeleteMe()
	end
	self.equip_cell = {}
	self.equip_list = nil
end

-------------------回调---------------------
function WantEquipView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(660,412,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.Guide.WantEquip
	self.node_list["WantEquipButton"].button:AddClickListener(BindTool.Bind(self.OnClickWantEquip, self))
	-- 创建抽奖网格
	self.equip_list = self.node_list["ListView"]
	local list_delegate = self.equip_list.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.equip_list.list_view:JumpToIndex(0)
	self.equip_list.list_view:Reload()
end

function WantEquipView:OpenCallBack()
	self:Flush()
end

function WantEquipView:CloseCallBack()
	self.select_data = nil
	self.other_data = nil
	self.equip_id_data = nil
end

function WantEquipView:OnClickWantEquip()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if 0 >= guild_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.PleaseJoinGuild)
		return
	end

	if nil == self.select_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Equip.XuanzeZhuangBei)
		return
	end
	local dec
	if self.other_data and (self.other_data.from_view == "orange_suit" or self.other_data.from_view == "red_suit") then
		dec = Language.Chat.WantEquipDec2[math.random(1, #Language.Chat.WantEquipDec2)] or ""
	else
		dec = Language.Chat.WantEquipDec[math.random(1, #Language.Chat.WantEquipDec)] or ""
	end
	-- local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	--local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	local equip_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")
	local item_id = self.select_data.item_id
	local equip_order = 0 																				
	if equip_cfg ~= nil and equip_cfg[item_id] ~= nil then
		equip_order = equip_cfg[item_id].order and equip_cfg[item_id].order - 1 or 0 						--子豪说阶数全部取装备配置里的阶数
	end
	-- local max_order = ItemData.Instance:GetItemMaxOrder(zhuan) - 1 								--丹青要求统一减1
	dec = string.format(dec, item_id, equip_order, "{face;" .. string.format("%03d", math.random(1, 40)) .. "}")
	if self.current_id == SPECIAL_CHAT_ID.GUILD then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
	elseif self.current_id == SPECIAL_CHAT_ID.TEAM then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, dec, CHAT_CONTENT_TYPE.TEXT)
	else
		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = dec
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框

		ChatData.Instance:AddPrivateMsg(self.current_id, msg_info)
		ChatCtrl.Instance.guild_chat_view:FlushChatList(false, self.current_id)

		ChatCtrl.SendSingleChat(self.current_id, dec, CHAT_CONTENT_TYPE.TEXT)
	end

	if self.other_data and (self.other_data.from_view == "orange_suit" or self.other_data.from_view == "red_suit") then
		TipsCtrl.Instance:ShowSystemMsg(Language.SuitCollect.WantEquipTip)
	end
	
	self:Close()
end

function WantEquipView:SetCurrentChannelType(current_id, other_data)
	self.current_id = current_id
	self.other_data = other_data
end

function WantEquipView:GetNumberOfCells()
	return 10
end

function WantEquipView:RefreshCell(index, cellObj)
	-- 构造Cell对象.

	local grid_index = math.floor(index / 5) * 5 + (5 - index % 5)
	local cell = self.equip_cell[grid_index]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		self.equip_cell[grid_index] = cell
		cell:SetToggleGroup(self.equip_list.toggle_group)
	end
	if self.other_data and (self.other_data.from_view == "orange_suit" or self.other_data.from_view == "red_suit") then
		self:SetCollectSuitData(cell, grid_index)
	else
		self:SetData(cell, grid_index)
	end
	cell:SetHighLight(true)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell))
end

function WantEquipView:HandleBagOnClick(cell)
	if cell and cell:GetData() then
		self.select_data = cell:GetData()
	end
end

function WantEquipView:SetData(cell, index)
	local sub_type = EquipData.GetFSEquipSubtype(index - 1) or 0
	local prof, zhuan = PlayerData.Instance:GetRoleBaseProf()
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo() and GameVoManager.Instance:GetMainRoleVo().level or 0
	local max_order = ItemData.Instance:GetItemMaxOrder(main_role_lv)
	local cfg = EquipData.Instance:GetOrderEquip(prof, max_order, sub_type, 5)

	if cfg then
		local data = {item_id = cfg.id, num = 1}
		cell:SetData(data)
		if self.select_data == nil then
			local equip = EquipData.Instance:GetGridData(index - 1) or {}
			local item_id = equip.item_id or 0
			local equip_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[item_id]
			if equip_cfg == nil or equip_cfg.order < max_order or equip_cfg.color < 5 then
				self.select_data = data
				cell:SetToggle(true)
			end
		end
	else
		cell:SetData({})
	end
end

-- 装备图录的SetData
function WantEquipView:SetCollectSuitData(cell, index)
	if not self.equip_id_data then
		if self.other_data.from_view == "orange_suit" then
			local suit_data = SuitCollectionData.Instance:GetOrangeCollectEquipCfg(self.other_data.select_seq)
			self.equip_id_data = Split(suit_data.equip_items, "|")
		else
			local suit_data = SuitCollectionData.Instance:GetRedCollectEquipCfg(self.other_data.select_seq)
			self.equip_id_data = Split(suit_data.equip_items, "|")
		end
	end

	if not self.equip_id_data then
		return
	end

	local equip_item_id = tonumber(self.equip_id_data[index])
	if equip_item_id then
		local data = {item_id = equip_item_id, num = 1}
		cell:SetData(data)
		if self.select_data == nil then
			self.select_data = data
			cell:SetToggle(true)
		end
	else
		cell:SetData({})
	end
end
-- 刷新
function WantEquipView:OnFlush()
	for k,v in pairs(self.equip_cell) do
		if self.other_data and (self.other_data.from_view == "orange_suit" or self.other_data.from_view == "red_suit") then
			self:SetCollectSuitData(v, k)
		else
			self:SetData(v, k)
		end
	end
end