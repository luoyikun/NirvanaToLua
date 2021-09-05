WeddingInviteView = WeddingInviteView or BaseClass(BaseView)

function WeddingInviteView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","MarryInviteView"},}
	self.cell_list = {}
	self.cell_list_2 = {}

	self.scroller_data = {}
	self.scroller_data_2 = {}
	self.is_modal = true
	self.tab_index = 1
end

function WeddingInviteView:ReleaseCallBack()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.cell_list_2 then
		for k,v in pairs(self.cell_list_2) do
			v:DeleteMe()
		end
	end
	self.cell_list_2 = {}
end

function WeddingInviteView:__delete()

	self.scroller_data = {}
	self.scroller_data_2 = {}
end

function WeddingInviteView:LoadCallBack()

	self.node_list["Btnfriend"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self, INVITE_TYPE.FRIEND))
	self.node_list["Btnguild"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self, INVITE_TYPE.GUILD))
	self.node_list["Btnother"].toggle:AddClickListener(BindTool.Bind(self.OnToggleChange, self, INVITE_TYPE.OTHER))

	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.AddPeople, self))

	--邀请列表
	local list_delegate_1 = self.node_list["ListView_1"].list_simple_delegate
	list_delegate_1.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells_1, self)
	list_delegate_1.CellRefreshDel = BindTool.Bind(self.RefreshTimeListView_1, self)

	--已邀请列表
	local list_delegate_2 = self.node_list["ListView_2"].list_simple_delegate
	list_delegate_2.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells_2, self)
	list_delegate_2.CellRefreshDel = BindTool.Bind(self.RefreshTimeListView_2, self)

	self:OnToggleChange(INVITE_TYPE.FRIEND)
end

function WeddingInviteView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_GET_YUYUE_INFO)
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_APPLICANT_INFO)
	self:Flush()
end

function WeddingInviteView:ShowIndexCallBack(index)
	if index == INVITE_TYPE.FRIEND then
		self.node_list["Btnfriend"].toggle.isOn = true
	elseif index == INVITE_TYPE.GUILD then
		self.node_list["Btnguild"].toggle.isOn = true
	elseif index == INVITE_TYPE.OTHER then
		self.node_list["Btnother"].toggle.isOn = true
	end
	self:OnToggleChange(index)
end

function WeddingInviteView:OnToggleChange(index)
		self.tab_index = index
		if index == INVITE_TYPE.FRIEND then
			self.scroller_data = MarriageData.Instance:GetinviteList(INVITE_TYPE.FRIEND)
		elseif index == INVITE_TYPE.GUILD then
			self.scroller_data = MarriageData.Instance:GetinviteList(INVITE_TYPE.GUILD)
		elseif index == INVITE_TYPE.OTHER then
			self.scroller_data = MarriageData.Instance:GetinviteList(INVITE_TYPE.OTHER)
		end
		
		self:FlushInviteList()
end

function WeddingInviteView:OnClickClose()
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.MarryInvite, false)
	self:Close()
end

function WeddingInviteView:AddPeople()

	local function ok_callback()
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_BUY_GUEST_NUM) 	--购买宾客数量
		self:FlushInviteList()
	end
	local money = MarriageData.Instance:GetMarryGoldPeople()
	local str = string.format(Language.Marriage.AddInviteTip1, money)

	TipsCtrl.Instance:ShowCommonAutoView("invite_view", str, ok_callback)
end

function WeddingInviteView:GetNumberOfCells_1()
	if self.scroller_data == nil then
		return 0
	end
	 return #self.scroller_data or 0
end

function WeddingInviteView:RefreshTimeListView_1(cell, data_index)
	data_index = data_index + 1
	if self.cell_list[cell] == nil then
		self.cell_list[cell] = InviteGuestsItemCell.New(cell.gameObject)
		self.cell_list[cell].root_node.toggle.group = self.node_list["ListView_2"].toggle_group
	end
	local data = self.scroller_data[data_index]
	data.data_index = data_index
	self.cell_list[cell]:SetData(data)
end

function WeddingInviteView:GetNumberOfCells_2()
	if self.scroller_data_2 == nil then
		return 0
	end
	return #self.scroller_data_2 or 0
end

function WeddingInviteView:RefreshTimeListView_2(cell, data_index)
	data_index = data_index + 1
	if self.cell_list_2[cell] == nil then
		self.cell_list_2[cell] = InviteGuestsItemCell.New(cell.gameObject)
		self.cell_list_2[cell].root_node.toggle.group = self.node_list["ListView_1"].toggle_group
	end
	local data = self.scroller_data_2[data_index]
	data.data_index = data_index
	self.cell_list_2[cell]:SetData(data)
end

function WeddingInviteView:FlushInviteList()
	local yuyue_info = MarriageData.Instance:GetHunYanYuYueInfo()
	self.scroller_data_2 = yuyue_info.data
	self:SetList(self.tab_index, self.scroller_data_2)

	self.node_list["TxtNum"].text.text = yuyue_info.have_invite_num .. "/" .. yuyue_info.have_max_num
	self.node_list["ListView_1"].scroller:ReloadData(0)
	self.node_list["ListView_2"].scroller:ReloadData(0)
end

function WeddingInviteView:OnFlush()
	self:FlushInviteList()
end

function WeddingInviteView:SetList(index, data)
	if index == INVITE_TYPE.FRIEND then
		self.scroller_data = MarriageData.Instance:FlushInviteListData(data)
	elseif index == INVITE_TYPE.GUILD then
		self.scroller_data = MarriageData.Instance:FlushGuildListData(data)
	elseif index == INVITE_TYPE.OTHER then
		self.scroller_data =  MarriageData.Instance:FlushApplyListData(data)
	end
end

-- function WeddingInviteView:AddInviteName(name)
-- 	self.is_invite_list[name] = true
-- end

-- function WeddingInviteView:GetIsInviteList()
-- 	return self.is_invite_list
-- end

--滚动条格子-------------------------------------
InviteGuestsItemCell = InviteGuestsItemCell or BaseClass(BaseCell)

function InviteGuestsItemCell:__init()

	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.InviteClick, self))
end

function InviteGuestsItemCell:__delete()

end

function InviteGuestsItemCell:OnFlush()
	local id = self.data.user_id or self.data.name
	local name = self.data.gamename or self.data.role_name or self.data.invite_name
	self.node_list["Name"].text.text = name
	-- self.node_list["BtnAdd"]:SetActive(self.data.invite_name == nil)
	local data = MarriageData.Instance:GetHunYanYuYueInfo().data
		self.node_list["BtnAdd"]:SetActive(true)
	for _,v in pairs(data) do
		if v.user_id == id then
			self.node_list["BtnAdd"]:SetActive(false)
			break
		end
	end
end

function InviteGuestsItemCell:InviteClick()
	local name = self.data.gamename or self.data.role_name or self.data.invite_name
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_INVITE_GUEST, self.data.user_id or self.data.uid)	
end