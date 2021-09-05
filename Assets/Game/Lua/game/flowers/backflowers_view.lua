BackFlowersView = BackFlowersView or BaseClass(BaseView)

function BackFlowersView:__init()
	self.ui_config = {{"uis/views/flowersview_prefab", "BackFlowers"}}
	self.full_screen = false
	self.play_audio = true
	self.role_infotable = {}
end

function BackFlowersView:__delete()

end

function BackFlowersView:LoadCallBack()
	self.node_list["ImgBgBt"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnChatBt"].button:AddClickListener(BindTool.Bind(self.ChosenChat, self))
	self.node_list["BtnBackBt"].button:AddClickListener(BindTool.Bind(self.ChosenBackFlower, self))
	
end

function BackFlowersView:ReleaseCallBack()
	self.backFlowersInfo = nil
end

function BackFlowersView:OpenCallBack()
	self:Flush()
end

function BackFlowersView:CloseCallBack()
end

function BackFlowersView:OnFlush()
	self.node_list["Txtinfo"].text.text = string.format(Language.Flower.ReceiveFlowerTxt,
		self.target_name, self.flower_name)
end

function BackFlowersView:CloseView()
	self:Close()
end

function BackFlowersView:ChosenChat()
	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
		return
	end
	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.role_infotable.role_id) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.role_infotable.role_id
		private_obj.username = self.role_infotable.role_name
		private_obj.sex = self.role_infotable.sex
		private_obj.camp = self.role_infotable.camp
		private_obj.prof = self.role_infotable.prof
		private_obj.avatar_key_small = self.role_infotable.avatar_key_small
		private_obj.level = self.role_infotable.level
		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end
	ChatData.Instance:SetCurrentId(self.role_infotable.role_id)

	if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat", {false, private_obj.role_id})
	else
		ViewManager.Instance:Open(ViewName.ChatGuild)
	end

	self:Close()
end

function BackFlowersView:SetRoleInfotable(info)
	self.role_infotable.role_id = info.role_id
	self.role_infotable.role_name = info.role_name
	self.role_infotable.sex = info.sex
	self.role_infotable.camp = info.camp
	self.role_infotable.prof = info.prof
	self.role_infotable.avatar_key_small = info.avatar_key_small
	self.role_infotable.avatar_key_big = info.avatar_key_big
	self.role_infotable.level = info.level
end

function BackFlowersView:ChosenBackFlower()
	FlowersCtrl.Instance:SetFriendInfo(self.role_infotable)
	ViewManager.Instance:Open(ViewName.Flowers)
	self:Close()
end

function BackFlowersView:SetInfo(backflowersinfo)
	self.from_uid = backflowersinfo.from_uid
	self.target_name = backflowersinfo.from_name
	self.item_cfg = ItemData.Instance:GetItemConfig(backflowersinfo.item_id)

	self.flower_name = self.item_cfg.name
	self.flower_num = backflowersinfo.flower_num
end
