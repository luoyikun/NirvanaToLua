require("game/marry_me/marry_me_view")
require("game/marry_me/marry_me_data")

MarryMeCtrl = MarryMeCtrl or BaseClass(BaseController)

function MarryMeCtrl:__init()
	if MarryMeCtrl.Instance ~= nil then
		print_error("[MarryMeCtrl] attempt to create singleton twice!")
		return
	end

	MarryMeCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = MarryMeView.New(ViewName.MarryMe)
	self.data = MarryMeData.New()

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))

	self.activity_change_handle = BindTool.Bind(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change_handle)
end

function MarryMeCtrl:__delete()
	MarryMeCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_change_handle and ActivityData.Instance then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change_handle)
		self.activity_change_handle = nil
	end
end

function MarryMeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMarryMeAllInfo, "OnMarryMeAllInfo")
end

function MarryMeCtrl:OnMarryMeAllInfo(protocol)
	self.data:SetInfo(protocol)
	self.view:Flush()
end

function MarryMeCtrl:MainRoleInfo()
	RemindManager.Instance:Fire(RemindName.MarryMe)
end

function MarryMeCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.MARRY_ME then
		if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then
			RemindManager.Instance:Fire(RemindName.MarryMe)
		end
	end
end