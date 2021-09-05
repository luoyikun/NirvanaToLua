
TipsTodayThemeData = TipsTodayThemeData or BaseClass(BaseView)

local VIP_LEVEL = 5  -- 系统类玩家VIP达到5级显示
function TipsTodayThemeData:__init()
	if TipsTodayThemeData.Instance ~= nil then
		print_error("[TipsTodayThemeData] attempt to create singleton twice!")
		return
	end
	TipsTodayThemeData.Instance = self

	self.is_show_today_effect = true
	self.today_theme_cfg = ConfigManager.Instance:GetAutoConfig("today_theme_reward_auto").reward_seq
	self.fetch_flag = {}

	RemindManager.Instance:Register(RemindName.TodayTheme, BindTool.Bind(self.RemindTodayThemeTips, self))
	-- self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	-- PlayerData.Instance:ListenerAttrChange(self.player_data_change)
end

function TipsTodayThemeData:__delete()
	TipsTodayThemeData.Instance = nil

	if self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end

	RemindManager.Instance:UnRegister(RemindName.TodayTheme)
end

function TipsTodayThemeData:PlayerDataChangeCallback(attr_name)
	if attr_name == "level" then
		RemindManager.Instance:Fire(RemindName.TodayTheme)
	end
end

function TipsTodayThemeData:SetTodayThemeRewardFlagInfo(protocol)
	RemindManager.Instance:Fire(RemindName.TodayTheme)
	self.fetch_flag = bit:uc2b(protocol.fetch_flag)
end

function TipsTodayThemeData:GetCfgByTypeAndIndex(str_type, index_peizh)
	local type_flag = str_type == "advance" and 1 or 0
	for k, v in pairs(self.today_theme_cfg) do
		if v.is_jinjie == type_flag and v.index_peizhi == index_peizh then
			return v
		end
	end
	return nil
end

function TipsTodayThemeData:GetShowLockPaneFlag(seq)
	return self.fetch_flag[seq]
end

function TipsTodayThemeData:IsShowTodayThemeEff()
	return self.is_show_effect or self.is_show_today_effect
end

function TipsTodayThemeData:SetTodayThemeEff(is_show)
	self.is_show_today_effect = is_show
end

function TipsTodayThemeData:SetTodayThemeEffHaveReward(is_show)
	self.is_show_effect = is_show
end

-- 是否显示按钮
function TipsTodayThemeData:IsShowMainIcon()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	self:SetTodayThemeEffHaveReward(false)
	local is_show = 0
	if 14 >= open_day then
		local act_type = COMPETITION_ACTIVITY_TYPE[open_day]
		local rank_type = ACTIVITY_TYPE_TO_RANK_TYPE[act_type]
		local system_type = BIPIN_TYPE_TO_JINJIE_TYPE[rank_type]
		local reward_cfg = self:GetCfgByTypeAndIndex("advance", system_type)
		if reward_cfg and reward_cfg.seq then
			if 0 == self:GetShowLockPaneFlag(reward_cfg.seq) then
				self:SetTodayThemeEffHaveReward(true)
				return true
			end
		end
		is_show = is_show + 1
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.vip_level >= VIP_LEVEL then
		for k, v in pairs(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE) do
			if 0 ~= v and 7 ~= v and 8 ~= v then
				local goal_info = DisCountData.Instance:GetClassASmallTargetInfo(v)
				if goal_info and next(goal_info) then
					local goal_type
					local goal_cfg_info
					if 0 == goal_info.fetch_flag[0] then
						goal_type = 0
						goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, v)
					elseif 0 == goal_info.fetch_flag[1] then
						goal_type = 1
						goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, v)
					end
					if goal_type and goal_cfg_info then
						local sever_time = TimeCtrl.Instance:GetServerTime()
						local diff_time = goal_info.open_system_timestamp - sever_time
						diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
						if diff_time > 0 then
							local reward_cfg = self:GetCfgByTypeAndIndex("system", v)
							if 0 == self:GetShowLockPaneFlag(reward_cfg.seq) then
								self:SetTodayThemeEffHaveReward(true)
								return true
							end
							is_show = is_show + 1
						end
					end		
				end
			end
		end
	end

	if is_show > 0 then
		return true
	else
		return false
	end
end

function TipsTodayThemeData:RemindTodayThemeTips()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level >= 85 and self:IsShowMainIcon() then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.TodayTheme, true)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.TodayTheme, false)
	end
end

function TipsTodayThemeData:GetShowSystemTargetList()
	local open_system_count = 0
	local open_system_type_tab = {}

	--进阶类大小目标
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if 14 >= open_day then
		local act_type = COMPETITION_ACTIVITY_TYPE[open_day]
		local rank_type = ACTIVITY_TYPE_TO_RANK_TYPE[act_type]
		local system_type = BIPIN_TYPE_TO_JINJIE_TYPE[rank_type]
		open_system_count = open_system_count + 1
		open_system_type_tab[open_system_count] = {}
		open_system_type_tab[open_system_count].system_big_type = "advance"
		open_system_type_tab[open_system_count].act_type = act_type
		open_system_type_tab[open_system_count].system_type = system_type
	end

	-- 系统类大小目标
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.vip_level >= VIP_LEVEL then
		for k, v in pairs(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE) do
			if 0 ~= v and 7 ~= v and 8 ~= v then
				local goal_info = DisCountData.Instance:GetClassASmallTargetInfo(v)
				if goal_info and next(goal_info) then
					local goal_type
					local goal_cfg_info
					if 0 == goal_info.fetch_flag[0] then
						goal_type = 0
						goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, v)
					elseif 0 == goal_info.fetch_flag[1] then
						goal_type = 1
						goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, v)
					end

					if goal_type and goal_cfg_info then
						local sever_time = TimeCtrl.Instance:GetServerTime()
						local diff_time = goal_info.open_system_timestamp - sever_time
						diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
						if diff_time > 0 then
							open_system_count = open_system_count + 1
							open_system_type_tab[open_system_count] = {}
							open_system_type_tab[open_system_count].system_big_type = "system"
							open_system_type_tab[open_system_count].system_type = v
							open_system_type_tab[open_system_count].goal_type = goal_type
							open_system_type_tab[open_system_count].open_system_time = goal_info.open_system_timestamp
							open_system_type_tab[open_system_count].goal_cfg_info = goal_cfg_info
						end
					end
				end
			end
		end
	end

	return open_system_type_tab
end

-- 获取要展示的模型（进阶类）
function TipsTodayThemeData:GetShowAdvanceSystemModel(system_type)
	local show_tab = {
		[0] = 3,			[1] = 3,		[2] = 3,		
		[3] = 4,			[4] = 5,		[5] = "small_target",		
		[6] = 7,			[7] = 8,		[8] = "bipin",		
		[9] = "big_target",	[10] = 11,		[11] = 12,		
		[12] = 13,			[13] = 14,		[14] = 14,		
	}

	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local act_type = COMPETITION_ACTIVITY_TYPE[open_day]
	local type_cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(act_type)
	local reward_item_id = type_cfg[#type_cfg].reward_item[0].item_id

	local view_show_type, show_model_cfg, cur_model_grade, grade_cfg
	if system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then
		-- 坐骑
		local mount_info = MountData.Instance:GetMountInfo()
		if mount_info == nil or mount_info.grade == nil then return end
		local cur_img_grade =  mount_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = MountData.Instance:GetMountGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (MountData.Instance:GetMountImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WING then
		-- 羽翼
		local wing_info = WingData.Instance:GetWingInfo()
		if wing_info == nil or wing_info.grade == nil then
			return
		end
		local cur_img_grade = wing_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = WingData.Instance:GetWingGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (WingData.Instance:GetWingImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end	

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then
		-- 战骑
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		if mount_info == nil or mount_info.grade == nil then
			return
		end
		local cur_img_grade = mount_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = FightMountData.Instance:GetMountGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (FightMountData.Instance:GetMountImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end			

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGCHONG then
		local lingchong_info = LingChongData.Instance:GetLingChongInfo()
		if lingchong_info == nil or lingchong_info.grade == nil then
			return
		end
		
		local cur_img_grade = lingchong_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(LingChongData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(grade_info.image_id)			
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end			

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FABAO then
		local fabao_info = FaBaoData.Instance:GetFaBaoInfo()
		if fabao_info == nil or fabao_info.grade == nil then
			return
		end
		local cur_img_grade = fabao_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = FaBaoData.Instance:GetFaBaoGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (FaBaoData.Instance:GetFaBaoImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FLYPET then
		local flypet_info = FlyPetData.Instance:GetFlyPetInfo()
		if flypet_info == nil or flypet_info.grade == nil then
			return
		end
		local cur_img_grade = flypet_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(FlyPetData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = FlyPetData.Instance:GetFlyPetGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = FlyPetData.Instance:GetFlyPetImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then
		local halo_info = HaloData.Instance:GetHaloInfo()
		if halo_info == nil or halo_info.grade == nil then
			return
		end
		local cur_img_grade = halo_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = HaloData.Instance:GetHaloGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = HaloData.Instance:GetSingleHaloImageCfg(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGQI then
		local lingqi_info = LingQiData.Instance:GetLingQiInfo()
		if lingqi_info == nil or lingqi_info.grade == nil then
			return
		end	
		local cur_img_grade = lingqi_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(LingQiData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = LingQiData.Instance:GetLingQiGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = LingQiData.Instance:GetLingQiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_WEIYAN then
		local weiyan_info = WeiYanData.Instance:GetWeiYanInfo()
		if weiyan_info == nil or weiyan_info.grade == nil then
			return
		end
		local cur_img_grade = weiyan_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(WeiYanData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = WeiYanData.Instance:GetWeiYanGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = WeiYanData.Instance:GetWeiYanImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_QILINBI then
		local qilinbi_info = QilinBiData.Instance:GetQilinBiInfo()
		if qilinbi_info == nil or qilinbi_info.grade == nil then
			return
		end
		local cur_img_grade = qilinbi_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(QilinBiData.Instance:GetSpecialImage()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = QilinBiData.Instance:GetQilinBiGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = QilinBiData.Instance:GetQilinBiImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then
		local shengong_info = ShengongData.Instance:GetShengongInfo()
		if shengong_info == nil or shengong_info.grade == nil then
			return
		end
		local cur_img_grade = shengong_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = ShengongData.Instance:GetShengongGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (ShengongData.Instance:GetShengongImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then
		local foot_info = FootData.Instance:GetFootInfo()
		if foot_info == nil or foot_info.grade == nil then
			return
		end
		local cur_img_grade = foot_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = FootData.Instance:GetFootGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (FootData.Instance:GetFootImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_LINGGONG then
		local linggong_info = LingGongData.Instance:GetLingGongInfo()
		if linggong_info == nil or linggong_info.grade == nil then
			return
		end
		local cur_img_grade = linggong_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(LingGongData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = LingGongData.Instance:GetLingGongGradeCfgInfoByGrade(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = LingGongData.Instance:GetLingGongImageCfgInfoByImageId(grade_info.image_id)
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end

	elseif system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then
		local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
		if shenyi_info == nil or shenyi_info.grade == nil then
			return
		end
		local cur_img_grade = shenyi_info.grade - 1
		cur_model_grade = (cur_img_grade < 0) and 0 or cur_img_grade
		local show_type = show_tab[cur_model_grade]
		view_show_type = show_type

		if show_type == "small_target" then
			view_show_type = "small_target"
		elseif show_type == "bipin" then
			for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == reward_item_id then
					show_model_cfg = v
					break
				end
			end
		elseif show_type == "big_target" then
			view_show_type = "big_target"
		else
			local grade_info = ShenyiData.Instance:GetShenyiGradeCfg(show_type + 1)
			if nil == grade_info then return end
			grade_cfg = grade_info
			local image_cfg = (ShenyiData.Instance:GetShenyiImageCfg() or {})[grade_info.image_id]
			if nil == image_cfg then return end
			show_model_cfg = image_cfg
		end
	end

	if view_show_type == "small_target" then
		show_model_cfg = JinJieRewardData.Instance:GetSmallTargetShowData(system_type)
	elseif view_show_type == "big_target" then
		local system_cfg = JinJieRewardData.Instance:GetSingleRewardCfg(system_type)
		local img_id = system_cfg and system_cfg.param_0 
		if img_id then
			show_model_cfg = JinJieRewardData.Instance:GetSystemSpecialImageCfg(system_type, img_id)
		end
		grade_cfg = system_cfg
	end

	return view_show_type, cur_model_grade, show_model_cfg, grade_cfg
end

-- 通过系统类型计算大小目标战力,大小目标那两种战力计算方式，这里直接复制
function TipsTodayThemeData:GetBigGoalAttrData(system_type)
	local attr_list = RuneData.Instance:GetGoalCfg(system_type)
	if attr_list == nil then
		return
	end

	local percent_cap = 0
	if system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE then
		--战魂
		local attr = RuneData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON then
		--异火
		local attr = HunQiData.Instance:GetAllAttrInfo()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)		
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGE then
		--星辉
		local attr = ShenGeData.Instance:GetShenGeAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)		
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENYIN then
		--铭纹
		local attr = ShenYinData.Instance:GetAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC then
		--生肖
		local attr = ShengXiaoData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	else
		return nil
	end

	local cap = CommonDataManager.GetCapabilityCalculation(attr_list) + math.floor(percent_cap * attr_list.add_per / 10000)
	return (cap == 0 and nil or cap)
end

-- 通过系统类型计算大小目标战力,大小目标那两种战力计算方式，这里直接复制
function TipsTodayThemeData:GetBigGoalAttrDataTwo(system_type, item_id)
	local type_cfg = {}
	local percent_cap = 0
	if system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANNV then
		local huanhua_id, _ = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(item_id)
		type_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(huanhua_id)
		local attr = GoddessData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG then
		local SpecialSpiritImageCfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(item_id)
		local huanhua_id = SpecialSpiritImageCfg.active_image_id
		type_cfg = SpiritData.Instance:GetSpecialImageCfgByID(huanhua_id, 1)
		local attr = SpiritData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENSHOU then
		type_cfg = RuneData.Instance:GetGoalCfg(system_type)
		percent_cap = ShenShouData.Instance:GetShenShouEquipAllAttr()
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENGQI then
		type_cfg = ShenShouData.Instance:GetGoalCfg(system_type)
		local attr = ShenShouData:GetShenShouShenQiAllAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	elseif system_type == ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_GREATESOLDIER then
		type_cfg = BianShenData.Instance:GetGoalCfg(system_type)
		local attr = BianShenData.Instance:GetAllBaseAttr()
		percent_cap = CommonDataManager.GetCapabilityCalculation(attr)
	end

	local attr_list = RuneData.Instance:GetGoalCfg(system_type)
	local cap = CommonDataManager.GetCapabilityCalculation(type_cfg) +  math.floor(percent_cap * attr_list.add_per / 10000)
	return (cap == 0 and nil or cap)
end


