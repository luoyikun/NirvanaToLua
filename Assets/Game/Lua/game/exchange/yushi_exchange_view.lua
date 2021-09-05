require("game/exchange/exchange_content_view")
YuShiExchangeView = YuShiExchangeView or BaseClass(BaseView)

local YUSHIEXCHANGETYPE = 19
local YUSHIICONID = 90574

function YuShiExchangeView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_1"},
		{"uis/views/exchangeview_prefab", "NewExchangeContent"},
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel_2"},
	}
	self.full_screen = false
	self.play_audio = true
	self.is_first = true
	self.click_shengwang = false
	self.click_rongyao = false
	
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function YuShiExchangeView:__delete()

end

function YuShiExchangeView:ReleaseCallBack()
	if self.exchange_content_view ~= nil then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end

	if self.tabbar then 
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	-- 清理变量和对象
	self.show_block = nil
	self.title_name = nil
	self.show_add_money = nil
	self.toggle_list = nil
end

function YuShiExchangeView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Title.YuShiDuiHuan
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.AddMoneyClick, self))
	self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.OnClickMoney, self))
	local value = ExchangeData.Instance:GetScoreList()[2] or 0
	self.node_list["TextNum"].text.text = self:FormatMoney(value)
	self:LoadCell()
end

function YuShiExchangeView:LoadCell()
	local res_async_loader = AllocResAsyncLoader(self, "loader")
	res_async_loader:Load("uis/views/exchangeview_prefab", "Content", nil, function (prefab)
		if nil == prefab then
			return
		end
		local obj = ResMgr:Instantiate(prefab)
		local obj_transform = obj.transform
		obj_transform:SetParent(self.node_list["NewExchangeContent"].transform, false)
		self.exchange_content_view = ExchangeContentView.New(obj)
		self.exchange_content_view:SetCurrentPriceType(YUSHIEXCHANGETYPE)
	end)
end

function YuShiExchangeView:GetExchangeContentView()
	return self.exchange_content_view
end

function YuShiExchangeView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function YuShiExchangeView:OpenCallBack()
	local bundle, asset = ResPath.GetExchangeNewIcon("YuShi")
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgIcon"].image:SetNativeSize()
	self:Flush("flush_list_view")
end

function YuShiExchangeView:OnClickMoney()
	local data = {item_id = YUSHIICONID}
	TipsCtrl.Instance:OpenItem(data)
end

function YuShiExchangeView:ShowIndexCallBack(index, index_nodes)
	self:ChangeContent(YUSHIEXCHANGETYPE)
	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(YUSHIEXCHANGETYPE)
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
end

function YuShiExchangeView:AddMoneyClick()
	ViewManager.Instance:Open(ViewName.Forge,TabIndex.forge_jade)
	self:Close()
end

function YuShiExchangeView:ChangeContent(tab_index)
	local bundle, asset = ResPath.GetExchangeNewIcon("YuShi")
	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(tab_index)
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["BtnAdd"]:SetActive(false)
	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.YUSHI))
	self:ShowsSpecialBG()
end

function YuShiExchangeView:OnFlush(param_t)
	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.YUSHI))
	self:ShowsSpecialBG()
	if self.exchange_content_view then
		self.exchange_content_view:FlushCoin()
	end
end

function YuShiExchangeView:ShowsSpecialBG()
	local is_show = ExchangeData.Instance:GetIsShowSpecialBg()
	self.node_list["BG"]:SetActive(is_show)
end