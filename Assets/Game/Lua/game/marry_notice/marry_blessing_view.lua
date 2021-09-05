MarryBlessingView = MarryBlessingView or BaseClass(BaseView)

function MarryBlessingView:__init()
	self.ui_config = {{"uis/views/marrynoticeview_prefab", "MarryBlessingView"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MarryBlessingView:__delete()

end

function MarryBlessingView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnConfig"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self:InitScroller()
end

function MarryBlessingView:ReleaseCallBack()
	self.list_view_delegate = nil
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MarryBlessingView:OpenCallBack()
	self:Flush()
end

function MarryBlessingView:CloseCallBack()

end

function MarryBlessingView:OnFlush(param_t)
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MarryBlessingView:InitScroller()
	self.cell_list = {}
	self.list_view_delegate = self.node_list["list_view"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function MarryBlessingView:GetNumberOfCells()
	return #MarryNoticeData.Instance:GetBlessing()
end

function MarryBlessingView:RefreshView(cell, data_index)
	local blessing_cell = self.cell_list[cell]
	if blessing_cell == nil then
		blessing_cell = MarryBlessingText.New(cell.gameObject)
		self.cell_list[cell] = blessing_cell
	end
	local record_list = MarryNoticeData.Instance:GetBlessing()
	local data = record_list[data_index + 1]
	blessing_cell:SetData(data)
end

------------------------------------------MarryBlessingText--------------------------------------------

MarryBlessingText = MarryBlessingText or BaseClass(BaseCell)

function MarryBlessingText:__init()

end

function MarryBlessingText:__delete()

end

function MarryBlessingText:OnFlush()
	if self.data then
		self.node_list["TxtBlessing"].text.text = string.format(Language.Marriage.BlessingText[self.data.blessing_type], self.data.name)
	end
end