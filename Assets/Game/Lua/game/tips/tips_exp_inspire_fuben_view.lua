TipsExpInSprieFuBenView = TipsExpInSprieFuBenView or BaseClass(BaseView)

function TipsExpInSprieFuBenView:__init()
	self.ui_config = {{"uis/views/tips/expviewtips_prefab", "ExpInspireFuBenTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipsExpInSprieFuBenView:LoadCallBack()
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.OnClickIsBuy, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
end

function TipsExpInSprieFuBenView:ReleaseCallBack()
	
end

function TipsExpInSprieFuBenView:OpenCallBack()
	self:Flush()
end

function TipsExpInSprieFuBenView:OnFlush()
	local scene_type = Scene.Instance:GetSceneType()
	
	if scene_type == SceneType.ChaosWar then	-- 一战到底
		self:SetYiZhanDaoDiText()
	else
		local cfg = FuBenData.Instance:GetExpFBCfg().exp_other_cfg[1]
		self.node_list["TxtMoney"].text.text = string.format(Language.Tips.Ci,cfg.buff_cost)
		self.node_list["TxtBefore"].text.text = string.format(Language.Tips.JiaCheng,FuBenData.Instance:GetInSpireDamage())
		self.node_list["TxtDamage"].text.text = string.format(Language.Tips.Damage,cfg.buff_add_gongji_per / 100,100)
		self.node_list["TxtBindGold"]:SetActive(true)
	end
end

function TipsExpInSprieFuBenView:SetYiZhanDaoDiText()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg() or {}
	self.node_list["TxtBefore"].text.text = string.format(Language.Tips.JiaCheng,user_info.gongji_guwu_per or 0)
	self.node_list["TxtMoney"].text.text = string.format(Language.Tips.Ci,other_cfg.gongji_guwu_gold or 0)
	self.node_list["TxtDamage"].text.text = string.format(Language.Tips.Damage,other_cfg.gongji_guwu_add_per or 0,other_cfg.gongji_guwu_max_per or 0)
	self.node_list["TxtBindGold"]:SetActive(false)
	if user_info.gongji_guwu_per == 50 then
		ViewManager.Instance:Close(ViewName.TipsExpInSprieFuBenView)
	end
end

function TipsExpInSprieFuBenView:ClickClose()
	self:Close()
end

function TipsExpInSprieFuBenView:OnClickBuyInYiZhanDaoDiScene()
	local user_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if nil == next(user_info) then return end

	local other_cfg = YiZhanDaoDiData.Instance:GetOtherCfg()
	if nil == other_cfg then return end

	if user_info.gongji_guwu_per >= other_cfg.gongji_guwu_max_per then
		TipsCtrl.Instance:ShowSystemMsg(Language.YiZhanDaoDi.MaxGuWu)
		return
	end

	YiZhanDaoDiCtrl.Instance:SendYiZhanDaoDiGuwuReq(YIZHANDAODI_GUWU_TYPE.YIZHANDAODI_GUWU_TYPE_GONGJI)
end

function TipsExpInSprieFuBenView:OnClickIsBuy()
	local scene_type = Scene.Instance:GetSceneType()

	if scene_type == SceneType.ChaosWar then	-- 一战到底
		self:OnClickBuyInYiZhanDaoDiScene()
	else
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

end

