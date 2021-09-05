HpBagView = HpBagView or BaseClass(BaseView)
function HpBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/hpbagview_prefab", "HpBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function HpBagView:__delete()
end

function HpBagView:ReleaseCallBack()

end

function HpBagView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(589, 672, 0)
	self.node_list["Txt"].text.text = Language.Title.XueQiChi

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClosen, self))
	self.node_list["SliderProgressBG"].slider:AddValueChangedListener(BindTool.Bind(self.SliderOnChange, self))
	self.node_list["SliderProgressBG1"].slider:AddValueChangedListener(BindTool.Bind(self.SliderOnChange, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.OnBuyClick01, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnBuyClick02, self))

end

function HpBagView:OnBuyClick01()
	local fun = function ()
		HpBagCtrl.Instance:SendSupplyBuyItem(self.data[1].supply_type,self.data[1].supply_index,self.data[1].is_use_gold)
	end
 	TipsCtrl.Instance:ShowCommonTip(fun, nil, Language.Common.QuickBuyTip, nil, nil, true, false, "buy_hp_one")
end

function HpBagView:OnBuyClick02()
	local fun = function ()
		HpBagCtrl.Instance:SendSupplyBuyItem(self.data[2].supply_type,self.data[2].supply_index,self.data[2].is_use_gold)
	end
 	TipsCtrl.Instance:ShowCommonTip(fun, nil, Language.Common.QuickBuyTip, nil, nil, true, false, "buy_hp_two")
end

function HpBagView:SliderOnChange(value)
	if self.cur_percent == value then
		return
	end
	self.node_list["SliderProgressBG"].slider.value = value
	self.node_list["SliderProgressBG1"].slider.value = value
	self.cur_percent = value
	self:FlushSliderData(self.cur_percent)
end

function HpBagView:OnFlush()
	self:FlushData()
end

function HpBagView:OnClosen()
	self:Close()
end

function HpBagView:CloseCallBack()
	if self.cur_percent == HpBagData.Instance:GetSupplySeverData().supply_range_per then
		return
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level
	local supply_type = HpBagData.Instance:GetRecoverHpByLevel(level).supply_type
	HpBagCtrl.Instance:SendSupplySetRecoverRangePer(supply_type,self.cur_percent)
end

function HpBagView:OpenCallBack()
	self.cur_percent = HpBagData.Instance:GetSupplySeverData().supply_range_per
	self.node_list["SliderProgressBG"].slider.value = self.cur_percent
	self.node_list["SliderProgressBG1"].slider.value = self.cur_percent
	self:FlushData()
end

function HpBagView:FlushData()
	self.data = HpBagData.Instance:GetSupplyData()
	self.node_list["TxtCurAllHp"].text.text = string.format(Language.HpBag.CurAllHp, HpBagData.Instance:GetSupplySeverData().supply_left_value)
	self.node_list["TxtValue"].text.text = string.format(Language.HpBag.ChuLiang, HpBagData.Instance:HpNumberChangeCallback(self.data[1].supply_value))
	self.node_list["TxtGoldValue"].text.text = self.data[1].price
	self.node_list["TxtRightValue"].text.text = string.format(Language.HpBag.ChuLiang, HpBagData.Instance:HpNumberChangeCallback(self.data[2].supply_value))
	self.node_list["TxtGoldValue1"].text.text = self.data[2].price

	self:FlushSliderData(self.cur_percent)
end

function HpBagView:FlushSliderData(value)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local add_percent = HpBagData.Instance:GetPercent() / 10000
	local cur_addhp = math.ceil(main_role_vo.base_max_hp * add_percent)
	self.node_list["TxtTips"].text.text = string.format(Language.Common.HpBag, value, cur_addhp)
end