BianShenSkillTipView = BianShenSkillTipView or BaseClass(BaseView)

function BianShenSkillTipView:__init()
	self.ui_config = {{"uis/views/bianshen_prefab", "SkillTipView"}}

	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function BianShenSkillTipView:ReleaseCallBack()
	
end

function BianShenSkillTipView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function BianShenSkillTipView:OpenCallBack()

end

function BianShenSkillTipView:SetData(skill_id, select_role_index, is_passivity_skill, is_special_skill)
	self.data = {}
	self.data.skill_id = skill_id
	self.data.select_role_index = select_role_index
	self.data.is_passivity_skill = is_passivity_skill
	self.data.is_special_skill = is_special_skill
	self:Flush()
end

function BianShenSkillTipView:OnFlush()
	if not self.data.is_passivity_skill then
			local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").skillinfo[self.data.skill_id]
			if not skill_cfg or not next(skill_cfg) then return end

			self.node_list["IconSkill"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. self.data.skill_id))
			self.node_list["TxtProName"].text.text = skill_cfg.skill_name
			self.node_list["TxtCurrent"].text.text = skill_cfg.skill_desc
			self.node_list["TxtSkillType"].text.text =  Language.BianShen.SkillTypeOne
	else
		if not self.data.is_special_skill then
			local each_passive_cfg = BianShenData.Instance:GetsinglePassive(self.data.select_role_index - 1)
			self.node_list["IconSkill"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. each_passive_cfg.icon_id))
			self.node_list["TxtProName"].text.text = each_passive_cfg.skill_name
			self.node_list["TxtCurrent"].text.text = each_passive_cfg.skill_tips or ""
			self.node_list["TxtSkillType"].text.text =  Language.BianShen.SkillTypeTwo
		else
			local select_cfg = BianShenData.Instance:GetSingleDataBySeq(self.data.select_role_index - 1)
			local select_info = BianShenData.Instance:GetGeneralSingleInfoBySeq(select_cfg.seq)
			if select_cfg and select_info then
				local level = select_info.potential_level > 0 and select_info.potential_level or 1
				local potential_cfg = BianShenData.Instance:GetSinglePotentialCfg(select_cfg.seq, level)
				local special_skill_cfg = nil
				if potential_cfg and potential_cfg.special_skill_level then
					local skill_level = potential_cfg.special_skill_level <= 0 and 1 or potential_cfg.special_skill_level
					special_skill_cfg = BianShenData.Instance:GetSpecialSkillInfoByTypeLevel(select_cfg.active_skill_type, skill_level)
				end
				if special_skill_cfg then
					self.node_list["IconSkill"].image:LoadSprite(ResPath.GetFamousGeneral("Skill_" .. special_skill_cfg.icon_id))
					self.node_list["TxtProName"].text.text = special_skill_cfg.skill_name
					self.node_list["TxtCurrent"].text.text = special_skill_cfg.skill_tips or ""
					self.node_list["TxtSkillType"].text.text =  Language.BianShen.SkillTipTwo
				end
			end
		end
	end
end

