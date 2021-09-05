TipsSpiritSoulView = TipsSpiritSoulView or BaseClass(BaseView)

function TipsSpiritSoulView:__init()
	self.ui_config = {{"uis/views/tips/spiritsoultips_prefab", "SpiritSoulTip"}}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsSpiritSoulView:LoadCallBack()
	self.node_list["BtnPutInBag"].button:AddClickListener(BindTool.Bind(self.OnClickPutInBag, self))
	self.node_list["BtnSale"].button:AddClickListener(BindTool.Bind(self.OnClickSale, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.soul_item = SpiritSoulItem.New(self.node_list["SoulItem"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPower"], "FightPower3")
end

function TipsSpiritSoulView:ReleaseCallBack()
	if self.soul_item then
		self.soul_item:DeleteMe()
		self.soul_item = nil
	end
	self.fight_text = nil
end

function TipsSpiritSoulView:OpenCallBack()
	self:Flush()
end

function TipsSpiritSoulView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.soul_item:CloseCallBack()
end

function TipsSpiritSoulView:CloseView()
	self:Close()
end

function TipsSpiritSoulView:OnClickPutInBag()
	if nil == self.data then return end
	PackageCtrl.Instance:SendUseItem(self.data.index, 1, nil, nil, nil)
	self:Close()
end

function TipsSpiritSoulView:OnClickSale()
	ViewManager.Instance:Open(ViewName.SpiritSoulResolveView)
	self:Close()
end

function TipsSpiritSoulView:SetData(data, from_view)
	self.data = data
	self.from_view = from_view
end

function TipsSpiritSoulView:OnFlush()
	if self.data then
		local soul_cfg = SpiritData.Instance:GetSoulCfgById(self.data.id)
		local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1)
		local soul_cfg_exp = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1, true)
		local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
		local other_cfg = lieming_cfg.other

		if nil == soul_cfg or nil == soul_cfg_exp then
			return
		end

		if self.from_view == SOUL_FROM_VIEW.SOUL_BAG then
			self.node_list["Attr1Name"].text.text = soul_cfg.name .. ":  "
			self.node_list["TxtTitle"].text.text = "Lv." .. self.data.level
			self.node_list["TXtAttr1"].text.text = attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]]
			self.node_list["TxtSale"].text.text = soul_cfg_exp * other_cfg[1].hunshou_exp_discount_rate * 0.01
			self.soul_item:SetData(self.data)
		end
		local  attr_list = {}
		attr_list[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]] = attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]]
		self.fight_text.text.text = CommonDataManager.GetCapability(attr_list)
	end
end