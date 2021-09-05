TipsExpFuBenGuWuView = TipsExpFuBenGuWuView or BaseClass(BaseView)

function TipsExpFuBenGuWuView:__init()
	self.ui_config = {{"uis/views/tips/expviewtips_prefab", "ExpFuBenGuWuTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsExpFuBenGuWuView:LoadCallBack()
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.OnClickIsBuy, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["ToggleGuWu"].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleIsAutoGuWu, self))
	self.node_list["ToggleGuWu"].toggle.isOn = FuBenData.Instance:GetIsAutoGuWu()
end

function TipsExpFuBenGuWuView:ReleaseCallBack()
	
end

function TipsExpFuBenGuWuView:OpenCallBack()
	self:Flush()
end

function TipsExpFuBenGuWuView:OnFlush()
	local cfg = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1]
	self.node_list["TxtMoney"].text.text = string.format(Language.Tips.Ci, cfg.buff_cost)
	self.node_list["TxtDamage"].text.text = string.format(Language.Tips.GuWuXiaoGuo, cfg.buff_add_gongji_per / 100)
	self.node_list["Text_2"].text.text = string.format(Language.Tips.ShengYuCount, FuBenData.Instance:GetExpFuBenGuWuCount(), cfg.max_buff_time or 10)
end

function TipsExpFuBenGuWuView:ClickClose()
	self:Close()
end

function TipsExpFuBenGuWuView:OnClickIsBuy()
	local exp_fb_info = FuBenData.Instance:GetExpFBInfo()
	local max_guwu = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1].max_buff_time
	if exp_fb_info.guwu_times >= max_guwu then
		TipsCtrl.Instance:ShowSystemMsg(Language.FB.InspireLimit)
		self:ClickClose()
		return 
	end
	local need_money = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1].buff_cost
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.gold + vo.bind_gold >= need_money then
		FuBenCtrl.Instance:SendExpFbPayGuwu()
	else
		TipsCtrl.Instance:ShowLackDiamondView()
	end
end

function TipsExpFuBenGuWuView:OnToggleIsAutoGuWu()
	FuBenData.Instance:SetIsAutoGuWu(self.node_list["ToggleGuWu"].toggle.isOn)
end

