-- 女神提示框 GoddessShengWuSkillTip
GoddessShengWuSkillView = GoddessShengWuSkillView or BaseClass(BaseView)

function GoddessShengWuSkillView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/goddess_prefab", "GoddessShengWuSkillTip"},
	}
	self.view_layer = UiLayer.Pop

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
	self.play_audio = true
	self.shengwu_id = 0
	self.shengwu_level = 0
end

function GoddessShengWuSkillView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(650, 400, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function GoddessShengWuSkillView:__delete()

end

function GoddessShengWuSkillView:ReleaseCallBack()
	self.shengwu_id = 0
	self.shengwu_level = 0
end

function GoddessShengWuSkillView:CloseCallBack()
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
end

function GoddessShengWuSkillView:OpenCallBack()
	self:Flush()
end

function GoddessShengWuSkillView:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)

	if nil == info_data then
		return
	end
	local skill_id = info_data.skill_id or 1
	local skill_level = info_data.skill_level or 0
	local skill_level_next = skill_level + 1
	local icon_num = info_data.icon_num or 0

	local now_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level)
	local next_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level_next)

	if nil == now_data then
		return
	end

	local is_zore = (skill_level == 0)
	local has_now = true
	local has_next_info = (next_data ~= nil)

	self.node_list["Txt"].text.text = now_data.name
	self.node_list["NowPanel"]:SetActive(has_now)
	self.node_list["Arrow"]:SetActive(has_now)
	self.node_list["Arrow"]:SetActive(has_next_info)
	self.node_list["NextPanel"]:SetActive(has_next_info)
	local level_str = Language.Goddess.GoddessSkillLevelTip

	-- 设置下级属性的显示
	if has_next_info then
		self.node_list["SkilllNextLevelText"].text.text = string.format(Language.Goddess.GoddessSkillLevelNextTip, now_data.name, skill_level_next)
		self.node_list["NextGongJi"].text.text = next_data.skill_desc
		self.node_list["NextLevel"].text.text = string.format(Language.Goddess.GoddessSkillTipText, info_data.name, next_data.shengwu_level)
	end

	-- 设置当前
	self.node_list["SkillLevelText"].text.text = string.format(Language.Goddess.GoddessSkillLevelTip, now_data.name, skill_level)

	if is_zore then
		self.node_list["NowLevel"].text.text = ToColorStr(Language.Goddess.GoddessUpTextNoJiHuo, TEXT_COLOR.RED)
	elseif has_next_info then
		self.node_list["NowLevel"].text.text = ToColorStr(Language.Goddess.GoddessUpTextJiHuo, TEXT_COLOR.GREEN)
	else
		self.node_list["NowLevel"].text.text = Language.Goddess.GoddessUpTextManJi
	end

	if is_zore then
		self.node_list["GongJi"].text.text = Language.Goddess.LabelNoText
	else
		self.node_list["GongJi"].text.text = now_data.skill_desc
	end

	if has_next_info then
		self.node_list["Bg"].rect.sizeDelta = Vector3(650, 400, 0)
	else
		self.node_list["Bg"].rect.sizeDelta = Vector3(340, 400, 0)
	end
end

function GoddessShengWuSkillView:SetShengWuId(id)
	self.shengwu_id = id
end

function GoddessShengWuSkillView:CloseWindow()
	self:Close()
end