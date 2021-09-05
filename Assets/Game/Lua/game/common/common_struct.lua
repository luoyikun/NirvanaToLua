-----------------------------------------------------
-- 通用结构体
-----------------------------------------------------
CommonStruct = CommonStruct or {}

-- 属性
function CommonStruct.AttributeNoUnderline()
	return {
		maxhp = 0,									-- 血量上限
		gongji = 0,									-- 攻击
		fangyu = 0,									-- 防御
		mingzhong = 0,								-- 命中
		shanbi = 0,									-- 闪避
		baoji = 0,									-- 暴击
		jianren = 0,								-- 抗暴
		movespeed = 0,								-- 移动速度
		per_jingzhun = 0,							-- 破甲
		per_baoji = 0,								-- 暴伤(暴击率)
		per_kang_bao = 0,							-- 抗暴率
		per_pofang = 0,								-- 增伤
		per_mianshang = 0,							-- 免伤
		goddess_gongji = 0,							-- 女神攻击(附加伤害)
		dikang_shanghai = 0,						-- 抵抗伤害
		constant_zengshang = 0,						-- 固定增伤
		constant_mianshang = 0,						-- 固定免伤
		huixinyiji = 0,								-- 会心一击率
		huixinyiji_hurt_per = 0,					-- 会心一击伤害率
		pvp_jianshang = 0,							-- pvp减伤
		pvp_zengshang = 0,							-- pvp增伤
		pve_jianshang = 0,							-- pve减伤
		pve_zengshang = 0,							-- pve增伤
		per_baoji_hurt = 0, 						-- 暴击伤害万分比
		per_kang_bao_hurt = 0, 						-- 暴击伤害抵抗万分比
		zhufuyiji_per = 0, 							-- 祝福一击率
		gedang_per = 0, 							-- 格挡率
		gedang_dikang_per = 0, 						-- 格挡抵抗率
		gedang_jianshang = 0, 						-- 格挡减伤
		skill_zengshang = 0, 						-- 技能增伤
		skill_jianshang = 0, 						-- 技能减伤
		mingzhong_per = 0, 							-- 基础命中率
		shanbi_per = 0, 							-- 基础闪避率
		skill_cap_per = 0, 							-- 技能战力万分比
	}
end

-- 属性
function CommonStruct.Attribute()
	return {
		max_hp = 0,									-- 血量上限
		gong_ji = 0,								-- 攻击
		fang_yu = 0,								-- 防御
		ming_zhong = 0,								-- 命中
		shan_bi = 0,								-- 闪避
		bao_ji = 0,									-- 暴击
		jian_ren = 0,								-- 抗暴
		move_speed = 0,								-- 移动速度
		per_jingzhun = 0,							-- 破甲
		per_baoji = 0,								-- 暴伤
		per_kang_bao = 0,							-- 抗暴率
		per_pofang = 0,								-- 增伤
		per_mianshang = 0,							-- 免伤
		goddess_gongji = 0,							-- 女神攻击(附加伤害)
		dikang_shanghai = 0,						-- 抵抗伤害
		constant_zengshang = 0,						-- 固定增伤
		constant_mianshang = 0,						-- 固定免伤
		huixinyiji = 0,								-- 会心一击率
		huixinyiji_hurt_per = 0,					-- 会心一击伤害率
		pvp_jianshang = 0,							-- pvp减伤
		pvp_zengshang = 0,							-- pvp增伤
		pve_jianshang = 0,							-- pve减伤
		pve_zengshang = 0,							-- pve增伤
		per_baoji_hurt = 0, 						-- 暴击伤害万分比
		per_kang_bao_hurt = 0, 						-- 暴击伤害抵抗万分比
		zhufuyiji_per = 0, 							-- 祝福一击率
		gedang_per = 0, 							-- 格挡率
		gedang_dikang_per = 0, 						-- 格挡抵抗率
		gedang_jianshang = 0, 						-- 格挡减伤
		skill_zengshang = 0, 						-- 技能增伤
		skill_jianshang = 0, 						-- 技能减伤
		mingzhong_per = 0, 							-- 基础命中率
		shanbi_per = 0, 							-- 基础闪避率		
		skill_cap_per = 0, 							-- 技能战力万分比		
	}
end

-- 属性
function CommonStruct.QiBinDunjiaAttribute()
	return {
		max_hp = 0,									-- 血量上限
		gong_ji = 0,								-- 攻击
		fang_yu = 0,								-- 防御
		ming_zhong = 0,								-- 命中
		shan_bi = 0,								-- 闪避
		bao_ji = 0,									-- 暴击
		jian_ren = 0,								-- 抗暴
		move_speed = 0,								-- 移动速度
		per_jingzhun = 0,							-- 破甲
		per_baoji = 0,								-- 暴伤
		per_kang_bao = 0,							-- 抗暴率
		per_pofang = 0,								-- 增伤
		per_mianshang = 0,							-- 免伤
		goddess_gongji = 0,							-- 女神攻击(附加伤害)
		dikang_shanghai = 0,						-- 抵抗伤害
		constant_zengshang = 0,						-- 固定增伤
		constant_mianshang = 0,						-- 固定免伤
		huixinyiji = 0,								-- 会心一击率
		huixinyiji_hurt_per = 0,					-- 会心一击伤害率
		pvp_jianshang = 0,							-- pvp减伤
		pvp_zengshang = 0,							-- pvp增伤
		pve_jianshang = 0,							-- pve减伤
		pve_zengshang = 0,							-- pve增伤
		per_baoji_hurt = 0, 						-- 暴击伤害万分比
		per_kang_bao_hurt = 0, 						-- 暴击伤害抵抗万分比
		zhufuyiji_per = 0, 							-- 祝福一击率
		gedang_per = 0, 							-- 格挡率
		gedang_dikang_per = 0, 						-- 格挡抵抗率
		gedang_jianshang = 0, 						-- 格挡减伤
		skill_zengshang = 0, 						-- 技能增伤
		skill_jianshang = 0, 						-- 技能减伤
		mingzhong_per = 0, 							-- 基础命中率
		shanbi_per = 0, 							-- 基础闪避率		
		skill_cap_per = 0, 							-- 技能战力万分比		
		exp = 0,
		level = 0,
		need_exp = 0,
	}
end


-- 进阶属性
function CommonStruct.AdvanceAttribute()
	return {
		mount_attr = 0,							    -- 坐骑
        wing_attr = 0,								-- 羽翼
        halo_attr = 0,								-- 光环
        shengong_attr = 0,							-- 神弓
        shenyi_attr = 0,							-- 神翼
        wuqi_arrt = 0                               -- 武器
	}
end

-- 进阶加成属性
function CommonStruct.AdvanceAddbute()
	return {
		mount_add = 0,								-- 坐骑
        wing_add = 0,								-- 羽翼
        halo_add = 0,								-- 光环
        shengong_add = 0,							-- 神弓
        shenyi_add = 0,								-- 神翼
        footprint_add = 0,							-- 足迹
        fightmount_add = 0,							-- 战斗坐骑
	}
end

-- 物品参数
function CommonStruct.ItemParamData()
	return {
		quality = 0,								-- 品质
		strengthen_level = 0,						-- 强化等级
		shen_level = 0,								-- 神铸等级
		fuling_level = 0,							-- 附灵等级
		star_level = 0,								-- 升星等级
		has_lucky = 0,								-- 幸运属性
		fumo_id = 0,								-- 附魔id
		xianpin_type_list = {},						-- 仙品属性
		eternity_level = 0,							-- 永恒等级
		angel_level = 0, 							-- 大天使等级（神装等级）
	}
end

-- 物品数据
function CommonStruct.ItemDataWrapper()
	return {
		item_id = 0,
		num = 0,
		is_bind = 0,
		has_param = 0,
		invalid_time = 0,
		gold_price = 0,
		index = 0,
		param = CommonStruct.ItemParamData()
	}
end

-- 铜币
function CommonStruct.CoinDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_BIND_COIN
	vo.num = num
	return vo
end

-- 绑定元宝
function CommonStruct.BindGoldDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL
	vo.num = num
	return vo
end

-- 经验
function CommonStruct.ExpDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP
	vo.num = num
	return vo
end
-- 女娲石
function CommonStruct.NvWaShiDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_NVWASHI
	vo.num = num
	return vo
end

-- 仙魂
function CommonStruct.XianHunDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_XIANHUN
	vo.num = num
	return vo
end

-- 真气
function CommonStruct.YuanLiDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_YUANLI
	vo.num = num
	return vo
end

--限时称号
function CommonStruct.TimeLimitTitleInfo()
	return {
		item_id = 0,
		cost = 0,
		left_time = 0,
		can_fetch = false,					-- 是否可领取
		from_panel = "",					-- 来自界面 TIME_LIMIT_TITLE_PANEL
		call_back = nil,					-- 回调类型 TIME_LIMIT_TITLE_CALL_TYPE
	}
end

--幻化超级战力提示
function CommonStruct.SpecialHuanHuaTipInfo()
	return {
		max_hp = 0,									-- 生命
		gong_ji = 0,								-- 攻击
		fang_yu = 0,								-- 防御
		desc = "",									-- 描述
	}
end

function CommonStruct.UUID()
	return {
		plat_type = 0,
		role_id = 0,
	}
end