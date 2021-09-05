require("game/guild/guild_view")
require("game/guild/guild_boss_view")
require("game/guild/guild_apply_view")
require("game/guild/guild_data")
require("game/guild/guild_station_view")
require("game/guild/guild_redpacket")
require("game/guild/guild_redpacket_tips")
require("game/guild/guild_signin_view")
require("game/guild/tips_guild_portrait_view")
require("game/guild/guild_donateWindow_view")
require("game/guild/guild_operation_view")
require("game/guild/guild_notice_view")
require("game/guild/guild_box_tip")
require("game/guild/guild_box_assist_view")
require("game/guild/guild_pre_view")
require("game/guild/guild_yunbiao")
require("game/guild/guild_answer_view")
require("game/guild/guild_wage_view")
require("game/guild/guild_wage_view")
require("game/guild/guild_box_get_tip_view")
require("game/guild/guild_show_view")
require("game/guild/guild_invite_view")
require("game/guild/guild_warehouse/drop_down_fixation_view")
require("game/guild/guild_warehouse/drop_down_scroll_view")
require("game/guild/guild_warehouse/guild_warehouse_view")
require("game/guild/guild_warehouse/contribute_equip_view")
require("game/guild/guild_warehouse/tips_guild_duihuan_view")

GuildCtrl = GuildCtrl or  BaseClass(BaseController)
local old_guild_gongxian = nil
local member_full_reminder_time = 20 * 60
function GuildCtrl:__init()
	if GuildCtrl.Instance ~= nil then
		print_error("[GuildCtrl] attempt to create singleton twice!")
		return
	end
	GuildCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = GuildView.New(ViewName.Guild)
	self.boss_view = GuildBossView.New(ViewName.GuildBoss)
	self.apply_view = GuildApplyView.New(ViewName.GuildApply)
	self.guild_wage_view = GuildWageView.New(ViewName.GuildWageView)
	self.guild_wage_view = GuildWageView.New(ViewName.GuildWageView)
	self.guild_data = GuildData.New()
	self.guild_station_view = GuildStationView.New()
	self.guild_redpacket_tips = GuildRedPacketTips.New()
	self.guild_redpacket_view = GuildRedPacketView.New(ViewName.GuildRedPacket)
	self.guild_signin_view = GuildSigninView.New()
	self.guild_portrait_view = TipsGuildPortraitView.New()
	self.guild_donateWindow_view = DonateWindowView.New()
	self.guild_operation_view = GuildOperationView.New()
	self.guild_operation_zhaoren_view = GuildOperationZhaoRenView.New()
	self.guild_notice_view = GuildNoticeView.New()
	self.guild_box_tip = GuildBoxTips.New()
	self.guild_assist_view = GuildAssistView.New()
	self.guild_invite_view = GuildInviteView.New()
	self.drop_down_fixation_view = DropDownFixationView.New(ViewName.DropDownFixationView)
	self.drop_down_scroll_view = DropDownScrollView.New(ViewName.DropDownScrollView)
	self.guild_warehouse_view = GuildWarehouseView.New(ViewName.GuildWarehouseView)

	self.guild_pre_view = GuildPreView.New() 
	self.guild_show_view = GuildShowView.New(ViewName.GuildShowView)	-- 仙盟展示输出功能
	self.guild_box_get_tip = GuildBoxGetTips.New(ViewName.GuildBoxGetTips)

	self.contribute_equip_view = ConTributeEquipView.New()
	self.guild_duihuan_view = TipGuildDuiHuanView.New()

	self.select_activity_id = nil

	self.last_reminder_time = -99999
	self.guild_answer_task = GuildAnswerTask.New(ViewName.GuildAnswerTask)
	self.maze_has_answered_list = {}
	self.clean_list = {count = 0, list = {}}
	self.has_yunbiao = false
	self.create_model = {                                           -- 创建公会模式
		coin = 1,
		jianmengling = 2,
	}
	self.guild_info_type = {										-- 公会信息类型
		INVALID = 0,
		ALL_GUILD_BASE_INFO = 1,									-- 所有公会基本信息
		GUILD_APPLY_FOR_INFO = 2,									-- 公会申请列表
		GUILD_MEMBER_LIST = 3,										-- 公会成员列表
		GUILD_INFO = 4,												-- 公会信息
		GUILD_EVENT_LIST = 5,										-- 公会日志列表
		APPLY_FOR_JOIN_GUILD_LIST = 6,								-- 已申请加入的公会列表
		INVITE_LIST = 7,											-- 邀请列表
		GUILD_INFO_TYPE_GONGZI_LIST = 8,							-- 工资列表
		MAX = 99,
	}
	self.role_list = {}
	self.cg_complete_list = {}

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DayCountChange, self))
	self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind1(self.DayChange, self))
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnChangeScene, self))
end

function GuildCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCreateGuild, "OnCreateGuild")
	self:RegisterProtocol(SCApplyForJoinGuild, "OnApplyForJoinGuild")
	self:RegisterProtocol(SCGuildBaseInfo, "OnGuildInfo")
	self:RegisterProtocol(SCAllGuildBaseInfo, "OnAllGuildInfoList")
	self:RegisterProtocol(SCApplyForJoinGuildAck, "OnApplyForJoinGuildAck")
	self:RegisterProtocol(SCGuildMemberList, "OnGuildMemberList")
	self:RegisterProtocol(SCChangeNotice, "OnChangeNotice")
	self:RegisterProtocol(SCQuitGuild, "OnQuitGuild")
	self:RegisterProtocol(SCGuildCheckCanDelateAck, "GuildCheckCanDelateAck")
	self:RegisterProtocol(SCAddGuildExpSucc, "OnJuanXianResult")
	self:RegisterProtocol(SCRoleGuildInfoChange, "OnRoleGuildInfoChange")
	self:RegisterProtocol(SCGuildRoleGuildInfo, "OnGuildRoleGuildInfo")
	self:RegisterProtocol(SCGuildGetApplyForList, "OnGuildApplyForList")
	self:RegisterProtocol(SCKickoutGuild, "OnKickoutGuild")
	self:RegisterProtocol(SCGuildBoxInfo, "OnGuildBoxInfo")
	self:RegisterProtocol(SCGuildBoxNeedAssistInfo, "OnGuildBoxNeedAssistInfo")
	self:RegisterProtocol(SCGuildMemberSos, "OnSCGuildMemberSos")
	self:RegisterProtocol(SCGuildBossInfo, "OnGuildBossInfo")
	self:RegisterProtocol(SCAppointGuild, "OnAppointGuild")
	self:RegisterProtocol(SCGuildStorgeInfo, "OnGuildStorgeInfo")
	self:RegisterProtocol(SCGuildStorgeChange, "OnGuildStorgeChange")
	self:RegisterProtocol(SCGuildResetName, "OnGuildResetName")
	self:RegisterProtocol(SCNotifyGuildSuper, "OnNotifyGuildSuper")
	self:RegisterProtocol(SCGuildBossActivityInfo, "OnGuildBossActivityInfo")
	self:RegisterProtocol(SCInviteNotify, "OnInviteNotify")
	self:RegisterProtocol(SCInviteGuild, "OnInviteGuild")
	self:RegisterProtocol(SCGuildOperaSucc, "OnGuildOperaSucc")
	self:RegisterProtocol(SCGuildMemberNum, "OnGuildMemberNum")
	self:RegisterProtocol(SCGulidReliveTimes, "OnGulidReliveTimes")
	self:RegisterProtocol(SCGulidBossRedbagInfo, "OnGulidBossRedbagInfo")
	self:RegisterProtocol(CSReplyGuildSosReq)
	--仙盟红包
	self:RegisterProtocol(SCGuildRedPocketListInfo, "OnGuildRedPocketListInfo")
	self:RegisterProtocol(SCNoticeGuildPaperInfo, "OnNoticeGuildPaperInfo")
	self:RegisterProtocol(CSGuildRedPaperListInfoReq)
	self:RegisterProtocol(CSCreateGuildRedPaperReq)
	self:RegisterProtocol(CSSingleChatRedPaperRole)

	-- 公会迷宫
	self:RegisterProtocol(CSGuildMazeOperate)
	self:RegisterProtocol(SCGuildMemberMazeInfo, "OnGuildMemberMazeInfo")
	self:RegisterProtocol(SCGuildMazeRankInfo, "OnGuildMazeRankInfo")

	-- 仙盟签到
	self:RegisterProtocol(CSGuildSinginReq)
	self:RegisterProtocol(SCGuildSinginAllInfo, "OnSCGuildSinginAllInfo")
	-- 仙盟事件
	self:RegisterProtocol(SCGuildEventList, "OnSCGuildEventList")

	-- 仙盟答题
	self:RegisterProtocol(SCGuildQuestionPlayerInfo, "OnGuildQuestionPlayerInfo")
	self:RegisterProtocol(SCGuildQuestionQuestionInfo, "OnGuildQuestionQuestionInfo")
	self:RegisterProtocol(SCGuildQuestionGuildRankInfo, "OnGuildQuestionGuildRankInfo")
	self:RegisterProtocol(CSGuildQuestionEnterReq)

	self:RegisterProtocol(SCGuildTianCiTongBiRankInfo, "SCGuildTianCiTongBiRankInfo")
	self:RegisterProtocol(SCGuildSyncTianCiTongBi,"SCGuildSyncTianCiTongBi")
	self:RegisterProtocol(SCGuildTianCiTongBiUserGatherChange,"SCGuildTianCiTongBiUserGatherChange")
	self:RegisterProtocol(SCGuildTianCiTongBiResult,"SCGuildTianCiTongBiResult")
	self:RegisterProtocol(SCGuildTianCiTongBiNpcinfo,"SCGuildTianCiTongBiNpcinfo")
	self:RegisterProtocol(SCGuildTianCiTongBiGatherAOIInfo,"SCGuildTianCiTongBiGatherAOIInfo")
	-- 仙盟输出展示
	self:RegisterProtocol(CSGuildInfoStatisticReq)
	self:RegisterProtocol(SCGuildInfoStatistic, "SCGuildInfoStatistic")
	self:RegisterProtocol(SCGuildMvpInfo, "SCGuildMvpInfo")
	self:RegisterProtocol(SCGuildStorageLogList, "SCGuildStorageLogList")

	--仙盟工资排行
	self:RegisterProtocol(SCGuildGongziRankList, "OnSCGuildGongziRankList")

	-- 珍稀日志信息
	self:RegisterProtocol(SCGuildRareLogRet,"OnSCGuildRareLogRet")
end

function GuildCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.guild_redpacket_view ~= nil then
		self.guild_redpacket_view:DeleteMe()
		self.guild_redpacket_view = nil
	end

	self.guild_redpacket_tips:DeleteMe()
	self.guild_redpacket_tips = nil

	if self.boss_view ~= nil then
		self.boss_view:DeleteMe()
		self.boss_view = nil
	end

	if self.guild_donateWindow_view ~= nil then
		self.guild_donateWindow_view:DeleteMe()
		self.guild_donateWindow_view = nil
	end

	if self.apply_view ~= nil then
		self.apply_view:DeleteMe()
		self.apply_view = nil
	end

	if self.guild_data ~= nil then
		self.guild_data:DeleteMe()
		self.guild_data = nil
	end

	if self.guild_station_view ~= nil then
		self.guild_station_view:DeleteMe()
		self.guild_station_view = nil
	end

	if nil ~= self.guild_portrait_view then
		self.guild_portrait_view:DeleteMe()
		self.guild_portrait_view = nil
	end

	if nil ~= self.guild_operation_view then
		self.guild_operation_view:DeleteMe()
		self.guild_operation_view = nil
	end

	if nil ~= self.guild_operation_zhaoren_view then
		self.guild_operation_zhaoren_view:DeleteMe()
		self.guild_operation_zhaoren_view = nil
	end

	if nil ~= self.guild_notice_view then
		self.guild_notice_view:DeleteMe()
		self.guild_notice_view = nil
	end

	if nil ~= self.guild_box_tip then
		self.guild_box_tip:DeleteMe()
		self.guild_box_tip = nil
	end

	if nil ~= self.guild_assist_view then
		self.guild_assist_view:DeleteMe()
		self.guild_assist_view = nil
	end

	if nil ~= self.guild_pre_view then
		self.guild_pre_view:DeleteMe()
		self.guild_pre_view = nil
	end

	if nil ~= self.guild_wage_view then
		self.guild_wage_view:DeleteMe()
		self.guild_wage_view = nil
	end

	if nil ~= self.guild_yunbiao_skill_render then
		self.guild_yunbiao_skill_render:DeleteMe()
		self.guild_yunbiao_skill_render = nil
	end

	if self.role_online_change then
		GlobalEventSystem:UnBind(self.role_online_change)
		self.role_online_change = nil
	end

	if self.guild_box_get_tip then
		self.guild_box_get_tip:DeleteMe()
		self.guild_box_get_tip = nil
	end

	if self.contribute_equip_view then
		self.contribute_equip_view:DeleteMe()
		self.contribute_equip_view = nil
	end

	if self.guild_duihuan_view then
		self.guild_duihuan_view:DeleteMe()
		self.guild_duihuan_view = nil
	end

	if self.guild_show_view then
		self.guild_show_view:DeleteMe()
		self.guild_show_view = nil
	end

	if self.guild_invite_view then
		self.guild_invite_view:DeleteMe()
		self.guild_invite_view = nil
	end

	if self.drop_down_fixation_view then
		self.drop_down_fixation_view:DeleteMe()
		self.drop_down_fixation_view = nil
	end

	if self.drop_down_scroll_view then
		self.drop_down_scroll_view:DeleteMe()
		self.drop_down_scroll_view = nil
	end

	if self.guild_warehouse_view then
		self.guild_warehouse_view:DeleteMe()
		self.guild_warehouse_view = nil
	end

	self:RemoveCountDown()
	self:CancelQuest()
	GuildCtrl.Instance = nil
end


-- 设置固定下拉列表
function GuildCtrl:SetDropDownFixationViewParam(vector, list_name, select_callback, cancle_callback, close_callback)
	self.drop_down_fixation_view:SetFramePosAndListName(vector, list_name)
	self.drop_down_fixation_view:SetCallBack(select_callback)
	self.drop_down_fixation_view:SetCallBack(cancle_callback , "Cancel")
	self.drop_down_fixation_view:SetCloseCallBack(close_callback)
	ViewManager.Instance:Open(ViewName.DropDownFixationView)
end

-- 设置滚动的下拉列表
function GuildCtrl:SetDropDownScrollViewParam(vector, list_name, select_callback, cancle_callback, close_callback)
	self.drop_down_scroll_view:SetFramePosAndListName(vector, list_name)
	self.drop_down_scroll_view:SetCallBack(select_callback)
	self.drop_down_scroll_view:SetCallBack(cancle_callback , "Cancel")
	self.drop_down_scroll_view:SetCloseCallBack(close_callback)
	ViewManager.Instance:Open(ViewName.DropDownScrollView)	
end


function GuildCtrl:ShowGuildPortraitView()
	self.guild_portrait_view:Open()
end

-- 关闭所有弹窗
function GuildCtrl:CloseAllWindow()
	self.view:CloseAllWindow()
end

function GuildCtrl:MainuiOpen()
	self:CancelQuest()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		if TimeCtrl.Instance:GetCurOpenServerDay() > 1 then
			if self.role_online_change then
				GlobalEventSystem:UnBind(self.role_online_change)
				self.role_online_change = nil
			end
			self:CancelQuest()
			return
		end
		self:CheckMemberFull()
	end, 60)
	GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_INFO_REQ)
	GuildCtrl.Instance:SendGuildInfoReq()

	self:SendGetGuildRareLog()
end

function GuildCtrl:DayCountChange(day_counter_id)
	if day_counter_id == -1 or day_counter_id == DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD then
		local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD) or 0
		GuildData.Instance:SetGuildFuLiCount(day_count)
		if self.view then
			self.view:Flush()
		end
	end
end

function GuildCtrl:MainRoleInfo()
	if not IS_ON_CROSSSERVER then
		self:SendAllGuildInfoReq()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		GuildData.Instance.guild_id = vo.guild_id
		GuildData.Instance:SetLastLeaveGuildTime(vo.last_leave_guild_time)
		if(vo.guild_id == 0) then
			return
		end
		self:SendGuildInfoReq()
		self:SendGuildApplyListReq()
		self:SendAllGuildMemberInfoReq()
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
		self:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_GET_INFO)
	end
end

function GuildCtrl:GuildViewOpen()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	GuildData.Instance.guild_id = vo.guild_id
	if(guild_id == 0) then
		self:SendAllGuildInfoReq()
		return
	end
	self:SendGuildInfoReq()
	self:SendAllGuildMemberInfoReq()
end

-- function GuildCtrl:InitGuildView()
-- 	if(self.view == nil) then
-- 		return
-- 	end
-- 	local vo = GameVoManager.Instance:GetMainRoleVo()
-- 	GuildData.Instance.guild_id = vo.guild_id

-- 	if(GuildData.Instance.guild_id <= 0) then -- 没有加入公会
-- 		self:SendAllGuildInfoReq()
-- 		self.view:InitViewCase1() --当没有加入公会时VIew面板的初始化
-- 	else
-- 		self:SendGuildInfoReq()
-- 		self.view:InitViewCase2() --当加入公会后VIew面板的初始化
-- 	end
-- end

-- 请求获得公会信息
function GuildCtrl:SendGuildInfoReq(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_INFO
	protocol.guild_id = guild_id or GameVoManager.Instance:GetMainRoleVo().guild_id
	protocol:EncodeAndSend()
end

-- 请求获得公会工资信息
function GuildCtrl:SendGuildWageInfoReq(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_INFO_TYPE_GONGZI_LIST
	protocol.guild_id = guild_id or GameVoManager.Instance:GetMainRoleVo().guild_id
	protocol:EncodeAndSend()
end

-- 请求获得公会日志信息
function GuildCtrl:SendGuildEventListReq(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_EVENT_LIST
	protocol.guild_id = guild_id or GameVoManager.Instance:GetMainRoleVo().guild_id
	protocol:EncodeAndSend()
end


-- 请求获得全部公会信息
function GuildCtrl:SendAllGuildInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.ALL_GUILD_BASE_INFO
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求获得申请加入自己公会的玩家列表
function GuildCtrl:SendGuildApplyListReq()
	if GuildData.Instance.guild_id <= 0 then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_APPLY_FOR_INFO
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求获得公会成员信息
function GuildCtrl:SendAllGuildMemberInfoReq(guild_id)
	if GuildData.Instance.guild_id <= 0 then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_MEMBER_LIST
	protocol.guild_id = guild_id or GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求更改公会公告
function GuildCtrl:SendGuildChangeNoticeReq(notice)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildChangeNotice)
	protocol.guild_id = GuildData.Instance.guild_id
	protocol.notice = notice
	protocol:EncodeAndSend()
end

-- 获得仙盟基本信息
function GuildCtrl:OnGuildInfo(protocol)
	local guildvo = {}
	guildvo.guild_id = protocol.guild_id
	guildvo.guild_name = protocol.guild_name
	guildvo.guild_level = protocol.guild_level
	guildvo.guild_exp = protocol.guild_exp
	guildvo.guild_max_exp = protocol.guild_max_exp
	guildvo.guild_totem_level = protocol.totem_level
	guildvo.guild_totem_exp = protocol.totem_exp
	guildvo.cur_member_count = protocol.cur_member_count
	guildvo.max_member_count = protocol.max_member_count
	guildvo.tuanzhang_uid = protocol.tuanzhang_uid
	guildvo.tuanzhang_name = protocol.tuanzhang_name
	guildvo.create_time = protocol.create_time
	guildvo.camp = protocol.camp
	guildvo.vip_level = protocol.vip_level
	guildvo.applyfor_setup = protocol.applyfor_setup
	guildvo.guild_notice = protocol.guild_notice
	guildvo.auto_kickout_setup = protocol.auto_kickout_setup
	guildvo.applyfor_need_capability = protocol.applyfor_need_capability
	guildvo.applyfor_need_level = protocol.applyfor_need_level
	guildvo.guild_callin_times = protocol.callin_times
	guildvo.my_lucky_color = protocol.my_lucky_color
	guildvo.active_degree = protocol.active_degree
	guildvo.total_capability = protocol.total_capability
	guildvo.rank = protocol.rank
	guildvo.totem_exp_today = protocol.totem_exp_today
	guildvo.is_auto_clear = protocol.is_auto_clear
	guildvo.avater_changed = protocol.avater_changed
	guildvo.is_today_biaoche_start = protocol.is_today_biaoche_start
	guildvo.guild_avatar_key_big = protocol.guild_avatar_key_big
	guildvo.guild_avatar_key_small = protocol.guild_avatar_key_small
	guildvo.guild_total_gongzi = protocol.guild_total_gongzi
	if protocol.guild_id == GameVoManager.Instance:GetMainRoleVo().guild_id then
		for k, v in pairs(guildvo) do
			GuildDataConst.GUILDVO[k] = v
		end
		GuildData.Instance:GetReminder(Guild_PANEL.totem)
		if self.view then
			self.view:Flush()
		end
		if GuildChatView.Instance:IsOpen() then
			GuildChatView.Instance:Flush("view")
		end
		if self.guild_wage_view:IsOpen() then
			self.guild_wage_view:Flush()
		end
		RemindManager.Instance:Fire(RemindName.GuildWage)
		AvatarManager.Instance:SetAvatarKey(protocol.guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small, true)

		Scene.Instance:GetMainRole():SetAttr("guild_id", protocol.guild_id)
	else
		local other_guild_info = GuildData.Instance:GetOtherGuildInfo()
		for k, v in pairs(guildvo) do
			other_guild_info[k] = v
		end
		if self.view then
			self.view:FlushRequest()
		end
	end

	if self.join_new_guild then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.tuanzhang_uid)
		self.join_new_guild = false
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.GuildStation then
			scene_logic:ChangeQizhi(protocol.totem_level or 0)
		end
	end
	self:CheckMemberFull()
	self:SetGuildYunbiaoSkillState(self:CheckGuildYunBiaoState())
end

-- 所有仙盟信息列表
function GuildCtrl:OnAllGuildInfoList(protocol)
	GuildDataConst.GUILD_INFO_LIST.free_create_guild_times = protocol.free_create_guild_times
	GuildDataConst.GUILD_INFO_LIST.is_first = protocol.is_first
	GuildDataConst.GUILD_INFO_LIST.count = protocol.count
	local list = protocol.info_list
	if list then
		table.sort(list, function(a, b) return a.total_capability > b.total_capability end)
	end
	GuildDataConst.GUILD_INFO_LIST.list = list
	GuildDataConst.GUILD_INFO_LIST.is_server_backed = true

	if self.view then
		self.view:Flush()
	end

	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
 		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GUILD_INVITE, false)
 	end
	if CityCombatCtrl.Instance.view:IsOpen() then
		CityCombatCtrl.Instance.view:Flush("view")
	end
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
end

-- 创建公会结果
function GuildCtrl:OnCreateGuild(protocol) -- 0 = 成功
	self.ret = protocol.ret
	if(self.ret ~= 0) then      -- 失败
		return
	end
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.Event_Type_1, GameVoManager.Instance:GetMainRoleVo().name))
	GuildData.Instance.guild_id = protocol.guild_id
	Scene.Instance:GetMainRole():SetAttr("guild_id", protocol.guild_id)
	self:CloseAllWindow()
	self:SendGuildApplyListReq()
	self:SendAllGuildMemberInfoReq()
	self:SendGuildInfoReq()
	self:SendAllGuildInfoReq()
	-- self.view:InitViewCase2()
	self.view:ChangeToIndex(TabIndex.guild_info)
	self.view:FlushTabbarByIndex(TabIndex.guild_info)
end

-- 申请加入公会结果
function GuildCtrl:OnApplyForJoinGuild(protocol)
	if 0 == protocol.ret then 						-- 0：成功 其它失败
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ApplyForJoinGuild)
	end
end

-- 请求创建公会
function GuildCtrl:SendGuildBaseInfoReq(name, guild_type, knapsack_index)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CanNotCreateInCross)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateGuild)
	protocol.guild_name = name
	protocol.create_guild_type = guild_type
	protocol.knapsack_index = knapsack_index
	protocol.guild_notice = ""
	protocol:EncodeAndSend()
end

--  请求加入公会 is_auto_join == 1 自动加入公会
function GuildCtrl:SendApplyForJoinGuildReq(guild_id, is_auto_join)
	local protocol = ProtocolPool.Instance:GetProtocol(CSApplyForJoinGuild)
	protocol.guild_id = guild_id or 0
	protocol.is_auto_join = is_auto_join or 0
	protocol:EncodeAndSend()
end

-- 公会变更通知
function GuildCtrl:OnRoleGuildInfoChange(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		obj:SetAttr("guild_id", protocol.guild_id)
		obj:SetAttr("guild_name", protocol.guild_name)
		obj:SetAttr("guild_post", protocol.guild_post)
		obj:SetAttr("last_leave_guild_time", protocol.last_leave_guild_time)
		obj:UpdateTitle()
		obj:ReloadUIGuildName()
		if obj:IsMainRole() then
			if old_guild_gongxian then
				local delta_gongxian = protocol.guild_gongxian - old_guild_gongxian
				old_guild_gongxian = protocol.guild_gongxian
				if delta_gongxian > 0 then
					TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddGuildGX, delta_gongxian))
				end
			end
			self.guild_data:SetGuildGongxian(protocol.guild_gongxian)
			self.guild_data:SetLastLeaveGuildTime(protocol.last_leave_guild_time)
			if(GuildData.Instance.guild_id ~= protocol.guild_id) then
				GuildData.Instance.guild_id = protocol.guild_id
				-- 加入了新公会
				self:SendGuildApplyListReq()
				self:SendAllGuildMemberInfoReq()
				self:SendGuildInfoReq()
				self.is_add_msg_data = false
				self:SendGetGuildRareLog()

				if(GuildData.Instance.guild_id ~= 0) then
					-- self.view:InitViewCase2()
					self.view:ChangeToIndex(TabIndex.guild_info)
					self.view:FlushTabbarByIndex(TabIndex.guild_info)
					self.join_new_guild = true
					local num = #Language.Guild.JoinGuildRandomTalk
					local str = Language.Guild.JoinGuildRandomTalk[math.random(num)] or ""
					local text = ChatData.Instance:FormattingMsg(str, CHANNEL_TYPE.GUILD)
					ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text)
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.Event_Type_2, GameVoManager.Instance:GetMainRoleVo().name))
				else
					-- 离开了公会
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.TuiChuGuild, GameVoManager.Instance:GetMainRoleVo().name))
					GuildData.Instance.guild_id = 0
					GuildData.Instance:ClearCache()
					self.view:ChangeToIndex(TabIndex.guild_request)
					MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildHongBao, false)
				end
			end

			-- 加入公会后请求下签到信息
			GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_ALL_INFO)
		end
	end

	if nil ~= obj and protocol.guild_id == GuildData.Instance.guild_id and protocol.guild_id ~= 0 then
		local vo = obj:GetVo()
		local role_id = vo.role_id
		local role_name = vo.name
		local post = GuildData.Instance:GetGuildPost(role_id)
		if post ~= protocol.guild_post and protocol.guild_post ~= GuildDataConst.GUILD_POST.CHENG_YUAN then
			if protocol.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG then
				if self.view then
					self.view:CloseAllWindow()
				end
			end
		end
		self.guild_data:SetGuildTotalGongxian(protocol.guild_total_gongxian)
		GuildData.Instance:GetReminder(Guild_PANEL.totem)
		self:SendGuildApplyListReq()
		self:SendAllGuildMemberInfoReq()
		self:SendGuildInfoReq()
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
		if self.view then
			self.view:Flush()
		end
		if GuildChatView.Instance:IsOpen() then
			GuildChatView.Instance:Flush("view")
		end
	end
	ExchangeData.Instance:SetGuildGongXianInfo(protocol.guild_gongxian)
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

-- 公会成员列表
function GuildCtrl:OnGuildMemberList(protocol)
	local list = protocol.member_list
	table.sort(list, function(a, b)
			if a.is_online == b.is_online then
				if a.is_online == 1 then
					if a.post == b.post then
						if a.gongxian == b.gongxian then
							if a.level == b.level then
								return a.capability > b.capability
							else
								return a.level > b.level
							end
						else
							return a.gongxian > b.gongxian
						end
					else
						return GuildDataConst.GUILD_POST_WEIGHT[a.post] > GuildDataConst.GUILD_POST_WEIGHT[b.post]
					end
				else
					return a.last_login_time > b.last_login_time
				end
			else
				return a.is_online > b.is_online
			end
		end)

	local member_list = GuildDataConst.GUILD_MEMBER_LIST
	member_list.count = protocol.count
	member_list.list = list
	for k, v in pairs(member_list.list) do
		AvatarManager.Instance:SetAvatarKey(v.uid, v.avatar_key_big, v.avatar_key_small)
		AvatarManager.Instance:SetAvatarFrameKey(v.uid, v.use_head_frame)
	end

	GuildData.Instance:GetReminder(Guild_PANEL.totem)
	GuildCtrl.Instance:SendGuildWageInfoReq()
	if self.view then
		self.view:Flush()
	end
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self:SendGuildApplyListReq()
	end
	ChatCtrl.Instance:FlushGuildChatViewGuildMemeberChange()

	self:CheckRemindMemberFull()
	GlobalEventSystem:Fire(OtherEventType.GUILD_MEMBER_INFO_CHANGE)
end

-- 修改仙盟公告结果返回
function GuildCtrl:OnChangeNotice(protocol)
	if(protocol.ret == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ModNoticeResult)
		self:SendGuildInfoReq()
		if self.view then
			self.view:CloseInfoViewWindow()
		end
	end
end

-- 捐献请求
-- times捐献铜钱次数
-- item_list捐献物品列表[{item_id:100, item_num:1}, ....]
function GuildCtrl:SendAddGuildExpReq(juanxian_type, num, times, item_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAddGuildExp)
	send_protocol.type = juanxian_type
	send_protocol.value = num
	send_protocol.times = times
	send_protocol.item_list = item_list or {}
	send_protocol:EncodeAndSend()
end

-- 仙盟捐献结果返回
function GuildCtrl:OnJuanXianResult(protocol)
	self.view:Flush()
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.AddGongXianVal, protocol.add_gongxian))
end

-- 请求退出公会
function GuildCtrl:SendQuitGuildReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuitGuild)
	if(GuildData.Instance.guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求退出公会结果返回
function GuildCtrl:OnQuitGuild(protocol)
	if(protocol.ret == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.QuitGuild)
		GuildData.Instance.guild_id = 0
		Scene.Instance:GetMainRole():SetAttr("guild_id", 0)
		-- self:InitGuildView()
		self.view:ChangeToIndex(TabIndex.guild_request)

		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

		local all_list_key = real_role_id .. "_fall_msg_list"
		local fall_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
		if fall_list_json_str == "" then
			return
		end
		PlayerPrefsUtil.DeleteKey(all_list_key)
		self.guild_data:ClearFallAllMsg()
	end
end

-- 检查能否弹劾会长
function GuildCtrl:SendGuildCheckCanDelateReq()
	if(GuildData.Instance.guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildCheckCanDelate)
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 检查是否能够弹劾盟主结果返回 0 不能 1能
function GuildCtrl:GuildCheckCanDelateAck(protocol)
	if(protocol.can_delate == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.DontDelate)
		return
	end
	self:SendGuildDelateReq()
end

-- 弹劾请求
function GuildCtrl:SendGuildDelateReq()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if(guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildDelate)
	protocol.guild_id = guild_id
	local delete_id = GuildData.Instance:GetGuildDeleteId()
	local index = ItemData.Instance:GetItemIndex(delete_id)
	protocol.knapsack_index = index
	protocol:EncodeAndSend()
end

-- 管理员收到的申请加入仙盟列表
function GuildCtrl:OnGuildApplyForList(protocol)
	local apply_list = GuildDataConst.GUILD_APPLYFOR_LIST
	apply_list.count = protocol.count
	apply_list.list = protocol.apply_list
	RemindManager.Instance:Fire(RemindName.GuildOperate)
	if self.view then
		self.view:SetWindowSwitch(false)
		self.view:Flush()
	end
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
	if self.apply_view then
		self.apply_view:Flush()
	end
	if self.guild_operation_view then
		self.guild_operation_view:Flush()
	end
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if protocol.count > 0 then
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GUILD_INVITE, true)
		else
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GUILD_INVITE, false)
		end
	end
end

function GuildCtrl:OpenGuildShowView(actity_type)
	self.guild_show_view:SetActityData(actity_type)
	ViewManager.Instance:Open(ViewName.GuildShowView)
end

function GuildCtrl:SendGuildInfoStatisticReq(activity_type)
	send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildInfoStatisticReq)
	send_protocol.activity_type = activity_type or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SCGuildInfoStatistic(protocol)
	GuildData.Instance:SetGuildInfoStatistic(protocol)
	if ViewManager.Instance:IsOpen(ViewName.GuildShowView) then
		self.guild_show_view:Flush()
	end
end

function GuildCtrl:SCGuildMvpInfo(protocol)
	GuildData.Instance:SetGuildMvpInfo(protocol)
	-- 刷新仙盟mvp名字显示
	if protocol.activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
		KuafuGuildBattleCtrl.Instance:FlushMvpName("mvp_name")
	elseif protocol.activity_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		CityCombatCtrl.Instance:FlushMvpName("mvp_name")
	elseif protocol.activity_type == ACTIVITY_TYPE.GUILDBATTLE then
		GuildFightCtrl.Instance:FlushMvpName("mvp_name")
	end
end

function GuildCtrl:SCGuildStorageLogList(protocol)
	GuildData.Instance:SetGuildWarehouseLogData(protocol)
	if self.guild_warehouse_view then
		self.guild_warehouse_view:Flush("warehouse_log")
	end
end

-- 请求获得兑换内容信息
function GuildCtrl:SendGuildExchangeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildExchange)
	protocol:EncodeAndSend()
end

-- 角色的公会信息
function GuildCtrl:OnGuildRoleGuildInfo(protocol)
	if old_guild_gongxian == nil and protocol.guild_gongxian then
		old_guild_gongxian = protocol.guild_gongxian
	end
	self.guild_data:SetGuildRoleGuildInfo(protocol)
	if self.guild_donateWindow_view then
		self.guild_donateWindow_view:CheckLevelUp()
	end
	RemindManager.Instance:Fire(RemindName.GuildDonation)
	RemindManager.Instance:Fire(RemindName.GuildAltar)
	self.guild_donateWindow_view:Flush()
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
	ExchangeData.Instance:SetGuildGongXianInfo(protocol.guild_gongxian)
end

-- 请求升级公会技能
function GuildCtrl:SendGuildSkillUplevelReq(index, up_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSkillUplevel)
	protocol.skill_index = index
	protocol.up_type = up_type or 0
	protocol:EncodeAndSend()
end

-- 仙盟设置请求
function GuildCtrl:SendSettingGuildReq(guild_id, applyfor_setup, need_capability, need_level)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSApplyforSetup)
	send_protocol.guild_id = guild_id
	send_protocol.applyfor_setup = applyfor_setup
	send_protocol.need_capability = need_capability
	send_protocol.need_level = need_level
	send_protocol:EncodeAndSend()
end

-- 回复加入申请通知
function GuildCtrl:OnApplyForJoinGuildAck(protocol)
	if 1 == protocol.result then 						-- 1：拒绝 0：失败
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.RefuseJoinGuild, protocol.guild_name))
	end
end

-- 审批申请加入仙盟请求
function GuildCtrl:SendGuildApplyforJoinReq(guild_id, result, count, list)
	if nil == list then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSApplyForJoinGuildAck)
	send_protocol.guild_id = guild_id
	send_protocol.result = result
	send_protocol.count = count
	send_protocol.list = list
	send_protocol:EncodeAndSend()
end

-- 请求升级公会图腾
function GuildCtrl:SendGuildTotemUplevelReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildUpTotemLevel)
	protocol:EncodeAndSend()
end

-- 发送返回驻地请求
function GuildCtrl:SendGuildBackToStationReq(guild_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBackToStation)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

-- 发送解散仙盟请求
function GuildCtrl:SendDismissGuildReq(guild_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDismissGuild)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

-- 发送踢人请求
function GuildCtrl:SendKickoutGuildReq(guild_id, bekicker_count, list)
	if nil == list then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSKickoutGuild)
	send_protocol.guild_id = guild_id
	send_protocol.bekicker_count = bekicker_count
	send_protocol.list = list
	send_protocol:EncodeAndSend()
end

-- 踢人结果(0是成功)
function GuildCtrl:OnKickoutGuild(protocol)
	if protocol.ret == 0 then
		for k,v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
			if v.uid == protocol.bekick_uid then
				table.remove(GuildDataConst.GUILD_MEMBER_LIST.list, k)
				GuildDataConst.GUILD_MEMBER_LIST.count = GuildDataConst.GUILD_MEMBER_LIST.count - 1
				break
			end
		end
		self.view:Flush()
	end
end

-- 宝箱信息
function GuildCtrl:OnGuildBoxInfo(protocol)
	local switch = false
	self:RemoveCountDown()
	local other_config = GuildData.Instance:GetOtherConfig()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if other_config and now_time then
		local rest_assist_count = other_config.box_assist_max_count - protocol.assist_count
		if rest_assist_count > 0 then
			local box_assist_cd_limit = other_config.box_assist_cd_limit
			if box_assist_cd_limit then
				if protocol.assist_cd_end_time - now_time <= box_assist_cd_limit then
					switch = true
				else
					self:StartCountDown(protocol.assist_cd_end_time - now_time - box_assist_cd_limit)
				end
			end
		end
		local time_zone = TimeUtil.GetTimeZone()
		now_time = (now_time + time_zone) % 86400
		local box_start_time = other_config.box_start_time
		GuildData.Instance:SetGuildBoxStart(true)
		if now_time >= box_start_time then
			-- GuildData.Instance:SetGuildBoxStart(true)
		else
			-- GuildData.Instance:SetGuildBoxStart(false)
			self.count_down2 = GlobalTimerQuest:AddDelayTimer(function() self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end,
				box_start_time - now_time + 1)
		end
	end
	GuildData.Instance:SetBoxInfo(protocol)
	GuildData.Instance:SetIsCanAssistBox(switch)
	RemindManager.Instance:Fire(RemindName.GuildBox)
	if self.view then
		self.view:Flush()
	end
end

-- 宝箱协助信息
function GuildCtrl:OnGuildBoxNeedAssistInfo(protocol)
	GuildData.Instance:SetAssistInfo(protocol)
	if self.view then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.GuildBox)
	-- GuildData.Instance:CalculateRedPoint()
end

-- 仙盟宝箱操作
function GuildCtrl:SendGuildBoxOperateReq(operate_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBoxOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 2
	send_protocol:EncodeAndSend()
end

-- 帮派求救
function GuildCtrl:SendSendGuildSosReq(sos_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendGuildSosReq)
	protocol.sos_type = sos_type
	protocol:EncodeAndSend()
end

-- 帮派求救
function GuildCtrl:OnSCGuildMemberSos(protocol)
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if IS_ON_CROSSSERVER then
		role_id = CrossServerData.Instance:GetRoleId()
	end
	if protocol.member_uid == role_id then
		if protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE or 
			protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN or 
			protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_GUILD_BATTLE then
			SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.ZhaoJiGuildSuc)
			return
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.SosToGuildSuc)
			return
		end
	end
	if protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN then
		if not ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.GONGCHENGZHAN) then
			return
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo and vo.role_id == protocol.member_uid then
			return
		end
		if Scene.Instance:GetSceneType() == SceneType.GongChengZhan then
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["same_citycombat_help"]
			if is_auto then 
				return
			end
			local func = function ()
				self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN, protocol.member_pos_x, protocol.member_pos_y, protocol.member_scene_id)
			end
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("same_citycombat_help", Language.CityCombat.BeCalled, func,nil, Language.Guild.GoText, nil,nil,nil,true,false, nil)
			return
		else
			-- local is_auto = TipsCtrl.Instance:GetIsCommonAuto("citycombat_help")
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["citycombat_help"]
			if is_auto then 
				return
			end
			local func = function()
				ViewManager.Instance:Open(ViewName.CityCombatView)
			end
			local no_func = function()
				TipsCtrl.Instance:CloseCommonAutoView()
			end
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("citycombat_help", Language.CityCombat.BeCalled1, func,nil, nil, nil,nil,nil,true,false, no_func)
			return
		end
	end
	if protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE then
		if not ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.GUILDBATTLE) then
			return
		end
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo and vo.role_id == protocol.member_uid then
			return
		end
		if Scene.Instance:GetSceneType() == SceneType.LingyuFb then
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["same_guildwar_help"]
			if is_auto then 
				return
			end
			local yes_func = function()
				self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE, protocol.member_pos_x, protocol.member_pos_y, protocol.member_scene_id)
				MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end

			local describe = Language.Guild.ZhaoJiText or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("same_guildwar_help", describe, yes_func, nil, Language.Guild.GoText,nil,nil,nil,true,false, nil)
			return
		else
			-- local is_auto = TipsCtrl.Instance:GetIsCommonAuto("guildwar_help")
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["guildwar_help"]
			if is_auto then 
				return
			end
			local func = function()
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
			end
			local no_func = function()
				TipsCtrl.Instance:CloseCommonAutoView()
			end
			local describe = Language.Guild.ZhaoJiText1 or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("guildwar_help", describe, func, nil, nil, nil,nil,nil,true,false, no_func)
			return
		end
	end

	if protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_GUILD_BATTLE then
		if not ActivityData.Instance:IsAchieveLevelInLimintConfigById(ACTIVITY_TYPE.KF_GUILDBATTLE) then
			return
		end
		if role_id == protocol.member_uid then
			return
		end
		if Scene.Instance:GetSceneType() == SceneType.CrossGuild then
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["same_cross_guild_help"]
			if is_auto then 
				return
			end
			local yes_func = function()
				self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_GUILD_BATTLE, protocol.member_pos_x, protocol.member_pos_y, protocol.member_scene_id)
				MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.member_scene_id)
			local scene_name = ""
			if scene_cfg then
				scene_name = scene_cfg.name
			end
			local describe = string.format(Language.KuafuGuildBattle.ZhaoJiText, scene_name) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("same_cross_guild_help", describe, yes_func, nil, Language.Guild.GoText,nil,nil,nil,true,false, nil)
			return
		else
			-- local is_auto = TipsCtrl.Instance:GetIsCommonAuto("cross_guild_help")
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["cross_guild_help"]
			if is_auto then 
				return
			end
			local func = function()
				if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.KF_GUILDBATTLE) then
					ViewManager.Instance:Open(ViewName.KuaFuBattle)
				else
					ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.liujie_bossinfo)
				end
			end
			local no_func = function()
				TipsCtrl.Instance:CloseCommonAutoView()
			end
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.member_scene_id)
			local scene_name = ""
			if scene_cfg then
				scene_name = scene_cfg.name
			end
			local describe = string.format(Language.KuafuGuildBattle.ZhaoJiText1, scene_name) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("cross_guild_help", describe, func, nil, nil, nil,nil,nil,true,false, no_func)
			return
		end
	end

	if protocol.sos_type == GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_BIANJINGZHIDI then
		if role_id == protocol.member_uid then
			return
		end
		if Scene.Instance:GetSceneType() == SceneType.KF_Borderland then
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["kf_borderland"]
			if is_auto then 
				return
			end
			local yes_func = function()
				self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_BIANJINGZHIDI, protocol.member_pos_x, protocol.member_pos_y, protocol.member_scene_id)
				-- MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.member_scene_id)
			local scene_name = ""
			if scene_cfg then
				scene_name = scene_cfg.name
			end
			local describe = string.format(Language.KFBorderland.ZhaoJiText, scene_name) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("kf_borderland", describe, yes_func, nil, Language.Guild.GoText,nil,nil,nil,true,false, nil)
			return
		else
			local is_auto = TipsCommonAutoView.AUTO_VIEW_STR_T["kf_borderland_two"]
			if is_auto then 
				return
			end
			local func = function()
				if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_BIANJING_ZHIDI) then
					ViewManager.Instance:Open(ViewName.Map, TabIndex.map_world)
				end
			end
			local no_func = function()
				TipsCtrl.Instance:CloseCommonAutoView()
			end
			local scene_cfg = ConfigManager.Instance:GetSceneConfig(protocol.member_scene_id)
			local scene_name = ""
			if scene_cfg then
				scene_name = scene_cfg.name
			end
			local describe = string.format(Language.KFBorderland.ZhaoJiText1, scene_name) or ""
			TipsCtrl.Instance:ChangeAutoViewAuto(false)
			TipsCtrl.Instance:ShowCommonAutoView("kf_borderland_two", describe, func, nil, nil, nil,nil,nil,true,false, no_func)
			return
		end
	end

	-- local icon_list = MainuiCtrl.Instance:GetTipIconList(MAINUI_TIP_TYPE.YUAN)
	-- if icon_list ~= nil then
	-- 	for k,v in pairs(icon_list) do
	-- 		if v:GetData() and v:GetData().param and v:GetData().param.member_uid == protocol.member_uid and v:IsVisible() then --不重复添加
	-- 			return
	-- 		end
	-- 	end
	-- end
	local data = {}
	data.x = protocol.member_pos_x
	data.y = protocol.member_pos_y
	data.member_uid = protocol.member_uid
	data.scene_id = protocol.member_scene_id
	data.name = protocol.member_name
	data.camp = GameVoManager.Instance:GetMainRoleVo().camp

	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end

	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SOS_REQ, true, data)
end

function GuildCtrl:OnClickSos(info)
	local yes_func = function()
		local SceneKey = 0 --这里默认去1线
		GuajiCtrl.Instance:FlyToScenePos(info.scene_id, info.x, info.y, false, SceneKey)
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end
	local describe = string.format(Language.Guild.QIUYUAN, info.name)
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- boss信息返回
function GuildCtrl:OnGuildBossInfo(protocol)
	self.guild_data:SetBossInfo(protocol)
	if self.boss_view then
		self.boss_view:Flush()
	end
	if self.view then
		self.view:Flush()
	end
	if self.guild_station_view then
		self.guild_station_view:Flush()
	end
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_boss")
end

function GuildCtrl:SetSelectActivityId(activity_id)
	self.select_activity_id = activity_id
end

function GuildCtrl:GetSelectActivityId()
	return self.select_activity_id
end

-- Boss操作
function GuildCtrl:SendGuildBossReq(boss_type, is_super_call)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildBossOperate)
	protocol.oper_type = boss_type
	protocol.param = is_super_call and 1 or 0
	protocol:EncodeAndSend()
end

-- 任命请求
function GuildCtrl:SendGuildAppointReq(guild_id, beappoint_uid, post)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAppointGuild)
	send_protocol.guild_id = guild_id
	send_protocol.beappoint_uid = beappoint_uid
	send_protocol.post = post
	send_protocol:EncodeAndSend()
end

-- 管理员任命玩家结果返回
function GuildCtrl:OnAppointGuild(protocol)
	if 0 == protocol.ret then 						-- 0：成功 其它失败
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AppointSuccess)
		if self.view and self.view.member_view then
			self.view.member_view.transfer_window:SetActive(false)
		end
	end
end

-- 领取每日奖励
function GuildCtrl:SendGuildFetchRewardReq(req_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildFetchReward)
	protocol.req_type = req_type or 0
	protocol:EncodeAndSend()
end

-- 仓库信息
function GuildCtrl:OnGuildStorgeInfo(protocol)
	GuildData.Instance:SetGuildStorgeInfo(protocol)
	if self.view then
		self.view:Flush()
	end
	if self.guild_warehouse_view and self.guild_warehouse_view:IsOpen() then
		self.guild_warehouse_view:Flush("contribute_success")
		self.guild_warehouse_view:Flush("warehouse_score")
	end	
end

-- 仓库变更
function GuildCtrl:OnGuildStorgeChange(protocol)
	GuildData.Instance:SetGuildStorgeChange(protocol)
	if self.view then
		self.view:Flush()
	end
	if self.contribute_equip_view and self.contribute_equip_view:IsOpen() then
		self.contribute_equip_view:Flush("contribute_success")
	end
	if self.guild_warehouse_view and self.guild_warehouse_view:IsOpen() then
		self.guild_warehouse_view:Flush("contribute_success")
	end
end

-- 公会名字改变
function GuildCtrl:OnGuildResetName(protocol)
	Scene.Instance:GetMainRole():SetAttr("guild_name", protocol.new_name)
	GuildDataConst.GUILDVO.guild_name = protocol.new_name
	if self.view then
		self.view:Flush()
	end
end

-- 公会消息通知
function GuildCtrl:OnNotifyGuildSuper(protocol)
	local notify_type_list = GuildDataConst.GUILD_NOTIFY_TYPE
	local notify_type = protocol.notify_type
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if notify_type == notify_type_list.APPLYFOR then
		local post = GuildData.Instance:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			self:SendGuildApplyListReq()
		end
	elseif notify_type == notify_type_list.GUILD_BIAOCHE_START then
		self.has_yunbiao = true
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) then
			local ok_callback = function()
				local scene_type = Scene.Instance:GetSceneType()
				if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
					return
				end
				local main_role = Scene.Instance:GetMainRole()
				if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
					MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
				end
				GuildCtrl.Instance:SendGuildYunBiaoReq(BIAOCHE_OPERA_TYPE.BIAOCHE_OPERA_TYPE_TRANS, guild_id)
			end
			TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, false, false, false, false, false, true, "guild")
			if GameVoManager.Instance:GetMainRoleVo().role_id == protocol.notify_param1 then
				local dec = Language.Guild.GuildYunBiaoStart
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
			end
		end
		self:SetGuildYunbiaoSkillState(self:CheckGuildYunBiaoState())
	elseif notify_type == notify_type_list.GUILD_BIAOCHE_END then
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		local scene_id = 0
		if guild_yunbiao_cfg then
			scene_id = guild_yunbiao_cfg.biaoche_scene_id
		end
		if protocol.notify_param == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_SUCC then
			self.has_yunbiao = false
			GuildCtrl.Instance:SendGuildInfoReq(guild_id)
			local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
			if attck_mode ~= nil and attck_mode ~= -1 then
				MainUICtrl.Instance:SendSetAttackMode(attck_mode)
			end
			if GameVoManager.Instance:GetMainRoleVo().role_id == protocol.notify_param1 then
				local dec = Language.Guild.GuildYunBiaoEnd
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, dec, CHAT_CONTENT_TYPE.TEXT)
			end
			self:SetGuildYunbiaoSkillState(false)
			if Scene.Instance:GetSceneId() == scene_id then
				local data = GuildData.Instance:GetGuildBiaoCheRewardByIndex(UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_SUCC)
				TipsCtrl.Instance:ShowRewardTipsView(data)
			end
		elseif protocol.notify_param == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_FAIL then
			self.has_yunbiao = false
			GuildCtrl.Instance:SendGuildInfoReq(guild_id)
			local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
			if attck_mode ~= nil and attck_mode ~= -1 then
				MainUICtrl.Instance:SendSetAttackMode(attck_mode)
			end
			self:SetGuildYunbiaoSkillState(false)
			if Scene.Instance:GetSceneId() == scene_id then
				local data = GuildData.Instance:GetGuildBiaoCheRewardByIndex(UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_FAIL)
				TipsCtrl.Instance:ShowRewardTipsView(data)
			end
		elseif protocol.notify_param == UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_ROB_SUCC then
			if Scene.Instance:GetSceneId() == scene_id then
				local other_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
				if other_cfg then
					local max_num = other_cfg.member_rob_count_max or 0
					if protocol.notify_param1 <= max_num then
						local data = GuildData.Instance:GetGuildBiaoCheRewardByIndex(UILD_YUNBIAO_RESULT_TYPE.GUILD_YUNBIAO_RESULT_TYPE_ROB_SUCC)
						TipsCtrl.Instance:ShowRewardTipsView(data)
					end
				end
			end
		end
	elseif protocol.notify_type == notify_type_list.GUILD_NOTIFY_TYPE_TIANCI_TONGBI_OPEN then
		GuildCtrl.Instance:OpenGuildMoneyTree(GUILD_TIANCITONGBI_REQ_TYPE.GUILD_TIANCITONGBI_REQ_TYPE_RANK_INFO)
		self.guild_data:SendMoneyTreeIcon(1)
		local ok_callback = function()
			local scene_type = Scene.Instance:GetSceneType()
			if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
				return
			end
			local main_role = Scene.Instance:GetMainRole()
			if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
				MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
			end
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			if guild_id and guild_id > 0 then
				GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
			end
		end
		TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, false, false, false, false, false, false, "guild", true)		
	elseif protocol.notify_type == notify_type_list.GUILD_NOTIFY_TYPE_TIANCI_TONGBI_CLOSE then
		self.guild_data:SendMoneyTreeIcon(0)
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_MONEYTREE, ACTIVITY_STATUS.CLOSE, 0)
	elseif protocol.notify_type == notify_type_list.GUILD_NOTIFY_TYPE_GUILD_BIAOCHE_CUR_POS then
		local pos_x, pos_y = protocol.notify_param or 0, protocol.notify_param1 or 0
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		local scene_id = guild_yunbiao_cfg.biaoche_scene_id
		if pos_x > 0 and pos_y > 0 and scene_id then
			MoveCache.end_type = MoveEndType.Normal
			local SceneKey = 0 --这里默认去1线
			GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y, 1, 1, false, SceneKey)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BiaoCheExist)
		end
	elseif protocol.notify_type == notify_type_list.GUILD_NOTIFY_TYPE_GET_GONGZI then
		if not ChatData.Instance:GetHeadSayState() then
			local str = string.format(Language.Guild.GetGuildWage, protocol.notify_param)
			TipsCtrl.Instance:OpenZhanChangBroacast(str)
		end
	elseif protocol.notify_type == notify_type_list.GUILD_NOTIFY_TYPE_TOTAL_GONGZI_CHNAGE then
		GuildDataConst.GUILDVO.guild_total_gongzi = protocol.notify_param
		RemindManager.Instance:Fire(RemindName.GuildWage)
	end
end

-- 公会仓库操作
function GuildCtrl:SendStorgeOperate(operate_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildStorgeOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end

-- 放进仓库
function GuildCtrl:SendStorgetPutItem(bag_index, num)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_PUTON_ITEM, bag_index, num)
end

-- 取出仓库
function GuildCtrl:SendStorgetOutItem(storge_index, num, item_id)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_TAKE_ITEM, storge_index, num, item_id)
end

-- 销毁物品
function GuildCtrl:SendStorgetDestoryItem(storge_index, item_id)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_DISCARD_ITEM, storge_index, item_id)
end

-- 公会仓库批量操作
function GuildCtrl:SendStorgeOneKeyOperate(operate_type, item_count, item_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildStorgeOneKeyOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.item_count = item_count or 0
	send_protocol.item_list = item_list or {}
	send_protocol:EncodeAndSend()
end

function GuildCtrl:StartCountDown(delay_time)
	self.count_down = GlobalTimerQuest:AddDelayTimer(function() GuildData.Instance:SetIsCanAssistBox(true)
	if self.view then self.view:Flush() end end, delay_time)
end

function GuildCtrl:RemoveCountDown()
	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
	if self.count_down2 then
		GlobalTimerQuest:CancelQuest(self.count_down2)
		self.count_down2 = nil
	end
	if self.count_down3 then
		GlobalTimerQuest:CancelQuest(self.count_down3)
		self.count_down3 = nil
	end
end

-- 公会领地领取奖励
function GuildCtrl:SendGuildTerritoryWelfOperate(operate_type, param1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildTerritoryWelfOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:FlushTerritort()
	if self.view then
		self.view:Flush()
	end
	local guild_id = Scene.Instance:GetMainRole().vo.guild_id
	local rank, has_territory = ClashTerritoryData.Instance:GetTerritoryRankById(guild_id)
	self.guild_data:SetTerritoryRank(rank, has_territory)
	GuildData.Instance:CalculateRedPoint()
end

function GuildCtrl:FlushBonFire(openstatus)
	GuildData.Instance:SetBonFireState(openstatus)
	if openstatus == 1 then
		if self.bon_fire then
			ViewManager.Instance:Close(ViewName.Guild)
			self.bon_fire = false
			return
		end
	end
	if self.view then
		self.view:Flush()
	end
end

-- 公会篝火是否是本人开启
function GuildCtrl:SetBonFireOperation(state)
	self.bon_fire = state
end

function GuildCtrl:FlushMiJing(openstatus)
	GuildData.Instance:SetMiJingState(openstatus)
	if self.view then
		self.view:Flush()
	end
end

function GuildCtrl:SendResetNameReq(guild_id, new_name)
	if not guild_id or not new_name or new_name == "" then return end
	local act_id_list = GuildData.Instance:GetGuildActivityIDList()
	if act_id_list ~= nil then
		for k, v in pairs(act_id_list) do
			if v ~= nil and ActivityData.Instance:GetActivityIsOpen(v.guild_act_id) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoRenameGuild)
				return
			end
		end
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildResetName)
	send_protocol.guild_id = guild_id
	send_protocol.new_name = new_name
	send_protocol:EncodeAndSend()
end

function string.utf8len(input)
	local len  = string.len(input)
	local left = len
	local cnt  = 0
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i   = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

-- 踢人操作
function GuildCtrl:OnClickKickout(uid, name)
	local describe = string.format(Language.Guild.KickoutMemberBundleTip1, name)
	local function yes_func()
		self:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, 1, {uid})
	end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 弹劾会长
function GuildCtrl:OnClickTransfer(uid, name)
	local describe = string.format(Language.Guild.ConfirmTransferMengZhuTip, name)
	TipsCtrl.Instance:ShowCommonAutoView("", describe,
		function()
			self:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, uid, GuildDataConst.GUILD_POST.TUANGZHANG)
		end)
end

function GuildCtrl:OpenStationView()
	if self.guild_station_view then
		self.guild_station_view:Open()
	end
	MainUICtrl.Instance:FlushView("guaji_manual_state", {true})
end

function GuildCtrl:CloseStationView()
	if self.guild_station_view then
		self.guild_station_view:Close()
	end
	MainUICtrl.Instance:FlushView("guaji_manual_state", {false})
end

function GuildCtrl:OnGuildBossActivityInfo(protocol)
	GuildData.Instance:SetBossActivityInfo(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GuildStation and GuildData.Instance:GetMoneyTreeIcon() == ACTIVITY_STATUS.CLOSE then
		if protocol.boss_id > 0 then
			if self.guild_station_view and not self.guild_station_view:IsOpen() then
				self:OpenStationView()
			end
		else
			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
			if act_info then
				if act_info.status == ACTIVITY_STATUS.CLOSE then
					self:CloseStationView()
				end
			else
				-- self:CloseStationView()
			end
		end
	end
	if self.guild_station_view then
		self.guild_station_view:Flush()
	end
end

--收到盟会邀请
function GuildCtrl:OnInviteNotify(protocol)
	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		return
	end

	local data = {}
	data.guild_id = protocol.guild_id
	data.invite_uid = protocol.invite_uid
	data.invite_name = protocol.invite_name
	data.guild_name = protocol.guild_name
	GuildData.Instance:SetInviteGuild(data)

	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GUILD_YAO, true)
end

function GuildCtrl:OnInviteGuild(protocol)
	if protocol.ret == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteSucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteFail)
	end
end

-- 回复邀请
function GuildCtrl:OnInviteGuildAck(guild_id, invite_uid, result)
	if nil == guild_id or nil == invite_uid or nil == result then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSInviteGuildAck)
	send_protocol.guild_id = guild_id
	send_protocol.invite_uid = invite_uid
	send_protocol.result = result
	send_protocol:EncodeAndSend()
end

-- 邀请加入军团
function GuildCtrl:SendInviteGuildReq(beinvite_uid)
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if nil == beinvite_uid or guild_id <= 0 then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSInviteGuild)
	send_protocol.guild_id = guild_id
	send_protocol.beinvite_uid = beinvite_uid
	send_protocol:EncodeAndSend()
end

-- 仙盟招募请求
function GuildCtrl:SendGuildCallInReq()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id <= 0 then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildCallIn)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

function GuildCtrl:OnGuildOperaSucc(protocol)
	-- 招募成功
	if protocol.opera_type == GHILD_OPERA_TYPE.OPERA_TYPE_CALL_IN then
		GuildData.Instance:SetLastCallinTime(Status.NowTime)
	end
end



-- 公会扩展成员请求
function GuildCtrl:SendGuildExtendMemberReq(operate_type, can_use_gold, num)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildExtendMemberReq)
	send_protocol.operate_type = operate_type or 0
	send_protocol.can_use_gold = can_use_gold or 0
	send_protocol.num = num or 0
	send_protocol:EncodeAndSend()
end

-- 公会当前最大成员数量
function GuildCtrl:OnGuildMemberNum(protocol)
	GuildDataConst.GUILDVO.max_member_count = protocol.max_guild_member_num
	local info = GuildData.Instance:GetGuildInfoById(GameVoManager.Instance:GetMainRoleVo().guild_id)
	if info then
		info.max_member_count = protocol.max_guild_member_num
	end
	if self.view then
		self.view:Flush()
	end
end

-- 领公会杀boss红包
function GuildCtrl:SendFetchGuildBossRedbagReq(index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchGuildBossRedbag)
	send_protocol.index = index or 0
	send_protocol:EncodeAndSend()
end

-- 公会复活次数信息
function GuildCtrl:OnGulidReliveTimes(protocol)
	GuildDataConst.GUILDVO.daily_relive_times = protocol.daily_guild_all_relive_times
	GuildDataConst.GUILDVO.daily_kill_boss_times = protocol.daily_guild_all_kill_boss_times
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
	GuildChatData.Instance:CheckRedPoint()
end

-- 公会领取boss红包信息
function GuildCtrl:OnGulidBossRedbagInfo(protocol)
	GuildData.Instance:SetDailyUseGuildReliveTimes(protocol.daily_use_guild_relive_times)
	GuildData.Instance:SetDailyBossRedbagFlag(protocol.daily_boss_redbag_reward_fetch_flag)
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
	GuildChatData.Instance:CheckRedPoint()
end

----------------仙盟红包-------------------
function GuildCtrl:OnGuildRedPocketListInfo(protocol)
	self.guild_data:SetRedPocketListInfo(protocol)
	RemindManager.Instance:Fire(RemindName.GuildRedPacket)
	self.guild_redpacket_view:Flush()
	self.guild_redpacket_tips:Flush()
	-- GuildData.Instance:CalculateRedPoint()
	self.view:Flush()
end

function GuildCtrl:OnNoticeGuildPaperInfo(protocol)
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

function GuildCtrl:OnGuildRedPocketDistributeInfo(protocol)
	self.guild_data:SetRedPocketDistributeInfo(protocol)
	self.guild_redpacket_tips:Flush()
end

function GuildCtrl:SendGuildRedPocketOperate()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildRedPaperListInfoReq)
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SendCreateGuildRedPaperReq(paper_seq, fetech_time, index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCreateGuildRedPaperReq)
	send_protocol.paper_seq = paper_seq or 0
	send_protocol.fetech_time = fetech_time or 0
	send_protocol.red_paper_index = index or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SendChatRedPaperReq(index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSingleChatRedPaperRole)
	send_protocol.red_paper_index = index or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:DayChange()
	GuildCtrl.Instance:SendGuildRedPocketOperate()
	GuildFightCtrl.Instance:SendGuildWarOperate(GUILD_WAR_TYPE.TYPE_INFO_REQ)
end

function GuildCtrl:OpenGuildRedPacketView()
	if not self.guild_redpacket_tips:IsOpen() then
		self.guild_redpacket_tips:Open()
	end
end

-- 检查公会是否满员
function GuildCtrl:CheckMemberFull()
	if self:IsShouldReminderFullMember() then
		self:SendAllGuildMemberInfoReq()
	end
end

-- 是否应该提醒满员
function GuildCtrl:IsShouldReminderFullMember()
	if Scene.Instance:GetMainRole().vo.guild_id > 0 then
		-- 如果满员且是开服第一天
		if GuildDataConst.GUILDVO.cur_member_count >= GuildDataConst.GUILDVO.max_member_count then
			if TimeCtrl.Instance:GetCurOpenServerDay() <= 1 then
				local post = GuildData.Instance:GetGuildPost()
				if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
					return true
				end
			end
		end
	end
	return false
end

-- 是否主界面提示满员
function GuildCtrl:CheckRemindMemberFull()
	local flag = false
	if self:IsShouldReminderFullMember() then
		local post = GuildData.Instance:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			flag = true
		-- 如果是副会长且会长不在线
		elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			local info = GuildData.Instance:GetGuildMemberInfo(GuildDataConst.GUILDVO.tuanzhang_uid)
			if info then
				if info.is_online == 0 then
					flag = true
				end
			end
		end
	end
	if flag then
		if self.last_reminder_time + member_full_reminder_time <= Status.NowTime then
			self:RecordCleanList()
			if self.clean_list.count > 0 then
				self.last_reminder_time = Status.NowTime
				MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.GuildMemberFull, true)
			end
		end
	end
end

-- 点击清除成员
function GuildCtrl:CleanFullMember()
	self.last_reminder_time = Status.NowTime
	local auto_kickout_level = GuildData.Instance:GetGuildAutoKickOutLevel()
	-- local sub_level, rebirth = PlayerData.GetLevelAndRebirth(auto_kickout_level)
	-- local str = string.format(Language.Common.LevelFormat, sub_level, rebirth)
	local describe = string.format(Language.Guild.CleanMember, PlayerData.GetLevelString(auto_kickout_level))
	-- 等服务端协议
	local yes_func = function() self:SendCleanReq() end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

function GuildCtrl:CancelQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GuildCtrl:CheckCleanRule(info)
	local auto_kickout_level = GuildData.Instance:GetGuildAutoKickOutLevel()
	if info.level < auto_kickout_level and info.is_online == 0 and info.post == GuildDataConst.GUILD_POST.CHENG_YUAN then
		if TimeCtrl.Instance:GetServerTime() - info.last_login_time > 1800 then
			return true
		end
	end
	return false
end

-- 记录需要清除的成员
function GuildCtrl:RecordCleanList()
	self.clean_list = {count = 0, list = {}}
	for k,v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
		if self:CheckCleanRule(v) then
			self.clean_list.count = self.clean_list.count + 1
			self.clean_list.list[v.uid] = 1
		end
	end
	if not self.role_online_change then
		self.role_online_change = GlobalEventSystem:Bind(OtherEventType.ROLE_ISONLINE_CHANGE, BindTool.Bind(self.RoleOnlineChange, self))
	end
end

function GuildCtrl:RoleOnlineChange(role_id, is_online)
	if self.clean_list.list[role_id] then
		self.clean_list.list[role_id] = is_online and 0 or 1
	end
end

function GuildCtrl:SendCleanReq()
	local list = {}
	for k,v in pairs(self.clean_list.list) do
		if v == 1 then
			table.insert(list, k)
		end
	end
	self:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, #list, list)
	self.clean_list = {count = 0, list = {}}
end

-- 公会成员迷宫信息
function GuildCtrl:OnGuildMemberMazeInfo(protocol)
	GuildData.Instance:SetMazeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.GuildMaze)
	GuildData.Instance:CalculateRedPoint()
	if self.count_down3 then
		GlobalTimerQuest:CancelQuest(self.count_down3)
		self.count_down3 = nil
	end
	if protocol.complete_time <= 0 then
		local cd = GuildData.Instance:GetMazeAnswerCD()
		if cd > 0 then
			self.count_down3 = GlobalTimerQuest:AddDelayTimer(function()
				self:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_GET_INFO)
			end, cd + 1)
		end
	end
	self.view:Flush()
end

-- 公会迷宫排行信息
function GuildCtrl:OnGuildMazeRankInfo(protocol)
	GuildData.Instance:SetMazeRankInfo(protocol)
	self.view:Flush()
end

-- 公会迷宫操作
function GuildCtrl:SendGuildMazeOperate(operate_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildMazeOperate)
	protocol.operate_type = operate_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

-- 公会迷宫回答
function GuildCtrl:SendGuildMazeAnswer(param1, param2, param3)
	if not self.maze_has_answered_list[param3] then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, string.format(Language.Guild.MazeChose, param1, param2), CHAT_CONTENT_TYPE.TEXT)
		self.maze_has_answered_list[param3] = true
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeHasAnswered)
	end
end



-- 自动清理3天不在线玩家
function GuildCtrl:SendGuildSetAutoClearReq(is_auto_clear, reserve)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSetAutoClearReq)
	protocol.is_auto_clear = is_auto_clear or 0
	protocol.reserve = reserve or 0
	protocol:EncodeAndSend()
end

-- 签到
function GuildCtrl:OnSCGuildSinginAllInfo(protocol)
	-- 签到成功发一天文字
	-- local signin_data = self.guild_data:GetSigninData()
	-- if signin_data.is_signin_today == 0 and protocol.is_signin_today == 1 then
	-- 	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local main_role_name = main_vo.name
	-- 	local signin_cfg = self.guild_data:GetSigninCfg()
	-- 	local last_data_cfg = signin_cfg[#signin_cfg] or {}
	-- 	local signin_limit = last_data_cfg.need_count or 15
	-- 	local text = string.format(Language.Chat.GuildSigninText, main_role_name, protocol.guild_signin_count_today, signin_limit)
	-- 	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, CHAT_CONTENT_TYPE.TEXT)
	-- end

	self.guild_data:SetSigninData(protocol)
	self.guild_signin_view:Flush()

	RemindManager.Instance:Fire(RemindName.GuildSignin)
	GuildChatView.Instance:Flush("view")
	RemindManager.Instance:Fire(RemindName.GuildHead)
	-- RemindManager.Instance:Fire(RemindName.Guild)
	self.view:Flush()

	-- 签到后请求下仙盟成员信息
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
end

-- 江湖传闻下发
function GuildCtrl:OnSCGuildEventList(protocol)
	self.guild_data:SetGuildEventListData(protocol)
	ChatCtrl.Instance:FlushGuildView()

end

-- 签到请求
function GuildCtrl:SendCSGuildSinginReq(req_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSinginReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

function GuildCtrl:OpenSigninView()
	self.guild_signin_view:Open()
end

function GuildCtrl:OpenDonateView()
	self.guild_donateWindow_view:Open()
end

function GuildCtrl:OpenOpearteView()
	self.guild_operation_view:Open()
end

function GuildCtrl:OpenOpearteZhaoRenView()
	self.guild_operation_zhaoren_view:Open()
end

function GuildCtrl:OpenNoticeView()
	self.guild_notice_view:Open()
end

function GuildCtrl:OpenAssistView()
	self.guild_assist_view:Open()
end

function GuildCtrl:OpenInviteView(callback)
	self.guild_invite_view:SetCallBack(callback)
	self.guild_invite_view:Open()
end

function GuildCtrl:OpenPreView()
	self.guild_pre_view:Open()
end

function GuildCtrl:GetBoxTips()
	return self.guild_box_tip
end

function GuildCtrl:SetBoxTipClose()
	if self.guild_box_tip and self.guild_box_tip:IsOpen() then
		self.guild_box_tip:Close()
	end
end

function GuildCtrl:SetOpenBoxTips(state)
	self.view:SetOpenBoxTips(state)
end

function GuildCtrl:GuildFlushView(view_name)
	if self.view:IsOpen() then
		self.view:Flush(view_name)
	end
end

-- 修改头像
function GuildCtrl:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildChangeAvatar)
	protocol.avatar_key_big = avatar_key_big
	protocol.avatar_key_small = avatar_key_small
	protocol:EncodeAndSend()
end

function GuildCtrl:FlushGuildWarView()
	if self.view:IsOpen() then
		self.view:Flush("guild_war")
	end
end

function GuildCtrl:SendSoSReq(sos_type, pos_x, pos_y, scene_id)
	send_protocol = ProtocolPool.Instance:GetProtocol(CSReplyGuildSosReq)
	send_protocol.sos_type = sos_type or 0
	send_protocol.pos_x = pos_x or 0
	send_protocol.pos_y = pos_y or 0
	send_protocol.scene_id = scene_id or 0
	send_protocol:EncodeAndSend()
end


-- 玩家信息
function GuildCtrl:OnGuildQuestionPlayerInfo(protocol)
	self.guild_data:SetQuestionPlayerInfo(protocol)
	self.guild_answer_task:Flush()
	ChatCtrl.Instance:FlushGuildChannel()
end

-- 帮派题目
function GuildCtrl:OnGuildQuestionQuestionInfo(protocol)
	-- 题目刷新之后主界面群聊要抖动
	if protocol.question_state == 1 then
		local main_chat_view = MainUICtrl.Instance:GetMainChatView()
		if main_chat_view then
			main_chat_view:SetGuildShake(true)
		end
	end

	self.guild_data:SetQuestionInfo(protocol)
	ChatCtrl.Instance:FlushGuildChannel()
	self.guild_answer_task:Flush()
end

function GuildCtrl:OnGuildQuestionGuildRankInfo(protocol)
	self.guild_data:SetGuildRankInfo(protocol)
end


function GuildCtrl:SendGuildQuestionEnterReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildQuestionEnterReq)
	protocol:EncodeAndSend()
end

function GuildCtrl:SendGuildYunBiaoReq(opera_type, param_1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBiaoCheOpera)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1
	protocol:EncodeAndSend()
end

-- 帮派宴会
function GuildCtrl:SCGuildTianCiTongBiRankInfo(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	self.guild_data:SendRankInfo(protocol)
	self.guild_data:SendMoneyTreeState(true)

	if self.guild_station_view:IsOpen() then
		self.guild_station_view:Flush()
	elseif scene_type == SceneType.GuildStation then
		self:OpenStationView()
	end

	FuBenCtrl.Instance:FlushGuildBossButton()
	FuBenCtrl.Instance:SendMoneyTreeTime()

	local times_tamp = protocol.tianci_tongbi_close_time
	local time = times_tamp - TimeCtrl.Instance:GetServerTime()

	if time > 0 then
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_MONEYTREE, ACTIVITY_STATUS.OPEN, times_tamp) -- 设置准备以显示倒计时
		self.guild_data:SendMoneyTreeIcon(1)
	end
end

function GuildCtrl:SCGuildTianCiTongBiResult(protocol)
	self.guild_data:SendMoneyTreeState(false)
	self.guild_data:SendMoneyTreeReward(protocol)
	ViewManager.Instance:Open(ViewName.SkyMoneyRewardView, nil, "money_tree", {data = {}})
	self:CloseStationView()
	
	self.guild_data:SendMoneyTreeIcon(0)
	self.guild_data:ClsoeMoneyTreeModel()
	FuBenCtrl.Instance:SendMoneyTreeTime()

	if self.guild_station_view:IsOpen() then
		self.guild_station_view:Flush()
	end
end

function GuildCtrl:SCGuildSyncTianCiTongBi(protocol)
	self.guild_data:SendMoneyTreeIcon(protocol.is_open)
end

function GuildCtrl:SCGuildTianCiTongBiUserGatherChange(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	self.guild_data:SendMoneyTreeInfo(protocol)
	self.guild_data:SendMoneyTreeGatherState(protocol.gather_type)

	if scene_type == SceneType.GuildStation then
		if protocol.gather_num == protocol.tianci_tongbi_max_gather_num and protocol.gather_type == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.FlushMoneyTreeTips)
		end
	end

	if self.guild_station_view:IsOpen() then
		self.guild_station_view:Flush()
	end
end

function GuildCtrl:SCGuildTianCiTongBiNpcinfo(protocol)
	self.guild_data:SendMoneyTreePosInfo(protocol)
	FuBenCtrl.Instance:SendMoneyTreeTime()
end

function GuildCtrl:SendTianCiTongBiGather()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildTianCiTongBiUseGather)
	protocol:EncodeAndSend()
end

function GuildCtrl:OpenGuildMoneyTree(opera_type, guild_id, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildTianCiTongBiReq)
	protocol.opera_type = opera_type
	protocol.guild_id = guild_id or 0
	protocol.role_id = role_id or 0
	protocol:EncodeAndSend()
end

function GuildCtrl:GoToMoneyTree()
	self.guild_data:MoveToMoneyTree()
end

function GuildCtrl:MoveToTreeState(state)
	if self.guild_station_view and self.guild_station_view:IsOpen() then
		self.guild_station_view:MoveToTreeState(state)
	end
end

function GuildCtrl:OnChangeScene(scene_id)
	self:SetGuildYunbiaoSkillState(self:CheckGuildYunBiaoState())
end

function GuildCtrl:CheckGuildYunBiaoState()
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE)
	if not act_is_open then
		return false
	end

	local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
	local scene_id = guild_yunbiao_cfg.biaoche_scene_id
	if Scene.Instance:GetSceneId() == scene_id then
		if GameVoManager.Instance:GetMainRoleVo().guild_id < 1 then
			return false
		end
		if GuildDataConst.GUILDVO.is_today_biaoche_start == 1 then
			return false
		end
		if not self.has_yunbiao then
			return false
		end
		local main_role = Scene.Instance:GetMainRole()
		if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_GUILD then
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
		end
		return true
	end
	return false
end

function GuildCtrl:SetGuildYunbiaoSkillState(enabled, is_force)
	-- if self.guild_yunbiao_skill_render then --屏蔽掉，不然会报计时器没清的错，在baserender那边
	-- 	self.guild_yunbiao_skill_render:Flush()
	-- end
	
	if not is_force and enabled == self.yunbiao_state then
		return
	end
	self.yunbiao_state = enabled

	if self.yunbiao_state then
		local loader = AllocAsyncLoader(self, "skill_button_loader")
		loader:Load("uis/views/guildview_prefab", "GuildYunBiaoSkill", function (obj)
			if IsNil(obj) then
				return
			end

			MainUICtrl.Instance:ShowActivitySkill(obj)

			if nil ~= self.guild_yunbiao_skill_render then
				self.guild_yunbiao_skill_render:DeleteMe()
				self.guild_yunbiao_skill_render = nil
			end

			self.guild_yunbiao_skill_render = GuildYunBiao.New(obj)
			self.guild_yunbiao_skill_render:Flush()
		end)
	else
		MainUICtrl.Instance:ShowActivitySkill(false)
		if nil ~= self.guild_yunbiao_skill_render then
			self.guild_yunbiao_skill_render:DeleteMe()
			self.guild_yunbiao_skill_render = nil
		end
	end
end

function GuildCtrl:SetIsStopYunBiaoFollow(enable)
	if self.guild_yunbiao_skill_render and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GUILD_BONFIRE) then
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		local scene_id = guild_yunbiao_cfg.biaoche_scene_id
		if Scene.Instance:GetSceneId() == scene_id then
			self.guild_yunbiao_skill_render:StopFollow(enable)
		end
	end
end

function GuildCtrl:SCGuildTianCiTongBiGatherAOIInfo(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if scene_obj then
		if protocol.gather_type > 0 then
			local id = self.guild_data:GetGatherIdByType(protocol.gather_type)
			self.guild_data:SetGatherID(id)
			self.guild_data:SetHugState(1)
		else
			self.guild_data:SetGatherID(0)
			self.guild_data:SetHugState(0)
			scene_obj:SetAttr("task_appearn", 1)
		end
	else
		self.guild_data:SetHugState(0)
		self.guild_data:SetGatherID(0)
	end
end

function GuildCtrl:OnSCGuildGongziRankList(protocol)
	self.guild_data:SetGuildGongZiRankList(protocol)
	if self.guild_wage_view:IsOpen() then
		self.guild_wage_view:Flush()
	end
end

function GuildCtrl:SendGetGuildRareLog()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildRareLog)
	protocol:EncodeAndSend()
end

function GuildCtrl:OnSCGuildRareLogRet(protocol)
	local data_info = protocol.data_list
	if data_info and #data_info > 1 then
		SortTools.SortAsc(data_info, "timestamp")
		for k,v in pairs(data_info) do
			self:AddFallObjOnLocal(v)
		end

		if not self.is_add_msg_data then
			self.is_add_msg_data = true
			self:AddFallMsgInData()
		end
	else
		self:AddFallObjOnLocal(data_info[1])
		self.guild_data:SetGuildRareLogRet(data_info[1])
	end

	if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
		ChatCtrl.Instance:RefreshGuildFallMsg()
	end
end

function GuildCtrl:AddFallMsgInData()
	local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	local all_list_key = real_role_id .. "_fall_msg_list"
	local fall_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
	if fall_list_json_str == "" then
		return
	end

	--转化为表
	local fall_msg_list = cjson.decode(fall_list_json_str)
	-- SortTools.SortDesc(fall_msg_list, "timestamp")

	local count = 0
	for k, v in pairs(fall_msg_list) do
		count = count + 1
	end

	for i = 0, count do
		if fall_msg_list[tostring(i)] then
			self.guild_data:SetGuildRareLogRet(fall_msg_list[tostring(i)])
		end
	end
end

function GuildCtrl:AddFallObjOnLocal(data)
	if data == nil or next(data) == nil then return end
	local cur_info = data or {}

	local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
	real_role_id = real_role_id > 0 and real_role_id or GameVoManager.Instance:GetMainRoleVo().role_id

	local all_list_key = real_role_id .. "_fall_msg_list"
	local fall_list_json_str = PlayerPrefsUtil.GetString(all_list_key)
	local fall_msg_list = fall_list_json_str == "" and {} or cjson.decode(fall_list_json_str)

	local count = 0
	local is_full = true
	local new_send_time = data.timestamp or 999999999
	local last_msg_key = 0
	for k, v in pairs(fall_msg_list) do
		count = count + 1
		last_msg_key = k
		if v.timestamp == new_send_time and v.uid == data.uid and v.item_id == data.item_id then
			--获取最早的聊天时间
			is_full = false
			-- last_send_time = v.timestamp
		end
	end

	if not is_full then
		return
	end
	--超过上限，把最早记录删除
	if count >= COMMON_CONSTS.MAX_FALL_MSG_NUM and is_full then
		fall_msg_list[last_msg_key] = nil
	end

	fall_msg_list[count] = cur_info
	fall_list_json_str = cjson.encode(fall_msg_list)
	PlayerPrefsUtil.SetString(all_list_key, fall_list_json_str)
end

function GuildCtrl:SetBoxGetTips(data, callback)
	if self.guild_box_get_tip then
		self.guild_box_get_tip:SetGetCallBack(data, callback)
		self.guild_box_get_tip:Open()
	end
end

function GuildCtrl:OpenConTributeView()
	if self.contribute_equip_view then
		self.contribute_equip_view:Open()
	end
end

function GuildCtrl:OpenGuildDuiHuanView(item_id, is_bind)
	if self.guild_duihuan_view then
		self.guild_duihuan_view:SetItemId(item_id, is_bind)
		self.guild_duihuan_view:Open()
	end
end

function GuildCtrl:OpenBoxTips()
	if self.guild_box_tip then
		self.guild_box_tip:Open()
	end
end

function GuildCtrl:FlushBoxTips()
	if self.guild_box_tip and self.guild_box_tip:IsOpen() then
		self.guild_box_tip:Flush()
	end
end

function GuildCtrl:CloseBoxTips()
	if self.guild_box_tip and self.guild_box_tip:IsOpen() then
		self.guild_box_tip:Close()
	end
end