KuaFuBossSwFightView = KuaFuBossSwFightView or BaseClass(BaseView)

function KuaFuBossSwFightView:__init()
	self.ui_config = {
			{"uis/views/kuafuliujie_prefab","KuaFuBossSwFightView"},
	}
	self.active_close = false
	self.click_flag = false
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.last_remind_time = 0
end

function KuaFuBossSwFightView:ReleaseCallBack()
	
end

function KuaFuBossSwFightView:LoadCallBack()

end

function KuaFuBossSwFightView:ClickInfo()

end

function KuaFuBossSwFightView:ClickBoss()

end

function KuaFuBossSwFightView:CloseCallBack()

end

function KuaFuBossSwFightView:FlushTabHl(show_boss)

end

function KuaFuBossSwFightView:OpenCallBack()

end

function KuaFuBossSwFightView:SetRendering(value)

end

function KuaFuBossSwFightView:PortraitToggleChange(state)

end

function KuaFuBossSwFightView:OnFlush(param_t)

end

function KuaFuBossSwFightView:SwitchButtonState(enable)

end

function KuaFuBossSwFightView:FlushExitTime()

end

function KuaFuBossSwFightView:UpdateExitTime()

end

function KuaFuBossSwFightView:CanCelExitQuest()

end

function KuaFuBossSwFightView:ClickTeam()

end
