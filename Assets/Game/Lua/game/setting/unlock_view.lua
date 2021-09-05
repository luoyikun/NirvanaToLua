-- 锁屏
UnlockView = UnlockView or BaseClass(BaseView)

local UnityApplication = UnityEngine.Application
local UnityRuntimePlatform = UnityEngine.RuntimePlatform

function UnlockView:__init()
	self.view_layer = UiLayer.Standby
	self.ui_config = {{"uis/views/settingview_prefab", "LuckScreenView"}}
end

function UnlockView:LoadCallBack()
	self.node_list["Slider"].slider.onValueChanged:AddListener(BindTool.Bind(self.OnSliderChange, self))

	local listener = self.node_list["Slider"].event_trigger_listener
	listener:AddPointerDownListener(BindTool.Bind(self.TouchDownEvent, self))
	listener:AddPointerUpListener(BindTool.Bind(self.TouchUpEvent, self))

	self.slider_value = 0
	self.node_list["Slider"].slider.value = 0
end

function UnlockView:ReleaseCallBack()
	
end

function UnlockView:OpenCallBack()
	self.slider_value = 0
	SettingCtrl.Instance:RemoveTimer()

	local main_fight_state = MainUICtrl.Instance:GetFightToggleState()
	SettingData.Instance:SetFightToggleState(not main_fight_state)
	if not main_fight_state then
		GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	end

	-- -- 打开锁屏的时候手机帧频降到15
	-- local platform = UnityApplication.platform
	-- if platform == UnityRuntimePlatform.IPhonePlayer or platform == UnityRuntimePlatform.Android then
	-- 	UnityApplication.targetFrameRate = 25
	-- end
end

function UnlockView:CloseCallBack()
	self.slider_value = 0
	self.node_list["Slider"].slider.value = 0

	if SettingData.Instance:GetNeedLuckView() then
		SettingCtrl.Instance:AddTimer()
	end

	-- 取消锁屏的时候手机帧频恢复到30
	local platform = UnityApplication.platform
	if platform == UnityRuntimePlatform.IPhonePlayer or platform == UnityRuntimePlatform.Android then
		UnityApplication.targetFrameRate = GAME_FPS
	end
end

function UnlockView:TouchUpEvent()
	self.node_list["Slider"].slider:DOValue(0, 0.1, false)
end

function UnlockView:TouchDownEvent()
end

function UnlockView:OnSliderChange(value)
	self.slider_value = value
	self.node_list["ShowImage"].image.color = Color.New(1, 1, 1, 1 - value)
	if value == 1 then
		local screen_bright = SettingData.Instance:GetScreenBright()
		if screen_bright > 0 then
			DeviceTool.SetScreenBrightness(screen_bright)
		end
		local fight_toggle_state = SettingData.Instance:GetFightToggleState()
		if fight_toggle_state then
			GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
		end
		self:Close()
	end
end

function UnlockView:OnFlush()
end