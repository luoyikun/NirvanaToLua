TipsCongratulationView = TipsCongratulationView or BaseClass(BaseView)
function TipsCongratulationView:__init()
	self.ui_config = {{"uis/views/congratulate_prefab", "CongratulationTip"}}
	self.view_layer = UiLayer.Pop
	self.is_auto = false
	self.play_audio = true
end

function TipsCongratulationView:LoadCallBack()
	self.node_list["ButtonClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnSendEgg"].button:AddClickListener(BindTool.Bind(self.SendEgg, self))
	self.node_list["BtnSendFlower"].button:AddClickListener(BindTool.Bind(self.SendFlower, self))

	self.node_list["Check"].toggle:AddValueChangedListener(BindTool.Bind(self.ChangeAuto, self))
	self.role_info_event = GlobalEventSystem:Bind(OtherEventType.RoleInfo, 
		BindTool.Bind(self.RoleInfoChange, self))
end

function TipsCongratulationView:ReleaseCallBack()
	if self.role_info_event then
		GlobalEventSystem:UnBind(self.role_info_event)
		self.role_info_event = nil
	end
	self.role_info = nil
end

function TipsCongratulationView:CloseCallBack()
	self.role_info = nil
end

function TipsCongratulationView:OpenCallBack()
	local friendid = CongratulationData.Instance:GetTips().uid
	CheckCtrl.Instance:SendQueryRoleInfoReq(friendid)
	self:Flush()
	CongratulationCtrl.Instance:SetTipShow()
end

function TipsCongratulationView:CloseWindow()
	self.is_auto = false
	CongratulationData.Instance:ClearTips()
	self:Close()
end

function TipsCongratulationView:SendFlower()
	CongratulationCtrl.Instance:SendReq(self.friendid, CONGRATULATION_TYPE.FLOWER)
	if self.is_auto then
		CongratulationData.Instance:SetAuto(self.is_auto, CONGRATULATION_TYPE.FLOWER)
	end
	self:CloseWindow()
end

function TipsCongratulationView:SendEgg()
	CongratulationCtrl.Instance:SendReq(self.friendid,CONGRATULATION_TYPE.EGG)
	if self.is_auto then
		CongratulationData.Instance:SetAuto(self.is_auto,CONGRATULATION_TYPE.EGG)
	end
	self:CloseWindow()
end

function TipsCongratulationView:OnFlush()
	self.tips_data = CongratulationData.Instance:GetTips()
	self.heli_type = self.tips_data.heli_type
	self.friendid = self.tips_data.uid
	self.param1 = self.tips_data.param1
	self.param2 = self.tips_data.param2	
	self:SetShowDec()
	self:FlushHead()
end

function TipsCongratulationView:SetShowDec()
	local friend_name = ScoietyData.Instance:GetFriendNameById(self.friendid)
	local context = self.node_list["decs"].rich_text

	if self.heli_type == SC_FRIEND_HELI_REQ_YTPE.SC_FRIEND_HELI_UPLEVEL_REQ then
		local des = string.format(Language.Congratulation.TipContext1, friend_name,self.param1)
		RichTextUtil.ParseRichText(context, des, nil, COLOR.WHITE, nil, nil, 24)
	elseif self.heli_type == SC_FRIEND_HELI_REQ_YTPE.SC_FRIEND_HELI_SKILL_BOSS_FETCH_EQUI_REQ then
		local boss_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.param1]
		local boss_name = boss_cfg.name
		local item_cfg,item_type = ItemData.Instance:GetItemConfig(self.param2)
		local item_name = item_cfg.name
		local des2 = string.format(Language.Congratulation.TipContext3,friend_name, self.param1, self.param2)
		RichTextUtil.ParseRichText(context, des2, nil, COLOR.WHITE, nil, nil, 24)
	end
end

function TipsCongratulationView:FlushHead()
	if self.role_info == nil then return end
	local user_id = self.friendid
	local prof =  ScoietyData.Instance:GetFriendInfoById(self.friendid).prof
	local sex = ScoietyData.Instance:GetFriendInfoById(self.friendid).sex
	AvatarManager.Instance:SetAvatarKey(user_id, self.role_info.avatar_key_big, self.role_info.avatar_key_small)

	AvatarManager.Instance:SetAvatar(user_id, self.node_list["raw_image_obj"], self.node_list["image_obj"], sex, prof, false)
end

function TipsCongratulationView:ChangeAuto(ison)
	self.is_auto = ison
end

--查看角色有变化时
function TipsCongratulationView:RoleInfoChange(role_id, role_info)
	if self.friendid == role_id then
		self.role_info = role_info
		self:Flush()
	end
end
