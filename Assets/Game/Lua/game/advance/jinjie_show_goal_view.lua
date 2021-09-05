JinJieShowGoalView = JinJieShowGoalView or BaseClass(BaseView)

function JinJieShowGoalView:__init()
	self.ui_config = {{"uis/views/tips/jinjieshowgoal_prefab", "JinJieShowGoal"}}
	self.is_modal = true
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function JinJieShowGoalView:ReleaseCallBack()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end
end

function JinJieShowGoalView:LoadCallBack()
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ButtonTip, self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
end

function JinJieShowGoalView:CloseCallBack()
	self.system_type = nil
	self.show_type = nil
end

function JinJieShowGoalView:ButtonTip()
	if self.show_type and 1 <= self.show_type and self.show_type <= 2 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 3 or 2
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	elseif 3 <= self.show_type and self.show_type <= 4 then
		local index = DailyChargeData.Instance:GetIsOpenActiveReward() and 5 or 4
		ViewManager.Instance:Open(ViewName.LeiJiDailyView, nil, "list_index", {["list_index"] = index})
	else
		self:Close()
	end
end

function JinJieShowGoalView:OpenCallBack()
	self:Flush()
end

--设置打开面板类型
function JinJieShowGoalView:SetData(system_type, show_type)
	if not system_type or not show_type then
		return
	end

	self.system_type = system_type
	self.show_type = show_type
	self:Open()
end

function JinJieShowGoalView:OnFlush()
	self:FlushModle()
end

--模型
function JinJieShowGoalView:FlushModle()
	if nil == self.model then
		return
	end
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	self.model:ClearModel()
	self.model:ResetRotation()

	if self.show_type == 1 or self.show_type == 2 then
		self.select_grade = 5
	elseif self.show_type == 3 or self.show_type == 4 then
		self.select_grade = 8
	end

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local act_type = COMPETITION_ACTIVITY_TYPE[open_day]
	local type_cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(act_type)
	local role_item_id = type_cfg[#type_cfg].reward_item[0].item_id

	if JINJIE_TYPE.JINJIE_TYPE_MOUNT == self.system_type then
		-- 坐骑
		self:SetMountModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_WING == self.system_type then
		-- 羽翼
		self:SetWingModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT == self.system_type then
		-- 战斗坐骑
		self:SetFightMountModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGCHONG == self.system_type then
		-- 灵童
		self:SetLingTongModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_FABAO == self.system_type then
		-- 法宝
		self:SetFabaoModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_FLYPET == self.system_type then
		-- 飞宠
		self:SetFlypetModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_HALO == self.system_type then
		-- 光环
		self:SetHaloModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGQI == self.system_type then
		-- 灵骑
		self:SetLingqiModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_WEIYAN == self.system_type then
		-- 尾焰
		self:SetWeiyanModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_QILINBI == self.system_type then
		-- 麒麟臂
		self:SetQilinbiModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_SHENGONG == self.system_type then
		-- 仙环
		self:SetShenGongModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT == self.system_type then
		-- 足迹
		self:SetFootModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_LINGGONG == self.system_type then
		-- 灵弓
		self:SetLinggongModel(role_item_id)
	elseif JINJIE_TYPE.JINJIE_TYPE_SHENYI == self.system_type then
		-- 仙阵
		self:SetShenyiModel(role_item_id)
	end

	if self.show_type == 1 or self.show_type == 2 then
		self.node_list["TextGroup1"]:SetActive(true)
		self.node_list["TextGroup2"]:SetActive(false)
		self.node_list["TextGroup3"]:SetActive(false)
		self.node_list["ButtonText"].text.text = Language.Advance.GetUpLevelItem
	elseif self.show_type == 3 or self.show_type == 4 then
		self.node_list["TextGroup2"]:SetActive(true)
		self.node_list["TextGroup1"]:SetActive(false)
		self.node_list["TextGroup3"]:SetActive(false)
		self.node_list["ButtonText"].text.text = Language.Advance.GetUpLevelItem
	elseif self.show_type == 5 then
		self.node_list["TextGroup3"]:SetActive(true)
		self.node_list["TextGroup1"]:SetActive(false)
		self.node_list["TextGroup2"]:SetActive(false)
		self.node_list["ButtonText"].text.text = Language.Advance.GetUpLevelItem2
	end
end

function JinJieShowGoalView:SetMountModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = MountData.Instance:GetMountGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (MountData.Instance:GetMountImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetMountModel(res_id)
	self.model:SetRotation(Vector3(0, -60, 0))
	self.model:SetMainAsset(bundle, asset)
	if self.show_type == 1 or self.show_type == 2 then
		self.model:SetCameraSetting({position = Vector3(-0.76, 1.9, 8), rotation = Quaternion.Euler(0, 180, 0)})
	else
		self.model:SetCameraSetting({position = Vector3(-0.4, 1.9, 8), rotation = Quaternion.Euler(0, 180, 0)})
	end
end

function JinJieShowGoalView:SetWingModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = WingData.Instance:GetWingGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (WingData.Instance:GetWingImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetWingResid(res_id)
	if prof == GameEnum.ROLE_PROF_3 or prof == GameEnum.ROLE_PROF_2 then
		self.model:SetRotation(Vector3(0, -160, 0))
	elseif prof == GameEnum.ROLE_PROF_1 then
		self.model:SetRotation(Vector3(0, 170, 0))
	else
		self.model:SetRotation(Vector3(0, -170, 0))
	end
end

function JinJieShowGoalView:SetFightMountModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = FightMountData.Instance:GetMountGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (FightMountData.Instance:GetMountImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetFightMountModel(res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -35, 0))
end

function JinJieShowGoalView:SetLingTongModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(LingChongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id_h
				break
			end
		end
	elseif self.select_grade then
		local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id_h
	end
	if not res_id then return end

	local bundle1, asset1 = ResPath.GetLingChongModel(res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle1, asset1)
	self.model:SetTrigger(LINGCHONG_ANIMATOR_PARAM.REST)
end

function JinJieShowGoalView:SetFabaoModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = FaBaoData.Instance:GetFaBaoGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (FaBaoData.Instance:GetFaBaoImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetFaBaoModel(res_id)
	self.model:SetMainAsset(bundle, asset)
end

function JinJieShowGoalView:SetFlypetModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(FlyPetData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetFlyPetModel(res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -35, 0))
end

function JinJieShowGoalView:SetHaloModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = HaloData.Instance:GetHaloGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = HaloData.Instance:GetSingleHaloImageCfg(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetHaloResid(res_id)
end

function JinJieShowGoalView:SetLingqiModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(LingQiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetLingQiModel(res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
	self.model:SetRotation(Vector3(0, -45, 0))
end

function JinJieShowGoalView:SetWeiyanModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(WeiYanData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	self:SetWeiYanIDModel(res_id)
	self.model:SetRotation(Vector3(0, 150, 0))
end

function JinJieShowGoalView:SetQilinbiModel(item_id)
	local res_id, res_id1
	if self.show_type == 5 then
		for k, v in pairs(QilinBiData.Instance:GetSpecialImage()) do
			if v.item_id == item_id then
				res_id = v.res_id0_h
				res_id1 = v.res_id1_h
				break
			end
		end
	elseif self.select_grade then
		local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id0_h
		res_id1 = image_cfg.res_id1_h
	end
	if not res_id or not res_id1 then return end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local qilinbi_res_id = main_vo.sex == 0 and res_id or res_id1
	local bundle, asset = ResPath.GetQilinBiModel(qilinbi_res_id, main_vo.sex)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
end

function JinJieShowGoalView:SetShenGongModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = ShengongData.Instance:GetShengongGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (ShengongData.Instance:GetShengongImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.halo_res_id = res_id
	self.model:SetGoddessModelResInfo(info)
end

function JinJieShowGoalView:SetFootModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = FootData.Instance:GetFootGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (FootData.Instance:GetFootImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()
	self.model:SetRoleResid(role_res_id)
	self.model:SetFootResid(res_id)
	self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	self.model:SetRotation(Vector3(0, -90, 0))
end

function JinJieShowGoalView:SetLinggongModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(LingGongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id_h
				break
			end
		end
	elseif self.select_grade then
		local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
		if nil == image_cfg then return end
		res_id = image_cfg.res_id_h
	end
	if not res_id then return end

	local bundle, asset = ResPath.GetLingGongModel(res_id)
	self.model:ResetRotation()
	self.model:SetMainAsset(bundle, asset)
end

function JinJieShowGoalView:SetShenyiModel(item_id)
	local res_id
	if self.show_type == 5 then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
	elseif self.select_grade then
		local grade_info = ShenyiData.Instance:GetShenyiGradeCfg(self.select_grade + 1)
		if nil == grade_info then return end
		local image_cfg = (ShenyiData.Instance:GetShenyiImageCfg() or {})[grade_info.image_id]
		if nil == image_cfg then return end
		res_id = image_cfg.res_id
	end
	if not res_id then return end

	local info = {}
	info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
	info.fazhen_res_id = res_id
	self.model:SetGoddessModelResInfo(info, true)
end

function JinJieShowGoalView:SetWeiYanIDModel(res_id)
	if nil == res_id then
		return
	end

	local mulit_mount_res_id = MultiMountData.Instance:GetCurMulitMountResId()
	local use_res_id = 0
	if mulit_mount_res_id > 0 then
		use_res_id = mulit_mount_res_id
	else
		local mount_image_id = MountData.Instance:GetUsedImageId()
		local mount_res_id = MountData.Instance:GetMountResIdByImageId(mount_image_id)
		use_res_id = mount_res_id
	end
	
	if use_res_id <= 0 then
		return
	end

	local bundle, asset = ResPath.GetMountModel(use_res_id)
	self.model:SetMainAsset(bundle, asset, function()
		self.model:SetWeiYanResid(res_id, use_res_id, false)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	end)
end
