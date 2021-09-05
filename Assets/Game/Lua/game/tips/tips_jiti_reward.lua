TipJiTiReward = TipJiTiReward or BaseClass(BaseView)

function TipJiTiReward:__init()
	self.ui_config = {
		{"uis/views/tips/tipsjitireward_prefab", "TipsJiTiReward"}
	}

	self.play_audio = true
	self.title_id = 0
	self.top_title_id = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipJiTiReward:__delete()
	self.title_id = nil
	self.top_title_id = nil
end

function TipJiTiReward:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}

	if self.tips_model then
		self.tips_model:DeleteMe()
		self.tips_model = nil
	end

	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["ImgTitle"])
end

function TipJiTiReward:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.item_list = {}
	self.other_item_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetShowOrangeEffect(true)
		table.insert(self.item_list, item_cell)

		local other_item_cell = ItemCell.New()
		other_item_cell:SetInstanceParent(self.node_list["ItemOther" .. i])
		other_item_cell:SetShowOrangeEffect(true)
		table.insert(self.other_item_list, other_item_cell)
	end

	self.tips_model = RoleModel.New()
	self.tips_model:SetDisplay(self.node_list["Display"].ui3d_display,MODEL_CAMERA_TYPE.BASE)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"])
end

function TipJiTiReward:SetData(main_items, other_items, act_type)
	self.main_items = main_items
	self.other_items = other_items
	self.act_type = act_type
end

function TipJiTiReward:CloseView()
	self:Close()
end

function TipJiTiReward:CloseCallBack()
	if self.close_callback then
		self.close_callback()
	end
end

function TipJiTiReward:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
end

function TipJiTiReward:OnFlush()
	if self.main_items then
		self.node_list["ItemMain"]:SetActive(true)

		for k,v in pairs(self.item_list) do
			if self.main_items[k] then
				v:SetData(self.main_items[k])
				self.node_list["Item" .. k]:SetActive(true)
			else
				self.node_list["Item" .. k]:SetActive(false)
			end
		end
	else
		self.node_list["ItemMain"]:SetActive(false)
	end

	if self.other_items then
		self.node_list["ItemOther"]:SetActive(true)
		for k,v in pairs(self.other_item_list) do
			if self.other_items[k] then
				v:SetData(self.other_items[k])
				self.node_list["ItemOther" .. k]:SetActive(true)
			else
				self.node_list["ItemOther" .. k]:SetActive(false)
			end
		end
	else
		self.node_list["ItemOther"]:SetActive(false)
	end

	if self.act_type == ACTIVITY_TYPE.GONGCHENGZHAN then
		self:SetGongChengModelRes()
	elseif self.act_type == ACTIVITY_TYPE.GUILDBATTLE then
		self:SetGuildWarRewardModelRes()
		self.node_list["ItemTextMain"].text.text = Language.Activity.JiTiRewardText[1]
		self.node_list["ItemTextOther"].text.text = Language.Activity.JiTiRewardText[2]
	elseif self.act_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
		self:SetModelRes()
		self.node_list["ItemTextMain"].text.text = Language.Activity.JiTiRewardText[3]
		self.node_list["ItemTextOther"].text.text = Language.Activity.JiTiRewardText[4]
	end
	self.node_list["ItemTextMain"]:SetActive(self.act_type ~= ACTIVITY_TYPE.GONGCHENGZHAN)
	self.node_list["ItemTextOther"]:SetActive(self.act_type ~= ACTIVITY_TYPE.GONGCHENGZHAN)
	self.node_list["ItemPanel"].transform.localPosition = self.act_type ~= ACTIVITY_TYPE.GONGCHENGZHAN and Vector3(363, -20, 0) or Vector3(314, -20, 0)
end

function TipJiTiReward:SetModelRes()
	if self.main_items then
		local item_id = self.main_items[1].item_id or 0
		self.tips_model:ChangeModelByItemId(item_id, function()
			self.tips_model:SetLocalPosition(Vector3(0, 0.4, 0))
		end)
		if self.fight_text and self.fight_text.text then
			local power = ItemData.Instance.GetFightPower(item_id)
			self.fight_text.text.text = power
		end
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg then
			self.node_list["TxtName"].text.text = item_cfg.name
			local name = Language.Common.PROP_TYPE[item_cfg.is_display_role] or ""
			self.node_list["TxtLower"].text.text = string.format(Language.Activity.JiTiTips, name)
		end
	end
end

function TipJiTiReward:SetGuildWarRewardModelRes()
	if self.main_items then
		local item_id = self.main_items[1].item_id or 0
		self.tips_model:ChangeModelByItemId(item_id)
		if self.fight_text and self.fight_text.text then
			local power = ItemData.Instance.GetFightPower(item_id)
			self.fight_text.text.text = power
		end		
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg then
			self.node_list["TxtName"].text.text = item_cfg.name
			local name = Language.Common.PROP_TYPE[item_cfg.is_display_role] or ""
			self.node_list["TxtLower"].text.text = string.format(Language.Activity.JiTiTips, name)
		end
	end
end

function TipJiTiReward:SetGongChengModelRes()
	if self.main_items then
		local item_id = self.main_items[1].item_id or 0
		self.tips_model:ChangeModelByItemId(item_id)
		if self.fight_text and self.fight_text.text then
			local power = ItemData.Instance.GetFightPower(item_id)
			self.fight_text.text.text = power
		end
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg then
			self.node_list["TxtName"].text.text = item_cfg.name
			local name = Language.Common.PROP_TYPE[item_cfg.is_display_role] or ""
			self.node_list["TxtLower"].text.text = string.format(Language.Activity.JiTiTips, name)
		end
	end
end

