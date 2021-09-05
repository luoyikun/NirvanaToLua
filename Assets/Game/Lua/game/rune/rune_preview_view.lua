RunePreviewView = RunePreviewView or BaseClass(BaseView)
local COLUMN = 3
function RunePreviewView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/rune_prefab", "RunePreviewView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function RunePreviewView:__delete()
end

function RunePreviewView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

end

function RunePreviewView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}
	self.is_first_list = {}

	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSize, self)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(600,520,0)
	self.node_list["Txt"].text.text = Language.Rune.TitleName3
end

function RunePreviewView:OpenCallBack()
	self:FlushView()
end

function RunePreviewView:CloseCallBack()

end

function RunePreviewView:GetCellSize(data_index)
	if self.is_first_list[data_index + 1] then
		return 224
	else
		return 183
	end
end

function RunePreviewView:FlushView()
	local list = RuneData.Instance:GetRuneListByLayer()
	self.list_data = {}
	self.is_first_list = {}
	local last_layer = -1
	local index = 0
	local count = 1
	for k,v in ipairs(list) do
		if v.in_layer_open ~= last_layer then
			index = index + 1
			self.list_data[index] = {}
			self.is_first_list[index] = true
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

function RunePreviewView:CloseWindow()
	self:Close()
end

function RunePreviewView:GetCellNumber()
	return self.total_count
end

function RunePreviewView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RunePreviewGroupCell.New(cell.gameObject)
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
	if self.is_first_list[data_index + 1] then
		group_cell:ShowTitle(true)
	else
		group_cell:ShowTitle(false)
	end
end

function RunePreviewView:ItemCellClick(cell)
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

function RunePreviewView:OnFlush(params_t)
	self:FlushView()
end

--------------------RunePreviewGroupCell---------------------------
RunePreviewGroupCell = RunePreviewGroupCell or BaseClass(BaseRender)
function RunePreviewGroupCell:__init()

	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RunePreviewItem.New(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function RunePreviewGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RunePreviewGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RunePreviewGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
	self.data = data
end

function RunePreviewGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RunePreviewGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function RunePreviewGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

function RunePreviewGroupCell:ShowTitle(state)
	self.node_list["Title"]:SetActive(state or false)
	if state then
		if self.data then
			local str = string.format(Language.Rune.JieSuo, self.data.in_layer_open or 0) or ""
			self.node_list["TitleText"].text.text = str
		end
	end
end



-- --------------------RunePreviewItem----------------------
-- RunePreviewItem = RunePreviewItem or BaseClass(BaseCell)
-- function RunePreviewItem:__init()
-- 	self.node_list["Item"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	
-- end

-- function RunePreviewItem:__delete()

-- end

-- function RunePreviewItem:SetToggleHighLight(state)
-- 	self.root_node.toggle.isOn = state
-- end

-- function RunePreviewItem:OnFlush()
-- 	if not self.data or not next(self.data) then
-- 		return
-- 	end

-- 	if self.data.item_id > 0 then
-- 		self.node_list["ImageRes"].image:LoadSprite(ResPath.GetItemIcon(self.data.item_id))
-- 		--展示特殊特效
-- 		if self.node_list["ShowSpecialEffect"] then
-- 			if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
-- 				self.node_list["ShowSpecialEffect"]:SetActive(true)
-- 			else
-- 				self.node_list["ShowSpecialEffect"]:SetActive(false)
-- 			end
-- 		end
-- 	end

-- 	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
-- 	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
-- 	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
-- 	self.node_list["LevelText"].text.text = level_str

-- 	local attr_type_name = ""
-- 	local attr_value = 0
-- 	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
-- 		--符文精华特殊处理
-- 		attr_type_name = Language.Rune.JingHuaAttrName
-- 		attr_value = self.data.dispose_fetch_jinghua
-- 		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
-- 		self.node_list["AttrText1"].text.text = str
-- 		self.node_list["AttrText2"].text.text = ""
-- 		return
-- 	end

-- 	local power_str = ToColorStr(self.data.power,TEXT_COLOR.LIGHTYELLOW)
-- 	self.node_list["AttrText1"].text.text = Language.Rune.ZhanLi .. power_str
-- 	self.node_list["AttrText2"].text.text = ""
-- end