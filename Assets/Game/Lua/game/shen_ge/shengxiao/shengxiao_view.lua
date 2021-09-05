ShengXiaoView = ShengXiaoView or BaseClass(BaseView)

function ShengXiaoView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_1"},
		{"uis/views/shengxiaoview_prefab", "UplevelContent", {TabIndex.shengxiao_uplevel}},
		{"uis/views/shengxiaoview_prefab", "EquipContent", {TabIndex.shengxiao_equip}},
		{"uis/views/shengxiaoview_prefab", "PieceContent", {TabIndex.shengxiao_piece}},
		{"uis/views/shengxiaoview_prefab", "SpiritContent", {TabIndex.shengxiao_spirit}},
		{"uis/views/shengxiaoview_prefab", "StarSoulContent", {TabIndex.shengxiao_starsoul}},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_2"},
		{"uis/views/commonwidgets_prefab", "BaseFullPanel_3"},
	}
	self.play_audio = true
	self.full_screen = true
	self.discount_close_time = 0
	self.discount_index = 0
end

function ShengXiaoView:LoadCallBack()
	-- self.node_list["ImgBiPingIcon"].button:AddClickListener(BindTool.Bind(self.OnClickBiPin, self)) --暂且注释
	local tab_cfg = {
		{name = Language.ShengXiao.TabbarName.ShengXiao, bundle = "uis/images_atlas", asset = "shengxiao_uplevel", func ="shengxiao_uplevel", tab_index = TabIndex.shengxiao_uplevel, remind_id = RemindName.ShengXiao_Uplevel},
		{name = Language.ShengXiao.TabbarName.ZhuangBei, bundle = "uis/images_atlas", asset = "shengxiao_equip", func = "shengxiao_equip", tab_index = TabIndex.shengxiao_equip, remind_id = RemindName.ShengXiao_Equip},
		{name = Language.ShengXiao.TabbarName.XingHun,  bundle = "uis/images_atlas", asset = "shengxiao_starsoul",func = "shengxiao_starsoul", tab_index = TabIndex.shengxiao_starsoul, remind_id = RemindName.ShengXiao_StarSoul},
		{name = Language.ShengXiao.TabbarName.LingZhu, bundle = "uis/images_atlas", asset = "shengxiao_piece", func = "shengxiao_piece", tab_index = TabIndex.shengxiao_piece, remind_id = RemindName.ShengXiao_Piece},
		{name = Language.ShengXiao.TabbarName.ShengLing,  bundle = "uis/images_atlas", asset = "shengxiao_spirit",func = "shengxiao_spirit", tab_index = TabIndex.shengxiao_spirit, remind_id = RemindName.ShengXiao_Spirit},
	}

	self.tabbar = TabBarOne.New()
	self.tabbar:Init(self, self.node_list["SideTabContent"], tab_cfg)
	self.tabbar:SetSelectCallback(BindTool.Bind(self.ChangeToIndex, self))
	self.node_list["TxtTitle"].text.text = Language.ShengXiao.TabbarName.ShengXiao
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["AddGoldButton"].button:AddClickListener(BindTool.Bind(self.HandleAddGold, self))

	self.node_list["UnderBg"]:SetActive(false)
	local bundle, asset = ResPath.GetRawImage("bg_shengxiao_view",false)
	local fun = function()
		self.node_list["UnderBg"]:SetActive(true)
		self.node_list["TaiZi"]:SetActive(false)
	end
	self.node_list["UnderBg"].raw_image:LoadSprite(bundle, asset, fun)

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Sheng_Xiao)
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
function ShengXiaoView:StartCountDown(data, node_list)
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
function ShengXiaoView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function ShengXiaoView:ReleaseCallBack()
	if self.shengxiao_uplevel_view then
		self.shengxiao_uplevel_view:DeleteMe()
		self.shengxiao_uplevel_view = nil
	end

	if self.shengxiao_equip_view then
		self.shengxiao_equip_view:DeleteMe()
		self.shengxiao_equip_view = nil
	end

	if self.shengxiao_piece_view then
		self.shengxiao_piece_view:DeleteMe()
		self.shengxiao_piece_view = nil
	end

	if self.shengxiao_spirit_view then
		self.shengxiao_spirit_view:DeleteMe()
		self.shengxiao_spirit_view = nil
	end
	
	if self.shengxiao_starsoul_view then
		self.shengxiao_starsoul_view:DeleteMe()
		self.shengxiao_starsoul_view = nil
	end

	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	self:StopCountDown()
end

function ShengXiaoView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(12, true)
	self.discount_index = index

	ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_ALL_INFO)

	-- self.node_list["ImgBiPingIcon"]:SetActive(discount_info ~= nil)
	-- self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	-- if discount_info and self.discount_timer == nil then
	-- 	self:UpdateTimer()
	-- 	self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	-- end
end

function ShengXiaoView:UpdateTimer()
	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
		self.node_list["ImgBiPingIcon"]:SetActive(false)
	else
		self.node_list["TxtTime"].text.text = time > 3600 and TimeUtil.FormatSecond(time, 1) or TimeUtil.FormatSecond(time, 2)
	end
end

function ShengXiaoView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.shengxiao_equip_view ~= nil then
		self.shengxiao_equip_view:CloseCallBack()
	end
	if self.shengxiao_starsoul_view ~= nil then
		self.shengxiao_starsoul_view:CloseCallBack()
	end
end

-- function ShengXiaoView:OnClickBiPin()
-- 	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
-- end

function ShengXiaoView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.node_list["BindGoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
	if attr_name == "gold" then
		self.node_list["GoldText"].text.text = CommonDataManager.ConverMoney(value)
	end
end

function ShengXiaoView:OpenUplevel()
	if nil ~= self.shengxiao_uplevel_view then
		self.shengxiao_uplevel_view:FlushAll()
	end
end

function ShengXiaoView:OpenEquip()
	if nil ~= self.shengxiao_equip_view then
		self.shengxiao_equip_view:FlushAll()
	end
end

function ShengXiaoView:OpenPiece()
	if nil ~= self.shengxiao_piece_view then
		self.shengxiao_piece_view:FlushAll()
	end
end

function ShengXiaoView:OpenSpirit()
	if nil ~= self.shengxiao_spirit_view then
		self.shengxiao_spirit_view:FlushAll()
	end
end

function ShengXiaoView:OpenStarSoul()
	if nil ~= self.shengxiao_starsoul_view then
		self.shengxiao_starsoul_view:FlushAll()
	end
end

function ShengXiaoView:ShowIndexCallBack(index ,index_nodes)
	self.tabbar:ChangeToIndex(index)
	self.node_list["UnderBg"]:SetActive(index ~= TabIndex.shengxiao_piece)
	if index_nodes then
		if index == TabIndex.shengxiao_uplevel then
			self.shengxiao_uplevel_view = ShengXiaoUpLevelView.New(index_nodes["UplevelContent"])
			self.shengxiao_uplevel_view:FlushAll()
		elseif index == TabIndex.shengxiao_spirit then
			self.shengxiao_spirit_view = ShengXiaoSpiritView.New(index_nodes["SpiritContent"])
			self.shengxiao_spirit_view:FlushAll()
		elseif index == TabIndex.shengxiao_equip then
			self.shengxiao_equip_view = ShengXiaoEquipView.New(index_nodes["EquipContent"])
			self.shengxiao_equip_view:FlushAll()
		elseif index == TabIndex.shengxiao_piece then
			self.shengxiao_piece_view = ShengXiaoPieceView.New(index_nodes["PieceContent"])
			self.shengxiao_piece_view:FlushAll()
			ShengXiaoData.Instance:SetPieceOpenState(true)
			RemindManager.Instance:Fire(RemindName.ShengXiao_Piece)
		elseif index == TabIndex.shengxiao_starsoul then
			self.shengxiao_starsoul_view = ShengXiaoStarSoulView.New(index_nodes["StarSoulContent"])
			self.shengxiao_starsoul_view:FlushAll()
		end
	end

	if index == TabIndex.shengxiao_uplevel then
		self.shengxiao_uplevel_view:UIsMove()
		self.shengxiao_uplevel_view:FlushAll()
	elseif index == TabIndex.shengxiao_spirit then
		self.shengxiao_spirit_view:UIsMove()
		self.shengxiao_spirit_view:FlushAll()
	elseif index == TabIndex.shengxiao_equip then
		self.shengxiao_equip_view:UIsMove()
		self.shengxiao_equip_view:FlushAll()
	elseif index == TabIndex.shengxiao_piece then
		self.shengxiao_piece_view:UIsMove()
		self.shengxiao_piece_view:FlushAll()
	elseif index == TabIndex.shengxiao_starsoul then
		self.shengxiao_starsoul_view:UIsMove()
		self.shengxiao_starsoul_view:FlushAll()
	end
end

function ShengXiaoView:OnClickClose()
	self:Close()
end

function ShengXiaoView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShengXiaoView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()

	if self.shengxiao_uplevel_view and cur_index == TabIndex.shengxiao_uplevel then
		self.shengxiao_uplevel_view:FlushAll()
	end
	if self.shengxiao_equip_view and cur_index == TabIndex.shengxiao_equip then
		self.shengxiao_equip_view:FlushAll()
	end
	if self.shengxiao_piece_view and cur_index == TabIndex.shengxiao_piece then
		self.shengxiao_piece_view:FlushAll()
	end
	if self.shengxiao_spirit_view and cur_index == TabIndex.shengxiao_spirit then
		self.shengxiao_spirit_view:FlushAll()
	end
	if self.shengxiao_starsoul_view and cur_index == TabIndex.shengxiao_starsoul then
		self.shengxiao_starsoul_view:FlushAll()
	end

	for k, v in pairs(param_list) do
		if k == "all" and v.item_id then
			local seq = ShengXiaoData.Instance:GetShengXiaoIndexByCostItem(v.item_id)
			if seq > 0 then
				ShengXiaoData.Instance:SetUplevelIndex(seq)
			end
		elseif k == "shengxiao_equip_change" and cur_index == TabIndex.shengxiao_equip then
			if self.shengxiao_equip_view then
				self.shengxiao_equip_view:AfterSuccessUp()
			end
		elseif k == "shengxiao_star_soul" and cur_index == TabIndex.shengxiao_starsoul then
			if self.shengxiao_starsoul_view then
				self.shengxiao_starsoul_view:AfterSuccessUp()
			end
		elseif k == "shengxiao_all_info" and cur_index == TabIndex.shengxiao_uplevel then
			if ShengXiaoData.Instance:GetUpgradeZodiac() >= 0 then
				self.shengxiao_uplevel_view:FlushEffect()
			end
		end
	end
end