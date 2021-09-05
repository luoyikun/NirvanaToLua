TipsSpiritExpBuyBuffView = TipsSpiritExpBuyBuffView or BaseClass(BaseView)

function TipsSpiritExpBuyBuffView:__init()
	self.ui_config = {{"uis/views/tips/spirithometip_prefab", "SpiritBuffBuyTips"}}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsSpiritExpBuyBuffView:__delete()
end

function TipsSpiritExpBuyBuffView:ReleaseCallBack()
end

function TipsSpiritExpBuyBuffView:OpenCallBack()
	self:Flush()
end

function TipsSpiritExpBuyBuffView:CloseCallBack()

end

function TipsSpiritExpBuyBuffView:LoadCallBack()
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
end

function TipsSpiritExpBuyBuffView:CloseView() 
	self:Close()
end

function TipsSpiritExpBuyBuffView:OnClickBuy()
	local buy_count = SpiritData.Instance:GetExploreBuyBuffCount()
	local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_max_count") or 0
	if buy_count >= limlit_count then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritexpNoCanBuyBuff)
		return
	end
	SpiritCtrl.Instance:SendJingLingExploreOperReq(JL_EXPLORE_OPER_TYPE.JL_EXPLORE_OPER_TYPE_BUY_BUFF)
end

function TipsSpiritExpBuyBuffView:OnFlush()
	local buy_count = SpiritData.Instance:GetExploreBuyBuffCount()
	local up_value = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_add_per") or 0
	local limlit_count = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_max_count") or 0
	local buy_consume = SpiritData.Instance:GetSpiritOtherCfgByName("explore_buff_buy_gold") or 0
	self.node_list["TxtBuyStr"].text.text = string.format(Language.JingLing.SpiritExpBuyStr, up_value)
	self.node_list["TxtButTips"].text.text = string.format(Language.JingLing.SpiritExpBuffLimlit, limlit_count)
	self.node_list["TxtBuyLimit"].text.text = string.format(Language.JingLing.SpiritexpBuffUp, buy_count, limlit_count)
	self.node_list["TxtmoneyText"].text.text = string.format(Language.Tips.Ci, buy_consume)
end