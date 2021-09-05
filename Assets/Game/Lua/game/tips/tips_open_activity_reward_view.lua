TipsShowRewardView = TipsShowRewardView or BaseClass(BaseView)

function TipsShowRewardView:__init()
	self.ui_config = {{"uis/views/tips/openactivityrewardtips_prefab", "OpenActivityRewardTips"}}
	self.play_audio = true
	self.is_modal = true
	self.view_layer = UiLayer.Pop
	self.is_async_load = true
end

function TipsShowRewardView:LoadCallBack()
	self.model_display = self.node_list["model_display"]
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.model_display.ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.node_list["BtnReward"].button:AddClickListener(BindTool.Bind(self.RewardOnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"])
end

function TipsShowRewardView:ReleaseCallBack()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.cal_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	self.fight_text = nil
	self.model_display = nil
end

function TipsShowRewardView:OpenCallBack()
	self:Flush()
end

function TipsShowRewardView:CloseCallBack()
	if self.cal_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipsShowRewardView:OnFlush()
	self:SetModle()
	-- self:CalTime()
end

function TipsShowRewardView:SetModle()
	if self.model_view == nil then
		return
	end
	local wuqi_res_id = 0
	local fashion_res_id = 0
	local mount_res_id = 0
	local wing_res_id = 0
	local title_id = 0
	local zhanli = 0
	local reward_id = 0
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local reward_info = ActivityData.Instance:GetSetActivityRewardInfo()
	if nil == reward_info or next(reward_info) == nil then return end

	local display_type = 0

	if reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WEAPON] then
		wuqi_res_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WEAPON].reward_id
		local cfg = FashionData.Instance:GetWuQiSpecialImageCfg(wuqi_res_id)
		local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
		zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(attr)
		reward_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WEAPON].reward_id
	end

	if reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_SHIZHUANG] then
		fashion_res_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_SHIZHUANG].reward_id
		local cfg = FashionData.Instance:GetShizhuangSpecialImgByIndex(fashion_res_id)
		local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
		zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(attr)
		reward_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_SHIZHUANG].reward_id
	end

	if reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WING] then
		local image_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WING].reward_id
		wing_res_id = WingData.Instance:GetWingResIdByImageId(image_id + 1000)
		local grade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(image_id, 1, false)
		local attr = CommonDataManager.GetAttributteNoUnderline(grade_cfg)
		zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(attr)
		reward_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_WING].reward_id
	end

	if reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_MOUNT] then
		local image_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_MOUNT].reward_id
		mount_res_id = MountData.Instance:GetMountResIdByImageId(image_id + 1000)
		local grade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(image_id, 1, false)
		local attr = CommonDataManager.GetAttributteNoUnderline(grade_cfg)
		zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(attr)
	end

	if reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_TITLE] and (reward_info.activity_id ~= ACTIVITY_TYPE.GUILDBATTLE or mount_res_id == 0) then
		title_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_TITLE].reward_id
		reward_id = reward_info[ACTIVITY_REWARD_TYPE.REWARD_TYPE_TITLE].reward_id
		local cfg = TitleData.Instance:GetTitleCfg(title_id)
		local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
		zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(attr)
	end

	self.model_view:ClearModel()
	self.model_view:SetScale(Vector3(0.9, 0.9, 0.9))
	self.model_view:SetRotation(Vector3(0, 0, 0))
	
	local is_show_model = fashion_res_id ~= 0 or wuqi_res_id ~= 0 or mount_res_id ~= 0 or wing_res_id ~= 0
	self.node_list["Content"].transform.localPosition = is_show_model and Vector3(0, 0, 0) or Vector3(0, 100, 0)
	self.node_list["TitlePanle"].transform.localPosition = is_show_model and Vector3(0, 340, 0) or Vector3(0, 0, 0)
	self.node_list["ImgTitle"]:SetActive(title_id ~= 0)
	self.node_list["ModelPanle"]:SetActive(is_show_model)
	self.node_list["Txt_tip"]:SetActive(false)
	self.node_list["Txt_tip2"]:SetActive(false)
	local str = ""
	if reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CROSS_ADD_CAP or reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CROSS_ADD_CHARM
		or reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CROSS_QINGYUAN_CAP or reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CROSS_GUILD_KILL_BOSSP then
		if reward_info.activity_id and Language.Tips.ActivityRewardDec[reward_info.activity_id] and Language.Tips.ActivityRewardDec[reward_info.activity_id][reward_id] then
			str = Language.Tips.ActivityRewardDec[reward_info.activity_id][reward_id]
		end
	elseif reward_info.activity_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_CHALLENGEFIELD or reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CHALLENGEFIELD then
		if reward_info.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CHALLENGEFIELD then
			self.node_list["Txt_tip"]:SetActive(true)
			self.node_list["Txt_tip"].text.text = ToColorStr(Language.KFArena.TipRewardDesc2, TEXT_COLOR.GREEN)
		end
		if reward_info.activity_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_CHALLENGEFIELD then
			self.node_list["Txt_tip2"]:SetActive(true)
			self.node_list["Txt_tip2"].text.text = ToColorStr(Language.KFArena.TipRewardDesc, TEXT_COLOR.GREEN)
		end
		local param = reward_info.param <= 3 and 0 or 1
		local flag = reward_info.param
		if reward_info.param <= 3 then
			flag = Language.KFArena.RankNum[reward_info.param]
		elseif reward_info.param > 3 and reward_info.param <= 10 then
			flag = Language.KFArena.RankNum[4]
		elseif reward_info.param > 10 and reward_info.param <= 20 then
			flag = Language.KFArena.RankNum[5]
		elseif reward_info.param > 20 and reward_info.param <= 50 then
			flag = Language.KFArena.RankNum[6]
		elseif reward_info.param > 50 and reward_info.param <= 100 then
			flag = Language.KFArena.RankNum[7]
		end
		if reward_info.activity_id and reward_info.param and Language.Tips.ActivityRewardDec[reward_info.activity_id] and Language.Tips.ActivityRewardDec[reward_info.activity_id][param] then
			str = string.format(Language.Tips.ActivityRewardDec[reward_info.activity_id][param], flag)
		end
	else
		if reward_info.activity_id and Language.Tips.ActivityRewardDec[reward_info.activity_id] and Language.Tips.ActivityRewardDec[reward_info.activity_id][title_id] then
			if reward_info.activity_id == ACTIVITY_TYPE.KF_GUILDBATTLE and role_id == GuildDataConst.GUILDVO.tuanzhang_uid then
				-- 要是盟主特殊处理
				str = Language.Tips.ActivityRewardDec[reward_info.activity_id][title_id + 10000]
			else
				str = Language.Tips.ActivityRewardDec[reward_info.activity_id][title_id]
			end
		end
	end
	
	self.node_list["TxtGetWay"].text.text = str
	self.fight_text.text.text = zhanli

	local role_info = PlayerData.Instance:GetRoleVo()
	if fashion_res_id ~= 0 or wuqi_res_id ~= 0 then
		local info = TableCopy(role_info)
		info.appearance = {}
		-- info.is_normal_fashion = false
		if fashion_res_id ~= 0 then
			info.appearance.fashion_body_is_special = true
			info.appearance.fashion_body = fashion_res_id
		end

		if wuqi_res_id ~= 0 then
			info.appearance.fashion_wuqi = wuqi_res_id
		end
		self.model_view:SetModelResInfo(info, false, false, true, false)
		self.model_view:SetBool(ANIMATOR_PARAM.FIGHT, wuqi_res_id ~= 0)
	end

	if mount_res_id ~= 0 then
		local mount_bundle, mount_asset = ResPath.GetMountModel(mount_res_id)
		self.model_view:SetMainAsset(mount_bundle, mount_asset)
		self.model_view:SetRotation(Vector3(0, -45, 0))
	end

	if wing_res_id ~= 0 then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetWingResid(wing_res_id)
		self.model_view:SetTrigger(ANIMATOR_PARAM.STATUS)
		if prof == GameEnum.ROLE_PROF_1 then      --男剑
			self.model_view:SetRotation(Vector3(0, 158, 0))
		elseif prof == GameEnum.ROLE_PROF_2 then  --男琴
			self.model_view:SetRotation(Vector3(0, -155, 0))
		elseif prof == GameEnum.ROLE_PROF_3 then  --女剑
			 self.model_view:SetRotation(Vector3(0, 169, 0))
		elseif prof == GameEnum.ROLE_PROF_4 then  -- 小萝莉
			self.model_view:SetRotation(Vector3(0, -170, 0))
		else
			self.model_view:SetRotation(Vector3(0, -170, 0))
		end
	end

	if title_id ~= 0 then
		local bundle, asset = ResPath.GetTitleIcon(title_id)
		self.node_list["ImgTitle"].image:LoadSprite(bundle, asset)
		self:LoadTitleEff(self.node_list["ImgTitle"], title_id, true)
	end
end

function TipsShowRewardView:LoadTitleEff(parent, title_id, is_active, call_back)
	local title_cfg = TitleData.Instance:GetTitleCfg(title_id)
	if title_cfg and title_cfg.is_zhengui then
		self.title_effect_loader = self.title_effect_loader or {}
		if self.title_effect_loader[parent] then
			self.title_effect_loader[parent]:SetActive(is_active)
			return
		end

		local asset_bundle, asset_name = ResPath.GetTitleEffect("UI_title_eff_" .. title_cfg.is_zhengui)
		local async_loader = self.title_effect_loader[parent] or AllocAsyncLoader(self, "title_effect_loader")
		async_loader:Load(asset_bundle, asset_name, function(obj)
			obj.transform:SetParent(parent.transform, false)
			obj:SetActive(is_active)
		end)
		self.title_effect_loader[parent] = async_loader
	end
end

function TipsShowRewardView:RewardOnClick()
	self:Close()
	if self.cal_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipsShowRewardView:CalTime()
	local timer_cal = 10
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal >= 0 then
			local str = string.format(Language.TipsOpenFunction.Time, math.floor(timer_cal))
			self.node_list["TxtRemainTime"].text.text = str
		end
		if timer_cal < 0 then
			self:RewardOnClick()
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
			self.cal_time_quest = nil
		end
	end, 0)
end