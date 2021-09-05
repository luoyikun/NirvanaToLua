ForgeSuitView = ForgeSuitView or BaseClass(BaseRender)

function ForgeSuitView:__init()

	self.is_load_effect = false
	self.effect_obj = nil
	self.suit_att_content_list = {}
	for i = 1, 3 do
		self.suit_att_content_list[i] = SuitAttContent.New(self.node_list["suit"..i])
	end
	self.item_cell_list = {}
	for i = 1, 2 do
		local item_cell = self.node_list["item_"..i]
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item_"..i])
	end

	self.equip_cell_item = ItemCell.New()
	self.equip_cell_item:SetInstanceParent(self.node_list["item_3"])

	self.node_list["StrengthBtn"].button:AddClickListener(BindTool.Bind(self.StrengthClick, self))
	self.node_list["SSBtn"].toggle:AddClickListener(BindTool.Bind(self.ChangeClickSS, self))
	self.node_list["CSBtn"].toggle:AddClickListener(BindTool.Bind(self.ChangeClickCS, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))

	self:InitScroller()
	self.suit_type = 1  --1:史诗套装，-1:传说套装
	self.select_equip_data = {}
	self.first_open = true

	self.timer_quest = nil
	self.btn_red_point_status = false

	self.hujia_suit = {2,4,6}
	self.shiping_suit = {1,2,4}
	self:FristFlushView()
end

function ForgeSuitView:__delete()
	if self.EquipModel then
		self.EquipModel:DeleteMe()
		self.EquipModel = nil
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_load_effect = nil
	if self.effect_obj then
		ResMgr:Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k, v in pairs(self.suit_att_content_list) do
		v:DeleteMe()
	end
	self.suit_att_content_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.equip_cell_item then
		self.equip_cell_item:DeleteMe()
		self.equip_cell_item = nil
	end
end

function ForgeSuitView:FristFlushView()
	local temp_equip_list_data = ForgeData.Instance:ReorderEquipList()
	self:SetScrollerData(temp_equip_list_data)
	self:InitEquipModel()
	if next(self.select_equip_data) then
		self:FlushModel()
	end

	if #self.scroller_data == 0 then
		self.node_list["ShiTouBgContent"]:SetActive(false)
		self.node_list["CSBtn"]:SetActive(false)
		self.node_list["SSBtn"]:SetActive(false)
		self.node_list["SuitAttContentContent"]:SetActive(false)

	else
		self.node_list["ShiTouBgContent"]:SetActive(true)
		self.node_list["CSBtn"]:SetActive(true)
		self.node_list["SSBtn"]:SetActive(true)
		self.node_list["SuitAttContentContent"]:SetActive(true)
	end

	self.first_open = true

	self:SetChangeSuitBtnRedPoint()

	if self.suit_type == 1 then
		self.node_list["ChangeSSRedPoint"]:SetActive(false)
	else
		self.node_list["ChangeCSRedPoint"]:SetActive(false)
	end

end

function ForgeSuitView:Flush()

end

function ForgeSuitView:SetChangeSuitBtnRedPoint()
	local ss_btn_red_point_status = ForgeData.Instance:GetChangeSuitBtnRedPointStatus(self.scroller_data, 1)
	local cs_btn_red_point_status = ForgeData.Instance:GetChangeSuitBtnRedPointStatus(self.scroller_data, -1)
	self.node_list["ChangeSSRedPoint"]:SetActive(ss_btn_red_point_status)
	self.node_list["ChangeCSRedPoint"]:SetActive(cs_btn_red_point_status)
end

function ForgeSuitView:InitScroller()
	self.cell_list = {}
	self.equip_scroller_select_index = 1

	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "cell_res_async_loader")
	res_async_loader:Load("uis/views/forgeview_prefab", "SuitEquipCell", nil, function (obj)
		if nil == obj then
			print(ToColorStr("prefab为空", TEXT_COLOR.RED))
			return
		end
		self.enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end


function ForgeSuitView:GetNumberOfCells()
	if self.scroller_data then
		return #self.scroller_data
	else
		return 0
	end
end


function ForgeSuitView:GetCellSize()
	return 110
end

function ForgeSuitView:GetCellView(scroller, data_index, cell_index)

	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local scroller_cell = self.cell_list[cell]
	if nil == scroller_cell then
		self.cell_list[cell] = EquiCell.New(cell.gameObject)
		scroller_cell = self.cell_list[cell]
		scroller_cell.mother_view = self
		scroller_cell.root_node.toggle.group = self.node_list["Scroller"].toggle_group
	end
	self.scroller_data[data_index].cell_index = data_index

	scroller_cell:SetData(self.scroller_data[data_index])
	return cell
end

--刷新所有装备格子信息
function ForgeSuitView:FlushEquiCell()
	for k,v in pairs(self.cell_list) do
		v:OnFlush()
	end
end

--设置装备列表的数据
function ForgeSuitView:SetScrollerData(data)
	self.scroller_data = data
end

--点击装备栏cell
function ForgeSuitView:SetSelectEquipData(data)
	local equip_list_data = EquipData.Instance:GetDataList()
	self.select_equip_data = data
	self.select_equip_item_id = data.item_id
	self:FlushAllAttContent()
	self:FlushModel()
	self:FlushEffect()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()

	self.equip_cell_item:SetData(data)
	local itemcell_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.node_list["NameText"].text.text = itemcell_cfg.name
end

function ForgeSuitView:StrengthEndCallBack()
	self:FlushAllAttContent()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()
	self:FlushEquiCell()
	self:OnAfterForgeEffect()
	self:SetChangeSuitBtnRedPoint()
end


function ForgeSuitView:SuitCellItem()

end

function ForgeSuitView:OnAfterForgeEffect()
	local bundle_name, asset_name = ResPath.GetMiscEffect("UI_ChengGongTongYong")
	TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, 1.5)
end

--设置锻造按钮的显示隐藏 ,can_strength:能否锻造，status:锻造是否完成
function ForgeSuitView:SetStrengthStatus()
	local can_strength = true
	local status = false
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(self.select_equip_data.data_index)
	local suit_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	if nil ~= suit_data_cfg then
		can_strength = true
		self.node_list["PowerNode"]:SetActive(true)
		local  power_suit = EquipData.Instance:GetEquipLegendFightPowerByData(self.select_equip_data, true, true)
		self.node_list["PowerTxt"].text.text = power_suit
	else
		self.node_list["PowerNode"]:SetActive(false)
		can_strength = false
		self.node_list["CantStrength"]:SetActive(true)
		self.node_list["ItemContent"]:SetActive(false)
		self.node_list["StrengthBtn"]:SetActive(false)
		if self.suit_type == 1 then
			self.node_list["CantStrength"].text.text = Language.Forge.CanNotForgeSS
		else
			self.node_list["CantStrength"].text.text = Language.Forge.CanNotForgeCS
		end
		return
	end

	if self.suit_type == 1 then
		if cur_suit_type == 0 then
			status = false
		elseif cur_suit_type == 1 then
			status = true
			self.node_list["CantStrength"].text.text = Language.Forge.CanForgeCS
			self.node_list["PowerNode"]:SetActive(false)
		elseif cur_suit_type == 2 then
			status = true
			self.node_list["CantStrength"].text.text = Language.Forge.ForgeEnd
			self.node_list["PowerNode"]:SetActive(false)
		end
	else 
		if cur_suit_type == 0 then
			status = true
			self.node_list["PowerNode"]:SetActive(false)
			self.node_list["CantStrength"].text.text = Language.Forge.CanNotForgeCS
		elseif cur_suit_type == 1 then
			status = false
			self.node_list["CantStrength"].text.text = Language.Forge.CanNotForgeCS
			self.node_list["PowerNode"]:SetActive(true)
		elseif cur_suit_type == 2 then
			status = true
			self.node_list["CantStrength"].text.text = Language.Forge.ForgeEnd
			self.node_list["PowerNode"]:SetActive(false)
		end
	end

	self.node_list["CantStrength"]:SetActive(status)
	self.node_list["ItemContent"]:SetActive(not status)
	self.node_list["StrengthBtn"]:SetActive(not status)
end

function ForgeSuitView:SetRedPointStatus(rock1_is_enough, rock2_is_enough)
	self.btn_red_point_status = false
	if self.suit_type == 1 then
		if rock1_is_enough then
			self.btn_red_point_status = true
		end
	else
		if rock1_is_enough and rock2_is_enough then
			self.btn_red_point_status = true
		end
	end
	return self.btn_red_point_status
end


function ForgeSuitView:FlushSuitRockItem()
	local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	local cur_num_1 = 0 --当前拥有的套装石数量
	local cur_num_2 = 0 --当前拥有的套装石数量
	local item_num_value_1 = ""
	local item_num_value_2 = ""
	local data_1 = {}
	local data_2 = {}

	if nil == strength_data_cfg then
		return
	end

	if self.suit_type == 1 then
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_ss)
		data_1.item_id = strength_data_cfg.need_stuff_id_ss
	else
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq1)
		data_1.item_id = strength_data_cfg.need_stuff_id_cq1
	end

	local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
	local rock2_is_enough = nil
	--设置当前套装石数量颜色
	cur_num_1 = self:SetTextNumColor(cur_num_1, strength_data_cfg.need_stuff_count_ss)
	item_num_value_1 = cur_num_1.."/"..strength_data_cfg.need_stuff_count_ss
	self.item_cell_list[1]:SetData(data_1)
	self.node_list["ItemNumTxt1"].text.text = item_num_value_1


	--史诗套装只需一种套装石，所以隐藏第二个套装石item
	self.node_list["suit_rock_item2"]:SetActive(self.suit_type == -1)
	if self.suit_type == -1 then
		cur_num_2 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq2)
		rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		data_2.item_id = strength_data_cfg.need_stuff_id_cq2
		cur_num_2 = self:SetTextNumColor(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		item_num_value_2 = cur_num_2.."/"..strength_data_cfg.need_stuff_count_cq2
		self.item_cell_list[2]:SetData(data_2)
		self.node_list["ItemNumTxt2"].text.text = item_num_2
	end
	self:SetRedPointStatus(rock1_is_enough, rock2_is_enough)

end

function ForgeSuitView:SetTextNumColor(cur_num, need_num)
	if cur_num < need_num then
		cur_num = ToColorStr(cur_num, TEXT_COLOR.RED_4)
	else
		cur_num = ToColorStr(cur_num, TEXT_COLOR.BLUE_4)
	end
	return cur_num
end

--刷新所有套装属性显示
function ForgeSuitView:FlushAllAttContent()
	--获取套装cfg
	local suit_uplevel_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	--无法锻造的装备隐藏属性
	if nil == suit_uplevel_cfg then
		self.node_list["SuitTitle"]:SetActive(false)
		self.node_list["AttContent"]:SetActive(false)
		return
	end
		local  power_suit = CommonDataManager.GetCapability(suit_uplevel_cfg)
	self.node_list["PowerTxt"].text.text = power_suit

	self.node_list["SuitTitle"]:SetActive(true)
	self.node_list["AttContent"]:SetActive(true)

	local suit_name = ForgeData.Instance:GetSuitName(suit_uplevel_cfg.suit_id,self.suit_type)
	self.node_list["SuitNameTxt"].text.text = suit_name
	local temp_suittype = 1
	if self.suit_type == -1 then
		temp_suittype = 2
	end
	local cur_suit_num = ForgeData.Instance:GetSuitNumByItemId(self.select_equip_item_id, temp_suittype)
	for i = 1, 3 do
		local suit_num = 1
		if suit_uplevel_cfg.suit_id >= 5134 then
			suit_num = self.shiping_suit[i]
		else
			suit_num = self.hujia_suit[i]
		end
		local suit_data_cfg = ForgeData.Instance:GetSuitAttCfg(suit_uplevel_cfg.suit_id, suit_num, self.suit_type)
		self.suit_att_content_list[i]:SetData(suit_data_cfg, cur_suit_num)
	end
end

function ForgeSuitView:InitEquipModel()
	if not self.EquipModel then
		self.EquipModel = RoleModel.New()
		self.EquipModel:SetDisplay(self.node_list["display"].ui3d_display)
	end
	self.EquipModel:SetVisible(false)
end

function ForgeSuitView:FlushModel()
	if next(self.select_equip_data) then
		if nil == self.select_equip_data.data_index then
			self.select_equip_data.data_index = 0
		end

		local res_id = "000" .. self.select_equip_data.data_index + 1
		local bubble, asset = ResPath.GetForgeEquipModel(res_id)
		self.EquipModel:SetVisible(true)
		self.EquipModel:SetMainAsset(bubble, asset)
		self:FlushFlyAniModel()
	end
end

function ForgeSuitView:FlushFlyAniModel()
	if self.tweener then
		self.tweener:Pause()
	end
	self.node_list["display"].rect:SetLocalScale(0, 0, 0)
	local target_scale = Vector3(1, 1, 1)
	self.tweener = self.node_list["display"].rect:DOScale(target_scale, 0.5)
end

function ForgeSuitView:FlushEffect()
	local item_cfg = ItemData.Instance:GetItemConfig(self.select_equip_item_id)
	local glow_bundle, glow_asset = ResPath.GetForgeEquipGlowEffect(item_cfg.color)
	local bg_bundle, bg_asset = ResPath.GetForgeEquipBgEffect(item_cfg.color)
	self.node_list["EquipGlowEffect"]:ChangeAsset(glow_bundle, glow_asset)

	self.node_list["EquipBgEffect"]:ChangeAsset(bg_bundle, bg_asset)

end

--锻造
function ForgeSuitView:StrengthClick()
	ForgeCtrl.Instance:SendSuitStrengthReq(
		FORGE.EQUIPMENT_SUIT_OPERATE_TYPE.EQUIPMENT_SUIT_OPERATE_TYPE_EQUIP_UP,
		self.select_equip_data.data_index)
end

--切换史诗套装
function ForgeSuitView:ChangeClickSS()

	self.node_list["SuitTitle"]:SetActive(true)
	self.node_list["AttContent"]:SetActive(true)
	self.suit_type = 1
	self:FlushAllAttContent()
	self:FlushEquiCell()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()
	self:SetChangeSuitBtnRedPoint()
	self.node_list["ChangeSSRedPoint"]:SetActive(false)

end
--切换传说套装
function ForgeSuitView:ChangeClickCS()

	self.suit_type = -1
	self:FlushAllAttContent()
	self:FlushEquiCell()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()
	self:SetChangeSuitBtnRedPoint()
	self.node_list["ChangeCSRedPoint"]:SetActive(false)
end

function ForgeSuitView:HelpClick()
	local tips_id = 148
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


----------装备列表cell--------
EquiCell = EquiCell or BaseClass(BaseCell)

function EquiCell:__init()
	self.data = {}
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.red_point_status = false

	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function EquiCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function EquiCell:SetData(data)
	if not next(data) or nil == data.item_id then
		return
	end
	self.data = data
	self:OnFlush()
end

function EquiCell:OnFlush()
	local suit_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(self.data.data_index)
	self.item_cell:SetData(self.data)
	self.item_cell:SetShowUpArrow(false)
	if nil == suit_data_cfg then --装备是否属于套装
		self.node_list["NameTxt"].text.text = item_cfg.name
		if item_cfg.order < 5 then
			self.node_list["IsStrengthTxt"].text.text = ToColorStr(Language.Forge.LevelLimit, TEXT_COLOR.RED_4)
		elseif item_cfg.color < 4 then
			self.node_list["IsStrengthTxt"].text.text = ToColorStr(Language.Forge.ColorLimit, TEXT_COLOR.RED_4)
		else
			self.node_list["IsStrengthTxt"].text.text = ToColorStr(Language.Forge.CanNotFogrge, TEXT_COLOR.RED_4)
		end
		self.node_list["SuitNumTxt"]:SetActive(false)
	else
		local temp_suittype = 1 --服务端的标记(0普通,1史诗,2传说)
		if self.mother_view.suit_type == 1 then --史诗
			temp_suittype = 1
		elseif self.mother_view.suit_type == -1 then --传说
			temp_suittype = 2
		end

		local suit_num = ForgeData.Instance:GetSuitNumByItemId(self.data.item_id, temp_suittype)

		self.node_list["SuitNumTxt"]:SetActive(true)
		if cur_suit_type == 0 then
			self.node_list["NameTxt"].text.text = item_cfg.name
			if self.mother_view.suit_type == 1 then
				self.node_list["IsStrengthTxt"].text.text = ToColorStr(Language.Forge.CanForgeSS, TEXT_COLOR.RED_4)
			else
				self.node_list["IsStrengthTxt"].text.text = ToColorStr(Language.Forge.CanNotFogrge, TEXT_COLOR.RED_4)
				self.node_list["SuitNumTxt"]:SetActive(false)
			end
		elseif cur_suit_type == 1 then
			local suit_name = ForgeData.Instance:GetSuitName(suit_data_cfg.suit_id,1)
			self.node_list["IsStrengthTxt"].text.text =ToColorStr(Language.Forge.CanForgeCS, TEXT_COLOR.BLUE_4)
		else
			local suit_name = ForgeData.Instance:GetSuitName(suit_data_cfg.suit_id,-1)
			self.node_list["NameTxt"].text.text = suit_name
			self.node_list["IsStrengthTxt"].text.text =Language.Forge.ForgeEnd
		end

		local suit_text = suit_num.."/"..suit_data_cfg.total_equip_count
		self.node_list["SuitNumTxt"].text.text = string.format(Language.Forge.SuitNumTxt, suit_text)
	end

	if self.mother_view.equip_scroller_select_index == self.data.cell_index then
		self.root_node.toggle.isOn = false
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end

	local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
	if nil ~= strength_data_cfg then
		local cur_num_1, cur_num_2 = ForgeData.Instance:GetCurSuitRockNum(self.data.item_id, self.mother_view.suit_type)
		local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
		local rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		self.red_point_status = ForgeData.Instance:SetRedPointStatus(rock1_is_enough, rock2_is_enough,self.data.data_index, self.mother_view.suit_type)
		self.node_list["RedPoint"]:SetActive(self.red_point_status)
	else
		self.red_point_status = false
		self.node_list["RedPoint"]:SetActive(false)
	end
end

function EquiCell:OnToggleValueChange(is_on)
	if is_on then
		if self.mother_view.equip_scroller_select_index == self.data.cell_index and not self.mother_view.first_open then
			return
		end
		self.mother_view.first_open = false
		self.mother_view.equip_scroller_select_index = self.data.cell_index
		self.mother_view:SetSelectEquipData(self.data)
		self.node_list["RedPoint"]:SetActive(self.red_point_status)
	end
end

function EquiCell:SetToggleValue(is_on)
	self.root_node.toggle.isOn = is_on
end

----------属性content---------
SuitAttContent = SuitAttContent or BaseClass(BaseCell)

function SuitAttContent:__init()

end

function SuitAttContent:SetData(data, cur_suit_num)
	self:SetActive(false)
	if nil == data then
		return
	end
	self.cur_suit_num = cur_suit_num
	self.data = data
	self:Flush()
end

function SuitAttContent:Flush()
	self:SetActive(true)
	--设置数据
	self.node_list["QiXueTxt"].text.text = string.format(Language.Forge.StrengLevelText, self.data.maxhp)
	self.node_list["GongJiTxt"].text.text = string.format(Language.Forge.StrengLevelText, self.data.gongji)
	self.node_list["FangYuTxt"].text.text = string.format(Language.Forge.StrengLevelText, self.data.fangyu)
	self.node_list["ShanBiTxt"].text.text = string.format(Language.Forge.StrengLevelText, self.data.shanbi)
	self.node_list["BaoJiTxt"].text.text = string.format(Language.Forge.StrengLevelText, self.data.jianren)
	self.node_list["QiXuePercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.maxhp_attr/100)
	self.node_list["GongJiPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.gongji_attr/100)
	self.node_list["FangYuPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.fangyu_attr/100)
	self.node_list["MingZhongPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.mingzhong_attr/100)
	self.node_list["ShanBiPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.shanbi_attr/100)
	self.node_list["BaoJiPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.baoji_attr/100)
	self.node_list["KangBaoPercentTxt"].text.text = string.format(Language.Forge.SuitPercentTxt, self.data.jianren_attr/100)

	local  power_suit = CommonDataManager.GetCapability(self.data)
	self.node_list["FightNumber"].text.text = power_suit

	local suit_type = Language.Forge.HuJia
	if self.data.suit_id >= 5134 then
		suit_type = Language.Forge.SHIPIN
	end

	local equip_count = string.format(Language.Forge.SuitNumCout,self.data.equip_count)
	local switch = false
	if self.cur_suit_num < self.data.equip_count then
		equip_count = equip_count
		switch = false
	else
		equip_count = "<color=".. TEXT_COLOR.BLUE_1 ..">"..equip_count.."</color>"
		switch = true
	end

	self.node_list["SuitNumTxt"].text.text = string.format("  %s", equip_count)
	UI:SetGraphicGrey(self.node_list["QiXue"], switch)
	UI:SetGraphicGrey(self.node_list["QiXueTxt"], switch)
	UI:SetGraphicGrey(self.node_list["GongJi"], switch)
	UI:SetGraphicGrey(self.node_list["GongJiTxt"], switch)
	UI:SetGraphicGrey(self.node_list["FangYuTxt"], switch)
	UI:SetGraphicGrey(self.node_list["FangYu"], switch)
	UI:SetGraphicGrey(self.node_list["ShanBi"], switch)
	UI:SetGraphicGrey(self.node_list["ShanBiTxt"], switch)
	UI:SetGraphicGrey(self.node_list["BaoJi"], switch)
	UI:SetGraphicGrey(self.node_list["BaoJiTxt"], switch)
	UI:SetGraphicGrey(self.node_list["QiXuePercent"], switch)
	UI:SetGraphicGrey(self.node_list["QiXuePercentTxt"], switch)
	UI:SetGraphicGrey(self.node_list["GongJiPercent"], switch)
	UI:SetGraphicGrey(self.node_list["GongJiPercentTxt"], switch)
	UI:SetGraphicGrey(self.node_list["FangYuPercent"], switch)
	UI:SetGraphicGrey(self.node_list["FangYuPercentTxt"], switch)
	--数值为0则隐藏
	self.node_list["qixue_obj"]:SetActive(self.data.maxhp ~= 0)
	self.node_list["gongji_obj"]:SetActive(self.data.gongji ~= 0)
	self.node_list["fangyu_obj"]:SetActive(self.data.fangyu ~= 0)
	self.node_list["shanbi_obj"]:SetActive(self.data.shanbi ~= 0)
	self.node_list["baoji_obj"]:SetActive(self.data.jianren ~= 0)

	self.node_list["qixue_pc_obj"]:SetActive(self.data.maxhp_attr ~= 0)
	self.node_list["gongji_pc_obj"]:SetActive(self.data.gongji_attr ~= 0)
	self.node_list["fangyu_pc_obj"]:SetActive(self.data.fangyu_attr ~= 0)
	self.node_list["mingzhong_pc_obj"]:SetActive(self.data.mingzhong_attr ~= 0)
	self.node_list["shanbi_pc_obj"]:SetActive(self.data.shanbi_attr ~= 0)
	self.node_list["baoji_pc_obj"]:SetActive(self.data.baoji_attr ~= 0)
	self.node_list["kangbao_pc_obj"]:SetActive(self.data.jianren_attr ~= 0)
end
