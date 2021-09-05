require("game/xianshilianchong/xian_shi_lian_chong_view")
require("game/xianshilianchong/xian_shi_lian_chong_data")

XianShiLianChongCtrl = XianShiLianChongCtrl or BaseClass(BaseController)

function XianShiLianChongCtrl:__init()
	if XianShiLianChongCtrl.Instance ~= nil then
		print_error("[XianShiLianChongCtrl] attempt to create singleton twice!")
		return
	end
	XianShiLianChongCtrl.Instance = self
	self.data = XianShiLianChongData.New()
	self.view = XianShiLianChongView.New(ViewName.XianShiLianChongView)
	self:RegisterAllProtocols()

	ActivityData.Instance:NotifyActChangeCallback(BindTool.Bind(self.ActivityChangeCallBack, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.XianShiLianChong)
end


function XianShiLianChongCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	XianShiLianChongCtrl.Instance = nil
end
-- 协议注册
function XianShiLianChongCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAContinueChongzhiInfo2, "OnRAContinueChongzhiInfo2")
end


function XianShiLianChongCtrl:OnRAContinueChongzhiInfo2(protocol)
	self.data:SetChongZhInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.XianShiLianChong)
end

function XianShiLianChongCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG then
		-- 活动开启之后才请求
		if status == ACTIVITY_STATUS.OPEN then
			KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG, RA_CONTINUE_CHONGZHI_OPERA_TYPE.RA_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO, 0, 0)
		end
	end
end


function XianShiLianChongCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.XianShiLianChong then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.XIAN_SHI_LIAN_CHONG, num > 0)
	end
end




