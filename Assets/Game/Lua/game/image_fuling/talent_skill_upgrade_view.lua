TalentSkillUpgradeView = TalentSkillUpgradeView or BaseClass(BaseView)

function TalentSkillUpgradeView:__init()
	self.ui_config = {{"uis/views/imagefuling_prefab","TalentSkillTips"},}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TalentSkillUpgradeView:__delete()
	
end
-- 创建完调用
function TalentSkillUpgradeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["UpLevelButton"].button:AddClickListener(BindTool.Bind(self.OnClickUpgradeButton, self))
end

function TalentSkillUpgradeView:ReleaseCallBack()
	
end

function TalentSkillUpgradeView:OpenCallBack()
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function TalentSkillUpgradeView:CloseCallBack()
	self.select_info = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function TalentSkillUpgradeView:ItemDataChangeCallback()
	self:Flush()
end

function TalentSkillUpgradeView:OnClickUpgradeButton()
	if nil == self.select_info then
		return
	end
	ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_SKILL_UPLEVEL, self.select_info.talent_type,  self.select_info.grid_index, 0)
end

function TalentSkillUpgradeView:SetSelectInfo(select_info)
	self.select_info = select_info
end

function TalentSkillUpgradeView:OnFlush(param_list)
	local talent_info_list = ImageFuLingData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]

	local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local next_skill_cfg = ImageFuLingData.Instance:GetTalentSkillNextConfig(talent_info.skill_id, talent_info.skill_star)

	self.node_list["NextEffect"]:SetActive(0 ~= talent_info.skill_id)
	-- self.node_list["BtnActive"]:SetActive(0 ~= talent_info.skill_id)
	self.node_list["TxtActive"].text.text = string.format(Language.ImageFuLing.ConditionName, nil == skill_cfg and Language.Advance.JiHuo or Language.Advance.ShengJi)
	self.node_list["TxtBtn"].text.text = nil == skill_cfg and Language.Advance.JiHuo or Language.Advance.ShengJi
	local cond_str = ImageFuLingData.Instance:GetTalentGridActiveCondition(self.select_info.talent_type, self.select_info.grid_index)
	self.node_list["UpLevelYip"].text.text = 0 == talent_info.is_open and cond_str or ""

	local is_active = true
	if nil == skill_cfg then
		local talent_type_cfg = ImageFuLingData.Instance:GetTalentConfig(self.select_info.talent_type)
		skill_cfg = ImageFuLingData.Instance:GetTalentTypeFirstConfigBySkillType(talent_type_cfg.skill_type)
		is_active = false
	end

	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ImgSkill"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["TxtSkillName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color or 0])
	self.node_list["TxtLevel"].text.text = string.format(Language.ImageFuLing.Level, skill_cfg.skill_quality + 1)
	self.node_list["TxtSkill"].text.text = skill_cfg.description

	local need_item_cfg = ItemData.Instance:GetItemConfig(is_active and skill_cfg.need_item_id or skill_cfg.book_id)
	local item_num = ItemData.Instance:GetItemNumInBagById(is_active and skill_cfg.need_item_id or skill_cfg.book_id)
	local txt_color = item_num >= skill_cfg.need_item_count and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local str = ToColorStr("(" .. item_num .. "/" .. skill_cfg.need_item_count .. ")", txt_color)
	self.node_list["TxtUpgrade"].text.text = string.format(Language.ImageFuLing.NeedPro, ToColorStr(need_item_cfg.name, ITEM_COLOR[need_item_cfg.color or 0]), str)
	self.node_list["UpCondition"]:SetActive(not (nil == next_skill_cfg and 0 ~= talent_info.skill_id))--and nil == next_skill_cfg
	-- self.node_list["BtnActive"]:SetActive(0 ~= talent_info.skill_id and nil == next_skill_cfg)
	self.node_list["BtnActive"]:SetActive(0 ~= talent_info.skill_id and nil ~= next_skill_cfg)
	self.node_list["TxtNextSkill"].text.text = next_skill_cfg and next_skill_cfg.description or Language.Advance.SkillMaxLevel
	self.node_list["Level"]:SetActive(0 ~= talent_info.skill_id)
end