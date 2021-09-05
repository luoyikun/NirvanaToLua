local COLUMN = 3

CoupleHomeThemeBuyView = CoupleHomeThemeBuyView or BaseClass(BaseRender)
function CoupleHomeThemeBuyView:__init()
	self.select_index = 1
	self.home_cell_list = {}
	self.home_data = CoupleHomeHomeData.Instance:GetSpecialThemeCfg()
	self.max_page = math.ceil(#self.home_data / COLUMN)

	self.home_list = self.node_list["HomeList"]
	self.home_list.list_page_scroll:SetPageCount(self.max_page)
	self.home_list.list_page_scroll.JumpToPageEvent = self.home_list.list_page_scroll.JumpToPageEvent + BindTool.Bind(self.PageChangeEvent, self)
	local scroller_delegate = self.home_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.node_list["PageUp"].button:AddClickListener(BindTool.Bind(self.PageUp, self))
	self.node_list["PageDown"].button:AddClickListener(BindTool.Bind(self.PageDown, self))
	self.node_list["ButtonBuy"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
	self.node_list["ButtonLoveBuy"].button:AddClickListener(BindTool.Bind(self.ClickLoverBuy, self))
	-- self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))

	self.click_cell_callback = BindTool.Bind(self.ClickCellCallBack, self)
end

function CoupleHomeThemeBuyView:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CoupleHomeThemeBuyView:ReleaseCallBack()
	for _, v in pairs(self.home_cell_list) do
		v:DeleteMe()
	end
	self.home_cell_list = nil

	self.home_list = nil
	self.show_page_up = nil
	self.show_page_down = nil

	-- if self.time_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.time_quest)
	-- 	self.time_quest = nil
	-- end
end

function CoupleHomeThemeBuyView:LoadCallBack()

end

function CoupleHomeThemeBuyView:CloseWindow()
	self:Close()
end

function CoupleHomeThemeBuyView:OpenCallBack()
	self.select_index = 1
	self:Flush()
end

function CoupleHomeThemeBuyView:ClickCellCallBack(cell)
	cell:SetToggleIsOn(true)

	local data = cell:GetData()
	if data == nil then
		return
	end

	local index = cell:GetIndex()
	if index == self.select_index then
		return
	end
	self.select_index = index
end

function CoupleHomeThemeBuyView:PageChangeEvent()
	self:FlushPageShow()
end

function CoupleHomeThemeBuyView:NumberOfCell()
	return self.max_page
end

function CoupleHomeThemeBuyView:CellRefresh(cell, data_index)
	local home_group = self.home_cell_list[cell]
	if home_group == nil then
		home_group = CoupleHomeBuyGroup.New(cell.gameObject)
		home_group:SetClickCallBack(self.click_cell_callback)
		home_group:SetToggleGroup(self.home_list.toggle_group)
		self.home_cell_list[cell] = home_group
	end

	for i = 1, COLUMN do
		local index = data_index * COLUMN + i
		home_group:SetToggleIsOn(i, self.select_index == index)
		home_group:SetIndex(i, index)
		home_group:SetData(i, self.home_data[index])
	end
end

function CoupleHomeThemeBuyView:PageUp()
	local now_page = self.home_list.list_page_scroll:GetNowPage()
	if now_page <= 0 then
		return
	end

	self.home_list.list_page_scroll:JumpToPage(now_page - 1)
end

function CoupleHomeThemeBuyView:PageDown()
	local now_page = self.home_list.list_page_scroll:GetNowPage()
	if now_page >= self.max_page - 1 then
		return
	end

	self.home_list.list_page_scroll:JumpToPage(now_page + 1)
end

function CoupleHomeThemeBuyView:ClickBuy()
	local data = self.home_data[self.select_index]
	if data == nil then
		return
	end

	local function ok_callback()
		CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_BUY_THEME, data.theme_type)
	end

	local des = ""
	local name_des = ToColorStr(Language.CoupleHome.ThemeType[data.theme_type], TEXT_COLOR.GREEN)

	local buy_need_gold = data.buy_need_gold
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		buy_need_gold = data.buy_need_gold * 0.5
	end
	if data.price_type > 0 then
		des = string.format(Language.CoupleHome.BuyByGoldDes, buy_need_gold, Language.Common.Gold, name_des)
	else
		des = string.format(Language.CoupleHome.BuyByGoldDes, buy_need_gold, Language.CoupleHome.Bind, name_des)
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
end

function CoupleHomeThemeBuyView:ClickLoverBuy()
	local data = self.home_data[self.select_index]
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if data == nil or main_vo == nil then
		return
	end

	local function ok_callback()
		CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_BUY_THEME_FOR_LOVER, main_vo.lover_uid, data.theme_type)
	end

	local des = ""
	local name_des = ToColorStr(Language.CoupleHome.ThemeType[data.theme_type], TEXT_COLOR.GREEN)
	local buy_need_gold = data.buy_need_gold
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		buy_need_gold = data.buy_need_gold * 0.5
	end

	if data.price_type > 0 then
		des = string.format(Language.CoupleHome.BuyLoverByGoldDes, buy_need_gold, Language.Common.Gold, main_vo.lover_name, name_des)
	else
		des = string.format(Language.CoupleHome.BuyLoverByGoldDes, buy_need_gold, Language.CoupleHome.Bind, main_vo.lover_name, name_des)
	end
	TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
end

function CoupleHomeThemeBuyView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(306)
end

function CoupleHomeThemeBuyView:FlushPageShow(page)
	local now_page = page or self.home_list.list_page_scroll:GetNowPage()
	self.node_list["PageUp"]:SetActive(now_page > 0)
	self.node_list["PageDown"]:SetActive(now_page < self.max_page - 1)
end

function CoupleHomeThemeBuyView:FlushView()
	self.home_list.scroller:ReloadData(0)
	self:FlushPageShow(0)
end

function CoupleHomeThemeBuyView:OnFlush()
	self:FlushView()

	local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid or 0
	self.node_list["LoveText"]:SetActive(lover_uid > 0)
	self.node_list["ButtonLoveBuy"]:SetActive(lover_uid > 0)

	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushActNextTime, self), 1)
		self:FlushActNextTime()
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		self.node_list["TextActivity"]:SetActive(true)
		self.node_list["Flower"]:SetActive(true)
		-- local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		-- if open_server_day <= 3 then
		-- 	self.node_list["TextActivity"].text.text = Language.CoupleHome.KaifuBuyHome
		-- else
			self.node_list["TextActivity"].text.text = Language.CoupleHome.NormalBuyHome
		-- end
	else
		self.node_list["TextActivity"]:SetActive(false)
		self.node_list["Flower"]:SetActive(false)
	end
end

function CoupleHomeThemeBuyView:FlushActNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["txt_timer"].text.text = TimeUtil.FormatSecond(time, 10)
end