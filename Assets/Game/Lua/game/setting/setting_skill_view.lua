SettingSkillView = SettingSkillView or BaseClass(BaseView)

function SettingSkillView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/settingview_prefab", "SettingSkillView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true

end

function SettingSkillView:__delete()

end

function SettingSkillView:ReleaseCallBack()
	for k, v in pairs(self.skill_cell_list) do
		v:DeleteMe()
	end
	self.skill_cell_list = {}
end

function SettingSkillView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(850, 610, 0)
	self.node_list["Txt"].text.text = Language.Setting.SkillSet

	self.skill_data_list = {}
	self.skill_cell_list = {}
	local skill_list_delegate = self.node_list["SkillList"].list_simple_delegate
	skill_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSkillCellNumber, self)
	skill_list_delegate.CellRefreshDel = BindTool.Bind(self.SkillCellRefresh, self)

end

function SettingSkillView:CloseWindow()
	self:Close()
end

function SettingSkillView:CloseCallBack()
	SettingCtrl.Instance:SendHotkeyInfoReq()
end

function SettingSkillView:OpenCallBack()
	if self.node_list["SkillList"] then
		self.skill_data_list = SkillData.Instance:GetActiveSkillListCfg()
		table.remove(self.skill_data_list, 1)
		for k, v in pairs(self.skill_data_list) do
			local skill_info = SkillData.Instance:GetSkillInfoById(v.skill_id)
			if nil == skill_info or 0 == skill_info.level then
				self.skill_data_list[k] = nil
			end
		end
		self.node_list["SkillList"].scroller:ReloadData(0)
	end
end


local skill_guaji_num = 4 					--挂机技能个数
-- 技能列表
function SettingSkillView:GetSkillCellNumber(value)
	local skill_num = #self.skill_data_list
	if skill_num > skill_guaji_num then
		return skill_guaji_num
	end
	return skill_num
end

function SettingSkillView:SkillCellRefresh(cell, index)
	local skill_cell = self.skill_cell_list[cell]
	index = index + 1
	if nil == skill_cell then
		skill_cell = SkillViewIconItemCell.New(cell.gameObject)
		self.skill_cell_list[cell] = skill_cell
	end

	local data = self.skill_data_list[index]
	skill_cell:SetIndex(index)
	skill_cell:SetData(data)
end
-----------------End-------------------

function  SettingSkillView:SetAutoUseSkill()
	if self.node_list["SkillList"] then
		self.node_list["SkillList"].scroller:ReloadData(0)
	end
end

function  SettingSkillView:OnFlush()

end







------------------------------------------
--------SkillViewIconItemCell 技能Item
------------------------------------------


SkillViewIconItemCell = SkillViewIconItemCell or BaseClass(BaseCell)
function SkillViewIconItemCell:__init()
	self.node_list["Toggle"].button:AddClickListener(BindTool.Bind(self.ToggleOnClick, self))
end

function SkillViewIconItemCell:__delete()

end

function SkillViewIconItemCell:ToggleOnClick()
	if (SettingData.Instance:GetAutoUseSkillFlag(self.data.skill_index - 1) == 1) then
		SettingData.Instance:SetAutoUseSkillFlag(self.data.skill_index - 1, 0)
	else
		SettingData.Instance:SetAutoUseSkillFlag(self.data.skill_index - 1, 1)
	end
	self:Flush()
end

function SkillViewIconItemCell:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["SkillNumber"].text.text = self.index

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local bundle, asset = "", ""
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.data.skill_id == GameEnum.KILL_SKILL_ID then
		local skill_icon = self.data.skill_icon + (main_vo.prof % 10)
		bundle, asset = ResPath.GetRoleSkillIcon(skill_icon)
	elseif self.data.skill_id == ZHUAN_ZHI_SKILL1[prof] or self.data.skill_id == ZHUAN_ZHI_SKILL2[prof] then
		-- local skill_icon = self.data.skill_icon .. (main_vo.prof % 10) .. "_2"
		bundle, asset = ResPath.GetRoleSkillIcon(self.data.skill_id)
	else
 		bundle, asset = ResPath.GetRoleSkillIcon(self.data.skill_icon)
	end
	self.node_list["SkillIcon"].image:LoadSprite(bundle, asset)

	local skill_cfg
	local skill_desc = ""
	local skill_info = SkillData.Instance:GetSkillInfoById(self.data.skill_id)
	local is_max_level = false
	if nil == skill_info or 0 == skill_info.level then return end
	
	if self.data.skill_id == ZHUAN_ZHI_SKILL1[prof] or self.data.skill_id == ZHUAN_ZHI_SKILL2[prof] then
		local cfg = SkillData.GetNormalSkillinfoConfig(self.data.skill_id)
		skill_cfg = {[1] = cfg}
		skill_desc = self.data.skill_desc
		is_max_level = true
	else
		skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto")["s" .. self.data.skill_id]

		skill_desc = string.gsub(self.data.skill_desc, "%b()%%" , function(str)
			return tonumber(skill_cfg[skill_info.level][string.sub(str, 2, -3)]) / 1000
			end)
		skill_desc = string.gsub(skill_desc, "%b[]%%" , function(str)
			return tonumber(skill_cfg[skill_info.level][string.sub(str, 2, -3)]) / 100 .. "%"
			end)
		skill_desc = string.gsub(skill_desc, "%[.-%]" , function(str)
			local add_target = SkillData.Instance:GetSkillIsAddTarget(skill_info.skill_id) or 0
			return (skill_cfg[skill_info.level][string.sub(str, 2, -2)] + add_target)
			end)

		local max_level = skill_cfg[#skill_cfg].skill_level
		is_max_level = skill_info.level == max_level and true or false
	end

	self.node_list["SkillName"].text.text = self.data.skill_name
	if is_max_level then
		self.node_list["SkillLevel"].text.text = ToColorStr(Language.Common.YiManJi, TEXT_COLOR.ORANGE)
	else
		self.node_list["SkillLevel"].text.text = ToColorStr(string.format(" Lv:" .. skill_info.level), TEXT_COLOR.ORANGE)
	end
	
	self.node_list["SkillDesc"].text.text = skill_desc
	self.node_list["HighLight"]:SetActive(SettingData.Instance:GetAutoUseSkillFlag(self.data.skill_index - 1) == 1)
end


