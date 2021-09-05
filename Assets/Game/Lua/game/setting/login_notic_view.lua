LoginNoticView = LoginNoticView or BaseClass(BaseView)

function LoginNoticView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/system_prefab", "Bulletin2"}}
	self.view_layer = UiLayer.Pop

	self.cur_index = 1
end

function LoginNoticView:__delete()
end

function LoginNoticView:LoadCallBack()
	self.cell_list = {}
	self.list_info = SettingData.Instance:GetNoticData() or {}

	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller:ReloadData(0)

	self.node_list["TitleText"].text.text = Language.Title.GongGao
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))

	self.node_list["BtnConfirm"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
end

function LoginNoticView:GetNumberOfCells()
	local list_num = GetListNum(self.list_info) or 0
	return list_num
end

function LoginNoticView:RefreshCell(cell, data_index)
	local list_cell = self.cell_list[cell]
	if nil == list_cell then
		list_cell = LoginNoticeItem.New(cell)
		self.cell_list[cell] = list_cell
	end

	data_index = data_index + 1
	list_cell:SetIndex(data_index)
	list_cell:ShowHl(self.cur_index)
	list_cell:SetClickCallBack(BindTool.Bind(self.ClickCallBcak, self, index))
	list_cell:SetData(self.list_info[data_index])
end

function LoginNoticView:ClickCallBcak(is_on, index)
	if self.cur_index == index then
		return
	end
	self.cur_index = index
	for k,v in pairs(self.cell_list) do
		if v then
			v:ShowHl(index)
		end
	end

	self:Flush()
end

function LoginNoticView:OpenCallBack()
	self:Flush()
end

function LoginNoticView:OnFlush()
	local data = SettingData.Instance:GetNoticData()

	if data[self.cur_index] then
		self.node_list["Text"].text.text = data[self.cur_index].content
		local rect = self.node_list["Text"]:GetComponent(typeof(UnityEngine.RectTransform))
		UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
		self.node_list["Scroll"].scroll_rect.verticalNormalizedPosition = 1
	end
end

function LoginNoticView:OnClickClose()
	self:Close()
end

function LoginNoticView:ReleaseCallBack()
	self.list_view = nil

	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end

	self.cur_index = 1
end

LoginNoticeItem = LoginNoticeItem or BaseClass(BaseCell)

function LoginNoticeItem:__init()
	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.callback = nil
end

function LoginNoticeItem:__delete()
	self.callback = nil
end

function LoginNoticeItem:OnClick()
	if self.callback then
		self.callback(self.index)
	end
end

function LoginNoticeItem:SetClickCallBack(callback)
	self.callback = callback
end

function LoginNoticeItem:OnFlush()
	if nil == self.data then
		return
	end

	self.node_list["TxtNomal"].text.text = self.data.notice_type
	self.node_list["TxtHight"].text.text = self.data.notice_type
end

function LoginNoticeItem:ShowHl(index)
	self.node_list["ImgNomal"]:SetActive(index ~= self.index)
	self.node_list["ImgHight"]:SetActive(index == self.index)
end