require("game/small_helper/small_helper_data")
require("game/small_helper/small_helper_view")
SmallHelperCtrl = SmallHelperCtrl or BaseClass(BaseController)

function SmallHelperCtrl:__init()
	if SmallHelperCtrl.Instance then
		print_error("[SmallHelperCtrl] Attemp to create a singleton twice !")
		return
	end
	SmallHelperCtrl.Instance = self
	self.view = SmallHelperView.New(ViewName.SmallHelper)
	self:RegisterAllProtocols()
	self.data = SmallHelperData.New()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.FlushIconMain, self))
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.FlushIcon, self))
	self.day_change_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.FlushIcon, self))
	self.vip_change_event = GlobalEventSystem:Bind(ObjectEventType.VIP_CHANGE, BindTool.Bind(self.FlushIcon, self))
end

function SmallHelperCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.level_change_event ~= nil then
		GlobalEventSystem:UnBind(self.level_change_event)
		self.level_change_event = nil
	end

	if self.day_change_event ~= nil then
		GlobalEventSystem:UnBind(self.day_change_event)
		self.day_change_event = nil
	end

	if self.vip_change_event ~= nil then
		GlobalEventSystem:UnBind(self.vip_change_event)
		self.vip_change_event = nil
	end

	self:CancelCoutDown()
	SmallHelperCtrl.Instance = nil
end

function SmallHelperCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSLittleHelperOpera)
	self:RegisterProtocol(SCLittleHelperInfo, "OnSCLittleHelperInfo")
	self:RegisterProtocol(SCLittleHelperItemInfo, "OnSCLittleHelperItemInfo")
	self:RegisterProtocol(CSLittleHelperRepeatOpera)
end

function SmallHelperCtrl:OnRecvMainRoleInfo()
	ShenYuBossCtrl.Instance:SendGodMagicBossBossInfoReq(GODMAGIC_BOSS_OPERA_TYPE.GODMAGIC_BOSS_OPERA_TYPE_PLAYER_INFO)
	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_ROLE_INFO_REQ)
	RemindManager.Instance:Fire(RemindName.SmallHelper)
	self.data:GetShowConfig()
end

function SmallHelperCtrl:OnSCLittleHelperInfo(protocol)
	self.data:SetLittleHelper(protocol)
	RemindManager.Instance:Fire(RemindName.SmallHelper)

	self:FlushIcon()
	self.view:Flush()
end

function SmallHelperCtrl:OnSCLittleHelperItemInfo(protocol)
	self.data:SetReward(protocol)
end

function SmallHelperCtrl:SendReqAll(count, task_type_list, param_list0, param_list1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLittleHelperRepeatOpera)
	send_protocol.count = count or 0
	send_protocol.task_type_list = task_type_list or {}
	send_protocol.param_list0 = param_list0 or {}
	send_protocol.param_list1 = param_list1 or {}
	send_protocol:EncodeAndSend()
end

function SmallHelperCtrl:FlushIconMain( )
	self:CancelCoutDown()
	self.count_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.FlushIcon, self), 5)
end

function SmallHelperCtrl:CancelCoutDown()
	if self.count_down ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
end

function SmallHelperCtrl:SendHelperReq(request_type, param_0, param_1, param_2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLittleHelperOpera)
	send_protocol.type = request_type or 0
	send_protocol.param_0 = param_0 or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol:EncodeAndSend()
end

function SmallHelperCtrl:FlushIcon()
	self.data:GetShowConfig()
	local is_show = self.data:GetRemind() > 0
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.SmallHelper, is_show)
end
