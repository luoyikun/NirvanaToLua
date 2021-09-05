ImageFuLingTalentUpgradeView = ImageFuLingTalentUpgradeView or BaseClass(BaseView)

function ImageFuLingTalentUpgradeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/imagefuling_prefab", "FuLingTalentUpgradeView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fight_info_view = true
	self.is_from_bag = true
end

function ImageFuLingTalentUpgradeView:__delete()
	
end

function ImageFuLingTalentUpgradeView:ReleaseCallBack()
	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	if nil ~= self.next_item then
		self.next_item:DeleteMe()
		self.next_item = nil
	end
end

function ImageFuLingTalentUpgradeView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(680, 620, 0)
	self.node_list["Txt"].text.text = Language.ImageFuLing.SkillUpgrade
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["BtnForget"].button:AddClickListener(BindTool.Bind(self.OnClickTakeOff, self))

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData()

	self.next_item = ItemCell.New()
	self.next_item:SetInstanceParent(self.node_list["NextItemCell"])
	self.next_item:SetData()

	self.node_list["AutoToggle"].toggle.isOn = self.is_auto_buy
	self.node_list["AutoToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
end

function ImageFuLingTalentUpgradeView:OpenCallBack()
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ImageFuLingTalentUpgradeView:CloseCallBack()
	self.select_info = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ImageFuLingTalentUpgradeView:OnAutoBuyToggleChange(isOn)
	self.is_auto_buy = isOn
end

function ImageFuLingTalentUpgradeView:ItemDataChangeCallback()
	self:FlushNextAttr()
end

function ImageFuLingTalentUpgradeView:OnFlush(param_t)
	self:FlushCurAttr()
	self:FlushNextAttr()
end

function ImageFuLingTalentUpgradeView:SetSelectInfo(select_info)
	self.select_info = select_info
end

function ImageFuLingTalentUpgradeView:OnClickUpgrade()
	if nil == self.select_info then
		return
	end

	local talent_info_list = ImageFuLingData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]
	local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local item_num = ItemData.Instance:GetItemNumInBagById(skill_cfg.need_item_id)

	if item_num < skill_cfg.need_item_count and not self.node_list["AutoToggle"].toggle.isOn then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.node_list["AutoToggle"].toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, skill_cfg.need_item_id, nil, skill_cfg.need_item_count - item_num)
		return
	end

	local need_item_data = ShopData.Instance:GetShopItemCfg(skill_cfg.need_item_id)
	local is_auto = (self.node_list["AutoToggle"].toggle.isOn and nil ~= need_item_data) and 1 or 0
	ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_SKILL_UPLEVEL, self.select_info.talent_type,  self.select_info.grid_index, is_auto)
end

function ImageFuLingTalentUpgradeView:OnClickTakeOff()
	if nil == self.select_info then
		return
	end
	local yes_func = nil
	yes_func = function() 
		ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_PUTOFF, self.select_info.talent_type,  self.select_info.grid_index) 
		self:Close()
	end
	describe = ToColorStr(Language.Advance.describe, COLOR.WHITE) 
	TipsCtrl.Instance:ShowCommonAutoView(nil, describe, yes_func)
	-- ImageFuLingCtrl.Instance:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_PUTOFF, self.select_info.talent_type,  self.select_info.grid_index)
	-- self:Close()
end

function ImageFuLingTalentUpgradeView:FlushCurAttr()
	if nil == self.select_info then
		return
	end
	local talent_info_list = ImageFuLingData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]
	local skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)

	if 1 == talent_info.is_open then
		self.item:SetCellLock(false)
		if 0 ~= talent_info.skill_id then
			self.item:ShowQuality(true)
			self.item:SetData({item_id = skill_cfg.book_id})
			self.item:SetShowStar(skill_cfg.skill_star)
		else
			self.item:SetData(nil)
			self.item:ShowQuality(false)
		end
	else
		self.item:SetCellLock(true)
		self.item:SetData(nil)
		self.item:ShowQuality(false)
	end

	-- self.node_list["TxtGold"].text.text = skill_cfg.forget_gold
	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	self.node_list["TxtCurName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color or 0])

	local attr_data = ImageFuLingData.Instance:GetTalentAttrDataList(skill_cfg, self.select_info.talent_type)
	if nil ~= attr_data and nil ~= attr_data.desc then
		self.node_list["TxtSkill"].text.text = attr_data.desc
		self.node_list["Attribute1"]:SetActive(false)
		self.node_list["Attribute2"]:SetActive(false)
		return
	else
		self.node_list["TxtSkill"].text.text = ""
	end

	self.node_list["Attribute1"]:SetActive(nil ~= attr_data[1])
	self.node_list["Attribute2"]:SetActive(nil ~= attr_data[2])

	if nil ~= attr_data[1] then
		self.node_list["TxtAttr1"].text.text = attr_data[1].str or ""
	end

	if nil ~= attr_data[2] then
		self.node_list["TxtAttr2"].text.text = attr_data[2] and attr_data[2].str or ""
	end
end

function ImageFuLingTalentUpgradeView:FlushNextAttr()
	if nil == self.select_info then
		return
	end
	local talent_info_list = ImageFuLingData.Instance:GetTalentAllInfo()
	local talent_info = talent_info_list[self.select_info.talent_type][self.select_info.grid_index]

	local skill_cfg = ImageFuLingData.Instance:GetTalentSkillNextConfig(talent_info.skill_id, talent_info.skill_star)
	if nil == skill_cfg then
		self.node_list["NextAttrPanel"]:SetActive(false)
		return
	else
		self.node_list["NextAttrPanel"]:SetActive(true)
	end

	if 1 == talent_info.is_open then
		self.next_item:SetCellLock(false)
		if 0 ~= talent_info.skill_id then
			self.next_item:ShowQuality(true)
			self.next_item:SetData({item_id = skill_cfg.book_id})
			self.next_item:SetShowStar(skill_cfg.skill_star)
		else
			self.next_item:SetData(nil)
			self.next_item:ShowQuality(false)
		end
	else
		self.next_item:SetCellLock(true)
		self.next_item:SetData(nil)
		self.next_item:ShowQuality(false)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(skill_cfg.book_id)
	self.node_list["TxtNextName"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color or 0])
	local cur_skill_cfg = ImageFuLingData.Instance:GetTalentSkillConfig(talent_info.skill_id, talent_info.skill_star)
	local need_item_cfg = ItemData.Instance:GetItemConfig(cur_skill_cfg.need_item_id)
	local need_item_name = ToColorStr(need_item_cfg.name, ITEM_COLOR[need_item_cfg.color or 0])

	local item_num = ItemData.Instance:GetItemNumInBagById(cur_skill_cfg.need_item_id)
	local txt_color = item_num >= cur_skill_cfg.need_item_count and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local str = need_item_name .. ToColorStr("(" .. item_num .. "/" .. cur_skill_cfg.need_item_count .. ")", txt_color)
	self.node_list["TxtNeed"].text.text = string.format(Language.Advance.NeedFragments, str)

	local need_item_data = ShopData.Instance:GetShopItemCfg(cur_skill_cfg.need_item_id)
	self.node_list["AutoToggle"]:SetActive(nil ~= need_item_data)

	local attr_data = ImageFuLingData.Instance:GetTalentAttrDataList(skill_cfg, self.select_info.talent_type)
	if nil ~= attr_data and nil ~= attr_data.desc then
		self.node_list["TxtNextSkill"].text.text = attr_data.desc
		self.node_list["Attribute3"]:SetActive(false)
		self.node_list["Attribute4"]:SetActive(false)
		return
	else
		self.node_list["TxtNextSkill"].text.text = ""
	end
	self.node_list["Attribute3"]:SetActive(nil ~= attr_data[1])
	self.node_list["Attribute4"]:SetActive(nil ~= attr_data[2])

	if nil ~= attr_data[1] then
		self.node_list["TxtAttr3"].text.text = attr_data[1].str or ""
	end

	if nil ~= attr_data[2] then
		self.node_list["txtAttr4"].text.text = attr_data[2] and attr_data[2].str or ""
	end
end

