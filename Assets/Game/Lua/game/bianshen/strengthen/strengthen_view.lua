-- 仙域-变身-强化
StrengthenView = StrengthenView or BaseClass(BaseRender)

local MATERIAL_BAG_COUNT = 400   -- 右边背包格子数量

function StrengthenView:__init()
	
end

function StrengthenView:ReleaseCallBack()

end

function StrengthenView:__delete()
	self.fight_text = nil
	self.left_contain_cell_list = {}
	self.packbag_item_list = {}
	self.equip_bag_grid_list = {}
	self.effect_cd = 0
	self.equip_list = {}

	for k, v in pairs(self.right_contain_cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.right_contain_cell_list = {}

	if self.select_item_cell then
		self.select_item_cell:DeleteMe()
		self.select_item_cell = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end


function StrengthenView:OpenCallBack()
	self.left_current_equip_index = 1
	self.packbag_item_list = {}
	self.select_item_cell_list = {}		-- 挑选的材料
	self.equip_list = BianShenData.Instance:GetStrengthenEquipList()

	if self.node_list["ListViewLeft"] then
		self.node_list["ListViewLeft"].scroller:ReloadData(0)
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	
	self.equip_bag_grid_list = BianShenData.Instance:GetEquipBagInfoList()
	if self.node_list["ListViewRight"] then
		self.node_list["ListViewRight"].scroller:ReloadData(0)
	end
end

function StrengthenView:ItemDataChangeCallback()
	self.equip_bag_grid_list = BianShenData.Instance:GetEquipBagInfoList()
	self.node_list["ListViewRight"].scroller:ReloadData(0)
end

function StrengthenView:UITween()
	UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(295, -20, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-142, -27.7, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["MiddleDown"], Vector3(0, -442, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["MiddleUp"] , true , 0.7 , DG.Tweening.Ease.Linear )
end

function StrengthenView:LoadCallBack()
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnUgrade"].button:AddClickListener(BindTool.Bind(self.OnClickStrengthen, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	self.fight_text.text.text = 0
	self.equip_list = {}	-- 可以强化的装备列表数据
	self.left_contain_cell_list = {} -- 左边的装备列表
	self.left_current_equip_index = 1
	self.right_contain_cell_list = {} -- 右边的列表
	self.packbag_item_list = {}
	self.equip_bag_grid_list = {}
	self.select_item_cell_list = {}		-- 挑选的材料
	self.select_type_index = -1
	self.equip_level = 0				-- 记录等级
	self.effect_cd = 0

	local list_delegate_left = self.node_list["ListViewLeft"].list_simple_delegate
	list_delegate_left.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsLeft, self)
	list_delegate_left.CellRefreshDel = BindTool.Bind(self.RefreshCellLeft, self)

	local list_delegate_right = self.node_list["ListViewRight"].list_simple_delegate
	list_delegate_right.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsRight, self)
	list_delegate_right.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)

	self.select_item_cell = ItemCell.New()
	self.select_item_cell:SetInstanceParent(self.node_list["SelectItem"])

	self.is_click_select = false
	self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
	self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)

	self.node_list["ImgLine"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))
	self.node_list["BtnUpArrows"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))
	self.node_list["BtnBelowArrows"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))

end

function StrengthenView:OnFlush(param_t)
	self.equip_list = BianShenData.Instance:GetStrengthenEquipList()
	self.node_list["ListViewLeft"].scroller:RefreshActiveCellViews()
	if next(self.equip_list) then
		local select_equip_info = self.equip_list[self.left_current_equip_index]
		if not select_equip_info then return end
		self.select_item_cell:SetData(select_equip_info)
		self.select_item_cell:ShowStrengthLable(true)
		self.select_item_cell:SetStrength(select_equip_info.strength_level)
		self.node_list["TxtNowLv"].text.text = "+" .. select_equip_info.strength_level

		local max_lv = BianShenData.Instance:GetEquipMaxLv()
		local is_max_lv = select_equip_info.strength_level >= max_lv
		self.node_list["ImgRightArrows"]:SetActive(not is_max_lv)

		-- 当前选中装备的熟练度
		local cur_equip_shuliandu = select_equip_info.shuliandu
		-- 选中装备强化总的熟练度
		local total_shuliandu = 0
		for k, v in pairs(self.select_item_cell_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			local equip_cfg_info = BianShenData.Instance:GetEquipCfg(item_cfg.sub_type - 1500, item_cfg.quality, v.param.strengthen_level)
			if equip_cfg_info and equip_cfg_info.contain_shulian then
				total_shuliandu = total_shuliandu + equip_cfg_info.contain_shulian
			end
		end

		local cur_item_cfg = ItemData.Instance:GetItemConfig(select_equip_info.item_id)
		local cur_equip_cfg_info = BianShenData.Instance:GetEquipCfg(cur_item_cfg.sub_type - 1500, cur_item_cfg.quality, select_equip_info.strength_level)
		if not cur_equip_cfg_info then return end
		local shu_lian_du_text = "%s +<color=#89f201FF>%s</color>/%s"
		self.node_list["TextShuLianValue"].text.text = string.format(shu_lian_du_text, cur_equip_shuliandu, total_shuliandu, cur_equip_cfg_info.upgrade_need_shulian)

		UI:SetButtonEnabled(self.node_list["BtnUgrade"], not is_max_lv)
		
		if is_max_lv then
			self.node_list["ImgProgressBg"].slider.value = 1
			for i = 1, 3 do
				self.node_list["TextNext" .. i]:SetActive(false)
			end
			self.node_list["TextShuLianValue"].text.text = Language.MultiMount.MaxGradeDesc
			self.node_list["UgradeText"].text.text = Language.MultiMount.MaxLv
		else
			self.node_list["ImgProgressBg"].slider.value = cur_equip_shuliandu / cur_equip_cfg_info.upgrade_need_shulian
			for i = 1, 3 do
				self.node_list["TextNext" .. i]:SetActive(true)
			end
			self.node_list["UgradeText"].text.text = Language.Common.Strengthen
		end

		local can_lv = select_equip_info.strength_level		-- 选中强化材料可以升级到的等级
		local total_shuliandu_two = total_shuliandu + cur_equip_shuliandu		-- 这个熟练度是参与计算的熟练度
		for i = select_equip_info.strength_level, max_lv do
			local equip_cfg_info = BianShenData.Instance:GetEquipCfg(cur_item_cfg.sub_type - 1500, cur_item_cfg.quality, i)
			if not equip_cfg_info then return end
			total_shuliandu_two = total_shuliandu_two - equip_cfg_info.upgrade_need_shulian
			if total_shuliandu_two >= 0 then
				can_lv = can_lv + 1
			else
				break
			end
		end
		can_lv = can_lv >= max_lv and max_lv or can_lv
		self.node_list["TxtNextLv"].text.text = "+" .. can_lv
		local can_lv_equip_cfg_info= BianShenData.Instance:GetEquipCfg(cur_item_cfg.sub_type - 1500, cur_item_cfg.quality, can_lv)
		if not can_lv_equip_cfg_info then return end
		self.node_list["TextNext1"].text.text = can_lv_equip_cfg_info.maxhp
		self.node_list["TextNext2"].text.text = can_lv_equip_cfg_info.gongji
		self.node_list["TextNext3"].text.text = can_lv_equip_cfg_info.fangyu

		local attr_text = "<color=#a8b4d2>%s：</color>%s"
		self.node_list["TextCur1"].text.text = string.format(attr_text, Language.Common.AttrNameUnderline["maxhp"],cur_equip_cfg_info.maxhp)
		self.node_list["TextCur2"].text.text = string.format(attr_text, Language.Common.AttrNameUnderline["gongji"],cur_equip_cfg_info.gongji)
		self.node_list["TextCur3"].text.text = string.format(attr_text, Language.Common.AttrNameUnderline["fangyu"],cur_equip_cfg_info.fangyu)
		self.node_list["AttrPanle1"]:SetActive(cur_equip_cfg_info.maxhp > 0 or can_lv_equip_cfg_info.maxhp > 0)
		self.node_list["AttrPanle2"]:SetActive(cur_equip_cfg_info.gongji > 0 or can_lv_equip_cfg_info.gongji > 0)
		self.node_list["AttrPanle3"]:SetActive(cur_equip_cfg_info.fangyu > 0 or can_lv_equip_cfg_info.fangyu > 0)
		
		self.fight_text.text.text = cur_item_cfg.mp + CommonDataManager.GetCapabilityCalculation(cur_equip_cfg_info)
	else
		for i = 1, 3 do
			self.node_list["AttrPanle" .. i]:SetActive(false)
		end
		self.node_list["ImgProgressBg"].slider.value = 0
		self.node_list["TxtNowLv"].text.text = "+0"
		self.node_list["ImgRightArrows"]:SetActive(false)
		self.node_list["TextShuLianValue"].text.text = string.format("%s +<color=#89f201FF>%s</color>/%s", 0, 0, 0)
		self.fight_text.text.text = 0
		UI:SetButtonEnabled(self.node_list["BtnUgrade"], false)
		self.select_item_cell:SetData({})
		self.select_item_cell:ShowStrengthLable(false)
	end
end

function StrengthenView:GetNumberOfCellsLeft()
	return #self.equip_list or 0
end

function StrengthenView:RefreshCellLeft(cell, cell_index)
	local contain_cell = self.left_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = StrengthenEquipItem.New(cell.gameObject)
		self.left_contain_cell_list[cell] = contain_cell
		contain_cell:SetClickCallBack(BindTool.Bind(self.OnClickEquip, self))
		contain_cell:SetToggleGroup(self.node_list["ListViewLeft"].toggle_group)
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.equip_list[cell_index])
	if cell_index ~= self.left_current_equip_index then
		contain_cell.bg_toggle.toggle.isOn = false
	else
		contain_cell.bg_toggle.toggle.isOn = true
	end
end

--右边列表
function StrengthenView:GetNumberOfCellsRight()
	return  MATERIAL_BAG_COUNT / 4
end

function StrengthenView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.right_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = EquipItemGroup.New(cell.gameObject)
		self.right_contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)

	local data = {}
	for i = 4 * cell_index - 3, cell_index * 4 do
		if nil ~= self.equip_bag_grid_list[i] then
			table.insert(data, self.equip_bag_grid_list[i])
		else
			table.insert(data, {})
		end
	end

	contain_cell:SetSelectType(self.select_type_index)
	contain_cell:SetData(data)

	for i = 1, 4 do
		local index = 4 * cell_index - 3 + i
		self.packbag_item_list[index] = contain_cell.item_cell_list[i]
		self.packbag_item_list[index].item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, self.packbag_item_list[index], self.packbag_item_list[index].item_cell, index))
	end	

	for i = 1, 4 do
		local index = 4 * cell_index - 4 + i
		self.packbag_item_list[index] = contain_cell.item_cell_list[i]
		local cell = contain_cell.item_cell_list[i].item_cell
		if next(contain_cell.item_cell_list[i]:GetData()) and contain_cell.item_cell_list[i]:GetIsSelect() then
			cell:SetToggle(true)
			cell:ShowHighLight(true)
			cell:SetIconGrayVisible(true)
			cell:ShowHasGet(true)
		else
			cell:SetToggle(false)
			cell:ShowHighLight(false)
			cell:SetIconGrayVisible(false)
			cell:ShowHasGet(false)
		end
	end
end

function StrengthenView:OnClickItemCell(parent_cell, item_cell, index)
	if next(item_cell:GetData()) then 
		local is_show = item_cell:IsHighLight()
		item_cell:SetToggle(true)
		item_cell:ShowHighLight(not is_show)
		item_cell:SetIconGrayVisible(not is_show)
		item_cell:ShowHasGet(not is_show)
		parent_cell:SetIsSelect(not is_show)
		local data = self.equip_bag_grid_list[index - 1]
		if not is_show then		-- 选中状态
			table.insert(self.select_item_cell_list, data)
		else					-- 取消选中状态
			for k,v in pairs(self.select_item_cell_list) do
				if v.index == data.index then
					table.remove(self.select_item_cell_list, k)
				end
			end
		end
		self:Flush()
	end
end

function StrengthenView:OnClickEquip(equip_cell)
	self.left_current_equip_index = equip_cell:GetIndex()
	self:Flush()
end

function StrengthenView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(312)
end

function StrengthenView:OnClickStrengthen()
	if not next(self.select_item_cell_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.BianShen.TipEquip)
		return
	end
	local destroy_num = #self.select_item_cell_list
	local destroy_backpack_index_list = {}
	for i = 0, destroy_num - 1 do
		destroy_backpack_index_list[i] = self.select_item_cell_list[i + 1].index
	end
	local select_equip_info = self.equip_list[self.left_current_equip_index]
	BianShenCtrl.Instance:SendStrengthReq(select_equip_info.seq, select_equip_info.slot, destroy_num, destroy_backpack_index_list)
	self.select_item_cell_list = {}
	self:PlayUpLVEffect()
end

function StrengthenView:ClickSelectMaterialQuality()
	self.is_click_select = not self.is_click_select
	self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
	self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)

	local function func(index)
		self.select_type_index = index
		self:SetSelectItemMaterial()
		self:FlushHightLight()
	end

	local function close_call_back()
		self.is_click_select = not self.is_click_select
		self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
		self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)
	end
	BianShenCtrl.Instance:SetStrengthenSelectMaterialViewCloseCallBack(close_call_back)

	BianShenCtrl.Instance:SetStrengthenSelectMaterialViewCallBack(func)
	BianShenCtrl.Instance:SetStrengthenCancelViewCallBack(BindTool.Bind(self.ClickCancleSelect, self ))
	ViewManager.Instance:Open(ViewName.BianShenStrengthenSelectView)
end

function StrengthenView:ClickCancleSelect()
	self.select_item_cell_list = {}
	self.select_type_index = -1
	self:FlushHightLight()
end

function StrengthenView:FlushHightLight()
	for k,v in pairs(self.equip_bag_grid_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			if item_cfg.quality <= self.select_type_index then
				v.is_select = true
			else
				if self.select_type_index > 0 and 0 == item_cfg.is_equip then
					v.is_select = true
				else
					v.is_select = false
				end
			end
		end

	end
	self.node_list["ListViewRight"].scroller:ReloadData(0)

	for k,v in pairs(self.packbag_item_list) do
		if next(v:GetData()) and true == v:GetIsSelect() then
			v.item_cell:SetToggle(true)
			v.item_cell:ShowHighLight(true)
			v.item_cell:SetIconGrayVisible(true)
			v.item_cell:ShowHasGet(true)
		else
			v.item_cell:SetToggle(false)
			v.item_cell:ShowHighLight(false)
			v.item_cell:SetIconGrayVisible(false)
			v.item_cell:ShowHasGet(false)
		end
	end
	self:Flush()
end

function StrengthenView:SetSelectItemMaterial()
	self.select_item_cell_list = {}
	for k, v in pairs(self.equip_bag_grid_list) do
		if v.sort_quality < (self.select_type_index + 1) then
			table.insert(self.select_item_cell_list, v)
		end
	end
end

function StrengthenView:PlayUpLVEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["effect_root"].transform,
			2.0)
		self.effect_cd = Status.NowTime + 1
	end
end


------------------------------------------------------------------------------------------------------
-- 名将身上的装备-StrengthenEquipItem

StrengthenEquipItem = StrengthenEquipItem or BaseClass(BaseCell)

function StrengthenEquipItem:__init()
	self.bg_toggle = self.node_list["bg_toggle"]
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.node_list["bg_toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.item_cell:ListenClick(function()
		self.node_list["bg_toggle"].toggle.isOn = true
		self.item_cell:ShowHighLight(false)
		self:OnClick()
	end)
end

function StrengthenEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function StrengthenEquipItem:OnFlush()
	self.item_cell:SetData(self.data)
	self.item_cell:ShowStrengthLable(true)
	self.item_cell:SetStrength(self.data.strength_level)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local name_str =  ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.quality])
	self.node_list["TxtName"].text.text = name_str
	self.node_list["TxtName2"].text.text = name_str
end

function StrengthenEquipItem:SetToggleGroup(toggle_group)
	if self.node_list["bg_toggle"].toggle then
		self.node_list["bg_toggle"].toggle.group = toggle_group
	end
end

--------------------------------------右边背包-EquipItemGroup--------------------------------------
EquipItemGroup = EquipItemGroup or BaseClass(BaseCell)
function EquipItemGroup:__init()
	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell_obj = self.node_list["item_"..i]
		self.item_cell_list[i] = EquipMaterialItem.New(item_cell_obj.gameObject)
	end	
	self.type = 0
end

function EquipItemGroup:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
		v:SetIsSelect(false)
	end
	self.item_cell_list = {}
end

function EquipItemGroup:SetIndex(index)
	self.index = index
	for k,v in pairs(self.item_cell_list) do
		v:SetIndex(4 * (index - 1) + k)
	end
end

function EquipItemGroup:SetSelectType(type)
	self.type = type
end

function EquipItemGroup:OnFlush()
	self.data = self:GetData()
	for k,v in pairs(self.item_cell_list) do
		v:SetSelectType(self.type)
		v:SetData(self.data[k])
	end
end

--------------------------------------装备材料-EquipMaterialItem--------------------------------------
EquipMaterialItem = EquipMaterialItem or BaseClass(BaseCell)
function EquipMaterialItem:__init()
	self.item_cell = BianShenEquip.New()
	self.item_cell:SetInstanceParent(self.root_node)
	self.type = 0
end

function EquipMaterialItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function EquipMaterialItem:SetIndex(index)
	self.index = index
end

function EquipMaterialItem:GetIndex()
	return self.index or 0
end

function EquipMaterialItem:SetSelectType(type)
	self.type = type
end

function EquipMaterialItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data)
		if self.data.item_id == 0 then
			self.data.is_select = false
			self.item_cell:SetData({})
		end
	else
		self.item_cell:SetData({})

	end
end

function EquipMaterialItem:GetIsSelect()
	return self.data.is_select or false
end

function EquipMaterialItem:SetIsSelect(enable)
	if next(self.data) then
		self.data.is_select = enable
	end
end

------------------------------------------------------------------------------------------------------------

BianShenEquip = BianShenEquip or BaseClass(ItemCell)
function BianShenEquip:__init()
	local toggle = self.root_node.toggle
	self.image = self.root_node.image
	toggle.interactable = true
end

function BianShenEquip:SetRootInteractable(value)
	self:ShowHighLight(value)
end

function BianShenEquip:SetData(data, is_from_bag)
	ItemCell.SetData(self, data, is_from_bag)
	
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end

	--设置图标
	local bundle, asset = ResPath.GetItemIcon(shenshou_equip_cfg.icon_id)
	self:SetAsset(bundle, asset)

	self:ShowQuality(true)
	local quality = shenshou_equip_cfg.quality
	if shenshou_equip_cfg.is_equip == 1 then
		quality = quality + 1
	else
		quality = quality + 2
	end
	self:SetQualityByColor(quality)

	local star_count = 0
	if self.data.attr_list then
		for k,v in pairs(self.data.attr_list) do
			if v.attr_type > 0 then
				local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(shenshou_equip_cfg.quality, v.attr_type) or {}
				if random_cfg.is_star_attr ==1 then
					star_count = star_count + 1
				end
			end
		end
	else
		star_count = self.data.param and self.data.param.star_level or 0
	end
	self:SetShowStar(star_count)
	local flag = self.name == "shenshou_bag" and ShenShouData.Instance:GetIsBetterBianShenEquip(self.data, self.select_shou_id or 0)
	self:SetShowUpArrow(flag)
	if self.data.strength_level and self.data.strength_level > 0 then
		self:ShowStrengthLable(true)
		self:SetStrength(self.data.strength_level)
	else
		self:ShowStrengthLable(false)
	end
end

function BianShenEquip:Reset(...)
	ItemCell.Reset(self, ...)
	local toggle = self.root_node.toggle
	toggle.interactable = true
end