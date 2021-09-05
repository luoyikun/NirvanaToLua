AdvanceEquipView = AdvanceEquipView or BaseClass(BaseView)

local ATTR_VALUE_COLOR = "B7D3F9FF"
local MOVE_TIME = 0.5

function AdvanceEquipView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightPanel"] , Vector3(400 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Zhuangbei"] , Vector3(-120, 0 , 0 ) , MOVE_TIME )
	-- UITween.MoveShowPanel(self.node_list["BtnPreView"] , Vector3(200 , 305 , 0 ) , MOVE_TIME )
	-- UITween.MoveShowPanel(self.node_list["BtnBack"] , Vector3(200 , 205 , 0 ) , MOVE_TIME )
end

function AdvanceEquipView:__init()
	self.ui_config = {
		{"uis/views/advanceview_prefab", "ModelDragLayer"}, 
		{"uis/views/advanceview_prefab", "JingjieZhuangBeiView"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		
	}
	self.camera_mode = UICameraMode.UICameraMid

	self.play_audio = true
	self.full_screen = true
	self.now_show_index = -1
	self.select_item_index = 0
	self.temp_res_id = 0
	self.fashion_id = -1
	self.image_id = -1
	self.skill_icon_res = ""
	self.active_skill_level = 0
	self.percent_icon_bundle = "uis/images_atlas"
	self.percent_icon_asset = ""
	self.all_normal_equip_attr_list = {}
	self.special_equip_attr_list = {}
	self.attr_var_list = {}
	self.all_equip_percent_value = 0
	-- self.equip_min_level = 0
	self.must_pro_num = {}
	self.must_pro_num[0] = 0
	self.must_pro_num[1] = 0
	self.must_pro_num[2] = 0

	self.name_and_level = {}
	self.name_and_level[0] = 0
	self.name_and_level[1] = ""

	self.txt_need_next_sp = {}
	self.txt_need_next_sp[0] = 0
	self.txt_need_next_sp[1] = 0
	self.txt_need_next_sp[2] = 0
	self.must_skill_active = {}
	self.must_skill_active[0] = 0
	self.must_skill_active[1] = 0
	self.max_level = 0

	-- self.must_txt_special_attr = {}
	-- self.must_txt_special_attr[0] = ""
	-- self.must_txt_special_attr[1] = ""

	self.grade_info_cfg = {}
	self.equip_level_limit = 0

	self.def_index = TabIndex.jinjie_zhuangbei
end

function AdvanceEquipView:ReleaseCallBack()
	self.must_pro_num = {}
	self.name_and_level = {}
	self.txt_need_next_sp = {}
	-- self.must_txt_special_attr = {}
	self.must_skill_active = {}

	for _, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	-- 清理变量
	self.attr_var_list = {}
	self.equip_item_var_list = nil
	self.skill_icon = nil
	self.equip_level = nil
	self.show_active_tip = nil
	self.percen_attr_icon = nil
	self.next_percent_attr_var_value = nil
	self.item_cell_toggle_group = nil
	self.max_level = nil
	if self.item_show ~= nil then
		self.item_show:DeleteMe()
		self.item_show = nil
	end
	
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.fight_text = nil
	self.temp_res_id = nil
end

function AdvanceEquipView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Common.ZhuangBei, bundle = "uis/images_atlas", asset = "shengxiao_equip", tab_index = TabIndex.jinjie_zhuangbei, remind_id = RemindName.AdvanceEquip},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ShowIndex, self))

	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["UpgradeBtn"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel, self))
	self.node_list["BtnPreView"].button:AddClickListener(BindTool.Bind(self.OnClickAttrPreview, self))
	self.node_list["BtnEquipSkill"].button:AddClickListener(BindTool.Bind(self.OnClickEquipSkill, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["TxtTitle"].text.text = Language.Title.JinJie

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
	UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)})

	self.item_cell_toggle_group = self.node_list["ItemCellToggleGroup"]

	self.equip_item_var_list = {}
	self.item_cell_list = {}
	self.item_cell_hl = {}
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

function AdvanceEquipView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(TabIndex.jinjie_zhuangbei)
	AdvanceData.Instance:SetEquipType(index)
	self:UIsMove()
	if self.now_show_index < 0 then
		self.now_show_index = index
		if self.model and self.now_show_index == TabIndex.foot_jinjie then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		elseif self.model then
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
	end

	self.image_id = 0
	self.fashion_id = 0
	self.temp_res_id = 0

	local callback = function ()
		self:Flush()
	end
	UIScene:ChangeScene(self, callback)
end

function AdvanceEquipView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceEquipView:OpenCallBack()
	self.select_item_index = 0
	-- self.item_cell_list[self.select_item_index + 1]:SetToggle(true)
	self:FlushItemHL(self.select_item_index + 1)

	self:Flush()
	-- 监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
		-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	RemindManager.Instance:Fire(RemindName.AdvanceEquip)
end

function AdvanceEquipView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AdvanceEquipView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end


function AdvanceEquipView:CloseCallBack()
	self.now_show_index = -1
	self.fashion_id = -1
	self.image_id = -1
	self.equip_cfg = nil
	self.next_equip_cfg = nil
	self.info = nil
	self.temp_res_id = 0
	self.remind_func = nil
	self.equip_skill_cfg = nil
	self.active_skill_level = 0
	self.all_normal_equip_attr_list = {}
	self.special_equip_attr_list = {}
	self.all_equip_percent_value = 0
	self.skill_icon_res = ""
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function AdvanceEquipView:OnClickClose()
	self:Close()
end

function AdvanceEquipView:OnClickEquipSkill()
	if self.now_show_index == TabIndex.goddess_shengong or self.now_show_index == TabIndex.goddess_shenyi then
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipSkillView)
end

function AdvanceEquipView:OnClickItemNormal(index)
	self:OnClickItem(index)
end
-- 点击装备格子
function AdvanceEquipView:OnClickItem(index)
	self.select_item_index = index - 1
	self:SetNowInfo()
	self:SetRightInfo()
	self:SetEquipItemInfo()
	self:FlushText()

	self.item_cell_list[index]:ShowHighLight(false)
	self:FlushItemHL(index)
end

function AdvanceEquipView:FlushItemHL(index)
	for k, v in pairs(self.item_cell_hl) do
		if k == index then
			v:SetActive(true)
		else
			v:SetActive(false)
		end
	end
end

function AdvanceEquipView:FlushText()
	if self.info then
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
end

function AdvanceEquipView:OnClickAttrPreview()
	local attr_des = string.format(Language.Advance.PercentAttrDesList[self.now_show_index], (self.all_equip_percent_value / 100) .."%")
	self.special_equip_attr_list = {{attr_des = attr_des, bundle = self.percent_icon_bundle, asset = self.percent_icon_asset, show = self.equip_cfg and self.equip_cfg.add_percent > 0 and true or false}}
	TipsCtrl.Instance:ShowPreferredSizeAttrView(self.all_normal_equip_attr_list, self.special_equip_attr_list, 0)
end

function AdvanceEquipView:OnClickUpLevel()
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

	if self.now_show_index == TabIndex.mount_jinjie then
		MountCtrl.Instance:SendMountUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.wing_jinjie then
		WingCtrl.Instance:SendWingUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.halo_jinjie then
		HaloCtrl.Instance:SendHaloUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.fabao_jinjie then
		FaBaoCtrl.Instance:SendUpGradeReq(CS_FABAO_REQ_TYPE.CS_FABAO_REQ_TYPE_UPLEVELEQUIP, self.select_item_index)

	elseif self.now_show_index == TabIndex.fight_mount then
		FightMountCtrl.Instance:SendFightMountUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.goddess_shengong then
		ShengongCtrl.Instance:SendShengongUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.goddess_shenyi then
		ShenyiCtrl.Instance:SendShenyiUpLevelReq(self.select_item_index)
		
	elseif self.now_show_index == TabIndex.foot_jinjie then
		FootCtrl.Instance:SendFootUpLevelReq(self.select_item_index)

	elseif self.now_show_index == TabIndex.fashion_jinjie then
		FashionCtrl.Instance:SendWuQiEquipUpLevelReq(self.select_item_index, SHIZHUANG_TYPE.BODY)

	elseif self.now_show_index == TabIndex.role_shenbing then
		FashionCtrl.Instance:SendWuQiEquipUpLevelReq(self.select_item_index, SHIZHUANG_TYPE.WUQI)
	end
end

function AdvanceEquipView:SetModel()
	if nil == self.info or nil == next(self.info) then return end

	self:SetMountModel()
	self:SetWingModel()
	self:SetHaloModel()
	self:SetFightMoutModel()
	self:SetShengongModel()
	self:SetShenyiModel()
	self:SetFootModel()
	self:SetFaBaoModel()
	self:SetShiZhuangModel()
	self:SetWuQiModel()
	UIScene:SetBackground()
	UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
end

function AdvanceEquipView:SetShiZhuangModel()
	if self.now_show_index ~= TabIndex.fashion_jinjie then
		return
	end

	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	local fashion_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img

	if self.fashion_id == fashion_id then return end
	self.fashion_id = fashion_id

	UIScene:DeleteModel()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}
	info.prof = prof
	info.sex = vo.sex
	info.is_not_show_weapon = true
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}

	UIScene:SetRoleModelResInfo(info, true, false, true, true)
end

function AdvanceEquipView:SetWuQiModel()
	if self.now_show_index ~= TabIndex.role_shenbing then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = vo.appearance.fashion_wuqi

	if self.image_id == image_id then return end
	self.image_id = image_id

	UIScene:DeleteModel()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.FIGHT)
			if prof == GameEnum.ROLE_PROF_4 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local info = {}
	info.prof = PlayerData.Instance:GetRoleBaseProf()
	info.sex = vo.sex
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
	info.shizhuang_part_list = {{image_id = image_id}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

	UIScene:SetRoleModelResInfo(info, false, false, false, true)
end

function AdvanceEquipView:SetFaBaoModel()
	if self.now_show_index ~= TabIndex.fabao_jinjie then
		return
	end

	local fabao_grade_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.info.grade)
	if nil == fabao_grade_cfg then return end

	local image_id = self.info.used_imageid
	local used_special_id = self.info.used_special_id
	local is_used_special_img = self.info.is_used_special_img
	local image_cfg = {}
	if is_used_special_img == 0 then
		image_cfg = FaBaoData.Instance:GetFaBaoImageCfg()[image_id]
	else
		image_cfg = FaBaoData.Instance:GetSpecialImagesCfg()[used_special_id - 1000]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
	transform.rotation = Quaternion.Euler(0, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 30, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetFaBaoModel(image_cfg.res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

function AdvanceEquipView:SetMountModel()
	if self.now_show_index ~= TabIndex.mount_jinjie then
		return
	end

	local mount_grade_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade)
	if nil == mount_grade_cfg then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = self.info.used_imageid
	local image_cfg = {}

	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = MountData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = MountData.Instance:GetMountImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
	transform.rotation = Quaternion.Euler(0, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetLayer(1, 1)
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if obj then
			local advance_huanhua_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount_huanhua", self.temp_res_id)
			local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount", self.temp_res_id)
			if advance_huanhua_transform_cfg then
				obj.gameObject.transform.localPosition = advance_huanhua_transform_cfg.position
				obj.gameObject.transform.localRotation = advance_huanhua_transform_cfg.rotation
			elseif advance_transform_cfg then
				obj.gameObject.transform.localPosition = advance_transform_cfg.position
				obj.gameObject.transform.localRotation = advance_transform_cfg.rotation
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -60, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetMountModel(image_cfg.res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

function AdvanceEquipView:SetWingModel()
	if self.now_show_index ~= TabIndex.wing_jinjie then
		return
	end

	local wing_grade_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade)
	if wing_grade_cfg == nil then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = vo.appearance.wing_used_imageid
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = WingData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = WingData.Instance:GetWingImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	UIScene:DeleteModel()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			if prof == GameEnum.ROLE_PROF_3 or prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -155, 0)
			elseif prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}
	info.wing_info = {used_imageid = vo.appearance.wing_used_imageid}
	info.prof = prof
	info.sex = vo.sex
	info.is_not_show_weapon = true
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

	UIScene:SetRoleModelResInfo(info, true, false, true, true)
end

function AdvanceEquipView:SetHaloModel()
	if self.now_show_index ~= TabIndex.halo_jinjie then
		return
	end

	local halo_grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade)
	if halo_grade_cfg == nil then return end

	local image_cfg = HaloData.Instance:GetHaloImageCfg()[halo_grade_cfg.image_id]
	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	UIScene:DeleteModel()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}
	info.halo_info = {used_imageid = vo.appearance.halo_used_imageid}
	info.prof = PlayerData.Instance:GetRoleBaseProf()
	info.sex = vo.sex
	info.is_not_show_weapon = true
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

	UIScene:SetRoleModelResInfo(info, true, true, false, true)
end

function AdvanceEquipView:SetFightMoutModel()
	if self.now_show_index ~= TabIndex.fight_mount then
		return
	end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.info.grade)
	if mount_grade_cfg == nil then return end

	--local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = self.info.used_imageid
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = FightMountData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = FightMountData.Instance:GetMountImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
	transform.rotation = Quaternion.Euler(25, -170, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetFightMountModel(image_cfg.res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

function AdvanceEquipView:SetShengongModel()
	if self.now_show_index ~= TabIndex.goddess_shengong then
		return
	end

	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local image_id = shengong_info.used_imageid
	local halo_res_id = 0
	if shengong_info.used_imageid > 1000 then
		image_id = image_id - 1000
		local special_cfg = ShengongData.Instance:GetSpecialImageCfg(image_id)
		if special_cfg then
			halo_res_id = ShengongData.Instance:GetSpecialImageCfg(image_id).res_id
		end
	else
		local image_cfg = ShengongData.Instance:GetShengongImageCfg()
		if image_cfg[image_id] then
			halo_res_id = image_cfg[image_id].res_id
		end
	end

	if self.temp_res_id == halo_res_id then return end
	self.temp_res_id = halo_res_id

	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
	UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.halo_res_id = halo_res_id

	UIScene:SetGoddessModelResInfo(info)
end

function AdvanceEquipView:SetShenyiModel()
	if self.now_show_index ~= TabIndex.goddess_shenyi then
		return
	end

	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg()
	local image_id = shenyi_info.used_imageid
	local fazhen_res_id = 0
	
	if shenyi_info.used_imageid > 1000 then
		image_id = image_id - 1000
		local special_cfg = ShenyiData.Instance:GetSpecialImageCfg(image_id)
		if special_cfg then
			fazhen_res_id = ShenyiData.Instance:GetSpecialImageCfg(image_id).res_id
		end
	else
		if image_cfg[image_id] then
			fazhen_res_id = image_cfg[image_id].res_id
		end
	end

	if self.temp_res_id == fazhen_res_id then return end
	self.temp_res_id = fazhen_res_id

	UIScene:DeleteModel()

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
	UIScene:SetCameraTransform(transform, Vector2(-0.3, 0))

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS, 0)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.fazhen_res_id = fazhen_res_id

	UIScene:SetGoddessModelResInfo(info)
end

function AdvanceEquipView:SetFootModel()
	if self.now_show_index ~= TabIndex.foot_jinjie then
		return
	end

	local foot_grade_cfg = FootData.Instance:GetFootGradeCfg(self.info.grade)
	if foot_grade_cfg == nil then return end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local image_id = vo.appearance.footprint_used_imageid
	local image_cfg = {}
	if image_id > 1000 then
		image_id = image_id - 1000
		image_cfg = FootData.Instance:GetSpecialImagesCfg()[image_id]
	else
		image_cfg = FootData.Instance:GetFootImageCfg()[image_id]
	end

	if nil == image_cfg then return end

	if self.temp_res_id == image_cfg.res_id then return end
	self.temp_res_id = image_cfg.res_id

	UIScene:DeleteModel()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
	transform.rotation = Quaternion.Euler(8, -168, 0)
	UIScene:SetCameraTransform(transform)

	local call_back = function(model, obj)
		if obj then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
		end
	end
	
	UIScene:SetModelLoadCallBack(call_back)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local info = {}
	info.foot_info = {used_imageid = vo.appearance.footprint_used_imageid}
	info.prof = PlayerData.Instance:GetRoleBaseProf()
	info.sex = vo.sex
	info.is_not_show_weapon = true
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

	UIScene:SetRoleModelResInfo(info, false, false, false, false, true)
end

function AdvanceEquipView:SetRightInfo()
	for _, v in pairs(self.attr_var_list) do
		v.show:SetActive(false)
	end

	if nil == self.info or nil == next(self.info) or nil == self.equip_cfg then return end

	self:SetAttr()

	self.name_and_level[0] = self.equip_cfg.equip_level
	self.name_and_level[1] = self.equip_cfg.zhuangbei_name or ""
	self.node_list["TxtEquipName"].text.text = string.format(Language.Advance.AdvanceEquipViewEquipLevelAndName,self.name_and_level[0],self.name_and_level[1])

	if nil ~= self.equip_skill_cfg then
		local cur_desc = ""
		cur_desc = string.gsub(self.equip_skill_cfg.skill_desc, "%b()%%", function (str)
			return (tonumber(self.equip_skill_cfg[string.sub(str, 2, -3)]) / 1000)
		end)
		cur_desc = string.gsub(cur_desc, "%b[]%%", function (str)
			return (tonumber(self.equip_skill_cfg[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		cur_desc = string.gsub(cur_desc, "%[.-%]", function (str)
			return self.equip_skill_cfg[string.sub(str, 2, -2)]
		end)
	end
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

function AdvanceEquipView:SetPropInfo()
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
		self.must_pro_num[1] = bag_num_str
		self.must_pro_num[2] = item_data.num
		self.node_list["TxtCostText"].text.text = self.must_pro_num[1] .. ToColorStr(" / " .. self.must_pro_num[2], TEXT_COLOR.GREEN_4)
	else
		local textcost = "- / -"
		self.node_list["TxtCostText"].text.text = ToColorStr(textcost, TEXT_COLOR.WHITE)
	end
end

function AdvanceEquipView:SetAttr()
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

function AdvanceEquipView:SetEquipItemInfo()
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
		-- v.level.text.text = string.format(Language.Advance.AdvanceEquipViewLevelTxt,var_level)
		v.level.text.text = "Lv." .. var_level
	end
end

function AdvanceEquipView:SetNowInfo()
	self.all_equip_percent_value = 0
	self.grade_info_cfg = {}
	if self.now_show_index == TabIndex.mount_jinjie then	-- 坐骑装备
		self.info = MountData.Instance:GetMountInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(MountData.Instance.CalEquipRemind, MountData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(MountData.Instance.GetEquipInfoCfg, MountData.Instance)

			self.skill_icon_res = "mount_skill_icon"
			self.percent_icon_asset = "icon_info_zq_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = MountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = MountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = MountData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT, temp_level)
		self.active_skill_level = MountData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = MountData.Instance:GetMountEquipAttrSum()
		self.grade_info_cfg = MountData.Instance:GetMountGradeCfg(self.info.grade) or {}
		self.equip_level_limit = MountData.Instance:GetEquipLevelLimit()
		-- if nil == mount_grade_cfg then return end

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = MountData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.wing_jinjie then		-- 羽翼装备
		self.info = WingData.Instance:GetWingInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(WingData.Instance.CalEquipRemind, WingData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(WingData.Instance.GetEquipInfoCfg, WingData.Instance)

			self.skill_icon_res = "wing_skill_icon"
			self.percent_icon_asset = "icon_info_yy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = WingData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = WingData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = WingData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING, temp_level)
		self.active_skill_level = WingData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = WingData.Instance:GetWingEquipAttrSum()
		self.grade_info_cfg = WingData.Instance:GetWingGradeCfg(self.info.grade) or {}
		self.equip_level_limit = WingData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = WingData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.halo_jinjie then		-- 光环装备
		self.info = HaloData.Instance:GetHaloInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(HaloData.Instance.CalEquipRemind, HaloData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(HaloData.Instance.GetEquipInfoCfg, HaloData.Instance)

			self.skill_icon_res = "halo_skill_icon"
			self.percent_icon_asset = "icon_info_halo_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = HaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = HaloData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = HaloData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO, temp_level)
		self.active_skill_level = HaloData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = HaloData.Instance:GetHaloEquipAttrSum()
		self.grade_info_cfg = HaloData.Instance:GetHaloGradeCfg(self.info.grade) or {}
		self.equip_level_limit = HaloData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = HaloData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.fight_mount then		-- 战斗坐骑装备
		self.info = FightMountData.Instance:GetFightMountInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FightMountData.Instance.CalEquipRemind, FightMountData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FightMountData.Instance.GetEquipInfoCfg, FightMountData.Instance)

			self.skill_icon_res = "fight_mount_skill_icon"
			self.percent_icon_asset = "icon_info_zdzq_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FightMountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FightMountData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = FightMountData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT, temp_level)
		self.active_skill_level = FightMountData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FightMountData.Instance:GetMountEquipAttrSum()
		self.grade_info_cfg = FightMountData.Instance:GetMountGradeCfg(self.info.grade) or {}
		self.equip_level_limit = FightMountData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FightMountData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.goddess_shengong then		-- 神弓装备
		self.info = ShengongData.Instance:GetShengongInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShengongData.Instance.CalEquipRemind, ShengongData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShengongData.Instance.GetEquipInfoCfg, ShengongData.Instance)

			self.skill_icon_res = "shengong_skill_icon"
			self.percent_icon_asset = "icon_info_gong_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShengongData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG, temp_level)
		self.active_skill_level = ShengongData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShengongData.Instance:GetShengongEquipAttrSum()
		self.grade_info_cfg = ShengongData.Instance:GetShengongGradeCfg(self.info.grade) or {}
		self.max_level = ShengongData.Instance:GetMaxGrade()
		self.equip_level_limit = ShengongData.Instance:GetEquipLevelLimit()
		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShengongData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end

	elseif self.now_show_index == TabIndex.goddess_shenyi then		-- 神翼装备
		self.info = ShenyiData.Instance:GetShenyiInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(ShenyiData.Instance.CalEquipRemind, ShenyiData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(ShenyiData.Instance.GetEquipInfoCfg, ShenyiData.Instance)

			self.skill_icon_res = "shenyi_skill_icon"
			self.percent_icon_asset = "icon_info_sy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = ShenyiData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI, temp_level)
		self.active_skill_level = ShenyiData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = ShenyiData.Instance:GetShenyiEquipAttrSum()
		self.grade_info_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.info.grade) or {}
		self.max_level = ShenyiData.Instance:GetMaxGrade()
		self.equip_level_limit = ShenyiData.Instance:GetEquipLevelLimit()
		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = ShenyiData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.foot_jinjie then		-- 足迹装备
		self.info = FootData.Instance:GetFootInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FootData.Instance.CalEquipRemind, FootData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FootData.Instance.GetEquipInfoCfg, FootData.Instance)

			self.skill_icon_res = "foot_skill_icon"
			self.percent_icon_asset = "icon_info_zj_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FootData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FootData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = FootData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT, temp_level)
		self.active_skill_level = FootData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FootData.Instance:GetFootEquipAttrSum()
		self.grade_info_cfg = FootData.Instance:GetFootGradeCfg(self.info.grade) or {}
		self.equip_level_limit = FootData.Instance:GetEquipLevelLimit()
		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FootData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.fabao_jinjie then		-- 法宝装备
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FaBaoData.Instance.CalEquipRemind, FaBaoData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FaBaoData.Instance.GetEquipInfoCfg, FaBaoData.Instance)

			self.skill_icon_res = "fabao_skill_icon"
			self.percent_icon_asset = "icon_info_fb_attr"
		end
		
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FaBaoData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.max_level = FaBaoData.Instance:GetMaxGrade()
		self.next_equip_cfg = FaBaoData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FABAO, temp_level)
		self.active_skill_level = FaBaoData.Instance:GetOhterCfg().active_equip_skill_level or 0
		self.all_normal_equip_attr_list = FaBaoData.Instance:GetFaBaoEquipAttrSum()
		self.grade_info_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(self.info.grade) or {}
		self.equip_level_limit = FaBaoData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FaBaoData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.role_shenbing then		-- 足迹装备
		self.info = FashionData.Instance:GetWuQiInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FashionData.Instance.CalEquipRemind, FashionData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FashionData.Instance.GetEquipInfoCfg, FashionData.Instance)

			self.skill_icon_res = "shenyi_skill_icon"
			self.percent_icon_asset = "icon_info_sy_attr"
		end
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FashionData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level)
		self.next_equip_cfg = FashionData.Instance:GetEquipInfoCfg(self.select_item_index, equip_level + 1)
		self.max_level = FashionData.Instance:GetMaxGrade()
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT, temp_level)
		self.active_skill_level =  FashionData.Instance:GetShizhuangOhterCfg() or 4
		self.all_normal_equip_attr_list = FashionData.Instance:GetWuQiEquipAttrSum()
		self.grade_info_cfg = FashionData.Instance:GetShenBingGradeCfg(self.info.grade) or {}
		self.equip_level_limit = FashionData.Instance:GetEquipLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FashionData.Instance:GetEquipInfoCfg(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	elseif self.now_show_index == TabIndex.fashion_jinjie then
		self.info = FashionData.Instance:GetFashionInfo()
		if nil == self.remind_func then
			self.remind_func = BindTool.Bind(FashionData.Instance.CalShizhuangEquipRemind, FashionData.Instance)
			self.get_now_equip_cfg_func = BindTool.Bind(FashionData.Instance.GetShizhuangEquipById, FashionData.Instance)
			self.skill_icon_res = "fashion_skill_icon"
			self.percent_icon_asset = "icon_info_fb_attr"
		end
		self.max_level = FashionData.Instance:GetShizhuangImgMaxGrade()
		local equip_level = self.info.equip_level_list[self.select_item_index] or 0
		self.equip_cfg = FashionData.Instance:GetShizhuangEquipById(self.select_item_index, equip_level)

		self.next_equip_cfg = FashionData.Instance:GetShizhuangEquipById(self.select_item_index, equip_level + 1)
		local temp_level = self.info.equip_skill_level > 0 and self.info.equip_skill_level or 1
		self.equip_skill_cfg = AdvanceData.Instance:GetEquipSkill(JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG, temp_level)
		self.active_skill_level = FashionData.Instance:GetShizhuangOhterCfg() or 4
		self.all_normal_equip_attr_list = FashionData.Instance:GetShizhuangEquipAttrSum()
		self.grade_info_cfg = FashionData.Instance:GetShiZhuangGradeCfg(self.info.grade) or {}
		self.equip_level_limit = FashionData.Instance:GetShiZhuangLevelLimit()

		local tenp_cfg = nil
		for k, v in pairs(self.info.equip_level_list) do
			tenp_cfg = FashionData.Instance:GetShizhuangEquipById(k, v)
			if nil ~= tenp_cfg then
				self.all_equip_percent_value = self.all_equip_percent_value + tenp_cfg.add_percent
			end
		end
	end
end

function AdvanceEquipView:OnFlush(param_list)
	self:SetNowInfo()
	self:SetModel()
	self:SetRightInfo()
	self:SetEquipItemInfo()
	self:FlushText()
end
