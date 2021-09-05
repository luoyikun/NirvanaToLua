require("game/shen_ge/hun_qi/hunqi_content_view")
require("game/shen_ge/hun_qi/damo_content_view")
require("game/shen_ge/hun_qi/baozang_content_view")
require("game/shen_ge/hun_qi/hunyin_content_view")
require("game/shen_ge/hun_qi/xilian_content_view")
HunQiView = HunQiView or BaseClass(BaseView)
function HunQiView:__init()
	self.ui_config = {
		--{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/hunqiview_prefab", "HorcruxesContent", 	{TabIndex.hunqi_content}},
		--{"uis/views/hunqiview_prefab", "DaMoContent", 		{TabIndex.hunqi_damo}},
		{"uis/views/hunqiview_prefab", "HunYinContent", 	{TabIndex.hunqi_hunyin}},
		{"uis/views/hunqiview_prefab", "BaoZangContent", 	{TabIndex.hunqi_bao}},
		{"uis/views/hunqiview_prefab", "XiLianContent", 	{TabIndex.hunqi_xilian}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.play_audio = true
	self.full_screen = true
	self.discount_close_time = 0
	self.discount_index = 0
end

function HunQiView:__delete()
	self:StopCountDown()
end

function HunQiView:ReleaseCallBack()
	for k,v in pairs(self.view_list) do
		if v then
			v:DeleteMe()
		end
	end

	self.view_list = {}
	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end

	self.tab_hunqi = nil
	self.open_trigger_list = nil

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self:StopCountDown()
end

function HunQiView:LoadCallBack()
	local tab_cfg = {
		{name = Language.HunQi.HunQiViewName[1], bundle = "uis/images_atlas", asset = "yi_huo_yihuo", func = "hunqi_content", tab_index = TabIndex.hunqi_content, remind_id = RemindName.HunQi_HunQi},
		--{name = Language.HunQi.HunQiViewName[2], bundle = "uis/images_atlas", asset = "yi_huo_jianding", func = "damo", tab_index = TabIndex.hunqi_damo, remind_id = RemindName.HunQi_DaMo},
		{name = Language.HunQi.HunQiViewName[3], bundle = "uis/images_atlas", asset = "yi_huo_wenzhang", func = "hunyin", tab_index = TabIndex.hunqi_hunyin, remind_id = RemindName.HunQi_HunYin},
		{name = Language.HunQi.HunQiViewName[4], bundle = "uis/images_atlas", asset = "yi_huo_baozang", func = "hunqi_bao",	tab_index = TabIndex.hunqi_bao, remind_id = RemindName.HunQi_BaoZang},
		{name = Language.HunQi.HunQiViewName[5], bundle = "uis/images_atlas", asset = "yi_huo_ronghuo", func = "hunqi_xilian", tab_index = TabIndex.hunqi_xilian, remind_id = RemindName.HunQi_XiLian},
	}
	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.view_list = {}

	self.node_list["TxtTitle"].text.text = Language.HunQi.TxtTitle
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["UnderBg"].raw_image:LoadSprite("uis/rawimages/inlaycontent_bg2", "InlayContent_BG2.jpg")
	self.node_list["UnderBg"]:SetActive(true)
	self.node_list["TaiZi"]:SetActive(false)
	--一折优惠暂时屏蔽
	--self.node_list["NodeBiPingIcon"].button:AddClickListener(BindTool.Bind(self.OnClickBiPin, self))

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Yi_Huo)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end

end

-- 一折抢购跳转
function HunQiView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function HunQiView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function HunQiView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.baozang_content_view then
		self.baozang_content_view:StopCountDown()
	end
end

function HunQiView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
end

function HunQiView:ItemDataChangeCallback(item_id)
	--打磨物品变化
	local identify_item_list = HunQiData.Instance:GetIdentifyItemList()
	if identify_item_list then
		for k, v in ipairs(identify_item_list) do
			if v.consume_item_id == item_id then
				self:Flush("damo")
				return
			end
		end
	end

	--炼魂物品变化
	for _, v in ipairs(HunQiData.ElementItemList) do
		if item_id == v then
			self:Flush("element_red")
			return
		end
	end
end

function HunQiView:ShowOrHideTab(name)
	if nil ~= self.open_trigger_list[name] then
		local is_enable = OpenFunData.Instance:CheckIsHide(name)
		self.open_trigger_list[name]:SetActive(is_enable)
	else
		for k,v in pairs(self.open_trigger_list) do
			local is_enable = OpenFunData.Instance:CheckIsHide(k)
			v:SetActive(is_enable)
		end
	end
end

function HunQiView:OnClickClose()
	self:Close()
end

function HunQiView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function HunQiView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		local index = self:GetShowIndex()
		if index ~= TabIndex.hunqi_bao then
			self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
		end
	end

	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function HunQiView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_INFO, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_SHENZHOU_WEAPON)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	--监听物品变化
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(9, true)
	self.discount_index = index
	self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	--一折优惠暂时屏蔽
	--self.node_list["NodeBiPingIcon"]:SetActive(discount_info ~= nil)
	-- if discount_info and self.discount_timer == nil then
	-- 	self:UpdateTimer()
	-- 	self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	-- end

	--清除协助
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_REMOVE_HELP_BOX)
end

--一折优惠暂时屏蔽
-- function HunQiView:UpdateTimer()
-- 	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
-- 	if time <= 0 then
-- 		GlobalTimerQuest:CancelQuest(self.discount_timer)
-- 		self.discount_timer = nil
-- 		self.node_list["NodeBiPingIcon"]:SetActive(false)
-- 	else
-- 		local temp_time = TimeUtil.Format2TableDHMS(time)
-- 		if temp_time.day >= 1 then
-- 			self.node_list["TxtTime"].text.text = string.format(Language.Common.TimeStr, temp_time.day, temp_time.hour)
-- 		else
-- 			self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond(time)
-- 		end
-- 	end
-- end

function HunQiView:ShowIndexCallBack(index, index_nodes)
	local show_tab_cfg_index = 1
	for k,v in pairs(self.tabbar.tab_cfg) do
		if v.tab_index == index then
			show_tab_cfg_index = k
			self.show_index = index
			break
		end
	end
	for k, toggle_button in pairs(self.tabbar.tab_button_list) do
		local root_node = toggle_button.root_node
		if k == show_tab_cfg_index then
			root_node.toggle.interactable = true
		else
			root_node.toggle.interactable = false
		end
	end

	if self.view_list[TabIndex.hunqi_bao] then
		self.view_list[TabIndex.hunqi_bao]:SetIsClick(false)
	end

	self.tabbar:ChangeToIndex(index)
	if nil ~= index_nodes then
		if index == TabIndex.hunqi_content then
			self.view_list[index] = self.view_list[index] or HunQiContentView.New(index_nodes["HorcruxesContent"])
		elseif index == TabIndex.hunqi_damo then
			self.view_list[index] = self.view_list[index] or DaMoContentView.New(index_nodes["DaMoContent"])
		elseif index == TabIndex.hunqi_hunyin then
			self.view_list[index] = self.view_list[index] or HunYinContentView.New(index_nodes["HunYinContent"])
		elseif index == TabIndex.hunqi_bao then
			self.view_list[index] = self.view_list[index] or BaoZangContentView.New(index_nodes["BaoZangContent"])
		elseif index == TabIndex.hunqi_xilian then
			HunQiData.Instance:SetXiLianRedPoint(false)
			self.view_list[index] = self.view_list[index] or XiLianContentView.New(index_nodes["XiLianContent"])
			RemindManager.Instance:Fire(RemindName.HunQi_XiLian)
		end
	end
	if self.view_list[index] then
		self.view_list[index]:OpenCallBack()
		self.view_list[index]:FlushView()
	end

	if index == TabIndex.hunqi_bao then
		self.node_list["ImgBindGold"].image:LoadSprite("uis/icons/coin_atlas", "Coin_YiHuo", function ()
			self.node_list["ImgBindGold"].image:SetNativeSize()
		end)
		self.node_list["ImgBindGold"].button:AddClickListener(function ()
				TipsCtrl.Instance:OpenItem({item_id = ResPath.CurrencyToIconId["yihuo_score"]})
		end)
		self:SetExchangeScore()
	else
		self.node_list["ImgBindGold"].image:LoadSprite("uis/images_atlas", "icon_gold_5_bind", function()
				self.node_list["ImgBindGold"].image:SetNativeSize()
		end)
		self.node_list["ImgBindGold"].button:AddClickListener(function ()
			TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL})
		end)
		local vo = GameVoManager.Instance:GetMainRoleVo()
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(vo.bind_gold)
	end

	self.node_list["UnderBg"]:SetActive(not (index == TabIndex.hunqi_content))
end

function HunQiView:SetExchangeScore()
	local count = ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.SHENZHOU)
	self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(count)
end

function HunQiView:OnFlush(param)
	for k,v in pairs(param) do
		-- for l,w in pairs(self.tabbar.tab_cfg) do
		-- 	if self.show_index == w.tab_index and self.view_list[self.show_index] then
		-- 		print_error("111111111111")
		-- 		self.view_list[self.show_index]:FlushView()
		-- 	end
		-- end
		if k == "all" then
			if self.view_list[self.show_index] then
				self.view_list[self.show_index]:FlushView()
			end
		elseif k == "item_change" then
			if self.show_index == TabIndex.hunqi_content and self.view_list[TabIndex.hunqi_content] then
				self.view_list[TabIndex.hunqi_content]:FlushCostDes()
			elseif self.show_index == TabIndex.hunqi_damo and self.damo_content_view then
				self.view_list[TabIndex.hunqi_damo]:FlushItemList()
			elseif self.show_index == TabIndex.hunqi_bao and self.view_list[TabIndex.hunqi_bao] then
				self:SetExchangeScore()
				self.view_list[TabIndex.hunqi_bao]:FlushContent()
			end
		elseif k == "gather_time" and self.show_index == TabIndex.hunqi_content then
			if self.view_list[TabIndex.hunqi_content] then
				self.view_list[TabIndex.hunqi_content]:FlushLeftContent()
			end
		elseif k == "hunqi_upgrade" and self.show_index == TabIndex.hunqi_content then
			if self.view_list[TabIndex.hunqi_content] then
				self.view_list[TabIndex.hunqi_content]:UpGradeResult(v[1])
			end
		elseif k == "element_red" and self.show_index == TabIndex.hunqi_content then
			if self.view_list[TabIndex.hunqi_content] then
				self.view_list[TabIndex.hunqi_content]:FlushElementRed()
			end
		elseif k == "resolve" then
			if self.view_list[TabIndex.hunqi_hunyin] then
				self.view_list[TabIndex.hunqi_hunyin]:Flush("resolve")
			end
		-- elseif k == "yi_huo" then
		-- 	if self.show_index == TabIndex.hunqi_content and self.view_list[self.show_index] then
		-- 		self.view_list[self.show_index]:FlushView()
		-- 	end
		end
	end

	self.tabbar:FlushTabbar()
end

function HunQiView:ShowTreasureType(type)
	if self.view_list[TabIndex.hunqi_bao] then
		self.view_list[TabIndex.hunqi_bao]:ShowTreasureType(type)
	end
end

function HunQiView:GetBaoZangContentView()
	if self.view_list and self.view_list[TabIndex.hunqi_bao] then
		return self.view_list[TabIndex.hunqi_bao]
	end
end