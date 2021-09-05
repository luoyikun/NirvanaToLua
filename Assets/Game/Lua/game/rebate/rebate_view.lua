require("game/rebate/rebate_content_view")
RebateView = RebateView or BaseClass(BaseView)
function RebateView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_1"},
		{"uis/views/rebateview_prefab", "RebateView"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelTwo_2"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function RebateView:__delete()

end

function RebateView:LoadCallBack()

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.rebate_content_view = RebateContentView.New(self.node_list["rebate_content_view"])

end

function RebateView:ReleaseCallBack()
	self.rebate_content_view:DeleteMe()
	self.rebate_content_view = nil
end

function RebateView:OpenCallBack()
	self.rebate_content_view:SetModelState()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		PlayerPrefsUtil.SetInt("rebate_remind_day", cur_day)
		RemindManager.Instance:Fire(RemindName.Rebate)
	end
end

function RebateView:OnCloseClick()
	self:Close()
end

function RebateView:OnFlush()
	if self.rebate_content_view then
		self.rebate_content_view:Flush()
	end
end