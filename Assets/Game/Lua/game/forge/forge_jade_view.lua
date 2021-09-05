-- 锻造 玉石
ForgeJade = ForgeJade or BaseClass(BaseRender)

function ForgeJade:__init(instance, parent_view)
	UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], true)
	UI:SetGraphicGrey(self.node_list["AutoText"], false)
	self.node_list["BtnStop"]:SetActive(false)

	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.ShowOrHideJadeList, self, false))
	self.node_list["ListBlackBG"].button:AddClickListener(BindTool.Bind(self.ShowOrHideJadeList, self, false))
	self.node_list["OptionBlackBG"].button:AddClickListener(BindTool.Bind(self.ShowOrHideJadeOption, self, false))
	self.node_list["BtnUnload"].button:AddClickListener(BindTool.Bind(self.UnloadClick, self))
	-- self.node_list["BtnLevelUp"].button:AddClickListener(BindTool.Bind(self.LevelUpClick, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnTotalJade"].button:AddClickListener(BindTool.Bind(self.ShowOrHideTotalJade, self, false))
	self.node_list["BtnAutoUpgrade"].button:AddClickListener(BindTool.Bind(self.AutoUpgradeClick, self))
	self.node_list["BtnStop"].button:AddClickListener(BindTool.Bind(self.CancelAutoUpgradeClick, self))
	self.node_list["BtnReplace"].button:AddClickListener(BindTool.Bind(self.ReplaceClick, self))
	self.node_list["BtnJadeBag"].button:AddClickListener(BindTool.Bind(self.OpenJadeBagFenJie, self))
	self.node_list["BtnJadeRecycle"].button:AddClickListener(BindTool.Bind(self.OpenJadeOptionView, self))
	self.node_list["JadeScoreItem"].button:AddClickListener(BindTool.Bind(self.OnClickJadeScoreItem, self))

	self.jade_list = {}
	local child_number = self.node_list["JadeGroup"].transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = self.node_list["JadeGroup"].transform:GetChild(i).gameObject
		obj = obj.transform:GetChild(0)
		if string.find(obj.name, "JadeCell") ~= nil then
			self.jade_list[count] = JadeSoltCell.New(obj)
			self.jade_list[count]:SetIndex(i)
			self.jade_list[count]:SetClickCallBack(BindTool.Bind(self.ClickJadeSlotCell, self))
			count = count + 1
		end
	end

	-- self.bag_jade_list = {}
	-- local list_view_delegate = self.node_list["BagJadeScroller"].list_simple_delegate
	-- list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItemCell"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerNum"])
end

function ForgeJade:__delete()
	for k, v in pairs(self.jade_list) do
		v:DeleteMe()
	end
	self.jade_list = {}

	-- for k, v in pairs(self.bag_jade_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.bag_jade_list = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.euqip_cell = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.fight_text = nil
end

-- function ForgeJade:GetNumberOfCells()
-- 	return #self.bag_jade_list_data or 0
-- end

-- -- 背包玉石列表 
-- function ForgeJade:RefreshListView(cell, cell_index)
-- 	cell_index = cell_index + 1
-- 	local item_cell = self.bag_jade_list[cell]
-- 	if nil == item_cell then
-- 		item_cell = JadeScrollerCell.New(cell.gameObject)
-- 		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickJadeListCell, self))
-- 		self.bag_jade_list[cell] = item_cell
-- 	end

-- 	local data = self.bag_jade_list_data[cell_index]
-- 	item_cell:SetIndex(cell_index)
-- 	item_cell:SetSelectHL(cell_index == self.select_jade_list_index)
-- 	item_cell:SetData(data)
-- end

-- function ForgeJade:OnClickJadeListCell(jade_cell)
-- 	local data = jade_cell:GetData()
-- 	if nil == data then return end

-- 	self.select_jade_bag_index = data.index
-- 	self.select_jade_list_index = jade_cell:GetIndex()
-- 	for k, v in pairs(self.bag_jade_list) do
-- 		v:SetSelectHL(self.select_jade_list_index == v:GetIndex())
-- 	end
-- 	self:InlayClick()
-- end

function ForgeJade:ClickEquipListCallBack(index)
	self:CancelAutoUpgradeClick()
	self.select_index = index
	self:Flush()
end

function ForgeJade:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_jade)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
		end
	end
	self.node_list["JadeScoreTxt"].text.text = ForgeData.Instance:GetJadeScore()
	
	if self.select_index == nil then
		for i = 1, 6 do
			self.jade_list[i]:SetOnEquipDataState()
		end
		return 
	end

	self.cell_data = ForgeData.Instance:GetZhuanzhiEquip(self.select_index)
	if nil == self.cell_data or self.cell_data.item_id <= 0 then 
		for i = 1, 6 do
			self.jade_list[i]:SetOnEquipDataState()
		end
		return 
	end

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowStrengthLable(false)
	self.jade_slot_data = ForgeData.Instance:GetEquipJadeSlotInfo(self.cell_data.index)
	self.bag_had_jade_data = ForgeData.Instance:GetHadJadesInBag(self.cell_data.index)
	self.bag_jade_list_data = self.bag_had_jade_data

	for i = 1, 6 do
		self.jade_list[i]:SetOtherData(self.cell_data, self.bag_had_jade_data)
		self.jade_list[i]:SetData(self.jade_slot_data[i])
	end

	local power_attr = ForgeData.Instance:GetJadePowerByIndex(self.cell_data.index)
	local fight_power = CommonDataManager.GetCapability(power_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
end

-- 1 玉石操作  2 打开背包玉石
function ForgeJade:ClickJadeSlotCell(click_type, slot_index, pos, is_up_power, is_can_replace)
	self.select_slot_index = slot_index
	if click_type == 1 then
		if is_can_replace then
			local item_id = self.jade_slot_data[self.select_slot_index + 1].jade_id
			local tab = {}
			for k,v in pairs(self.bag_had_jade_data) do
				if v.item_id > item_id then
					table.insert(tab, v)
				end
			end
			self.bag_jade_list_data = tab
			table.sort(self.bag_jade_list_data, SortTools.KeyUpperSorter("item_id"))
			self.node_list["BagJadeScroller"].scroller:ReloadData(0)
		end
		self.node_list["BtnReplace"]:SetActive(is_can_replace)
		-- self.node_list["BtnLevelUp"]:SetActive(is_up_power)
		self:ShowOrHideJadeOption(true, pos)
		self.is_can_replace = is_can_replace
		self.is_up_power = is_up_power
	elseif click_type == 2 then
		self.node_list["BagJadeScroller"].scroller:ReloadData(0)
		self:ShowOrHideJadeList(true)		
	end
	
end

-- 镶嵌按下后
function ForgeJade:InlayClick()
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_INLAY_STONE, self.select_index, self.select_slot_index, self.select_jade_bag_index)
	self:ShowOrHideJadeList(false)
end

-- --显示或隐藏可镶嵌列表
function ForgeJade:ShowOrHideJadeList(is_show)
	-- self.node_list["JadeList"]:SetActive(is_show)
	if not is_show then
		self.select_jade_bag_index = nil
		self.select_jade_list_index = 0
		self.bag_jade_list_data = self.bag_had_jade_data
	else
		local data = {
			jade_list = self.bag_jade_list_data,
			select_index = self.select_index,
			select_slot_index = self.select_slot_index,
		}
		ForgeCtrl.Instance:OpenJadeListView(data)
	end
end

-- 玉石槽操作显示
function ForgeJade:ShowOrHideJadeOption(is_show, pos)
	self.node_list["JadeOption"]:SetActive(is_show)
	if is_show then
		self.node_list["JadeOptionFrame"].transform.position = pos
	else
		self.is_can_replace = false
		self.is_up_power = false
	end
end

-- 摘下option
function ForgeJade:UnloadClick()
	ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_UNINLAY_STONE, self.select_index, self.select_slot_index)
	self:ShowOrHideJadeOption(false)
end

-- 升级option (功能屏蔽)
-- function ForgeJade:LevelUpClick()
-- 	self.jade_list[self.select_slot_index + 1]:ImproveClick()
-- 	self:ShowOrHideJadeOption(false)
-- end

-- 替换option
function ForgeJade:ReplaceClick()
	self:ShowOrHideJadeList(true)
	self:ShowOrHideJadeOption(false)
end

--按下了自动升级
function ForgeJade:AutoUpgradeClick()
	if self.cell_data == nil or self.cell_data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	self.node_list["BtnStop"]:SetActive(true)
	self.node_list["BtnAutoUpgrade"]:SetActive(false)
	self:AutoUpgrade()

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:AutoUpgrade()
	end, 0.5)
end

--自动升级
function ForgeJade:AutoUpgrade()
	local function get_best_jade()
		local max_id = 0
		local best_jade = nil
		for k,v in pairs(self.bag_had_jade_data) do
			if v.item_id > max_id then
				best_jade = v
				max_id = v.item_id
			end
		end
		return best_jade
	end

	if not self.bag_had_jade_data or not next(self.bag_had_jade_data) then
		self:CancelAutoUpgradeClick()
		return
	end

	-- 先镶嵌
	for k, v in pairs(self.jade_slot_data) do
		if v.jade_state == 1 then
			local best_jade = get_best_jade()
			if best_jade then
				ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_INLAY_STONE, self.cell_data.index, (k - 1), best_jade.index)
			end
			return
		end
	end
	-- 再升级
	local min_id = 0
	local up_jade_slot = nil
	for k, v in pairs(self.jade_slot_data) do
		if v.jade_state == 2 and (v.jade_id < min_id or min_id == 0) then
			up_jade_slot = k
			min_id = v.jade_id
		end
	end
	if up_jade_slot then
		-- ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_UP_LEVEL, self.cell_data.index, up_jade_slot, best_jade.index)
		local is_up = self.jade_list[up_jade_slot]:ImproveClick()
		if is_up then
			return
		end
	end
	self:CancelAutoUpgradeClick()
end

function ForgeJade:CancelAutoUpgradeClick()
	self.node_list["JadeOption"]:SetActive(false)
	self.node_list["JadeList"]:SetActive(false)
	
	self.node_list["BtnStop"]:SetActive(false)
	self.node_list["BtnAutoUpgrade"]:SetActive(true)
	UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], true)
	UI:SetGraphicGrey(self.node_list["AutoText"], false)

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

--打开或关闭全身玉石奖励
function ForgeJade:ShowOrHideTotalJade()
	local level, current_cfg, next_cfg = ForgeData.Instance:GetTotalJadeCfg()
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeJadeSuitAtt, level, current_cfg, next_cfg)
end

function ForgeJade:ClickHelp()
	local tips_id = 260
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeJade:OpenJadeBagFenJie()
	ViewManager.Instance:Open(ViewName.ForgeJadeBagFenJie)
end

function ForgeJade:OpenJadeOptionView()
	ViewManager.Instance:Open(ViewName.YuShiExchangeView)
end

function ForgeJade:OnClickJadeScoreItem()
	local item_data = {item_id = 90574}
	TipsCtrl.Instance:OpenItem(item_data)	
end

-- ---------------------------
-- ----------- 玉石槽 JadeSoltCell
JadeSoltCell = JadeSoltCell or BaseClass(BaseCell)

function JadeSoltCell:__init()
	self.node_list["ImproveButton"].button:AddClickListener(BindTool.Bind(self.ImproveClick, self))
	self.node_list["JadeIcon"].button:AddClickListener(BindTool.Bind(self.JadeIconClick, self))
	self.node_list["PlusButton"].button:AddClickListener(BindTool.Bind(self.PlusClick, self))
end

function JadeSoltCell:__delete()
	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function JadeSoltCell:SetOtherData(equip_data, bag_had_jade)
	self.equip_data = equip_data
	self.bag_had_jade = bag_had_jade
end

--玉石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function JadeSoltCell:OnFlush()
	self.is_can_inlay = false
	self.is_can_upgrade = false
	self.is_can_up_power = false
	self.is_can_replace = false
	self.best_jade = nil
	self.node_list["ImproveButton"]:SetActive(false)
	self.node_list["Attr1"]:SetActive(true)
	self.node_list["Attr2"]:SetActive(true)
	self.node_list["JadeName"].text.text = ""
	if nil == self.data or nil == self.equip_data then return end

	if self.data.jade_state == 0 then
		self:LockState()
	elseif self.data.jade_state == 1 then
		self:OpenState()
	elseif self.data.jade_state == 2 then
		self:InlayState()
	end
end

function JadeSoltCell:LockState()
	self.node_list["Icon_Lock"]:SetActive(true)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["ImproveButton"]:SetActive(false)
	self.node_list["JadeIcon"]:SetActive(false)
	self.node_list["JadeIconBg"]:SetActive(false)		
	self.node_list["Attr2"].text.text = ""

	self:SetCellEffect(false)

	local limit_cfg = ForgeData.Instance:GetJadeOpenLimitCfg(self.equip_data.index, self.index)
	local str = ""
	if limit_cfg then
		if limit_cfg.order_limit and limit_cfg.order_limit > 0 then
			str = string.format(Language.Forge.JadeOpenLimit[0], limit_cfg.order_limit - 1)
		else
			str = string.format(Language.Forge.JadeOpenLimit[1], limit_cfg.vip_level_limit)
		end 
	end
	self.node_list["Attr1"].text.text = str
end

function JadeSoltCell:OpenState()
	self.node_list["Icon_Lock"]:SetActive(false)
	self.node_list["PlusButton"]:SetActive(true)
	self.node_list["JadeIcon"]:SetActive(false)
	self.node_list["JadeIconBg"]:SetActive(false)
	self.node_list["Attr1"].text.text = ""
	self.node_list["Attr2"].text.text = ""

	self:SetCellEffect(false)
	if (self.bag_had_jade ~= nil) and (next(self.bag_had_jade) ~= nil) then
		self.is_can_inlay = true
	end
	self.node_list["ImproveButton"]:SetActive(self.is_can_inlay)
end

function JadeSoltCell:InlayState()
	self.node_list["Icon_Lock"]:SetActive(false)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["JadeIcon"]:SetActive(true)
	self.node_list["JadeIconBg"]:SetActive(true)

	local icon_cfg = ItemData.Instance:GetItemConfig(self.data.jade_id)
	local asset = QUALITY_ICON[icon_cfg.color]
	self.node_list["JadeIconBg"].image:LoadSprite(ResPath.GetImages(asset))
	self.node_list["JadeIcon"].image:LoadSprite(ResPath.GetItemIcon(self.data.jade_id))
	self.node_list["JadeName"].text.text = ToColorStr(icon_cfg.name, ORDER_COLOR[icon_cfg.color])

	-- self:SetCellEffect(true, icon_cfg.color)
	local attrs = ForgeData.Instance:GetJadeAttr(self.data.jade_id)
	for i = 1, 2 do
		if attrs[i] == nil or attrs[i] == 0 then
			self.node_list["Attr"..i].text.text = ""
		else
			self.node_list["Attr"..i].text.text = attrs[i].attr_name .. ':  ' .. attrs[i].attr_value
		end
	end

	if not self.bag_had_jade or not next(self.bag_had_jade) then return end

	-- 可替换玉石
	local max_id = self.data.jade_id
	for k,v in pairs(self.bag_had_jade) do
		if v.item_id > max_id then
			self.is_can_replace = true
			self.best_jade = v
			max_id = v.item_id
		end
	end

	-- 可升级玉石
	-- if self.best_jade == nil then
	-- 	local jade_cfg = ForgeData.Instance:GetJadeCfg(self.data.jade_id)
	-- 	if jade_cfg then
	-- 		local level = jade_cfg.level
	-- 		local next_cfg = ForgeData.Instance:GetJadeCfgByTypeAndLevel(jade_cfg.stone_type, level + 1)
	-- 		local up_jade_cfg = ForgeData.Instance:GetJadeUpLevelCfg(self.data.jade_id)
	-- 		if nil ~= next_cfg and nil ~= up_jade_cfg then
	-- 			local upgrade_need_energy = math.pow(up_jade_cfg.need_num, level) - math.pow(up_jade_cfg.need_num, level - 1)
	-- 			local had_energy = 0
	-- 			for k,v in pairs(self.bag_had_jade) do
	-- 				if v.item_id <= jade_cfg.item_id then
	-- 					local temp_up_jade_cfg = ForgeData.Instance:GetJadeUpLevelCfg(v.item_id)
	-- 					local temp_jade_cfg = ForgeData.Instance:GetJadeCfg(v.item_id)
	-- 					if temp_up_jade_cfg then
	-- 						had_energy = had_energy + (math.pow(temp_up_jade_cfg.need_num, temp_jade_cfg.level - 1) * v.num)
	-- 					end
	-- 				end
	-- 			end
	-- 			if had_energy >= upgrade_need_energy then
	-- 				self.is_can_upgrade = true
	-- 				self.is_can_up_power = true
	-- 				self.node_list["ImproveButton"]:SetActive(true)
	-- 			end
	-- 		else
	-- 			self.max_level = true
	-- 		end
	-- 	end
	-- else
	if self.best_jade then
		self.is_can_up_power = true
		self.node_list["ImproveButton"]:SetActive(true)
	end
end

function JadeSoltCell:SetCellEffect(is_show, color)
	if self.effect_obj then
		self.effect_obj:SetActive(is_show)
	else
		if is_show then
			local effect_bundle, effect_asset = ResPath.GetItemEffect(color)
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if nil == obj then
					return
				end
				obj.transform:SetParent(self.node_list["JadeIconBg"].transform)
				obj.name = "effect_obj"
				obj.gameObject.transform.localScale = Vector3(1, 1, 1)
				obj.gameObject.transform.localPosition = Vector3(0, 0, 0)
				self.effect_obj = obj
			end)
		end
	end
end

-- --按下了自动镶嵌/替换/升级
function JadeSoltCell:ImproveClick()
	if nil == self.equip_data then return end

	if self.is_can_inlay then
		self:PlusClick()
		return
	end

	if self.best_jade ~= nil then
		--可换更好的玉石
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_INLAY_STONE, self.equip_data.index, self.index, self.best_jade.index)
		return true
	-- elseif self.is_can_upgrade then
		--可升级
		-- ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_UP_LEVEL, self.equip_data.index, self.index)
		-- return true
	else
		if self.max_level then
			return false, 1
		else
			return false, 0
		end
	end
end

function JadeSoltCell:JadeIconClick()
	local dis = 10
	local pos = self.root_node.transform.position
	if self.index < 2 then
		pos.x = pos.x - dis
	else
		pos.x = pos.x + dis
	end
	self.click_callback(1, self.index, pos, self.is_can_up_power, self.is_can_replace)
end

function JadeSoltCell:PlusClick()
	if nil == self.equip_data then return end

	if self.is_can_inlay then
		self.click_callback(2, self.index)
	else
		local jade_type = ForgeData.Instance:GetJadeTypeByIndex(self.equip_data.index)
		local cfg = ForgeData.Instance:GetJadeCfgByTypeAndLevel(jade_type, 1)

		if cfg then
			local func = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, cfg.item_id, nil, 1)
		end
	end
end

-- 没有数据时的格子状态
function JadeSoltCell:SetOnEquipDataState()
	self.node_list["Icon_Lock"]:SetActive(true)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["JadeIcon"]:SetActive(false)
	self.node_list["JadeIconBg"]:SetActive(false)
	self.node_list["ImproveButton"]:SetActive(false)
end

-- -----------------------------------------
-- -- 背包玉石 JadeScrollerCell  obj_name:JadeItem
-- JadeScrollerCell = JadeScrollerCell or BaseClass(BaseCell)
-- function JadeScrollerCell:__init()
-- 	self.item_cell = ItemCell.New()
-- 	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
-- 	self.item_cell:ListenClick(function()end)

-- 	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
-- end

-- function JadeScrollerCell:__delete()
-- 	if self.item_cell then
-- 		self.item_cell:DeleteMe()
-- 	end
-- end

-- function JadeScrollerCell:OnFlush()
-- 	self.item_cell:SetData(self.data)
-- 	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
-- 	self.node_list["NameTxt"].text.text = item_cfg.name
-- end

-- function JadeScrollerCell:OnClickCell()
-- 	BaseCell.OnClick(self)
-- end

-- function JadeScrollerCell:SetSelectHL(is_hl)
-- 	self.node_list["HLBg"]:SetActive(is_hl)
-- end
