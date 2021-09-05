CheckAppearanceView = CheckAppearanceView or BaseClass(BaseRender)

function CheckAppearanceView:__init(instance, parent_view)
	self.parent_view = parent_view
	self.appearance_item_list = {}
	self:LoadCell()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightTxt"])

	self.node_list["AttrBtn"].button:AddClickListener(BindTool.Bind(self.OnButtonAttr, self))

end

function CheckAppearanceView:__delete()
	self.fight_text = nil
	self.parent_view = nil

	if self.sprite_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.sprite_time_quest)
		self.sprite_time_quest = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	for k, v in pairs(self.appearance_item_list) do
		v:DeleteMe()
	end
	self.appearance_item_list = {}
end

function CheckAppearanceView:CloseCallBack()
	if self.sprite_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.sprite_time_quest)
		self.sprite_time_quest = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CheckAppearanceView:SetAttr()
	self:LoadCell(true)
	self:Flush()
end

function CheckAppearanceView:OnFlush()
	local index_list = CheckData.Instance:GetShowTabIndex()
	table.remove(index_list, 1)
	if #index_list < 1 then return end

	for k, v in pairs(index_list) do
		if self.appearance_item_list[k] then
			self.appearance_item_list[k]:SetData(v)
			self.appearance_item_list[k]:SetActive(true)
			self.appearance_item_list[k]:SetHLImg(v == self.select_type)
		end
	end

	for i = #index_list + 1, #self.appearance_item_list, 1 do
		if self.appearance_item_list[i] then
			self.appearance_item_list[i]:SetActive(false)
		end
	end

	self:SetModle()
end

function CheckAppearanceView:OnButtonAttr()
	local attr_tab = {}
	for k, v in pairs(self.attribute) do
		if k ~= "move_speed" and tonumber(v) > 0 then
			attr_tab[k] = v
		end
	end
	attr_tab.name = Language.Tip.JiChuShuXing2
	TipsCtrl.Instance:ShowAttrView(attr_tab, nil, nil, true)
end

function CheckAppearanceView:LoadCell(first_time)
	local index_list = CheckData.Instance:GetShowTabIndex()
	table.remove(index_list, 1)
	if first_time then
		self.select_type = index_list[1]
	end
	local res_async_loader = AllocResAsyncLoader(self, "checkview")
	res_async_loader:Load("uis/views/checkview_prefab", "CheckItemCell", nil, function(new_obj)
		if nil == new_obj then return end

		for i = 1, #index_list do
			if nil == self.appearance_item_list[i] then
				local obj = ResMgr:Instantiate(new_obj)
				local obj_transform = obj.transform
				obj_transform:SetParent(self.node_list["LeftList"].transform)
				obj.transform.localScale = Vector3(1, 1, 1)
				obj.transform.localPosition = Vector3(0, 0, 0)
				local item_render = AppearanceItemRender.New(obj)
				item_render:AddClickEventListener(BindTool.Bind(self.OnClickItemRender, self))
				self.appearance_item_list[i] = item_render
				self.appearance_item_list[i]:SetData(index_list[i])
				self.appearance_item_list[i]:SetHLImg(index_list[i] == self.select_type)
			end
		end
	end)
end

function CheckAppearanceView:OnClickItemRender(item)
	local data = item:GetData()
	if nil == data then return end

	self.select_type = data
	self:SetModle()
end

function CheckAppearanceView:SetModle()
	self.parent_view:SetModle(self.select_type)

	local check_attr = CheckData.Instance:UpdateAttrView()
	self.attribute = CommonStruct.Attribute()
	self.capability = 0
	self.name = ""
	local index = self.select_type

	for k, v in pairs(self.appearance_item_list) do
		if v:GetData() and v:GetData() == index then
			v:SetHLImg(true)
		else
			v:SetHLImg(false)
		end
	end

	if index == CHECK_TAB_TYPE.MOUNT then			
		self:SetMountAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.WING then			
		self:SetWingAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SHIZHUANG then 		
		self:SetShiZhuanAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SPIRIT then 		
		self:SetSpiritAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SHENBING then 		
		self:SetShenBingAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.FABAO then 			
		self:SetFaBaoAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.FOOT then 			
		self:SetFootAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.HALO then 			
		self:SetHaloAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.FIGHT_MOUNT then 	
		self:SetFightMountAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.CLOAK then 		
		self:SetCloakAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.TOUSHI then 		
		self:SetTouShiAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.MASK then 			
		self:SetMaskAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.YAOSHI then 		
		self:SetYaoShiAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.QILINBI then 		
		self:SetQiLinBiAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SHEN_GONG then 	
		self:SetShenGongAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SHEN_YI then 		
		self:SetShenYiAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.GODDESS then 		
		self:SetGoddessAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.LINGZHU then 		
		self:SetLingZhuAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.XIANBAO then 		
		self:SetXianBaoAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.LINGTONG then 		
		self:SetLingTongAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.LINGGONG then 		
		self:SetLingGongAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.LINGQI then		
		self:SetLingQiAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.WEIYAN then 		
		self:SetWeiYanAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.SHOUHUAN then 		
		self:SetShouHuanAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.TAIL then 			
		self:SetTailAttr(check_attr)

	elseif index == CHECK_TAB_TYPE.FLYPET then 
		self:SetFlyPetAttr(check_attr)

	end

	if self.fight_text then
		self.fight_text.text.text = self.capability
	end
	self.node_list["TitleTxt"].text.text = self.name
end

-- 坐骑
function CheckAppearanceView:SetMountAttr(check_attr)
	local mount_attr = check_attr.mount_attr
	if mount_attr.client_grade + 1 ~= 0 then
		if mount_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = MountData.Instance:GetSpecialImagesCfg()[mount_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = MountData.Instance:GetMountImageCfg()[mount_attr.used_imageid].res_id
		end
		local mount_res_id = res_id

		local call_back = function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
			if obj then
				local advance_huanhua_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount_huanhua", mount_res_id)
				local advance_transform_cfg = AdvanceData.Instance:GetAdvanceTransformCfg("mount", mount_res_id)
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
		local bundle, asset = ResPath.GetMountModel(mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "mount")
		transform.rotation = Quaternion.Euler(0, 169, 0)
		UIScene:SetCameraTransform(transform)
	end

	self.attribute = CommonDataManager.GetAttributteByClass(mount_attr)
	self.capability = mount_attr.capability

	local grade = mount_attr.client_grade + 1
	local mount_cfg = MountData.Instance:GetMountGradeCfg(grade)
	if mount_cfg == nil then return end
	local image_id = mount_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..MountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"
	if mount_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(mount_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color]) 
	end	
end

-- 羽翼
function CheckAppearanceView:SetWingAttr(check_attr)
	local wing_attr = check_attr.wing_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = {}
	info.wing_info = {used_imageid = role_info.wing_info.grade == 1 and role_info.wing_info.grade or role_info.wing_info.grade - 1}
	info.prof = role_info.prof
	info.sex = role_info.sex
	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.shizhuang_part_list = {{image_id = 0}, {image_id = fashion_id}}

	local call_back = function(model, obj)
		if obj then
			model:SetTrigger(ANIMATOR_PARAM.STATUS)
			if base_prof == GameEnum.ROLE_PROF_3 or base_prof == GameEnum.ROLE_PROF_2 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -155, 0)
			elseif base_prof == GameEnum.ROLE_PROF_1 then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 170, 0)
			else
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -170, 0)
			end
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	UIScene:SetRoleModelResInfo(info, true, false, true, true, false, true)
	UIScene:SetActionEnable(false)

	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, 169, 0)
	UIScene:SetCameraTransform(transform)

	self.attribute = CommonDataManager.GetAttributteByClass(wing_attr)
	self.capability = wing_attr.capability

	local grade = wing_attr.client_grade + 1
	local used_imageid = wing_attr.used_imageid
	local is_spec = false
	if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
		is_spec = true
		used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
	end
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..WingData.Instance:GetImageListInfo(used_imageid, is_spec).image_name.."</color>"

	if wing_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(wing_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color]) 
	end
end

-- 时装
function CheckAppearanceView:SetShiZhuanAttr(check_attr)
	local fashion_attr = check_attr.fashion_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end

	if fashion_attr.client_grade + 1 ~= 0 then
		local info = TableCopy(role_info)
		info.appearance = {}
		local fashion_info = role_info.shizhuang_part_list[2]
		local wuqi_info = role_info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		info.appearance.fashion_body = fashion_id
		UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
		UIScene:ResetLocalPostion()

		local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
		transform.rotation = Quaternion.Euler(8, 169, 0)
		UIScene:SetCameraTransform(transform)
	end

	self.attribute = CommonDataManager.GetAttributteByClass(fashion_attr)
	self.capability = fashion_attr.capability

	local grade = fashion_attr.client_grade + 1
	local fashion_cfg = FashionData.Instance:GetWuQiGradeCfg(grade)
	if nil == fashion_cfg then return end
	local image_id = fashion_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
	if not image_id_cfg then return end
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"
	if fashion_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(fashion_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end

-- 宠物
function CheckAppearanceView:SetSpiritAttr(check_attr)
	local spirit_attr = check_attr.spirit_attr
	if spirit_attr then
		local show_spirit_id = 0
		local show_spirit_level = 0
		if spirit_attr.use_jingling_id == 0 then
			for k,v in pairs(spirit_attr.jingling_item_list) do
				if v.jingling_id ~= 0 then

					show_spirit_id = v.jingling_id
					show_spirit_level = v.jingling_level
					break
				end
			end
		else
			show_spirit_id = spirit_attr.use_jingling_id
			for k,v in pairs(spirit_attr.jingling_item_list) do
				if v.jingling_id == show_spirit_id then
					show_spirit_level = v.jingling_level
					break
				end
			end
		end
		local spirit_cfg = SpiritData.Instance:GetSpiritLevelCfgById(show_spirit_id, show_spirit_level)
		local gongji = 0
		local fangyu = 0
		local shengming = 0
		local kangbao = 0
		if show_spirit_id ~= 0 and spirit_cfg ~= nil then
			local item_cfg = {}
			item_cfg = ItemData.Instance:GetItemConfig(show_spirit_id)
			if item_cfg ~= nil then
				self.name = item_cfg.name
			end
			
			gongji = spirit_cfg.gongji
			fangyu = spirit_cfg.fangyu
			shengming = spirit_cfg.maxhp
			kangbao = spirit_cfg.jianren
		end
		self.attribute.gong_ji = gongji
		self.attribute.fang_yu = fangyu
		self.attribute.max_hp = shengming
		self.attribute.kangbao = kangbao
		local jingling_item = CheckData.Instance:GetShowJingLingAttr()
		self.capability = RankData.Instance:GetJingLingPower(jingling_item.jingling_id, jingling_item.jingling_level)

		UIScene:SetActionEnable(false)
		if show_spirit_id == 0 then return end
		if self.sprite_time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.sprite_time_quest)
			self.sprite_time_quest = nil
		end
		local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(show_spirit_id)
		if spirit_cfg ~= nil then

			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)

			local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "spirit")
			transform.rotation = Quaternion.Euler(0, 169, 0)
			UIScene:SetCameraTransform(transform)

			self:CalToSpiritShowAnim()
		end
	end	
end

-- 神兵
function CheckAppearanceView:SetShenBingAttr(check_attr)
	local shenbing_attr = check_attr.shenbing_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	if role_info == nil then return end
	if shenbing_attr.client_grade + 1 ~= 0 then
		local info = {}
		info.prof = role_info.prof
		info.sex = role_info.sex
		info.is_not_show_weapon = false
		local fashion_info = role_info.shizhuang_part_list[2]
		local wuqi_info = role_info.shizhuang_part_list[1]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		info.is_normal_wuqi = true
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		local wuqi_id = wuqi_info.grade == 0 and wuqi_info.grade or wuqi_info.grade - 1
		info.shizhuang_part_list = {{image_id = wuqi_id}, {image_id = fashion_id}}
		UIScene:SetRoleModelResInfo(info)
		local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetBool(ANIMATOR_PARAM.FIGHT, true)
		end
	end

	self.attribute = CommonDataManager.GetAttributteByClass(shenbing_attr)
	self.capability = shenbing_attr.capability

	local grade = shenbing_attr.client_grade + 1
	local shengbing_cfg = MountData.Instance:GetMountGradeCfg(grade)
	if shengbing_cfg == nil then return end
	local image_id = shengbing_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
	if not image_id_cfg then return end
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"
	if shenbing_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(shenbing_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end

-- 法宝
function CheckAppearanceView:SetFaBaoAttr(check_attr)
	local fabao_attr = check_attr.fabao_attr
	if fabao_attr.client_grade + 1 ~= 0 then
		if fabao_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = FaBaoData.Instance:GetSpecialImagesCfg()[fabao_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = FaBaoData.Instance:GetFaBaoImageCfg()[fabao_attr.used_imageid].res_id
		end
		local fabao_res_id = res_id

		local call_back = function(model, obj)
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = ResPath.GetFaBaoModel(fabao_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "baoju")
		transform.rotation = Quaternion.Euler(0, 169, 0)
		UIScene:SetCameraTransform(transform)
	end

	self.attribute = CommonDataManager.GetAttributteByClass(fabao_attr)
	self.capability = fabao_attr.capability

	local grade = fabao_attr.client_grade + 1
	local fabao_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(grade)
	if fabao_cfg == nil then return end
	local image_id = fabao_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FaBaoData.Instance:GetFaBaoImageCfg(image_id)[image_id].image_name.."</color>"
	if fabao_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(fabao_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end

-- 足印
function CheckAppearanceView:SetFootAttr(check_attr)
	local foot_attr = check_attr.foot_attr
	local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	end
	local call_back = function(model, obj)
		if obj then
			obj.gameObject.transform.localRotation = Quaternion.Euler(0, -90, 0)
		end
	end
	UIScene:SetModelLoadCallBack(call_back)
	
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = TableCopy(role_info)
	info.appearance = {}
	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, true, true, true)
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, 169, 0)
	UIScene:SetCameraTransform(transform)

	self.attribute = CommonDataManager.GetAttributteByClass(foot_attr)
	self.capability = foot_attr.capability

	local grade = foot_attr.client_grade + 1
	local foot_cfg = FootData.Instance:GetFootGradeCfg(grade)
	if nil == foot_cfg then return end
	local image_id = foot_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FootData.Instance:GetFootImageCfg(image_id)[image_id].image_name.."</color>"
	if foot_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(foot_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end
-- 光环
function CheckAppearanceView:SetHaloAttr(check_attr)
	local halo_attr = check_attr.halo_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = TableCopy(role_info)
	info.appearance = {}

	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = use_special_img or 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	local wuqi_id = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
	info.appearance.fashion_body = fashion_id

	UIScene:SetRoleModelResInfo(info, true, true, false, true, false, true)
	UIScene:ResetLocalPostion()
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, 169, 0)
	UIScene:SetCameraTransform(transform)

	self.attribute = CommonDataManager.GetAttributteByClass(halo_attr)
	self.capability = halo_attr.capability

	local grade = halo_attr.client_grade + 1
	local halo_cfg = HaloData.Instance:GetHaloGradeCfg(grade)
	if halo_cfg == nil then return end
	local image_id = halo_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..HaloData.Instance:GetHaloImageCfg(image_id)[image_id].image_name.."</color>"
	if halo_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(halo_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end		
end
-- 战斗坐骑
function CheckAppearanceView:SetFightMountAttr(check_attr)
	local fight_attr = check_attr.fight_attr
	local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	if part then
		part:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	end
	if fight_attr.client_grade + 1 ~= 0 then
		if fight_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = FightMountData.Instance:GetSpecialImagesCfg()[fight_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			if fight_attr.used_imageid == 0 then
				res_id = 0
			else
				res_id = FightMountData.Instance:GetMountImageCfg()[fight_attr.used_imageid].res_id
			end
		end
		local mount_res_id = res_id
		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, -35, 0)
			end
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
		UIScene:SetModelLoadCallBack(call_back)
		local bundle, asset = ResPath.GetFightMountModel(mount_res_id)
		local bundle_list = {[SceneObjPart.Main] = bundle}
		local asset_list = {[SceneObjPart.Main] = asset}
		UIScene:ModelBundle(bundle_list, asset_list)

		local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "fightmount")
		transform.rotation = Quaternion.Euler(25, 169, 0)
		UIScene:SetCameraTransform(transform)

		self.attribute = CommonDataManager.GetAttributteByClass(fight_attr)
		self.capability = fight_attr.capability

		local grade = fight_attr.client_grade + 1
		local fightmount_cfg = FightMountData.Instance:GetMountGradeCfg(grade)
		if nil == fightmount_cfg then return end
		local image_id = fightmount_cfg.image_id
		local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
		local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FightMountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"
		if fight_attr.client_grade == 0 then
			self.name = name_str
		else
			local grade_txt = CheckData.Instance:GetGradeName(fight_attr.client_grade)
			self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
		end			
	end	
end

-- 披风
function CheckAppearanceView:SetCloakAttr(check_attr)
	local cloak_attr = check_attr.cloak_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = TableCopy(role_info)
	info.appearance = {}
	local fashion_info = role_info.shizhuang_part_list[2]
	local wuqi_info = role_info.shizhuang_part_list[1]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	info.is_normal_wuqi = wuqi_info.use_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	if cloak_attr.capability > 0 and cloak_attr.used_imageid <= 0 then
		local cfg = CloakData.Instance:GetCloakLevelCfg(cloak_attr.cloak_level)
		info.cloak_info.used_imageid = cfg and cfg.active_image or 0
	end

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
		end
	end
	UIScene:SetModelLoadCallBack(call_back)

	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, false)
	UIScene:SetActionEnable(false)

	local base_prof = PlayerData.Instance:GetRoleBaseProf(info.prof)
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, 169, 0)
	UIScene:SetCameraTransform(transform)

	self.attribute = CommonDataManager.GetAttributteByClass(cloak_attr)
	self.capability = cloak_attr.capability

	local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_attr.cloak_level)
	if cloak_level_cfg == nil then return end
	local used_imageid = cloak_level_cfg.active_image
	if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
		used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
	end

	local color = math.floor((used_imageid - 1) / 2) + 1
	if cloak_attr.capability > 0 and used_imageid > 0 then
		local name_str = " <color="..SOUL_NAME_COLOR[color]..">" .. "Lv." .. cloak_attr.cloak_level  .." " .. CloakData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
		self.name = name_str
	end
end

-- 头饰
function CheckAppearanceView:SetTouShiAttr(check_attr)
	local toushi_attr = check_attr.toushi_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.toushi_used_imageid = role_info.head_info.grade == 1 and role_info.head_info.grade or role_info.head_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)

	if toushi_attr then
		local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(toushi_attr.grade)
		if nil == grade_info then return end
		local image_info = TouShiData.Instance:GetTouShiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = TouShiData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(TouShiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * toushi_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * toushi_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * toushi_attr.shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp

		self.capability = toushi_attr.capability
	end
end
-- 面具
function CheckAppearanceView:SetMaskAttr(check_attr)
	local mask_attr = check_attr.mask_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.mask_used_imageid = role_info.mask_info.grade == 1 and role_info.mask_info.grade or role_info.mask_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)

	if mask_attr then
		local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(mask_attr.grade)
		if nil == grade_info then return end
		local image_info = MaskData.Instance:GetMaskImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = MaskData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(MaskShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * mask_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * mask_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * mask_attr.shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = mask_attr.capability
	end	
end
-- 腰饰
function CheckAppearanceView:SetYaoShiAttr(check_attr)
	local yaoshi_attr = check_attr.yaoshi_attr
	local role_info = CheckData.Instance:GetRoleInfo()
	local info = {}
	info.prof = role_info.prof
	info.sex = role_info.sex
	info.appearance = {}
	info.appearance.yaoshi_used_imageid = role_info.waist_info.grade == 1 and role_info.waist_info.grade or role_info.waist_info.grade - 1
	local fashion_info = role_info.shizhuang_part_list[2]
	local is_used_special_img = fashion_info.use_special_img
	info.is_normal_fashion = is_used_special_img == 0
	local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
	info.appearance.fashion_body = fashion_id
	UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)

	if yaoshi_attr then
		local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(yaoshi_attr.grade)
		if nil == grade_info then return end
		local image_info = WaistData.Instance:GetWaistImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = WaistData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(YaoShiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * yaoshi_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * yaoshi_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * yaoshi_attr.shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = yaoshi_attr.capability
	end
end
-- 麒麟臂
function CheckAppearanceView:SetQiLinBiAttr(check_attr)
	local qilinbi_attr = check_attr.qilinbi_attr
	if qilinbi_attr then
		local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(qilinbi_attr.grade)
		if nil == grade_info then return end
		local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = QilinBiData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(QilinBiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local zizhi_hp = zi_zhi_cfg.maxhp * qilinbi_attr.shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * qilinbi_attr.shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * qilinbi_attr.shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = qilinbi_attr.capability

		local role_info = CheckData.Instance:GetRoleInfo()
		local bundle, asset = ResPath.GetQilinBiModel(image_info["res_id" .. role_info.sex .. "_h"], role_info.sex)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
	end
end

-- 仙环
function CheckAppearanceView:SetShenGongAttr(check_attr)
	local xiannv_attr = check_attr.xiannv_attr
	local shengong_attr = check_attr.shengong_attr
	if check_attr and shengong_attr.client_grade + 1 ~= 0 then
		local info = {}
		local goddess_data = GoddessData.Instance

		info.role_res_id = -1
		local goddess_huanhua_id = xiannv_attr.huanhua_id

		if goddess_huanhua_id > 0 then
			info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
		else
			local goddess_id = xiannv_attr.pos_list[1]
			if goddess_id == -1 then
				goddess_id = 0
			end
			info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
		end

		if shengong_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShengongData.Instance:GetSpecialImagesCfg()[shengong_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShengongData.Instance:GetShengongImageCfg()[shengong_attr.used_imageid].res_id
		end
		info.halo_res_id = res_id

		UIScene:SetGoddessModelResInfo(info)
	else
		UIScene:IsNotCreateRoleModel(false)
	end

	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_attr.grade)
	local attr = CommonDataManager.GetAttributteByClass(shengong_grade_cfg)

	local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShengongShuXingDanCfgType.Type)
	if zi_zhi_cfg == nil then return end
	local zizhi_hp = zi_zhi_cfg.maxhp * shengong_attr.shuxingdan_count 
	local zizhi_gongji = zi_zhi_cfg.gongji * shengong_attr.shuxingdan_count
	local zizhi_fangyu = zi_zhi_cfg.fangyu * shengong_attr.shuxingdan_count

	self.attribute = CommonDataManager.GetAttributteByClass(attr)
	self.attribute.gong_ji = (attr.gong_ji or 0) + zizhi_gongji
	self.attribute.fang_yu = (attr.fang_yu or 0) + zizhi_fangyu
	self.attribute.max_hp = (attr.max_hp or 0) + zizhi_hp
	self.capability = shengong_attr.capability

	local grade = shengong_attr.client_grade + 1
	local shengong_cfg = ShengongData.Instance:GetShengongGradeCfg(grade)
	if nil == shengong_cfg then return end
	local image_id = shengong_cfg.image_id
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg(image_id)[image_id].image_name.."</color>"

	if shengong_attr.client_grade == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(shengong_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end
-- 仙阵
function CheckAppearanceView:SetShenYiAttr(check_attr)
	local xiannv_attr = check_attr.xiannv_attr
	local shenyi_attr = check_attr.shenyi_attr
	UIScene:SetActionEnable(false)
	if shenyi_attr.client_grade + 1 ~= 0 then
		local info = {}
		local goddess_data = GoddessData.Instance
		info.role_res_id = -1

		local goddess_huanhua_id = xiannv_attr.huanhua_id
		if goddess_huanhua_id > 0 then
			info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
		else
			local goddess_id = xiannv_attr.pos_list[1]
			if goddess_id == -1 then
				goddess_id = 0
			end
			info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
		end

		if shenyi_attr.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			res_id = ShenyiData.Instance:GetSpecialImagesCfg()[shenyi_attr.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID].res_id
		else
			res_id = ShenyiData.Instance:GetShenyiImageCfg()[shenyi_attr.used_imageid].res_id
		end
		info.fazhen_res_id = res_id

		UIScene:SetGoddessModelResInfo(info)


		if self.time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end

		self:CalToShowAnim(true)
	else
		UIScene:IsNotCreateRoleModel(false)
	end

	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_attr.grade)
	local attr = CommonDataManager.GetAttributteByClass(shenyi_grade_cfg)

	local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShenyiShuXingDanCfgType.Type)
	if zi_zhi_cfg == nil then return end
	local zizhi_hp = zi_zhi_cfg.maxhp * shenyi_attr.shuxingdan_count 
	local zizhi_gongji = zi_zhi_cfg.gongji * shenyi_attr.shuxingdan_count
	local zizhi_fangyu = zi_zhi_cfg.fangyu * shenyi_attr.shuxingdan_count

	self.attribute = CommonDataManager.GetAttributteByClass(attr)
	self.attribute.gong_ji = (attr.gong_ji or 0) + zizhi_gongji
	self.attribute.fang_yu = (attr.fang_yu or 0) + zizhi_fangyu
	self.attribute.max_hp = (attr.max_hp or 0) + zizhi_hp
	self.capability = shenyi_attr.capability

	local grade = shenyi_attr.client_grade + 1
	local used_imageid = shenyi_attr.used_imageid
	if used_imageid > 1000 then
		used_imageid = used_imageid - 1000
	end
	local image_id = ShenyiData.Instance:GetImageListInfo(used_imageid).image_name
	local color = (grade / 3 + 1) >= 5 and 5 or math.floor(grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"

	if shenyi_attr.used_imageid == 0 then
		self.name = name_str
	else
		local grade_txt = CheckData.Instance:GetGradeName(shenyi_attr.client_grade)
		self.name = ToColorStr(grade_txt .."·" .. name_str, SOUL_NAME_COLOR[color])
	end
end

-- 仙女
function CheckAppearanceView:SetGoddessAttr(check_attr)
	local xiannv_attr = check_attr.xiannv_attr
	UIScene:SetActionEnable(false)
	local goddess_data = GoddessData.Instance
	local info = {}
	info.role_res_id = -1
	local goddess_data = GoddessData.Instance
	local goddess_huanhua_id = xiannv_attr.huanhua_id

	if goddess_huanhua_id > 0 then
		info.role_res_id = goddess_data:GetXianNvHuanHuaCfg(goddess_huanhua_id).resid
	else
		local goddess_id = xiannv_attr.pos_list[1]
		if goddess_id == -1 then
			goddess_id = 0
		end
		info.role_res_id = GoddessData.Instance:GetXianNvCfg(goddess_id).resid
	end

	UIScene:SetGoddessModelResInfo(info)
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	self:CalToShowAnim(true)

	local attr = GoddessData.Instance:GetXiannvAttrByRoleInfo(check_attr)
	self.attribute = CommonDataManager.GetAttributteByClass(attr)
	self.capability = xiannv_attr.capability

	if xiannv_attr.xiannv_name ~= "" then
		self.name = xiannv_attr.xiannv_name
	else
		local show_id = xiannv_attr.pos_list[1]
		if show_id == -1 then
			local active_list = goddess_data:GetXiannvActiveList(xiannv_attr.xiannv_item_list)
			if #active_list ~= 0 then
				show_id = active_list[1]
				self.name = goddess_data:GetXianNvCfg(show_id).name
			end
		else
			self.name = goddess_data:GetXianNvCfg(show_id).name
		end
	end
end

-- 灵珠
function CheckAppearanceView:SetLingZhuAttr(check_attr)
	local lingzhu_attr = check_attr.lingzhu_attr
	if lingzhu_attr then
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(lingzhu_attr.grade)
		if nil == grade_info then return end
		local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingZhuData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(LingZhuShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = lingzhu_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = lingzhu_attr.capability

		local bundle, asset = ResPath.GetLingZhuModel(image_info.res_id, true)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

-- 仙宝
function CheckAppearanceView:SetXianBaoAttr(check_attr)
	local xianbao_attr = check_attr.xianbao_attr
	if xianbao_attr then
		local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(xianbao_attr.grade)
		if nil == grade_info then return end
		local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = XianBaoData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(XianBaoShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = xianbao_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = xianbao_attr.capability

		local bundle, asset = ResPath.GetXianBaoModel(image_info.res_id, true)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

-- 灵童
function CheckAppearanceView:SetLingTongAttr(check_attr)
	local lingtong_attr = check_attr.lingtong_attr
	if lingtong_attr then
		local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(lingtong_attr.grade)
		if nil == grade_info then return end
		local image_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .. "·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingChongData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(LingChongShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = lingtong_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = lingtong_attr.capability

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle_effect, asset_effect = ResPath.GetLingChongModelEffect(image_info.res_id_h)
		UIScene:LoadSceneEffect(bundle_effect, asset_effect)
		local bundle, asset = ResPath.GetLingChongModel(image_info.res_id_h)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

-- 灵弓
function CheckAppearanceView:SetLingGongAttr(check_attr)
	local linggong_attr = check_attr.linggong_attr
	if linggong_attr then
		local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(linggong_attr.grade)
		if nil == grade_info then return end
		local image_info = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingGongData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(LingGongShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = linggong_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = linggong_attr.capability

		local bundle, asset = ResPath.GetLingGongModel(image_info.res_id_h)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

-- 灵骑
function CheckAppearanceView:SetLingQiAttr(check_attr)
	local lingqi_attr = check_attr.lingqi_attr
	if lingqi_attr then
		local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(lingqi_attr.grade)
		if nil == grade_info then return end
		local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingQiData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(LingQiShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = lingqi_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = lingqi_attr.capability

		local bundle, asset = ResPath.GetLingQiModel(image_info.res_id, true)
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

-- 尾焰
function CheckAppearanceView:SetWeiYanAttr(check_attr)
	local weiyan_attr = check_attr.weiyan_attr
	if weiyan_attr then
		local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(weiyan_attr.grade)
		if nil == grade_info then return end
		local image_info = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = WeiYanData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(WeiYanShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = weiyan_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = weiyan_attr.capability

		local role_info = CheckData.Instance:GetRoleInfo()
		local mount_res_id = nil
		local image_id = role_info.mount_info.grade == 1 and role_info.mount_info.grade or role_info.mount_info.grade - 1
		local cfg = MountData.Instance:GetMountImageCfg()[image_id]
		if cfg then
			mount_res_id = cfg.res_id
		else
			return
		end
		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
		local load_list = {{mount_bundle, mount_asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			UIScene:SetWeiYanResid(image_info.res_id, mount_res_id)
			local bundle_list = {[SceneObjPart.Main] = mount_bundle}
			local asset_list = {[SceneObjPart.Main] = mount_asset}
			UIScene:ModelBundle(bundle_list, asset_list)

			local part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
			if part then
				part:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			end
		end)
	end
end

-- 手环
function CheckAppearanceView:SetShouHuanAttr(check_attr)
	local shouhuan_attr = check_attr.shouhuan_attr
	if shouhuan_attr then
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(shouhuan_attr.grade)
		if nil == grade_info then return end
		local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = LingZhuData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(ShouHuanShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = shouhuan_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = shouhuan_attr.capability

		local call_back = function(model, obj)
			if obj then
				obj.gameObject.transform.localRotation = Quaternion.Euler(0, 90, 0)
			end
		end
		UIScene:SetModelLoadCallBack(call_back)

		local role_info = CheckData.Instance:GetRoleInfo()
		local info = {}
		info.prof = role_info.prof
		info.sex = role_info.sex
		info.appearance = {}
		info.appearance.shouhuan_used_imageid = grade_info.image_id
		local fashion_info = role_info.shizhuang_part_list[2]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		info.appearance.fashion_body = fashion_id
		UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)		
	end
end

-- 尾巴
function CheckAppearanceView:SetTailAttr(check_attr)
	local tail_attr = check_attr.tail_attr
	if tail_attr then
		local grade_info = TailData.Instance:GetTailGradeCfgInfoByGrade(tail_attr.grade)
		if nil == grade_info then return end
		local image_info = TailData.Instance:GetTailImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = TailData.Instance:CalcChengZhandDanAddBaseAttr(grade_info, tail_attr)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(TailShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = tail_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = tail_attr.capability

		local role_info = CheckData.Instance:GetRoleInfo()
		local info = {}
		info.prof = role_info.prof
		info.sex = role_info.sex
		info.appearance = {}
		info.appearance.tail_used_imageid = grade_info.image_id
		local fashion_info = role_info.shizhuang_part_list[2]
		local is_used_special_img = fashion_info.use_special_img
		info.is_normal_fashion = is_used_special_img == 0
		local fashion_id = is_used_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		info.appearance.fashion_body = fashion_id
		UIScene:SetRoleModelResInfo(info, true, true, true, true, false, true)
	end
end

-- 飞宠
function CheckAppearanceView:SetFlyPetAttr(check_attr)
	local flypet_attr = check_attr.flypet_attr
	if flypet_attr then
		local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(flypet_attr.grade)
		if nil == grade_info then return end
		local image_info = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		self.name = ToColorStr((grade_info.gradename .."·" .. image_info.image_name), SOUL_NAME_COLOR[image_info.colour])

		local attr = FlyPetData.Instance:UseChengZhandDanAddBaseAttr(grade_info)
		local switch_attr_list = CommonDataManager.SwitchAttri(attr)

		local zi_zhi_cfg = AppearanceData.Instance:GetZiZhiCfg(FlyPetShuXingDanCfgType.Type)
		if zi_zhi_cfg == nil then return end
		local shuxingdan_count = flypet_attr.shuxingdan_list[0]
		local zizhi_hp = zi_zhi_cfg.maxhp * shuxingdan_count 
		local zizhi_gongji = zi_zhi_cfg.gongji * shuxingdan_count
		local zizhi_fangyu = zi_zhi_cfg.fangyu * shuxingdan_count

		self.attribute = CommonDataManager.GetAttributteByClass(switch_attr_list)
		self.attribute.gong_ji = (switch_attr_list.gong_ji or 0) + zizhi_gongji
		self.attribute.fang_yu = (switch_attr_list.fang_yu or 0) + zizhi_fangyu
		self.attribute.max_hp = (switch_attr_list.max_hp or 0) + zizhi_hp
		self.capability = flypet_attr.capability

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetFlyPetModel(image_info.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			local bundle_list = {[SceneObjPart.Main] = bundle}
			local asset_list = {[SceneObjPart.Main] = asset}
			UIScene:ModelBundle(bundle_list, asset_list)
		end)
	end
end

function CheckAppearanceView:CalToShowAnim(is_change_tab)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	local timer = GameEnum.GODDESS_ANIM_LONG_TIME
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 or is_change_tab == true then
			is_change_tab = false
			timer = GameEnum.GODDESS_ANIM_LONG_TIME
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end
	end, 0)
end

function CheckAppearanceView:CalToSpiritShowAnim(is_change_tab)
	self.timer = 8
	local part = nil
	if UIScene.role_model then
		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	end
	self.sprite_time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				part:SetTrigger(ANIMATOR_PARAM.REST)
			end
			self.timer = 8
		end
	end, 0)
end

----------------------------------------
------------AppearanceItemRender
AppearanceItemRender = AppearanceItemRender or BaseClass(BaseCell)
function AppearanceItemRender:__init()

end

function AppearanceItemRender:__delete()

end

function AppearanceItemRender:SetHLImg(enable)
	if self.node_list["HL"] then
		self.node_list["HL"]:SetActive(enable)
	end
end

function AppearanceItemRender:OnFlush()
	if nil == self.data then return end

	-- self.node_list["Name"].text.text = Language.Common.CheckTabName[self.data]
	-- self.node_list["Level"].text.text = self.data

	local index = self.data
	local name_str = ""
	local grade = 0
	local grade_str = ""
	local check_attr = CheckData.Instance:UpdateAttrView()
	if index == CHECK_TAB_TYPE.MOUNT then			
		local mount_attr = check_attr.mount_attr
		grade = mount_attr.client_grade
		local local_grade = mount_attr.client_grade + 1
		local mount_cfg = MountData.Instance:GetMountGradeCfg(local_grade)
		if mount_cfg == nil then return end
		local image_id = mount_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..MountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = MountData.Instance:GetMountImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.WING then			
		local wing_attr = check_attr.wing_attr
		grade = wing_attr.client_grade
		local local_grade = wing_attr.client_grade + 1
		local used_imageid = wing_attr.used_imageid
		local is_spec = false
		if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
			is_spec = true
			used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
		end
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..WingData.Instance:GetImageListInfo(used_imageid, is_spec).image_name.."</color>"
		name_str = WingData.Instance:GetImageListInfo(used_imageid, is_spec).image_name

	elseif index == CHECK_TAB_TYPE.SHIZHUANG then 		
		local fashion_attr = check_attr.fashion_attr
		grade = fashion_attr.client_grade
		local local_grade = fashion_attr.client_grade + 1
		local fashion_cfg = FashionData.Instance:GetWuQiGradeCfg(local_grade)
		if nil == fashion_cfg then return end
		local image_id = fashion_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
		if not image_id_cfg then return end
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"
		name_str = image_id_cfg.image_name

	elseif index == CHECK_TAB_TYPE.SPIRIT then 	
		local spirit_attr = check_attr.spirit_attr
		local show_spirit_id = 0
		local show_spirit_level = 0
		if spirit_attr.use_jingling_id == 0 then
			for k,v in pairs(spirit_attr.jingling_item_list) do
				if v.jingling_id ~= 0 then
					show_spirit_id = v.jingling_id
					show_spirit_level = v.jingling_level
					break
				end
			end
		else
			show_spirit_id = spirit_attr.use_jingling_id
			for k,v in pairs(spirit_attr.jingling_item_list) do
				if v.jingling_id == show_spirit_id then
					show_spirit_level = v.jingling_level
					break
				end
			end
		end
		grade = show_spirit_level
		item_cfg = ItemData.Instance:GetItemConfig(show_spirit_id)
		if item_cfg ~= nil then
			name_str = item_cfg.name
		end

	elseif index == CHECK_TAB_TYPE.SHENBING then 		
		local shenbing_attr = check_attr.shenbing_attr
		grade = shenbing_attr.client_grade
		local local_grade = shenbing_attr.client_grade + 1
		local shengbing_cfg = MountData.Instance:GetMountGradeCfg(local_grade)
		if shengbing_cfg == nil then return end
		local image_id = shengbing_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		local image_id_cfg = FashionData.Instance:GetShizhuangImg(image_id)
		if not image_id_cfg then return end
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_id_cfg.image_name.."</color>"
		name_str = image_id_cfg.image_name

	elseif index == CHECK_TAB_TYPE.FABAO then 			
		local fabao_attr = check_attr.fabao_attr
		grade = fabao_attr.client_grade
		local local_grade = fabao_attr.client_grade + 1
		local fabao_cfg = FaBaoData.Instance:GetFaBaoGradeCfg(local_grade)
		if fabao_cfg == nil then return end
		local image_id = fabao_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FaBaoData.Instance:GetFaBaoImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = FaBaoData.Instance:GetFaBaoImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.FOOT then 			
		local foot_attr = check_attr.foot_attr
		grade = foot_attr.client_grade
		local local_grade = foot_attr.client_grade + 1
		local foot_cfg = FootData.Instance:GetFootGradeCfg(local_grade)
		if nil == foot_cfg then return end
		local image_id = foot_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FootData.Instance:GetFootImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = FootData.Instance:GetFootImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.HALO then 			
		local halo_attr = check_attr.halo_attr
		grade = halo_attr.client_grade
		local local_grade = halo_attr.client_grade + 1
		local halo_cfg = HaloData.Instance:GetHaloGradeCfg(local_grade)
		if halo_cfg == nil then return end
		local image_id = halo_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..HaloData.Instance:GetHaloImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = HaloData.Instance:GetHaloImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.FIGHT_MOUNT then 	
		local fight_attr = check_attr.fight_attr
		grade = fight_attr.client_grade
		local local_grade = fight_attr.client_grade + 1
		local fightmount_cfg = FightMountData.Instance:GetMountGradeCfg(local_grade)
		if nil == fightmount_cfg then return end
		local image_id = fightmount_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..FightMountData.Instance:GetMountImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = FightMountData.Instance:GetMountImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.CLOAK then 		
		local cloak_attr = check_attr.cloak_attr
		local cloak_level_cfg = CloakData.Instance:GetCloakLevelCfg(cloak_attr.cloak_level)
		grade = cloak_attr.cloak_level
		if cloak_level_cfg == nil then return end
		local used_imageid = cloak_level_cfg.active_image
		if used_imageid > ADVANCE_IMAGE_ID_CHAZHI then
			used_imageid = used_imageid - ADVANCE_IMAGE_ID_CHAZHI
		end
		local color = math.floor((used_imageid - 1) / 2) + 1
		if cloak_attr.capability > 0 and used_imageid > 0 then
			-- name_str = "<color=".. SOUL_NAME_COLOR[color] ..">" .. CloakData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
			name_str = CloakData.Instance:GetImageListInfo(used_imageid).image_name
		end

	elseif index == CHECK_TAB_TYPE.TOUSHI then 		
		local grade_info = TouShiData.Instance:GetTouShiGradeCfgInfoByGrade(check_attr.toushi_attr.grade)
		if nil == grade_info then return end
		local image_info = TouShiData.Instance:GetTouShiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.MASK then 			
		local grade_info = MaskData.Instance:GetMaskGradeCfgInfoByGrade(check_attr.mask_attr.grade)
		if nil == grade_info then return end
		local image_info = MaskData.Instance:GetMaskImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str =image_info.image_name

	elseif index == CHECK_TAB_TYPE.YAOSHI then 		
		local grade_info = WaistData.Instance:GetWaistGradeCfgInfoByGrade(check_attr.yaoshi_attr.grade)
		if nil == grade_info then return end
		local image_info = WaistData.Instance:GetWaistImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.QILINBI then 		
		local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(check_attr.qilinbi_attr.grade)
		if nil == grade_info then return end
		local image_info = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.SHEN_GONG then 	
		grade = check_attr.shengong_attr.client_grade
		local local_grade = check_attr.shengong_attr.client_grade + 1
		local shengong_cfg = ShengongData.Instance:GetShengongGradeCfg(local_grade)
		if nil == shengong_cfg then return end
		local image_id = shengong_cfg.image_id
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg(image_id)[image_id].image_name.."</color>"
		name_str = ShengongData.Instance:GetShengongImageCfg(image_id)[image_id].image_name

	elseif index == CHECK_TAB_TYPE.SHEN_YI then
		local shenyi_attr = check_attr.shenyi_attr
		grade = shenyi_attr.client_grade
		local local_grade = shenyi_attr.client_grade + 1
		local used_imageid = shenyi_attr.used_imageid
		if used_imageid > 1000 then
			used_imageid = used_imageid - 1000
		end
		local image_id = ShenyiData.Instance:GetImageListInfo(used_imageid).image_name
		local color = (local_grade / 3 + 1) >= 5 and 5 or math.floor(local_grade / 3 + 1)
		-- name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetImageListInfo(used_imageid).image_name.."</color>"
		name_str = ShenyiData.Instance:GetImageListInfo(used_imageid).image_name

	elseif index == CHECK_TAB_TYPE.GODDESS then 		
		local xiannv_attr = check_attr.xiannv_attr
		local show_id = xiannv_attr.pos_list[1]
		if show_id == -1 then
			local active_list = GoddessData.Instance:GetXiannvActiveList(xiannv_attr.xiannv_item_list)
			if #active_list ~= 0 then
				show_id = active_list[1]
				name_str = GoddessData.Instance:GetXianNvCfg(show_id).name
				grade = xiannv_attr.xiannv_item_list[show_id].xn_zizhi
			end
		else
			name_str = GoddessData.Instance:GetXianNvCfg(show_id).name
			grade = xiannv_attr.xiannv_item_list[show_id].xn_zizhi
		end

	elseif index == CHECK_TAB_TYPE.LINGZHU then 		
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(check_attr.lingzhu_attr.grade)
		if nil == grade_info then return end
		local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.XIANBAO then 		
		local grade_info = XianBaoData.Instance:GetXianBaoGradeCfgInfoByGrade(check_attr.xianbao_attr.grade)
		if nil == grade_info then return end
		local image_info = XianBaoData.Instance:GetXianBaoImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.LINGTONG then 		
		local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(check_attr.lingtong_attr.grade)
		if nil == grade_info then return end
		local image_info = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.LINGGONG then 		
		local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(check_attr.linggong_attr.grade)
		if nil == grade_info then return end
		local image_info = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.LINGQI then		
		local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(check_attr.lingqi_attr.grade)
		if nil == grade_info then return end
		local image_info = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.WEIYAN then 		
		local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(check_attr.weiyan_attr.grade)
		if nil == grade_info then return end
		local image_info = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.SHOUHUAN then 		
		local grade_info = LingZhuData.Instance:GetLingZhuGradeCfgInfoByGrade(check_attr.shouhuan_attr.grade)
		if nil == grade_info then return end
		local image_info = LingZhuData.Instance:GetLingZhuImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.TAIL then 			
		local grade_info = TailData.Instance:GetTailGradeCfgInfoByGrade(check_attr.tail_attr.grade)
		if nil == grade_info then return end
		local image_info = TailData.Instance:GetTailImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	elseif index == CHECK_TAB_TYPE.FLYPET then 
		local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(check_attr.flypet_attr.grade)
		if nil == grade_info then return end
		local image_info = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_info then return end
		-- grade_str = grade_info.gradename
		grade_str = grade_info.grade
		-- name_str = ToColorStr(image_info.image_name, SOUL_NAME_COLOR[image_info.colour])
		name_str = image_info.image_name

	end

	self.node_list["Name"].text.text = ToColorStr(name_str, TEXT_COLOR.WHITE) 

	if index == CHECK_TAB_TYPE.CLOAK or index == CHECK_TAB_TYPE.SPIRIT or index == CHECK_TAB_TYPE.GODDESS then
		-- self.node_list["Level"].text.text = Language.Common.CheckTabName[self.data] .. "Lv." .. grade
		self.node_list["Level"].text.text = "Lv." .. grade
	else
		if grade_str == "" then
			self.node_list["Level"].text.text = grade .. Language.Common.Jie
		else
			self.node_list["Level"].text.text = (grade_str - 1) .. Language.Common.Jie
		end
	end

	local bundle, asset = ResPath.GetCheckViewImage("check_icon_" .. self.data)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
end

