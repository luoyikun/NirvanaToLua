require("game/dalegou/dalegou_view")
require("game/dalegou/dalegou_tips_view")
require("game/dalegou/dalegou_data")

DaLeGouCtrl = DaLeGouCtrl or BaseClass(BaseController)

function DaLeGouCtrl:__init()
	if DaLeGouCtrl.Instance ~= nil then
		print_error("[DaLeGouCtrl] attempt to create singleton twice!")
		return
	end

	DaLeGouCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = DaLeGouData.New()
	self.view = DaLeGouView.New(ViewName.DaLeGouView)
	self.tips_view = DaLeGouTips.New(ViewName.DaLeGouTips)
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.DaLeGou)
end

function DaLeGouCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.tips_view ~= nil then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	DaLeGouCtrl.Instance = nil
end

-- 协议注册
function DaLeGouCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRACrazyBuyAllInfo, "OnRACrazyBuyAllInfo")
	self:RegisterProtocol(SCRACracyBuyLimitInfo, "OnRACracyBuyLimitInfo")
end

-- 疯狂抢购面板信息
function DaLeGouCtrl:OnRACrazyBuyAllInfo(protocol)
	-- print_error("疯狂抢购面板信息", protocol)
	self.data:SetBuyInfo(protocol)

	if self.view:IsOpen() then
		self.view:Flush()
	end

	if self.tips_view:IsOpen() then
		self.tips_view:Flush()
	end
end

-- 限购信息
function DaLeGouCtrl:OnRACracyBuyLimitInfo(protocol)
	-- print_error("限购信息", protocol)
	self.data:SetBuyLimitList(protocol.limit_list)

	if self.view:IsOpen() then
		self.view:Flush()
	end

	if self.tips_view:IsOpen() then
		self.tips_view:Flush()
	end
end

function DaLeGouCtrl:ShowTips(data, close_callback)
	self.tips_view:SetData(data)
	self.tips_view:SetCloseCallBack(close_callback)
	self.tips_view:Open()
end

function DaLeGouCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DALEGOU, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
	end
end

function DaLeGouCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.DaLeGou then
		self.data:DaLeGouPoindRemind()
	end
end
