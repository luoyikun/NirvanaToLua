ShengongHuanHuaView = ShengongHuanHuaView or BaseClass(BaseView)

local TWEEN_TIME = 0.5
function ShengongHuanHuaView:__init()
	self.ui_config = {
		{"uis/views/goddess_prefab", "ModelDragLayer"},
		{"uis/views/goddess_prefab", "ShengongHuanHuaView"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid
	
	self.play_audio = true
	self.full_screen = true
	self.item_id = 0
	self.index = 1
	self.shengong_special_image = nil
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil

	self.prefab_preload_id = 0
	self.def_index = TabIndex.mount_huan_hua
end

function ShengongHuanHuaView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.Huanhua, bundle = "uis/images_atlas", asset = "tab_icon_goddess_halo", tab_index = TabIndex.mount_huan_hua, remind_id = RemindName.Goddess_ShengongHuanhua},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ShowIndex, self))

	self.node_list["BtnActivate"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["UpGradeButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["UseImageButton"].button:AddClickListener(BindTool.Bind(self.OnClickUseIma, self))
	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.ClickRecharge, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))

	self.node_list["RotateEventTrigger"].event_trigger_listener:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.node_list["TxtTitle"].text.text = Language.Goddess.TabbarName[2]

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	RemindManager.Instance:Fire(RemindName.Goddess_ShengongHuanhua)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPowerNum"])

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShengongNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShengongCell, self)
	self.cell_list = {}

	if self.player_data_change == nil then
		self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change)
		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo.gold)
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo.bind_gold)
	end
end

function ShengongHuanHuaView:ReleaseCallBack()
	self.fight_text = nil
	if PlayerData.Instance and self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
	end
	self.player_data_change = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	-- 清理变量和对象
	self.shengong_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.ming_zhong = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.shengong_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.is_show_skill_desc = nil
	self.img_num = nil
end

function ShengongHuanHuaView:__delete()
	self.index = 1
	self.item_id = nil
	self.shengong_special_image = nil
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShengongHuanHuaView:GetShengongNumberOfCells()
	return ShengongData.Instance:GetMaxSpecialImage()
end

function ShengongHuanHuaView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShengongHuanHuaView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GoddessData.HuanhuaTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["LeftContent"], GoddessData.HuanhuaTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GoddessData.HuanhuaTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GoddessData.HuanhuaTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ShengongHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ShengongHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self.grade = nil
		self.res_id = nil
		self.used_imageid = nil
	end
end

-- 玩家元宝改变时
function ShengongHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function ShengongHuanHuaView:RefreshShengongCell(cell, cell_index)
	-- local images_id = cell_index == 1 and cell_index + 2 or cell_index + 1
	local special_image = ShengongData.Instance:GetSpecialImageList()
	local images_id = special_image[cell_index + 1] and special_image[cell_index + 1].image_id or cell_index + 1
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(images_id)
	if nil == shengong_special_image then return end
	local shengong_cell = self.cell_list[cell]
	if shengong_cell == nil then
		shengong_cell = ShengongHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = shengong_cell
	end
	shengong_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	shengong_cell:SetHighLight(self.index == images_id)
	local data = {}
	data.head_id = shengong_special_image.head_id
	data.image_name = shengong_special_image.image_name
	data.item_id = shengong_special_image.item_id
	data.index = images_id
	data.is_show = ShengongData.Instance:CanHuanhuaUpgrade() == (images_id)
	shengong_cell:SetData(data)
	shengong_cell:ListenClick(BindTool.Bind( handler or self.OnClickListCell, self, shengong_special_image, images_id, shengong_cell))
end

function ShengongHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShengongHuanHuaView:CloseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:OpenCallBack()
	local special_image = ShengongData.Instance:GetSpecialImageList()
	self.index = special_image[1] and special_image[1].image_id or 1
	self:DoPanelTweenPlay()
	self:Flush("shengonghuanhua")
end

function ShengongHuanHuaView:ShowIndexCallBack(index, index_nodes)
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

--点击激活按钮
function ShengongHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(self.index)
	if nil == shengong_special_image then return end
	self.item_id = shengong_special_image.item_id
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

--点击超级战力按钮
function ShengongHuanHuaView:ClickSuperPower()
	local shengong_special_cfg = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
	local image_id = shengong_special_cfg and shengong_special_cfg.image_id or 0
	local index = image_id or 0
	local data = ShengongData.Instance:GetSpecialHuanHuaShowData(index)
	TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
end

--点击升级按钮
function ShengongHuanHuaView:OnClickUpGrade()
	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= ShengongData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	ShengongHuanHuaCtrl.Instance:ShengongSpecialImaUpgrade(self.index)
end

--点击使用当前形象
function ShengongHuanHuaView:OnClickUseIma()
	ShengongCtrl.Instance:SendUseShengongImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function ShengongHuanHuaView:OnClickListCell(shengong_special_data, index, shengong_cell)
	self.shengong_special_image = shengong_special_data
	shengong_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = shengong_special_data.item_id
	self:SetSpecialImageAttr(shengong_special_data, index)
end

--获取激活坐骑符数量
function ShengongHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end
	return count
end

function ShengongHuanHuaView:SetSpecialImageAttr(shengong_special_data, index)
	if shengong_special_data == nil then
		return
	end
	local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_data.image_id)
	local image_cfg = ShengongData.Instance:GetSpecialImageCfg(index)
	local info_list = ShengongData.Instance:GetShengongInfo()
	local bit_list = ShengongData.Instance:GetBitFlag()

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)

	if self.res_id ~= shengong_special_data.res_id then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.halo_res_id = shengong_special_data.res_id or -1
		self.res_id = shengong_special_data.res_id
		self:SetModel(info)
	end

	self.used_imageid = info_list.used_imageid
	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
		self.node_list["TxtShengGongName"].text.text = "Lv." .. attr_cfg.grade .. " " .. "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..shengong_special_data.image_name.."</color>"
		local num = self:GetHaveProNum(shengong_special_data.item_id, upgrade_cfg.stuff_num)
		self.node_list["TxtNeedPro"].text.text = tostring(num) .. " / " .. upgrade_cfg.stuff_num or 1 -- 这里要改
	end

	local special_image_grade = ShengongData.Instance:GetSingleSpecialImageGrade(shengong_special_data.image_id)
	local attr0 = ShengongData.Instance:GetSpecialImageUpgradeInfo(index)
	local attr1 = ShengongData.Instance:GetSpecialImageUpgradeInfo(index, special_image_grade, true)
	local max_grade = ShengongData.Instance:GetSpecialImageMaxUpLevelById(shengong_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, index)

	local is_show_super = ShengongData.Instance:IsShowSuperPower(shengong_special_data.image_id)
	local is_active_super = ShengongData.Instance:GetStarIsShowSuperPower(shengong_special_data.image_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local need_reach_level = ShengongData.Instance:GetActiveSuperPowerNeedLevel(shengong_special_data.image_id)
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end
	

	local data = {item_id = shengong_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
	self:IsGrayUpgradeButton(self.index)
end

function ShengongHuanHuaView:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
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

	local active_grade, attr_type, attr_value = ShengongData.Instance:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	if active_grade and attr_type and attr_value then
		if special_image_grade < active_grade then
			local str = string.format(Language.Advance.OpenLevel, active_grade)
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%") .. str
		else
			local str = ""
			local special_attr = nil
			for i = special_image_grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = ShengongData.Instance:GetHuanHuaSpecialAttrActiveType(i, special_index)
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
	-- local capability = CommonDataManager.GetCapability(attr0)
	-- self.fight_text.text.text = capability
end

function ShengongHuanHuaView:GetIndex()
	return self.index
end

--设置激活按钮显示和隐藏
function ShengongHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = ShengongData.Instance:GetShengongInfo()
	local bit_list = ShengongData.Instance:GetBitFlag()

	self.node_list["BtnActivate"]:SetActive(0 == bit_list[image_id]) 
	self.node_list["UseImageButton"]:SetActive(0 ~= bit_list[image_id])
	self.node_list["ImgUseImage"]:SetActive(0 ~= bit_list[image_id])

	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.node_list["UseImageButton"]:SetActive(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID) and 0 ~= bit_list[image_id])
		self.node_list["ImgUseImage"]:SetActive(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID) and 0 ~= bit_list[image_id] )
	else
		self.node_list["UseImageButton"]:SetActive(0 ~= bit_list[image_id])
		self.node_list["ImgUseImage"]:SetActive(false)
	end
end

--设置升级按钮显示和隐藏
function ShengongHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = ShengongData.Instance:GetSpecialImageUpgradeCfg()
	local bit_list = ShengongData.Instance:GetBitFlag()
	for k, v in pairs(special_img_up) do
		if v.special_img_id == image_id then
			self.node_list["UpGradeButton"]:SetActive(0 ~= bit_list[image_id])
			break
		else
			self.node_list["UpGradeButton"]:SetActive(false)
		end
	end
end

--升级按钮是否置灰
function ShengongHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(index)
	if nil == shengong_special_image then return end
	local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_image.image_id)
	if upgrade_cfg.grade < ShengongData.Instance:GetSpecialImageMaxUpLevelById(shengong_special_image.image_id) then
		UI:SetButtonEnabled(self.node_list["UpGradeButton"], true)
		self.node_list["TxtShengGongUpgrade"].text.text = Language.Common.UpGrade
	else
		UI:SetButtonEnabled(self.node_list["UpGradeButton"], false)
		self.node_list["TxtNeedPro"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
		self.node_list["TxtShengGongUpgrade"].text.text = Language.Common.YiManJi
	end
end

function ShengongHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "shengonghuanhua" or v.id then
			if v and v.id then
				local index , num = ShengongData.Instance:CanHuanhuaIndexByImageId(v.id)
				if index then
					self.index = index
					local max_num = ShengongData.Instance:GetMaxSpecialImage()
					num = num > 5 and num or num - 1
					self.node_list["ListView"].scroller:ReloadData(num / max_num)
				end
			end

			local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(self.index)
			if nil == shengong_special_image then return end
			local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_image.image_id)
			if upgrade_cfg and next(upgrade_cfg) then
				local info_list = ShengongData.Instance:GetShengongInfo()
				local bit_list = ShengongData.Instance:GetBitFlag()
				if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[self.index]) or (self.used_imageid ~= info_list.used_imageid) then
					self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
					self:IsShowActivate(self.index)
					self:IsShowUpGrade(self.index)
					self:SetSpecialImageAttr(shengong_special_image, self.index)
					self:IsGrayUpgradeButton(self.index)
					self.node_list["ListView"].scroller:RefreshActiveCellViews()
				end
			end
		end
	end
end

function ShengongHuanHuaView:SetModel(info)
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localPosition = Vector3(-0.3, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local asset, bundle = ResPath.GetGoddessHaloModel(info.halo_res_id)
	local load_list = {{asset, bundle}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			UIScene:SetGoddessModelResInfo(info)
		end)

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if UIScene.role_model then
				UIScene.role_model:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end
------------------------

ShengongHuanHuaCell = ShengongHuanHuaCell or BaseClass(BaseRender)

function ShengongHuanHuaCell:__init()

end

function ShengongHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	local bundle, asset = ResPath.GetItemIcon(data.item_id)

	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"

	self.node_list["TxtName"].text.text = name_str

	self.node_list["ImgRemind"]:SetActive(data.is_show)
	self:ShowLabel(data, data.index)
end

function ShengongHuanHuaCell:ListenClick(handler)

	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler)
end

function ShengongHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ShengongHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ShengongHuanHuaCell:ShowLabel(data, image_id)
	if image_id == nil then
		return
	end
	local info_list = ShengongData.Instance:GetShengongInfo()
	local bit_list = ShengongData.Instance:GetBitFlag()
	self.node_list["ImgYiHuanHua"]:SetActive(0 ~= bit_list[image_id])
	UI:SetGraphicGrey(self.node_list["ImgIcon"], 0 == bit_list[image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.node_list["ImgYiHuanHua"]:SetActive(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.node_list["ImgYiHuanHua"]:SetActive(false)
	end
end
