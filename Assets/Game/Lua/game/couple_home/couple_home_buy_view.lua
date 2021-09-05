local COLUMN = 3

CoupleHomeBuyContentView = CoupleHomeBuyContentView or BaseClass(BaseRender)
function CoupleHomeBuyContentView:__init()
	self.select_index = 1

	self.home_cell_list = {}
	self.home_data = CoupleHomeHomeData.Instance:GetSpecialThemeCfg()
	self.max_page = math.ceil(#self.home_data / COLUMN)

	self.home_list = self.node_list["ListView"]
	self.home_list.list_page_scroll:SetPageCount(self.max_page)
	self.home_list.list_page_scroll.JumpToPageEvent = self.home_list.list_page_scroll.JumpToPageEvent + BindTool.Bind(self.PageChangeEvent, self)
	local scroller_delegate = self.home_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.node_list["PageUp"].button:AddClickListener(BindTool.Bind(self.PageUp, self))
	self.node_list["PageDown"].button:AddClickListener(BindTool.Bind(self.PageDown, self))
	self.node_list["ButtonBuy"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))
	self.node_list["ButtonLoveBuy"].button:AddClickListener(BindTool.Bind(self.ClickLoverBuy, self))
	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))

	self.click_cell_callback = BindTool.Bind(self.ClickCellCallBack, self)
end

function CoupleHomeBuyContentView:__delete()
	for _, v in pairs(self.home_cell_list) do
		v:DeleteMe()
	end
	self.home_cell_list = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function CoupleHomeBuyContentView:ClickCellCallBack(cell)
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

function CoupleHomeBuyContentView:PageChangeEvent()
	self:FlushPageShow()
end

function CoupleHomeBuyContentView:NumberOfCell()
	return self.max_page
end

function CoupleHomeBuyContentView:CellRefresh(cell, data_index)
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

function CoupleHomeBuyContentView:PageUp()
	local now_page = self.home_list.list_page_scroll:GetNowPage()
	if now_page <= 0 then
		return
	end

	self.home_list.list_page_scroll:JumpToPage(now_page - 1)
end

function CoupleHomeBuyContentView:PageDown()
	local now_page = self.home_list.list_page_scroll:GetNowPage()
	if now_page >= self.max_page - 1 then
		return
	end

	self.home_list.list_page_scroll:JumpToPage(now_page + 1)
end

function CoupleHomeBuyContentView:ClickBuy()
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

function CoupleHomeBuyContentView:ClickLoverBuy()
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

function CoupleHomeBuyContentView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(306)
end

--界面隐藏时调用
function CoupleHomeBuyContentView:CloseView()

end

function CoupleHomeBuyContentView:FlushPageShow(page)
	local now_page = page or self.home_list.list_page_scroll:GetNowPage()
	self.node_list["PageUp"]:SetActive(now_page > 0)
	self.node_list["PageDown"]:SetActive(now_page < self.max_page - 1)
end

--界面显示时调用
function CoupleHomeBuyContentView:InitView()
	self.select_index = 1
	self:FlushView()
end

function CoupleHomeBuyContentView:FlushView()
	local lover_uid = GameVoManager.Instance:GetMainRoleVo().lover_uid or 0
	self.node_list["LoveText"]:SetActive(lover_uid > 0)
	self.node_list["ButtonLoveBuy"]:SetActive(lover_uid > 0)

	self.home_list.scroller:ReloadData(0)
	self:FlushPageShow(0)
end

function CoupleHomeBuyContentView:OnFlush()
	self:FlushView()

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		self.node_list["TextActivity"]:SetActive(true)
		-- local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		-- if open_server_day <= 3 then
		-- 	self.node_list["TextActivity"].text.text = Language.CoupleHome.KaifuBuyHome
		-- else
			self.node_list["TextActivity"].text.text = Language.CoupleHome.NormalBuyHome
		-- end
	else
		self.node_list["TextActivity"]:SetActive(false)
	end
	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushActNextTime, self), 1)
		self:FlushActNextTime()
	end
end

function CoupleHomeBuyContentView:FlushActNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME)
	self.node_list["Flower"]:SetActive(true)
	if time <= 0 then
		self.node_list["Flower"]:SetActive(false)
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.node_list["txt_timer"].text.text = TimeUtil.FormatSecond(time, 10)
end

-----------------------------CoupleHomeBuyGroup--------------------------------
CoupleHomeBuyGroup = CoupleHomeBuyGroup or BaseClass(BaseRender)
function CoupleHomeBuyGroup:__init()
	self.cell_list = {}
	for i = 1, COLUMN do
		local cell = CoupleHomeBuyCell.New(self.node_list["Cell" .. i])
		self.cell_list[i] = cell
	end
end

function CoupleHomeBuyGroup:__delete()
	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function CoupleHomeBuyGroup:SetClickCallBack(callback)
	for _, v in ipairs(self.cell_list) do
		v:SetClickCallBack(callback)
	end
end

function CoupleHomeBuyGroup:SetToggleGroup(group)
	for _, v in ipairs(self.cell_list) do
		v:SetToggleGroup(group)
	end
end

function CoupleHomeBuyGroup:SetToggleIsOn(i, is_on)
	self.cell_list[i]:SetToggleIsOn(is_on)
end

function CoupleHomeBuyGroup:SetIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function CoupleHomeBuyGroup:SetData(i, data)
	self.cell_list[i]:SetData(data)
end

-----------------------------CoupleHomeBuyCell--------------------------------
CoupleHomeBuyCell = CoupleHomeBuyCell or BaseClass(BaseCell)
function CoupleHomeBuyCell:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Number"], "FightPower3")
	self.node_list["HomeItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["ClickIcon"].button:AddClickListener(BindTool.Bind(self.ClickIcon, self))
end

function CoupleHomeBuyCell:__delete()
	self.fight_text = nil
end

function CoupleHomeBuyCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CoupleHomeBuyCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function CoupleHomeBuyCell:ClickIcon()
	if self.data == nil then
		return
	end

	--弹出预览界面
	CoupleHomeCtrl.Instance:ShowPreView(self.data.theme_type)

	self:OnClick()
end

function CoupleHomeBuyCell:OnFlush()
	if self.data == nil then
		self:SetActive(false)
		return
	end
	self:SetActive(true)

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_HOME) then
		self.node_list["Text"]:SetActive(true)
		self.node_list["Image"]:SetActive(true)
		self.node_list["Text"].text.text = self.data.buy_need_gold * 0.5
	else
		self.node_list["Text"]:SetActive(false)
		self.node_list["Image"]:SetActive(false)
	end
		self.node_list["CostText"].text.text = self.data.buy_need_gold

	if self.data.price_type > 0 then
		self.node_list["CoinImage"].image:LoadSprite(ResPath.GetDiamonIcon("5"))
	else
		self.node_list["CoinImage"].image:LoadSprite(ResPath.GetDiamonIcon("5_bind"))
	end

	local theme_type = self.data.theme_type
	local theme_attr_info = CoupleHomeHomeData.Instance:GetThemeAttrCfgInfoByThemeType(theme_type)
	if theme_attr_info then
		local power = CommonDataManager.GetCapabilityCalculation(theme_attr_info)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	end

	local normal_theme_text_asset = "couple_theme_text_" .. theme_type
	local normal_text_bundle, normal_text_asset = ResPath.GetCoupleHomeImg(normal_theme_text_asset)
	self.node_list["NormalImage"].image:LoadSprite(normal_text_bundle, normal_text_asset)

	local high_theme_text_asset = "couple_theme_text_" .. theme_type .. "_h"
	local high_text_bundle, high_text_asset = ResPath.GetCoupleHomeImg(high_theme_text_asset)
	self.node_list["HighImage"].image:LoadSprite(high_text_bundle, high_text_asset)

	local theme_icon_bundle, theme_icon_asset = ResPath.GetRawImage("couple_theme_" .. theme_type)
	self.node_list["ClickIcon"].raw_image:LoadSprite(theme_icon_bundle, theme_icon_asset)
end