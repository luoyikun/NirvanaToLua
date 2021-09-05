TowerSkillRender = TowerSkillRender or BaseClass(BaseRender)

function TowerSkillRender:__init()

end

function TowerSkillRender:__delete()
	for k,v in pairs(self.skill_panel) do
		self:RemoveCountDown(k)
		v = nil
	end
	self.skill_panel = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TowerSkillRender:LoadCallBack()
	self.skill_panel = {}
	self.select_index = 1
	self.is_click = 0
	for i = 1, 4 do
		local skill = self.node_list["Gongji"].transform:Find("skill" .. i)
		self.skill_panel[i] = {}
		self.skill_panel[i].btn = skill
		self.skill_panel[i].icon = skill.transform:Find("BtnSkill")
		self.skill_panel[i].mask = skill.transform:Find("ImgMask")
		self.skill_panel[i].name = skill.transform:Find("TextName"):GetComponent(typeof(UnityEngine.UI.Text))
		self.skill_panel[i].time = self.node_list["TextTime" .. i]

		skill.transform:GetComponent(typeof(UnityEngine.UI.Button)):AddClickListener(
			BindTool.Bind2(self.SendSkill, self, i))
		self.node_list["skill" .. i].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickAttackDown, self, i))
		self.node_list["skill" .. i].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickAttackUp, self, i))
	end

	self:UpdateSkillTime()
end

function TowerSkillRender:OnFlush(param_t)
	self:UpdateSkillTime()

	local team_info = FuBenData.Instance:GetTeamTowerInfo()
	if nil ~= team_info then
		for i = 1, 4 do
			if self.skill_panel[i] and self.skill_panel[i].icon and team_info.skill_list[i] then
				self.skill_panel[i].name.text = Language.FuBen.TeamFbSkillName[team_info.skill_list[i].skill_id]
				local bundle, asset = ResPath.GetTowerSkillIcon(team_info.skill_list[i].skill_id)
				local obj = U3DObject(self.skill_panel[i].icon, self.skill_panel[i].icon.transform, self)
				obj.image:LoadSprite(bundle, asset)
				if VIRTUAL_SKILL[team_info.skill_list[i].skill_id] == nil then
					local btn_obj = U3DObject(self.skill_panel[i].btn, self.skill_panel[i].btn.transform, self)
					btn_obj.button.interactable = false
				end
			end
		end
	end
end

function TowerSkillRender:OnClickAttackDown(index)
	self.select_index = index
	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.is_click = self.is_click + 1
			if self.is_click >= 2 then
				FuBenCtrl.Instance:ShowFuBenTeamSkillExplain(self.select_index)
			end
		end, 1)
	end
end

function TowerSkillRender:OnClickAttackUp(index)
	ViewManager.Instance:Close(ViewName.FuBenTeamSkillExplain)
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TowerSkillRender:SendSkill(index)
	local team_skill_list = FuBenData.Instance:GetSkillCfg()
	local team_info = FuBenData.Instance:GetTeamTowerInfo()
	local time = 0
	if nil ~= team_info then
		local target_obj = GuajiCtrl.Instance:SelectAtkTarget(false)
		local id = team_info.skill_list[index].skill_id
		if team_info.skill_list[index].last_perform_time - TimeCtrl.Instance:GetServerTime() > 0 then
			return SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.SkillTime)
		end
		if VIRTUAL_SKILL[id] then
			if VIRTUAL_SKILL[id].pos == VIRTUAL_SKILL_EFFECT_POS.MainRole then
				target_obj = Scene.Instance:GetMainRole()
			end
		end

		if nil ~= target_obj then
			local main_role = Scene.Instance:GetMainRole()
			local main_role_x, main_role_y = main_role:GetLogicPos()
			local target_x, target_y = target_obj:GetLogicPos()

			if VIRTUAL_SKILL[id] and VIRTUAL_SKILL[id].pos == VIRTUAL_SKILL_EFFECT_POS.Target then
				local disstance = FuBenData.Instance:GetSkillDistance(id)
				if not GuajiCtrl.CheckRange(target_x, target_y, disstance) then
					return SysMsgCtrl.Instance:ErrorRemind(Language.Role.AttackDistanceFar)
				end
			end
			
			FightCtrl.SendPerformSkillReq(
				index - 1,
				0,
				target_x,
				target_y,
				target_obj:GetObjId(),
				true,
				main_role_x,
				main_role_y)
		end
		self:PlaySkillAnim(id, target_obj)
	end
end

function TowerSkillRender:PlaySkillAnim(skill_id, target_obj)
	local skill_cfg = VIRTUAL_SKILL[skill_id]
	-- 不主动播放buff特效
	if skill_cfg and skill_id ~= 10 then
		local main_role = Scene.Instance:GetMainRole()
		local target = target_obj
		if skill_cfg.pos == VIRTUAL_SKILL_EFFECT_POS.MainRole then
			target = main_role
		end

		if target then
			local part = main_role:GetDrawObj():GetPart(SceneObjPart.Main)
			local part_obj = part:GetObj()
			if part_obj ~= nil and not IsNil(part_obj.gameObject) then
				local animator = part_obj.animator
				animator:SetTrigger("attack5")
			end

			local attach_obj = target:GetRoot()
			-- 7范围持续伤害（组队塔防）3降低敌人攻击（组队塔防）
			if skill_id == 3 then
				main_role:GetDrawObj():GetRoot().transform:LookAt(attach_obj.transform.position)
				EffectManager:PlayControlEffect(self, skill_cfg.bundle, skill_cfg.asset, part_obj.transform.position, nil, part_obj.transform.rotation)
				return
			-- elseif skill_id == 7 then
			-- 	main_role:GetDrawObj():GetRoot().transform:LookAt(attach_obj.transform.position)
			-- 	EffectManager:PlayControlEffect(self, skill_cfg.bundle, skill_cfg.asset, attach_obj.transform.position)
			-- 	return
			end

			if attach_obj then
				local effect = AllocAsyncLoader(self, "skill_effect_loader_".. skill_id)
				effect:SetParent(attach_obj.transform)
				local call_back = function(effect_obj)
					if not IsNil(effect_obj) then
						effect_obj.transform.localScale = Vector3(skill_cfg.scale, skill_cfg.scale, skill_cfg.scale)
					end
				end
				effect:Load(skill_cfg.bundle, skill_cfg.asset, call_back)
				GlobalTimerQuest:AddDelayTimer(function() effect:Destroy() effect:DeleteMe() end, 5)
			end
		end
	end
end

function TowerSkillRender:UpdateSkillTime()
	local team_info = FuBenData.Instance:GetTeamTowerInfo()
	if team_info then
		for k,v in pairs(team_info.skill_list) do
			local cd = math.max(0, v.last_perform_time - TimeCtrl.Instance:GetServerTime())
			self:FlushSkillTime(k, cd, v.skill_id)
		end
	end
end

function TowerSkillRender:FlushSkillTime(index, time, id)
	if index == 1 and self.montser_count_down_list1 == nil then
		self.skill_panel[index].time:SetActive(true)
		local function diff_time_func1 (elapse_time, total_time)
			local left_time = total_time - elapse_time
			if left_time <= 0 then
				self["skill_time" .. index] = 0
				self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = 0
				self.skill_panel[index].time.text.text = 0
				self.skill_panel[index].time:SetActive(false)
				self:RemoveCountDown(index)
				return
			end

			self["skill_time" .. index] = left_time
			self.skill_panel[index].time.text.text = math.ceil(left_time)
			self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = (left_time / total_time)
		end
		diff_time_func1(0, time)
		self.montser_count_down_list1 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func1)
	end

	if index == 2 and self.montser_count_down_list2 == nil then
		self.skill_panel[index].time:SetActive(true)
		local function diff_time_func2 (elapse_time, total_time)
			local left_time = total_time - elapse_time
			if left_time <= 0 then
				self["skill_time" .. index] = 0
				self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = 0
				self.skill_panel[index].time.text.text = 0
				self.skill_panel[index].time:SetActive(false)
				self:RemoveCountDown(index)
				return
			end

			self["skill_time" .. index] = left_time
			self.skill_panel[index].time.text.text = math.ceil(left_time)
			self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = (left_time / total_time)
		end
		diff_time_func2(0, time)
		self.montser_count_down_list2 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func2)
	end

	if index == 3 and self.montser_count_down_list3 == nil then
		self.skill_panel[index].time:SetActive(true)
		local function diff_time_func3 (elapse_time, total_time)
			local left_time = total_time - elapse_time
			if left_time <= 0 then
				self["skill_time" .. index] = 0
				self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = 0
				self.skill_panel[index].time.text.text = 0
				self.skill_panel[index].time:SetActive(false)
				self:RemoveCountDown(index)
				return
			end

			self["skill_time" .. index] = left_time
			self.skill_panel[index].time.text.text = math.ceil(left_time)
			self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = (left_time / total_time)
		end
		diff_time_func3(0, time)
		self.montser_count_down_list3 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func3)
	end

	if index == 4 and self.montser_count_down_list4 == nil then
		self.skill_panel[index].time:SetActive(true)
		local function diff_time_func4 (elapse_time, total_time)
			local left_time = total_time - elapse_time
			if left_time <= 0 then
				self["skill_time" .. index] = 0
				self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = 0
				self.skill_panel[index].time.text.text = 0
				self.skill_panel[index].time:SetActive(false)
				self:RemoveCountDown(index)
				return
			end

			self["skill_time" .. index] = left_time
			self.skill_panel[index].time.text.text = math.ceil(left_time)
			self.skill_panel[index].mask:GetComponent(typeof(UnityEngine.UI.Image)).fillAmount = (left_time / total_time)
		end
		diff_time_func4(0, time)
		self.montser_count_down_list4 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func4)
	end

end

function TowerSkillRender:RemoveCountDown(index)
	if self.montser_count_down_list1 ~= nil and index == 1 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list1)
	 	self.montser_count_down_list1 = nil
	end

	if self.montser_count_down_list2 ~= nil and index == 2 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list2)
	 	self.montser_count_down_list2 = nil
	end

	if self.montser_count_down_list3 ~= nil and index == 3 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list3)
	 	self.montser_count_down_list3 = nil
	end

	if self.montser_count_down_list4 ~= nil and index == 4 then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list4)
	 	self.montser_count_down_list4 = nil
	end

end