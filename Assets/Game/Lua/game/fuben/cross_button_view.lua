-- 跨服 组队 求救按钮
CrossButtonView = CrossButtonView or BaseClass(BaseView)

local SceneButtonHelp = {
	[SceneType.CrossBoss] = GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_BOSS,				-- 跨服远古BOSS
	[SceneType.KFMiZangBoss] = GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_MIZANG_BOSS,		-- 跨服神域BOSS
	[SceneType.VipFB] = GUILD_SOS_TYPE.GUILD_SOS_TYPE_CROSS_VIP_BOSS				-- 跨服VIPBOSS
}

function CrossButtonView:__init()
	self.ui_config = {
		{"uis/views/fubenview_prefab", "CrossButtonView"},
	}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUI
end

function CrossButtonView:ReleaseCallBack()
	if self.help_skill_render then
		self.help_skill_render:DeleteMe()
		self.help_skill_render = nil
	end

	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
end

function CrossButtonView:OpenCallBack()
	local shake = not ScoietyData.Instance.have_team
	if shake then
		if self.count_down_quest == nil then
			self.count_down_quest = GlobalTimerQuest:AddRunQuest(function ()
				local have_team = not ScoietyData.Instance.have_team
				if have_team then
					self.node_list["BtnTeam"].animator:SetTrigger("shake")
				end
			end, 5)
		end
	end
	self:Flush()
end

function CrossButtonView:CloseCallBack()
	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end
end

function CrossButtonView:LoadCallBack()
	self.node_list["BtnTeam"].button:AddClickListener(BindTool.Bind(self.OnClickBtnTeam, self))
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:ShowButton()
end

function CrossButtonView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["BtnTeam"]:SetActive(state)
end

function CrossButtonView:OnFlush(param_t)
	local num = ScoietyData.Instance:GetTeamNum()
	self.node_list["Img_add"]:SetActive(num <= 0)
	num = num ~= 0 and num or ""
	self.node_list["Txt_Num"].text.text = num
end

function CrossButtonView:OnClickBtnTeam()
	-- local param_t = {}
	-- param_t.must_check = 0
	-- param_t.assign_mode = 1
	-- ScoietyCtrl.Instance:CreateTeamReq(param_t)

	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end
end

function CrossButtonView:ShowButton()
	if SceneType.KF_Borderland == Scene.Instance:GetSceneType() then
		return
	end

	local loader = AllocAsyncLoader(self, "cross_button_view_loader")
	loader:Load("uis/views/fubenview_prefab", "CrossButtonSkill", function (obj)
		if IsNil(obj) then
			return
		end
		MainUICtrl.Instance:ShowActivitySkill(obj)
		if self.help_skill_render then
			self.help_skill_render:DeleteMe()
			self.help_skill_render = nil
		end
		self.help_skill_render = CrossHelpSkillRender.New(obj)
	end)
end

--------------------------------------------------
-- 求救
--------------------------------------------------
CrossHelpSkillRender = CrossHelpSkillRender or BaseClass(BaseRender)
function CrossHelpSkillRender:__delete()
end

function CrossHelpSkillRender:LoadCallBack()
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClickButtonHelp, self))
end

function CrossHelpSkillRender:OnClickButtonHelp()
	local sos_type = SceneButtonHelp[Scene.Instance:GetSceneType()]
	if sos_type then
		GuildCtrl.Instance:SendSendGuildSosReq(sos_type)
	end
end

function CrossHelpSkillRender:OnFlush(param_t)

end
