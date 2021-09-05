require("game/kuafu_pvp/kf_pvp_fight_view")
require("game/kuafu_pvp/kf_pvp_data")
require("game/kuafu_pvp/kf_pvp_view_vector")
require("game/kuafu_pvp/kf_pvp_view_main")
require("game/kuafu_pvp/kf_pvp_view_rank")
require("game/kuafu_pvp/kf_pvp_view")
require("game/kuafu_pvp/kf_pvp_view_prepare")
KuafuPVPCtrl = KuafuPVPCtrl or BaseClass(BaseController)
function KuafuPVPCtrl:__init()
	if KuafuPVPCtrl.Instance ~= nil then
		print_error("[KuafuPVPCtrl] attempt to create singleton twice!")
		return
	end
	KuafuPVPCtrl.Instance = self
	self:RegisterAllProtocals()
	self.kuafu3v3_view = KFPVPView.New(ViewName.KuaFu3v3)
	self.fight_view = KFPVPFightView.New()
	self.data = KuafuPVPData.New()
	self.show_zhizun_effect = false
	self.pipei_view = KFPVPViewPiPei.New(ViewName.KFPVPViewPiPei)
	self.prepare_view = KFPVPPrepareView.New(ViewName.KFPVPPrepareView)
	self.vector_view = KFPVPViewVector.New()
	-- self.view = Field1v1View.New()
	--self.prepare_view = KfPVPPrepareView.New()
	--self.finish_view = KfPVPFisish.New()
	--self.info_view = KfPVPInfo.New()
	--self.time_view = NewTeamView.New()
end

function KuafuPVPCtrl:__delete()
	-- self.view:DeleteMe()
	-- self.view = nil

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.kuafu3v3_view then
		self.kuafu3v3_view:DeleteMe()
		self.kuafu3v3_view = nil
	end

	if self.prepare_view then
		self.prepare_view:DeleteMe()
		self.prepare_view = nil
	end

	if self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if self.pipei_view then
		self.pipei_view:DeleteMe()
		self.pipei_view = nil
	end

	if self.vector_view then
		self.vector_view:DeleteMe()
		self.vector_view = nil
	end


	KuafuPVPCtrl.Instance = nil
end

function KuafuPVPCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCCrossMultiuserChallengeBaseSelfSideInfo, "OnCrossMultiuserChallengeBaseSelfSideInfo")
	self:RegisterProtocol(SCCrossMultiuserChallengeSelfInfoRefresh, "OnCrossMultiuserChallengeSelfInfoRefresh")
	self:RegisterProtocol(SCCrossMultiuserChallengeMatchInfoRefresh, "OnCrossMultiuserChallengeMatchInfoRefresh")
	self:RegisterProtocol(SCCrossMultiuserChallengeMatchState, "OnCrossMultiuserChallengeMatchState")
	self:RegisterProtocol(SCCrossMultiuserChallengeSelfActicityInfo, "OnCrossMultiuserChallengeSelfActicityInfo")
	self:RegisterProtocol(SCCrossMultiuserChallengeMatchingState, "OnCrossMultiuserChallengeMatchingState")
end


function KuafuPVPCtrl:OpenPiPeiView()
	if self.pipei_view then
		self.pipei_view:Open()
	end
end

-- 进入战斗时调用
function KuafuPVPCtrl:InitFight()
	self.fight_view:Open()
end

function KuafuPVPCtrl:CloseFight()
	self.fight_view:Close()
end

function KuafuPVPCtrl:GetFightView()
	return self.fight_view
end

function KuafuPVPCtrl:CloseVector()
	self.vector_view:Close()
end

function KuafuPVPCtrl:OpenView()
	if not self.data:GetIsMatching() then
		ViewManager.Instance:Open(ViewName.KuaFu3v3)
	end
end


function KuafuPVPCtrl:OpenFinishView()
	if self.vector_view then
		self.vector_view:Open()
	end
end



--------------------------------协议-----------------------------

-- 跨服3v3基本信息 
function KuafuPVPCtrl:OnCrossMultiuserChallengeBaseSelfSideInfo(protocol)
	self.data:SetMatesInfo(protocol.user_list)
	self.kuafu3v3_view:Flush("MainPanel")
end

-- 跨服3v3主角信息刷新 
function KuafuPVPCtrl:OnCrossMultiuserChallengeSelfInfoRefresh(protocol)
	self.data:SetRoleInfo(protocol)
	if self.kuafu3v3_view:IsOpen() then
		self.kuafu3v3_view:Flush("MainPanel")
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic.GetColorName and scene_logic.GetIsShowSpecialImage then
		local list = Scene.Instance:GetObjList()
		for k,v in pairs(list) do
			v:GetFollowUi():SetName(scene_logic:GetColorName(v), v)
			v:GetFollowUi():SetSpecialImage(scene_logic:GetIsShowSpecialImage(v))
		end
	end
end

-- 跨服3v3信息刷新
function KuafuPVPCtrl:OnCrossMultiuserChallengeMatchInfoRefresh(protocol)
	self.data:SetStrongHoldInfo(protocol)
	self.fight_view:Flush()
	
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic.FlushHoldObjVisible then
		scene_logic:FlushHoldObjVisible()
	end
end

	
-- 跨服3v3匹配状态
function KuafuPVPCtrl:OnCrossMultiuserChallengeMatchState(protocol)
	self.data:SetPrepareInfo(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	if protocol.match_state == 0 and scene_type == SceneType.Kf_PVP then
		self.fight_view:Open()
	else
		-- self.fight_view:ClosePrepare()
		ViewManager.Instance:Close(ViewName.KFPVPPrepareView)
	end

	if protocol.match_state == 1 then
		self.fight_view:Flush("start_time")
	end

	if protocol.match_state == 2 then
		self:OpenFinishView()
	end
end
	
-- 跨服3v3角色活动信息
function KuafuPVPCtrl:OnCrossMultiuserChallengeSelfActicityInfo(protocol)
	self.data:SetActivityInfo(protocol.info)
	KuafuPVPData.Instance:GetRewardIntegralCfg(protocol)
	RemindManager.Instance:Fire(RemindName.Cross3v3GongXunRed)
	local state_info = self.data:GetMatchStateInfo()
	state_info.matching_state = protocol.info.matching_state
	if self.kuafu3v3_view:IsOpen() then
		self.kuafu3v3_view:Flush("SeasonPanel")
		self.kuafu3v3_view:Flush("MainPanel")
		self.kuafu3v3_view:Flush("RankPanel")
		self.kuafu3v3_view:Flush("GongXunView")
	end
	-- if KuafuOnevoneCtrl.Instance.ring_view:IsOpen() then
	-- 	KuafuOnevoneCtrl.Instance.ring_view:Flush(RING_TAB_TYPE.KingLingPai)
	-- end
	self:SendCheckMultiuserChallengeHasMatch() --获取3v3战斗状态
	ZhiZunLingPaiCtrl.Instance:Flush()
end
	
-- 跨服3V3匹配状态
function KuafuPVPCtrl:OnCrossMultiuserChallengeMatchingState(protocol)
	self.data:SetMatchStateInfo(protocol)
	if protocol.matching_state == 2 then
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_PVP)
	else
		self.data:SetMatesInfo({})
		for k,v in ipairs(protocol.user_list) do
			self.data:AddTeamMate(v)
		end
		if protocol.matching_state == 3 then
			self:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
		end
		if self.kuafu3v3_view:IsOpen() then
			self.kuafu3v3_view:Flush("MainPanel")
		end
	end
end

	
-- -- 跨服3V3匹配通知
-- function KuafuPVPCtrl:OnMultiuserChallengeHasMatchNotice(protocol)
-- 	if protocol.has_match == 1 then
-- 		if nil == self.alert_window then
-- 			local function ok_fun()
-- 				CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_PVP)
-- 			end
-- 			local function cancel_func()
-- 				CrossServerCtrl.Instance:SendCrossStartReq(0)
-- 			end
-- 			self.alert_window = Alert.New(Language.KuafuPVP.MatchingTips, ok_fun, cancel_func, nil, nil, nil, false)
-- 			self.alert_window:SetOkString(Language.KuafuPVP.EnterTxt)
-- 		end
-- 		self.alert_window:Open()
-- 	else
-- 		local state_info = self.data:GetMatchStateInfo()
-- 		if state_info.matching_state == 0 or state_info.matching_state == 1 then
-- 			self:SendCrossMultiuerChallengeCancelMatching()
-- 		end
-- 	end
-- end

function KuafuPVPCtrl:OnCrossMultiuserChallengeFetchGongxunReward(seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMultiuserChallengeFetchGongxunReward)
	send_protocol.seq = seq
	send_protocol:EncodeAndSend()
end
-- 跨服3v3请求匹配（队长发起）
function KuafuPVPCtrl:SendCrossMultiuserChallengeMatchgingReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMultiuserChallengeMatchgingReq)
	send_protocol:EncodeAndSend()
end

-- 跨服3v3请求同队基本信息
function KuafuPVPCtrl:SendCrossMultiuserChallengeGetBaseSelfSideInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMultiuserChallengeGetBaseSelfSideInfo)
	send_protocol:EncodeAndSend()
end

-- 跨服3v3获取每日奖励
function KuafuPVPCtrl:SendCrossMultiuserChallengeFetchDaycountReward(seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMultiuserChallengeFetchDaycountReward)
	send_protocol.seq = seq
	send_protocol:EncodeAndSend()
end

-- 跨服3v3取消匹配
function KuafuPVPCtrl:SendCrossMultiuerChallengeCancelMatching()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMultiuerChallengeCancelMatching)
	send_protocol:EncodeAndSend()
end

-- 请求跨服3v3是否有
function KuafuPVPCtrl:SendCheckMultiuserChallengeHasMatch()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCheckMultiuserChallengeHasMatch)
	send_protocol:EncodeAndSend()
end

-- 跨服3v3展示排行查询
function KuafuPVPCtrl:SendGetCross3V3RankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetMultiuserChallengeRankList)
	send_protocol.rank_type = rank_type or 0
	send_protocol:EncodeAndSend()
end

function KuafuPVPCtrl:SendChallengeFetchGongxunReward()
	return 
end

--穿戴令牌
function KuafuPVPCtrl:SendCrossPVPCard(opr_type, ring_seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossPVPWearCardReq)
	send_protocol.opr_type = opr_type or 0
	send_protocol.ring_seq = ring_seq or 0
	send_protocol:EncodeAndSend()
end

function KuafuPVPCtrl:MianUIOpenComlete()
	self.show_zhizun_effect = true
end

function KuafuPVPCtrl:SetShowZhiZunEffect(flag)
	self.show_zhizun_effect = flag
end

function KuafuPVPCtrl:GetShowZhiZunEffect()
	return self.show_zhizun_effect
end


-- --跨服3v3展示排行
-- function KuafuPVPCtrl:OnCross3V3RankList(protocol)
-- 	if protocol.rank_type == KF_RANK_TYPE.CROSS_PERSON_RANK_TYPE_3V3_SCORE then
-- 		local rank_list = protocol.rank_list
-- 		table.sort(rank_list, function(a, b) return a.rank_value > b.rank_value end)
-- 		KuafuPVPData.Instance:SetRankList(protocol.rank_list)
-- 		if self.kuafu3v3_view:IsOpen() then
-- 			self.kuafu3v3_view:Flush("SeasonPanel")
-- 			self.kuafu3v3_view:Flush("MainPanel")
-- 			self.kuafu3v3_view:Flush("RankPanel")
-- 			self.kuafu3v3_view:Flush("GongXunView")
-- 		end
-- 	end
-- end


