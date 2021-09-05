WeddingYuYueView = WeddingYuYueView or BaseClass(BaseView)

function WeddingYuYueView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","MarryAppointment"},}
	self.marry_yuyue_list = {}
	self.select_data = {}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.vew_cache_time = 0
end

function WeddingYuYueView:ReleaseCallBack()
	self.hunyan_type = nil
	self.select_data = {}
	if self.marry_yuyue_list then
		for k,v in pairs(self.marry_yuyue_list) do
			v:DeleteMe()
		end
	end
	self.marry_yuyue_list = {}

	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = {}
	end
end

function WeddingYuYueView:LoadCallBack()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTimeListView, self)

	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["ItemCell_" .. i])
		item:SetData(nil)
		table.insert(self.item_list, item)
		self.node_list["ItemCell_" .. i]:SetActive(false)
	end

	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["ButtonAppoint"].button:AddClickListener(BindTool.Bind(self.OnClickYuYue, self))
	self.node_list["ButtonInvite"].button:AddClickListener(BindTool.Bind(self.OnClickInvite, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.OnClickDesc, self))

	self:Flush()
end

function WeddingYuYueView:GetNumberOfCells()
	return #MarriageData.Instance:GetMarryYuYueCfg() or 0
end

--刷新ListView
function WeddingYuYueView:RefreshTimeListView(cell, data_index)
	data_index = data_index + 1
	local yuyue_cell = self.marry_yuyue_list[cell]
	if yuyue_cell == nil then
		yuyue_cell = AppointmentItemCell.New(cell.gameObject)
		yuyue_cell.root_node.toggle.group = self.node_list["ListView"].toggle_group
		yuyue_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.marry_yuyue_list[cell] = yuyue_cell
	end

	self.item_data = MarriageData.Instance:GetMarryYuYueCfg()
	yuyue_cell:SetIndex(data_index)
	yuyue_cell:SetData(self.item_data[data_index])
end

function WeddingYuYueView:OpenCallBack()
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_FLAG)
	self:Flush()
end

function WeddingYuYueView:OnClickClose()
	self:Close()
end

function WeddingYuYueView:OnClickItemCallBack(cell, select_index)
	if cell == nil or cell.data == nil then return end
	self.select_data = cell.data
	MarriageData.Instance:SetMarryTimeSeq(self.select_data.seq)
	for k, v in pairs(self.marry_yuyue_list) do
		v:ChangeHightLight()
	end
end

function WeddingYuYueView:OnClickYuYue()
	if self.select_data == nil or next(self.select_data) == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.YuYueTime)
		return
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local h = math.floor(self.select_data.apply_time / 100)
	local m = self.select_data.apply_time % 100
	local yuyue_time = os.time({year=time_table.year, month=time_table.month, day=time_table.day, hour=h, min=m, sec=0})
	if TimeCtrl.Instance:GetServerTime() > yuyue_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.YuYueTips5)
		return
	elseif self.select_data.is_yuyue == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NoYuYue)
		return
	end
	if 1 == is_online then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.WaitYuYue)
	end
	MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE, self.select_data.seq, self.hunyan_type)
end

function WeddingYuYueView:OnClickInvite()
	ViewManager.Instance:Open(ViewName.WeddingInviteView)	--邀请界面
end

function WeddingYuYueView:OnClickDesc()
	local tips_id = 282
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WeddingYuYueView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "my_yuyue" and self.node_list["ListView"] then
			self.node_list["ListView"].scroller:ReloadData(0)
		end
	end

	local my_name = PlayerData.Instance:GetRoleVo()
	if self.hunyan_type == nil then
		self.hunyan_type = MarriageData.Instance:GetSelectYanHuiType() or MarriageData.Instance:GetYuYueRoleInfo().marry_type
		self.node_list["Bg_Hunyan"].raw_image:LoadURLSprite(ResPath.GetHunyanRawImage(self.hunyan_type))
		self.node_list["WeddingType_1"]:SetActive(self.hunyan_type == 1)
		self.node_list["WeddingType_2"]:SetActive(self.hunyan_type == 2)
	else
		if self.hunyan_type < 0 then
			self.hunyan_type = 2
		end
		self.hunyan_type = MarriageData.Instance:GetSelectYanHuiType() or MarriageData.Instance:GetYuYueRoleInfo().marry_type
	end

	local reward_item_list = MarriageData.Instance:GetRewardItemData(self.hunyan_type)
	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()
	if my_name then
		self.node_list["RoleName"].text.text = my_name.name
		self.node_list["LoverName"].text.text = my_name.lover_name
		self.node_list["ButtonAppoint"]:SetActive(role_msg_info.param_ch4 <= 0)
		self.node_list["ButtonInvite"]:SetActive(role_msg_info.param_ch4 > 0)
		local str = role_msg_info.marry_count
		if str > 0 then
			str = ToColorStr(str, TEXT_COLOR.GREEN)
		else
			str = ToColorStr(str, TEXT_COLOR.RED)
		end
		self.node_list["WedingCount"].text.text = Language.Marriage.WeddingCount .. str
	end

	if reward_item_list == nil or next(reward_item_list) == nil then return end
	for k, v in pairs(reward_item_list) do
		if self.item_list[k+1] then
			self.item_list[k+1]:SetData(v)
			self.node_list["ItemCell_" .. (k + 1)]:SetActive(true)
		end
	end
end


----------AppointmentItemCell	婚宴预约时间段
AppointmentItemCell = AppointmentItemCell or BaseClass(BaseCell)

function AppointmentItemCell:__init()
	self.is_click = true
	self.node_list["AppointmentItem"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function AppointmentItemCell:OnClickItem()
	if nil ~= self.click_callback and self.is_click then
		self.click_callback(self)
	end
end

function AppointmentItemCell:__delete()

end

function AppointmentItemCell:OnFlush()
	if not self.data then return end

	self.node_list["Img_heart"]:SetActive(false)
	local begin1 = math.floor(self.data.apply_time / 100)
	local begin2 = self.data.apply_time % 100

	local end1 = math.floor(self.data.end_time / 100)
	local end2 = self.data.end_time % 100

	self.node_list["Time"].text.text = string.format("%02d:%02d - %02d:%02d", begin1, begin2, end1, end2)

	local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local h = math.floor(self.data.apply_time / 100)
	local m = self.data.apply_time % 100
	local yuyue_time = os.time({year=time_table.year, month=time_table.month, day=time_table.day, hour=h, min=m, sec=0})
	local role_msg_info = MarriageData.Instance:GetYuYueRoleInfo()
	local info = MarriageData.Instance:GetYuYueInfo()
	if self.data.is_yuyue == 1 then
		if TimeCtrl.Instance:GetServerTime() > yuyue_time then
			self.node_list["Txt_state2"].text.text = Language.Marriage.YuYueTips
			self.node_list["Txt_state"]:SetActive(false)
			self.node_list["Txt_state2"]:SetActive(true)			
			self.node_list["Bg"]:SetActive(false)
			self.is_click = false
		else
			self.node_list["Txt_state2"].text.text = Language.Marriage.YiYuYue
			self.node_list["Txt_state"]:SetActive(false)
			self.node_list["Txt_state2"]:SetActive(true)
			self.node_list["Bg"]:SetActive(false)
			self.is_click = false
		end
		if self.data.seq == role_msg_info.param_ch4 then
			self.node_list["Txt_state2"].text.text = Language.Marriage.MyYuYueTips
			self.node_list["Txt_state"]:SetActive(false)
			self.node_list["Txt_state2"]:SetActive(true)
			self.node_list["Bg"]:SetActive(true)
			self.node_list["Img_heart"]:SetActive(true)
			self.is_click = true
		end
	else
		if TimeCtrl.Instance:GetServerTime() > yuyue_time then
			self.node_list["Txt_state2"].text.text = Language.Marriage.YuYueTips
			self.node_list["Txt_state"]:SetActive(false)
			self.node_list["Txt_state2"]:SetActive(true)			
			self.node_list["Bg"]:SetActive(false)
			self.is_click = false
		else
			if info and info[64 - self.data.seq] and info[64 - self.data.seq] == 1 then
				self.node_list["Txt_state2"].text.text = Language.Marriage.YiYuYue
				self.node_list["Txt_state"]:SetActive(false)
				self.node_list["Txt_state2"]:SetActive(true)
				self.node_list["Bg"]:SetActive(false)
				self.is_click = false
			else
				self.node_list["Txt_state"]:SetActive(true)
				self.node_list["Txt_state2"]:SetActive(false)
				self.node_list["Bg"]:SetActive(true)
				self.is_click = true
			end
		end
	end
	self:ChangeHightLight()
end

function AppointmentItemCell:ChangeHightLight()
	self.node_list["HightLight"]:SetActive(self.data.seq == MarriageData.Instance:GetMarryTimeSeq())
end