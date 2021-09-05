PreferredSizeAttrView = PreferredSizeAttrView or BaseClass(BaseView)

function PreferredSizeAttrView:__init()
	self.ui_config = {{"uis/views/tips/attrtips_prefab", "PreferredSizeAttrView"}}
	self.play_audio = true
	self.fight_info_view = true
	self.normal_attr_cfg = {}
	self.special_attr_list = {}
	self.special_fight_power = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function PreferredSizeAttrView:ReleaseCallBack()
	self.total_attr_var_list = nil
	self.fight_text = nil
end

function PreferredSizeAttrView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightPower"], "FightPower3")

	self.total_attr_var_list = {}
	for i = 1, 10 do
		self.total_attr_var_list[i] = {
			text = self.node_list["TxtAttr"..i],
		}
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function PreferredSizeAttrView:OpenCallBack()
	self:ResetAttrVar()
	self:SetAttrInfo()
end

function PreferredSizeAttrView:CloseCallBack()
end

function PreferredSizeAttrView:OnClickClose()
	self:Close()
end

function PreferredSizeAttrView:SetAttrInfo()
	local attr_list = CommonDataManager.GetOrderAttributte(CommonDataManager.GetAttributteNoUnderline(self.normal_attr_cfg))
	local normal_count = 1
	local attr_var = nil
	local temp_value_str = ""
	for k, v in pairs(attr_list) do
		attr_var = self.total_attr_var_list[normal_count]
		if v.value > 0 and nil ~= attr_var then
			attr_var.text:SetActive(true)
			self.node_list["ShowTxtAttr"]:SetActive(false)
			temp_value_str = string.format(Language.Common.ShowWhiteStr, v.value)
			attr_var.text.text.text = Language.Common.AttrName[v.key].."："..temp_value_str
			normal_count = normal_count + 1
		end
	end

	for k, v in pairs(self.special_attr_list) do
		attr_var = self.total_attr_var_list[normal_count]
		if nil ~= attr_var and v.show then
			attr_var.text:SetActive(v.show)
			self.node_list["ShowTxtAttr"]:SetActive(not v.show)
			attr_var.text.text.text = v.attr_des
			normal_count = normal_count + 1
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteNoUnderline(self.normal_attr_cfg))
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = (power + self.special_fight_power)
	end
end

function PreferredSizeAttrView:SetNormalAttrCfg(normal_attr_cfg)
	self.normal_attr_cfg = normal_attr_cfg or {}
end

function PreferredSizeAttrView:SetSpecialAttrList(special_attr_list)
	self.special_attr_list = special_attr_list or {}
end

function PreferredSizeAttrView:SetSpecialAttrFightPower(special_fight_power)
	self.special_fight_power = special_fight_power or 0
end

function PreferredSizeAttrView:ResetAttrVar()
	for k, v in pairs(self.total_attr_var_list) do
		v.text:SetActive(false)
	end
end