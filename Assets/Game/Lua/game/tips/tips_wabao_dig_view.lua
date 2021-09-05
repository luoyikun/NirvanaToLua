TipWaBaoDigView = TipWaBaoDigView or BaseClass(BaseView)

function TipWaBaoDigView:__init()
	self.ui_config = {{"uis/views/tips/wabaotips_prefab", "WaBaoDigTips"}}
	self.full_screen = false
	self.play_audio = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
end

function TipWaBaoDigView:LoadCallBack()
	self.node_list["BtnWaBao"].button:AddClickListener(BindTool.Bind(self.OnClickWaBao, self))
end

function TipWaBaoDigView:OpenCallBack()
	self.node_list["SliderGather"]:SetActive(false)
end

function TipWaBaoDigView:OnClickWaBao()
	self.node_list["SliderGather"]:SetActive(true)
	self:CountDown()
end

function TipWaBaoDigView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TipWaBaoDigView:CountDown()
	local timer_cal = 2
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			timer_cal = timer_cal - UnityEngine.Time.deltaTime
			if timer_cal >= 0 then
				self.node_list["SliderGather"].slider.value = (2 - timer_cal)/2
			else
				self.node_list["SliderGather"]:SetActive(false)
				local baotu_count = WaBaoData.Instance:GetWaBaoInfo().baotu_count
				if baotu_count > 0 then
					WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_DIG, 0)
				end
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
			end
		end, 0)
	end
end

