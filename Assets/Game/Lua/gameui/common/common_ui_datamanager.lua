CommonDataManager = CommonDataManager or {}

-- 匹配阶数（文字）
CommonDataManager.DAXIE =  { [0] = "零", "十", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
CommonDataManager.FANTI =  { [0] = "零", "拾", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" }

CommonDataManager.attrview_t = {{"hp", "max_hp"}, {"gongji", "gong_ji"}, {"fangyu", "fang_yu"}, {"mingzhong", "ming_zhong"}, {"shanbi", "shan_bi"}, {"baoji", "bao_ji"}, {"jianren", "jian_ren"}}

CommonDataManager.suit_att_t = {{"maxhp"}, {"gongji"}, {"fangyu"}, {"mingzhong"}, {"shanbi"}, {"baoji"}, {"jianren"}, {"maxhp_attr"}, {"gongji_attr"}, {"fangyu_attr"}, {"mingzhong_attr"}, {"shanbi_attr"}, {"jianren_attr"}, {"baoji_attr"}}

function CommonDataManager.GetDaXie(num, type)
	if nil == num or num < 0 or num >= 100 then
		return ""
	end
	local result = ""
	local index1 = num
	local index2 = -1
	if 10 == num then
		index1 = 0
	elseif num > 10 then
		index1 = math.floor(num / 10)
		index1 = (1 == index1) and 0 or index1
		index2 = num % 10
	elseif num == 0 then
		index1 = -1
	end

	local table = {}
	if nil == type then
		table = CommonDataManager.DAXIE
	else
		table = CommonDataManager.FANTI
	end

	result = table[index1 + 1]
	if math.floor(num / 10) > 1 and index2 ~= 0 then
		result = result .. table[1]
	end
	if index2 > -1 then
		result = result .. table[index2 + 1]
	end

	return result
end

--转换财富
function CommonDataManager.ConverMoney(value)
	value = tonumber(value)
	if value >= 100000 and value < 100000000 then
		local result = math.floor(value / 10000) .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 100000000) .. Language.Common.Yi
		return result
	end
	return value
end

-- 保留两位小数点
function CommonDataManager.ConverMoney2(value)
	value = tonumber(value)
	if value >= 100000 and value < 100000000 then
		local result =  (math.floor(value / 100) / 100) .. Language.Common.Wan
		return result
	end
	if value >= 100000000 and value < 1000000000000 then
		local result = (math.floor(value / 1000000) / 100) .. Language.Common.Yi
		return result
	end

	if value >= 1000000000000 then
		local result = (math.floor(value / 10000000000) / 100) .. Language.Common.WanYi
		return result
	end
	return value
end

--转换
function CommonDataManager.ConverNum(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 1000)/10 .. Language.Common.Wan
		return result
	end

	if value >= 100000000 and value < 1000000000000 then
		local result = math.floor(value / 10000000)/10 .. Language.Common.Yi
		return result
	end

	if value >= 1000000000000 then
		local result = math.floor(value / 100000000000)/10 .. Language.Common.WanYi
		return result
	end
	return value
end

--转换经验
function CommonDataManager.ConverExp(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = string.format("%.2f", value / 10000) .. Language.Common.Wan
		return result
	end
	
	if value >= 100000000 and value < 1000000000000 then
		local result = string.format("%.2f", value / 100000000)
		local result1 = CommonDataManager.ConverExp(result)
		return result1 .. Language.Common.Yi
	end

	if value >= 1000000000000 then
		local result = string.format("%.2f", value / 1000000000000)
		local result1 = CommonDataManager.ConverExp(result)
		return result1 .. Language.Common.WanYi
	end
	return value
end

-- 不保留小数点
function CommonDataManager.ConverExp2(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 10000) .. Language.Common.Wan
		return result
	end
	
	if value >= 100000000 and value < 1000000000000 then
		local result = math.floor(value / 100000000)
		local result1 = CommonDataManager.ConverExp(result)
		return result1 .. Language.Common.Yi
	end

	if value >= 1000000000000 then
		local result = math.floor(value / 1000000000000)
		local result1 = CommonDataManager.ConverExp(result)
		return result1 .. Language.Common.WanYi
	end
	return value
end

-- 战力值 
-- is_next 是否下一未获得属性（默认 false 可不传）
-- own_attr 下一属性中已拥有部分属性的（当前级的属性）
-- 如果要计算一个系统某个等级的战力，或者下一级的战力
-- 1.把我这个系统当前已经获得的属性给清了，2.重新再加上这个等级的属性，分别计算战力后相减。（已获得这部分属性的，一些升级进阶系统）
-- other_role_attr 其他玩家的人物属性

function CommonDataManager.GetCapability(value, is_next, own_attr, other_role_attr)
	value = CommonDataManager.GetAttributteByClass(value)
	
	local cap_a, cap_b = 0, 0
	local cap_tatol = 0
	if other_role_attr then
		cap_a = CommonDataManager.GetCapabilityACalculation(value)
		cap_b = CommonDataManager.GetCapabilityBCalculation(value, other_role_attr)
		local skill_cap_per = other_role_attr.skill_cap_per * 0.0001 + 1
		cap_tatol = (cap_a + cap_b) * skill_cap_per * 0.0001
	else
		local main_role_attr = CommonDataManager.GetMainRoleAttr()
		if is_next then
			own_attr = CommonDataManager.GetAttributteByClass(own_attr)
			local less_attr = CommonDataManager.LerpAttributeAttr(value, own_attr)
			return CommonDataManager.GetCapabilityCalculation(less_attr)
		else
			cap_a = CommonDataManager.GetCapabilityACalculation(value)
			cap_b = CommonDataManager.GetCapabilityBCalculation(value, main_role_attr)
			-- local skill_cap_per = main_role_attr.skill_cap_per * 0.0001 + 1
			-- cap_tatol = (cap_a + cap_b) * skill_cap_per
			cap_tatol = cap_a + cap_b
		end
	end

	return math.floor(cap_tatol)
end

-- 获取激活的战力
-- 比如说激活某个称号，某个特殊形象激活，这种增加多少战力 (还未获得这部分属性的)
function CommonDataManager.GetCapabilityIncrease(value)
	value = CommonDataManager.GetAttributteByClass(value)

	local main_role_attr = CommonDataManager.GetMainRoleAttr()
	local cap_a, cap_b = 0, 0
	cap_a = CommonDataManager.GetCapabilityACalculation(value)
	cap_b = CommonDataManager.GetCapabilityBCalculation(value, main_role_attr)
	local skill_cap_per = main_role_attr.skill_cap_per * 0.0001 + 1
	return math.floor((cap_a + cap_b) * skill_cap_per)
end

function CommonDataManager.GetMainRoleAttr()
	local attribute = CommonStruct.Attribute()
	local data = PlayerData.Instance and PlayerData.Instance:GetRoleVo() or {}
	attribute.gong_ji = data.base_gongji or 0
	attribute.max_hp = data.base_max_hp or 0
	attribute.fang_yu = data.base_fangyu or 0
	attribute.ming_zhong = data.base_mingzhong or 0
	attribute.shan_bi = data.base_shanbi or 0
	attribute.bao_ji = data.base_baoji or 0
	attribute.jian_ren = data.base_jianren or 0
	attribute.per_jingzhun = data.base_per_jingzhun or 0
	attribute.per_baoji = data.base_per_baoji or 0
	attribute.per_kang_bao = data.base_per_kangbao or 0
	attribute.per_mianshang = data.base_per_mianshang or 0
	attribute.per_pofang = data.base_per_pofang or 0
	attribute.goddess_gongji = data.base_fujia_shanghai or 0
	attribute.dikang_shanghai = data.base_dikang_shanghai or 0
	attribute.constant_zengshang = data.base_constant_zengshang or 0
	attribute.constant_mianshang = data.base_constant_mianshang or 0
	attribute.huixinyiji = data.base_huixinyiji or 0
	attribute.huixinyiji_hurt_per = data.base_huixinyiji_hurt_per or 0
	attribute.pvp_jianshang = data.pvp_jianshang or 0
	attribute.pvp_zengshang = data.pvp_zengshang or 0
	attribute.pve_jianshang = data.pve_jianshang or 0
	attribute.pve_zengshang = data.pve_zengshang or 0
	attribute.per_baoji_hurt = data.base_per_baoji_hurt or 0
	attribute.per_kang_bao_hurt = data.base_per_kangbao_hurt or 0
	attribute.zhufuyiji_per = data.base_zhufuyiji_per or 0
	attribute.gedang_per = data.base_gedang_per or 0
	attribute.gedang_dikang_per = data.base_gedang_dikang_per or 0
	attribute.gedang_jianshang = data.base_gedang_jianshang or 0
	attribute.skill_zengshang = data.base_skill_zengshang or 0
	attribute.skill_jianshang = data.base_skill_jianshang or 0
	attribute.mingzhong_per = data.base_mingzhong_per or 0
	attribute.shanbi_per = data.base_shanbi_per or 0
	attribute.skill_cap_per = data.skill_cap_per or 0

	return attribute
end

--[[
战力 =  (战力A + 战力B) * （1 + 技能1 + 技能2 + … + 技能N)
]]

-- 战力值计算 外部调用CommonDataManager.GetCapability
-- value必须为格式化后的table
function CommonDataManager.GetCapabilityCalculation(value)
	value = CommonDataManager.GetAttributteByClass(value)
	return math.floor(
		(math.floor(value.max_hp or value.maxhp or 0) * 0.1
		+ math.floor(value.gong_ji or value.gongji or 0) * 2
		+ math.floor(value.fang_yu or value.fangyu or 0) * 2
		+ math.floor(value.ming_zhong or value.mingzhong or 0) * 2
		+ math.floor(value.shan_bi or value.shanbi or 0) * 2
		+ math.floor(value.bao_ji or value.baoji or 0) * 2
		+ math.floor(value.jian_ren or value.jianren or 0) * 2
		+ math.floor(value.goddess_gongji or value.xiannv_gongji or value.fujia_shanghai or 0) * 2.5
		+ math.floor(value.dikang_shanghai or 0) * 2.5
		)
	)
end

--战力A =  生命 * 0.1 + 攻击 * 2 + 防御 * 2+ 命中 * 2 + 闪避 * 2 + 暴击 * 2 + 抗暴 * 2 + 仙女攻击（附加伤害） * 2.5 + 抵抗伤害 * 2.5
function CommonDataManager.GetCapabilityACalculation(value)
	return CommonDataManager.GetCapabilityCalculation(value)
end
--[[
战力B = CommonDataManager.GetCapabilityCalculation(人物属性) / 3 *（
	  技能增伤 * 0.4
	+ 技能减伤 * 0.4
	+ 祝福一击 * 0.2
	+ 命中几率 
	+ 闪避几率 
	+ 暴击几率 * 0.5
	+ 抗暴几率 * 0.5 
	+ 暴击伤害 * 0.5 
	+ 暴击抵抗 * 0.5 
	+ 会心几率 * 0.2 
	+ 会心伤害 * 0.2 
	+ 格挡几率 * 0.3 
	+ 格挡减伤 * 0.4 
	+ 伤害加成 
	+ 伤害减免 
	+ PVE伤害加成 * 0.5 
	+ PVP伤害加成 * 0.5 
	+ PVP伤害减免 * 0.5
	+ 破甲几率 * 0.5）
]]
function CommonDataManager.GetCapabilityBCalculation(value, role_attr)
	value = CommonDataManager.GetAttributteByClass(value)
	return math.floor(
		CommonDataManager.GetCapabilityCalculation(role_attr) / 3 * (
		(math.floor(value.skill_zengshang) * 0.4
		+ math.floor(value.skill_jianshang) * 0.4
		+ math.floor(value.zhufuyiji_per) * 0.2
		+ math.floor(value.mingzhong_per)
		+ math.floor(value.shanbi_per)
		+ math.floor(value.per_baoji) * 0.5
		+ math.floor(value.per_kang_bao_hurt) * 0.5
		+ math.floor(value.per_baoji_hurt) * 0.5
		+ math.floor(value.per_kang_bao) * 0.5
		+ math.floor(value.huixinyiji) * 0.2
		+ math.floor(value.huixinyiji_hurt_per) * 0.2
		+ math.floor(value.gedang_per) * 0.3
		+ math.floor(value.gedang_jianshang) * 0.4
		+ math.floor(value.per_pofang)
		+ math.floor(value.per_mianshang)
		+ math.floor(value.pve_zengshang) * 0.5
		+ math.floor(value.pvp_zengshang) * 0.5
		+ math.floor(value.pvp_jianshang) * 0.5
		+ math.floor(value.per_jingzhun) * 0.5
		) * 0.0001)
	)
end

-- 属性显示: 大于等于6位 =》XX万 速度显示百分比:15%
function CommonDataManager.SwitchAttri(attr)
	local attr_tab = CommonDataManager.GetAttributteByClass(attr)
	-- if attr_tab.move_speed >= 100000 then
	-- 	print_warning("move_speed >= 100000")
	-- 	return attr_tab
	-- end
	-- for k,v in pairs(attr_tab) do
	-- 	if nil ~= v and v >= 100000 then
	-- 		local value = tonumber(v)
	-- 		attr_tab[k] = math.floor(value / 10000) .. Language.Common.Wan
	-- 	end
	-- end

	if attr_tab.move_speed then
		attr_tab.move_speed = math.floor(attr_tab.move_speed / COMMON_CONSTS.DEFAULT_SPEED * 100) .. "%"
	end

	return attr_tab
end

-- 两个属性相加
function CommonDataManager.AddAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute1.gong_ji + attribute2.gong_ji
	m_attribute.max_hp = attribute1.max_hp + attribute2.max_hp
	m_attribute.fang_yu = attribute1.fang_yu + attribute2.fang_yu
	m_attribute.ming_zhong = attribute1.ming_zhong + attribute2.ming_zhong
	m_attribute.shan_bi = attribute1.shan_bi + attribute2.shan_bi
	m_attribute.bao_ji = attribute1.bao_ji + attribute2.bao_ji
	m_attribute.jian_ren = attribute1.jian_ren + attribute2.jian_ren
	m_attribute.per_jingzhun = attribute2.per_jingzhun + attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji + attribute1.per_baoji
	m_attribute.per_kang_bao = attribute2.per_kang_bao + attribute1.per_kang_bao
	m_attribute.per_mianshang = attribute2.per_mianshang + attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang + attribute1.per_pofang
	m_attribute.goddess_gongji = (attribute1.goddess_gongji or attribute1.fujia_shanghai or 0) + (attribute2.goddess_gongji or attribute2.fujia_shanghai or 0)
	m_attribute.dikang_shanghai = (attribute1.dikang_shanghai or 0) + (attribute2.dikang_shanghai or 0)
	m_attribute.move_speed = attribute1.move_speed + attribute2.move_speed
	m_attribute.constant_zengshang = ((attribute1.constant_zengshang or 0) * (attribute2.constant_zengshang or 0)) / 10000
	m_attribute.constant_mianshang = ((attribute1.constant_mianshang or 0) * (attribute2.constant_mianshang or 0)) / 10000
	m_attribute.huixinyiji = attribute2.huixinyiji + attribute1.huixinyiji
	m_attribute.huixinyiji_hurt_per = attribute2.huixinyiji_hurt_per + attribute1.huixinyiji_hurt_per
	m_attribute.pvp_jianshang = (attribute2.pvp_jianshang * attribute1.pvp_jianshang) / 10000
	m_attribute.pvp_zengshang = (attribute2.pvp_zengshang * attribute1.pvp_zengshang) / 10000
	m_attribute.pve_jianshang = (attribute2.pve_jianshang * attribute1.pve_jianshang) / 10000
	m_attribute.pve_zengshang = (attribute2.pve_zengshang * attribute1.pve_zengshang) / 10000
	m_attribute.per_baoji_hurt = attribute2.per_baoji_hurt + attribute1.per_baoji_hurt
	m_attribute.per_kang_bao_hurt = attribute2.per_kang_bao_hurt + attribute1.per_kang_bao_hurt
	m_attribute.zhufuyiji_per = attribute2.zhufuyiji_per + attribute1.zhufuyiji_per
	m_attribute.gedang_per = attribute2.gedang_per + attribute1.gedang_per
	m_attribute.gedang_dikang_per = attribute2.gedang_dikang_per + attribute1.gedang_dikang_per
	m_attribute.gedang_jianshang = attribute2.gedang_jianshang + attribute1.gedang_jianshang
	m_attribute.skill_zengshang = attribute2.skill_zengshang + attribute1.skill_zengshang
	m_attribute.skill_jianshang = attribute2.skill_jianshang + attribute1.skill_jianshang
	m_attribute.mingzhong_per = attribute2.mingzhong_per + attribute1.mingzhong_per
	m_attribute.shanbi_per = attribute2.shanbi_per + attribute1.shanbi_per
	return m_attribute
end

-- 两个属性相加(没下划线)
function CommonDataManager.AddAttributeAttrNoUnderLine(attribute1, attribute2)
	local m_attribute = CommonStruct.AttributeNoUnderline()
	m_attribute.gongji = attribute1.gongji + attribute2.gongji
	m_attribute.maxhp = attribute1.maxhp + attribute2.maxhp
	m_attribute.fangyu = attribute1.fangyu + attribute2.fangyu
	m_attribute.mingzhong = attribute1.mingzhong + attribute2.mingzhong
	m_attribute.shanbi = attribute1.shanbi + attribute2.shanbi
	m_attribute.baoji = attribute1.baoji + attribute2.baoji
	m_attribute.jianren = attribute1.jianren + attribute2.jianren
	m_attribute.per_jingzhun = attribute2.per_jingzhun + attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji + attribute1.per_baoji
	m_attribute.per_kang_bao = attribute2.per_kang_bao + attribute1.per_kang_bao
	m_attribute.per_mianshang = attribute2.per_mianshang + attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang + attribute1.per_pofang
	m_attribute.goddess_gongji = (attribute1.goddess_gongji or attribute1.fujia_shanghai or 0) + (attribute2.goddess_gongji or attribute2.fujia_shanghai or 0)
	m_attribute.dikang_shanghai = (attribute1.dikang_shanghai or 0) + (attribute2.dikang_shanghai or 0)
	m_attribute.constant_zengshang = (attribute1.constant_zengshang or 0) + (attribute2.constant_zengshang or 0)
	m_attribute.constant_mianshang = (attribute1.constant_mianshang or 0) + (attribute2.constant_mianshang or 0)
	m_attribute.huixinyiji = attribute2.huixinyiji + attribute1.huixinyiji
	m_attribute.huixinyiji_hurt_per = attribute2.huixinyiji_hurt_per + attribute1.huixinyiji_hurt_per
	m_attribute.pvp_jianshang = attribute2.pvp_jianshang + attribute1.pvp_jianshang
	m_attribute.pvp_zengshang = attribute2.pvp_zengshang + attribute1.pvp_zengshang
	m_attribute.pve_jianshang = attribute2.pve_jianshang + attribute1.pve_jianshang
	m_attribute.pve_zengshang = attribute2.pve_zengshang + attribute1.pve_zengshang
	m_attribute.per_baoji_hurt = attribute2.per_baoji_hurt + attribute1.per_baoji_hurt
	m_attribute.per_kang_bao_hurt = attribute2.per_kang_bao_hurt + attribute1.per_kang_bao_hurt
	m_attribute.zhufuyiji_per = attribute2.zhufuyiji_per + attribute1.zhufuyiji_per
	m_attribute.gedang_per = attribute2.gedang_per + attribute1.gedang_per
	m_attribute.gedang_dikang_per = attribute2.gedang_dikang_per + attribute1.gedang_dikang_per
	m_attribute.gedang_jianshang = attribute2.gedang_jianshang + attribute1.gedang_jianshang
	m_attribute.skill_zengshang = attribute2.skill_zengshang + attribute1.skill_zengshang
	m_attribute.skill_jianshang = attribute2.skill_jianshang + attribute1.skill_jianshang
	m_attribute.mingzhong_per = attribute2.mingzhong_per + attribute1.mingzhong_per
	m_attribute.shanbi_per = attribute2.shanbi_per + attribute1.shanbi_per

	return m_attribute
end

-- is_no_underline 是否不要下换线
function CommonDataManager.AddAttributeBaseAttr(attribute1, vo, is_no_underline)
	local m_attribute = {}
	if not is_no_underline then
		m_attribute.gong_ji = attribute1.gong_ji + vo.base_gongji
		m_attribute.max_hp = attribute1.max_hp + vo.base_max_hp
		m_attribute.fang_yu = attribute1.fang_yu + vo.base_fangyu
		m_attribute.ming_zhong = attribute1.ming_zhong + vo.base_mingzhong
		m_attribute.shan_bi = attribute1.shan_bi + vo.base_shanbi
		m_attribute.bao_ji = attribute1.bao_ji + vo.base_baoji
		m_attribute.jian_ren = attribute1.jian_ren + vo.base_jianren
	else
		m_attribute.gongji = attribute1.gongji + vo.base_gongji
		m_attribute.maxhp = attribute1.maxhp + vo.base_max_hp
		m_attribute.fangyu = attribute1.fangyu + vo.base_fangyu
		m_attribute.mingzhong = attribute1.mingzhong + vo.base_mingzhong
		m_attribute.shanbi = attribute1.shanbi + vo.base_shanbi
		m_attribute.baoji = attribute1.baoji + vo.base_baoji
		m_attribute.jianren = attribute1.jianren + vo.base_jianren
	end
	m_attribute.per_jingzhun = vo.base_per_jingzhun + attribute1.per_jingzhun
	m_attribute.per_baoji = vo.base_per_baoji + attribute1.per_baoji
	m_attribute.per_kang_bao = vo.base_per_kangbao + attribute1.per_kang_bao
	m_attribute.per_mianshang = vo.base_per_mianshang + attribute1.per_mianshang
	m_attribute.per_pofang = vo.base_per_pofang + attribute1.per_pofang
	m_attribute.goddess_gongji = (attribute1.goddess_gongji or attribute1.fujia_shanghai or 0) + (vo.base_goddess_gongji or vo.base_fujia_shanghai or 0)
	m_attribute.dikang_shanghai = vo.dikang_shanghai + attribute1.dikang_shanghai
	m_attribute.constant_zengshang = vo.constant_zengshang + attribute1.constant_zengshang
	m_attribute.constant_mianshang = vo.constant_mianshang + attribute1.constant_mianshang
	m_attribute.huixinyiji = vo.huixinyiji + attribute1.huixinyiji
	m_attribute.huixinyiji_hurt_per = vo.huixinyiji_hurt_per + attribute1.huixinyiji_hurt_per
	m_attribute.pvp_jianshang = vo.pvp_jianshang + attribute1.pvp_jianshang
	m_attribute.pvp_zengshang = vo.pvp_zengshang + attribute1.pvp_zengshang
	m_attribute.pve_jianshang = vo.pve_jianshang + attribute1.pve_jianshang
	m_attribute.pve_zengshang = vo.pve_zengshang + attribute1.pve_zengshang
	m_attribute.per_baoji_hurt = vo.base_per_baoji_hurt + attribute1.per_baoji_hurt
	m_attribute.per_kang_bao_hurt = vo.base_per_kangbao_hurt + attribute1.per_kang_bao_hurt
	m_attribute.zhufuyiji_per = vo.base_zhufuyiji_per + attribute1.zhufuyiji_per
	m_attribute.gedang_per = vo.base_gedang_per + attribute1.gedang_per
	m_attribute.gedang_dikang_per = vo.base_gedang_dikang_per + attribute1.gedang_dikang_per
	m_attribute.gedang_jianshang = vo.base_gedang_jianshang + attribute1.gedang_jianshang
	m_attribute.skill_zengshang = vo.base_skill_zengshang + attribute1.skill_zengshang
	m_attribute.skill_jianshang = vo.base_skill_jianshang + attribute1.skill_jianshang
	m_attribute.mingzhong_per = vo.base_mingzhong_per + attribute1.mingzhong_per
	m_attribute.shanbi_per = vo.base_shanbi_per + attribute1.shanbi_per

	if attribute1.move_speed and vo.base_move_speed then
		m_attribute.move_speed = attribute1.move_speed + vo.base_move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute2.gong_ji - attribute1.gong_ji
	m_attribute.max_hp = attribute2.max_hp - attribute1.max_hp
	m_attribute.fang_yu = attribute2.fang_yu - attribute1.fang_yu
	m_attribute.ming_zhong = attribute2.ming_zhong - attribute1.ming_zhong
	m_attribute.shan_bi = attribute2.shan_bi - attribute1.shan_bi
	m_attribute.bao_ji = attribute2.bao_ji - attribute1.bao_ji
	m_attribute.per_kang_bao = attribute2.per_kang_bao - attribute1.per_kang_bao
	m_attribute.jian_ren = attribute2.jian_ren - attribute1.jian_ren
	m_attribute.goddess_gongji = attribute2.goddess_gongji - attribute1.goddess_gongji
	m_attribute.per_jingzhun = attribute2.per_jingzhun - attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji - attribute1.per_baoji
	m_attribute.per_mianshang = attribute2.per_mianshang - attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang - attribute1.per_pofang
	m_attribute.dikang_shanghai = attribute2.dikang_shanghai - attribute1.dikang_shanghai
	m_attribute.constant_mianshang = attribute2.constant_mianshang - attribute1.constant_mianshang
	m_attribute.constant_zengshang = attribute2.constant_zengshang - attribute1.constant_zengshang
	m_attribute.huixinyiji = attribute2.huixinyiji - attribute1.huixinyiji
	m_attribute.huixinyiji_hurt_per = attribute2.huixinyiji_hurt_per - attribute1.huixinyiji_hurt_per
	m_attribute.pvp_jianshang = attribute2.pvp_jianshang - attribute1.pvp_jianshang
	m_attribute.pvp_zengshang = attribute2.pvp_zengshang - attribute1.pvp_zengshang
	m_attribute.pve_jianshang = attribute2.pve_jianshang - attribute1.pve_jianshang
	m_attribute.pve_zengshang = attribute2.pve_zengshang - attribute1.pve_zengshang
	m_attribute.per_baoji_hurt = attribute2.per_baoji_hurt - attribute1.per_baoji_hurt
	m_attribute.per_kang_bao_hurt = attribute2.per_kang_bao_hurt - attribute1.per_kang_bao_hurt
	m_attribute.zhufuyiji_per = attribute2.zhufuyiji_per - attribute1.zhufuyiji_per
	m_attribute.gedang_per = attribute2.gedang_per - attribute1.gedang_per
	m_attribute.gedang_dikang_per = attribute2.gedang_dikang_per - attribute1.gedang_dikang_per
	m_attribute.gedang_jianshang = attribute2.gedang_jianshang - attribute1.gedang_jianshang
	m_attribute.skill_zengshang = attribute2.skill_zengshang - attribute1.skill_zengshang
	m_attribute.skill_jianshang = attribute2.skill_jianshang - attribute1.skill_jianshang
	m_attribute.mingzhong_per = attribute2.mingzhong_per - attribute1.mingzhong_per
	m_attribute.shanbi_per = attribute2.shanbi_per - attribute1.shanbi_per

	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttrNoUnderLine(attribute1, attribute2)
	local m_attribute = CommonStruct.AttributeNoUnderline()
	m_attribute.gongji = attribute2.gongji - attribute1.gongji
	m_attribute.maxhp = attribute2.maxhp - attribute1.maxhp
	m_attribute.fangyu = attribute2.fangyu - attribute1.fangyu
	m_attribute.mingzhong = attribute2.mingzhong - attribute1.mingzhong
	m_attribute.shanbi = attribute2.shanbi - attribute1.shanbi
	m_attribute.baoji = attribute2.baoji - attribute1.baoji
	m_attribute.jianren = attribute2.jianren - attribute1.jianren
	m_attribute.goddess_gongji = attribute2.goddess_gongji - attribute1.goddess_gongji
	m_attribute.per_jingzhun = attribute2.per_jingzhun - attribute1.per_jingzhun
	m_attribute.per_baoji = attribute2.per_baoji - attribute1.per_baoji
	m_attribute.per_kang_bao = attribute2.per_kang_bao - attribute1.per_kang_bao
	m_attribute.per_mianshang = attribute2.per_mianshang - attribute1.per_mianshang
	m_attribute.per_pofang = attribute2.per_pofang - attribute1.per_pofang
	m_attribute.dikang_shanghai = attribute2.dikang_shanghai - attribute1.dikang_shanghai
	m_attribute.constant_mianshang = attribute2.constant_mianshang - attribute1.constant_mianshang
	m_attribute.constant_zengshang = attribute2.constant_zengshang - attribute1.constant_zengshang
	m_attribute.huixinyiji = attribute2.huixinyiji - attribute1.huixinyiji
	m_attribute.huixinyiji_hurt_per = attribute2.huixinyiji_hurt_per - attribute1.huixinyiji_hurt_per
	m_attribute.pvp_jianshang = attribute2.pvp_jianshang - attribute1.pvp_jianshang
	m_attribute.pvp_zengshang = attribute2.pvp_zengshang - attribute1.pvp_zengshang
	m_attribute.pve_jianshang = attribute2.pve_jianshang - attribute1.pve_jianshang
	m_attribute.pve_zengshang = attribute2.pve_zengshang - attribute1.pve_zengshang
	m_attribute.per_baoji_hurt = attribute2.per_baoji_hurt - attribute1.per_baoji_hurt
	m_attribute.per_kang_bao_hurt = attribute2.per_kang_bao_hurt - attribute1.per_kang_bao_hurt
	m_attribute.zhufuyiji_per = attribute2.zhufuyiji_per - attribute1.zhufuyiji_per
	m_attribute.gedang_per = attribute2.gedang_per - attribute1.gedang_per
	m_attribute.gedang_dikang_per = attribute2.gedang_dikang_per - attribute1.gedang_dikang_per
	m_attribute.gedang_jianshang = attribute2.gedang_jianshang - attribute1.gedang_jianshang
	m_attribute.skill_zengshang = attribute2.skill_zengshang - attribute1.skill_zengshang
	m_attribute.skill_jianshang = attribute2.skill_jianshang - attribute1.skill_jianshang
	m_attribute.mingzhong_per = attribute2.mingzhong_per - attribute1.mingzhong_per
	m_attribute.shanbi_per = attribute2.shanbi_per - attribute1.shanbi_per	

	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 属性乘以一个常数
function CommonDataManager.MulAttribute(attr, num)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attr.gong_ji * num
	m_attribute.max_hp = attr.max_hp * num
	m_attribute.fang_yu = attr.fang_yu * num
	m_attribute.ming_zhong = attr.ming_zhong * num
	m_attribute.shan_bi = attr.shan_bi * num
	m_attribute.bao_ji = attr.bao_ji * num
	m_attribute.jian_ren = attr.jian_ren * num
	m_attribute.goddess_gongji = attr.goddess_gongji * num
	m_attribute.per_jingzhun = attr.per_jingzhun * num
	m_attribute.per_baoji = attr.per_baoji * num
	m_attribute.per_kang_bao = attr.per_kang_bao * num
	m_attribute.per_mianshang = attr.per_mianshang * num
	m_attribute.per_pofang = attr.per_pofang * num
	m_attribute.dikang_shanghai = attr.dikang_shanghai * num
	m_attribute.constant_mianshang = attr.constant_mianshang * num
	m_attribute.constant_zengshang = attr.constant_zengshang * num
	m_attribute.huixinyiji = attr.huixinyiji * num
	m_attribute.huixinyiji_hurt_per = attr.huixinyiji_hurt_per * num
	m_attribute.pvp_jianshang = attr.pvp_jianshang * num
	m_attribute.pvp_zengshang = attr.pvp_zengshang * num
	m_attribute.pve_jianshang = attr.pve_jianshang * num
	m_attribute.pve_zengshang = attr.pve_zengshang * num
	m_attribute.per_baoji_hurt = attr.per_baoji_hurt * num
	m_attribute.per_kang_bao_hurt = attr.per_kang_bao_hurt * num
	m_attribute.zhufuyiji_per = attr.zhufuyiji_per * num
	m_attribute.gedang_per = attr.gedang_per * num
	m_attribute.gedang_dikang_per = attr.gedang_dikang_per * num
	m_attribute.gedang_jianshang = attr.gedang_jianshang * num
	m_attribute.skill_zengshang = attr.skill_zengshang * num
	m_attribute.skill_jianshang = attr.skill_jianshang * num
	m_attribute.mingzhong_per = attr.mingzhong_per * num
	m_attribute.shanbi_per = attr.shanbi_per * num	

	if attr.move_speed then
		m_attribute.move_speed = attr.move_speed * num
	end
	return m_attribute
end

-- 属性乘以一个常数
function CommonDataManager.MulAttributeNoUnderline(attr, num)
	local m_attribute = CommonStruct.AttributeNoUnderline()
	m_attribute.gongji = attr.gongji * num
	m_attribute.maxhp = attr.maxhp * num
	m_attribute.fangyu = attr.fangyu * num
	m_attribute.mingzhong = attr.mingzhong * num
	m_attribute.shanbi = attr.shanbi * num
	m_attribute.baoji = attr.baoji * num
	m_attribute.jianren = attr.jianren * num
	m_attribute.goddess_gongji = attr.goddess_gongji * num
	m_attribute.per_jingzhun = attr.per_jingzhun * num
	m_attribute.per_baoji = attr.per_baoji * num
	m_attribute.per_kang_bao = attr.per_kang_bao * num
	m_attribute.per_mianshang = attr.per_mianshang * num
	m_attribute.per_pofang = attr.per_pofang * num
	m_attribute.dikang_shanghai = attr.dikang_shanghai * num
	m_attribute.constant_mianshang = attr.constant_mianshang * num
	m_attribute.constant_zengshang = attr.constant_zengshang * num
	m_attribute.huixinyiji = attr.huixinyiji * num
	m_attribute.huixinyiji_hurt_per = attr.huixinyiji_hurt_per * num
	m_attribute.pvp_jianshang = attr.pvp_jianshang * num
	m_attribute.pvp_zengshang = attr.pvp_zengshang * num
	m_attribute.pve_jianshang = attr.pve_jianshang * num
	m_attribute.pve_zengshang = attr.pve_zengshang * num
	m_attribute.per_baoji_hurt = attr.per_baoji_hurt * num
	m_attribute.per_kang_bao_hurt = attr.per_kang_bao_hurt * num
	m_attribute.zhufuyiji_per = attr.zhufuyiji_per * num
	m_attribute.gedang_per = attr.gedang_per * num
	m_attribute.gedang_dikang_per = attr.gedang_dikang_per * num
	m_attribute.gedang_jianshang = attr.gedang_jianshang * num
	m_attribute.skill_zengshang = attr.skill_zengshang * num
	m_attribute.skill_jianshang = attr.skill_jianshang * num
	m_attribute.mingzhong_per = attr.mingzhong_per * num
	m_attribute.shanbi_per = attr.shanbi_per * num		

	if attr.move_speed then
		m_attribute.move_speed = attr.move_speed * num
	end	
	return m_attribute
end

CommonDataManager.PROF_ATTR_RATE = {
	{max_hp = 1.1103, gong_ji = 0.89, fang_yu = 1},
	{max_hp = 0.9662, gong_ji = 1.03, fang_yu = 1},
	{max_hp = 1.0356, gong_ji = 0.98, fang_yu = 1},
	{max_hp = 0.8832, gong_ji = 1.09, fang_yu = 1}
}

-- 读取一个对象的属性值,没有下划线
function CommonDataManager.GetAttributteNoUnderline(info)
	local attribute = CommonStruct.AttributeNoUnderline()

	if nil ~= info then
		attribute.gongji = info.gong_ji or info.attack or info.gongji or 0
		attribute.maxhp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fangyu = info.fang_yu or info.fangyu or 0
		attribute.mingzhong = info.ming_zhong or info.mingzhong or 0
		attribute.shanbi = info.shan_bi or info.shanbi or 0
		attribute.baoji = info.bao_ji or info.baoji or 0
		attribute.jianren = info.jian_ren or info.jianren or info.kangbao or info.kang_bao or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or info.pojia_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_kang_bao = info.per_kang_bao or info.kang_bao_per or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or info.per_shanghaijiacheng or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or info.per_base_attr_jiacheng or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or info.fujia or 0
		attribute.dikang_shanghai = info.dikang_shanghai or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or info.zeng_shang or info.zengshang or 0
		attribute.huixinyiji = info.huixinyiji or info.hxyj or 0
		attribute.huixinyiji_hurt_per = info.huixinyiji_hurt_per or info.hxyj_hurt_per or 0
		attribute.pvp_jianshang = info.pvp_jianshang or info.reduce_hurt or 0
		attribute.pvp_zengshang = info.pvp_zengshang or info.add_hurt or 0
		attribute.pve_jianshang = info.pve_jianshang or info.pve_jianshang_per or 0
		attribute.pve_zengshang = info.pve_zengshang or info.pve_zengshang_per or 0
		attribute.per_baoji_hurt = info.per_baoji_hurt or 0
		attribute.per_kang_bao_hurt = info.per_kang_bao_hurt or 0
		attribute.zhufuyiji_per = info.zhufuyiji_per or info.per_zhufuyiji or info.zhufu_per or 0
		attribute.gedang_per = info.gedang_per or info.per_gedang or 0
		attribute.gedang_dikang_per = info.gedang_dikang_per or info.per_gedang_dikang or 0
		attribute.gedang_jianshang = info.gedang_jianshang or 0
		attribute.skill_zengshang = info.skill_zengshang or info.skill_zengshang_per or 0
		attribute.skill_jianshang = info.skill_jianshang or info.skill_jianshang_per or info.jianshang_per or 0
		attribute.mingzhong_per = info.mingzhong_per or info.per_mingzhong or 0
		attribute.shanbi_per = info.shanbi_per or info.per_shanbi or info.shangbi_per or 0
	end
	return attribute
end

-- 读取一个对象的属性值,没有下划线(女神)
function CommonDataManager.GetGoddessAttributteNoUnderline(info)
	local attribute = CommonStruct.AttributeNoUnderline()

	if nil ~= info then
		attribute.gongji = info.gong_ji or info.attack or info.gongji or 0
		attribute.maxhp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fangyu = info.fang_yu or info.fangyu or 0
		attribute.mingzhong = info.ming_zhong or info.mingzhong or 0
		attribute.shanbi = info.shan_bi or info.shanbi or 0
		attribute.baoji = info.bao_ji or info.baoji or 0
		attribute.jianren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or info.pojia_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_kang_bao = info.per_kang_bao or info.kang_bao_per or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or info.per_shanghaijiacheng or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or info.per_base_attr_jiacheng or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or info.fu_jia or info.fujia or 0
		attribute.dikang_shanghai = info.dikang_shanghai or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or info.zeng_shang or info.zengshang or 0
		attribute.huixinyiji = info.huixinyiji or info.hxyj or 0
		attribute.huixinyiji_hurt_per = info.huixinyiji_hurt_per or info.hxyj_hurt_per or 0
		attribute.pvp_jianshang = info.pvp_jianshang or info.reduce_hurt or 0
		attribute.pvp_zengshang = info.pvp_zengshang or info.add_hurt or 0
		attribute.pve_jianshang = info.pve_jianshang or info.pve_jianshang_per or 0
		attribute.pve_zengshang = info.pve_zengshang or info.pve_zengshang_per or 0
		attribute.per_baoji_hurt = info.per_baoji_hurt or 0
		attribute.per_kang_bao_hurt = info.per_kang_bao_hurt or 0
		attribute.zhufuyiji_per = info.zhufuyiji_per or info.per_zhufuyiji or info.zhufu_per or 0
		attribute.gedang_per = info.gedang_per or info.per_gedang or 0
		attribute.gedang_dikang_per = info.gedang_dikang_per or info.per_gedang_dikang or 0
		attribute.gedang_jianshang = info.gedang_jianshang or 0
		attribute.skill_zengshang = info.skill_zengshang or 0
		attribute.skill_jianshang = info.skill_jianshang or info.skill_jianshang_per or info.jianshang_per or 0
		attribute.mingzhong_per = info.mingzhong_per or info.per_mingzhong or 0
		attribute.shanbi_per = info.shanbi_per or info.per_shanbi or info.shangbi_per or 0		
	end
	return attribute
end

-- 读取一个对象的属性值，有下划线
function CommonDataManager.GetAttributteByClass(info)
	local attribute = CommonStruct.Attribute()
	if nil ~= info then
		attribute.gong_ji = info.gong_ji or info.attack or info.gongji or 0
		attribute.max_hp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fang_yu = info.fang_yu or info.fangyu or 0
		attribute.ming_zhong = info.ming_zhong or info.mingzhong or 0
		attribute.shan_bi = info.shan_bi or info.shanbi or 0
		attribute.bao_ji = info.bao_ji or info.baoji or 0
		attribute.jian_ren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or info.pojia_per or 0
		attribute.per_baoji = info.per_baoji or info.baoji_per or 0
		attribute.per_kang_bao = info.per_kang_bao or info.kang_bao_per or info.per_kangbao or 0
		attribute.per_mianshang = info.per_mianshang or info.per_mianshang or info.per_shanghaijiacheng or 0
		attribute.per_pofang = info.per_pofang or info.per_pofang or info.per_shanghaijiacheng or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.move_speed = info.move_speed or 0
		attribute.goddess_gongji = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or info.fujia or 0
		attribute.dikang_shanghai = info.dikang_shanghai or 0
		attribute.constant_mianshang = info.constant_mianshang or info.mian_shang or info.mianshang or 0
		attribute.constant_zengshang = info.constant_zengshang or info.zeng_shang or info.zengshang or 0
		attribute.huixinyiji = info.huixinyiji or info.hxyj or 0
		attribute.huixinyiji_hurt_per = info.huixinyiji_hurt_per or info.hxyj_hurt_per or 0
		attribute.pvp_jianshang = info.pvp_jianshang or info.reduce_hurt or info.pvp_jianshang_per or 0
		attribute.pvp_zengshang = info.pvp_zengshang or info.add_hurt or 0
		attribute.pve_jianshang = info.pve_jianshang or info.pve_jianshang_per or 0
		attribute.pve_zengshang = info.pve_zengshang or info.pve_zengshang_per or 0
		attribute.per_baoji_hurt = info.per_baoji_hurt or 0
		attribute.per_kang_bao_hurt = info.per_kang_bao_hurt or 0
		attribute.zhufuyiji_per = info.zhufuyiji_per or info.per_zhufuyiji or info.zhufu_per or 0
		attribute.gedang_per = info.gedang_per or info.per_gedang or 0
		attribute.gedang_dikang_per = info.gedang_dikang_per or info.per_gedang_dikang or 0
		attribute.gedang_jianshang = info.gedang_jianshang or 0
		attribute.skill_zengshang = info.skill_zengshang or info.skill_zengshang_per or 0
		attribute.skill_jianshang = info.skill_jianshang or info.skill_jianshang_per or info.jianshang_per or 0
		attribute.mingzhong_per = info.mingzhong_per or info.per_mingzhong or 0
		attribute.shanbi_per = info.shanbi_per or info.per_shanbi or info.shangbi_per or 0			
	end
	return attribute
end

-- 人物百分比属性（没有下划线）
function CommonDataManager.GetRolePercentAttrNoUnderline(info)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local attribute = CommonStruct.AttributeNoUnderline()
	if nil ~= info then
		attribute.gongji = math.floor((info.per_gongji or 0) * vo.base_gongji * 0.0001)
		attribute.maxhp = math.floor((info.per_maxhp or 0) * vo.base_max_hp * 0.0001)
		attribute.fangyu = math.floor((info.per_fangyu or 0) * vo.base_fangyu * 0.0001)
		-- attribute.mingzhong = math.floor((info.per_mingzhong or 0) * vo.base_mingzhong * 0.0001)
		-- attribute.shanbi = math.floor((info.per_shanbi or 0) * vo.base_shanbi * 0.0001)
		-- attribute.baoji = math.floor((info.per_baoji or 0) * vo.base_baoji * 0.0001)
		-- attribute.jianren = math.floor((info.per_jianren or 0) * vo.base_jianren * 0.0001)
	end
	return attribute
end

-- 人物百分比属性
function CommonDataManager.GetRolePercentAttr(info)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local attribute = CommonStruct.Attribute()
	if nil ~= info then
		attribute.gong_ji = math.floor((info.per_gongji or info.gongji_per or 0) * vo.base_gongji * 0.0001)
		attribute.max_hp = math.floor((info.per_maxhp or info.hp_per or 0) * vo.base_max_hp * 0.0001)
		attribute.fang_yu = math.floor((info.per_fangyu or 0) * vo.base_fangyu * 0.0001)
		-- attribute.ming_zhong = math.floor((info.per_mingzhong or 0) * vo.base_mingzhong * 0.0001)
		-- attribute.shan_bi = math.floor((info.per_shanbi or 0) * vo.base_shanbi * 0.0001)
		-- attribute.bao_ji = math.floor((info.per_baoji or 0) * vo.base_baoji * 0.0001)
		-- attribute.jian_ren = math.floor((info.per_jianren or 0) * vo.base_jianren * 0.0001)
	end
	return attribute
end

-- 获取属性，除去含有百分比的属性
function CommonDataManager.GetAttributteNoParcent(info)
	local attribute = {}
	if nil ~= info then
		attribute.gong_ji = info.gong_ji or info.attack or info.gongji or 0
		attribute.max_hp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fang_yu = info.fang_yu or info.fangyu or 0
		attribute.ming_zhong = info.ming_zhong or info.mingzhong or 0
		attribute.shan_bi = info.shan_bi or info.shanbi or 0
		attribute.bao_ji = info.bao_ji or info.baoji or 0
		attribute.jian_ren = info.jian_ren or info.jianren or 0
	end
	return attribute
end

function CommonDataManager.GetOrderAttributte(info)
	local t = {}
	if nil ~= info then
		table.insert(t, {key = "gong_ji", value = info.gong_ji or info.attack or info.gongji or 0})
		table.insert(t, {key = "fang_yu", value = info.fang_yu or info.fangyu or 0})
		table.insert(t, {key = "max_hp", value = info.max_hp or info.maxhp or info.hp or info.qixue or 0})
		table.insert(t, {key = "ming_zhong", value = info.ming_zhong or info.mingzhong or 0})
		table.insert(t, {key = "shan_bi", value = info.shan_bi or info.shanbi or 0})
		table.insert(t, {key = "bao_ji", value = info.bao_ji or info.baoji or 0})
		table.insert(t, {key = "jian_ren", value = info.jian_ren or info.jianren or 0})
		table.insert(t, {key = "per_pofang", value = info.per_pofang or info.per_pofang or 0})
		table.insert(t, {key = "per_gongji", value = info.per_gongji or info.per_gongji or 0})
		table.insert(t, {key = "per_maxhp", value = info.per_maxhp or info.per_maxhp or 0})
		table.insert(t, {key = "goddess_gongji", value = info.goddess_gongji or info.fujia_shanghai or info.xiannv_gongji or info.fujia or 0})
		table.insert(t, {key = "dikang_shanghai", value = info.dikang_shanghai or 0})
		table.insert(t, {key = "move_speed", value = info.move_speed or 0})
		table.insert(t, {key = "per_jingzhun", value = info.per_jingzhun or info.jingzhun_per or info.pojia_per or 0})
		table.insert(t, {key = "per_baoji", value = info.per_baoji or info.baoji_per or 0})
		table.insert(t, {key = "per_kang_bao", value = info.per_kang_bao or info.kang_bao_per or 0})
		table.insert(t, {key = "per_mianshang", value = info.per_mianshang or info.per_mianshang or 0})
		table.insert(t, {key = "constant_zengshang", value = info.constant_zengshang or info.zeng_shang or info.zengshang or 0})
		table.insert(t, {key = "constant_mianshang", value = info.constant_mianshang or info.mian_shang or info.mianshang or 0})
		table.insert(t, {key = "pvp_jianshang", value = info.pvp_jianshang or info.reduce_hurt or 0})
		table.insert(t, {key = "pvp_zengshang", value = info.pvp_zengshang or info.add_hurt or 0})
		table.insert(t, {key = "pve_jianshang", value = info.pve_jianshang or info.pve_jianshang_per or 0})
		table.insert(t, {key = "pve_zengshang", value = info.pve_zengshang or info.pve_zengshang_per or 0})
		table.insert(t, {key = "per_baoji_hurt", value = info.per_baoji_hurt or 0})
		table.insert(t, {key = "per_kang_bao_hurt", value = info.per_kang_bao_hurt or 0})
		table.insert(t, {key = "zhufuyiji_per", value = info.zhufuyiji_per or info.per_zhufuyiji or info.zhufu_per or 0})
		table.insert(t, {key = "gedang_per", value = info.gedang_per or info.per_gedang or 0})
		table.insert(t, {key = "gedang_dikang_per", value = info.gedang_dikang_per or info.per_gedang_dikang or 0})
		table.insert(t, {key = "gedang_jianshang", value = info.gedang_jianshang or 0})
		table.insert(t, {key = "skill_zengshang", value = info.skill_zengshang or info.skill_zengshang_per or 0})
		table.insert(t, {key = "skill_jianshang", value = info.skill_jianshang or 0})
		table.insert(t, {key = "mingzhong_per", value = info.mingzhong_per or info.per_mingzhong or 0})
		table.insert(t, {key = "shanbi_per", value = info.shanbi_per or info.per_shanbi or info.shangbi_per or 0})
		table.insert(t, {key = "huixinyiji", value = info.huixinyiji or info.hxyj or 0})
		table.insert(t, {key = "huixinyiji_hurt_per", value = info.huixinyiji_hurt_per or info.hxyj_hurt_per or 0})
		table.insert(t, {key = "skill_jianshang_per", value = info.skill_jianshang_per or info.jianshang_per or 0})
	end
	return t
end

-- 读取一个对象的进阶属性值
function CommonDataManager.GetAdvanceAttributteByClass(info)
	local attribute = CommonStruct.AdvanceAttribute()

	if nil ~= info then
		attribute.mount_attr = info.mount_attr or info.mountattr or 0
		attribute.wing_attr = info.wing_attr or info.wingattr or 0
		attribute.halo_attr = info.halo_attr or info.haloattr or 0
		attribute.shengong_attr = info.shengong_attr or info.shengongattr or 0
		attribute.shenyi_attr = info.shenyi_attr or info.shenyiattr or 0
	end

	return attribute
end

-- 读取一个对象的进阶加成属性值
function CommonDataManager.GetAdvanceAddibutteByClass(info)
	local attribute = CommonStruct.AdvanceAddbute()

	if nil ~= info then
		attribute.mount_add = info.mount_add or info.mountadd or 0
		attribute.wing_add = info.wing_add or info.wingadd or 0
		attribute.halo_add = info.halo_add or info.haloadd or 0
		attribute.shengong_add = info.shengong_add or info.shengongadd or 0
		attribute.shenyi_add = info.shenyi_add or info.shenyiadd or 0
		attribute.footprint_add = info.footprint_add or info.shenyiadd or 0
		attribute.fightmount_add = info.fightmount_add or info.shenyiadd or 0
	end

	return attribute
end

function CommonDataManager.AddTotalAttributeAttrNoUnder(attribute1, attribute2)
	local m_attribute = CommonStruct.AttributeNoUnderline()
	m_attribute.gongji = attribute1.gongji + attribute2.gongji
	m_attribute.maxhp = attribute1.maxhp + attribute2.maxhp
	m_attribute.fangyu = attribute1.fangyu + attribute2.fangyu

	return m_attribute
end

function CommonDataManager.AttributeAddProfRate(attribute)
	if nil == attribute then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()

	for k,v in pairs(attribute) do
		local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof] or {}
		if prof_attr_rate[k] then
			attribute[k] = math.floor(v * prof_attr_rate[k])
		end
	end
end

function CommonDataManager.GetProfAttrValue(value, attr_name)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof]
	if nil == prof_attr_rate then return value end

	if attr_name == "attack" or attr_name == "gongji" or attr_name == "gong_ji" then
		return math.floor(value * prof_attr_rate["gong_ji"])
	end

	if attr_name == "fangyu" or attr_name == "fang_yu" then
		return math.floor(value * prof_attr_rate["fang_yu"])
	end

	if attr_name == "maxhp" or attr_name == "hp" or attr_name == "qixue" or attr_name == "max_hp" then
		return math.floor(value * prof_attr_rate["max_hp"])
	end
	return value
end

-- 读取一个显示属性列表
function CommonDataManager.GetAttrNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAttributteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAttrName(k)
			vo.value = v
			list[#list + 1] = vo
		end
	end
	return list
end

-- 读取一个显示排序属性列表
function CommonDataManager.GetOrderAttrNameAndValue(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetOrderAttributte(info)
	for k,v in pairs(attribute) do
		if all_show or v.value > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAttrName(v.key)
			vo.value = v.value
			list[#list + 1] = vo
		end
	end
	return list
end

-- 读取一个显示进阶加成列表
function CommonDataManager.GetAdvanceAddNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAdvanceAddibutteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAdvanceAddName(k)
			vo.value = v
			vo.attr = k
			list[#list + 1] = vo
		end
	end
	return list
end

function CommonDataManager.GetAttrKeyList()
	return{
		[1] = "gong_ji",
		[2] = "fang_yu",
		[3] = "max_hp",
		[4] = "ming_zhong",
		[5] = "shan_bi",
		[6] = "bao_ji",
		[7] = "jian_ren",
		[8] = "move_speed",
	}
end

function CommonDataManager.GetAttrKeyList2()
	return{
		[1] = "max_hp",
		[2] = "gong_ji",
		[3] = "fang_yu",
		[4] = "ming_zhong",
		[5] = "shan_bi",
		[6] = "bao_ji",
		[7] = "jian_ren",
		[8] = "move_speed",
	}
end

function CommonDataManager.FlushAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_val"] then
				widgets["lbl_" .. v[1] .. "_val"].node:setString(attribute[v[2]])
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_val then
				widgets.lbl_mingongji_val.node:setString(math.floor(attribute.gong_ji * 0.4))
			end
		end
		if true == showspd then
			-- local speed = (attribute.move_speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
			widgets.lbl_movespeed_val.node:setString("+" .. attribute.speed_percent .. "%")
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString("+" .. attribute[v[2]])
				end
				if widgets["img_" .. v[1] .. "_add"] then
					widgets["img_" .. v[1] .. "_add"].node:setVisible(0 ~= attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if widgets.img_mingongji_add then
					widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				end
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString("+" .. math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_arrow_speed.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString("+" .. attribute.speed_percent .. "%")
			end
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushArrowsNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				local arrows = widgets["img_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				arrows:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString(attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString(math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString(attribute.speed_percent .. "%")
			end
		end
	end
end

-- 获取基础属性名字
function CommonDataManager.GetAttrName(attr_type)
	attr_type = attr_type == "fangyu" and "fang_yu" or attr_type
	attr_type = attr_type == "gongji" and "gong_ji" or attr_type
	attr_type = attr_type == "maxhp" and "max_hp" or attr_type
	attr_type = attr_type == "jianren" and "jian_ren" or attr_type
	attr_type = attr_type == "shanbi" and "shan_bi" or attr_type
	attr_type = attr_type == "baoji" and "bao_ji" or attr_type
	attr_type = attr_type == "mingzhong" and "ming_zhong" or attr_type

	return Language.Common.AttrName[attr_type] or "nil"
end

-- 获取基础属性名字（没有空格）
function CommonDataManager.GetAttrNameWithNoSpace(attr_type)
	attr_type = attr_type == "fangyu" and "fang_yu" or attr_type
	attr_type = attr_type == "gongji" and "gong_ji" or attr_type
	attr_type = attr_type == "maxhp" and "max_hp" or attr_type
	attr_type = attr_type == "jianren" and "jian_ren" or attr_type
	attr_type = attr_type == "shanbi" and "shan_bi" or attr_type
	attr_type = attr_type == "baoji" and "bao_ji" or attr_type
	attr_type = attr_type == "mingzhong" and "ming_zhong" or attr_type

	return Language.Common.AttrNameNoSpace[attr_type] or Language.Common.AttrName[attr_type] or "nil"
end

-- 获取进阶属性名字
function CommonDataManager.GetAdvanceAttrName(attr_type)
	attr_type = attr_type == "mountattr" and "mount_attr" or attr_type
	attr_type = attr_type == "wingattr" and "wing_attr" or attr_type
	attr_type = attr_type == "haloattr" and "halo_attr" or attr_type
	attr_type = attr_type == "shengongattr" and "shengong_attr" or attr_type
	attr_type = attr_type == "shenyiattr" and "shenyi_attr" or attr_type
	return Language.Common.AdvanceAttrName[attr_type] or "nil"
end

-- 获取进阶加成名字
function CommonDataManager.GetAdvanceAddName(attr_type)
	attr_type = attr_type == "mountadd" and "mount_add" or attr_type
	attr_type = attr_type == "wingadd" and "wing_add" or attr_type
	attr_type = attr_type == "haloadd" and "halo_add" or attr_type
	attr_type = attr_type == "shengongadd" and "shengong_add" or attr_type
	attr_type = attr_type == "shenyiadd" and "shenyi_add" or attr_type
	attr_type = attr_type == "footprintadd" and "footprint_add" or attr_type
	attr_type = attr_type == "fightmountadd" and "fightmount_add" or attr_type
	return Language.Common.AdvanceAddName[attr_type] or "nil"
end

-- 速度换算
function CommonDataManager.CountSpeedForPercent(speed)
	local speed_percent = (speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
	speed_percent = GameMath.Round(speed_percent / 5) * 5

	return speed_percent
end

--通过索引获得仓库的格子对应的编号 cell_index-滚动条索引(从1开始), row-列数 column-行数
function CommonDataManager.GetCellIndexList(cell_index, row, column)
	local cell_index_list = {}
	local x = math.floor(cell_index/row)
	if x > 0 and x * row ~= cell_index then
		cell_index = cell_index + row * (column - 1) * x
	elseif x > 1 and x * row == cell_index then
		cell_index = cell_index + row * (column - 1) * (x - 1)
	end
	for i = 1, column do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + row * (i - 1)
		end
	end
	return cell_index_list
end

--拆分礼包(传进来必须是礼包)
function CommonDataManager.SplitGiftToItems(item_id, count)
	local gift_cfg = ItemData.Instance:GetItemConfig(item_id)
	local item_list = {}
	for i = 1, count do
		local data = {}
		data.item_id = gift_cfg["item_"..i.."_id"]
		data.num = gift_cfg["item_"..i.."_num"]
		data.num = gift_cfg["is_bind_"..i]
		item_list[i] = data
	end
	return item_list
end

--=============================新ui控件重写=============================--

function CommonDataManager.ParseTagContent(content, font_size)
	font_size = font_size or 32
	--有名字替换，<player_name>主角</player_name>
	local name = PlayerData.Instance.role_vo.name--HtmlTool.GetHtml(PlayerData.Instance.role_vo.name, COLOR.YELLOW , font_size)
	content = XmlUtil.RelaceTagContent(content, "player_name", name)

	--有性别替换，<sex0>女娃儿</sex0><sex1>小兄弟</sex1>
	local sex = PlayerData.Instance.role_vo.sex
	local sex_tag_content = XmlUtil.GetTagContent(content, "sex" .. sex)
	if sex_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "sex0", sex_tag_content)
		content = XmlUtil.RelaceTagContent(content, "sex1", "")
	end

	local camp = PlayerData.Instance.role_vo.camp
	local camp_tag_content = XmlUtil.GetTagContent(content, "camp" .. camp)
	if camp_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "camp1", camp_tag_content)
		content = XmlUtil.RelaceTagContent(content, "camp0", "")
		content = XmlUtil.RelaceTagContent(content, "camp2", "")
		content = XmlUtil.RelaceTagContent(content, "camp3", "")
	end

	return content
end

-- 解析不同平台的游戏名字
function CommonDataManager.ParseGameName(content)
	return string.gsub(content, "{gamename;}", CommonDataManager.GetGameName())
end

function CommonDataManager.GetGameName()
	if nil ~= AgentAdapter and nil ~= AgentAdapter.GetGameName then
		return AgentAdapter:GetGameName()
	end

	return UnityEngine.Application.installerName
	-- return Language.Common.GameName[1]
end

function CommonDataManager.GetAgentGameName()
	local game_name = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(Config.agent_adapt_auto.agent_adapt) do
		if spid == v.spid then
			game_name = v.game_name
		end
	end
	return game_name
end

--解析不同平台的交流群
function CommonDataManager.ParseContectGroup(content)

	local i, j = string.find(content, "{contectgroup_2;}")
	if i ~= nil and j ~= nil then
		local contect_group = CommonDataManager.GetAgentContectGroup2()
		content =  string.gsub(content, "{contectgroup_2;}", contect_group)
	end
	i, j = string.find(content, "{contectgroup;}")
	if i == nil or j == nil then return content end

	local contect_group = CommonDataManager.GetAgentContectGroup()
	return string.gsub(content, "{contectgroup;}", contect_group)
end

function CommonDataManager.GetAgentContectGroup2()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect_2
			else
				contect_group = v.contect_2
			end
		end
	end
	return contect_group
end

function CommonDataManager.GetAgentContectGroup()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect
			else
				contect_group = v.contect
			end
		end
	end
	return contect_group
end

function CommonDataManager.IsSpecAgentContect(spec_id)
	local list = Split(spec_id, "#")
	local server_id = GameVoManager.Instance:GetUserVo().plat_server_id
	for k,v in pairs(list) do
		if tonumber(v) == server_id then
			return true
		end
	end
	return false
end

-- 转换游戏品质
function CommonDataManager.ChangeQuality(obj, level)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:SetOverrideLevel(level or 0)
			end
		end
	end
end

-- 还原游戏品质
function CommonDataManager.ResetQuality(obj)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:ResetOverrideLevel()
			end
		end
	end
end

-- 设置头像(优化版)(show_image_variable是否展示默认头像的绑定变量)(image_asset_variable设置默认头像资源的绑定变量)
function CommonDataManager.NewSetAvatar(role_id, show_image_variable, image_asset_variable, raw_image_obj, sex, prof, is_big, download_callback)
	-- 如果是主角
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 如果是跨服中
		if IS_ON_CROSSSERVER then
			role_id = CrossServerData.Instance:GetRoleId()
		end
	end
	is_big = is_big or false
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 then
		show_image_variable:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		image_asset_variable.image:LoadSprite(bundle, asset)
	else
		local avatar_key = AvatarManager.Instance:GetAvatarKey(role_id, is_big)
		local path = AvatarManager.GetFilePath(role_id, is_big)
		if not AvatarManager.HasCache(avatar_key, path) then
			show_image_variable:SetActive(false)
			local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
			image_asset_variable.image:LoadSprite(bundle, asset)
		end

		local callback = function (path)
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end

			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadURLSprite(avatar_path,
			function()
				if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
					return
				end

				show_image_variable:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, is_big, download_callback or callback)
	end
end


function CommonDataManager.GetRandomName(rand_num)
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local sex = rand_num % 2

	local name_first_list = {}	-- 前缀
	local name_last_list = {}	-- 后缀
	if sex == GameEnum.FEMALE then
		name_first_list = name_cfg.female_first
		name_last_list = name_cfg.female_last
	else
		name_first_list = name_cfg.male_first
		name_last_list = name_cfg.male_last
	end

	local name_first_index = (rand_num % #name_first_list) + 1
	local name_last_index = (rand_num % #name_last_list) + 1
	local first_name = name_first_list[name_first_index] or ""
	local last_name = name_last_list[name_last_index] or ""
	return first_name .. last_name
end

function CommonDataManager.SetAvatarFrame(role_id, image_variable, show_default)
	local key = AvatarManager.Instance:GetAvatarFrameKey(role_id)
	CoolChatCtrl.Instance:SetAvatarFrameImage(image_variable, key, show_default)
end

function CommonDataManager.StringToTable(s)
    local tb = {}
    for utfChar in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(tb, utfChar)
    end

    return tb
end

function CommonDataManager.ConverNum2(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 1000)/10
		return result, Language.Common.Wan
	end

	if value >= 100000000 then
		local result = math.floor(value / 10000000)/10
		return result, Language.Common.Yi
	end
	return value
end

function CommonDataManager.FightPower(_self, node, asset_name)
	if nil == _self or nil == node then
		return
	end
	local bundle_name = "uis/views/miscpreload_prefab"
	asset_name = asset_name or "FightPower2"
	local obj = U3DObject(ResPoolMgr:TryGetGameObject(bundle_name, asset_name))
	if obj then
		obj.transform:SetParent(node.transform, false)
		local node_list = U3DNodeList(obj:GetComponent(typeof(UINameTable)), _self)
		return node_list["Number"]
	end
end

-- 设置一折抢购跳转按钮
function CommonDataManager.SetYiZheBtnJump(_self, parent_root, callback)
	if nil == _self or nil == parent_root then
		return
	end

	local async_loader = AllocAsyncLoader(_self, "BtnYiZheJump")
	async_loader:SetIsUseObjPool(true)
	async_loader:Load("uis/views/commonwidgets_prefab", "BtnYiZheJump", function(obj)
		if IsNil(obj) then
			async_loader:Destroy()
			return
		end

		parent_root:SetActive(true)
		local obj_transform = obj.transform
		obj_transform:SetParent(parent_root.transform, false)
		local node_list = U3DNodeList(obj_transform:GetComponent(typeof(UINameTable)), _self)
		if callback then
			callback(node_list)
		end
	end)
end

-- 设置一折抢购跳转按钮2
function CommonDataManager.SetYiZheBtnJumpTwo(_self, parent_root, callback)
	if nil == _self or nil == parent_root then
		return
	end

	local async_loader = AllocAsyncLoader(_self, "BtnYiZheJumpTwo")
	async_loader:SetIsUseObjPool(true)
	async_loader:Load("uis/views/commonwidgets_prefab", "BtnYiZheJumpTwo", function(obj)
		if IsNil(obj) then
			async_loader:Destroy()
			return
		end

		parent_root:SetActive(true)
		local obj_transform = obj.transform
		obj_transform:SetParent(parent_root.transform, false)
		local node_list = U3DNodeList(obj_transform:GetComponent(typeof(UINameTable)), _self)
		if callback then
			callback(node_list)
		end
	end)
end
