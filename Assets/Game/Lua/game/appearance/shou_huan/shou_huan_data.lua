ShouHuanData = ShouHuanData or BaseClass()

ShouHuanShuXingDanCfgType = {
	Type = 106,					-- 手环资质丹类型
}

ShouHuanShuXingDanId = {
	ZiZhiDanId = 22137,			-- 手环资质丹
	ChengZhangDanId = 22146,	-- 手环成长丹
}

function ShouHuanData:__init()
	if ShouHuanData.Instance ~= nil then
		ErrorLog("[ShouHuanData] attempt to create singleton twice!")
		return
	end
	ShouHuanData.Instance = self

	self.shouhuan_cfg = ConfigManager.Instance:GetAutoConfig("upgrade_sys6_auto")

	self.other_cfg = self.shouhuan_cfg.other[1]
	self.shouhuan_grade_cfg = ListToMap(self.shouhuan_cfg.grade, "grade")
	self.shouhuan_image_list_cfg = ListToMap(self.shouhuan_cfg.image_list, "image_id")
	self.shouhuan_special_img_cfg = self.shouhuan_cfg.special_img
	self.shouhuan_special_img_item_cfg = ListToMap(self.shouhuan_cfg.special_img, "item_id")
	self.shouhuan_special_image_upgrade_cfg = ListToMap(self.shouhuan_cfg.image_upgrade, "image_id", "grade")
	self.huanhua_special_cap_add = self.shouhuan_cfg.big_goal_cap_add			--幻化特殊战力加成
	self.shouhuan_skill_cfg = self.shouhuan_cfg.skill

	self.special_grade_max_level = self:CalcSpecialImgMaxLevel()

	RemindManager.Instance:Register(RemindName.ShouHuan, BindTool.Bind(self.IsShowRedPoint, self))
	RemindManager.Instance:Register(RemindName.ShouHuanHuanHua, BindTool.Bind(self.CalcHuanHuaRemind, self))	-- 灵珠幻化红点
end

function ShouHuanData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShouHuan)
	RemindManager.Instance:UnRegister(RemindName.ShouHuanHuanHua)

	ShouHuanData.Instance = nil
end

function ShouHuanData:SetShouHuanInfo(info)
	self.shouhuan_info = info

	self.shouhuan_info.shuxingdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI]			-- 资质丹
	self.shouhuan_info.chengzhangdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG]	-- 成长丹
	self.img_grade_list = info.img_grade_list
	self.active_img_flag_list = bit:uc2b(info.active_img_flag)
end

function ShouHuanData:GetShouHuanInfo()
	return self.shouhuan_info
end

-- 全属性加成所需阶数
function ShouHuanData:GetActiveNeedGrade()
  	return self.other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function ShouHuanData:GetGrade()
	if self.shouhuan_info then
  		return self.shouhuan_info.grade or 0
  	end
  	return 0
end

-- 全属性加成百分比
function ShouHuanData:GetAllAttrPercent()
  	local attr_percent = math.floor(self.other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function ShouHuanData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

--获取对应等级相关数据
function ShouHuanData:GetShouHuanGradeCfgInfoByGrade(grade)
	grade = grade or (self.shouhuan_info and self.shouhuan_info.grade) or 0
	return self.shouhuan_grade_cfg[grade]
end

--获取清空祝福值的最小阶数
function ShouHuanData:GetClearBlessGradeLimit()
	for k, v in ipairs(self.shouhuan_grade_cfg) do
		if v.is_clear_bless == 1 then
			return v.show_grade, v.gradename
		end
	end

	return 0, ""
end

function ShouHuanData:GetShouHuanImageCfgInfoByImageId(image_id)
	return self.shouhuan_image_list_cfg[image_id]
end

function ShouHuanData:GetSpecialImageCfgInfoByImageId(image_id)
	for k, v in pairs(self.shouhuan_special_img_cfg) do 
		if v.image_id == image_id then
			return v
		end
	end
	-- return self.shouhuan_special_img_cfg[image_id]
end

function ShouHuanData:GetSpecialImageCfgInfoByItemId(item_id)
	item_id = item_id or 0
	return self.shouhuan_special_img_item_cfg[item_id]
end

function ShouHuanData:GetSpecialImagesCfg()
	return self.shouhuan_special_img_cfg or {}
end

-- 获取特殊形象进阶信息
function ShouHuanData:GetSpecialImageUpgradeInfo(image_id, grade)
	local image_id = image_id or 1
	local grade = grade or 0
	if self.shouhuan_special_image_upgrade_cfg[image_id] then
		return self.shouhuan_special_image_upgrade_cfg[image_id][grade]
	end
end

function ShouHuanData:GetImageMaxShowGrade()
	local max_info = self.shouhuan_image_list_cfg and self.shouhuan_image_list_cfg[#self.shouhuan_image_list_cfg]
	local max_grade = max_info and max_info.show_grade or 0
	return max_grade or 0
end

--获取对应的资源id
function ShouHuanData:GetResIdByImageId(image_id)
	local image_info = nil

	image_info = self:GetShouHuanImageCfgInfoByImageId(image_id)
	if nil == image_info then
		image_info = self:GetSpecialImageCfgInfoByImageId(image_id)
	end

	if image_info then
		return image_info.res_id
	end

	return 0
end

--计算特殊形象等级上限
function ShouHuanData:CalcSpecialImgMaxLevel()
	local level_limit = 0
	for k, v in pairs(self.shouhuan_special_image_upgrade_cfg) do
		for k2, v2 in pairs(v) do
			if v2.grade > level_limit then
				level_limit = v2.grade
			end
		end
		break
	end

	return level_limit
end

--获取特殊形象等级上限
function ShouHuanData:GetSpecialImgMaxLevel()
	return self.special_grade_max_level
end

--获取对应的幻化image_id是否已使用
function ShouHuanData:GetHuanHuaIdIsUsed(image_id)
	if nil == self.shouhuan_info then
		return false
	end

	return self.shouhuan_info.used_imageid == image_id
end

function ShouHuanData:IsHaveZhiShengDanInGrade()  
  if self.shouhuan_info and next(self.shouhuan_info) then
    local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)	
    for k, v in pairs(zhishengdan_list) do
      local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
      if item_cfg.use_type == 107 and item_cfg.param1 == UPGRADE_TYPE.SHOU_HUAN and item_cfg.param3 == self.shouhuan_info.grade then 		
        return true, item_cfg.id
      end
    end
  end
  return false, nil
end

--获取最多的属性丹数量
function ShouHuanData:GetMaxShuXingDanCount(grade)
	local max_num = 0
	if nil == self.shouhuan_info then
		return max_num
	end

	grade = grade or self.shouhuan_info.grade

	--先获取当前阶数的属性丹最大数量
	local grade_info = self:GetShouHuanGradeCfgInfoByGrade(grade)
	if nil == grade_info then
		return max_num
	end
	max_num = max_num + grade_info.shuxingdan_limit

	--加上幻化形象增加的属性丹数量
	local flag = 0
	for k, v in pairs(self.shouhuan_special_image_upgrade_cfg) do
		if self.active_img_flag_list[v.img_id] == 1 then
			max_num = max_num + v[0].shuxingdan_count
		end
	end

	return max_num
end

--获取可显示的幻化列表
function ShouHuanData:GetHuanHuaCfgList()
	local huanhua_list = nil

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in pairs(self.shouhuan_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			if nil == huanhua_list then
				huanhua_list = {}
			end

			table.insert(huanhua_list, v)
		end
	end

	return huanhua_list
end

function ShouHuanData:CanHuanhuaIndexByImageId(image_id)
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
function ShouHuanData:GetHuanHuaGrade(image_id)
	if nil == self.img_grade_list then
		return 0
	end

	return self.img_grade_list[image_id] or 0
end

function ShouHuanData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.shouhuan_info.grade or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.shouhuan_cfg.grade, cur_grade)
end

function ShouHuanData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self:GetHuanHuaGrade(index) or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.shouhuan_cfg.image_upgrade, grade, index)
end

--获取对应幻化信息
function ShouHuanData:GetHuanHuaCfgInfo(image_id, grade)
	grade = grade or self:GetHuanHuaGrade(image_id)

	if self.shouhuan_special_image_upgrade_cfg[image_id] then
		return self.shouhuan_special_image_upgrade_cfg[image_id][grade]
	end

	return nil
end

-- 获取幻化最大等级
function ShouHuanData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self.shouhuan_cfg.image_upgrade) do
		if v.image_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

--获取对应幻化形象是否已激活
function ShouHuanData:GetHuanHuaIsActiveByImageId(image_id)
	if nil == self.active_img_flag_list then
		return false
	end

	return self.active_img_flag_list[image_id] == 1
end

--计算升级材料是否足够
function ShouHuanData:CalcUpgradeRemind()
	if nil == self.shouhuan_info then
		return 0
	end

	--没有下一阶表示已满阶
	local next_grade_info = self:GetShouHuanGradeCfgInfoByGrade(self.shouhuan_info.grade + 1)
	if nil == next_grade_info then
		return 0
	end

	local grade_info = self:GetShouHuanGradeCfgInfoByGrade(self.shouhuan_info.grade)
	if nil == grade_info then
		return 0
	end

	local item_id = grade_info.upgrade_stuff_id
	local item_id2 = grade_info.upgrade_stuff2_id
	local need_item_num = grade_info.upgrade_stuff_count
	local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
	if need_item_num <= have_item_num then
		--升阶材料足够
		return 1
	end

	return 0
end

--计算幻化形象红点
function ShouHuanData:CalcHuanHuaRemind()
	if nil == self.img_grade_list then
		return 0
	end

	--判断是否有幻化形象可激活或可升级
	local grade_list = nil				--对应资源的等级列表
	local grade_info = nil				--对应等级相关数据
	local img_info = nil				--对应资源相关数据
	local have_num = 0
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(self.img_grade_list) do
		grade_list = self.shouhuan_special_image_upgrade_cfg[k]
		img_info = self:GetSpecialImageCfgInfoByImageId(k)

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

--计算资质丹红点
function ShouHuanData:CalcZiZhiRemind()
	if nil == self.shouhuan_info then
		return 0
	end

	--判断资质升级是否达到上限
	if self.shouhuan_info.shuxingdan_count < self:GetMaxShuXingDanCount() then
		--是否拥有资质丹
	 	local zizhi_info = AppearanceData.Instance:GetZiZhiCfgInfoByType(ZIZHI_TYPE.SHOUHUAN)
	 	if nil == zizhi_info then
	 		return 0
	 	end

	 	if ItemData.Instance:GetItemNumInBagById(zizhi_info.item_id) > 0 then
	 		return 1
	 	end
	end

	return 0
end

function ShouHuanData:IsHidden()
	local is_hidden = false
	if self.shouhuan_info and self.shouhuan_info.is_hidden then				--0为不隐藏，1为隐藏
		is_hidden = self.shouhuan_info.is_hidden == 1
	end
	return is_hidden
end

-- 技能升级
function ShouHuanData:CanSkillUpLevelList()
	if nil == self.shouhuan_info then
		return
	end
	
	local list = {}
	if nil == self.shouhuan_info.grade or self.shouhuan_info.grade <= 0 then
		return list
	end

	if nil == self.shouhuan_info.skill_level_list then
		return list
	end

	for i, j in pairs(self.shouhuan_skill_cfg) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.shouhuan_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.shouhuan_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

-- 使用成长丹增加基础属性
function ShouHuanData:UseChengZhandDanAddBaseAttr(info)
	local attribute = CommonDataManager.GetAttributteByClass(info)
	local shuxingdan_cfg = AppearanceData.Instance:GetShuXingDanInfo(ShouHuanShuXingDanCfgType.Type, SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG)
	if nil == shuxingdan_cfg or nil == self.shouhuan_info or nil == attribute then
		return
	end

	local attr = {}
	for k, v in pairs(attribute) do
		attr[k] = math.ceil((self.shouhuan_info.chengzhangdan_count * shuxingdan_cfg.attr_per / 10000 + 1) * v)
	end
	return attr
end

-- 获取当前等级可使用的最大成长丹数量
function ShouHuanData:GetMaxChengZhangDanCount(grade)
	local max_num = 0
	if nil == self.shouhuan_info then
		return max_num
	end

	grade = grade or self.shouhuan_info.grade 

	local grade_cfg = self:GetShouHuanGradeCfgInfoByGrade(grade)
	if nil == grade_cfg then
		return max_num
	end
	max_num = max_num + grade_cfg.chengzhangdan_limit

	-- 加上幻化形象增加的成长丹数量
	local flag = 0
	for k, v in pairs(self.shouhuan_special_img_cfg) do
		if self.active_img_flag_list[v.img_id] == 1 then
			max_num = max_num + v[0].chengzhangdan_count
		end
	end

	return max_num
end
-- 获得特殊属性更高的
function ShouHuanData:GetGradeAndSpecialAttr()
	local cfg = self:GetShouHuanGradeCfgInfoByGrade(self.shouhuan_info.grade)
	for k, v in ipairs(self.shouhuan_cfg.grade) do
		if v.mingzhong > cfg.mingzhong then
			return v.grade, v.mingzhong - cfg.mingzhong
		end
	end
end

-- 尾焰的最大阶数，服务器阶数
function ShouHuanData:GetShouHuanMaxGrade()
	return #self.shouhuan_grade_cfg
end

-- 根据形象id判断是否是幻化形象
function ShouHuanData:IsHuanHuaImage(image_id)
	for k, v in pairs(self.shouhuan_special_img_cfg) do
		if v.image_id == image_id then
			return true
		end
	end
	return false
end

-- 计算资质丹红点
function ShouHuanData:IsShowZiZhiRemind()
	if self.shouhuan_info then
		if self.shouhuan_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN then
			return false
		end
		if self.shouhuan_info.shuxingdan_count >= self:GetMaxShuXingDanCount(self.shouhuan_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(ShouHuanShuXingDanId.ZiZhiDanId) > 0 then
			return true
		end
	end

	return false
end

-- 计算成长丹按钮红点
function ShouHuanData:IsShowGrowupRemind()
	if self.shouhuan_info then
		if self.shouhuan_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN then
			return false
		end
		if self.shouhuan_info.chengzhangdan_count >= self:GetMaxChengZhangDanCount(self.shouhuan_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(ShouHuanShuXingDanId.ChengZhangDanId) > 0 then
			return true
		end
	end
	return false
end

-- 计算进阶按钮红点
function ShouHuanData:IsShowUpgradeBtnRemind()
	if not self.shouhuan_info or not self.shouhuan_info.grade then
		return false
	end

	local shouhuan_cfg = self:GetShouHuanGradeCfgInfoByGrade(self.shouhuan_info.grade)
	if not shouhuan_cfg  then
		return false
	end

	-- 不清空祝福值时和可进阶时，显示红点
	if shouhuan_cfg.is_clear_bless == APPEARANCE_CLEAR_BLESS.NOT_CLEAR then
		local item_id = shouhuan_cfg.upgrade_stuff_id
		local item_id2 = shouhuan_cfg.upgrade_stuff2_id
		local need_item_num = shouhuan_cfg.upgrade_stuff_count
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
		if have_item_num >= need_item_num then
			return true
		end
	end

	return false
end

-- 获取已激活特殊形象的总属性
function ShouHuanData:GetSpecialImageAttrSum(info)
	local sum_attr_list = CommonStruct.Attribute()
	local is_active_big_target = false
	if nil == info then
		return sum_attr_list, is_active_big_target
	end

	local active_flag = info.active_special_image_flag or 0
	local active_flag2 = info.active_special_image_flag2 or 0
	local bit_list = bit:ll2b(active_flag2, active_flag)
	local max_special_count = GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID
	local big_target_img_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_SHOUHUAN)

	for k, v in pairs(bit_list) do
		if v == 1 then
			local cfg = {}
			local grade_list = info.img_grade_list
			local grade = grade_list and grade_list[max_special_count - k]
			local cur_grade = grade or 1
			cfg = self:GetHuanHuaCfgInfo(max_special_count - k, cur_grade)
			--是否达成大目标
			if max_special_count - k == big_target_img_id then
				is_active_big_target = true
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

-- 侧边栏红点逻辑
function ShouHuanData:IsShowRedPoint()
	if not OpenFunData.Instance:CheckIsHide("shouhuan_jinjie") then
		return 0
	end

	local is_shouhuan_huanhua = self:CalcHuanHuaRemind() == 1 and true or false
	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_SHOUHUAN)
	if self:IsShowGrowupRemind() or 
		self:IsShowZiZhiRemind() or 
		self:IsShowUpgradeBtnRemind() or 
		is_can_active_jinjie_reward or 
		is_shouhuan_huanhua then
		return 1
	end

	local can_upgrade_skill_list = self:CanSkillUpLevelList()
	if can_upgrade_skill_list then
		for i = 1, 3 do 
			if can_upgrade_skill_list[i] ~= nil then
				return 1
			end
		end
	end

	return 0
end

-- 获取当前点击的技能的配置 通过技能索引和技能等级来确定一个技能的所有属性
function ShouHuanData:GetSkillCfgById(skill_idx, level, shouhuan_info)
	local shouhuan_info = shouhuan_info or self.shouhuan_info
	local level = level or shouhuan_info.skill_level_list[skill_idx]

	for k, v in pairs(self.shouhuan_skill_cfg) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end
	return nil
end

-- 技能配置表
function ShouHuanData:GetSkillCfg()
	return self.shouhuan_skill_cfg
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function ShouHuanData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetShouHuanGradeCfgInfoByGrade(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade() 
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end

	return power, huanhua_add_per
end

--获取当前使用形象image_id
function ShouHuanData:GetUsedImageId()
	local image_id = 0
	if self.shouhuan_info and self.shouhuan_info.used_imageid then
		image_id = self.shouhuan_info.used_imageid
	end
	return image_id
end

--当前进阶等级对应的image_id
function ShouHuanData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetShouHuanGradeCfgInfoByGrade()
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

-----------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function ShouHuanData:SuperPowerIsOpenByCfg()
	local other_cfg = self.other_cfg
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function ShouHuanData:GetStarIsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end

	if nil == huanhua_id or nil == self.huanhua_special_cap_add then
		return is_show
	end

	local list = {}
	for k, v in pairs (self.huanhua_special_cap_add) do
		if v.image_id == huanhua_id then
			list = v 
		end
	end
	if list.grade == nil then return is_show end
	-- local list = self.huanhua_special_cap_add[huanhua_id]
	local need_level = list.grade
	local cur_level = self:GetHuanHuaGrade(huanhua_id)
	if need_level and cur_level and cur_level >= need_level then
		is_show = true
	end

	return is_show
end

--超级战力是否显示
function ShouHuanData:IsShowSuperPower(huanhua_id)
	local is_show = false
	local is_open = self:SuperPowerIsOpenByCfg()
	if not is_open then
		return is_show
	end
	
	if nil == huanhua_id or nil == self.huanhua_special_cap_add then
		return is_show
	end

	local list = {}
	for k, v in pairs (self.huanhua_special_cap_add) do
		if v.image_id == huanhua_id then
			list = v 
		end
	end
	if list.grade == nil then 
		return is_show 
	end
	local level = self:GetHuanHuaGrade(huanhua_id)
	is_show = level > 0
	return is_show
end

--获取单个幻化形象特殊战力配置
function ShouHuanData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local list = {}
	if nil == huanhua_id or nil == self.huanhua_special_cap_add then
		return list
	end

	-- list = self.huanhua_special_cap_add[huanhua_id]
	for k, v in pairs (self.huanhua_special_cap_add) do
		if v.image_id == huanhua_id then
			list = v 
		end
	end
	return list
end

--获取激活超级形象的要求等级
function ShouHuanData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.grade then
		level = list.grade
	end

	return level
end

--特殊战力面板显示数据
function ShouHuanData:GetSpecialHuanHuaShowData(huanhua_id)
	local data_list = CommonStruct.SpecialHuanHuaTipInfo()
	if nil == huanhua_id then
		return data_list
	end

	local cfg = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	local huanhua_cfg = self:GetSpecialImageCfgInfoByImageId(huanhua_id)
	local image_name = huanhua_cfg and huanhua_cfg.image_name or ""
	local name = image_name or "" 

	local need_level = cfg.grade or 0
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

function ShouHuanData:IsHidden()
	local flag = SettingData.Instance:GetAdvanceTypeHideFlag(ADVANCE_HIDE_TYPE.SHOUHUAN)		--0为不隐藏，1为隐藏
	return flag == 1
end