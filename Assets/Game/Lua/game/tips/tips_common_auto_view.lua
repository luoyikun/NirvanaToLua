TipsCommonAutoView = TipsCommonAutoView or BaseClass(BaseView)
TipsCommonAutoView.AUTO_VIEW_STR_T = {}
function TipsCommonAutoView:__init()
	self.ui_config = {{"uis/views/tips/commontips_prefab", "CommonAutoTip"}}
	self.view_layer = UiLayer.Pop
	self.is_auto = true
	self.can_show_auto = true
	self.auto_view_str = ""
	self.ok_str = ""
	self.canel_str = ""
	self.play_audio = true
	self.auto_view_str_t = {}
	self.is_special = false
	self.toggle_isOn = true
	self.is_modal = true
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsCommonAutoView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnCanel"].button:AddClickListener(BindTool.Bind(self.ClickCancel, self))
	self.node_list["BtnOk"].button:AddClickListener(BindTool.Bind(self.ClickOk, self))
	self.node_list["Check"].toggle:AddValueChangedListener(BindTool.Bind(self.ChangeAuto, self))
	self.node_list["BGBtn"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function TipsCommonAutoView:ReleaseCallBack()
	self.ok_callback = nil
	self.canel_callback = nil
	self.close_callback = nil
	self:CancelCountDownTimer()
end

function TipsCommonAutoView:OpenCallBack()
	self:Flush()
end


function TipsCommonAutoView:CloseCallBack()
	self:CancelCountDownTimer()
end

function TipsCommonAutoView:SetRedText(the_red_text)
	self.the_red_text = the_red_text or Language.Common.AutoBuyDes
end

function TipsCommonAutoView:CloseWindow()
	if self.close_callback then
		self.close_callback()
	end
	self.is_auto = false
	self:Close()
end

function TipsCommonAutoView:ClickOk()
	self:Close()	
	if self.ok_callback then
		if self.is_special and self.is_auto then
			TipsCommonAutoView.AUTO_VIEW_STR_T[self.auto_view_str] = true
		end
		self.ok_callback(self.is_auto)
	end
end

function TipsCommonAutoView:ClickCancel()
	if self.canel_callback then
		self.canel_callback(self.is_auto)
		self:Close()
	else
		self:CloseWindow()
	end
end

function TipsCommonAutoView:SetOkCallBack(callback)
	self.ok_callback = callback
end

function TipsCommonAutoView:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function TipsCommonAutoView:SetCloseCallBack(callback)
	self.close_callback = callback
end

function TipsCommonAutoView:ChangeAuto(isOn)
	self.is_auto = isOn
end

function TipsCommonAutoView:SetIsSpecial(is_special)
	self.is_special = is_special
end

--是否展示自动购买
function TipsCommonAutoView:SetShowAutoBuy(value)
	self.can_show_auto = value
end

--是否展示红字提示
function TipsCommonAutoView:SetShowRedTip(value)
	self.is_show_red_tip = value
end

function TipsCommonAutoView:SetAutoStr(str)
	self.auto_view_str = str
end

function TipsCommonAutoView:SetDes(des)
	self.des_str = des
end

function TipsCommonAutoView:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or Language.Common.Confirm
	self.canel_str = canel_des or Language.Common.Cancel
end

function TipsCommonAutoView:SetToggleIsOn(value)
	self.toggle_isOn = value
end

function TipsCommonAutoView:SetCountDownTime(count_down_time)
	self.count_down_time = count_down_time
end

function TipsCommonAutoView:OnFlush()
	self.node_list["Check"].toggle.isOn = self.toggle_isOn
	self.is_auto = self.toggle_isOn

	self.node_list["PanelShowCheckBox"]:SetActive(self.can_show_auto)
	self.node_list["TxtDes"].text.text = self.des_str

	self.node_list["TxtOKBtn"].text.text = self.ok_str
	self.node_list["TxtCanelBtn"].text.text = self.canel_str

	self:SetCountDownTimer()
end

function TipsCommonAutoView:SetCountDownTimer(count_down_time)
	if not self.count_down_time or self.count_down_time <= 0 then
		self.node_list["CountDown"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnOk"], true)
	else
		self.node_list["CountDown"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["BtnOk"], false)
		self.node_list["CountDown"].text.text = string.format(Language.Tips.StartTime, TimeUtil.FormatSecond(self.count_down_time, 2))

		self:CancelCountDownTimer()

		self.count_down_timer = CountDown.Instance:AddCountDown(
		self.count_down_time, 1, function (elapse_time, total_time)
			if elapse_time < total_time then
				if self.node_list then
					local str = string.format(Language.Tips.StartTime, TimeUtil.FormatSecond(math.floor(total_time - elapse_time), 2))
					self.node_list["CountDown"].text.text = str
				end
			else
				self:CancelCountDownTimer()
				if self.node_list then
					self.node_list["CountDown"]:SetActive(false)
					UI:SetButtonEnabled(self.node_list["BtnOk"], true)
				end
			end
		end)
	end
end

function TipsCommonAutoView:CancelCountDownTimer()
	if self.count_down_timer then
		CountDown.Instance:RemoveCountDown(self.count_down_timer)
		self.count_down_timer = nil
	end
end