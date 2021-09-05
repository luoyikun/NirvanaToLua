VoiceSettingView = VoiceSettingView or BaseClass(BaseView)

local SETTING_COUNT = 4

local SettingList = {
	["world"] = 1,
	["team"] = 2,
	["guild"] = 3,
	["privite"] = 4,
}

function VoiceSettingView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/chatview_prefab", "VoiceSettingView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function VoiceSettingView:__delete()
	
end

function VoiceSettingView:ReleaseCallBack()

end

function VoiceSettingView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.Title.PinDao
	self.node_list["Bg"].rect.sizeDelta = Vector3(523,293,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnWorld"].button:AddClickListener(BindTool.Bind(self.AutoClick, self, SettingList.world))
	self.node_list["BtnTeam"].button:AddClickListener(BindTool.Bind(self.AutoClick, self, SettingList.team))
	self.node_list["BtnGuild"].button:AddClickListener(BindTool.Bind(self.AutoClick, self, SettingList.guild))
	self.node_list["BtnPrivite"].button:AddClickListener(BindTool.Bind(self.AutoClick, self, SettingList.privite))

end

function VoiceSettingView:CloseWindow()
	self.node_list["PanelItem"].animator:SetBool("show" , false)
	self:Close()
end

function VoiceSettingView:AutoClick(index)
	local state = false
	local animator = nil
	local ani_state = false
	if index == SettingList.world then
		state = ChatData.Instance:GetAutoWorldVoice()
		animator = self.node_list["WorldVoice"].animator
	elseif index == SettingList.team then
		state = ChatData.Instance:GetAutoTeamVoice()
		animator = self.node_list["TeamVoice"].animator
	elseif index == SettingList.guild then
		state = ChatData.Instance:GetAutoGuildVoice()
		animator = self.node_list["GuildVoice"].animator
	elseif index == SettingList.privite then
		state = ChatData.Instance:GetAutoPriviteVoice()
		animator = self.node_list["PriviteVoice"].animator
	end

	if animator then
		ani_state = animator:GetBool("auto")
	end

	if animator and state == ani_state then
		local new_state = not ani_state
		if index == SettingList.world then
			ChatData.Instance:SetAutoWorldVoice(new_state)
		elseif index == SettingList.team then
			ChatData.Instance:SetAutoTeamVoice(new_state)
		elseif index == SettingList.guild then
			ChatData.Instance:SetAutoGuildVoice(new_state)
		elseif index == SettingList.privite then
			ChatData.Instance:SetAutoPriviteVoice(new_state)
		end
		animator:SetBool("auto", new_state)
	end
end

function VoiceSettingView:RefeshSetting()
	for index = 1, SETTING_COUNT do
		local state = false
		local animator = nil
		local ani_state = false

		if index == SettingList.world then
			state = ChatData.Instance:GetAutoWorldVoice()
			animator = self.node_list["WorldVoice"].animator
		elseif index == SettingList.team then
			state = ChatData.Instance:GetAutoTeamVoice()
			animator = self.node_list["TeamVoice"].animator
		elseif index == SettingList.guild then
			state = ChatData.Instance:GetAutoGuildVoice()
			animator = self.node_list["GuildVoice"].animator
		elseif index == SettingList.privite then
			state = ChatData.Instance:GetAutoPriviteVoice()
			animator = self.node_list["PriviteVoice"].animator
		end

		if animator then
			ani_state = animator:GetBool("auto")
		end

		if animator and state ~= ani_state then
			animator:SetBool("auto", state)
		end
	end
end

function VoiceSettingView:OpenCallBack()
	self:RefeshSetting()
end

function VoiceSettingView:CloseCallBack()

end