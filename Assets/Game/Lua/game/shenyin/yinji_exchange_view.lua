ShenYinYinJiExchangeView = ShenYinYinJiExchangeView or BaseClass(BaseRender)


local MOVE_TIME = 0.5	-- 界面动画时间

function ShenYinYinJiExchangeView:UIsMove()
	UITween.AlpahShowPanel(self.node_list["MiddleContent"] ,true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["MiddleContent"] , Vector3(0 , -100 , 0 ) , MOVE_TIME )
end
function ShenYinYinJiExchangeView:__init()
	self:InitListView()
end

function ShenYinYinJiExchangeView:__delete()
	for _, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = {}
end

function ShenYinYinJiExchangeView:OpenCallBack()
	self:Flush()
end

function ShenYinYinJiExchangeView:OnFlush(param_t)
	self:FlushView()
end

function ShenYinYinJiExchangeView:InitListView()
	self.contain_cell_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ShenYinYinJiExchangeView:GetNumberOfCells()
	local exchange_cfg = ShenYinData.Instance:GetShenYinExchangeCfg()
	return math.ceil(#exchange_cfg / 4)
end

function ShenYinYinJiExchangeView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ShenYinExchangeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
	end
	cell_index = cell_index + 1
	local item_id_list = ShenYinData.Instance:GetShenYinExchangeContainByIndex(cell_index - 1)
	contain_cell:InitItems(item_id_list)
	contain_cell:SetIndex(cell_index)
end

function ShenYinYinJiExchangeView:FlushView()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushAllFrame()
	end
end


------------------------------------------------------------------------
ShenYinExchangeContain = ShenYinExchangeContain or BaseClass(BaseCell)

function ShenYinExchangeContain:__init()
	self.exchange_contain_list = {}
	for i = 1, 4 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ShenYinExchangeItem.New(self.node_list["item_" .. i])
	end
end

function ShenYinExchangeContain:__delete()
	for i = 1, 4 do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function ShenYinExchangeContain:GetFirstCell()
	return self.exchange_contain_list[1]
end

function ShenYinExchangeContain:InitItems(item_id_list)
	for i = 1, 4 do
		if nil ~= item_id_list[i] then
			self.exchange_contain_list[i]:SetItemData(item_id_list[i])
			self.exchange_contain_list[i]:OnFlush()
			self.exchange_contain_list[i]:SetActive(true)
		else
			self.exchange_contain_list[i]:SetActive(false)
		end
	end
end

function ShenYinExchangeContain:FlushItems(item_id_list,toggle_group)

end

function ShenYinExchangeContain:SetToggleGroup(toggle_group)
	for i = 1, 4 do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ShenYinExchangeContain:FlushAllFrame()
	for i = 1, 4 do
		self.exchange_contain_list[i]:Flush()
	end
end

----------------------------------------------------------------------------
ShenYinExchangeItem = ShenYinExchangeItem or BaseClass(BaseCell)

function ShenYinExchangeItem:__init()
	self.item_data = {}
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item"])
	self.btn_exchange = self.node_list["NodeExchange"]
	self.node_list["btn_exchange"].toggle:AddClickListener(BindTool.Bind(self.ImprintExchangeCallback, self))

end

function ShenYinExchangeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ShenYinExchangeItem:SetItemData(item_id_list)
	self.item_data = item_id_list
end

function ShenYinExchangeItem:OnFlush()
	local item_data_cfg = ShenYinData.Instance:GetItemCFGByVItemID(self.item_data.v_item_id)
	local item_info = ShenYinData.Instance:GetSpiritImprintShopItemInfoByIndex(self.item_data.index)
	local exchange_item_cfg = ShenYinData.Instance:GetShenYinExchangeItemByIndex(self.item_data.index)
	if self.item_data.is_virtual_item == 0 then
		item_data_cfg = ItemData.Instance:GetItemConfig(self.item_data.v_item_id)
	end
	self.node_list["TimeTxt"].text.text = ""
	if nil == item_data_cfg or nil == item_info or 
		nil == exchange_item_cfg then 
		return
	end
	
	local item_id = item_data_cfg.item_id or item_data_cfg.id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local score_info = ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()
	local buy_count = exchange_item_cfg.buy_count - item_info.buy_count
	local ExchangeTimesLeft
	if buy_count < 0 then
		buy_count = 0
	end
	local color = buy_count > 0 and TEXT_COLOR.LIGHTYELLOW or TEXT_COLOR.RED
	self.node_list["NameTxt"].text.text = string.format(Language.ShenYin.ExchangeItemName, ITEM_COLOR[item_cfg.color], item_cfg.name)

	if exchange_item_cfg.is_week_refresh >= 1 then
		ExchangeTimesLeft = Language.ShenYin.ExchangeTimesLeftWeek
	else
		ExchangeTimesLeft = Language.ShenYin.ExchangeTimesLeftDay
	end
	self.item_cell:SetData({item_id = item_id, num = self.item_data.item_num, is_bind = self.item_data.is_bind})
	self.node_list["LimitTxt"].text.text = string.format(ExchangeTimesLeft, color, buy_count)

	color = score_info >= self.item_data.imprint_score and TEXT_COLOR.DARKYELLOW or TEXT_COLOR.RED
	self.node_list["ExchangTxt"].text.text = string.format(Language.ShenYin.ExchangeFen, color, self.item_data.imprint_score)

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if buy_count <= 0 then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local next_flush_time = item_info.timestamp - server_time
		local next_flush_time_str = self:FormatSecond2Str(next_flush_time)
		self.btn_exchange:SetActive(false)
		self.node_list["TimeTxt"].text.text = next_flush_time_str
		
		self.count_down = CountDown.Instance:AddCountDown(next_flush_time, 1, BindTool.Bind(self.CountDown, self))
	else
		self.btn_exchange:SetActive(true)
		self.node_list["TimeTxt"].text.text = ""
	end
end

function ShenYinExchangeItem:CountDown(elapse_time, total_time)
	local next_flush_time_str = self:FormatSecond2Str(total_time - elapse_time)
	self.node_list["TimeTxt"].text.text = next_flush_time_str
	if elapse_time >= total_time then
		self:Flush()
	end
end

function ShenYinExchangeItem:FormatSecond2Str(time)
	if nil == time then
		return ""
	end
	local time_t = TimeUtil.Format2TableDHMS(time)
	local time_str_1 = ""
	local time_1 = 0
	local time_str_2 = ""
	local time_2 = 0
	for i,v in ipairs({'day','hour','min','s'}) do
		if (time_t[v] and time_t[v] > 0) or "" ~= time_str_1 or 'min' == v then
			if time_str_1 == "" then
				time_1 = time_t[v]
				time_str_1 = Language.ShenYin.TimeList[v]
			elseif time_str_2 == "" then
				time_2 = time_t[v]
				time_str_2 = Language.ShenYin.TimeList[v]
				break
			end
		end
	end

	return string.format(Language.ShenYin.NextExchangeFlush, time_1, time_str_1,
		time_2, time_str_2)
end

function ShenYinExchangeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function ShenYinExchangeItem:ImprintExchangeCallback()
	local item_info = ShenYinData.Instance:GetSpiritImprintShopItemInfoByIndex(self.item_data.index)
	local exchange_item_cfg = ShenYinData.Instance:GetShenYinExchangeItemByIndex(self.item_data.index)
	local score_info = ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()
	local buy_count = exchange_item_cfg.buy_count - item_info.buy_count
	if score_info < self.item_data.imprint_score then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.ExchangeScoreInsufficient)
	elseif buy_count <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.ExchangeNoTimes)
	else
		local max_buy_num = math.floor(score_info / exchange_item_cfg.imprint_score)
		if max_buy_num > buy_count then
			max_buy_num = buy_count
		end
		TipsCtrl.Instance:OpenCommonInputView(1, BindTool.Bind(self.SendImprintExchange, self), nil, max_buy_num)
	end
end

function ShenYinExchangeItem:SendImprintExchange(cur_num)
	local cur_num = tonumber(cur_num)
	if cur_num == 0 then
		cur_num = 1
	end
	for i = 1, cur_num do
		ShenYinCtrl.Instance.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_EXCHANGE, self.item_data.index)
	end
end