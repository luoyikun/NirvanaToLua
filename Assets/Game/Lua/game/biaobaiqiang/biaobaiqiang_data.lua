BiaoBaiQiangData = BiaoBaiQiangData or BaseClass()

local WALL_TYPE = {
	MYSELFWALL = 0,			--我表白的
	TOSELFWALL = 1,			--表白我的
	COMMONWALL = 2,			--公共墙
}

function BiaoBaiQiangData:__init()
	if BiaoBaiQiangData.Instance then
		ErrorLog("[BiaoBaiQiangData] attempt to create singleton twice!")
		return
	end
	BiaoBaiQiangData.Instance = self

	self.gift_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").profess_gift
	self.common_wall_info = {
		profess_count = 0,
		timestamp = -1,
		profess_item = {},
	}
	
	self.person_wall_info = {
		profess_count = 0,
		timestamp = -1,
		my_item = {},
		toself_item = {},
	}

	self.male_rank_info = {
	}
	self.female_rank_info = {
	}


	self.common_wallcount = 0							-- 公共墙数量
	self.my_wallcount = 0								-- 自己的墙
	self.toself_wallcount = 0							-- 对自己的墙
	self.cur_index = 0									-- 选中下标
	self.select_index = 1
	self.baby_id = 0
end

function BiaoBaiQiangData:__delete()
	BiaoBaiQiangData.Instance = nil
end

function BiaoBaiQiangData:GetCfgByType(gift_type)
	for _,v in pairs(self.gift_cfg) do
		if v.gift_type == gift_type then
			return v
		end 
	end
	return nil
end

function BiaoBaiQiangData:SetCurrent(index)
	self.cur_index = index
end

function BiaoBaiQiangData:GetCurIndex()
	return self.cur_index
end

function BiaoBaiQiangData:SetSelectindex(index)
	self.select_index = index
end
function BiaoBaiQiangData:GetSelectindex()
	if not ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) and self.select_index > 3 then
		return 1
	else
		return self.select_index
	end
end

function BiaoBaiQiangData:GetCommonWallNum()
	return self.common_wallcount
end

function BiaoBaiQiangData:GetMyWallNum()
	return self.my_wallcount
end

function BiaoBaiQiangData:GetToMyWallNum()
	return self.toself_wallcount
end

function BiaoBaiQiangData:CommonWallInfo(protocol)
	self.common_wall_info.profess_count = protocol.profess_count
	self.common_wallcount = math.max(self.common_wallcount, self.common_wall_info.profess_count)
	self.common_wall_info.timestamp = protocol.timestamp
	for i = 1, protocol.profess_count do
		if self.common_wall_info.profess_item[i] then
			self.common_wall_info.profess_item[i] = nil
		end
	end

	for i = protocol.profess_count + 1, self.common_wallcount do
		if self.common_wall_info.profess_item[i] then
			self.common_wall_info.profess_item[i - protocol.profess_count] = self.common_wall_info.profess_item[i]
		end
	end

	if self.common_wallcount - protocol.profess_count <= 0 then
		for i = 1, protocol.profess_count do
			self.common_wall_info.profess_item[i] = protocol.profess_item[i]

		end
	else
		for i = self.common_wallcount - protocol.profess_count, self.common_wallcount do
			self.common_wall_info.profess_item[i] = protocol.profess_item[i]
		end
	end
	if self.common_wall_info.profess_item then
		table.sort(self.common_wall_info.profess_item, SortTools.KeyUpperSorters("profess_time"))
	end
end

function BiaoBaiQiangData:GetDataInfo(index)
	return self.common_wall_info.profess_item[index]
end

function BiaoBaiQiangData:GetMyDataInfo(index)
	return self.person_wall_info.my_item[index]
end

function BiaoBaiQiangData:GetToSelfDataInfo(index)
	return self.person_wall_info.toself_item[index]
end

function BiaoBaiQiangData:SetMaleRankInfo(list)
	self.male_rank_info = list
end

function BiaoBaiQiangData:GetMaleRankInfo()
	return self.male_rank_info
end

function BiaoBaiQiangData:SetFemaleRankInfo(list)
	self.female_rank_info = list
end

function BiaoBaiQiangData:GetFemaleRankInfo()
	return self.female_rank_info
end

function BiaoBaiQiangData:GetRankCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.profess_rank, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK)
end

function BiaoBaiQiangData:GetShowItem()
	local cfg = self:GetRankCfg()
	for i,v in ipairs(cfg) do
		if v.seq == 0 then
			return v.reward_item.item_id
		end
	end
	return nil
end

function BiaoBaiQiangData:SetMyRankInfo(protocol)
	self.my_rank_info = protocol
end

function BiaoBaiQiangData:GetMyRankInfo()
	return self.my_rank_info
end

function BiaoBaiQiangData:GetRankFirst(num)
	if num == 1 then
		return self:GetMaleRankInfo()[1]
	elseif num == 2 then
		return self:GetFemaleRankInfo()[1]
	end
end

function BiaoBaiQiangData:PersonWallInfo(protocol)
	if protocol.profess_type == WALL_TYPE.COMMONWALL then return end
	self.person_wall_info.profess_count = protocol.profess_count
	self.person_wall_info.timestamp = protocol.timestamp
	-- -- if self.person_wall_info.timestamp < protocol.timestamp then
	-- -- if count >= MAX_COUNT then
	-- 	self.person_wall_info.timestamp = protocol.timestamp
	-- 	for i = 1, protocol.profess_count do
	-- 		if item[i] then
	-- 			item[i] = nil
	-- 		end
	-- 	end

	-- 	for i = protocol.profess_count + 1, count do
	-- 		if item[i] then
	-- 			item[i - protocol.profess_count] = item[i]
	-- 		end
	-- 	end
	-- else
	-- 	if count - protocol.profess_count <= 0 then
	if protocol.profess_type == WALL_TYPE.MYSELFWALL then
		self.person_wall_info.my_item = protocol.profess_item
		table.sort(self.person_wall_info.my_item, SortTools.KeyUpperSorters("profess_time"))
		self.my_wallcount = protocol.profess_count
	else
		self.person_wall_info.toself_item = protocol.profess_item
		table.sort(self.person_wall_info.toself_item, SortTools.KeyUpperSorters("profess_time"))
		self.toself_wallcount = protocol.profess_count
	end
	-- 	else
	-- 		for i = count - protocol.profess_count, count do
	-- 			item[i] = protocol.profess_item[i]
	-- 		end
	-- 	end
	-- end
end

function BiaoBaiQiangData:SetBabySelectCfg(index)
		self.baby_id = index
end

function BiaoBaiQiangData:GetBabySelectCfg()
	 return self.baby_id
end

