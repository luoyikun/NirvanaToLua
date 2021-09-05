RedSuitCollect = RedSuitCollect or BaseClass(BaseRender)

function RedSuitCollect:__init(instance)
	self.node_list["BtnGotoGet"].button:AddClickListener(BindTool.Bind(self.OnBtnGotoGet, self))
	self.node_list["BtnTotalAttr"].button:AddClickListener(BindTool.Bind(self.OnBtnTotalAttr, self))
	self.node_list["BtnGetTitle"].button:AddClickListener(BindTool.Bind(self.OnBtnGetTitle, self))
	self.node_list["TitleImg"].button:AddClickListener(BindTool.Bind(self.OnTitleImg, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnBtnHelp, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
	-- 装备
	self.equip_item_list = {}
	for i = 0, 9 do
		local item_cell = RedEquipItemCell.New(self.node_list["EquipItem" .. (i + 1)])
		item_cell:SetIndex(i)
		item_cell:SetToggleGroup(self.node_list["EquipItems"].toggle_group)
		self.equip_item_list[i] = item_cell
	end

	self.suit_type_data = {}
	self.suit_cell_list = {}
	local suit_list_delegate = self.node_list["SuitList"].list_simple_delegate
	suit_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSkillCellNumber, self)
	suit_list_delegate.CellRefreshDel = BindTool.Bind(self.SkillCellRefresh, self)

	self.suit_type_data = SuitCollectionData.Instance:GetRedItemNum()
	self.choose_type_data = self.suit_type_data[1]
	self.node_list["SuitList"].scroller:ReloadData(0)

	self.progress = ProgressBar.New(self.node_list["ProgressBG"])

	SuitCollectionData.Instance:SetRedRemindFlag()
	RemindManager.Instance:Fire(RemindName.RedSuitCollection)
	self:Flush()
end

function RedSuitCollect:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.suit_cell_list) do
		v:DeleteMe()
	end
	self.suit_cell_list = {}

	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImg"])
end

function RedSuitCollect:LoadCallBack()

end

-- 左边套装类型列表
function RedSuitCollect:GetSkillCellNumber(value)
	return #self.suit_type_data
end

function RedSuitCollect:SkillCellRefresh(cell, index)
	local suit_cell = self.suit_cell_list[cell]
	index = index + 1
	if nil == suit_cell then
		suit_cell = RedSuitTypeItemCell.New(cell.gameObject)
		suit_cell:SetClickCallBack(BindTool.Bind(self.ClickSuitTypeCallBack, self))
		self.suit_cell_list[cell] = suit_cell
	end

	local data = self.suit_type_data[index]
	suit_cell:SetIndex(data.seq)
	suit_cell:SetData(data)

	if self.choose_type_data and self.choose_type_data.seq == data.seq then
		suit_cell:FlushHL(true)
	else
		suit_cell:FlushHL(false)
	end

	-- local suit_type_cfg = SuitCollectionData.Instance:GetRedItemType(data.seq)
	-- local level = GameVoManager.Instance:GetMainRoleVo().level
	-- if suit_type_cfg and level < suit_type_cfg.level then
	-- 	suit_cell:SetActive(false)
	-- end
end
-----------------End-------------------

function RedSuitCollect:ClickSuitTypeCallBack(cell_data)
	self.choose_type_data = cell_data
	
	self:Flush()


	local level = GameVoManager.Instance:GetMainRoleVo().level
	if cell_data.level > level then
		-- local zhuan = math.floor(cell_data.level / 100) or 0
		-- local level = cell_data.level - (zhuan * 100) or 0
		local show_tip = string.format(Language.SuitCollect.SuitCollectTips4, cell_data.level, cell_data.order)
		TipsCtrl.Instance:ShowSystemMsg(show_tip)
	end

	for k, v in pairs(self.suit_cell_list) do
		if v:GetIndex() == cell_data.seq then
			v:FlushHL(true)
		else
			v:FlushHL(false)
		end
	end
end

function RedSuitCollect:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = SuitCollectionData.Instance:GetUITweenCfg(TabIndex.red_suit_collect)
			UITween.MoveShowPanel(self.node_list["ListPanel"] , ui_cfg["ListPanel"], ui_cfg["MOVE_TIME"])
			UITween.MoveShowPanel(self.node_list["RightPanel"] , ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"])
			-- UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	if not self.choose_type_data or not next(self.choose_type_data) then
		return
	end

	local data = self.choose_type_data

	for k, v in pairs(self.suit_cell_list) do
		v:FlushTypeRemind()
	end

	local star_info = SuitCollectionData.Instance:GetRedStarsInfo(data.seq)
	self.active_equip_num = star_info and star_info.item_count or 0

	local attr_list = SuitCollectionData.Instance:GetRedCollectAttr(data.seq) or {}
	if self.active_equip_num < 10 then
		local temp_attr = self:GetAttrTab(attr_list[self.active_equip_num + 1])
		local attr_text = ""
		for k, v in pairs(temp_attr) do
			attr_text = v.name .. ":" .. v.value .. " "
		end
		self.node_list["NextAttr"].text.text = attr_text
		self.node_list["NextCount"].text.text = string.format(Language.SuitCollect.SuitEquipJiqiText, next(attr_list) and attr_list[self.active_equip_num + 1].collect_count or 0)
		self.node_list["NextAttr"]:SetActive(true)
		self.node_list["NextCount"]:SetActive(true)
		-- self.node_list["MaxActiveDesc"]:SetActive(false)
	else
		self.node_list["NextAttr"]:SetActive(false)
		self.node_list["NextCount"]:SetActive(false)
		-- self.node_list["MaxActiveDesc"]:SetActive(true)
	end

	self.progress:SetValue(self.active_equip_num / 10)
	self.node_list["ProgressBGText"].text.text = self.active_equip_num .. "/10" 

	-- 称号
	local bundle, asset = ResPath.GetTitleIcon(data.reward_title_id)
	if bundle and asset then
		self.node_list["TitleImg"].image:LoadSprite(bundle, asset, function()
			TitleData.Instance:LoadTitleEff(self.node_list["TitleImg"], data.reward_title_id, true)
			self.node_list["TitleImg"].image:SetNativeSize()
		end)
	end

	local is_huanxing = SuitCollectionData.Instance:GetRedIsActive(data.seq)
	if is_huanxing then
		if is_huanxing == 1 then
			self.node_list["GetTitleBtnText"].text.text = Language.SuitCollect.YiHuanXing
		else
			self.node_list["GetTitleBtnText"].text.text = Language.SuitCollect.HuanXing
		end
	end

	local equip_list = SuitCollectionData.Instance:GetRedEquipCollect(data.seq)
	local equip_collect_cfg = SuitCollectionData.Instance:GetRedCollectEquipCfg(data.seq)
	if nil == equip_list or nil == equip_collect_cfg then 
		return
	end

	local star_count = 0
	local equip_id_tab = Split(equip_collect_cfg.equip_items, "|")
	local virtual_id_tab = Split(equip_collect_cfg.ts_virtual, "|")
	for k, v in pairs(self.equip_item_list) do
		if equip_id_tab[k + 1] and virtual_id_tab[k + 1] then
			v:SetEquipIdAndVirtualId(equip_id_tab[k + 1], virtual_id_tab[k + 1], data.seq)
		end

		if equip_list[k] then
			v:SetData(equip_list[k])

			if equip_list[k].param and equip_list[k].param.xianpin_type_list and next(equip_list[k].param.xianpin_type_list) then
				star_count = star_count + #equip_list[k].param.xianpin_type_list
			end
		end
	end

	local active_need_count = SuitCollectionData.Instance:GetRedActiveSuitCount()
	local percent = tonumber(data.star_add_attr_percent) * star_count
	self.node_list["CurrStar"].text.text = string.format(Language.SuitCollect.TotalStar, star_count)
	self.node_list["SuitAddition"].text.text = string.format(Language.SuitCollect.SuitAddPercent, percent)
	self.node_list["AdditionDesc"].text.text = string.format(Language.SuitCollect.PerSuitAddPercent, tonumber(data.star_add_attr_percent))
	self.node_list["ActiveCount"].text.text = string.format(Language.SuitCollect.ActiveTitleDesc, ToColorStr(active_need_count, TEXT_COLOR.GREEN))

	local attr_tab = self:GetTotalAttr(attr_list)
	local power = CommonDataManager.GetCapability(attr_tab)

	local title_power = 0
	if active_need_count <= self.active_equip_num and is_huanxing == 1 then
		local title_cfg = TitleData.Instance:GetTitleCfg(data.reward_title_id)
		local title_attr_list = CommonDataManager.GetAttributteNoUnderline(title_cfg)
		title_attr_list = CommonDataManager.MulAttributeNoUnderline(title_attr_list, 1 + (percent / 100))
		title_power = CommonDataManager.GetCapability(title_attr_list)
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power + title_power
	end

	if active_need_count <= self.active_equip_num and is_huanxing == 0 then
		self.node_list["Remind"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["BtnGetTitle"], true)
		UI:SetGraphicGrey(self.node_list["BtnGetTitle"], false)		
	else
		self.node_list["Remind"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnGetTitle"], false)
		UI:SetGraphicGrey(self.node_list["BtnGetTitle"], true)
	end
end

function RedSuitCollect:GetAttrTab(attr_tab)
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(attr_tab) do
		if v > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(k)
			total_attr[count].value = v
			count = count + 1
		end
	end
	return total_attr
end

function RedSuitCollect:OnBtnGotoGet()
	-- if not ViewManager.Instance:IsOpen(ViewName.Boss) and self.choose_type_data then
	-- 	ViewManager.Instance:OpenByCfg(self.choose_type_data.get_way)
	-- end
	local data = {
		from_view = "red_suit",
		select_seq = self.choose_type_data.seq
	}
	ChatCtrl.Instance:OpenWantEquipView(SPECIAL_CHAT_ID.GUILD, data)
end

-- 总属性
function RedSuitCollect:OnBtnTotalAttr()
	local order_suit_attr_cfg = SuitCollectionData.Instance:GetRedCollectAttr(self.choose_type_data.seq)
	local attr_tab = self:GetTotalAttr(order_suit_attr_cfg)
	attr_tab.seq = self.choose_type_data.seq
	attr_tab.reward_title_id = self.choose_type_data.reward_title_id
	TipsCtrl.Instance:OpenEquipAttrTipsView("red_suit_collect_attr", attr_tab)
end

function RedSuitCollect:GetTotalAttr(attr_data_list)
	local attr_tab = CommonStruct.AttributeNoUnderline()
	for k, v in pairs(attr_data_list) do
		if v.collect_count <= self.active_equip_num then
			local temp_attr = CommonDataManager.GetAttributteNoUnderline(v)
			attr_tab = CommonDataManager.AddAttributeAttrNoUnderLine(attr_tab, temp_attr)
		end
	end
	return attr_tab
end

-- 获得称号
function RedSuitCollect:OnBtnGetTitle()
	local active_need_count = SuitCollectionData.Instance:GetRedActiveSuitCount()
	if self.active_equip_num < active_need_count then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.SuitCollect.ActiveTitleDesc, active_need_count))
	else
		SuitCollectionCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_FETCH_TITEL_REWARD, self.choose_type_data.seq)
	end
end

function RedSuitCollect:OnTitleImg()
	if self.choose_type_data and next(self.choose_type_data) then
		local title_item = {item_id = self.choose_type_data.reward_title_item}
		-- local title_item = {item_id = 22237}
		TipsCtrl.Instance:OpenItem(title_item)
	end
end

function RedSuitCollect:OnBtnHelp()
	local tips_id = 299
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end




----------------------------------------
----套装类型 RedSuitTypeItemCell
RedSuitTypeItemCell = RedSuitTypeItemCell or BaseClass(BaseCell)
function RedSuitTypeItemCell:__init()
	self.root_node.button:AddClickListener(BindTool.Bind(self.ClickTypeItem, self))
end

function RedSuitTypeItemCell:__delete()
	TitleData.Instance:ReleaseTitleEff(self.node_list["TitleImg"])
end

function RedSuitTypeItemCell:ClickTypeItem()
	if self.click_callback then
		self.click_callback(self.data)
	end
end

-- function RedSuitTypeItemCell:SetActive(enable)
-- 	self.root_node:SetActive(enable)
-- end

function RedSuitTypeItemCell:OnFlush()
	if nil == self.data then return end

	self.node_list["SuitName"].text.text = self.data.name
	
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < self.data.level then
		self.node_list["Lock"]:SetActive(true)
	else
		self.node_list["Lock"]:SetActive(false)
	end

	local bundle, asset = ResPath.GetTitleIcon(self.data.reward_title_id)
	self.node_list["TitleImg"].image:LoadSprite(bundle, asset, function()
		TitleData.Instance:LoadTitleEff(self.node_list["TitleImg"], self.data.reward_title_id, true)
		self.node_list["TitleImg"].image:SetNativeSize()
	end)

	self:FlushTypeRemind()
end

function RedSuitTypeItemCell:FlushTypeRemind()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if SuitCollectionData.Instance:GetRedRemindBySeq(self.data.seq) and self.data.level <= level then
		self.node_list["Remind"]:SetActive(true)
	else
		self.node_list["Remind"]:SetActive(false)
	end
end

function RedSuitTypeItemCell:FlushHL(value)
	if self.node_list["HL"] then
		self.node_list["HL"]:SetActive(value)
	end
end


------------------------------------
------ 装备格子 RedEquipItemCell
RedEquipItemCell = RedEquipItemCell or BaseClass(BaseCell)
function RedEquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])

	self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.root_node.button:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function RedEquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.equip_id = nil
	self.virtual_id = nil
end

-- 设置可装备的装备ID和虚拟物品ID
function RedEquipItemCell:SetEquipIdAndVirtualId(equip_id, virtual_id, seq)
	self.equip_id = tonumber(equip_id)
	self.virtual_id = tonumber(virtual_id)
	self.curr_seq = tonumber(seq)
end

function RedEquipItemCell:ClickItem()
	local suit_type_cfg = SuitCollectionData.Instance:GetRedItemType(self.curr_seq)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if suit_type_cfg and level < suit_type_cfg.level then
		local show_tip = string.format(Language.SuitCollect.SuitCollectTips4, suit_type_cfg.level, suit_type_cfg.order)
		TipsCtrl.Instance:ShowSystemMsg(show_tip)
		return
	end

	local function open_equip_view(is_show_tip)
		local data = {}
		data.equip_id = self.equip_id
		data.seq = self.curr_seq
		data.index = self.index
		data.is_show_tip = is_show_tip
		SuitCollectionCtrl.Instance:OpenSuitEquipView(data)
	end

	if nil == self.data or nil == self.data.item_id or self.data.item_id <= 0 then
		local bag_item = SuitCollectionData.Instance:GetEquipByItemId(self.equip_id)
		if next(bag_item) and self.curr_seq then
			if #bag_item == 1 then
				local function ok_callback()
					SuitCollectionCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_TAKEON, 
						self.curr_seq, self.index, bag_item[1].index)
				end	
				if self.is_show_tip then
					-- local des = Language.SuitCollect.TipConfirmDesc
					-- TipsCtrl.Instance:ShowCommonAutoView("red_suitcollect", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
					open_equip_view(true)
				else
					ok_callback()
				end
			else
				open_equip_view(false)
			end
		else
			if self.virtual_id then
				local item_data = {item_id = self.virtual_id}
				TipsCtrl.Instance:OpenItem(item_data)	
			end
		end		
	else
		open_equip_view(false)
	end
end

function RedEquipItemCell:OnFlush()
	self.node_list["BtnImprove"]:SetActive(false)
	self.is_show_tip = false
	local suit_type_cfg = SuitCollectionData.Instance:GetRedItemType(self.curr_seq)
	if not suit_type_cfg then return end
	local level = GameVoManager.Instance:GetMainRoleVo().level

	local wear_equip
	local item_cfg
	if self.equip_id then
		item_cfg = ItemData.Instance:GetItemConfig(self.equip_id)
		if item_cfg then
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			wear_equip = ForgeData.Instance:GetZhuanzhiEquip(equip_index)
		end
	end
	local bag_item = SuitCollectionData.Instance:GetEquipByItemId(self.equip_id)
	if nil == self.data or nil == self.data.item_id or self.data.item_id <= 0 then
		self.equip_cell:SetItemActive(false)
		if self.equip_id then
			self.is_show_tip = true
			if next(bag_item) then
				if item_cfg and wear_equip and wear_equip.item_id > 0 then
					local wear_item_cfg = ItemData.Instance:GetItemConfig(wear_equip.item_id)
					-- if item_cfg.order <= wear_item_cfg.order and item_cfg.color <= wear_item_cfg.color then
					for k, v in pairs(bag_item) do
						if v.item_id == self.equip_id and
							suit_type_cfg.level <= level then

							local bag_equip_cap = EquipData.Instance:GetEquipCapacityPower(v)
							local wear_equip_cap = EquipData.Instance:GetEquipCapacityPower(wear_equip)	
							if bag_equip_cap <= wear_equip_cap then
								self.node_list["BtnImprove"]:SetActive(true)
								self.is_show_tip = false
							end
						end
					end
					-- end				
				end
			end
		end
		return
	else
		self.equip_cell:SetItemActive(true)
		if self.equip_id then
			if next(bag_item) then
				for k, v in pairs(bag_item) do
					if wear_equip and v.item_id == self.equip_id and 
						v.param and self.data.param and
						#self.data.param.xianpin_type_list < #v.param.xianpin_type_list and suit_type_cfg.level <= level then
						local bag_equip_cap = EquipData.Instance:GetEquipCapacityPower(v)
						local wear_equip_cap = EquipData.Instance:GetEquipCapacityPower(wear_equip)									
						if bag_equip_cap <= wear_equip_cap then
							self.node_list["BtnImprove"]:SetActive(true)
						end
					end
				end
			end
		end
	end

	self.equip_cell:SetData(self.data)
end

function RedEquipItemCell:SetToggleGroup(toggle_group)
	self.equip_cell:SetToggleGroup(toggle_group)
end