RuneTotalShowView = RuneTotalShowView or BaseClass(BaseRender)

local TOP_CELL_SIZE = 395		-- 塔顶塔格子的大小
local BOTTOM_CELL_SIZE = 367	-- 塔底塔格子的大小
local NORMAL_CELL_SIZE = 249	-- 正常塔格子的大小

local COLUMN = 3

function RuneTotalShowView:__init()
	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTowerCell, self)
	list_delegate.CellSizeDel = BindTool.Bind(self.CellSizeDel, self)

	-- self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
end

function RuneTotalShowView:FlushView()

	local list = RuneData.Instance:GetRuneListByLayer()
	self.list_data = {}
	self.is_first_list = {}
	local last_layer = -1
	local last_type = -1
	local index = 0
	local count = 1
	for k,v in ipairs(list) do
		if v.pandect > 0 then
			if v.in_layer_open ~= last_layer then
				index = index + 1
				self.list_data[index] = {}
				self.is_first_list[index] = true
				last_layer = v.in_layer_open
				last_type = v.type
				count = 1
			else
				if last_type ~= v.type then
					index = index + 1
					self.list_data[index] = {}
					last_layer = v.in_layer_open
					last_type = v.type
					count = 1
				end
				if count > COLUMN then
					index = index + 1
					self.list_data[index] = {}
					count = 1
				end
			end
			self.list_data[index][count] = v
			count = count + 1
		end
	end
	self.total_count = index + 2
	jumpindex = BOTTOM_CELL_SIZE/(BOTTOM_CELL_SIZE + TOP_CELL_SIZE + index * NORMAL_CELL_SIZE)
	self.node_list["ListView"].scroller:ReloadData(1 - jumpindex)
end

function RuneTotalShowView:GetNumberOfCells()
	return self.total_count
end

function RuneTotalShowView:RefreshTowerCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneTotalShowListView.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data_list = self.list_data[self.total_count - data_index - 1] or {}
	for i = 1, COLUMN do
		local data = data_list[i]
		if data then
			group_cell:SetActive(i, true)
			group_cell:SetData(i, data, self.total_count, data_index)
			group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
		else
			group_cell:SetData(i, nil, self.total_count, data_index)
			group_cell:SetActive(i, false)
		end
	end
	if self.is_first_list[self.total_count - data_index - 1] then
		group_cell:ShowTitle(true)
	else
		group_cell:ShowTitle(false)
	end
	
	-- local item_list = self.list_data[self.total_count - data_index - 2] or {}
	local layer_open = 0
	for k, v in pairs(data_list) do
		if nil ~= v and nil ~= v.in_layer_open then
			layer_open = v.in_layer_open
			break
		end
	end
	local list = {}
	local pass_layer = RuneData.Instance:GetPassLayer()
	list = RuneData.Instance:GetRuneListByLayer()
	local temp = 300
	for k, v in pairs(list) do
		if v.in_layer_open > pass_layer and v.in_layer_open <= temp then
			temp = v.in_layer_open
		end
	end
	local is_lock = layer_open > pass_layer
	-- local is_right = layer_open > temp 
	group_cell:IsShowRight()
	group_cell:IsShowLock(is_lock)
end

function RuneTotalShowView:CellSizeDel(data_index)
	if data_index == 0 then
		return TOP_CELL_SIZE
	elseif data_index == self.total_count - 1 then
		return BOTTOM_CELL_SIZE
	end
	return NORMAL_CELL_SIZE
end

function RuneTotalShowView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	RuneCtrl.Instance:SetTipsData(data)
	RuneCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.RuneItemTips)
end

function RuneTotalShowView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function RuneTotalShowView:InitView()
	UITween.AlpahShowPanel(self.node_list["LeftPanel"], true)
	self:FlushView()
end


--符文塔格子
RuneTotalShowListView = RuneTotalShowListView or BaseClass(BaseRender)

function RuneTotalShowListView:__init(instance)
	-- self.is_cur_challenge = false
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RunePreviewItem.New(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function RuneTotalShowListView:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneTotalShowListView:SetData(i, data, count, data_index)
	if data then
		self.item_list[i]:SetData(data)
		self.data = data
	end
	self.is_top = data_index == 0
	self.is_bottom = data_index + 1 == count
	self.is_second = data_index == 1
	self.node_list["LockShowFirst"]:SetActive(not self.is_top and not self.is_bottom)
	self.node_list["CurLevel"]:SetActive(not self.is_top and not self.is_bottom)
	self.node_list["Right"]:SetActive(not self.is_top and not self.is_bottom)
	self.node_list["ShowTop"]:SetActive(self.is_top)
	self.node_list["ShowBottom"]:SetActive(self.is_bottom)
	self.node_list["LineImage"]:SetActive(not self.is_second)
	self.node_list["LineImage1"]:SetActive(not self.is_second)
end

function RuneTotalShowListView:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneTotalShowListView:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function RuneTotalShowListView:GetContents()
	return self.contents
end

function RuneTotalShowListView:SetIndex(index)
	self.index = index
end

function RuneTotalShowListView:GetIndex()
	return self.index
end

function RuneTotalShowListView:GetHeight()
	return self.root_node.rect.rect.height
end

function RuneTotalShowListView:ShowTitle(state)
	-- if state then
	if self.data then
		local str = string.format(Language.Rune.JieSuo, self.data.in_layer_open or 0) or ""
		self.node_list["CurLevel"].text.text = str
	else
		local str = string.format(Language.Rune.JieSuo, 0) or ""
		self.node_list["CurLevel"].text.text = str
	end
	-- end
end
function RuneTotalShowListView:IsShowRight()
	self.node_list["Right"]:SetActive( not self.is_bottom and not self.is_top)
end


function RuneTotalShowListView:IsShowLock(enable)
	--self.node_list["TreasureItemGroup"]:SetActive(not enable)
	self.node_list["TreasureItemGroup"]:SetActive(true)
	self.node_list["Lock"]:SetActive(enable)
	-- self.node_list["LineImage"]:SetActive(not enable and not self.is_second)
	-- self.node_list["LineImage1"]:SetActive(not enable and not self.is_second)
end

--------------------RunePreviewItem----------------------
RunePreviewItem = RunePreviewItem or BaseClass(BaseCell)
function RunePreviewItem:__init()
	self.node_list["Item"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	
end

function RunePreviewItem:__delete()

end

function RunePreviewItem:SetToggleHighLight(state)
	self.root_node.toggle.isOn = state
end

function RunePreviewItem:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id > 0 then
		self.node_list["ImageRes"].image:LoadSprite(ResPath.GetItemIcon(self.data.item_id))
		--展示特殊特效
		if self.node_list["ShowSpecialEffect"] then
			if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.node_list["ShowSpecialEffect"]:SetActive(true)
			else
				self.node_list["ShowSpecialEffect"]:SetActive(false)
			end
		end
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	self.node_list["LevelText"].text.text = level_str

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrText1"].text.text = str
		self.node_list["AttrText2"].text.text = ""
		return
	end

	local power_str = ToColorStr(self.data.power,TEXT_COLOR.LIGHTYELLOW)
	self.node_list["AttrText1"].text.text = Language.Rune.ZhanLi .. power_str
	self.node_list["AttrText2"].text.text = ""
end
