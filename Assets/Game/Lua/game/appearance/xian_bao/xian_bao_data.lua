XianBaoData = XianBaoData or BaseClass()

XianBaoShuXingDanCfgType = {
	Type = 101,					-- 仙宝资质丹类型
}

XianBaoShuXingDanId = {
	ZiZhiDanId = 22132,			-- 仙宝资质丹
	ChengZhangDanId = 22141,	-- 仙宝成长丹
}

function XianBaoData:__init()
	if XianBaoData.Instance ~= nil then
		ErrorLog("[XianBaoData] attempt to create singleton twice!")
		return
	end
	XianBaoData.Instance = self

	self.xianbao_cfg = ConfigManager.Instance:GetAutoConfig("upgrade_sys1_auto")

	self.other_cfg = self.xianbao_cfg.other[1]
	self.xianbao_grade_cfg = ListToMap(self.xianbao_cfg.grade, "grade")
	self.xianbao_image_list_cfg = ListToMap(self.xianbao_cfg.image_list, "image_id")
	self.xianbao_special_img_cfg = self.xianbao_cfg.special_img
	self.xianbao_special_image_upgrade_cfg = ListToMap(self.xianbao_cfg.image_upgrade, "image_id", "grade")
	self.huanhua_special_cap_add = self.xianbao_cfg.big_goal_cap_add			--幻化特殊战力加成
	self.xianbao_skill_cfg = self.xianbao_cfg.skill

	self.special_grade_max_level = self:CalcSpecialImgMaxLevel()
	RemindManager.Instance:Register(RemindName.XianBao, BindTool.Bind(self.IsShowRedPoint, self))
	RemindManager.Instance:Register(RemindName.XianBaoHuanHua, BindTool.Bind(self.CalcHuanHuaRemind, self))	-- 仙宝幻化红点
end

function XianBaoData:__delete()
	RemindManager.Instance:UnRegister(RemindName.XianBao)
	RemindManager.Instance:UnRegister(RemindName.XianBaoHuanHua)

	XianBaoData.Instance = nil
end

function XianBaoData:SetXianBaoInfo(info)
	self.xianbao_info = info

	self.xianbao_info.shuxingdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_ZIZHI]			-- 资质丹
	self.xianbao_info.chengzhangdan_count = info.shuxingdan_list[SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG]	-- 成长丹
	self.img_grade_list = info.img_grade_list
	self.active_img_flag_list = bit:uc2b(info.active_img_flag)
end

function XianBaoData:GetXianBaoInfo()
	return self.xianbao_info
end

-- 全属性加成所需阶数
function XianBaoData:GetActiveNeedGrade()
  	return self.other_cfg.extra_attrs_per_grade or 1
end

-- 当前阶数
function XianBaoData:GetGrade()
	if self.xianbao_info then
  		return self.xianbao_info.grade or 0
  	end
  	return 0
end

-- 全属性加成百分比
function XianBaoData:GetAllAttrPercent()
  	local attr_percent = math.floor(self.other_cfg.extra_attrs_per / 100) 	-- 万分比转为百分比
  	return attr_percent or 0
end

--获取对应等级相关数据
function XianBaoData:GetXianBaoGradeCfgInfoByGrade(grade)
	grade = grade or (self.xianbao_info and self.xianbao_info.grade) or 0
	return self.xianbao_grade_cfg[grade]
end

-- 根据当前属性的战力，计算全属性百分比的战力加成
function XianBaoData:CalculateAllAttrCap(cap)
	if self:GetGrade() >= self:GetActiveNeedGrade() then
		return math.floor(cap * self:GetAllAttrPercent() * 0.01)
	end
	return 0
end

--获取清空祝福值的最小阶数
function XianBaoData:GetClearBlessGradeLimit()
	for k, v in ipairs(self.xianbao_grade_cfg) do
		if v.is_clear_bless == 1 then
			return v.show_grade, v.gradename
		end
	end

	return 0, ""
end

function XianBaoData:GetXianBaoImageCfgInfoByImageId(image_id)
	return self.xianbao_image_list_cfg[image_id]
end

function XianBaoData:GetSpecialImageCfgInfoByImageId(image_id)
	for k, v in pairs(self.xianbao_special_img_cfg) do 
		if v.image_id == image_id then
			return v
		end
	end
	-- return self.xianbao_special_img_cfg[image_id]
end

function XianBaoData:GetSpecialImagesCfg()
	return self.xianbao_special_img_cfg or {}
end

-- 获取特殊形象进阶信息
function XianBaoData:GetSpecialImageUpgradeInfo(image_id, grade)
	local image_id = image_id or 1
	local grade = grade or 0
	
	return self.xianbao_special_image_upgrade_cfg[image_id][grade]
end


function XianBaoData:GetImageMaxShowGrade()
	local max_info = self.xianbao_image_list_cfg and self.xianbao_image_list_cfg[#self.xianbao_image_list_cfg]
	local max_grade = max_info and max_info.show_grade or 0
	return max_grade or 0
end

--得到当前使用image_id配置
function XianBaoData:GetCurUseImageCfgByImageId(image_id)
	local image_info = {}
	if nil == image_id then
		return image_info
	end

	image_info = self:GetXianBaoImageCfgInfoByImageId(image_id)
	if nil == image_info then
		image_info = self:GetSpecialImageCfgInfoByImageId(image_id)
	end

	return image_info
end

--获取对应的资源id
function XianBaoData:GetResIdByImageId(image_id)
	local res_id = 0
	local image_info = self:GetCurUseImageCfgByImageId(image_id)
	if image_info and image_info.res_id then
		res_id = image_info.res_id
	end

	return res_id
end
--计算特殊形象等级上限
function XianBaoData:CalcSpecialImgMaxLevel()
	local level_limit = 0
	for k, v in pairs(self.xianbao_special_image_upgrade_cfg) do
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
function XianBaoData:GetSpecialImgMaxLevel()
	return self.special_grade_max_level
end

--获取对应的幻化image_id是否已使用
function XianBaoData:GetHuanHuaIdIsUsed(image_id)
	if nil == self.xianbao_info then
		return false
	end
	return self.xianbao_info.used_imageid == image_id
end

function XianBaoData:IsHaveZhiShengDanInGrade() 
  if self.xianbao_info and next(self.xianbao_info) then
    local zhishengdan_list = ItemData.Instance:GetItemListByBigType(GameEnum.ITEM_BIGTYPE_EXPENSE)	
    for k, v in pairs(zhishengdan_list) do
      local item_cfg, bag_type = ItemData.Instance:GetItemConfig(v.item_id)
      if item_cfg.use_type == 107 and item_cfg.param1 == UPGRADE_TYPE.XIAN_BAO and item_cfg.param3 == self.xianbao_info.grade then 		
        return true, item_cfg.id
      end
    end
  end
  return false, nil
end

--获取当前使用形象image_id
function XianBaoData:GetUsedImageId()
	local image_id = 0
	if self.xianbao_info and self.xianbao_info.used_imageid then
		image_id = self.xianbao_info.used_imageid
	end
	return image_id
end

--获取最多的属性丹数量
function XianBaoData:GetMaxShuXingDanCount(grade)
	local max_num = 0
	if nil == self.xianbao_info then
		return max_num
	end

	grade = grade or self.xianbao_info.grade

	--先获取当前阶数的属性丹最大数量
	local grade_info = self:GetXianBaoGradeCfgInfoByGrade(grade)
	if nil == grade_info then
		return max_num
	end
	max_num = max_num + grade_info.shuxingdan_limit

	--加上幻化形象增加的属性丹数量
	local flag = 0
	for k, v in pairs(self.xianbao_special_image_upgrade_cfg) do
		if self.active_img_flag_list[v.img_id] == 1 then
			max_num = max_num + v[0].shuxingdan_count
		end
	end

	return max_num
end

--获取可显示的幻化列表
function XianBaoData:GetHuanHuaCfgList()
	local huanhua_list = nil

	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	for _, v in pairs(self.xianbao_special_img_cfg) do
		if main_vo.level >= v.lvl and open_server_day >= v.open_day then
			if nil == huanhua_list then
				huanhua_list = {}
			end

			table.insert(huanhua_list, v)
		end
	end

	return huanhua_list
end

function XianBaoData:CanHuanhuaIndexByImageId(image_id)
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
function XianBaoData:GetHuanHuaGrade(image_id)
	if nil == self.img_grade_list then
		return 0
	end

	return self.img_grade_list[image_id] or 0
end

--获取对应幻化信息
function XianBaoData:GetHuanHuaCfgInfo(image_id, grade)
	grade = grade or self:GetHuanHuaGrade(image_id)

	if self.xianbao_special_image_upgrade_cfg[image_id] then
		return self.xianbao_special_image_upgrade_cfg[image_id][grade]
	end

	return nil
end

-- 获取幻化最大等级
function XianBaoData:GetSpecialImageMaxUpLevelById(image_id)
	if not image_id then return 0 end
	local max_level = 0

	for k, v in pairs(self.xianbao_cfg.image_upgrade) do
		if v.image_id == image_id and v.grade > 0 then
			max_level = max_level + 1
		end
	end
	return max_level
end

--获取对应幻化形象是否已激活
function XianBaoData:GetHuanHuaIsActiveByImageId(image_id)
	if nil == self.active_img_flag_list then
		return false
	end

	return self.active_img_flag_list[image_id] == 1
end

--计算幻化形象红点
function XianBaoData:CalcHuanHuaRemind()
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
		grade_list = self.xianbao_special_image_upgrade_cfg[k]
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


-- 计算资质丹红点
function XianBaoData:IsShowZiZhiRemind()
	if self.xianbao_info then
		if self.xianbao_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.ZIZHIDAN then
			return false
		end
		if self.xianbao_info.shuxingdan_count >= self:GetMaxShuXingDanCount(self.xianbao_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(XianBaoShuXingDanId.ZiZhiDanId) > 0 then
			return true
		end
	end

	return false
end

-- 计算成长丹按钮红点
function XianBaoData:IsShowGrowupRemind()
	if self.xianbao_info then
		if self.xianbao_info.grade <= APPEARANCE_SHUXINGDAN_LIMIT.CHENGZHANGDAN then
			return false
		end
		if self.xianbao_info.chengzhangdan_count >= self:GetMaxChengZhangDanCount(self.xianbao_info.grade) then
			return false
		end
		if ItemData.Instance:GetItemNumInBagById(XianBaoShuXingDanId.ChengZhangDanId) > 0 then
			return true
		end
	end
	return false
end

-- 侧边栏红点逻辑
function XianBaoData:IsShowRedPoint()
	if not OpenFunData.Instance:CheckIsHide("xianbao_jinjie") then
		return 0
	end

	local is_can_active_jinjie_reward = JinJieRewardData.Instance:SystemIsShowRedPoint(JINJIE_TYPE.JINJIE_TYPE_XIANBAO)
	local is_xianbao_huanhua = self:CalcHuanHuaRemind() == 1 and true or false
	if self:IsShowGrowupRemind() or 
		self:IsShowZiZhiRemind() or 
		self:IsShowUpgradeBtnRemind() or
		is_can_active_jinjie_reward or
		is_xianbao_huanhua then
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

-- 计算进阶按钮红点
function XianBaoData:IsShowUpgradeBtnRemind()
	if not self.xianbao_info or not self.xianbao_info.grade then
		return false
	end

	local xiaobao_cfg = self:GetXianBaoGradeCfgInfoByGrade(self.xianbao_info.grade)
	if not xiaobao_cfg  then
		return false
	end

	-- 不清空祝福值时和可进阶时，显示红点
	if xiaobao_cfg.is_clear_bless == APPEARANCE_CLEAR_BLESS.NOT_CLEAR then
		local item_id = xiaobao_cfg.upgrade_stuff_id
		local item_id2 = xiaobao_cfg.upgrade_stuff2_id
		local need_item_num = xiaobao_cfg.upgrade_stuff_count
		local have_item_num = ItemData.Instance:GetItemNumInBagById(item_id) + ItemData.Instance:GetItemNumInBagById(item_id2)
		if have_item_num >= need_item_num then
			return true
		end
	end

	return false
end

--当前进阶等级对应的image_id
function XianBaoData:GetCurGradeImageId()
	local image_id = 0
	local cfg = self:GetXianBaoGradeCfgInfoByGrade()
	if cfg then
		image_id = cfg.image_id or 0
	end

	return image_id
end

--当前等级基础战力 power  额外属性加成 huanhua_add_per
function XianBaoData:GetCurGradeBaseFightPowerAndAddPer()
	local power = 0
	local huanhua_add_per = 0

	local grade = self:GetGrade()
	local cur_grade = grade == 0 and 1 or grade
	local attr_cfg = self:GetXianBaoGradeCfgInfoByGrade(cur_grade)
	local attr = CommonDataManager.GetAttributteByClass(attr_cfg)
	power = CommonDataManager.GetCapabilityCalculation(attr)

	local active_add_per_need_level = self:GetActiveNeedGrade() 
	if grade >= active_add_per_need_level then
		huanhua_add_per = self:GetAllAttrPercent()
	end

	return power, huanhua_add_per
end
-- 获得特殊属性更高的
function XianBaoData:GetGradeAndSpecialAttr()
	local cfg = self:GetXianBaoGradeCfgInfoByGrade(self.xianbao_info.grade)
	for k, v in ipairs(self.xianbao_cfg.grade) do
		if v.baoji > cfg.baoji then
			return v.grade, v.baoji - cfg.baoji
		end
	end
end
--获取相关总属性值
function XianBaoData:GetAttrSum(info)
	local attr = CommonStruct.Attribute()
	if nil == info or nil == info.grade or info.grade <= 0 then
		return attr
	end

	local base_grade_cfg = self:GetXianBaoGradeCfgInfoByGrade(info.grade)
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
		local big_target_add_attr = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(JINJIE_TYPE.JINJIE_TYPE_XIANBAO)
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
function XianBaoData:GetSpecialImageAttrSum(info)
	local sum_attr_list = CommonStruct.Attribute()
	local is_active_big_target = false
	if nil == info then
		return sum_attr_list, is_active_big_target
	end

	local active_flag = info.active_special_image_flag or 0
	local active_flag2 = info.active_special_image_flag2 or 0
	local bit_list = bit:ll2b(active_flag2, active_flag)
	local max_special_count = GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID
	local big_target_img_id = JinJieRewardData.Instance:GetSingleRewardCfgParam0(JINJIE_TYPE.JINJIE_TYPE_XIANBAO)

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

-- 获取当前等级可使用的最大成长丹数量
function XianBaoData:GetMaxChengZhangDanCount(grade)
	local max_num = 0
	if nil == self.xianbao_info then
		return max_num
	end

	grade = grade or self.xianbao_info.grade 

	local grade_cfg = self:GetXianBaoGradeCfgInfoByGrade(grade)
	if nil == grade_cfg then
		return max_num
	end
	max_num = max_num + grade_cfg.chengzhangdan_limit

	-- 加上幻化形象增加的成长丹数量
	local flag = 0
	for k, v in pairs(self.xianbao_special_img_cfg) do
		if self.active_img_flag_list[v.img_id] == 1 then
			max_num = max_num + v[0].chengzhangdan_count
		end
	end

	return max_num
end

-- 仙宝的最大阶数，服务器阶数
function XianBaoData:GetXianBaoMaxGrade()
	return #self.xianbao_grade_cfg
end

-- 根据形象id判断是否是幻化形象
function XianBaoData:IsHuanHuaImage(image_id)
	for k, v in pairs(self.xianbao_special_img_cfg) do
		if v.image_id == image_id then
			return true
		end
	end
	return false
end

-- 技能升级
function XianBaoData:CanSkillUpLevelList()
	if nil == self.xianbao_info then
		return
	end
	
	local list = {}
	if nil == self.xianbao_info.grade or self.xianbao_info.grade <= 0 then
		return list
	end

	if nil == self.xianbao_info.skill_level_list then
		return list
	end

	for i, j in pairs(self.xianbao_skill_cfg) do
		if j.uplevel_stuff_num <= ItemData.Instance:GetItemNumInBagById(j.uplevel_stuff_id)
			and self.xianbao_info.skill_level_list[j.skill_idx] == (j.skill_level - 1)
			and j.grade <= self.xianbao_info.grade and j.skill_type ~= 0 then
			list[j.skill_idx] = j.skill_idx
		end
	end
	return list
end

-- 使用成长丹增加基础属性
function XianBaoData:UseChengZhandDanAddBaseAttr(info)
	local attribute = CommonDataManager.GetAttributteByClass(info)
	local shuxingdan_cfg = AppearanceData.Instance:GetShuXingDanInfo(XianBaoShuXingDanCfgType.Type, SHUXINGDAN_SLOT_TYPE.SHUXINGDAN_SLOT_TYPE_CHENGZHANG)
	if nil == shuxingdan_cfg or nil == self.xianbao_info or nil == attribute then
		return
	end

	local attr = {}
	for k, v in pairs(attribute) do
		attr[k] = math.ceil((self.xianbao_info.chengzhangdan_count * shuxingdan_cfg.attr_per / 10000 + 1) * v)
	end
	return attr
end

-- 获取当前点击的技能的配置 通过技能索引和技能等级来确定一个技能的所有属性
function XianBaoData:GetSkillCfgById(skill_idx, level, xianbao_info)
	local xianbao_info = xianbao_info or self.xianbao_info
	local level = level or xianbao_info.skill_level_list[skill_idx]

	for k, v in pairs(self.xianbao_skill_cfg) do
		if v.skill_idx == skill_idx and v.skill_level == level then
			return v
		end
	end
	return nil
end

-- 技能配置表
function XianBaoData:GetSkillCfg()
	return self.xianbao_skill_cfg
end

function XianBaoData:GetSpecialAttrActiveType(cur_grade)
	cur_grade = cur_grade or self.xianbao_info.grade or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.xianbao_cfg.grade, cur_grade)
end

function XianBaoData:GetHuanHuaSpecialAttrActiveType(grade, index)
	local grade = grade or self:GetHuanHuaGrade(index) or 0
	return AppearanceData.Instance:GetSpecialAttrActiveType(self.xianbao_cfg.image_upgrade, grade, index)
end

-----------------------------------------------幻化超级战力-------------------------------------------------
--获取配置判断超级战力是否开启 0/1 不开启/开启
function XianBaoData:SuperPowerIsOpenByCfg()
	local other_cfg = self.other_cfg
	local open_flag = other_cfg and other_cfg.is_open_special_cap_add
	local is_open = false
	if open_flag then
		is_open = open_flag == 1
	end

	return is_open
end

--特殊星星是否显示
function XianBaoData:GetStarIsShowSuperPower(huanhua_id)
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
function XianBaoData:IsShowSuperPower(huanhua_id)
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
function XianBaoData:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
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
function XianBaoData:GetActiveSuperPowerNeedLevel(huanhua_id)
	local level = 0
	local list = self:GetSingleHuanHuaSpecialCapAddList(huanhua_id)
	if list and list.grade then
		level = list.grade
	end

	return level
end

--特殊战力面板显示数据
function XianBaoData:GetSpecialHuanHuaShowData(huanhua_id)
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
