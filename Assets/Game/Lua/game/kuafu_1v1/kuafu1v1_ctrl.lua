require("game/kuafu_1v1/kuafu1v1_fight_view")
require("game/kuafu_1v1/kuafu1v1_data")
require("game/kuafu_1v1/kuafu1v1_view_loser")
require("game/kuafu_1v1/kuafu1v1_view_vector")
require("game/kuafu_1v1/kuafu1v1_view_count")
require("game/kuafu_1v1/kuafu1v1_view_main")
require("game/kuafu_1v1/kuafu1v1_view_rank")
require("game/kuafu_1v1/kuafu1v1_award_view")
require("game/kuafu_1v1/kuafu1v1_view")
require("game/kuafu_1v1/kuafu1v1_view_pipei")

KuaFu1v1Ctrl = KuaFu1v1Ctrl or BaseClass(BaseController)

function KuaFu1v1Ctrl:__init()
	if KuaFu1v1Ctrl.Instance ~= nil then
		print_error("[KuaFu1v1Ctrl] attempt to create singleton twice!")
		return
	end
	KuaFu1v1Ctrl.Instance = self

	self:RegisterAllProtocols()
	self.kuafu1v1_view = Kuafu1V1View.New(ViewName.KuaFu1v1)
	self.kuafu3v3_view = KFPVPView.New(ViewName.KuaFu3v3)
	self.fight_view = KuaFu1v1FightView.New()
	self.data = KuaFu1v1Data.New()
	self.vector_view = KuaFu1v1ViewVector.New()
	self.loser_view = KuaFu1v1ViewLoser.New()
	self.pipei_view = KuaFu1v1ViewPiPei.New(ViewName.KuaFu1v1PiPei)
	self.show_wangzhe_effect = false
	self.can_move = false
end

function KuaFu1v1Ctrl:__delete()

	if self.kuafu1v1_view then
		self.kuafu1v1_view:DeleteMe()
		self.kuafu1v1_view = nil
	end

	if self.kuafu3v3_view then
		self.kuafu3v3_view:DeleteMe()
		self.kuafu3v3_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.vector_view ~= nil then
		self.vector_view:DeleteMe()
		self.vector_view = nil
	end

	if self.loser_view ~= nil then
		self.loser_view:DeleteMe()
		self.loser_view = nil
	end

	if nil ~= self.fight_view then
		self.fight_view:DeleteMe()
		self.fight_view = nil
	end

	if nil ~= self.pipei_view then
		self.pipei_view:DeleteMe()
		self.pipei_view = nil
	end

	KuaFu1v1Ctrl.Instance = nil
end

function KuaFu1v1Ctrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossActivity1V1SelfInfo, "OnCrossActivity1V1SelfInfo")
	self:RegisterProtocol(SCCross1v1FightStart, "OnCross1v1FightStart")
	self:RegisterProtocol(SCCross1v1MatchAck, "OnCross1v1MatchAck")
	self:RegisterProtocol(SCCross1v1WeekRecord, "OnCross1v1WeekRecord")
	self:RegisterProtocol(SCGetCrossPersonRankListAck, "OnCross1V1RankList")
	self:RegisterProtocol(SCCross1v1MatchResult, "OnCross1v1MatchResult")
	self:RegisterProtocol(SCCross1v1FightResult, "OnCross1v1FightResult")
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadingQuite, self))
end

function KuaFu1v1Ctrl:OpenView()
	if not self.data:GetIsMatching() then
		ViewManager.Instance:Open(ViewName.KuaFu1v1)
	end
end

-- 进入战斗时调用
function KuaFu1v1Ctrl:InitFight()
	self.fight_view:Open()
end

-- 得到跨服1v1的个人信息
function KuaFu1v1Ctrl:OnCrossActivity1V1SelfInfo(protocol)
	self.can_move = false
	KuaFu1v1Data.Instance:SetRoleData(protocol)
	RemindManager.Instance:Fire(RemindName.GongXunRed)
	if self.kuafu1v1_view:IsOpen() then
		self.kuafu1v1_view:Flush("SeasonPanel")
		self.kuafu1v1_view:Flush("MainPanel")
		self.kuafu1v1_view:Flush("RankPanel")
		self.kuafu1v1_view:Flush("GongXunView")
	end
	WangZheZhiJieCtrl.Instance:Flush()
end


function KuaFu1v1Ctrl:SetCanMove(is_move)
	self.can_move = is_move
end

function KuaFu1v1Ctrl:GetCanMove()
	return self.can_move
end

-- 跨服1V1战斗开始
function KuaFu1v1Ctrl:OnCross1v1FightStart(protocol)
	KuaFu1v1Data.Instance:SetCross1v1FightStart(protocol)
	if protocol.timestamp_type == 1 then
		self.fight_view:Flush("fight")
		self.can_move = true
	end
end

--跨服1v1匹配确认
function KuaFu1v1Ctrl:OnCross1v1MatchAck(protocol)
	self.data:Set1V1MacthInfo(protocol)
	if self.kuafu1v1_view:IsOpen() then
		self.kuafu1v1_view:Flush("MainPanel")
	end
end

--跨服1v1战斗记录
function KuaFu1v1Ctrl:OnCross1v1WeekRecord(protocol)
	self.data:ClearKf1V1News()
	for i,v in ipairs(protocol.kf_1v1_news) do		
		local plat = ""
		if GameVoManager.Instance:GetMainRoleVo().plat_type ~= v.oppo_plat_type then
			plat = Language.Common.WaiYu .. "_"
		end
		if v.oppo_server_id <= 0 then
			v.oppo_server_id = 1
		end
		local name = plat .. v.oppo_name .. "_s" .. v.oppo_server_id
		self.data:AddKf1V1News(name, v.result, v.add_score)
	end
end

--跨服1v1展示排行
function KuaFu1v1Ctrl:OnCross1V1RankList(protocol)
	if protocol.rank_type == KF_RANK_TYPE.CROSS_PERSON_RANK_TYPE_1V1_SCORE then
		local rank_list = protocol.rank_list
		table.sort(rank_list, function(a, b) return a.rank_value > b.rank_value end)
		KuaFu1v1Data.Instance:SetRankList(protocol.rank_list)
		if self.kuafu1v1_view:IsOpen() then
			self.kuafu1v1_view:Flush("SeasonPanel")
			self.kuafu1v1_view:Flush("MainPanel")
			self.kuafu1v1_view:Flush("RankPanel")
			self.kuafu1v1_view:Flush("GongXunView")
		end
	elseif protocol.rank_type == KF_RANK_TYPE.CROSS_PERSON_RANK_TYPE_3V3_SCORE then
		local rank_list = protocol.rank_list
		table.sort(rank_list, function(a, b) return a.rank_value > b.rank_value end)
		KuafuPVPData.Instance:SetRankList(protocol.rank_list)
		if self.kuafu3v3_view:IsOpen() then
			self.kuafu3v3_view:Flush("SeasonPanel")
			self.kuafu3v3_view:Flush("MainPanel")
			self.kuafu3v3_view:Flush("RankPanel")
			self.kuafu3v3_view:Flush("GongXunView")
		end
	elseif protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ADD_CAPABILITY
		or protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ADD_CHARM 
		or protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_GUILD_KILL_BOSS then
		CrossRankCtrl.Instance:OnPersonCrossRankListAck(protocol)
	elseif protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_CAPABILITY_ALL
		or protocol.rank_type == CROSS_PERSON_RANK_TYPE.CROSS_PERSON_RANK_TYPE_ROLE_LEVEL then		
		RankData.Instance:OnGetKuaFuRankListAck(protocol)
		ViewManager.Instance:FlushView(ViewName.Ranking)
	end
end


--跨服1v1匹配结果
function KuaFu1v1Ctrl:OnCross1v1MatchResult(protocol)
	self.data:SetMatchResult(protocol.info)
	self.data:SetMatchingEnemySex(protocol.info)
	self.kuafu1v1_view:Close()
	self.pipei_view:Open()
end

function KuaFu1v1Ctrl:ShowEnemyInfo()
	if self.kuafu1v1_view:IsOpen() then
		self.kuafu1v1_view:ShowEnemyInfo()
	end
end

function KuaFu1v1Ctrl:OpenRankView()
	self:SendGetCross1V1RankListReq()
	ViewManager.Instance:Open(ViewName.KuaFu1v1Rank)
end

--跨服1v1挑战结果
function KuaFu1v1Ctrl:OnCross1v1FightResult(protocol)
	self.data:SetFightResult(protocol)
	if self.fight_view:IsOpen() then
		self.fight_view:OpenRewardPanel(protocol.result)
	end
	if protocol.result == 1 then
		if self.vector_view then
			self.vector_view:Open()
		end
	else
		if self.loser_view then
			self.loser_view:Open()
		end
	end
end

-- 跨服1v1匹配请求
function KuaFu1v1Ctrl:SendCrossMatch1V1Req()
	self.can_move = false
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossMatch1V1Req)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1战斗准备
function KuaFu1v1Ctrl:SendCross1v1FightReadyReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1FightReady)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1下注
function KuaFu1v1Ctrl:SendCross1v1XiazhuReq(seq, gold)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1XiazhuReq)
	send_protocol.seq = seq or 0
	send_protocol.gold = gold or 0
	send_protocol:EncodeAndSend()
end

-- 跨服1v1匹配查询
function KuaFu1v1Ctrl:SendCross1v1MatchQueryReq(req_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1MatchResultReq)
	send_protocol.req_type = req_type or 0
	send_protocol:EncodeAndSend()
end

-- 跨服1v1战斗记录查询
function KuaFu1v1Ctrl:SendCross1v1WeekRecordQuery()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1WeekRecordQuery)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1展示排行查询
function KuaFu1v1Ctrl:SendGetCross1V1RankListReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetCross1V1RankList)
	send_protocol:EncodeAndSend()
end

-- 跨服1v1领取奖励
function KuaFu1v1Ctrl:SendGetCross1V1RankRewardReq(fetch_type, seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1FetchRewardReq)
	send_protocol.fetch_type = fetch_type
	send_protocol.seq = seq or 0
	send_protocol:EncodeAndSend()
end

-- 跨服1v1购买次数
function KuaFu1v1Ctrl:SendCSCross1v1BuyTimeReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1BuyTimeReq)
	send_protocol:EncodeAndSend()
end

function KuaFu1v1Ctrl:OnSceneLoadingQuite()
	if Scene.Instance:GetSceneType() == SceneType.Kf_OneVOne then
		self.fight_view:Open()
	end
end

function KuaFu1v1Ctrl:CloseFightView()
	self.fight_view:Close()
	if self.vector_view then
		self.vector_view:Close()
	end
	if self.loser_view then
		self.loser_view:Close()
	end
end

function KuaFu1v1Ctrl:MianUIOpenComlete()
	self.show_wangzhe_effect = true
end

function KuaFu1v1Ctrl:SetShowWangZheEffect(flag)
	self.show_wangzhe_effect = flag
end

function KuaFu1v1Ctrl:GetShowWangZheEffect()
	return self.show_wangzhe_effect
end

--穿戴戒指
function KuaFu1v1Ctrl:SendCross1v1Ring(opr_type,ring_seq)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCross1v1WearRingReq)
	send_protocol.opr_type = opr_type or 0
	send_protocol.ring_seq = ring_seq or 0
	send_protocol:EncodeAndSend()
end

function KuaFu1v1Ctrl:IsBlockActive()
	if self.fight_view and self.fight_view:IsOpen() then
		self.fight_view.node_list["Block"]:SetActive(false)
	end
end

function KuaFu1v1Ctrl:CreartKuaFu1v1ViewFight()
	if self.fight_view then
		self.fight_view:Open()
		self.fight_view:CreartKuaFu1v1ViewFight()
	end
end

function KuaFu1v1Ctrl:CloseHpTouXiang()
	if self.fight_view and self.fight_view:IsOpen() then
		self.fight_view:Flush("close_all_view")
		-- self.fight_view:CloseAllView()
	end
end