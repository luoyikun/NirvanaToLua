require("game/festivalactivity/festival_single_party/festival_single_party_data")
require("game/festivalactivity/festival_single_party/single_party_info_guard_view")
require("game/festivalactivity/festival_single_party/festival_single_party_view")

FestivalSinglePartyCtrl = FestivalSinglePartyCtrl or BaseClass(BaseController)
function FestivalSinglePartyCtrl:__init()
	if nil ~= FestivalSinglePartyCtrl.Instance then
		print_error("[FestivalSinglePartyCtrl] Attemp to create a singleton twice !")
		return
	end
	FestivalSinglePartyCtrl.Instance = self
	self.guard_info_view = SinglePartyInfoGuardView.New(ViewName.SinglePartyInfoView)
	self.data = FestivalSinglePartyData.New()
	self:RegisterAllProtocols()
end

function FestivalSinglePartyCtrl:__delete()
	FestivalSinglePartyCtrl.Instance = nil
	if self.data then
		self.data:DeleteMe()
	end
	if self.guard_info_view then
		self.guard_info_view:DeleteMe()
		self.guard_info_view = nil
	end
end

function FestivalSinglePartyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHolidayGuardRoleInfo, "OnHolidayGuardRoleInfo")
	self:RegisterProtocol(SCHolidayGuardInfo, "OnHolidayGuardInfo")
	self:RegisterProtocol(SCHolidayGuardFBDropInfo, "OnHolidayGuardFBDropInfo")  -- 副本怪物掉落统计
	self:RegisterProtocol(SCHolidayGuardResult, "OnHolidayGuardResult")
	self:RegisterProtocol(SCHolidayGuardWarning, "OnHolidayGuardWarning")  --个人塔防警告
	-- 单身派对排行榜
	self:RegisterProtocol(SCRAHolidayGuardRanKInfo, "OnRAHolidayGuardRaNKInfo")
	-- -- 被动变身榜
	-- self:RegisterProtocol(SCRASpecialAppearancePassiveInfo, "OnRASpecialAppearancePassiveInfo")
end

-----------------
--单身派对

-------------
--个人塔防角色信息
function FestivalSinglePartyCtrl:OnHolidayGuardRoleInfo(protocol)
	self.data:SetEnterSinglePartyTimes(protocol)
	self.guard_info_view:Flush()
end

--个人塔防信息
function FestivalSinglePartyCtrl:OnHolidayGuardInfo(protocol)
	self.data:SetSinglePartyInfo(protocol)
	self.guard_info_view:Flush()
end

--个人塔防掉落
function FestivalSinglePartyCtrl:OnHolidayGuardFBDropInfo(protocol)
	self.data:SetSinglePartyDropInfo(protocol)
end

-- --个人塔防结果
function FestivalSinglePartyCtrl:OnHolidayGuardResult(protocol)
	self.data:SetSinglePartyResultInfo(protocol)
	local cfg = FestivalSinglePartyData.Instance:GetSinglePartyOtherCfg()
	if cfg == nil then return end
	local reward_data = cfg.leave_fb_reward
	local can_fetch_count = cfg.everyday_can_fetch_reward_count
	local join_times = FestivalSinglePartyData.Instance:GetEnterSinglePartyTimes()
	if join_times > can_fetch_count then
		reward_data = {}
	end
	-- if self.data:GetIsPassed() then
		ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finishout", {data = reward_data})
	-- else
	-- 	ViewManager.Instance:Open(ViewName.FBFailFinishView)
	-- end
end

--个人塔防警告
function FestivalSinglePartyCtrl:OnHolidayGuardWarning(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	if protocol.warning_type == 1 then
		FuBenData.Instance:SetTowerIsWarning(true)
		if scene_type == SceneType.SingleParty then
			SysMsgCtrl.Instance:ErrorRemind(Language.SingleParty.TowerBeHurt2)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.SingleParty.TowerBeHurt)
		end
	else
		if scene_type == SceneType.SingleParty then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.SingleParty.TowerHpTooLess2, protocol.percent .. "%"))
		else
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.SingleParty.TowerHpTooLess, protocol.percent .. "%"))
		end
	end
end

--单身派对操作请求
function FestivalSinglePartyCtrl:SendHolidayGuardRoleReq(req_type)   
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHolidayGuardRoleReq)
	send_protocol.req_type = req_type
	send_protocol:EncodeAndSend()
end
--排行榜信息请求
function FestivalSinglePartyCtrl:SendHolidayGuardRankInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRAHolidayGuardRankInfoReq)
	send_protocol:EncodeAndSend()
end

function FestivalSinglePartyCtrl:OnRAHolidayGuardRaNKInfo(protocol)
	self.data:SetSpecialAppearanceInfo(protocol)
	FestivalActivityCtrl.Instance:FlushFestivalSingleParty()
end

function FestivalSinglePartyCtrl:AskEnterSingleParty()
	local call_back = function ()
		self.is_click_ok = true
		local x, y = MoveCache.target_obj:GetLogicPos()
		local npc_index = FestivalSinglePartyData.Instance:GetNpcIndexByPosition(x,y)
		local level = FestivalSinglePartyData.Instance:GetCurrentLevel()
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, level, 1, npc_index)
	end
	TipsCtrl.Instance:ShowCommonAutoView("enter_single_party", Language.SingleParty.AskReturn, call_back, nil, nil, nil, nil, nil, true, true)
end