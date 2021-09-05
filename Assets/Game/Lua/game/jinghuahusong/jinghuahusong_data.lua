JingHuaHuSongData = JingHuaHuSongData or BaseClass()
JingHuaHuSongData.JingHuaType = {
	None = -1,				--无	
	Big = 0,				--大灵石	
	Small = 1,				--小灵石
}
function JingHuaHuSongData:__init()
	if JingHuaHuSongData.Instance ~= nil then
		print_error("[JingHuaHuSongData] attempt to create singleton twice!")
		return
	end
	JingHuaHuSongData.Instance = self

	self.cur_commit_times = 0						--当日提交次数
	self.failure_time = 0							--失效时间
	self.gather_times = 0							--人物可采集次数
	self.cut_out_times = 0							--截取成功次数
	self.cur_jinghua_type = JingHuaHuSongData.JingHuaType.Big 		--最近一次护送的是大灵石还是小灵石，不储存None的状态, 默认大灵石
	self.remain_time = 0							--剩余时间（秒）

	self.main_role_jinghua_husong_state = 0			--当前玩家角色精华护送状态

	self.big_gather_amount = 0						--场景中大灵石的数目
	self.small_gather_amount = 0					--场景中小灵石的数目
	self.shuijin_times = 0

	self.vip_buy_times =0 				
	self.rob_count = 0 					
	self.crystal_times =0 				
	self.commit_count = 0 				
	self.husong_type = 0 				
	self.husong_status = 0				
	self.invalid_time = 0

	self.type = 0
	self.next_refresh_time_big = 0

	self.remind_level = 160 						-- 写死，低于160级不提醒玩家
end

function JingHuaHuSongData:GetCfg()
	if not self.cfg_auto then
		self.cfg_auto = ConfigManager.Instance:GetAutoConfig("cross_husong_shuijing_auto")
	end
	return self.cfg_auto
end
--根据精华的类型获取对应的其他配置
function JingHuaHuSongData:GetOtherCfgByType(jinghua_type)
	jinghua_type = jinghua_type or self.cur_jinghua_type
	for k,v in pairs(self:GetCfg().gather_cfg) do
		if jinghua_type == v.type then
			return v
		end
	end
	return nil
end
--根据精华的类型获取对应的奖励配置
function JingHuaHuSongData:GetRewardCfgByType(jinghua_type)
	jinghua_type = jinghua_type or self.cur_jinghua_type
	local result_table = {}
	for k,v in pairs(self:GetCfg().reward) do
		if jinghua_type == v.type then
			table.insert(result_table, v)
		end
	end
	return result_table
end

function JingHuaHuSongData:__delete()
	JingHuaHuSongData.Instance = nil
end

function JingHuaHuSongData:SetJingHuaHuSongInfo(protocol)
	self.cur_commit_times = protocol.param1			--当日提交次数
	self.failure_time = protocol.param2				--失效时间
	self.gather_times = protocol.param3				--剩余可采集次数
	self.cut_out_times = protocol.param4			--截取成功次数

	self.remain_time = protocol.param2 - TimeCtrl.Instance:GetServerTime()
end

function JingHuaHuSongData:GetRemainTime()
	return self.remain_time or 0
end

--获取任务ID
function JingHuaHuSongData:GetTaskId()
	if TaskData.Instance then
		return TaskData.Instance:GetVirtualLingTask().task_id or 999999
	end
	return 999999
end

function JingHuaHuSongData:SetRemainTime(remain_time)
	self.remain_time = remain_time
end

function JingHuaHuSongData:GetCurCommitTimes()
	return self.cur_commit_times or 0
end
--获得剩余可采集次数
function JingHuaHuSongData:GetGatherTimes()
	return self.gather_times or 0
end
--获得劫取次数
function JingHuaHuSongData:GetCutOutTimes()
	return self.cut_out_times or 0
end
--获取哪个等级提醒玩家
function JingHuaHuSongData:GetRemindLevel()
	return self.remind_level
end
--设置当前角色的护送状态
function JingHuaHuSongData:SetMainRoleState(state)
	self.main_role_jinghua_husong_state = state
end

--获取当前角色的护送状态
function JingHuaHuSongData:GetMainRoleState()
	return self.main_role_jinghua_husong_state
end
--设置最近一次护送的灵石为大灵石还是小灵石
function JingHuaHuSongData:SetCurJingHuaType(jinghua_type)
	self.cur_jinghua_type = jinghua_type
end

--获得最近一次护送的灵石为大灵石还是小灵石
function JingHuaHuSongData:GetCurJingHuaType()
	return self.cur_jinghua_type
end

--获取提交物品的NPC Id
function JingHuaHuSongData:GetCommitNpc()
	return self:GetCfg().gather_cfg[1].commit_npcid
end

--获取采集物所在场景Id
function JingHuaHuSongData:GetGatherSceneId(jinghua_type)
	-- jinghua_type = jinghua_type or self.cur_jinghua_type
	return self:GetCfg().other[1].scene_id
end

--获取奖励物品
function JingHuaHuSongData:GetReweardItemInfo()
	return self:GetCfg().other[1].total_reward_item
end

--获取抢夺次数
function JingHuaHuSongData:GetReweardTorobInfo()
	return self:GetCfg().other[1].commit_count
end

--获取每天最大采集数
function JingHuaHuSongData:GetReweardCollectionInfo()
	return self:GetCfg().other[1].gather_day_count
end

--获取采集物坐标
function JingHuaHuSongData:GetGatherPosX(jinghua_type)
	return self:GetOtherCfgByType(jinghua_type).gather_pos_x
end

--获取采集物坐标
function JingHuaHuSongData:GetGatherPosY(jinghua_type)
	return self:GetOtherCfgByType(jinghua_type).gather_pos_y
end

--获取采集物Id
function JingHuaHuSongData:GetGatherId(jinghua_type)
	return self:GetOtherCfgByType(jinghua_type).gather_id
end

--获取最大采集次数
function  JingHuaHuSongData:GetGatherDayCount()
	return self:GetCfg().gather_cfg[1].gather_day_count
end

--活动是否开启（客户端计算）
function JingHuaHuSongData:IsOpen()
	local time = TimeCtrl.Instance:GetServerTimeFormat()
	local time_s =  TimeCtrl.Instance:GetServerTime() 																-- 当前时间戳
	local today_s = os.time({day=time.day, month=time.month, year=time.year, hour=0, minute=0, second=0}) or 0		-- 当天开始时的时间戳
	local cur_s = time_s - today_s 																					-- 当前是当天的第几秒
	if cur_s >= self:GetCfg().other[1].open_time_s and cur_s < self:GetCfg().other[1].end_time_s then
		return true
	else
		return false
	end
end

--精华是否已经全部护送完毕
function JingHuaHuSongData:IsAllCommit()
	if self.crystal_times >= self:GetReweardCollectionInfo() then
		return true
	else
		return false
	end
end

--获得任务奖励
function JingHuaHuSongData:GetRewardItemList()
	local cur_reward = self:GetCurReward()
	if self.main_role_jinghua_husong_state == JH_HUSONG_STATUS.FULL then
		return cur_reward.total_reward_item
	elseif  self.main_role_jinghua_husong_state == JH_HUSONG_STATUS.LOST then
		return cur_reward.be_robbed_reward_item
	end
end

--设置精华采集物在场景中的数目
function JingHuaHuSongData:SetJingHuaGatherAmount(gather_id ,amount)
	if self:GetGatherId(JingHuaHuSongData.JingHuaType.Big) == gather_id then
		self.big_gather_amount = amount
	elseif self:GetGatherId(JingHuaHuSongData.JingHuaType.Small) == gather_id then
		self.small_gather_amount = amount
	end
end

--得到精华采集物在场景中的数目
function JingHuaHuSongData:GetJingHuaGatherAmount(gather_id)
	if gather_id == self:GetGatherId(JingHuaHuSongData.JingHuaType.Big) then
		return self.big_gather_amount or 0
	elseif gather_id == self:GetGatherId(JingHuaHuSongData.JingHuaType.Small) then
		return self.small_gather_amount or 0
	end
	return 0
end
--得到精华采集物在场景中的数目
function JingHuaHuSongData:GetJingHuaGatherAmountByType(jinghua_type)
	if jinghua_type == JingHuaHuSongData.JingHuaType.Big then
		return self.big_gather_amount or 0
	elseif jinghua_type == JingHuaHuSongData.JingHuaType.Small then
		return self.small_gather_amount or 0
	end
	return 0
end

function JingHuaHuSongData:GetRewardPercent()
	local max_reward_num = self:GetCfg().reward[1].total_reward_item[0].num 		--奖励最大数目
	local cur_reward = self:GetCurReward(JingHuaHuSongData.JingHuaType.Big)
	local percent = cur_reward.total_reward_item[0].num / max_reward_num * 100
	return math.ceil(percent)
end

function JingHuaHuSongData:GetCurReward(jinghua_type)
	jinghua_type = jinghua_type or self.cur_jinghua_type
	local reward_cfg = self:GetRewardCfgByType(jinghua_type)
	if not reward_cfg then return end
	for k,v in pairs(reward_cfg) do
		if self.cur_commit_times < v.commit_times then
			return v
		end
	end
end

function JingHuaHuSongData:GetNextTime(time)
	if nil == time then
		time = 0
	end

	local min = math.floor(time / 60)
	local sec = math.floor(time - min * 60)
	local next_time = ""
	if min < 10 then
		min = "0" .. min
	end

	if sec < 10 then
		sec = "0" .. sec
	end

	next_time = string.format(Language.JingHuaHuSong.NextTime, min, sec)

	return next_time
end

function JingHuaHuSongData:IsJingHuaScene(scene_id)
	if scene_id == self:GetGatherSceneId() then
		return true
	end
	return false
end

function JingHuaHuSongData:SetJingHuaHuSongTimeInfo(protocol)
	self.shuijin_times = protocol.cur_remain_gather_time_big
	self.type = protocol.type
	self.next_refresh_time_big = protocol.next_refresh_time_big
end

function JingHuaHuSongData:SetAllJingHuaHuSongInfo(protocol)
	self.vip_buy_times = protocol.vip_buy_times 				-- 购买次数
	self.rob_count = protocol.rob_count 					-- 截取成功次数
	self.crystal_times = protocol.gather_times 					-- 采集次数
	self.commit_count = protocol.commit_count 				-- 护送提交次数
	self.husong_type = protocol.husong_type 					-- 护送类型
	self.husong_status = protocol.husong_status					-- 护送状态
	self.invalid_time = protocol.invalid_time
end

function JingHuaHuSongData:GetEscortSurplusTimes()
	return self.crystal_times or 0
end



function JingHuaHuSongData:GetHuSongStatus()
	return self.husong_status or 0
end

function JingHuaHuSongData:GetInterceptTimes()
	return self.commit_count or 0
end
function JingHuaHuSongData:GetBigCrystalNum()
	return self.shuijin_times or 0
end

function JingHuaHuSongData:GetBigFushTime()
	return self.next_refresh_time_big or 0
end
function JingHuaHuSongData:GetNeedJoinActLevel()
	local min_level ,max_level = ActivityData.Instance:GetRealLevelLimit(ACTIVITY_TYPE.JINGHUA_HUSONG)
	return min_level or 0
end
