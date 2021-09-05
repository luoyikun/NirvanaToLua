require("game/biaobaiqiang/biaobaiqiang_view")
require("game/biaobaiqiang/biaobaiqiang_data")
require("game/biaobaiqiang/biaobaiqiang_tips")
require("game/biaobaiqiang/biaobaiqiang_rank_view")
require("game/biaobaiqiang/gifteffect_view")

BiaoBaiQiangCtrl = BiaoBaiQiangCtrl or BaseClass(BaseController)
function BiaoBaiQiangCtrl:__init()
	if BiaoBaiQiangCtrl.Instance ~= nil then
		print_error("[BiaoBaiQiangCtrl] attempt to create singleton twice!")
		return
	end
	BiaoBaiQiangCtrl.Instance = self

	self:RegisterAllProtocols()
	self.view = BiaoBaiQiangView.New(ViewName.BiaoBaiQiang)
	self.data = BiaoBaiQiangData.New()
	self.tips_view = BiaoBaiQiangTips.New()
	self.rank_view = BiaoBaiRankView.New(ViewName.BiaoBaiRank)
	self.giaft_effect_view = GiftEffectView.New(ViewName.GiftEffectView)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function BiaoBaiQiangCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.tips_view ~= nil then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.rank_view ~= nil then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end
	
	BiaoBaiQiangCtrl.Instance = nil
end

function BiaoBaiQiangCtrl:MainuiOpenCreate()
	self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 0)
	self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 1)
	self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 2)
	self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_LEVEL_INFO)
end

function BiaoBaiQiangCtrl:RegisterAllProtocols()
	--公共告白墙信息
	self:RegisterProtocol(SCGlobalProfessWallInfo, "OnSCGlobalProfessWallInfo")
	--个人告白墙信息
	self:RegisterProtocol(SCPersonProfessWallInfo, "OnSCPersonProfessWallInfo")
	--表白特效
	self:RegisterProtocol(SCProfessWallEffect, "OnSCProfessWallEffect")
	--表白等级信息
	self:RegisterProtocol(SCProfessLevelInfo, "OnSCProfessLevelInfo")
	--排行榜活动
	self:RegisterProtocol(SCRAProfessRankInfo, "OnSCRAProfessRankInfo")
end

--公共告白墙信息
function BiaoBaiQiangCtrl:OnSCGlobalProfessWallInfo(protocol)
	self.data:CommonWallInfo(protocol)
	self.view:Flush("common")
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	if self.tips_view:IsOpen() then
		self.tips_view:Flush()
	end
end

--个人告白墙信息
function BiaoBaiQiangCtrl:OnSCPersonProfessWallInfo(protocol)
	self.data:PersonWallInfo(protocol)
	if protocol.profess_type == 1 then
		self.view:Flush("toself")
	elseif protocol.profess_type == 0 then
		self.view:Flush("self")
	end
	if self.tips_view:IsOpen() then
		self.tips_view:Flush()
	end
	local select_index = BiaoBaiQiangData.Instance:GetSelectindex()
	if protocol.notify_type == 1 and (not self.view:IsOpen() or select_index ~= 2 )then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BiaoBaiQiang, true)
	end
end

function BiaoBaiQiangCtrl:OpenNanShenRank()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		local role_vo = GameVoManager.Instance:GetMainRoleVo().sex 
		if role_vo == 1 then
			BiaoBaiQiangData.Instance:SetSelectindex(4)
			self.view:Open()
			if self.view:IsOpen() then
				self.view:Flush("nanshenrank")
			end
		else
			self:OpenNvShenRank()
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
	end
end

function BiaoBaiQiangCtrl:OpenMySelfBiaoBai()
	BiaoBaiQiangData.Instance:SetSelectindex(2)
	self.view:Open()
	if self.view:IsOpen() then
		self.view:Flush("toself")
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BiaoBaiQiang, false)
	end
end

function BiaoBaiQiangCtrl:OpenNvShenRank()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		BiaoBaiQiangData.Instance:SetSelectindex(5)
		self.view:Open()
		if self.view:IsOpen() then
			self.view:Flush("nvshenrank")
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GUILDJIUHUINOOPEN)
	end
end

--表白特效
function BiaoBaiQiangCtrl:OnSCProfessWallEffect(protocol)
	local bundle_name, asset_name
	if protocol.effect_type == 0 then
		bundle_name, asset_name = ResPath.GetMiscEffect("UI_xiangbing")
	elseif protocol.effect_type == 1 then
		bundle_name, asset_name = ResPath.GetMiscEffect("UI_chuan")
	elseif protocol.effect_type == 2 then
		bundle_name, asset_name = ResPath.GetMiscEffect("UI_huojian")
	end

	if bundle_name and asset_name then
		self.giaft_effect_view:SetData(bundle_name, asset_name, "biaobai_effect_add_loader")
		self.giaft_effect_view:Open()
	end
end

--表白等级信息
function BiaoBaiQiangCtrl:OnSCProfessLevelInfo(protocol)
	MarriageData.Instance:SetBiaoBaiInfo(protocol)
	local view = MarriageCtrl.Instance:GetMarriageView()
	if view:IsOpen() then
		view:Flush("biaobai")
	end
end

--表白墙排名信息
function BiaoBaiQiangCtrl:OnSCRAProfessRankInfo(protocol)
	self.data:SetMyRankInfo(protocol)
	if self.rank_view:IsOpen() then
		self.rank_view:Flush()
	end
	self.view:Flush("common")
end

--表白墙通用请求
function BiaoBaiQiangCtrl:SendProfessWallReq(oper_type, param1, param2, param3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSProfessWallReq)
	protocol.oper_type = oper_type or 0
	protocol.param_1 = param1 or 0
	protocol.param_2 = param2 or 0
	protocol.param_3 = param3 or 0
	protocol:EncodeAndSend()
end

--表白请求
function BiaoBaiQiangCtrl:SendProfessToReq(id, gift_id, is_auto_bug, content)
	local protocol = ProtocolPool.Instance:GetProtocol(CSProfessToReq)
	protocol.target_id = id
	protocol.gift_type = gift_id
	protocol.is_auto_buy = is_auto_bug
	protocol.contract_notice = content
	protocol:EncodeAndSend()
end

function BiaoBaiQiangCtrl:BiaoBaiQiangDelResult(protocol)
	if protocol.result == 1 then
		self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 0)
		self:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 1)
	end	
end

function BiaoBaiQiangCtrl:OpenTips()
	self.tips_view:Open()
end

function BiaoBaiQiangCtrl:FlushRankView()
	if self.rank_view:IsOpen() then
		self.rank_view:Flush()
	end
end