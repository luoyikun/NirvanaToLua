TouShiData = TouShiData or BaseClass()

TouShiShuXingDanCfgType = {
	Type = 19,					-- 头饰资质丹类型
}

TouShiShuXingDanId = {
	ZiZhiDanId = 22123,			-- 头饰资质丹
	ChengZhangDanId = 22128,	-- 头饰成长丹
}

function TouShiData:__init()
	if TouShiData.Instance ~= nil then
		ErrorLog("[TouShiData] attempt to create singleton twice!")
		return
	end
	TouShiData.Instance = self

	self.toushi_cfg = ConfigManager.Instance:GetAutoConfig("toushi_auto")

	self.other_cfg = self.toushi_cfg.other[1]
	self.toushi_grade_cfg = ListToMap(self.toushi_cfg.grade, "grade")
	self.toushi_image_list_cfg = ListToMap(self.toushi_cfg.image_list, "image_id")
	self.toushi_special_img_cfg = ListToMap(self.toushi_cfg.special_img, "image_id")
	self.toushi_special_img_item_cfg = ListToMap(self.toushi_cfg.special_img, "item_id")
	self.toushi_special_image_upgrade_cfg = ListToMap(self.toushi_cfg.special_image_upgrade, "special_img_id", "grade")
	self.huanhua_special_cap_add = ListToMap(self.toushi_cfg.huanhua_special_cap_add, "huanhua_id")			--幻化特殊战力加成
	self.special_grade_max_level = self:CalcSpecialImgMaxLevel()
	self.toushi_skill_cfg = self.toushi_cfg.toushi_skill

	RemindManager.Instance:Register(RemindName.TouShi, BindTool.Bind(self.ShowTouShiRemind, self))
	RemindManager.Instance:Register(RemindName.TouShiHuanHua, BindTool.Bind(self.CalcHuanHuaRemind, self))	-- 头饰幻化红点
end

function TouShiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.TouShi)
	RemindManager.Instance:UnRegister(RemindName.TouShiHuanHua)
	TouShiData.Instance = nil
end

function TouShiData:SetTouShiInfo(info)
	if self.toushi_info and self.toushi_info.grade_bless_val then
		local diff = info.grade_bless_val - self.toushi_info.grade_bless_val
		local bless_cfg =  AdvanceData.Instance:GetBlessBaojiCfg(UPGRADE_BAOJI_TYPE.UPGRADE_TYPE_TOUSHI)
		local baoji_bless = bless_cfg.upgrade_exp * bless_cfg.crit_value
		if diff > 0 and diff == baoji_bless then
			TipsCtrl.Instance:OpenBaojiViewTips("appearance_view")
		end
	end

	self.toushi_info = info
	self.toushi_info.shuxingdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI]			-- 资质丹
	self.toushi_info.chengzhangdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG]	-- 成长丹
	self.special_img_grade_list = self.toushi_info.special_img_grade_list
	self.active_image_flag_list = bit:uc2b(info.active_image_flag)
	self.active_special_image_flag_list = bit:uc2b(info.active_special_image_flag)
end

function TouShiData:GetTouShiInfo()
	return self.toushi_info
end

-- 全属性加成所需阶数
function TouShiData:GetActiveNeedGrade()
  	return self.other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function TouShiData:GetGrade()
	if self.toushi_info then
  		return self.toushi_info.grade or 0
  	end
  	return 0
end

-- 全属性加成百分比
function TouShiData:GetAllAttrPercent()
  	local attr_percent = math.floor(self.other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function TouShiData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

--获取对应等级相关数据
function TouShiData:GetTouShiGradeCfgInfoByGrade(grade)
	grade = grade or (self.toushi_info and self.toushi_info.grade) or 0
	return self.toushi_grade_cfg[grade]
end

--获取清空祝福值的最小阶数
function TouShiData:GetClearBlessGradeLimit()
	for k, v in ipairs(self.toushi_grade_cfg) do
		if v.is_clear_bless == 1 then
			return v.show_grade, v.gradename
		end
	end

	return 0, ""
end

function TouShiData:GetTouShiImageCfgInfoByImageId(image_id)
	return self.toushi_image_list_cfg[image_id]
end

function TouShiData:GetTouShiImage()
	return self.toushi_image_list_cfg
end

function TouShiData:GetSpecialImageCfgInfoByImageId(image_id)
	return self.toushi_special_img_cfg[image_id]
end

function TouShiData:GetSpecialImageCfgInfoByItemId(item_id)
	item_id = item_id or 0
	return self.toushi_special_img_item_cfg[item_id]
end

-- 获取特殊形象配置
function TouShiData:GetSpecialImageCfg()
	return self.toushi_special_img_cfg
end

-- 获取对应的资源id
function TouShiData:GetResIdByImageId(image_id)
	local image_info = nil
	if image_id > 1000 then
		-- 特殊形象由1000开始
		image_id = image_id - 1000
		image_info = self:GetSpecialImageCfgInfoByImageId(image_id)
	else
		image_info = self:GetTouShiImageCfgInfoByImageId(image_id)
	end

	if image_info then
		return image_info.res_id
	end

	return 0
end

-- 计算特殊形象等级上限
function TouShiData:CalcSpecialImgMaxLevel()
	local level_limit = 0
	for k, v in pairs(self.toushi_special_image_upgrade_cfg) do
		for k2, v2 in pairs(v) do
			if v2.grade > level_limit then
				level_limit = v2.grade
			end
		end
		break
	end

	return level_limit
end

-- 获取特殊形象等级上限
function TouShiData:GetSpecialImgMaxLevel()
	return self.special_grade_max_level
end

-- 获取对应的幻化image_id是否已使用
function TouShiData:GetHuanHuaIdIsUsed(image_id, is_special)
	if nil == self.toushi_info then
		return false
	end

	-- 特殊形象加1000
	if is_special then
		image_id = image_id + 1000
	end

	return self.toushi_info.used_imageid == image_id
end

-- 获取当前等级可使用最大资质丹数量
function TouShiData:GetMaxShuXingDanCount(grade)
	local max_num = 0
	if nil == self.toushi_info then
		return max_num
	end

	grade = grade or self.toushi_info.grade

	-- 先获取当前阶数的属性丹最大数量
	local grade_info = self:GetTouShiGradeCfgInfoByGrade(grade)
	if nil == grade_info then
		return max_num
	end
	max_num = max_num + grade_info.shuxingdan_limit

	-- 加上幻化形象增加的资质丹数量
	local flag = 0
	for k, v in pairs(self.toushi_special_image_upgrade_cfg) do
		if self.active_special_image_flag_list[k] == 1 then
			max_num = max_num + v[0].shuxingdan_count
		end
	end

	return max_num
end

-- 获取当前等级可使用的最大成长丹数量
function TouShiData:GetMaxChengZhangDanCount(grade)
	local max_num = 0
	if nil == self.toushi_info then
		return max_num
	end

	grade = grade or self.toushi_info.grade 

	local grade_cfg = self:GetTouShiGradeCfgInfoByGrade(grade)
	if nil == grade_cfg then
		return max_num
	end
	max_num = max_num + grade_cfg.chengzhangdan_limit

	-- 加上幻化形象增加的成长丹数量
	local flag = 0
	for k, v in pairs(self.toushi_special_image_upgrade_cfg) do
		if self.active_special_image_flag_list[k] == 1 then
			max_num = max_num + v[0].chengzhangdan_count
		end
	end

	return max_num
end

-- 获取可显示的幻化列表
function TouShiData:GetHuanHuaCfgList()
	local huanhua_list = nil

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in pairs(self.toushi_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			if nil == huanhua_list then
				huanhua_list = {}
			end

			table.insert(huanhua_list, v)
		end
	end

	return huanhua_list
end

function TouShiData:CanHuanhuaIndexByImageId(image_id)
	local list = self:GetHuanHuaCfgList()
	local num = 0
	for k, v in ipairs(list) do
		num = num + 1
		if v.item_id == image_id then
			return k, num
		end
	end
end

--获取对应幻化等级
function TouShiData:GetHuanHuaGrade(image_id)
	if nil == self.special_img_grade_list then
		return 0
	end
	return self.special_img_grade_list[image_id] or 0
end

--获取对应幻化信息
function TouShiData:GetHuanHuaCfgInfo(image_id, grade)
	grade = grade or self:GetHuanHuaGrade(image_id)

	if self.toushi_special_image_upgrade_cfg[image_id] then
		return self.toushi_special_image_upgrade_cfg[image_id][grade]
	end

	return nil
end

-- 获取幻化最大等级
function TouShiData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self.toushi_cfg.special_image_upgrade) do
		if v.special_img_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

--获取对应幻化形象是否已激活
function TouShiData:GetHuanHuaIsActiveByImageId(image_id)
	if nil == self.active_special_image_flag_list then
		return false
	end

	return self.active_special_image_flag_list[image_id] == 1
end

--获取对应幻化形象的红点
function TouShiData:GetHuanHuaRemindByImageId(image_id)
	--没达到对应开服天数, 或者等级没达到要求没有红点
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local image_info = self.toushi_special_img_cfg[image_id]
	if not image_info or open_server_day < image_info.open_day or main_vo.level < image_info.lvl then
		return 0
	end

	if nil == self.special_img_grade_list then
		return 0
	end

	--满级的话没有红点
	local grade = self.special_img_grade_list[image_id]
	if nil == grade or grade >= self.special_grade_max_level then
		return 0
	end

	local grade_list = self.toushi_special_image_upgrade_cfg[image_id]
	if nil == grade_list then
		return 0
	end

	local grade_info = grade_list[grade]
	if nil == grade_info then
		return 0
	end

	local have_num = ItemData.Instance:GetItemNumInBagById(grade_info.stuff_id)
	if have_num >= grade_info.stuff_num then
		return 1
	end

	return 0
end

--计算幻化形象红点
function TouShiData:CalcHuanHuaRemind()
	if nil == self.special_img_grade_list then
		return 0
	end

	--判断是否有幻化形象可激活或可升级
	local grade_list = nil				--对应资源的等级列表
	local grade_info = nil				--对应等级相关数据
	local img_info = nil				--对应资源相关数据
	local have_num = 0
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.special_img_grade_list) do
		grade_list = self.toushi_special_image_upgrade_cfg[k]
		img_info = self.toushi_special_img_cfg[k]

		--达到对应开服天数, 人物等级达到要求, 当前等级数据存在且下一级数据也存在则进入物品数量判断
		if img_info
			and open_server_day >= img_info.open_day
			and main_vo.level >= img_info.lvl
			and grade_list
			and grade_list[v]
			and grade_list[v + 1] then

			grade_info = grade_list[v]
			have_num = ItemData.Instance:GetItemNumInBagById(grade_info.stuff_id)
			if have_num >= grade_info.stuff_num then
				return 1
			end
		end
	end

	return 0
end

-- 计算资质丹红点
function TouShiData:IsShowZiZhiRemind()
	if self.toushi_info then
		if self.toushi_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN then
			return false
		end
		if self.toushi_info.shuxingdan_count >= self:GetMaxShuXingDanCount(self.toushi_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(TouShiShuXingDanId.ZiZhiDanId) > 0 then
			return true
		end
	end

	return false
end

-- 计算成长丹按钮红点
function TouShiData:IsShowGrowupRemind()
	if self.toushi_info then
		if self.toushi_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN then
			return false
		end
		if self.toushi_info.chengzhangdan_count >= self:GetMaxChengZhangDanCount(self.toushi_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(TouShiShuXingDanId.ChengZhangDanId) > 0 then
			return true
		end
	end
	return false
end

-- 计算进阶按钮红点
function TouShiData:IsShowUpgradeBtnRemind()
	if not self.toushi_info or not self.toushi_info.grade then
		return false
	end

	local toushi_cfg = self:GetTouShiGradeCfgInfoByGrade(self.toushi_info.grade)
	if not toushi_cfg  then
		return false
	end

	-- 不清空祝福值时和可进阶时，显示红点
	if toushi_cfg.is_clear_bless == APPEARANCE_CLEAR_BLESS.NOT_CLEAR then
		local item_id = toushi_cfg.upgrade_stuff_id
		local item_id2 = toushi_cfg.upgrade_stuff2_id
		local need_item_num = toushi_cfg.upgrade_stuff_count
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
		if have_item_num >= need_item_num then
			return true
		end
	end

	return false
end

function TouShiData:IsHaveZhiShengDanInGrade()
  if self.toushi_info and next(self.toushi_info) then
    local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)	
    for k, v in pairs(zhishengdan_list) do
      local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
      if item_cfg.use_type == 98 and item_cfg.param2 == self.toushi_info.grade then 		
        return true, item_cfg.id
      end
    end
  end
  return false, nil
end

-- 计算头饰侧边栏红点显示
function TouShiData:ShowTouShiRemind()
	local is_toushi_huanhua = self:CalcHuanHuaRemind() == 1 and true or false
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_TOUSHI)
	if self:IsShowUpgradeBtnRemind() or 
		self:IsShowZiZhiRemind() or 
		self:IsCanLevelSkill() or 
		self:IsShowGrowupRemind() or 
		is_toushi_huanhua or
		is_can_active_jinjie_reward then
		return 1
	end
	return 0
end
-- -- 获得特殊属性更高的
-- function TouShiData:GetGradeAndSpecialAttr()
-- 	local cfg = self:GetTouShiGradeCfgInfoByGrade(self.toushi_info.grade)
-- 	for k, v in ipairs(self.toushi_cfg.grade) do
-- 		if v.mingzhong > cfg.mingzhong then
-- 			return v.grade, v.mingzhong - cfg.mingzhong
-- 		end
-- 	end
-- end

-- 头饰的最大阶数，服务器阶数
function TouShiData:GetTouShiMaxGrade()
	return #self.toushi_grade_cfg
end

function TouShiData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.toushi_info.grade or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.toushi_cfg.grade, cur_grade)
end

function TouShiData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self.toushi_info.special_img_grade_list[index] or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.toushi_cfg.special_image_upgrade, grade, index)
end

-- 技能升级
function TouShiData:CanSkillUpLevelList()
	if nil == self.toushi_info then
		return
	end
	
	local list = {}
	if nil == self.toushi_info.grade or self.toushi_info.grade <= 0 then
		return list
	end

	if nil == self.toushi_info.skill_level_list then
		return list
	end

	for i, j in pairs(self.toushi_skill_cfg) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.toushi_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.toushi_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

-- 是否有技能可以升级
function TouShiData:IsCanLevelSkill()
	local skill_level_list = self:CanSkillUpLevelList()
	if skill_level_list then
		for k,v in pairs(skill_level_list) do
			if v ~= nil then
				return true
			end
		end
	end
	return false
end

-- 获取当前点击的头饰技能的配置 通过技能索引和技能等级来确定一个技能的所有属性
function TouShiData:GetTouShiSkillCfgById(skill_idx, level, toushi_info)
	local toushi_info = toushi_info or self.toushi_info
	local level = level or toushi_info.skill_level_list[skill_idx]

	for k, v in pairs(self.toushi_skill_cfg) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end
	return nil
end

-- 头饰技能配置表
function TouShiData:GetTouShiSkillCfg()
	return self.toushi_skill_cfg
end

-- 使用成长丹增加基础属性
function TouShiData:UseChengZhandDanAddBaseAttr(info)
	local attribute = CommonDataManager.GetAttributteByClass(info)
	local shuxingdan_cfg = AppearanceData.Instance:GetShuXingDanInfo(TouShiShuXingDanCfgType.Type, SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG)
	if nil == shuxingdan_cfg or nil == self.toushi_info or nil == attribute then
		return
	end

	local attr = {}
	for k, v in pairs(attribute) do
		attr[k] = math.ceil((self.toushi_info.chengzhangdan_count * shuxingdan_cfg.attr_per / 10000 + 1) * v)
	end
	return attr
end

--获取当前使用形象image_id
function TouShiData:GetUsedImageId()
	local image_id = 0
	if self.toushi_info and self.toushi_info.used_imageid then
		image_id = self.toushi_info.used_imageid
	end
	return image_id
end

------------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function TouShiData:SuperPowerIsOpenByCfg()
	local other_cfg = self.other_cfg
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function TouShiData:GetStarIsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end

	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return is_show
	end

	local list = self.huanhua_special_cap_add[huanhua_id]
	local need_level = list.huanhua_level
	local cur_level = self:GetHuanHuaGrade(huanhua_id)
	if need_level and cur_level and cur_level >= need_level then
		is_show = true
	end

	return is_show
end

--超级战力是否显示
function TouShiData:IsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end
	
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return is_show
	end

	local level = self:GetHuanHuaGrade(huanhua_id)
	is_show = level > 0
	return is_show
end

--获取单个幻化形象特殊战力配置
function TouShiData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add or nil == self.huanhua_special_cap_add[huanhua_id] then
		return list
	end

	list = self.huanhua_special_cap_add[huanhua_id]
	return list
end

--获取激活超级形象的要求等级
function TouShiData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.huanhua_level then
		level = list.huanhua_level
	end

	return level
end

--特殊战力面板显示数据
function TouShiData:GetSpecialHuanHuaShowData(huanhua_id)
	local data_list = CommonStruct.SpecialHuanHuaTipInfo()
	if nil == huanhua_id then
		return data_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local huanhua_cfg = self:GetSpecialImageCfgInfoByImageId(huanhua_id)
	local image_name = huanhua_cfg and huanhua_cfg.image_name or ""
	local name = image_name or "" 

	local need_level = cfg.huanhua_level or 0
	local cur_level = self:GetHuanHuaGrade(huanhua_id) or 0
	local color = cur_level >= need_level and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
	local cur_level_str = ToColorStr(cur_level, color)
	local desc_str = string.format(Language.Advance.SpecialHuanHuaTips, name, cur_level_str, ToColorStr(need_level, TEXT_COLOR.GREEN_4))

 	data_list.max_hp = cfg.maxhp or 0								-- 生命
	data_list.gong_ji = cfg.gongji or 0 							-- 攻击
	data_list.fang_yu = cfg.fangyu or 0								-- 防御
	data_list.desc = desc_str										-- 描述
	return data_list
end
-----------------------------------------------幻化超级战力结束----------------------------------------------
--当前进阶等级对应的image_id
function TouShiData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetTouShiGradeCfgInfoByGrade()
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function TouShiData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetTouShiGradeCfgInfoByGrade(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade() 
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end

	return power, huanhua_add_per
end

--计算进阶奖励红点
function TouShiData:CalcJinJieRewardRemind()
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_TOUSHI)
	local remind_num = is_can_active_jinjie_reward and 1 or 0
	return remind_num
end

--获取相关总属性值
function TouShiData:GetAttrSum(info)
	local attr = CommonStruct.Attribute()
	if nil == info or nil == info.grade or info.grade <= 0 then
		return attr
	end

	local base_grade_cfg = self:GetTouShiGradeCfgInfoByGrade(info.grade)
	local special_img_attr, is_active_big_target = self:GetSpecialImageAttrSum(info)
	if base_grade_cfg and special_img_attr then
		attr.max_hp = base_grade_cfg.maxhp + special_img_attr.max_hp
		attr.gong_ji = base_grade_cfg.gongji + special_img_attr.gong_ji
		attr.fang_yu = base_grade_cfg.fangyu + special_img_attr.fang_yu
		attr.ming_zhong = base_grade_cfg.mingzhong + special_img_attr.ming_zhong
		attr.shan_bi = base_grade_cfg.shanbi + special_img_attr.shan_bi
		attr.bao_ji = base_grade_cfg.baoji + special_img_attr.bao_ji
		attr.jian_ren = base_grade_cfg.jianren + special_img_attr.jian_ren
	end

	--大目标属性加成
	if is_active_big_target then
		local grade_attr = CommonDataManager.GetAttributteByClass(base_grade_cfg)
		local big_target_add_attr = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(JINJIE_TYPE.JINJIE_TYPE_TOUSHI)
		local big_target_per = big_target_add_attr and big_target_add_attr * 0.0001
		if big_target_per then
			local big_target_add_attr = CommonDataManager.MulAttribute(grade_attr, big_target_per)
			attr = CommonDataManager.AddAttributeAttr(attr, big_target_add_attr)
		end
	end

	--进阶加成
	local active_need_grade = self:GetActiveNeedGrade()
	local cur_grade = info.grade or 1
	if cur_grade >= active_need_grade then
		local percent = self:GetAllAttrPercent()
		local per = percent and percent * 0.01
		if per then
			local add_attr = CommonDataManager.MulAttribute(attr, per)
			attr = CommonDataManager.AddAttributeAttr(attr, add_attr)
		end
	end

	return attr
end

-- 获取已激活特殊形象的总属性
function TouShiData:GetSpecialImageAttrSum(info, flag)
	local sum_attr_list = CommonStruct.Attribute()
	local is_active_big_target = false
	if nil == info then
		return sum_attr_list, is_active_big_target
	end

	local active_flag = info.active_special_image_flag or 0
	local active_flag2 = info.active_special_image_flag2 or 0
	local bit_list = bit:ll2b(active_flag2, active_flag)
	local max_special_count = GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID
	local big_target_img_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_TOUSHI)
	local super_power_is_open = self:SuperPowerIsOpenByCfg()

	for k, v in pairs(bit_list) do
		if v == 1 then
			local cfg = {}
			local grade_list = info.special_img_grade_list
			local grade = grade_list and grade_list[max_special_count - k]
			local cur_grade = grade or 1
			cfg = self:GetHuanHuaCfgInfo(max_special_count - k, cur_grade)
			--是否达成大目标
			if max_special_count - k == big_target_img_id then
				is_active_big_target = true
			end
			--超级战力
			if super_power_is_open then
				local attr_list = self:SuperPowerAttr(max_special_count - k, cur_grade)
				sum_attr_list = CommonDataManager.AddAttributeAttr(attr_list, sum_attr_list)
			end
			
			if cfg and cfg.maxhp then
				sum_attr_list.max_hp = sum_attr_list.max_hp + cfg.maxhp
				sum_attr_list.gong_ji = sum_attr_list.gong_ji + cfg.gongji
				sum_attr_list.fang_yu = sum_attr_list.fang_yu + cfg.fangyu
				sum_attr_list.ming_zhong = sum_attr_list.ming_zhong + cfg.mingzhong
				sum_attr_list.shan_bi = sum_attr_list.shan_bi + cfg.shanbi
				sum_attr_list.bao_ji = sum_attr_list.bao_ji + cfg.baoji
				sum_attr_list.jian_ren = sum_attr_list.jian_ren + cfg.jianren
			end
		end
	end

	return sum_attr_list, is_active_big_target
end

--超级战力属性
function TouShiData:SuperPowerAttr(huanhua_id, cur_grade)
	local attr_list = CommonStruct.Attribute()
	if nil == huanhua_id or nil == cur_grade then
		return attr_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local need_level = cfg and cfg.huanhua_level
	--是否激活
	if nil == need_level or need_level > cur_grade then
		return attr_list
	end

	local super_power_attr = CommonDataManager.GetAttributteByClass(cfg)
	attr_list = CommonDataManager.AddAttributeAttr(attr_list, super_power_attr)

	return attr_list
end

-- 获取特殊形象进阶信息
function TouShiData:GetSpecialImageUpgradeInfo(image_id, grade)
	local image_id = image_id or 1
	local grade = grade or 0
	
	return self.toushi_special_image_upgrade_cfg[image_id][grade]
end

function TouShiData:IsHidden()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.TOUSHI)		--0为不隐藏，1为隐藏
	return flag == 1
end
