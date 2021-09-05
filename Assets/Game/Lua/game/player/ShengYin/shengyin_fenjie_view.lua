ShengYinReSolve = ShengYinReSolve or BaseClass(BaseView)
-- 常亮定义
local ShengYin_MAX_GRID_NUM = 320			-- 最大格子数
local ShengYin_PAGE_NUM = 8					-- 页数
local ShengYin_PAGE_COUNT = 40				-- 每页个数
local ShengYin_ROW = 4						-- 行数
local ShengYin_COLUMN = 10					-- 列数

function ShengYinReSolve:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab","BaseSecondPanel"},
		{"uis/views/player/shengyin_prefab", "ShengYinFenJie"}
	}
	self.is_any_click_close = false
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.equip_dropdown_list = {}
	self.select_list = {}
	self.jinghua_list = {}
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.grade_cell_list = {}
	self.color_cell_list = {}
end

function ShengYinReSolve:__delete()
	
end

function ShengYinReSolve:LoadCallBack()
	self:CreateGradeList()
	self:CreateColorList()
	self.node_list["TitleText"].text.text = Language.Player.ShengYinFenJie
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.resolve_color = 0 	--分解品质
	self.resolve_order = 0 --分解阶数
	local list_view = self.node_list["ListView"].page_simple_delegate
	list_view.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_view.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.node_list["ButtonFenJie"].button:AddClickListener(BindTool.Bind(self.OnClickFenJie, self))
	self.node_list["Btncondition1"].button:AddClickListener(BindTool.Bind(self.OpenConditonList1, self))
	self.node_list["ConditionItem1"].toggle:AddClickListener(BindTool.Bind(self.CleanOrder, self))
	self.node_list["Btncondition2"].button:AddClickListener(BindTool.Bind(self.OpenConditonList2, self))
	self.node_list["ConditionItem2"].toggle:AddClickListener(BindTool.Bind(self.CleanColor, self))
	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.OnClickBolck, self))
	self.bag_cell = {}
end

function ShengYinReSolve:OnClickFenJie()
	local recycle_backpack_index_list = {}
	for i = 0, ShengYin_MAX_GRID_NUM - 1 do 
		recycle_backpack_index_list[i] = 0
	end
	local num = 0
	for i, v in pairs(self.select_list) do 
		if v ~= nil then 
			recycle_backpack_index_list[num] = v
			num = num + 1
		end
	end
	PlayerCtrl.Instance:SendUseShengYinResolve(num, recycle_backpack_index_list)
	self.select_list = {}
	self.jinghua_list = {}
	self:Flush()
end

function ShengYinReSolve:CloseWindow()
	self:Close()
end

function ShengYinReSolve:CleanOrder()
	self.select_list = {}
	self.jinghua_list = {}
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.node_list["BtnconditionTxt1"].text.text = Language.Player.ClearSelect
	self:Flush()
end

function ShengYinReSolve:CleanColor()
	self.select_list = {}
	self.jinghua_list = {}
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.node_list["BtnconditionTxt2"].text.text = Language.Player.ClearSelect
	self:Flush()
end

function ShengYinReSolve:OnClickBolck()
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
end


function ShengYinReSolve:OnClickColorCell(index)
	self.resolve_color = index
	self:FlushChooseCell()
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.node_list["BtnconditionTxt2"].text.text = Language.Player.SelectType1[index]
end

function ShengYinReSolve:OnClickGradeCell(index)
	self.resolve_order = index
	self:FlushChooseCell()
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.is_show_condition_list1 = false
	self.is_show_condition_list2 = false
	self.node_list["BtnconditionTxt1"].text.text = Language.Player.SelectType2[index]
end

function ShengYinReSolve:CreateGradeList()
	local list_delegate = self.node_list["ConditionList1"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #Language.Player.SelectType2
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.grade_cell_list[cell]
		if cell_item == nil then
			cell_item = OrderListCellSY.New(cell.gameObject)
			self.grade_cell_list[cell] = cell_item
		end
		cell_item:SetData(data_index + 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickGradeCell, self, data_index + 1))
	end
end

function ShengYinReSolve:CreateColorList()
	local list_delegate = self.node_list["ConditionList2"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #Language.Player.SelectType1
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.grade_cell_list[cell]
		if cell_item == nil then
			cell_item = ColorListCellSY.New(cell.gameObject)
			self.grade_cell_list[cell] = cell_item
		end
		cell_item:SetData(data_index + 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickColorCell, self, data_index + 1))
	end
end

function ShengYinReSolve:OpenConditonList1()
	self.is_show_condition_list1 = not self.is_show_condition_list1
	self.node_list["ListScreenObj"]:SetActive(self.is_show_condition_list1)
	self.node_list["BtnBlock"]:SetActive(self.is_show_condition_list1)
	self.node_list["ListScreenQua"]:SetActive(false)
	self.is_show_condition_list2 = false
end

function ShengYinReSolve:OpenConditonList2()
	self.is_show_condition_list2 = not self.is_show_condition_list2
	self.node_list["ListScreenQua"]:SetActive(self.is_show_condition_list2)
	self.node_list["BtnBlock"]:SetActive(self.is_show_condition_list2)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.is_show_condition_list1 = false
end

function ShengYinReSolve:FlushChooseCell()
	self.select_list = PlayerData.Instance:GetShengYinResoleSelect(self.grid_list, self.resolve_order)
	self:RefreshJingHuaIndexList()
	self:FlushJingHua()
	self.node_list["ListView"].list_view:Reload()
end

function ShengYinReSolve:OpenCallBack()
	self.resolve_color = 0 	--分解品质
	self.resolve_order = 0 --分解阶数
	self.grid_list = PlayerData.Instance:GetSealBagItemList()
	self.select_list = PlayerData.Instance:GetShengYinResoleSelect(self.grid_list, self.resolve_order)
	self:RefreshJingHuaIndexList()
	self.node_list["ListView"].list_view:Reload()
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	self.node_list["BtnconditionTxt1"].text.text = Language.Player.ClearSelect
	self:FlushJingHua()
end

function ShengYinReSolve:SetDropdownInfo()
	
end

function ShengYinReSolve:ReleaseCallBack()
	self.resolve_color = nil
	self.resolve_order = nil
	self.select_list = {}
	self.jinghua_list = {}
	self.grid_list = {}
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	for k, v in pairs(self.grade_cell_list) do
		v:DeleteMe()
	end
	self.grade_cell_list = {}
	for k, v in pairs(self.color_cell_list) do
		v:DeleteMe()
	end
	self.color_cell_list = {}
end

function ShengYinReSolve:OnFlush()
	self:FlushListInfo()
	self:FlushJingHua()
end
function ShengYinReSolve:FlushJingHua()
	if next(self.jinghua_list) then 
		local get_jinghua = 0
		for k, v in pairs(self.jinghua_list) do

			if self.grid_list[v] and self.grid_list[v].color then
				local get_cfg = PlayerData.Instance:GetShengYinJingHuaCfg(self.grid_list[v].color)
				if self.grid_list[v].slot_index == 0 and next(get_cfg) then
					get_jinghua = get_jinghua + get_cfg.jinghua_hun_score * self.grid_list[v].num
				elseif self.grid_list[v].slot_index ~= 0 and next(get_cfg) then
					get_jinghua = get_jinghua + get_cfg.hun_score * self.grid_list[v].num
				end
			end		
		end
		self.node_list["GetJingHua"].text.text = string.format(Language.Player.GetJingHua, get_jinghua)
		self.node_list["GetJingHua"]:SetActive(true)
	else
		self.node_list["GetJingHua"].text.text = ""
		self.node_list["GetJingHua"]:SetActive(false)
	end
end
function ShengYinReSolve:FlushListInfo()
	self.grid_list = PlayerData.Instance:GetSealBagItemList()
	self.node_list["ListView"].list_view:Reload()
	--self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
end

-- 分解列表数量
function ShengYinReSolve:BagGetNumberOfCells()
	return ShengYin_MAX_GRID_NUM
end

-- 刷新分解列表数据
function ShengYinReSolve:BagRefreshCell(index, cellObj)

	-- 获取数据
	local grid_list = nil
	if not self.grid_list then 
		self.grid_list = PlayerData.Instance:GetSealBagItemList()		-- 74行数据
	end
	grid_list = self.grid_list
	grid_list = grid_list or{}
	--local cell_data = {} 
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
	if next(guid_info) then 
		-- cell:ShowHighLight(true)
		if guid_info.order > 0 then
			-- cell:SetShengYinGrade(guid_info.order)
		end
	-- else
	-- 	cell:ShowHighLight(false)
	end
	if self.select_list[grid_index + 1] ~= nil then 
		-- cell:ShowHighLight(true)
		cell:SetIconGrayVisible(true)
		cell:ShowHasGet(true)
	else
		-- cell:ShowHighLight(false)
		cell:SetIconGrayVisible(false)
		cell:ShowHasGet(false)
	end

	cell:ListenClick(BindTool.Bind(self.HandleOnClick, self, guid_info, cell , grid_index + 1))
	-- cell:SetInteractable((nil ~= grid_list[grid_index].item_id))
end

function ShengYinReSolve:HandleOnClick(guid_info, cell, index)
	-- local high_light = cell:IsHighLight()
	if self.select_list[index] then 
		self.select_list[index] = nil
		self:RefreshJingHuaIndexList()
		-- cell:ShowHighLight(false)
		cell:SetIconGrayVisible(false)
		cell:ShowHasGet(false)
	else
		if guid_info ~= nil and guid_info.order then
			self.select_list[index] = guid_info.bag_index
			self:RefreshJingHuaIndexList()
			-- cell:ShowHighLight(true)
			cell:SetIconGrayVisible(true)
			cell:ShowHasGet(true)
		end
	end
	self:FlushJingHua()
end

function ShengYinReSolve:RefreshJingHuaIndexList()
	self.jinghua_list = {}
	for k, v in pairs(self.select_list) do
		for m, n in pairs(self.grid_list) do
			if n.bag_index == v then
				self.jinghua_list[k] = m
				break
			end
		end
	end
end

ColorListCellSY = ColorListCellSY or BaseClass(BaseCell)

function ColorListCellSY:__init(instance)

end

function ColorListCellSY:__delete()

end

function ColorListCellSY:OnFlush()
	self.node_list["TxtBtn"].text.text = Language.Player.SelectType1[self.data]
end

function ColorListCellSY:ListenClick(handler)
	self.node_list["ConditionItem"].toggle:AddClickListener(handler)
end

OrderListCellSY = OrderListCellSY or BaseClass(BaseCell)

function OrderListCellSY:__init(instance)

end

function OrderListCellSY:__delete()

end

function OrderListCellSY:OnFlush()
	self.node_list["TxtBtn"].text.text = Language.Player.SelectType2[self.data]
end

function OrderListCellSY:ListenClick(handler)
	self.node_list["ConditionItem"].toggle:AddClickListener(handler)
end