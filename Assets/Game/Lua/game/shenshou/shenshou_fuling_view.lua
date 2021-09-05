ShenShouFulingView = ShenShouFulingView or BaseClass(BaseRender)

ShenShouFulingView.CACHE_SHOW_ID = -1
ShenShouFulingView.CACHE_SOLT_INDEX = -1
MaterialBagCount = 300
MaxType = 10
--ShenShouEquipCount = 5
local MOVE_TIME = 0.5
function ShenShouFulingView:__init(instance, mother_view)
	self.eqlist_data = {}
	self.shenshow_grid_list = {}
	self.select_type_index = 0
	self.effect_cd = 0
	self.packbag_item_list = {}
	
	local list_delegate_left = self.node_list["ListViewLeft"].list_simple_delegate
	list_delegate_left.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsLeft, self)
	list_delegate_left.CellRefreshDel = BindTool.Bind(self.RefreshCellLeft, self)
	self.left_current_equip_index = -1
	self.left_contain_cell_list = {}
	self.node_list["ListViewLeft"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
	local list_delegate_right = self.node_list["ListViewRight"].list_simple_delegate
	list_delegate_right.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsRight, self)
	list_delegate_right.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)
	self.right_current_suit_index = -1
	self.right_contain_cell_list = {}
	self.count = 0
	self.select_equip_item = ShenShouEquip.New()
	self.select_equip_item:SetInstanceParent(self.node_list["select_equip"])
	self.select_equip_item:SetInteractable(false)
	self.select_equip_item:ListenClick(function()
		ShenShouCtrl.Instance:SetDataAndOepnEquipTip(self.current_equip_data, ShenShouEquipTip.FromView.ShenShouComposeView, ShenShouFulingView.CACHE_SHOW_ID)
		end)

	self.is_click_select = false
	self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
	self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnUgrade"].button:AddClickListener(BindTool.Bind(self.ClickUpGrade, self))
	self.node_list["double_toggle"].toggle:AddClickListener(BindTool.Bind(self.ClickDouble, self))
	self.node_list["ImgLine"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))
	self.node_list["BtnUpArrows"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))
	self.node_list["BtnBelowArrows"].button:AddClickListener(BindTool.Bind(self.ClickSelectMaterialQuality, self))

	self.node_list["TxtList"].text.text = Language.ShenShou.SelectType[self.select_type_index + 1]

	self.attr_name_list = {}
	self.attr_add_list = {}
	for i = 1, 3 do
		self.attr_name_list[i] = self.node_list["TxtPanel" .. i]
		self.attr_add_list[i] = self.node_list["TxtPanelTxt" .. i]
		self.attr_add_list[i]:SetActive(false)
	end
	
	self.node_list["double_toggle"].toggle.isOn = false

	self.is_double = false
	self.is_select_all = false
	self.is_jum_flag = false
end
function ShenShouFulingView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"] , Vector3(-140 , -20 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(520 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , 100 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -450 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , -100 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["MiddleUp"] ,true , MOVE_TIME ,DG.Tweening.Ease.InExpo)
end

function ShenShouFulingView:__delete()
	self.fight_text = nil
	self.select_equip_item:DeleteMe()

	for k,v in pairs(self.left_contain_cell_list) do
		v:DeleteMe()
	end
	self.left_contain_cell_list = {}

	for k,v in pairs(self.right_contain_cell_list) do
		v:DeleteMe()
	end
	self.right_contain_cell_list = {}

	self.is_double = false
	self.is_select_all = false
	self.node_list["double_toggle"].toggle.isOn = false
	self.select_type_index = 0
	self.effect_cd = 0

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShenShouFulingView:OpenCallBack()
	self.is_double = false
	self.is_select_all = false
	self.node_list["double_toggle"].toggle.isOn = false

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.select_type_index = 0
	self:FlushHightLight()

	self:FlushView()
end

function ShenShouFulingView:FlushView()
	--拿到强化装备列表
	self.eqlist_data = ShenShouData.Instance:GetShenShouEqListData()
	if next(self.eqlist_data) then
		self.left_current_equip_index = 1
		for k,v in pairs(self.eqlist_data) do
			if ShenShouFulingView.CACHE_SHOW_ID == v.shou_id and ShenShouFulingView.CACHE_SOLT_INDEX == v.slot_index then
				self.left_current_equip_index = k
				self.is_jum_flag = true
				ShenShouFulingView.CACHE_SHOW_ID = -1
				ShenShouFulingView.CACHE_SOLT_INDEX = -1
			end
		end
	else
		self.left_current_equip_index = 0
	end
	if self.node_list["ListViewLeft"] and self.node_list["ListViewLeft"].gameObject.activeInHierarchy then
		if self.is_jum_flag then
			self.node_list["ListViewLeft"].scroller:ReloadData(1)
		else
			self.node_list["ListViewLeft"].scroller:ReloadData(0)
		end
	end
	self:FlushMiddleContent()
	--拿到背包信息
	self.shenshow_grid_list = ShenShouData.Instance:GetShenshouGridList()
	if self.node_list["ListViewRight"] and self.node_list["ListViewRight"].gameObject.activeInHierarchy then
		self.node_list["ListViewRight"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function ShenShouFulingView:ItemDataChangeCallback()
	if self:IsOpen() then
		self:Flush()
	end
end

function ShenShouFulingView:CheckToJump(index)
	if index - 1 >= 0 then 
		if self.node_list["ListViewLeft"] and self.node_list["ListViewLeft"].gameObject.activeInHierarchy then
			self.node_list["ListViewLeft"].scroller:JumpToDataIndex(index - 1)
		end
	end
	self.is_jum_flag = false
end

function ShenShouFulingView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_jum_flag then
		self:CheckToJump(self.left_current_equip_index)
	end
end

--左边列表
function ShenShouFulingView:GetNumberOfCellsLeft()
	return #self.eqlist_data or 0
end

function ShenShouFulingView:RefreshCellLeft(cell, cell_index)
	local contain_cell = self.left_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = FulingEquipItem.New(cell.gameObject)
		self.left_contain_cell_list[cell] = contain_cell
		contain_cell:SetClickCallBack(BindTool.Bind(self.OnClickEquip, self))
		contain_cell:SetToggleGroup(self.node_list["ListViewLeft"].toggle_group)
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.eqlist_data[cell_index])
	if cell_index ~= self.left_current_equip_index then
		contain_cell.bg_toggle.toggle.isOn = false
	else
		contain_cell.bg_toggle.toggle.isOn = true
	end
end

function ShenShouFulingView:OnClickEquip(equip_cell)
	self.left_current_equip_index = equip_cell:GetIndex()
	self:FlushMiddleContent()
end

--右边列表
function ShenShouFulingView:GetNumberOfCellsRight()
	return  MaterialBagCount / 4
end

function ShenShouFulingView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.right_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = FulingItemGroup.New(cell.gameObject)
		self.right_contain_cell_list[cell] = contain_cell
	end

	for i = 1, 4 do
		local index = 4 * cell_index - 4 + i
		self.packbag_item_list[index] = contain_cell.item_cell_list[i]
		self.packbag_item_list[index].item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, self.packbag_item_list[index], self.packbag_item_list[index].item_cell, index))
	end	
		
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)

	local data = {}
	for i = 4 * cell_index - 3, cell_index * 4 do
		if nil ~= self.shenshow_grid_list[i] then
			table.insert(data, self.shenshow_grid_list[i])
		else
			table.insert(data, {})
		end
	end
	contain_cell:SetSelectType(self.select_type_index)
	contain_cell:SetData(data)

	for i = 1, 4 do
		local index = 4 * cell_index - 4 + i
		self.packbag_item_list[index] = contain_cell.item_cell_list[i]
		local cell = contain_cell.item_cell_list[i].item_cell
		if next(contain_cell.item_cell_list[i]:GetData()) and true == contain_cell.item_cell_list[i]:GetIsSelect() then
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

function ShenShouFulingView:OnClickItemCell(parent_cell, item_cell, index)
	if next(item_cell:GetData()) then 
		local is_show = item_cell:IsHighLight()
		item_cell:SetToggle(true)
		item_cell:ShowHighLight(not is_show)
		item_cell:SetIconGrayVisible(not is_show)
		item_cell:ShowHasGet(not is_show)
		parent_cell:SetIsSelect(not is_show)
		self:FlushAddShuliandu()
	end
end
function ShenShouFulingView:GetEquipPower(equip_data)
	local item_cfg = ShenShouData.Instance:GetShenShouEqCfg(equip_data.item_id)
	if item_cfg == nil then
		return
	end
	local attr_list = ShenShouData.Instance:GetShenshouBaseList(item_cfg.slot_index, item_cfg.quality)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(attr_list)
	local base_capability = CommonDataManager.GetCapability(attr_list)      							-- 装备基础评分
	local qh_shenshou_cfg = ShenShouData.Instance:GetShenshouLevelList(item_cfg.slot_index, equip_data.strength_level)
	local qh_attr_struct = CommonDataManager.GetAttributteByClass(qh_shenshou_cfg)
	local strengthen_capability = CommonDataManager.GetCapability(qh_attr_struct)   	-- 锻造总评分
	local cur_shou_id = equip_data.shou_id
	local bestattr_capability = 0
	if equip_data.attr_list then
		-- bestattr_capability = ShenShouData.Instance:GetShenShouEqCapability(equip_data.attr_list, cur_shou_id, equip_data)   -- 极品属性追加总评分
	end
	local zhuangbei_pingfen = base_capability + strengthen_capability  					-- 装备评分
	local zonghe_pingfen = zhuangbei_pingfen + bestattr_capability 						-- 装备综合评分
	return zonghe_pingfen
end
function ShenShouFulingView:FlushMiddleContent()
	local one_data = ShenShouData.Instance:GetCurEqData(1)
	self.current_equip_data = ShenShouData.Instance:GetCurEqData(self.left_current_equip_index)

	if nil ~= self.current_equip_data then
		local FightPower = self:GetEquipPower(self.current_equip_data)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = FightPower
		end
		local attr_list = self.current_equip_data.attr_list
		self.select_equip_item:SetData(self.current_equip_data)
		self.select_equip_item:SetInteractable(false)
		local strength_level = self.current_equip_data.strength_level
		local current_info = ShenShouData.Instance:GetShenshouLevelList(self.current_equip_data.slot_index, strength_level)
		local max_level = ShenShouData.Instance:GetEquipMaxLevel(self.current_equip_data.slot_index)
		if max_level <= strength_level then
			self.node_list["TxtNow"].text.text = string.format("%s", strength_level)
			self.node_list["TxtNext"].text.text = ""
			self.node_list["ImgRightArrows"]:SetActive(false)
			self.node_list["UgradeText"].text.text = Language.Common.YiManJi

			self.node_list["ImgProgressBg"].slider.value = 1
			self.node_list["TxtNum"].text.text = Language.ShenShou.MaxGradeDesc
			local value_list = ShenShouData.Instance:GetSlotIndexAttrByLevel(self.current_equip_data.slot_index, strength_level)
			for i = 1, 3 do
				if value_list[i] then 
					self.attr_name_list[i]:SetActive(true)
					self.attr_name_list[i].text.text = string.format("<color=#d0d8ff>%s：</color>%s", value_list[i].name, value_list[i].cur_attr)
					self.node_list["ThreePanle"]:SetActive(true)
				else
					if i == 3 then
						self.node_list["ThreePanle"]:SetActive(false)
					end
					self.attr_name_list[i]:SetActive(false)
				end
			end

			for k, v in pairs(self.attr_add_list) do
				v:SetActive(false)
			end
			UI:SetButtonEnabled(self.node_list["BtnUgrade"], false)
			return
		end

		UI:SetButtonEnabled(self.node_list["BtnUgrade"], true)
		self.node_list["UgradeText"].text.text = Language.ShenShou.UgradeName
		self.node_list["TxtNow"].text.text = string.format("+%s", strength_level)
		local shuliandu = self.current_equip_data.shuliandu
		self.current_shuliandu = shuliandu

		self.need_shuliandu = current_info.upgrade_need_shulian
		if 0 == shuliandu or 0 == current_info.upgrade_need_shulian then
			self.node_list["ImgProgressBg"].slider.value = 0
		else
			self.node_list["ImgProgressBg"].slider.value = shuliandu / current_info.upgrade_need_shulian
		end
		self.node_list["ImgRightArrows"]:SetActive(true)
		self.node_list["TxtNum"]:SetActive(true)
		self:FlushAddShuliandu()
		self.node_list["TxtNum"].text.text = string.format("%s <color=#00ff00>+%s</color> / %s", self.current_shuliandu, self.add_shuliandu, self.need_shuliandu)
	elseif nil ~= one_data then 
		self.left_current_equip_index = 1
		if self.node_list["ListViewRight"] and self.node_list["ListViewRight"].gameObject.activeInHierarchy then
			self.node_list["ListViewRight"].scroller:RefreshAndReloadActiveCellViews(true)
		end
		self:FlushMiddleContent()
	else
		self:ClearContent()
	end
end

function ShenShouFulingView:ClearContent()
	self.node_list["ImgProgressBg"].slider.value = 0

	self.current_shuliandu = 0
	self.add_shuliandu = 0
	self.need_shuliandu = 0
	self.node_list["TxtNum"].text.text = string.format("%s <color=#00ff00>+%s</color> / %s", self.current_shuliandu, self.add_shuliandu, self.need_shuliandu)

	self.node_list["ImgRightArrows"]:SetActive(false)
	self.node_list["TxtNum"]:SetActive(false)
	for i = 1, 3 do
		self.attr_name_list[i]:SetActive(false)
	end

	self.is_double = false
	self.is_select_all = false
	self.node_list["double_toggle"].toggle.isOn = false
	self.select_equip_item:SetData({})
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = 0
	end
end

function ShenShouFulingView:ClickDouble()
	self.is_double = not self.is_double
	self.node_list["double_toggle"].toggle.isOn = self.is_double
	self:FlushAddShuliandu()
end

function ShenShouFulingView:ClickAllSelect()
	self.is_select_all = false
	self.select_type_index = self.is_select_all and MaxType or 0 

	self:FlushHightLight()
end

function ShenShouFulingView:FlushHightLight()
	for k,v in pairs(self.shenshow_grid_list) do
		local item_cfg = ShenShouData.Instance:GetShenShouEqCfg(v.item_id)
		if item_cfg then
			if item_cfg.quality < self.select_type_index then
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
	if self.node_list["ListViewRight"] and self.node_list["ListViewRight"].gameObject.activeInHierarchy then
		self.node_list["ListViewRight"].scroller:RefreshAndReloadActiveCellViews(true)
	end

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
	self:FlushAddShuliandu()
end

function ShenShouFulingView:ClickSelectMaterialQuality()
	self.is_click_select = not self.is_click_select
	self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
	self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)

	local function func(index)
		self.select_type_index = index
		self:FlushHightLight()
		self.node_list["TxtList"].text.text = Language.ShenShou.SelectType[self.select_type_index + 1]
	end

	local function close_call_back()
		self.is_click_select = not self.is_click_select
		self.node_list["BtnUpArrows"]:SetActive(not self.is_click_select)
		self.node_list["BtnBelowArrows"]:SetActive(self.is_click_select)
	end
	ShenShouCtrl.Instance:SetFulingSelectMaterialViewCloseCallBack(close_call_back)
	ShenShouCtrl.Instance:SetFulingSelectMaterialViewCallBack(func)
	ShenShouCtrl.Instance:SetFulingCancelViewCallBack(BindTool.Bind(self.ClickAllSelect, self ))
	ViewManager.Instance:Open(ViewName.FulingSelectMaterialView)
end

function ShenShouFulingView:FlushAddShuliandu()
	local total_shulian = 0
	self.count = 0
	if nil == self.current_equip_data or self.current_equip_data.strength_level == ShenShouData.Instance:GetEquipMaxLevel(self.current_equip_data.slot_index) or not next(self.current_equip_data) then
		self.add_shuliandu = 0
		return
	end
	
	for k,v in pairs(self.shenshow_grid_list) do
		if v.is_select == true and v.item_id ~= 0 then
			local current_material_info = ShenShouData.Instance:GetShenShouEqCfg(v.item_id)
			if current_material_info == nil then
				return
			end
			local current_info = {}
			if current_material_info.is_equip == 1 then
				current_info = ShenShouData.Instance:GetShenshouLevelList(current_material_info.slot_index, v.param.strengthen_level)
				total_shulian = total_shulian + current_info.contain_shulian + v.param.param1 + current_material_info.contain_shulian
			else
				total_shulian = total_shulian + current_material_info.contain_shulian * v.num
			end
				
			--如果是双倍 --剔除已经进阶的
			if self.is_double then
				if v.param and v.param.strengthen_level > 0 then
				else
					self.count = self.count + current_material_info.contain_shulian * 2
					total_shulian = total_shulian + current_material_info.contain_shulian * v.num
				end
			end
		end
	end

	self.add_shuliandu = total_shulian
	self.node_list["TxtNum"].text.text = string.format("%s <color=#00ff00>+%s</color> / %s", self.current_shuliandu, self.add_shuliandu, self.need_shuliandu)
	local all_info = ShenShouData.Instance:GetLevelInfoByIndex(self.current_equip_data.slot_index)

	local current_level_info = ShenShouData.Instance:GetShenshouLevelList(self.current_equip_data.slot_index, self.current_equip_data.strength_level)

	total_shulian = current_level_info.contain_shulian + total_shulian + self.current_equip_data.shuliandu

	for k,v in pairs(all_info) do
		if total_shulian < v.contain_shulian then
			self.node_list["TxtNext"].text.text = string.format("+%s", v.strength_level - 1)
			local value_list = ShenShouData.Instance:CheckAddAttr(self.current_equip_data.slot_index, self.current_equip_data.strength_level, v.strength_level - 1)
			for i = 1, 3 do
				if value_list[i] then 
					self.attr_add_list[i]:SetActive(true)
					self.attr_name_list[i]:SetActive(true)
					self.attr_name_list[i].text.text = string.format("<color=#d0d8ff>%s：</color>%s", value_list[i].name, value_list[i].cur_attr)
					self.attr_add_list[i].text.text = value_list[i].add_attr
					self.node_list["ThreePanle"]:SetActive(true)
				else
					self.attr_add_list[i]:SetActive(false)
					self.attr_name_list[i]:SetActive(false)
					if i == 3 then
						self.node_list["ThreePanle"]:SetActive(false)
					end
				end
			end
			return 
		end
	end


end

function ShenShouFulingView:ClickUpGrade()
	if nil == self.current_equip_data or not next(self.current_equip_data) or self.current_equip_data.strength_level == ShenShouData.Instance:GetEquipMaxLevel(self.current_equip_data.slot_index) then 
		return 
	end

	local destroy_list_1, destroy_list_2 = self:GetDestroyList()
	local is_double_shuliandu = 0
	if not next(destroy_list_1) and not next(destroy_list_2) then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.NoSelect)
		return
	end

	----- 服务端一次分解上限是200，超过了需要分成两次
	local use_destroy = {}
	local use_destroy2 = {}
	for k,v in pairs(destroy_list_1) do
		if k <= 200 then
			table.insert(use_destroy, v)
		else
			table.insert(use_destroy2, v)
		end
	end
	if self.is_double then
		--如果双倍
		is_double_shuliandu = 1

		function close_callback()
			if next(use_destroy) then
				ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
					is_double_shuliandu, #use_destroy, use_destroy)
			end
			if next(use_destroy2) then
				ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
					is_double_shuliandu, #use_destroy2, use_destroy2)	
			end
			if next(destroy_list_2) then
				ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
					0, #destroy_list_2, destroy_list_2)
			end
			if next(use_destroy) or next(destroy_list_2) then
				self:PlayUpStarEffect()
			end
		end
		function open_callback()
			
			return ShenShouData.Instance:GetOther()[1].equip_double_shulian_per_gold, self.count
		end

		ShenShouCtrl.Instance:SetTipsCloseCallBack(close_callback)
		ShenShouCtrl.Instance:SetTipsOpenCallBack(open_callback)
		ViewManager.Instance:Open(ViewName.FulingTips)
	else
		is_double_shuliandu = 0
		if next(use_destroy) then
			ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
				is_double_shuliandu, #use_destroy, use_destroy)
		end
		if next(use_destroy2) then
			ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
				is_double_shuliandu, #use_destroy2, use_destroy2)	
		end
		if next(destroy_list_2) then
			ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
				0, #destroy_list_2, destroy_list_2)
		end
		if next(use_destroy) or next(destroy_list_2) then
			self:PlayUpStarEffect()
		end
	end
	
end

function ShenShouFulingView:GetDestroyList()
	local select_material_list = {}
	local has_strength_list = {}
	for k,v in pairs(self.shenshow_grid_list) do
		if v.is_select == true then
			if v.param and v.param.strengthen_level > 0 then
				table.insert(has_strength_list, v.index)
			else
				table.insert(select_material_list, v.index)
			end
		end
	end
	return select_material_list, has_strength_list
end

function ShenShouFulingView:PlayUpStarEffect()
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

function ShenShouFulingView:OnFlush(param_t)
	self.eqlist_data = ShenShouData.Instance:GetShenShouEqListData()
	--self:FlushShenShouEquip()
	if self.node_list["ListViewLeft"] and self.node_list["ListViewLeft"].gameObject.activeInHierarchy then
		self.node_list["ListViewLeft"].scroller:ReloadData(0)
	end
	local index = self.left_current_equip_index - 1
	if #self.eqlist_data - self.left_current_equip_index < 4 then
		index = self.left_current_equip_index - 5
	end
	if index >= 0 then 
		if self.node_list["ListViewLeft"] and self.node_list["ListViewLeft"].gameObject.activeInHierarchy then
			self.node_list["ListViewLeft"].scroller:JumpToDataIndex(index)
		end
	end

	--拿到背包信息
	self.shenshow_grid_list = ShenShouData.Instance:GetShenshouGridList()
	if self.node_list["ListViewRight"] and self.node_list["ListViewRight"].gameObject.activeInHierarchy then
		self.node_list["ListViewRight"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushMiddleContent()
end

function ShenShouFulingView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(221)
end

--------------------------------FulingEquipItem-----------------------------------
FulingEquipItem = FulingEquipItem or BaseClass(BaseCell)
function FulingEquipItem:__init()
	self.node_list["bg_toggle"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["bg_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnToggleClick, self))

	self.bg_toggle = self.node_list["bg_toggle"]

	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:SetRootInteractable(false)
	self.item_cell:ListenClick(function()
		self.node_list["bg_toggle"].toggle.isOn = true
		self:OnClick()
	end)
end

function FulingEquipItem:OnToggleClick()
	self:TextState()
end

function FulingEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FulingEquipItem:SetIndex(index)
	self.index = index
end

function FulingEquipItem:GetIndex()
	return self.index or 0
end

function FulingEquipItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data)
		self:TextState()
	end
end

function FulingEquipItem:TextState()
	if nil == self.data then return end
	local config, cfg
	config = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.node_list["TxtName"].text.text = "<color=" .. ITEM_TIP_COLOR[config.quality] .. ">" .. config.name .. "</color>"
	self.node_list["TxtName2"].text.text = "<color=" .. ITEM_TIP_COLOR[config.quality] .. ">" .. config.name .. "</color>"
end

function FulingEquipItem:SetToggleGroup(toggle_group)
	if self.node_list["bg_toggle"].toggle then
		self.node_list["bg_toggle"].toggle.group = toggle_group
	end
end

--------------------------------------FulingItemGroup--------------------------------------
FulingItemGroup = FulingItemGroup or BaseClass(BaseCell)
function FulingItemGroup:__init()
	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell_obj = self.node_list["item_"..i]
		self.item_cell_list[i] = FulingMaterialItem.New(item_cell_obj.gameObject)
	end	
	self.type = 0
end

function FulingItemGroup:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function FulingItemGroup:SetIndex(index)
	self.index = index
	for k,v in pairs(self.item_cell_list) do
		v:SetIndex(4 * (index - 1) + k)
	end
end

function FulingItemGroup:SetSelectType(type)
	self.type = type
end

function FulingItemGroup:OnFlush()
	self.data = self:GetData()
	for k,v in pairs(self.item_cell_list) do
		v:SetSelectType(self.type)
		v:SetData(self.data[k])
	end
end

--------------------------------------FulingMaterialItem--------------------------------------
FulingMaterialItem = FulingMaterialItem or BaseClass(BaseCell)
function FulingMaterialItem:__init()
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.root_node)
	self.type = 0
end

function FulingMaterialItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function FulingMaterialItem:SetIndex(index)
	self.index = index
end

function FulingMaterialItem:GetIndex()
	return self.index or 0
end

function FulingMaterialItem:SetSelectType(type)
	self.type = type
end

function FulingMaterialItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data, true)
		if self.data.item_id == 0 then
			self.data.is_select = false
			self.item_cell:SetData({})
		end
	else
		self.item_cell:SetData({})

	end
end

function FulingMaterialItem:GetIsSelect()
	return self.data.is_select or false
end

function FulingMaterialItem:SetIsSelect(enable)
	if next(self.data) then
		self.data.is_select = enable
	end
end
