require("game/treasure_loft/treasure_loft_data")
require("game/treasure_loft/treasure_loft_view")
TreasureLoftCtrl = TreasureLoftCtrl or BaseClass(BaseController)

function TreasureLoftCtrl:__init()
	if TreasureLoftCtrl.Instance then
		print_error("[TreasureLoftCtrl] Attemp to create a singleton twice !")
	end
	TreasureLoftCtrl.Instance = self

	self.data = TreasureLoftData.New()
	self.view = TreasureLoftView.New(ViewName.TreasureLoftView)

	self:RegisterAllProtocols()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TreasureLoftCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	TreasureLoftCtrl.Instance = nil
end

function TreasureLoftCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAZhenbaogeInfo, "OnRAZhenbaogeInfo")			 --套装探秘
	
end

-- 主界面创建
function TreasureLoftCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	end
end

function TreasureLoftCtrl:OnRAZhenbaogeInfo(protocol)
	self.data:SetZhenbaogeInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	
	self.data:FlushHallRedPoindRemind()
	RemindManager.Instance:Fire(RemindName.ZhenBaoge)
end