-- 运营活动 限时秒杀
TimeLimitSaleView = TimeLimitSaleView or BaseClass(BaseView)

local COUNT_IN_PAGE = 6				-- 每页个数

function TimeLimitSaleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/randomact/timelimitsale_prefab", "TimeLimitSaleView"},
	}
	self.play_audio = true
	self.cell_list = {}
	self.timelimit_left_time = 0
	self.open_phase = 1
	self.is_in_phase = false						--是否在阶段中
	self.is_modal = true

	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
end

function TimeLimitSaleView:__delete()

end

function TimeLimitSaleView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	self.cell_list = {}
	self.page_list = {}
end

function TimeLimitSaleView:LoadCallBack()
	self.can_kill_phase = 1
	self:SetCanKillPhase(1,self.seckilling)
	self.seckilling = 0
	self:SetSkilling(0,self.can_kill_phase)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["Name"].text.text = Language.Activity.MiaoSha
	
	-- 设置时间段
	local time_list = TimeLimitSaleData.Instance:GetPhaseTimeList()
	if nil ~= time_list then
		for i = 1,4 do
			local time = time_list[i]
			local str = string.format(Language.Common.StartTimeDes, time)
			self.node_list["TxtNormal" .. i].text.text = str
			self.node_list["TxtHL" .. i].text.text = str
		end
	end

	-- 设置页码
	self.page_list = {}
	for i = 1,10 do
		self.page_list[i] = self.node_list["Tpggle" .. i]
	end
	self:SetPageCount(1)

	self.list_data = {}
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)
end

-- 设置页码
function TimeLimitSaleView:SetPageCount(page_value)
	for i = 1,page_value do
		self.page_list[i]:SetActive(true)
	end
end

-- 设置时间栏的状态 参数为Integer
function TimeLimitSaleView:SetCanKillPhase(can_kill_phase,seckilling)
	self.can_kill_phase = can_kill_phase

	self.node_list["ImgNormal1"]:SetActive(not (1 == can_kill_phase))
	self.node_list["ImgHL1"]:SetActive(1 == can_kill_phase)
	self.node_list["ImgNotOpen1"]:SetActive((can_kill_phase < 1) and (not (1 == seckilling)))
	self.node_list["ImgIsEnd1"]:SetActive((can_kill_phase > 1) and (not (1 == seckilling)))
	self.node_list["ImgReadying1"]:SetActive((1 == can_kill_phase) and (not (1 == seckilling)))

	self.node_list["ImgNormal2"]:SetActive(not (2 == can_kill_phase))
	self.node_list["ImgHL2"]:SetActive(2 == can_kill_phase)
	self.node_list["ImgNotOpen2"]:SetActive((can_kill_phase < 2) and (not (2 == seckilling)))
	self.node_list["ImgIsEnd2"]:SetActive((can_kill_phase >2) and (not (2 == seckilling)))
	self.node_list["ImgReadying2"]:SetActive((2 == can_kill_phase) and (not (2 == seckilling)))

	self.node_list["ImgNormal3"]:SetActive(not (3 == can_kill_phase))
	self.node_list["ImgHL3"]:SetActive(3 == can_kill_phase)
	self.node_list["ImgNotOpen3"]:SetActive((can_kill_phase < 3) and (not (3 == seckilling)))
	self.node_list["ImgIsEnd3"]:SetActive((can_kill_phase > 3) and (not (3 == seckilling)))
	self.node_list["ImgReadying3"]:SetActive((3 == can_kill_phase) and (not (3 == seckilling)))

	self.node_list["ImgNormal4"]:SetActive(not (4 == can_kill_phase))
	self.node_list["ImgHL4"]:SetActive(4 == can_kill_phase)
	self.node_list["ImgNotOpen4"]:SetActive((can_kill_phase < 4) and (not (4 == seckilling)))
	self.node_list["ImgIsEnd4"]:SetActive((can_kill_phase > 4) and (not (4 == seckilling)))
	self.node_list["ImgReadying4"]:SetActive((4 == can_kill_phase) and (not (4 == seckilling)))
end

-- 设置秒杀开始状态 参数为Integer
function TimeLimitSaleView:SetSkilling(seckilling,can_kill_phase)
	self.seckilling = seckilling

	self.node_list["ImgNotOpen1"]:SetActive((can_kill_phase < 1) and (not (1 == seckilling)))
	self.node_list["ImgIsEnd1"]:SetActive((can_kill_phase > 1) and (not (1 == seckilling)))
	self.node_list["ImgReadying1"]:SetActive((1 == can_kill_phase) and (not (1 == seckilling)))
	self.node_list["ImgStarting1"]:SetActive(1 == seckilling)

	self.node_list["ImgNotOpen2"]:SetActive((can_kill_phase < 2) and (not (2 == seckilling)))
	self.node_list["ImgIsEnd2"]:SetActive((can_kill_phase > 2) and (not (2 == seckilling)))
	self.node_list["ImgReadying2"]:SetActive((2 == can_kill_phase) and (not (2 == seckilling)))
	self.node_list["ImgStarting2"]:SetActive(2 == seckilling)

	self.node_list["ImgNotOpen3"]:SetActive((can_kill_phase < 3) and (not (3 == seckilling)))
	self.node_list["ImgIsEnd3"]:SetActive((can_kill_phase > 3) and (not (3 == seckilling)))
	self.node_list["ImgReadying3"]:SetActive((3 == can_kill_phase) and (not (3 == seckilling)))
	self.node_list["ImgStarting3"]:SetActive(3 == seckilling)

	self.node_list["ImgNotOpen4"]:SetActive((can_kill_phase < 4) and (not (4 == seckilling)))
	self.node_list["ImgIsEnd4"]:SetActive((can_kill_phase > 4) and (not (4 == seckilling)))
	self.node_list["ImgReadying4"]:SetActive((4 == can_kill_phase) and (not (4 == seckilling)))
	self.node_list["ImgStarting4"]:SetActive(4 == seckilling)
end

function TimeLimitSaleView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, RA_RUSH_BUYING_OPERA_TYPE.RA_RUSH_BUYING_OPERA_TYPE_QUERY_ALL_INFO)

	self:CalcPhase()
	--开始倒计时秒杀倒计时
	self:StartRushBuyCountDown()

	--开始计算活动剩余时间
	self:StartLeftCountDown()

	self:FlushListView()
	self:ChangePhase()
end

function TimeLimitSaleView:CloseCallBack()
	self:StopLeftCountDown()
	self:StopRushBuyCountDown()
end

function TimeLimitSaleView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "list" then
			self:CalcPhase()
			self:StartRushBuyCountDown()
			self:FlushListView()
			self:ChangePhase()
		end
	end
end

--计算当前处于哪个阶段
function TimeLimitSaleView:CalcPhase()
	self.open_phase = 1
	self.is_in_phase = false

	local time_list = TimeLimitSaleData.Instance:GetPhaseTimeList()
	if nil == time_list then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	server_time = math.floor(server_time)
	local rush_buying_duration = TimeLimitSaleData.Instance:GetRushBuyingDuration() or 0
	local rush_buying_second = rush_buying_duration * 60
	local h = tonumber(os.date("%H", server_time))
	local m = tonumber(os.date("%M", server_time))
	local s = tonumber(os.date("%S", server_time))

	local second = m * 60 + s
	local is_next_day = false

	for k, v in ipairs(time_list) do
		if h > v then
			-- self.open_phase = self.open_phase + 1
			if (h - v) * 60 * 60 + second < rush_buying_second then
				if time_list[k + 1] then
					if h >= time_list[k + 1] then
						self.open_phase = self.open_phase + 1
					else
						self.is_in_phase = true
						break
					end
				else
					self.is_in_phase = true
					break
				end
			else
				self.open_phase = self.open_phase + 1
			end
		elseif h == v then
			--小时相同的时候检查秒数
			if (h - v) * 60 * 60 + second < rush_buying_second then
				self.is_in_phase = true
				break
			else
				self.open_phase = self.open_phase + 1
			end
		end

		if self.open_phase > 4 then
			is_next_day = true
			self.open_phase = 1
			break
		end
	end

	--计算剩余时间
	self.timelimit_left_time = 0
	if self.is_in_phase then
		self.timelimit_left_time = rush_buying_second - second
	else
		local next_time = time_list[self.open_phase]
		if is_next_day then
			self.timelimit_left_time = (24 - h + next_time) * 3600 - second
		else
			self.timelimit_left_time = (next_time - h) * 3600 - second
		end
	end
end

function TimeLimitSaleView:FlushListView()

	self.list_data = TimeLimitSaleData.Instance:GetItemListBySeq(self.open_phase - 1) or {}
	local page = math.ceil(#self.list_data/COUNT_IN_PAGE)
	self:SetPageCount(page)
	self.node_list["ListView"].list_page_scroll2:SetPageCount(page)
	self.node_list["ListView"].list_view:Reload()
end

function TimeLimitSaleView:ChangePhase()
	local old_phase = self.can_kill_phase
	if old_phase ~= self.open_phase then
		--直接跳到第一页
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	end

	self:SetCanKillPhase(self.open_phase,self.seckilling)
end

function TimeLimitSaleView:StopRushBuyCountDown()
	if self.rush_buying_count_down then
		CountDown.Instance:RemoveCountDown(self.rush_buying_count_down)
		self.rush_buying_count_down = nil
	end
end

function TimeLimitSaleView:StartRushBuyCountDown()
	self:StopRushBuyCountDown()
	self:SetSeckillingCorner(0)
	local str = Language.RandomActivity.RushBuyingDes1
	if self.is_in_phase then
		self:SetSeckillingCorner(self.open_phase)
		str = Language.RandomActivity.RushBuyingDes2
	end

	local des = string.format(str, TimeUtil.FormatSecond(self.timelimit_left_time))
	self.node_list["TxtStartKillTimes"].text.text = des

	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StopRushBuyCountDown()
			--时间到了请求协议
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, RA_RUSH_BUYING_OPERA_TYPE.RA_RUSH_BUYING_OPERA_TYPE_QUERY_ALL_INFO)
			return
		end

		local left_time = total_time - math.floor(elapse_time)
		des = string.format(str, TimeUtil.FormatSecond(left_time))
		self.node_list["TxtStartKillTimes"].text.text = des
	end

	self.rush_buying_count_down = CountDown.Instance:AddCountDown(self.timelimit_left_time, 1, time_func)
end

function TimeLimitSaleView:ClickHelp()
	local tips_id = 212
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function TimeLimitSaleView:StopLeftCountDown()
	if self.left_count_down then
		CountDown.Instance:RemoveCountDown(self.left_count_down)
		self.left_count_down = nil
	end
end

function TimeLimitSaleView:StartLeftCountDown()
	self:StopLeftCountDown()

	--计算时间函数
	local function calc_times(times)
		local time_tbl = TimeUtil.Format2TableDHMS(times)
		local time_des = ""
		if time_tbl.day > 0 then
			--大于1天的只显示天数和时间
			time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
		else
			--小于一天的就显示三位时间
			time_des = TimeUtil.FormatSecond(times)
		end
		self.node_list["TxtLeftTimes"].text.text = string.format(Language.RandomActivity.ActivityResidueTime, time_des)
	end

	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.node_list["TxtLeftTimes"].text.text = string.format(Language.RandomActivity.ActivityResidueTime, "00:00:00")
			self:StopLeftCountDown()
		end

		--先计算出剩余时间秒数
		local times = total_time - math.floor(elapse_time)
		calc_times(times)
	end

	local left_act_times = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING)
	--不足1s按1s算（向上取整）
	left_act_times = math.ceil(left_act_times)
	if left_act_times > 0 then
		--活动进行中
		calc_times(left_act_times)
		self.left_count_down = CountDown.Instance:AddCountDown(left_act_times, 1, time_func)
	else
		--活动已结束
		self.node_list["TxtLeftTimes"].text.text = string.format(Language.RandomActivity.ActivityResidueTime, "00:00:00")
	end
end

function TimeLimitSaleView:CloseWindow()
	self:Close()
end

function TimeLimitSaleView:GetCellNumber()
	return #self.list_data
end

function TimeLimitSaleView:RefreshDel(data_index, cell)
	data_index = data_index + 1
	local new_cell = self.cell_list[cell]
	if not new_cell then
		new_cell = TimeLimitSaleItem.New(cell.gameObject)
		self.cell_list[cell] = new_cell
	end

	new_cell:SetIndex(data_index)
	new_cell:SetIsInPhase(self.is_in_phase)
	new_cell:SetData(self.list_data[data_index])
end

--设置活动进行中角标
function TimeLimitSaleView:SetSeckillingCorner(index)
	self:SetSkilling(index,self.can_kill_phase)
end

--------TimeLimitItem---------------------------------------------------------------
TimeLimitSaleItem = TimeLimitSaleItem or BaseClass(BaseCell)
function TimeLimitSaleItem:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetData(nil)
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
end

function TimeLimitSaleItem:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TimeLimitSaleItem:ClickBuy()
	local gold_des = ToColorStr(self.data.sale_price, TEXT_COLOR.GREEN)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.sale_item.item_id)
	local item_color = ITEM_COLOR[GameEnum.ITEM_COLOR_WHITE]
	local item_name = ""
	if item_cfg then
		item_color = ITEM_COLOR[item_cfg.color]
		item_name = item_cfg.name
	end
	local item_des = ToColorStr(item_name, item_color)

	local des = string.format(Language.Common.BuyItemByGoldDes, gold_des, item_des)
	local function ok_callback()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING, RA_RUSH_BUYING_OPERA_TYPE.RA_RUSH_BUYING_OPERA_TYPE_BUY_ITEM, self.data.index)
	end
	TipsCtrl.Instance:ShowCommonAutoView("rush_buy", des, ok_callback)
end

function TimeLimitSaleItem:SetIsInPhase(is_in_phase)
	self.is_in_phase = is_in_phase
end

function TimeLimitSaleItem:OnFlush()
	if nil == self.data then return end

	local item_data = self.data.sale_item
	self.item_cell:SetData(item_data)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	local item_name = ""
	local item_color = ITEM_COLOR[GameEnum.ITEM_COLOR_WHITE]

	if nil ~= item_cfg then
		item_name = item_cfg.name
		item_color = ITEM_COLOR[item_cfg.color]
	end

	self.node_list["TxtName"].text.text = ToColorStr(item_name, item_color)
	self.node_list["TxtCost1"].text.text = self.data.original_price
	self.node_list["TxtCost2"].text.text = self.data.sale_price

	--获取已经购买的次数
	local buy_times_list = TimeLimitSaleData.Instance:GetBuyTimesInSeq(self.data.seq, self.data.index)
	local role_buy_times = 0
	local server_buy_times = 0
	if nil ~= buy_times_list then
		role_buy_times = buy_times_list.role_buy_times
		server_buy_times = buy_times_list.server_buy_times
	end
	--最大限购次数
	local max_role_buy_times = self.data.role_buy_times_limit
	local max_server_buy_times = self.data.server_buy_times_limit
	--可购买的最大次数(其中一项满了都不能再买了)
	local can_buy_role_times = max_role_buy_times - role_buy_times
	local can_buy_server_times = max_server_buy_times - server_buy_times
	if can_buy_role_times <= 0 or can_buy_server_times <= 0 or not self.is_in_phase then
		UI:SetButtonEnabled(self.node_list["BtnBuy"], false)
	else
		UI:SetButtonEnabled(self.node_list["BtnBuy"], true)
	end

	--设置个人限购次数显示
	local role_color = "89f201"
	if can_buy_role_times <= 0 then
		role_color = "ff0000"
	end


	local str = string.format(Language.XianShiMiaoSha.num, can_buy_role_times, role_color, max_role_buy_times)
	RichTextUtil.ParseRichText(self.node_list["TxtNum"].rich_text, str, 20)
	--设置全服限购次数显示
	local server_color = "89f201"
	if can_buy_server_times <= 0 then
		server_color = "ff0000"
	end


	local str2 = string.format(Language.XianShiMiaoSha.num, can_buy_server_times, server_color, max_server_buy_times)
	RichTextUtil.ParseRichText(self.node_list["TxtNum2"].rich_text, str2, 20)
end
