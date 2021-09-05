MonomerView = MonomerView or BaseClass(BaseView)
local SEND_CD = 30
function MonomerView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "MonomerView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function MonomerView:__delete()

end

function MonomerView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickTuoDan, self))
end

function MonomerView:OpenCallBack()
	self.node_list["InputField"].input_field.text = ""
	self:ChangeTuoDanBtnText()
end

function MonomerView:ReleaseCallBack()
	self:CancelTuoDanQuest()
end

function MonomerView:ClickClose()
	self:Close()
end

function MonomerView:ClickTuoDan()
	local is_in_list = MarriageData.Instance:IsInTuoDanList()
	local des = self.node_list["InputField"].input_field.text
	if des == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotTuoDanDes)
		return
	end
	if ChatFilter.Instance:IsIllegal(des) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ContentUnlawful)
		return
	end
	local length = StringUtil.GetCharacterCount(des)
	if length > 15 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.TuoDanDesTooLength)
		return
	end
	MarriageCtrl.Instance:SendTuodanReq(TUODAN_OPERA_TYPE.TUODAN_INSERT, des)
	self:Close()

	MarriageData.Instance:SetSendTuoDanTime()
end

function MonomerView:ChangeTuoDanBtnText()
	--开始倒计时
	self:CancelTuoDanQuest()
	local send_time = MarriageData.Instance:GetSendTuoDanTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if send_time <= 0 or (server_time - send_time) > SEND_CD then
		UI:SetButtonEnabled(self.node_list["Button"], true)
		self.node_list["TxtButton"].text.text = Language.Marriage.TuoDanDes
		return
	end

	local left_time = math.ceil(SEND_CD - (server_time - send_time))
	left_time = left_time > SEND_CD and SEND_CD or left_time

	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:CancelTuoDanQuest()
			UI:SetButtonEnabled(self.node_list["Button"], true)
			self.node_list["TxtButton"].text.text = Language.Marriage.TuoDanDes
			return
		end
		local temp_time = math.ceil(total_time - elapse_time)
		local time_des = string.format(Language.Chat.ResetTimes, temp_time)
		UI:SetButtonEnabled(self.node_list["Button"], false)
		self.node_list["TxtButton"].text.text = time_des
	end

	self.tuo_dan_count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	UI:SetButtonEnabled(self.node_list["Button"], false)
	local time_des = string.format(Language.Chat.ResetTimes, left_time)
	self.node_list["TxtButton"].text.text = time_des
end

function MonomerView:CancelTuoDanQuest()
	if self.tuo_dan_count_down then
		CountDown.Instance:RemoveCountDown(self.tuo_dan_count_down)
		self.tuo_dan_count_down = nil
	end
end