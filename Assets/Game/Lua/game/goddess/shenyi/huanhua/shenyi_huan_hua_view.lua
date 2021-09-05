ShenyiHuanHuaView = ShenyiHuanHuaView or BaseClass(BaseView)
local FIX_SHOW_TIME = 8
local TWEEN_TIME = 0.5
function ShenyiHuanHuaView:__init()
	self.ui_config = {
		{"uis/views/goddess_prefab", "ModelDragLayer"},
		{"uis/views/goddess_prefab", "ShenyiHuanHuaView"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	
	self.play_audio = true
	self.full_screen = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.shenyi_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	self.prefab_preload_id = 0
	self.must_pro_num = {}
	self.must_pro_num[0] = 0
	self.must_pro_num[1] = 1
	self.def_index = TabIndex.mount_huan_hua
end

function ShenyiHuanHuaView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = "uis/images_atlas", asset = "tab_icon_goddess_fazheng", tab_index = TabIndex.mount_huan_hua, remind_id = RemindName.Goddess_ShenyiHuanhua },
	}

	self.tabbar = TabBarOne.New()
	self.node_list["TxtTitle"].text.text = Language.Goddess.TabbarName[3]
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ShowIndex, self))
	RemindManager.Instance:Fire(RemindName.Goddess_ShenyiHuanhua)

	self.shenyi_display = self.node_list["ShenyiDisplay"]

	self.have_pro_num = self.node_list["TxtNeedPro"]
	self.need_pro_num = self.node_list["TxtNeedPro"]
	self.button_text = self.node_list["TxtShengYiUpgrade"]

	self.gong_ji = self.node_list["TxtGongJi"]
	self.fang_yu = self.node_list["TxtFangYu"]
	self.sheng_ming = self.node_list["TxtMaxHP"]

	self.shenyi_name = self.node_list["TxtShengYiName"]
	self.show_upgrade_btn = self.node_list["UpGradeButton"]
	self.show_activate_btn = self.node_list["BtnActivate"]
	self.show_use_ima_btn = self.node_list["UseImageButton"]
	self.show_use_image = self.node_list["ImgUseImage"]

	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["BtnActivate"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["UpGradeButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["UseImageButton"].button:AddClickListener(BindTool.Bind(self.OnClickUseIma, self))
	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))

	self.node_list["RotateEventTrigger"].event_trigger_listener:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.list_view = self.node_list["ListView"]
	self.upgrade_btn = self.node_list["UpGradeButton"]
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShenyiNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShenyiCell, self)
	self.cell_list = {}

	if self.player_data_change == nil then
		self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change)
		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo.gold)
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo.bind_gold)
	end
end

function ShenyiHuanHuaView:ReleaseCallBack()
	self.fight_text = nil
	self.must_pro_num = {}
	if PlayerData.Instance and self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
	end
	self.player_data_change = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	self.shenyi_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.shenyi_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.list_view = nil
	self.upgrade_btn = nil
end

function ShenyiHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.shenyi_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShenyiHuanHuaView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenyiHuanHuaView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ShenyiHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ShenyiHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self.grade = nil
		self.res_id = nil
		self.used_imageid = nil
	end
end

function ShenyiHuanHuaView:GetShenyiNumberOfCells()
	return #self.special_img_list
end

function ShenyiHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	local callback = function ()
		UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		UIScene:SetTerraceBg(nil, nil, {position = Vector3(-134, -275, 0)}, nil)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
		UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))

		self:OpenCallBack()
	end
	UIScene:ChangeScene(self, callback)
end

function ShenyiHuanHuaView:RefreshShenyiCell(cell, cell_index)
	local shenyi_cell = self.cell_list[cell]
	if shenyi_cell == nil then
		shenyi_cell = ShenyiHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = shenyi_cell
	end

	shenyi_cell:SetToggleGroup(self.list_view.toggle_group)
	shenyi_cell:SetHighLight(self.index == self.special_img_list[cell_index + 1].image_id)
	shenyi_cell:SetData(self.special_img_list[cell_index + 1])
	shenyi_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, self.special_img_list[cell_index + 1], self.special_img_list[cell_index + 1].image_id, shenyi_cell))
end

function ShenyiHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShenyiHuanHuaView:OpenCallBack()
	self.special_img_list = ShenyiData.Instance:GetHuanHuaCfgList()
	self:DoPanelTweenPlay()
	self.index = self.special_img_list[1].image_id
	self:Flush("shenyihuanhua")
end

function ShenyiHuanHuaView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.HuanhuaTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.HuanhuaTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GoddessData.HuanhuaTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GoddessData.HuanhuaTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

-- 玩家元宝改变时
function ShenyiHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

--点击超级战力按钮
function ShenyiHuanHuaView:ClickSuperPower()
	local shenyi_special_cfg = ShenyiData.Instance:GetSpecialImageCfg(self.index)
	local image_id = shenyi_special_cfg and shenyi_special_cfg.image_id or 0
	local index = image_id or 0
	local data = ShenyiData.Instance:GetSpecialHuanHuaShowData(index)
	TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
end

--点击激活按钮
function ShenyiHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local shenyi_special_image = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	self.item_id = shenyi_special_image[self.index].item_id
	for k, v in pairs(data_list) do
		if v.item_id == self.item_id then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(self.item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	return
end

--点击升级按钮
function ShenyiHuanHuaView:OnClickUpGrade()
	local attr_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= ShenyiData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
			return
		end
		if ItemData.Instance:GetItemNumInBagById(attr_cfg.stuff_id) < attr_cfg.stuff_num then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[attr_cfg.stuff_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(attr_cfg.stuff_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(attr_cfg.stuff_id, 2)
				return
			end

			local func = function(stuff_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, attr_cfg.stuff_id, nil, attr_cfg.stuff_num)
			return
		end
	end
	ShenyiHuanHuaCtrl.Instance:ShenyiSpecialImaUpgrade(self.index)
end

-- 点击使用当前形象
function ShenyiHuanHuaView:OnClickUseIma()
	ShenyiCtrl.Instance:SendUseShenyiImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function ShenyiHuanHuaView:OnClickListCell(shenyi_special_data, index, shenyi_cell)
	self.shenyi_special_image = shenyi_special_data
	shenyi_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = shenyi_special_data.item_id
	self:SetSpecialImageAttr(shenyi_special_data, index)
end

-- 获取激活神翼符数量
function ShenyiHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end
	self.must_pro_num[0] = count
end

function ShenyiHuanHuaView:SetSpecialImageAttr(shenyi_special_data, index)
	if shenyi_special_data == nil then
		return
	end
	local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_data.image_id)
	local image_cfg = ShenyiData.Instance:GetSpecialImageCfg(index)
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local bit_list = ShenyiData.Instance:GetBitFlag()

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	if self.res_id ~= image_cfg.res_id then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.fazhen_res_id = tonumber(image_cfg.res_id)

		self:SetModel(info)
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid

	local attr_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		self.shenyi_name.text.text = string.format("Lv.%s",attr_cfg.grade) .. " " .. "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..shenyi_special_data.image_name.."</color>"
		self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
		self.must_pro_num[1] = upgrade_cfg.stuff_num or 1
		self:GetHaveProNum(shenyi_special_data.item_id, upgrade_cfg.stuff_num)
		self.need_pro_num.text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
	end

	local special_image_grade = ShenyiData.Instance:GetSingleSpecialImageGrade(shenyi_special_data.image_id)
	local attr0 = ShenyiData.Instance:GetSpecialImageUpgradeInfo(index)
	local attr1 = ShenyiData.Instance:GetSpecialImageUpgradeInfo(index, special_image_grade, true)
	local max_grade = ShenyiData.Instance:GetSpecialImageMaxUpLevelById(shenyi_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, index)

	local data = {item_id = shenyi_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	local is_show_super = ShenyiData.Instance:IsShowSuperPower(shenyi_special_data.image_id)
	local is_active_super = ShenyiData.Instance:GetStarIsShowSuperPower(shenyi_special_data.image_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local need_reach_level = ShenyiData.Instance:GetActiveSuperPowerNeedLevel(shenyi_special_data.image_id)
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
	self:IsGrayUpgradeButton(self.index)
end

function ShenyiHuanHuaView:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
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

	local active_grade, attr_type, attr_value = ShenyiData.Instance:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	if active_grade and attr_type and attr_value then
		if special_image_grade < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = special_image_grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = ShenyiData.Instance:GetHuanHuaSpecialAttrActiveType(i, special_index)
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

--设置激活按钮显示和隐藏
function ShenyiHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local bit_list = ShenyiData.Instance:GetBitFlag()
	self.show_activate_btn:SetActive(0 == bit_list[image_id]) 
	self.show_use_ima_btn:SetActive(0 ~= bit_list[image_id])
	self.show_use_image:SetActive(0 ~= bit_list[image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetActive(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
		self.show_use_image:SetActive(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.show_use_ima_btn:SetActive(0 ~= bit_list[image_id])
		self.show_use_image:SetActive(false)
	end
end

--设置升级按钮显示和隐藏
function ShenyiHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = ShenyiData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local bit_list = ShenyiData.Instance:GetBitFlag()
	for k, v in pairs(special_img_up) do
		if v.special_img_id == image_id then
			self.show_upgrade_btn:SetActive(0 ~= bit_list[image_id])
			break
		else
			self.show_upgrade_btn:SetActive(false)
		end
	end
end

-- 升级按钮是否置灰
function ShenyiHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local shenyi_special_image = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_image[index].image_id)
	if upgrade_cfg.grade < ShenyiData.Instance:GetSpecialImageMaxUpLevelById(shenyi_special_image[index].image_id) then
		UI:SetButtonEnabled(self.upgrade_btn, true)
		self.button_text.text.text = Language.Common.UpGrade
	else
		UI:SetButtonEnabled(self.upgrade_btn, false)
		self.node_list["TxtNeedPro"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
		self.button_text.text.text = Language.Common.YiManJi
	end
end

function ShenyiHuanHuaView:CheckShowSkillDesc()
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local bit_list = ShenyiData.Instance:GetBitFlag()

	local active_num = 0
	local special_image = ShenyiData.Instance:GetSpecialImagesCfg()
	for k, v in pairs(special_image) do
		if 1 == bit_list[v.image_id] then
			active_num = active_num + 1
		end
	end

	local fuling_skill_cfg = ImageFuLingData.Instance:GetImgFuLingSkillLevelCfg(IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI, 1)
	local diff_num = fuling_skill_cfg.img_count_limit - active_num
end

function ShenyiHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "shenyihuanhua" or v.id then
			if v and v.id then
				local index , num = ShenyiData.Instance:CanHuanhuaIndexByImageId(v.id)
				if index then
					self.index = index
					local max_num = #ShenyiData.Instance:GetHuanHuaCfgList()
					num = num > 5 and num or num - 1
					self.node_list["ListView"].scroller:ReloadData(num / max_num)
				end
			end
			self:CheckShowSkillDesc()
			local shenyi_special_image = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
			local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_image[self.index].image_id)
			local info_list = ShenyiData.Instance:GetShenyiInfo()
			local bit_list = ShenyiData.Instance:GetBitFlag()
			if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[self.index]) or (self.used_imageid ~= info_list.used_imageid) then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(self.index)
				self:IsShowUpGrade(self.index)
				self:SetSpecialImageAttr(shenyi_special_image[self.index], self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

function ShenyiHuanHuaView:SetModel(info)
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localPosition = Vector3(-0.3, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local asset, bundle = ResPath.GetGoddessFaZhenModel(info.fazhen_res_id)
	local load_list = {{asset, bundle}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			UIScene:SetGoddessModelResInfo(info, true)
			self:CalToShowAnim(true)
		end)
end

function ShenyiHuanHuaView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			if timer <= 6 then
				self:PlayAnim(is_change_tab)
				is_change_tab = false
				timer = GameEnum.GODDESS_ANIM_LONG_TIME
				GlobalTimerQuest:CancelQuest(self.time_quest)
			end
		end
	end, 0)

end

function ShenyiHuanHuaView:PlayAnim(is_change_tab)
	local is_change_tab = is_change_tab
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
end

----------------------------------------------------------------------------------------
ShenyiHuanHuaCell = ShenyiHuanHuaCell or BaseClass(BaseRender)

function ShenyiHuanHuaCell:__init()

end

function ShenyiHuanHuaCell:SetData(data)
	if data == nil then
		return
	end

	local bundle, asset = ResPath.GetItemIcon(data.item_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then 
		return
	end

	local huanhua_cfg = ShenyiData.Instance:GetHuanHuaCfgInfo(data.image_id)
	if nil == huanhua_cfg then
		return
	end

	self.node_list["TxtName"].text.text = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" ..  data.image_name  .. "</color>"

	local is_show_remind = false
	if ShenyiData.Instance:GetHuanHuaGrade(data.image_id) < ShenyiData.Instance:GetMaxSpecialImageCfgById(data.image_id) and
		ItemData.Instance:GetItemNumIsEnough(data.item_id, huanhua_cfg.stuff_num) then
		is_show_remind = true
	end

	self.node_list["ImgRemind"]:SetActive(is_show_remind)

	self:ShowLabel(data.image_id)
end

function ShenyiHuanHuaCell:ListenClick(handler)
	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler)
end

function ShenyiHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ShenyiHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ShenyiHuanHuaCell:ShowLabel(image_id)
	if image_id == nil then
		return
	end

	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local bit_list = ShenyiData.Instance:GetBitFlag()
	
	self.node_list["ImgYiHuanHua"]:SetActive(0 ~= bit_list[image_id])
	UI:SetGraphicGrey(self.node_list["ImgIcon"], 0 == bit_list[image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.node_list["ImgYiHuanHua"]:SetActive(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.node_list["ImgYiHuanHua"]:SetActive(false)
	end
end
