TipNewExchangeView = TipNewExchangeView or BaseClass(BaseView)
function TipNewExchangeView:__init()
	self.ui_config = {{"uis/views/exchangeview_prefab", "ChongWuExchangeTip"}}
	self.item_info = {}
	self.close_call_back = nil
	self.tips_text = Language.Exchange.CanNotBuy
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.content = ""
	self.single_price = ""
end

function TipNewExchangeView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TipNewExchangeView:LoadCallBack()
	self.buy_num_value = 1
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])

	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["Btn_buyNum"].button:AddClickListener(BindTool.Bind(self.OnClickInputField, self))
end

function TipNewExchangeView:OpenCallBack()
	self:Flush()
	self.buy_num_value = 1
	self.node_list["BuyNumTxt"].text.text = self.buy_num_value
end

function TipNewExchangeView:SetTipData(item_id, ok_fun, single_price, content, coin_bundle, coin_asset)
	self.item_id = item_id
	self.single_price = single_price
	self.content = content
	self.ok_fun = ok_fun
	self.coin_bundle = coin_bundle
	self.coin_asset = coin_asset
end

function TipNewExchangeView:OnFlush()
	if self.item_id ~= nil then
		self.item_cell:SetData({item_id = self.item_id})
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg == nil then return end
	local name = ToColorStr(item_cfg.name, SOUL_NAME_COLOR[item_cfg.color] or 0)
	self.node_list["ProName"].text.text = name or ""
	if nil ~= self.coin_bundle and nil ~= self.coin_asset then
		self.node_list["Img_coin"].image:LoadSprite(self.coin_bundle, self.coin_asset)
		self.node_list["Img_Dan_Coin"].image:LoadSprite(self.coin_bundle, self.coin_asset)
	end
	self.node_list["Desc"].text.text = self.content or ""

	if self.single_price ~= nil then
		self.node_list["SumPrice"].text.text = self.buy_num_value * self.single_price
		self.node_list["SumDanPrice"].text.text = self.single_price
	end
end

function TipNewExchangeView:OnBuyClick()
	if nil ~= self.ok_fun then
		self.ok_fun(self.buy_num_value)
		self:Close()
	end
end


function TipNewExchangeView:OnCloseClick()
	self:Close()
end

function TipNewExchangeView:OnClickInputField()
	local ok_fun = function (cur_str)
		self:SetBuyNumViewText(cur_str)
	end
	local cancle_func = function ()
		self:SetBuyNumViewText(self.buy_num_value)
	end
	local score = LittlePetData.Instance:GetCurJiFenByInfo() or 0 
	local max_num = 1
	if score / self.single_price > 0 then
		max_num = math.floor(score / self.single_price)
	end
	TipsCtrl.Instance:OpenCommonInputView(self.buy_num_value, ok_fun, cancle_func, max_num)
end

function TipNewExchangeView:SetBuyNumViewText(cur_str)
	self.node_list["BuyNumTxt"].text.text = tonumber(cur_str)
	self.buy_num_value = tonumber(cur_str)
	self:Flush()
end
