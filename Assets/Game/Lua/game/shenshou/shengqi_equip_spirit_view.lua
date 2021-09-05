ShengQiEquipSpiritView = ShengQiEquipSpiritView or BaseClass(BaseView)

function ShengQiEquipSpiritView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/shenshouview_prefab", "ShengQiEquipSpiritContent",}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengQiEquipSpiritView:__delete()

end

function ShengQiEquipSpiritView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.ShenShou.ShengQiSpirit
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnSprite"].button:AddClickListener(BindTool.Bind(self.SpiriteShengQi, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.fuling_attr_list = {}
	for i = 1, 4 do
		self.fuling_attr_list[i] = ShengQiSpiritArrt.New(self.node_list["attr" .. i])
		self.fuling_attr_list[i]:SetIndex(i)
	end
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
end

function ShengQiEquipSpiritView:OpenCallBack()
	local bundle, asset = ResPath.GetShengqiModel(self.shengqi_cfg.id)
	self.model_view:SetMainAsset(bundle, asset)
	self.model_view:ResetRotation()
	self:Flush()
end

function ShengQiEquipSpiritView:ReleaseCallBack()
	if self.fuling_attr_list then
		for k,v in pairs(self.fuling_attr_list) do
			v:DeleteMe()
		end
		self.fuling_attr_list = {}
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self.fight_text = nil
end

function ShengQiEquipSpiritView:SetViewData(data)
	self.shengqi_cfg = data
end

function ShengQiEquipSpiritView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(271)
end

function ShengQiEquipSpiritView:OnClickOpen()
	MarketData.Instance:SetPurchaseItemId(8)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 8})
end


function ShengQiEquipSpiritView:SpiriteShengQi()
	local spirit_cfg = ShenShouData.Instance:GetShengQiSpiritCfg()[self.shengqi_cfg.index + 1]
	if not spirit_cfg then return end
	local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.shengqi_cfg.index)
	if not info then return end

	local func = function()
		ShenShouCtrl.Instance:SendShengQiEquipReq(ShenShouData.OpenType.OpenTypeSpirit, self.shengqi_cfg.id, spirit_cfg.spirit_stuff_id)
	end

	local is_all_active = true
	local active_list = bit:d2b(info.spirit_flag)
	for i = 1, 4 do
		if 0 == active_list[33 - i] then
			is_all_active = false
			break
		end
	end
	if is_all_active then
		func()
	else
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.ShenShou.FulingTip, nil, nil, true, nil, "fuling", 
			nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
end

function ShengQiEquipSpiritView:OnFlush()
	local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.shengqi_cfg.index)
	if not info then return end
	local spirit_cfg = ShenShouData.Instance:GetShengQiSpiritCfg()[self.shengqi_cfg.index + 1]
	local other_cfg = ShenShouData.Instance:GetShengQiOtherCfg()
	if not spirit_cfg and not other_cfg then return end

	self.node_list["TxtName"].text.text = self.shengqi_cfg.name
	self.node_list["TxtLevel"].text.text = "Lv." .. info.level
	self.item_cell:SetData({item_id = spirit_cfg.spirit_stuff_id})
	local item_cfg = ItemData.Instance:GetItemConfig(spirit_cfg.spirit_stuff_id)
	self.node_list["BtnBuy"]:SetActive(item_cfg and item_cfg.color >= 4)
	local have_count = ItemData.Instance:GetItemNumInBagById(spirit_cfg.spirit_stuff_id)
	if spirit_cfg.spirit_stuff_num <= have_count then
		local is_max_fuling = true
		for i = 1, 4 do
			if info.per_spirit_value[i] > 0 and info.per_spirit_value[i] < other_cfg[1].spirit_max * 100 then
				is_max_fuling = false
				break
			end
		end
		self.node_list["ImgRedPoint"]:SetActive(not is_max_fuling)
	else
		have_count = "<color=" .. TEXT_COLOR.RED_4 .. ">" .. have_count .. "</color>"
		self.node_list["ImgRedPoint"]:SetActive(false)
	end
	self.node_list["TxtNeedCount"].text.text = string.format(Language.Common.CountDes, have_count, spirit_cfg.spirit_stuff_num)

	local active_list = bit:d2b(info.spirit_flag)
	for i = 1, 4 do
		local data = {}
		data.spirit_value = info.spirit_value[i]
		data.per_spirit_value = info.per_spirit_value[i]
		data.is_active = active_list[33 - i]
		data.attr_type = spirit_cfg["attr_type_" .. i]
		self.fuling_attr_list[i]:SetData(data)
	end

	local fuling_active_attr = CommonStruct.Attribute()
	local value = 0
	for i = 1, 4 do
		if spirit_cfg["attr_type_" .. i] == SHENGQI_ATTR_TYPE.SHENGQI_ATTR_BASE_JIACHENG_PER then
			value = info.per_spirit_value[i] / 10000		--万分比
		else
			if 1 == active_list[33 - i] then
				fuling_active_attr[ShengQiAttrStruct[spirit_cfg["attr_type_" .. i]]] = info.spirit_value[i]
			end
		end
	end
	local strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.shengqi_cfg.index][info.level]
	local active_attr = CommonDataManager.MulAttribute(CommonDataManager.GetAttributteByClass(strength_cfg), value)
	active_attr = CommonDataManager.AddAttributeAttr(active_attr, fuling_active_attr)
	local power = CommonDataManager.GetCapability(active_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
end

------------------------------------------------------------------------------------------
ShengQiSpiritArrt = ShengQiSpiritArrt or BaseClass(BaseCell)
function ShengQiSpiritArrt:OnFlush()
	local color = "<color=%s>%s</color>"
	-- 配表规定
	local value = self.data.spirit_value
	if self.data.attr_type <= SHENGQI_ATTR_TYPE.SHENGQI_ATTR_BASE_JIACHENG_PER and self.data.attr_type >= SHENGQI_ATTR_TYPE.SHENGQI_ATTR_TYPE_PER_BAOJI then
		value = (self.data.spirit_value / 100) .. "%"
	end	

	self.node_list["TxtLeft"].text.text = Language.ShenShou.SHENGQI_FULING_ATTR[self.data.attr_type] .. ToColorStr(value, COLOR.WHITE)

	if 1 == self.data.is_active then
		local per_spirit_value = self.data.per_spirit_value
		local next_value = "(" .. per_spirit_value / 100 .. "%)"
		if per_spirit_value < 2500 then
			next_value = string.format(color, ShenqiData.AttrColor.WHITE, next_value)
		elseif per_spirit_value < 5000 then
			next_value = string.format(color, ShenqiData.AttrColor.Blue, next_value)
		elseif per_spirit_value < 7500 then
			next_value = string.format(color, ShenqiData.AttrColor.PURPLE, next_value)
		elseif per_spirit_value < 10000 then
			next_value = string.format(color, ShenqiData.AttrColor.ORANGE, next_value)
		elseif per_spirit_value >= 10000 then
			next_value = string.format(color, ShenqiData.AttrColor.RED, next_value)
		end
		self.node_list["TxtRight"].text.text = next_value
	else
		self.node_list["TxtRight"].text.text = Language.ShenShou.ShengQiNotActive
	end
end