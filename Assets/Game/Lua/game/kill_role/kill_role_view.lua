KillRoleView = KillRoleView or BaseClass(BaseView)

function KillRoleView:__init(instance)
	self.ui_config = {{"uis/views/killroleview_prefab", "KillRoleView"}}
	self.be_kill_role_vo = {}
	self.close_delay_time = 5
end

function KillRoleView:LoadCallBack()
	self.main_role_list = {
		level_and_name = self.node_list["TxtKillInfo"],
		fight_power = self.node_list["TxtKillFightPower"],
		normal_img = self.node_list["ImgKillPortrait"],
		raw_image = self.node_list["RawKillPortrait"],
	}

	self.be_kill_role_list = {
		level_and_name = self.node_list["TxtBeKillInfo"],
		fight_power = self.node_list["TxtBeKillFightPower"],
		normal_img = self.node_list["ImgBeKillPortrait"],
		raw_image = self.node_list["RawBeKillPortrait"],
	}
end

function KillRoleView:ReleaseCallBack()
	-- 清理变量
	self.main_role_list = {}
	self.be_kill_role_list = {}
	self.be_kill_role_vo = {}
end

function KillRoleView:OpenCallBack()
	self.close_delay_time = 5
	self:Flush()
end

function KillRoleView:CloseCallBack()
	self:RemoveCountDown()
end

function KillRoleView:SetBeKillRoleVo(be_kill_role_vo)
	self.be_kill_role_vo = be_kill_role_vo or {}
end

function KillRoleView:SetMainRoleInfo()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	self:SetInfo(game_vo, self.main_role_list)
end

function KillRoleView:SetBekillRoleInfo()
	self:SetInfo(self.be_kill_role_vo, self.be_kill_role_list)
end

function KillRoleView:SetInfo(role_vo, var_list)
	if nil == next(role_vo) then
		return
	end
	local game_vo = role_vo
	var_list.level_and_name.text.text = string.format("LV.%s %s", game_vo.level, game_vo.name)
	if nil ~= game_vo.capability then
		var_list.fight_power.text.text = game_vo.capability + game_vo.other_capability
	else
		var_list.fight_power.text.text = game_vo.total_capability
	end
	var_list.normal_img:SetActive(AvatarManager.Instance:isDefaultImg(game_vo.role_id) == 0)
	var_list.raw_image:SetActive(AvatarManager.Instance:isDefaultImg(game_vo.role_id) ~= 0)

	AvatarManager.Instance:SetAvatar(game_vo.role_id, var_list.raw_image, var_list.normal_img, game_vo.sex, game_vo.prof, true)
end

function KillRoleView:SetCloseDelay()
	self:RemoveCountDown()
	self.delay_close = GlobalTimerQuest:AddRunQuest(
		function ()
			self:Close()
		end, self.close_delay_time)
end

function KillRoleView:RemoveCountDown()
	if nil ~= self.delay_close then
		GlobalTimerQuest:CancelQuest(self.delay_close)
		self.delay_close = nil
	end
end

function KillRoleView:OnFlush()
	self:SetMainRoleInfo()
	self:SetBekillRoleInfo()
	self:SetCloseDelay()
end