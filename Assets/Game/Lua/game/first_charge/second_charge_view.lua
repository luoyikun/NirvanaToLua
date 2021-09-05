require("game/first_charge/second_charge_content_view")
SecondChargeView = SecondChargeView or BaseClass(BaseView)

local MAX_TOGGLE_NUM = 3
local remind_cfg = {RemindName.FirstCharge, RemindName.SecondCharge, RemindName.ThirdCharge}

function SecondChargeView:__init()
	self.ui_config = {
		{"uis/views/firstchargeview_prefab", "SecondChargeView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.auto_close_time = 0
	self.select_index = -1
	self.is_stop_task = false
	self.selected_index = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SecondChargeView:__delete()

end

function SecondChargeView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.SecondChargeView)
	end
	self.auto_close_time = 0
	self.is_stop_task = false

	if self.second_charge_content_view then
		self.second_charge_content_view:DeleteMe()
		self.second_charge_content_view = nil
	end

	self.selected_index = 0
end

function SecondChargeView:CloseCallBack()
	self.auto_close_time = 0
	local role_level = PlayerData.Instance:GetRoleVo().level
	if role_level <= GameEnum.NOVICE_LEVEL then
		TaskCtrl.Instance:SetIsOpenView(false)
	end
	self.is_stop_task = false
	if self.close_timer_quest then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
end

function SecondChargeView:SetAutoCloseTime(close_time, is_stop_task)
	self.auto_close_time = close_time
	self.is_stop_task = is_stop_task
end

function SecondChargeView:Open()
	-- 三充过后
	if DailyChargeData.Instance:GetIsThreeRecharge() then
		local active_flag1, fetch_flag1 = DailyChargeData.Instance:GetThreeRechargeFlag(1)
		local active_flag2, fetch_flag2 = DailyChargeData.Instance:GetThreeRechargeFlag(2)
		local active_flag3, fetch_flag3 = DailyChargeData.Instance:GetThreeRechargeFlag(3)
		--并且三档都领了
		if fetch_flag1 == 1 and fetch_flag2 == 1 and fetch_flag3 == 1 then
			return
		end
	end
	BaseView.Open(self)
end

function SecondChargeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.second_charge_content_view = SecondChargeContentView.New(self.node_list["SecondChargeView"])

	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	if self.auto_close_time ~= 0 then
		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:Close()
		end, self.auto_close_time)
	end

	for i = 1, MAX_TOGGLE_NUM do
		self.second_charge_content_view.node_list["toggle_" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToFlush, self, i))
	end

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.SecondChargeView, BindTool.Bind(self.GetUiCallBack, self))
end

function SecondChargeView:OpenCallBack()
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	self.second_charge_content_view:OpenCallBack()
	DailyChargeData.Instance:SetShowPushIndex(self.selected_index)
	DailyChargeData.hasOpenFirstRecharge = true
	RemindManager.Instance:Fire(remind_cfg[self.selected_index])
	local role_level = PlayerData.Instance:GetRoleVo().level
	if role_level <= GameEnum.NOVICE_LEVEL then
		TaskCtrl.Instance:SetIsOpenView(true)
	end
	self:Flush()
end

function SecondChargeView:OnClickToFlush(index)
	local select_index = DailyChargeData.Instance:GetShowPushIndex()
	if select_index == index then
		return
	end
	self.select_index = index
	DailyChargeData.Instance:SetShowPushIndex(index)

	self:Flush()
end

function SecondChargeView:OnFlush(param_list)
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	-- if self.selected_index == select_index then return end

	for i = 1, MAX_TOGGLE_NUM do
		if i == self.selected_index then
			self.second_charge_content_view.node_list["toggle_" .. i].toggle.isOn = true
		else
			self.second_charge_content_view.node_list["toggle_" .. i].toggle.isOn = false
		end
	end

	if self.second_charge_content_view then
		self.second_charge_content_view:Flush()
	end
end

function SecondChargeView:OnCloseClick()
	self:Close()
end

function SecondChargeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then return end

	if self[ui_name] and self[ui_name].gameObject.activeInHierarchy then
		return self[ui_name]
	end
end