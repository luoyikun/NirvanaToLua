require("game/shop/shop_data")
require("game/shop/shop_view")
require("game/shop/tips_jifenshop_view")

ShopCtrl = ShopCtrl or BaseClass(BaseController)
function ShopCtrl:__init()
	if ShopCtrl.Instance then
		print_error("[ShopCtrl] Attemp to create a singleton twice !")
	end
	ShopCtrl.Instance = self
	self.data = ShopData.New()
	self.view = ShopView.New(ViewName.Shop)
	self.tips_jifenshop_view = JiFenShopView.New(ViewName.JiFenShopView)

	self.score_change_callback = BindTool.Bind1(self.ScoreDataChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)

	self.price_change_callback = BindTool.Bind1(self.PriceDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.price_change_callback)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.TeHuiShop)

	self:RegisterAllProtocols()
end

function ShopCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.tips_jifenshop_view:DeleteMe()
	self.tips_jifenshop_view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.score_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
	end

	if self.price_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.price_change_callback)
		self.price_change_callback = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	ShopCtrl.Instance = nil
end

function ShopCtrl:OpenJifenShop()
	ViewManager.Instance:Open(ViewName.JiFenShopView)
end

function ShopCtrl:OpenShopView() 				-- 不经过ViewManager
	if self.view then
		self.view:Open()
		self.view:ChangeToIndex(TabIndex.shop_chengzhang)
	end
end

function ShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendMysteriosshopItemInfo, "ShenMiShop")
	self:RegisterProtocol(SCSendDiscounthopItemInfo, "OnSCSendDiscounthopItemInfo")
	self:RegisterProtocol(CSMysteriosshopinMallOperate)
	self:RegisterProtocol(CSMysteriosshopOperate)
end

function ShopCtrl:ShenMiShop(protocol)
	-- 刷新红点提醒
	self.data:SetClientRemindFlag(protocol.client_remind_flag)

	self.data:SetShenMiShop(protocol)
	self.tips_jifenshop_view:Flush()
	RemindManager.Instance:Fire(RemindName.ShenmiShop)
	RemindManager.Instance:Fire(RemindName.TeHuiShop)
	if self.view and self.view:IsOpen() then
		self.view:Flush()
		self.view:ShenMiItem()
		self.view:PlayEffect()
		self.view:SetButtonGrayEnabled()
	end
end

function ShopCtrl:OnSCSendDiscounthopItemInfo(protocol)
	self.data:SetDiscounthopItemInfo(protocol)
	
	self.view:Flush("tehui_shop_flush")
	RemindManager.Instance:Fire(RemindName.TeHuiShop)
end

function ShopCtrl:SendDiscountShopBuy(seq, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiscountShopBuy)
	protocol.operate_type = operate_type
	protocol.seq = seq or 0
	protocol.num = num or 1
	protocol:EncodeAndSend()
end

function ShopCtrl:SendMysteriosshopinMallOperate(operate_type, seq)
	if operate_type == MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH then
		ShopData.Instance:SetSendType(seq)
	else
		ShopData.Instance:SetSendType(-1)
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSMysteriosshopinMallOperate)
	protocol.operate_type = operate_type
	protocol.seq = seq
	protocol:EncodeAndSend()
end

function ShopCtrl:SendMysteriosshopOperate(conver_type, item_seq, item_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	protocol.scoretoitem_type = conver_type
	protocol.index = item_seq
	protocol.num = item_num
	protocol:EncodeAndSend()
end

function ShopCtrl:ScoreDataChange()
	self.view:Flush()
	self.tips_jifenshop_view:Flush()
end

function ShopCtrl:PriceDataChange(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		self.view:Flush()
	end
end

--接受点击事件
function ShopCtrl:SetCloseBackEvent(callback)
	if callback ~= nil then
		self.view:SetCloseBackEvent(callback)
	end
end

function ShopCtrl:FlushTeHuiCountDown()
	if self.view:IsOpen() then
		self.view:TeHuiCountDown()
	end
end

function ShopCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.TeHuiShop then
		MainUICtrl.Instance:GetView():ShowTeHuiDiscountShop()
		if self.view:IsOpen() then
			self.view:IsShowRedPoint(1, num > 0)
		end
	end
end