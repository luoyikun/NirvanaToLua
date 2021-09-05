TipsEnterArenaView = TipsEnterArenaView or BaseClass(BaseView)

function TipsEnterArenaView:__init()
	self.ui_config = {{"uis/views/tips/arenatips_prefab", "EnterArenaTips"}}
	self.view_layer = UiLayer.Pop
	self.uid = nil
	self.user_data = nil
	self.is_modal = true
end

function TipsEnterArenaView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.ClickClose, self))
	self.node_list["BtnSure"].button:AddClickListener(BindTool.Bind(self.SendEnterArenaReq, self))

	self.alert = Alert.New()
end

function TipsEnterArenaView:ReleaseCallBack()
	-- 清理变量和对象
	self.user_data = nil
	self.uid = nil
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function TipsEnterArenaView:OpenCallBack()
	self:Flush()
end

function TipsEnterArenaView:OnFlush()
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(self.uid)
	local info = ArenaData.Instance:GetUserInfo()

	if tz_info then
		self.node_list["TxtName"].text.text = self.user_data.name
		self.node_list["TxtRank"].text.text = tz_info.rank
		self.node_list["TxtFightPower"].text.text = self.user_data.capability
		if info then
			local cur_reward = ArenaData.Instance:GetCurRanJieShuanShengWangByRank(tz_info.rank_pos)
			self.node_list["TxtHonor"].text.text = cur_reward
		end
	end
end

function TipsEnterArenaView:ClickClose()
	self:Close()
end

function TipsEnterArenaView:SendEnterArenaReq()
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(self.uid)
	if tz_info then
		local data = {}
		data.opponent_index = tz_info.index
		data.rank_pos = tz_info.rank_pos
		data.is_auto_buy = 0
		ArenaCtrl.Instance:ResetFieldFightReq(data)
	end
end

function TipsEnterArenaView:SetData(data)
	self.user_data = data
	self.uid = self.user_data.role_id
	self:Flush()
end