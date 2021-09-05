require("game/serveractivity/treasure_businessman/treasure_businessman_data")
require("game/serveractivity/treasure_businessman/treasure_businessman_view")
TreasureBusinessmanCtrl = TreasureBusinessmanCtrl or BaseClass(BaseController)

function TreasureBusinessmanCtrl:__init()
	if TreasureBusinessmanCtrl.Instance then
		print_error("[TreasureBusinessmanCtrl] Attemp to create a singleton twice !")
	end
	TreasureBusinessmanCtrl.Instance = self
	self.data = TreasureBusinessmanData.New()
	self.view = TreasureBusinessmanView.New(ViewName.TreasureBusinessmanView)
	self:RegisterAllProtocols()

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ZhenBaoge2)

end

function TreasureBusinessmanCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.main_view_complete then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	TreasureBusinessmanCtrl.Instance = nil
end

function TreasureBusinessmanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAZhenbaoge2Info, "OnRAZhenbaoge2Info")			 --珍宝阁
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 主界面创建
function TreasureBusinessmanCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	end
end

function TreasureBusinessmanCtrl:OnRAZhenbaoge2Info(protocol)
	self.data:SetRATreasureLoft(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ZhenBaoge2)
end

function TreasureBusinessmanCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.ZhenBaoge2 then
		self.data:FlushHallRedPoindRemind()
	end
end
