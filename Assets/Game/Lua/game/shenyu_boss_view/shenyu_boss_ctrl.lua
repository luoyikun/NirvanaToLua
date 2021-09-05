require("game/shenyu_boss_view/shenyu_boss_view")
require("game/shenyu_boss_view/shenyu_boss_data")
require("game/shenyu_boss_view/cross_mizang_boss_info_view")
require("game/shenyu_boss_view/cross_youming_boss_info_view")
require("game/boss/boss_godmagic_fight_view")

ShenYuBossCtrl = ShenYuBossCtrl or BaseClass(BaseController)

function ShenYuBossCtrl:__init()
	if ShenYuBossCtrl.Instance ~= nil then
		ErrorLog("[ShenYuBossCtrl] attempt to create singleton twice!")
		return
	end
	ShenYuBossCtrl.Instance = self
	self.shenyu_boss_data = ShenYuBossData.New()
	self.shenyu_boss_view = ShenYuBossView.New(ViewName.ShenYuBossView)
	self.cross_mizang_info_view = CrossMiZangBossInfoView.New(ViewName.CrossMiZangBossInfoView)
	self.cross_youming_info_view = CrossYouMingBossInfoView.New(ViewName.CrossYouMingBossInfoView)
	self.godmagic_fight_view = BossGodMagicFightView.New(ViewName.BossGodMagicFightView)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.TipHiddenAppearance, self))
end

function ShenYuBossCtrl:__delete()
	if self.shenyu_boss_view then
		self.shenyu_boss_view:DeleteMe()
		self.shenyu_boss_view = nil
	end

	if self.shenyu_boss_data then
		self.shenyu_boss_data:DeleteMe()
		self.shenyu_boss_data = nil
	end

	if self.cross_mizang_info_view then
		self.cross_mizang_info_view:DeleteMe()
		self.cross_mizang_info_view = nil
	end

	if self.cross_youming_info_view then
		self.cross_youming_info_view:DeleteMe()
		self.cross_youming_info_view = nil
	end

	if self.godmagic_fight_view then
		self.godmagic_fight_view:DeleteMe()
		self.godmagic_fight_view = nil
	end

	ShenYuBossCtrl.Instance = nil
end

-- 协议注册
function ShenYuBossCtrl:RegisterAllProtocols()
	-- 秘藏Boss
	self:RegisterProtocol(SCCrossMiZangBossPlayerInfo, "OnCrossMiZangBossPlayerInfo")		-- 玩家信息
	self:RegisterProtocol(SCCrossMizangBossSceneInfo, "OnCrossMiZangBossSceneInfo")			-- 场景内信息
	self:RegisterProtocol(SCMiZangBossReliveTire, "OnCrossMiZangBossReliveTire") 			-- 复活疲劳
	self:RegisterProtocol(SCCrossMizangBossBossInfoAck, "OnCrossMiZangBossBossInfoAck") 	-- 跨服boss信息
	self:RegisterProtocol(CSCrossMiZangBossBossInfoReq) 

	--幽冥Boss
	self:RegisterProtocol(SCCrossYouMingBossPlayerInfo, "OnCrossYouMingBossPlayerInfo")		-- 玩家信息
	self:RegisterProtocol(SCCrossYouMingBossSceneInfo, "OnCrossYouMingBossSceneInfo")			-- 场景内信息
	self:RegisterProtocol(SCYouMingBossReliveTire, "OnCrossYouMingBossReliveTire") 			-- 复活疲劳
	self:RegisterProtocol(SCCrossYouMingBossBossInfoAck, "OnCrossYouMingBossBossInfoAck") 	-- 跨服boss信息
	self:RegisterProtocol(CSCrossYouMingBossBossInfoReq)

	--神魔Boss
	self:RegisterProtocol(SCGodmagicBossPlayerInfo, "OnSCGodmagicBossPlayerInfo")		-- 玩家信息
	self:RegisterProtocol(SCGodmagicBossSceneInfo, "OnSCGodmagicBossSceneInfo")			-- 场景内信息
	self:RegisterProtocol(SCGodmagicBossInfoAck, "OnSCGodmagicBossInfoAck") 	-- 神魔boss信息
	self:RegisterProtocol(CSGodmagicBossInfoReq)
end

function ShenYuBossCtrl:GetView()
	if self.shenyu_boss_view then
		return self.shenyu_boss_view
	end
end

function ShenYuBossCtrl:SetBossDisPlay(boss_data)
	if self.shenyu_boss_view:IsOpen() then
		self.shenyu_boss_view:FlushDisPlayModel(boss_data)
	end
end

function ShenYuBossCtrl:SetBoxDisPlay(bundle, asset, res_id)
	if self.shenyu_boss_view:IsOpen() then
		self.shenyu_boss_view:FlushDisPlayModelBox(bundle, asset, res_id)
	end
end

function ShenYuBossCtrl:SetBossTujianDisPlay(boss_data)
	if self.shenyu_boss_view:IsOpen() then
		self.shenyu_boss_view:FlushTuJianDisPlayModel(boss_data)
	end
end

function ShenYuBossCtrl:TipHiddenAppearance()
	BossCtrl.Instance:SendBossTuJianReq(BOSS_CARD_OPERA_TYPE.BOSS_CARD_OPERA_TYPE_ALL_INFO)
end

--请求跨服秘藏boss信息
function ShenYuBossCtrl:SendCrossMiZangBossBossInfoReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossMiZangBossBossInfoReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param1 or 0
	protocol.param_2 = param2 or 0
	protocol:EncodeAndSend()
end

function ShenYuBossCtrl:OnCrossMiZangBossPlayerInfo(protocol)
	self.shenyu_boss_data:SetCrossBossPalyerInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("secret_boss")
	end
	if self.cross_mizang_info_view then
		self.cross_mizang_info_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenYu_Secret)
	RemindManager.Instance:Fire(RemindName.ShenYuBoss)
end

function ShenYuBossCtrl:OnCrossMiZangBossSceneInfo(protocol)
	self.shenyu_boss_data:SetCrossBossSceneInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("secret_boss")
	end
	if self.cross_mizang_info_view then
		self.cross_mizang_info_view:Flush()
	end
end

function ShenYuBossCtrl:OnCrossMiZangBossReliveTire(protocol)
	self.shenyu_boss_data:SetCrossBossWeary(protocol)
end

function ShenYuBossCtrl:OnCrossMiZangBossBossInfoAck(protocol)
	self.shenyu_boss_data:SetCrossBossBossInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("secret_boss")
	end
	if self.cross_mizang_info_view then
		self.cross_mizang_info_view:Flush()
	end
end

--请求跨服幽冥boss信息
function ShenYuBossCtrl:SendCrossYouMingBossBossInfoReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossYouMingBossBossInfoReq)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param1 or 0
	protocol.param_2 = param2 or 0
	protocol:EncodeAndSend()
end

function ShenYuBossCtrl:OnCrossYouMingBossPlayerInfo(protocol)
	self.shenyu_boss_data:SetCrossYouMingBossPalyerInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("youming_boss")
	end
	if self.cross_youming_info_view then
		self.cross_youming_info_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenYu_YouMing)
	RemindManager.Instance:Fire(RemindName.ShenYuBoss)
end

function ShenYuBossCtrl:OnCrossYouMingBossSceneInfo(protocol)
	self.shenyu_boss_data:SetCrossYouMingBossSceneInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("youming_boss")
	end
	if self.cross_youming_info_view then
		self.cross_youming_info_view:Flush()
	end
end

function ShenYuBossCtrl:OnCrossYouMingBossReliveTire(protocol)
	self.shenyu_boss_data:SetCrossYouMingBossWeary(protocol)
end

function ShenYuBossCtrl:OnCrossYouMingBossBossInfoAck(protocol)
	self.shenyu_boss_data:SetCrossYouMingBossBossInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("youming_boss")
	end
	if self.cross_youming_info_view then
		self.cross_youming_info_view:Flush()
	end
end

function ShenYuBossCtrl:OnSCGodmagicBossSceneInfo(protocol)
	self.shenyu_boss_data:SetGodMagicBossSceneInfo(protocol)
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("godmagic_boss")
	end
	self.godmagic_fight_view:Flush()
end

function ShenYuBossCtrl:OnSCGodmagicBossInfoAck(protocol)
	self.shenyu_boss_data:SetGodMagicBossBossInfo(protocol)
	self.godmagic_fight_view:Flush()
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("godmagic_boss")
	end
end

--请求神魔boss信息
function ShenYuBossCtrl:SendGodMagicBossBossInfoReq(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGodmagicBossInfoReq)
	protocol.req_type = opera_type or 0
	protocol.param_1 = param1 or 0
	protocol.param_2 = param2 or 0
	protocol:EncodeAndSend()
end

function ShenYuBossCtrl:OnSCGodmagicBossPlayerInfo(protocol)
	self.shenyu_boss_data:SetGodmagicBossPalyerInfo(protocol)
	-- self.view:Flush("kf_boss")
	if self.shenyu_boss_view then
		self.shenyu_boss_view:Flush("godmagic_boss")
	end
	self.godmagic_fight_view:Flush()
	RemindManager.Instance:Fire(RemindName.ShenYu_Godmagic)
end