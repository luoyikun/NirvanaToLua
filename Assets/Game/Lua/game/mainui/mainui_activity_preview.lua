MainUiActivityPreview = MainUiActivityPreview or BaseClass(BaseView)

function MainUiActivityPreview:__init()
	self.ui_config = {{"uis/views/activityview_prefab", "MainuiActivityPreview"}}

end

function MainUiActivityPreview:__delete()

end

function MainUiActivityPreview:LoadCallBack()
	self.item_list = {}
	self.list_view = self.node_list["ListView"]

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnBgClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function MainUiActivityPreview:OpenCallBack()
	self:Flush()
end

function MainUiActivityPreview:OnFlush()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function MainUiActivityPreview:ReleaseCallBack()
	self.list_view = nil
	
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_list = {}
end

function MainUiActivityPreview:GetNumberOfCells()
	local data_list = ActivityData.Instance:GetTodayActInfoSort()
	return #data_list
end

function MainUiActivityPreview:RefreshCell(cell, data_index, cell_index)
	local data_list = ActivityData.Instance:GetTodayActInfoSort()

	local the_cell = self.item_list[cell]
	if the_cell == nil then
		the_cell = MainUiActivityPreviewItem.New(cell.gameObject)
		self.item_list[cell] = the_cell
	end

	self.item_list[cell]:SetData(data_list[data_index + 1])
end

-----------------------------------------------------------------------------

MainUiActivityPreviewItem = MainUiActivityPreviewItem or BaseClass(BaseCell)

function MainUiActivityPreviewItem:LoadCallBack(instance)
	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MainUiActivityPreviewItem:__delete()

end

function MainUiActivityPreviewItem:OnFlush()
	if nil == self.data then
		return
	end
	local act_state_icon = "act_end_icon"
	local time_str = (self.data.act_id ~= ACTIVITY_TYPE.MOSHEN) and self.data.open_time .. "-" .. self.data.end_time or self.data.open_time
	if self.data.state == ActivityData.ActState.OPEN then
		self.node_list["TxtActTime"]:SetActive(true)
		act_state_icon = "start1"
	elseif self.data.state == ActivityData.ActState.WAIT then
		act_state_icon = "act_notstart_icon"
	else
		time_str = string.format(Language.Common.ToColor, TEXT_COLOR.GRAY, time_str)
	end
	self.node_list["TxtActName"].text.text = self.data.act_name
	local bundle, asset = ResPath.GetActivityRawimage(self.data.act_type, self.data.act_id)
	self.node_list["Act_image"].raw_image:LoadSpriteAsync(bundle, asset)
	self.node_list["label"].image:LoadSpriteAsync(ResPath.GetActivityview(act_state_icon))

	if time_str ~= "" then
		self.node_list["TxtActName"].text.text = self.data.act_name
		self.node_list["TxtActTime"].text.text = time_str
	end
end

function MainUiActivityPreviewItem:OnClick()
	if nil == self.data then
		return
	end
	if self.data.act_id == ACTIVITY_TYPE.MOSHEN then 
		ViewManager.Instance:Open(ViewName.Boss, TabIndex.world_boss)
	elseif self.data.act_id == ACTIVITY_TYPE.KF_GUILDBATTLE then
		ViewManager.Instance:Open(ViewName.KuaFuBattle)
	elseif self.data.act_id == ACTIVITY_TYPE.Triple_LiuJie then
		ViewManager.Instance:Open(ViewName.KuaFuBattle)
	else
		ActivityCtrl.Instance:ShowDetailView(self.data.act_id)
	end
end
