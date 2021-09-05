require("game/other/other_data")
OtherCtrl = OtherCtrl or BaseClass(BaseController)

MODULE_OPERATE_TYPE = {
	OP_MOUNT_UPGRADE = 1,						-- 坐骑进阶
	OP_MOUNT_UPBUILD = 2,						-- 骑兵打造
	OP_Wing_UPEVOL = 6,							-- 羽翼进化
	OP_EQUIP_STRENGTHEN = 7,					-- 装备强化
	OP_STONE_UPLEVEL = 8 ,						-- 宝石升级成功
	OP_FISH_POOL_EXTEND_CAPACITY_SUCC = 9,		-- 鱼池扩展成功
	OP_WING_UPGRADE = 10,
	OP_MOUNT_FLYUP = 11,						-- 坐骑飞升
	OP_XIANNV_HALO_UPGRADE = 12,				-- 仙女守护
	OP_JINGLING_UPGRADE = 17,					-- 精灵升阶
	OP_SHENZHUANG_JINJIE = 18,					-- 神装进阶
	OP_BABY_JIE_UPGRADE  = 19,                  -- 宝宝进阶
	OP_PET_JIE_UPGRADE = 20,					-- 宠物自动进阶
	OP_QINGYUAN_JIE_UPGRADE  = 21 ,             -- 情缘进阶
	OP_HUASHEN_UPLEVEL = 22,					-- 化神进阶
	OP_MULTI_MOUNT_UPGRADE = 24,				-- 双人坐骑进阶
	OP_WUSHANG_EQUIP_UPSTAR = 25,               -- 跨服装备升星
	OP_JINGLING_HALO_UPSTAR = 26,				-- 精灵光环升级
	OP_HALO_UPGRADE = 29,						-- 进阶光环升级
	OP_SHENGONG_UPGRADE = 30,					-- 进阶神弓升级
	OP_SHENYI_UPGRADE = 31,						-- 进阶神翼升级
	OP_JINGLING_FAZHEN_UPGRADE = 33,			-- 精灵法阵升阶
	OP_SHENGONG_UPSTAR = 34,					-- 神弓升星
	OP_SHENYI_UPSTAR = 35,						-- 神翼升星
	OP_HUASHEN_UPGRADE_SPIRIT = 36,				-- 化神精灵进阶
	OP_FIGHT_MOUNT_UPGRADE = 37,				-- 战斗坐骑进阶
	OP_LIEMING_CHOUHUN = 38,					-- 猎命抽魂结果
	OP_MOUNT_UPSTAR = 39,						-- 坐骑升星
	OP_WING_UPSTAR = 40,						-- 羽翼升星
	OP_HALO_UPSTAR = 41,						-- 光环升星
	OP_FIGHT_MOUNT_UPSTAR = 42,					-- 战骑升星
	OP_SHEN_BING_UPGRADE = 43,					-- 神兵进阶
	OP_SHENZHOU_WEAPON = 44,					-- 魂器
	OP_UP_ETERNITY = 45,						-- 永恒装备升级
	OP_RA_MAPHUNT_AUTO_FLUSH = 46,				-- 地图寻宝自动刷新
	OP_FOOTPRINT_UPGRADE = 47,					-- 足迹升阶
	OP_FOOTPRINT_UPSTAR = 48,					-- 足迹升星
	OP_CLOAK_UPLEVEL = 49,						-- 披风升级
	OP_FISHING_REQ = 50,            			-- 钓鱼请求
	OP_STEAL_FISH_RESULT = 51,         			-- 偷鱼结果
	OP_ELEMENT_HEART_UPGRADE = 52,       		-- 元素进阶
	OP_ELEMENT_TEXTURE_UPGRADE = 53,      		-- 元素之纹升级
	OP_ELEMENT_EQUIP_UPGRADE = 54,        		-- 元素装备进阶
	OP_SHIZHUANG_UPGRADE = 55,					-- 时装进阶
	OP_FABAO_UPGRADE = 56,						-- 法宝进阶
	OP_FABAO_SPECIAL_IMG_UPGRADE = 57,
	OP_SHENBING_SPECIAL_IMG_UPGRADE = 58,       --神兵特殊形象进阶
	OP_FEIXIAN_COMPOSE = 61,					-- 飞仙装备合成
	OP_FEIXIAN_UPLEVEL = 62,					-- 飞仙装备升级
	OP_BABY_JL_UPGRADE = 63,          			-- 宝宝精灵进阶
	OP_ONEKEY_LIEMING_GAIMING = 64,				-- 精灵命魂-自动改命-改命
	OP_ONEKEY_LIEMING_CHOUHUN = 65,				-- 精灵命魂-自动改命-抽魂
	OP_YAOSHI_UPGRADE = 66,						-- 外观-腰饰进阶
	OP_TOUSHI_UPGRADE = 67,						-- 外观-头饰进阶
	OP_QILINBI_UPGRADE = 68,					-- 外观-麒麟臂进阶
	OP_MASK_UPGRADE = 69,						-- 外观-面饰进阶
	OP_ZHUANZHI_STONE_REFINE = 70, 				-- 玉石精炼(服务端加了，客户端处理了，没跑这里)
	OP_ZHUANZHI_FULING = 71,					-- 转职装备附灵(服务端加了，客户端处理了，没跑这里)
	OP_RA_FANFAN_REFRESH = 72,					-- 寻字好礼
	OP_SHENQI_SHENGBING_UPLEVEL = 73, 			-- 神兵升级
	OP_SHENQI_BAOJIA_UPLEVEL = 74,				-- 宝甲升级
	OP_DELETE_PROFESS = 75,						-- 告白墙删除结果
	OP_UPLEVEL_RUNE = 76,						-- 符文升级
	OP_JINGLING_SKILL_REFRESH = 77,				-- 精灵技能刷新
   	OP_GREATE_SOLDIER_SLOT_UPLEVEL = 78,    	-- 名将槽位升级
   	OP_JINGLING_LINGHUN_UPLEVEL = 79,			-- 精灵灵魂升级
	OP_LING_ZHU	= 200,							-- 灵珠进阶(200+进阶系统类型)
	OP_XIAN_BAO = 201,							-- 仙宝进阶(200+进阶系统类型)
	OP_LING_TONG = 202,							-- 灵童进阶(200+进阶系统类型)
	OP_LING_GONG = 203,							-- 灵弓进阶(200+进阶系统类型)
	OP_LING_QI = 204,							-- 灵骑进阶(200+进阶系统类型)
	OP_WEI_YAN = 205,							-- 尾焰进阶(200+进阶系统类型)
	OP_SHOU_HUAN = 206,							-- 手环进阶(200+进阶系统类型)
	OP_TAIL = 207,								-- 尾巴进阶(200+进阶系统类型)
	OP_FLY_PET = 208,							-- 飞宠进阶(200+进阶系统类型)
}
REPLY_TYPE = {
	NT_REPLY_TYPE_SHENGE = 1,					-- 神格系统
}

local SHOP_MODE = {
	[1] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_1,
	[10] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_10,
	[50] = CHEST_SHOP_MODE.CHEST_GENERAL_MODE_50,
}

function OtherCtrl:__init()
	OtherCtrl.Instance = self

	self.get_item_view = QuickBuy.New()
	self.data = OtherData.New()
	self:RegisterEvent()
	self:RegisterAllProtocals()
end

function OtherCtrl:__delete()
	self.get_item_view:DeleteMe()
	self.get_item_view = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	OtherCtrl.Instance = nil
end

function OtherCtrl:GetAutoBuyFlag()
	return self.get_item_view:GetAutoBuyFlag()
end

function OtherCtrl:SetAutoBuyFlag(flag)
	self.get_item_view:SetAutoBuyFlag(flag)
end

function OtherCtrl:RegisterEvent()
	self:BindGlobalEvent(KnapsackEventType.KNAPSACK_LECK_ITEM, BindTool.Bind1(self.OpenGetItemView, self))
end

function OtherCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCOperateResult, "OnOperateResult")
	self:RegisterProtocol(SCRoleMsgReply, "OnSCRoleMsgReply")
	self:RegisterProtocol(SCDrawResult, "OnSCDrawResult")
end
function OtherCtrl:OnSCRoleMsgReply(protocol)
	if protocol.typ == REPLY_TYPE.NT_REPLY_TYPE_SHENGE then 
		if nil ~= ShenGeCtrl then 
			ShenGeCtrl.Instance:OnShenQuChange(protocol.value)
		end
	end

end
function OtherCtrl:OnOperateResult(protocol)
	GlobalEventSystem:Fire(OtherEventType.OPERATE_RESULT, protocol.operate, protocol.result, protocol.param1, protocol.param2)
	if MODULE_OPERATE_TYPE.OP_MOUNT_UPGRADE == protocol.operate then
		-- 坐骑进阶
		if nil ~= AdvanceCtrl then
			MountData.Instance:SetGradeBlessVal(protocol.param1)
			AdvanceCtrl.Instance:MountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MOUNT_UPSTAR == protocol.operate then
		-- 坐骑升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:MountUpgradeResult(protocol.result, protocol.param1)
		end
	elseif MODULE_OPERATE_TYPE.OP_FOOTPRINT_UPGRADE == protocol.operate then
		-- 足迹进阶
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:FootUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FOOTPRINT_UPSTAR == protocol.operate then
		-- 足迹升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:FootUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_WING_UPSTAR == protocol.operate then
		-- 羽翼升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:WingUpgradeResult(protocol.result)
		end
		elseif MODULE_OPERATE_TYPE.OP_WING_UPGRADE == protocol.operate then
		-- 羽翼进阶
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:WingUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_HALO_UPGRADE == protocol.operate then
		-- 光环进阶
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:HaloUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_HALO_UPSTAR == protocol.operate then
		-- 光环升星
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:HaloUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_YAOSHI_UPGRADE == protocol.operate then	-- 腰饰进阶
		if nil ~= WaistCtrl.Instance then
			WaistCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_TOUSHI_UPGRADE == protocol.operate then	-- 头饰进阶
		if nil ~= TouShiCtrl.Instance then
			TouShiCtrl.Instance:UpGradeResult(protocol.result)
		end

	elseif MODULE_OPERATE_TYPE.OP_QILINBI_UPGRADE == protocol.operate then	-- 麒麟臂进阶
		if nil ~= QilinBiCtrl.Instance then
			QilinBiCtrl.Instance:UpGradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MASK_UPGRADE == protocol.operate then		-- 面饰进阶
		if nil ~= MaskCtrl.Instance then
			MaskCtrl.Instance:UpGradeResult(protocol.result)
		end

	-- 灵珠进阶、仙宝进阶、灵弓进阶、灵骑进阶、尾焰进阶、手环进阶、尾巴、飞宠、(类型从200开始)
	elseif protocol.operate >= 200 then
		if nil ~= UpgradeCtrl.Instance then
			UpgradeCtrl.Instance:UpGradeResult(protocol.operate, protocol.result)
		end

	elseif  MODULE_OPERATE_TYPE.OP_SHENGONG_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_SHENGONG_UPGRADE == protocol.operate then
		if nil ~= ShengongCtrl then
			ShengongCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_XIANNV_HALO_UPGRADE == protocol.operate then
		if nil ~= GoddessShouhuCtrl then
			GoddessShouhuCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_SHENYI_UPSTAR == protocol.operate or MODULE_OPERATE_TYPE.OP_SHENYI_UPGRADE == protocol.operate then
		if nil ~= ShenyiCtrl then
			ShenyiCtrl.Instance:OnUppGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_JINGLING_LINGHUN_UPLEVEL == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnGetUpGradeResult(protocol.result, protocol.param1, protocol.param2)
		end
	elseif  MODULE_OPERATE_TYPE.OP_JINGLING_FAZHEN_UPGRADE == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnFazhenUppGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_JINGLING_HALO_UPSTAR == protocol.operate then
		if nil ~= SpiritCtrl then
			SpiritCtrl.Instance:OnHaloUpGradeOptResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_HUASHEN_UPGRADE_SPIRIT == protocol.operate then
		if nil ~= SpiritCtrl then
			HuashenCtrl.Instance:OnSpiritUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ONEKEY_LIEMING_GAIMING == protocol.operate then
		if nil ~= SpiritCtrl.Instance and nil ~= SpiritData.Instance then
			local state = SpiritData.Instance:GetQuickChangeLifeState()
			if state ~= QUICK_FLUSH_STATE.GAI_MING_ZHONG then return end
			SpiritCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ONEKEY_LIEMING_CHOUHUN == protocol.operate then
		if nil ~= SpiritCtrl.Instance and nil ~= SpiritData.Instance then
			local state = SpiritData.Instance:GetQuickChangeLifeState()
			if state ~= QUICK_FLUSH_STATE.CHOU_HUN_ZHONG then return end
			SpiritCtrl.Instance:OnQuickGaiMingResult(protocol.result)
		end
	elseif  MODULE_OPERATE_TYPE.OP_FIGHT_MOUNT_UPSTAR == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnFightMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FIGHT_MOUNT_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:OnFightMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_LIEMING_CHOUHUN == protocol.operate then
		if 1 == protocol.result then return end

		local item_id = 22606
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
			return
		end

		local func = function(_item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
	elseif	MODULE_OPERATE_TYPE.OP_HUASHEN_UPLEVEL == protocol.operate then
		if nil ~= HuashenCtrl then
			HuashenCtrl.Instance:OnUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_SHEN_BING_UPGRADE == protocol.operate then
		if nil ~= LingRenCtrl then
			LingRenCtrl.Instance:OnUpgradeResult(protocol.result)
		end
	elseif	MODULE_OPERATE_TYPE.OP_SHENZHOU_WEAPON == protocol.operate then
		if nil ~= HunQiCtrl then
			HunQiCtrl.Instance:HunQiUpGrade(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_RA_FANFAN_REFRESH == protocol.operate then
		if nil ~= PuzzleCtrl.Instance then
			PuzzleCtrl.Instance:OnFastFilpResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_RA_MAPHUNT_AUTO_FLUSH == protocol.operate  then
		if nil ~= MapFindCtrl then
			if protocol.result == 1 and MapFindCtrl.Instance:GetRush() then
				MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH,MapFindData.Instance:GetSelect(),5)
			else
				MapFindCtrl.Instance:EndRush()
			end
		end
	elseif MODULE_OPERATE_TYPE.OP_CLOAK_UPLEVEL == protocol.operate then
		-- 披风升级
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:CloakUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_LINGREN_UPLEVEL == protocol.operate then
		-- 灵刃升级
		if nil ~= LingRenCtrl then
			LingRenCtrl.Instance:OnUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_MULTI_MOUNT_UPGRADE == protocol.operate then
		if nil ~= MultiMountCtrl then
			MultiMountCtrl.Instance:OnMultiMountUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ELEMENT_HEART_UPGRADE == protocol.operate then
		if nil ~= SymbolCtrl then
			SymbolCtrl.Instance:OnElementHeartUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ELEMENT_TEXTURE_UPGRADE == protocol.operate then
		if nil ~= SymbolCtrl then
			SymbolCtrl.Instance:OnElementTextureUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_ELEMENT_EQUIP_UPGRADE == protocol.operate then
		if nil ~= SymbolCtrl then
			SymbolCtrl.Instance:OnYuanZhuangUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHIZHUANG_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:ShizhuangUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FABAO_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			AdvanceCtrl.Instance:FaBaoUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FABAO_SPECIAL_IMG_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			-- AdvanceCtrl.Instance:ShizhuangUpgradeResult(protocol.result)
		end
		--神兵
	elseif MODULE_OPERATE_TYPE.OP_SHENBING_SPECIAL_IMG_UPGRADE == protocol.operate then
		if nil ~= AdvanceCtrl then
			--print_error("asd +++++++++++")
			 AdvanceCtrl.Instance:ShenBingUpgradeResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_FEIXIAN_COMPOSE == protocol.operate then
		if nil ~= ForgeCtrl then 
			ForgeCtrl.Instance:FeixianOrangeCallBack(protocol)
		end
	elseif MODULE_OPERATE_TYPE.OP_FEIXIAN_UPLEVEL == protocol.operate then
		if nil ~= ForgeCtrl then 
			ForgeCtrl.Instance:FeixianRedCallBack(protocol)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_SHENGBING_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl.Instance then
			ShenqiCtrl.Instance:OnShenbingUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_SHENQI_BAOJIA_UPLEVEL == protocol.operate then
		if nil ~= ShenqiCtrl.Instance then
			ShenqiCtrl.Instance:OnBaojiaUpGradeOptResult(protocol.result)
		end
	elseif MODULE_OPERATE_TYPE.OP_DELETE_PROFESS == protocol.operate then
		if nil ~= BiaoBaiQiangCtrl then
			BiaoBaiQiangCtrl.Instance:BiaoBaiQiangDelResult(protocol)
		end
	elseif MODULE_OPERATE_TYPE.OP_UPLEVEL_RUNE == protocol.operate then
		if nil ~= RuneCtrl then
			RuneCtrl.Instance:OnRuneInlayTips(protocol.result, protocol.param1, protocol.param2)
		end
	elseif MODULE_OPERATE_TYPE.OP_JINGLING_SKILL_REFRESH == protocol.operate then
		if nil ~= SpiritCtrl then
			local spirit_skill_big_view = SpiritCtrl.Instance:GetSpiritSkillBigView()
			if spirit_skill_big_view and spirit_skill_big_view:IsOpen() then
				SpiritData.Instance:SetIsFlushSucc(protocol.result)
				spirit_skill_big_view:FlushAutoButton()
			end
		end
	end
end

function OtherCtrl:OpenGetItemView(item_id, item_count)
	print_log("物品不足-->> id : ", item_id)

	if item_id == 27583 then
		TipsCtrl.Instance:ShowLackDiamondView(nil, Language.Recharge.LeckOfFlyShoes)
		print_log("小飞鞋不足")
		return
	end

	if item_id == 90054 then
		-- TipsCtrl.Instance:ShowLackDiamondView()
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
		print_log("绑定元宝不足")
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		print_log("物品不存在，请更新配置-->> id : ", item_id)
		return
	else
		if 31 == item_cfg.search_type then	--勾玉不弹获取提示
			return
		end
	end
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	if 0 == tonumber(way[1]) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		item_count = item_count or 1
		local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if shop_item_cfg == nil then
			item_cfg = ItemData.Instance:GetItemConfig(item_id)
			TipsCtrl.Instance:ShowSystemMsg(ToColorStr(item_cfg.name, TEXT_COLOR.GREEN).."不足")
			print("缺少物品ID:",item_id)
		else
			local func = function(item_id2, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func,item_id)
		end
	else
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	end
end

function OtherCtrl:OnSCDrawResult(protocol)
	local reason = protocol.draw_reason
	if reason == DRAW_REASON.DRAW_REASON_BEAUTY then
		-- BeautyData.Instance:SetPrayItemList(protocol.item_info_list)
		-- if protocol.item_count == 1 then
		-- 	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY1, true)
		-- else
		-- 	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_BEAUTY_PRAY10, true)
		-- end
	elseif reason == DRAW_REASON.DRAW_REASON_GREATE_SOLDIER then
		BianShenData.Instance:SetItemList(protocol.item_info_list)
		TipsCtrl.Instance:ShowTreasureView(SHOP_MODE[protocol.item_count])
		-- GlobalEventSystem:Fire(OtherEventType.CHEST_SHOP_ITEM_LIST, protocol.item_info_list)
	elseif reason == DRAW_REASON.DRAW_REASON_HAPPY_DRAW then
	-- 	HappyBargainData.Instance:SetDrawResultList(protocol)
	-- 	TipsCtrl.Instance:ShowTreasureView(HappyBargainData.Instance:GetChestShopMode())
	end
end