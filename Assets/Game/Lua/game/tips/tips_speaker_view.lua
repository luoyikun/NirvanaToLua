------------------------------------------------------------
--喇叭公告
------------------------------------------------------------
TipsSpeakerView = TipsSpeakerView or BaseClass(BaseView)
LOCAL_PRICE = 10
CROSS_PRICE = 30
function TipsSpeakerView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/tips/speakertips_prefab", "SpeakerView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.view_layer = UiLayer.Pop
end

function TipsSpeakerView:__delete()
	self.send_state = nil
end

function TipsSpeakerView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.Title.LaBa
	self.node_list["Bg"].rect.sizeDelta = Vector3(580,497,0)
	self.speaker_input = self.node_list["InputContent"]
	self.world_toggle = self.node_list["worldToggle"]
	self.kuafu_toggle = self.node_list["KuafuToggle"]

	self.world_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_LOCAL))
	self.kuafu_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_CROSS))
	--self.node_list["PwHongbaoToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_KOULING))

	self.node_list["BtnSendButton"].button:AddClickListener(BindTool.Bind(self.OnClickSendButton, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
	self.node_list["BtnHeko"].button:AddClickListener(BindTool.Bind(self.OnClickDecsButton, self))
	self:OnToggleChange(SPEAKER_TYPE.SPEAKER_TYPE_LOCAL)
	self.node_list["PwHongbaoToggle"].toggle.isOn = true
	self.switch_handle = GlobalEventSystem:Bind(ChatEventType.KF_LABA, BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:UpdateVoiceSwitch()
end

function TipsSpeakerView:ReleaseCallBack()
	-- 清理变量和对象
	self.speaker_input = nil
	self.world_toggle = nil
	self.kuafu_toggle = nil

	if self.switch_handle ~= nil then
		GlobalEventSystem:UnBind(self.switch_handle)
		self.switch_handle = nil
	end
end

function TipsSpeakerView:OnToggleChange(send_state)
	self.send_state = send_state
	local price
	if self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_LOCAL then
		price = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").talk_cfg.speaker_need_gold or 20
		self.node_list["TxtNeedGold"].text.text = price
	-- elseif self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING then
	-- 	local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
	-- 	price = cfg.consume
	-- 	self.node_list["TxtNeedGold"].text.text = price
	else
		price = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").talk_cfg.cross_speaker_need_gold or 50
		self.node_list["TxtNeedGold"].text.text = price
	end
end

function TipsSpeakerView:CloseCallBack()
	if self.speaker_input then
		self.speaker_input.input_field.text = ""
	end
end

function TipsSpeakerView:OnClickSendButton()
	local text = self.speaker_input.input_field.text
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
	if ChatFilter.Instance:IsIllegal(text) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		return
	end
	local function ok_callback()
		if self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING then
			ChatCtrl.Instance:SendCreateCommandRedPaper(text)
		else
			ChatCtrl.Instance:SendCurrentTransmit(1, text, nil, self.send_state)
			ChatCtrl.Instance:ChangeLockState(false)
		end
		self.speaker_input.input_field.text = ""
		self:Close()
	end

	text = ChatData.Instance:FormattingMsg(text, CHAT_CONTENT_TYPE.TEXT)
	

	local des = ""
	local price = 0
	local open_view_str = ""
	if self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_LOCAL then
		price = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").talk_cfg.speaker_need_gold or 20
		des = string.format(Language.Chat.SendByGold, price)
		open_view_str = "speaker_local"
	elseif self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING then
		local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
		price = cfg.consume
		des = string.format(Language.Chat.SendKoulingHbByGold, price)
		open_view_str = "speaker_kouling"
	else
		price = ConfigManager.Instance:GetAutoConfig("otherconfig_auto").talk_cfg.cross_speaker_need_gold or 50
		des = string.format(Language.Chat.SendSrossByGold, price)
		open_view_str = "speaker_cross"
	end
	TipsCtrl.Instance:ShowCommonAutoView(open_view_str, des, ok_callback)
end

function TipsSpeakerView:OnClickCloseButton()
	self:Close()
end

function TipsSpeakerView:OnClickDecsButton()
	TipsCtrl.Instance:ShowHelpTipView(188)
end

function TipsSpeakerView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" and v.item_id then
			if tonumber(v.item_id) == 26907 then
				self.kuafu_toggle.toggle.isOn = true
			elseif tonumber(v.item_id) == 26908 then
				self.world_toggle.toggle.isOn = true
			end
		end
	end
end

-- 根据渠道开启跨服喇叭
function TipsSpeakerView:UpdateVoiceSwitch()
	local state = TipsData.Instance:GetKuaFuLabaState()
	if self.node_list["worldToggle"] then
		self.node_list["worldToggle"]:SetActive(state)
	end
	if self.node_list["KuafuToggle"] then
		self.node_list["KuafuToggle"]:SetActive(state)
	end
end