require("game/symbol/symbol_info_view")
require("game/symbol/symbol_fuzhou_view")
require("game/symbol/symbol_yuanhun_view")
require("game/symbol/symbol_yuanzhuang_view")
require("game/symbol/symbol_mishi_view")
require("game/symbol/symbol_upgrade_view")

SymbolView = SymbolView or BaseClass(BaseView)

function SymbolView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/symbol_prefab", "InfoContent", {TabIndex.symbol_intro}},
		-- {"uis/views/symbol_prefab", "FuzhouContent", {TabIndex.symbol_fuzhou}},
		-- {"uis/views/symbol_prefab", "YuanhunContent", {TabIndex.symbol_yuanhun}},
		--{"uis/views/symbol_prefab", "YuanzhuangContent", {TabIndex.symbol_yuanzhuang}},
		{"uis/views/symbol_prefab", "MishiContent", {TabIndex.symbol_mishi}},
		{"uis/views/symbol_prefab", "UpgradeContent", {TabIndex.symbol_upgrade}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
		-- {"uis/views/symbol_prefab", "MiShiJiFen"},
	}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.symbol_intro
	self.cur_toggle = INFO_TOGGLE
	self.view_cfg = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.FlushTabbar, self))
	self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
end

function SymbolView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function SymbolView:ItemDataChangeCallback()
	local index = self:GetShowIndex()
	if index == TabIndex.symbol_yuanhun or index == TabIndex.symbol_upgrade then
		local cfg = self.view_cfg[index]
		cfg.view:Flush()
	end
end

function SymbolView:ReleaseCallBack()
	for k,v in pairs(self.view_cfg) do
		if v.view then
			v.view:DeleteMe()
		end
	end
	self.view_cfg = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	
	self.red_point_list = {}

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function SymbolView:LoadCallBack()
	local tab_cfg = {
		{name = Language.Symbol.TabbarName[1], bundle = "uis/images_atlas", asset = "symbol_weiyang", func = "symbol_intro", 	tab_index = TabIndex.symbol_intro, 		remind_id = RemindName.SymbolYuanSu},
		-- {name = Language.Symbol.TabbarName[2], bundle = "uis/images_atlas", asset = "symbol_fuwen", func = "symbol_fuzhou", 	tab_index = TabIndex.symbol_fuzhou, 	remind_id = RemindName.SymbolYuanHuo},
		-- {name = Language.Symbol.TabbarName[3], bundle = "uis/images_atlas", asset = "symbol_huanling", func = "symbol_yuanhun", tab_index = TabIndex.symbol_yuanhun, 	remind_id = RemindName.SymbolYuanHun},
		--{name = Language.Symbol.TabbarName[4], bundle = "uis/images_atlas", asset = "symbol_lianhun", func = "symbol_yuanzhuang",tab_index = TabIndex.symbol_yuanzhuang,remind_id = RemindName.SymbolYuanZhuang},
		{name = Language.Symbol.TabbarName[6], bundle = "uis/images_atlas", asset = "symbol_jinjie", func = "symbol_upgrade", 	tab_index = TabIndex.symbol_upgrade, 	remind_id = RemindName.SymbolYuanShi},
		{name = Language.Symbol.TabbarName[5], bundle = "uis/images_atlas", asset = "symbol_lingyao", func = "symbol_mishi", 	tab_index = TabIndex.symbol_mishi, 		remind_id = RemindName.SymbolYuanYong},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))

	self.view_cfg = {
	[TabIndex.symbol_intro] = {
		index_t = {TabIndex.symbol_intro},
		view = nil,
		view_name = SymbolInfoView,
		prefab = {"uis/views/symbol_prefab", "InfoContent"},
		fun_open = "symbol_intro",
		parent_name = "InfoContent",
		},
	-- [TabIndex.symbol_fuzhou] = {
	-- 	index_t = {TabIndex.symbol_fuzhou},
	-- 	view = nil,
	-- 	view_name = SymbolFuzhouView,
	-- 	prefab = {"uis/views/symbol_prefab", "FuzhouContent"},
	-- 	fun_open = "symbol_fuzhou",
	-- 	parent_name = "FuzhouContent",
	-- 	},
	-- [TabIndex.symbol_yuanhun] = {
	-- 	index_t = {TabIndex.symbol_yuanhun},
	-- 	view = nil,
	-- 	view_name = SymbolYuanhunView,
	-- 	prefab = {"uis/views/symbol_prefab", "YuanhunContent"},
	-- 	fun_open = "symbol_yuanhun",
	-- 	parent_name = "YuanhunContent",
	-- 	},
	-- [TabIndex.symbol_yuanzhuang] = {
	-- 	index_t = {TabIndex.symbol_yuanzhuang, TabIndex.symbol_yz_get},
	-- 	view = nil,
	-- 	view_name = SymbolYuanzhuangView,
	-- 	prefab = {"uis/views/symbol_prefab", "YuanzhuangContent"},
	-- 	fun_open = "symbol_yuanzhuang",
	-- 	parent_name = "YuanzhuangContent",
	-- 	},
	[TabIndex.symbol_mishi] = {
		index_t = {TabIndex.symbol_mishi},
		view = nil,
		view_name = SymbolMishiView,
		prefab = {"uis/views/symbol_prefab", "MishiContent"},
		fun_open = "symbol_mishi",
		parent_name = "MishiContent",
		},
	[TabIndex.symbol_upgrade] = {
		index_t = {TabIndex.symbol_upgrade},
		view = nil,
		view_name = SymbolUpgradeView,
		prefab = {"uis/views/symbol_prefab", "UpgradeContent"},
		fun_open = "symbol_upgrade",
		parent_name = "UpgradeContent",
		},
	}

	self.red_point_list = {
		[RemindName.SymbolYuanSu] = self.node_list["ShowInfoRed"],
		-- [RemindName.SymbolYuanHuo] = self.node_list["ShowFuzhouRed"],
		-- [RemindName.SymbolYuanHun] = self.node_list["ShowYuanhunRed"],
		-- [RemindName.SymbolYuanZhuang] = self.node_list["ShowFuzhuangRed"],
		[RemindName.SymbolYuanYong] = self.node_list["ShowMishiRed"],
		[RemindName.SymbolYuanShi] = self.node_list["ShowUpgradeRed"],
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetActive(RemindManager.Instance:GetRemind(k) > 0)
	end

	self.node_list["TxtTitle"].text.text = Language.Symbol.TitleTxt
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	-- self.node_list["AddButton"].button:AddClickListener(BindTool.Bind(self.OnClickAddScore, self))

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function SymbolView:FlushTabbar()
	if not self:IsOpen() then return end
	self.tabbar:FlushTabbar()
end

function SymbolView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function SymbolView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
end

function SymbolView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function SymbolView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		local count = CommonDataManager.ConverMoney(value)
		if attr_name == "bind_gold" then
			self.node_list["BindGoldText"].text.text = count
		else
			self.node_list["GoldText"].text.text = count
		end
	end
end

function SymbolView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function SymbolView:ShowIndexCallBack(index, index_nodes)
	local last_index = self:GetLastIndex()
	if last_index > 0 and last_index ~= index and self.view_cfg[last_index].view then
		self.view_cfg[last_index].view:CloseCallBack()
	end
	self.tabbar:ChangeToIndex(index)
	local cfg = self.view_cfg[index]
	cfg.view = cfg.view or cfg.view_name.New(index_nodes[cfg.parent_name])
	cfg.view:OpenCallBack()
	cfg.view:Flush()
	-- self.node_list["TopBar"]:SetActive(index == TabIndex.symbol_mishi)
	-- self:SetShowMiShiJiFen()
	self.node_list["UnderBg"]:SetActive(true)
	if index == TabIndex.symbol_fuzhou or index == TabIndex.symbol_upgrade then
		self.node_list["TaiZi"]:SetActive(true)
		self.node_list["TaiZi"].transform.localPosition = Vector3(-160, -270, 0)
	else
		self.node_list["TaiZi"]:SetActive(false)
	end
end

function SymbolView:OnFlush(param_t)
	local cfg = self.view_cfg[self:GetShowIndex()]
	if nil == cfg then return end
	if cfg.view then
		for k,v in pairs(param_t) do
			cfg.view:Flush(k, v)
		end
	end
	self.tabbar:FlushTabbar()
end

function SymbolView:ElementHeartUpgradeResult(result)
	if self.view_cfg[TabIndex.symbol_upgrade].view then
		self.view_cfg[TabIndex.symbol_upgrade].view:ElementHeartUpgradeResult(result)
	end
end

function SymbolView:ElementTextureUpgradeResult(result)
	if self.view_cfg[TabIndex.symbol_fuzhou].view then
		self.view_cfg[TabIndex.symbol_fuzhou].view:ElementTextureUpgradeResult(result)
	end
end

function SymbolView:OnYuanZhuangUpgradeResult(result)
	if self.view_cfg[TabIndex.symbol_yuanzhuang].view then
		self.view_cfg[TabIndex.symbol_yuanzhuang].view:SymbolYuanzhuangUpgradeResult(result)
	end
end

-- function SymbolView:SetShowMiShiJiFen()
-- 	local score = SymbolData.Instance:GetPastureScore()
-- 	self.node_list["TxtJiFen"].text.text = score
-- end

-- function SymbolView:OnClickAddScore()
-- 	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.KF_FARMHUNTING)
-- end