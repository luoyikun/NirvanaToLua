KuaFuXiuLuoTowerBuyView = KuaFuXiuLuoTowerBuyView or BaseClass(BaseView)

function KuaFuXiuLuoTowerBuyView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/kuafuxiuluotower_prefab", "XiuLuoTaBuffView"}}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
end

function KuaFuXiuLuoTowerBuyView:__delete()
	PlayerPrefsUtil.DeleteKey("kf_xlt_inspire")
	PlayerPrefsUtil.DeleteKey("kf_xlt_buy_revive")
end

function KuaFuXiuLuoTowerBuyView:ReleaseCallBack()

end

function KuaFuXiuLuoTowerBuyView:OpenCallBack()
end

function KuaFuXiuLuoTowerBuyView:CloseCallBack()
	PlayerPrefsUtil.DeleteKey("kf_xlt_inspire")
	PlayerPrefsUtil.DeleteKey("kf_xlt_buy_revive")
end

function KuaFuXiuLuoTowerBuyView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnInspire"].button:AddClickListener(BindTool.Bind(self.OnClickBuyHandler, self, 0, 0))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickBuyHandler, self, 1, 1))
	self:Flush()
end

function KuaFuXiuLuoTowerBuyView:OnClickBuyHandler(is_buy_realive_count, is_use_gold_bind)
	local other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]
	if is_buy_realive_count == 0 then
		local func  = function ()
			KuaFuXiuLuoTowerCtrl.Instance:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
		end
		TipsCtrl.Instance:ShowCommonAutoView("kf_xlt_inspire", string.format(Language.Honorhalls.GuwuTips, other_cfg.yb_guwu_cost), func)
	else
		local func  = function ()
			KuaFuXiuLuoTowerCtrl.Instance:SendCrossXiuluoTowerBuyBuff(is_buy_realive_count, is_use_gold_bind)
		end
		TipsCtrl.Instance:ShowCommonAutoView("kf_xlt_buy_revive", string.format(Language.Honorhalls.BuyFuhuoTips, other_cfg.buy_fuhuo_cost), func)
	end
end

function KuaFuXiuLuoTowerBuyView:OnFlush()
	local buff_info = KuaFuXiuLuoTowerData.Instance:GetAttrInfo()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("kuafu_rongyudiantang_auto").other[1]

	self.node_list["TxtGongjiInspire"].text.text = string.format(Language.XiuLuo.GongjiInspire, buff_info.add_gongji_per)
	self.node_list["TxtHpInspire"].text.text = string.format(Language.XiuLuo.HpInspire, buff_info.add_hp_per)
	self.node_list["TxtMaxInspire"].text.text = string.format(Language.XiuLuo.MaxInspire, other_cfg.add_guwu)
	self.node_list["TxtCostAndAdd"].text.text = string.format(Language.XiuLuo.InspireCost, other_cfg.yb_guwu_cost, 5)
	self.node_list["TxtReviveCount"].text.text = string.format(Language.XiuLuo.ReviveCount, buff_info.buy_realive_count + other_cfg.fuhuo_count)
	self.node_list["TxtMaxBuy"].text.text = string.format(Language.XiuLuo.MaxBuy, 5)
	self.node_list["TxtBuyOneCost"].text.text = string.format(Language.XiuLuo.OnceBuyCost, other_cfg.buy_fuhuo_cost)
end

