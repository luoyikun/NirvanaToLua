MarketBuyView = MarketBuyView or BaseClass(BaseRender)

local NUMBER = 5  -- 每页显示的数量

function MarketBuyView:__init(instance)
	self.color_list = {
		GameEnum.ITEM_COLOR_GREEN,
		GameEnum.ITEM_COLOR_BLUE,
		GameEnum.ITEM_COLOR_PURPLE,
		GameEnum.ITEM_COLOR_ORANGE,
		GameEnum.ITEM_COLOR_RED,
	}
	self.info_list = {}
	self.variables = {}
	self.item_cell = {}

	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self:InitView()
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))
	self.node_list["BtnSearch"].button:AddClickListener(BindTool.Bind(self.OnSearch, self))
	self.node_list["BtnPageUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["BtnPageDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
	self.node_list["Btncondition1"].button:AddClickListener(BindTool.Bind(self.OpenConditonList1, self))
	self.node_list["Btncondition2"].button:AddClickListener(BindTool.Bind(self.OpenConditonList2, self))
	self.node_list["BtnConditionItem1"].toggle:AddClickListener(BindTool.Bind(self.ClickAllOrder, self))
	self.node_list["BtnConditionItem2"].toggle:AddClickListener(BindTool.Bind(self.ClickAllColor, self))

	self.sale_item_list_market = {}
	self.total_page = 0
	self.current_page = 0
	self.info_count = 0
	self:CreateParentList()
	self:CreateGradeList()
	self:CreateColorList()
	self.parent_cell_list = {}
	self.child_cell_list = {}
	self.grade_cell_list = {}
	self.color_cell_list = {}
	self.father_id = 0
	self.child_id = 0
	self.color = 0
	self.order = 0
	self.is_equipment = 0
	self.left_index = 0
end

function MarketBuyView:__delete()
	for k,v in pairs(self.parent_cell_list) do
		v:DeleteMe()
	end
	self.parent_cell_list = {}
	for k,v in pairs(self.child_cell_list) do
		v:DeleteMe()
	end
	self.child_cell_list = {}
	for k,v in pairs(self.grade_cell_list) do
		v:DeleteMe()
	end
	self.grade_cell_list = {}
	for k,v in pairs(self.color_cell_list) do
		v:DeleteMe()
	end
	self.color_cell_list = {}

	for k,v in pairs(self.item_cell) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_cell = {}
end

function MarketBuyView:InitView()
	self.node_list["TxtNoSearch"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.node_list["ListScreenObj"]:SetActive(false)
	for i = 1, NUMBER do
		self.info_list[i] = self.node_list["Info" .. i]
		local obj = self.info_list[i]:GetComponent(typeof(UINameTable)):Find("ItemCell")
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetFromView(TipsFormDef.FROME_MARKET_GOUMAI)
		self.item_cell[i]:SetInstanceParent(U3DObject(obj))

		local name_table = self.info_list[i]:GetComponent(typeof(UINameTable))
		self.variables[i] = {}
		self.variables[i].count = U3DObject(name_table:Find("TxtCount"))
		self.variables[i].name = U3DObject(name_table:Find("TxtName"))
		self.variables[i].price = U3DObject(name_table:Find("TxtUnitPrice"))
		self.variables[i].total_price = U3DObject(name_table:Find("TxtTotalPrice"))
		self.node_list["Info" .. i].toggle:AddClickListener(function() self:ShowDetails(i) end)
	end
end

function MarketBuyView:CreateParentList()
	local parent_group = self.node_list["MarketTypeList"]:GetComponent("ToggleGroup")
	local list_delegate = self.node_list["MarketTypeList"].list_simple_delegate
	local need_auto_select = true
	list_delegate.NumberOfCellsDel = function ()
		return #MarketData.Instance:GetMarketParentConfig()
	end
	list_delegate.CellRefreshDel = function(cell, data_index)
		local cell_item = self.parent_cell_list[cell]
		if cell_item == nil then
			cell_item = ParentListCell.New(cell.gameObject)
			self.parent_cell_list[cell] = cell_item
		end
		local data_list = MarketData.Instance:GetMarketParentConfig()
		local data = data_list[data_index + 1]
		cell_item:SetData(data)
		cell_item:SetToggleGroup(parent_group)
		if need_auto_select and data_index == 0 then
			cell_item:SetToggle(true)
			need_auto_select = false
		end
		cell_item:SetToggle(data_index == self.left_index)
		cell_item:ListenClick(BindTool.Bind(self.OnClickParentCell, self, data, data_index))
	end
end

function MarketBuyView:OnClickParentCell(data, data_index)
	self.left_index = data_index
	MarketCtrl.Instance:SendSaleTypeCountReq()
	self.node_list["ListScreenQua"]:SetActive(false)
	self.node_list["ListScreenObj"]:SetActive(false)

	self.node_list["PanelKindsContent"]:SetActive(true)
	self.node_list["PanelDetailContent"]:SetActive(false)
	self.father_id = data.parent_cfg.father_id
	self.child_id = 0
	self.is_equipment = 0
	self:SetSearchType(0)
	if self.father_id == 0 then
		self:SetSearchColor(0)
		self:SetSearchOrder(0)
		self.node_list["PanelKindsContent"]:SetActive(false)
		self.node_list["PanelDetailContent"]:SetActive(true)
		self:OnSearch(0)
	else
		self:CreateChildList()
		if self.node_list["KindsList"].scroller.isActiveAndEnabled then
			self.node_list["KindsList"].scroller:ReloadData(0)
		end
	end
end

function MarketBuyView:CreateChildList()
	local list_delegate = self.node_list["KindsList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return math.ceil(#MarketData.Instance:GetMarketChildConfig(self.father_id) / 3)
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.child_cell_list[cell]
		if cell_item == nil then
			cell_item = ChildListCell.New(cell.gameObject)
			self.child_cell_list[cell] = cell_item
		end
		local data_list = MarketData.Instance:GetMarketChildConfig(self.father_id)
		local data = {data_list[data_index * 3 + 1], data_list[data_index * 3 + 2], data_list[data_index * 3 + 3], }
		cell_item:SetData(data)
		cell_item:ListenClick(BindTool.Bind(self.OnClickChildCell, self))
	end
end

function MarketBuyView:FlushListData()
	if self.node_list["KindsList"] then
		self.node_list["KindsList"].scroller:ReloadData(0)
	end
end

function MarketBuyView:OnClickChildCell(data)
	self:SetSearchColor(0)
	self:SetSearchOrder(0)
	self.child_id = data.child_id
	self.is_equipment = data.is_equipment
	self:SetSearchType(self.child_id)
	self:OnSearch(1)
	self.node_list["PanelKindsContent"]:SetActive(false)
	self.node_list["PanelDetailContent"]:SetActive(true)
end

function MarketBuyView:CreateGradeList()
	local list_delegate = self.node_list["ConditionList1"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 10
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.grade_cell_list[cell]
		if cell_item == nil then
			cell_item = OrderListCell.New(cell.gameObject)
			self.grade_cell_list[cell] = cell_item
		end
		cell_item:SetData(data_index + 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickGradeCell, self, data_index + 1))
	end
end

function MarketBuyView:OnClickGradeCell(order)
	self.order = order
	self:SetSearchOrder(order)
	self:OnSearch(0)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
end

function MarketBuyView:ClickAllOrder()
	self.order = 0
	self:SetSearchOrder(0)
	self:OnSearch(0)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
end

function MarketBuyView:CreateColorList()
	local list_delegate = self.node_list["ConditionList2"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return 6
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.color_cell_list[cell]
		if cell_item == nil then
			cell_item = ColorListCell.New(cell.gameObject)
			self.color_cell_list[cell] = cell_item
		end
		cell_item:SetData(data_index + 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickColorCell, self, data_index + 1))
	end
end

function MarketBuyView:OnClickColorCell(color)
	self.color = color
	self:SetSearchColor(color)
	self:OnSearch(0)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
end

function MarketBuyView:ClickAllColor()
	self.color = 0
	self:SetSearchColor(0)
	self:OnSearch(0)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
end

-- 搜索
function MarketBuyView:OnSearch(flag)
	local search_config = MarketData.Instance:GetSearchConfig()
	if not search_config then return end

	search_config.req_page = 1
	search_config.total_page = 0
	if flag then
		search_config.level = 0
		search_config.prof = 0
		search_config.color_interval = 0
		search_config.fuzzy_type_count = 0
		search_config.fuzzy_type_list = {}
	else
		local fuzzy_type_list, has_input = self:GetFuzzyList()
		search_config.fuzzy_type_list = fuzzy_type_list
		search_config.fuzzy_type_count = #fuzzy_type_list
		local color = 0
		for i = 1, 5 do
			if self.node_list["Toggle" .. i].toggle.isOn then
				color = self.color_list[i]
				break
			end
		end
		search_config.color = color
	end
	if search_config.fuzzy_type_count == 0 and flag ~= 0 and has_input then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.SelectEmpty)
		self:CloseSearchWindow()
		MarketData.Instance:SetCurPage(1)
		MarketData.Instance:SetTotalPage(0)
		MarketData.Instance:SetSaleitemListMarket({})
		self:Flush()
	else
		MarketCtrl.Instance:SendPublicSaleSearchReq(flag)
	end
end

function MarketBuyView:Flush()
	self:FlushListData()
	self.sale_item_list_market = MarketData.Instance:GetSaleitemListMarket() or {}
	self:FlushPageCount()
	self:FlushPage(self.current_page)
	local search_config = MarketData.Instance:GetSearchConfig()
	self.node_list["Btncondition1"]:SetActive(not next(search_config.fuzzy_type_list) and self.is_equipment == 1)
	self.node_list["Btncondition2"]:SetActive(not next(search_config.fuzzy_type_list))

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local gold = vo.gold
	self.node_list["TxtCoin"].text.text = CommonDataManager.ConverMoney(gold)
end

-- 更新页面
function MarketBuyView:FlushPage(page)
	self.node_list["TxtPage"].text.text = self.current_page .. "/" .. self.total_page
	self.info_count = #self.sale_item_list_market or 0
	if self.info_count == 0 and page == 1 then
		self.node_list["TxtNoSearch"]:SetActive(true)
	else
		self.node_list["TxtNoSearch"]:SetActive(false)
	end
	if page == self.total_page then  -- 如果是最后一页
		for i = 1, NUMBER do
			if i <= NUMBER - self.info_count then
				self.info_list[NUMBER + 1 - i]:SetActive(false)
			else
				self.info_list[NUMBER + 1 - i]:SetActive(true)
			end
		end
	else
		for i = 1, NUMBER do
			self.info_list[i]:SetActive(true)
		end
	end
	for i = 1, self.info_count do
		self:FlushRow(i)
	end
end

function MarketBuyView:FlushNextMaxNum()
	local count = #self.sale_item_list_market
	local search_config = MarketData.Instance:GetSearchConfig()
	if count == 1 then
		search_config.req_page = math.max(search_config.req_page - 1, 1)
	end
end

-- 更新每一行的信息
function MarketBuyView:FlushRow(index)
	if index > NUMBER then return end
	local info = self.sale_item_list_market[index] or {}
	if info and next(info) then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(info.item_id)
		self.item_cell[index]:SetData(info)
		self.variables[index].count.text.text = "X" .. info.num
		self.variables[index].name.text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color or 0])
		self.variables[index].total_price.text.text = info.gold_price
		local one_price = math.floor(info.gold_price / info.num) >= 1 and math.floor(info.gold_price / info.num) or 1
		self.variables[index].price.text.text = one_price
	else
		self.item_cell[index]:SetData(nil)
	end
end

-- 充值金币
function MarketBuyView:OnClickAdd()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 向上翻页
function MarketBuyView:OnPageUp()
	local search_config = MarketData.Instance:GetSearchConfig()
	if MarketData.Instance:GetTotalPage() < 1 then
		return
	end
	search_config.req_page = math.max(search_config.req_page - 1, 1)
	MarketCtrl.Instance:SendPublicSaleSearchReq()
end

-- 向下翻页
function MarketBuyView:OnPageDown()
	local search_config = MarketData.Instance:GetSearchConfig()
	if(MarketData.Instance:GetTotalPage() < 1) then
		return
	end
	search_config.req_page = math.min(search_config.req_page + 1, MarketData.Instance:GetTotalPage())
	MarketCtrl.Instance:SendPublicSaleSearchReq()
end

function MarketBuyView:OpenConditonList1()
	self.is_show_condition_list1 = not self.is_show_condition_list1
	self.node_list["ListScreenObj"]:SetActive(self.is_show_condition_list1)
end

function MarketBuyView:OpenConditonList2()
	self.is_show_condition_list2 = not self.is_show_condition_list2
	self.node_list["ListScreenQua"]:SetActive(self.is_show_condition_list2)
end

-- 刷新页面数目
function MarketBuyView:FlushPageCount()
	self.current_page = MarketData.Instance:GetCurPage()
	self.total_page = MarketData.Instance:GetTotalPage()
	self.total_page = math.max(self.total_page , 1)
end

-- 显示物品详细信息
function MarketBuyView:ShowDetails(index)
	local info = self.sale_item_list_market[index] or {}
	if info and next(info) then
		local one_price = math.floor(info.gold_price / info.num) >= 1 and math.floor(info.gold_price / info.num) or 1
		info.price = one_price
		local function callback()
			self.info_list[index]:GetComponent("Toggle").isOn = false
		end
		TipsCtrl.Instance:OpenItem(info, TipsFormDef.FROME_MARKET_GOUMAI, {fromIndex = info.sale_index},callback)
	end
end

-- 关闭搜索弹窗
function MarketBuyView:CloseSearchWindow()
	self.node_list["SearchWindow"]:SetActive(false)
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchType(index)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().item_type = index
	self.node_list["InputName"].input_field.text = ""
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchColor(color)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().color = color
	self.node_list["InputName"].input_field.text = ""
	if color == 0 then
		self.node_list["TxtQua"].text.text = Language.Market.ColorDefTxt
	else
		self.node_list["TxtQua"].text.text = Language.Common.ColorName[color]
	end
end

-- 设置搜索物品的类型
function MarketBuyView:SetSearchOrder(order)   -- 0为搜索全部
	MarketData.Instance:GetSearchConfig().order = order
	self.node_list["InputName"].input_field.text = ""
	if order == 0 then
		self.node_list["TxtObj"].text.text = Language.Market.OrderDefTxt
	else
		self.node_list["TxtObj"].text.text = CommonDataManager.GetDaXie(order) .. Language.Common.Jie
	end
end

function MarketBuyView:FlushCurPage()
	self:SetSearchType(self.child_id)
	self:OnSearch(self.child_id == 0 and 0 or 1)
end

-- 获取模糊查找列表
function MarketBuyView:GetFuzzyList()
	local text_input = self.node_list["InputName"].input_field.text
	if "" == text_input then
		return {}, false
	end
	local search_type = MarketData.Instance:GetSearchConfig().item_type
	local all_item_cfg = MarketData.Instance:GetItemAllConfig()
	if not all_item_cfg then return end

	local temp_fuzzy_list = {}
	local temp_fuzzy_count = 0

	for k, v in pairs(all_item_cfg) do
		for item_id, item_cfg in pairs(v) do
			if nil ~= item_cfg.search_type and (0 == search_type or search_type == item_cfg.search_type) and nil ~= string.find(item_cfg.name, text_input) then
				local info = temp_fuzzy_list[item_cfg.search_type]
				if nil == info and temp_fuzzy_count < COMMON_CONSTS.FUZZY_SEARCH_ITEM_TYPE_COUNT then
					info = {
						item_sale_type = item_cfg.search_type,
						item_count = 0,
						item_id_list = {},
					}
					temp_fuzzy_list[item_cfg.search_type] = info
					temp_fuzzy_count = temp_fuzzy_count + 1
				end
				if nil ~= info then
					if info.item_count < COMMON_CONSTS.FUZZY_SEARCH_ITEM_ID_COUNT then
						table.insert(info.item_id_list, item_id)
						info.item_count = info.item_count + 1
					end
				end
			end
		end
	end

	local fuzzy_list = {}
	for k, v in pairs(temp_fuzzy_list) do
		table.sort(v.item_id_list)
		table.insert(fuzzy_list, v)
	end
	return fuzzy_list, true
end


ParentListCell = ParentListCell or BaseClass(BaseCell)
function ParentListCell:__init(instance)

end

function ParentListCell:__delete()

end

function ParentListCell:OnFlush()
	self.node_list["TxtBtn"].text.text = self.data.parent_cfg.father_name
	self.node_list["TxtButton"].text.text = self.data.parent_cfg.father_name
end

function ParentListCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ParentListCell:SetToggle(value)
	self.root_node.toggle.isOn = value
end

function ParentListCell:ListenClick(handler)
	self.node_list["TypeButtonItem"].toggle:AddClickListener(handler)
end


ChildListCell = ChildListCell or BaseClass(BaseCell)
function ChildListCell:__init(instance)
	self.node_list["BtnItem1"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self, 1))
	self.node_list["BtnItem2"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self, 2))
	self.node_list["BtnItem3"].button:AddClickListener(BindTool.Bind(self.OnClickCell, self, 3))
end

function ChildListCell:__delete()

end

function ChildListCell:OnFlush()
	for i = 1, 3 do
		if self.data[i] then
			self.node_list["TxtItem" ..  i].text.text = self.data[i].child_name
			local item_cfg = ItemData.Instance:GetItemConfig(self.data[i].item_id)
				-- 设置图标
			if item_cfg then
				local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
				self.node_list["ImgIcon" .. i].image:LoadSprite(bundle, asset .. ".png")

				local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
				self.node_list["ImgQuality" .. i].image:LoadSprite(bundle1, asset1 .. ".png")

				local item_num = MarketData.Instance:GetCountBySaleType(self.data[i].child_id)
				self.node_list["TxtCell" .. i].text.text = string.format(Language.Market.ItemNum, item_num)
			end
		end
		self.node_list["BtnItem" .. i]:SetActive(self.data[i] ~= nil)
	end
end

function ChildListCell:ListenClick(handler)
	self.handler = handler
end

function ChildListCell:OnClickCell(index)
	if self.data and self.handler then
		self.handler(self.data[index])
	end
end


OrderListCell = OrderListCell or BaseClass(BaseCell)
function OrderListCell:__init(instance)

end

function OrderListCell:__delete()

end

function OrderListCell:OnFlush()
	self.node_list["TxtBtn"].text.text = CommonDataManager.GetDaXie(self.data) .. Language.Common.Jie
end

function OrderListCell:ListenClick(handler)
	self.node_list["ConditionItem"].toggle:AddClickListener(handler)
end


ColorListCell = ColorListCell or BaseClass(BaseCell)
function ColorListCell:__init(instance)

end

function ColorListCell:__delete()

end

function ColorListCell:OnFlush()
	self.node_list["TxtBtn"].text.text = Language.Common.ColorName[self.data]
end

function ColorListCell:ListenClick(handler)
	self.node_list["ConditionItem"].toggle:AddClickListener(handler)
end