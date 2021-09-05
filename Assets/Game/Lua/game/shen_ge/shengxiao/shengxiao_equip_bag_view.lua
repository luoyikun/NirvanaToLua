ShengXiaoEquipBag = ShengXiaoEquipBag or BaseClass(BaseView)
-- 常亮定义
local ShengXiao_MAX_GRID_NUM = 16			-- 最大格子数
local ShengXiao_PAGE_NUM = 1				-- 页数
local ShengXiao_PAGE_COUNT = 16				-- 每页个数
local ShengXiao_ROW = 4						-- 行数
local ShengXiao_COLUMN = 4					-- 列数

function ShengXiaoEquipBag:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengxiaoview_prefab", "ShengXiaoEquip"},
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
	-- self.select_cell = {}
	self.bag_cell = {}
	self.slot_index = - 1
end

function ShengXiaoEquipBag:__delete()
	
end

function ShengXiaoEquipBag:LoadCallBack()
	self.open_start = true
	self.node_list["Txt"].text.text = Language.SuitCollect.EquipBagTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(450, 510, 0)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	-- self.node_list["TitleText"].text.text = Language.ShengXiao.ShengXiaoEquip
	-- self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	-- local list_view = self.node_list["ListView"].page_simple_delegate
	-- list_view.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	-- list_view.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	-- self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickZhuangBei, self))
	for i = 1, ShengXiao_MAX_GRID_NUM do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["ListCellView"])
		cell:SetIndex(i)
		self.bag_cell[i] = cell
	end
end

function ShengXiaoEquipBag:OnClickZhuangBei()
	-- self:GetGridList()
	-- if self.select_cell["cel"] ~= nil and self.select_cell["index"] ~= nil then 
	-- 	local index = self.select_cell["index"]
	-- 	local data = self.grid_list[index]
	-- 	if data == nil then
	-- 		return self:CloseWindow()
	-- 	end
	-- 	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id) or {}
	-- 	local equip_index = ShengXiaoData.Instance:GetEquipListByindex()
	-- 	PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index - 1)

 -- 	end
	
	-- self:CloseWindow()
end

function ShengXiaoEquipBag:SetSlotIndex(slot_index)
	self.slot_index = slot_index - 1
end

function ShengXiaoEquipBag:CloseWindow()
	self:Close()
end

function ShengXiaoEquipBag:CloseCallBack()
end

function ShengXiaoEquipBag:OpenCallBack()
	self.open_start = true
	self:FlushListInfo()
	self:FlushListCell()
end

function ShengXiaoEquipBag:ReleaseCallBack()
	-- if self.select_cell["cel"] ~= nil then
	-- 	self.select_cell["cel"]:DeleteMe()
	-- end
	-- self.select_cell = {}
	self.grid_list = {}
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
end

function ShengXiaoEquipBag:OnFlush()
	self:FlushListInfo()
	self:FlushListCell()
end

function ShengXiaoEquipBag:FlushListInfo()
	-- self:GetGridList()
	-- self.node_list["ListView"].list_view:Reload()
	-- self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)	
end

function ShengXiaoEquipBag:GetGridList()
	self.grid_list = {}
	local bag_list = ShengXiaoData.Instance:GetBagEquipDataList()
	local index = 0
	for k, v in pairs(bag_list) do
		if v.sub_type ~= nil and (v.sub_type - 1300) == self.slot_index then
			table.insert(self.grid_list, index, v)
			index = index + 1
		end
	end
end

function ShengXiaoEquipBag:BagGetNumberOfCells()
	return ShengXiao_MAX_GRID_NUM
end

function ShengXiaoEquipBag:BagRefreshCell(index, cellObj)
	-- 获取数据
	local grid_list = nil
	if not self.grid_list then 
		self:GetGridList()
	end
	grid_list = self.grid_list
	grid_list = grid_list or{}
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.bag_cell.toggle_group)
		cell:SetItemNumVisible(false)
		self.bag_cell[cellObj] = cell
	end
	
	-- local page = math.floor(index / ShengXiao_PAGE_COUNT)
	-- local cur_colunm = math.floor(index / ShengXiao_ROW) + 1 - page * ShengXiao_COLUMN
	-- local cur_row = math.floor(index % ShengXiao_ROW) + 1
	-- local grid_index = (cur_row - 1) * ShengXiao_COLUMN - 1 + cur_colunm + page * ShengXiao_ROW * ShengXiao_COLUMN

	-- local guid_info = grid_list[grid_index] or {}
	cell:SetData(guid_info, false)
	
	cell:ShowHighLight(false)	
	cell:ListenClick(BindTool.Bind(self.CellOnClick, self, guid_info, cell, grid_index))
	-- if self.open_start then
	-- 	self.select_cell["cel"] = cell
	-- 	self.select_cell["index"] = grid_index
	-- 	self.open_start = false
	-- 	if guid_info.sub_type ~= nil then
	-- 		cell:ShowHighLight(true)
	-- 	end
	-- end
end

function ShengXiaoEquipBag:FlushListCell()
	self:GetGridList()
	for i = 1, ShengXiao_MAX_GRID_NUM do
		local grid_index = i - 1
		local guid_info = self.grid_list[grid_index] or {}
		if guid_info then
			self.bag_cell[i]:SetItemNumVisible(false)
			self.bag_cell[i]:ListenClick(BindTool.Bind(self.CellOnClick, self, guid_info, self.bag_cell[i], grid_index))
			self.bag_cell[i]:SetData(guid_info, false)
			self.bag_cell[i]:ShowHighLight(false)	
		end
	end
end

function ShengXiaoEquipBag:CellOnClick(guid_info, cell, select_index)	
	if guid_info.index == nil then
		return
	end 
	-- if self.select_cell["cel"] ~= nil and self.select_cell["index"] ~= nil then 
	-- 	self.select_cell["cel"]:ShowHighLight(false)
	-- 	if self.select_cell["index"] == select_index then
	-- 		self.select_cell["cel"] = nil
	-- 		self.select_cell["index"] = nil 
	-- 	else
	-- 		self.select_cell["cel"] = cell
	-- 		self.select_cell["index"] = select_index 
	-- 		cell:ShowHighLight(true)
	-- 	end
	-- else
	-- 	self.select_cell["cel"] = cell
	-- 	self.select_cell["index"] = select_index
	-- 	cell:ShowHighLight(true)
	-- end
	self:GetGridList()
	-- if self.select_cell["cel"] ~= nil and self.select_cell["index"] ~= nil then 
		local data = self.grid_list[select_index]
		if data == nil then
			return self:CloseWindow()
		end
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id) or {}
		local equip_index = ShengXiaoData.Instance:GetEquipListByindex()
		PackageCtrl.Instance:SendUseItem(data.index, 1, equip_index - 1)

 	-- end
	
	self:CloseWindow()
end
