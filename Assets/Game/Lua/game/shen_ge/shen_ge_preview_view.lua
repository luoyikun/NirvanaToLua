ShenGePreviewView = ShenGePreviewView or BaseClass(BaseView)
local COLUMN = 4

function ShenGePreviewView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGePreviewView"}}
	self.play_audio = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function ShenGePreviewView:__delete()
end

function ShenGePreviewView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenGePreviewView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}
	self.is_first_list = {}

	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSize, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
end

function ShenGePreviewView:OpenCallBack()
	self:FlushView()
end

function ShenGePreviewView:CloseCallBack()

end

function ShenGePreviewView:GetCellSize(data_index)
	if self.is_first_list[data_index + 1] then
		return 224
	else
		return 143
	end
end

function ShenGePreviewView:FlushView()
	self.list_data = {}
	self.is_first_list = {}
	self.list = {}
	local shenge_data = ShenGeData.Instance
	local last_layer = -1
	local index = 0
	local count = 2
	local types = shenge_data:GetShenGepreviewCfgForTypes()
	for i = 1, 6 do
		for quality = 1, 4 do
			local item_id = shenge_data:GetShenGeItemId(types[i], quality)
			local data = shenge_data:GetShenGepreviewCfg(types[i], quality, 1)
			table.insert(list, data)
		end
	end
	for k,v in ipairs(list) do
		if v.in_layer_open ~= last_layer then
			index = index + 1
			self.list_data[index] = {}
			last_layer = v.in_layer_open
			count = 1
		else
			if count > COLUMN then
				index = index + 1
				self.list_data[index] = {}
				count = 1
			end
		end

		self.list_data[index][count] = v
		count = count + 1
	end
	self.total_count = index
	self.node_list["ListView"].scroller:ReloadData(0)
end

function ShenGePreviewView:CloseWindow()
	self:Close()
end

function ShenGePreviewView:GetCellNumber()
	return 6
end

function ShenGePreviewView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = ShenGePreviewGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data_list = self.list_data[data_index + 1] or {}
	for i = 1, COLUMN do
		local data = data_list[i]
		if data then
			group_cell:SetActive(i, true)
			group_cell:SetData(i, data)
			group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
		else
			group_cell:SetActive(i, false)
		end
	end
	group_cell:SetImage(data_index)
	if self.is_first_list[data_index + 1] then
		group_cell:ShowTitle(true)
	else
		group_cell:ShowTitle(false)
	end
end

function ShenGePreviewView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	ShenGeCtrl.Instance:SetTipsData(data)
	ShenGeCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.ShenGeItemTips)
end

function ShenGePreviewView:OnFlush(params_t)
	self:FlushView()
end

--------------------ShenGePreviewGroupCell---------------------------
ShenGePreviewGroupCell = ShenGePreviewGroupCell or BaseClass(BaseRender)
function ShenGePreviewGroupCell:__init()
	self.item_list = {}
	self.data = {}
	for i = 1, COLUMN do
		local item_cell = ShenGeAnalyzeItemCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function ShenGePreviewGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGePreviewGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGePreviewGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
	self.data[i] = data
end

function ShenGePreviewGroupCell:SetImage(data_index)
	-- self.data.quality
	for i = 1, COLUMN do
		if self.data and self.data[i] then
			local item_id = ShenGeData.Instance:GetShenGeItemId(self.data[i].types, self.data[i].quality)
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if nil ~= item_cfg then 
				self.node_list["TxtItem" .. i].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
			end
		end
	end
end

function ShenGePreviewGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGePreviewGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function ShenGePreviewGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

function ShenGePreviewGroupCell:ShowTitle(state)
	if state then
		if self.data then
			local str = string.format(Language.Rune.JieSuo, self.data.in_layer_open or 0) or ""
			self.node_list["TxtTips"].text.text = str
		end
	end
end

--------------------ShenGeAnalyzeItemCell----------------------
ShenGeAnalyzeItemCell = ShenGeAnalyzeItemCell or BaseClass(BaseCell)
function ShenGeAnalyzeItemCell:__init()
	self.node_list["CellItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShenGeAnalyzeItemCell:__delete()

end

function ShenGeAnalyzeItemCell:SetToggleHighLight(state)
	self.root_node.toggle.isOn = state
end

function ShenGeAnalyzeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.ShenGe.AttrTypeName[self.data.types] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)

	local attr_type_name = ""
	local attr_value = 0
	local cap = {}
	cap[Language.ShenGe.AttrType[self.data.attr_type_0]] = self.data.add_attributes_0
	if self.data.attr_type_1 > 0 then
		cap[Language.ShenGe.AttrType[self.data.attr_type_1]] = self.data.add_attributes_1
	end

	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end
	local cap_attr = CommonDataManager.GetCapabilityCalculation(cap)
	local color_str = ToColorStr(cap_attr, TEXT_COLOR.LIGHTYELLOW)
	self.node_list["TxtItem1"].text.text = Language.ShenGe.ZhanLi .. color_str
	self.node_list["TxtItem2"]:SetActive(false)

end