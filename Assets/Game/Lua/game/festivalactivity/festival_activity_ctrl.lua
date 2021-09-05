require("game/festivalactivity/festival_activity_data")
require("game/festivalactivity/festival_activity_view")
require("game/rewardlog/expense_nice_gift_reward_pool_view")
require("game/festivalactivity/festival_activity_sanbao/festivity_activity_sanbao_data")
require("game/festivalactivity/festival_activity_leichong/festival_activity_leichong_data")
require("game/festivalactivity/festival_activity_leichong/festival_activity_leichong_view")

FestivalActivityCtrl = FestivalActivityCtrl or BaseClass(BaseController)

function FestivalActivityCtrl:__init()
	if FestivalActivityCtrl.Instance ~= nil then
		print_error("[FestivalActivityCtrl] Attemp to create a singleton twice !")
	end

	FestivalActivityCtrl.Instance = self
	
	self.data = FestivalActivityData.New()
	self.view = FestivalActivityView.New(ViewName.FestivalView)
	self.sanbao_data = VersionThreePieceData.New()
	self.leichong_data = FestivalLeiChongData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.GetBanBenActivityRemind, self))
end

function FestivalActivityCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	FestivalActivityCtrl.Instance = nil
end

function FestivalActivityCtrl:GetView()
	return self.view
end

function FestivalActivityCtrl:RegisterAllProtocols()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.BANBEN_ACTIVITY) then
		self:OnKaifuActivityInfo()
	end

	-- 吉祥三宝
	self:RegisterProtocol(SCRATotalChargeFiveInfo, "OnSCRATotalChargeFiveInfo")
	-- 版本累计充值
	self:RegisterProtocol(SCRAVersionTotalChargeInfo, "OnSCRAVersionTotalChargeInfo")

end


function FestivalActivityCtrl:OnKaifuActivityInfo()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end


function FestivalActivityCtrl:FlushKaifuView()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

--关闭界面
function FestivalActivityCtrl:CloseKaiFuView()
	self.view:Close()
end

-- 登陆豪礼
function FestivalActivityCtrl:FlushLoginReward()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:Flush()
	self.view:FlushLoginReward()
end


function FestivalActivityCtrl:FlushFengKuangYaoJiang()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushFengKuangYaoJiang()
	end
end

--单身伴侣
function FestivalActivityCtrl:FlushMakeMoonCake()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushMakeMoonCake()
	end
end

function FestivalActivityCtrl:FlushDailyGiftView()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushDailyGiftView()
	end
end

function FestivalActivityCtrl:FlushHappyDanBiChongZhi()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:FlushHappyDanBiChongZhi()
end 


function FestivalActivityCtrl:FlushDailyDanBi()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:FlushDailyDanBi()
end

--连续充值
function FestivalActivityCtrl:FlushLianXuChongZhi()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:FlushLianXuChongZhi()
end

-- 吹气球排行榜
function FestivalActivityCtrl:FlushChuiQiQiuRank()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:FlushChuiQiQiuRank()
end

-- 放飞气球排行榜
function FestivalActivityCtrl:FlushFangFeiQiQiuRank()
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	self.view:FlushFangFeiQiQiuRank()
end

--吉祥三宝--
function FestivalActivityCtrl:OnSCRATotalChargeFiveInfo(protocol)
	self.sanbao_data:SetSanBaoInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushVersionThreePiece()
	end
end

--吃鸡盛宴
function FestivalActivityCtrl:FlushFestivalSingleParty()
	self.view:Flush()
	self.view:FlushFestivalSingleParty()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
end

--极限挑战
function FestivalActivityCtrl:FlushExtremeChallenge()
	self.view:Flush()
	self.view:FlushExtremeChallenge()
	RemindManager.Instance:Fire(RemindName.Festival_Act)
end

-- 刷新狂嗨庆典
function FestivalActivityCtrl:FlushCrazyHiCelebrationView()
	if self.view:IsOpen() then
		self.view:FlushCrazyHiCelebrationView()
	end
end

-- 刷新礼物收割
function FestivalActivityCtrl:FlushChristmaGiftView()
	if self.view:IsOpen() then
		self.view:FlushChristmaGiftView()
	end
end

function FestivalActivityCtrl:SendGetSanBaoActivityInfo()
	if IS_ON_CROSSSERVER then
		return
	end
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRATotalChargeFiveInfo)
	protocol:EncodeAndSend()
end

--版本累充--
function FestivalActivityCtrl:OnSCRAVersionTotalChargeInfo(protocol)
	self.leichong_data:SetFesLeiChongInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Festival_Act)
	if self.view:IsOpen() then
		self.view:Flush()
		self.view:FlushBanBenLeiChong()
	end

	-- RemindManager.Instance:Fire(RemindName.VesLeiChongRemind)
end

function FestivalActivityCtrl:GetBanBenActivityRemind()
	if self.data then
		self.data:GetBanBenActivityRemind()
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK, 0)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK, 0)
end

