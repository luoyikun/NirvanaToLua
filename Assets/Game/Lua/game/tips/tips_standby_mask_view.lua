TipsStandbyMaskView = TipsStandbyMaskView or BaseClass(BaseView)

function TipsStandbyMaskView:__init()
	self.ui_config = {{"uis/views/tips/standbymasktips_prefab", "StandbyMaskView"}}
	self.close_mode = CloseMode.CloseVisible
	self.view_layer = UiLayer.Standby
	self.play_audio = true
	self.is_modal = true
end

function TipsStandbyMaskView:LoadCallBack()
	
end

function TipsStandbyMaskView:SetCallback(call_back)
	self.click_call_back = call_back
end

function TipsStandbyMaskView:OnClickHide()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		scene_logic:OnTouchScreen()
	end

	if self.click_call_back then
		self.click_call_back()
		self.click_call_back = nil
	end

	self:Close()
end