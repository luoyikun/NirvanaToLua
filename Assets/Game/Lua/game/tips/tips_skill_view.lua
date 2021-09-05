TipSkillView = TipSkillView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function TipSkillView:__init()
	self.ui_config = {{"uis/views/tips/skilltip_prefab", "SkillTip"}}
	self.view_layer = UiLayer.Pop
	self.skill_id = 0
	self.skill_level = 0
	self.has_active = 0
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

-- 创建完调用
function TipSkillView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnClickCloseButton, self))
end

function TipSkillView:OnClickCloseButton()
	self:Close()
end

function TipSkillView:SetData(skill_id, skill_level, has_active)
	self.skill_id = skill_id
	self.skill_level = skill_level
	self.has_active = has_active == nil and true or has_active
	if self.skill_id > 0 then
		self:Open()
		self:Flush()
	end
end

function TipSkillView:OnFlush(param_list)
	local IsActive = self.has_active and "" or string.format("<color=#89F201>(%s)</color>", Language.Common.NoActivate)
	self.node_list["TxtLevel"].text.text = string.format(Language.Tips.MoJieTisLevel, self.skill_level)
	local skill_type = self.skill_id ~= PASSIVE_TYPE and Language.Common.ZhuDongSkill or Language.Common.BeiDongSkill
	self.node_list["TxtSkillType"].text.text = skill_type
	local skill_cfg = SkillData.GetSkillinfoConfig(self.skill_id)
	if skill_cfg then
		self.node_list["TxtIcon"].image:LoadSprite(ResPath.GetRoleSkillIcon(skill_cfg.skill_icon))
		self.node_list["TxtProName"].text.text = string.format(Language.Tips.MoJieProName, skill_cfg.skill_name, IsActive)
		self.node_list["TxtCurrentEffect"].text.text = SkillData.RepleCfgContent(self.skill_id, self.skill_level)
	end
end