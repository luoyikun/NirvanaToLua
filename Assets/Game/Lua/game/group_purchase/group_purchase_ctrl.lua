require("game/group_purchase/group_purchase_view")
require("game/group_purchase/group_purchase_data")

GroupPurchaseCtrl = GroupPurchaseCtrl or BaseClass(BaseController)
function GroupPurchaseCtrl:__init()
	if GroupPurchaseCtrl.Instance then
		print_error("[GroupPurchaseCtrl] Attemp to create a singleton twice !")
	end
	GroupPurchaseCtrl.Instance = self

	self.data = GroupPurchaseData.New()
	self.view = GroupPurchaseView.New(ViewName.GroupPurchaseView)

	self.activity_call_back = BindTool.Bind(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self:RegisterAllProtocols()
end

function GroupPurchaseCtrl:__delete()
	GroupPurchaseCtrl.Instance = nil

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
end

function GroupPurchaseCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRACombineBuyInfo, "OnSCRACombineBuyInfo")
	self:RegisterProtocol(SCRACombineBuyBucketInfo, "OnSCRACombineBuyBucketInfo")
end

-- 物品已购买数量信息
function GroupPurchaseCtrl:OnSCRACombineBuyInfo(protocol)
	self.data:SetItemHasPurchaseNumData(protocol)
	self:FlushView("has_buy_info")
end

-- 购物车信息
function GroupPurchaseCtrl:OnSCRACombineBuyBucketInfo(protocol)
	self.data:SetCartData(protocol)
	self:FlushView("cart_info")
end

--操作请求
function GroupPurchaseCtrl:SendRandActivityOperaReqReq(opera_type, param_1, param_2)
	local rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
end

--活动开启请求协议
function GroupPurchaseCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type ~= ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GROUP_PURCHASE or status ~= ACTIVITY_STATUS.OPEN then
		return 
	end

	local opera_type = RA_COMBINE_BUY_OPERA_TYPE.RA_COMBINE_BUY_OPERA_TYPE_INFO
	self:SendRandActivityOperaReqReq(opera_type)
end

function GroupPurchaseCtrl:FlushView(param_list)
	if self.view and self.view:IsOpen() then
		self.view:Flush(param_list)
	end
end