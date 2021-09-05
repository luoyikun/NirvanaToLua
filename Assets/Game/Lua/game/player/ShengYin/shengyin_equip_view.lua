ShengYinEquip = ShengYinEquip or BaseClass(BaseView)
-- 常亮定义
local ShengYin_MAX_GRID_NUM = 200			-- 最大格子数
local ShengYin_PAGE_NUM = 5					-- 页数
local ShengYin_PAGE_COUNT = 40				-- 每页个数
local ShengYin_ROW = 4						-- 行数
local ShengYin_COLUMN = 10					-- 列数

function ShengYinEquip:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/player/shengyin_prefab", "ShengYinEquip"},
	}
	self.is_any_click_close = false
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.select_cell = {}
	self.slot_index = - 1
end

function ShengYinEquip:__delete()
	
end

function ShengYinEquip:LoadCallBack()
	self.open_start = true
	self.node_list["TitleText"].text.text = Language.Player.ShengYinEquip
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	local list_view = self.node_list["ListView"].page_simple_delegate
	list_view.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_view.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickZhuangBei, self))
	self.bag_cell = {}
end

function ShengYinEquip:OnClickZhuangBei()
	self:GetGridList()
	if self.select_cell["cel"] ~= nil and self.select_cell["index"] ~= nil then 
		local index = self.select_cell["index"]
		local data = self.grid_list[index]
		if data == nil then
			return self:CloseWindow()
		end
		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id) or {}
		local seal_slot = PlayerData.Instance:GetSealSlotBySealId(item_cfg.id)
		PackageCtrl.Instance:SendUseItem(data.bag_index, 1)
 		-- PlayerCtrl.Instance:SendUseShengYin(SEAL_OPERA_TYPE.SEAL_OPERA_TYPE_PUT_ON, data.bag_index, seal_slot)

 	end
	
	self:CloseWindow()
end

function ShengYinEquip:SetSlotIndex(slot_index)
	self.slot_index = slot_index
end

function ShengYinEquip:CloseWindow()
	self:Close()
end

function ShengYinEquip:CloseCallBack()
end

function ShengYinEquip:OpenCallBack()
	self.open_start = true
	self:FlushListInfo()
end

function ShengYinEquip:ReleaseCallBack()
	if self.select_cell["cel"] ~= nil then
		self.select_cell["cel"]:DeleteMe()
	end
	self.select_cell = {}
	self.grid_list = {}
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
end

function ShengYinEquip:OnFlush()
	self:FlushListInfo()
end

function ShengYinEquip:FlushListInfo()
	self:GetGridList()
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)	
end

function ShengYinEquip:GetGridList()
	self.grid_list = {}
	local bag_list = PlayerData.Instance:GetSealBagItemList()
	local index = 1
	for k, v in pairs(bag_list) do
		if v.slot_index ~= nil and v.slot_index == self.slot_index then
			table.insert(self.grid_list, index, v)
			index = index + 1
		end
	end
end

function ShengYinEquip:BagGetNumberOfCells()
	return ShengYin_MAX_GRID_NUM
end

function ShengYinEquip:BagRefreshCell(index, cellObj)
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
	
	local page = math.floor(index / ShengYin_PAGE_COUNT)
	local cur_colunm = math.floor(index / ShengYin_ROW) + 1 - page * ShengYin_COLUMN
	local cur_row = math.floor(index % ShengYin_ROW) + 1
	local grid_index = (cur_row - 1) * ShengYin_COLUMN - 1 + cur_colunm + page * ShengYin_ROW * ShengYin_COLUMN

	local guid_info = grid_list[grid_index + 1] or {}
	cell:SetData(guid_info, false)
	-- if next(guid_info) then 
	-- 	cell:SetShengYinGrade(guid_info.order)
	-- end
	
	cell:ShowHighLight(false)	
	cell:ListenClick(BindTool.Bind(self.CellOnClick, self, guid_info, cell, grid_index + 1))
	if self.open_start then
		self.select_cell["cel"] = cell
		self.select_cell["index"] = grid_index + 1
		self.open_start = false
		if guid_info.order ~= nil then
			cell:ShowHighLight(true)
		end
	end
end

function ShengYinEquip:CellOnClick(guid_info, cell, select_index)	
	if guid_info.index == nil then
		return
	end 
	local high_light = cell:IsHighLight()
	if self.select_cell["cel"] ~= nil and self.select_cell["index"] ~= nil then 
		self.select_cell["cel"]:ShowHighLight(false)
		if self.select_cell["index"] == select_index then
			self.select_cell["cel"] = nil
			self.select_cell["index"] = nil 
		else
			self.select_cell["cel"] = cell
			self.select_cell["index"] = select_index 
			cell:ShowHighLight(true)
		end
	else
		self.select_cell["cel"] = cell
		self.select_cell["index"] = select_index
		cell:ShowHighLight(true)
	end
end
