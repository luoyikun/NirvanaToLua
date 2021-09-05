-- 礼物收割-技能
-- Gift_Fuben_Skill

GiftSkillView = GiftSkillView or BaseClass(BaseRender)

function GiftSkillView:__init()

end

function GiftSkillView:LoadCallBack()
	self.skill_time_list = {}
	self.skill_time_text_list = {}
	for i = 1, 3 do
		self.node_list["GongJi" .. i].button:AddClickListener(BindTool.Bind(self.SendSkill, self, i))
		self.skill_time_list[i] = self.node_list["skill_time_" .. i]
		self.skill_time_text_list[i] = self.node_list["skill_time_text" .. i]
	end
end

function GiftSkillView:__delete()
	for i = 1, 3 do
		self:RemoveCountDown(i)
		self.skill_time_list[i] = nil
		self.skill_time_text_list[i] = nil
	end
	self.skill_time_list = {}
	self.skill_time_text_list = {}
end

function GiftSkillView:OpenCallBack()

end

function GiftSkillView:OnFlush(param_t)
	self:UpdateSkillTime()
end

function GiftSkillView:SendSkill(index)
	local target_obj = GuajiCtrl.Instance:SelectAtkTarget(false)
	if nil ~= target_obj then
		local main_role = Scene.Instance:GetMainRole()
		local main_role_x, main_role_y = main_role:GetLogicPos()
		local target_x, target_y = target_obj:GetLogicPos()
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
end

function GiftSkillView:PlaySkillAnim(skill_id, target_obj)
	local skill_cfg = VIRTUAL_SKILL[skill_id]
	if skill_cfg then
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
			if attach_obj then
				local effect = AsyncLoader.New(attach_obj.transform)
				local call_back = function(effect_obj)
					if effect_obj then
						effect_obj.transform.localScale = Vector3(skill_cfg.scale, skill_cfg.scale, skill_cfg.scale)
					end
				end
				effect:Load(skill_cfg.bundle, skill_cfg.asset, call_back)
				GlobalTimerQuest:AddDelayTimer(function() effect:Destroy() effect:DeleteMe() end, 5)
			end
		end
	end
end

function GiftSkillView:UpdateSkillTime()
	local skill_data = ChristmaGiftData.Instance:GetSkillData()
	if not skill_data or not skill_data.next_perform_timestamp then return end
	local cd = math.max(0, skill_data.next_perform_timestamp - TimeCtrl.Instance:GetServerTime())
	self:FlushSkillTime(skill_data.id - 700 , cd, skill_data.id)
end

function GiftSkillView:FlushSkillTime(index,time,id)
	self:RemoveCountDown(index)
	if index == 1 then
		self.skill_time_text_list[index]:SetActive(true)
		local function diff_time_func1 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				-- self["skill_time" .. index] = 0
				self.skill_time_text_list[index].text.text = 0
				self.skill_time_list[index].image.fillAmount = 0
				self.skill_time_text_list[index]:SetActive(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			-- self["skill_time" .. index] = left_time
			self.skill_time_text_list[index].text.text = left_sec
			self.skill_time_list[index].image.fillAmount = left_time / ChristmaGiftData.Instance:GetSkillCD(id)
		end
		diff_time_func1(0, time)
		self.montser_count_down_list1 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func1)
	end

	if index == 2 then
		self.skill_time_text_list[index]:SetActive(true)
		local function diff_time_func2 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				-- self["skill_time" .. index] = 0
				self.skill_time_text_list[index].text.text = 0
				self.skill_time_list[index].image.fillAmount = 0
				self.skill_time_text_list[index]:SetActive(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			-- self["skill_time" .. index] = left_time
			self.skill_time_text_list[index].text.text = left_sec
			self.skill_time_list[index].image.fillAmount = left_time / ChristmaGiftData.Instance:GetSkillCD(id)
		end
		diff_time_func2(0, time)
		self.montser_count_down_list2 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func2)
	end

	if index == 3 then
		self.skill_time_text_list[index]:SetActive(true)
		local function diff_time_func3 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				-- self["skill_time" .. index] = 0
				self.skill_time_text_list[index].text.text = 0
				self.skill_time_list[index].image.fillAmount = 0
				self.skill_time_text_list[index]:SetActive(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			-- self["skill_time" .. index] = left_time
			self.skill_time_text_list[index].text.text = left_sec
			self.skill_time_list[index].image.fillAmount = left_time / ChristmaGiftData.Instance:GetSkillCD(id)
		end
		diff_time_func3(0, time)
		self.montser_count_down_list3 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func3)
	end

	if index == 4 then
		self["hide_text" .. index]:SetValue(true)
		local function diff_time_func4 (elapse_time, total_time)
			local left_time = total_time - elapse_time + 0.05
			if left_time <= 0.05 then
				-- self["skill_time" .. index] = 0
				self.skill_time_text_list[index].text.text = 0
				self.skill_time_list[index].image.fillAmount = 0
				self["hide_text" .. index]:SetValue(false)
				self:RemoveCountDown(index)
				return
			end
			local left_sec = math.floor(left_time)
			if left_sec < 1 then
				left_sec = 1
			end
			-- self["skill_time" .. index] = left_time
			self.skill_time_text_list[index].text.text = left_sec
			self.skill_time_list[index].image.fillAmount = left_time / TeamFbData.Instance:SetTeamTowerDefendSkillCD(id)
		end
		diff_time_func4(0, time)
		self.montser_count_down_list4 = CountDown.Instance:AddCountDown(time, 0.05, diff_time_func4)
	end

end

function GiftSkillView:RemoveCountDown(index)
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