ExchangeContentView = ExchangeContentView or BaseClass(BaseRender)
local TWEEN_TIME = 0.5
function ExchangeContentView:__init(instance)
	ExchangeContentView.Instance = self
	self.contain_cell_list = {}
	self.contain_special_cell_list = {}
	self.is_default_select = true
	self.current_item_id = -1
	self.current_price_type = EXCHANGE_PRICE_TYPE.SHENGWANG
	self:InitListView()
	self.buy_num = -1

	self.display_model = RoleModel.New()
	self.display_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	local event_trigger = self.node_list["ModelTrigger"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDrag, self))

	if self.node_list and self.node_list["BtnBuy"] then			--有预制体不同
		self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OpenHuiJi, self))
	end
end


function ExchangeContentView:__delete()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	for k,v in pairs(self.contain_special_cell_list) do
		v:DeleteMe()
	end
	self.contain_special_cell_list = {}

	if self.display_model then
		self.display_model:DeleteMe()
		self.display_model = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.current_price_type = EXCHANGE_PRICE_TYPE.SHENGWANG

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end
end

function ExchangeContentView:OpenCallBack()

end

function ExchangeContentView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Frame"], Vector3(-266, -75, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ExchangeContentView:InitListView()
	self.node_list["list_view"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["list_view"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["ListViewSpecial"].list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSpecialNumberOfCells, self)
	self.node_list["ListViewSpecial"].list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSpecialCell, self)
end

function ExchangeContentView:GetSpecialNumberOfCells()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, self.current_price_type, prof)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.SHENZHOU then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(1, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.YUSHI then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(10, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.JINGLING then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(5, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.HUNJING then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(11, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(12, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.WEIJI then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(13, self.current_price_type, prof)
	end

	if #item_id_list % 2 ~= 0 then
		return math.ceil(#item_id_list / 2)
	else
		return #item_id_list / 2
	end
end

function ExchangeContentView:RefreshSpecialCell(cell, cell_index)
	local contain_cell = self.contain_special_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ExchangeContainSpecial.New(cell.gameObject, self)
		self.contain_special_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.node_list["ListViewSpecial"].toggle_group)
	end
	cell_index = cell_index + 1
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	local is_special = true
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(2, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.SHENZHOU then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(1, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.YUSHI then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(10, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.JINGLING then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(5, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.HUNJING then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(11, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(12, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.WEIJI then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(13, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	end

	contain_cell:InitItems(item_id_list)
	contain_cell:SetIndex(cell_index)
end

function ExchangeContentView:GetNumberOfCells()
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, self.current_price_type, prof)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.SHENZHOU then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(1, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.YUSHI then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(10, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.JINGLING then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(5, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.HUNJING then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(11, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(12, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.WEIJI then
		item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(13, self.current_price_type, prof)
	end

	if #item_id_list%4 ~= 0 then
		return math.ceil(#item_id_list/4)
	else
		return #item_id_list/4
	end
end

function ExchangeContentView:PlayerDataChangeCallback(attr_name, value, old_value)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.RONGYAO and attr_name == "cross_honor" then
		self:FlushCoin()
	end
end

function ExchangeContentView:OnRoleDrag(data)
	if self.display_model then
		self.display_model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function ExchangeContentView:GetCellList()
	return self.contain_cell_list
end

function ExchangeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ExchangeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.node_list["list_view"].toggle_group)
	end
	cell_index = cell_index + 1
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	local is_special = false
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(2, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.SHENZHOU then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(1, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.YUSHI then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(10, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.JINGLING then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(5, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.HUNJING then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(11, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.GUILDCONTRIBUTE then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(12, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.WEIJI then
		item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(13, self.current_price_type, prof, cell_index, is_special, not is_activity_open)
	end

	contain_cell:InitItems(item_id_list)
	contain_cell:SetIndex(cell_index)
end

function ExchangeContentView:SetCurrentItemId(item_id)
	self.current_item_id = item_id
end

function ExchangeContentView:GetCurrentItemId()
	return self.current_item_id
end

function ExchangeContentView:SetBuyNum(buy_num)
	self.buy_num = buy_num
end

function ExchangeContentView:OnFlushAllCell()
	for k,v in pairs(self.contain_cell_list) do
		v:OnFlushAllCell()
	end
end

function ExchangeContentView:SetCurrentPriceType(price_type)
	self.current_price_type = price_type
	if self.node_list and self.node_list["BtnBuy"] then			--有预制体不同
		self.node_list["BtnBuy"]:SetActive(price_type and price_type == EXCHANGE_PRICE_TYPE.WEIJI)
	end
end

function ExchangeContentView:GetCurrentPriceType()
	return self.current_price_type
end

function ExchangeContentView:OnFlushListView()
	local is_special = false
	local prof = PlayerData.Instance:GetRoleBaseProf()
	if self.current_price_type == EXCHANGE_PRICE_TYPE.SHENZHOU then
		is_special = ExchangeData.Instance:GetIsSpecialShow(1, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.YUSHI then 
		is_special = ExchangeData.Instance:GetIsSpecialShow(10, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.JINGLING then
		is_special = ExchangeData.Instance:GetIsSpecialShow(5, self.current_price_type, prof)
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.GUANGHUI then
		is_special = ExchangeData.Instance:GetIsSpecialShow(2, self.current_price_type, prof)
		is_special = true
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.WEIJI then
		is_special = ExchangeData.Instance:GetIsSpecialShow(13, self.current_price_type, prof)
	else
		is_special = ExchangeData.Instance:GetIsSpecialShow(2, self.current_price_type, prof)
	end
	self.node_list["Normal"]:SetActive(not is_special)
	self.node_list["Special"]:SetActive(is_special)
	self.node_list["list_view"].scroller:ReloadData(0)
	self.node_list["ListViewSpecial"].scroller:ReloadData(0)
	self:FlushModel()
end

function ExchangeContentView:FlushModel()
	local item_info = ExchangeData.Instance:GetSpecialShowItem()
	if item_info and next(item_info) then
		self.display_model:ChangeModelByItemId(item_info.item_id)
		if item_info.item_id == 25042 then
			local transform = {position = Vector3(0, 0.6, 3), rotation = Quaternion.Euler(0, 180, 0)}
			self.display_model:SetCameraSetting(transform)
		end
		local server_time = TimeCtrl.Instance:GetServerTime()
		local time = TimeUtil.NowDayTimeStart(server_time) + (item_info.to_open_game_day - TimeCtrl.Instance:GetCurOpenServerDay() + 1) * 24 * 3600 - server_time
		if item_info.to_open_game_day >= 9999 then
			self.node_list["Image"]:SetActive(false)
		else
			if time > 0 then
				self.node_list["Image"]:SetActive(true)
				if self.current_price_type == EXCHANGE_PRICE_TYPE.GUANGHUI then
					self.node_list["Image"]:SetActive(false)
				end
				if self.count_down then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				if nil == self.count_down then
					self.count_down = CountDown.Instance:AddCountDown(time, 1, function()
						time = time - 1
						if time <= 0 then
							if self.count_down then
								CountDown.Instance:RemoveCountDown(self.count_down)
								self.count_down = nil
							end
						end
						local time = TimeUtil.FormatSecond(time, 15)
						self.node_list["Text"].text.text = string.format(Language.Exchange.ExchangeSpecialTips, time)
					end)
				end
			end
		end
	end
	if self.current_price_type == EXCHANGE_PRICE_TYPE.GUANGHUI then
		self.node_list["Image"]:SetActive(false)
	end
end

function ExchangeContentView:SetArenaReMainTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local sever_day = ArenaData.Instance:GetArenaViewOpenSeverDay()
	local differ_day = sever_day - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day + 22 * 3600 - time
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["bg_time"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 17)
			self.node_list["bg_time"]:SetActive(true)
			self.node_list["refresh_tips"].text.text = string.format(Language.Arena.DayClearTime, time_str)
		end

		diff_time_func(0, diff_time)
		self.day_count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function ExchangeContentView:FlushCoin()
	local res = ExchangeData.Instance:GetExchangeRes(self.current_price_type)
	local bundle, asset = ResPath.GetExchangeNewIcon(res)
	local str = ""
	if self.current_price_type == EXCHANGE_PRICE_TYPE.MOJING then
		str = Language.Exchange.MojingGetWay
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.SHENGWANG then
		str = Language.Exchange.ShengwangGetWay
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		str = Language.Exchange.RongyuGetWay
	end
end

function ExchangeContentView:FlushAllFrame()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushAllFrame()
	end
	for k,v in pairs(self.contain_special_cell_list) do
		v:FlushAllFrame()
	end
end

function ExchangeContentView:SetIsOpen(is_open)
	self.is_open = is_open
end

function ExchangeContentView:GetIsOpen()
	return self.is_open
end

-- 打开徽记收购
function ExchangeContentView:OpenHuiJi()
	MarketData.Instance:SetPurchaseItemId(12)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 12})
end

------------------------------------------------------------------------
ExchangeContain = ExchangeContain  or BaseClass(BaseCell)

function ExchangeContain:__init()
	self.exchange_contain_list = {}
	for i = 1, 4 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ExchangeItem.New(self.node_list["item_" .. i])
	end
end

function ExchangeContain:__delete()
	for i = 1, 4 do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function ExchangeContain:GetFirstCell()
	return self.exchange_contain_list[1]
end

function ExchangeContain:InitItems(item_id_list)
	for i = 1, 4 do
		self.exchange_contain_list[i]:SetItemId(item_id_list[i])
		self.exchange_contain_list[i]:OnFlush()
	end
end

function ExchangeContain:FlushItems(item_id_list,toggle_group)
	for i = 1, 4 do
		local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
		if item_id_list[i] ~= 0 then
			local data = ItemData.Instance:GetItemConfig(item_id_list[i]) or {}
			data.item_id = data.id
			if consume_type == SHOP_BIND_TYPE.BIND then
				data.is_bind = 1
			elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
				data.is_bind = 0
			end
			self.shop_contain_list[i].item_cell:SetData(data)
		end
		self.shop_contain_list[i].item_frame:FlushFrame(item_id_list[i])
	end
end

function ExchangeContain:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ExchangeContain:FlushAllFrame()
	for i = 1, 4 do
		self.exchange_contain_list[i]:OnFlush()
	end
end
------------------------------------------------------------------------
ExchangeContainSpecial = ExchangeContainSpecial  or BaseClass(BaseCell)

function ExchangeContainSpecial:__init()
	self.exchange_special_scontain_list = {}
	for i = 1, 2 do
		self.exchange_special_scontain_list[i] = {}
		self.exchange_special_scontain_list[i] = ExchangeItem.New(self.node_list["item_" .. i])
	end
end

function ExchangeContainSpecial:__delete()
	for i = 1, 2 do
		self.exchange_special_scontain_list[i]:DeleteMe()
		self.exchange_special_scontain_list[i] = nil
	end
end

function ExchangeContainSpecial:GetFirstCell()
	return self.exchange_special_scontain_list[1]
end

function ExchangeContainSpecial:InitItems(item_id_list)
	for i = 1, 2 do
		self.exchange_special_scontain_list[i]:SetItemId(item_id_list[i])
		self.exchange_special_scontain_list[i]:OnFlush()
	end
end

function ExchangeContainSpecial:FlushItems(item_id_list,toggle_group)
	for i = 1, 2 do
		local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
		if item_id_list[i] ~= 0 then
			local data = ItemData.Instance:GetItemConfig(item_id_list[i]) or {}
			data.item_id = data.id
			if consume_type == SHOP_BIND_TYPE.BIND then
				data.is_bind = 1
			elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
				data.is_bind = 0
			end
			self.exchange_special_scontain_list[i].item_cell:SetData(data)
		end
		self.exchange_special_scontain_list[i].item_frame:FlushFrame(item_id_list[i])
	end
end

function ExchangeContainSpecial:SetToggleGroup(toggle_group)
	for i = 1, 2 do
		self.exchange_special_scontain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ExchangeContainSpecial:FlushAllFrame()
	for i = 1, 2 do
		self.exchange_special_scontain_list[i]:OnFlush()
	end
end
----------------------------------------------------------------------------
ExchangeItem = ExchangeItem or BaseClass(BaseCell)

function ExchangeItem:__init()
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick,self))
	self.item_id = 0
	self.is_jueban = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.item_cell:SetShowOrangeEffect(true)
	self.item_cell:ShowHighLight(false)
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
end

function ExchangeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function ExchangeItem:SetItemId(item_id_list)
	local cfg = item_id_list
	if cfg == 0 then
		return
	end
	if nil ~= cfg then
		self.item_id = cfg[1]
		self.is_jueban = cfg[2]
	else
		self.item_id = 0
	end
end

function ExchangeItem:OnFlush()
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
	self.root_node:SetActive(true)
	if self.item_id == 0 then
		self.root_node:SetActive(false)
		return
	end
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	if not item_info then 
		return 
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local text = ""
	local price_type = ExchangeContentView.Instance:GetCurrentPriceType()
	local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, item_info.conver_type, price_type)
	local multiple_cfg = ExchangeData.Instance:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)

	if multiple_cfg then
		self.multiple_time = multiple_cfg.times_max - conver_value
		text = 0 == multiple_cfg.is_max_times and Language.Exchange.Change .. self.multiple_time .. Language.Exchange.TwoMoney or Language.Exchange.MaxTime
		self.price_multile = multiple_cfg.price_multile
		self.is_max_multiple = 1 == multiple_cfg.is_max_times
		ExchangeCtrl.Instance.tips_view:UpdateMultipleTime(self.item_id, self.multiple_time, self.is_max_multiple)
	end

	

	if item_info.require_type == REQUIRE_TYPE.LEVEL and main_role_vo.level < item_info.require_value then
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(item_info.require_value)
		-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		text = string.format(Language.Exchange.NeedLevel, PlayerData.GetLevelString(item_info.require_value))
	end

	local limit_value = ""
	local desc = item_info.lifetime_convert_count > 0 and Language.Exchange.TodayExchange or Language.Exchange.TodayExchange
	if conver_value == item_info.limit_convert_count then
		limit_value = string.format(desc, item_info.limit_convert_count - conver_value)
	else
		limit_value = string.format(desc, item_info.limit_convert_count - conver_value)
	end

	self.node_list["LimitText"].text.text = (item_info.limit_convert_count == 0 or text ~= "") and "" or limit_value

	self.node_list["ExchangeText"].text.text = text
	local res = ExchangeData.Instance:GetExchangeRes(ExchangeContentView.Instance:GetCurrentPriceType())
	if ExchangeContentView.Instance:GetCurrentPriceType() == EXCHANGE_PRICE_TYPE.WEIJI then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.sex == 0 then
			res = "WeiJi0"
		end
	end
	local bundle2, asset2 = ResPath.GetExchangeNewIcon(res)
	self.node_list["GoldText"].image:LoadSprite(bundle2, asset2, function ()
		self.node_list["GoldText"].image:SetNativeSize()
	end)
	local price = item_info.price * (self.price_multile == 0 and 1 or self.price_multile)
	self.cur_multile_price = price

	self.node_list["GoldTextNode"].text.text = price

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg then
		self.node_list["NameText"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
		local item_data = {item_id = self.item_id, is_bind = item_info.is_bind, is_jueban = self.is_jueban}
		self.item_cell:SetData(item_data)
		self.item_cell:IsDestoryActivityEffect(not ExchangeData.Instance:IsShowEffect(self.item_id))
		self.item_cell:SetActivityEffect()
	end
	if self.click_self then
		self:OnToggleClick(true)
		self.click_self = false
	end
	
	if self.is_jueban == 1 then
		self.node_list["LimitBuy"]:SetActive(false)
		self.node_list["TextDays"]:SetActive(true)
		self.node_list["TextDays"].text.text = string.format(Language.Exchange.OpenDays, item_info.to_open_game_day)
	else
		self.node_list["LimitBuy"]:SetActive(true)
		self.node_list["TextDays"]:SetActive(false)
		self.node_list["Tips"]:SetActive(false)
	end
	if price_type == EXCHANGE_PRICE_TYPE.GUANGHUI then
		self.node_list["Tips"]:SetActive(false)
	end
end


function ExchangeItem:CloseCallBack()

end

function ExchangeItem:SelectToggle()
	self.root_node.toggle.isOn = true
end

function ExchangeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function ExchangeItem:OnToggleClick(is_click)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	 if is_click then
		local close_func = function()
			self.root_node.toggle.isOn = false
		end
		if self.price_multile > 0 or self.is_max_multiple then
			local price_type = ExchangeContentView.Instance:GetCurrentPriceType()
			local func = function()
				ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_info.conver_type, item_info.seq, 1)
			end
			local coin_name = ""
			if price_type == EXCHANGE_PRICE_TYPE.MOJING then
				coin_name = Language.Common.MoJing
			elseif price_type == EXCHANGE_PRICE_TYPE.SHENGWANG then
				coin_name = Language.Common.ShengWang
			elseif price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
				coin_name = Language.Common.RongYao
			elseif price_type == EXCHANGE_PRICE_TYPE.JINGLING then
				coin_name = Language.Common.SpiritScore
			elseif price_type == EXCHANGE_PRICE_TYPE.HUNJING then
				coin_name = Language.Common.HunJingScore
			end
			local prop_name = "<color=" .. SOUL_NAME_COLOR[item_cfg and item_cfg.color or 1] .. ">" .. item_cfg.name .. "</color>"
			local content = string.format(Language.Exchange.Multiple_Tip, self.cur_multile_price, coin_name, prop_name, self.multiple_time)
			if self.is_max_multiple then
				content = string.format(Language.Exchange.Max_Multiple_Tip, self.cur_multile_price, coin_name, prop_name)
			end
			ExchangeCtrl.Instance:ShowExchangeView(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType(),
			EXCHANGE_CONVER_TYPE.DAO_JU, close_func, self.cur_multile_price, self.multiple_time, self.is_max_multiple, click_func)
		else
			TipsCtrl.Instance:ShowExchangeView(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType(), EXCHANGE_CONVER_TYPE.DAO_JU, close_func)
		end
	 end
end







