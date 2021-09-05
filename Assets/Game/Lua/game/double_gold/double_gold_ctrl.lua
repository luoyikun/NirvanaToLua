require("game/double_gold/double_gold_data")
require("game/double_gold/double_gold_view")
DoubleGoldCtrl = DoubleGoldCtrl or BaseClass(BaseController)

function DoubleGoldCtrl:__init()
	if DoubleGoldCtrl.Instance then
		print_error("[DoubleGoldCtrl] Attemp to create a singleton twice !")
	end
	DoubleGoldCtrl.Instance = self
	self.data = DoubleGoldData.New()
	self.view = DoubleGoldView.New(ViewName.DoubleGoldView)
	self:RegisterAllProtocols()

	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.ListenActivityChange, self))
	self.pass_day_handle = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.OnDayChangeCallBack, self))
end

function DoubleGoldCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	GlobalEventSystem:UnBind(self.pass_day_handle)
	DoubleGoldCtrl.Instance = nil

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	
end

function DoubleGoldCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRADoubleGetInfo, "OnRADoubleGetInfo")
end

function DoubleGoldCtrl:OnRADoubleGetInfo(protocol)
	self.data:SetRADoubleGetInfo(protocol)
	self.view:Flush()
	MainUICtrl.Instance:FlushActivity()
	local is_have_weilingqu = self.data:ListIsHaveWeiLingQu()
	local is_have_open = self.data:GetActiveState()
	if is_have_open then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, false)
	else
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, is_have_weilingqu)
		if is_have_weilingqu then
			ViewManager.Instance:Open(ViewName.DoubleGoldView)
		end
	end
end

function DoubleGoldCtrl:ListenActivityChange()
	local is_have_weilingqu = self.data:ListIsHaveWeiLingQu()
	if is_have_weilingqu then
		ViewManager.Instance:Open(ViewName.DoubleGoldView)
	end
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, is_have_weilingqu)
end

function DoubleGoldCtrl:ActivityCallBack(activity_type, status)
	if activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DOUBLE_GOLD then
		if status == ACTIVITY_STATUS.OPEN then
			ViewManager.Instance:Open(ViewName.DoubleGoldView)
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, true)
		elseif status == ACTIVITY_STATUS.CLOSE then
			self.data:ClearFetchRewatd()
			MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DoubluGold, false)
		end 
	end
end

function DoubleGoldCtrl:OnDayChangeCallBack()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end