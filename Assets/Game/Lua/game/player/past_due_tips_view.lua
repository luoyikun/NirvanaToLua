TipsPastDueView = TipsPastDueView or BaseClass(BaseView)

function TipsPastDueView:__init()
	self.ui_config = {{"uis/views/player_prefab", "PastDueTips"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.play_audio = true
	self.is_any_click_close = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.imp_guard_type = 0
	self.is_use_bind_gold = 0
end

function TipsPastDueView:LoadCallBack()
	self.imp_guard_item = ItemCell.New()
	self.imp_guard_item:SetInstanceParent(self.node_list["Item"])

	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickButton, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function TipsPastDueView:ReleaseCallBack()
	if self.imp_guard_item ~= nil then
		self.imp_guard_item:DeleteMe()
		self.imp_guard_item = nil
	end
end

function TipsPastDueView:OpenCallBack()
	self:Flush()
end

function TipsPastDueView:CloseCallBack()

end

function TipsPastDueView:SetData(data, index)
	if nil == data then
		return
	end
	
	self.data = data
	self.index = index or 0
end

function TipsPastDueView:Flush()
	local imp_cfg = EquipData.GetXiaoGuiCfgById(self.data.item_id)
	if not imp_cfg then
		return
	end

	self.is_use_bind_gold = imp_cfg.is_bind_gold
	local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
	if (self.is_use_bind_gold == 1 and bind_gold < imp_cfg.gold_price) or self.is_use_bind_gold == 0 then
		self.is_use_bind_gold = 0
	end

	if self.is_use_bind_gold == 1 then
		self.node_list["Gold"].text.text = imp_cfg.gold_price
	else
		self.node_list["Gold"].text.text = imp_cfg.gold_price
	end
	self.node_list["GoldImage"]:SetActive(self.is_use_bind_gold ~= 1)
	self.node_list["BindGoldImage"]:SetActive(self.is_use_bind_gold == 1)

	local data = {item_id = self.data.item_id, invalid_time = self.data.invalid_time}
	self.imp_guard_item:SetData(data)
end

function TipsPastDueView:OnClickButton()
	local param1 = self.data.is_inbag == IMP_GUARD_REQ_TYPE.IMP_GUARD_REQ_TYPE_RENEW_KNAPSACK and self.data.index or self.index
	
	local yes_func = function() 
		PlayerCtrl.Instance:SendImpGuardOperaReq(self.data.is_inbag, param1, self.is_use_bind_gold)
	end
	local imp_cfg = EquipData.GetXiaoGuiCfgById(self.data.item_id)
	if not imp_cfg or next(imp_cfg) == nil then return end

	local describe = string.format(Language.Player.XuFeiText[self.is_use_bind_gold], imp_cfg.imp_guard_name, imp_cfg.gold_price)
	TipsCtrl.Instance:ShowCommonAutoView("pastdue_view", describe, yes_func)

	self:Close()
end

function TipsPastDueView:OnClickClose()
	self:Close()
end