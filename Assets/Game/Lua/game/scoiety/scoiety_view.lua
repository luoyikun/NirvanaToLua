require("game/scoiety/scoiety_team_view")
require("game/scoiety/scoiety_friend_view")
require("game/scoiety/scoiety_enemy_view")
require("game/scoiety/scoiety_mail_view")
-- require("game/scoiety/write_mail_view")


ScoietyView = ScoietyView or BaseClass(BaseView)
function ScoietyView:__init()
    self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/scoietyview_prefab", "FriendContentView", {TabIndex.society_friend}},
		{"uis/views/scoietyview_prefab", "TeamContentView", {TabIndex.society_team}},
		{"uis/views/scoietyview_prefab", "GetMailView", {TabIndex.society_mail}},
		{"uis/views/scoietyview_prefab", "EnemyContentView", {TabIndex.society_enemy}},
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
    self.play_audio = true
    self.is_async_load = false
    
    self.is_check_reduce_mem = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ScoietyView:__delete()
end

function ScoietyView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Scoiety)
	end

	if self.scoiety_team_view then
		self.scoiety_team_view:DeleteMe()
		self.scoiety_team_view = nil
	end
	if self.scoiety_friend_view then
		self.scoiety_friend_view:DeleteMe()
		self.scoiety_friend_view = nil
	end
	if self.scoiety_enemy_view then
		self.scoiety_enemy_view:DeleteMe()
		self.scoiety_enemy_view = nil
	end
	if self.scoiety_mail_view then
		self.scoiety_mail_view:DeleteMe()
		self.scoiety_mail_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function ScoietyView:LoadCallBack()
	local tab_cfg = {
		{name =	Language.Scoiety.TabbarName[1], tab_index = TabIndex.society_friend, remind_id = RemindName.ScoietyFriend}, 
		{name = Language.Scoiety.TabbarName[2], tab_index = TabIndex.society_team}, 
		{name = Language.Scoiety.TabbarName[3], tab_index = TabIndex.society_mail, remind_id = RemindName.ScoietyMail}, 
		{name = Language.Scoiety.TabbarName[4], tab_index = TabIndex.society_enemy}, 
	}

	self.tabbar = TabBarTwo.New()
	self.tabbar:Init(self, self.node_list["TabPanel"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.TabBarChangeToIndex, self))

	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.HandleClose, self))
	self.node_list["TitleText"].text.text = Language.Scoiety.Title
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Scoiety, BindTool.Bind(self.GetUiCallBack, self))
end

function ScoietyView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function ScoietyView:HandleClose()
	self:Close()
end

function ScoietyView:TabBarChangeToIndex(index)
	if IS_ON_CROSSSERVER then
		if TabIndex.society_team ~= index and index ~= TabIndex.society_enemy then
			index = TabIndex.society_team
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		end
	end
	self.tabbar:SetAllowSame(IS_ON_CROSSSERVER)
	self.tabbar:ChangeToIndex(index)
	self:ChangeToIndex(index)
end

function ScoietyView:ShowIndexCallBack(index, index_nodes)
	self.tabbar:ChangeToIndex(index)

	if index_nodes then
		if index == TabIndex.society_team then
			self.scoiety_team_view = ScoietyTeamView.New(index_nodes["TeamContentView"])
		elseif index == TabIndex.society_friend then
			self.scoiety_friend_view = ScoietyFriendView.New(index_nodes["FriendContentView"])
		elseif index == TabIndex.society_enemy then
			self.scoiety_enemy_view = ScoietyEnemyView.New(index_nodes["EnemyContentView"])
		elseif index == TabIndex.society_mail then
			self.scoiety_mail_view = ScoietyMailView.New(index_nodes["GetMailView"])
		end
	end

	if index == TabIndex.society_team then
		if self.scoiety_team_view then
			self.scoiety_team_view:FlushTeamView()
		end
	elseif index == TabIndex.society_friend then
		if self.scoiety_friend_view then
			self.friend_lot_add = self.scoiety_friend_view.friend_lot_add
			self.scoiety_friend_view:FlushFriendView()
		end
	elseif index == TabIndex.society_enemy then
		if self.scoiety_enemy_view then
			self.scoiety_enemy_view:FlushEnemyView()
		end
	elseif index == TabIndex.society_mail then
		if self.scoiety_mail_view then
			self.scoiety_mail_view:FlushMailView()
		end
	else
		--默认选中标签
		self:ChangeToIndex(TabIndex.society_friend)
	end
end

function ScoietyView:CloseCallBack()
	if self.scoiety_friend_view then
		self.scoiety_friend_view:CloseFriendView()
	end

	if self.scoiety_enemy_view then
		self.scoiety_enemy_view:CloseEnemyView()
	end

	if self.scoiety_mail_view then
		self.scoiety_mail_view:CloseMailView()
	end
end

function ScoietyView:OpenCallBack()

end

function ScoietyView:ShowWriteMailView()
	local send_mail_name = ScoietyData.Instance:GetSendName()
	if self.mail_content then
		self.mail_content:SetActive(false)
	end
	if self.write_mail_content then
		self.write_mail_content:SetActive(true)
	end
	if self.write_mail_view then
		self.write_mail_view:SetFriendName(send_mail_name)
	end
end

function ScoietyView:ShowMailView()
	if self.mail_content then
		self.mail_content:SetActive(true)
	end
	if self.write_mail_content then
		self.write_mail_content:SetActive(false)
	end
end

function ScoietyView:FlushMailLeft()
	if self.scoiety_mail_view then
		self.scoiety_mail_view:FlushLeft()
	end
end

function ScoietyView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "team"  then --and self.node_list["TabTeam"].toggle.isOn then
			if self.scoiety_team_view then
				self.scoiety_team_view:FlushTeamView()
			end
		elseif k == "friend" then --and self.node_list["TabFriend"].toggle.isOn then
			if self.scoiety_friend_view then
				self.scoiety_friend_view:FlushFriendView()
			end
		elseif k == "enemy" then --and self.node_list["TabEnemy"].toggle.isOn then
			if self.scoiety_enemy_view then
				self.scoiety_enemy_view:FlushEnemyView()
			end
		elseif k == "mail_left" then
			if self.scoiety_mail_view then
				self.scoiety_mail_view:Flush("mail_left")
			end
		elseif k == "mail_right" then
			if self.scoiety_mail_view then
				self.scoiety_mail_view:Flush("mail_right")
			end
		elseif k == "mail_all" then
			if self.scoiety_mail_view then
				self.scoiety_mail_view:Flush("mail_all")
			end
		elseif k == "mail_fetch" then
			if self.scoiety_mail_view then
				self.scoiety_mail_view:Flush("mail_fetch")
			end
		end
	end
end

function ScoietyView:ChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.society_friend then
		self.node_list["TabFriend"].toggle.isOn = true
	end
end

function ScoietyView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.society_friend then
			if self.node_list["TabFriend"].gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.ChangeToggle, self, TabIndex.society_friend)
				return self.node_list["TabFriend"], callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end