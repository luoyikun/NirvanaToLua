require("game/activity/activity_view")
require("game/activity/activity_detail_view")
require("game/activity/activity_data")
require("game/activity/activity_luckylog_view")
require("game/activity/three_other_first_view")
require("game/activity/beherrscher_show_view")

ActivityCtrl = ActivityCtrl or BaseClass(BaseController)
local SanJieOpenDay = 1 					--三界争锋—开服第几天
local GuildWarOpenDay = 2 					--仙魔争霸-开服第几天
local GongChengZhanOpenDay = 3 				--攻城战-开服第几天
local LianFuDuoChengOpenDay = 5 			--连服夺城-开服第几天

function ActivityCtrl:__init()
	if ActivityCtrl.Instance ~= nil then
		print_error("[ActivityCtrl] attempt to create singleton twice!")
		return
	end
	ActivityCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = ActivityData.New()
	self.view = ActivityView.New(ViewName.Activity)
	self.lucky_log_view = LuckyLogView.New(ViewName.LuckyLogView)
	self.detail_view = ActivityDetailView.New(ViewName.ActivityDetail)
	self.threeother_firstview = ThreeOtherFirstView.New(ViewName.ThreeOtherFirstView)
	self.beherrscher_show_view = BeherrscherShowView.New(ViewName.BeherrscherShowView)

	self.has_open_list = {}
	self.activity_join_list = {
		[3] = 0,										-- 护送
		[6] = 0,										-- 攻城战
		[21] = 0,										-- 公会争霸
		[30] = 0,										-- 仙盟答题
		[27] = 0,										-- 仙盟运镖
		[32] = 0,										-- 膜拜城主
		[34] = 0,										-- 仙盟试炼
		[3073] = 0,										-- 跨服修罗塔
		[3081] = 0,										-- 跨服水晶（没开）
		[14] = 0,										-- 灵石秘境
		[3083] = 0,										-- 珍宝秘境
		[5] = 0,										-- 仙魔战场
		[23] = 0,										-- 怒战九霄
		[26] = 0,										-- 王陵探险
		[31] = 0,										-- 乱斗战场
		[3074] = 0,										-- 巅峰对决
		[3075] = 0,										-- 战队争霸
		[3077] = 0,										-- 万灵神殿
		[3080] = 0,										-- 温泉答题
		[3082] = 0,										-- 六界争霸
		[3084] = 0,										-- 跨服钓鱼
		[3085] = 0,										-- 怒战九霄
		[3086] = 0,										-- 乱斗战场
		[3087] = 0,										-- 灵鲲之战
		[3091] = 0,										-- 连服诛魔
		[3094] = 0,										-- 灵石护送
	}

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE,BindTool.Bind(self.OnLevelChange, self))
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function ActivityCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.detail_view ~= nil then
		self.detail_view:DeleteMe()
		self.detail_view = nil
	end

	if self.threeother_firstview ~= nil then
		self.threeother_firstview:DeleteMe()
		self.threeother_firstview = nil
	end

	if self.beherrscher_show_view then
		self.beherrscher_show_view:DeleteMe()
		self.beherrscher_show_view = nil
	end
	
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.lucky_log_view ~= nil then
		self.lucky_log_view:DeleteMe()
		self.lucky_log_view = nil
	end

	if self.flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end

	if self.show_reward_timequest then
		GlobalTimerQuest:CancelQuest(self.show_reward_timequest)
		self.show_reward_timequest = nil
	end

	if self.level_change_event ~= nil then
		GlobalEventSystem:UnBind(self.level_change_event)
		self.level_change_event = nil
	end

	if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	self.activity_join_list = nil
	ActivityCtrl.Instance = nil
	self.has_open_list = nil
end

function ActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActivityStatus, "OnActivityStatus")
	self:RegisterProtocol(SCQunxianLuandouFirstRankInfo, "OnQunxianLuandouFirstRankInfo")
	self:RegisterProtocol(SCCrossRandActivityStatus, "OnCrossRandActivityStatus")
	self:RegisterProtocol(SCLuckyLogRet, "SCLuckyLogRet")

	-- 活动奖励展示
	self:RegisterProtocol(SCSceneActivityRewardInfo, "OnSCSceneActivityRewardInfo")
end

-- 活动信息
function ActivityCtrl:OnActivityStatus(protocol)
	if IS_AUDIT_VERSION then
		return
	end
	--中央滚动播报
	local content = ""
	local activity_cfg = self.data:GetActivityConfig(protocol.activity_type)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if activity_cfg ~= nil then
		local level_limit = activity_cfg.min_level
		if main_role_vo.level >= level_limit then
			local name = activity_cfg.act_name

			if activity_cfg.act_id == 1026 then
				name = Language.Common.CloseBeta
			elseif activity_cfg.act_id == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WEEKENDHAPPY then
				local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
				if time_day <= 4 then
					name = Language.Activity.WeekendHappy
				end
			end
			
			if ACTIVITY_STATUS.CLOSE == protocol.status then
				if CrossServerData.LAST_CROSS_TYPE == protocol.activity_type then
					--跨服六界场景全天可以进所以与活动开关无关，不返回原服
					if protocol.activity_type ~= ACTIVITY_TYPE.KF_GUILDBATTLE then
						CrossServerCtrl.Instance:GoBack()
					end
				end
			end

			if ACTIVITY_STATUS.CLOSE == protocol.status then
				content = name .. Language.Activity.HuoDongYiGuanBi
			elseif ACTIVITY_STATUS.STANDY == protocol.status then
				content = name .. Language.Activity.NaiXinDengDai
			elseif ACTIVITY_STATUS.OPEN == protocol.status then
				content = name .. Language.Activity.ActivityStart
			end

			-- 现在只有玩法活动有聊天传闻播报
			if ACTIVITY_PLAYING_TYPE[protocol.activity_type] then
				local ok_callback = function()
					local no_msg_condition = protocol.status == ACTIVITY_STATUS.CLOSE and (protocol.activity_type == ACTIVITY_TYPE.LUANDOUBATTLE or protocol.activity_type == ACTIVITY_TYPE.KF_LUANDOUBATTLE)
					if not no_msg_condition then
						if ACTIVITY_STATUS.STANDY ~= protocol.status then
							ChatCtrl.Instance:AddSystemMsg(content)
						end
						if ACTIVITY_STATUS.OPEN == protocol.status then
							SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
						end
					end
				end
				if ACTIVITY_ENTER_LIMIT_LIST[protocol.activity_type] then
					if ActivityData.Instance:IsAchieveLevelInLimintConfigById(protocol.activity_type) then
						ok_callback()
					end
				else
					ok_callback()
				end
			else
				ChatCtrl.Instance:AddSystemMsg(content)
				ViewManager.Instance:FlushView(ViewName.KaifuActivityView)
			end

			if CompetitionActivityData.IsActivityBiPin(protocol.activity_type) and ACTIVITY_STATUS.OPEN == protocol.status then
				CompetitionActivityData.Instance:SetBiPinRank(true)
				local rank_type_list = RankData.Instance:GetRankTypeList()
				RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[ACTIVITY_TYPE_TO_RANK_TYPE[protocol.activity_type]])
			end
		end
	end

	if ACTIVITY_ENTER_LIMIT_LIST[protocol.activity_type] then
		self.activity_join_list[protocol.activity_type] = protocol.status
		if ActivityData.Instance:IsAchieveLevelInLimintConfigById(protocol.activity_type) then
			self.data:SetActivityStatus(protocol.activity_type, protocol.status, protocol.next_status_switch_time, protocol.param_1, protocol.param_2, protocol.open_type)
		else
			local status = ACTIVITY_STATUS.CLOSE
			self.data:SetActivityStatus(protocol.activity_type, status, protocol.next_status_switch_time, protocol.param_1, protocol.param_2, protocol.open_type)
		end
	else
		self.data:SetActivityStatus(protocol.activity_type, protocol.status, protocol.next_status_switch_time, protocol.param_1, protocol.param_2, protocol.open_type)
	end
	local is_in_realopenday = ActivityData.Instance:GetRealOpenDay(protocol.activity_type)

	if protocol.status ~= ACTIVITY_STATUS.CLOSE and activity_cfg and activity_cfg.open_panel == 1 and main_role_vo.level >= activity_cfg.min_level and SceneType.Common == Scene.Instance:GetSceneType() and is_in_realopenday then
		if ACTIVITY_ENTER_LIMIT_LIST[protocol.activity_type] then
			if ActivityData.Instance:IsAchieveLevelInLimintConfigById(protocol.activity_type) then
				self:OpenPopView(protocol.activity_type)
			end
		else
			self:OpenPopView(protocol.activity_type)
		end
	end
	if FestivalActivityData.Instance:GetActivityOpenCfgById(protocol.activity_type) then
		if FestivalActivityCtrl.Instance:GetView():IsOpen() then
			FestivalActivityCtrl.Instance:GetView():Flush("open_active")
		end
	end

	if ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI == protocol.activity_type then
		KuaFuBorderlandCtrl.Instance:SendCSCrossBianJingZhiDiBossInfoReq()

		local old_act_state = KuaFuBorderlandData.Instance:GetActStates()
		if ACTIVITY_STATUS.CLOSE ~= protocol.status and 0 == Scene.Instance:GetSceneType() and old_act_state ~= protocol.status then
			local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
			local open_act_day = KuaFuBorderlandData.Instance:GetKFBorderlandActivityOtherCfg().server_open_day or 0
			if open_day < open_act_day then
				return
			end
			ViewManager.Instance:Open(ViewName.Map, TabIndex.map_world)
		end

		KuaFuBorderlandData.Instance:SetActStates(protocol.status)
	end
	
	if ACTIVITY_STATUS.STANDY == self.data:GetActivityStatusCacheData(protocol.activity_type) and ACTIVITY_STATUS.OPEN == protocol.status then
		ViewManager.Instance:FlushView(ViewName.FbIconView, "reset_count_down")

		if ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING == protocol.activity_type then
			ViewManager.Instance:FlushView(ViewName.FishingView, "open_act_flush")
		end
	end
	self.data:SetActivityStatusCacheData(protocol.activity_type, protocol.status)

	GlobalEventSystem:Fire(OtherEventType.ACTIVITY_STATUS, protocol)
end

--外部点击回调不要用
function ActivityCtrl:OpenPopView(activity_type)
	if IS_ON_CROSSSERVER or JUST_BACK_FROM_CROSS_SERVER then
		return
	end

	if activity_type == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS then
		GlobalTimerQuest:AddDelayTimer(function()
			local is_other_dialy_open = ActivityData.Instance:GetIsOtherDailyOpenExceptType(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS)
			if not is_other_dialy_open then
				self:ShowDetailView(activity_type)
			end
		end, 1)
	else
		self:ShowDetailView(activity_type)
	end
end

function ActivityCtrl:SendActivityEnterReq(activity_type, room_index)
	if not activity_type then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSActivityEnterReq)
	protocol.activity_type = activity_type
	protocol.room_index = room_index or 0
	protocol:EncodeAndSend()
end

function ActivityCtrl:CloseView()
	if self.view then
		self.view:Close()
	end
end

function ActivityCtrl:OnCrossRandActivityStatus(protocol)
	self.data:AddCrossActivityInfo(protocol)
	if not self.data:CanShowActivityByLevelFloor(protocol.activity_type) then
		protocol.status = ACTIVITY_STATUS.CLOSE
	end
	self.data:SetCrossRandActivityStatus(protocol.activity_type, protocol.status, protocol.begin_time, protocol.end_time)
end

--活动面板点击参加活动后调用的方法
function ActivityCtrl:ShowDetailView(act_id, is_from_activity_view)
	if not act_id then return end
	if IS_AUDIT_VERSION then
		return
	end

	if activity_type == ACTIVITY_TYPE.QUESTION then		--答题面板
		AnswerCtrl.Instance:OpenView()
		return
	elseif act_id == ACTIVITY_TYPE.KF_ONEVONE then
		KuaFu1v1Ctrl.Instance:OpenView()
		return
	elseif act_id == ACTIVITY_TYPE.KF_PVP then
		KuafuPVPCtrl.Instance:OpenView()
		return
	elseif act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		ViewManager.Instance:Open(ViewName.ClashTerritory)
		return
	elseif act_id == ACTIVITY_TYPE.GONGCHENGZHAN then
		local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_info = ActivityData.Instance:GetActivityStatuByType(act_id)

		if nil ~= activity_info and HefuActivityData.Instance:IsHeFuFirstCombine() and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.HeFuCombatFirstView)
			return
		end
		if time_day <= GongChengZhanOpenDay and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.CityCombatFirstView)
		else
			if ViewManager.Instance:IsOpen(ViewName.CityCombatFirstView) then
				ViewManager.Instance:Close(ViewName.CityCombatFirstView)
			end
			ViewManager.Instance:Open(ViewName.CityCombatView)
		end
		return
	elseif act_id == ACTIVITY_TYPE.GUILDBATTLE then
		local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_info = ActivityData.Instance:GetActivityStatuByType(act_id)

		if nil ~= activity_info and HefuActivityData.Instance:IsHeFuFirstGuildWar() and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.XianMengWarView)
			return
		end

		if ViewManager.Instance:IsOpen(ViewName.GuildFirstView) then
			ViewManager.Instance:Close(ViewName.GuildFirstView)
		end
		if time_day <= GuildWarOpenDay and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.GuildFirstView)
		else
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			local move_speed = GameVoManager.Instance:GetMainRoleVo().move_speed
			if guild_id == 0 and move_speed == 0 then
				return
			elseif guild_id <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
			elseif guild_id > 0 then
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
			end
		end
		return
	elseif act_id == ACTIVITY_TYPE.GONGCHENG_WORSHIP then
		ViewManager.Instance:Open(ViewName.CityCombatView)
		return
	elseif act_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
		-- local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		-- local activity_info = ActivityData.Instance:GetActivityStatuByType(act_id)
		-- local residue_time = ActivityData.Instance:GetResidueTime(act_id)
		-- if time_day <= LianFuDuoChengOpenDay + residue_time and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
		-- 	ViewManager.Instance:Open(ViewName.LianFuDuoChengFirstView)
		-- else
			if ViewManager.Instance:IsOpen(ViewName.LianFuDuoChengFirstView) then
				ViewManager.Instance:Close(ViewName.LianFuDuoChengFirstView)
			end
			if IS_ON_CROSSSERVER or not OpenFunData.Instance:CheckIsHide("kf_battle") then
				return
			end
			local flag = ActivityData.Instance:IsAchieveLevelInLimintConfigById(act_id)
			if flag or is_from_activity_view then
				ViewManager.Instance:Open(ViewName.KuaFuBattle)
			end
		-- end
		return
	elseif act_id == ACTIVITY_TYPE.KF_GUILDBATTLE_READYACTIVITY then
		ViewManager.Instance:Open(ViewName.LianFuDuoChengFirstView)
		return
	elseif act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB then
		ViewManager.Instance:Open(ViewName.LingKunBattleDetailView)
		return
	elseif act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS then
		if IS_ON_CROSSSERVER or not OpenFunData.Instance:CheckIsHide("kf_battle_pre") then
			return
		end

		if ActivityData.Instance:IsAchieveLevelInLimintConfigById(act_id) or is_from_activity_view then
			ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.liujie_bossinfo)
		end
		return
	end
	if act_id == ACTIVITY_TYPE.KF_MONTH_BLACK_WIND_HIGHT then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.shenyu_zhengbao)
	elseif act_id == ACTIVITY_TYPE.KF_TUANZHAN then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.nuzhan_jiuxiao)
	elseif act_id == ACTIVITY_TYPE.KF_LUANDOUBATTLE then
		ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.luandou_zhanchang)
	elseif act_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		local is_open = ActivityData.Instance:GetRealOpenDay(ACTIVITY_TYPE.GUILD_BONFIRE)
		if is_open then
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			local move_speed = GameVoManager.Instance:GetMainRoleVo().move_speed
			if guild_id <= 0 and move_speed <= 0 then
				return
			end
			self.detail_view:SetActivityId(act_id)
			self.detail_view:Open()
			self.detail_view:Flush()
		end
	elseif act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		local time_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_info = ActivityData.Instance:GetActivityStatuByType(act_id)

		if time_day <= SanJieOpenDay and nil ~= activity_info and ACTIVITY_STATUS.STANDY == activity_info.status then
			ViewManager.Instance:Open(ViewName.ThreeOtherFirstView)
		else
			if ViewManager.Instance:IsOpen(ViewName.ThreeOtherFirstView) then
				ViewManager.Instance:Close(ViewName.ThreeOtherFirstView)
			end
			self.detail_view:SetActivityId(act_id)
			self.detail_view:Open()
			self.detail_view:Flush()
		end
		return
	elseif act_id == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI then
		ViewManager.Instance:Open(ViewName.Map, TabIndex.map_world)
		return
	else 
		self.detail_view:SetActivityId(act_id)
		self.detail_view:Open()
		self.detail_view:Flush()
	end
end

function ActivityCtrl:GetDetailView()
	return self.detail_view
end

function ActivityCtrl:SendQunxianLuandouFirstRankInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQunxianLuandouFirstRankReq)
	protocol:EncodeAndSend()
end

function ActivityCtrl:OnKFtowerBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerBuyBuffReq)
	protocol:EncodeAndSend()
end

function ActivityCtrl:OnQunxianLuandouFirstRankInfo(protocol)
	self.data:SetQunxianLuandouFirstRankInfo(protocol)
	self.detail_view:Flush()

	if ViewManager.Instance:IsOpen(ViewName.BeherrscherShowView) then
		self.beherrscher_show_view:OpenCallBack()
	end
end

--设置活动详细数据(右边)
function ActivityCtrl:SetDetailData(data)
	--右边活动描述滚动文字重置
	self.view.content.transform:SetLocalPosition(self.view.content.transform.localPosition.x,0,self.view.content.transform.localPosition.z)
	self.view:SetDetailData(data)
	self.data_tmp = data
end

--参加活动按钮点击事件
function ActivityCtrl:ClickPart(is_from_activity_view)
	local act_id = self.data_tmp.act_id
	self:ShowDetailView(act_id, is_from_activity_view)
end

function ActivityCtrl:SendActivityLogSeq(activity_type)
	self.data:SendActivityLogType(activity_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetLuckyLog)
	protocol.activity_type = activity_type or 0
	protocol:EncodeAndSend()
end

function ActivityCtrl:SCLuckyLogRet(protocol)
	self.data:SetActivityLogInfo(protocol)
	if not JUST_BACK_FROM_CROSS_SERVER then
		ViewManager.Instance:Open(ViewName.LuckyLogView)
	end
end

function ActivityCtrl:OnSCSceneActivityRewardInfo(protocol)
	if protocol.reward_id == 0 then
		return
	end

	local not_got = false
	if protocol.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CHALLENGEFIELD then
		if self.arena_reward_record_list == nil then
			self.arena_reward_record_list = {}
		end
		if protocol.reward_type and protocol.param then
			local num = protocol.reward_type * 10000 + protocol.param
			for k,v in pairs(self.arena_reward_record_list) do
				if v == num then
					not_got = true
					break
				end
			end
			if not not_got then
				table.insert(self.arena_reward_record_list, num)
			end
		end
	end

	--处理开服论剑未领取时，从跨服返回会下发的情况
	if JUST_BACK_FROM_CROSS_SERVER and not_got and protocol.activity_id == ACTIVITY_TYPE.REWARD_SOURCE_ID_CHALLENGEFIELD then
		return
	end
	self.create_btn = true
	self.data:AddToRewardList(protocol)
	
	if self.show_reward_timequest == nil then
		self.show_reward_timequest = GlobalTimerQuest:AddDelayTimer(function ()
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ActivityReward, true)

			if self.show_reward_timequest ~= nil then
				GlobalTimerQuest:CancelQuest(self.show_reward_timequest)
				self.show_reward_timequest = nil
			end
		end, 1)
	end
end

function ActivityCtrl:MainuiOpenCreate()
	if self.create_btn then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ActivityReward, true)
		self.create_btn = false
	end
end

function ActivityCtrl:SetBtnStatus(status)
	self.create_btn = status
end


function ActivityCtrl:ShowGuildYunBiaoButton(index, status)
		local act_id = ACTIVITY_TYPE.GUILD_BONFIRE
		self.detail_view:SetActivityId(act_id)
		self.detail_view:Open()
		self.detail_view:SetGuildYunBiaoText(index, status)
		self.detail_view:Flush()
end

function ActivityCtrl:OnRecvMainRoleInfo()
	if IS_AUDIT_VERSION then
		return
	end
	if self.data:GetActivityIsOpen(ACTIVITY_TYPE.GUILDBATTLE) then
		local is_open = ActivityData.Instance:GetRealOpenDay(ACTIVITY_TYPE.GUILDBATTLE)
		if is_open and Scene.Instance:GetSceneType() == SceneType.Common then
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			if guild_id > 0 then
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
			end
		end
	end
	if self.data:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) then
		local is_open = ActivityData.Instance:GetRealOpenDay(ACTIVITY_TYPE.GUILD_BONFIRE)
		if is_open and Scene.Instance:GetSceneType() == SceneType.Common then
			self.detail_view:SetActivityId(ACTIVITY_TYPE.GUILD_BONFIRE)
			self.detail_view:Open()
			self.detail_view:Flush()
		end
	end
	if self.activity_join_list then
		for k,v in pairs(self.activity_join_list) do
			if self.data:GetIsOpenLevel(k) and v > 0 then
				local is_open = ActivityData.Instance:GetRealOpenDay(k)
				if is_open and Scene.Instance:GetSceneType() == SceneType.Common then
					if ActivityData.Instance:IsAchieveLevelInLimintConfigById(k) then
						local activity_info = self.data:GetActivityStatuByType(k)
						if k == ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIUJIE_BOSS and KuafuGuildBattleData.Instance:IsAnyBossAlive() then
							if activity_info then
								activity_info.status = v
								if v > 1 and self.has_open_list[k] == nil then
									self.has_open_list[k] = true
									self:ShowDetailView(k)
								end
							end
						else
							if activity_info then
								activity_info.status = v
								if v > 1 and self.has_open_list[k] == nil then
									self.has_open_list[k] = true
									self:ShowDetailView(k)
								end
							end
						end
					end
				end
			end
		end
	end
	if not IS_ON_CROSSSERVER then
		KuaFuTargetCtrl.Instance:MainuiOpen()
	end
	if not DelayOnceRemindList[RemindName.JingCai_Act_Delay] then
		RemindManager.Instance:Fire(RemindName.JingCai_Act_Delay)
	end
end

-- 玩家等级更变
function ActivityCtrl:OnLevelChange(obj, new_level, old_level)
	if IS_AUDIT_VERSION then
		return
	end
	local cross_activity_info_list = self.data:GetCrossActivityInfoList()
	if cross_activity_info_list then
		for k,v in pairs(cross_activity_info_list) do
			if v.activity_type then
				local new_status = self.data:CanShowActivityByLevelFloor(v.activity_type, new_level)
				local old_status = self.data:CanShowActivityByLevelFloor(v.activity_type, old_level)
				if new_status ~= old_status then
					self:OnCrossRandActivityStatus(v)
				end
			end
		end
	end
end
