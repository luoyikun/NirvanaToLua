LingRenData = LingRenData or BaseClass()

ShenBingDanId = {
	ZiZhiDanId = 22106,
	ChengZhangDanId = 22125,
}

ShenBingShuXingDanCfgType = {
	Type = 11
}

function LingRenData:__init()
	if LingRenData.Instance then
		print_error("[LingRenData] Attemp to create a singleton twice !")
		return
	end
	LingRenData.Instance = self
	self.shenbing_info = {}
	self.shenbing_cfg = ConfigManager.Instance:GetAutoConfig("shenbingconfig_auto")
end

function LingRenData:__delete()
	LingRenData.Instance = nil
	self.shenbing_info = {}
end

function LingRenData:GetRemind()
	if not OpenFunData.Instance:CheckIsHide("immortals_jinjie") then
		return 0
	end
	return (self:GetShenBingLevelRemind() or self:GetShenBingZiZhiRemind() or self:GetShenBingChengZhangRemind()) and 1 or 0
end

function LingRenData:GetShenBingLevelRemind()
	if next(self.shenbing_info) then
		if self.shenbing_info.level >= self:GetLingRenMaxLevel() then return false end
		local level_exp = 0
		for i = 1, 3 do
			local cur_item_id = self:GetUpLevelCfg(i - 1).up_level_item_id
			local level_exp_vale = self:GetUpLevelCfg(i - 1).level_exp
			local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
			if num > 0 then 
				local temp_level_exp = num * level_exp_vale
				level_exp = level_exp + temp_level_exp
			end
		end
		level_exp = level_exp + self.shenbing_info.exp
		local level_attr_cfg = self:GetLevelAttrCfg(self.shenbing_info.level)
		local uplevel_exp = level_attr_cfg.uplevel_exp 
		if uplevel_exp and level_exp >= uplevel_exp then
			return true 
		end
	end
	return false
end

-- 获取当前等级可使用的最大成长丹数量
function LingRenData:GetMaxChengZhangDanCount(grade)
	local max_num = 0
	if nil == self.shenbing_info then
		return max_num
	end
	grade = grade or self.shenbing_info.level 
	max_num = self:GetLingRenChengZhangLevelCfg(grade)
	return max_num
end

function LingRenData:GetLingRenChengZhangLevelCfg(level)
	level = level or self.shenbing_info.level
	local list = self:GetLevelAttrCfg(level)
	return list and list.chengzhangdan_limit or 0
end

function LingRenData:GetChengZhangDanNextLevel(level)
	local list = self:GetLevelAttrCfg(level)
	if list then
		local chengzhangdan_count = list.chengzhangdan_limit
		if chengzhangdan_count then
			for k,v in ipairs(self.shenbing_cfg.level_attr) do
				if v.chengzhangdan_limit > chengzhangdan_count then
					return v.level, v.chengzhangdan_limit
				end
			end
		end
	end
	return 0, -1
end


function LingRenData:GetMaxLevel()
	local max_level = 0
	for k, v in pairs(self.shenbing_cfg.level_attr) do
		if v.level > max_level then
			max_level = v.level
		end
	end
	return max_level
end

function LingRenData:GetShenBingZiZhiRemind()
	if nil == next(self.shenbing_info) then
		return false
	end
	
	local max_shuxingdan_count = self:GetLimitXingDanCount()
	local info = self:GetShenBingInfo()
	if info and info.shuxingdan_count then 
		if info.shuxingdan_count >= max_shuxingdan_count then
			return false
		end
	end
	return ItemData.Instance:GetItemNumInBagById(ShenBingDanId.ZiZhiDanId) > 0
end

function LingRenData:GetShenBingChengZhangRemind()
	if nil == next(self.shenbing_info) then
		return false
	end
	local max_chengzhangdan_count = self:GetMaxChengZhangDanCount()
	local info = self:GetShenBingInfo()
	if info and info.chengzhangdan_count then 
		if info.chengzhangdan_count >= max_chengzhangdan_count then
			return false
		end
	end
	return ItemData.Instance:GetItemNumInBagById(ShenBingDanId.ChengZhangDanId) > 0
end

function LingRenData:SetShenBingInfo(protocol)
	self.shenbing_info.level = protocol.level
	self.shenbing_info.use_image = protocol.use_image
	-- self.shenbing_info.shuxingdan_count = protocol.shuxingdan_count
	self.shenbing_info.shuxingdan_count = protocol.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI]			-- 资质丹

	self.shenbing_info.chengzhangdan_count = protocol.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG]	-- 成长丹
	self.shenbing_info.exp = protocol.exp
end

function LingRenData:GetShenBingInfo()
	return self.shenbing_info
end

function LingRenData:GetShenBingCfg()
	return self.shenbing_cfg
end

function LingRenData:GetIsActive(skill_index)
	if next(self.shenbing_info) then
		for k,v in pairs(self.shenbing_cfg.skill) do
			if v.skill_idx == skill_index and self.shenbing_info.level >= v.shenbing_level then
				return true
			end
		end
	end
	return false
end

function LingRenData:GetShenBingSkillCfg(index)
	for k,v in pairs(self.shenbing_cfg.skill) do
		if index == v.skill_idx then
			return v
		end
	end
end

function LingRenData:GetLimitXingDanCount(level)
	local level = level or self.shenbing_info.level or 1
	for k,v in pairs(self.shenbing_cfg.level_attr) do
		if v.level == level then
			return v.shuxingdan_limit
		end
	end
	return 0
end

function LingRenData:GetLimitXingDanNextLevelCount(level)
	local shuxingdan_count = self:GetLimitXingDanCount(level)
	for k,v in pairs(self.shenbing_cfg.level_attr) do
		if v.shuxingdan_limit > shuxingdan_count then
			return v.level, v.shuxingdan_limit
		end
	end
	return 0, -1
end

function LingRenData:GetUpLevelCfg(up_level_index)
	for k,v in pairs(self.shenbing_cfg.up_level_stuff) do
		if v.up_level_item_index == up_level_index then
			return v
		end
	end
end

function LingRenData:GetAttrCfg(level)
	local max_level = self:GetMaxLevel()
	local level = (level and level >= max_level) and max_level or level
	for k,v in pairs(self.shenbing_cfg.level_attr) do
		if v.level == level then
			return v
		end
	end
	return {}
end

function LingRenData:GetLevelAttrCfg(level)
	local lingren_cfg = self:GetAttrCfg(level)
	local chengzhang_cfg ={}
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.type == CloakShuXingDanCfgType.Type and v.slot_idx == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG then
			chengzhang_cfg = v
		end
	end
	local attr_cfg = TableCopy(lingren_cfg)
	if chengzhang_cfg and next(chengzhang_cfg) then
		for k, v in pairs(lingren_cfg) do
			attr_cfg[k] = math.ceil((self.shenbing_info.chengzhangdan_count * chengzhang_cfg.attr_per / 10000 + 1) * v)
		end
		attr_cfg.chengzhangdan_limit = lingren_cfg.chengzhangdan_limit
	end
	return attr_cfg
end

function LingRenData:CheckSelectItem(cur_index)
	local cur_item_id = self:GetUpLevelCfg(cur_index).up_level_item_id
	local num = ItemData.Instance:GetItemNumInBagById(cur_item_id)
	if num > 0 then return cur_index end

	for k,v in pairs(self.shenbing_cfg.up_level_stuff) do
		if v.up_level_item_id ~= cur_item_id then
			local num = ItemData.Instance:GetItemNumInBagById(v.up_level_item_id)
			if num > 0 then return v.up_level_item_index end
		end
	end

	return self.shenbing_cfg.up_level_stuff[1].up_level_item_index
end

function LingRenData:CheckPlayEffect(level)
	return next(self.shenbing_info) and self.shenbing_info.level ~= level
end

function LingRenData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.shenbing_info.level or 0
	return AdvanceData.Instance:GetSpecialAttrActiveType(self.shenbing_cfg.level_attr, cur_grade)
end

function LingRenData:GetLingRenMaxLevel()
	local cfg = self.shenbing_cfg.level_attr
	return cfg[#cfg].level
end

