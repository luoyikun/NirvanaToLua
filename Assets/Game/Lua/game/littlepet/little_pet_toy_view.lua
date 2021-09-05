--宠物玩具
LittlePetToyView = LittlePetToyView or BaseClass(BaseRender)

local EQUIP_NUM = 4

function LittlePetToyView:__init()
	self.pet_cell_list = {}
	self.pet_data_list = {}
	self.equip_item_list = {}
	self.equip_pet_cfg_list = {}
	self.equip_item_toggle_list = {}
	self.equip_change_remind_list = {}
	self.equip_up_level_remind_list = {}
	self.index = 1

	self.is_has_equip_pet = false
	self.is_active_max_level = false
	self.is_toy_equip = false
	self.is_show_arrow = false

	self.up_grade_item = ItemCell.New()
	self.up_grade_item:SetInstanceParent(self.node_list["ItemToy"])
	self.exchange = self.node_list["Exchange"]

	self.pet_model = RoleModel.New()
	self.pet_model:SetDisplay(self.node_list["ToyDisplay"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.pet_model:SetRotation(Vector3(0, -30, 0))

	self.list_view = self.node_list["ToyList"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLittleToyPetCell, self)
	
	self.node_list["ToyHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["UpGradeButtonToy"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["BtnDuiHuan"].button:AddClickListener(BindTool.Bind(self.OnClickDuiHuan, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerToy"])
	for i = 1, EQUIP_NUM do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ToyItem" .. i])
		item_cell:SetData(nil)
		table.insert(self.equip_item_list, item_cell)

		self.equip_item_toggle_list[i] = self.node_list["ToyItemClick" .. i]
		self.equip_change_remind_list[i] = self.node_list["Arrow" .. i]

		local start_pos4 = Vector3(30 , 13 , 0)
		local end_pos4 = Vector3(30 , 30 , 0)
		UITween.MoveLoop(self.node_list["Arrow" .. i], start_pos4, end_pos4, 1)
		self.equip_up_level_remind_list[i] = self.node_list["ShowUpEquipRemind" .. i]
		-- self.node_list["ToyItem" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickItem, self, i))
		-- self.node_list["ToyItemClick" .. i].button:AddClickListener(BindTool.Bind(self.OnClickChange, self, i))
		self.node_list["ToyItemClick" .. i].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickItem, self, i))
		self.node_list["BtnIsLover" .. i].button:AddClickListener(BindTool.Bind(self.OnClickChange, self, i))
		self.node_list["Choose" .. i].button:AddClickListener(BindTool.Bind(self.OnClickChange, self, i))
		self.node_list["BtnXiexia" .. i].button:AddClickListener(BindTool.Bind(self.OnClickXiexia, self, i))
	end

	
end

function LittlePetToyView:__delete()
	self:CancelAniQuest()
	if self.pet_model ~= nil then
		self.pet_model:DeleteMe()
		self.pet_model = nil
	end

	if self.up_grade_item ~= nil then
		self.up_grade_item:DeleteMe()
		self.up_grade_item = nil
	end

	for k,v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.equip_item_toggle_list) do
		v = nil
	end
	self.equip_item_toggle_list = {}

	for k, v in pairs(self.pet_cell_list) do
		v:DeleteMe()
	end
	self.pet_cell_list = {}

	self.model = nil
	self.exchange = nil
	self.list_view = nil
	self.fight_text = nil
end

function LittlePetToyView:CloseCallBack()
	self:CancelAniQuest()
end
	
function LittlePetToyView:OpenCallBack()
	self.select_index = 1
	self.cur_toy_index = 1
	self.cur_toy_level = 0
	self.cur_pet_index = -1
	self.cur_pet_info_type = -1
	self.cur_pet_color = 0
	self.model_res_id = 0
	self.can_up_level_list = {}
	
	self:DoPanelTweenPlay()
	self:GetPetDataList()
	self:GetEquipPetDataList()
	self.list_view.scroller:ReloadData(0)
	self:AutoClick()
end

function LittlePetToyView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Top"], Vector3(-40, 487, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], Vector3(200, -380, 0), TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-200, -28, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveAlpahShowPanel(self.node_list["Boom"], Vector3(-40, -162, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

--flag为是否通过刷新方法调用标志
function LittlePetToyView:AutoClick(flag)
	local res_id = 0
	local num = self:GetNumberOfCells()
	local data = self:SingleItemDataByIndex(self.select_index)

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then
		return
	end

	if flag and num > 0 and self.select_index > 1 and (nil == data or nil == data.pet_index) then
		self.select_index = self.select_index - 1
		data = self:SingleItemDataByIndex(self.select_index)
	end

	if data and data.pet_index then
		self.cur_pet_index = data.pet_index
		self.cur_pet_info_type = data.info_type
		self.cur_pet_color = data.color
		res_id = data.res_id
	end

	self.cur_pet_info_type = num > 0 and self.cur_pet_info_type or LITTLE_PET_TYPE.MINE_PET
	self.is_has_equip_pet = num > 0
	self.node_list["ToyDisplay"]:SetActive(self.is_has_equip_pet)
	self.node_list["MaskToy"]:SetActive(self.is_has_equip_pet)
	self.node_list["NameImaToy"]:SetActive(self.is_has_equip_pet)
	-- self.node_list["NextUpToy"]:SetActive(self.is_has_equip_pet and not self.is_active_max_level and self.is_toy_equip)
	self.node_list["NoEquipPetToy"]:SetActive(not self.is_has_equip_pet)
	self.node_list["PetNameToy"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	
	self:FlushAllHighLight()
	self:FlushPetModle(res_id, flag)
	self:FlushFourEquipItem()
	self:ShowRemindRelated()
	self:OnClickItem(self.cur_toy_index, true)
end

--宠物Item数据
function LittlePetToyView:GetPetDataList()
	self.pet_data_list = LittlePetData.Instance:GetSortAllPetList()
end

function LittlePetToyView:OnClickDuiHuan()
	ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_exchange)
end

--相关配置数据
function LittlePetToyView:GetEquipPetDataList()
	self.equip_pet_cfg_list = LittlePetData.Instance:GetAllEquipPetCfgDataList()
end

function LittlePetToyView:GetNumberOfCells()
	local num = self.pet_data_list and #self.pet_data_list or 0
	return num
end

--玩具装备格子点击事件
function LittlePetToyView:OnClickItem(index, state)
	if state then
		self:FlushLeftDataByToyIndex(index)
		self:ShowLevelRemind()
		if self.equip_item_toggle_list[index] then
			self.equip_item_toggle_list[index].toggle.isOn = true
			self.index = index
		end
	end
end

function LittlePetToyView:RefreshLittleToyPetCell(cell, cell_index)
	local pet_cell = self.pet_cell_list[cell]
	if nil == pet_cell then
		pet_cell = LittleToyPetCell.New(cell.gameObject)
		pet_cell.root_node.toggle.group = self.list_view.toggle_group
		pet_cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self))
		self.pet_cell_list[cell] = pet_cell
	end

	local data_index = cell_index + 1 
	local data = self:SingleItemDataByIndex(data_index)
	pet_cell:SetData(data)
	pet_cell:SetIndex(data_index)
	pet_cell:SetHighLight(data_index == self.select_index)
end

function LittlePetToyView:SingleItemDataByIndex(data_index)
	local data = {}
	local data_list = self.pet_data_list and self.pet_data_list[data_index]
	if nil == data_list or nil == next(data_list) then return data end

	local id = data_list.id
	local info_type = data_list.info_type
	local attr_list = data_list.attr_list
	local cur_index = data_list.index
	for k,v in pairs(self.equip_pet_cfg_list) do
		if cur_index == v.index and id == v.id and info_type == v.info_type then
			data = v
			data.attr_list = attr_list
			data.pet_index = cur_index
			break
		end
	end

	return data
end

function LittlePetToyView:OnClickXiexia(index)
	LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_TAKEOFF, self.cur_pet_index, index - 1)
end
--宠物Item点击回调
function LittlePetToyView:OnClickCellCallBack(cell)
	if nil == cell then return end
	local index = cell:GetIndex()
	local data = cell:GetData()
	if self.select_index == index or nil == data or nil == data.pet_index then return end

	self.cur_pet_index = data.pet_index
	self.cur_pet_info_type = data.info_type
	self.select_index = index
	self.cur_pet_color = data.color

	self:FlushAllHighLight()
	self:FlushCenterByPetIndex(data)
	self:ShowRemindRelated()
	self:OnClickItem(self.cur_toy_index, true)
end

--刷新高亮
function LittlePetToyView:FlushAllHighLight()
	if nil == self.select_index then return end

	for k,v in pairs(self.pet_cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end

-- 刷新中间部分
function LittlePetToyView:FlushCenterByPetIndex(data)
	self:FlushFourEquipItem()

	if nil == data or nil == data.pet_index then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then
		return
	end
	local res_id = data.res_id or 0
	local name = data.name or ""
	local info_type = data.info_type or -1

	self:FlushPetModle(res_id)

	self.node_list["PetNameToy"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
end

--当前装备列表
function LittlePetToyView:GetCurPetToyListByInfo()
	local toy_equip_list = {}
	local pet_index = self.select_index
	local data_list = self.pet_data_list and self.pet_data_list[pet_index]
	if nil == data_list or nil == data_list.equipment_llist then return toy_equip_list end 

	toy_equip_list = data_list.equipment_llist
	return toy_equip_list
end

--刷新四个装备格子
function LittlePetToyView:FlushFourEquipItem()
	local toy_equip_list = self:GetCurPetToyListByInfo()

	for i = 1, EQUIP_NUM do
		if self.equip_item_list[i] then
			local data = {}
			local item_id = 0
			local level = 0

			if toy_equip_list and toy_equip_list[i] then
				item_id = toy_equip_list[i].equipment_id or 0
				level = toy_equip_list[i].level or 0
			end
			data.item_id = item_id
			self.equip_item_list[i]:SetData(data)
			--self.equip_item_list[i]:SetDefualtBgState(false)
			self.equip_item_list[i]:ShowStrengthLable(item_id ~= 0 and level ~= 0)
			self.equip_item_list[i]:SetStrength(level)
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg and next(item_cfg) ~= nil then
				self.equip_item_list[i]:SetIconGrayVisible(item_cfg.color > self.cur_pet_color)
			end
			self.node_list["BtnXiexia" .. i]:SetActive(item_id ~= 0 and self.cur_pet_info_type ~= LITTLE_PET_TYPE.LOVER_PET)
			self.node_list["BtnIsLover" .. i ]:SetActive(item_id ~= 0 and self.cur_pet_info_type ~= LITTLE_PET_TYPE.LOVER_PET)
			self.node_list["Choose" .. i]:SetActive(item_id == 0 and self.cur_pet_info_type ~= LITTLE_PET_TYPE.LOVER_PET)
		end
	end
end

--刷新模型 flag为通过刷新方法调用时判断是否需要刷新模型
function LittlePetToyView:FlushPetModle(res_id, flag)
	if nil == res_id then return end

	local model_flush_flag = flag or false
	if model_flush_flag and res_id == self.model_res_id then return end

	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.pet_model:SetMainAsset(bundle, asset)
	self.model_res_id = res_id

	self:CancelAniQuest()
	if res_id == 0 then return end
	
	self.pet_model:SetTrigger("rest")
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.pet_model:SetTrigger("rest")
	end, 15)
end

function LittlePetToyView:CancelAniQuest()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

--当前是否装备了宠物
function LittlePetToyView:IsEquipPet()
	local is_equip = true
	if #self.pet_data_list == 0 then
		is_equip = false
		TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.NoEquipPet)
	end

	return is_equip
end

--玩具格子是否装备玩具
function LittlePetToyView:IsEquipPetToy()
	local is_equip_toy = true
	local toy_equip_list = self:GetCurPetToyListByInfo()
	local index = self.cur_toy_index
	if toy_equip_list[index] and toy_equip_list[index].equipment_id and toy_equip_list[index].equipment_id == 0 then
		local str = self.cur_pet_info_type == LITTLE_PET_TYPE.LOVER_PET and Language.LittlePet.LoverNoEquipPetToy or Language.LittlePet.NoEquipPetToy
		TipsCtrl.Instance:ShowSystemMsg(str)
		is_equip_toy = false
	end

	return is_equip_toy
end

--玩具装备更换
function LittlePetToyView:OnClickChange(index)
	if not self:IsEquipPet() or self.cur_pet_index == -1 then return end

	local data = {}
	data.pet_index = self.cur_pet_index
	data.toy_index = index
	data.max_color = self.cur_pet_color

	local toy_id = 0
	local toy_equip_list = self:GetCurPetToyListByInfo()
	if toy_equip_list and toy_equip_list[index] then
		toy_id = toy_equip_list[index].equipment_id or 0
	end
	local toy_list = LittlePetData.Instance:GetBagLittlePetToyDataListByToyPart(index, self.cur_pet_color)
	if toy_id == 0 then
		if toy_list == nil or toy_list[1] == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.LittlePet.LittlePetError)
		else
			LittlePetCtrl.Instance:ShowToyBagView(data)
		end
	else
		if self.index == index then
			LittlePetCtrl.Instance:ShowToyBagView(data)
		end
	end
	self:OnClickItem(index, true)
	
end

--玩具装备升级
function LittlePetToyView:OnClickUpGrade()
	if not self:IsEquipPet() then return end
	if not self:IsEquipPetToy() then return end
	local cfg = LittlePetData.Instance:GetSingleEquipToyCfgByIndexAndLevel(self.cur_toy_index - 1, self.cur_toy_level + 1)
	if nil == next(cfg) then return end

	local need_num = cfg.stuff_num
	local stuff_item_id = cfg.stuff_id
	local has_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local auto_buy = LittlePetData.Instance:GetToyUpLevelAutoBuyFlag()
	if has_num < need_num and not auto_buy then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				LittlePetData.Instance:SetToyUpLevelAutoBuyFlag(is_buy_quick)
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end

	local is_lover = self.cur_pet_info_type == LITTLE_PET_TYPE.LOVER_PET
	local opera_type = not is_lover and LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_SELF or LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EQUIPMENT_UPLEVEL_LOVER
	local param1 = self.cur_pet_index
	local param2 = self.cur_toy_index - 1
	local param3 = auto_buy

	LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
end

--属性加成显示
function LittlePetToyView:EquipPetAttrShow(pet_cfg, equipment_id, next_cfg, is_max_level)
	local attr_list = LittlePetData.Instance:GetSinglePetToyPartAttr(pet_cfg)
	local next_attr_list = LittlePetData.Instance:GetSinglePetToyPartAttr(next_cfg)
	local item_cfg = ItemData.Instance:GetItemConfig(equipment_id)
	
	if nil == attr_list or nil == next(attr_list) then return end
	if item_cfg then
		local gongji_num = attr_list.gong_ji + (item_cfg.attack or 0)
		local fangyu_num = attr_list.fang_yu + (item_cfg.fangyu or 0)
		local shengming_num = attr_list.max_hp + (item_cfg.hp or 0)

		self.node_list["GongJi"].text.text = gongji_num
		self.node_list["FangYu"].text.text = fangyu_num
		self.node_list["ShengMing"].text.text = shengming_num
		self.node_list["PercentToy"].text.text = (attr_list.per or 0) .. "%"

		self.node_list["GongJiNode"]:SetActive(gongji_num ~= 0 )
		self.node_list["FangYuNode"]:SetActive(fangyu_num ~= 0 )
		self.node_list["ShengMingNode"]:SetActive(shengming_num ~= 0)
	else
		self.node_list["GongJi"].text.text = 0
		self.node_list["FangYu"].text.text = 0
		self.node_list["ShengMing"].text.text = 0
		self.node_list["PercentToy"].text.text = 0
		self.node_list["GongJiNode"]:SetActive(true)
		self.node_list["FangYuNode"]:SetActive(true)
		self.node_list["ShengMingNode"]:SetActive(true)
	end


	self.node_list["GongJiNextAttr"]:SetActive(not is_max_level and nil ~= item_cfg)
	self.node_list["FangYuNextAttr"]:SetActive(not is_max_level and nil ~= item_cfg)
	self.node_list["ShengMingNextAttr"]:SetActive(not is_max_level and nil ~= item_cfg)
	self.node_list["PercentToyNextAttr"]:SetActive(not is_max_level and nil ~= item_cfg)
	if not is_max_level and next_attr_list and next(next_attr_list) then
		self.node_list["GongJiNextText"].text.text = next_attr_list.gong_ji - attr_list.gong_ji
		self.node_list["FangYuNextText"].text.text = next_attr_list.fang_yu - attr_list.fang_yu
		self.node_list["ShengMingNextText"].text.text = next_attr_list.max_hp - attr_list.max_hp
		self.node_list["PercentToyNextText"].text.text = next_attr_list.per - attr_list.per
	end
end

--右侧属性加成更新
function LittlePetToyView:FlushLeftDataByToyIndex(toy_index)
	self.exchange:SetActive(false)
	local toy_equip_list = self:GetCurPetToyListByInfo()
	self.cur_toy_index = toy_index
	self.cur_toy_level = toy_equip_list[toy_index] and toy_equip_list[toy_index].level or 0

	local cfg = LittlePetData.Instance:GetSingleEquipToyCfgByIndexAndLevel(self.cur_toy_index - 1, self.cur_toy_level + 1)
	local next_cfg = LittlePetData.Instance:GetSingleEquipToyCfgByIndexAndLevel(self.cur_toy_index - 1, self.cur_toy_level + 2)
	self.exchange:SetActive(true)
	if nil == next(cfg) then return end

	local need_num = cfg.stuff_num
	local stuff_item_id = cfg.stuff_id
	local equipment_id = toy_equip_list[toy_index] and toy_equip_list[toy_index].equipment_id or 0
	local has_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local has_num_color = has_num >= need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local has_num_str = ToColorStr(has_num, has_num_color)
	local max_level = LittlePetData.Instance:GetToySinglePartMaxLevelByIndex(self.cur_toy_index)
	local is_max_level = max_level ~= 0 and self.cur_toy_level >= max_level 
	local item_cfg = ItemData.Instance:GetItemConfig(equipment_id)

	self.node_list["Txt_tip"]:SetActive(item_cfg and item_cfg.color > self.cur_pet_color)

	self.node_list["NeedNumToy"].text.text = string.format("%s / %s" , has_num_str , need_num)
	
	self.is_active_max_level = is_max_level
	if is_max_level and nil ~= item_cfg then
		UI:SetButtonEnabled(self.node_list["UpGradeButtonToy"], false)
	else
		UI:SetButtonEnabled(self.node_list["UpGradeButtonToy"], has_num >= need_num)
	end
	self.node_list["TxtBtnToy"].text.text = (self.is_active_max_level and nil ~= item_cfg) and Language.LittlePet.YiManJi or Language.LittlePet.ShengJi
	if self.is_active_max_level and nil ~= item_cfg then
		self.node_list["NeedNumToy"].text.text = "- / -"
	end
	self:EquipPetAttrShow(cfg, equipment_id, next_cfg, is_max_level)

	local cur_power = LittlePetData.Instance:GetSinglePetToyPartPower(self.cur_pet_index, self.cur_pet_info_type, toy_index, nil, true)
	-- local next_power = LittlePetData.Instance:GetSinglePetToyPartPower(self.cur_pet_index, self.cur_pet_info_type, toy_index, true)
	-- local next_up = next_power - cur_power

	-- local equip_capability = CommonDataManager.GetCapabilityCalculation(item_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = cur_power --+ equip_capability
	end
	-- self.node_list["NextUpNum"].text.text = next_up


	local toy_name = item_cfg and item_cfg.name or ""
	local toy_level = self.cur_toy_level
	self.is_toy_equip = equipment_id ~= 0
	self.node_list["NoHaveName"]:SetActive(not self.is_toy_equip)
	-- self.node_list["NextUpToy"]:SetActive(self.is_has_equip_pet and not self.is_active_max_level and self.is_toy_equip)
	self.node_list["ToyName"]:SetActive(equipment_id ~= 0)
	self.node_list["ToyName"].text.text = string.format("Lv. %s  %s" , self.cur_toy_level , toy_name)
	local data = {}
	data.item_id = stuff_item_id
	self.up_grade_item:SetData(data)
end

--红点相关
function LittlePetToyView:ShowRemindRelated()
	local is_remind, remind_list = LittlePetData.Instance:SinglePetToyRemind(self.cur_pet_index, self.cur_pet_info_type)
	local can_equip_part_list = remind_list.can_equip_part_list
	local can_replace_list = remind_list.can_replace_list
	self.can_up_level_list = remind_list.can_up_level_list
	--“替换”按钮红点
	for k,v in pairs(self.equip_change_remind_list) do
		local show_red_ponit = is_remind
		if show_red_ponit then
			if (nil == can_equip_part_list or nil == can_equip_part_list[k]) and (nil == can_replace_list or nil == can_replace_list[k]) then
				show_red_ponit = false
			end
		end
		local toy_equip_list = self:GetCurPetToyListByInfo()
		local toy_id = 0
		if toy_equip_list and toy_equip_list[k] then
			toy_id = toy_equip_list[k].equipment_id or 0
		end
		if toy_id == 0 then
			v:SetActive(false)
		else
			v:SetActive(show_red_ponit)
		end
	end
	--玩具装备格子红点
	for k,v in pairs(self.equip_up_level_remind_list) do
		local show_red_ponit = is_remind
		if show_red_ponit then
			if (nil == can_equip_part_list or nil == can_equip_part_list[k]) and (nil == self.can_up_level_list or nil == self.can_up_level_list[k]) then
				show_red_ponit = false
			end
		end
		v:SetActive(show_red_ponit)
	end
end

--升级按钮红点
function LittlePetToyView:ShowLevelRemind()
	local state = false
	if self.can_up_level_list and self.can_up_level_list[self.cur_toy_index] then
		state = true
	end
	self.node_list["ShowUpLevelRemind"]:SetActive(state)
end

function LittlePetToyView:OnFlush()
	self:GetPetDataList()
	self:GetEquipPetDataList()
	-- if num <= 0 then
	-- 	self.list_view.scroller:ReloadData(0)
	-- else
	if self.node_list["MaskToy"].gameObject.activeInHierarchy then 
		self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
	end
	--end

	self:AutoClick(true)
end

function LittlePetToyView:OnClickHelp()
	local tip_id = 278
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

------------------------------------------------------------------------------------------
LittleToyPetCell = LittleToyPetCell or BaseClass(BaseCell)

function LittleToyPetCell:__init()
	-- self.item_cell = ItemCell.New()
	-- self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	-- self.item_cell:ShowHighLight(false)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"], "FightPower3")
	self.node_list["ToyItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function LittleToyPetCell:__delete()
	-- if self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end
	self.fight_text = nil
end

function LittleToyPetCell:SetData(data)
	self.data = data
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["Sprite"].image:LoadSprite(bundle, asset)
	end
	local bg_bundle, bg_asset = ResPath.GetLittlePetBg(Common_Five_Rank_Color[item_cfg.color])
	if bg_bundle and bg_asset then
		self.node_list["head_frame"].image:LoadSprite(bg_bundle, bg_asset)
	end
	self:Flush()
end

function LittleToyPetCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function LittleToyPetCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function LittleToyPetCell:OnFlush()
	if nil == self.data or nil == self.data.index then return end
	local pet_index = self.data.index
	local pet_info_type = self.data.info_type
	local item_id = self.data.item_id or 0

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return
	end
	local is_lover = pet_info_type == LITTLE_PET_TYPE.LOVER_PET
	local base_power = LittlePetData.Instance:CalPetBaseFightPower(false, self.data.item_id)
	local feed_power = LittlePetData.Instance:GetFeedAttrCfgByIndex(pet_index, pet_info_type, self.data.item_id)
	local toy_power = LittlePetData.Instance:GetSinglePetToyPower(pet_index, pet_info_type)
	local power = base_power + toy_power + feed_power
	local state = LittlePetData.Instance:SinglePetToyRemind(pet_index, pet_info_type)


	-- self.node_list["Name"].text.text = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color])
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
	self.node_list["IsLover"]:SetActive(is_lover)
	self.node_list["ShowRedPoint"]:SetActive(state)

	-- local data = {}
	-- data.item_id = self.data.item_id or 0
	-- self.item_cell:SetData(data)
end