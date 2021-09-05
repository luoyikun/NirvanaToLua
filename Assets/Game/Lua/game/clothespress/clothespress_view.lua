require("game/clothespress/clothespress_suit_view")
-- require("game/clothespress/clothespress_looks_view")
-- require("game/clothespress/clothespress_dress_view")
require("game/clothespress/clothespress_exchange_view")

local SUIT_TOGGLE = 1
local LOOKS_TOGGLE = 2
local DRESS_TOGGLE = 3
local EXCHANGE_TOGGLE = 4

ClothespressView = ClothespressView or BaseClass(BaseView)


function ClothespressView:__init()
	self.ui_config = {
		{"uis/views/clothespress_prefab", "ClothespressView"},
		{"uis/views/advanceview_prefab", "ModelDragLayer"}, 
		{"uis/views/clothespress_prefab", "SuitContent", {TabIndex.clothespress_suit}},				--套装
		{"uis/views/clothespress_prefab", "ExchangeContent", {TabIndex.clothespress_exchange}},		--兑换
		-- {"uis/views/clothespress_prefab", "LooksContent", {TabIndex.clothespress_looks}},			--比拼
		-- {"uis/views/clothespress_prefab", "DressContent", {TabIndex.clothespress_dress}},			--装扮
		-- {"uis/views/clothespress_prefab", "ClothespressView2"},
	}

	self.def_index = TabIndex.clothespress_suit
	self.camera_mode = UICameraMode.UICameraMid

	self.play_audio = true
	self.is_modal = true
	self.full_screen = true
end

function ClothespressView:LoadCallBack(index, index_nodes)
	self.tab_cfg = {
		{name = Language.FuBen.TabbarName[1], tab_index = TabIndex.clothespress_suit},
		{name = Language.FuBen.TabbarName[2], tab_index = TabIndex.clothespress_exchange},
		-- {name = Language.FuBen.TabbarName[3], tab_index = TabIndex.fb_phase, remind_id = RemindName.FuBen_JinJie},
		-- {name = Language.FuBen.TabbarName[4], tab_index = TabIndex.fb_phase, remind_id = RemindName.FuBen_JinJie},
	}

	-- self.tabbar = TabBarTwo.New()
	-- self.tabbar:Init(self, self.node_list["TabPanel"], self.tab_cfg)
	-- self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["ToggleSuit"].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, TabIndex.clothespress_suit))
	self.node_list["ToggleExchange"].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, TabIndex.clothespress_exchange))

	-- self.node_list["StuffBg"]:SetActive(self.def_index == TabIndex.clothespress_exchange)

	local event_trigger = self.node_list["RotateEventTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))
end

function ClothespressView:__delete()

end

function ClothespressView:ReleaseCallBack()
	self.show_lock = nil
	self.show_exchange_lock = nil
	self.def_index = TabIndex.clothespress_suit
	-- self.tabbar:DeleteMe()
	-- self.tabbar = nil

	if self.suit_view then
		self.suit_view:DeleteMe()
		self.suit_view = nil
	end
	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end

	self.red_point_list = {}
end

function ClothespressView:OpenCallBack()
	-- 监听系统事件
	if self.suit_view then
		self:ResetModel()
	end
end

function ClothespressView:CloseCallBack()
	self.cur_system_type = -1
end

function ClothespressView:OnRoleDrag(data)
	if UIScene.role_model then
		UIScene:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ClothespressView:ShowIndexCallBack(index, index_nodes)
	if nil ~= index_nodes then
		if index == TabIndex.clothespress_suit then
			self.suit_view = ClothespressSuitView.New(index_nodes["SuitContent"])
			self.suit_view:SetClickCallBack(BindTool.Bind(self.SetModle, self))	
		elseif index == TabIndex.clothespress_exchange then
			self.exchange_view = ClothespressExchangeView.New(index_nodes["ExchangeContent"])
			self.exchange_view:SetClickCallBack(BindTool.Bind(self.SetModle, self))
		elseif index == TabIndex.clothespress_looks then
			self.looks_view = ClothespressLooksView.New(index_nodes["LooksContent"])
		elseif index == TabIndex.clothespress_dress then
			self.dress_view = ClothespressDressView.New(index_nodes["DressContent"])
		end
	end
	self.def_index = index
	-- self.node_list["StuffBg"]:SetActive(self.def_index == TabIndex.clothespress_exchange)
	if index == TabIndex.clothespress_suit and self.suit_view then
		self.suit_view:Flush()
		self:ResetModel()
	elseif index == TabIndex.clothespress_exchange and self.exchange_view then 
		self.exchange_view:Flush()
		self:ResetModel()
	elseif index == TabIndex.clothespress_looks and self.looks_view then 
		self.looks_view:Flush()
	elseif index == TabIndex.clothespress_dress and self.dress_view then 
		self.dress_view:Flush()
	end
end

function ClothespressView:ResetModel()
	local select_suit = ClothespressData.Instance:GetSelectSuitIndex()
	local last_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	self:SetModle(select_suit, last_index)
end

function ClothespressView:OnFlush(param_t)
	if self.def_index == TabIndex.clothespress_suit and self.suit_view then
		self.suit_view:Flush()
	elseif self.def_index == TabIndex.clothespress_exchange and self.exchange_view then 
		self.exchange_view:Flush()
	end
end

function ClothespressView:SetModle(suit_index, sub_index)
	if suit_index == nil or sub_index == nil then return end

	local modle_info = ClothespressData.Instance:GetSingleModleInfo(suit_index, sub_index)
	if modle_info == nil or next(modle_info) == nil then
		return
	end
	self.cur_list_index = ClothespressData.Instance:GetSelectSuitIndex() 
	self.cur_system_type = modle_info.system_type

	if modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then			
		self:SetMountModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then 		-- 双骑
		self:SetMultiMountModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then			
		self:SetWingModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then 		
		self:SetShiZhuanModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then 		
		self:SetSpiritModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then 		
		self:SetShenBingModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FABAO then 			
		self:SetFaBaoModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then 			
		self:SetFootModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then 			
		self:SetHaloModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then 	
		self:SetFightMountModel(modle_info)

	-- elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then 		
	-- 	self:SetCloakModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then 		
		self:SetTouShiModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then 			
		self:SetMaskModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then 		
		self:SetYaoShiModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then 		
		self:SetQiLinBiModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENGONG then 	
		self:SetShenGongModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENYI then 		
		self:SetShenYiModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then 		
		self:SetGoddessModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGZHU then 		
		self:SetLingZhuModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANBAO then 		
		self:SetXianBaoModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGTONG then 		
		self:SetLingTongModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGGONG then 		
		self:SetLingGongModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGQI then		
		self:SetLingQiModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WEIYAN then 		
		self:SetWeiYanModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHOUHUAN then 		
		self:SetShouHuanModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TAIL then 			
		self:SetTailModel(modle_info)

	elseif modle_info.system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FLYPET then 
		self:SetFlyPetModel(modle_info)

	end
end

-- 坐骑
function ClothespressView:SetMountModel(modle_info)
	local mount_res_id = modle_info.mount_res_id

	local callback = function()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
		end
	UIScene:ChangeScene(self, callback)

	local call_back = function(model, obj)
		model:SetTrigger(ANIMATOR_PARAM.REST)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -60, 0)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	local bundle, asset = ResPath.GetMountModel(mount_res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

function ClothespressView:SetMultiMountModel(modle_info)
	local multi_res_id = modle_info.multi_mount_res_id
	if multi_res_id == 0 then return end

	local callback = function()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "multimount")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	UIScene:SetModelLoadCallBack(function(model, obj)
		model:SetTrigger(ANIMATOR_PARAM.REST)
		obj.gameObject.transform.localRotation = Quaternion.Euler(0, -45, 0)
		obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
	end)

	local bundle, asset = ResPath.GetMountModel(multi_res_id)
	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

-- 羽翼
function ClothespressView:SetWingModel(modle_info)
	local wing_res_id = modle_info.role_info.appearance.wing_used_imageid
	local role_info = PlayerData.Instance:GetRoleVo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
			if obj then
				model:SetTrigger(ANIMATOR_PARAM.STATUS)
				if base_prof == GameEnum.ROLE_PROF_3 or base_prof == GameEnum.ROLE_PROF_2 then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -155, 0)
				elseif base_prof == GameEnum.ROLE_PROF_1 then
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
				else
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
				end
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end
		end)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local info = {}
	info.wing_info = {used_imageid = wing_res_id}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.is_not_show_weapon = true
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}

	UIScene:SetRoleModelResInfo(info, true, false, true, true, false, true)
	UIScene:SetActionEnable(false)
end

-- 时装
function ClothespressView:SetShiZhuanModel(modle_info)
	local fashion_res_id = modle_info.role_info.appearance.fashion_body
	local role_info = PlayerData.Instance:GetRoleVo()

	if fashion_res_id ~= 0 then
		local callback = function()
			UIScene:SetModelLoadCallBack(function(model, obj)
				model:SetTrigger(ANIMATOR_PARAM.REST)
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end)

			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
			transform.rotation = Quaternion.Euler(9, 195, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

		local info = TableCopy(role_info)
		info.appearance = {}
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = false
		info.appearance.fashion_body_is_special = true
		info.appearance.fashion_body = fashion_res_id
		UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
		UIScene:ResetLocalPostion()
	end
end

-- 宠物
function ClothespressView:SetSpiritModel(modle_info)
	UIScene:SetActionEnable(false)

	if modle_info.sprite_info ~= nil then
		local callback = function()
			UIScene:SetModelLoadCallBack(function(model, obj)
				model:SetTrigger(ANIMATOR_PARAM.REST)
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(0, 195, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

		local bundle, asset = ResPath.GetSpiritModel(modle_info.sprite_info.res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end
end

-- 神兵
function ClothespressView:SetShenBingModel(modle_info)
	local role_info = PlayerData.Instance:GetRoleVo()
	local base_prof = PlayerData.Instance:GetRoleBaseProf()

	if modle_info.role_info.appearance ~= nil then
		local callback = function()
			local call_back = function(model, obj)
				if obj then
					local rotation = nil
					if base_prof == GameEnum.ROLE_PROF_4 then
						rotation = Quaternion.Euler(0, -45, 0)
					elseif base_prof == GameEnum.ROLE_PROF_1 then
						rotation = Quaternion.Euler(0, -90, 0)
					else
						rotation = Quaternion.Euler(0, 0, 0)
					end
					obj.gameObject.transform.localRotation = rotation
					obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role")
			transform.rotation = Quaternion.Euler(8, 195, 0)
			UIScene:SetCameraTransform(transform)
		end
		UIScene:ChangeScene(self, callback)

		local info = {}
		info.prof = role_info.prof
		info.sex = role_info.sex
		info.is_not_show_weapon = false
		local fashion_info = FashionData.Instance:GetFashionInfo()
		local is_used_special_img = fashion_info.is_used_special_img
		info.is_normal_fashion = is_used_special_img == 0 and true or false
		local wuqi_id = modle_info.role_info.appearance.fashion_wuqi
		info.shizhuang_part_list = {{image_id = wuqi_id}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
		UIScene:SetRoleModelResInfo(info)

		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetBool(ANIMATOR_PARAM.FIGHT, true)
		end
	end
end

-- 法宝
function ClothespressView:SetFaBaoModel(modle_info)
	local callback = function()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
		model:SetTrigger(ANIMATOR_PARAM.REST)
	end
	UIScene:SetModelLoadCallBack(call_back)

	local used_imageid = modle_info.role_info.appearance.fabao_used_imageid - 1000
	local fabao_res_id = FaBaoData.Instance:GetSpecialImagesCfg()[used_imageid].res_id
	local call_back = function(model, obj)
		model:SetTrigger(ANIMATOR_PARAM.REST)
	end
	UIScene:SetModelLoadCallBack(call_back)
	local bundle, asset = ResPath.GetFaBaoModel(fabao_res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

-- 足印
function ClothespressView:SetFootModel(modle_info)
	local callback = function()
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local call_back = function(model, obj)
		if obj then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	local foot_res_id = modle_info.role_info.appearance.footprint_used_imageid
	-- local foot_res_id = FootData.Instance:GetSpecialImagesCfg()[used_imageid].res_id
	
	local role_info = PlayerData.Instance:GetRoleVo()
	local info = TableCopy(role_info)
	info.appearance = {}
	info.foot_info = {used_imageid = foot_res_id}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, true, true, true)
	UIScene:SetActionEnable(false)
end

-- 光环
function ClothespressView:SetHaloModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local fabao_res_id = modle_info.role_info.appearance.halo_used_imageid
	-- local fabao_res_id = HaloData.Instance:GetSpecialImagesCfg()[used_imageid].res_id

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = TableCopy(role_info)
	info.appearance = {}
	info.halo_info = {used_imageid = fabao_res_id}
	UIScene:SetRoleModelResInfo(info, true, true, false, true, false, true)
	UIScene:ResetLocalPostion()
	UIScene:SetActionEnable(false)
end

-- 战斗坐骑
function ClothespressView:SetFightMountModel(modle_info)
	local callback = function()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
		transform.rotation = Quaternion.Euler(25, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local mount_res_id = modle_info.fight_mount_res_id
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
		model:SetTrigger(ANIMATOR_PARAM.REST)
	end
	UIScene:SetModelLoadCallBack(call_back)
	local bundle, asset = ResPath.GetFightMountModel(mount_res_id)
	local bundle_list = {[SceneObjPart.Main] = bundle}
	local asset_list = {[SceneObjPart.Main] = asset}
	UIScene:ModelBundle(bundle_list, asset_list)
end

-- 披风
function ClothespressView:SetCloakModel(modle_info)
	local callback = function()
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = TableCopy(role_info)
	info.appearance = {}
	info.cloak_info = {used_imageid = index}

	local call_back = function(model, obj)
		local prof = PlayerData.Instance:GetRoleBaseProf()
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS)
			if prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
			elseif prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 145, 0)
			end
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, false)
	UIScene:SetActionEnable(false)
end

-- 头饰
function ClothespressView:SetTouShiModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.toushi_used_imageid = modle_info.role_info.appearance.toushi_used_imageid
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

-- 面具
function ClothespressView:SetMaskModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.mask_used_imageid = modle_info.role_info.appearance.mask_used_imageid
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

-- 腰饰
function ClothespressView:SetYaoShiModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.yaoshi_used_imageid = modle_info.role_info.appearance.yaoshi_used_imageid
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

-- 麒麟臂
function ClothespressView:SetQiLinBiModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "arm")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local image_id = modle_info.role_info.appearance.qilinbi_used_imageid - 1000
	local image_info = QilinBiData.Instance:GetSpecialImage()[image_id]

	local role_info = PlayerData.Instance:GetRoleVo()
	local bundle, asset = ResPath.GetQilinBiModel(image_info["res_id" .. role_info.sex .. "_h"], role_info.sex)
	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

-- 仙环
function ClothespressView:SetShenGongModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
		transform.rotation = Quaternion.Euler(8, 195, 0)
		UIScene:SetCameraTransform(transform, {x = 0.34})
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local info = {}
	info.role_res_id = modle_info.goddess_info.goddess_res_id
	info.halo_res_id = modle_info.goddess_info.goddess_halo_id

	local bundle1, asset1 = ResPath.GetGoddessModel(info.role_res_id)
	local bundle2, asset2 = ResPath.GetGoddessHaloModel(info.halo_res_id)

	local load_list = {{bundle2, asset2}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		UIScene:SetGoddessModelResInfo(info)
	end)
end

-- 仙阵
function ClothespressView:SetShenYiModel(modle_info)
	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
		transform.rotation = Quaternion.Euler(8, 195, 0)
		UIScene:SetCameraTransform(transform, {x = 0.34})
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local info = {}
	info.role_res_id = modle_info.goddess_info.goddess_res_id
	info.fazhen_res_id = modle_info.goddess_info.goddess_fazhen_id

	local bundle1, asset1 = ResPath.GetGoddessModel(info.role_res_id)
	local bundle2, asset2 = ResPath.GetGoddessHaloModel(info.fazhen_res_id)

	local load_list = {{bundle2, asset2}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		UIScene:SetGoddessModelResInfo(info)
	end)
end

-- 仙女
function ClothespressView:SetGoddessModel(modle_info)
	UIScene:SetActionEnable(false)

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "goddess")
		transform.rotation = Quaternion.Euler(8, 195, 0)
		UIScene:SetCameraTransform(transform, {x = 0.34})
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local info = {}
	info.role_res_id = modle_info.goddess_info.goddess_res_id
	UIScene:SetGoddessModelResInfo(info)
end

-- 灵珠
function ClothespressView:SetLingZhuModel(modle_info)
	local lingzhu_res_id = modle_info.sprite_info.lingzhu_res_id

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingzhu")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		-- UIScene:SetCameraTransform(transform, {x = 0.34})
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local bundle, asset = ResPath.GetLingZhuModel(lingzhu_res_id, true)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

-- 仙宝
function ClothespressView:SetXianBaoModel(modle_info)
	local xianbao_res_id = modle_info.xianbao_info.res_id

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "xianbao")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local bundle, asset = ResPath.GetXianBaoModel(xianbao_res_id, true)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

-- 灵童
function ClothespressView:SetLingTongModel(modle_info)
	local lingtong_res_id = modle_info.lingtong_info.res_id
	if lingtong_res_id == 0 then return end

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingchong")
		transform.rotation = Quaternion.Euler(2, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	-- local bundle_effect, asset_effect = ResPath.GetLingChongModelEffect(lingtong_res_id)
	-- UIScene:LoadSceneEffect(bundle_effect, asset_effect)
	local bundle, asset = ResPath.GetLingChongModel(lingtong_res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
		end)
end

-- 灵弓
function ClothespressView:SetLingGongModel(modle_info)
	local linggong_res_id = modle_info.lingtong_info.linggong_res_id
	if linggong_res_id == 0 then return end

	local callback = function()
		local call_back = function(model, obj)
			if obj then
				-- obj.gameObject.transform.localRotation = Quaternion.Euler(-30, -195, 0)
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "linggong")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local bundle, asset = ResPath.GetLingGongModel(linggong_res_id)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

-- 灵骑
function ClothespressView:SetLingQiModel(modle_info)
	local lingqi_res_id = modle_info.lingtong_info.lingqi_res_id
	if lingqi_res_id == 0 then return end

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "lingqi")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local bundle, asset = ResPath.GetLingQiModel(lingqi_res_id, true)
	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end

-- 尾焰
function ClothespressView:SetWeiYanModel(modle_info)
	local mount_res_id = modle_info.mount_res_id
	local weiyan_res_id = modle_info.weiyan_res_id
	if weiyan_res_id == 0 then return end

	local callback = function()
		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 120, 0)
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
		-- transform.position = Vector3(transform.position.x, transform.position.y, transform.position.z + 2)
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
	local load_list = {{mount_bundle, mount_asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		UIScene:SetWeiYanResid(weiyan_res_id, mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = mount_bundle}
		local asset_list = {[SceneObjPart.Main] = mount_asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		end
	end)
end

-- 手环
function ClothespressView:SetShouHuanModel(modle_info)
	local shouhuan_res_id = modle_info.role_info.appearance.shouhuan_used_imageid
	if shouhuan_res_id == 0 then return end
	local callback = function()
		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 90, 0)
				obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.shouhuan_used_imageid = shouhuan_res_id
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)	
end

-- 尾巴
function ClothespressView:SetTailModel(modle_info)
	local tail_res_id = modle_info.role_info.appearance.tail_used_imageid
	local base_prof = PlayerData.Instance:GetRoleBaseProf()
	if tail_res_id == 0 then return end

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
			if base_prof == GameEnum.ROLE_PROF_1 or base_prof == GameEnum.ROLE_PROF_3 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 130, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 160, 0)
			end
		end)
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(9, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	local role_info = PlayerData.Instance:GetRoleVo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.tail_used_imageid = tail_res_id
	local fashion_info = FashionData.Instance:GetFashionInfo()
	local is_used_special_img = fashion_info.is_used_special_img
	info.is_normal_fashion = is_used_special_img == 0 and true or false
	info.shizhuang_part_list = {{image_id = 0}, {image_id = is_used_special_img == 0 and fashion_info.use_clothing_index or fashion_info.use_special_img}}
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
end

-- 飞宠
function ClothespressView:SetFlyPetModel(modle_info)
	local flypet_res_id = modle_info.flypet_info.res_id
	if flypet_res_id == 0 then return end

	local callback = function()
		UIScene:SetModelLoadCallBack(function(model, obj)
			obj.gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		end)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "flypet")
		transform.rotation = Quaternion.Euler(0, 195, 0)
		UIScene:SetCameraTransform(transform)
	end
	UIScene:ChangeScene(self, callback)

	-- PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local bundle, asset = ResPath.GetFlyPetModel(flypet_res_id)
	local load_list = {{bundle, asset}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)
	end)
end