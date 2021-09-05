require("game/kfarena/kf_arena_data")
require("game/kfarena/kf_arena_activity_view")
require("game/kfarena/kf_arena_view")
require("game/kfarena/kf_arena_rank_view")
require("game/kfarena/kf_arena_fight")
require("game/kfarena/kf_arena_victory_view")
require("game/kfarena/kf_arena_lose_view")

local KFARENA_STATUS = {
	AWAIT = 0,					-- 等待
	PREPARE = 1,				-- 准备
	PROCEED = 2,				-- 进行中
	OVER = 3,					-- 结束
}

KFArenaCtrl = KFArenaCtrl or BaseClass(BaseController)
function KFArenaCtrl:__init()
	if KFArenaCtrl.Instance then
		print_error("[KFArenaCtrl] Attemp to create a singleton twice !")
	end
	KFArenaCtrl.Instance = self

	self.data = KFArenaData.New()
	self.kf_arena_activity_view = KFArenaActivityView.New(ViewName.KFArenaActivityView)
	self.fight_view = KFArenaFight.New()
	self.victory_view = KFArenaVictoryView.New()
	self.lose_view = KFArenaLoseView.New()

	self.can_move = false

	self:RegisterAllProtocols()
end

function KFArenaCtrl:__delete()
	KFArenaCtrl.Instance = nil

	if self.fight_view ~= nil then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
end

function KFArenaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossChallengeFieldStatus, "OnSCChallengeFieldStatus")
	self:RegisterProtocol(SCCrossChallengeFieldUserInfo, "OnSCChallengeFieldUserInfo")
	self:RegisterProtocol(SCCrossChallengeFieldOpponentRankPosChange, "OnSCChallengeFieldOpponentRankPosChange")
	self:RegisterProtocol(SCCrossChallengeFieldWin, "OnSCChallengeFieldWin")
	self:RegisterProtocol(SCCrossChallengeFieldRankInfo, "OnSCChallengeFieldRankInfo")
	self:RegisterProtocol(SCCrossChallengeFieldOpponentInfo, 'OnSCChallengeFieldOpponentInfo')
	self:RegisterProtocol(SCCrossChallengeFieldBeDefeatNotice, 'OnSCChallengeFieldBeDefeatNotice')

	self:RegisterProtocol(CSCrossChallengeFieldOpera)
end


-- 场景用户信息
function KFArenaCtrl:OnSCChallengeFieldStatus(protocol)
	self.data.scene_user_list = protocol.side_info_list
	self.data.scene_status = protocol.status
	self.data.scene_next_time = protocol.next_status_timestamp
	if self.data.scene_status == KFARENA_STATUS.AWAIT then				-- 等待
		-- ArenaCtrl.Instance:SetCanMove(false)
	elseif self.data.scene_status == KFARENA_STATUS.PREPARE then		-- 准备
		self:SetCanMove(false)
		self.data.last_rank = self.data.user_info.rank
		if self.fight_view then
			self.fight_view:StartCountDown()
		end
	elseif self.data.scene_status == KFARENA_STATUS.PROCEED then		-- 进行中
		self:SetCanMove(true)
		if self.fight_view then
			self.fight_view:StartFight()
		end
	elseif self.data.scene_status == KFARENA_STATUS.OVER then
		KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
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
			KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_SELFT_INFO)
			KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_REFRESH)
			KFArenaCtrl.Instance:SendKfArenaReq(CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_OPPONENT_INFO, 0)
		end
		GlobalTimerQuest:AddDelayTimer(timer_callback, 0.5)			--延迟打开
	end
	ViewManager.Instance:FlushView(ViewName.KFArenaActivityView, "kfarena")
end

function KFArenaCtrl:SetCanMove(is_move)
	self.can_move = is_move
end

function KFArenaCtrl:GetCanMove()
	return self.can_move
end

-- 请求进入挑战
function KFArenaCtrl:ResetFieldFightReq(data)
	local send_protocol = ProtocolPool.Instance:GetProtocol()
	send_protocol.opponent_index = data.opponent_index
	send_protocol.ignore_rank_pos = 1
	send_protocol.rank_pos = data.rank_pos
	send_protocol.is_auto_buy = data.is_auto_buy
	send_protocol:EncodeAndSend()
end

-- 挑战列表信息和个人信息
function KFArenaCtrl:OnSCChallengeFieldUserInfo(protocol)
	self.data.user_info = protocol.user_info
	ViewManager.Instance:FlushView(ViewName.KFArenaActivityView, "kfarena")
	self.kf_arena_activity_view:Flush("kfarena_rank")
	RemindManager.Instance:Fire(RemindName.KFArenaChallange)
	RemindManager.Instance:Fire(RemindName.KFArenaRank)
	RemindManager.Instance:Fire(RemindName.KFArena)
end

-- 返回玩家详细信息
function KFArenaCtrl:OnSCChallengeFieldOpponentInfo(protocol)
	self.data:SetRoleInfo(protocol.role_info)
	ViewManager.Instance:FlushView(ViewName.KFArenaActivityView, "kfarena")
end

function KFArenaCtrl:CloseFightView()
	self.fight_view:Close()
	if self.victory_view then
		self.victory_view:Close()
	end
	if self.lose_view then
		self.lose_view:Close()
	end
end

-- 进入战斗时调用
function KFArenaCtrl:InitFight()
	self.fight_view:Open()
end

-- 排位变化通知
function KFArenaCtrl:OnSCChallengeFieldOpponentRankPosChange(protocol)
	ViewManager.Instance:FlushView(ViewName.KFArenaActivityView, "kfarena")
end

-- 直接胜利
function KFArenaCtrl:OnSCChallengeFieldWin(protocol)
	self.data:SetFightResult2(protocol)
	if self.victory_view then
		self.victory_view:Open()
	end
end

-- 英雄榜
function KFArenaCtrl:OnSCChallengeFieldRankInfo(protocol)
	self.data.rank_info = protocol.rank_info
	self.kf_arena_activity_view:Flush("kfarena_rank")
end

-- 角色排位改变
function KFArenaCtrl:OnSCChallengeFieldBeDefeatNotice()

end


-- 请求其它玩家详细信息
function KFArenaCtrl:SendKfArenaReq(req_type, param1, param2, param3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossChallengeFieldOpera)
	if CROSS_CHALLENGEFIELD_OPERA_REQ.CROSS_CHALLENGEFIELD_OPERA_REQ_FIGHT == req_type then
			-- 请求进入前先设置禁止移动
		self.can_move = false
	end
	send_protocol.req_type = req_type
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

function KFArenaCtrl:GetTargetObj()
	local obj_list = Scene.Instance:GetObjList()
	if obj_list then
		for k,v in pairs(obj_list) do
			if v:IsRole() and not v:IsMainRole() then
				return v
			end
		end
	end
end