--衣柜兑换
ClothespressExchangeView = ClothespressExchangeView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 16			-- 最大格子数
local BAG_PAGE_NUM = 1					-- 页数
local BAG_PAGE_COUNT = 16				-- 每页个数
local BAG_ROW = 4						-- 行数
local BAG_COLUMN = 4					-- 列数

local MODLE_STATE = {
	NONE = 0,
	MOUNT_STATE = 1,
	FIGHT_MOUNT_STATE = 2,
	MULTI_MOUNT_STATE = 3,
	STAND_STATE = 4,
}

local DISPLAY_CAMERA_SETTING = {
	[0] = {position = Vector3(0, 1.55, 5.38), rotation = Quaternion.Euler(0, 180, 0)},
	[1] = {position = Vector3(0, 2.70, 7.62), rotation = Quaternion.Euler(0, 180, 0)},
	[2] = {position = Vector3(0, 1.90, 6.60), rotation = Quaternion.Euler(0, 180, 0)},
	[3] = {position = Vector3(0, 2.55, 13.2), rotation = Quaternion.Euler(0, 180, 0)},
	[4] = {position = Vector3(0, 1.55, 4.88), rotation = Quaternion.Euler(0, 180, 0)},
}

function ClothespressExchangeView:__init()
	self.first_load = true
	self.stuff_id = ClothespressData.Instance:GetExchangeNeedMaterials()
	self.select_index = ClothespressData.Instance:GetSelectSuitIndex()
	self.suit_cell_list = {}
	self.suit_part_cell_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}

	self:InitList()
	self:FlushStuffNum()

	self.node_list["ButtonSuitAttr"].button:AddClickListener(BindTool.Bind(self.ClickAttr, self))
	self.node_list["StuffImage"].button:AddClickListener(BindTool.Bind(self.IconClickListener, self))

	-- self.node_list["BtnOpenShop"].button:AddClickListener(BindTool.Bind(self.ClickOpenShop, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFight"])

	self.bag_cell = {}
	local list_delegate = self.node_list["BagListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	
	self.node_list["BagListView"].list_view:Reload()

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ClothespressExchangeView:__delete()
	for k,v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	for k,v in pairs(self.suit_part_cell_list) do
		v:DeleteMe()
	end
	self.suit_part_cell_list = {}

	if self.weiyan_timer_quest then
		GlobalTimerQuest:CancelQuest(self.weiyan_timer_quest)
		self.weiyan_timer_quest = nil
	end

	self.role_display = nil
	self.suit_list = nil
	self.suit_part_list = nil
	self.fight_text = nil

	self.suit_data_cfg_list = {}
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function ClothespressExchangeView:IconClickListener()
	TipsCtrl.Instance:OpenItem({item_id = self.stuff_id})
end

function ClothespressExchangeView:CloseCallBack()
	self.first_load = true
end
	
function ClothespressExchangeView:OnFlush(param_t)
	self.modle_info_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}
	self.stuff_id = ClothespressData.Instance:GetExchangeNeedMaterials()

	self:FlushSuitPartList()
	self.cur_suit_index = -1
	self:GetAllSuitDataList()
	self.select_index = ClothespressData.Instance:GetSelectSuitIndex()

	self:GetCurSuitIndex()
	self:FlushRightContent()
	self:FlushAllHighLight()
	self:FlushSuitItemHL()
	self:GetStuffImage()
end

--初始化list
function ClothespressExchangeView:InitList()
	for i = 1, 5 do
		self.suit_part_cell_list[i] = ClothespressExchangePartCell.New(self.node_list["ExchangeSuitPartItem" .. i])
		self.suit_part_cell_list[i]:SetClickCallBack(BindTool.Bind(self.OnClickCallBack, self))
		local data = self.single_suit_all_part_cfg and self.single_suit_all_part_cfg[i]
		self.suit_part_cell_list[i]:SetIndex(i)
		self.suit_part_cell_list[i]:SetStuffId(self.stuff_id)
		self.suit_part_cell_list[i]:SetSelectIndex(self.select_index)
		self.suit_part_cell_list[i]:SetData(data)
	end
end

function ClothespressExchangeView:SetClickCallBack(click_callback)
	self.scene_click_callback = click_callback
end

--套装Item点击回调
function ClothespressExchangeView:OnClickCallBack(index)
	local index = index or 0
	local last_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	if index == last_index then return end

	ClothespressData.Instance:SetSelectSuitItemIndex(index)

	if self.scene_click_callback then
		self.scene_click_callback(self.select_index, index)
	end

	self:FlushSuitItemHL()
end

function ClothespressExchangeView:FlushSuitItemHL()
	local select_item_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	for k, v in pairs(self.suit_part_cell_list) do
		if v:GetIndex() == select_item_index then
			v:ShowHighLight(true)
		else
			v:ShowHighLight(false)
		end
	end

	local data = self.single_suit_all_part_cfg and self.single_suit_all_part_cfg[select_item_index]
	if data and self.fight_text and self.fight_text.text then
		local power = ItemData.Instance:SetFightPower(data.img_item_id)
		self.fight_text.text.text = power or 0
	end
end

--所有套装配置信息
function ClothespressExchangeView:GetAllSuitDataList()
	self.suit_data_cfg_list = ClothespressData.Instance:GetExchangeSuitCfg() or {}
end

--单个套装的部位配置信息
function ClothespressExchangeView:GetSingleSuitAllPartCfg()
	self.single_suit_all_part_cfg = ClothespressData.Instance:SingleSuitCanExchangePartCfgBySuitIndex(self.select_index) or {}
end

--单个套装的激活信息
function ClothespressExchangeView:GetSingleSuitAllPartActiveInfo()
	self.single_suit_all_part_info = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(self.select_index) or {}
end

--当前所选套装的index
function ClothespressExchangeView:GetCurSuitIndex()
	self.cur_suit_index = self.suit_data_cfg_list[self.select_index] and self.suit_data_cfg_list[self.select_index].suit_index + 1 or 0
end

----------------------------
------ 背包List
function ClothespressExchangeView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ClothespressExchangeView:BagRefreshCell(index, cellObj)
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = SuitExchangeItemRenderer.New(cellObj)
		cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self, cell))
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN + cur_colunm + page * BAG_ROW * BAG_COLUMN
	-- 获取数据信息
	local cfg_list = self.suit_data_cfg_list[grid_index]
	local data = {}
	if cfg_list then
		data.item_id = cfg_list.suit_image_id or 0
		data.name = cfg_list.suit_name or ""
	end

	cell:SetIndex(grid_index)
	cell:SetData(data)
	cell:ShowHighLight(grid_index == self.select_index)
end

--套装Item点击回调
function ClothespressExchangeView:OnClickCellCallBack(cell)
	if cell:GetData() == nil or next(cell:GetData()) == nil then return end

	local index = cell:GetIndex()
	if index == nil then return end
	if self.select_index == index then 
		self:FlushAllHighLight()
		return 
	end

	self.select_index = index
	ClothespressData.Instance:SetSelectSuitItemIndex(1)
	ClothespressData.Instance:SetSelectSuitIndex(index)

	self:FlushRightContent()
	self:FlushSuitItemHL()
	self:GetCurSuitIndex()
	self:FlushAllHighLight()

	if self.scene_click_callback then
		self.scene_click_callback(self.select_index, 1)
	end
end

--刷新高亮
function ClothespressExchangeView:FlushAllHighLight()
	if nil == self.select_index or self.bag_cell == nil then
		return
	end

	for k,v in pairs(self.bag_cell) do
		local index = v:GetIndex()
		v:ShowHighLight(index == self.select_index)
	end
end

--刷新右侧
function ClothespressExchangeView:FlushRightContent()
	self.switch_state = MODLE_STATE.NONE
	self:FlushSuitPartList()
	self:FlushSuitDesc()
end

function ClothespressExchangeView:ItemDataChangeCallback(item_id)
	if item_id == self.stuff_id then
		self:FlushStuffNum()
	end
end

--刷新材料数量
function ClothespressExchangeView:FlushStuffNum()
	if nil == self.stuff_id and self.stuff_id == 0 then
		return
	end
	local stuff_num = ItemData.Instance:GetItemNumInBagById(self.stuff_id)
	self.node_list["StuffNum"].text.text = stuff_num

	self:FlushSuitPartList()
end

--设置材料icon
function ClothespressExchangeView:GetStuffImage()
	if nil == self.stuff_id and self.stuff_id == 0 then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.stuff_id)
	if nil == item_cfg then
		return
	end
	self.node_list["StuffImage"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
end

--刷新套装描述
function ClothespressExchangeView:FlushSuitDesc()
	-- local str = self.suit_data_cfg_list[self.select_index] and self.suit_data_cfg_list[self.select_index].suit_effect or ""
	-- local str_1 = self.suit_data_cfg_list[self.select_index] and self.suit_data_cfg_list[self.select_index].suit_effect2
	-- if str_1 ~= "" then
	-- 	-- self.node_list["ShowDesc"]:SetActive(true)
	-- 	self.node_list["SingleSuitDesc2"].text.text = str_1
	-- else
	-- 	self.node_list["ShowDesc"]:SetActive(false)
	-- end
	-- self.node_list["SingleSuitDesc1"].text.text = str
	local data_list = ClothespressData.Instance:GetSuitAttrDataListBySuitIndex(self.select_index)
	local active_part_num = data_list.active_part_num or 0
	local suit_power = 0
	if data_list and data_list.suit_attr then
		for k, v in pairs(data_list.suit_attr) do
			if active_part_num >= v.img_count_min then
				local cur_suit_attr = CommonDataManager.GetRolePercentAttr(v)
				local cur_power = CommonDataManager.GetCapability(cur_suit_attr)
				suit_power = suit_power + cur_power
			end
		end
	end

	self.node_list["SuitCap"].text.text = string.format(Language.Common.GaoZhanLi, suit_power)
	self.node_list["SuitCapBg"]:SetActive(suit_power > 0)
	self.node_list["GaoPer"]:SetActive(suit_power <= 0)
end

--刷新套装部位显示
function ClothespressExchangeView:FlushSuitPartList()
	self:GetSingleSuitAllPartCfg()
	self:GetSingleSuitAllPartActiveInfo()
	-- self.suit_part_list.scroller:ReloadData(0)

	for k,v in pairs(self.suit_part_cell_list) do
		if v and self.single_suit_all_part_cfg then
			local data = self.single_suit_all_part_cfg[k]
			v:SetIndex(k)
			v:SetStuffId(self.stuff_id)
			v:SetSelectIndex(self.select_index)
			v:SetActFlag(self.single_suit_all_part_info[k])
			v:SetData(data)
		end
	end
end

--套装属性
function ClothespressExchangeView:ClickAttr()
	ClothespressCtrl.Instance:ShowSuitAttrTipView(self.cur_suit_index)
end

--跳转商店-常用
function ClothespressExchangeView:ClickOpenShop()
	--ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_baoshi)
	local func = function(item_id, no_func, need_num, is_spec)
		MarketCtrl.Instance:SendShopBuy(item_id, no_func, need_num, is_spec)
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_id, nil, 1, true)
end

-----------------------------------套装Item----------------------------------
ClothespressExchangeCell = ClothespressExchangeCell or BaseClass(BaseCell)

function ClothespressExchangeCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
	self.node_list["SuitItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ClothespressExchangeCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ClothespressExchangeCell:SetData(data)
	self.data = data
	self:Flush()
end

function ClothespressExchangeCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ClothespressExchangeCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ClothespressExchangeCell:OnFlush()
	if nil == self.data or nil == self.data.suit_index then
		return
	end

	local name = self.data.suit_name or ""
	self.node_list["Name"].text.text = name

	local data_item_id = self.data.suit_image_id or 0
	self.item_cell:SetData({item_id = data_item_id, is_bind = 0})
end
--------------------------------套装cell结束-------------------------------------

---------------------------------套装部位cell------------------------------------
ClothespressExchangePartCell = ClothespressExchangePartCell or BaseClass(BaseCell)

function ClothespressExchangePartCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickExchange, self))
	self.item_cell:SetBackground(false)
	self.item_cell.root_node.rect.sizeDelta = Vector2(96, 96)

	-- self.node_list["BtrExchange"].button:AddClickListener(BindTool.Bind(self.ClickExchange, self))
end

function ClothespressExchangePartCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.active_flag = nil
end

function ClothespressExchangePartCell:SetData(data)
	self.data = data
	self:Flush()
end

function ClothespressExchangePartCell:SetActFlag(active_flag)
	self.active_flag = active_flag
end

function ClothespressExchangePartCell:SetStuffId(stuff_id)
	self.stuff_id = stuff_id
end

function ClothespressExchangePartCell:OnFlush()
	if nil == self.data then
		return
	end

	local data_item_id = self.data.img_item_id or 0
	self.item_cell:SetData({item_id = data_item_id, is_bind = 0})
	if nil == self.stuff_id then
		return
	end

	-- local is_active = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(self.select_index)[self.index]
	-- self.node_list["IsShow"]:SetActive(is_active == 1)

	local need_num = self.data.need_exchange_ticket_num or 0
	-- local is_enough = ItemData.Instance:GetItemNumIsEnough(self.stuff_id, need_num)
	-- local color = not is_enough and TEXT_COLOR.RED or TEXT_COLOR.WHITE
	-- self.node_list["StuffNeedNum"].text.text = ToColorStr(need_num, color)
	self.node_list["StuffNeedNum"].text.text = need_num

	local item_cfg = ItemData.Instance:GetItemConfig(self.stuff_id)
	if nil == item_cfg then
		return
	end 

	local active_flag = self.active_flag or 0
	self.item_cell:ShowQuality(active_flag ~= 0)
	self.item_cell:SetIconGrayScale(active_flag == 0)
	UI:SetGraphicGrey(self.node_list["Image"], active_flag == 0)

	self.node_list["StuffImage"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
end

function ClothespressExchangePartCell:ClickExchange()
	if nil == self.data or nil == self.stuff_id then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.stuff_id)
	local part_cfg = ItemData.Instance:GetItemConfig(self.data.img_item_id)
	if nil == item_cfg or nil == part_cfg then
		return
	end

	local need_num = self.data.need_exchange_ticket_num or 0
	local is_enough = ItemData.Instance:GetItemNumIsEnough(self.stuff_id, need_num)
	local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
	local materials_name = item_cfg.name or ""
	local materials_name_str = ToColorStr(materials_name, color)

	if self.click_callback then
		self.click_callback(self.index)
	end

	if not is_enough then
		local str = string.format(Language.Clothespress.NotEnough, materials_name_str)
		SysMsgCtrl.Instance:ErrorRemind(str)
		return
	end

	local function ok_callback()
		local suit_index = self.data.suit_index
		local sub_index = self.data.sub_index
		ClothespressCtrl.Instance:SendDressingRoomExchangeOpera(suit_index, sub_index)
	end

	local part_color = part_cfg.color and ITEM_COLOR[part_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
	local part_name = part_cfg.name or ""
	local part_name_str = ToColorStr(part_name, part_color)

	local des = string.format(Language.Clothespress.Exchange, need_num, materials_name, part_name_str)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function ClothespressExchangePartCell:SetSelectIndex(select_index)
	self.select_index = select_index
end

function ClothespressExchangePartCell:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function ClothespressExchangePartCell:ShowHighLight(enable)
	local bundle, asset = "uis/views/clothespress/images_atlas", "item_nor_bg"
	if enable then
		bundle, asset = "uis/views/clothespress/images_atlas", "item_pre_bg"
	end
	self.node_list["Image"].image:LoadSprite(bundle, asset, function()
		self.node_list["Image"].image:SetNativeSize()
	end)
end
--------------------------------套装部位cell结束----------------------------------


------------------------------
----------SuitExchangeItemRenderer
SuitExchangeItemRenderer = SuitExchangeItemRenderer or BaseClass(BaseCell)
function SuitExchangeItemRenderer:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickCellCallBack, self))
end

function SuitExchangeItemRenderer:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SuitExchangeItemRenderer:OnClickCellCallBack()
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function SuitExchangeItemRenderer:OnFlush()
	if not self.data or not self.data.item_id then
		self.item_cell:SetData()
		self.node_list["Name"].text.text = ""
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then
		self.item_cell:SetData()
		self.node_list["Name"].text.text = ""
		return	
	end

	self.item_cell:SetData(self.data)
	self.node_list["Name"].text.text = self.data.name
end

function SuitExchangeItemRenderer:ShowHighLight(enable)
	self.item_cell:ShowHighLight(enable)
end