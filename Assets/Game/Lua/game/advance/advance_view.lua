AdvanceView = AdvanceView or BaseClass(BaseView)

local MOUNT = 1
local WING = 2
local HALO = 3
local HUASHEN = 4
local HUASHEN_PROTECT = 5
local FIGHT_MOUNT = 6
local SHEN_BING = 7
local FOOT = 8
local CLOAK = 9
local FASHION = 10
local IMMORTALS = 11
local FABAO = 12

function AdvanceView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/advanceview_prefab", "ModelDragLayer"}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.mount_jinjie}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.wing_jinjie}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.foot_jinjie}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.halo_jinjie}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.fight_mount}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.fashion_jinjie}}, 
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.role_shenbing}},
		{"uis/views/advanceview_prefab", "AdvanceContent", {TabIndex.fabao_jinjie}},
		{"uis/views/advanceview_prefab", "ShenBingContent", {TabIndex.immortals_jinjie}}, 
		{"uis/views/advanceview_prefab", "CloakContent", {TabIndex.cloak_jinjie}}, 
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.full_screen = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenAdvanced)
	end

	self.def_index = TabIndex.mount_jinjie
	self.play_audio = true
	self.notips = false
	self.data = nil

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
end

function AdvanceView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function AdvanceView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Advance)
	end

	if self.mount_view ~= nil then
		self.mount_view:DeleteMe()
		self.mount_view = nil
	end

	if self.wing_view ~= nil then
		self.wing_view:DeleteMe()
		self.wing_view = nil
	end

	if self.foot_view ~= nil then
		self.foot_view:DeleteMe()
		self.foot_view = nil
	end

	if self.halo_view ~= nil then
		self.halo_view:DeleteMe()
		self.halo_view = nil
	end

	if self.fight_mount_view ~= nil then
		self.fight_mount_view:DeleteMe()
		self.fight_mount_view = nil
	end

	if self.shenbing_view ~= nil then
		self.shenbing_view:DeleteMe()
		self.shenbing_view = nil
	end

	if self.cloak_view ~= nil then
		self.cloak_view:DeleteMe()
		self.cloak_view = nil
	end

	if self.fashion_view ~= nil then
		self.fashion_view:DeleteMe()
		self.fashion_view = nil
	end

	if self.immortals_view ~= nil then
		self.immortals_view:DeleteMe()
		self.immortals_view = nil
	end

	if self.fabao_view ~= nil then
		self.fabao_view:DeleteMe()
		self.fabao_view = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self.btn_close = nil
end

function AdvanceView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Advance.TabbarName[1],  bundle = "uis/images_atlas", asset = "tab_icon_mount", func = "mount_jinjie", tab_index = TabIndex.mount_jinjie, remind_id = RemindName.AdvanceMount},
		{name = Language.Advance.TabbarName[2],  bundle = "uis/images_atlas", asset = "tab_icon_wing", func = "wing_jinjie", tab_index = TabIndex.wing_jinjie, remind_id = RemindName.AdvanceWing},
		{name = Language.Advance.TabbarName[8],  bundle = "uis/images_atlas", asset = "tab_icon_fightmount", func = "fight_mount", tab_index = TabIndex.fight_mount, remind_id = RemindName.AdvanceFightMount},
		{name = Language.Advance.TabbarName[5],  bundle = "uis/images_atlas", asset = "tab_icon_fabao", func = "fabao_jinjie", tab_index = TabIndex.fabao_jinjie, remind_id = RemindName.AdvanceFaBao},
		{name = Language.Advance.TabbarName[7],  bundle = "uis/images_atlas", asset = "tab_icon_halo", func = "halo_jinjie", tab_index = TabIndex.halo_jinjie, remind_id = RemindName.AdvanceHalo},
		{name = Language.Advance.TabbarName[6],  bundle = "uis/images_atlas", asset = "tab_icon_foot", func = "foot_jinjie", tab_index = TabIndex.foot_jinjie, remind_id = RemindName.AdvanceFoot},
		{name = Language.Advance.TabbarName[3],  bundle = "uis/images_atlas", asset = "tab_icon_fashion", func = "fashion_jinjie", tab_index = TabIndex.fashion_jinjie, remind_id = RemindName.AdvanceFashion},
		{name = Language.Advance.TabbarName[4],  bundle = "uis/images_atlas", asset = "tab_icon_wuqi", func = "player_role_shenbing", tab_index = TabIndex.role_shenbing, remind_id = RemindName.AdvanceShenbing},
		{name = Language.Advance.TabbarName[9],  bundle = "uis/images_atlas", asset = "tab_icon_pifeng", func = "cloak_jinjie", tab_index = TabIndex.cloak_jinjie , remind_id = RemindName.AdvanceCloak},
		{name = Language.Advance.TabbarName[10], bundle = "uis/images_atlas", asset = "tab_icon_lingren", func = "immortals_jinjie", tab_index = TabIndex.immortals_jinjie, remind_id = RemindName.AdvanceImmortals},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.OpenIndexCheck, self))
	self:SetTuPoTabButtonIcon()
	self.node_list["TxtTitle"].text.text = Language.Title.Advance
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.btn_close = self.node_list["BtnClose"]
	self.btn_close.button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Advance, BindTool.Bind(self.GetUiCallBack, self))

	self.shang_index = 1
end

function AdvanceView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end

function AdvanceView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function AdvanceView:FlushTabbar()	
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function AdvanceView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if not value then
		self:StopAutoAdvance()
	end
end

function AdvanceView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function AdvanceView:HandleClose()
	if self.show_index == TabIndex.immortals_jinjie or self.show_index == TabIndex.cloak_jinjie then
		self:Close()
	else
		AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Advance, self.show_index)
	end
end

function AdvanceView:MountUpgradeResult(result)
	if self.mount_view then
		self.mount_view:MountUpgradeResult(result)
	end
end

function AdvanceView:WingUpgradeResult(result)
	if self.wing_view then
		self.wing_view:WingUpgradeResult(result)
	end
end

function AdvanceView:HaloUpgradeResult(result)
	if self.halo_view then
		self.halo_view:HaloUpgradeResult(result)
	end
end

function AdvanceView:FootUpgradeResult(result)
	if self.foot_view then
		self.foot_view:FootUpgradeResult(result)
	end
end

function AdvanceView:CloakUpgradeResult(result)
	if self.cloak_view then
		self.cloak_view:CloakUpgradeResult(result)
	end
end

function AdvanceView:FashionUpgradeResult(result)
	if self.fashion_view then
		self.fashion_view:FashionUpgradeResult(result)
	end
end

function AdvanceView:WuQiUpgradeResult(result)
	if self.immortals_view then
		self.immortals_view:WuQiUpgradeResult(result)
	end
end

function AdvanceView:ShenBingUpgradeResult(result)
	if self.shenbing_view then
		self.shenbing_view:ShenBingUpgradeResult(result)
	end
end

function AdvanceView:FaBaoUpgradeResult(result)
	if self.fabao_view then
		self.fabao_view:FaBaoUpgradeResult(result)
	end
end

function AdvanceView:OnFightMountUpgradeResult(result)
	if self.fight_mount_view then
		self.fight_mount_view:OnFightMountUpgradeResult(result)
	end
end

function AdvanceView:SetClearData(data)
	self.data = data
end

function AdvanceView:OpenIndexCheck(to_index)
	if not self.is_open_bless_view then
		AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Advance, self.show_index, BindTool.Bind(self.ChangeToIndex, self), to_index)
		if self.data and self.data.cur_val > 0 and self.data.is_clear_bless == 1 then
			self.is_open_bless_view = true
		else
			self.is_open_bless_view = false
		end
	else
		self:ChangeToIndex(to_index)
	end
end

function AdvanceView:ShowIndexCallBack(index, index_nodes, is_jump)
	AdvanceData.Instance.Instance:SetViewType(0)
	for k,toggle_button in pairs(self.tabbar.tab_button_list) do
		local root_node = toggle_button.root_node
		if k == self.shang_index then
			root_node.toggle.interactable = true
			self.shang_index = k
		else
			root_node.toggle.interactable = false
		end
	end

	self.tabbar:ChangeToIndex(index, is_jump)
	if nil ~= index_nodes then

		if index == TabIndex.mount_jinjie then
			self.mount_view = AdvanceMountView.New(index_nodes["AdvanceContent"])
			self.mount_view:ResetModleRotation()
		elseif index == TabIndex.wing_jinjie then
			self.wing_view = AdvanceWingView.New(index_nodes["AdvanceContent"])
			self.wing_view:ResetModleRotation()
		elseif index == TabIndex.foot_jinjie then
			self.foot_view = AdvanceFootView.New(index_nodes["AdvanceContent"])
			self.foot_view:ResetModleRotation()
		elseif index == TabIndex.halo_jinjie then
			self.halo_view = AdvanceHaloView.New(index_nodes["AdvanceContent"])
			self.halo_view:ResetModleRotation()
		elseif index == TabIndex.fight_mount then
			self.fight_mount_view = AdvanceFightMountView.New(index_nodes["AdvanceContent"])
			self.fight_mount_view:ResetModleRotation()
		elseif index == TabIndex.role_shenbing then
			self.shenbing_view = AdvanceShenBingView.New(index_nodes["AdvanceContent"])
			self.shenbing_view:ResetModleRotation()
		elseif index == TabIndex.cloak_jinjie then
			self.cloak_view = AdvanceCloakView.New(index_nodes["CloakContent"])
			self.cloak_view:ResetModleRotation()
		elseif index == TabIndex.fashion_jinjie then
			self.fashion_view = AdvanceFashionView.New(index_nodes["AdvanceContent"])
			self.fashion_view:ResetModleRotation()
		elseif index == TabIndex.immortals_jinjie then
			self.immortals_view = AdvanceLingRenView.New(index_nodes["ShenBingContent"])
		elseif index == TabIndex.fabao_jinjie then
			self.fabao_view = AdvanceFaBaoView.New(index_nodes["AdvanceContent"])
			self.fabao_view:ResetModleRotation()
		end
	end

	self:StopAutoAdvance()
	self:ClearTempData()

	local prof = PlayerData.Instance:GetRoleBaseProf()
	if index == TabIndex.mount_jinjie then
		self.mount_view:OpenCallBack()
		self.mount_view:UIsMove()
		local callback = function()
			self.mount_view:Flush()
			self.mount_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
			transform.rotation = Quaternion.Euler(0, -170, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.wing_jinjie then
		self.wing_view:OpenCallBack()
		self.wing_view:UIsMove()
		local callback = function()
			self.wing_view:Flush()
			self.wing_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.foot_jinjie then
		self.foot_view:OpenCallBack()
		self.foot_view:UIsMove()
		local callback = function()
			self.foot_view:Flush()
			self.foot_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.halo_jinjie then
		self.halo_view:OpenCallBack()
		self.halo_view:UIsMove()
		local callback = function()
			self.halo_view:Flush()
			self.halo_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.fight_mount then
		self.fight_mount_view:OpenCallBack()
		self.fight_mount_view:UIsMove()
		local callback = function()
			self.fight_mount_view:Flush()
			self.fight_mount_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
			transform.rotation = Quaternion.Euler(25, -170, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.role_shenbing then
		self.shenbing_view:OpenCallBack()
		self.shenbing_view:UIsMove()
		local callback = function()
			self.shenbing_view:Flush()
			self.shenbing_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.cloak_jinjie then
		self.cloak_view:UIsMove()
		self.cloak_view:OpenCallBack()
		local callback = function()
			self.cloak_view:Flush()
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.fashion_jinjie then
		self.fashion_view:OpenCallBack()
		self.fashion_view:UIsMove()
		local callback = function()
			self.fashion_view:Flush()
			self.fashion_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.immortals_jinjie then
		self.immortals_view:UIsMove()
		local callback = function()
			self.immortals_view:Flush()
			self.immortals_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif index == TabIndex.fabao_jinjie then
		self.fabao_view:OpenCallBack()
		self.fabao_view:UIsMove()
		local callback = function()
			self.fabao_view:Flush()
			self.fabao_view:SetModle(true)
			UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
			UIScene:SetTerraceBg(nil, nil, {position = Vector3(-222, -275, 0)}, nil)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
			transform.rotation = Quaternion.Euler(0, -170, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	end

end

function AdvanceView:ClearTempData()
	if self.mount_view then
		self.mount_view:ClearTempData()
	end
	if self.wing_view then
		self.wing_view:ClearTempData()
	end
	if self.halo_view then
		self.halo_view:ClearTempData()
	end
	if self.foot_view then
		self.foot_view:ClearTempData()
	end
	if self.shenbing_view then
		self.shenbing_view:ClearTempData()
	end
	if self.cloak_view then
		self.cloak_view:ClearTempData()
	end
	if self.cloak_view then
		self.cloak_view:ClearTempData()
	end
	if self.fashion_view then
		self.fashion_view:ClearTempData()
	end
	if self.fabao_view then
		self.fabao_view:ClearTempData()
	end

	if self.fight_mount_view then
		self.fight_mount_view:ClearTempData()
	end
end

function AdvanceView:StopAutoAdvance()
	if self.mount_view and self.mount_view.is_auto then
		self.mount_view:OnAutomaticAdvance()
	end
	if self.wing_view and self.wing_view.is_auto then
		self.wing_view:OnAutomaticAdvance()
	end
	if self.halo_view and self.halo_view.is_auto then
		self.halo_view:OnAutomaticAdvance()
	end
	if self.foot_view and self.foot_view.is_auto then
		self.foot_view:OnAutomaticAdvance()
	end
	if self.fight_mount_view and self.fight_mount_view.is_auto then
		self.fight_mount_view:OnAutomaticAdvance()
	end
	if self.shenbing_view and self.shenbing_view.is_auto then
		self.shenbing_view:AutomaticAdvance()
	end
	if self.cloak_view and self.cloak_view.is_auto then
		self.cloak_view:OnAutomaticAdvance()
	end
	if self.fashion_view and self.fashion_view.is_automatic then
		self.fashion_view:AutomaticAdvance()
	end
	if self.immortals_view and self.immortals_view.is_auto then
		self.immortals_view:OnAutoJinJieClick()
	end
	if self.fabao_view and self.fabao_view.is_auto then
		self.fabao_view:OnAutomaticAdvance()
	end
end

function AdvanceView:CloseCallBack()
	AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
	FunctionGuide.Instance:DelWaitGuideListByName("mount_up")
	FunctionGuide.Instance:DelWaitGuideListByName("wing_up")

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self:StopAutoAdvance()

	if self.mount_view then
		self.mount_view:RemoveNotifyDataChangeCallBack()
	end
	if self.wing_view then
		self.wing_view:RemoveNotifyDataChangeCallBack()
	end
	if self.halo_view then
		self.halo_view:RemoveNotifyDataChangeCallBack()
	end
	if self.foot_view then
		self.foot_view:RemoveNotifyDataChangeCallBack()
	end
	if self.fight_mount_view then
		self.fight_mount_view:RemoveNotifyDataChangeCallBack()
	end
	if self.cloak_view then
		self.cloak_view:RemoveNotifyDataChangeCallBack()
	end
	if self.fashion_view then
		self.fashion_view:RemoveNotifyDataChangeCallBack()
	end
	if self.immortals_view then
		self.immortals_view:RemoveNotifyDataChangeCallBack()
	end
	if self.fabao_view then
		self.fabao_view:RemoveNotifyDataChangeCallBack()
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	self.notips = false

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end
	
	Scene.Instance:GetMainRole():FixMeshRendererBug()
end


function AdvanceView:OpenCallBack()
	AdvanceData.Instance:SetViewType(0)
	self.is_open_bless_view = false
	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.FlushBiPinIcon, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.notips = true
	self:FlushTabbar()
	self:FlushBiPinIcon()

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
		self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo.gold)
		self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo.bind_gold)
	end
	self.node_list["BaseFullPanel_1"]:SetActive(false)
	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("mount_up")
	FunctionGuide.Instance:TriggerGuideByName("wing_up")
	
end

function AdvanceView:ItemDataChangeCallback(item_id)
	local cur_index = self:GetShowIndex()

	if self.mount_view and cur_index == TabIndex.mount_jinjie then
		self.mount_view:ItemDataChangeCallback(item_id)
	elseif self.wing_view and cur_index == TabIndex.wing_jinjie then
		self.wing_view:ItemDataChangeCallback(item_id)
	elseif self.halo_view and cur_index == TabIndex.halo_jinjie then
		self.halo_view:ItemDataChangeCallback(item_id)
	elseif self.foot_view and cur_index == TabIndex.foot_jinjie then
		self.foot_view:ItemDataChangeCallback(item_id)
	elseif self.fight_mount_view and cur_index == TabIndex.fight_mount then
		self.fight_mount_view:ItemDataChangeCallback(item_id)
	elseif self.cloak_view and cur_index == TabIndex.cloak_jinjie then
		self.cloak_view:ItemDataChangeCallback(item_id)
	elseif self.fashion_view and cur_index == TabIndex.fashion_jinjie then
		self.fashion_view:ItemDataChangeCallback(item_id)
	elseif self.immortals_view and cur_index == TabIndex.immortals_jinjie then
		self.immortals_view:ItemDataChangeCallback(item_id)
	elseif self.fabao_view and cur_index == TabIndex.fabao_jinjie then
		self.fabao_view:ItemDataChangeCallback(item_id)
	elseif self.shenbing_view and cur_index == TabIndex.role_shenbing then
		self.shenbing_view:ItemDataChangeCallback(item_id)
	end

end

function AdvanceView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	local view_type = AdvanceData.Instance:GetViewType()
	for k, v in pairs(param_list) do
		if k == "mount" then
			if self.mount_view and cur_index == TabIndex.mount_jinjie then
				self.mount_view:Flush()
			end
		elseif k == "wing" then
			if self.wing_view and cur_index == TabIndex.wing_jinjie then
				self.wing_view:Flush()
			end
		elseif k == "halo" then
			if self.halo_view and cur_index == TabIndex.halo_jinjie then
				self.halo_view:Flush()
			end
		elseif k == "foot" then
			if self.foot_view and cur_index == TabIndex.foot_jinjie then
				self.foot_view:Flush()
			end
		elseif k == "fightmount" then
			if self.fight_mount_view and cur_index == TabIndex.fight_mount then
				self.fight_mount_view:Flush()
			end
		elseif k == "shenbing" then
			if self.shenbing_view and cur_index == TabIndex.role_shenbing then
				self.shenbing_view:Flush()
			end
		elseif k == "cloak" then
			if self.cloak_view and cur_index == TabIndex.cloak_jinjie then
				self.cloak_view:Flush()
			end
		elseif k == "fashion" then
			if self.fashion_view  and cur_index == TabIndex.fashion_jinjie and view_type == 0 then
				self.fashion_view:Flush()
			end
		elseif k == "fabao" and cur_index == TabIndex.fabao_jinjie then
			if self.fabao_view then
				self.fabao_view:Flush()
			end	
		elseif k == "upgraderesult" then
			if self.immortals_view then
				self.immortals_view:Flush("upgraderesult", {v[1]})
			end
		elseif k == "all" then
			--self:StopAutoAdvance()
			if self.mount_view and cur_index == TabIndex.mount_jinjie then
				self.mount_view:Flush(param_list)
				self.mount_view:ResetModleRotation()
			elseif self.wing_view and cur_index == TabIndex.wing_jinjie then
				self.wing_view:Flush(param_list)
			elseif self.halo_view and cur_index == TabIndex.halo_jinjie then
				self.halo_view:Flush(param_list)
			elseif self.foot_view and cur_index == TabIndex.foot_jinjie then
				self.foot_view:Flush(param_list)
			elseif self.fight_mount_view and cur_index == TabIndex.fight_mount then
				self.fight_mount_view:Flush(param_list)
			elseif self.cloak_view and cur_index == TabIndex.cloak_jinjie then
				self.cloak_view:Flush(param_list)
			elseif self.fashion_view and cur_index == TabIndex.fashion_jinjie and view_type == 0 then
				self.fashion_view:Flush(param_list)
			elseif self.immortals_view and cur_index == TabIndex.immortals_jinjie then
				self.immortals_view:Flush(param_list)
			elseif self.fabao_view and cur_index == TabIndex.fabao_jinjie then
				self.fabao_view:Flush(param_list)
			elseif self.shenbing_view and cur_index == TabIndex.role_shenbing then
				self.shenbing_view:Flush(param_list)
			end
		end
	end
end

function AdvanceView:FlushBiPinIcon()
	-- for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
	-- 	if self.bipin_icon_list[k] then
	-- 		self.bipin_icon_list[k]:SetActive(ActivityData.Instance:GetActivityIsOpen(v))
	-- 	end
	-- end
end

function AdvanceView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		return self.tabbar:GetTabButton(index), BindTool.Bind(self.ChangeToIndex, self, index)
	elseif ui_name == GuideUIName.AdvanceMountUp then
		if self.mount_view and self.mount_view.GetStartButton then
			return self.mount_view:GetStartButton()
		end
	elseif self.node_list[ui_name] then
		if self.node_list[ui_name].gameObject.activeInHierarchy then
			return self.node_list[ui_name]
		end
	end
end


function AdvanceView:SetTuPoTabButtonIcon()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local tab_index = COMPETITION_ACTIVITY_DAY_TO_TABINDEX[cur_day]
	if tab_index and self.tabbar then
		local tab_button = self.tabbar:GetTabButton(tab_index)
		if tab_button then
			tab_button:ShowBiPin(true)
		end
	end	
end
