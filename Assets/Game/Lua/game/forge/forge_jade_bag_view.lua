ForgeJadeBagView = ForgeJadeBagView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 75			-- 最大格子数
local BAG_PAGE_NUM = 3					-- 页数
local BAG_PAGE_COUNT = 25				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 5					-- 列数

function ForgeJadeBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab", "JadeBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function ForgeJadeBagView:__delete()
end

function ForgeJadeBagView:ReleaseCallBack()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	self.select_length = nil

	for k, v in pairs(self.choose_cell_list) do
		v:DeleteMe()
	end
	self.choose_cell_list = {}

	for k, v in pairs(self.convert_cell_list) do
		v:DeleteMe()
	end
	self.convert_cell_list = {}
end

-- open_type 1:玉石背包回收 2：玉石兑换
function ForgeJadeBagView:SetOpenTypeData(open_type)
	if open_type == 1 then
		self.open_type = 1

	elseif open_type == 2 then
		self.open_type = 2

	end

	self:Open()
	self.is_show_condition_list = false
end

function ForgeJadeBagView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Condition"].button:AddClickListener(BindTool.Bind(self.OpenConditonList, self))

	------------------------------
	-- 玉石背包回收
	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.OnClickBolck, self))
	self.node_list["ButtonFenJie"].button:AddClickListener(BindTool.Bind(self.ButtonFenJie, self))

	self.choose_recycle_list = {}

	self.bag_cell = {}
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.is_show_condition_list = false

	self.choose_cell_list = {}
	local choose_list_delegate = self.node_list["ChooseList"].list_simple_delegate
	choose_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetChooseCellNumber, self)
	choose_list_delegate.CellRefreshDel = BindTool.Bind(self.ChooseCellRefresh, self)

	------------------------------
	-- 玉石兑换
	self.jade_convert_cfg = {}

	self.convert_cell_list = {}
	local convert_list_delegate = self.node_list["ConvertListView"].list_simple_delegate
	convert_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetConvertCellNumber, self)
	convert_list_delegate.CellRefreshDel = BindTool.Bind(self.ConvertCellRefresh, self)

end

function ForgeJadeBagView:CloseWindow()
	self:Close()
end

function ForgeJadeBagView:OpenCallBack()
	if self.open_type == 1 then
		self.node_list["Txt"].text.text = Language.Forge.RecycleJade
		self.node_list["Bg"].rect.sizeDelta = Vector3(530, 715, 0)
		self.node_list["ConvertJade"]:SetActive(false)
		self.node_list["JadeBag"]:SetActive(true)

		self.node_list["ChooseList"].scroller:ReloadData(0)
		self.node_list["RecycleScore"].text.text = string.format(Language.Forge.GetJadeScore, 0)
	
	elseif self.open_type == 2 then
		self.node_list["Txt"].text.text = Language.Forge.ConvertJade
		self.node_list["Bg"].rect.sizeDelta = Vector3(465, 550, 0)
		self.node_list["JadeBag"]:SetActive(false)
		self.node_list["ConvertJade"]:SetActive(true)

		self.jade_convert_cfg = ForgeData.Instance:GetJadeConvertCfg()
		if self.node_list["ConvertListView"] then
			self.node_list["ConvertListView"].scroller:ReloadData(0)
		end
	end
	self:Flush()
end


----------------------------
------ 玉石List
function ForgeJadeBagView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ForgeJadeBagView:BagRefreshCell(index, cellObj)
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN
	-- 获取数据信息
	local data = nil
	data = self.bag_jade_data[grid_index] or {}
	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetData(cell_data, true)
	if self.choose_recycle_list[cell_data.index] then
		cell:ShowHighLight(true)
	else
		cell:ShowHighLight(false)
	end
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
end

function ForgeJadeBagView:HandleBagOnClick(cell_data, cell)
	if nil == cell_data.item_id then return end

	local bag_index = cell_data.index

	if self.choose_recycle_list[bag_index] then
		self.choose_recycle_list[bag_index] = nil
	else
		self.choose_recycle_list[bag_index] = bag_index
	end
	self:FlushChooseCellHL()
end
-----------------End-------------------

----------------------------
------ 选择Lis
function ForgeJadeBagView:GetChooseCellNumber()
	return #Language.Forge.JadeType
end

function ForgeJadeBagView:ChooseCellRefresh(cell, index)
	local choose_cell = self.choose_cell_list[cell]
	index = index + 1
	if nil == choose_cell then
		choose_cell = JadeTypeChooseCellItem.New(cell.gameObject)
		self.choose_cell_list[cell] = choose_cell
		choose_cell:SetClickCallBack(BindTool.Bind(self.ClickChooseCellCallBack, self))
	end

	local data = Language.Forge.JadeType[index]
	choose_cell:SetIndex(index)
	choose_cell:SetData(data)
end

function ForgeJadeBagView:ClickChooseCellCallBack(index)
	self.resolve_order = index
	self:FlushChooseCell()
	self.node_list["ChooseListCont"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.is_show_condition_list = false
	self.node_list["BtnconditionTxt"].text.text = Language.Forge.JadeType[index]
end
-----------------End-------------------


----------------------------
------ 兑换List
function ForgeJadeBagView:GetConvertCellNumber()
	return #self.jade_convert_cfg
end

function ForgeJadeBagView:ConvertCellRefresh(cell, index)
	local convert_cell = self.convert_cell_list[cell]
	index = index + 1
	if nil == convert_cell then
		convert_cell = JadeConvertCellItem.New(cell.gameObject)
		self.convert_cell_list[cell] = convert_cell
	end

	local data = self.jade_convert_cfg[index]
	convert_cell:SetData(data)
end
-----------------End-------------------


function  ForgeJadeBagView:OnFlush()
	if self.open_type == 1 then
		self.bag_jade_data = ForgeData.Instance:GetAllJadesInBag()
		if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
			self.node_list["ListView"].list_view:Reload()
			self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
		end
		self.node_list["PageToggle1"].toggle.isOn = true

	elseif self.open_type == 2 then

		self.node_list["JadeScore"].text.text = ToColorStr(ForgeData.Instance:GetJadeScore(), COLOR.YELLOW)
	end
end

function ForgeJadeBagView:OpenConditonList()
	self.is_show_condition_list = not self.is_show_condition_list
	self.node_list["ChooseListCont"]:SetActive(self.is_show_condition_list)
	self.node_list["BtnBlock"]:SetActive(self.is_show_condition_list)
end

function ForgeJadeBagView:OnClickBolck()
	self.is_show_condition_list = false
	self.node_list["ChooseListCont"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
end

-- 分解
function ForgeJadeBagView:ButtonFenJie()
	for k, v in pairs(self.choose_recycle_list) do
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_RESOLVE, v)
	end
	self.choose_recycle_list = {}
	self.node_list["RecycleScore"].text.text = string.format(Language.Forge.GetJadeScore, ToColorStr(0, COLOR.YELLOW))
end

function ForgeJadeBagView:FlushChooseCell()
	self.choose_recycle_list = {}
	for k, v in pairs(self.bag_jade_data) do
		if v.jade_level <= self.resolve_order then
			self.choose_recycle_list[v.index] = v.index
		end
	end
	self:FlushChooseCellHL()
end

-- 刷新格子高亮
function ForgeJadeBagView:FlushChooseCellHL()
	local score = 0
	for k, v in pairs(self.bag_cell) do
		if v:GetActive() then
			local data_index = v:GetData().index
			if data_index and self.choose_recycle_list[data_index] then
				v:ShowHighLight(true)
			else
				v:ShowHighLight(false)
			end
		end
	end
	for k, v in pairs(self.choose_recycle_list) do
		local item_data = ItemData.Instance:GetGridData(v)
		if item_data and item_data.item_id then
			score = score + ForgeData.Instance:GetJadeResolveCfg(item_data.item_id) * item_data.num
		end
	end
	score = ToColorStr(score, COLOR.YELLOW)
	self.node_list["RecycleScore"].text.text = string.format(Language.Forge.GetJadeScore, score)
end







------------------------------------------
--------JadeTypeChooseCellItem 玉石类型选择
JadeTypeChooseCellItem = JadeTypeChooseCellItem or BaseClass(BaseCell)
function JadeTypeChooseCellItem:__init()
	self.node_list["ConditionItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))
end

function JadeTypeChooseCellItem:__delete()

end

function JadeTypeChooseCellItem:ClickItem()
	if self.click_callback then
		self.click_callback(self.index)
	end
end

function JadeTypeChooseCellItem:OnFlush()
	if nil == self.data then return end

	self.node_list["TxtBtn"].text.text = self.data
end

------------------------------------------
--------JadeConvertCellItem 玉石兑换
JadeConvertCellItem = JadeConvertCellItem or BaseClass(BaseCell)
function JadeConvertCellItem:__init()
	self.jade_cell = ItemCell.New()
	self.jade_cell:SetInstanceParent(self.node_list["JadeItem"])

	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickConvert, self))
end

function JadeConvertCellItem:__delete()
	if self.jade_cell then
		self.jade_cell:DeleteMe()
		self.jade_cell = nil
	end
end

function JadeConvertCellItem:OnClickConvert()
	local function ok_callback()
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_CONVERT, self.data.seq)
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.convert_stone_id)
	local des = string.format(Language.Forge.IsConvertJade, ToColorStr(self.data.convert_need_score, TEXT_COLOR.GREEN_4), ToColorStr(item_cfg.name, ORDER_COLOR[item_cfg.color]))
	TipsCtrl.Instance:ShowCommonAutoView("jade_convert", des, ok_callback, nil, nil, nil, nil, nil, nil, true)
end

function JadeConvertCellItem:OnFlush()
	if nil == self.data then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.convert_stone_id)
	local attrs = ForgeData.Instance:GetJadeAttr(self.data.convert_stone_id)
	self.jade_cell:SetData({item_id = self.data.convert_stone_id, num = 1, is_bind = 0})
	self.node_list["JadeName"].text.text = ToColorStr(item_cfg.name, ORDER_COLOR[item_cfg.color]) 
	self.node_list["Score"].text.text = self.data.convert_need_score
	for i = 1, 2 do
		if attrs[i] == nil or attrs[i] == 0 then
			self.node_list["AttrText"..i].text.text = ""
		else
			self.node_list["AttrText"..i].text.text = attrs[i].attr_name .. ':  ' .. attrs[i].attr_value
		end
	end
end

