--衣柜套装
ClothespressSuitView = ClothespressSuitView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 16				-- 最大格子数
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

function ClothespressSuitView:__init()
	self.suit_cell_list = {}
	self.suit_part_cell_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}
	self.select_index = ClothespressData.Instance:GetSelectSuitIndex()

	self:InitList()
	
	self.node_list["ButtonSuitAttr"].button:AddClickListener(BindTool.Bind(self.ClickAttr, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFight"])

	self.bag_cell = {}
	local list_delegate = self.node_list["BagListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	
	self.node_list["BagListView"].list_view:Reload()
end

function ClothespressSuitView:__delete()
	for k,v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	for k,v in pairs(self.suit_part_cell_list) do
		v:DeleteMe()
	end
	self.suit_part_cell_list = {}

	self.fight_text = nil
	self.suit_list = nil
	self.suit_part_list = nil

	self.suit_data_cfg_list = {}
end

function ClothespressSuitView:CloseCallBack()

end
	
function ClothespressSuitView:OnFlush()
	self.modle_info_list = {}
	self.suit_data_cfg_list = {}
	self.single_suit_all_part_cfg = {}
	self.single_suit_all_part_info = {}

	self:FlushSuitPartList()
	self:GetAllSuitDataList()
	self.select_index = ClothespressData.Instance:GetSelectSuitIndex()
	self:FlushRightContent()
	self:FlushAllHighLight()
	self:FlushSuitItemHL()
end

--初始化list
function ClothespressSuitView:InitList()
	for i = 1, 5 do
		self.suit_part_cell_list[i] = ClothespressSuitPartCell.New(self.node_list["SuitPartItem" .. i])
		local data = self:GetSingleSuitPartData(i)
		self.suit_part_cell_list[i]:SetClickCallBack(BindTool.Bind(self.OnClickCallBack, self))
		self.suit_part_cell_list[i]:SetIndex(i)
		self.suit_part_cell_list[i]:SetData(data)
	end
end

function ClothespressSuitView:SetClickCallBack(click_callback)
	self.scene_click_callback = click_callback
end

--套装Item点击回调
function ClothespressSuitView:OnClickCallBack(index)
	local index = index or 0
	local last_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	if index == last_index then return end

	ClothespressData.Instance:SetSelectSuitItemIndex(index)
	if self.scene_click_callback then
		self.scene_click_callback(self.select_index, index)
	end

	self:FlushSuitItemHL()
end

function ClothespressSuitView:FlushSuitItemHL()
	local select_item_index = ClothespressData.Instance:GetSelectSuitItemIndex()
	for k, v in pairs(self.suit_part_cell_list) do
		if v:GetIndex() == select_item_index then
			v:ShowHighLight(true)
		else
			v:ShowHighLight(false)
			v:SetCurSelectIndex(select_item_index)
		end
	end
	local data = self:GetSingleSuitPartData(select_item_index)
	if data.list and self.fight_text and self.fight_text.text then
		local power = ItemData.Instance:SetFightPower(data.list.img_item_id)
		self.fight_text.text.text = power or 0
	end
end

----------------------------
------ 背包List
function ClothespressSuitView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ClothespressSuitView:BagRefreshCell(index, cellObj)
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = SuitItemRenderer.New(cellObj)
		cell:SetClickCallBack(BindTool.Bind(self.OnClickCellCallBack, self, cell))
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN + 1
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

--所有套装配置信息
function ClothespressSuitView:GetAllSuitDataList()
	self.suit_data_cfg_list = ClothespressData.Instance:GetExchangeSuitCfg() or {}
	-- self.suit_data_cfg_list = ClothespressData.Instance:GetAllSuitCfg() or {}
end

--单个套装的部位配置信息
function ClothespressSuitView:GetSingleSuitAllPartCfg()
	self.single_suit_all_part_cfg = ClothespressData.Instance:GetSingleSuitPartCfgBySuitIndex(self.select_index) or {}
end

--单个套装的激活信息
function ClothespressSuitView:GetSingleSuitAllPartActiveInfo()
	self.single_suit_all_part_info = ClothespressData.Instance:GetSingleSuitPartInfoBySuitIndex(self.select_index) or {}
end

-- --套装Item点击回调
function ClothespressSuitView:OnClickCellCallBack(cell, cell_index)
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
	self:FlushAllHighLight()

	if self.scene_click_callback then
		self.scene_click_callback(self.select_index, 1)
	end
end

--刷新高亮
function ClothespressSuitView:FlushAllHighLight()
	if nil == self.select_index then return end

	for k,v in pairs(self.bag_cell) do
		local index = v:GetIndex()
		v:ShowHighLight(index == self.select_index)
	end
end

--刷新右侧
function ClothespressSuitView:FlushRightContent()
	self.switch_state = MODLE_STATE.NONE
	-- self:GetModleDataList()
	self:FlushSuitPartList()
	self:FlushSuitDesc()
end

--刷新套装描述
function ClothespressSuitView:FlushSuitDesc()
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
function ClothespressSuitView:FlushSuitPartList()
	self:GetSingleSuitAllPartCfg()
	self:GetSingleSuitAllPartActiveInfo()

	for k,v in pairs(self.suit_part_cell_list) do
		local data = self:GetSingleSuitPartData(k) or {}
		if v and next(data) ~= nil then
			v:SetIndex(k)
			v:SetData(data)
		end
	end
	-- self.suit_part_list.scroller:ReloadData(0)
end

--单个套装部位数据
function ClothespressSuitView:GetSingleSuitPartData(data_index)
	local data = {} 
	local list = self.single_suit_all_part_cfg and self.single_suit_all_part_cfg[data_index]
	local active_flag = self.single_suit_all_part_info and self.single_suit_all_part_info[data_index]
	data.list = list or {}
	data.active_flag = active_flag or 0

	return data
end

--套装属性
function ClothespressSuitView:ClickAttr()
	ClothespressCtrl.Instance:ShowSuitAttrTipView(self.select_index)
end

-----------------------------------套装Item----------------------------------
ClothespressSuitCell = ClothespressSuitCell or BaseClass(BaseCell)

function ClothespressSuitCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
	self.node_list["SuitItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ClothespressSuitCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ClothespressSuitCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function ClothespressSuitCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ClothespressSuitCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ClothespressSuitCell:OnFlush()
	if nil == self.data or nil == self.data.suit_index then return end

	local name = self.data.suit_name or ""
	self.node_list["Name"].text.text = name

	local data = {}
	data.item_id = self.data.suit_image_id or 0
	self.item_cell:SetData(data)
end
--------------------------------套装cell结束-------------------------------------

---------------------------------套装部位cell------------------------------------
ClothespressSuitPartCell = ClothespressSuitPartCell or BaseClass(BaseCell)

function ClothespressSuitPartCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))
	self.item_cell.root_node.rect.sizeDelta = Vector2(96, 96)
	self.item_cell:SetIconGrayScale(true)
	self.item_cell:SetBackground(false)
	self.item_cell:OnlyShowQuality(false)
	-- self.item_cell:SetDefualtBgState(false)
	self.select_index = 1
end

function ClothespressSuitPartCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ClothespressSuitPartCell:SetData(data)
	self.data = data
	self:OnFlush()
end

function ClothespressSuitPartCell:OnFlush()
	if nil == next(self.data.list)then return end
	local data_list = self.data.list
	local active_flag = self.data.active_flag or 0

	local data = {}
	data.item_id = data_list.img_item_id or 0
	data.is_bind = 0
	
	self.item_cell:SetData(data)
	self.item_cell:ShowQuality(active_flag ~= 0)
	self.item_cell:SetIconGrayScale(active_flag == 0)
	UI:SetGraphicGrey(self.node_list["Image"], active_flag == 0)
	-- self.item_cell:SetDefualtBgState(false)
end

function ClothespressSuitPartCell:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function ClothespressSuitPartCell:OnClick()
	if self.select_index == self.index then
		-- self.item_cell:OnClickItemCell()
		ViewManager.Instance:Open(ViewName.SuitModelTipView)
		return
	end
	self.select_index = self.index

	if self.click_callback then
		self.click_callback(self.index)
	end
end

function ClothespressSuitPartCell:ShowHighLight(enable)
	local bundle, asset = "uis/views/clothespress/images_atlas", "item_nor_bg"
	if enable then
		bundle, asset = "uis/views/clothespress/images_atlas", "item_pre_bg"
	end
	self.node_list["Image"].image:LoadSprite(bundle, asset, function()
		self.node_list["Image"].image:SetNativeSize()
	end)
end

function ClothespressSuitPartCell:SetCurSelectIndex(index)
	self.select_index = index
end
--------------------------------套装部位cell结束----------------------------------


------------------------------
----------SuitItemRenderer
SuitItemRenderer = SuitItemRenderer or BaseClass(BaseCell)

function SuitItemRenderer:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["Item"])
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickCellCallBack, self))
end

function SuitItemRenderer:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SuitItemRenderer:OnClickCellCallBack()
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function SuitItemRenderer:OnFlush()
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

function SuitItemRenderer:ShowHighLight(enable)
	self.item_cell:ShowHighLight(enable)
end