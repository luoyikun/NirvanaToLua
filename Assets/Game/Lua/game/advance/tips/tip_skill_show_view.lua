TipSkillShowView = TipSkillShowView or BaseClass(BaseView)

function TipSkillShowView:__init()
	self.ui_config = {{"uis/views/tips/advancetips_prefab", "SkillShowTip"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

end

-- 创建完调用
function TipSkillShowView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function TipSkillShowView:ReleaseCallBack()

end

function TipSkillShowView:CloseCallBack()
	self.show_type = nil
	self.skill_data = nil
end

function TipSkillShowView:__delete()

end

function TipSkillShowView:OpenCallBack()
	self:Flush()
end

function TipSkillShowView:SetShowSkillData(data, show_type)
	self.skill_data = data
	self.show_type = show_type
	self:Open()
end

function TipSkillShowView:OnFlush()
	if self.show_type == "shengwu_skill" then
		self:SetShengWuSkillShow()
	end
end

-- 仙女仙器技能
function TipSkillShowView:SetShengWuSkillShow()
	local select_index = self.skill_data.select_index
	if not select_index then return end

	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(select_index)
	local shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(select_index, shengwu_level)
	if not info_data then return end

	local skill_level = info_data.skill_level
	local now_skill_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(info_data.skill_id, skill_level)
	if not now_skill_data then return end

	local next_skill_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(info_data.skill_id, skill_level + 1)
	local next_skill_info = GoddessData.Instance:GetShengwuCfgBySkillLevel(select_index, skill_level + 1)

	local bundle, asset = ResPath.GetSkillIcon("shengwu_skill_" .. (select_index + 1))
	self.node_list["ImgNIcon"].image:LoadSprite(bundle, asset)

	local is_active_text = skill_level == 0 and Language.Mount.NotActive or ""
	self.node_list["TxtNProName"].text.text = string.format("%s   %s", now_skill_data.name, is_active_text)
	self.node_list["TxtNSkillLevel"].text.text = string.format(Language.Advance.TipSkillUpgradeViewLevel, skill_level)

	if next_skill_data then
		self.node_list["TxtNNextEft"].text.text = next_skill_data.skill_desc
		local desc = (skill_level == 0) and Language.Common.Activate and Language.Common.Up
		self.node_list["TxtNomalUpLevelTip"].text.text = string.format(Language.Goddess.ShengWuSkillUpLevel, next_skill_info.level, desc)

		self.node_list["NextEffect"]:SetActive(true)
		self.node_list["EffectNomeralSkill"]:SetActive(false)
	else
		self.node_list["TxtCurNEft"].text.text = now_skill_data.skill_desc
		self.node_list["TxtNomalUpLevelTip"].text.text = Language.Common.YiManJi

		self.node_list["NextEffect"]:SetActive(false)
		self.node_list["EffectNomeralSkill"]:SetActive(true)
	end
end

