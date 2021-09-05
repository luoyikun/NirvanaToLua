----------------------------------------------------
-- 角色模型
----------------------------------------------------
RoleModel = RoleModel or BaseClass()
RoleModel.RoleModelCounter = 0

DISPLAY_TYPE = {
	XIAN_NV = 1, 
	MOUNT = 2, 
	WING = 3, 
	FASHION = 4, --神兵类型
	HALO = 5, 
	SPIRIT = 6, 
	FIGHT_MOUNT = 7, 
	SHENGONG = 8, 
	SHENYI = 9,
	SPIRIT_HALO = 10, 
	SPIRIT_FAZHEN = 11, 
	NPC = 12, 
	BUBBLE = 13, 
	ZHIBAO = 14, 
	MONSTER = 15, 
	ROLE = 16, 
	DAILY_CHARGE = 17,
	TITLE = 18, 
	XUN_ZHANG = 19,
	ROLE_WING = 20, 
	WEAPON = 21, 
	SHENGONG_WEAPON = 22, 
	FORGE = 23, 
	GATHER = 24, 
	STONE = 25,
	SHEN_BING = 26, 
	BOX = 27, 
	HUNQI = 28, 
	ZEROGIFT = 29, 
	FOOTPRINT = 30, 
	CLOAK = 31, 
	COUPLE_HALO = 32 , 
	FABAO = 33,
	SHIZHUANG = 34,
	HEAD_FRAME = 35,
	TOUSHI = 36,
	MASK = 37,
	WAIST = 38,
	QILINBI = 39,
	LITTLEPET = 40,
	LINGZHU	= 41,
	XIANBAO = 42,
	LINGTONG = 43,
	LINGGONG = 44,
	LINGQI = 45,
	WEIYAN = 46,
	SHOUHUAN = 47,
	TAIL = 48,
	FLYPET = 49,
	XIAOGUI = 50,
	BIANSHEN = 51,
}

-- 一些羽翼需要特殊处理（例如8048001界面上要显示跟场景上显示不一样）
local SpecialWingList = {
	[8048001] = 1,
	[8049001] = 1,
}

local RoleModelDirPosList = {
	[0] = {x = 1, y = 0},
	[1] = {x = 0, y = -1},
	[2] = {x = -1, y = 0},
	[3] = {x = 0, y = 1},
}

local UiSceneLayer = UnityEngine.LayerMask.NameToLayer("UIScene")
local Ui3DLayer = UnityEngine.LayerMask.NameToLayer("UI3D")
local UIObjLayer = GameObject.Find("GameRoot/UIObjLayer").transform

function RoleModel:__init()
	self.draw_obj = DrawObj.New(self, UIObjLayer)
	self.draw_obj:SetRemoveCallback(BindTool.Bind(self._OnModelRemove, self))
	self.draw_obj.auto_fly = false

	self.display = nil
	self.camera_type = nil
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.weapon2_res_id = 0
	self.wing_res_id = 0
	self.mount_res_id = 0
	self.halo_res_id = 0
	self.weapon2_res_id = 0
	self.fazhen_res_id = 0
	self.foot_res_id = 0
	self.fabao_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.lingzhu_res_id = 0
	self.xianbao_res_id = 0
	self.lingtong_res_id = 0
	self.linggong_res_id = 0
	self.lingqi_res_id = 0
	self.weiyan_res_id = 0
	self.shouhuan_res_id = 0
	self.tail_res_id = 0
	self.flypet_res_id = 0
	self.weiyan_list = {}

	self.is_display = false
	self.next_wing_fold = false
	self.wing_need_action = false
	self.goddess_wing_need_action = false
	self.cloak_need_action = true
	self.is_in_ui_scene = false 			-- 是否ui_scene创建的模型

	self.load_complete = nil
	self.is_load_effect2 = false
	self.loop_name = ""
	self.loop_interval = 10					--循环播放间隔
	self.loop_last_time = 0 				--最后循环播放时间
	self.footprint_eff_t = {}
	self.ui_model_offset = Vector3(0, 0, 0)
end

function RoleModel:__delete()
	if self.scene_effect then
		ResPoolMgr:Release(self.scene_effect)
		self.scene_effect = nil
	end
	if self.display then
		self.display:ClearDisplay()
		self.display = nil
	end
	self.camera_type = nil

	self:FixMeshRendererBug()
	self.draw_obj:DeleteMe()
	self.draw_obj = nil

	if self.scene_effect_obj then
		self.scene_effect_obj:DeleteMe()
		self.scene_effect_obj = nil
	end
	
	if self.weapon_effect then
		ResMgr:Destroy(self.weapon_effect)
		self.weapon_effect = nil
	end
	if self.weapon2_effect then
		ResMgr:Destroy(self.weapon2_effect)
		self.weapon2_effect = nil
	end
	self.is_load_effect = nil
	self.is_load_effect2 = nil

	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end

	if self.run_request then
		GlobalTimerQuest:CancelQuest(self.run_request)
		self.run_request = nil
	end
	self.loop_name = ""
	self.loop_last_time = 0
	self.info = nil
	self:ClearFootprint()
	if self.foot_timer then
		GlobalTimerQuest:CancelQuest(self.foot_timer)
		self.foot_timer = nil
	end
	if self.dealy_foot_timer then
		GlobalTimerQuest:CancelQuest(self.dealy_foot_timer)
		self.dealy_foot_timer = nil
	end

	self:RemoveShowRestDelayTime()

	self.weiyan_res_id = 0
	self:RemoveSprite()
	self:RemoveGoddess()
	self:RemoveFlypet()
	self:RemoveLingTong()
	self:RemoveXianBao()
	self:RemoveMarriageModel()
	self:FreeWeiYanList()
end

-- 主要针对一个display要显示很多种模型的问题
-- 模型摄像机设置 (根据读取的主资源路径来获得摄像机参数，所以一做就做一套，每种模型都要设定好参数)
function RoleModel:GetModelCameraSetting(camera_type, bundle, asset)
	if nil == camera_type or nil == bundle then 
		return
	end
	local start_pos, end_pos = string.find(bundle, "%/.-%/")
	local key = string.sub(bundle, start_pos + 1, end_pos - 1)

	if "role" == key then
		start_pos, end_pos = string.find(bundle, "%/.-.prefab")
		key = "role/" .. string.sub(bundle, start_pos + 9, end_pos - 10)
	elseif "effects/prefab/lingzhu" == string.match(bundle, "effects/prefab/lingzhu") then	-- 特殊处理下灵珠的,因为这地方是从特效那边获取的。
		key = "lingzhu"
	end

	return MODEL_CAMERA_SETTING[camera_type][key]
end

function RoleModel.GetModelCameraSettingByType(camera_type, type_key)
	local transform = TableCopy(MODEL_CAMERA_SETTING[MODEL_CAMERA_TYPE.BASE]["role"])
	if nil == camera_type or nil == type_key then
		return transform
	end

	return TableCopy(MODEL_CAMERA_SETTING[camera_type][type_key]) or transform
end

-- 修复MeshRenderer被隐藏的bug
function RoleModel:FixMeshRendererBug()
	if self.draw_obj then
		-- 取到身上所有部件
		for k,v in pairs(SceneObjPart) do
			local part_obj = self.draw_obj:_TryGetPartObj(v)
			if part_obj then
				local mesh_renderer_list = part_obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
				-- 把每个meshRenderer的Enabled强制设为true
				for i = 0, mesh_renderer_list.Length - 1 do
					local mesh_renderer = mesh_renderer_list[i]
					if mesh_renderer then
						mesh_renderer.enabled = true
					end
				end
			end
		end
	end
end

function RoleModel:SetIsUseObjPool(is_use_objpool)
	self.draw_obj:SetIsUseObjPool(is_use_objpool)
end

function RoleModel:SetLoadComplete(complete)
	self.load_complete = complete
end

function RoleModel:SetDisplay(display, camera_type, no_locate_fitscale)
	self.display = display
	self.display:SetRotation(Vector3(0, 0, 0))
	self.display:SetScale(Vector3(1, 1, 1))
	
	self.camera = self.display:GetComponentInChildren(typeof(UnityEngine.Camera))
	if nil ~= self.camera then
		-- fieldOfView根据其他项目设置的都是40
		self.camera.fieldOfView = 40
		self.camera.nearClipPlane = 0.01
		self.camera.farClipPlane = 60
	end

	self.camera_type = camera_type

	if not no_locate_fitscale then
		self:ResetFitScaleWorldPosition()
	end
end

function RoleModel:ResetFitScaleWorldPosition()
	if nil == self.display.FitScaleRoot then
		print_warning("Why no FitScale ? Do you have soul ?")
		return
	end
	if self.display then
		RoleModel.RoleModelCounter = RoleModel.RoleModelCounter + 1
		local round = math.floor(RoleModel.RoleModelCounter / 4) + 1
		local pos = RoleModelDirPosList[RoleModel.RoleModelCounter % 4]

		self.display.FitScaleRoot.position = Vector3(pos.x * round * 100, pos.y * round * 100, 0)
	end
end

function RoleModel:SetCameraSettingForce(transform)
	transform = transform or {}
	self.display_position = transform.position
	self.display_rotation = transform.rotation
end

function RoleModel:SetCameraSetting(transform)
	if nil ~= self.camera and nil ~= transform then
		self.camera.transform.localPosition = self.display_position or transform.position
		self.camera.transform.localRotation = self.display_rotation or transform.rotation
	end
end

function RoleModel:SetMainAsset(bundle, asset, func)
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:RemoveModel()
	local camera_setting = self:GetModelCameraSetting(self.camera_type, bundle, asset)
	self:SetCameraSetting(camera_setting)

	part:ChangeModel(bundle, asset, function (obj)
		if nil ~= func then
			func(obj)
		end
	end)
end

-- 就首充、一折那里调这个函数
function RoleModel:SpecialSetMainAsset(bundle, asset, func)
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	part:RemoveModel()
	local camera_setting = self:GetModelCameraSetting(self.camera_type, bundle, asset)
	self:SetCameraSetting(camera_setting)

	self.call_back_func = func
	part:ChangeModel(bundle, asset, function (obj)
		if nil ~= self.call_back_func then
			self.call_back_func(obj)
		end
	end)
end

function RoleModel:ClearCallBackFun()
	self.call_back_func = nil
end

function RoleModel:LoadSceneEffect(bundle, asset, node, func)
	if not self.scene_effect_obj then
		if not node then
			return
		end
		self.scene_effect_obj = DrawObj.New(self, node.gameObject.transform)
		local position = Vector3(0, 0, 0)
		self.scene_effect_obj:GetRoot().gameObject.transform.localPosition = position
		self.scene_effect_obj:GetRoot().gameObject.transform.rotation = position
		self.scene_effect_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
	end

	local draw_obj_root = self.scene_effect_obj:GetRoot()
	if IsNil(draw_obj_root.gameObject) then
		return
	end

	if self.scene_effect then
		ResPoolMgr:Release(self.scene_effect)
		self.scene_effect = nil
	end

	ResPoolMgr:GetEffectAsync(bundle, asset, function(obj)
		if not IsNil(obj) then
			if not self.scene_effect_obj then
				ResPoolMgr:Release(obj)
				return
			end
		end
		self.scene_effect = obj
		obj.transform:SetParent(draw_obj_root.transform, false)
		obj.gameObject:SetLayerRecursively(Ui3DLayer)

		if func then
			func()
		end
	end)
end

function RoleModel:SetGoddessAsset(bundle, asset, func)
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	local camera_setting = self:GetModelCameraSetting(self.camera_type, bundle, asset)
	self:SetCameraSetting(camera_setting)

	part:ChangeModel(bundle, asset, function ()
		if nil ~= func then
			func()
		end
	end)
end

function RoleModel:SetRoleResid(role_res_id)
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local bundle, asset = ResPath.GetRoleModel(self.role_res_id)
	local camera_setting = self:GetModelCameraSetting(self.camera_type, bundle, asset)
	self:SetCameraSetting(camera_setting)

	part:ChangeModel(bundle, asset, function ()
	
	end)
end

function RoleModel:SetGoddessResid(role_res_id, is_hide_effect)
	is_hide_effect = is_hide_effect or false
	self.role_res_id = role_res_id
	self.draw_obj:SetLoadComplete(BindTool.Bind(self._OnModelLoaded, self))
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local bundle, asset = ResPath.GetGoddessModel(self.role_res_id)

	local camera_setting = self:GetModelCameraSetting(self.camera_type, bundle, asset)
	self:SetCameraSetting(camera_setting)

	part:ChangeModel(bundle, asset, function ()
		local effects_point = part:GetObj().transform:Find("GameObject")
		if not effects_point then
			effects_point = part:GetObj().transform:Find("effects")
		end
		if effects_point then
			effects_point.gameObject:SetActive(not is_hide_effect)
		end
		
		if self.fazhen_res_id ~= -1 then
			self:SetGoddessFaZhenResid(self.fazhen_res_id)
		end
		if self.halo_res_id ~= -1 then
			self:SetGoddessHaloResid(self.halo_res_id)
		end
	end)
end

function RoleModel:SetGoddessHaloResid(halo_res_id)
	self.halo_res_id = halo_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Halo)
	if self.halo_res_id > -1 then
		part:ChangeModel(ResPath.GetGoddessHaloModel(self.halo_res_id))
	end
end

-- 设置腰饰
function RoleModel:SetWaistResid(waist_res_id)
	self.waist_res_id = waist_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.Waist)
	if nil == waist_res_id or waist_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetWaistModel(waist_res_id))
end

--设置头饰
function RoleModel:SetTouShiResid(toushi_res_id)
	self.toushi_res_id = toushi_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.TouShi)
	if nil == toushi_res_id or toushi_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetTouShiModel(toushi_res_id))
end

--设置麒麟臂（这个是装在人身上的, 单独展示麒麟臂调SetMainAsset）
function RoleModel:SetQilinBiResid(qilinbi_res_id, sex)
	self.qilinbi_res_id = qilinbi_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.QilinBi)
	if nil == qilinbi_res_id or qilinbi_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetQilinBiModel(qilinbi_res_id, sex))
end

--设置面饰
function RoleModel:SetMaskResid(mask_res_id)
	self.mask_res_id = mask_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.Mask)
	if nil == mask_res_id or mask_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetMaskModel(mask_res_id))
end

function RoleModel:FreeWeiYanList()
	for _, v in pairs(self.weiyan_list) do
		if not IsNil(v) then
			ResMgr:Destroy(v)
		end
	end
	self.weiyan_list = {}
end

--设置尾焰
function RoleModel:SetWeiYanResid(weiyan_res_id, mount_res_id, is_uiscene_layer)
	if is_uiscene_layer == nil then
		is_uiscene_layer = true
	else
		is_uiscene_layer = is_uiscene_layer
	end

	--把之前旧的尾焰特效删除
	self:FreeWeiYanList()

	self.weiyan_res_id = weiyan_res_id or 0

	if self.weiyan_res_id <= 0 then
		return
	end

	local path_list = WeiYanData.Instance:GetWeiYanGuaDianPathList(mount_res_id)
	if path_list == nil then
		return
	end

	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local part2 = self.draw_obj:GetPart(SceneObjPart.Mount)
	if part == nil or part:GetObj() == nil then
		return
	end

	local part_obj = part:GetObj()
	local part_obj2
	if part2 ~= nil and part2:GetObj() ~= nil then
		part_obj2 = part2:GetObj()
	end

	local bundle, asset = ResPath.GetWeiYanModel(weiyan_res_id)
	if path_list then
		local async_loader = AllocAsyncLoader(self, "weiyan")
		async_loader:Load(bundle, asset, function(prefab)
			if IsNil(prefab) then
				return
			end
			
			for _, v in ipairs(path_list) do
				local gua_dian = part_obj.transform:FindByName(v)
				if not gua_dian and part_obj2 then
					gua_dian = part_obj2.transform:FindByName(v)
				end

				if gua_dian then
					local obj = ResMgr:Instantiate(prefab)
					if nil == obj then
						print_error("error weiyan", bundle, asset)
						return
					end

					if weiyan_res_id ~= self.weiyan_res_id then
						ResMgr:Destroy(obj)
						return
					end

					--当节点不可见则不添加尾焰特效
					if gua_dian == nil or not gua_dian.gameObject.activeInHierarchy then
						ResMgr:Destroy(obj)
						return
					end

					--防止一个坐骑存在多种尾焰
					if self.weiyan_list[gua_dian] then
						ResMgr:Destroy(obj)
						return
					end

					obj:GetOrAddComponent(typeof(TrailRendererController))
					obj.transform:SetParent(gua_dian, false)
					if is_uiscene_layer then
						obj:SetLayerRecursively(UiSceneLayer)
					else
						obj:SetLayerRecursively(Ui3DLayer)
					end
					self.weiyan_list[gua_dian] = obj
				end
			end
		end)
	end



	

	--self.weiyan_res_id = weiyan_res_id

	-- local part = self.draw_obj:GetPart(SceneObjPart.ShouHuan)
	--local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	--if nil == weiyan_res_id then
		--part:RemoveModel()
		--return
	--end

	--part:ChangeModel(ResPath.GetWeiYanModel(weiyan_res_id))

	-- local part = self.draw_obj:GetPart(SceneObjPart.Wing)

	-- part:ChangeModel(ResPath.GetWeiYanModel(weiyan_res_id))
	-- local part = self.draw_obj:GetPart(SceneObjPart.Hug)

	-- part:ChangeModel(ResPath.GetWeiYanModel(weiyan_res_id))
	-- local part = self.draw_obj:GetPart(SceneObjPart.Waist)

	-- part:ChangeModel(ResPath.GetWeiYanModel(weiyan_res_id))

end

--设置手环
function RoleModel:SetShouHuanResid(shouhuan_res_id)
	self.shouhuan_res_id = shouhuan_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.ShouHuan)
	if nil == shouhuan_res_id or (type(shouhuan_res_id) == "number" and shouhuan_res_id <= 0) then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetShouHuanModel(shouhuan_res_id))
end

--设置尾巴
function RoleModel:SetTailResid(tail_res_id)
	self.tail_res_id = tail_res_id

	local part = self.draw_obj:GetPart(SceneObjPart.Tail)
	if nil == tail_res_id or tail_res_id <= 0 then
		part:RemoveModel()
		return
	end

	part:ChangeModel(ResPath.GetTailModel(tail_res_id))
end

function RoleModel:SetMountResid(mount_res_id, weiyan_res_id, is_flush)
	if not is_flush and self.mount_res_id == mount_res_id then
		return
	end
	self:RemoveMount()

	self.mount_res_id = mount_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Mount)
	local layer = self:GetMountLayer(mount_res_id)

	local asset, bundle = ResPath.GetMountModel(self.mount_res_id)
	part:ChangeModel(asset, bundle, function ()
		if self.draw_obj then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			main_part:SetLayer(layer, 1)
			if weiyan_res_id and weiyan_res_id > 0 then
				self:SetWeiYanResid(weiyan_res_id, mount_res_id)
			end
		end
	end)
end

function RoleModel:RemoveMount()
	self.mount_res_id = 0
	self.draw_obj:RemoveModel(SceneObjPart.Mount)
	local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
	main_part:SetLayer(ANIMATOR_PARAM.MOUNT_LAYER2, 0)
end

function RoleModel:GetMountLayer(mount_res_id)
	local layer = ANIMATOR_PARAM.MOUNT_LAYER
	local cfg = MountData.Instance:GetSpecialImagesCfg()
	for k,v in pairs(cfg) do
		if v.res_id == mount_res_id then
			layer = v.is_sit == 2 and ANIMATOR_PARAM.MOUNT_LAYER2 or layer
			return layer
		end
	end
	local multi_cfg = MultiMountData.Instance:GetMultiMountHuanhuaCfg()
	for k,v in pairs(multi_cfg) do
		if v.res_id == mount_res_id then
			if v.is_sit == 1 then
				layer = ANIMATOR_PARAM.FIGHTMOUNT_LAYER
			elseif v.is_sit == 2 then
				layer = ANIMATOR_PARAM.MOUNT_LAYER2
			end
			return layer
		end
	end
	return layer
end

function RoleModel:SetFightMountResid(fight_mount_res_id)
	if self.fight_mount_res_id == fight_mount_res_id then
		return
	end

	self.fight_mount_res_id = fight_mount_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.FightMount)
	part:ChangeModel(ResPath.GetFightMountModel(self.fight_mount_res_id))
end

function RoleModel:RemoveFightMount()
	self.fight_mount_res_id = 0
	self.draw_obj:RemoveModel(SceneObjPart.FightMount)
end

function RoleModel:SetHaloResid(halo_res_id)
	self.halo_res_id = halo_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Halo)
	if self.halo_res_id > -1 then
		part:ChangeModel(ResPath.GetHaloModel(self.halo_res_id))
	end

end

function RoleModel:SetFaBaoResid(fabao_res_id)
	self.fabao_res_id = fabao_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.BaoJu)
	local asset, bundle = ResPath.GetFaBaoModel(self.fabao_res_id, true)
	part:ChangeModel(asset, bundle)
	-- 	if self.draw_obj then
	-- 		part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	-- 	end
	-- end)
end

function RoleModel:SetWeaponResid(weapon_res_id)
	self.weapon_res_id = weapon_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	part:ChangeModel(ResPath.GetWeaponModel(self.weapon_res_id))
end

function RoleModel:SetWeapon2Resid(weapon2_res_id)
	self.weapon2_res_id = weapon2_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Weapon2)
	part:ChangeModel(ResPath.GetWeaponModel(self.weapon2_res_id))
end

function RoleModel:SetFaZhenResid(fazhen_res_id)
	-- self.fazhen_res_id = fazhen_res_id
	-- local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	-- part:ChangeModel(ResPath.GetZhenfaEffect(self.fazhen_res_id))
end

function RoleModel:ClearFootprint()
	for k,v in pairs(self.footprint_eff_t) do
		if not IsNil(v) then
			ResPoolMgr:Release(v)
		end
	end
	self.footprint_eff_t = {}
end

function RoleModel:ClearFoot()
	for k,v in pairs(self.footprint_eff_t) do
		if not IsNil(v) then
			ResPoolMgr:Release(v)
		end
	end
	self.footprint_eff_t = {}

	if self.foot_timer then
		GlobalTimerQuest:CancelQuest(self.foot_timer)
		self.foot_timer = nil
	end
	if self.dealy_foot_timer then
		GlobalTimerQuest:CancelQuest(self.dealy_foot_timer)
		self.dealy_foot_timer = nil
	end
end

function RoleModel:SetFootResid(foot_res_id)
	self.foot_res_id = foot_res_id
	self:ClearFootprint()
	if self.foot_res_id > 0 then
		self:CreateFootprint()
		if nil == self.foot_timer then
			self.foot_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateFootprintPos, self), 0)
		end
	else
		if self.foot_timer then
			GlobalTimerQuest:CancelQuest(self.foot_timer)
			self.foot_timer = nil
		end
		if self.dealy_foot_timer then
			GlobalTimerQuest:CancelQuest(self.dealy_foot_timer)
			self.dealy_foot_timer = nil
		end
	end
end

function RoleModel:CreateFootprint()
	if self.foot_res_id <= 0 or self.dealy_foot_timer then return end
	if self.draw_obj and self.draw_obj:GetRoot() then
		local draw_obj_root = self.draw_obj:GetRoot()
		if IsNil(draw_obj_root.gameObject) then
			return
		end
		
		local bundle, asset = ResPath.GetFootModel(self.foot_res_id)
		ResPoolMgr:GetDynamicObjAsync(bundle, asset, function(obj)
			if not IsNil(obj) then
				if nil == self.draw_obj then
					ResPoolMgr:Release(obj)
					return
				end
				obj.transform:SetParent(draw_obj_root.transform, false)

				local layer = self.is_in_ui_scene and UiSceneLayer or draw_obj_root.gameObject.layer
				obj.gameObject:SetLayerRecursively(layer)

				local control = obj:GetOrAddComponent(typeof(EffectControl))
				if nil ~= control then
					control:Reset()
					control.enabled = true
					control:Play()					
				end
				
				if #self.footprint_eff_t > 5 then
					local footprint = table.remove(self.footprint_eff_t, 1)
					if not IsNil(footprint) then
						ResPoolMgr:Release(footprint)
					end
				end
				table.insert(self.footprint_eff_t, obj)
			end
		end)
		self.dealy_foot_timer = GlobalTimerQuest:AddDelayTimer(function ()
					self.dealy_foot_timer = nil
					self:CreateFootprint()
				end, 0.5)
	end
end

function RoleModel:UpdateFootprintPos()
	for k,v in pairs(self.footprint_eff_t) do
		if not IsNil(v) then
			local pos = v.transform.localPosition
			v.transform.localPosition = Vector3(pos.x, pos.y, pos.z - 0.05)
		end
	end
end

function RoleModel:SetWingResid(wing_res_id)
	self.wing_res_id = wing_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	local bundle, asset = ResPath.GetWingModel(self.wing_res_id)
	part:ChangeModel(bundle, asset,function()
		if self.wing_need_action or self.goddess_wing_need_action then
			part:SetTrigger("action")
		end

		if nil ~= SpecialWingList[wing_res_id] and not self.is_in_ui_scene then
			local attach_obj = part.obj.attach_obj.transform
			attach_obj:Find("guadian001").transform:Find("effects").gameObject:SetActive(false)
			attach_obj:Find("guadian001").transform:Find("effects01_UI").gameObject:SetActive(true)
			
			attach_obj:Find("guadian002").transform:Find("effects").gameObject:SetActive(false)
			attach_obj:Find("guadian002").transform:Find("effects01_UI").gameObject:SetActive(true)
		end
	end)
end

function RoleModel:SetWingNeedAction(is_need)
	self.wing_need_action = is_need
end

function RoleModel:SetGoddessWingNeedAction(is_need)
	self.goddess_wing_need_action = is_need
end

function RoleModel:SetGoddessFaZhenResid(fazhen_res_id)
	self.fazhen_res_id = fazhen_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.FaZhen)
	local bundle, asset = ResPath.GetGoddessFaZhenModel(self.fazhen_res_id)
	part:ChangeModel(bundle, asset)
end

function RoleModel:SetWingAsset(bundle,asset)
	local part = self.draw_obj:GetPart(SceneObjPart.Wing)
	part:ChangeModel(bundle, asset, function()
		if self.goddess_wing_need_action or self.wing_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetCloakResid(cloak_res_id)
	self.cloak_res_id = cloak_res_id
	local part = self.draw_obj:GetPart(SceneObjPart.Cloak)
	local bundle, asset = ResPath.GetPifengModel(self.cloak_res_id)
	-- if nil == bundle or nil == asset then
	-- 	return
	-- end
	-- if nil ~= asset then
	-- 	--asset = asset .. "_P"
	-- 	asset = asset
	-- end
	
	part:ChangeModel(bundle, asset, function()
		if self.cloak_need_action then
			part:SetTrigger("action")
		end
	end)
end

function RoleModel:SetVisible(state)
	self.draw_obj:SetVisible(state)
end

function RoleModel:SetRotation(rotation)
	if rotation and self.display then
		self.display:SetRotation(rotation)
	end
end

function RoleModel:SetScale(scale)
	if scale and self.display then
		self.display:SetScale(scale)
	end
end

function RoleModel:SetLocalPosition(pos)
	self.draw_obj.root.transform.localPosition = pos
end

function RoleModel:SetLocalRotation(rotation)
	self.draw_obj.root.transform.localRotation = rotation
end

function RoleModel:_OnModelLoaded(part, obj)
	-- ui上的特效强制使用最高品质
	GlobalTimerQuest:AddDelayTimer(function() CommonDataManager.ChangeQuality(obj, COMMON_CONSTS.UI_QUALITY_OVER_LEVEL) end, 0.2)
	
	if part == SceneObjPart.Main then
		if nil ~= self.display and nil ~= self.camera and false == self.is_display then
			--只允许进来一次，不然lossyScale被修改过后又修改导致FitScale出问题
			self.is_display = true
			self.display:Display(obj.transform.parent.gameObject, self.camera)
		end

		if self.trigger_name then
			part_obj:SetTrigger(self.trigger_name)
			self.trigger_name = nil
		end
	end

	-- local animator = obj:GetComponent(typeof(UnityEngine.Animator))
	-- if animator then
	-- 	animator.cullingMode = UnityEngine.AnimatorCullingMode.AlwaysAnimate
	-- end

	if self.load_complete then
		self.load_complete(part, obj)
	end
end

function RoleModel:_OnModelRemove(part, obj)
	-- 还原游戏品质
	CommonDataManager.ResetQuality(obj)
end

function RoleModel:SetTrigger(name, is_delay)
	if is_delay == nil then
		is_delay = true
	end
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				if is_delay then
					GlobalTimerQuest:AddDelayTimer(function() main_part:SetTrigger(name) end, 0.1)
				else
					main_part:SetTrigger(name)
				end
			else
				self.trigger_name = name
			end
		end
	end
end

function RoleModel:SetBool(name, state)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				GlobalTimerQuest:AddDelayTimer(function() main_part:SetBool(name, state) end, 0.1)
			end
		end
	end
end

function RoleModel:SetInteger(key, value)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				main_part:SetInteger(key, value)
			end
		end
	end
end

function RoleModel:RemoveShowRestDelayTime()
	if self.play_action_delay_time then
		GlobalTimerQuest:CancelQuest(self.play_action_delay_time)
		self.play_action_delay_time = nil
	end
	if self.play_action_delay_time2 then
		GlobalTimerQuest:CancelQuest(self.play_action_delay_time2)
		self.play_action_delay_time2 = nil
	end
end

-- 显示动作(包含战斗状态切回正常状态)
function RoleModel:ShowRest()
	if not self.is_play_action and self.draw_obj then
		local part = self.draw_obj:GetPart(SceneObjPart.Main)
		self:RemoveShowRestDelayTime()
		part:SetBool(ANIMATOR_PARAM.FIGHT, false)
		self.play_action_delay_time = GlobalTimerQuest:AddDelayTimer(function()
			self.is_play_action = true
			part:SetTrigger(ANIMATOR_PARAM.REST)
			self.play_action_delay_time2 = GlobalTimerQuest:AddDelayTimer(function()
					self.is_play_action = false
				 end ,3)
		  end, 0.5)
	end
end

function RoleModel:Rotate(x_angle, y_angle, z_angle)
	if self.draw_obj then
		self.draw_obj:Rotate(x_angle, y_angle, z_angle)
	end
end

function RoleModel:ResetRotation()
	if self.display then
		self.display:ResetRotation()
	end
end

function RoleModel:SetGoddessModelResInfo(info, is_hide_effect)
	for k, v in pairs(SceneObjPart) do
		local part = self.draw_obj:GetPart(v)
		if part then
			part:RemoveModel()
		end
	end
	if info ~= nil then
		self.role_res_id = info.role_res_id or -1
		self.halo_res_id = info.halo_res_id or -1
		self.fazhen_res_id = info.fazhen_res_id or -1
	end
	if self.role_res_id ~= -1 then
		self:SetGoddessResid(self.role_res_id, is_hide_effect)
	end
end

function RoleModel:SetModelResInfo(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak, ignore_fabao)
	self.info = info
	self.ignore_find = ignore_find
	self.ignore_wing = ignore_wing
	self.ignore_halo = ignore_halo
	self.ignore_weapon = ignore_weapon
	self.show_footprint = show_footprint
	self.ignore_cloak = ignore_cloak
	self.ignore_fabao = ignore_fabao

	if info == nil then return end
	local prof = info.prof
	local sex = info.sex
	if nil == prof or nil == sex then
		return
	end
	self:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak, ignore_fabao)
	self:SetRoleResid(self.role_res_id)
	if not info.is_not_show_weapon then
		self:SetWeaponResid(self.weapon_res_id)
		self:SetWeapon2Resid(self.weapon2_res_id)
	else
		local part_one = self.draw_obj:GetPart(SceneObjPart.Weapon)
		if part_one then
			part_one:RemoveModel()
		end
		local part_two = self.draw_obj:GetPart(SceneObjPart.Weapon2)
		if part_two then
			part_two:RemoveModel()
		end
	end
	self:SetWingResid(self.wing_res_id)
	self:SetHaloResid(self.halo_res_id)
	self:SetFootResid(self.foot_res_id)
	self:SetCloakResid(self.cloak_res_id)
	self:SetWaistResid(self.waist_res_id)
	self:SetTouShiResid(self.toushi_res_id)
	self:SetQilinBiResid(self.qilinbi_res_id, sex)
	self:SetMaskResid(self.mask_res_id)
	self:SetFaBaoResid(self.fabao_res_id)
	-- self:SetWeiYanResid(self.weiyan_res_id)
	self:SetShouHuanResid(self.shouhuan_res_id)
	self:SetTailResid(self.tail_res_id)
end

function RoleModel:UpdateAppearance(info, ignore_find, ignore_wing, ignore_halo, ignore_weapon, show_footprint, ignore_cloak, ignore_fabao)
	local prof = info.prof
	local sex = info.sex

	if nil == prof or nil == sex then
		return
	end
	prof = PlayerData.Instance:GetRoleBaseProf(prof)
	local wuqi_color = info.wuqi_color
	if nil == wuqi_color and info.equipment_info then
		local equip_info = info.equipment_info[GameEnum.EQUIP_INDEX_WUQI + 1]
		if equip_info then
			local cfg = ItemData.Instance:GetItemConfig(equip_info.equip_id)
			if cfg then
				wuqi_color = cfg.color
			end
		end
	end
	wuqi_color = wuqi_color and wuqi_color or 0
	--清空缓存
	self.role_res_id = 0
	self.weapon_res_id = 0
	self.wing_res_id = 0
	self.halo_res_id = 0
	self.weapon2_res_id = 0
	self.fazhen_res_id = 0
	self.foot_res_id = 0
	self.cloak_res_id = 0
	self.waist_res_id = 0
	self.toushi_res_id = 0
	self.qilinbi_res_id = 0
	self.mask_res_id = 0
	self.fabao_res_id = 0
	self.lingzhu_res_id = 0
	self.xianbao_res_id = 0
	self.lingtong_res_id = 0
	self.linggong_res_id = 0
	self.lingqi_res_id = 0
	self.weiyan_res_id = 0
	self.shouhuan_res_id = 0
	self.tail_res_id = 0
	self.flypet_res_id = 0

	local wing_index = 0
	local halo_index = 0
	local foot_index = 0
	local cloak_index = 0
	-- 先查找时装的武器和衣服
	local appearance = info.appearance
	if appearance == nil then
		local shizhuang_part_list = info.shizhuang_part_list
		if shizhuang_part_list then
			appearance = {fashion_body = shizhuang_part_list[2].image_id, fashion_wuqi = shizhuang_part_list[1].image_id}
		end
	else
		wing_index = appearance.wing_used_imageid or 0
		if not ignore_halo then
			halo_index = appearance.halo_used_imageid or 0
		end
		if show_footprint then
			foot_index = appearance.footprint_used_imageid or 0
		end

		if not ignore_cloak then
			cloak_index = appearance.cloak_used_imageid or 0
		end
	end

	if appearance ~= nil then
		if appearance.fashion_wuqi ~= 0 and appearance.fashion_wuqi ~= nil then
			local weapon_cfg_list = (info.is_normal_wuqi or (appearance.fashion_wuqi_is_special and appearance.fashion_wuqi_is_special == 0)) and ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_img or ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
			if weapon_cfg_list then
				local wuqi_cfg = weapon_cfg_list[appearance.fashion_wuqi]
				if wuqi_cfg and next(wuqi_cfg) then
					local cfg = wuqi_cfg["resouce" .. prof .. sex]
					if type(cfg) == "string" then
						local temp_table = Split(cfg, ",")
						if temp_table then
							self.weapon_res_id = temp_table[1]
							self.weapon2_res_id = temp_table[2]
						end
					elseif type(cfg) == "number" then
						self.weapon_res_id = cfg
					end
				end
			end
		end

		if appearance.fashion_body ~= 0 then
			local clothing_cfg
			if info.is_normal_fashion or (info.appearance and info.appearance.fashion_body_is_special == 0) then
				clothing_cfg = FashionData.Instance:GetShizhuangImg(appearance.fashion_body)
			else
				clothing_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(appearance.fashion_body)
			end
			if clothing_cfg then
				local res_id = clothing_cfg["resouce" .. prof .. sex]
				self.role_res_id = res_id
			end
		end

		--法宝
		if appearance.fabao_used_imageid and appearance.fabao_used_imageid > 0 and not ignore_fabao then
			self.fabao_res_id = FaBaoData.Instance:GetResIdByImageId(appearance.fabao_used_imageid)
		end

		--腰饰
		if appearance.yaoshi_used_imageid and appearance.yaoshi_used_imageid > 0 then
			self.waist_res_id = WaistData.Instance:GetResIdByImageId(appearance.yaoshi_used_imageid)
		end

		--头饰
		if appearance.toushi_used_imageid and appearance.toushi_used_imageid > 0 then
			self.toushi_res_id = TouShiData.Instance:GetResIdByImageId(appearance.toushi_used_imageid)
		end

		--麒麟臂
		if appearance.qilinbi_used_imageid and appearance.qilinbi_used_imageid > 0 then
			self.qilinbi_res_id = QilinBiData.Instance:GetResIdByImageId(appearance.qilinbi_used_imageid, sex)
		end

		--面饰
		if appearance.mask_used_imageid and appearance.mask_used_imageid > 0 then
			self.mask_res_id = MaskData.Instance:GetResIdByImageId(appearance.mask_used_imageid)
		end

		--手环
		if appearance.shouhuan_used_imageid and ShouHuanData.Instance and appearance.shouhuan_used_imageid > 0 then
			self.shouhuan_res_id = ShouHuanData.Instance:GetResIdByImageId(appearance.shouhuan_used_imageid)
		end

		--尾巴
		if appearance.tail_used_imageid and appearance.tail_used_imageid > 0 then
			self.tail_res_id = TailData.Instance:GetResIdByImageId(appearance.tail_used_imageid)
		end

	end

	-- 查找翅膀
	if wing_index == 0 then
		if info.wing_info then
			wing_index = info.wing_info.used_imageid or 0
		end
	end
	local wing_config = ConfigManager.Instance:GetAutoConfig("wing_auto")
	local image_cfg = nil
	if wing_config and not ignore_wing then
		if wing_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = wing_config.special_img[wing_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = wing_config.image_list[wing_index]
		end
		if image_cfg then
			self.wing_res_id = image_cfg.res_id
		end
	end
	-- 查找光环
	if halo_index == 0 and not ignore_halo then
		if info.halo_info then
			halo_index = info.halo_info.used_imageid or 0
		end
	end
	local halo_config = ConfigManager.Instance:GetAutoConfig("halo_auto")
	image_cfg = nil

	if halo_config and halo_index > 0 then
		if halo_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = halo_config.special_img[halo_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = halo_config.image_list[halo_index]
		end
		if image_cfg then
			self.halo_res_id = image_cfg.res_id
		end
	end

	-- 查找足迹
	if foot_index == 0 and show_footprint then
		if info.foot_info then
			foot_index = info.foot_info.used_imageid or 0
		end
	end
	local foot_config = ConfigManager.Instance:GetAutoConfig("footprint_auto")
	image_cfg = nil

	if foot_config and foot_index > 0 then
		if foot_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = foot_config.special_img[foot_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = foot_config.image_list[foot_index]
		end
		if image_cfg then
			self.foot_res_id = image_cfg.res_id
		end
	end

	-- 查找披风
	if cloak_index == 0 and not ignore_cloak then
		if info.cloak_info then
			cloak_index = info.cloak_info.used_imageid or 0
		end
	end
	local cloak_config = ConfigManager.Instance:GetAutoConfig("cloak_auto")
	image_cfg = nil
	if cloak_config and cloak_index > 0 then
		if cloak_index >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			image_cfg = cloak_config.special_img[cloak_index - GameEnum.MOUNT_SPECIAL_IMA_ID]
		else
			image_cfg = cloak_config.image_list[cloak_index]
		end
		if image_cfg then
			self.cloak_res_id = image_cfg.res_id
		end
	end

	-- 最后查找职业表
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if self.role_res_id == 0 then
			self.role_res_id = role_job["model" .. sex]
		end
		if not ignore_find then
			if self.weapon_res_id == 0 then
				-- 武器颜色为红色时，使用特殊的模型
				if wuqi_color >= GameEnum.ITEM_COLOR_RED then
					self.weapon_res_id = role_job["right_red_weapon" .. sex]
				else
					self.weapon_res_id = role_job["right_weapon" .. sex]
				end
			end

			if self.weapon2_res_id == 0 then
				if wuqi_color >= GameEnum.ITEM_COLOR_RED then
					self.weapon2_res_id = role_job["left_red_weapon" .. sex]
				else
					self.weapon2_res_id = role_job["left_weapon" .. sex]
				end
			end
		end
	else
		if self.role_res_id == 0 then
			self.role_res_id = 1001001
		end
		if not ignore_find then
			if self.weapon_res_id == 0 then
				self.weapon_res_id = 900100101
			end
		end
	end
end

function RoleModel:EquipDataChangeListen()
	self:SetModelResInfo(self.info, self.ignore_find, self.ignore_wing, self.ignore_halo, self.ignore_weapon, self.show_footprint, self.ignore_cloak, self.ignore_fabao)
end

function RoleModel:SetWeaponEffect(part, obj)
	if not obj or (part ~= SceneObjPart.Weapon and part ~= SceneObjPart.Weapon2) then return end
	local main_role = Scene.Instance:GetMainRole()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local weapon_part = self.draw_obj:GetPart(SceneObjPart.Weapon)
	local weapon2_part = self.draw_obj:GetPart(SceneObjPart.Weapon2)
	if vo.appearance and vo.appearance.fashion_wuqi and vo.appearance.fashion_wuqi == 0
		and (main_role:GetWeaponResId() == tonumber(weapon_part.asset_name) or weapon2_part and main_role:GetWeapon2ResId() == tonumber(weapon2_part.asset_name))
		and main_role.vo.wuqi_color >= GameEnum.ITEM_COLOR_RED then

			local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
			if self.weapon_effect_name and self.weapon_effect_name ~= asset then
				self.weapon_effect = nil
			end

			if bundle and asset and not self.weapon_effect and not self.is_load_effect then
				self.is_load_effect = true

				self.weapon_effect_async_loader = self.weapon_effect_async_loader or AllocAsyncLoader(self, "weapon_effect_async_loader")
				self.weapon_effect_async_loader:SetParent(obj.transform)

				self.weapon_effect_async_loader:Load(bundle, asset, function(effect_obj)
					if IsNil(effect_obj) then
						return
					end

					self.weapon_effect = effct_obj.gameObject
					if self.draw_obj then
						obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
					end
					self.weapon_effect_name = asset
					self.is_load_effect = false
				end)
			end

		if part == SceneObjPart.Weapon2 then
			local bundle, asset = ResPath.GetWeaponEffect(self.weapon_res_id)
			if self.weapon2_effect_name and self.weapon2_effect_name ~= asset then
				self.weapon2_effect = nil
			end

			if bundle and asset and not self.weapon2_effect and not self.is_load_effect2 then
				self.is_load_effect2 = true
				
				self.weapon2_effect_async_loader = self.weapon2_effect_async_loader or AllocAsyncLoader(self, "weapon2_effect_async_loader")
				self.weapon2_effect_async_loader:SetParent(obj.transform)

				self.weapon2_effect_async_loader:Load(bundle, asset, function (effect_obj)
					if IsNil(effect_obj) then
						return
					end
					effect_obj:SetParent(obj.transform)
					self.weapon2_effect = effct_obj.gameObject
					effct_obj.transform:SetParent(obj.transform, false)
					if self.draw_obj then
						obj.gameObject:SetLayerRecursively(self.draw_obj.root.gameObject.layer)
					end
					self.weapon2_effect_name = asset
					self.is_load_effect2 = false
				end)
			end
		end
	else
		if self.weapon_effect and self.weapon_effect_async_loader then
			self.weapon_effect_async_loader:Destroy()
			self.weapon_effect = nil
		end

		if self.weapon2_effect and self.weapon2_effect_async_loader then
			self.weapon2_effect_async_loader:Destroy()
			self.weapon2_effect = nil
		end
	end
end

function RoleModel:SetListenEvent(list_name, callback)
	if self.draw_obj then
		if not self.draw_obj:IsDeleted() then
			local main_part = self.draw_obj:GetPart(SceneObjPart.Main)
			if main_part then
				main_part:ListenEvent(list_name, callback)
			end
		end
	end
end

function RoleModel:ClearModel()
	for k, v in pairs(SceneObjPart) do
		local part = self.draw_obj:GetPart(v)
		if part then
			part:RemoveModel()
		end
	end
end

function RoleModel:ShowAttachPoint(point, state)
	if nil == self.draw_obj then
		return
	end
	local part = self.draw_obj:GetPart(SceneObjPart.Main)
	local attach_point = part:GetAttachPoint(point)
	if nil ~= attach_point then
		attach_point.gameObject:SetActive(state)
	end
end

--[[
	有些模型需要手动循环播放
	调用SetLoopAnimal传入动作名字
]]
function RoleModel:ListCallBack()
	self.loop_last_time = Status.NowTime
end

function RoleModel:SetLoopAnimal(ani_name, list_name)
	if ani_name == "" or not ani_name then return end
	if list_name then
		self:SetListenEvent(list_name, BindTool.Bind(self.ListCallBack, self))
	end
	self.loop_name = ani_name
	if self.loop_time_quest then
		GlobalTimerQuest:CancelQuest(self.loop_time_quest)
		self.loop_time_quest = nil
	end
	self.loop_last_time = 0
	self.loop_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if Status.NowTime - self.loop_interval < self.loop_last_time then
			return
		end
		self.loop_last_time = Status.NowTime + 999
		if self.loop_name and self.loop_name ~= "" then
			self:SetTrigger(self.loop_name)
		end
	end, 0)
end

function RoleModel:SetIsInUiScene(is_in_ui_scene)
	self.is_in_ui_scene = is_in_ui_scene
end

function RoleModel:GetModelOffSet(model_id)
	local model_offset = 1.5

	if self.clothe_model_id ~= model_id and self.clothe_model_id == 0 then
		model_offset = -1.5
	end
	self.clothe_model_id = model_id

	return model_offset
end

function RoleModel:SetMarriageModel(role_info, halo_info, lover_info)
	if role_info and next(role_info) then
		if not self.marry_my_obj then
			self.marry_my_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
			self.marry_my_obj:GetRoot().gameObject.transform.localScale = Vector3(1.35, 1.35, 1.35)
			self.marry_my_obj:GetRoot().gameObject.transform.localRotation = Quaternion.Euler(0, -10.26, 0)
			self.marry_my_obj:GetRoot().gameObject.transform.localPosition = Vector3(0.9, 0, 0.3)

			if role_info.appearance.fashion_body ~= 0 then
				local clothing_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(role_info.appearance.fashion_body)
				local res_id

				if clothing_cfg then
					res_id = clothing_cfg["resouce" .. role_info.prof .. role_info.sex]
				end

				local main_part = self.marry_my_obj:GetPart(SceneObjPart.Main)
				main_part:ChangeModel(ResPath.GetRoleModel(res_id))
			end
		end
	end

	if halo_info and next(halo_info) then
		local bundle, asset = ResPath.GetHaloEffect(halo_info.res_id)
		self:SetMainAsset(bundle, asset)
	end

	if lover_info and next(lover_info) then
		if not self.marry_lover_obj then
			self.marry_lover_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
			self.marry_lover_obj:GetRoot().gameObject.transform.localScale = Vector3(1.35, 1.35, 1.35)
			self.marry_lover_obj:GetRoot().gameObject.transform.localRotation = Quaternion.Euler(0, 5, 0)
			self.marry_lover_obj:GetRoot().gameObject.transform.localPosition = Vector3(-0.9, 0, 0.3)

			if lover_info.appearance.fashion_body ~= 0 then
				local clothing_cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(lover_info.appearance.fashion_body)
				local res_id

				if clothing_cfg then
					res_id = clothing_cfg["resouce" .. lover_info.prof .. lover_info.sex]
				end

				local main_part = self.marry_lover_obj:GetPart(SceneObjPart.Main)
				main_part:ChangeModel(ResPath.GetRoleModel(res_id))
			end
		end
	end
end

function RoleModel:RemoveMarriageModel()
	if self.marry_my_obj then
		self.marry_my_obj:DeleteMe()
		self.marry_my_obj = nil
	end
	if self.marry_lover_obj then
		self.marry_lover_obj:DeleteMe()
		self.marry_lover_obj = nil
	end	
end


-- 衣柜展示用的方法
-- 可以支持同时创建人物、伙伴、仙宠、坐骑
function RoleModel:SetClosetInfo(role_info, sprite_info, goddess_info, mount_res_id, fight_mount_resid, show_footprint, lingtong_info, weiyan_res_id, flypet_info, xianbao_info, multi_mount_res_id)
	self:SetModelResInfo(role_info, false , false, false, false, show_footprint, false)

	self.clothe_model_id = 0
	self:SetCameraSetting(RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount"))
	local model_offset = 0
	if sprite_info and sprite_info.res_id > 0 then
		model_offset = self:GetModelOffSet(sprite_info.res_id)
		self:AddSprite(sprite_info.res_id, model_offset or 1, sprite_info.lingzhu_res_id)
	else
		self:RemoveSprite()
	end

	if goddess_info and goddess_info.goddess_res_id > 0 then
		model_offset = self:GetModelOffSet(goddess_info.goddess_res_id)
		self:AddGoddess(goddess_info.goddess_res_id, model_offset or -1, goddess_info.goddess_halo_id, goddess_info.goddess_fazhen_id)
	else
		self:RemoveGoddess()
	end

	if lingtong_info and lingtong_info.res_id > 0 then
		model_offset = self:GetModelOffSet(lingtong_info.res_id)
		self:AddLingTong(lingtong_info.res_id, model_offset or 1, lingtong_info.linggong_res_id, lingtong_info.lingqi_res_id)
	else
		self:RemoveLingTong()
	end

	if flypet_info and flypet_info.res_id > 0 then
		model_offset = self:GetModelOffSet(flypet_info.res_id)
		self:AddFlypet(flypet_info.res_id, model_offset or 1)
	else
		self:RemoveFlypet()
	end

	if xianbao_info and xianbao_info.res_id > 0 then
		model_offset = self:GetModelOffSet(xianbao_info.res_id)
		self:AddXianBao(xianbao_info.res_id, model_offset or 1)
	else
		self:RemoveXianBao()
	end

	if mount_res_id == nil or multi_mount_res_id == nil then
		self:RemoveMount()
	end
	
	if fight_mount_resid == nil and self:GetMountLayer(mount_res_id) ~= ANIMATOR_PARAM.MOUNT_LAYER2 then
		self:RemoveFightMount()
	end

	if multi_mount_res_id then
		self:SetMountResid(multi_mount_res_id)
	end

	if mount_res_id then
		self:SetMountResid(mount_res_id, weiyan_res_id)
	end

	if fight_mount_resid then
		self:SetFightMountResid(fight_mount_resid)
	end

	if not show_footprint then
		self:ClearFootprint()
	end
end

function RoleModel:AddSprite(sprite_res_id, offset, lingzhu_res_id)
	if not self.sprite_obj then
		self.sprite_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.sprite_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.sprite_obj:GetRoot().gameObject.transform.rotation = Vector3(0, 0, 0)
		self.sprite_obj.auto_fly = false
		self.sprite_obj:SetIsUseObjPool(false)
		self.sprite_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	self.sprite_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
	local main_part = self.sprite_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetSpiritModel(sprite_res_id))
	if lingzhu_res_id > 0 then
		local main_part = self.sprite_obj:GetPart(SceneObjPart.Halo)
		main_part:ChangeModel(ResPath.GetLingZhuModel(lingzhu_res_id))
	end
end

function RoleModel:RemoveSprite()
	if self.sprite_obj then
		self.sprite_obj:DeleteMe()
		self.sprite_obj = nil
	end
end

function RoleModel:AddFlypet(flypet_res_id, offset)
	if not self.flypet_obj then
		self.flypet_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.flypet_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.flypet_obj:GetRoot().gameObject.transform.transform.rotation = Vector3(0, 0, 0)
		self.flypet_obj.auto_fly = false
		self.flypet_obj:SetIsUseObjPool(false)
		self.flypet_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	self.flypet_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
	local main_part = self.flypet_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetFlyPetModel(flypet_res_id))
end

function RoleModel:RemoveFlypet()
	if self.flypet_obj then
		self.flypet_obj:DeleteMe()
		self.flypet_obj = nil
	end
end

function RoleModel:AddXianBao(xianbao_res_id, offset)
	if not self.xianbao_obj then
		self.xianbao_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.xianbao_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.xianbao_obj:GetRoot().gameObject.transform.rotation = Vector3(0, 0, 0)
		self.xianbao_obj.auto_fly = false
		self.xianbao_obj:SetIsUseObjPool(false)
		self.xianbao_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	self.xianbao_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
	local main_part = self.xianbao_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetXianBaoModel(xianbao_res_id))
end

function RoleModel:RemoveXianBao()
	if self.xianbao_obj then
		self.xianbao_obj:DeleteMe()
		self.xianbao_obj = nil
	end
end

function RoleModel:AddGoddess(goddess_res_id, offset, goddess_halo_id, goddess_fazhen_id)
	if not self.goddess_obj then
		self.goddess_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.goddess_obj:GetRoot().gameObject.transform.localScale = Vector3(1, 1, 1)
		self.goddess_obj:GetRoot().gameObject.transform.rotation = Vector3(0, 0, 0)
		self.goddess_obj.auto_fly = false
		self.goddess_obj:SetIsUseObjPool(false)
		self.goddess_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	self.goddess_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
	local main_part = self.goddess_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetGoddessModel(goddess_res_id))
	if goddess_halo_id > 0 then
		local part = self.goddess_obj:GetPart(SceneObjPart.Halo)
		part:ChangeModel(ResPath.GetGoddessHaloModel(goddess_halo_id))
	end
	if goddess_fazhen_id > 0 then
		local part = self.goddess_obj:GetPart(SceneObjPart.FaZhen)
		part:ChangeModel(ResPath.GetGoddessFaZhenModel(goddess_fazhen_id))
	end
end

function RoleModel:AddLingTong(lingtong_res_id, offset, linggong_res_id, lingqi_res_id)
	if not self.lingtong_obj then
		self.lingtong_obj = DrawObj.New(self, self.draw_obj:GetRoot().gameObject.transform)
		self.lingtong_obj:GetRoot().gameObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
		self.lingtong_obj:GetRoot().gameObject.transform.rotation = Vector3(0, 0, 0)
		self.lingtong_obj.auto_fly = false
		self.lingtong_obj:SetIsUseObjPool(false)
		self.lingtong_obj:GetPart(SceneObjPart.Main):SetMainRole(false)
	end
	self.lingtong_obj:GetRoot().gameObject.transform.localPosition = Vector3(offset, 0, 0)
	local main_part = self.lingtong_obj:GetPart(SceneObjPart.Main)
	main_part:ChangeModel(ResPath.GetLingChongModel(lingtong_res_id))
	if linggong_res_id > 0 then
		local part = self.lingtong_obj:GetPart(SceneObjPart.Weapon)
		part:ChangeModel(ResPath.GetLingGongModel(linggong_res_id, true))
	end
	if lingqi_res_id > 0 then
		local part = self.lingtong_obj:GetPart(SceneObjPart.Mount)
		part:ChangeModel(ResPath.GetLingQiModel(lingqi_res_id))
	end
end

function RoleModel:RemoveLingTong()
	if self.lingtong_obj then
		self.lingtong_obj:DeleteMe()
		self.lingtong_obj = nil
	end
end

function RoleModel:RemoveGoddess()
	if self.goddess_obj then
		self.goddess_obj:DeleteMe()
		self.goddess_obj = nil
	end
end

function RoleModel:ChangeModelByItemId(item_id, func)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if self.run_request then
		GlobalTimerQuest:CancelQuest(self.run_request)
		self.run_request = nil
	end
	if cfg == nil then
		return
	end

	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0

	self:ClearModel()
	self:SetLocalPosition(Vector3(0, 0, 0))
	self:SetRotation(Vector3(0, 0, 0))
	if display_role == DISPLAY_TYPE.MOUNT then
		local multi_id = MultiMountData.Instance:GetMountIdByItemId(item_id)
		if multi_id > 0 then
			res_id = MultiMountData.Instance:GetMulitMountResId(multi_id)
			bundle,asset = ResPath.GetMountModel(res_id)
		end
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		local fun = function ()
			self:ResetRotation()
			-- 智霖要求特殊处理写死ID，进行放大模型
			if item_id == 22515 then
				self:SetLocalPosition(Vector3(0, -2.8, -4))
			elseif multi_id > 0 then 		--双人坐骑
				local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "multimount")
				self:SetCameraSetting(transform)
			elseif item_id == 24952 then 					-- 0元购坐骑模型太侧边看不到一部分
				self:SetLocalPosition(Vector3(0, 0.5, 0))
				self:SetRotation(Vector3(0, -32, 0))
			end
		end
		self:SetRotation(Vector3(0, -40, 0))
		self:SetMainAsset(bundle, asset, fun)
		return
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		if prof == GameEnum.ROLE_PROF_2 then
			self:SetRotation(Vector3(0, -160, 0))
		elseif prof == GameEnum.ROLE_PROF_1 then
			self:SetRotation(Vector3(0, 170, 0))
		else
			self:SetRotation(Vector3(0, -170, 0))
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetWingResid(res_id)
	elseif display_role == DISPLAY_TYPE.FASHION then
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == item_id then
				local weapon_res_id = 0
				local weapon2_res_id = 0
				local temp_res_id = 0
				if v.part_type == 1 then
					temp_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
					weapon_res_id = main_role:GetWeaponResId()
					weapon2_res_id = main_role:GetWeapon2ResId()
				else
					temp_res_id = main_role:GetRoleResId()
					weapon_res_id = v["resouce" .. (game_vo.prof % 10) .. game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
				self:SetRoleResid(temp_res_id)
				self:SetWeaponResid(weapon_res_id)
				if weapon2_res_id then
					self:SetWeapon2Resid(weapon2_res_id)
				end
				break
			end
		end
		self:SetRotation(Vector3(0, 0, 0))
		self:ResetRotation()
		self:SetTrigger(ANIMATOR_PARAM.REST)
	elseif display_role == DISPLAY_TYPE.SHIZHUANG then
		local image_cfg = nil
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == item_id then
				image_cfg = v
				break
			end
		end
		if image_cfg then
			local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
			local res_id = image_cfg["resouce" .. (role_vo.prof % 10) .. role_vo.sex]
			self:SetRoleResid(res_id)
			self:SetRotation(Vector3(0, 0, 0))
			self:ResetRotation()
			self:SetTrigger(ANIMATOR_PARAM.REST)
		end
	elseif display_role == DISPLAY_TYPE.HALO then
		for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetHaloResid(res_id)
		self:SetRotation(Vector3(0, 0, 0))
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
			if v.id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		self:SetRotation(Vector3(0, -35, 0))
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
			end
		end
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.halo_res_id = res_id
		self:SetGoddessModelResInfo(info)
		return
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
			end
		end
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.fazhen_res_id = res_id
		self:SetGoddessModelResInfo(info)
		return

	elseif display_role == DISPLAY_TYPE.WEIYAN then
		for k, v in pairs(WeiYanData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
		local mount_res_id = (mulit_mount_res_id > 0 and mulit_mount_res_id) or MountData.Instance:GetMountResIdByImageId(MountData.Instance:GetUsedImageId())
		if mount_res_id <= 0 then
			return
		end

		local bundle, asset = ResPath.GetMountModel(mount_res_id)
		self:SetMainAsset(bundle, asset, function()
			self:SetWeiYanResid(res_id, mount_res_id, false)
		end)
		self.run_request = GlobalTimerQuest:AddRunQuest(function()
			self:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		end, 0.1)
		self:ResetRotation()
		self:SetRotation(Vector3(0, 160, 0))
		return
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
				--self:SetModel(info, DISPLAY_TYPE.XIAN_NV)
				self:ResetRotation()
				self:SetGoddessModelResInfo(info)
				self:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))	
				return
			end
			res_id = xiannv_resid
		end
	elseif display_role == DISPLAY_TYPE.BUBBLE then
		local index = CoolChatData.Instance:GetBubbleIndexByItemId(item_id)
		if index > 0 then
			local PrefabName = "BubbleChat" .. index

			local async_loader = AllocAsyncLoader(self, "chatres_loader")
			local bundle = "uis/chatres/bubbleres/bubble" .. index .. "_prefab"
			async_loader:Load(bundle, PrefabName, function(obj)
					-- if obj then
					-- 	obj.transform:SetParent(self.ani_obj.transform, false)
					-- end
				end)
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == item_id then
				bundle, asset = ResPath.GetFaBaoModel(v.image_id)
				res_id = v.image_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
		for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetFootResid(res_id)
		self.display:SetRotation(Vector3(0, -90, 0))
		self:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.LITTLEPET then
		for k, v in pairs(LittlePetData.Instance:GetLittlePetCfg()) do
			if v.active_item_id == item_id then
				bundle, asset = ResPath.GetLittlePetModel(v.using_img_id)
				res_id = v.active_item_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFaBaoModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
		local fun = function ()
			self:ResetRotation()
		end
		self:SetMainAsset(bundle, asset, fun)
		-- self:SetLoopAnimal("bj_rest")	--会播放两次动画
		self:SetRotation(Vector3(0, 0, 0))
		return
	elseif display_role == DISPLAY_TYPE.TOUSHI then
		for k, v in pairs(TouShiData.Instance:GetSpecialImageCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetTouShiResid(res_id)
		return
	elseif display_role == DISPLAY_TYPE.MASK then
		for k, v in pairs(MaskData.Instance:GetSpecialImage()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetMaskResid(res_id)
		return
	elseif display_role == DISPLAY_TYPE.WAIST then
		for k, v in pairs(WaistData.Instance:GetSpecialImage()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetWaistResid(res_id)
		self:SetRotation(Vector3(0, 48, 0))
		return
	elseif display_role == DISPLAY_TYPE.QILINBI then
		for k, v in pairs(QilinBiData.Instance:GetSpecialImage()) do
			if v.item_id == item_id then
				res_id = v["res_id" .. game_vo.sex .. "_h"]
				break
			end
		end
		local bundle, asset = ResPath.GetQilinBiModel(res_id, game_vo.sex)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.XIAOGUI then
		local cfg = EquipData.GetXiaoGuiCfgById(item_id)
		res_id = cfg.res_id
		local bundle, asset = ResPath.GetShouHuXiaoGuiModel(res_id)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.LINGZHU then
		for k, v in pairs(LingZhuData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingZhuModel(res_id, true)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.XIANBAO then
		for k, v in pairs(XianBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetXianBaoModel(res_id)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		for k, v in pairs(LingChongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id_h
				break
			end
		end
		local bundle, asset = ResPath.GetLingChongModel(res_id)
		self:SetMainAsset(bundle, asset)
		self:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
		return
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		for k, v in pairs(LingGongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id_h
				break
			end
		end
		local bundle, asset = ResPath.GetLingGongModel(res_id)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.LINGQI then
		for k, v in pairs(LingQiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingQiModel(res_id, true)
		self:SetMainAsset(bundle, asset)
		self:SetRotation(Vector3(0, -45, 0))
		return
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		for k, v in pairs(LingChongData:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingChongModel(res_id)
		self:SetMainAsset(bundle, asset)
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		for k, v in pairs(LingGongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetLingGongModel(res_id)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
		for k, v in pairs(ShouHuanData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		self:SetRoleResid(main_role:GetRoleResId())
		self:SetShouHuanResid(res_id)
		return
	elseif display_role == DISPLAY_TYPE.TAIL then 
		for k, v in pairs(TailData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetTailModel(res_id)
		self:SetTailResid(res_id)
		self:SetRoleResid(main_role:GetRoleResId())
		local role_prof = PlayerData.Instance:GetRoleBaseProf()
		if prof == GameEnum.ROLE_PROF_1 or prof == GameEnum.ROLE_PROF_3 then
			rotation = Vector3(0, 130, 0)
		else
			rotation = Vector3(0, 160, 0)
		end
		self:SetRotation(rotation)
		return
	elseif display_role == DISPLAY_TYPE.FLYPET then
		for k, v in pairs(FlyPetData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		local bundle, asset = ResPath.GetFlyPetModel(res_id)
		self:SetMainAsset(bundle, asset)
		return
	elseif display_role == DISPLAY_TYPE.BIANSHEN then	-- 变身
		local greate_cfg = BianShenData.Instance:GetGeneralConfig().level
		for k, v in pairs(greate_cfg) do
			if v.item_id == item_id then
				res_id = v.image_id
				break
			end
		end
		local bundle, asset = ResPath.GetMingJiangRes(res_id)
		self:SetMainAsset(bundle, asset)
	end

	if bundle and asset then
		self:SetMainAsset(bundle, asset, function()
			if func then
				func()
			end
		end)
		if display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			self:SetTrigger(ANIMATOR_PARAM.REST)
		end
	end
end

function RoleModel:SetHeadRes(bundle, name)
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:ChangeModel(bundle, name)
end

function RoleModel:RemoveHead()
	local part = self.draw_obj:GetPart(SceneObjPart.Head)
	part:RemoveModel()
end
