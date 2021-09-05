require("game/arena/arena_data")
require("game/arena/arena_view")
require("game/arena/arena_rank_view")
require("game/arena/arena_fight")
require("game/arena/arena_victory_view")
require("game/arena/arena_lose_view")
require("game/arena/arena_rank_view")
require("game/arena/arena_buff_tips")
require("game/arena/arena_reward_preview")
require("game/arena/arena_activity_view")
require("game/arena/arena_tupo_view")
ArenaCtrl = ArenaCtrl or BaseClass(BaseController)

local ISARENAREMIND = 0

function ArenaCtrl:__init()
	if ArenaCtrl.Instance then
		print_error("[ArenaCtrl] Attemp to create a singleton twice !")
	end
	ArenaCtrl.Instance = self
	self.data = ArenaData.New()
	-- self.rank_view = ArenaRankView.New(ViewName.ArenaRankView)
	self.fight_view = ArenaFight.New()
	self.victory_view = ArenaVictoryView.New()
	self.lose_view = ArenaLoseView.New()
	self.arena_buff_tips = ArenaBuffTips.New()
	self.arena_reward_preview = ArenaRewardPreview.New()
	self.arena_activity_view = ArenaActivityView.New(ViewName.ArenaActivityView)
	self:RegisterAllProtocols()

	self.can_move = false
end

function ArenaCtrl:__delete()

	-- if self.rank_view ~= nil then
	-- 	self.rank_view:DeleteMe()
	-- 	self.rank_view = nil
	-- end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.fight_view ~= nil then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if self.victory_view ~= nil then
		self.victory_view:DeleteMe()
		self.victory_view = nil
	end

	if self.lose_view ~= nil then
		self.lose_view:DeleteMe()
		self.lose_view = nil
	end

	if self.arena_buff_tips ~= nil then
		self.arena_buff_tips:DeleteMe()
		self.arena_buff_tips = nil
	end

	if self.arena_reward_preview ~= nil then
		self.arena_reward_preview:DeleteMe()
		self.arena_reward_preview = nil
	end

	if self.arena_activity_view ~= nil then
		self.arena_activity_view:DeleteMe()
		self.arena_activity_view = nil
	end

	ArenaCtrl.Instance = nil
end

function ArenaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCChallengeFieldStatus, "OnSCChallengeFieldStatus")
	self:RegisterProtocol(SCChallengeFieldUserInfo, "OnSCChallengeFieldUserInfo")
	self:RegisterProtocol(SCChallengeFieldOpponentRankPosChange, "OnSCChallengeFieldOpponentRankPosChange")
	self:RegisterProtocol(SCChallengeFieldWin, "OnSCChallengeFieldWin")
	self:RegisterProtocol(SCChallengeFieldRankInfo, "OnSCChallengeFieldRankInfo")
	self:RegisterProtocol(SCChallengeFieldOpponentInfo, 'OnSCChallengeFieldOpponentInfo')
	self:RegisterProtocol(SCChallengeFieldBeDefeatNotice, 'OnSCChallengeFieldBeDefeatNotice')
	self:RegisterProtocol(SCChallengeFieldBestRankBreakInfo, 'OnChallengeFieldBestRankBreakInfo')

	self:RegisterProtocol(CSChallengeFieldGetRankInfo)
	self:RegisterProtocol(CSChallengeFieldGetUserInfo)
	self:RegisterProtocol(CSChallengeFieldResetOpponentList)
	self:RegisterProtocol(CSChallengeFieldFightReq)
	self:RegisterProtocol(CSChallengeFieldFetchGuangHui)
	self:RegisterProtocol(CSChallengeFieldBuyJoinTimes)
	self:RegisterProtocol(CSChallengeFieldGetOpponentInfo)
	self:RegisterProtocol(CSChallengeFieldBuyBuff)
	self:RegisterProtocol(CSChallengeFieldBestRankBreakReq)
	self:RegisterProtocol(CSChallengeFieldReadyStartFightReq)

	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadingQuite, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function ArenaCtrl:GetExchangeContentView()
	if self.arena_activity_view then
		return self.arena_activity_view:GetExchangeContentView()
	end
end

function ArenaCtrl:ShowXianShi()
	-- if self.arena_activity_view then
		-- self.arena_activity_view:ShowXianShi()
	-- end
end

function ArenaCtrl:GetArenaActivityView()
	return self.arena_activity_view
end

-- 主界面创建
function ArenaCtrl:MainuiOpenCreate()
	self:ReqFieldGetUserInfo()
	self:ResetOpponentList()
	self:ReqOtherRoleInfo(0)
	self:ReqFieldGetRankInfo()
	self:ReqOtherRoleInfo(1)
end

-- 请求战报，挑战列表
function ArenaCtrl:GetArenaRankView()
	if self.rank_view then
		return self.rank_view
	end
end

-- 请求战报，挑战列表
function ArenaCtrl:OpenArenaBuffView()
	if self.arena_buff_tips then
		self.arena_buff_tips:Open()
	end
end

function ArenaCtrl:OpenRewardPreview()
	if self.arena_reward_preview then
		self.arena_reward_preview:Open()
	end
end

-- 请求战报，挑战列表
function ArenaCtrl:ReqFieldGetUserInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldGetUserInfo)
	send_protocol:EncodeAndSend()
end

-- 刷新挑战对手
function ArenaCtrl:ResetOpponentList()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldResetOpponentList)
	send_protocol:EncodeAndSend()
end

-- 领取光辉
function ArenaCtrl:ResetGetGuangHuiReward()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldFetchGuangHui)
	send_protocol:EncodeAndSend()
end

-- 请求进入挑战
function ArenaCtrl:ResetFieldFightReq(data)
	-- 请求进入前先设置禁止移动
	self.can_move = false
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldFightReq)
	send_protocol.opponent_index = data.opponent_index
	send_protocol.ignore_rank_pos = 1
	send_protocol.rank_pos = data.rank_pos
	send_protocol.is_auto_buy = data.is_auto_buy
	send_protocol:EncodeAndSend()
end

-- 购买次数
function ArenaCtrl:FieldBuyJoinTimes()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldBuyJoinTimes)
	send_protocol:EncodeAndSend()
end

-- 请求英雄榜信息
function ArenaCtrl:ReqFieldGetRankInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldGetRankInfo)
	send_protocol:EncodeAndSend()
end

-- 请求其它玩家详细信息
function ArenaCtrl:ReqOtherRoleInfo(type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldGetOpponentInfo)
	send_protocol.type = type
	send_protocol:EncodeAndSend()
end

function ArenaCtrl:ReqArenaBuff()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldBuyBuff)
	send_protocol:EncodeAndSend()
end

-- 场景用户信息
function ArenaCtrl:OnSCChallengeFieldStatus(protocol)
	self.data.scene_user_list = protocol.scene_user_list
	self.data.scene_status = protocol.status
	self.data.scene_next_time = protocol.next_time
	if self.data.scene_status == FIELD1V1_STATUS.AWAIT then				-- 等待
		-- ArenaCtrl.Instance:SetCanMove(false)
	elseif self.data.scene_status == FIELD1V1_STATUS.PREPARE then		-- 准备
		self:SetCanMove(false)
		self.data.last_rank = self.data.user_info.rank
		if self.fight_view then
			self.fight_view:StartCountDown()
		end
	elseif self.data.scene_status == FIELD1V1_STATUS.PROCEED then		-- 进行中
		self:SetCanMove(true)
		if self.fight_view then
			self.fight_view:StartFight()
		end
	elseif self.data.scene_status == FIELD1V1_STATUS.OVER then
		self:ReqFieldGetUserInfo()
		local timer_callback = function()
			self.data:SetFightResult()
			local result = self.data:IsWin()
			if self.data:IsWin() then
				if self.victory_view then
					self.victory_view:Open()
				end
			else
				if self.lose_view then
					self.lose_view:Open()
				end
			end
			local target_obj = self:GetTargetObj()
			if target_obj and not target_obj:IsDead() then
				local part = target_obj.draw_obj:GetPart(SceneObjPart.Main)
				if part then
					part:SetBool(ANIMATOR_PARAM.FIGHT, false)
				end
			end
			local main_role = Scene.Instance:GetMainRole()
			if not main_role:IsDead() then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			end
			if self.fight_view then
				self.fight_view:OpenRewardPanel()
			end
			self:ReqFieldGetUserInfo()
			self:ResetOpponentList()
			self:ReqOtherRoleInfo(0)
		end
		GlobalTimerQuest:AddDelayTimer(timer_callback, 0.5)			--延迟打开
	end
	ViewManager.Instance:FlushView(ViewName.ArenaActivityView, "arena")
end

function ArenaCtrl:GetTargetObj()
	local obj_list = Scene.Instance:GetObjList()
	if obj_list then
		for k,v in pairs(obj_list) do
			if v:IsRole() and not v:IsMainRole() then
				return v
			end
		end
	end
end

function ArenaCtrl:SetCanMove(is_move)
	self.can_move = is_move
end

function ArenaCtrl:GetCanMove()
	return self.can_move
end

function ArenaCtrl:GetIsRemind()
	return ISARENAREMIND
end

function ArenaCtrl:SetIsRemind()
	ISARENAREMIND = 1
end

-- 挑战列表信息和个人信息
function ArenaCtrl:OnSCChallengeFieldUserInfo(protocol)
	self.data.user_info = protocol.user_info
	ViewManager.Instance:FlushView(ViewName.ArenaActivityView, "arena")
	ViewManager.Instance:FlushView(ViewName.ArenaRankView)
	self.arena_buff_tips:Flush()
	self.arena_activity_view:Flush("arena_rank")
	RemindManager.Instance:Fire(RemindName.ActivityHall)
	RemindManager.Instance:Fire(RemindName.ArenaChallange)
	RemindManager.Instance:Fire(RemindName.ArenaRank)
	RemindManager.Instance:Fire(RemindName.Arena)
end

-- 返回玩家详细信息
function ArenaCtrl:OnSCChallengeFieldOpponentInfo(protocol)
	self.data:SetRoleInfo(protocol.role_info)
	ViewManager.Instance:FlushView(ViewName.ArenaActivityView, "arena")
end

-- 排位变化通知
function ArenaCtrl:OnSCChallengeFieldOpponentRankPosChange(protocol)
	ViewManager.Instance:FlushView(ViewName.ArenaActivityView, "arena")
end

-- 英雄榜
function ArenaCtrl:OnSCChallengeFieldRankInfo(protocol)
	self.data.rank_info = protocol.rank_info
	self.arena_activity_view:Flush("arena_rank")
end

-- 直接胜利
function ArenaCtrl:OnSCChallengeFieldWin(protocol)
	self.data:SetFightResult2(protocol)
	if self.victory_view then
		self.victory_view:Open()
	end
end

-- 角色排位改变
function ArenaCtrl:OnSCChallengeFieldBeDefeatNotice()

end

-- 进入战斗时调用
function ArenaCtrl:InitFight()
	self.fight_view:Open()
end

function ArenaCtrl:OnSceneLoadingQuite()
	if Scene.Instance:GetSceneType() == SceneType.Field1v1 then
		self.fight_view:Open()
	end
end

function ArenaCtrl:CloseFightView()
	self.fight_view:Close()
	if self.victory_view then
		self.victory_view:Close()
	end
	if self.lose_view then
		self.lose_view:Close()
	end
end

-- 1V1竞技场历史最高突破信息
function ArenaCtrl:OnChallengeFieldBestRankBreakInfo(protocol)
	self.data:SetBestRank(protocol)
	self.arena_activity_view:Flush("arena_tupo")
	RemindManager.Instance:Fire(RemindName.ArenaTupo)
	RemindManager.Instance:Fire(RemindName.Arena)
end

-- 1V1竞技场历史最高突破请求
function ArenaCtrl.SendChallengeFieldBestRankBreakReq(op_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldBestRankBreakReq)
	send_protocol.op_type = op_type
	send_protocol:EncodeAndSend()
end

-- 1V1竞技场请求准备正式开始战斗倒计时
function ArenaCtrl:SendChallengeFieldReadyStartFightReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChallengeFieldReadyStartFightReq)
	send_protocol:EncodeAndSend()
end