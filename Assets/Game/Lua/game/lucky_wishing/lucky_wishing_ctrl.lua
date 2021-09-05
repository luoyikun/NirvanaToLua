
require("game/lucky_wishing/lucky_wishing_data")
require("game/lucky_wishing/lucky_wishing_view")

LuckWishingCtrl = LuckWishingCtrl or BaseClass(BaseController)

function LuckWishingCtrl:__init()
	if nil ~= LuckWishingCtrl.Instance then
		print_error("[LuckWishingCtrl] attempt to create singleton twice!")
		return
	end
	LuckWishingCtrl.Instance = self
	self.data = LuckWishingData.New()
	self.view = LuckWishingView.New(ViewName.LuckWishingView)
	self:RegisterAllProtocols()
	self:RegisterAllHandlers()

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self.type = CHEST_SHOP_MODE.CHEST_LUCKYWISHIN_MODE_1

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.LuckWishing)
end

function LuckWishingCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	LuckWishingCtrl.Instance = nil
end

function LuckWishingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCLuckyWishInfo, "OnSCLuckyWishInfo")
	self:RegisterProtocol(CSLuckyWishOpera)
end

function LuckWishingCtrl:RegisterAllHandlers()

end

-- 打开主窗口
function LuckWishingCtrl:Open()
	self.view:Open()
end

-- 刷新面板
function LuckWishingCtrl:OnSCLuckyWishInfo(protocol)
	self.data:UpdateInfoData(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if protocol.type ~= LUCKY_WISH_TYPE.LUCKY_WISH_TYPE_ONLY_LUCKY_VALUE then
		TipsCtrl.Instance:ShowTreasureView(LuckWishingData.Instance:GetChestShopMode())
	end
	RemindManager.Instance:Fire(RemindName.LuckWishing)
end

function LuckWishingCtrl:SendAllInfoReq(send_type, param_1) 
	local protocol = ProtocolPool.Instance:GetProtocol(CSLuckyWishOpera)
	protocol.type = send_type or 0
	protocol.param_1 = param_1 or 0
	protocol:EncodeAndSend()
end

function LuckWishingCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH then
		if status == ACTIVITY_STATUS.OPEN then
			self:SendAllInfoReq()
		end
		RemindManager.Instance:Fire(RemindName.LuckWishing)
	end
end

function LuckWishingCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.LuckWishing then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_WISH, num > 0)
	end
end