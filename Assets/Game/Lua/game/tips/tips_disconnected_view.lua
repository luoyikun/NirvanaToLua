TipsDisconnectedView = TipsDisconnectedView or BaseClass(BaseView)

function TipsDisconnectedView:__init()
	self.ui_config = {{"uis/views/tips/disconnectedtips_prefab", "DisconnectedTip"}}
	self.view_layer = UiLayer.Disconnect
	self.auto_connect = true
	self.play_audio = true
	self.active_close = false

	self.is_game_end = false
end

function TipsDisconnectedView:__delete()
	self.is_game_end = false
end

function TipsDisconnectedView:ReleaseCallBack()
	self.is_game_end = false
	GlobalTimerQuest:CancelQuest(self.connect_time)
end

function TipsDisconnectedView:LoadCallBack()
	ReportManager:Step(Report.STEP_DISCONNECT_SHOW)
	self.node_list["BtnBack"].button:AddClickListener(BindTool.Bind(self.OnBack, self))
	self.node_list["BtnRetry"].button:AddClickListener(BindTool.Bind(self.OnRetry, self))
end

function TipsDisconnectedView:OnRetry()
	if self.is_game_end then
		return
	end
	print_log("Retry connect.")
	ReportManager:Step(Report.STEP_DISCONNECT_RETRY)
	TipsCtrl.Instance:ShowLoadingTips(15, BindTool.Bind(self.Open, self), 1)
	GameNet.Instance:ResetLoginServer()
	GameNet.Instance:ResetGameServer()
	GameNet.Instance:AsyncConnectLoginServer(5)
	self:Close()
end

function TipsDisconnectedView:OnBack()
	print_log("Back to login.")
	self:Close()
	ReportManager:Step(Report.STEP_DISCONNECT_BACK)
	GameRoot.Instance:Restart()
end

function TipsDisconnectedView:SetAutoConnect(auto_connect, is_game_end)
	if auto_connect ~= nil then
		self.auto_connect = auto_connect
	end
	self.is_game_end = is_game_end
end

function TipsDisconnectedView:OpenCallBack()
	self.node_list["BtnRetry"]:SetActive(not self.is_game_end)
	if self.is_game_end then
		self.node_list["TxtTime"].text.text = ""
		self.node_list["Content"].text.text = Language.Common.RestartGameTip
		return
	end
	self.reconnect_time = 30
	GlobalTimerQuest:CancelQuest(self.connect_time)
	if self.auto_connect then
		self.connect_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.ConnectTimeUpdate,self), 1)
		self:ConnectTimeUpdate()
	else
		self.node_list["TxtTime"].text.text = ""
	end
end

function TipsDisconnectedView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.connect_time)
	self.auto_connect = true
end

function TipsDisconnectedView:ConnectTimeUpdate()
	self.reconnect_time = self.reconnect_time - 1
	self.node_list["TxtTime"].text.text = string.format(Language.Login.ReconnectTips, self.reconnect_time)
	if self.reconnect_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.connect_time)
		self:OnRetry()
	end
end
