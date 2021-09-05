require("game/kf_month_black_wind_high/kf_month_black_wind_high_data")
require("game/kf_month_black_wind_high/kf_month_black_wind_high_view")

KFMonthBlackWindHighCtrl = KFMonthBlackWindHighCtrl or  BaseClass(BaseController)

function KFMonthBlackWindHighCtrl:__init()
	if KFMonthBlackWindHighCtrl.Instance ~= nil then
		print_error("[KFMonthBlackWindHighCtrl] attempt to create singleton twice!")
		return
	end
	KFMonthBlackWindHighCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = KFMonthBlackWindHighData.New()
	self.view = KFMonthBlackWindHighView.New(ViewName.KFMonthBlackWindHigh)
	self.target_boss_info = {}
end

function KFMonthBlackWindHighCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	KFMonthBlackWindHighCtrl.Instance = nil
end

function KFMonthBlackWindHighCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSCrossDarkNightRankOpera)
	self:RegisterProtocol(SCCrossDarkNightUserInfo, "OnSCCrossDarkNightUserInfo")
	self:RegisterProtocol(SCCrossDarkNightRankInfo, "OnSCCrossDarkNightRankInfo")
	self:RegisterProtocol(SCCrossDarkNightBossInfo, "OnSCCrossDarkNightBossInfo")
	self:RegisterProtocol(SCCrossDarkNightPlayerInfoBroadcast, "OnSCCrossDarkNightPlayerInfoBroadcast")
	self:RegisterProtocol(SCCrossDarkNightRewardTimestampInfo, "OnSCCrossDarkNightRewardTimestampInfo")
	self:RegisterProtocol(SCCrossDarkNightTopPlayerPosi, "OnSCCrossDarkNightTopPlayerPosi")
end

function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightUserInfo(protocol)
	self.data:SetFollowNum(protocol.box_count)
	self.data:SetCrossDarkNightUserInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	if protocol.is_finish == 1 then
		local data = self.data:GetActivityEndRewardList()
		if data then
			TipsCtrl.Instance:OpenActivityEndView(data)
		end
	end
end

function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightRankInfo(protocol)
	self.data:SetCrossDarkNightRankInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightBossInfo(protocol)
	self.data:SetCrossDarkNightBossInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
		ViewManager.Instance:FlushView(ViewName.FbIconView, "boss_list")
	end
end

function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightPlayerInfoBroadcast(protocol)
	self.data:SetCrossDarkNightPlayerInfoBroadcast(protocol)
end

function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightRewardTimestampInfo(protocol)
	self.data:SetCrossDarkNightRewardTimestampInfo(protocol)
	FuBenCtrl.Instance:FlushFbIconView()
end

--返回榜首的位置
function KFMonthBlackWindHighCtrl:OnSCCrossDarkNightTopPlayerPosi(protocol)
	-- 如果第一名是自己
	GuajiCtrl.Instance:CancelSelect()
	GuajiCtrl.Instance:ClearAllOperate()
	if protocol.obj_id == Scene.Instance:GetMainRole():GetObjId() then
		SysMsgCtrl.Instance:ErrorRemind(Language.MonthBlackWindHigh.YouAreFirst)
		self.is_follow = false
		GuajiCtrl.Instance:StopGuaji()
	end
	if self.is_follow then
		if nil ~= Scene.Instance:GetObj(protocol.obj_id) then
			local vo = Scene.Instance:GetObj(protocol.obj_id):GetVo()
			MoveCache.param1 = vo.role_id or 0
			GuajiCache.monster_id = 0
			MoveCache.target_obj = Scene.Instance:GetObj(protocol.obj_id)
			GuajiCache.target_obj = Scene.Instance:GetObj(protocol.obj_id)
			MoveCache.end_type = MoveEndType.AttackTarget
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), protocol.pos_x, protocol.pos_y, 3, 1)
		else
			MoveCache.end_type = MoveEndType.AttackTarget
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), protocol.pos_x, protocol.pos_y, 3, 1)
		end
	end
end

--请求榜首的信息
function KFMonthBlackWindHighCtrl:SendFirstPos()
	self.is_follow = true
	self:SendFirstPosReq()
end

function KFMonthBlackWindHighCtrl:SendFirstPosReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossDarkNightRankOpera)
	protocol.opera_type = 0
	protocol:EncodeAndSend()
end

function KFMonthBlackWindHighCtrl:MoveToBoss()
	self.view:MonsterClickCallBack()
end