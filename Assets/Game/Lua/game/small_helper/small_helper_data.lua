SmallHelperData = SmallHelperData or BaseClass()

function SmallHelperData:__init()
	if SmallHelperData.Instance then
		print_error("[SmallHelperData] 尝试创建第二个单例模式")
		return
	end
	SmallHelperData.Instance = self
	self.config = {
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS, name = "easy_boss",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS, name = "hard_boss",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_BABY_BOSS, name = "baby_boss",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_SUIT_BOSS, name = "suit_boss",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS, name = "shenmo_boss",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE, name = "sprint_meet",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_ESCORT_FAIRY, name = "escort",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_FB, name = "exp_fb",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB, name = "tower_def",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_CYCLE_TASK, name = "run_ring",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_TASK, name = "exp_task",},
	-- 	{complete_type = LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_GUILD_TASK, name = "guild_task",},
	}

	self.save_data = {}
	self.count = -1
	self.chest_shop_mode = -1
	
	RemindManager.Instance:Register(RemindName.SmallHelper, BindTool.Bind(self.GetRemind, self))
end

function SmallHelperData:__delete()
	RemindManager.Instance:UnRegister(RemindName.SmallHelper)
	SmallHelperData.Instance = nil
	self.count = nil 
	self.chest_shop_mode = nil
end

function SmallHelperData:GetRemind()
	self:GetShowConfig()
	if self.config ~= nil and next(self.config) then
		for k, v in pairs(self.config) do		
			if self:IsCanHelp(v.complete_type) then
				return 1
			end
		end
	end 
	return 0
end

function SmallHelperData:GetShowConfig()
	local task_config = ConfigManager.Instance:GetAutoConfig("little_helper_auto").helper or {}
	local config = {}
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.cfg_by_type = {}
	for k, v in pairs(task_config) do
		if v ~= nil then
			if day >= v.opengame_day then
				if vo.level >= v.level_left and vo.level <= v.level_right then
					if self:IsCanHelp(v.complete_type) then
						table.insert(config, v)
						self.cfg_by_type[v.complete_type] = v
					end
				end
			end
		end
	end
	self.config = config
	return config
end

function SmallHelperData:GetConfigByType(task_type)
	return self.cfg_by_type[task_type] or {}
end

function SmallHelperData:GetBuyNumPhase(fb_type)
	local has_times, can_buy_times = 0, 0
	local layer = PhaseFuBenTypeSort[fb_type]
	local index = layer - 1
	local cur_page = FuBenData.Instance:GetOpenCurPage(layer)
	local fuben_info = FuBenData.Instance:GetPhaseFBInfo()
	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(index, cur_page)
	has_times = fuben_cfg.free_times + fuben_info[index].today_buy_times - fuben_info[index].today_times
	local max_times = VipPower.Instance:GetParam(VipPowerId.fuben_phase_buy_times)
	can_buy_times = max_times - fuben_info[index].today_buy_times
	return has_times, can_buy_times
end

function SmallHelperData:GetTowerDefendTimes()
	local tf_cfg_other = FuBenData.Instance:GetDefenseTowerOtherCfg()
	local tf_fb_buy_num = FuBenData.Instance:GetBuildTowerBuyTimes() or 0
	local tf_fb_join_num = FuBenData.Instance:GetBuildTowerEnterTimes() or 0
	local free_times = 0
	if tf_cfg_other and tf_cfg_other.enter_free_times ~= nil then
		free_times = tf_cfg_other.enter_free_times
	end
	local times = free_times + tf_fb_buy_num - tf_fb_join_num
	return times
end

function SmallHelperData:GetBuyNum(task_type)
	local has_times = 0
	local can_buy_times = 0
	if task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_FB then
		local other_cfg = FuBenData.Instance:GetExpFBOtherCfg()
		local pay_times = FuBenData.Instance:GetExpPayTimes()
		local enter_times = FuBenData.Instance:GetExpEnterTimes()
		local max_times = VipPower.Instance:GetParam(VipPowerId.exp_fb_buy_times) or 0
		local day_times = 0
		if other_cfg and other_cfg.day_times ~= nil then
			day_times = other_cfg.day_times
		end
		has_times = (pay_times + day_times - enter_times)
		can_buy_times = max_times - pay_times
	elseif task_type == "mountphase" then
		has_times, can_buy_times = self:GetBuyNumPhase(1)
	elseif task_type == "wingphase" then
		has_times, can_buy_times = self:GetBuyNumPhase(2)
	elseif task_type == "fightmountphase" then
		has_times, can_buy_times = self:GetBuyNumPhase(3)
	elseif task_type == "lingtongphase" then
		has_times, can_buy_times = self:GetBuyNumPhase(4)
	elseif task_type == "fabaophase" then
		has_times, can_buy_times = self:GetBuyNumPhase(5)
	elseif task_type == "flypetphase" then
		has_times, can_buy_times = self:GetBuyNumPhase(6)
	elseif task_type == "halophase" then
		has_times, can_buy_times = self:GetBuyNumPhase(7)
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
		local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
		local spirit_meet_info = SpiritData.Instance:GetSpiritAdvantageInfo()
		if spirit_meet_cfg ~= nil and spirit_meet_cfg.other ~= nil and spirit_meet_cfg.other[1] ~= nil and spirit_meet_info ~= nil then 
			local spirit_count = spirit_meet_info.today_gather_blue_jingling_count or 0
			has_times =  spirit_meet_cfg.other[1].times - spirit_count
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_CYCLE_TASK then
		local max_times = VipPower.Instance:GetParam(VIPPOWER.KEY_HUAN_TASK) or 0
		local task_times = 0
		if max_times >= 1 then
			task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.HUAN) or 0
		end
		has_times = task_times > 0 and 1 or 0
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS then
		local max_wearry = BossData.Instance:GetActiveBossMaxWeary()
		has_times = max_wearry - BossData.Instance:GetActiveBossWeary()
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS then
		local max_wearry = BossData.Instance:GetMikuBossMaxWeary()
		has_times = max_wearry - BossData.Instance:GetMikuBossWeary()
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_BABY_BOSS then
		local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
		local enter_times = BossData.Instance:GetBabyBossEnterTimes()
		has_times = enter_limit - enter_times
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_SUIT_BOSS then
		local enter_count = BossData.Instance:GetDabaoBossCount()
		local max_count = BossData.Instance:GetDabaoFreeTimes()
		has_times = max_count - enter_count
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS then
		has_times = ShenYuBossData.Instance:GetGodMagicBossTire()
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_GUILD_TASK then
		local task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.GUILD) or 0
		has_times = task_times > 0 and 1 or 0
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB then
		local defense_info = FuBenData.Instance:GetBuildTowerFBInfo()
		local can_times = self:GetTowerDefendTimes()
		local max_count = 10
		if defense_info and next(defense_info) then
			max_count = defense_info.remain_buyable_monster_num
		end
		max_count = can_times == 0 and 0 or max_count
		has_times = max_count
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_ESCORT_FAIRY then
		has_times = math.max(0, YunbiaoData.Instance:GetHusongRemainTimes())
		local buy_times = YunbiaoData.Instance:GetGouMaiCishu() or 0
		local max_count = VipPower.Instance:GetParam(VipPowerId.husong_buy_times) or 0
		can_buy_times = max_count - buy_times
	elseif task_type == "qualityfb" then
		local other_cfg = FuBenData.Instance:GetChallengOtherCfg() or {}
		local day_free_times = other_cfg.day_free_times or 0
		local buy_times = FuBenData.Instance:GetQualityBuyCount() or 0
		local total_times = day_free_times + buy_times
		local enter_times = FuBenData.Instance:GetQualityEnterCount() or 0
		has_times = total_times - enter_times
		local max_count = VipPower.Instance:GetParam(VIPPOWER.QUALITY_FB_TIMES) or 0
		can_buy_times = max_count - buy_times
	elseif task_type == "defendgoddess" then
		local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1] or {}
		local info = FuBenData.Instance:GetArmorDefendRoleInfo() or {}
		if other_cfg.free_join_times and info.buy_join_times and info.join_times then
			has_times = other_cfg.free_join_times + info.buy_join_times - info.join_times
			local max_count = VipPower.Instance:GetParam(VipPowerId.armor_fb_buy_times) or 0
			can_buy_times = max_count - info.buy_join_times
		end
	elseif task_type == "clothfb" then
		local info = FuBenData.Instance:GetTowerDefendRoleInfo() or {}
		local other_cfg = FuBenData.Instance:GetArmorDefendCfgOther() or {}
		if other_cfg.free_join_times and info.buy_join_times and info.item_buy_join_times and info.join_times then
			has_times = other_cfg.free_join_times + info.buy_join_times + info.item_buy_join_times - info.join_times
			local max_times = VipPower:GetParam(VipPowerId.tower_defend_buy_count) or 0
			can_buy_times = max_times - info.buy_join_times
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_TASK then
		local task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.RI) or 0
		has_times = task_times > 0 and 1 or 0
	end
	has_times = has_times < 0 and 0 or has_times
	can_buy_times = can_buy_times < 0 and 0 or can_buy_times
	local max_set_times = has_times + can_buy_times									-- 小飞说打开默认显示最大次数 这个最大次数 包括可购买次数
	
	local show_times = max_set_times <= 0 and 0 or 1
	if task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS 
		or task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS 
		or task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS 
		or task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
		show_times = max_set_times
	end
	can_buy_times = max_set_times - show_times									
	return show_times, can_buy_times, has_times
end

function SmallHelperData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

function SmallHelperData:GetChestShopMode()
	return self.chest_shop_mode
end

function SmallHelperData:GetChestCount()
	return self.count
end

-- function SmallHelperData:IsShowBuyTxt(task_type)
-- 	local is_show = false
-- 	if task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_FB then
-- 		is_show = true
-- 	elseif task_type == "mountphase" then
-- 		is_show = true
-- 	elseif task_type == "wingphase" then
-- 		is_show = true
-- 	elseif task_type == "fightmountphase" then
-- 		is_show = true
-- 	elseif task_type == "lingtongphase" then
-- 		is_show = true
-- 	elseif task_type == "fabaophase" then
-- 		is_show = true
-- 	elseif task_type == "flypetphase" then
-- 		is_show = true
-- 	elseif task_type == "halophase" then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_CYCLE_TASK then
-- 		is_show = false
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_BABY_BOSS then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_SUIT_BOSS then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_GUILD_TASK then
-- 		is_show = false
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_ESCORT_FAIRY then
-- 		is_show = true
-- 	elseif task_type == "qualityfb" then
-- 		is_show = true
-- 	elseif task_type == "defendgoddess" then
-- 		is_show = true
-- 	elseif task_type == "clothfb" then
-- 		is_show = true
-- 	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_TASK then
-- 		is_show = false
-- 	end
-- 	return is_show
-- end

function SmallHelperData:IsCanHelp(task_type)
	local is_show = false
	local has_times, can_buy_times = self:GetBuyNum(task_type)
	if has_times > 0 or can_buy_times > 0 then
		is_show = true
	end
	return is_show
end

function SmallHelperData:GetBuyTimeGold(task_type, times)
	local bind_pay, unbind_pay = 0, 0
	local _, _, has_times = self:GetBuyNum(task_type)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local loc_times = times - has_times
	if loc_times < 0 then
		loc_times = 0
	end

	local cfg = self:GetConfigByType(task_type)
	local cfg_bind, cfg_gold = 0, 0
	if cfg.money_type == 0 then
		cfg_bind = cfg.gold or 0
	elseif cfg.money_type == 1 then
		cfg_gold = cfg.gold or 0
	end

	if task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_FB then
		local pay_times = FuBenData.Instance:GetExpPayTimes() or 0	
		if loc_times > 0 then
			for i = 1, loc_times do
				bind_pay = bind_pay + FuBenData.Instance:GetExpNextPayMoney(pay_times)
				pay_times = pay_times + 1
			end
		end
		local cfg = ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").exp_other_cfg[1].item_stuff
		if cfg ~= nil then
			local item_num = ItemData.Instance:GetItemNumInBagById(cfg.item_id)
			local need_num = times - item_num
			if need_num < 0 then
				need_num = 0
			end
			local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[cfg.item_id] or {}
			local shop_price = shop_item_cfg.bind_gold or 0
			bind_pay = bind_pay + need_num * shop_price
		end
	elseif task_type == "mountphase" then
		bind_pay = self:GetPhaseBuyPrice(1) * loc_times
	elseif task_type == "wingphase" then
		bind_pay = self:GetPhaseBuyPrice(2) * loc_times
	elseif task_type == "fightmountphase" then
		bind_pay = self:GetPhaseBuyPrice(3) * loc_times
	elseif task_type == "lingtongphase" then
		bind_pay = self:GetPhaseBuyPrice(4) * loc_times
	elseif task_type == "fabaophase" then 
		bind_pay = self:GetPhaseBuyPrice(5) * loc_times
	elseif task_type == "flypetphase" then
		bind_pay = self:GetPhaseBuyPrice(6) * loc_times
	elseif task_type == "halophase" then
		bind_pay = self:GetPhaseBuyPrice(7) * loc_times
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_PET_ADVENTURE then
		local spirit_meet_cfg = SpiritData.Instance:GetSpiritAdvantageCfg()
		if spirit_meet_cfg ~= nil and spirit_meet_cfg.other ~= nil and spirit_meet_cfg.other[1] ~= nil then
			bind_pay = times * spirit_meet_cfg.other[1].skip_gather_consume
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_CYCLE_TASK then
		local price = TaskData.Instance:GetQuickPrice(TASK_TYPE.HUAN) or 0
		local task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.HUAN) or 0
		bind_pay = times * price * task_times
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EASY_BOSS then

	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DIFFICULT_BOSS then

	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_BABY_BOSS then
		local enter_times = BossData.Instance:GetBabyBossEnterTimes() 
		local need_item_id = BossData.Instance:GetBabyEnterCondition()
		local need_num = 0
		if times > 0 then
			for i = 1, times do
				need_num = need_num + BossData.Instance:GetBabyNeedByTimes(enter_times)
				enter_times = enter_times + 1
			end
		end
		local bag_num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		need_num = need_num - bag_num
		if need_num > 0 then
			local item_shop_cfg = ShopData.Instance:GetShopItemCfg(need_item_id)
			local price = item_shop_cfg.bind_gold or 0
			bind_pay = need_num * price
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_SUIT_BOSS then
		local free_enter_times = BossData.Instance:GetDabaoFreeEnterTimes() or 0
		local enter_count = BossData.Instance:GetDabaoBossCount() or 0
		local need_item_id, need_item_num = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)
		local bag_num = ItemData.Instance:GetItemNumInBagById(need_item_id) or 0
		local need_num = 0
		for i = 1, times do
			local _, need_count = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)
			need_num = need_num + need_count
			enter_count = enter_count + 1
		end
		need_num = need_num - bag_num
		if need_num > 0 then
			local item_shop_cfg = ShopData.Instance:GetShopItemCfg(need_item_id)
			local cost = item_shop_cfg.bind_gold or 0
			bind_pay = need_num * cost
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_DEMON_BOSS then

	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_GUILD_TASK then
		local price = TaskData.Instance:GetQuickPrice(TASK_TYPE.GUILD)
		local task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.GUILD) or 0
		bind_pay = times * price * task_times
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_TOWER_DEFENSE_FB then
		local can_times = self:GetTowerDefendTimes()
		local cfg = FuBenData.Instance:GetDefenseTowerOtherCfg()
		local price = 0
		if cfg and cfg.extra_call_gold ~= nil then
			price = cfg.extra_call_gold
		end
		bind_pay = times * price * can_times
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_ESCORT_FAIRY then
		local buy_times = YunbiaoData.Instance:GetGouMaiCishu() or 0
		local cfg = YunbiaoData.Instance:GetBuyHusonGold()
		if cfg ~= nil and loc_times > 0 then
			for i = 1, loc_times do
				local data = cfg[buy_times + 1]
				if data ~= nil and data.gold_cost ~= nil then
					bind_pay = bind_pay + data.gold_cost
				end
				buy_times = buy_times + 1
			end
		end
	elseif task_type == "qualityfb" then
		local pay_times = FuBenData.Instance:GetQualityBuyCount() or 0
		if loc_times > 0 then
			for i = 1, loc_times do
				bind_pay = bind_pay + FuBenData.Instance:GetCostGoldByTimes(pay_times)
				pay_times = pay_times + 1
			end
		end
	elseif task_type == "defendgoddess" then
		if loc_times > 0 then
			local info = FuBenData.Instance:GetArmorDefendRoleInfo() or {}
			local pay_times = info.buy_join_times or 0
			for i = 1, loc_times do
				local price = FuBenData.Instance:GetTowerBuyCost(pay_times + 1) or 0
				bind_pay = bind_pay + price
				pay_times = pay_times + 1
			end
		end
	elseif task_type == "clothfb" then
		if loc_times > 0 then
			local info = FuBenData.Instance:GetTowerDefendRoleInfo() or {}
			local pay_times = info.buy_join_times or 0
			local cost_cfg = FuBenData.Instance:GetArmorDefendBuyCostCfg() or {}
			for i = 1, loc_times do
				local price = 0
				if cost_cfg[pay_times + 1] then
					price = cost_cfg[pay_times + 1].gold_cost or 0
				end
				bind_pay = bind_pay + price
				pay_times = pay_times + 1
			end
		end
	elseif task_type == LITTLE_HELPER_COMPLETE_TYPE.LITTLE_HELPER_COMPLETE_TYPE_EXP_TASK then
		local price = TaskData.Instance:GetQuickPrice(TASK_TYPE.RI)
		local task_times = TaskData.Instance:GetTaskCount(TASK_TYPE.RI) or 0
		bind_pay = times * price * task_times
	end
	if bind_pay < 0 then
		bind_pay = 0
	end
	bind_pay = bind_pay + cfg_bind * times
	-- if bind_pay - main_vo.bind_gold > 0 then
	-- 	unbind_pay = unbind_pay + bind_pay - main_vo.bind_gold
	-- 	bind_pay = main_vo.bind_gold
	-- end
	unbind_pay = unbind_pay + cfg_gold * times
	return bind_pay, unbind_pay
end

function SmallHelperData:GetPhaseBuyPrice(fb_type)
	local layer = PhaseFuBenTypeSort[fb_type]
	
	local price = FuBenData.Instance:GetPhaseFbResetGold(layer - 1) or 0
	return price
end

function SmallHelperData:GetItemData(index)
	if index ~= nil then
		return self.config[index]
	else
		self:GetShowConfig()
		return self.config 
	end
end

function SmallHelperData:SetLittleHelper(protocol)
	local task_type = protocol.type
	if task_type == -1 then
		self:ResetAllData()
	else
		self:ResetData(task_type)
	end
end

function SmallHelperData:SetReward(protocol)
	self.tao_seq = protocol.reward_list
    self.count = protocol.item_count
    if self.count and self.count > 0 then
    	if self.count > 80 then
	    	self.count = 80											--限制最大展示数量
	    end
    	TipsCtrl.Instance:ShowTreasureView(self.chest_shop_mode)
    end
end

function SmallHelperData:GetChestShopItemInfo()
	local data = {}
	for i = 1, self.count do
		if self.tao_seq and self.tao_seq[i] then
			local tao_seq = self.tao_seq[i]
			local color = 0
			local item_cfg = ItemData.Instance:GetItemConfig(tao_seq.item_id)
			if item_cfg then 
				if item_cfg.color then
					color = item_cfg.color
				end
			
				tao_seq.noindex_show_xianpin = true
				tao_seq.color = color
				if tao_seq.xianpin_type_list then
					for k, v in pairs(tao_seq.xianpin_type_list) do
						if v == 0 then
							tao_seq.xianpin_type_list[k] = nil
						end
					end
					tao_seq.param = {}
					tao_seq.param.xianpin_type_list = tao_seq.xianpin_type_list
				end
				if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) then
					if color >= GameEnum.ITEM_COLOR_ORANGE then
						table.insert(data, tao_seq)
					end
				-- elseif EquipData.Instance:IsBianShenEquipType(item_cfg.sub_type) then
				-- 	if color >= GameEnum.ITEM_COLOR_ORANGE then
				-- 		table.insert(data, tao_seq)
				-- 	end
				else
					table.insert(data, tao_seq)
				end
			end
		end
	end
	table.sort(data, SortTools.KeyUpperSorter("color"))
	return data
end

function SmallHelperData:ResetAllData()
	self:GetShowConfig()
	self.save_data = {}
	for k, v in pairs(self.config) do 
		if v ~= nil then
			self:ResetData(v.complete_type)
		end
	end
end

function SmallHelperData:ResetData(task_type)
	self.save_data[task_type] = {}
	local has_times, can_buy_times = self:GetBuyNum(task_type)
	self.save_data[task_type].has_times = has_times or 0 
	self.save_data[task_type].can_buy_times = can_buy_times or 0
	local bind_gold, gold = self:GetBuyTimeGold(task_type, has_times)
	self.save_data[task_type].bind_gold = bind_gold or 0
	self.save_data[task_type].gold = gold or 0
end

function SmallHelperData:GetSaveData(task_type)
	if self.save_data[task_type] == nil or self.save_data[task_type].has_times == nil then
		self:ResetData(task_type)
	end
	return self.save_data[task_type]
end

function SmallHelperData:SetSaveData(task_type, operate)
	if self.save_data[task_type] == nil then
		self.save_data[task_type] = {}
	end
	if operate == 0 then
		self.save_data[task_type].has_times = self.save_data[task_type].has_times - 1
		self.save_data[task_type].can_buy_times = self.save_data[task_type].can_buy_times + 1
	elseif operate == 1 then
		self.save_data[task_type].has_times = self.save_data[task_type].has_times + 1
		self.save_data[task_type].can_buy_times = self.save_data[task_type].can_buy_times - 1
	elseif operate == 2 then
		self.save_data[task_type].has_times = self.save_data[task_type].has_times + self.save_data[task_type].can_buy_times
		self.save_data[task_type].can_buy_times = 0
	end

	local bind_gold, gold = self:GetBuyTimeGold(task_type, self.save_data[task_type].has_times)
	self.save_data[task_type].bind_gold = bind_gold or 0
	self.save_data[task_type].gold = gold or 0
end

function SmallHelperData:SaveSetData(task_type, has_times, can_buy_times)
	if self.save_data[task_type] ~= nil then
		self.save_data[task_type].has_times = has_times
		self.save_data[task_type].can_buy_times = can_buy_times
	end
	local bind_gold, gold = self:GetBuyTimeGold(task_type, self.save_data[task_type].has_times)
	self.save_data[task_type].bind_gold = bind_gold or 0
	self.save_data[task_type].gold = gold or 0
end

function SmallHelperData:GetAllSaveData()
	return self.save_data
end