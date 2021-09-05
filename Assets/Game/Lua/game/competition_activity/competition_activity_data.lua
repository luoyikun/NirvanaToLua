CompetitionActivityData = CompetitionActivityData or BaseClass()

COMPETITION_ACTIVITY_TYPE = {
	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	[1] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK,				-- 坐骑进阶榜(开服活动)
	[2] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK,				-- 羽翼进阶榜(开服活动)
	[3] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK,					-- 战骑战力榜(开服活动)
	[4] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGTONG_RANK,			-- 灵童进阶榜(开服活动)
	[5] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK,				-- 法宝进阶榜(开服活动)
	[6] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FLYPET_RANK,				-- 飞宠进阶榜(开服活动)
	[7] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK,				-- 光环进阶榜(开服活动)
	[8] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGQI_RANK,				-- 灵骑进阶榜(开服活动)
	[9] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WEIYAN_RANK,				-- 尾焰进阶榜(开服活动)
	[10] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_QILINBI_RANK,			-- 麒麟臂进阶榜(开服活动)
	[11] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK,			-- 神弓仙环进阶榜(开服活动)
	[12] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK,				-- 足迹进阶榜(开服活动)
	[13] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGGONG_RANK,			-- 灵弓进阶榜(开服活动)
	[14] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK,				-- 神翼仙阵进阶榜(开服活动)
	-- [15] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK,			-- 时装进阶榜(开服活动)
	-- [16] = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK,				-- 神兵进阶榜(开服活动)			
}

COMPETITION_ACTIVITY_DAY_TO_TABINDEX = {
	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	[1] = TabIndex.mount_jinjie,				-- 坐骑进阶榜(开服活动)
	[2] = TabIndex.wing_jinjie,					-- 羽翼进阶榜(开服活动)
	[3] = TabIndex.fight_mount,					-- 战骑战力榜(开服活动)
	[4] = TabIndex.appearance_lingtong,			-- 灵童进阶榜(开服活动)
	[5] = TabIndex.fabao_jinjie,				-- 法宝进阶榜(开服活动)
	[6] = TabIndex.appearance_flypet,			-- 飞宠进阶榜(开服活动)
	[7] = TabIndex.halo_jinjie,					-- 光环进阶榜(开服活动)
	[8] = TabIndex.appearance_lingqi,			-- 灵骑进阶榜(开服活动)
	[9] = TabIndex.appearance_weiyan,			-- 尾焰进阶榜(开服活动)
	[10] = TabIndex.appearance_qilinbi,			-- 麒麟臂进阶榜(开服活动)
	[11] = TabIndex.goddess_shengong,			-- 神弓仙环进阶榜(开服活动)
	[12] = TabIndex.foot_jinjie,				-- 足迹进阶榜(开服活动)
	[13] = TabIndex.appearance_linggong,		-- 灵弓进阶榜(开服活动)
	[14] = TabIndex.goddess_shenyi,				-- 神翼仙阵进阶榜(开服活动)
	-- [15] = TabIndex.fashion_jinjie,				-- 时装进阶榜(开服活动)
	-- [16] = TabIndex.role_shenbing,				-- 神兵进阶榜(开服活动)			
}

ACTIVITY_TYPE_TO_RANK_TYPE = {
	-- 开服比拼活动(目前只开14个，后面两个暂时不用)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_MOUNT_RANK] = RANK_TAB_TYPE.MOUNT,			-- 坐骑进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WING_RANK] = RANK_TAB_TYPE.WING,				-- 羽翼进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHT_MOUNT_RANK] = RANK_TAB_TYPE.FIGHT_MOUNT,		-- 战骑战力榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGTONG_RANK] = RANK_TAB_TYPE.LINGTONG,		-- 灵童进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FABAO_RANK] = RANK_TAB_TYPE.FABAO,			-- 法宝进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FLYPET_RANK] = RANK_TAB_TYPE.FLYPET,			-- 飞宠进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_HALO_RANK] = RANK_TAB_TYPE.HALO,				-- 光环进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGQI_RANK] = RANK_TAB_TYPE.LINGQI,			-- 灵骑进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WEIYAN_RANK] = RANK_TAB_TYPE.WEIYAN,			-- 尾焰进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_QILINBI_RANK] = RANK_TAB_TYPE.QILINBI,		-- 麒麟臂进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENGONG_RANK] = RANK_TAB_TYPE.SHENGONG,		-- 神弓仙环进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FOOT_RANK] = RANK_TAB_TYPE.FOOT,				-- 足迹进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_LINGGONG_RANK] = RANK_TAB_TYPE.LINGGONG,		-- 灵弓进阶榜(开服活动)
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_SHENYI_RANK] = RANK_TAB_TYPE.SHENYI,			-- 神翼仙阵进阶榜(开服活动)
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_FASHION_RANK] = RANK_TAB_TYPE.FASHION,		-- 时装进阶榜(开服活动)
	-- [ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_WUQI_RANK] = RANK_TAB_TYPE.SHENBING,			-- 神兵进阶榜(开服活动)
}

BIPIN_TYPE_TO_JINJIE_TYPE = {
	[RANK_TAB_TYPE.MOUNT] = JINJIE_TYPE.JINJIE_TYPE_MOUNT,	
	[RANK_TAB_TYPE.WING] = JINJIE_TYPE.JINJIE_TYPE_WING,		
	[RANK_TAB_TYPE.FIGHT_MOUNT] = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT,
	[RANK_TAB_TYPE.LINGTONG] = JINJIE_TYPE.JINJIE_TYPE_LINGCHONG,	
	[RANK_TAB_TYPE.FABAO] = JINJIE_TYPE.JINJIE_TYPE_FABAO,	
	[RANK_TAB_TYPE.FLYPET] = JINJIE_TYPE.JINJIE_TYPE_FLYPET,	
	[RANK_TAB_TYPE.HALO] = JINJIE_TYPE.JINJIE_TYPE_HALO,		
	[RANK_TAB_TYPE.LINGQI] = JINJIE_TYPE.JINJIE_TYPE_LINGQI,	
	[RANK_TAB_TYPE.WEIYAN] = JINJIE_TYPE.JINJIE_TYPE_WEIYAN,	
	[RANK_TAB_TYPE.QILINBI] = JINJIE_TYPE.JINJIE_TYPE_QILINBI,	
	[RANK_TAB_TYPE.SHENGONG] = JINJIE_TYPE.JINJIE_TYPE_SHENGONG,	
	[RANK_TAB_TYPE.FOOT] = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT,		
	[RANK_TAB_TYPE.LINGGONG] = JINJIE_TYPE.JINJIE_TYPE_LINGGONG,	
	[RANK_TAB_TYPE.SHENYI] = JINJIE_TYPE.JINJIE_TYPE_SHENYI,
}


function CompetitionActivityData:__init()
	if CompetitionActivityData.Instance then
		print_error("[CompetitionActivityData] Attempt to create singleton twice!")
		return
	end
	CompetitionActivityData.Instance = self
	RemindManager.Instance:Register(RemindName.BiPin, BindTool.Bind(self.GetBiPinRemind, self))
	RemindManager.Instance:Register(RemindName.BPCapabilityRemind, BindTool.Bind(self.GetBPCapabilityRemind, self))
	self.bipin_show = false
	self.is_first_open = true
	self.toggle_not_is_on = false
end

function CompetitionActivityData:__delete()
	RemindManager.Instance:UnRegister(RemindName.BiPin)
	RemindManager.Instance:UnRegister(RemindName.BPCapabilityRemind)

	CompetitionActivityData.Instance = nil
	self.is_first_open = true
	self.toggle_not_is_on = nil
end

function CompetitionActivityData:SetFirstOpenFlag()
	self.is_first_open = false
end

function CompetitionActivityData:GetFirstOpenFlag()
	return self.is_first_open
end

function CompetitionActivityData.IsBiPin(activity_type)
	return COMPETITION_ACTIVITY_TYPE[activity_type] ~= nil
end

function CompetitionActivityData.IsActivityBiPin(activity_type)
	return ACTIVITY_TYPE_TO_RANK_TYPE[activity_type] ~= nil
end

function CompetitionActivityData:GetBPCapabilityRemind()
	return ClickOnceRemindList[RemindName.BPCapabilityRemind]
end

function CompetitionActivityData:GetBiPinRemind()
	return self:GetIsShowRedpt() and 1 or 0
end

function CompetitionActivityData:SetBiPinRank(is_show)
	self.bipin_show = is_show 
end

function CompetitionActivityData:GetBiPinRank()
	return self.bipin_show
end

function CompetitionActivityData:GetBiPinRankType(rank_type)
	local rank_type_list = RankData.Instance:GetRankTypeList()
	local rank_key = 0
	for k,v in pairs(rank_type_list) do
		if rank_type == v then
			rank_key = k
		end
	end
	for k,v in pairs(ACTIVITY_TYPE_TO_RANK_TYPE) do
		if rank_key == v then
			local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
			local activity_type = COMPETITION_ACTIVITY_TYPE[server_day]
			if activity_type == k then
				return true
			end
		end
	end
	return false
end

function CompetitionActivityData:SetRankData()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local activity_type = COMPETITION_ACTIVITY_TYPE[server_day]
	local rank_data = RankData.Instance:GetRankList()
	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if not cfg[#cfg] then
		return
	end
	local seq = cfg[#cfg].seq_2 or 0
	local item_id = cfg[#cfg].reward_item[0].item_id
	local rank_name1 = (rank_data[1] and rank_data[1].flexible_int > 5) and rank_data[1].user_name or Language.Common.ZanWu
	local rank_name2 = (rank_data[2] and rank_data[2].flexible_int > 5) and rank_data[2].user_name or Language.Common.ZanWu
	local rank_name3 = (rank_data[3] and rank_data[3].flexible_int > 5) and rank_data[3].user_name or Language.Common.ZanWu
	
	local item_data = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_data then
		return
	end

	-- local content = string.format(Language.Activity.QuanMinBiPin, Language.Activity.QuanMinBP[seq], SOUL_NAME_COLOR[item_data.color],
	-- 	item_data.name, rank_name1, rank_name2, rank_name3)
	-- local content = string.format(Language.Activity.QuanMinBiPin, Language.Activity.QuanMinBP[seq], rank_name1, rank_name2, rank_name3, 
	-- 	SOUL_NAME_COLOR[item_data.color], ItemData.Instance:GetItemName(item_id))
	-- SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.SYSTEM_TYPE)
	-- local str = string.format(Language.Chat.BiPinEquipDec, Language.Activity.QuanMinBP[seq], rank_name1, rank_name2, rank_name3, item_id)
	-- ChatCtrl.Instance:AddSystemMsg(str)

	self.bipin_show = false
	ClickOnceRemindList[RemindName.BPCapabilityRemind] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.BPCapabilityRemind)
end

function CompetitionActivityData:GetIsShowRedpt()
	local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- local remind_day = PlayerPrefsUtil.GetInt("Remind_BiPin")

	-- if server_day == remind_day then
	-- 	return false
	-- end

	local activity_type = COMPETITION_ACTIVITY_TYPE[server_day]
	local act_cfg = ActivityData.Instance:GetActivityConfig(activity_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if act_cfg == nil or level < act_cfg.min_level or level > act_cfg.max_level then return false end

	local cfg = KaifuActivityData.Instance:GetKaifuActivityCfgByType(activity_type)
	if nil == cfg or nil == next(cfg) then return false end

	local is_reward = KaifuActivityData.Instance:IsGetReward(#cfg, activity_type)
	local is_complete = KaifuActivityData.Instance:IsComplete(#cfg, activity_type)

	return (is_complete and not is_reward) or self:GetFirstOpenFlag()
end

function CompetitionActivityData:GetBiPinTips(index)
	if ((index == TabIndex.mount_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[1]))				--坐骑进阶
		or (index == TabIndex.wing_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[2]))			--羽翼进阶
		or (index == TabIndex.halo_jinjie and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[4]))			--光环进阶
		or (index == TabIndex.goddess_info and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[3])))			--女神进阶
		-- or (index == TabIndex.goddess_shengong and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[3]))		--神弓进阶
		-- or (index == TabIndex.goddess_shenyi and ActivityData.Instance:GetActivityIsOpen(COMPETITION_ACTIVITY_TYPE[3])))		--神翼进阶
		and self:GetUpLVDan(index)
	then
		return index
	-- elseif TipsCtrl.Instance:GetBiPingView():IsOpen() then
	-- 	 TipsCtrl.Instance:GetBiPingView():Close()
	-- 	return false
	end
	return false
end

function CompetitionActivityData:GetUpLVDan(index)
	local item_id = nil
	if TabIndex.mount_jinjie == index then
		item_id = 23234
	elseif TabIndex.wing_jinjie == index then
		item_id = 23235
	elseif TabIndex.halo_jinjie == index then
		item_id = 23236
	elseif TabIndex.goddess_shengong == index then
		item_id = 23237
	elseif TabIndex.goddess_shenyi == index then
		item_id = 23238
	end
	if item_id then
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
		for k,v in pairs(bag_data_list) do
			if item_id == v.item_id then return false end
		end
	end
	return true
end

function CompetitionActivityData:SetToggleState(value)
	self.toggle_not_is_on = value or false
end

function CompetitionActivityData:GetToggleState()
	return self.toggle_not_is_on
end

function CompetitionActivityData:GetWeiYanRes(item_id)
	local data_list = WeiYanData.Instance:GetSpecialImagesCfg()
	for k,v in pairs(data_list) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
	return 0
end

function CompetitionActivityData:IsShowItemEffect(display_role)
	local list = {33,39,44,49}
	for k,v in  ipairs(list) do 
		if v == display_role then
			return true
		end
	end
	return false
end


		