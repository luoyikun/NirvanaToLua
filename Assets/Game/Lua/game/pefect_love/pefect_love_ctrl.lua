require("game/pefect_love/pefect_love_view")
require("game/pefect_love/pefect_love_data")

PefectLoverCtrl = PefectLoverCtrl or BaseClass(BaseController)

function PefectLoverCtrl:__init()
	if PefectLoverCtrl.Instance ~= nil then
		print_error("[PefectLoverCtrl] attempt to create singleton twice!")
		return
	end

	PefectLoverCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = PefectLoverView.New(ViewName.PerfectLover)
	self.data = PefectLoverData.New()

	-- self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))

	-- self.activity_change_handle = BindTool.Bind(self.ActivityChangeCallBack, self)
	-- ActivityData.Instance:NotifyActChangeCallback(self.activity_change_handle)
end

function PefectLoverCtrl:__delete()
	PefectLoverCtrl.Instance = nil
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

function PefectLoverCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAPerfectLoverInfo, "OnSCRAPerfectLoverInfo")
end

function PefectLoverCtrl:OnSCRAPerfectLoverInfo(protocol)
	self.data:SetInfo(protocol)
	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
	local is_show = self.data:GetSelfPerfectActiveCfg()
	local main_view = MainUICtrl.Instance:GetView()
	if main_view and is_show then
		main_view:SetPerfectEffct(true)
	end
end

function PefectLoverCtrl:MainRoleInfo()
	-- RemindManager.Instance:Fire(RemindName.MarryMe)
end

function PefectLoverCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.MARRY_ME then
		if GameVoManager.Instance:GetMainRoleVo().lover_uid <= 0 then
			-- RemindManager.Instance:Fire(RemindName.MarryMe)
		end
	end
end