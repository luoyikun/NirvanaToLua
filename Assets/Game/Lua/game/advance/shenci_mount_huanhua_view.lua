ShenCiMountHuanHuaView = ShenCiMountHuanHuaView or BaseClass(BaseView)
local SHOWLEVELICONMAXLEVEL = 31

function ShenCiMountHuanHuaView:UIsMove()
	UITween.MoveShowPanel(self.node_list["InfoPanel"] , Vector3(400, 0, 0) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["SkillPanel"] , Vector3(-50, -44.5, 0) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["TitlePanel"] , Vector3(-75, 150, 0) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["TitlePanel"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["BtnPanel"] , Vector3(-75, -500, 0) , MOVE_TIME )
end

function ShenCiMountHuanHuaView:__init()
	self.ui_config = {
		{"uis/views/advanceview_prefab", "ModelDragLayer"}, 
		{"uis/views/advanceview_prefab", "ShenCiHuanHuaContent"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.play_audio = true
	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	self.def_index = TabIndex.shenci_mount_huan_hua
	self.play_audio = true

	self.item_id = 0
	self.index = 1
	self.grade = nil
	-- self.special_image_cfg = nil
	self.res_id = nil
	self.fix_show_time = 10
	self.cell_list = {}
	self.prefab_preload_id = 0
	self.must_pro_num = {}
	self.must_pro_num[0] = 0
	self.must_pro_num[1] = 1
end

function ShenCiMountHuanHuaView:__delete()
end

function ShenCiMountHuanHuaView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.fight_text = nil
	self.index = 1
	self.grade = nil
	self.item_id = nil
	-- self.special_image_cfg = nil
	self.data = nil

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function ShenCiMountHuanHuaView:SetRendering(value)
	BaseView.SetRendering(self, value)
end

function ShenCiMountHuanHuaView:LoadCallBack()
	self:HideLevelList()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.node_list["BtnActivate"].button:AddClickListener(BindTool.Bind(self.OnClickActivate, self))
	self.node_list["BtnUpGrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpGrade, self))
	self.node_list["BtnUseImage"].button:AddClickListener(BindTool.Bind(self.OnClickUseIma, self))
	self.node_list["BtnSuperPower"].button:AddClickListener(BindTool.Bind(self.ClickSuperPower, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShenCiMountHuanHuaView:ShowIndexCallBack(index, index_nodes)
	self.grade = nil
	self.res_id = nil
	local callback = function ()
		UIScene:SetBackground("uis/rawimages/bg_shenci_huanhua", "bg_shenci_huanhua.png")
		UIScene:SetTerraceBgActive(false)
		self:OpenFlush()
	end
	UIScene:ChangeScene(self, callback)
end

function ShenCiMountHuanHuaView:HideLevelList()
	for i = 1, 10 do
		self.node_list["shenci_level_" .. i]:SetActive(false)
	end
end

function ShenCiMountHuanHuaView:FlushLevelList(mount_special_data)
	local attr_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	if not attr_cfg then return end
	local level = attr_cfg.grade > SHOWLEVELICONMAXLEVEL and SHOWLEVELICONMAXLEVEL or attr_cfg.grade - 1
	self.node_list["StartBg"]:SetActive(level >= 0)
	local big_level, small_level = math.modf(level / 10)
	small_level = string.format("%.2f", small_level * 10)
	small_level = math.floor(small_level)
	local image_list = {}
	if big_level > 0 then
		for j = 1, small_level do
			local bubble, asset = ResPath.GetShenCiLevelImage(big_level + 1)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end

		for i = small_level + 1, 10 do
			local bubble, asset = ResPath.GetShenCiLevelImage(big_level)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	else
		for i = 1, small_level do
			local bubble, asset = ResPath.GetShenCiLevelImage(big_level + 1)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	end
	
	for i = 1, #image_list do
		self.node_list["shenci_level_" .. i]:SetActive(true)
		local va_res_path = image_list[i]
		UI:SetButtonEnabled(self.node_list["shenci_level_" .. i], true)
		self.node_list["shenci_level_" .. i].image:LoadSprite(va_res_path[1], va_res_path[2], function()
			-- self.node_list["shenci_level_" .. i].image:SetNativeSize()
		end)
	end

	for i = #image_list + 1, 10 do
		self.node_list["shenci_level_" .. i]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["shenci_level_" .. i], false)
		local bubble, asset = ResPath.GetShenCiLevelImage(1)
		self.node_list["shenci_level_" .. i].image:LoadSprite(bubble, asset)
	end
end

function ShenCiMountHuanHuaView:ClickSuperPower()
	local special_cfg = MountData.Instance:GetSpecialImageCfg(self.index)
	local image_id = special_cfg and special_cfg.image_id or 0
	local index = image_id or 0
	local data = MountData.Instance:GetSpecialHuanHuaShowData(index)
	if data then
		TipsCtrl.Instance:ShowSpecialHuanHuaViewView(data)
	end
end

function ShenCiMountHuanHuaView:GetNumberOfCells()
	local cfg_list = MountData.Instance:GetShenCiHuanHuaCfgList()
	return #cfg_list
end

function ShenCiMountHuanHuaView:RefreshCell(cell, cell_index)
	local special_image_cfg = MountData.Instance:GetShenCiHuanHuaCfgList()
	if nil == special_image_cfg[cell_index + 1] or nil == special_image_cfg[cell_index + 1].image_id then
		return
	end
	local is_show = MountData.Instance:CanShenCiHuanhuaUpgradeList()[special_image_cfg[cell_index + 1].image_id] ~= nil

	local info_list = MountData.Instance:GetMountInfo()

	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = MountHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	
	local data = {}
	data.head_id = special_image_cfg[cell_index + 1].head_id
	data.image_name = special_image_cfg[cell_index + 1].image_name
	data.item_id = special_image_cfg[cell_index + 1].item_id
	data.index = special_image_cfg[cell_index + 1].image_id
	data.zhuanzhi_prof = special_image_cfg[cell_index + 1].zhuanzhi_prof
	data.is_show = is_show
	data.info_list = info_list
	mount_cell:SetData(data)
	mount_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	mount_cell:SetHighLight(self.index == special_image_cfg[cell_index + 1].image_id)
	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, special_image_cfg[cell_index + 1], data.index, mount_cell))
end

function ShenCiMountHuanHuaView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShenCiMountHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(count)
	end
end

function ShenCiMountHuanHuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	
	--监听系统事件
	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self:OpenFlush()
end

function ShenCiMountHuanHuaView:CloseCallBack()

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.used_special_id = nil
	self.res_id = nil
end

function ShenCiMountHuanHuaView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ShenCiMountHuanHuaView:ItemDataChangeCallback()
end

function ShenCiMountHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mounthuanhua" then
			self:OnFlushCommonAdvance(k,v)
		end
	end
end

function ShenCiMountHuanHuaView:OnFlushCommonAdvance(key, value)
	if value and value.id then
		local index, num = MountData.Instance:CanShenCiHuanhuaIndexByImageId(value.id)
		self.grade = nil
		if index then
			self.index = index
			local cfg_list = MountData.Instance:GetShenCiHuanHuaCfgList()
			num = num > 5 and num or num - 1
			self.node_list["ListView"].scroller:ReloadData(num / #cfg_list)
		end
	end
	local cfg_list = MountData.Instance:GetShenCiHuanHuaCfgList()
	if #cfg_list <= 0 then return end
	local special_image_cfg = MountData.Instance:GetSpecialImagesCfg()
	if nil == special_image_cfg or nil == special_image_cfg[self.index] then
		return
	end
	local upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(special_image_cfg[self.index].image_id)
	local info_list = MountData.Instance:GetMountInfo()
	local bit_list = info_list.active_special_image_flag
	if not self.grade or (upgrade_cfg and upgrade_cfg.grade and bit_list and bit_list[self.index] and self.grade < upgrade_cfg.grade and 0 ~= bit_list[self.index]) then
		-- (self.used_special_id ~= info_list.used_special_id) then
		self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
		self:IsShowUpGrade(self.index)
		self:SetSpecialImageAttr(special_image_cfg[self.index], self.index)
		self:IsGrayUpgradeButton(self.index)
	end
	self:IsShowActivate(self.index)
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ShenCiMountHuanHuaView:OpenFlush()
	self:UIsMove()

	local cfg_list = MountData.Instance:GetShenCiHuanHuaCfgList()
	if cfg_list then
		self.index = cfg_list[1] and cfg_list[1].image_id or 1
		self:OnFlushCommonAdvance()
	end
	self.node_list["ListView"].scroller:ReloadData(0)
end

--点击激活按钮
function ShenCiMountHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local special_image_cfg = MountData.Instance:GetSpecialImagesCfg()
	if nil == special_image_cfg or nil == special_image_cfg[self.index] then
		return
	end
	self.item_id = special_image_cfg[self.index].item_id
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
function ShenCiMountHuanHuaView:OnClickUpGrade()
	local attr_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(self.index)
	local cfg_grade = attr_cfg and MountData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) or 0

	if nil ~= attr_cfg and nil ~= next(attr_cfg) then
		if attr_cfg.grade >= cfg_grade then
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
	AdvanceCtrl.Instance:MountSpecialImaUpgrade(self.index)
end

--点击使用当前形象
function ShenCiMountHuanHuaView:OnClickUseIma()
	MountCtrl.Instance:SendUseMountImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function ShenCiMountHuanHuaView:OnClickListCell(mount_special_data, index, mount_cell)
	-- self.special_image_cfg = mount_special_data
	mount_cell:SetHighLight(true)
	if self.index == index then return end
	-- if self.count ~= nil then
	-- 	CountDown.Instance:RemoveCountDown(self.count)
	-- 	self.count = nil
	-- end
	self.index = index or 1
	self.item_id = mount_special_data.item_id
	self:SetSpecialImageAttr(mount_special_data, index)
end

--获取激活坐骑符数量
function ShenCiMountHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.must_pro_num[0] = count
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
end

function ShenCiMountHuanHuaView:SetSpecialImageAttr(mount_special_data, index)
	self.node_list["LeastTime"]:SetActive(false)
	if mount_special_data == nil then
		return
	end

	self:SetMountModle(index)
	self:SetOtherSpecialImageAttr(mount_special_data, index)
	self:FlushLevelList(mount_special_data)
end

function ShenCiMountHuanHuaView:SetMountModle(index)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
	transform.rotation = Quaternion.Euler(0, -173, 0)
	UIScene:SetCameraTransform(transform)

	local image_cfg = MountData.Instance:GetSpecialImageCfg(index)
	if self.res_id == image_cfg.res_id then
		return
	end
	self.res_id = image_cfg.res_id
	
	local call_back = function(model, obj)
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetLayer(1, 1)
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		obj.gameObject.transform.localPosition = Vector3(0, 0, 0)

		local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount_huanhua", self.res_id)
		if advance_transform_cfg then
			obj.gameObject.transform.localPosition = advance_transform_cfg.position
			obj.gameObject.transform.localRotation = advance_transform_cfg.rotation
		else
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -60, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetMountModel(self.res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

function ShenCiMountHuanHuaView:SetOtherSpecialImageAttr(mount_special_data, index)
	local image_cfg = MountData.Instance:GetSpecialImageCfg(index)
	local attr_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	local info_list = MountData.Instance:GetMountInfo()
	local bit_list = info_list.active_special_image_flag
	if not image_cfg or not attr_cfg or not bit_list then return end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
	self.node_list["ZuoQiName"].text.text = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. mount_special_data.image_name .. "</color>"
	self.must_pro_num[1] = attr_cfg.stuff_num or 1
	self.node_list["TxtNeedPro"].text.text = string.format("%s / %s",self.must_pro_num[0],self.must_pro_num[1])
	self:GetHaveProNum(mount_special_data.item_id, attr_cfg.stuff_num)

	local is_show_super = MountData.Instance:IsShowSuperPower(mount_special_data.image_id)
	local is_active_super = MountData.Instance:GetStarIsShowSuperPower(mount_special_data.image_id)
	local need_reach_level = MountData.Instance:GetActiveSuperPowerNeedLevel(mount_special_data.image_id)
	self.node_list["BtnSuperPower"]:SetActive(is_show_super)
	self.node_list["TextSuperPower"]:SetActive(false)
	UI:SetGraphicGrey(self.node_list["BtnSuperPower"], not is_active_super)
	self.node_list["BtnEff"].gameObject:SetActive(not is_active_super)
	if is_show_super and not is_active_super then
		local super_power_text = string.format(Language.Advance.SuperPowerText, need_reach_level)
		self.node_list["TextSuperPower"]:SetActive(true)
		self.node_list["TextSuperPower"].text.text = super_power_text
	end

	local special_image_grade = MountData.Instance:GetSingleSpecialImageGrade(mount_special_data.image_id)
	local attr0 = MountData.Instance:GetSpecialImageUpgradeInfo(index)
	local attr1 = MountData.Instance:GetSpecialImageUpgradeInfo(index, special_image_grade, true)
	local max_grade = MountData.Instance:GetSpecialImageMaxUpLevelById(mount_special_data.image_id)
	self:SetAttr(special_image_grade, attr0, attr1, max_grade, index)

	local data = {item_id = mount_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsGrayUpgradeButton(self.index)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
end

function ShenCiMountHuanHuaView:SetAttr(special_image_grade, attr0, attr1, max_grade, special_index)
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
		local capability = CommonDataManager.GetCapability(attr1)
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
		local capability = CommonDataManager.GetCapability(attr0)
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
		local capability = CommonDataManager.GetCapability(attr0)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = capability
		end
	end
	local active_grade, attr_type, attr_value = MountData.Instance:GetHuanHuaSpecialAttrActiveType(nil, special_index)
	if active_grade and attr_type and attr_value then
		if special_image_grade < active_grade then
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. 0 .. "%%")
			self.node_list["TxtSpecialArrow"]:SetActive(true)
			self.node_list["TxtSpecialAddValue"].text.text = attr_value / 100 .. "%"
		else
			local special_attr = nil
			self.node_list["TxtSpecialArrow"]:SetActive(false)
			self.node_list["TxtSpecialAddValue"]:SetActive(false)
			for i = special_image_grade + 1, max_grade do
				local next_active_grade, next_attr_type, next_attr_value = MountData.Instance:GetHuanHuaSpecialAttrActiveType(i, special_index)
				if next_attr_value then
					if next_attr_value ~= attr_value then
						special_attr = next_attr_value - attr_value
						self.node_list["TxtSpecialArrow"]:SetActive(true)
						self.node_list["TxtSpecialAddValue"]:SetActive(true)
						self.node_list["TxtSpecialAddValue"].text.text = special_attr / 100 .. "%"
						break
					end
				end
			end
			self.node_list["TxtSpecialAttr"]:SetActive(true)
			self.node_list["TxtSpecialAttr"].text.text = string.format(Language.Advance.SpecialAttr[attr_type] .. attr_value / 100 .. "%%")
		end
	else
		self.node_list["TxtSpecialAttr"]:SetActive(false)
	end
end

--设置激活按钮显示和隐藏
function ShenCiMountHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = MountData.Instance:GetMountInfo()
	local bit_list = info_list.active_special_image_flag
	self.node_list["BtnActivate"]:SetActive(bit_list[image_id] and 0 == bit_list[image_id])
	self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
	self.node_list["BtnImageUsed"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
	local used_imageid = 0
	if info_list.is_used_special_img and info_list.is_used_special_img == 1 then
		used_imageid = info_list.used_special_id
	else
		used_imageid = info_list.used_imageid
	end
	if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and image_id ~= (used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
		self.node_list["BtnImageUsed"]:SetActive(bit_list[image_id] and image_id == (used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.node_list["BtnUseImage"]:SetActive(bit_list[image_id] and 0 ~= bit_list[image_id])
		self.node_list["BtnImageUsed"]:SetActive(false)
	end
end

--设置升级按钮显示和隐藏
function ShenCiMountHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end

	local info_list = MountData.Instance:GetMountInfo()
	local special_img_up = MountData.Instance:GetSpecialImageUpgradeCfg()
	local bit_list = info_list.active_special_image_flag

	if special_img_up[image_id] then
		self.node_list["BtnUpGrade"]:SetActive(0 ~= bit_list[image_id])
	else
		self.node_list["BtnUpGrade"]:SetActive(false)
	end
end

--升级按钮是否置灰
function ShenCiMountHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local special_image_cfg = MountData.Instance:GetSpecialImagesCfg()
	if nil == special_image_cfg or nil == special_image_cfg[self.index] then
		return
	end
	local upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(special_image_cfg[index].image_id)
	local image_id = MountData.Instance:GetSpecialImageMaxUpLevelById(special_image_cfg[index].image_id)

	if upgrade_cfg.grade < image_id then
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], true)
		self.node_list["BtnUpGradeText"].text.text = Language.Common.UpGrade
	else
		UI:SetButtonEnabled(self.node_list["BtnUpGrade"], false)
		self.node_list["BtnUpGradeText"].text.text = Language.Common.YiManJi
		self.node_list["TxtNeedPro"].text.text = ToColorStr("- / -", TEXT_COLOR.WHITE)
	end
end

------------------------------------------------------------------------------------------------
MountHuanHuaCell = MountHuanHuaCell or BaseClass(BaseRender)

function MountHuanHuaCell:__init()
end

function MountHuanHuaCell:SetData(data)
	if data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. data.image_name .. "</color>"
	self.node_list["TxtName"].text.text = name_str

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local zhuanzhi_prof = math.floor(vo.prof / 10)
	self.node_list["Warn"]:SetActive(data.zhuanzhi_prof > zhuanzhi_prof)
	self.node_list["Warn"].text.text = string.format(Language.Advance.ZhuanZhiOpen, CommonDataManager.GetDaXie(data.zhuanzhi_prof))
	self.node_list["ImgRemind"]:SetActive(data.is_show)
	self:ShowLabel(data, data.index)
end

function MountHuanHuaCell:ListenClick(handler)
	self.node_list["HuanHuaItem"].toggle:AddClickListener(handler)
end

function MountHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MountHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function MountHuanHuaCell:ShowLabel(data, image_id)
	if image_id == nil then
		return
	end
	
	local bit_list = data.info_list.active_special_image_flag
	self.node_list["ImgYiHuanHua"]:SetActive(0 ~= bit_list[image_id])
	UI:SetGraphicGrey(self.node_list["ImgIcon"], 0 == bit_list[image_id])
	if data.info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.node_list["ImgYiHuanHua"]:SetActive(image_id == (data.info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.node_list["ImgYiHuanHua"]:SetActive(false)
	end
end

