TipsAddFriendView = TipsAddFriendView or BaseClass(BaseView)

function TipsAddFriendView:__init()
	self.ui_config = {{"uis/views/tips/addfriendtip_prefab", "AddFriendTip"}}
	self.view_layer = UiLayer.Pop

	self.name = ""
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
end

function TipsAddFriendView:__delete()

end

function TipsAddFriendView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.SureBtnOnClick, self))
end

function TipsAddFriendView:RenameOnChange()
	self.node_list["Input"].input_field.text = ""
	self.name = text
end

function TipsAddFriendView:ReleaseCallBack()

end

function TipsAddFriendView:SureBtnOnClick()
	local name = self.node_list["Input"].input_field.text
	local main_role = Scene.Instance:GetMainRole()
	local main_role_name = main_role.name

	if "" == name or ChatFilter.Instance:IsIllegal(name, true) then	-- 判断是否非法
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.AddPrivate)
	elseif main_role_name == name then						-- 判断是否自己
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotAddSelf)
	elseif ScoietyData.Instance:IsFriend(name) then		-- 判断是否好友
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyYouFriend)
	else
		self.check_name = name
		PlayerCtrl.Instance:CSFindRoleByName(name)
	end

end

function TipsAddFriendView:OpenCallBack()
	self.check_name = ""
	self.role_name_info = GlobalEventSystem:Bind(OtherEventType.ROLE_NAME_INFO, BindTool.Bind(self.ReqRoleInfo, self))
end

function TipsAddFriendView:CloseCallBack()
	self.check_name = ""

	if self.role_name_info then
		GlobalEventSystem:UnBind(self.role_name_info)
		self.role_name_info = nil
	end
end

function TipsAddFriendView:CloseWindow()
	self.node_list["Input"].input_field.text = ""
	self.name = ""
	self:Close()
end

function TipsAddFriendView:ReqRoleInfo(info)
	if info.role_name ~= "" and self.check_name ~= info.role_name then
		return
	end
	self.check_name = ""
	local role_id = info.role_id
	local is_online = info.is_online
	
	if 0 == role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.UserNotExist)
		return
	elseif 1 ~= is_online then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end

	ScoietyCtrl.Instance:AddFriendReq(role_id)
	self:Close()
end