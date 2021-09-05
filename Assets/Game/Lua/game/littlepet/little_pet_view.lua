require("game/littlepet/little_pet_home_view")
require("game/littlepet/little_pet_feed_view")
require("game/littlepet/little_pet_toy_view")
require("game/littlepet/little_pet_shop_view")
require("game/littlepet/little_pet_exchange_view")

-- local HOME_TOGGLE = 1
-- local FEED_TOGGLE = 2
-- local TOY_TOGGLE = 3
-- local SHOP_TOGGLE = 4
-- local EXCHANGE_TOGGLE = 5

LittlePetView = LittlePetView or BaseClass(BaseView)

function LittlePetView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		
		{"uis/views/littlepetview_prefab", "HomeContent" , {TabIndex.little_pet_home}},					-- 家园界面
		{"uis/views/littlepetview_prefab", "FeedContent" , {TabIndex.little_pet_feed}},					-- 喂养界面
		{"uis/views/littlepetview_prefab", "ToyContent" , {TabIndex.little_pet_toy}},					-- 玩具界面
		{"uis/views/littlepetview_prefab", "ShopContent" , {TabIndex.little_pet_shop}},					-- 商店界面
		{"uis/views/littlepetview_prefab", "ExchangeContent" , {TabIndex.little_pet_exchange}},			-- 商店界面

		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		{"uis/views/littlepetview_prefab", "JiFenContent"},												-- 积分数值
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.def_index = TabIndex.little_pet_home
end

function LittlePetView:__delete()

end

function LittlePetView:ReleaseCallBack()
	self.view_cfg = {}
	self.index_cfg = {}
	self.red_point_list = {}
	if self.open_trigger_handle then 
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end
	if self.pet_home then
		self.pet_home:DeleteMe()
		self.pet_home = nil
	end

	if self.pet_feed then
		self.pet_feed:DeleteMe()
		self.pet_feed = nil
	end
	if self.pet_toy then
		self.pet_toy:DeleteMe()
		self.pet_toy = nil
	end
	if self.pet_shop then
		self.pet_shop:DeleteMe()
		self.pet_shop = nil
	end
	if self.pet_exchange then
		self.pet_exchange:DeleteMe()
		self.pet_exchange = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function LittlePetView:LoadCallBack()
	self.view_cfg = {}
	self.index_cfg = {}
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTab, self))
	------------------------------------------------New代码--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Tab的自定义配置文件
	local tab_cfg = {
	{name = Language.LittlePet.TabbarName[1], bundle = "uis/images_atlas", asset = "icon_tab_shenge_1", tab_index = TabIndex.little_pet_home, remind_id = RemindName.LittlePetHome},
	{name = Language.LittlePet.TabbarName[2], bundle = "uis/images_atlas", asset = "icon_tab_shenge_4", tab_index = TabIndex.little_pet_feed, remind_id = RemindName.LittlePetFeed},
	{name = Language.LittlePet.TabbarName[3], bundle = "uis/images_atlas", asset = "icon_tab_shenge_3", tab_index = TabIndex.little_pet_toy, remind_id = RemindName.LittlePetToy},
	{name = Language.LittlePet.TabbarName[4], bundle = "uis/images_atlas", asset = "icon_tab_shenge_4", tab_index = TabIndex.little_pet_shop, remind_id = RemindName.LittlePetShop},
	{name = Language.LittlePet.TabbarName[5], bundle = "uis/images_atlas", asset = "icon_tab_shenge_3", tab_index = TabIndex.little_pet_exchange, remind_id = RemindName.LittlePetExchange},
	}
	-- Tab标签的生成
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	-- 界面名字 ，点击加钱按钮的监听 ， 关闭按钮
	self.node_list["TxtTitle"].text.text = Language.LittlePet.ViewName
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddGold, self))
	self.node_list["Btn_jifen_getway"].button:AddClickListener(BindTool.Bind(self.OnClickjifenGetWay, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["UnderBg"]:SetActive(false)
	self.node_list["TaiZi"].rect.anchoredPosition3D = Vector3(-54, -272, 0)
end

function LittlePetView:SetBg(index)
	local call_back = function ()
		self.node_list["UnderBg"]:SetActive(true)
	end
	if index == TabIndex.little_pet_home then
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_little", "bg_little.jpg", call_back)
	else
		self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/bg_common1_under", "bg_common1_under.jpg", call_back)
	end
end

function LittlePetView:ShowIndexCallBack(index ,index_nodes)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		self:Close()
		return
	end
	self.tabbar:ChangeToIndex(index)
	self:SetBg(index)
	if index_nodes then
		if index == TabIndex.little_pet_home then
			self.pet_home = LittlePetHomeView.New(index_nodes["HomeContent"])
			--self.pet_home:Flush()
		elseif index == TabIndex.little_pet_feed then
			self.pet_feed = LittlePetFeedView.New(index_nodes["FeedContent"])
			--self.pet_feed:Flush()
		elseif index == TabIndex.little_pet_toy then
			self.pet_toy = LittlePetToyView.New(index_nodes["ToyContent"])
			--self.pet_toy:Flush()
		elseif index == TabIndex.little_pet_shop then
			self.pet_shop = LittlePetShopView.New(index_nodes["ShopContent"])
			--self.pet_shop:Flush()
		elseif index == TabIndex.little_pet_exchange then
			self.pet_exchange = LittlePetExchangeView.New(index_nodes["ExchangeContent"])
			--self.pet_exchange:Flush()
		end
	end

	if index == TabIndex.little_pet_home then
		--self.pet_home:UIsMove()
		self.node_list["TaiZi"]:SetActive(false)
		self.pet_home:OpenCallBack()
		--self.pet_home:Flush()
	elseif index == TabIndex.little_pet_feed then
		--self.pet_feed:UIsMove()
		self.node_list["TaiZi"]:SetActive(true)
		self.node_list["TaiZi"].transform.localPosition = Vector3(-92, -272, 0)
		self.pet_feed:OpenCallBack()
		--self.pet_feed:Flush()
	elseif index == TabIndex.little_pet_toy then
		--self.pet_toy:UIsMove()
		self.node_list["TaiZi"]:SetActive(true)
		self.node_list["TaiZi"].transform.localPosition = Vector3(-92, -272, 0)
		self.pet_toy:OpenCallBack()
		--self.pet_toy:Flush()
	elseif index == TabIndex.little_pet_shop then
		--self.pet_shop:UIsMove()
		self.node_list["TaiZi"]:SetActive(false)
		self.pet_shop:OpenCallBack()
		--self.pet_shop:Flush()
	elseif index == TabIndex.little_pet_exchange then
		--self.pet_exchange:UIsMove()
		self.node_list["TaiZi"]:SetActive(false)
		self.pet_exchange:OpenCallBack()
		--self.pet_exchange:Flush()
	end
	self:CloseFlush(index)
end
function LittlePetView:CloseFlush(index)
	if index ~= TabIndex.little_pet_home and self.pet_home then
		self.pet_home:CloseCallBack()
	elseif index ~= TabIndex.little_pet_feed and self.pet_feed then
		self.pet_feed:CloseCallBack()
	elseif index ~= TabIndex.little_pet_toy and self.pet_toy then
		self.pet_toy:CloseCallBack()
	elseif index ~= TabIndex.little_pet_shop and self.pet_shop then
		self.pet_shop:CloseCallBack()
	elseif index ~= TabIndex.little_pet_exchange and self.pet_exchange then
		self.pet_exchange:CloseCallBack()
	end
end
-- 刷新界面
function LittlePetView:OnFlush(param_list)
	-- 刷新积分数值
	self:ShowJiFen()

	local cur_index = self:GetShowIndex()
	
	if cur_index == TabIndex.little_pet_home then
		if nil == self.pet_home then return end
		self.pet_home:Flush(param_list)
	elseif cur_index == TabIndex.little_pet_feed then
		if nil == self.pet_feed then return end
		self.pet_feed:Flush(param_list)
	elseif cur_index == TabIndex.little_pet_toy then
		if nil == self.pet_toy then return end
		self.pet_toy:Flush(param_list)
	elseif cur_index == TabIndex.little_pet_shop then
		if nil == self.pet_shop then return end
		self.pet_shop:Flush(param_list)
	elseif cur_index == TabIndex.little_pet_exchange then
		if nil == self.pet_exchange then return end
		self.pet_exchange:Flush(param_list)
	end
	-- 刷新Tabbar
	self:FlushTab()
end

function LittlePetView:GetChouJiangReward()
	if self.pet_shop then
		self.pet_shop:GetChouJiangRewardByInfo()
	end
end
-- 点击加钱按钮
function LittlePetView:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 打开界面
function LittlePetView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	self:FlushTab()
	self:ShowJiFen()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

-- 元宝，绑元数值赋值
function LittlePetView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(vo.gold)
	end

	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end
end
-- 关闭界面
function LittlePetView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	local cur_index = self:GetShowIndex()
	
	if cur_index == TabIndex.little_pet_home then
		if nil == self.pet_home then return end
		self.pet_home:CloseCallBack()
	elseif cur_index == TabIndex.little_pet_feed then
		if nil == self.pet_feed then return end
		self.pet_feed:CloseCallBack()
	elseif cur_index == TabIndex.little_pet_toy then
		if nil == self.pet_toy then return end
		self.pet_toy:CloseCallBack()
	elseif cur_index == TabIndex.little_pet_shop then
		if nil == self.pet_shop then return end
		self.pet_shop:CloseCallBack()
	elseif cur_index == TabIndex.little_pet_exchange then
		if nil == self.pet_exchange then return end
		self.pet_exchange:CloseCallBack()
	end
end

function LittlePetView:FlushTab()
	self.tabbar:FlushTabbar()
end

function LittlePetView:ShowJiFen()
	local ji_fen = LittlePetData.Instance:GetCurJiFenByInfo()
	ji_fen = CommonDataManager.ConverMoney(ji_fen)
	self.node_list["TxtJiFen"].text.text = ji_fen
end

function LittlePetView:ItemDataChangeCallback()
	LittlePetCtrl.Instance:FlushRecycleView()
	self:Flush()
end

function LittlePetView:OnClickjifenGetWay()
	local item_id = 90346
	TipsCtrl.Instance:ShowItemGetWayView(item_id)
end