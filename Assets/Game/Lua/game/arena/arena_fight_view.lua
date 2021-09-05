ArenaFightView = ArenaFightView or BaseClass(BaseRender)

function ArenaFightView:LoadCallBack(instance)
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

function ArenaFightView:__delete()
	self:RemoveCountDown()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if nil ~= self.role_one then 
		self.role_one:DeleteMe()
		self.role_one = nil
	end
	if nil ~= self.role_two then 
		self.role_two:DeleteMe()
		self.role_two = nil
	end
end

function ArenaFightView:CloseCallBack()
	self:RemoveCountDown()
	self.node_list["TxtRestTime"].text.text = ""
end

function ArenaFightView:OpenCallBack()
	local main_role = Scene.Instance:GetMainRole()
	main_role:RotateTo(180)
end

function ArenaFightView:OnFlush()
	self:HeadChangeSelf()
	self:FlushBaseInfo()
end

function ArenaFightView:StartCountDown()
	if self.count_down then
		return
	end
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	self.node_list["TxtTime"].text.text = 3
	self.node_list["TxtFightPowerNum"]:SetActive(true)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, self.node_list["TxtTime"]))
end

function ArenaFightView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ArenaFightView:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
	end
	time_obj.text.text = time
end

function ArenaFightView:StartFight()
	self.node_list["TxtFightPowerNum"]:SetActive(false)
	self:RemoveCountDown()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local time = math.floor(ArenaData.Instance:GetFightTime() - TimeCtrl.Instance:GetServerTime())
	self.node_list["TxtRestTime"].text.text = time
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self,self.node_list["TxtRestTime"]))
end

function ArenaFightView:FlushBaseInfo()
	local target_info = ArenaData.Instance:GetEnemyUserInfo()
	if target_info then
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(target_info.level)
		-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.level_target = PlayerData.GetLevelString(target_info.level)
		self.name_target = target_info.name
		self.role_two.node_list["NameTxt"].text.text = self.name_target
		self.role_two.node_list["LevelTxt"].text.text = "Lv." .. self.level_target	--string.format("<color=#89F201FF>Lv.%s</color>", self.level_target)
		local base_prof = PlayerData.Instance:GetRoleBaseProf(target_info.prof)
		local bundle, asset = ResPath.GetRoleHeadBig(base_prof, target_info.sex)
		self.role_two.node_list["IconImg"].image:LoadSprite(bundle, asset .. ".png")
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(vo.level)
	-- local level = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	self.level_self = PlayerData.GetLevelString(vo.level)
	self.name_self = vo.name
	self.role_one.node_list["NameTxt"].text.text = self.name_self
	self.role_one.node_list["LevelTxt"].text.text = "Lv." .. vo.level	--string.format("<color=#89F201FF>Lv.%s</color>", vo.level)

	-- local vo = GameVoManager.Instance:GetMainRoleVo()
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


function ArenaFightView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.max_hp ~= nil and vo.max_hp > 0 then
			self:SetHpPercent(vo.hp / vo.max_hp, true)
		end
	end
end

-- 目标血量改变
function ArenaFightView:TimerCallback()
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
function ArenaFightView:SetHpPercent(percent, is_self)
	if is_self then
		self.hp_slider_top_self.value = percent
		self.hp_slider_bottom_self:DOValue(percent, 0.8, false)
	else
		self.hp_slider_top_target.value = percent
		self.hp_slider_bottom_target:DOValue(percent, 0.8, false)
	end
end

-- 得到目标obj
function ArenaFightView:GetTargetObj()
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
function ArenaFightView:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	AvatarManager.Instance:SetAvatar(vo.role_id, self.node_list["portraitRawSelf"], self.node_list["portraitSelf"], vo.sex, vo.prof, true)
end

-- 对手头像更换
function ArenaFightView:HeadChangeTarget(vo)
	local base_prof = PlayerData.Instance:GetRoleBaseProf(vo.prof)
	local bundle, asset = ResPath.GetRoleHeadBig(base_prof, vo.sex)
	self.role_two.node_list["IconImg"].image:LoadSprite(bundle, asset .. ".png")
end
ArenaFightRole = ArenaFightRole or BaseClass(BaseRender)