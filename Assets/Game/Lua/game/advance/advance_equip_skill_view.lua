AdvanceEquipSkillView = AdvanceEquipSkillView or BaseClass(BaseView)

function AdvanceEquipSkillView:__init()
	self.ui_config = {{"uis/views/advanceview_prefab", "JinJieEquipSkillView"}}

	self.play_audio = true

	self.is_modal = true
	self.is_any_click_close = true
end

function AdvanceEquipSkillView:ReleaseCallBack()
	-- 清理变量

	self.skill_var_list = nil
end

function AdvanceEquipSkillView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.skill_var_list = {}
	for  i = 1, 7 do
		self.skill_var_list[i] = {
			level = self.node_list["TxtSkillLevel"..i],
			gray = self.node_list["ImgSkillIcon"..i],
		}
	end
end

function AdvanceEquipSkillView:OpenCallBack()
	local total_count = AdvanceData.Instance:GetJinjieSkillTotalCount()
	local cur_skill_gauge = 0
	local next_skill_gauge = 0
	if total_count <= 0 then
		cur_skill_gauge = AdvanceData.Instance:GetJinjieGaugeCount(total_count + 1)
		 self.node_list["TxtDiffCount"].text.text = string.format(Language.Common.AdvanceEquipSkillViewDiffCount,0)
		 self.node_list["TxtDiffCount"]:SetActive(0 > 0)
	else
		cur_skill_gauge = AdvanceData.Instance:GetJinjieGaugeCount(total_count)
		next_skill_gauge = AdvanceData.Instance:GetJinjieGaugeCount(total_count + 1)
		if next_skill_gauge <= 0 then
		 self.node_list["TxtDiffCount"].text.text = string.format(Language.Common.AdvanceEquipSkillViewDiffCount,0)
		 self.node_list["TxtDiffCount"]:SetActive(0 > 0)
		else
			local need = cur_skill_gauge - next_skill_gauge
			 self.node_list["TxtDiffCount"].text.text = string.format(Language.Common.AdvanceEquipSkillViewDiffCount,need)
			 self.node_list["TxtDiffCount"]:SetActive(need > 0)
		end
	end
	self.node_list["TxtTotalCount"].text.text = string.format(Language.Common.AdvanceEquipSkillViewtotleCount,cur_skill_gauge)

	local level_str = ""
	local temp_level = 0
	for k, v in pairs(self.skill_var_list) do
		temp_level = self:GetSkillLevel(k - 1)
		if temp_level > 0 then
			local local_text = string.format(Language.Common.ShowGreenStr, temp_level)
			v.level.text.text = string.format(Language.Advance.AdvanceEquipSkillViewSkillIconType[k], local_text)
		else
			v.level.text.text = string.format(Language.Advance.AdvanceEquipSkillViewSkillIconType[k],temp_level)
		end
		UI:SetGraphicGrey(v.gray,self:GetSkillLevel(k - 1) <= 0)
	end
end

function AdvanceEquipSkillView:CloseCallBack()
end

function AdvanceEquipSkillView:OnClickClose()
	self:Close()
end

function AdvanceEquipSkillView:GetSkillLevel(equip_type)
	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_MOUNT then
		return MountData.Instance:GetMountInfo().equip_skill_level or 0
	end

	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_WING then
		return WingData.Instance:GetWingInfo().equip_skill_level or 0
	end

	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_HALO then
		return HaloData.Instance:GetHaloInfo().equip_skill_level or 0
	end

	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENGONG then
		return ShengongData.Instance:GetShengongInfo().equip_skill_level or 0
	end

	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_SHENYI then
		return ShenyiData.Instance:GetShenyiInfo().equip_skill_level or 0
	end

	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FIGHT_MOUNT then
		return FightMountData.Instance:GetFightMountInfo().equip_skill_level or 0
	end
	
	if equip_type == JINJIE_EQUIP_SKILL_TYPE.SKILL_TYPE_FOOT_PRINT then
		return FootData.Instance:GetFootInfo().equip_skill_level or 0
	end
	return 0
end