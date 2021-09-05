require("game/rank/rank_data")
require("game/rank/rank_view")
RankCtrl = RankCtrl or BaseClass(BaseController)

function RankCtrl:__init()
	if RankCtrl.Instance then
		print_error("[RankCtrl] Attemp to create a singleton twice !")
	end
	RankCtrl.Instance = self

	self.data = RankData.New()
	self.view = RankView.New(ViewName.Ranking)
	self:RegisterAllProtocols()

	self.time_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.ServerOpenDayChange, self))
end

function RankCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.time_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_quest)
		self.time_quest = nil
	end

	RankCtrl.Instance = nil
end

function RankCtrl:GetRankView()
	return self.view
end

function RankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetPersonRankListAck, "OnGetPersonRankListAck")
	self:RegisterProtocol(SCGetGuildRankListAck, "OnGetGuildRankListAck")
	self:RegisterProtocol(SCGetTeamRankListAck, "OnGetTeamRankListAck")
	self:RegisterProtocol(SCGetPersonRankTopUserAck, "OnGetPersonRankTopUserAck")
	self:RegisterProtocol(SCGetWorldLevelAck, "OnGetWorldLevelAck")
	self:RegisterProtocol(SCSendFamousManInfo, "OnSCSendFamousManInfo")
	self:RegisterProtocol(SCGetCoupleRankListAck, "OnGetCoupleRankListAck")
	self:RegisterProtocol(CSGetCoupleRankList)
end

function RankCtrl:ServerOpenDayChange(cur_day, is_new_day)
	RemindManager.Instance:Fire(RemindName.Rank)
end

function RankCtrl:OnGetCoupleRankListAck(protocol)
	self.data:OnGetCoupleRankListAck(protocol)
end

function RankCtrl:GetCoupleRankListReq(rank_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetCoupleRankList)
	protocol.rank_type = rank_type
	protocol:EncodeAndSend()
end

-- 个人排行返回
function RankCtrl:OnGetPersonRankListAck(protocol)
	self.data:OnGetPersonRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	if CompetitionActivityCtrl.Instance.view:IsOpen() then
		CompetitionActivityCtrl.Instance:FlushView()
	end

	if KaifuActivityCtrl.Instance.view:IsOpen() then
		KaifuActivityCtrl.Instance:FlushKaifuView()
	end

	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QUAN_MIN_UPGRADE_GROUPE, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	-- if protocol.rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FIGHTING_CHALLENGE then
	-- 	MiningController.Instance:FlsuhChallengeRankView()
	-- end

	if BiaoBaiQiangCtrl.Instance.rank_view:IsOpen() then
		BiaoBaiQiangCtrl.Instance:FlushRankView()
	end

	-- if CompetitionActivityCtrl.Instance.view:IsOpen() then
	-- 	CompetitionActivityCtrl.Instance.view:FlushRankInfo()
	-- end
	GlobalEventSystem:Fire(OtherEventType.RANK_CHANGE, protocol.rank_type)
end

-- 仙盟排行返回
function RankCtrl:OnGetGuildRankListAck(protocol)
	-- self.data:OnGetGuildRankListAck(protocol)
	self.data:OnGetGuildWarRankListAck(protocol)
	GuildCtrl.Instance:FlushGuildWarView()
	ChatCtrl.Instance:FlushGuildShenYuRank()
end

--队伍排行返回
function RankCtrl:OnGetTeamRankListAck(protocol)
	self.data:OnGetTeamRankListAck(protocol)
end

--顶级玩家信息返回
function RankCtrl:OnGetPersonRankTopUserAck(protocol)
	self.data:OnGetPersonRankTopUserAck(protocol)
end

--世界等级信息返回
function RankCtrl:OnGetWorldLevelAck(protocol)
	self.data:OnGetWorldLevelAck(protocol)
end

--名人堂信息返回
function RankCtrl:OnSCSendFamousManInfo(protocol)

	RankData.Instance:SetFamousList(protocol.famous_list)
	RankData.Instance:ClearMingrenData()
	RankData.Instance:SetMingrenIdList(protocol.famous_list)
end

--请求个人排行
function RankCtrl:SendGetPersonRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求军团排行
function RankCtrl:SendGetGuildRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求队伍排行
function RankCtrl:SendGetTeamRankListReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetTeamRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求顶级玩家信息
function RankCtrl:SendGetPersonRankTopUserReq(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankTopUserReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end

--请求名人堂信息
function RankCtrl:SendFamousManOpera(opera_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFamousManOpera)
	send_protocol.opera_type = opera_type
	send_protocol:EncodeAndSend()
end

--请求所有模块的战力值
function RankCtrl:SendRoleCapabilityOpera()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRoleCapability)
	protocol:EncodeAndSend()
end

-- 请求爬塔排行榜信息
function RankCtrl:SendTowerRankOpera(rank_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetPersonRankListReq)
	send_protocol.rank_type = rank_type
	send_protocol:EncodeAndSend()
end


function RankCtrl:ClearRankRoleIDCache()
	if self.view then
		self.view:ClearRoleIDCache()
	end
end

