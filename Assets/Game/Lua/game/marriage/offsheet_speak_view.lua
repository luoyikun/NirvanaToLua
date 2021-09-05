OffSheetSpeakView = OffSheetSpeakView or BaseClass(BaseView)
local SEND_CD = 30
function OffSheetSpeakView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab", "OffSheetSpeakView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function OffSheetSpeakView:__delete()
	
end

function OffSheetSpeakView:ReleaseCallBack()
	for k, v in pairs(self.monomer_cell_list) do
		v:DeleteMe()
	end
	self.monomer_cell_list = {}
end

function OffSheetSpeakView:LoadCallBack()
	self.monomer_data = {}
	self.monomer_cell_list = {}
	self.node_list["OnlySexCheckBox"].toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckBoxChange, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["TuoDanBtn"].button:AddClickListener(BindTool.Bind(self.ClickTuoDan, self))
	local scroller_delegate = self.node_list["MonomerList"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end



function OffSheetSpeakView:OpenCallBack()
	self:Flush()
end

function OffSheetSpeakView:OnCheckBoxChange(isOn)
	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(isOn)
	self.node_list["MonomerList"].scroller:ReloadData(0)
end

function OffSheetSpeakView:GetNumberOfCell()
	return #self.monomer_data
end

function OffSheetSpeakView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local monomer_cell = self.monomer_cell_list[cell]
	if not monomer_cell then
		monomer_cell = TwoMonomerItemCell.New(cell.gameObject)
		self.monomer_cell_list[cell] = monomer_cell
	end
	monomer_cell:SetIndex(data_index)
	monomer_cell:SetData(self.monomer_data[data_index])
end

function OffSheetSpeakView:ReleaseCallBack()

end

function OffSheetSpeakView:ClickClose()
	self:Close()
end

function OffSheetSpeakView:ClickTuoDan()
	 MarriageCtrl.Instance:ShowMonomerView()
end

function OffSheetSpeakView:Flush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_uid <= 0 then
		local only_other_sex = self.node_list["OnlySexCheckBox"].toggle.isOn
		self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
		self.node_list["MonomerList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function OffSheetSpeakView:CancelTuoDanQuest()
	
end


-------------我要脱单ItemCell------------------------
TwoMonomerItemCell = TwoMonomerItemCell or BaseClass(BaseCell)

function TwoMonomerItemCell:__init()
	self.node_list["Btn"].button:AddClickListener(BindTool.Bind(self.ClickGood, self))
	self.node_list["ImgBg"].button:AddClickListener(BindTool.Bind(self.ClickHead, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtPowerNum"], "FightPower3")
end

function TwoMonomerItemCell:__delete()
	self.fight_text = nil
end

function TwoMonomerItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	if self.data.sex == 1 then
		self.node_list["Img"]:SetActive(false)
		self.node_list["Img1"]:SetActive(true)
	else
		self.node_list["Img"]:SetActive(true)
		self.node_list["Img1"]:SetActive(false)
	end

	self.node_list["Txt"].text.text = self.data.name
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data.capability
	end

	-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	-- local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.node_list["TxtLevel"].text.text = PlayerData.GetLevelString(self.data.level)
	self.node_list["TxtDes"].text.text = self.data.notice

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["Btn"]:SetActive(self.data.uid ~= main_vo.role_id)

	--设置头像
	local role_id = self.data.uid
	AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawImage"],self.node_list["ImgIcon"], self.data.sex, self.data.prof, false)

	self:StartCountDown()
end

--示好
function TwoMonomerItemCell:ClickGood()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
		return
	end

	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.uid) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.data.uid
		private_obj.username = self.data.name
		private_obj.sex = self.data.sex
		private_obj.prof = self.data.prof
		private_obj.avatar_key_small = self.data.avatar_key_small
		private_obj.level = self.data.level
		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end

	local text = MarriageData.Instance:GetTuoDanDes()

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = main_vo.role_id
	msg_info.username = main_vo.name
	msg_info.sex = main_vo.sex
	msg_info.camp = main_vo.camp
	msg_info.prof = main_vo.prof
	msg_info.authority_type = main_vo.authority_type
	msg_info.avatar_key_small = main_vo.avatar_key_small
	msg_info.level = main_vo.level
	msg_info.vip_level = main_vo.vip_level
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.content = text
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
	msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
	msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0--土豪金
	msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()--气泡框
	msg_info.is_read = 1
	
	ChatData.Instance:AddPrivateMsg(self.data.uid, msg_info)

	ChatCtrl.SendSingleChat(self.data.uid, text, CHAT_CONTENT_TYPE.TEXT)

	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.GoodSuccDes)

	--设置冷却时间
	MarriageData.Instance:AddSendGoodTimeList(self.data.uid)
	self:StartCountDown()
end

--开始倒计时
function TwoMonomerItemCell:StartCountDown()
	self:StopCountDown()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local last_send_time = MarriageData.Instance:GetSendGoodTime(self.data.uid) or 0
	local end_cd_time = last_send_time + 10
	if server_time >= end_cd_time then
		self.node_list["Txt1"]:SetActive(flase)
		self.node_list["TxtBtn"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["Btn"], true) 
		return
	end

	local function timer_func(elapse_time, total_time)
		if self.root_node == nil or IsNil(self.root_node.gameObject) then
			self:StopCountDown()
			return
		end
		if elapse_time >= total_time then
			self:StopCountDown()
			self.node_list["Txt1"]:SetActive(false)
		self.node_list["TxtBtn"]:SetActive(true)
		
		UI:SetButtonEnabled(self.node_list["Btn"], true) 
			return
		end
		local time = math.ceil(total_time - elapse_time)
		self.node_list["Txt1"].text.text = string.format(Language.Marriage.ResidueTime, time)		
		self.node_list["Txt1"]:SetActive(true)
		self.node_list["TxtBtn"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["Btn"], false) 
	end

	local left_time = math.ceil(end_cd_time - server_time)
	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	self.node_list["Txt1"].text.text = string.format(Language.Marriage.ResidueTime, left_time)
	self.node_list["Txt1"]:SetActive(true)
	self.node_list["TxtBtn"]:SetActive(false)
	
	UI:SetButtonEnabled(self.node_list["Btn"], false) 
end

--停止倒计时
function TwoMonomerItemCell:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TwoMonomerItemCell:ClickHead()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		return
	end
	local open_type = ScoietyData.DetailType.Default
	ScoietyCtrl.Instance:ShowOperateList(open_type, self.data.name)
end
