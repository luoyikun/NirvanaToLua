require("game/gift_limit_buy/gift_limit_buy_data")
require("game/gift_limit_buy/gift_limit_buy_view")

GiftLimitBuyCtrl = GiftLimitBuyCtrl or BaseClass(BaseController)

function GiftLimitBuyCtrl:__init()
	if GiftLimitBuyCtrl.Instance then
		print_error("[GiftLimitBuyCtrl]:Attempt to create singleton twice!")
	end
	GiftLimitBuyCtrl.Instance = self

	self.view = GiftLimitBuyView.New(ViewName.GiftLimitBuy)
	self.data = GiftLimitBuyData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendRAOpenGameGiftShopBuyInfo, self))
end

function GiftLimitBuyCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	GiftLimitBuyCtrl.Instance = nil
end

function GiftLimitBuyCtrl:RegisterAllProtocols()
	-- 礼包限购协议信息
	self:RegisterProtocol(SCRAOpenGameGiftShopBuy2Info, "OnRAOpenGameGiftShopBuyInfo")
end

-- 购买礼包
function GiftLimitBuyCtrl:SendRAOpenGameGiftShopBuy(seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuy2)
	protocol.opera_type = 1
	protocol.seq = seq or 0
	protocol:EncodeAndSend()
end

-- 请求礼包信息
function GiftLimitBuyCtrl:SendRAOpenGameGiftShopBuyInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRAOpenGameGiftShopBuy2)
	protocol.opera_type = 0
	protocol:EncodeAndSend()
end

-- 设置限购礼包信息
function GiftLimitBuyCtrl:OnRAOpenGameGiftShopBuyInfo(protocol)
	self.data:SetGiftShopFlag(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.GiftLimitBuy)
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, "GiftLimitBuy")
end
