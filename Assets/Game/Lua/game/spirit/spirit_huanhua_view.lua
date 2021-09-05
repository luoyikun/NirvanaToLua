-- 仙宠幻化-SpiritHuanHuaView
SpiritHuanHuaView = SpiritHuanHuaView or BaseClass(BaseView)

function SpiritHuanHuaView:__init()
	self.ui_config = {
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/spiritview_prefab", "ModelDragLayer"}, 
		{"uis/views/spiritview_prefab", "SpiritHuanHuaView"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.cell_list = {}
	self.res_id = 0
	self.index = 1
	self.def_index = TabIndex.spitit_huanhua
	self.play_audio = true
	self.full_screen = true
end

function SpiritHuanHuaView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = "uis/images_atlas", asset = "tab_icon_sprite", tab_index = TabIndex.spitit_huanhua,remind_id = RemindName.SpiritHuanHua},
	}
	self.node_list["ActivateBtn"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnReturn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["UpGradeButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["UseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickUseIma, self))
	self.node_list["BtnZhaoHui"].button:AddClickListener(BindTool.Bind(self.OnClickCancelIma, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))
	self.node_list["TxtTitle"].text.text = Language.Common.Huanhua

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	RemindManager.Instance:Fire(RemindName.SpiritHuanHua)

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.HuanHuaRefreshCell, self)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerTxt"])
	self:Flush()
end

function SpiritHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	local callback = function ()
		UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		UIScene:SetTerraceBg(nil, nil, {position = Vector3(-145, -272, 0)}, nil)

		self:OpenCallBack()
	end
	UIScene:ChangeScene(self, callback)
end

function SpiritHuanHuaView:__delete()

end

function SpiritHuanHuaView:CloseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SpiritHuanHuaView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.fight_text = nil
end

function SpiritHuanHuaView:OpenCallBack()
	self:Flush()
	-- self.index = 1
	self:SetModleRestAni()
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:UITween()

	local cur_huanhua_list = SpiritData.Instance:GetCurHuanHuaList()
	self.index = cur_huanhua_list[1] and cur_huanhua_list[1].active_image_id + 1 or 1
	self:SetModle(self.index)

end

function SpiritHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function SpiritHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self.res_id = 0
	end
end

function SpiritHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function SpiritHuanHuaView:OnClickCancelIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, -1, "")
end

function SpiritHuanHuaView:OnClickActivate()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, self.index - 1, "")
end

function SpiritHuanHuaView:OnClickUseIma()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PHANTOM, 0, 0, 0, self.index - 1, "")
end

--点击目标战力
function SpiritHuanHuaView:ClickSuperPower()
	local data = SpiritData.Instance:GetSpecialHuanHuaShowData(self.index - 1)
	TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
end

function SpiritHuanHuaView:OnClickUpGrade()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPPHANTOM, 0, 0, 0, self.index - 1, "")
end

function SpiritHuanHuaView:GetNumberOfCells()
	-- return SpiritData.Instance:GetMaxSpiritHuanhuaImage()
	return #SpiritData.Instance:GetCurHuanHuaList()
end

function SpiritHuanHuaView:HuanHuaRefreshCell(cell, data_index)
	local huanhua_cell = self.cell_list[cell]
	-- local remove_list = SpiritData.Instance:GetSpiritHuanhuaRemoveList()
	local remove_list = SpiritData.Instance:GetCurHuanHuaList()
	if remove_list == nil and remove_list[data_index + 1] == nil then
		return
	end
	local index = remove_list[data_index + 1].active_image_id
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_level = spirit_info.phantom_level_list[index]

	if index >= GameEnum.JINGLING_PTHANTOM_MAX_TYPE then
		huanhua_level = spirit_info.phantom_level_list_new[index - GameEnum.JINGLING_PTHANTOM_MAX_TYPE]
	end

	if huanhua_cell == nil then
		huanhua_cell = SpiritHuanHuaList.New(cell.gameObject)
		self.cell_list[cell] = huanhua_cell
	end

	huanhua_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	local image_cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(index, huanhua_level)
	local huanhua_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[index + 1]
	local is_show = SpiritData.Instance:CanHuanhuaUpgradeList()[index] ~= nil
	huanhua_cell:SetData(huanhua_cfg, is_show, remove_list[data_index + 1].active_image_id)
	huanhua_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, index + 1, image_cfg, huanhua_cell))
	huanhua_cell:SetHighLight(self.index == index + 1)
end

function SpiritHuanHuaView:OnClickItemCell(index, data, huanhua_cell)
	self:SetSelectAttr(index)
	self.index = index
	self:SetButtonState(index)
	self:SetModle(index)
	huanhua_cell:SetHighLight(self.index == index)
end

function SpiritHuanHuaView:SetModleRestAni()
	if self.time_quest then
		return
	end
	self:PlayModleAction()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self:PlayModleAction()
	end, 10)
end

function SpiritHuanHuaView:PlayModleAction()
	if UIScene.role_model then
		local call_back = function(model, obj)
			if obj then
				model:SetTrigger(ANIMATOR_PARAM.REST)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
	end
end

function SpiritHuanHuaView:SetSelectAttr(index)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local huanhua_level = spirit_info.phantom_level_list[index - 1]
	local huanhua_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[index]
	-- if index > 10 then
	-- 	huanhua_level = spirit_info.phantom_level_list_new[index - 11]
	-- end
	index = index or self.index

	local client_huanhua_level = huanhua_level >= 0 and huanhua_level or 0
	local data = SpiritData.Instance:GetSpiritHuanhuaCfgById(index - 1, client_huanhua_level)
	local item_cfg = ItemData.Instance:GetItemConfig(data.stuff_id)
	local attr_list = CommonDataManager.GetAttributteNoUnderline(data, true)

	local attr0 = SpiritData.Instance:GetSpiritHuanhuaCfgById(index - 1, client_huanhua_level)
	local attr1 = SpiritData.Instance:GetSpiritHuanhuaCfgById(index - 1, client_huanhua_level + 1)
	local max_grade = SpiritData.Instance:GetMaxSpiritHuanhuaLevelById(index - 1)
	self:SetAttr(client_huanhua_level, attr0, attr1, max_grade, data.image_id)

	local is_show_super = SpiritData.Instance:IsShowSuperPower(index - 1)
	local is_active_super = SpiritData.Instance:GetStarIsShowSuperPower(index - 1)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local need_reach_level = SpiritData.Instance:GetActiveSuperPowerNeedLevel(index - 1)
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	
	local count = ItemData.Instance:GetItemNumInBagById(data.stuff_id)
	if count < data.stuff_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end

	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. huanhua_cfg.image_name .. "</color>"
	self.node_list["ZuoQiNameTxt"].text.text = "Lv." .. huanhua_level .. "·" .. name_str

	local is_max_lv = SpiritData.Instance:GetMaxSpiritHuanhuaLevelById(index - 1) <= huanhua_level
	self.node_list["ActivateTxt"].text.text = is_max_lv and ToColorStr("- / -", TEXT_COLOR.WHITE) or count .. " / " .. data.stuff_num


	local item_data = {item_id = data.stuff_id, is_bind = 0}
	self.item:SetData(item_data)
	self.item:ListenClick(BindTool.Bind(self.OnClickItem, self, item_data))


end

function SpiritHuanHuaView:SetModle(index)
	-- 形象展示
	local huanhua_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[index]
	if huanhua_cfg and huanhua_cfg.res_id and huanhua_cfg.res_id > 0 then
		if self.res_id ~= huanhua_cfg.res_id then
			local call_back = function(model, obj)
				if obj then
					local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
					transform.rotation = Quaternion.Euler(3, -172, 0)
					UIScene:SetCameraTransform(transform)

					model:SetTrigger(ANIMATOR_PARAM.REST)
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -15, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
			local bundle, asset = ResPath.GetSpiritModel(huanhua_cfg.res_id)
			local load_list = {{bundle, asset}}
			self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
					local bundle_list = {[SceneObjPart.Main] = bundle}
					local asset_list = {[SceneObjPart.Main] = asset}
					UIScene:ModelBundle(bundle_list, asset_list)
				end)

			self.res_id = huanhua_cfg.res_id
		end
	end
end

function SpiritHuanHuaView:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
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
				self.node_list["AddValue" .. index]:SetActive(true)
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
				self.node_list["AddValue" .. index]:SetActive(false)
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

	-- local active_grade, attr_type, attr_value = SpiritData.Instance:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	-- if active_grade and attr_type and attr_value then
	-- 	if special_image_grade < active_grade then
	-- 		local str = string.format(Language.Advance.OpenLevel, CommonDataManager.GetDaXie(active_grade - 1))
	-- 		self.node_list["TxtSpecialAttr"]:SetActive(true)
	-- 		self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
	-- 	else
	-- 		local str = ""
	-- 		local special_attr = nil
	-- 		for i = special_image_grade + 1, max_grade do
	-- 			local next_active_grade, next_attr_type, next_attr_value = SpiritData.Instance:GetHuanHuaSpecialAttrActiveType(i, special_index)
	-- 			if next_attr_value then
	-- 				if next_attr_value ~= attr_value then
	-- 					special_attr = next_attr_value - attr_value
	-- 					str = string.format(Language.Advance.NextLevelAttr, CommonDataManager.GetDaXie(next_active_grade - 1), special_attr / 100)
	-- 					break
	-- 				end
	-- 			end
	-- 		end
	-- 		self.node_list["TxtSpecialAttr"]:SetActive(true)
	-- 		self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
	-- 	end
	-- else
	-- 	self.node_list["TxtSpecialAttr"]:SetActive(false)
	-- end
	-- local capability = CommonDataManager.GetCapability(attr0)
	-- self.node_list["FightPowerTxt"].text.text = capability
end

function SpiritHuanHuaView:OnClickItem(data)
	if nil == data then return end
	TipsCtrl.Instance:OpenItem(data)
end

function SpiritHuanHuaView:SetButtonState(index)
	index = index or self.index
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	-- local bit_list = bit:d2b(spirit_info.special_img_active_flag)
	local bit_list = spirit_info.special_img_active_flag
	local huanhua_level = spirit_info.phantom_level_list[index - 1]
	-- if index > 10 then
	-- 	huanhua_level = spirit_info.phantom_level_list_new[index - 11]
	-- end
	self.node_list["ActivateBtn"]:SetActive(bit_list[index - 1] == 0)
	self.node_list["UseBtn"]:SetActive((bit_list[index - 1] == 1) and spirit_info.phantom_imageid ~= (index - 1))
	self.node_list["UpGradeButton"]:SetActive(bit_list[index - 1] == 1)
	self.node_list["BtnZhaoHui"]:SetActive(spirit_info.phantom_imageid == (index - 1))
	
	local is_max_lv = SpiritData.Instance:GetMaxSpiritHuanhuaLevelById(index - 1) <= huanhua_level
	UI:SetButtonEnabled(self.node_list["UpGradeButton"], not is_max_lv)
	if is_max_lv then
		self.node_list["TxtUpGradeBtn"].text.text = Language.JingLing.MaxLv
	else
		self.node_list["TxtUpGradeBtn"].text.text = Language.JingLing.BtnTextSJ
	end
end

function SpiritHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = 0
end

function SpiritHuanHuaView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" and v and v.item_id then
			local cfg = SpiritData.Instance:GetSpiritHuanConfigByItemId(v.item_id)
			self.index = cfg and (cfg.type + 1) or self.index
		elseif k == "all" and v and v.id then
			local index, num = SpiritData.Instance:CanHuanhuaIndexByImageId(v.id)
			if index then
				self.index = index + 1
				local cfg_list = SpiritData.Instance:GetCurHuanHuaList()
				num = num > 5 and num or num - 1
				self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
				self:SetModle(self.index)
			end
		end
	end
	
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
	
	self:SetSelectAttr(self.index)
	self:SetButtonState(self.index)
	-- self:SetModle(self.index)
end

function SpiritHuanHuaView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function SpiritHuanHuaView:UITween()
	UITween.MoveShowPanel(self.node_list["ListFrame"], Vector3(-250, -365.6, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(760, -20, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["TopPanel"], Vector3(0, 250, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(0, -250, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnReturn"], Vector3(-67, 250, 0), 0.7)
end

----------------------------------------------------------------------------------------------------
-- 仙宠幻化形象列表
SpiritHuanHuaList = SpiritHuanHuaList or BaseClass(BaseRender)

function SpiritHuanHuaList:__init(instance)
end

function SpiritHuanHuaList:ListenClick(handler)
	self.node_list["SpiritHuanHuaItem"].toggle:AddClickListener(handler)
end

function SpiritHuanHuaList:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function SpiritHuanHuaList:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function SpiritHuanHuaList:SetData(data, is_show, index)
	if nil == data then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		return
	end

	local info_list = SpiritData.Instance:GetSpiritInfo()
	if nil == info_list then
		return
	end

	local active_flag = info_list.special_img_active_flag
	if nil == active_flag then
		return
	end

	local bit_list = active_flag

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["IconImg"].image:LoadSprite(bundle, asset)
	local is_active = 1 == bit_list[index]
	UI:SetGraphicGrey(self.node_list["IconImg"], not is_active)
	self.node_list["ImgYiHuanHua"]:SetActive(is_active and (index == info_list.phantom_imageid))

	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. data.image_name .. "</color>"
	self.node_list["NameTxt"].text.text = name_str
	self.node_list["RedPointImg"]:SetActive(is_show)
end
