require("game/cross_rank/cross_rank_data")
require("game/cross_rank/cross_rank_view")
CrossRankCtrl = CrossRankCtrl or BaseClass(BaseController)

function CrossRankCtrl:__init()
	if CrossRankCtrl.Instance then
		print_error("[CrossRankCtrl] Attemp to create a singleton twice !")
	end
	CrossRankCtrl.Instance = self

	self.data = CrossRankData.New()
	self.view = CrossRankView.New(ViewName.CrossRankView)
	self:RegisterAllProtocols()
	self.is_show = true
end

function CrossRankCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	CrossRankCtrl.Instance = nil
end

function CrossRankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSCrossGetPersonRankList)
	self:RegisterProtocol(CSGetSpecialRankValue)
	self:RegisterProtocol(SCGetSpecialRankValueAck, "OnSCGetSpecialRankValueAck")
	self:RegisterProtocol(SCGetCrossCoupleRankListAck, "OnSCGetCrossCoupleRankListAck")
end

-- 请求跨服排行榜信息
function CrossRankCtrl:SendGetPersonCrossRankList(rank_type)
   local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossGetPersonRankList)
   send_protocol.rank_type = rank_type or 0
   send_protocol:EncodeAndSend()
end

-- 请求跨服排行榜个人信息
function CrossRankCtrl:SendGetSpecialRankValue(rank_type)
   local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetSpecialRankValue)
   send_protocol.rank_type = rank_type or 0
   send_protocol:EncodeAndSend()
end

-- 跨服排行榜（单人）信息返回
function CrossRankCtrl:OnPersonCrossRankListAck(protocol)
	self.data:OnPersonCrossRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("rank_info")
	end
end

-- 跨服情侣榜协议返回
function CrossRankCtrl:OnSCGetCrossCoupleRankListAck(protocol)
	self.data:OnSCGetCrossCoupleRankListAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("rank_info")
	end
end

-- 跨服排行榜自己信息返回
function CrossRankCtrl:OnSCGetSpecialRankValueAck(protocol)
	self.data:OnSCGetSpecialRankValueAck(protocol)
	if self.view:IsOpen() then
		self.view:Flush("rank_info")
	end
end

-- 跨服排行榜查看个人信息返回
function CrossRankCtrl:OnGetRoleBaseInfoAck()
	if self.view:IsOpen() then
		self.view:Flush("model")
	end
end

function CrossRankCtrl:SetSelectTable(index)
	self.data:SetSelectTableIndex(index)
	self.view:Open()
end