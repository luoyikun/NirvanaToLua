require("game/biping_activity/biping_activity_view")
require("game/biping_activity/biping_activity_data")
require("game/biping_activity/biping_activityrank_view")
BiPingActivityCtrl = BiPingActivityCtrl or BaseClass(BaseController)

function BiPingActivityCtrl:__init()
	if BiPingActivityCtrl.Instance ~= nil then
		print_error("[BiPingActivityCtrl] attempt to create singleton twice!")
		return
	end

	BiPingActivityCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = BiPingActivityView.New(ViewName.BiPingActivity)
	self.data = BiPingActivityData.New()
	self.rank_view = BiPingActivityRankView.New()
	self.pass_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.MainuiOpenCreate, self))
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

	-- self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	-- RemindManager.Instance:Bind(self.remind_change, RemindName.BPCapabilityRemind)
end

function BiPingActivityCtrl:__delete()
	BiPingActivityCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	
end

-- function BiPingActivityCtrl:GetView()
-- 	return self.view
-- end

function BiPingActivityCtrl:FlushView()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function BiPingActivityCtrl:ViewIsOpen()
	if self.view then
		return self.view:IsOpen()
	end
	return false
end

function BiPingActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCImageCompetitionInfo, "OnSCImageCompetitionInfo")
end


function BiPingActivityCtrl:OnSCImageCompetitionInfo(protocol)
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_IMAGE_COMPETITION)
		self.data:SetOpenDayCfg(protocol)
		self.view:Flush()
end

function BiPingActivityCtrl:SetPlayDataEvent()
	if not self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
end

function BiPingActivityCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		self:MainuiOpenCreate()
	end
end

function BiPingActivityCtrl:MainuiOpenCreate()
	
end

function BiPingActivityCtrl:SendGetBipinInfo()
	
end

function BiPingActivityCtrl:OpenRankView()
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_IMAGE_COMPETITION)
		self.rank_view:Open()
end

function BiPingActivityCtrl:RemindChangeCallBack(remind_name, num)
	
end

function BiPingActivityCtrl:FlushRankView()
	if self.rank_view:IsOpen() then
		self.rank_view:Flush()
	end
end