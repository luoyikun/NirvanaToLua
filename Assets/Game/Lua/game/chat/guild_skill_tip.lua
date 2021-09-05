GuildSkillTip = GuildSkillTip or BaseClass(BaseView)
function GuildSkillTip:__init()
	self.ui_config = {
		{"uis/views/chatview_prefab", "SkillDesTip"}
	}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildSkillTip:__delete()

end

function GuildSkillTip:ReleaseCallBack()

end

function GuildSkillTip:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function GuildSkillTip:CloseWindow()
	self:Close()
end

function GuildSkillTip:OpenCallBack()

end

function GuildSkillTip:CloseCallBack()

end
