CHONG_ZHI_STATE =
{
	NEED_TOTAL_CHONGZHI_10 = 60,
	NEED_TOTAL_CHONGZHI_99 = 300,
}

CHONGZHI_REWARD_TYPE =
{
	CHONGZHI_REWARD_TYPE_SPECIAL_FIRST = 0,											-- 特殊首充
	CHONGZHI_REWARD_TYPE_DAILY_FIRST = 1,											-- 日常首充
	CHONGZHI_REWARD_TYPE_DAILY_TOTAL = 2,											-- 日常累充
	CHONGZHI_REWARD_TYPE_DIFF_WEEKDAY_TOTAL = 3,									-- 每日累充
	CHONGZHI_REWARD_TYPE_FIRST = 4,													-- 首充
	CHONGZHI_REWARD_TYPE_DAILY = 5,													-- 每日充值
	CHONGZHI_REWARD_TYPE_DAILY_TIMES = 6,											-- 每日充值累计天数奖励
	CHONGZHI_REWARD_TYPE_DAILY2 = 7,												--每日充值2
	CHONGZHI_REWARD_TYPE_MAX,
}

DailyChargeData = DailyChargeData or BaseClass()

DailyChargeData.hasOpenFirstRecharge = false

function DailyChargeData:__init()
	if DailyChargeData.Instance then
		print_error("[DailyChargeData] Attemp to create a singleton twice !")
	end
	DailyChargeData.Instance = self
	self.chongzhi_info = {}
	self.recharge2_info = nil
	self.cfg_open_day = nil
	self.push_show_index = 1
	CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward[1].need_total_chongzhi
	CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward[2].need_total_chongzhi
	RemindManager.Instance:Register(RemindName.DailyCharge, BindTool.Bind(self.GetDailyChargeRemind, self))
	RemindManager.Instance:Register(RemindName.FirstCharge, BindTool.Bind2(self.GetFirstChargeRemind, self, 1))
	RemindManager.Instance:Register(RemindName.SecondCharge, BindTool.Bind2(self.GetFirstChargeRemind, self, 2))
	RemindManager.Instance:Register(RemindName.ThirdCharge, BindTool.Bind2(self.GetFirstChargeRemind, self, 3))
	RemindManager.Instance:Register(RemindName.DailyLeiJi, BindTool.Bind(self.GetDailyLeiJiRemind, self))
	RemindManager.Instance:Register(RemindName.ChargeGroup, BindTool.Bind(self.GetChargeGroupRemind, self))
end

function DailyChargeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DailyCharge)
	RemindManager.Instance:UnRegister(RemindName.FirstCharge)
	RemindManager.Instance:UnRegister(RemindName.SecondCharge)
	RemindManager.Instance:UnRegister(RemindName.ThirdCharge)
	RemindManager.Instance:UnRegister(RemindName.DailyLeiJi)
	RemindManager.Instance:UnRegister(RemindName.ChargeGroup)
	DailyChargeData.Instance = nil
end

function DailyChargeData:OnSCChongZhiInfo(protocol)
	self.chongzhi_info.first_chongzhi_fetch_reward_flag_list = bit:d2b(protocol.first_chongzhi_fetch_reward_flag)	--首充奖励领取标记
	self.chongzhi_info.daily_chongzhi_fetch_reward_flag_list = bit:d2b(protocol.daily_chongzhi_fetch_reward_flag)	--每日首充奖励领取标记
	self.chongzhi_info.daily_chongzhi_complete_days = protocol.daily_chongzhi_complete_days							--每日首充完成天数
	self.chongzhi_info.daily_chongzhi_times_fetch_reward_flag_list = bit:d2b(protocol.daily_chongzhi_times_fetch_reward_flag)--每日首充累计天数奖励标记
	self.chongzhi_info.history_recharge = protocol.history_recharge
	self.chongzhi_info.history_recharge_count = protocol.history_recharge_count
	self.chongzhi_info.today_recharge = protocol.today_recharge
	self.chongzhi_info.reward_flag = protocol.reward_flag
	self.chongzhi_info.reward_flag_list = bit:d2b(protocol.reward_flag)  --每个档位是否充值标记
	self.chongzhi_info.special_first_chongzhi_timestamp = protocol.special_first_chongzhi_timestamp			--特殊首冲开始时间戳
	self.chongzhi_info.is_daily_first_chongzhi_open = protocol.is_daily_first_chongzhi_open					--每日首冲是否开启
	self.chongzhi_info.is_daily_first_chongzhi_fetch_reward = protocol.is_daily_first_chongzhi_fetch_reward	--每日充值奖励是否已经领取
	self.chongzhi_info.daily_total_chongzhi_fetch_reward_flag = protocol.daily_total_chongzhi_fetch_reward_flag	--每日累计充值奖励领取标记
	self.chongzhi_info.daily_total_chongzhi_stage = protocol.daily_total_chongzhi_stage						--累计充值当前阶段
	self.chongzhi_info.daily_first_chongzhi_times = protocol.daily_first_chongzhi_times       				--每日首冲累计次数（满7次有额外奖励）
	self.chongzhi_info.special_first_chongzhi_fetch_reward_flag = protocol.special_first_chongzhi_fetch_reward_flag   	--特殊首冲领取标志
	self.chongzhi_info.zai_chongzhi_fetch_reward_flag = protocol.zai_chongzhi_fetch_reward_flag					--0未充值.1可领取.2已领取
	self.chongzhi_info.daily_total_chongzhi_stage_chongzhi = protocol.daily_total_chongzhi_stage_chongzhi
	self.chongzhi_info.third_chongzhi_reward_flag = protocol.third_chongzhi_reward_flag						--第三次充值状态（0 未充值，1 可领取，2 已领取）
	self.chongzhi_info.diff_weekday_chongzhi_is_open = protocol.diff_weekday_chongzhi_is_open					--每日累充是否开启(星期几相关)
	self.chongzhi_info.diff_weekday_chongzhi_stage_fetch_flag = protocol.diff_weekday_chongzhi_stage_fetch_flag		--每日累充阶级奖励领取标记(星期几相关)
	self.chongzhi_info.diff_wd_chongzhi_value = protocol.diff_wd_chongzhi_value						--每日累充额度(星期几相关)
	self.chongzhi_info.daily_chongzhi_fetch_reward2_flag = bit:d2b(protocol.daily_chongzhi_fetch_reward2_flag)			--每日累计充值奖励2领取标记
	self.chongzhi_info.first_chongzhi_active_reward_flag = bit:d2b(protocol.first_chongzhi_active_reward_flag)			-- 首冲奖励激活标记
	self.chongzhi_info.daily_chongzhi_value = protocol.daily_chongzhi_value
	
	MainUICtrl.Instance:FlushView("flush_charge_icon")

	RemindManager.Instance:Fire(RemindName.FirstCharge)
	RemindManager.Instance:Fire(RemindName.SecondCharge)
	RemindManager.Instance:Fire(RemindName.ThirdCharge)
	RemindManager.Instance:Fire(RemindName.DailyCharge)
	RemindManager.Instance:Fire(RemindName.DailyLeiJi)
	RemindManager.Instance:Fire(RemindName.ChargeGroup)
end

function DailyChargeData:GetDailyChongzhiFetchRewardFlag()
	if self.chongzhi_info.special_first_chongzhi_fetch_reward_flag == 0 then
		return false
	end
	return true
end

function DailyChargeData.GetMinRecharge()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").first_chongzhi_reward[1].need_danbi_chongzhi or 60
end

function DailyChargeData:GetRewardAuto()
return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").reward
end

function DailyChargeData:GetSpecialChongzhiRewardAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").special_chongzhi_reward
end

function DailyChargeData:GetOtherAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").other
end

function DailyChargeData:GetDailyTotalChongzhiRewardAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_total_chongzhi_reward
end

function DailyChargeData:GetDailyTotalChongzhiStageAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_total_chongzhi_stage
end

function DailyChargeData:GetTotalChongzhiWantMoneyAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").total_chongzhi_want_money
end

function DailyChargeData:GetWeekdayTotalChongzhiAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").weekday_total_chongzhi
end

function DailyChargeData:GetThreeRechargeAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").first_chongzhi_reward
end

local daily_chongzhi_reward = {}
local level = 0
function DailyChargeData:GetDailyChongzhiRewardAuto()
	daily_chongzhi_reward = {}
	level = PlayerData.Instance.role_vo.level
	for i,v in ipairs(ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward) do
		if level >= v.min_level and level <= v.max_level then
			table.insert(daily_chongzhi_reward, v)
		end
	end
	return daily_chongzhi_reward
end

function DailyChargeData:GetDailyChongzhiTimesRewardAuto()
	local cfg = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_times_reward
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local range = GetDataRange(cfg, "opengame_day")
	local rank = GetRangeRank(range,open_day)
	local opengame_day_reward_list = {}
	for i, v in ipairs(cfg) do
		if v.opengame_day == rank then
			table.insert(opengame_day_reward_list, v)
		end
	end
	return opengame_day_reward_list
end

function DailyChargeData:GetDailyFirstChongzhiTimesRewardAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_fisrt_chongzhi_reward
end

function DailyChargeData:GetDailyLeiJiRewardAuto()
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward2
end


function DailyChargeData:GetChongZhiInfo()
	return self.chongzhi_info
end

function DailyChargeData:GetFirstRewardByWeek()
	local week_num = os.date("%w",os.time())
	local cfg = self:GetDailyFirstChongzhiTimesRewardAuto()
	return cfg[week_num] or cfg[0]
end

--获得相应金额充值配置信息
function DailyChargeData:GetChongZhiReward(need_chongzhi)
	local list = self:GetDailyChongzhiRewardAuto()
	local new_list = {}
	for k,v in pairs(list) do
		if need_chongzhi == v.need_total_chongzhi then
			return v
		end
	end
	return list[1]
end

--获得三充相应金额充值配置信息
function DailyChargeData:GetThreeChongZhiReward(need_chongzhi)
	local list = self:GetThreeRechargeAuto()
	local new_list = {}
	for k,v in pairs(list) do
		if need_chongzhi == v.need_danbi_chongzhi then
			return v
		end
	end
	return list[1]
end

function DailyChargeData:GetThreechargeNeedRecharge(seq)
	return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").first_chongzhi_reward[seq].need_danbi_chongzhi
end

function DailyChargeData:GetThreeRechargeReward()
	local chongzhi_state = self:GetThreechargeNeedRecharge(self.push_show_index)
	local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	local index = 1
	if gifts_cfg == nil then
		return item_data_list
	end
	for i = 1, gifts_cfg.item_num do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(gifts_cfg["item_"..i.."_id"])
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local flag = true
		if nil ~= item_cfg then
			if base_prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				flag = false
			end
		end

		if flag and gifts_cfg["item_"..i.."_id"] ~= 0 then
			item_data_list[index] = {}
			item_data_list[index].item_id = gifts_cfg["item_"..i.."_id"]
			item_data_list[index].num = gifts_cfg["item_"..i.."_num"]
			item_data_list[index].is_bind = gifts_cfg["is_bind_"..i]
			index = index + 1
		end
	end
	return item_data_list
end

function DailyChargeData:GetDailyGiftInfoList(chongzhi_state)
	local gifts_info = self:GetChongZhiReward(chongzhi_state).reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	if gifts_cfg == nil then
		return item_data_list
	end
	for i = 1, gifts_cfg.item_num do
		item_data_list[i] = {}
		item_data_list[i].item_id = gifts_cfg["item_"..i.."_id"]
		item_data_list[i].num = gifts_cfg["item_"..i.."_num"]
		item_data_list[i].is_bind = gifts_cfg["is_bind_"..i]
	end
	return item_data_list
end

function DailyChargeData:GetFirstGiftInfoList(chongzhi_state)
	local gifts_info = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).first_reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	if gifts_cfg == nil then
		return item_data_list
	end
	local index = 1
	for i = 1, gifts_cfg.item_num do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(gifts_cfg["item_"..i.."_id"])
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local flag = true
		if nil ~= item_cfg then
			if base_prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				flag = false
			end
		end

		if flag and gifts_cfg["item_"..i.."_id"] ~= 0 then
			item_data_list[index] = {}
			item_data_list[index].item_id = gifts_cfg["item_"..i.."_id"]
			item_data_list[index].num = gifts_cfg["item_"..i.."_num"]
			item_data_list[index].is_bind = gifts_cfg["is_bind_"..i]
			index = index + 1
		end
	end
	return item_data_list
end

--通过索引获得一列配置
function DailyChargeData:GetChongzhiTimesCfg(seq)
	local cfg = self:GetDailyChongzhiTimesRewardAuto()
	for k,v in pairs(cfg) do
		if v.seq == seq then
			return v
		end
	end
end

--通过索引获得一列配置
function DailyChargeData:GetChongzhiTimesCfg(seq)
	local cfg = self:GetDailyChongzhiTimesRewardAuto()
	for k,v in pairs(cfg) do
		if v.seq == seq then
			return v
		end
	end
end

function DailyChargeData:GetDailyChongzhiOpen()
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return false
	end
	if list[32] == 1 then
		return true
	end
	return false
end

function DailyChargeData:GetDailyChargeRemind()
	return self:GetDailyChongzhiState() and 1 or 0
end

function DailyChargeData:GetDailyChongzhiState()
	-- if self:GetFirstChongzhiOpen() then
	-- 	return false
	-- end
	if self:GetDailyChongzhiTimesCanReward() then
		return true
	end
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("daily_charge_remind_day") or cur_day
	local has_open = cur_day == -1 or cur_day == remind_day
	if list[32] == 1 and list[31] == 1 then
		return false
	elseif list[32] == 1 then
		if self.chongzhi_info.daily_chongzhi_value < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 and has_open then
			return false
		end
	elseif list[32] == 0 and list[31] == 0 then
		if self.chongzhi_info.daily_chongzhi_value < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and has_open then
			return false
		end
	end
	return true
end

function DailyChargeData:GetDailyChongzhiTimesCanReward()
	local reward_cfg = self:GetDailyChongzhiTimesRewardAuto()
	local list = self.chongzhi_info.daily_chongzhi_times_fetch_reward_flag_list
	local current_days = self.chongzhi_info.daily_chongzhi_complete_days
	if list == nil or current_days == nil then
		return false
	end
	for k,v in pairs(reward_cfg) do
		if list[33 - k] ~= 1 and current_days >= v.complete_days then
			return true
		end
	end
	return false
end

function DailyChargeData:GetFirstChongzhiOpen()
	if IS_AUDIT_VERSION then
		return false
	end
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[32] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetThreeRechargeOpen(index)
	if IS_AUDIT_VERSION then
		return false
	end

	local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag
	if fetch_list == nil then
		return true
	end

	if index <= 0 or index > 3 then
		return false
	end
	if 1 == index then
		return 1 == active_list[33 - index] and 0 == fetch_list[33 - index]
	end

	for i = 1, 3 do
		if i < index and 0 == active_list[33 - i] then
			return false
		end
	end

	return 0 == fetch_list[33 - index]
end

function DailyChargeData:GetIsThreeRecharge()
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag or {}
	return active_list[30] == 1
end

function DailyChargeData:GetThreeRechargeFlag(index)
	local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag or {}
	if nil == active_list or nil == fetch_list then
		return 0
	end
	return active_list[32 - index + 1], fetch_list[32 - index + 1]
end

function DailyChargeData:GetDailyLeiJiGetFlag()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	local _, max_seq = self:GetDailyLeiJiRewardDay()
	max_seq = max_seq + 1
	for i = max_seq, 1, -1 do
		if list and list[33 - i] == 0 then
			return true
		end
	end
 	return false
end

function DailyChargeData:GetDailyLeiJiRemind()
	return self:GetDailyLeiJiState() and 1 or 0
end

function DailyChargeData:GetChargeGroupRemind()
	local first_charge_remind_1 = self:GetFirstChargeRemind(1)
	local first_charge_remind_2 = self:GetFirstChargeRemind(2)
	local first_charge_remind_3 = self:GetFirstChargeRemind(3)

	local daily_leiji_remind = self:GetDailyLeiJiRemind()
	local is_first = DailyChargeData.Instance:HasFirstRecharge()
	local flag = DailyChargeData.Instance:GetDailyLeiJiGetFlag()
	local open = OpenFunData.Instance:CheckIsHide("leiji_daily")
	local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
	local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if active_reward_info and active_reward_info.reward_state and time_day > 0 then
		flag = true
	end
	if open and is_first and flag then
	else
		daily_leiji_remind = 0
	end

	local daily_charge_remind = self:GetDailyChargeRemind()
	local vip_remind = VipData.Instance:GetIsGetVipRewardFlag()
	local putiantongqing_remind = ResetDoubleChongzhiData.Instance:GetResetDoubleChongzhiRemind()

	if MainUICtrl.Instance:GetView():GetButtonState() then
		if first_charge_remind_1 > 0 or first_charge_remind_2 > 0 or first_charge_remind_3 > 0 then
			return 1
		end								
	else
		if daily_leiji_remind > 0 or daily_charge_remind > 0 or vip_remind > 0 or putiantongqing_remind > 0 then
			return 1
		end
	end
	return 0
end

function DailyChargeData:GetDailyLeiJiState()
	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local daily_leiji_reward, max_seq = self:GetDailyLeiJiRewardDay()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	max_seq = max_seq + 1
	for i = max_seq, 1, -1 do
		if list and list[33 - i] == 0 and daily_leiji_reward[i].need_chongzhi <= today_recharge then
			return true
		end
	end

	if ZhiBaoData.Instance:IsShowActiveRewardRedPoint() then
		return true
	end
	return false
end

function DailyChargeData:GetFirstChargeRemind(index)
	return self:GetFirstChongzhiState(index) and 1 or 0
end

function DailyChargeData:GetDailyLeiJiIndexState(index)
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	if list and list[33 - index] == 0 then
		return true
	end
	return false
end

function DailyChargeData:GetDailyLeiJiIndexFlag()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	for i = 32, 1, -1 do
		if list and list[i] == 0 then
			return 33 - i
		end
	end
end

-- --根据开服天数或者角色等级获取每日累充奖励配置
-- function DailyChargeData:GetDailyLeiJiRewardDay()
-- 	local daily_leiji_reward = {}
-- 	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
-- 	local cfg = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward2
-- 	local max_seq = cfg[#cfg].seq
-- 	local level = GameVoManager.Instance:GetMainRoleVo().level
-- 	for k,v in ipairs(cfg) do
-- 		if open_day <= v.open_day and level <= v.max_level then
-- 			if daily_leiji_reward[1] ~= nil and daily_leiji_reward[1].open_day == v.open_day then
-- 				table.insert(daily_leiji_reward, v)
-- 			elseif daily_leiji_reward[1] == nil then
-- 				table.insert(daily_leiji_reward, v)
-- 			end
-- 		end

-- 	end
-- 	-- else
-- 	-- 	local flag = false
-- 	-- 	for k,v in ipairs(cfg) do
-- 	-- 		if v.open_day > 30 then
-- 	-- 			if level <= v.max_level and flag == false then
-- 	-- 				flag = true
-- 	-- 				level = v.max_level
-- 	-- 			end
-- 	-- 			if level == v.max_level then
-- 	-- 				table.insert(daily_leiji_reward, v)
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- 	return daily_leiji_reward, max_seq
-- end

--根据开服天数或者角色等级获取每日累充奖励配置
function DailyChargeData:GetDailyLeiJiRewardDay()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()

	if nil == self.recharge2_info then
		self:InitMaxSeqAndDay()
	end

	if nil == self.cfg_open_day[open_day] then
		return self.cfg_open_day[self.recharge2_info.max_open_day], self.recharge2_info.max_seq
	end

	return self.cfg_open_day[open_day], self.recharge2_info.max_seq
end

function DailyChargeData:InitMaxSeqAndDay()
	self.recharge2_info = {}
	local cfg = ConfigManager.Instance:GetAutoConfig("chongzhireward_auto").daily_chongzhi_reward2

	if nil == self.cfg_open_day then
		self.cfg_open_day = ListToMapList(cfg, "open_day")
	end

	local max_open_day = 0
	for k,v in pairs(self.cfg_open_day) do
		if k > max_open_day then
			max_open_day = k
		end
	end
	local max_seq = 0
	for k,v in pairs(self.cfg_open_day[max_open_day]) do
		if v.seq > max_seq then
			max_seq = v.seq
		end
	end
	self.recharge2_info.max_open_day = max_open_day
	self.recharge2_info.max_seq = max_seq
end

function DailyChargeData:GetDailyNoReceiveDay()
	local now_receive_list = {}
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	local no_receive_list, _ = self:GetDailyLeiJiRewardDay()
	for k,v in ipairs(no_receive_list) do
		table.insert(now_receive_list, v)
	end

	table.sort(now_receive_list, function (a, b)
			if list and list[32 - a.seq] ~= list[32 - b.seq] then
				return list[32 - a.seq] < list[32 - b.seq]
			else
				return a.seq < b.seq
			end
		end)
	return now_receive_list, #now_receive_list
end

function DailyChargeData:GetFirstChongzhiState(index)
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag
	if nil == active_list then
		return
	end
	local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if index == 1 and active_list[32 - index + 1] == 1 and not fetch_list then
		return true
	end
	if active_list[32 - index + 1] == 1 and fetch_list[32 - index + 1] == 0 then
		return true
	end
	
	return false
end

function DailyChargeData:GetFirstChongzhi10State()
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[32] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetFirstChongzhi99State()
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[31] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetRewardSeq(chongzhi_state)
	local cfg = self:GetDailyChongzhiRewardAuto()
	for k,v in pairs(cfg) do
		if v.need_total_chongzhi == chongzhi_state then
			return v.seq
		end
	end
end

function DailyChargeData:CheckIsFirstRechargeById(id)
	local list = self.chongzhi_info.reward_flag_list
	if list == nil then
		return true
	end
	if list[32-id] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetHistoryRecharge()
	return self.chongzhi_info.history_recharge or 0
end

function DailyChargeData:SetShowPushIndex(index)
	self.push_show_index = index
end

function DailyChargeData:GetShowPushIndex()
	return self.push_show_index
end

function DailyChargeData:GetWingResId(item_id)
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	for k,v in pairs(wing_cfg) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
end

function DailyChargeData:GetISWingByResId(res_id)
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	for k,v in pairs(wing_cfg) do
		if v.res_id == res_id then
			return true
		end
	end
	return false
end

function DailyChargeData:GetMountResId(item_id)
	local mount_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	for k,v in pairs(mount_cfg) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
end

-- 是否首充过
function DailyChargeData:HasFirstRecharge()
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag or {}
	local first_recharge_index = 1
	return active_list[33 - first_recharge_index] == 1
end

-- 每日首充第二档是否领取了(每日首充里面有个今日累充，根据这个是否领取奖励判断特效是否显示)
function DailyChargeData:IsDailyFirstChargeShowEffect()
	local flag_list = self.chongzhi_info.daily_chongzhi_fetch_reward_flag_list
	local leichong_index = 1
	local shouchong_index = 0
	return flag_list[32 - leichong_index] == 0 or flag_list[32 - shouchong_index] == 0
end

function DailyChargeData:GetTotalLeijiDailyReward()
	local daily_leiji_reward = self:GetDailyLeiJiRewardDay()
	if self:GetIsOpenActiveReward2() then
		local total_reward_info = {}
		local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
		if next(active_reward_info) then
			table.insert(total_reward_info, active_reward_info)
		end

		for i,v in ipairs(daily_leiji_reward) do
			table.insert(total_reward_info, v)
		end
		return total_reward_info
	else
		return daily_leiji_reward
	end
	return {}
end

function DailyChargeData:GetIsOpenActiveReward()
	-- local now_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- return now_day > 7
	return true -- 改成每天都有
end

function DailyChargeData:GetIsOpenActiveReward2()
	local now_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return now_day > 0
end

function DailyChargeData:GetLeijiDailyShowModelItemId()
	local today_recharge = self.chongzhi_info.today_recharge
	local daily_leiji_reward = self:GetDailyLeiJiRewardDay()
	local last_reward = {}

	for i,v in ipairs(daily_leiji_reward) do
		-- if today_recharge < v.need_chongzhi and v.model_item_id ~= "" then
		-- 	return v
		-- end
		-- if v.model_item_id ~= "" then
		-- 	last_reward = v
		-- end
		if today_recharge < v.need_chongzhi and (v.model_item_id ~= "" or v.fightpower ~= "") then
			return v
		end
		if v.model_item_id ~= "" or v.fightpower ~= "" then
			last_reward = v
		end		
	end
	return last_reward
end

function DailyChargeData:GetLeijiDailyViewCurIndex()
	local open_flag = self:GetIsOpenActiveReward2()
	if open_flag then
		local daily_active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
		if not next(daily_active_reward_info) then
			return 1
		end

		local reward_on_day_flag_list = daily_active_reward_info.reward_on_day_flag_list
		if reward_on_day_flag_list[5] == 0 then
			return 1
		end

		local seq_list = self:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
		if seq_list then
			for i = #seq_list, 1, -1 do
				if seq_list[i] == 0 then
					local reward_list = self:GetTotalLeijiDailyReward()
					local max_num = #reward_list and #reward_list or 0
					local num = #seq_list - i + 2 >= max_num and max_num or #seq_list - i + 2
					return num
				end
			end
		end
		return 2
	else
		local seq_list = self:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
		if seq_list then
			for i = #seq_list, 1, -1 do
				if seq_list[i] == 0 then
					local reward_list = self:GetTotalLeijiDailyReward()
					local max_num = #reward_list and #reward_list or 0
					local num = #seq_list - i + 1 >= max_num and max_num or #seq_list - i + 1
					return num
				end
			end
		end
		return 1
	end
	return 1
end

function DailyChargeData:IsLeijiRewardRedPoint()
	local data_list = self:GetDailyLeiJiRewardDay()
	if next(self.chongzhi_info) == nil or next(data_list) == nil then
		return false
	end
	local today_recharge = self.chongzhi_info.today_recharge
	local seq_list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag

	for i,v in ipairs(data_list) do
		if seq_list and today_recharge >= v.need_chongzhi and seq_list[32 - v.seq] ~= 1 then
			return true
		end
	end
	return false
end

function DailyChargeData:GetDailyChargeRedPointByIndex(index)
	-- 每日累充（不包括活跃度奖励）红点
	local data_list = self:GetTotalLeijiDailyReward()
	if next(self.chongzhi_info) == nil or next(data_list) == nil then
		return false
	end
	local today_recharge = self.chongzhi_info.today_recharge
	local seq_list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag

	local data = data_list[index]
	if seq_list and today_recharge >= data.need_chongzhi and seq_list[32 - data.seq] ~= 1 then
		return true
	else
		return false
	end
end

function DailyChargeData:GetDailyChargeNowIndex()
	-- 没有红点情况下的跳转
	local chongzhi_info = self:GetChongZhiInfo()
	local reward_info = self:GetDailyLeiJiRewardDay()
	if next(chongzhi_info) == nil or next(reward_info) == nil then
		return 1
	end

	local seq_list = chongzhi_info.daily_chongzhi_fetch_reward2_flag
	if seq_list then
		local open_flag = self:GetIsOpenActiveReward2()
		local times = #seq_list - #reward_info + 1
		for i = #seq_list, times, -1 do
			if seq_list[i] == 0 then
				return open_flag and #seq_list - i + 2 or #seq_list - i + 1
			end
		end
	end
	return -1
end

-- 获取玩家历史充值金额，总金额减去当天充值的
function DailyChargeData:GetLeiJiChongZhiValue()
	local value = 0
	if self.chongzhi_info and self.chongzhi_info.history_recharge and self.chongzhi_info.today_recharge then
		value = self.chongzhi_info.history_recharge - self.chongzhi_info.today_recharge
	end
	return value
end

function DailyChargeData:GetFirstChargeGiveTime(cur_time, charge_type)
	local create_role_time = GameVoManager.Instance:GetMainRoleVo().create_role_time
	if charge_type == 1 then
		local time = cur_time - (TimeCtrl.Instance:GetServerTime() - create_role_time)
		if time > 0 then
			return time
		end
		return time
	else
		if TimeCtrl.Instance:GetServerTime() > 0 and create_role_time > 0 then
			local day_time_end = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
			local create_role_day_time_end = TimeUtil.NowDayTimeEnd(create_role_time)
			if day_time_end == create_role_day_time_end then
				local time = day_time_end - TimeCtrl.Instance:GetServerTime()
				if time > 0 then
					return time
				end
				return time
			else
				return 0
			end	
		end	
	end
end