MapFindRewardView = MapFindRewardView or BaseClass(BaseView)

function MapFindRewardView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/mapfind_prefab", "MapRewardView"},
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MapFindRewardView:__delete()
end

function MapFindRewardView:LoadCallBack()
	-- self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(695, 545, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Txt"].text.text = Language.MapFind.RewardTipTitle
	self.cell_list = {}
	self.list_simple_delegate  = self.node_list["List"].list_simple_delegate
	self.list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function MapFindRewardView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
	self.list_simple_delegate = nil
end

function MapFindRewardView:CloseWindow()
	self:Close()
end

function MapFindRewardView:GetNumberOfCells()
	return math.ceil(MapFindData.Instance:GetRouteNumber()/2.0)
end

function MapFindRewardView:RefreshView(cell, data_index)
	local left_cell = self.cell_list[cell]
	if left_cell == nil then
		left_cell = MapRewardGroupItem.New(cell.gameObject)
		self.cell_list[cell] = left_cell
	end
	left_cell:SetData(data_index + 1)
end


MapRewardGroupItem = MapRewardGroupItem or BaseClass(BaseRender)

function MapRewardGroupItem:__init()
	self.item_1 = MapRewardShowItem.New(self.node_list["item1"])
	self.item_2 = MapRewardShowItem.New(self.node_list["item2"])
end

function MapRewardGroupItem:__delete()
	if self.item_1 then
		self.item_1:DeleteMe()
	end
	self.item_1 = nil
	if self.item_2 then
		self.item_2:DeleteMe()
	end
	self.item_2 = nil
end

function MapRewardGroupItem:SetData(index)
	local data = MapFindData.Instance:GetMapRewardData(index * 2 - 1)
	self.item_1:SetData(data)
	data = MapFindData.Instance:GetMapRewardData(index * 2)
	if data then
		self.item_2:SetData(data)
		self.node_list["item2"].gameObject:SetActive(true)
	else
		self.node_list["item2"].gameObject:SetActive(false)
	end
end


MapRewardShowItem = MapRewardShowItem or BaseClass(BaseRender)
function MapRewardShowItem:__init()
end

function MapRewardShowItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function MapRewardShowItem:SetData(data)
	if data == nil then
		return
	end
	if nil == self.cell then
		self.cell = ItemCell.New()
		self.cell:SetInstanceParent(self.node_list["Item"])
	end
	self.cell:SetData(data.base_reward_item)
	self.node_list["Text"].text.text = data.name
end