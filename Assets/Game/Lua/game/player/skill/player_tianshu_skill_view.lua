PlayerTianShuSkillView = PlayerTianShuSkillView or BaseClass(BaseRender)

local PASSIVE_SKILL_NUM = 4

function PlayerTianShuSkillView:__init(instance, parent_view)
	self.parent_view = parent_view

	self.tianshu_index = 1
	self.last_tianshu_index = 1
	self.tianshu_skill = {}								-- 被动技能
	self.tianshu_skill_data = {}

	for i = 1, PASSIVE_SKILL_NUM do
		local skill = self.node_list["PassiveSkill" .. i]
		local icon = self.node_list["PassiveSkillIcon" .. i]
		local name_lable = skill.transform:FindHard("SkillNameLable")
		local skill_name = name_lable.transform:FindHard("Name")
		local arrow = skill.transform:FindHard("Arrow")
		local effect = skill.transform:FindHard("UI_Effect")
		local animator = arrow:GetComponent(typeof(UnityEngine.Animator))
		table.insert(self.tianshu_skill, {skill = skill, icon = icon, name_lable = name_lable, skill_name = skill_name, arrow = arrow, animator = animator, effect = effect})
	end

	self.tianshu_skill_data = SkillData.Instance:GetTianShuSkillListCfg()
	self.index = 1
	self.temp_skill_id = 0
	self.tianshu_level_list = {}
	self:AddSkillListenEvent()
	self.is_click_skill = false
	self:FlushSkillState()
end

function PlayerTianShuSkillView:LoadCallBack()

end

function PlayerTianShuSkillView:__delete()
	self.is_index = nil
	self.parent_view = nil
	self.temp_skill_id = nil
	self.tianshu_skill = nil								-- 被动技能
	self.is_click_skill = nil
	self.tianshu_level_list = {}
	self.tianshu_skill_data = {}
end

function PlayerTianShuSkillView:AddSkillListenEvent()
	for k, v in pairs(self.tianshu_skill) do
		v.skill.toggle:AddClickListener(BindTool.Bind(self.OnClickSkill, self,
			self.tianshu_skill_data[k].skill_icon, self.tianshu_skill_data[k].skill_id,
			self.tianshu_skill_data[k].skill_name, k, 0.4))
	end

	self:GetSkillInfo(self.tianshu_skill_data[self.index].skill_id, self.tianshu_skill_data[self.index].skill_name, self.index)
	self.tianshu_skill[self.index].skill.toggle.isOn = true
end

function PlayerTianShuSkillView:OnClickSkill(skill_icon, skill_id, skill_name, index, delay_play_skill_time)
	self.tianshu_index = index
	self.index = index
	self.temp_skill_id = skill_id
	self.is_click_skill = true
	self:GetSkillInfo(skill_id, skill_name, index)

end

function PlayerTianShuSkillView:FlushSkillState()
	for k,v in pairs(self.tianshu_skill_data) do
		local tianshu_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
		local tianshu_skill = self.tianshu_skill[k]
		local bundle, asset = ResPath.GetRoleSkillIcon(v.skill_icon)
		tianshu_skill.icon.image:LoadSprite(bundle, asset)
		if tianshu_info then
			UI:SetGraphicGrey(tianshu_skill.icon.gameObject, false)
		else
			UI:SetGraphicGrey(tianshu_skill.icon.gameObject, true)
		end
	end
end

function PlayerTianShuSkillView:GetSkillInfo(skill_id, skill_name, index)
	if skill_id == 0 or skill_name == nil or index == nil then
		return
	end

	local skill_info = SkillData.Instance:GetSkillInfoById(skill_id)

	self.node_list["TxtPassSkillName2"].text.text = skill_name

	if skill_info == nil then
		self:SetSkillInfo( index, nil, skill_info)
	else
		-- 客户端记录的技能等级，熟练度
		local proficient = SkillData.Instance:GetSkillProficiency(skill_id)
		local level = skill_info.level
		self:SetSkillInfo(index, level, skill_info)
	end
end

function PlayerTianShuSkillView:SetSkillInfo(index, level, skill_info)
	local effect_level = level or 1
		local tianshu_info = SkillData.Instance:GetSkillInfoById(self.tianshu_skill_data[index].skill_id)
	local tianshu_skill = self.tianshu_skill[index]
	local bundle, asset = ResPath.GetRoleSkillIcon(self.tianshu_skill_data[index].skill_icon)
	tianshu_skill.icon.image:LoadSprite(bundle, asset)
	if tianshu_info then
		UI:SetGraphicGrey(tianshu_skill.icon.gameObject, false)
	else
		UI:SetGraphicGrey(tianshu_skill.icon.gameObject, true)
	end

	for k, v in pairs(self.tianshu_skill) do
		v.skill_name:GetComponent(typeof(UnityEngine.UI.Text)).text = self.tianshu_skill_data[k].skill_name
	end
	local desc = ""
	desc = string.gsub(self.tianshu_skill_data[index].skill_desc, "%[.-%]" , function(str)
		return skill_cfg[effect_level][string.sub(str, 2, -2)]
	end)
	self.tianshu_level_list[index] = tianshu_info and tianshu_info.level or 0
	self.node_list["TxtCurrentEffect1"].text.text = desc
	self.node_list["ContentText"].text.text = self.tianshu_skill_data[index].pram_1
end

function PlayerTianShuSkillView:OnClickPassiveButton(v)
	self.parent_view:SetSceneMaskState(true)
	local call_back = function()
		if self.parent_view then
			self.parent_view:SetSceneMaskState(false)
		end
	end
	UIScene:SetUISceneLoadCallBack(call_back)
	self:SetRoleFight(false)
	UIScene:SetActionEnable(true)
end

function PlayerTianShuSkillView:SetRoleFight(enable)
	UIScene:SetFightBool(enable)
end

function PlayerTianShuSkillView:DoPanelTweenPlay()
	local ui_cfg = PlayerData.Instance:GetUITweenCfg(TabIndex.role_tianshu_skill)
	UITween.MoveShowPanel(self.node_list["LeftView"], ui_cfg["LeftPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["SkillInfoInitiative"], ui_cfg["RightPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InOutSine)
end
