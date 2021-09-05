TipGuildDuiHuanView = TipGuildDuiHuanView or BaseClass(BaseView)

function TipGuildDuiHuanView:__init()
	self.ui_config = {{"uis/views/tips/shoporexchangetip_prefab", "ShopOrExchangeTip"}}
	self.item_info = {}
	self.buy_num_value = 0

	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function TipGuildDuiHuanView:__delete()
end

function TipGuildDuiHuanView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TipGuildDuiHuanView:LoadCallBack()
	local handler = function()
		if self.item_cell then 
			self.item_cell:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_cell:GetData())
		end
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])
	self.item_cell:ListenClick(handler)
	self.node_list["BtnReduceButton"].button:AddClickListener(BindTool.Bind(self.OnMinusClick, self))
	self.node_list["BtnPlusButton"].button:AddClickListener(BindTool.Bind(self.OnPlusClick, self))
	self.node_list["TxtMaxText"].button:AddClickListener(BindTool.Bind(self.OnMaxClick, self))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnBuyClick, self))
	self.node_list["BtnCloseButton"].button:AddClickListener(BindTool.Bind(self.OnCloseClick, self))
	self.node_list["BtnInputClick"].button:AddClickListener(BindTool.Bind(self.OnTextClick, self))

	self.node_list["TxtBuyText"].text.text = Language.Common.DuiHuan
	self.node_list["TxtIconName"].text.text = Language.Common.DuiHuan
end

function TipGuildDuiHuanView:SetItemId(item_id, is_bind)
	self.item_info = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	self.item_info.is_bind = is_bind
	self.item_info.item_id = item_id
end

function TipGuildDuiHuanView:CloseCallBack()
	self.item_info = {}
end

function TipGuildDuiHuanView:OpenCallBack()
	local spec_id = GuildData.Instance:GetGuildConfig().storage_constant_item_id or 22703
	local sepc_score = GuildData.Instance:GetGuildConfig().constant_item_storage_score or 5000
	local price = 0
	if self.item_info and (self.item_info.item_id == spec_id) and sepc_score > 0 then
		price = sepc_score
	end
	if next(self.item_info) ~= nil then
		self.node_list["TxtProName"].text.text = ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color])
		self.node_list["TxtBuyOnePrice"].text.text = price
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self.node_list["TxtBuyOnePrice"].text.text = price
		self:SetAllPrice()
		if self.item_cell then
			self.item_cell:SetData(self.item_info)
		end
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		local use_level = PlayerData.GetLevelString(self.item_info.limit_level)
		local level_color = role_level < self.item_info.limit_level and TEXT_COLOR.RED or TEXT_COLOR.GREEN
		self.node_list["TxtDesc"].text.text = string.format(Language.Tip.ShiYongDengJi, ToColorStr(use_level, level_color))
	end

	local bundle, asset = "uis/views/tips/shoporexchangetip/images_atlas", "icon_warehouse_score"
	self.node_list["ImgCoinIcon1"].image:LoadSprite(bundle, asset)
	self.node_list["ImgCoinIcon2"].image:LoadSprite(bundle, asset)
	self.node_list["ImgCoinIcon3"].image:LoadSprite(bundle, asset)
	self.node_list["TextDesc"].text.text = self.item_info.description

	self:FlushCoin()
end

function TipGuildDuiHuanView:FlushCoin()
	local count = GameVoManager.Instance:GetMainRoleVo().gold
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.node_list["TxtMyCoin"].text.text = count
end

function TipGuildDuiHuanView:CloseCallBack()
	self.buy_num_value = 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
end

function TipGuildDuiHuanView:OnPlusClick()
	local can_buy_num = self:GetCanBuyNum()
	if can_buy_num > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		if self.buy_num_value > 999 then
			self.buy_num_value = 999
		end
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self:SetAllPrice()
	end
end

function TipGuildDuiHuanView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	self.buy_num_value = self.buy_num_value - 1
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self:SetAllPrice()
end

function TipGuildDuiHuanView:OnMaxClick()
	self.buy_num_value = self:GetCanBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	self:SetAllPrice()
end

function TipGuildDuiHuanView:GetCanBuyNum()
	local can_buy_num = 0
	local spec_id = GuildData.Instance:GetGuildConfig().storage_constant_item_id or 22703
	local sepc_score = GuildData.Instance:GetGuildConfig().constant_item_storage_score or 5000
	local price = 0
	if self.item_info and (self.item_info.item_id == spec_id) and sepc_score > 0 then
		price = sepc_score
	end
	local storge_info = GuildData.Instance:GetGuildStorgeInfo()
	if not storge_info or not storge_info.storage_score then
		return can_buy_num
	end
	local money_can_buy = price ~= 0 and math.floor(storge_info.storage_score / price) or 0
	local pile_limit = self.item_info.pile_limit
	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end
	return can_buy_num
end

function TipGuildDuiHuanView:SetAllPrice()
	local spec_id = GuildData.Instance:GetGuildConfig().storage_constant_item_id or 22703
	local sepc_score = GuildData.Instance:GetGuildConfig().constant_item_storage_score or 5000
	local price = 0
	if self.item_info and (self.item_info.item_id == spec_id) and sepc_score > 0 then
		price = sepc_score
	end
	self.node_list["TxtBuyAllPrice"].text.text = price * self.buy_num_value
end

function TipGuildDuiHuanView:OnBuyClick()
	if nil == self.item_info then return end
	
	if self.buy_num_value == 0 then
		return
	end
		GuildCtrl.Instance:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_TAKE_ITEM, self.item_info.index, self.buy_num_value, self.item_info.id)
	if self.buy_num_value <= self:GetCanBuyNum() then
		self.buy_num_value = 1
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
		self:Close()
	end
end

function TipGuildDuiHuanView:OnCloseClick()
	self:Close()
end

function TipGuildDuiHuanView:OnTextClick()
	local open_func = function(buy_num)
		local can_buy_num = self:GetCanBuyNum()
		if buy_num + 0 == 0 then
			self.buy_num_value = 1
			return
		end

		if buy_num + 0 <= can_buy_num then
			self.buy_num_value = buy_num + 0
		else
			if can_buy_num == 0 then
				self.buy_num_value = 1
			else
				self.buy_num_value = can_buy_num
			end
		end
		self.node_list["TxtBuyNum"].text.text = self.buy_num_value
	end

	local close_func = function()
		self:SetAllPrice()
	end

	local max = 0
	if self:GetCanBuyNum() == 0 then
		max = 1
	else
		max = self:GetCanBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max)
end