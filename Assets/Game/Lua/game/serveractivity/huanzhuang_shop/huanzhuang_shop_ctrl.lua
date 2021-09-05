require("game/serveractivity/huanzhuang_shop/huanzhuang_shop_view")
require("game/serveractivity/huanzhuang_shop/huanzhuang_shop_data")
require("game/serveractivity/huanzhuang_shop/title_shop_view")

HuanzhuangShopCtrl = HuanzhuangShopCtrl or BaseClass(BaseController)
function HuanzhuangShopCtrl:__init()
	if HuanzhuangShopCtrl.Instance then
		print_error("[HuanzhuangShopCtrl] Attemp to create a singleton twice !")
	end
	HuanzhuangShopCtrl.Instance = self

	self.huan_zhuang_shop_data = HuanzhuangShopData.New()
	self.huan_zhuang_shop_view = HuanzhuangShopView.New(ViewName.HuanZhuangShopView)
	self.title_shop_view = TitleShopView.New(ViewName.TitleShopView)

	self:RegisterAllProtocols()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
end

function HuanzhuangShopCtrl:__delete()
	HuanzhuangShopCtrl.Instance = nil

	if self.huan_zhuang_shop_view then
		self.huan_zhuang_shop_view:DeleteMe()
		self.huan_zhuang_shop_view = nil
	end

	if self.huan_zhuang_shop_data then
		self.huan_zhuang_shop_data:DeleteMe()
		self.huan_zhuang_shop_data = nil
	end

	if self.title_shop_view then
		self.title_shop_view:DeleteMe()
		self.title_shop_view = nil
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function HuanzhuangShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMagicShopAllInfo, "OnSCRAMagicShopAllInfo")
	self:RegisterProtocol(SCRAChongZhiGiftInfo, "OnSCRAChongZhiGiftInfo")
end

function HuanzhuangShopCtrl:OnSCRAMagicShopAllInfo(protocol)
	self.huan_zhuang_shop_data:SetRAMagicShopAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ShowHuanZhuangShopPoint)
	if self.huan_zhuang_shop_view then
		self.huan_zhuang_shop_view:Flush("FlsuhData")
	end

	-- if self.title_shop_view then
	-- 	self.title_shop_view:Flush("FlsuhData")
	-- end
end

function HuanzhuangShopCtrl:OnSCRAChongZhiGiftInfo(protocol)
	self.huan_zhuang_shop_data:SetRATitleShopAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.NiChongWoSong)
	RemindManager.Instance:Fire(RemindName.TitleShopTodayRemind)
	-- if self.huan_zhuang_shop_view then
	-- 	self.huan_zhuang_shop_view:Flush("FlsuhData")
	-- end

	if self.title_shop_view then
		self.title_shop_view:Flush("FlsuhData")
	end
end

function HuanzhuangShopCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP then
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_KING_DRAW_OPERA_TYPE.RA_KING_DRAW_OPERA_TYPE_QUERY_INFO)
		end
	end
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG then
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_NICHONGWOSONG, CHONGZHI_GIFT_OPER_TYPE.CHONGZHI_GIFT_OPER_TYPE_INFO)
		end
	end 

end