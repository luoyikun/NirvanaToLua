CrossRankData = CrossRankData or BaseClass()

function CrossRankData:__init()
	if CrossRankData.Instance then
		print_error("[CrossRankData] Attemp to create a singleton twice !")
	end
	CrossRankData.Instance = self

	self:InitConfig()
end

function CrossRankData:__delete()
	CrossRankData.Instance = nil
end

-------------------------------------- 配置表处理 --------------------------------------
function CrossRankData:InitConfig()
	local cross_rank_reward_cfg = ConfigManager.Instance:GetAutoConfig("crossrank_reward_auto")
	self.reward_cfg = cross_rank_reward_cfg.reward_cfg
	self.reward_date = cross_rank_reward_cfg.reward_date
	self.cross_guild_kill_boss_rank = cross_rank_reward_cfg.cross_guild_kill_boss_rank
end
-------------------------------------- 配置表结束 --------------------------------------

-------------------------------------- 协议返回处理 --------------------------------------
-- 跨服排行榜（单人）信息返回
function CrossRankData:OnPersonCrossRankListAck(protocol)
	self.rank_type = protocol.rank_type or 0
	self:SetPersonCrossRankListInfo(protocol.rank_list)
end

-- 跨服情侣排行榜信息返回
function CrossRankData:OnSCGetCrossCoupleRankListAck(protocol)
	self.rank_type = protocol.rank_type + 1000		-- 跨服情侣榜+1000为客户端类型
	self:SetCoupleCrossRankInfo(protocol.couple_rank_list)
end

-- 跨服排行榜自己信息返回
function CrossRankData:OnSCGetSpecialRankValueAck(protocol)
	self.private_rank_type = protocol.rank_type
	self.private_rank_value = protocol.rank_value
	self:SetSelfCrossRankInfo()
end

-------------------------------------- 协议返回结束 --------------------------------------

function CrossRankData:InitCrossRankTypeList()
	self.cross_rank_type = {
		CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ADD_CAPABILITY,		-- 跨服增战榜
		CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ADD_CHARM,			-- 跨服增魅榜
		CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_COUPLE_RANK,			-- 跨服情侣榜
		CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS,		-- 跨服工会榜
	}
end

-- 获取排行榜标签
function CrossRankData:GetCrossRankTypeList()
	if self.cross_rank_type == nil then
		self:InitCrossRankTypeList()
	end
	return self.cross_rank_type or {}
end

-- 设置跨服排行榜自己的数据
function CrossRankData:SetSelfCrossRankInfo()
	local temp_cross_rank_info = {}
	temp_cross_rank_info.rank_type = self.private_rank_type or -1
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	temp_cross_rank_info.plat_type = main_role_vo.plat_type
	temp_cross_rank_info.server_id = main_role_vo.server_id
	temp_cross_rank_info.uid = main_role_vo.role_id
	temp_cross_rank_info.name = main_role_vo.name
	temp_cross_rank_info.sex = main_role_vo.sex
	temp_cross_rank_info.prof = main_role_vo.prof
	if temp_cross_rank_info.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		temp_cross_rank_info.rank_value = self:GetMyGuildRankData(main_role_vo.guild_id)
	else
		temp_cross_rank_info.rank_value = self.private_rank_value or 0
	end
	
	temp_cross_rank_info.lover_info = {}
	temp_cross_rank_info.is_married = MarriageData.Instance:CheckIsMarry()
	temp_cross_rank_info.guild_id = main_role_vo.guild_id
	temp_cross_rank_info.guild_name = main_role_vo.guild_name
	if self:GetIsCoupleRank(true) then
		if temp_cross_rank_info.is_married then
			local temp_lover_info = {}
			temp_lover_info.uid = main_role_vo.lover_uid
			temp_lover_info.name = main_role_vo.lover_name
			temp_lover_info.sex = main_role_vo.sex == GameEnum.MALE and GameEnum.FEMALE or GameEnum.MALE
			temp_lover_info.prof = MarriageData.Instance:GetLoverProf()
			temp_cross_rank_info.lover_info = temp_lover_info
		end
	end

	self.private_rank_info = temp_cross_rank_info
end

function CrossRankData:GetPrivateCrossRankInfo()
	return self.private_rank_info or {}
end

function CrossRankData:GetMyGuildRankData(my_guildid)
	if self.rank_list ~= nil then
		for k, v in pairs(self.rank_list) do
			if v.guild_id == my_guildid then
				return v.rank_value
			end
		end
	end
	return 0
end

-- 设置跨服排行榜（单人）数据
function CrossRankData:SetPersonCrossRankListInfo(rank_list)
	local temp_cross_rank_info = {}
	for i,v in ipairs(rank_list) do
		local temp_list = {}
		temp_list.rank_type = self.rank_type or -1
		temp_list.plat_type = v.plat_type
		temp_list.server_id = v.server_id
		temp_list.uid = v.user_id
		temp_list.name = v.user_name
		temp_list.sex = v.sex
		temp_list.prof = v.prof
		temp_list.rank_value = v.rank_value
		temp_list.is_married = false
		temp_list.lover_info = {}

		temp_list.avatar_key_big = v.avatar_key_big
		temp_list.avatar_key_small = v.avatar_key_small
		temp_list.guild_name = v.flexible_name
		temp_list.guild_id = v.user_id
		if self.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
			temp_list.uid = v.flexible_int																	--服务端改了 flexible_int 对应团长id
			AvatarManager.Instance:SetAvatarKey(temp_list.guild_id, v.avatar_key_big, v.avatar_key_small, true)
		end
		table.insert(temp_cross_rank_info, temp_list)
	end
	self.rank_list = temp_cross_rank_info
end

-- 设置跨服情侣排行榜数据
function CrossRankData:SetCoupleCrossRankInfo(couple_rank_list)
	local temp_cross_rank_couple_info = {}

	for i,v in ipairs(couple_rank_list) do
		local temp_list = {}
		temp_list.rank_type = self.rank_type or -1
		temp_list.plat_type = v.plat_type
		temp_list.server_id = v.server_id
		temp_list.uid = v.male_uid
		temp_list.name = v.male_name
		temp_list.sex = GameEnum.MALE
		temp_list.prof = v.male_prof
		local male_rank_value = v.male_rank_value or 0
		local female_rank_value = v.female_rank_value or 0
		temp_list.rank_value = male_rank_value + female_rank_value
		temp_list.is_married = true
		local temp_lover_info = {}
		temp_lover_info.uid = v.female_uid
		temp_lover_info.name = v.female_name
		temp_lover_info.sex = GameEnum.FEMALE
		temp_lover_info.prof = v.female_prof
		temp_list.lover_info = temp_lover_info

		table.insert(temp_cross_rank_couple_info, temp_list)
	end

	self.rank_list = temp_cross_rank_couple_info
end

-- 获取排行榜列表
function CrossRankData:GetCrossRankList()
	return self.rank_list or {}
end

-- 获取单条排行榜数据
function CrossRankData:GetCrossRankInfoByIndex(index)
	if self.rank_list == nil then
		return nil
	end
	return self.rank_list[index]
end

-- 是否为情侣榜
function CrossRankData:GetIsCoupleRank(is_self)
	local rank_type = is_self and self.private_rank_type or self.rank_type
	return rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_COUPLE_RANK
end

-- 根据排行榜类型获取时装奖励
function CrossRankData:GetFashionRewardByType(rank_type)
	if rank_type == nil then
		return 0
	end
	local cfg = {}
	-- if rank_type ~= CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		cfg = self.reward_cfg 
	-- else
	-- 	cfg = self.cross_guild_kill_boss_rank
	-- end
	if cfg == nil then
		return 0 
	end
	for k,v in pairs(cfg) do
		if rank_type == v.rank_type and v.rank_pos == 1 then
			return v.img_item_id
		end
	end
	return 0
end

-- 获取自己的排名
function CrossRankData:GetSelfRankNum()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.rank_list == nil then
		return 0
	end
	if self.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		for i,v in ipairs(self.rank_list) do
			if v.guild_id == main_role_vo.guild_id then
				return i
			end
		end
	else
		for i,v in ipairs(self.rank_list) do
			if v.uid == main_role_vo.role_id then
				return i
			end
		end
	end
	if self:GetIsCoupleRank(false) then
		for i,v in ipairs(self.rank_list) do
			if v.lover_info.uid == main_role_vo.role_id then
				return i
			end
		end
	end
	return 0
end

-- 根据类型名次获取奖励
function CrossRankData:GetRewardByRankNum(rank_type, rank_num)
	if rank_type == nil or rank_num == nil then
		return 0
	end

	if rank_num == 0 then
		return 0
	end

	local cfg = {}
	if rank_type ~= CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		cfg = self.reward_cfg 
	else
		cfg = self.cross_guild_kill_boss_rank
	end
	if cfg == nil then
		return 0 
	end

	for k,v in pairs(cfg) do
		if rank_type == v.rank_type and rank_num <= v.rank_pos then
			return v.img_item_id
		end
	end
	return 0
end

-- 根据类型获取结算时间
function CrossRankData:GetRewardDateByTime(rank_type)
	local reward_date = {}
	if rank_type == nil or self.reward_date == nil then
		return reward_date
	end

	for i,v in ipairs(self.reward_date) do
		if rank_type == v.rank_type then
			table.insert(reward_date, v.weekday)
		end
	end
	return reward_date
end

function CrossRankData:GetRewardTitle(index, rank_type)
	if self.cross_guild_kill_boss_rank then
		for k,v in pairs(self.cross_guild_kill_boss_rank) do
			if rank_type == v.rank_type then
				return v.tuanzhang_title_id, v.member_title_id
			end
		end
	end
end

function CrossRankData:GetRewardTitleItemId(rank_type)
	if self.cross_guild_kill_boss_rank then
		for k,v in pairs(self.cross_guild_kill_boss_rank) do
			if rank_type == v.rank_type then
				return v.img_item_id, v.img_item_id2
			end
		end
	end
end


function CrossRankData:SetSelectTableIndex(index)
	self.tab_index = index
end

function CrossRankData:GetSelectTableIndex()
	return self.tab_index or 1
end