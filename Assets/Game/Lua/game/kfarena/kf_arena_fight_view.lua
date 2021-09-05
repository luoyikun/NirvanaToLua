KFArenaFightView = KFArenaFightView or BaseClass(BaseRender)

function KFArenaFightView:LoadCallBack(instance)
	if instance == nil then
		return
	end

	self.role_one = ArenaFightRole.New(self.node_list["RoleInfo"])
	self.role_two = ArenaFightRole.New(self.node_list["RoleInfo2"])
	self.hp_slider_top_self = self.role_one.node_list["HPTop"].slider
	self.hp_slider_bottom_self = self.role_one.node_list["HPBottom"].slider
	self.hp_slider_top_target = self.role_two.node_list["HPTop"].slider
	self.hp_slider_bottom_target = self.role_two.node_list["HPBottom"].slider

	self.target_obj = nil
	self.node_list["TxtRestTime"].text.text = ""
	self.listen_hp = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.listen_hp)

	self:Flush()
end

function KFArenaFightView:__delete()
	self:RemoveCountDown()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.role_one = nil
	self.role_two = nil
end

function KFArenaFightView:CloseCallBack()
	self:RemoveCountDown()
	self.node_list["TxtRestTime"].text.text = ""
end

function KFArenaFightView:OpenCallBack()
	local main_role = Scene.Instance:GetMainRole()
	main_role:RotateTo(180)
end

function KFArenaFightView:OnFlush()
	self:HeadChangeSelf()
	self:FlushBaseInfo()
end

function KFArenaFightView:StartCountDown()
	if self.count_down then
		return
	end
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	self.node_list["TxtTime"].text.text = 3
	self.node_list["TxtFightPowerNum"]:SetActive(true)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, self.node_list["TxtTime"]))
end

function KFArenaFightView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KFArenaFightView:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
	end
	time_obj.text.text = time
end

function KFArenaFightView:StartFight()
	self.node_list["TxtFightPowerNum"]:SetActive(false)
	self:RemoveCountDown()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local time = math.floor(KFArenaData.Instance:GetFightTime() - TimeCtrl.Instance:GetServerTime())
	self.node_list["TxtRestTime"].text.text = time
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self,self.node_list["TxtRestTime"]))
end

function KFArenaFightView:FlushBaseInfo()
	local target_info = KFArenaData.Instance:GetEnemyUserInfo()
	if target_info then
		self.level_target = PlayerData.GetLevelString(target_info.level)
		local role_info = KFArenaData.Instance:GetRoleInfoByUid(target_info.role_id)
		if role_info and role_info.server_id ~= 0 then
			self.role_two.node_list["NameTxt"].text.text = string.format(Language.KFArena.NameWithSever, target_info.name, role_info.server_id)
		else
			self.role_two.node_list["NameTxt"].text.text = target_info.name
		end
		self.role_two.node_list["LevelTxt"].text.text = "Lv." .. self.level_target
		local base_prof = PlayerData.Instance:GetRoleBaseProf(target_info.prof)
		local bundle, asset = ResPath.GetRoleHeadBig(base_prof, target_info.sex)
		self.role_two.node_list["IconImg"].image:LoadSprite(bundle, asset .. ".png")
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.level_self = PlayerData.GetLevelString(vo.level)
	self.name_self = vo.name
	if vo.merge_server_id ~= 0 then
		self.role_one.node_list["NameTxt"].text.text = string.format(Language.KFArena.NameWithSever, self.name_self, vo.merge_server_id)
	else
		self.role_one.node_list["NameTxt"].text.text = self.name_self
	end
	self.role_one.node_list["LevelTxt"].text.text = "Lv." .. vo.level

	if vo.max_hp ~= nil and vo.max_hp > 0 then
		self:SetHpPercent(vo.hp / vo.max_hp, true)
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.target_obj then
		self.target_obj = nil
	end
	self:TimerCallback()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 0.3)
end


function KFArenaFightView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.max_hp ~= nil and vo.max_hp > 0 then
			self:SetHpPercent(vo.hp / vo.max_hp, true)
		end
	end
end

-- 目标血量改变
function KFArenaFightView:TimerCallback()
	if not self.target_obj then
		self.target_obj = self:GetTargetObj()
	end
	if self.target_obj then
		local target_hp = self.target_obj:GetAttr("hp")
		local max_hp = self.target_obj:GetAttr("max_hp")
		if max_hp ~= nil and max_hp > 0 then
			self:SetHpPercent(target_hp / max_hp, false)
		end
	end
end

-- 设置目标血条
function KFArenaFightView:SetHpPercent(percent, is_self)
	if is_self then
		self.hp_slider_top_self.value = percent
		self.hp_slider_bottom_self:DOValue(percent, 0.8, false)
	else
		self.hp_slider_top_target.value = percent
		self.hp_slider_bottom_target:DOValue(percent, 0.8, false)
	end
end

-- 得到目标obj
function KFArenaFightView:GetTargetObj()
	local obj_list = Scene.Instance:GetObjList()
	if obj_list then
		for k,v in pairs(obj_list) do
			if v:IsRole() and not v:IsMainRole() then
				local vo = v:GetVo()
				self:HeadChangeTarget(vo)
				return v
			end
		end
	end
end

-- 头像更换
function KFArenaFightView:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:SetAvatar(vo.role_id, self.node_list["portraitRawSelf"], self.node_list["portraitSelf"], vo.sex, vo.prof, true)
end

-- 对手头像更换
function KFArenaFightView:HeadChangeTarget(vo)
	local base_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
	local bundle, asset = ResPath.GetRoleHeadBig(base_prof, vo.sex)
	self.role_two.node_list["IconImg"].image:LoadSprite(bundle, asset .. ".png")
end