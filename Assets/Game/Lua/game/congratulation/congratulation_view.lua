CongratulationView = CongratulationView or BaseClass(BaseView)
function CongratulationView:__init()
	self.ui_config = {{"uis/views/congratulate_prefab", "Congratulation"}}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.is_modal = true
end

function CongratulationView:__delete()
end

function CongratulationView:LoadCallBack()
	self.congratulation_item_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.node_list["BtnOption"].button:AddClickListener(BindTool.Bind(self.CloseView,self))
end

function CongratulationView:GetNumberOfCells()
	return #CongratulationData.Instance:GetCongratulationlist()
end

function CongratulationView:RefreshCell(cell, data_index)
	data_index = data_index + 1	
	local the_cell = self.congratulation_item_list[cell]
	if the_cell == nil then
		the_cell = CongratulateItem.New(cell.gameObject)
		the_cell.parent = self
		self.congratulation_item_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:Flush()
end

function CongratulationView:OpenCallBack()
	self.node_list["ListView"].scroller:ReloadData(1)
end

function CongratulationView:OnFlush()
	self.node_list["ListView"].scroller:ReloadData(1)
end

function CongratulationView:CloseView()
	self:Close()
end

function CongratulationView:CloseCallBack()
	CongratulationCtrl.Instance:SetClosenTime()
	CongratulationData.Instance:ClearTempList()
end

function CongratulationView:ReleaseCallBack()
	if next(self.congratulation_item_list) ~= nil then
		local x = #self.congratulation_item_list
		for i = 1, x do
			self.congratulation_item_list[i]:DeleteMe()
		end
	end
	self.congratulation_item_list = {}
end

--------------祝贺列表
CongratulateItem = CongratulateItem or BaseClass(BaseCell)
function CongratulateItem:__init()

end

function  CongratulateItem:__delete()

end

function CongratulateItem:OnFlush()
	local info = CongratulationData.Instance:GetCongratulationlist()[self.index]
	local friend_name = ScoietyData.Instance:GetFriendNameById(info.uid)
	local value = ""
	local experience = CongratulationData.Instance:GetExperience()
	if info._type == CONGRATULATION_TYPE.EGG then
		value = string.format(Language.Congratulation.Info1, friend_name, experience)
	elseif info._type == CONGRATULATION_TYPE.FLOWER then
		value = string.format(Language.Congratulation.Info2, friend_name, experience)
	end
	self.node_list["Txt"].text.text = value
end