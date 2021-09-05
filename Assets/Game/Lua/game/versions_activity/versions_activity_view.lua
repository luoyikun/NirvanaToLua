VersionsActivityView = VersionsActivityView or BaseClass(BaseView)

function VersionsActivityView:__init()
	self.ui_config = {{"uis/views/versionsactivity_prefab", "VersionsView"}}
	self.play_audio = true

	self.cell_list = {}
end

function VersionsActivityView:__delete()

end

function VersionsActivityView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.right_content = nil
end

function VersionsActivityView:OpenCallBack()
	self:Flush()
end

function VersionsActivityView:CloseCallBack()
end

function VersionsActivityView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	self.panel_obj_list = {}
	self.panel_list = {}

	local list_delegate = self.node_list["ToggleList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.right_content = self.node_list["RightContent"]
end

function VersionsActivityView:ShowIndexCallBack()
end

function VersionsActivityView:Onflush()
end

function VersionsActivityView:OnClickClose()
	self:Close()
end

function VersionsActivityView:GetNumberOfCells()
	return 0
end

function VersionsActivityView:RefreshCell(cell, data_index)
	local config_index = data_index + 1
	local tab_btn = self.cell_list[cell]
	if tab_btn == nil then
		tab_btn = LeftTableButton.New(cell.gameObject)
		tab_btn:SetToggleGroup(self.node_list["ToggleList"].toggle_group)
		self.cell_list[cell] = tab_btn
	end
	-- tab_btn:SetHighLight(self.cur_sub_type == sub_type)
	-- tab_btn:ListenClick(BindTool.Bind(self.OnClickTabButton, self, sub_type, config_index, tab_btn))

	local data = {}
	data.is_show_effect = false
	tab_btn:SetData(data)
end