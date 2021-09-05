-- 仙域-外观-面饰幻化-AppearanceHuanHuaContent
MaskHuanHuaView = MaskHuanHuaView or BaseClass(BaseView)

function MaskHuanHuaView:__init()
	self.ui_config = {
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/appearance_prefab", "ModelDragLayer"},
		{"uis/views/appearance_prefab", "AppearanceHuanHuaContent"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.def_index = TabIndex.appearance_mask_huanhua
	self.play_audio = true
	self.full_screen = true
	self.cell_list = {}
	self.prefab_preload_id = 0
end

function MaskHuanHuaView:__delete()
	
end

function MaskHuanHuaView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	self.fight_text = nil
end

function MaskHuanHuaView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = "uis/images_atlas", asset = "tab_icon_mask", tab_index = TabIndex.appearance_mask_huanhua, remind_id = RemindName.MaskHuanHua},
	}

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.ClickUpGrade, self))
	self.node_list["BtnUse"].button:AddClickListener(BindTool.Bind(self.ClickUsed, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickAddGold, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))
	RemindManager.Instance:Fire(RemindName.MaskHuanHua)

	self.node_list["TxtTitle"].text.text = Language.Common.Huanhua

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemParent"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function MaskHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function MaskHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self.select_index = nil
	end
end

function MaskHuanHuaView:ClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MaskHuanHuaView:ClickClose()
	self:Close()
	local mask_view = nil
	if AppearanceCtrl.Instance.view then
		mask_view = AppearanceCtrl.Instance.view:GetMaskView()
	end

	if mask_view and mask_view:IsOpen() then
		mask_view:UITween()
	end
end

--点击目标战力
function MaskHuanHuaView:ClickSuperPower()
	local cfg = self.list_data[self.select_index]
	local image_id = cfg and cfg.image_id
	local index = image_id or 0
	local data = MaskData.Instance:GetSpecialHuanHuaShowData(index)
	TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
end

-- 激活升级形象
function MaskHuanHuaView:ClickUpGrade()
	local data = self.list_data[self.select_index]
	if nil == data then
		return
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	local is_active = MaskData.Instance:GetHuanHuaIsActiveByImageId(data.image_id)
	local huanhua_cfg = MaskData.Instance:GetHuanHuaCfgInfo(data.image_id)
	if huanhua_cfg == nil then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(huanhua_cfg.stuff_id) < huanhua_cfg.stuff_num then
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[huanhua_cfg.stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(huanhua_cfg.stuff_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(huanhua_cfg.stuff_id, 2)
			return
		end

		local func = function(stuff_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, huanhua_cfg.stuff_id, nil, huanhua_cfg.stuff_num)
		return
	end

	
	if not is_active then
		for k, v in pairs(data_list) do
			if v.item_id == data.item_id then
				PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
				return
			end
		end
	else
		MaskCtrl.Instance:SendMaskReq(MASK_OPERA_TYPE.MASK_OPERA_TYPE_SPECIAL_IMAGE_UPGRADE, data.image_id)
	end
end

-- 使用形象
function MaskHuanHuaView:ClickUsed()
	local data = self.list_data[self.select_index]
	if nil == data then
		return
	end

	local image_id = data.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000
	MaskCtrl.Instance:SendMaskReq(MASK_OPERA_TYPE.MASK_OPERA_TYPE_USE_IMAGE, image_id)
end

function MaskHuanHuaView:GetNumberOfCells()
	return #self.list_data 
end

function MaskHuanHuaView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	
	local huanhua_cell = self.cell_list[cell]
	if nil == huanhua_cell then
		huanhua_cell = MaskHuanHuaCell.New(cell.gameObject)
		huanhua_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		huanhua_cell:ListenClick(BindTool.Bind(self.ClickItem, self, huanhua_cell))
		self.cell_list[cell] = huanhua_cell
	end

	huanhua_cell:SetToggleIsOn(self.select_index == data_index)
	huanhua_cell:SetIndex(data_index)
	huanhua_cell:SetData(self.list_data[data_index])
end

function MaskHuanHuaView:ClickItem(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()
	if cell == data then
		return
	end

	local index = cell:GetIndex()
	if self.select_index == index then
		return
	end

	self.select_index = index

	self:FlushView()
	self:FlushModel()	
end

function MaskHuanHuaView:FlushView()
	self:FlushContent()
end

function MaskHuanHuaView:FlushContent()
	local data = self.list_data[self.select_index]
	if nil == data then
		return
	end
	
	local huanhua_cfg = MaskData.Instance:GetHuanHuaCfgInfo(data.image_id)
	if nil == huanhua_cfg then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end

	local now_level = MaskData.Instance:GetHuanHuaGrade(data.image_id)
	local name = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. "> " .. data.image_name .. "</color>"
	self.node_list["TxtName"].text.text = "Lv." .. now_level .. name

	-- self.fight_text.text.text = CommonDataManager.GetCapabilityCalculation(huanhua_cfg)
	-- self.node_list["HP"].text.text = huanhua_cfg.maxhp
	-- self.node_list["GongJi"].text.text = huanhua_cfg.gongji
	-- self.node_list["FangYu"].text.text = huanhua_cfg.fangyu
	local attr0 = MaskData.Instance:GetHuanHuaCfgInfo(data.image_id)
	local attr1 = MaskData.Instance:GetHuanHuaCfgInfo(data.image_id, now_level + 1)
	local max_grade = MaskData.Instance:GetSpecialImageMaxUpLevelById(data.image_id)
	self:SetAttr(now_level, attr0, attr1, max_grade, data.image_id)

	local is_show_super = MaskData.Instance:IsShowSuperPower(data.image_id)
	local is_active_super = MaskData.Instance:GetStarIsShowSuperPower(data.image_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local need_reach_level = MaskData.Instance:GetActiveSuperPowerNeedLevel(data.image_id)
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	local max_level = MaskData.Instance:GetSpecialImgMaxLevel()
	local is_active = MaskData.Instance:GetHuanHuaIsActiveByImageId(data.image_id)
	local is_used = MaskData.Instance:GetHuanHuaIdIsUsed(data.image_id, true)

	-- 设置升级按钮状态
	UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
	if not is_active then
		self.node_list["BtnUpGradeText"].text.text = Language.MultiMount.Active
	elseif now_level >= max_level then
		self.node_list["BtnUpGradeText"].text.text = Language.MultiMount.MaxLv
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
	else
		self.node_list["BtnUpGradeText"].text.text = Language.MultiMount.UpGrade
	end

	-- 设置是否使用显示
	self.node_list["ImgUse"]:SetActive(is_used)
	self.node_list["BtnUse"]:SetActive(is_active and not is_used)

	self.item_cell:SetData({item_id = data.item_id})

	local have_num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	local need_num = huanhua_cfg.stuff_num or 0
	local color = have_num >= need_num and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	if now_level >= max_level then
		self.node_list["TxtMaterials"].text.text = Language.MultiMount.MaxGradeDesc
	else
		self.node_list["TxtMaterials"].text.text = string.format("%s / %s", ToColorStr(have_num, color), need_num)
	end
end

function MaskHuanHuaView:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
	local switch_attr_list_1 = CommonDataManager.GetOrderAttributte(attr1)
	local switch_attr_list_0 = CommonDataManager.GetOrderAttributte(attr0)
	if special_image_grade == 0 then
		local index = 0
		for k, v in pairs(switch_attr_list_1) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = switch_attr_list_0[k].value or 0
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = (switch_attr_list_1[k].value - switch_attr_list_0[k].value) or 0
			end
		end
		local capability = CommonDataManager.GetCapabilityCalculation(attr1)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	elseif special_image_grade >= max_grade then
		local index = 0
		for k, v in pairs(switch_attr_list_0) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				self.node_list["Arrow" .. index]:SetActive(false)
			end
		end
		local capability = CommonDataManager.GetCapabilityCalculation(attr0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	else
		local index = 0
		for k, v in pairs(switch_attr_list_0) do
			local attr_name = Language.Advance.NormalAttr[v.key]
			if nil ~= attr_name and v.value ~= 0 then
				index = index + 1
				self.node_list["ShuXing_" .. index]:SetActive(true)
				self.node_list["Value_" .. index]:SetActive(true)
				self.node_list["ShuXing_" .. index].text.text = attr_name
				self.node_list["Value_" .. index].text.text = v.value
				self.node_list["Arrow" .. index]:SetActive(true)
				self.node_list["AddValue" .. index]:SetActive(true)
				self.node_list["AddValue" .. index].text.text = (switch_attr_list_1[k].value - switch_attr_list_0[k].value) or 0
			end
		end
		local capability = CommonDataManager.GetCapabilityCalculation(attr0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	end

	local active_grade, attr_type, attr_value = MaskData.Instance:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	if active_grade and attr_type and attr_value then
		if special_image_grade < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = special_image_grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = MaskData.Instance:GetHuanHuaSpecialAttrActiveType(i, special_index)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						str = string.format(Language.Advance.NextLevelAttr, next_active_grade, special_attr / 100)
						break
					end
				end
			end
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		end
	else
		self.node_list["TxtSpecialAttr"]:SetActive(false)
	end
end


function MaskHuanHuaView:FlushModel()
	local data = self.list_data[self.select_index]
	if nil == data then
		return
	end

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -172, 0)
	UIScene:SetCameraTransform(transform)
	UIScene:SetTerraceBg(nil, nil, {position = Vector3(-136, -300, 0)}, nil)
	
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetMaskModel(data.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local info = {}
			info.prof = base_prof
			info.sex = main_vo.sex
			info.appearance = {}
			local fashion_info = FashionData.Instance:GetFashionInfo()
			local is_used_special_img = fashion_info.is_used_special_img
			info.is_normal_fashion = is_used_special_img == 0 and true or false
			info.appearance.fashion_body_is_special = is_used_special_img == 0 and true or false
			info.appearance.fashion_body = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img
			info.appearance.mask_used_imageid = data.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID -- 特殊资源形象+ 1000

			UIScene:ResetRotate()
			UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
		end)
end

function MaskHuanHuaView:OpenCallBack()
	self.select_index = 1
	self:Flush()
	self.list_data = MaskData.Instance:GetHuanHuaCfgList() or {}
	if nil == self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:UITween()
	self:FlushModel()
end

function MaskHuanHuaView:CloseCallBack()
	if nil ~= self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function MaskHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	local callback = function ()
		UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		UIScene:SetTerraceBg(nil, nil, {position = Vector3(-142, -300, 0)}, nil)

		local prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
		transform.rotation = Quaternion.Euler(8, -168, 0)
		UIScene:SetCameraTransform(transform)

		self:OpenCallBack()
	end
	UIScene:ChangeScene(self, callback)
end

function MaskHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function MaskHuanHuaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			if v and v.id then
				local index, num = MaskData.Instance:CanHuanhuaIndexByImageId(v.id)
				if index then
					self.select_index = index
					local cfg_list = MaskData.Instance:GetHuanHuaCfgList()
					num = num > 5 and num or num - 1
					self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
					self:FlushModel()
				end
			end
			self:FlushView()
			self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(false)
		end
	end
end

function MaskHuanHuaView:UITween()
	UITween.MoveShowPanel(self.node_list["SkillPanel"], Vector3(-20, -374, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["InfoPanel"], Vector3(70, -377.5, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["TitlePanel"], Vector3(-3, 40, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnPanel"], Vector3(-0.8, -450, 0), 0.7)
end

---------------------------------------------------------------------------------------------------
MaskHuanHuaCell = MaskHuanHuaCell or BaseClass(BaseCell)
function MaskHuanHuaCell:__init()

end

function MaskHuanHuaCell:__delete()

end

function MaskHuanHuaCell:ListenClick(handler)
	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler)
end

function MaskHuanHuaCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MaskHuanHuaCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function MaskHuanHuaCell:SetData(data)
	if nil == data then
		return
	end

	local huanhua_cfg = MaskData.Instance:GetHuanHuaCfgInfo(data.image_id)
	if nil == huanhua_cfg then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	self.node_list["TxtName"].text.text = ToColorStr(data.image_name, SOUL_NAME_COLOR[item_cfg.color])

	local is_active = MaskData.Instance:GetHuanHuaIsActiveByImageId(data.image_id)
	UI:SetGraphicGrey(self.node_list["ImgIcon"], not is_active)
	local is_used = MaskData.Instance:GetHuanHuaIdIsUsed(data.image_id, true)
	self.node_list["ImgYiHuanHua"]:SetActive(is_active and is_used)

	local is_show_remind = false
	if MaskData.Instance:GetHuanHuaGrade(data.image_id) < MaskData.Instance:GetSpecialImgMaxLevel() and
		ItemData.Instance:GetItemNumIsEnough(data.item_id, huanhua_cfg.stuff_num) then
		is_show_remind = true
	end
	self.node_list["ImgRemind"]:SetActive(is_show_remind)
	
end