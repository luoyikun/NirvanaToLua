QuickDelView = QuickDelView or BaseClass(BaseView)
function QuickDelView:__init()
	self.ui_config = {{"uis/views/scoietyview_prefab", "QuickClearView"}}
	self.is_modal = true
	self.is_any_click_close = true
end

function QuickDelView:__delete()

end

function QuickDelView:ReleaseCallBack()

	self.is_intimacy = nil
	self.is_lev = nil
	self.is_offline = nil
end

function QuickDelView:LoadCallBack()
	self.is_intimacy = true
	self.is_lev = true
	self.is_offline = true

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClickClear"].button:AddClickListener(BindTool.Bind(self.ClickClear, self))
	self.node_list["InputIntimacy"].button:AddClickListener(BindTool.Bind(self.ClickInput, self, 1))
	self.node_list["InputLev"].button:AddClickListener(BindTool.Bind(self.ClickInput, self, 2))
	self.node_list["InputDay"].button:AddClickListener(BindTool.Bind(self.ClickInput, self,3))

	self.node_list["AutoKickToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnClickAutoKick, self))

	self.node_list["AutoKickToggle"].isOn = ScoietyData.Instance:GetIsAutoDef() == 1
end

function QuickDelView:OpenCallBack()
	self.node_list["CheckIntimacy"].toggle.isOn = true
	self.node_list["CheckFriendLev"].toggle.isOn = true
	self.node_list["CheckOffLine"].toggle.isOn = true
end

function QuickDelView:CloseWindow()
	self:Close()
end

function QuickDelView:CloseCallBack()

end

function QuickDelView:ChangeInput(param, text)
	if param == 1 then
		self.node_list["TxtPlaceholder"].text.text = text
	elseif param == 2 then
		self.node_list["TxtInputLev"].text.text = text
	elseif param == 3 then
		self.node_list["TxtInputDay"].text.text = text
	end
end

function QuickDelView:ClickInput(param)
	local max_num = 9999
	local normal_str = ""
	if param == 1 then
		normal_str = self.node_list["TxtPlaceholder"].text.text
	elseif param == 2 then
		max_num = 1000
		normal_str = self.node_list["TxtInputLev"].text.text
	elseif param == 3 then
		normal_str = self.node_list["TxtInputDay"].text.text
	end
	TipsCtrl.Instance:OpenCommonInputView(normal_str, BindTool.Bind(self.ChangeInput, self, param), nil, max_num)
end

function QuickDelView:ClickClear()

	if not self.is_intimacy and not self.is_lev and not self.is_offline then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IsSelectNull)
		return
	end

	if self.node_list["TxtPlaceholder"].text.text == "" and self.is_intimacy then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.IntimacyDes)
		return
	elseif self.node_list["TxtInputLev"].text.text == "" and self.is_lev then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.LevDes)
		return
	elseif self.node_list["TxtInputDay"].text.text == "" and self.is_offline then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.OfflineDes)
		return
	end

	local friend_info = ScoietyData.Instance:GetFriendInfo()
	if not next(friend_info) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotFriendList)
		return
	end
	-- 提取符合条件的玩家
	local clear_list = {}
	for k,v in ipairs(friend_info) do
		local leave_time = math.ceil(TimeCtrl.Instance:GetServerTime()) - v.last_logout_timestamp
		local leave_day = math.floor((leave_time / 3600) / 24)
		local intimacy = self.node_list["TxtPlaceholder"].text.text
		local lev = self.node_list["TxtInputLev"].text.text
		local day = self.node_list["TxtInputDay"].text.text
		if (self.is_intimacy and v.intimacy < tonumber(intimacy)) or (self.is_lev and v.level < tonumber(lev)) or (self.is_offline and leave_day > tonumber(day)) then
			table.insert(clear_list, v)
		end
	end
	--没有符合条件的玩家
	if not next(clear_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotAccordFriend)
		return
	end
	-- 循环删除
	for k,v in ipairs(clear_list) do
		ScoietyCtrl.Instance:DeleteFriend(v.user_id)
	end
end

function QuickDelView:CheckIntimacy(ison)
	self.is_intimacy = ison
end

function QuickDelView:CheckFriendLev(ison)
	self.is_lev = ison
end

function QuickDelView:CheckOffLine(ison)
	self.is_offline = ison
end

function QuickDelView:OnClickAutoKick(switch)
	local flag = switch and 1 or 0
	ScoietyCtrl.Instance:SendOfflineFriendAutoDecFlag(flag)
	ScoietyData.Instance:SetIsAutoDef(flag)
end