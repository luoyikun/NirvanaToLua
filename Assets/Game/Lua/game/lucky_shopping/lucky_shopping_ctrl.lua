require("game/lucky_shopping/lucky_shopping_data")
require("game/lucky_shopping/lucky_shopping_view")

LuckyShoppingCtrl = LuckyShoppingCtrl or BaseClass(BaseController)
function LuckyShoppingCtrl:__init()
	if LuckyShoppingCtrl.Instance then
		print_error("[LuckyShoppingCtrl] Attemp to create a singleton twice !")
	end
	LuckyShoppingCtrl.Instance = self
	self:RegisterAllProtocols()

	self.data = LuckyShoppingData.New()
	self.view = LuckyShoppingView.New(ViewName.LuckyShoppingView)

	self.reddot_activate = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.reddot_activate, RemindName.LuckyShoppingRemind)
end

function LuckyShoppingCtrl:__delete()
	LuckyShoppingCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.reddot_activate then
		RemindManager.Instance:UnBind(self.reddot_activate)
		self.reddot_activate = nil
	end
end

function LuckyShoppingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALuckyCloudBuyInfo, "OnSCRALuckyCloudBuyInfo")
	self:RegisterProtocol(SCRALuckyCloudBuyBuyList, "OnSCRALuckyCloudBuyBuyList")
	self:RegisterProtocol(SCRALuckyCloudBuyOpenInfo, "OnSCRALuckyCloudBuyOpenInfo")
end

function LuckyShoppingCtrl:OnSCRALuckyCloudBuyInfo(protocol)
	self.data:OnSCRALuckyCloudBuyInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function LuckyShoppingCtrl:OnSCRALuckyCloudBuyBuyList(protocol)
	self.data:OnSCRALuckyCloudBuyBuyList(protocol)
	if self.view:IsOpen() then
		self.view:Flush("flush_record")
	end
end

function LuckyShoppingCtrl:OnSCRALuckyCloudBuyOpenInfo(protocol)
	self.data:SetOpenStatus(protocol.is_open)
	if not self.view:IsOpen() then
		self.data:SetViewIsOpen(protocol.is_open == 0)
	end
	RemindManager.Instance:Fire(RemindName.LuckyShoppingRemind)
	
	if self.view:IsOpen() then
		local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
		local time_stamp = LuckyShoppingData.Instance:GetRetTimesTamp()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_INFO)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_LUCKY_CLOUD_BUY_OPERA_TYPE.RA_LUCKY_CLOUD_BUY_TYPE_OPEN, time_stamp)
	end
end

function LuckyShoppingCtrl:RemindChangeCallBack(remind_name, num)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_SHOPPING
	if remind_name == RemindName.LuckyShoppingRemind and ActivityData.Instance:GetActivityIsOpen(activity_type) then
		self.data:FlushHallRedPoindRemind()
	end
end