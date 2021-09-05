require("game/exchange/exchange_data")
require("game/exchange/exchange_view")
require("game/exchange/exchange_tips_view")
require("game/exchange/yihuo_exchange_view")
require("game/exchange/yushi_exchange_view")

ExchangeCtrl = ExchangeCtrl or BaseClass(BaseController)
function ExchangeCtrl:__init()
	if ExchangeCtrl.Instance then
		print_error("[ExchangeCtrl] Attemp to create a singleton twice !")
	end
	ExchangeCtrl.Instance = self
	self.data = ExchangeData.New()
	self.view = ExchangeView.New(ViewName.Exchange)
	self.yihuo_exchange_view = YiHuoExchangeView.New(ViewName.YiHuoExchange)
	self.yushi_exchange_view = YuShiExchangeView.New(ViewName.YuShiExchangeView)
	self.tips_view = ExchangeTipView.New(ViewName.ExchangeTip)
	self:RegisterAllProtocols()
	self.score_change_callback_list = {}
end

function ExchangeCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.yihuo_exchange_view then
		self.yihuo_exchange_view:DeleteMe()
		self.yihuo_exchange_view = nil
	end

	if self.yushi_exchange_view then
		self.yushi_exchange_view:DeleteMe()
		self.yushi_exchange_view = nil
	end

	if self.tips_view then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end
	self.score_change_callback_list = {}
	ExchangeCtrl.Instance = nil
end

function ExchangeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendScoreInfo,"OnScoreInfo")
	self:RegisterProtocol(SCSendScoreInfoNotice,"OnScoreNotice")
	self:RegisterProtocol(SCConvertRecordInfo, "OnConvertRecordInfo")
end

function ExchangeCtrl:GetExchangeContentView()
	self.view:GetExchangeContentView()
end

--请求购买物品
function ExchangeCtrl:SendCSShopBuy(item_id, item_num, is_bind, is_use, reserve_ch1, reserve_ch2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShopBuy)
	protocol.scoretoitem_type = conver_type
	protocol.item_id = item_id or 0
	protocol.item_num = item_num or 0
	protocol.is_bind = is_bind or 0
	protocol.is_use = is_use or 0
	protocol.reserve_ch1 = reserve_ch1 or 0
	protocol.reserve_ch2 = reserve_ch2 or 0
	protocol:EncodeAndSend()
end

function ExchangeCtrl:OnConvertRecordInfo(protocol)
	local old_count = self.data:GetLifeTimeRecordCount()
	self.data:OnConvertRecordInfo(protocol)
	local new_count = self.data:GetLifeTimeRecordCount()
	local treasure_view = TreasureCtrl.Instance:GetView()
	if self.view:IsOpen() then
		self.view:ShowXianShi()
		self.view:Flush("xianshi_tab")
		local exchange_content_view = self.view:GetExchangeContentView()
		if exchange_content_view then
			if new_count > old_count then
				exchange_content_view:OnFlushListView()
			else
				exchange_content_view:FlushAllFrame()
			end
		end
	end

	local arena_view = ArenaCtrl.Instance:GetArenaActivityView()
	if arena_view:IsOpen() then
		ArenaCtrl.Instance:ShowXianShi()
		local arena_exchange_content_view = ArenaCtrl.Instance:GetExchangeContentView()
		if arena_exchange_content_view then
			if new_count > old_count then
				arena_exchange_content_view:OnFlushListView()
			else
				arena_exchange_content_view:FlushAllFrame()
			end
		end	
	end	
	if self.tips_view:IsOpen() and self.tips_view:IsLoaded() then
		self.tips_view:Flush()
	end
	if treasure_view:IsOpen() then
		treasure_view:Flush("exchange")
	end

	-- 主界面图标
	MainUICtrl.Instance:GetView():ShowXianShiDuiHuan()
	PlayerCtrl.Instance:FlushXunBaoActBtn()
end

function ExchangeCtrl:OnScoreInfo(protocol)
	self.data:OnScoreInfo(protocol)
	TreasureData.Instance:SetTreasureScore(protocol.chest_shop_treasure_credit)
	TreasureData.Instance:SetTreasureScore1(protocol.chest_shop_treasure_credit1)
	TreasureData.Instance:SetTreasureScore2(protocol.chest_shop_treasure_credit2)

	if self.view:IsOpen() then
		local exchange_content_view = self.view:GetExchangeContentView()
		if exchange_content_view then
			exchange_content_view:FlushCoin()
		end
	end

	if self.yihuo_exchange_view:IsOpen() then
		self.yihuo_exchange_view:Flush()
	end

	if self.yushi_exchange_view:IsOpen() then
		self.yushi_exchange_view:Flush()
	end

	local arena_view = ArenaCtrl.Instance:GetArenaActivityView()
	if arena_view:IsOpen() then
		local arena_exchange_content_view = ArenaCtrl.Instance:GetExchangeContentView()
		if arena_exchange_content_view then
			arena_exchange_content_view:FlushCoin()
		end	
	end		

	BossData.Instance:SetSecretExchangeValue(protocol.chest_shop_precious_boss_score)
	ViewManager.Instance:FlushView(ViewName.SecretBossFightView)

	if self.tips_view:IsOpen() and self.tips_view:IsLoaded() then
		self.tips_view:Flush()
	end
	local treasure_view = TreasureCtrl.Instance:GetView()
	if treasure_view:IsOpen() then
		treasure_view:Flush("exchange")
	end

	self:DoNotify()
	-- 精灵积分
	
	SpiritData.Instance:SetSpiritExchangeScore(protocol.chest_shop_jingling_credit)
	self.view:Flush()

	RemindManager.Instance:Fire(RemindName.ForgeUpStar)
	RemindManager.Instance:Fire(RemindName.Echange)
	RemindManager.Instance:Fire(RemindName.PlayerActiveSkill)

	if HunQiCtrl.Instance.hunyin_resolve_view:IsOpen() then
		HunQiCtrl.Instance.hunyin_resolve_view:Flush("lingzhi")
	end
	if ArenaCtrl.Instance.arena_activity_view then
		ArenaCtrl.Instance.arena_activity_view:Flush()
	end
	if KFArenaCtrl.Instance.kf_arena_activity_view then
		KFArenaCtrl.Instance.kf_arena_activity_view:Flush()
	end

	HunQiCtrl.Instance:FlushBaoZangView() -- 刷新异火界面
end

function ExchangeCtrl:OnScoreNotice(protocol)
	-- local score_list = self.data:GetScoreList()
	local msg = ""
	-- if not next(score_list) then
	if protocol.chest_shop_mojing > 0 then
		msg = string.format(Language.SysRemind.AddMoJing, protocol.chest_shop_mojing)
	elseif protocol.chest_shop_shengwang > 0 then
		msg = string.format(Language.SysRemind.AddShengWang, protocol.chest_shop_shengwang)
	elseif protocol.chest_shop_gongxun > 0 then
		msg = string.format(Language.SysRemind.AddGongxun, protocol.chest_shop_gongxun)
	elseif protocol.chest_shop_weiwang > 0 then
		msg = string.format(Language.SysRemind.AddWeiWang, protocol.chest_shop_weiwang)
	elseif protocol.chest_shop_treasure_credit > 0 then
		msg = string.format(Language.SysRemind.AddTreasure, protocol.chest_shop_treasure_credit)
	elseif protocol.chest_shop_treasure_credit1 > 0 then
		msg = string.format(Language.SysRemind.AddTreasure1, protocol.chest_shop_treasure_credit1)
	elseif protocol.chest_shop_treasure_credit2 > 0 then
		msg = string.format(Language.SysRemind.AddTreasure2, protocol.chest_shop_treasure_credit2)				
	elseif protocol.chest_shop_jingling_credit > 0 then
		msg = string.format(Language.SysRemind.AddJingLing, protocol.chest_shop_jingling_credit)
	elseif protocol.chest_shop_happytree_grow > 0 then
		msg = string.format(Language.SysRemind.AddHappyTree, protocol.chest_shop_happytree_grow)
	elseif protocol.chest_shop_precious_boss_score > 0 then
		msg = string.format(Language.SysRemind.AddBossScore,protocol.chest_shop_precious_boss_score)
	elseif protocol.chest_shop_hunjing > 0 then
		msg = string.format(Language.SysRemind.AddHunJing,protocol.chest_shop_hunjing)
	end
	-- else
	-- 	if protocol.chest_shop_mojing > score_list[EXCHANGE_PRICE_TYPE.MOJING] then
	-- 		msg = string.format(Language.SysRemind.AddMoJing, protocol.chest_shop_mojing - score_list[EXCHANGE_PRICE_TYPE.MOJING])
	-- 	elseif protocol.chest_shop_shengwang > score_list[EXCHANGE_PRICE_TYPE.SHENGWANG] then
	-- 		msg = string.format(Language.SysRemind.AddShengWang, protocol.chest_shop_shengwang - score_list[EXCHANGE_PRICE_TYPE.SHENGWANG])
	-- 	elseif protocol.chest_shop_gongxun > score_list[EXCHANGE_PRICE_TYPE.GONGXUN] then
	-- 		msg = string.format(Language.SysRemind.AddGongxun, protocol.chest_shop_gongxun - score_list[EXCHANGE_PRICE_TYPE.GONGXUN])
	-- 	elseif protocol.chest_shop_weiwang > score_list[EXCHANGE_PRICE_TYPE.WEI_WANG] then
	-- 		msg = string.format(Language.SysRemind.AddWeiWang, protocol.chest_shop_weiwang - score_list[EXCHANGE_PRICE_TYPE.WEI_WANG])
	-- 	elseif protocol.chest_shop_treasure_credit > score_list[EXCHANGE_PRICE_TYPE.TREASURE] then
	-- 		msg = string.format(Language.SysRemind.AddTreasure, protocol.chest_shop_treasure_credit - score_list[EXCHANGE_PRICE_TYPE.TREASURE])
	-- 	elseif protocol.chest_shop_jingling_credit > score_list[EXCHANGE_PRICE_TYPE.JINGLING] then
	-- 		msg = string.format(Language.SysRemind.AddJingLing, protocol.chest_shop_jingling_credit - score_list[EXCHANGE_PRICE_TYPE.JINGLING])
	-- 	elseif protocol.chest_shop_happytree_grow > score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE] then
	-- 		msg = string.format(Language.SysRemind.AddHappyTree, protocol.chest_shop_happytree_grow - score_list[EXCHANGE_PRICE_TYPE.HAPPYTREE])
	-- 	end
	-- end
	TipsCtrl.Instance:ShowFloatingLabel(msg)

	self.data:SetLingzhi(protocol)
	if HunQiCtrl.Instance.hunyin_exchange_view:IsOpen() then
		HunQiCtrl.Instance.hunyin_exchange_view:FlushLingzhiCount()
	end
	if ViewManager.Instance:IsOpen(ViewName.DouQiView) and protocol.chest_shop_mojing > 0 then
		DouQiCtrl.Instance:FlushEuqipView()
	end
end

--消耗积分兑换物品请求
function ExchangeCtrl:SendScoreToItemConvertReq(conver_type, seq, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	protocol.scoretoitem_type = conver_type
	protocol.index = seq
	protocol.num = num
	protocol:EncodeAndSend()
end

--兑换记录信息请求
function ExchangeCtrl:SendGetConvertRecordInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetConvertRecordInfo)
	protocol:EncodeAndSend()
end

--获取积分数量请求
function ExchangeCtrl:SendGetSocreInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSocreInfoReq)
	protocol:EncodeAndSend()
end

--注册积分改变回调
function ExchangeCtrl:NotifyWhenScoreChange(callback)
	self.score_change_callback_list[callback] = callback
end

--取消积分改变回调
function ExchangeCtrl:UnNotifyWhenScoreChange(callback)
	self.score_change_callback_list[callback] = nil
end

--积分改变回调
function ExchangeCtrl:DoNotify()
	for k,v in pairs(self.score_change_callback_list) do
		v()
	end
end

function ExchangeCtrl:ShowExchangeView(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	self.tips_view:SetItemId(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	self.tips_view:Open()
end

function ExchangeCtrl:FlushExchangeView()
	if self.view ~= nil and self.view:IsOpen() then
		self.view:Flush()
	end

	if self.tips_view ~= nil and self.tips_view:IsOpen() then
		self.tips_view:Flush()
	end
end