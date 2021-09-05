WeddingDeMandView = WeddingDeMandView or BaseClass(BaseView)

function WeddingDeMandView:__init()
	self.ui_config = {{"uis/views/marriageview_prefab","InviteOtherView"},}

	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.hunyan_info = nil
end

function WeddingDeMandView:__delete()
	
end

function WeddingDeMandView:LoadCallBack()
	self.node_list["BtnJoin"].button:AddClickListener(BindTool.Bind(self.OnBtnWedding, self))
	self.node_list["Btndemand"].button:AddClickListener(BindTool.Bind(self.OnBtnDemand, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

end

function WeddingDeMandView:OnClickClose()
	self:Close()
end

function WeddingDeMandView:OpenCallBack()
	MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_GET_WEDDING_INFO)
	self:Flush()
end

function WeddingDeMandView:OnFlush()
	self.hunyan_info = MarriageData.Instance:GetHunYanCurAllInfo()
	self:SetHuYanInfo()
	self:SetMyHead()
	self:SetOtherHead()
end

function WeddingDeMandView:OnBtnDemand()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if role_id == self.hunyan_info.role_id or role_id == self.hunyan_info.lover_role_id then
		MarriageCtrl.Instance:OpenInviteView()
		self:Close()
	else
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_APPLY)
	end
end

function WeddingDeMandView:OnBtnWedding()
	local fb_key = MarriageData.Instance:GetFuBenKey()
	--这里暂时只发个1
	fb_key = 1 
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
	if activity_info.status == HUNYAN_STATUS.OPEN then
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		MarriageCtrl.Instance:SendMarryOpera(HUNYAN_OPERA_TYPE.HUNYAN_OPERA_TYPE_JOIN_HUNYAN, 1)
	elseif activity_info.status == HUNYAN_STATUS.XUNYOU then
		ViewManager.Instance:CloseAll()
		
		if MarriageData.Instance:IsMarryUser() then
			return
		end
		MarriageCtrl.Instance:SetMoveXuyou(true)
		local flag = PlayerData.Instance:GetRoleVo().sex == 0 and 3 or 2
		GuajiCtrl.Instance:SetMoveToPosCallBack(nil)
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_XUNYOU_OBJ_POS, flag)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.MarryNoOpen)
	end
end

function WeddingDeMandView:SetHuYanInfo()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local yuyue_time = MarriageData.Instance:GetYuYueTime(self.hunyan_info.cur_wedding_seq)
	local guild_id = MarriageData.Instance:GetHunYanCurAllInfo().guests_uid

	local begin1 = math.floor(yuyue_time.xunyou_end_time / 100)
	local begin2 = yuyue_time.xunyou_end_time % 100
	local end1 = math.floor(yuyue_time.end_time / 100)
	local end2 = yuyue_time.end_time % 100
	local str = ""

	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.WEDDING)
	str = MarriageData.Instance:GetShowXuyouTime(self.hunyan_info.cur_wedding_seq)

	if activity_info.status == HUNYAN_STATUS.OPEN then
		str = string.format("%02d:%02d - %02d:%02d", begin1, begin2, end1, end2)
		self.node_list["AgreeText"].text.text = Language.Marriage.AgreeHunliText
		str = string.format(Language.Marriage.DemandTips5, str)
	else
		self.node_list["AgreeText"].text.text = Language.Marriage.AgreeXunyouText
		str = string.format(Language.Marriage.DemandTips6, str)
	end
	self.node_list["Name_1"].text.text = self.hunyan_info.role_name
	self.node_list["Name_2"].text.text = self.hunyan_info.lover_role_name
	self.node_list["TxtDes1"].text.text = string.format(Language.Marriage.DemandTips1, ToColorStr(self.hunyan_info.wedding_index, TEXT_COLOR.YELLOW))

	self.node_list["TxtDes2"].text.text = string.format(Language.Marriage.DemandTips2, ToColorStr(self.hunyan_info.role_name, TEXT_COLOR.YELLOW), ToColorStr(self.hunyan_info.lover_role_name, TEXT_COLOR.YELLOW))
	self.node_list["TxtDes3"].text.text = string.format(Language.Marriage.DemandTips3)
	self.node_list["TxtDes4"].text.text = string.format(Language.Marriage.DemandTips4, 520, 1314, 3344)

	self.node_list["DesTime"].text.text = str

	local btn_str = ""
	if role_id == self.hunyan_info.role_id or role_id == self.hunyan_info.lover_role_id then
		btn_str = Language.Marriage.Invite
	else
		btn_str = Language.Marriage.Demand
	end

	for _,v in pairs(guild_id) do
		if role_id == v.user_id then
			UI:SetButtonEnabled(self.node_list["Btndemand"], false)
			btn_str = Language.Marriage.NoDemand
		end
	end
	self.node_list["Txtinvite"].text.text = btn_str

	MarriageData.Instance:SetIsShowBubble(false)
	MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
	UI:SetGraphicGrey(self.node_list["BtnJoin"], (activity_info.status ~= HUNYAN_STATUS.OPEN and activity_info.status ~= HUNYAN_STATUS.XUNYOU))
	UI:SetButtonEnabled(self.node_list["BtnJoin"], (activity_info.status == HUNYAN_STATUS.OPEN or activity_info.status == HUNYAN_STATUS.XUNYOU))
end

--设置我的头像
function WeddingDeMandView:SetMyHead()
	self.node_list["IconImage_1"]:SetActive(false)
	self.node_list["RawImage_1"]:SetActive(false)
	local user_id = 0
	local prof = 0
	local sex = 0
	if self.hunyan_info then
		user_id = self.hunyan_info.role_id
		prof = self.hunyan_info.role_prof or 0
	else
		local vo = GameVoManager.Instance:GetMainRoleVo()
		user_id = vo.role_id
		prof = vo.prof % 10
	end
	if prof < 3 then
		sex = 1
	end
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImage_1"], self.node_list["IconImage_1"], sex, prof, false)
end

--设置他人头像
function WeddingDeMandView:SetOtherHead()
	self.node_list["IconImage_2"]:SetActive(false)
	self.node_list["RawImage_2"]:SetActive(false)
	local user_id = 0
	local prof = 0
	local sex = 0
	if self.hunyan_info then
		user_id = self.hunyan_info.lover_role_id
		prof = (self.hunyan_info.lover_role_prof or 0) % 10
	end
	if prof < 3 then
		sex = 1
	end
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImage_2"], self.node_list["IconImage_2"], sex, prof, false)
end