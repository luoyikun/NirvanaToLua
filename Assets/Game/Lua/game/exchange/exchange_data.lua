ExchangeData = ExchangeData or BaseClass()

EXCHANGE_CONVER_TYPE =
{
	DAO_JU = 2,
	XUN_BAO = 3,
	JING_LING = 5,
	HAPP_YTREE = 6,
}

EXCHANGE_PRICE_TYPE =
{
	MOJING = 1,
	SHENGWANG = 2,
	GONGXUN = 3,
	WEI_WANG = 4,
	TREASURE = 5,
	JINGLING = 6,
	HAPPYTREE = 7,
	RONGYAO = 8,
	GUANGHUI = 9,
	JIFEN = 10,
	Blue_lingzhi = 11,
	Purple_lingzhi = 12,
	Orange_lingzhi = 13,
	BOSSSCORE = 14,
	SHENZHOU = 15,
	XUNBAO1 = 16,
	XUNBAO2 = 17,
	XUNBAO3 = 18,
	YUSHI = 19,
	HUNJING = 20,
	GUILDCONTRIBUTE = 21,
	WEIJI = 22,
}

REQUIRE_TYPE = {
	LEVEL = 1,
}
local RES_ENUM = {
	[1] = "ShengWang",
	[2] = "RongYu",
	[5] = "XunBao",
	[6] = "LingChong",
	[7] = "HunaLeShu",
	[8] = "RongYao",
	[9] = "GuangHui",
	[14] = "MiZang",
	[15] = "YiHuo",
	[19] = "YuShi",
	[20] = "HunJing",
	[21] = "Guild",
	[22] = "WeiJi1",
}

function ExchangeData:__init()
	if ExchangeData.Instance then
		print_error("[ExchangeData] Attemp to create a singleton twice !")
	end
	ExchangeData.Instance = self
	self.protocol_come = false
	self.is_show_special_bg = false
	self.convert_record_info = {}
	self.lifetime_record_list = {}
	self.score_list = {}
	self.is_special_item = {}
	self.limit_time_record_list = {}
	self.other_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").other
	self.convert_shop_config = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop

	--积分初始化
	self.score_list[EXCHANGE_PRICE_TYPE.MOJING] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.SHENGWANG] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.GONGXUN] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.WEI_WANG] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.TREASURE] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.JINGLING] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.JIFEN] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.GUANGHUI] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.BOSSSCORE] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.SHENZHOU] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO1] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO2] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO3] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.YUSHI] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.HUNJING] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE] = 0
	self.score_list[EXCHANGE_PRICE_TYPE.WEIJI] = 0

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	RemindManager.Instance:Register(RemindName.Echange, BindTool.Bind(self.CalcExChangeRedPoint, self))
end

function ExchangeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Echange)

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if ExchangeData.Instance then
		ExchangeData.Instance = nil
	end
	self.convert_record_info = {}
	self.score_list = {}
	self.protocol_come = false
	PlayerPrefsUtil.DeleteKey("exchange_prop")
end

function ExchangeData:CalcExChangeRedPoint()
	--先判断功能是否开启
	if not OpenFunData.Instance:CheckIsHide("exchange") then
		return 0
	end

	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("exchange_remind_day") or cur_day

	if cur_day == -1 or cur_day == remind_day then
		return 0
	end
	return 1
end

function ExchangeData:ItemDataChangeCallback(item_id)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if (vo.sex == 1 and item_id == 26617) or (vo.sex == 0 and item_id == 26618) then
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		self.score_list[EXCHANGE_PRICE_TYPE.WEIJI] = num
	end
end

function ExchangeData:OnConvertRecordInfo(protocol)
	self.convert_record_info = protocol.convert_record
	self.lifetime_record_list = protocol.lifetime_record_list
	self.limit_time_record_list = protocol.limittime_record_list
	self.protocol_come = true
end

function ExchangeData:GetLimitTimeRecordList()
	return self.limit_time_record_list
end

function ExchangeData:GetExchangeLimitTimeRecordByConverTypeAndSeq(conver_type, seq)
	if self.limit_time_record_list then
		for k,v in pairs(self.limit_time_record_list) do
			if v.conver_type == conver_type and v.seq == seq then
				return v.timestamp
			end
		end
	end
	return 0
end

function ExchangeData:GetIsHasRestTimeByConverTypeAndSeq(conver_type, seq)
	local timestamp = self:GetExchangeLimitTimeRecordByConverTypeAndSeq(conver_type, seq)
	local exchange_cfg = self:GetExchangeCfgBySeq(conver_type, seq)
	if exchange_cfg then
		if exchange_cfg.limit_conver_time <= 0 then
			return true
		end
		local rest_time = exchange_cfg.limit_conver_time + timestamp - TimeCtrl.Instance:GetServerTime()
		if rest_time > 0 then
			return true
		else
			return false
		end
	end
	return false
end

function ExchangeData:GetExchangeCfgBySeq(conver_type, seq)
	local exchange_cfg = self:GetExchangeCfgByType(conver_type)
	if exchange_cfg then
		for k, v in pairs(exchange_cfg) do
			if v.seq == seq then
				return v
			end
		end
	end
	return nil
end

function ExchangeData:GetIsHasNewLimitExchange()
	local last_limit_time = 0
	local role_vo_level = PlayerData.Instance:GetRoleLevel()
	if self.limit_time_record_list then
		for k, v in pairs(self.limit_time_record_list) do
			if v then
				local exchange_cfg = self:GetExchangeCfgBySeq(v.conver_type, v.seq)
				if exchange_cfg and exchange_cfg.require_value and exchange_cfg.require_value_max then
					if role_vo_level >= exchange_cfg.require_value and role_vo_level <= exchange_cfg.require_value_max then
						local timestamp = exchange_cfg.limit_conver_time + v.timestamp
						if timestamp > last_limit_time then
							conver_type = exchange_cfg.conver_type
							last_limit_time = timestamp
						end
					end
				end
			end
		end
	end
	return last_limit_time
end

function ExchangeData:GetLifeTimeRecordCount()
	local count = 0
	if next(self.lifetime_record_list) then
		count = #self.lifetime_record_list
	end
	return count
end

function ExchangeData:GetConvertRecordInfo()
	return self.convert_record_info
end

function ExchangeData:GetConvertCount(seq, convert_type, price_type)
	for k,v in pairs(self.convert_record_info) do
		if v.seq == seq and v.convert_type == convert_type then
			return v.convert_count
		end
	end
	return 0
end

function ExchangeData:GetLifetimeRecordCount(seq, convert_type, price_type)
	if next(self.lifetime_record_list) then
		for k,v in pairs(self.lifetime_record_list) do
			if v.seq == seq and v.convert_type == convert_type then
				return v.convert_count
			end
		end
	end
	return 0
end

function ExchangeData:OnScoreInfo(protocol)
	self.score_list[EXCHANGE_PRICE_TYPE.MOJING] = protocol.chest_shop_mojing
	self.score_list[EXCHANGE_PRICE_TYPE.SHENGWANG] = protocol.chest_shop_shengwang
	self.score_list[EXCHANGE_PRICE_TYPE.GONGXUN] = protocol.chest_shop_gongxun
	self.score_list[EXCHANGE_PRICE_TYPE.WEI_WANG] = protocol.chest_shop_weiwang
	self.score_list[EXCHANGE_PRICE_TYPE.TREASURE] = protocol.chest_shop_treasure_credit
	self.score_list[EXCHANGE_PRICE_TYPE.JINGLING] = protocol.chest_shop_jingling_credit
	self.score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE] = protocol.chest_shop_happytree_grow
	self.score_list[EXCHANGE_PRICE_TYPE.JIFEN] = protocol.chest_shop_jifen
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = protocol.chest_shop_blue_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = protocol.chest_shop_purple_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = protocol.chest_shop_orange_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.GUANGHUI] = protocol.chest_shop_guanghui
	self.score_list[EXCHANGE_PRICE_TYPE.BOSSSCORE] = protocol.chest_shop_precious_boss_score
	self.score_list[EXCHANGE_PRICE_TYPE.SHENZHOU] = protocol.chest_shop_shenzhouweapon_score
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO1] = protocol.chest_shop_treasure_credit1
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO2] = protocol.chest_shop_treasure_credit2
	self.score_list[EXCHANGE_PRICE_TYPE.XUNBAO3] = protocol.chest_shop_treasure_credit3
	self.score_list[EXCHANGE_PRICE_TYPE.YUSHI] = protocol.chest_shop_zhuanzhi_stone_score
	self.score_list[EXCHANGE_PRICE_TYPE.HUNJING] = protocol.chest_shop_hunjing

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local item_id = vo.sex == 1 and 26617 or 26618
	self.score_list[EXCHANGE_PRICE_TYPE.WEIJI] = ItemData.Instance:GetItemNumInBagById(item_id)

	PlayerData.Instance:SetAttr("guanghui", protocol.chest_shop_guanghui)

	local package_view = PackageCtrl.Instance:GetPackageView()
	if package_view then
		package_view:MoJingChange()
	end
end

function ExchangeData:SetGuildGongXianInfo(num)
	self.score_list[EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE] = num
end

function ExchangeData:SetGuangHuiInfo(num)
	self.score_list[EXCHANGE_PRICE_TYPE.GUANGHUI] = num
end

--获取所有兑换配置
function ExchangeData:GetAllExchangeCfg()
	return ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
end

function ExchangeData:GetUsefulExchageCfg()
	local useful_cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop) do
		useful_cfg[#useful_cfg + 1] = v
	end
	if next(self.lifetime_record_list) then
		for i = #useful_cfg, 1, -1 do
			for k,v in pairs(self.lifetime_record_list) do
				if useful_cfg[i] and useful_cfg[i].seq == v.seq and useful_cfg[i].lifetime_convert_count ~= 0
					and useful_cfg[i].lifetime_convert_count <= v.convert_count
					and useful_cfg[i].conver_type == v.convert_type then
					table.remove(useful_cfg, i)
				end
			end
		end
	end
	return useful_cfg
end

--获取单个兑换配置
function ExchangeData:GetExchangeCfg(item_id, price_type)
	local job = PlayerData.Instance:GetRoleBaseProf()
	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k,v in pairs(item_list) do
		if v.item_id == item_id and v.price_type == price_type and (v.show_limit == job or v.show_limit == 5) then
			return v
		end
	end
end


--获取寻宝单个兑换配置
function ExchangeData:GetXunBaoExchangeCfg(item_id, conver_type)
	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k,v in pairs(item_list) do
		if v.item_id == item_id and v.conver_type == conver_type then
			return v
		end
	end
end


-- 获取兑换翻倍配置
function ExchangeData:GetMultipleCostCfg(convert_count, multiple_cost_id)
	if not convert_count or not multiple_cost_id then return end
	if 0 == multiple_cost_id then return end

	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").multiple_cost_cfg
	for k, v in pairs(item_list) do
		if v.multiple_cost_id == multiple_cost_id and v.times_min <= convert_count and v.times_max >= convert_count then
			return v
		end
	end
	return nil
end

--根据类型获取配置
function ExchangeData:GetExchangeCfgByType(conver_type)
	local data = {}
	local item_list = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	for k,v in pairs(item_list) do
		if v.conver_type == conver_type then
			table.insert(data,v)
		end
	end
	return data
end

function ExchangeData:GetXianShiNumByJobAndType(conver_type, price_type, job)
	local item_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	local xianshi_num = 0
	for k, v in ipairs(item_list) do
		if v[2] == 1 then
			xianshi_num = xianshi_num + 1
		end
	end
	return xianshi_num
end

function ExchangeData:GetItemIdListByJobAndType(conver_type, price_type, job)
	local all_item_cfg = self:GetUsefulExchageCfg()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local item_id_list = {}
	for k, v in pairs(all_item_cfg) do
		local is_xianshi = false
		if open_server_day >= v.from_open_game_day and open_server_day <= v.to_open_game_day then
			is_xianshi = true
		end

		if v.conver_type == conver_type and v.price_type == price_type and (v.show_limit == job or v.show_limit == 5) and is_xianshi then
			local cfg = {v.item_id, v.is_jueban, v}
			item_id_list[#item_id_list + 1] = cfg
		end
	end
	return item_id_list
end

function ExchangeData:IsHasXianShi(conver_type, price_type)
	local job = PlayerData.Instance:GetRoleBaseProf()
	local all_item_cfg = self:GetUsefulExchageCfg()
	local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local item_id_list = {}
	local num = 0
	for k, v in pairs(all_item_cfg) do
		local is_xianshi = false
		if open_server_day >= v.from_open_game_day and open_server_day <= v.to_open_game_day then
			is_xianshi = true
		end
		if v.conver_type == conver_type and v.price_type == price_type and (v.show_limit == job or v.show_limit == 5) and is_xianshi then
			if v.is_jueban == 1 then
				num = num + 1
			end
		end
	end
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("IsHasXianShi".. conver_type .. price_type) or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day and num > 0 then
		return true
	end	
	return false
end

function ExchangeData:GetItemListByJobAndIndex(conver_type, price_type, job, index, is_special)
	local item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	local num = is_special and 2 or 4
	local job_id_list = {}
	if index == 1 then
		for i = 1, num do
			job_id_list[#job_id_list + 1] = item_id_list[i]
		end
		return job_id_list
	end

	for i = 1, num do
		if item_id_list[(index - 1)*num + i] == nil then
			item_id_list[(index - 1)*num + i] = {0, 0}
		end
		job_id_list[#job_id_list + 1] = item_id_list[(index - 1)*num + i]
	end
	return job_id_list
end

function ExchangeData:GetIsSpecialShow(conver_type, price_type, job)
	local item_id_list = self:GetItemIdListByJobAndType(conver_type, price_type, job)
	self.is_special_item = {}
	if item_id_list then
		for k,v in pairs(item_id_list) do
			if v and v[2] == 1 then			--有倒计时和标签
				self.is_special_item = v[3]
				self.is_show_special_bg = true
				return true
			end
		end
		for k,v in pairs(item_id_list) do
			if v and v[3] and v[3].is_xingxiang_show == 1 then
				self.is_special_item = v[3]
				self.is_show_special_bg = true
				return true
			end
		end
	end
	self.is_show_special_bg = false
	return false
end

function ExchangeData:GetSpecialShowItem()
	return self.is_special_item
end

function ExchangeData:GetIsShowSpecialBg()
	return self.is_show_special_bg
end


--获取物品被动消耗类配置
function ExchangeData:GetItemOtherCfg(item_id)
	return ConfigManager.Instance:GetAutoItemConfig("other_auto")[item_id]
end

function ExchangeData:GetScoreList()
	return self.score_list
end

function ExchangeData:GetCurrentScore(price_type)
	local current_score = 0
	if price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		current_score = PlayerData.Instance.role_vo.cross_honor or 0 
	else
		current_score = self.score_list[price_type] or 0
	end
	return current_score
end

function ExchangeData:GetLackScoreTis(price_type)
	return Language.Exchange.NotRemin[price_type] or ""
end

function ExchangeData:GetExchangeRes(price_type)
	return RES_ENUM[price_type] or ""
end

function ExchangeData:GetMultilePrice(item_id, price_type)
	local item_info = self:GetExchangeCfg(item_id, price_type)
	local conver_value = self:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, price_type)
	local multiple_cfg = self:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
	local multiple_time = 1
	local price_multile = 0
	local price = 0
	if multiple_cfg then
		multiple_time = multiple_cfg.times_max - conver_value
		price_multile = multiple_cfg.price_multile
		price = item_info.price * (price_multile == 0 and 1 or price_multile)
	end
	return price
end

--是否强制显示特效
function ExchangeData:IsShowEffect(item_id)
	item_id = item_id or 0
	local flag = false
	if self.other_config then
		for k,v in pairs(self.other_config) do
			if v.item_special == item_id then
				flag = true
				break
			end
		end
	end
	return flag
end

function ExchangeData:GetItemListByConverType(conver_type)
	local cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	local list_cfg = {}

	for _, v in pairs(cfg) do
		if v.conver_type == conver_type then
			table.insert(list_cfg, v)
		end
	end

	return list_cfg
end

function ExchangeData:GetHunYinExchangeCfg()
	local hunyin_exchange_cfg = {}
	for k,v in pairs(self.convert_shop_config) do
		if 1 == v.conver_type then
			table.insert(hunyin_exchange_cfg, v)
		end
	end
	return hunyin_exchange_cfg
end

function ExchangeData:SetLingzhi(protocol)
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] or 0
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] or 0
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] or 0
	
	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] + protocol.chest_shop_blue_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] + protocol.chest_shop_purple_lingzhi
	self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] + protocol.chest_shop_orange_lingzhi
end

function ExchangeData:GetAllLingzhi()
	local lingzhi_data = {}
	lingzhi_data["blue"] = 	self.score_list[EXCHANGE_PRICE_TYPE.Blue_lingzhi] or 0 
	lingzhi_data["purple"] = self.score_list[EXCHANGE_PRICE_TYPE.Purple_lingzhi] or 0
	lingzhi_data["orange"] = self.score_list[EXCHANGE_PRICE_TYPE.Orange_lingzhi] or 0
	return lingzhi_data
end

function ExchangeData:GetUseJueBanExchageCfg()
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	local can_exchange = true
	local exchange_cfg = ConfigManager.Instance:GetAutoConfig("convertshop_auto").convert_shop
	if next(self.lifetime_record_list) then
		for i = #exchange_cfg, 1, -1 do
			for k,v in pairs(self.lifetime_record_list) do
				if exchange_cfg[i] and exchange_cfg[i].seq == v.seq and exchange_cfg[i].lifetime_convert_count ~= 0
					and exchange_cfg[i].lifetime_convert_count <= v.convert_count
					and exchange_cfg[i].price_type == 9 
					and exchange_cfg[i].is_jueban == 1 
					and is_activity_open then
					can_exchange = false
				end
			end
		end
	else
		can_exchange = self.protocol_come
	end
	return can_exchange
end

function ExchangeData:GetCanOpenTabIndex()
	local tab_index = 0
	if OpenFunData.Instance:CheckIsHide("shengwang") then
		tab_index = TabIndex.exchange_shengwang
	elseif OpenFunData.Instance:CheckIsHide("raoyao") then
		tab_index = TabIndex.exchange_rongyao
	-- elseif OpenFunData.Instance:CheckIsHide("hunqi") then
	-- 	tab_index = TabIndex.exchange_yihuo
	-- elseif OpenFunData.Instance:CheckIsHide("forge_jade") then
	-- 	tab_index = TabIndex.exchange_yushi
	elseif OpenFunData.Instance:CheckIsHide("spiritview") then
		tab_index = TabIndex.exchange_jingling
	elseif OpenFunData.Instance:CheckIsHide("guild_contribute") then
		tab_index = TabIndex.exchange_guildcontribute
	elseif OpenFunData.Instance:CheckIsHide("exchange_huiji") then
		tab_index = TabIndex.exchange_weiji
	end
	return tab_index
end