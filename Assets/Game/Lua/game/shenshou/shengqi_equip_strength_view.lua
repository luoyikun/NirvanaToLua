ShengQiEquipStrengthView = ShengQiEquipStrengthView or BaseClass(BaseView)

function ShengQiEquipStrengthView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/shenshouview_prefab", "ShengQiEquipStrengthContent",}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShengQiEquipStrengthView:__delete()

end

function ShengQiEquipStrengthView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.ShenShou.ShengQiStrength
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.jichu_attr_list = {}
	for i = 1, 3 do
		self.jichu_attr_list[i] = ShengQiStrengthArrt.New(self.node_list["attr" .. i])
		self.jichu_attr_list[i]:SetIndex(i)
	end
	self.node_list["BtnSprite"].button:AddClickListener(BindTool.Bind(self.StrengthShengQi, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
end

function ShengQiEquipStrengthView:OpenCallBack()
	for k,v in pairs(self.jichu_attr_list) do
		v:SetStrengthIndex(self.shengqi_cfg.index)
	end
	local bundle, asset = ResPath.GetShengqiModel(self.shengqi_cfg.id)
	self.model_view:SetMainAsset(bundle, asset)
	self.model_view:ResetRotation()
	self:Flush()
end

function ShengQiEquipStrengthView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.jichu_attr_list then
		for  k,v in pairs(self.jichu_attr_list) do
			v:DeleteMe()
		end
		self.jichu_attr_list = {}
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self.fight_text = nil
end

function ShengQiEquipStrengthView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(272)
end

function ShengQiEquipStrengthView:OnClickOpen()
	MarketData.Instance:SetPurchaseItemId(7)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 7})
end


function ShengQiEquipStrengthView:SetViewData(data)
	self.shengqi_cfg = data
end

function ShengQiEquipStrengthView:OnFlush()
	local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.shengqi_cfg.index)
	if not info then return end
	local strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.shengqi_cfg.index][info.level]
	if not strength_cfg then return end

	self.node_list["TxtName"].text.text = self.shengqi_cfg.name
	self.node_list["TxtLevel"].text.text = "Lv." .. info.level
	self.item_cell:SetData({item_id = strength_cfg.strength_stuff_id})

	local next_strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.shengqi_cfg.index][info.level + 1] or nil
	if not next_strength_cfg then
		self.node_list["TxtBtnStrength"].text.text = Language.ShenShou.YiManJi
		UI:SetButtonEnabled(self.node_list["BtnSprite"], false)
	else
		self.node_list["TxtBtnStrength"].text.text = Language.ShenShou.Strength
		UI:SetButtonEnabled(self.node_list["BtnSprite"], true)
	end	
	local have_count = ItemData.Instance:GetItemNumInBagById(strength_cfg.strength_stuff_id)
	if have_count >= strength_cfg.strength_stuff_num and next_strength_cfg then
		self.node_list["ImgRedPoint"]:SetActive(true)
	else
		self.node_list["ImgRedPoint"]:SetActive(false)		
	end
	if strength_cfg.strength_stuff_num > have_count then
		have_count = "<color=" .. TEXT_COLOR.RED_4 .. ">" .. have_count .. "</color>"
	end	

	self.node_list["TxtNeedCount"].text.text = string.format(Language.Common.CountDes, have_count, strength_cfg.strength_stuff_num)

	local attr_cfg = CommonDataManager.GetAttributteByClass(strength_cfg)
	local attribute = CommonDataManager.GetOrderAttributte(attr_cfg)
	local attr_list = {}
	for k, v in pairs(attribute) do
		if v.value > 0 then
			local attr = {}
			attr[v.key] = v.value
			attr_list[#attr_list + 1] = attr
		end
	end
	for i = 1, 3 do
		self.jichu_attr_list[i]:SetData(attr_list[i])
	end
	local power = CommonDataManager.GetCapability(attr_cfg)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
end

function ShengQiEquipStrengthView:StrengthShengQi()
	local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.shengqi_cfg.index)
	local strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.shengqi_cfg.index][info.level]
	local have_count = ItemData.Instance:GetItemNumInBagById(strength_cfg.strength_stuff_id)
	if strength_cfg == nil or next(strength_cfg) == nil then return end
	if strength_cfg.strength_stuff_num > have_count then
		return SysMsgCtrl.Instance:ErrorRemind(Language.Exchange.NotEnoughItem)
	end
	ShenShouCtrl.Instance:SendShengQiEquipReq(ShenShouData.OpenType.OpenTypeStrength, self.shengqi_cfg.id, strength_cfg.strength_stuff_id)
end


ShengQiStrengthArrt = ShengQiStrengthArrt or BaseClass(BaseCell)
function ShengQiStrengthArrt:OnFlush()
	if self.data then
		local info = ShenShouData.Instance:GetShengQiEquipInfoByIndex(self.strength_index)
		local next_strength_cfg = ShenShouData.Instance:GetShengQiStrengthCfg()[self.strength_index][info.level + 1]
		local is_max = false
		local next_attr_list = {}
		if next_strength_cfg then
			local next_attr_cfg = CommonDataManager.GetAttributteByClass(next_strength_cfg)
			local next_attr = CommonDataManager.GetOrderAttributte(next_attr_cfg)
			for k, v in pairs(next_attr) do
				if v.value > 0 then
					local attr = {}
					attr[v.key] = v.value
					next_attr_list[#next_attr_list + 1] = attr
				end
			end
		else
			is_max = true
		end

		for k, v in pairs(self.data) do
			self.node_list["TxtLeft"].text.text = CommonDataManager.GetAttrName(k) .. "：" .. v
			self.node_list["TxtRight"].text.text = is_max and "----" or next_attr_list[self.index][k] - v
		end
	end
end

function ShengQiStrengthArrt:SetStrengthIndex(index)
	self.strength_index = index
end