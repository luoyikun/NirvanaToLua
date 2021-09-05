require("game/competition_activity/competition_activity_view")
require("game/competition_activity/competition_activity_data")

CompetitionActivityCtrl = CompetitionActivityCtrl or BaseClass(BaseController)

function CompetitionActivityCtrl:__init()
	if CompetitionActivityCtrl.Instance ~= nil then
		print_error("[CompetitionActivityCtrl] attempt to create singleton twice!")
		return
	end

	CompetitionActivityCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = CompetitionActivityView.New(ViewName.CompetitionActivity)
	self.data = CompetitionActivityData.New()
	
	self.pass_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.MainuiOpenCreate, self))
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.BPCapabilityRemind)
end

function CompetitionActivityCtrl:__delete()
	CompetitionActivityCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	if self.pass_day then
		GlobalEventSystem:UnBind(self.pass_day)
		self.pass_day = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

-- function CompetitionActivityCtrl:GetView()
-- 	return self.view
-- end

function CompetitionActivityCtrl:FlushView()
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
end

function CompetitionActivityCtrl:ViewIsOpen()
	if self.view then
		return self.view:IsOpen()
	end
	return false
end

function CompetitionActivityCtrl:RegisterAllProtocols()
end

function CompetitionActivityCtrl:SetPlayDataEvent()
	if not self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
end

function CompetitionActivityCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		self:MainuiOpenCreate()
	end
end

function CompetitionActivityCtrl:MainuiOpenCreate()
	local day_time = TimeCtrl.Instance:GetCurOpenServerDay() > #COMPETITION_ACTIVITY_TYPE and #COMPETITION_ACTIVITY_TYPE or TimeCtrl.Instance:GetCurOpenServerDay()
	local act_type = COMPETITION_ACTIVITY_TYPE[day_time]
	if ActivityData.Instance:GetActivityIsOpen(act_type) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(act_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
end

function CompetitionActivityCtrl:SendGetBipinInfo()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ActivityData.Instance:GetActivityConfig(COMPETITION_ACTIVITY_TYPE[day])
	if cfg == nil then return end
	for k, v in pairs(COMPETITION_ACTIVITY_TYPE) do
		if ActivityData.Instance:GetActivityIsOpen(v) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
	-- KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(COMPETITION_ACTIVITY_TYPE[day], RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end

function CompetitionActivityCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.BPCapabilityRemind and num > 0 then
		CompetitionActivityData.Instance:SetBiPinRank(true)
		local server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local activity_type = COMPETITION_ACTIVITY_TYPE[1]
		local rank_type_list = RankData.Instance:GetRankTypeList()
		RankCtrl.Instance:SendGetPersonRankListReq(rank_type_list[ACTIVITY_TYPE_TO_RANK_TYPE[activity_type]])
	end
end

function CompetitionActivityCtrl:ActCloseView()
	if self.view:IsOpen() then
		self.view:OnClickClose()
	end
end