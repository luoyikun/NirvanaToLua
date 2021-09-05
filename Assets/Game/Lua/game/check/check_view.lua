require("game/check/check_present_view")
require("game/check/check_appearance_view")


CheckView = CheckView or BaseClass(BaseView)

function CheckView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/checkview_prefab", "ModelDragLayer"},
		{"uis/views/checkview_prefab", "InfoContent", {CHECK_TAB_NEW_TYPE.JUE_SE}},
		{"uis/views/checkview_prefab", "CheckAppearanceContent", {CHECK_TAB_NEW_TYPE.APPEARANCE}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
	}

	self.camera_mode = UICameraMode.UICameraMid

	self.full_screen = true
	self.play_audio = true
	self.is_cell_active = false
	self.is_set_jump = false
	self.def_index = CHECK_TAB_NEW_TYPE.JUE_SE
	self.tab_index = CHECK_TAB_NEW_TYPE.JUE_SE

	local check_tab_name = Language.Common.CheckTabNewName
	local bundle = "uis/images_atlas"
	self.tab_cfg = {
		[CHECK_TAB_NEW_TYPE.JUE_SE] = {name = check_tab_name[1],	bundle = bundle, asset = "icon_msg", 		tab_index = CHECK_TAB_NEW_TYPE.JUE_SE },
		[CHECK_TAB_NEW_TYPE.APPEARANCE] = {name = check_tab_name[2],bundle = bundle, asset = "tab_icon_appearance", 	tab_index = CHECK_TAB_NEW_TYPE.APPEARANCE },
	}

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.cell_list = {}
	self.view_list = {}
end

function CheckView:LoadCallBack()
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.AddMoneyClick, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TxtTitle"].text.text = Language.Rank.JueSeChaKan
	self.node_list["UnderBg"]:SetActive(true)

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	self.rotate_event_trigger = self.node_list["RotateEventTrigger"]
	local event_trigger = self.rotate_event_trigger.event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	self.baizhan_flag = nil
end

function CheckView:BanZhanChange(flag)
	self.baizhan_flag = flag
	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if self.check_foot_view then
			self.check_foot_view:StopFoot()
		end
	end
	UIScene:ClearWeiYanData()
	self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("bg_common1_under", true))
	self.node_list["TaiZi"]:SetActive(true)

	if self.baizhan_flag == true then
		local role_info = CheckData.Instance:GetRoleInfo()
		local base_prof = PlayerData.Instance:GetRoleBaseProf(role_info.prof)
		local callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)
	elseif self.baizhan_flag == false then
		UIScene:ChangeScene(nil)

		self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("BaiZhanBG", true))
		self.node_list["TaiZi"]:SetActive(false)		
	end
	self:FlushIndex(CHECK_TAB_NEW_TYPE.JUE_SE)
end

function CheckView:ShowIndexCallBack(index, index_nodes)
	if nil ~= self.tabbar then
		self.tabbar:ChangeToIndex(index)
	end	
	if index_nodes then
		if index == CHECK_TAB_NEW_TYPE.JUE_SE then
			self.view_list[CHECK_TAB_NEW_TYPE.JUE_SE] = CheckPresentView.New(index_nodes["InfoContent"])
		elseif index == CHECK_TAB_NEW_TYPE.APPEARANCE then
			self.view_list[CHECK_TAB_NEW_TYPE.APPEARANCE] = CheckAppearanceView.New(index_nodes["CheckAppearanceContent"], self)
		end
	end

	if UIScene.role_model then
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if self.check_foot_view then
			self.check_foot_view:StopFoot()
		end
	end

	self.node_list["BaseFullPanel_1"]:SetActive(true)

	UIScene:ClearWeiYanData()

	local role_info = CheckData.Instance:GetRoleInfo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf(role_info.prof)

	local callback = nil
	if index == CHECK_TAB_NEW_TYPE.JUE_SE then
		self.view_list[CHECK_TAB_NEW_TYPE.JUE_SE]:DoPanelTweenPlay()
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, -168, 0)
			UIScene:SetCameraTransform(transform)
		end
		self.node_list["RotateEventTrigger"].transform.localPosition = Vector3(-197, 0, 0)
		self.node_list["TaiZi"].transform.localPosition = Vector3(-236, -318, 0)
	elseif index == CHECK_TAB_NEW_TYPE.APPEARANCE then
		self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("bg_common1_under", true))
		self.node_list["RotateEventTrigger"].transform.localPosition = Vector3(93, 0, 0)
		self.node_list["TaiZi"].transform.localPosition = Vector3(210, -318, 0)
		self.node_list["TaiZi"]:SetActive(true)
	end
	if index == CHECK_TAB_NEW_TYPE.JUE_SE and self.baizhan_flag == false then
		UIScene:ChangeScene(nil)
		self.node_list["UnderBg"].raw_image:LoadSprite(ResPath.GetRawImage("BaiZhanBG", true))
		self.node_list["TaiZi"]:SetActive(false)		
	else
		UIScene:ChangeScene(self, callback)
	end	
	self:FlushIndex(index)
end

function CheckView:FlushIndex(index)
	if self.view_list[index] then
		self.view_list[index]:SetAttr()
	end
end

function CheckView:ReleaseCallBack()
	for k,v in pairs(self.view_list) do
		v:DeleteMe()
	end
	self.view_list = {}

	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = {}

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)

	self.rotate_event_trigger = nil
	self.list_view = nil
	self.is_cell_active = false
	self.is_set_jump = false --是否外部设置跳转

	self.baizhan_flag = nil
end

function CheckView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function CheckView:Open(index)
	BaseView.Open(self, index)
end

function CheckView:OnFlush(param_t)
	local index = self:GetCurIndex()
	self:FlushIndex(index)
end

function CheckView:OpenCallBack()
	local scene_load_callback = function()
		self:Flush()
	end
	UIScene:ChangeScene(self, scene_load_callback)

	if not self.is_set_jump then
		self.tab_index = CHECK_TAB_NEW_TYPE.JUE_SE
	end
	self.jump_flag = true

	local list = {}
	local index_list = CheckData.Instance:GetShowTabIndex()
	if #index_list > 1 then
		list = self.tab_cfg
	else
		list[1] = self.tab_cfg[1]
	end

	self.tabbar = self.tabbar or TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], list)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self:ChangeToIndex(self.tab_index)
end

function CheckView:CloseCallBack()
	self.is_set_jump = false
	UIScene:IsNotCreateRoleModel(false)
	local is_return = PlayerData.Instance:GetIsReturnTalkSystem()
	if is_return then
		PlayerData.Instance:SetIsReturnTalkSystem(false)
		ViewManager.Instance:Open(ViewName.Chat, TabIndex.chat_system)
	end

	if self.view_list[CHECK_TAB_NEW_TYPE.APPEARANCE] then
		self.view_list[CHECK_TAB_NEW_TYPE.APPEARANCE]:CloseCallBack()
	end
	RankCtrl.Instance:ClearRankRoleIDCache()
end

function CheckView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function CheckView:OnUiSceneLoadingQuite()
	local role_info = CheckData.Instance:GetRoleInfo()
	UIScene:ResetLocalPostion()
	UIScene:SetRoleModelResInfo(role_info)
	UIScene:SetActionEnable(true)
	UIScene:DeleteModel()
end

function CheckView:CloseOnClick()
	self:Close()
end

function CheckView:AddMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CheckView:SetCurIndex(tab_index, is_set_jump)
	self.tab_index = tab_index
	self.is_set_jump = is_set_jump
end

function CheckView:GetCurIndex()
	return self.tab_index
end

function CheckView:CheckToJump()
	if self.tab_count == 9 then
		if self.tab_index >= 9 then
			self:BagJumpPage(2)
		else
			self:BagJumpPage(0)
		end
	end
	self.jump_flag = false
	self.is_set_jump = false
end

function CheckView:BagJumpPage(page)
	self.list_view.scroller:JumpToDataIndex(page)
end

function CheckView:SetOpenType(open_type)
	self.open_type = open_type
end

-- 玩家钻石改变时
function CheckView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function CheckView:CancellAllQuest()
	if self.check_shengong_view then
		self.check_shengong_view:CancelTheQuest()
	end
	if self.check_shenyi_view then
		self.check_shenyi_view:CancelTheQuest()
	end
end

function CheckView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

function CheckView:SetModle(select_type)
	UIScene:ClearWeiYanData()

	local role_info = CheckData.Instance:GetRoleInfo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf(role_info.prof)
	local index = select_type

	local callback = nil
	if index == CHECK_TAB_TYPE.MOUNT then
		-- UIScene:SetBackground("uis/rawimages/bg_common1_under", "bg_common1_under.jpg")
		-- UIScene:SetTerraceBg(nil, nil, {position = Vector3(-185, -272, 0)}, nil)
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.WING then
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.HALO then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end			

	elseif index == CHECK_TAB_TYPE.FIGHT_MOUNT then
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.SPIRIT then
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.GODDESS then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			transform.rotation = Quaternion.Euler(7.5, 180, 0)
			UIScene:SetCameraTransform(transform, {x = 0.34})
		end

	elseif index == CHECK_TAB_TYPE.SHEN_GONG then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			transform.rotation = Quaternion.Euler(7.5, 180, 0)
			UIScene:SetCameraTransform(transform, {x = 0.34})
		end			

	elseif index == CHECK_TAB_TYPE.SHEN_YI then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
			transform.rotation = Quaternion.Euler(7.5, 180, 0)
			UIScene:SetCameraTransform(transform, {x = 0.34})
		end			

	elseif index == CHECK_TAB_TYPE.FOOT then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end			

	elseif index == CHECK_TAB_TYPE.CLOAK then
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.FABAO then
		callback = function()
		end

	elseif index == CHECK_TAB_TYPE.SHIZHUANG then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end			

	elseif index == CHECK_TAB_TYPE.TOUSHI then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end	

	elseif index == CHECK_TAB_TYPE.MASK then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end	

	elseif index == CHECK_TAB_TYPE.YAOSHI then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)

			UIScene:SetModelLoadCallBack(function(model, obj)
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 40, 0)
			end)
		end	

	elseif index == CHECK_TAB_TYPE.QILINBI then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "arm")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.LINGZHU then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingzhu")
			transform.rotation = Quaternion.Euler(0, 180, 0)
			UIScene:SetCameraTransform(transform, {x = 0.34})
		end

	elseif index == CHECK_TAB_TYPE.XIANBAO then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "xianbao")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.LINGTONG then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingchong")
			transform.rotation = Quaternion.Euler(4, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.LINGGONG then
		callback = function()
			local call_back = function(model, obj)
				if obj then
					-- obj.gameObject.transform.localRotation = Quaternion.Euler(-30, -90, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "linggong")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.LINGQI then
		callback = function()
			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingqi")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.WEIYAN then
		callback = function()
			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, 120, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
			transform.position = Vector3(transform.position.x, transform.position.y, transform.position.z + 2)
			transform.rotation = Quaternion.Euler(0, 172, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.SHOUHUAN then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.TAIL then
		callback = function()
			local call_back = function(model, obj)
				if obj then
					local role_prof = PlayerData.Instance:GetRoleBaseProf()
					if obj then
						if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
							obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
						else
							obj.gameObject.transform.localRotation = Quaternion.Euler(0, 160, 0)
						end
					end
				end
			end
			UIScene:SetModelLoadCallBack(call_back)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end

	elseif index == CHECK_TAB_TYPE.FLYPET then
		callback = function()
			local call_back = function(model, obj)
				if obj then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "flypet")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end
	elseif index == CHECK_TAB_TYPE.LINGREN then
		callback = function()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "hunqi")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)
		end
	elseif index == CHECK_TAB_TYPE.SHENBING then
		callback = function()
			local call_back = function(model, obj)
				local role_info = CheckData.Instance:GetRoleInfo()
				if role_info == nil then return end
				local prof = role_info.prof % 10
				if obj then
					local rotation = nil
					if prof == GameEnum.ROLE_PROF_4 then
						rotation = Quaternion.Euler(0, -45, 0)
					elseif prof == GameEnum.ROLE_PROF_1 then
						rotation = Quaternion.Euler(0, -90, 0)
					else
						rotation = Quaternion.Euler(0, 0, 0)
					end
					obj.gameObject.transform.localRotation = rotation
				end
			end
			UIScene:SetModelLoadCallBack(call_back)
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role")
			transform.rotation = Quaternion.Euler(8, 169, 0)
			UIScene:SetCameraTransform(transform)
		end
	end
	UIScene:ChangeScene(self, callback)
end