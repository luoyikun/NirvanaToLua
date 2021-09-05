AppearanceData = AppearanceData or BaseClass(BaseEvent)

--是否清空祝福值
APPEARANCE_CLEAR_BLESS = {
	NOT_CLEAR = 0,
	CLEAR = 1,
}

-- 属性丹使用等级限制
APPEARANCE_SHUXINGDAN_LIMIT = {
	ZIZHIDAN = 3,
	CHENGZHANGDAN = 5,
	EQUIPLEVEL = 5,
}

-- 进阶系统类型
UPGRADE_TYPE = {
	LING_ZHU = 0,		-- 灵珠
	XIAN_BAO = 1,		-- 仙宝
	LING_TONG = 2,		-- 灵童
	LING_GONG = 3,		-- 灵弓
	LING_QI = 4,		-- 灵骑
	WEI_YAN = 5,		-- 尾焰
	SHOU_HUAN = 6,		-- 手环
	TAIL = 7,			-- 尾巴
	FLY_PET = 8,		-- 飞宠
}

function AppearanceData:__init()
	if AppearanceData.Instance then
		print_error("[AppearanceData] Attempt to create singleton twice!")
		return
	end
	AppearanceData.Instance = self
	self.appearence_equip_type = 0

	self.shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	RemindManager.Instance:Register(RemindName.AppearanceEquip, BindTool.Bind(self.CalAppearenceEquipRemind, self))
end

function AppearanceData:__delete()
	AppearanceData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.AppearanceEquip)
end

-- 根据类型、槽位获取属性丹数据
function AppearanceData:GetShuXingDanInfo(shuxingdan_type, slot_idx)
	for k, v in pairs(self.shuxingdan_cfg) do
		if v.type == shuxingdan_type and v.slot_idx == slot_idx then
			return v
		end
	end
	return nil
end

-- 获取形象激活表（下标是image_id）
function AppearanceData:GetActiveImageFlagTab(active_img_flag)
	local flag_tab = {}
	local count = 0
	for k, v in pairs(active_img_flag) do
		local bit_tab = bit:d2b(v)
		for i = 0, 7 do
			flag_tab[count] = bit_tab[33 - 8 + i]
			count = count + 1
		end
	end
	return flag_tab
end

-- 获取资质表
function AppearanceData:GetZiZhiCfg(app_type)
	local shuxingdan_cfg = ConfigManager.Instance:GetAutoConfig("shuxingdan_cfg_auto").reward
	for k, v in pairs(shuxingdan_cfg) do
		if v.slot_idx == SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI then
			if v.type == app_type then
				return v
			end
		end
	end
end

function AppearanceData:GetSpecialAttrActiveType(config, cur_grade, index)
	local active_grade, attr_type, attr_value
	for i, v in ipairs(config) do
		if nil == index or (index and (v.special_img_id == index or v.image_id == index)) then
			for key, value in pairs(v) do
				if nil ~= Language.Advance.SpecialAttr[key] then
					if value > 0 then
						active_grade = v.grade or v.level
						attr_type = key
						attr_value = value
						break
					end
				end
			end
			if active_grade then
				break
			end
		end
	end
	if nil == active_grade or nil == attr_type or nil == attr_value then return end
	if nil ~= index then
		if cur_grade >= active_grade then
			for i, v in ipairs(config) do
				if v.special_img_id == index or v.image_id == index then
					if v.grade == cur_grade then
						attr_value = v[attr_type]
						break
					else
						attr_value = nil
					end
				end
			end
			return cur_grade, attr_type, attr_value
		else
			return active_grade, attr_type, attr_value
		end
	else
		if cur_grade >= active_grade then
			if config[cur_grade] then
				attr_value = config[cur_grade][attr_type]
			else
				attr_value = nil
			end
			return cur_grade, attr_type, attr_value
		else
			return active_grade, attr_type, attr_value
		end
	end
end

function AppearanceData:CalAppearenceEquipRemind()
	local index = self.appearence_equip_type
	if index == TabIndex.appearance_lingtong then
		return LingChongData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.appearance_flypet then
		return FlyPetData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.appearance_lingqi then
		return LingQiData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.appearance_weiyan then
		return WeiYanData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.appearance_qilinbi then
		return QilinBiData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	elseif index == TabIndex.appearance_linggong then
		return LingGongData.Instance:CalAllEquipRemind() > 0 and 1 or 0
	end
end

function AppearanceData:SetEquipType(appearence_equip_type)
	self.appearence_equip_type = appearence_equip_type or 0
end


function AppearanceData:IsOpenEquip(tab_index)
	if tab_index == TabIndex.appearance_lingtong then
		return LingChongData.Instance:IsOpenEquip()
	elseif tab_index == TabIndex.appearance_flypet then
		return FlyPetData.Instance:IsOpenEquip()
	elseif tab_index == TabIndex.appearance_lingqi then
		return LingQiData.Instance:IsOpenEquip()
	elseif tab_index == TabIndex.appearance_weiyan then
		return WeiYanData.Instance:IsOpenEquip()
	elseif tab_index == TabIndex.appearance_qilinbi then
		return QilinBiData.Instance:IsOpenEquip()
	elseif tab_index == TabIndex.appearance_linggong then
		return LingGongData.Instance:IsOpenEquip()
	end
	return false, 0
end