TipsShowSkillView = TipsShowSkillView or BaseClass(BaseView)

local SKILL_TIPS_FROM_SHENBING = 0
local SKILL_TIPS_FROM_CLOAK = 1

SKILL_TIP_FROM_VIEW_TYPE = {
	["shenbing"] = SKILL_TIPS_FROM_SHENBING, 
	["cloak"] = SKILL_TIPS_FROM_CLOAK, 
}

function TipsShowSkillView:__init()
	self.ui_config = {{"uis/views/tips/showskilltips_prefab", "ShowSkillTip"}}
	self.play_audio = true
	self.from_view = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsShowSkillView:ReleaseCallBack()
	self.skill_idx = -1
	self.from_view = 0
end

function TipsShowSkillView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.CloseClick, self))
end

function TipsShowSkillView:OpenCallBack()
	if self.skill_idx ~= -1 then
		self:Flush()
	end
end

function TipsShowSkillView:CloseCallBack()
	self.skill_idx = -1
	self.from_view = 0
end

function TipsShowSkillView:CloseClick()
	self.skill_idx = -1
	self:Close()
	self.from_view = 0
end

function TipsShowSkillView:SetData(skill_idx, from_view)
	self.skill_idx = skill_idx
	self.from_view = SKILL_TIP_FROM_VIEW_TYPE[from_view]
	self:Flush()
end

function TipsShowSkillView:OnFlush()
	if self.from_view == SKILL_TIPS_FROM_SHENBING then
		self:OnFlushLingRenSkill()
	elseif self.from_view == SKILL_TIPS_FROM_CLOAK  then
		self:OnFlushCloakSkill()
	end
end

function TipsShowSkillView:OnFlushLingRenSkill()
	local ling_ren_data = LingRenData.Instance
	local cfg = ling_ren_data:GetShenBingSkillCfg(self.skill_idx)
	self.node_list["TxtLevel"].text.text = string.format(Language.Advance.TipSkillUpgradeViewLevel, cfg.skill_level)
	local desc = cfg.skill_dec
	if cfg.param_a ~= 0 then
		desc = string.gsub(desc,"%[param_a]", tonumber(cfg.param_a)/100)
	end
	if cfg.param_b ~= 0 then
		desc = string.gsub(desc,"%[param_b]", tonumber(cfg.param_b)/100)
	end
	if cfg.param_c ~= 0 then
		desc = string.gsub(desc,"%[param_c]", tonumber(cfg.param_c)/1000)
	end
	if cfg.param_d ~= 0 then
		desc = string.gsub(desc,"%[param_d]", tonumber(cfg.param_d)/1000)
	end
	self.node_list["TxtDesc"].text.text = desc
	local name = cfg.skill_name
	local state = ling_ren_data:GetIsActive(self.skill_idx) and string.format("(%s)", Language.Common.YiActivate) or ToColorStr(string.format("(%s)", Language.Common.NoActivate), TEXT_COLOR.RED)
	self.node_list["TxtProName"].text.text = string.format("%s <color=#89f201>%s</color>", name, state)
	local level =  ling_ren_data:GetIsActive(self.skill_idx) and string.format(Language.Tips.CloakLevel, cfg.shenbing_level) or ToColorStr(string.format(Language.Tips.CloakLevel, cfg.shenbing_level), TEXT_COLOR.RED)
	self.node_list["TxtActivateTips"].text.text = string.format(Language.Tips.DengJiDaDao, Language.Common.MoRen, level)
	local bundle, asset = ResPath.GetLingRenSkillIcon(self.skill_idx + 1)
	self.node_list["SpecialSkill"]:SetActive(self.skill_idx == 0)
	self.node_list["NomalSkill"]:SetActive(self.skill_idx ~= 0)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	self.node_list["ImgIcon1"].image:LoadSprite(bundle, asset)
end

function TipsShowSkillView:OnFlushCloakSkill()
	local cloak_data = CloakData.Instance
	local cfg = cloak_data:GetCloakSkillCfgBuyIndex(self.skill_idx)
	self.node_list["TxtLevel"].text.text = string.format(Language.Advance.TipSkillUpgradeViewLevel, cfg.skill_level)
	local desc = cfg.desc
	if cfg.param_a ~= 0 then
		desc = string.gsub(desc,"%[param_a]", tonumber(cfg.param_a)/100)
	end
	if cfg.param_b ~= 0 then
		desc = string.gsub(desc,"%[param_b]", tonumber(cfg.param_b)/100)
	end
	if cfg.param_c ~= 0 then
		desc = string.gsub(desc,"%[param_c]", tonumber(cfg.param_c)/1000)
	end
	if cfg.param_d ~= 0 then
		desc = string.gsub(desc,"%[param_d]", tonumber(cfg.param_d)/1000)
	end
	self.node_list["TxtDesc"].text.text = desc
	local name = cfg.skill_name
	local state = cloak_data:GetSkillIsActive(self.skill_idx) and string.format("(%s)", Language.Common.YiActivate) or ToColorStr(string.format("(%s)", Language.Common.NoActivate), TEXT_COLOR.RED)
	self.node_list["TxtProName"].text.text = string.format("%s <color=#89f201>%s</color>", name, state)
	local level = cloak_data:GetSkillIsActive(self.skill_idx) and string.format(Language.Tips.CloakLevel, cfg.level) or ToColorStr(string.format(Language.Tips.CloakLevel, cfg.level), TEXT_COLOR.RED)
	self.node_list["TxtActivateTips"].text.text = string.format(Language.Tips.DengJiDaDao, Language.Common.PiFeng, level)
	local bundle, asset = ResPath.GetCloakSkillIcon(self.skill_idx + 1)
	self.node_list["SpecialSkill"]:SetActive(self.skill_idx == 0)
	self.node_list["NomalSkill"]:SetActive(self.skill_idx ~= 0)
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset)
	self.node_list["ImgIcon1"].image:LoadSprite(bundle, asset)
end

