AppearanceEquipView = AppearanceEquipView or BaseClass(BaseView)

function AppearanceEquipView:__init()
	self.ui_config = {
		{"uis/views/appearance_prefab", "ModelDragLayer"}, 
		{"uis/views/appearance_prefab", "EquipContent"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		
	}
	self.camera_mode = UICameraMode.UICameraMid
	self.play_audio = true
	self.full_screen = true
	self.now_show_index = -1
	self.select_item_index = 0
	self.attr_var_list = {}
end

function AppearanceEquipView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(400 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Zhuangbei"] , Vector3(-120, 0 , 0 ) , MOVE_TIME )
end

function AppearanceEquipView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.item_show ~= nil then
		self.item_show:DeleteMe()
		self.item_show = nil
	end

	for _, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	self.equip_item_var_list = nil
	self.item_cell_toggle_group = nil
	self.attr_var_list = {}
	self.fight_text = nil
	self.remind_func = nil
end

function AppearanceEquipView:__delete()

end

function AppearanceEquipView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.ZhuangBei, bundle = "uis/images_atlas", asset = "shengxiao_equip", tab_index = TabIndex.appearance_equip_view, remind_id = RemindName.AppearanceEquip},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ShowIndex, self))
	self.node_list["TxtTitle"].text.text = Language.Title.JinJie

	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["UpgradeBtn"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list["BtnPreView"].button:AddClickListener(BindTool.Bind(self.OnClickAttrPreview, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))

	UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
	UIScene:SetTerraceBg(nil, nil, {position = Vector3(-140, -275, 0)})

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.item_cell_hl = {}
	self.item_cell_list = {}
	self.equip_item_var_list = {}
	self.item_cell_toggle_group = self.node_list["ItemCellToggleGroup"]
	for i = 1, 4 do
		self.equip_item_var_list[i] = {
			remind = self.node_list["ImgEquipRemind"..i],
			level = self.node_list["TxtEquipLevel"..i],
		}

		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemCellRoot"..i])
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		item:SetToggleGroup(self.item_cell_toggle_group.toggle_group)
		self.item_cell_list[i] = item

		self.node_list["Normal" .. i].button:AddClickListener(BindTool.Bind(self.OnClickItemNormal, self, i))
		self.item_cell_hl[i] = self.node_list["Select" .. i]
	end

	self.attr_var_list = {}
	for i = 1, 3 do
		self.attr_var_list[i] = {
			text = self.node_list["TxtAttr" .. i],
			show = self.node_list["NodeAttr" .. i],
			next_attr_active = self.node_list["NodeNextAtrr" .. i],
			next_attr_txt = self.node_list["TxtNextAtrr" .. i]
		}
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])

	self.item_show = ItemCell.New()
	self.item_show:SetInstanceParent(self.node_list["ItemCellShow"])
end

function AppearanceEquipView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(TabIndex.appearance_equip_view)
	AppearanceData.Instance:SetEquipType(index)
	self:UIsMove()
	if self.now_show_index < 0 then
		self.now_show_index = index
	end

	self.temp_res_id = 0
	local callback = function ()
		self:Flush()
	end
	UIScene:ChangeScene(self, callback)
end

function AppearanceEquipView:OpenCallBack()
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self.select_item_index = 0
	self:FlushItemHL(self.select_item_index + 1)
	self:Flush()
	RemindManager.Instance:Fire(RemindName.AppearanceEquip)
end

function AppearanceEquipView:CloseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.now_show_index = -1
	self.temp_res_id = 0
	self.remind_func = nil
end

function AppearanceEquipView:OnFlush(param_list)
	self:SetNowInfo()
	self:SetModel()
	self:SetRightInfo()
	self:SetEquipItemInfo()
	self:FlushText()
end

function AppearanceEquipView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AppearanceEquipView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function AppearanceEquipView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AppearanceEquipView:OnClickAttrPreview()
	local attr_des = string.format(Language.MultiMount.PercentAttrDesList[self.now_show_index], (self.all_equip_percent_value / 100) .."%")
	self.special_equip_attr_list = {{attr_des = attr_des, show = self.equip_cfg and self.equip_cfg.add_percent > 0 and true or false}}
	TipsCtrl.Instance:ShowPreferredSizeAttrView(self.all_normal_equip_attr_list, self.special_equip_attr_list, 0)
end

function AppearanceEquipView:OnClickUpLevel()
	if nil == self.next_equip_cfg or not self.equip_cfg then return end
	local equip_level = self.info.equip_level_list[self.select_item_index] or 0
	if self.grade_info_cfg and self.grade_info_cfg.equip_level_toplimit then
		local equip_level_toplimit = self.grade_info_cfg.equip_level_toplimit --or equip_level_toplimit
		local info_grade = self.info.grade > self.equip_level_limit - 1 and self.info.grade or self.equip_level_limit -1
		if equip_level >= equip_level_toplimit and self.info.grade < self.max_level then
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.ReachGradeCanUpgrade, CommonDataManager.GetDaXie(info_grade)))
			return
		end
	end
	local item_data = self.equip_cfg.item or self.equip_cfg.uplevel_item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	if had_prop_num < item_data.num then
		-- 物品不足，弹出TIP框
		local stuff_item_id = item_data.item_id
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[stuff_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(stuff_item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end

	if self.now_show_index == TabIndex.appearance_lingtong then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_TONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)
	
	elseif self.now_show_index == TabIndex.appearance_flypet then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.FLY_PET, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)

	elseif self.now_show_index == TabIndex.appearance_lingqi then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_QI, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)

	elseif self.now_show_index == TabIndex.appearance_weiyan then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.WEI_YAN, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)

	elseif self.now_show_index == TabIndex.appearance_qilinbi then
		QilinBiCtrl.Instance:SendQiLinBiReq(QILINBI_OPERA_TYPE.QILINBI_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)

	elseif self.now_show_index == TabIndex.appearance_linggong then
		UpgradeCtrl.Instance:SendUpgradeReq(UPGRADE_TYPE.LING_GONG, UPGRADE_OPERA_TYPE.UPGRADE_OPERA_TYPE_EQUIP_UPGRADE, self.select_item_index)
	end
end

-- 点击装备格子
function AppearanceEquipView:OnClickItem(index)
	self.select_item_index = index - 1
	self:SetNowInfo()
	self:SetRightInfo()
	self:SetEquipItemInfo()
	self:FlushText()

	self.item_cell_list[index]:ShowHighLight(false)
	self:FlushItemHL(index)
end

function AppearanceEquipView:OnClickItemNormal(index)
	self:OnClickItem(index)
end

function AppearanceEquipView:FlushItemHL(index)
	for k, v in pairs(self.item_cell_hl) do
		if k == index then
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end
end

function AppearanceEquipView:SetNowInfo()
	self.all_equip_percent_value = 0
	self.grade_info_cfg = {}
	if self.now_show_index == TabIndex.appearance_lingtong then	-- 灵童装备
		self.info = LingChongData.Instance:GetLingChongInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(LingChongData.Instance.CalEquipRemind, LingChongData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(LingChongData.Instance.GetEquipInfoCfg, LingChongData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = LingChongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = LingChongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = LingChongData.Instance:GetLingChongMaxGrade()
		self.all_normal_equip_attr_list = LingChongData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = LingChongData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = LingChongData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.appearance_flypet then	-- 飞宠装备
		self.info = FlyPetData.Instance:GetFlyPetInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FlyPetData.Instance.CalEquipRemind, FlyPetData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FlyPetData.Instance.GetEquipInfoCfg, FlyPetData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FlyPetData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FlyPetData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = FlyPetData.Instance:GetFlyPetMaxGrade()
		self.all_normal_equip_attr_list = FlyPetData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = FlyPetData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FlyPetData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.appearance_lingqi then	-- 灵骑装备
		self.info = LingQiData.Instance:GetLingQiInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(LingQiData.Instance.CalEquipRemind, LingQiData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(LingQiData.Instance.GetEquipInfoCfg, LingQiData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = LingQiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = LingQiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = LingQiData.Instance:GetLingQiMaxGrade()
		self.all_normal_equip_attr_list = LingQiData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = LingQiData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = LingQiData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.appearance_weiyan then	-- 尾焰装备
		self.info = WeiYanData.Instance:GetWeiYanInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(WeiYanData.Instance.CalEquipRemind, WeiYanData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(WeiYanData.Instance.GetEquipInfoCfg, WeiYanData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = WeiYanData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = WeiYanData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = WeiYanData.Instance:GetWeiYanMaxGrade()
		self.all_normal_equip_attr_list = WeiYanData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = WeiYanData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = WeiYanData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.appearance_qilinbi then	-- 麒麟臂装备
		self.info = QilinBiData.Instance:GetQilinBiInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(QilinBiData.Instance.CalEquipRemind, QilinBiData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(QilinBiData.Instance.GetEquipInfoCfg, QilinBiData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = QilinBiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = QilinBiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = QilinBiData.Instance:GetQiLinBiMaxGrade()
		self.all_normal_equip_attr_list = QilinBiData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = QilinBiData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = QilinBiData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.appearance_linggong then	-- 灵弓装备
		self.info = LingGongData.Instance:GetLingGongInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(LingGongData.Instance.CalEquipRemind, LingGongData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(LingGongData.Instance.GetEquipInfoCfg, LingGongData.Instance)
		end

		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = LingGongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = LingGongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = LingGongData.Instance:GetLingGongMaxGrade()
		self.all_normal_equip_attr_list = LingGongData.Instance:GetEquipAttrSum()
		self.grade_info_cfg = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.info.grade) or {}
		self.equip_level_limit = LingGongData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = LingGongData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	end
end

function AppearanceEquipView:SetModel()
	if nil == self.info or nil == next(self.info) then return end

	self:SetLingChongModel()
	self:SetFlyPetModel()
	self:SetLingQiModel()
	self:SetWeiYanModel()
	self:SetQiLinBiModel()
	self:SetLingGongModel()
	UIScene:SetBackground()
	UIScene:SetTerraceBg(nil, nil, {position = Vector3(-140, -275, 0)}, nil)
end

function AppearanceEquipView:SetLingChongModel()
	if self.now_show_index ~= TabIndex.appearance_lingtong then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local lingchong_used_imageid = vo.appearance.lingchong_used_imageid
	local lingchong_res_id = LingChongData.Instance:GetResIdHByImageId(lingchong_used_imageid)

	if self.temp_res_id == lingchong_res_id then return end
	self.temp_res_id = lingchong_res_id
	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingchong")
	transform.rotation = Quaternion.Euler(3, -173, 0)
	UIScene:SetCameraTransform(transform)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	UIScene:SetModelLoadCallBack(function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
	end)
	local bundle, asset = ResPath.GetLingChongModel(lingchong_res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetFlyPetModel()
	if self.now_show_index ~= TabIndex.appearance_flypet then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local flypet_res_id = FlyPetData.Instance:GetResIdByImageId(vo.appearance.flypet_used_imageid)

	if self.temp_res_id == flypet_res_id then return end
	self.temp_res_id = flypet_res_id
	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "flypet")
	transform.rotation = Quaternion.Euler(3, -173, 0)
	UIScene:SetCameraTransform(transform)
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFlyPetModel(flypet_res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetLingQiModel()
	if self.now_show_index ~= TabIndex.appearance_lingqi then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local lingqi_res_id = LingQiData.Instance:GetResIdByImageId(vo.appearance.lingqi_used_imageid)
	if self.temp_res_id == lingqi_res_id then return end
	self.temp_res_id = lingqi_res_id
	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingqi")
	transform.rotation = Quaternion.Euler(3, -173, 0)
	UIScene:SetCameraTransform(transform)
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetLingQiModel(lingqi_res_id, true)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetWeiYanModel()
	if self.now_show_index ~= TabIndex.appearance_weiyan then
		return
	end

	local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
	if mount_res_id <= 0 then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local weiyan_res_id = WeiYanData.Instance:GetResIdByImageId(vo.appearance.weiyan_used_imageid or 0)
	if self.temp_res_id == weiyan_res_id then return end
	self.temp_res_id = weiyan_res_id
	UIScene:DeleteModel()

	local type_key = mulit_mount_res_id > 0 and "multimount" or "mount"
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, type_key)
	transform.position.z = transform.position.z + 2
	transform.rotation = Quaternion.Euler(1, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("appearance_mount_weiyan", mount_res_id)
		if advance_transform_cfg then
			UIScene:MoveObjResetPos({position = Vector3(advance_transform_cfg.position.x - 1.5, advance_transform_cfg.position.y, advance_transform_cfg.position.z), rotation = advance_transform_cfg.rotation})
		else
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 120, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
	local load_list = {{mount_bundle, mount_asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		UIScene:SetWeiYanResid(weiyan_res_id, mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = mount_bundle}
		local asset_list = {[SceneObjPart.Main] = mount_asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetQiLinBiModel()
	if self.now_show_index ~= TabIndex.appearance_qilinbi then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(vo.appearance.qilinbi_used_imageid, vo.sex, true)

	if self.temp_res_id == qilinbi_res_id then return end
	self.temp_res_id = qilinbi_res_id
	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "arm")
	transform.rotation = Quaternion.Euler(3, -173, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetQilinBiModel(qilinbi_res_id, vo.sex)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetLingGongModel()
	if self.now_show_index ~= TabIndex.appearance_linggong then
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local linggong_res_id = LingGongData.Instance:GetResIdByImageId(vo.appearance.linggong_used_imageid or 0)

	if self.temp_res_id == linggong_res_id then return end
	self.temp_res_id = linggong_res_id
	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "linggong")
	transform.rotation = Quaternion.Euler(0, -173, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		-- model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetLingGongModel(linggong_res_id + 1) --加一获得高模
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

function AppearanceEquipView:SetEquipItemInfo()
	if nil == self.info or nil == next(self.info) then return end

	local level_list = self.info.equip_level_list
	local equip_cfg = nil

	for k, v in pairs(self.equip_item_var_list) do
		equip_cfg = self.get_now_equip_cfg_func(k - 1, level_list[k - 1] or 0)
		if nil ~= equip_cfg then
			self.item_cell_list[k]:SetData({item_id = equip_cfg.item.item_id, is_bind = 0})
			local item_cfg = ItemData.Instance:GetItemConfig(equip_cfg.item.item_id)
			if item_cfg then
				self.node_list["ItemName" .. k].text.text = item_cfg.name
			end
		end
		v.remind:SetActive(self.remind_func(k - 1) > 0)
		local var_level = level_list[k - 1] or 0
		v.level.text.text = "Lv." .. var_level
	end
end

function AppearanceEquipView:SetRightInfo()
	for _, v in pairs(self.attr_var_list) do
		v.show:SetActive(false)
	end

	if nil == self.info or nil == next(self.info) or nil == self.equip_cfg then return end
	self:SetAttr()

	local equip_level = self.equip_cfg.equip_level
	local zhuangbei_name = self.equip_cfg.zhuangbei_name or ""
	self.node_list["TxtEquipName"].text.text = string.format(Language.Advance.AdvanceEquipViewEquipLevelAndName, equip_level, zhuangbei_name)

	if self.grade_info_cfg and self.grade_info_cfg.equip_level_toplimit == 0 then
		self.node_list["TxtUpgradeText"].text.text = string.format(Language.Advance.JieUse, CommonDataManager.GetDaXie(self.equip_level_limit))
		UI:SetButtonEnabled(self.node_list["UpgradeBtn"], false)
	elseif nil ~= self.next_equip_cfg then
		self.node_list["TxtUpgradeText"].text.text = Language.Role.JinJie
		UI:SetButtonEnabled(self.node_list["UpgradeBtn"], true)
	else
		self.node_list["TxtUpgradeText"].text.text = Language.Common.YiManJi
		UI:SetButtonEnabled(self.node_list["UpgradeBtn"], false)
	end

	self:SetPropInfo()
end

function AppearanceEquipView:SetAttr()
	if not self.equip_cfg then return end
	local attr_list = {}
	local is_zero = false
	if self.equip_cfg.equip_level <= 0 then
		attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_equip_cfg)
		is_zero = true
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(attr_list)
		end
	else
		attr_list = CommonDataManager.GetAttributteNoUnderline(self.equip_cfg)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(attr_list)
		end
	end
	local next_attr_list = CommonDataManager.GetAttributteNoUnderline(self.next_equip_cfg)
	attr_list = CommonDataManager.GetOrderAttributte(attr_list)
	next_attr_list = CommonDataManager.GetOrderAttributte(next_attr_list)

	local attr_count = 1
	local value_str = ""
	local temp_value = 0
	for k, v in pairs(attr_list) do
		if v.value > 0 and nil ~= self.attr_var_list[attr_count] then
			self.attr_var_list[attr_count].show:SetActive(true)
			temp_value = is_zero and 0 or v.value
			value_str = Language.Common.AttrName[v.key] .. ":  " .. string.format(Language.Common.ToColor, ATTR_VALUE_COLOR, temp_value)
			self.attr_var_list[attr_count].text.text.text = value_str
			self.attr_var_list[attr_count].next_attr_active:SetActive(next_attr_list[k].value > 0)
			self.attr_var_list[attr_count].next_attr_txt.text.text = next_attr_list[k].value - temp_value
			attr_count = attr_count + 1
		end
	end
end

function AppearanceEquipView:SetPropInfo()
	if not self.equip_cfg then return end
	local item_data = self.equip_cfg.item or self.equip_cfg.uplevel_item
	local had_prop_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	
	local data = {item_id = item_data.item_id}
	self.item_show:SetData(item_data)

	if nil ~= self.next_equip_cfg then
		local bag_num_str = ""
		if had_prop_num < item_data.num then
			bag_num_str = ToColorStr(had_prop_num, TEXT_COLOR.RED_1)
		else
			bag_num_str = ToColorStr(had_prop_num, TEXT_COLOR.GREEN_4)
		end
		self.node_list["TxtCostText"].text.text = bag_num_str .. ToColorStr(" / " .. item_data.num, TEXT_COLOR.GREEN_4)
	else
		local textcost = "- / -"
		self.node_list["TxtCostText"].text.text = ToColorStr(textcost, TEXT_COLOR.WHITE)
	end
end

function AppearanceEquipView:FlushText()
	local equip_level = self.info.equip_level_list[self.select_item_index] or 0
	if self.grade_info_cfg and self.grade_info_cfg.equip_level_toplimit then
		local equip_level_toplimit = self.grade_info_cfg.equip_level_toplimit
		if self.info.grade >= self.equip_level_limit and equip_level >= equip_level_toplimit and self.info.grade < self.max_level then
			self.node_list["TextWarn"]:SetActive(true)
			self.node_list["TextWarn"].text.text = string.format(Language.Advance.ReachGradeCanUpgrade, CommonDataManager.GetDaXie(self.info.grade))
		else
			self.node_list["TextWarn"]:SetActive(false)
		end
	end
end
