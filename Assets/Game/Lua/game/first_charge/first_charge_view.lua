require("game/first_charge/first_charge_content_view")
FirstChargeView = FirstChargeView or BaseClass(BaseView)

function FirstChargeView:__init()
	self.ui_config = {{"uis/views/firstchargeview_prefab", "FirstChargeView"}}
	self.full_screen = false
	self.play_audio = true
	self.auto_close_time = 0
	self.is_stop_task = false
end

function FirstChargeView:__delete()

end

function FirstChargeView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FirstChargeView)
	end
	self.auto_close_time = 0
	self.is_stop_task = false

	if self.first_charge_content_view then
		self.first_charge_content_view:DeleteMe()
		self.first_charge_content_view = nil
	end
end

function FirstChargeView:CloseCallBack()
	self.auto_close_time = 0
	if self.is_stop_task == true then
		TaskCtrl.Instance:SetAutoTalkState(true)
		TaskCtrl.Instance:DoTask()
	end
	self.is_stop_task = false
	if self.close_timer_quest then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
end

function FirstChargeView:SetAutoCloseTime(close_time, is_stop_task)
	self.auto_close_time = close_time
	self.is_stop_task =is_stop_task
end

function FirstChargeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.first_charge_content_view = FirstChargeContentView.New(self.node_list["first_charge_content_view"])
	if self.auto_close_time ~= 0 then
		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:Close()
		end, self.auto_close_time)
	end

	if self.is_stop_task then
		TaskCtrl.Instance:SetAutoTalkState(false)
	end

	--功能引导注册
	-- FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FirstChargeView, BindTool.Bind(self.GetUiCallBack, self))
end

function FirstChargeView:OpenCallBack()
	self.first_charge_content_view:OpenCallBack()
	DailyChargeData.hasOpenFirstRecharge = true
	RemindManager.Instance:Fire(RemindName.FirstCharge)
	RemindManager.Instance:Fire(RemindName.ChargeGroup)
end

function FirstChargeView:OnFlush(param_list)
	if self.first_charge_content_view then
		self.first_charge_content_view:Flush()
	end
end

function FirstChargeView:OnCloseClick()
	self:Close()
end

function FirstChargeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then return end

	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end