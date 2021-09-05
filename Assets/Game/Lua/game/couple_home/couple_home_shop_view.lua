CoupleHomeShopContentView = CoupleHomeShopContentView or BaseClass(BaseRender)

function CoupleHomeShopContentView:__init()
	self.click_theme_cell_call_back = BindTool.Bind(self.ClickThemeCellCallBack, self)
	self.click_furniture_cell_call_back = BindTool.Bind(self.ClickFurnitureCellCallBack, self)

	self.select_theme_client_index = 1
	self.select_furniture_client_index = 1

	self.input = self.node_list["Input"]

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])

	self.node_list["Sub"].button:AddClickListener(BindTool.Bind(self.ClickSub, self))
	self.node_list["Add"].button:AddClickListener(BindTool.Bind(self.ClickAdd, self))
	self.node_list["ClickInput"].button:AddClickListener(BindTool.Bind(self.ClickInput, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.ClickBuy, self))

	self.theme_cell_list = {}
	self.theme_data = CoupleHomeHomeData.Instance:GetSpecialThemeCfg()
	self.theme_list = self.node_list["ThemeList"]
	local scroller_delegate = self.theme_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.ThemeNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.ThemeCellRefresh, self)

	self.furniture_cell_list = {}
	self.furniture_data = {}
	self.furniture_list = self.node_list["FurnitureList"]
	scroller_delegate = self.furniture_list.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.FurnitureNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.FurnitureCellRefresh, self)
	self:InitView()
end

function CoupleHomeShopContentView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for k, v in pairs(self.theme_cell_list) do
		v:DeleteMe()
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	
	self.theme_cell_list = nil

	for k, v in pairs(self.furniture_cell_list) do
		v:DeleteMe()
	end
	self.furniture_cell_list = nil
	self.fight_text = nil
end

function CoupleHomeShopContentView:ClickSub()
	local count = tonumber(self.input.input_field.text) or 0
	if count > 1 then
		count = count - 1
	end

	self.input.input_field.text = count
	self:FlushTotalCost()
end

function CoupleHomeShopContentView:ClickAdd()
	local count = tonumber(self.input.input_field.text) or 0
	if count < 999 then
		count = count + 1
	end

	self.input.input_field.text = count
	self:FlushTotalCost()
end

function CoupleHomeShopContentView:ClickInput()
	local function input_end(str)
		local count = tonumber(str)
		if count <= 0 then
			count = 1
		end

		self.input.input_field.text = count
		self:FlushTotalCost()
	end

	TipsCtrl.Instance:OpenCommonInputView(nil, input_end)
end

function CoupleHomeShopContentView:ClickBuy()
	local furniture_data = self.furniture_data[self.select_furniture_client_index]
	if furniture_data == nil then
		return
	end

	local item_id = furniture_data.item_id

	local count = tonumber(self.input.input_field.text) or 0
	local count_str = ToColorStr(count, TEXT_COLOR.YELLOW) .. Language.Common.UnitName[1]

	local total_cost = furniture_data.need_gold * count
	local total_cost_str = ToColorStr(total_cost, TEXT_COLOR.YELLOW)

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local item_name = ""
	if item_cfg then
		local item_color = ITEM_COLOR[item_cfg.color]
		item_name = ToColorStr(item_cfg.name, item_color)
	end

	local function ok_callback()
		CoupleHomeHomeCtrl.Instance:SendSpouseHomeOperaReq(CS_SPOUSE_HOME_TYPE.CS_SPOUSE_HOME_TYPE_BUY_FURNITURE_ITEM, item_id, count)
	end

	local des = string.format(Language.Common.BuyItemByGoldDes, total_cost_str, count_str .. item_name)
	TipsCtrl.Instance:ShowCommonAutoView("couple_home_shop", des, ok_callback)
end

function CoupleHomeShopContentView:ClickThemeCellCallBack(cell)
	cell:SetToggleIsOn(true)

	local index = cell:GetIndex()
	if index == self.select_theme_client_index then
		return
	end
	self.select_theme_client_index = index
	self.select_furniture_client_index = 1
	self.input.input_field.text = 1

	self:FlushFurnitureList()
	self:FlushRightContent()
end

function CoupleHomeShopContentView:ThemeNumberOfCell()
	return #self.theme_data
end

function CoupleHomeShopContentView:ThemeCellRefresh(cell, data_index)
	data_index = data_index + 1
	local theme_cell = self.theme_cell_list[cell]
	if theme_cell == nil then
		theme_cell = ShopThemeCell.New(cell.gameObject)
		theme_cell:SetClickCallBack(self.click_theme_cell_call_back)
		theme_cell:SetToggleGroup(self.theme_list.toggle_group)
		self.theme_cell_list[cell] = theme_cell
	end

	theme_cell:SetIndex(data_index)
	theme_cell:SetData(self.theme_data[data_index])
	theme_cell:SetToggleIsOn(self.select_theme_client_index == data_index)
end

function CoupleHomeShopContentView:ClickFurnitureCellCallBack(cell)
	cell:SetToggleIsOn(true)

	local index = cell:GetIndex()
	if index == self.select_furniture_client_index then
		return
	end
	self.select_furniture_client_index = index
	self.input.input_field.text = 1

	self:FlushRightContent()
end

function CoupleHomeShopContentView:FurnitureNumberOfCell()
	return #self.furniture_data
end

function CoupleHomeShopContentView:FurnitureCellRefresh(data_index, cell)
	data_index = data_index + 1
	local furniture_cell = self.furniture_cell_list[cell]
	if furniture_cell == nil then
		furniture_cell = ShopFurnitureCell.New(cell)
		furniture_cell:SetClickCallBack(self.click_furniture_cell_call_back)
		furniture_cell:SetToggleGroup(self.furniture_list.toggle_group)
		self.furniture_cell_list[cell] = furniture_cell
	end

	furniture_cell:SetIndex(data_index)
	furniture_cell:SetData(self.furniture_data[data_index])
	furniture_cell:SetToggleIsOn(self.select_furniture_client_index == data_index)
end

--界面隐藏时调用
function CoupleHomeShopContentView:CloseView()

end

--界面显示时调用
function CoupleHomeShopContentView:InitView()
	self.select_theme_client_index = 1
	self.select_furniture_client_index = 1
	self.input.input_field.text = 1

	self:FlushThemeList()
	self:FlushFurnitureList()
	self:FlushRightContent()
end

--刷新主题列表
function CoupleHomeShopContentView:FlushThemeList()
	self.theme_list.scroller:ReloadData(0)
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE) then
		self.node_list["TextActivity"]:SetActive(true)
		local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if open_server_day <= 3 then
			self.node_list["TextActivity"].text.text = Language.CoupleHome.KaifuBuyJiaJu
		else
			self.node_list["TextActivity"].text.text = Language.CoupleHome.NormalBuyJiaJu
		end
	else
		self.node_list["TextActivity"]:SetActive(false)
	end
end

--刷新家具列表
function CoupleHomeShopContentView:FlushFurnitureList()
	local theme_data = self.theme_data[self.select_theme_client_index]
	if theme_data then
		local theme_type = theme_data.theme_type
		local shop_list = CoupleHomeShopData.Instance:GetShopInfoByThemeType(theme_type)
		self.furniture_data = shop_list or {}
	end

	self.furniture_list.list_view:Reload(function()
		self.furniture_list.list_view:JumpToIndex(0)
	end)
end

function CoupleHomeShopContentView:FlushRightContent()
	local furniture_data = self.furniture_data[self.select_furniture_client_index]
	if furniture_data == nil then
		return
	end

	local item_id = furniture_data.item_id

	self.item_cell:SetData({item_id = item_id})

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local item_name = ""
	if item_cfg then
		local item_color = ITEM_COLOR[item_cfg.color]
		item_name = ToColorStr(item_cfg.name, item_color)
	end
	self.node_list["ItemName"].text.text = item_name

	local item_list = CoupleHomeHomeData.Instance:GetFurnitureItemListById(item_id)
	if item_list then
		local item_info = item_list[1]
		self.node_list["HpAttr"].text.text = Language.CoupleHome.hp .. item_info.maxhp
		self.node_list["GongJiAttr"].text.text = Language.CoupleHome.gongji .. item_info.gongji
		self.node_list["FangYuAttr"].text.text = Language.CoupleHome.fangyu .. item_info.fangyu

		local power = CommonDataManager.GetCapabilityCalculation(item_info)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	end

	local single_cost = furniture_data.need_gold
	self.node_list["SingleText"].text.text = single_cost

	self:FlushTotalCost()
end

function CoupleHomeShopContentView:FlushTotalCost()
	local furniture_data = self.furniture_data[self.select_furniture_client_index]
	if furniture_data == nil then
		return
	end

	local single_cost = furniture_data.need_gold
	local count = tonumber(self.input.input_field.text) or 0
	local total_cost = count * single_cost
	self.node_list["TotalText"].text.text = total_cost
end

function CoupleHomeShopContentView:OnFlush(param_t)
	self:FlushThemeList()
	self:FlushFurnitureList()

	--刷新时间
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushActNextTime, self), 1)
		self:FlushActNextTime()
	end
end

function CoupleHomeShopContentView:FlushActNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DISCOUNT_BUY_FURNITURE)
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

-----------------------ShopThemeCell-------------------------
ShopThemeCell = ShopThemeCell or BaseClass(BaseCell)
function ShopThemeCell:__init()
	self.node_list["ShopThemeCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShopThemeCell:__delete()
	
end

function ShopThemeCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShopThemeCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function ShopThemeCell:OnFlush()
	if self.data == nil then
		return
	end

	local theme_name = Language.CoupleHome.ThemeType[self.data.theme_type] or ""
	self.node_list["NormalText"].text.text = theme_name
	self.node_list["SpecialText"].text.text = theme_name
end

-----------------------ShopFurnitureCell-------------------------
ShopFurnitureCell = ShopFurnitureCell or BaseClass(BaseCell)
function ShopFurnitureCell:__init()
	self.content = self.node_list["Content"]
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(BindTool.Bind(self.ItemClick, self))

	self.node_list["Content"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShopFurnitureCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShopFurnitureCell:SetToggleGroup(group)
	self.content.toggle.group = group
end

function ShopFurnitureCell:SetToggleIsOn(is_on)
	self.content.toggle.isOn = is_on
end

function ShopFurnitureCell:ItemClick()
	if self.data == nil then
		return
	end

	local data = {item_id = self.data.item_id}
	local function close_call_back()
		if self.item_cell then
			self.item_cell:SetHighLight(false)
		end
	end
	TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)

	self:OnClick()
end

function ShopFurnitureCell:OnFlush()
	if self.data == nil then
		return
	end

	-- local coin_bundle, coin_asset = ResPath.GetImages("diamon")
	-- self.node_list["CoinImage"].image:LoadSprite(coin_bundle, coin_asset)
	self.node_list["CostText"].text.text = self.data.need_gold

	local item_id = self.data.item_id
	self.item_cell:SetData({item_id = item_id})

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return
	end

	local color = ITEM_COLOR[item_cfg.color]
	local name = ToColorStr(item_cfg.name, color)
	self.node_list["Name"].text.text = name
end