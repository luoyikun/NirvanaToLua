require("game/couple_home/couple_home_home_view")
require("game/couple_home/couple_home_shop_view")
require("game/couple_home/couple_home_theme_buy_view")

CoupleHomeView = CoupleHomeView or BaseClass(BaseView)

function CoupleHomeView:__init()
	self.ui_config = {
		{"uis/views/couplehome_prefab", "CoupleHomeView"},
		{"uis/views/couplehome_prefab", "HomeContent", {TabIndex.couple_home_home}},				--家园
		{"uis/views/couplehome_prefab", "ShopContent", {TabIndex.couple_home_shop}},				--家具商城
		{"uis/views/couplehome_prefab", "ThemeBuyView", {TabIndex.couple_home_buy}},				--房子购买
		{"uis/views/couplehome_prefab", "CoupleHomePanleView"},
	}

	self.play_audio = true
	self.is_init_toggle = true
	self.is_modal = true
	self.def_index = TabIndex.couple_home_home
	
	-- self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
end

function CoupleHomeView:__delete()
end

function CoupleHomeView:ReleaseCallBack()
	if self.home_view ~= nil then
		self.home_view:DeleteMe()
		self.home_view = nil
	end

	if self.shop_view ~= nil then
		self.shop_view:DeleteMe()
		self.shop_view = nil
	end

	if self.buy_view ~= nil then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end

	self.variable_list = nil
	self.other_node_list = nil
end

function CoupleHomeView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["ToggleHome"].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, TabIndex.couple_home_home))
	self.node_list["ToggleShop"].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, TabIndex.couple_home_shop))
	self.node_list["ToggleBuy"].toggle:AddClickListener(BindTool.Bind(self.ChangeToIndex, self, TabIndex.couple_home_buy))
end

function CoupleHomeView:RemindChangeCallBack(key, value)
	
end

function CoupleHomeView:CloseWindow()
	self:Close()
end

function CoupleHomeView:OpenCallBack()
	-- 监听系统事件
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	local house_list = CoupleHomeHomeData.Instance:GetHouseList() or {}
	if #house_list > 0 then
		self.node_list["TabBuy"]:SetActive(true)
		self.node_list["HighText"].text.text = Language.CoupleHome.LayoutHome
		self.node_list["NormalText"].text.text = Language.CoupleHome.LayoutHome
	else
		self.node_list["TabBuy"]:SetActive(false)
		self.node_list["HighText"].text.text = Language.CoupleHome.BuyHome
		self.node_list["NormalText"].text.text = Language.CoupleHome.BuyHome
	end
	-- self:ShowOrHideTab()
	self.node_list["ToggleHome"].toggle.isOn = true
	--请求家园所有信息
	CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_ALL_INFO)
	self:FlushIcon()
end

function CoupleHomeView:CloseCallBack()
	local index = self.show_index or 0
	-- local view_cfg_info = self.view_cfg[index]
	-- if view_cfg_info and view_cfg_info.view and view_cfg_info.view.CloseView then
	-- 	view_cfg_info.view:CloseView()
	-- end

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function CoupleHomeView:ShowOrHideTab()
	for k, v in pairs(self.view_cfg) do
		v.tab:SetActive(OpenFunData.Instance:FunIsUnLock(v.funopen_name) == true)
	end
end

function CoupleHomeView:ClickTab(tab_index)
	if tab_index == self.show_index then
		return
	end

	self.is_init_toggle = false
	self:ShowIndex(tab_index)
end

function CoupleHomeView:InitAllToggleIsOn()
	for k, v in pairs(self.view_cfg) do
		v.toggle.toggle.isOn = false
	end
end

function CoupleHomeView:AsyncLoadCallBack(index, obj)
	local view_cfg_info = self.view_cfg[index]
	if view_cfg_info then
		obj.transform:SetParent(view_cfg_info.content.transform, false)
		obj = U3DObject(obj)
		view_cfg_info.view = view_cfg_info.view_class.New(obj)

		if self.show_index == index then
			view_cfg_info.view:InitView()
		end
	end
end

function CoupleHomeView:ShowIndexCallBack(index, index_nodes)
	if nil ~= index_nodes then
		if index == TabIndex.couple_home_home then
			self.home_view = CoupleHomeHomeContentView.New(index_nodes["HomeContent"])
		elseif index == TabIndex.couple_home_shop then
			self.shop_view = CoupleHomeShopContentView.New(index_nodes["ShopContent"])	
		elseif index == TabIndex.couple_home_buy then
			self.buy_view = CoupleHomeThemeBuyView.New(index_nodes["ThemeBuyView"])
		end
	end

	self.show_index = index
	if index == TabIndex.couple_home_home and self.home_view then
		self.home_view:Flush("decorate")
		self.home_view:Flush("buy")
		local house_list = CoupleHomeHomeData.Instance:GetHouseList() or {}
		if #house_list <= 0 and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
			RemindManager.Instance:SetRemindToday(RemindName.FiftyPercent)
		end
	elseif index == TabIndex.couple_home_shop and self.shop_view then 
		self.shop_view:Flush()
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE) then
			RemindManager.Instance:SetRemindToday(RemindName.BuyOneGetOne)
		end
	elseif index == TabIndex.couple_home_buy and self.buy_view then 
		self.buy_view:Flush()
		local house_list = CoupleHomeHomeData.Instance:GetHouseList() or {}
		if #house_list > 0 and ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
			RemindManager.Instance:SetRemindToday(RemindName.FiftyPercent)
		end
	end
	
	self.node_list["ToggleHome"].toggle.isOn = index == TabIndex.couple_home_home
	self.node_list["ToggleShop"].toggle.isOn = index == TabIndex.couple_home_shop
	self.node_list["ToggleBuy"].toggle.isOn = index == TabIndex.couple_home_buy
end

function CoupleHomeView:OnFlush(param_t)
	local index = self.show_index or 0
	--根据index取得对应的界面配置
	-- local view_cfg_info = self.view_cfg[index]
	-- if nil == view_cfg_info then
	-- 	return
	-- end

	-- local view = view_cfg_info.view
	-- if nil == view then
	-- 	return
	-- end

	-- local flush_params = view_cfg_info.flush_params

	for k, v in pairs(param_t) do
		if self.show_index == TabIndex.couple_home_home then
			self.home_view:Flush(k, v)
		elseif self.show_index == TabIndex.couple_home_shop then
			self.shop_view:Flush(k, v)
		elseif self.show_index == TabIndex.couple_home_buy then
			self.buy_view:Flush(k, v)
		end

		if k == "decorate" and v.house_count_change then
			self.node_list["TabBuy"]:SetActive(true)
			self:FlushIcon()
			self.node_list["HighText"].text.text = Language.CoupleHome.LayoutHome
			self.node_list["NormalText"].text.text = Language.CoupleHome.LayoutHome
			-- ViewManager.Instance:Open(ViewName.CoupleHomeView, TabIndex.couple_home_buy)
		end
	end
end

function CoupleHomeView:FlushIcon()
	local house_list = CoupleHomeHomeData.Instance:GetHouseList() or {}
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		self.node_list["FiftyPercent"]:SetActive(#house_list <= 0)
		self.node_list["FiftyPercentHaveBuy"]:SetActive(#house_list > 0)
	else
		self.node_list["FiftyPercent"]:SetActive(false)
		self.node_list["FiftyPercentHaveBuy"]:SetActive(false)
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE) then
		self.node_list["BuyOneGetOne"]:SetActive(true)
	else
		self.node_list["BuyOneGetOne"]:SetActive(false)
	end
	if #house_list > 0 then
		if self.buy_view and self.show_index == TabIndex.couple_home_buy then
			self.buy_view:Flush()
		end
	else
		if self.home_view and self.show_index == TabIndex.couple_home_home then
			self.home_view:Flush("buy")
		end
	end
	if self.show_index == TabIndex.couple_home_shop and self.shop_view then 
		self.shop_view:Flush()
	end
end