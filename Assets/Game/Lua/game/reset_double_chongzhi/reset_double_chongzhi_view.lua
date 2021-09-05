--------------------------------------------------------------------------
--PuTianTongQingView 	普天同庆面板
--------------------------------------------------------------------------

ResetDoubleChongzhiView = ResetDoubleChongzhiView or BaseClass(BaseView)

function ResetDoubleChongzhiView:__init()
	self.ui_config = {{"uis/views/restdoublechongzhi_prefab", "RestDoubleChongZhiView"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ResetDoubleChongzhiView:__delete()
	-- body
end

--打开回调函数
function ResetDoubleChongzhiView:OpenCallBack()
	self:Flush()
end

--关闭回调函数
function ResetDoubleChongzhiView:CloseCallBack()

end

--释放回调
function ResetDoubleChongzhiView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ResetDoubleChongzhiView:LoadCallBack()
	self.node_list["btn_close"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["btn_chongzhi"].button:AddClickListener(BindTool.Bind(self.OnChongZhiClick, self))
end

function ResetDoubleChongzhiView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

--关闭页面
function ResetDoubleChongzhiView:OnCloseClick()
	self:Close()
end

function ResetDoubleChongzhiView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function ResetDoubleChongzhiView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end

	local time_tab = TimeUtil.FormatSecond(time, 10)
	self.node_list["act_time"].text.text = string.format(Language.Activity.ActivityTime1, time_tab)
end



