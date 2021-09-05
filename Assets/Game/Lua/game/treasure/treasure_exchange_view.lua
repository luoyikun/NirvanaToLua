TreasureExchangeView = TreasureExchangeView or BaseClass(BaseRender)

function TreasureExchangeView:__init(instance)
	self.exchange_contain_list = {}
	local prof = PlayerData.Instance:GetRoleBaseProf()
	self.item_cfg_list = TreasureData.Instance:GetXunBaoItemCfgList(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE, prof)
	-- self.item_cfg_list = TreasureData.Instance:GetItemIdListByJobAndType(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE, prof)
	-- local all_item_cfg = {}
	-- self.has_flash_change = TreasureData.Instance:IsFlashChange()
	-- if self.has_flash_change then
	-- 	local rare_change = TreasureData.Instance:GetRareChangeList()
	-- 	for k,v in pairs(rare_change) do
	-- 		table.insert(all_item_cfg, v)
	-- 	end
	-- 	for k,v in pairs(self.item_cfg_list) do
	-- 		table.insert(all_item_cfg, v)
	-- 	end
	-- 	self.item_cfg_list = all_item_cfg
	-- end

	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TreasureExchangeView:__delete()
	if self.exchange_contain_list ~= nil then
		for k, v in pairs(self.exchange_contain_list) do
			v:DeleteMe()
		end
	end
	self.exchange_contain_list = {}
	TreasureData.Instance:ForgetItemIdList()
end

function TreasureExchangeView:OpenCallBack()
	local right_pos = self.node_list["list_view"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["list_view"], Vector3(right_pos.x, right_pos.y + 300, right_pos.z))
	UITween.AlpahShowPanel(self.node_list["list_view"], true)
end

function TreasureExchangeView:GetNumberOfCells()
	local count = #self.item_cfg_list
	if count % 4 ~= 0 then
		self.list_count = math.floor(count / 4) + 1
	else
		self.list_count = count / 4
	end
	return self.list_count
end

function TreasureExchangeView:RefreshCell(cell, cell_index)
	local exchange_contain = self.exchange_contain_list[cell]
	if exchange_contain == nil then
		exchange_contain = TreasureExchangeContain.New(cell.gameObject, self)
		self.exchange_contain_list[cell] = exchange_contain
	end
	cell_index = cell_index + 1
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local item_id_list = TreasureData.Instance:GetIXunBaotemListByJobAndIndex(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE, prof, cell_index)
	exchange_contain:SetData(item_id_list)
end

function TreasureExchangeView:OnFlush()
	if self.list_count then
		local prof = PlayerData.Instance:GetRoleBaseProf()
		for i = 1, self.list_count do
			TreasureData.Instance:GetXunbaoItemCfgListByIndex(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE, prof, i)
		end
	end
	if 	self.node_list["list_view"] then
		self.node_list["list_view"].scroller:RefreshActiveCellViews()
	end
end

----------------------------------------------------------------------------
TreasureExchangeContain = TreasureExchangeContain or BaseClass(BaseCell)
function TreasureExchangeContain:__init()
	self.item_list = {}
	for i = 1, 4 do
		self.item_list[i] = TreasureExchangeItem.New(self.node_list["item_".. i])
	end
end
function TreasureExchangeContain:__delete()
	if self.item_list ~= nil then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function TreasureExchangeContain:OnFlush()
	for i = 1, 4 do
		self.item_list[i]:SetData(self.data[i])
		--self.item_list[i]:Flush()
	end
end
----------------------------------------------------------------------------
TreasureExchangeItem = TreasureExchangeItem or BaseClass(BaseCell)

function TreasureExchangeItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:SetShowOrangeEffect(true)

	self.node_list["BtnExchange"].toggle:AddClickListener(BindTool.Bind(self.OnExchangeClick, self))

	self.node_list["ImgNameBG"]:SetActive(true)
	self.node_list["ImgNameBG2"]:SetActive(false)
	self.rare_change_list = TreasureData.Instance:GetRareChangeList()
end

function TreasureExchangeItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TreasureExchangeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.data[1] == 0 then
		self.root_node:SetActive(false)
		return
	end
	for k,v in pairs(self.rare_change_list) do
		if self.data[1] == v[1] then
			self.node_list["ImgNameBG"]:SetActive(false)
			self.node_list["ImgNameBG2"]:SetActive(true)
		end
	end
	local item_info = ExchangeData.Instance:GetXunBaoExchangeCfg(self.data[1], EXCHANGE_CONVER_TYPE.XUN_BAO)
	local item_cfg, item_type = ItemData.Instance:GetItemConfig(self.data[1])
	if nil == item_cfg then return end
	
	local prop_name = "<color=" .. SOUL_NAME_COLOR[item_cfg and item_cfg.color or 1] .. ">" .. item_cfg.name .. "</color>"
	self.node_list["TxtName1"].text.text = prop_name
	self.node_list["TxtName2"].text.text = prop_name


	self.node_list["TxtNoLimit"]:SetActive(item_info.limit_convert_count == 0 and item_info.lifetime_convert_count == 0)
	self.node_list["TxtValue"]:SetActive(item_info.limit_convert_count ~= 0 or item_info.lifetime_convert_count ~= 0)

	local treasure_score = TreasureData.Instance:GetTreasureScore()
	if item_info.price_type == 16 then
		local item_bundle, item_asset = ResPath.GetItemIcon(90089)
		treasure_score = TreasureData.Instance:GetTreasureScore1()
		self.node_list["Image"].image:LoadSprite(item_bundle, item_asset)
	elseif item_info.price_type == 17 then
		local item_bundle, item_asset = ResPath.GetItemIcon(90090)
		self.node_list["Image"].image:LoadSprite(item_bundle, item_asset)
		treasure_score = TreasureData.Instance:GetTreasureScore2()
	elseif item_info.price_type == 18 then
		local item_bundle, item_asset = ResPath.GetItemIcon(90091)
		self.node_list["Image"].image:LoadSprite(item_bundle, item_asset)
	elseif item_info.price_type == 5 then
		local item_bundle, item_asset = ResPath.GetItemIcon(90006)
		self.node_list["Image"].image:LoadSprite(item_bundle, item_asset)
	end

	local color = treasure_score >= item_info.price and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	self.node_list["TxtNeedValue"].text.text = ToColorStr(item_info.price, color)

	local text = ""
	if item_info.limit_convert_count ~= 0 then
		local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
		local lifetime_conver_value = ExchangeData.Instance:GetLifetimeRecordCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
		if conver_value == item_info.limit_convert_count then
			text = tostring(item_info.limit_convert_count - conver_value)
			text = ToColorStr(text, TEXT_COLOR.RED)
		else
			text = tostring(item_info.limit_convert_count - conver_value)
			text = ToColorStr(text, TEXT_COLOR.GREEN)
		end
		self.node_list["TxtValue"].text.text = string.format(Language.Treasure.Times, text, item_info.limit_convert_count)
	elseif item_info.lifetime_convert_count ~= 0 then
		local lifetime_conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.XUN_BAO, EXCHANGE_PRICE_TYPE.TREASURE)
		if lifetime_conver_value == item_info.lifetime_convert_count then
			text = tostring(item_info.lifetime_convert_count - lifetime_conver_value)
			text = ToColorStr(text, TEXT_COLOR.RED)
		else
			text = tostring(item_info.lifetime_convert_count - lifetime_conver_value)
			text = ToColorStr(text, TEXT_COLOR.GREEN)
		end
		self.node_list["TxtValue"].text.text = string.format(Language.Treasure.Times, text, item_info.lifetime_convert_count)
	end

	local xianpin_type_string = item_info.xianpin_type_list
	local data = {}
	data.item_id = self.data[1]
	data.is_jueban = self.data[2]
	data.is_bind = item_info.is_bind
	local xianpin_type_list = {}
	if xianpin_type_string then
		xianpin_type_list = Split(xianpin_type_string, ",")
		if xianpin_type_list[1] and xianpin_type_list[1] ~= "0" then
			data.index = -1
			data.param = {}
			data.param.xianpin_type_list = {}
			for k, v in pairs(xianpin_type_list) do
				data.param.xianpin_type_list[k] = tonumber(xianpin_type_list[k])
			end
		end
	end

	-- self.item_cell:SetHideEffect(GameEnum.ITEM_BIGTYPE_EQUIPMENT ~= item_type)
	self.item_cell:SetData(data)
	self.item_cell:IsDestoryActivityEffect(item_info.price >= 1000)
	-- self.item_cell:SetActivityEffect()

	if self.data[2] == 1 then
		self.node_list["Txt2"]:SetActive(true)
		self.node_list["Txt"]:SetActive(true)
		self.node_list["Img"]:SetActive(true)
		self.node_list["List"]:SetActive(false)
		self:InitData()
	else
		self.node_list["Txt2"]:SetActive(false)
		self.node_list["Txt"]:SetActive(false)
		self.node_list["Img"]:SetActive(false)
		self.node_list["List"]:SetActive(true)
	end
	local coutdown_start_timestamp = ExchangeData.Instance:GetExchangeLimitTimeRecordByConverTypeAndSeq(item_info.conver_type ,item_info.seq)
	local rest_time = (item_info.limit_conver_time + coutdown_start_timestamp) - TimeCtrl.Instance:GetServerTime()

	if rest_time > 0 then
		self.node_list["RestTime"]:SetActive(true)
		self.node_list["List"]:SetActive(false)
		local diff_func = function(elapse_time, total_time)
			if elapse_time >= total_time then
				if self.count_down then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				self.node_list["RestTime"]:SetActive(false)
			end
			local time = math.floor(total_time - elapse_time + 0.5)
			if self.node_list and self.node_list["TxtEquipRestTime"] then
				local text = TimeUtil.FormatSecond(time, 12)
				if time <= 3600 then
					text = TimeUtil.FormatSecond(time, 4)
				elseif time > 3600 and time < 24 * 3600 then
					text = TimeUtil.FormatSecond(time, 1)
				end
				self.node_list["TxtEquipRestTime"].text.text = text
			end
		end
		local complete_func = function ()
			self.node_list["List"]:SetActive(true)
			self.node_list["RestTime"]:SetActive(false)
			ExchangeCtrl.Instance:SendGetConvertRecordInfo()
		end
		if nil == self.count_down then
			local text = TimeUtil.FormatSecond(rest_time, 12)
			if rest_time <= 3600 then
				text = TimeUtil.FormatSecond(rest_time, 4)
			elseif rest_time > 3600 and rest_time < 24 * 3600 then
				text = TimeUtil.FormatSecond(rest_time, 1)
			end
			self.node_list["TxtEquipRestTime"].text.text = text
			self.count_down = CountDown.Instance:AddCountDown(rest_time, 1, diff_func, complete_func)
		end
	else
		if self.count_down then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		self.node_list["List"]:SetActive(true)
		self.node_list["RestTime"]:SetActive(false)
	end
end

function TreasureExchangeItem:InitData()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	self:SetTime(time_tab)

	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(rareChange_time, 1, function ()
			time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
			self:SetTime(time_tab)
		end)

end

function TreasureExchangeItem:SetTime(time_tab)
	if time_tab.day < 1 then
		local left_day = ""
		local left_hour = ""
		local left_minute = ""
		local left_second = ""
		if time_tab.hour < 10 then
			left_hour = ToColorStr("0" .. time_tab.hour, COLOR.RED)
		else
			left_hour = ToColorStr(time_tab.hour, COLOR.RED)
		end
		if time_tab.min < 10 then
			left_minute = ToColorStr(":" .. "0" .. time_tab.min, COLOR.RED)
		else
			left_minute = ToColorStr(":" .. time_tab.min, COLOR.RED)
		end
		if time_tab.s < 10 then
			left_second = ToColorStr(":" .. "0" .. time_tab.s, COLOR.RED)
		else
			left_second = ToColorStr(":" .. time_tab.s, COLOR.RED)
		end
		self.node_list["Txt"].text.text = string.format("%s %s%s%s", left_day, left_hour, left_minute, left_second)
	else
		local left_day = ToColorStr(time_tab.day .. Language.Common.TimeList.d, COLOR.GREEN)
		self.node_list["Txt"].text.text = string.format("%s %s%s%s", left_day, "", "", "")
	end
end

function TreasureExchangeItem:OnExchangeClick()
	local exchange_data = ExchangeData.Instance
	local exchange_item_cfg = exchange_data:GetXunBaoExchangeCfg(self.data[1], EXCHANGE_CONVER_TYPE.XUN_BAO)
	if exchange_data:GetScoreList()[exchange_item_cfg.price_type] >= exchange_item_cfg.price then
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, 1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LackTreasureScore)
	end
end