require("game/daily_charge/daily_charge_content_view")
DailyChargeView = DailyChargeView or BaseClass(BaseView)

function DailyChargeView:__init()
	self.ui_config = {
		{"uis/views/dailychargeview_prefab", "DailyChargeView"}
	}
	self.full_screen = false
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function DailyChargeView:__delete()
	if self.daily_charge_content_view then
		self.daily_charge_content_view:DeleteMe()
		self.daily_charge_content_view = nil
	end
end

function DailyChargeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.daily_charge_content_view = DailyChargeContentView.New(self.node_list["daily_charge_content_view"])
end

function DailyChargeView:ReleaseCallBack()
	if self.daily_charge_content_view then
		self.daily_charge_content_view:DeleteMe()
		self.daily_charge_content_view = nil
	end
end

function DailyChargeView:ShowIndexCallBack()
	if self.daily_charge_content_view then
		self.daily_charge_content_view:InitListView()
	end
end

function DailyChargeView:OnFlush(param_list)
	if self.daily_charge_content_view then
		self.daily_charge_content_view:Flush()
	end
end

function DailyChargeView:OnCloseClick()
	self:Close()
end

function DailyChargeView:OpenCallBack()
	self.daily_charge_content_view:OpenCallBack()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("daily_charge_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.DailyCharge)
		RemindManager.Instance:Fire(RemindName.ChargeGroup)
	end
end