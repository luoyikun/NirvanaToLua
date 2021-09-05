-- 可滚动数量item的下拉列表
-- DropDownScrollView

DropDownScrollView = DropDownScrollView or BaseClass(BaseView)

function DropDownScrollView:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "DropDownScrollView"}}
	self.play_audio = true
	self.vew_cache_time = 0
end

function DropDownScrollView:__delete()

end

function DropDownScrollView:ReleaseCallBack()

end

function DropDownScrollView:LoadCallBack()
	self.node_list["AutoSelectBlock"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.drop_down_scroll_cell = {}
	local left_list_delegate = self.node_list["ListView"].list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetListNumberOfCell, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function DropDownScrollView:GetListNumberOfCell()
	return #self.list_name or 0
end

function DropDownScrollView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.drop_down_scroll_cell[cell]
	if cell_item == nil then
		cell_item = DropDownScrollCell.New(cell.gameObject)
		self.drop_down_scroll_cell[cell] = cell_item
	end
	local data = self.list_name[data_index]
	cell_item:SetData(data or {})
	cell_item:SetClickCallBack(data_index, BindTool.Bind(self.ClickToggle, self))
end

function DropDownScrollView:OpenCallBack()
	if self.frame_pos then
		self.node_list["FramePos"].transform.localPosition = self.frame_pos
	end
end

function DropDownScrollView:ClickToggle(i)
	if 0 == i and self.cancel_call_back then 
		self.cancel_call_back()
	elseif 0 ~= i and self.call_back then 
		self.call_back(i)
	end
	self:Close()
end

function DropDownScrollView:SetCloseCallBack(close_call_back)
	self.close_call_back = close_call_back
end

function DropDownScrollView:SetCallBack(call_back , state)
	if "Cancel" == state then 
		self.cancel_call_back = call_back
	else 
		self.call_back = call_back
	end
end

function DropDownScrollView:CloseCallBack()
	if self.close_call_back then
		self.close_call_back()
	end
	
	self.call_back = nil
	self.close_call_back = nil
	self.cancel_call_back = nil
	self.list_name = {}
end

-- 设置列表的位置和名字
function DropDownScrollView:SetFramePosAndListName(vector, list_name)
	self.frame_pos = vector
	self.list_name = list_name
end


---------------------------------------------------------------------
-- DropDownScrollCell
DropDownScrollCell = DropDownScrollCell or BaseClass(BaseCell)

function DropDownScrollCell:__init()
	self.node_list["DropDownScrollCell"].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self))
end

function DropDownScrollCell:__delete()
	
end

function DropDownScrollCell:SetClickCallBack(data_index, call_back)
	self.data_index = data_index
	self.click_callback = call_back
end

function DropDownScrollCell:OnClickToggle() 
	if self.click_callback and self.data_index then
		self.click_callback(self.data_index - 1)
	end
end

function DropDownScrollCell:OnFlush()
	if not self.data or {} == self.data then
		return
	end

	self.node_list["Text"].text.text = tostring(self.data)
end

