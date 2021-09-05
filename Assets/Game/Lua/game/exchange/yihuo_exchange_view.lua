require("game/exchange/exchange_content_view")
YiHuoExchangeView = YiHuoExchangeView or BaseClass(BaseView)

local YIHUOEXCHANGETYPE = 15
local YIHUOICONID = 90021

function YiHuoExchangeView:__init()
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
	self.cur_index = TabIndex.exchange_yihuo
end

function YiHuoExchangeView:__delete()

end

function YiHuoExchangeView:ReleaseCallBack()
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

function YiHuoExchangeView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Title.YiHuoDuiHuan
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.AddMoneyClick, self))
	self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.OnClickMoney, self))

	local value = ExchangeData.Instance:GetScoreList()[2] or 0
	self.node_list["TextNum"].text.text = self:FormatMoney(value)
	self:LoadCell()
end

function YiHuoExchangeView:LoadCell()
	local res_async_loader = AllocResAsyncLoader(self, "loader")
	res_async_loader:Load("uis/views/exchangeview_prefab", "Content", nil, function (prefab)
		if nil == prefab then
			return
		end
		local obj = ResMgr:Instantiate(prefab)
		local obj_transform = obj.transform
		obj_transform:SetParent(self.node_list["NewExchangeContent"].transform, false)
		self.exchange_content_view = ExchangeContentView.New(obj)
		self.exchange_content_view:SetCurrentPriceType(YIHUOEXCHANGETYPE)
	end)
end

function YiHuoExchangeView:GetExchangeContentView()
	return self.exchange_content_view
end

function YiHuoExchangeView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

function YiHuoExchangeView:OpenCallBack()
	local bundle, asset = ResPath.GetExchangeNewIcon("YiHuo")
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["ImgIcon"].image:SetNativeSize()
	self:Flush("flush_list_view")
end

function YiHuoExchangeView:OnClickMoney()
	local data = {item_id = YIHUOICONID}
	TipsCtrl.Instance:OpenItem(data)
end

function YiHuoExchangeView:ShowIndexCallBack(index, index_nodes)
	self:ChangeContent(YIHUOEXCHANGETYPE)
	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(YIHUOEXCHANGETYPE)
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
end

function YiHuoExchangeView:AddMoneyClick()
	ViewManager.Instance:Open(ViewName.HunQiView, TabIndex.hunqi_bao)
	self:Close()
end

function YiHuoExchangeView:ChangeContent(tab_index)
	local bundle, asset = ResPath.GetExchangeNewIcon("YiHuo")
	if self.exchange_content_view then
		self.exchange_content_view:SetCurrentPriceType(tab_index)
		self.exchange_content_view:OnFlushListView()
		self.exchange_content_view:FlushCoin()
	end
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["BtnAdd"]:SetActive(false)
	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.SHENZHOU))
	self:ShowsSpecialBG()
end

function YiHuoExchangeView:OnFlush(param_t)
	self.node_list["TextNum"].text.text = self:FormatMoney(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.SHENZHOU))
	self:ShowsSpecialBG()
	if self.exchange_content_view then
		self.exchange_content_view:FlushCoin()
	end
end

function YiHuoExchangeView:ShowsSpecialBG()
	local is_show = ExchangeData.Instance:GetIsShowSpecialBg()
	self.node_list["BG"]:SetActive(is_show)
end