GuildMemberView = GuildMemberView or BaseClass(BaseRender)

function GuildMemberView:__init(instance)
	if instance == nil then
		return
	end
	self.toggle_group = instance:GetComponent("ToggleGroup")
	self.row = 5 -- 每一页有多少行，暂定为5行

	self.info_table = {}

	self.is_editor_state = false
	self.is_show_kick = false
	self.select_index = 0
	self.current_page = 1
	self.last_flush_page = 0
	self.select_member_data = {}
	self.select_member_list = {}
	self:InitFransfer()
	self.node_list["ButtonExitEditor"]:SetActive(false)
	self.node_list["ButtonKickOut"]:SetActive(false and self.is_show_kick)

	local parent = self.node_list["Panel"].transform
	local load_count = 0
	for i = 1, self.row do
		local info_cell = GuildMemberInfoCell.New(self.node_list["MemberInfo" .. i], self)
		info_cell:SetToggleGroup(self.toggle_group)
		info_cell:SetEditor(self.is_editor_state)
		info_cell:SetClickCallBack(BindTool.Bind(self.OnSelectMember, self))
		self.info_table[i] = info_cell
	end

	self.node_list["ButtonPageUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["ButtonPageDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
	self.node_list["ButtonKickOut"].button:AddClickListener(BindTool.Bind(self.OnClickBundleKickOut, self))
	self.node_list["ButtonEditor"].button:AddClickListener(BindTool.Bind(self.OnClickEditor, self))
	self.node_list["ButtonExitEditor"].button:AddClickListener(BindTool.Bind(self.OnClickExitEditor, self))
end

function GuildMemberView:__delete()
	for k,v in pairs(self.info_table) do
		v:DeleteMe()
	end
	self.info_table = {}
	self.transfer_window = nil
end

-- 批量操作模式
function GuildMemberView:OnClickEditor()
	self.node_list["ButtonEditor"]:SetActive(false)
	self.node_list["ButtonExitEditor"]:SetActive(true and not self.is_show_kick)
	self.node_list["ButtonKickOut"]:SetActive(true and self.is_show_kick)

	self.is_editor_state = true
	self.select_member_list = {}
	for k,v in pairs(self.info_table) do
		v:SetEditor(true)
	end
	self:Flush()
end

function GuildMemberView:OnClickExitEditor()
	self.node_list["ButtonEditor"]:SetActive(true and not self.is_show_kick)
	self.node_list["ButtonExitEditor"]:SetActive(false)
	self.node_list["ButtonKickOut"]:SetActive(false and self.is_show_kick)
	self.is_editor_state = false
	for k,v in pairs(self.info_table) do
		v:SetEditor(false)
	end
	self:ResetToggle()
	self:Flush()
end

function GuildMemberView:Flush()
	local post = GuildData.Instance:GetGuildPost()
	if post == -1 then return end
	self.node_list["ButtonExitEditor"]:SetActive(self.is_editor_state)
	self.node_list["ButtonKickOut"]:SetActive(self.is_editor_state and self.is_show_kick)
	if GuildDataConst.GUILD_POST_WEIGHT[post] >= GuildDataConst.GUILD_POST_WEIGHT[GuildDataConst.GUILD_POST.ZHANG_LAO] then
		if not self.is_editor_state then
			self.node_list["ButtonEditor"]:SetActive(true and not self.is_show_kick)
		else
			self.node_list["ButtonExitEditor"]:SetActive(true and not self.is_show_kick)
		end
	else
		self.node_list["ButtonEditor"]:SetActive(false)
		for k,v in pairs(self.info_table) do
			v:SetEditor(false)
		end
		self.is_editor_state = false
	end
	if #self.select_member_list > 0 then

		self.node_list["ButtonKickOut"]:SetActive(self.is_editor_state and true)
		self.is_show_kick = true
	else
		self.node_list["ButtonKickOut"]:SetActive(self.is_editor_state and false)
		self.is_show_kick = false
	end

	self.info_list = GuildDataConst.GUILD_MEMBER_LIST.list or {}
	if self.is_editor_state then
		local temp_list = {}
		for k,v in pairs(self.info_list) do
			if GuildDataConst.GUILD_POST_WEIGHT[post] > GuildDataConst.GUILD_POST_WEIGHT[v.post] then
				table.insert(temp_list, v)
			end
		end
		self.info_list = temp_list
	end
	self:FlushPageCount()
	-- 刷新当前页
	self.current_page = self.page_count >= self.current_page and self.current_page or self.page_count
	self:FlushPage(self.current_page)
end

-- 刷新页面数目
function GuildMemberView:FlushPageCount()
	self.info_count = #self.info_list
	self.page_count = self.info_count / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

function GuildMemberView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildMemberView:DoPanelTweenPlay()
	UITween.MoveAlpahShowPanel(self.node_list["TopContent"], GuildData.MemberTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], GuildData.MemberTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

-- 更新页面
function GuildMemberView:FlushPage(page)
	if (page > self.page_count or page < 1) then		--or not self.is_load then
		return
	end
	if not self.is_editor_state or self.last_flush_page ~= page then
		self:ResetToggle()
	end
	self.last_flush_page = page
	self.current_page = page

	self.node_list["Pages"].text.text = self.current_page .. "/" .. self.page_count

	for i = 1, self.row do
		local index = (page - 1) * self.row + i
		local is_active = index <= self.info_count
		self.info_table[i]:SetActive(is_active)

		if is_active then
			local info = self.info_list[index]
			if info then
				info.has_chose = self:IsHasChose(info.uid)
				if self.info_table[i] then
					self.info_table[i]:SetData(info)
				end
			end
		end
	end
end

-- 是否已经选中
function GuildMemberView:IsHasChose(uid)
	for k,v in pairs(self.select_member_list) do
		if v.uid == uid then
			return true
		end
	end
	return false
end

-- 重置Toggle
function GuildMemberView:ResetToggle()
	for k,v in pairs(self.info_table) do
		-- 这里为了在翻页的时候记录上一页的数据
		v.toggle.isOn = false
		v:AddClickListen()
	end
end

-- 向上翻页
function GuildMemberView:OnPageUp()
	self.current_page = self.current_page - 1
	self.current_page = self.current_page < 1 and 1 or self.current_page
	self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildMemberView:OnPageDown()
	self.current_page = self.current_page + 1
	self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
	self:FlushPage(self.current_page)
end

-- 选择成员
function GuildMemberView:OnSelectMember(data, state)
	if data then
		self.select_member_data = data
		if self.is_editor_state then
			self:AddMember(data, state)
		else
			self:ShowDetails(data, state)
		end
	end
end

-- 添加选中成员
function GuildMemberView:AddMember(data, state)
	if state then
		if not self:IsHasChose(data.uid) then
			table.insert(self.select_member_list, data)
		end
	else
		for k,v in pairs(self.select_member_list) do
			if v.uid == data.uid then
				table.remove(self.select_member_list, k)
				break
			end

		end
	end

	if #self.select_member_list > 0 then
		
		self.node_list["ButtonKickOut"]:SetActive(self.is_editor_state and true)
		self.node_list["ButtonExitEditor"]:SetActive(self.is_editor_state and false)
		self.is_show_kick = true
	else
		
		self.node_list["ButtonKickOut"]:SetActive(self.is_editor_state and false)
		self.node_list["ButtonExitEditor"]:SetActive(self.is_editor_state and true)
		self.is_show_kick = false
	end
end

-- 弹出信息
function GuildMemberView:ShowDetails(data, state)
	if state then
		if data.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
			local info = GuildData.Instance:GetGuildMemberInfo()
			if info then
				local detail_type = ScoietyData.DetailType.Default
				if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
					detail_type = ScoietyData.DetailType.GuildTuanZhang
				elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
					detail_type = ScoietyData.DetailType.Guild
				end
				ScoietyCtrl.Instance:ShowOperateList(detail_type, self.select_member_data.role_name,
				 nil,function() self:ResetToggle() end)
			end
		end
	end
end

-- 关闭所有弹窗
function GuildMemberView:CloseAllWindow()
	self.is_editor_state = false
	self.select_member_list = {}
	self:ResetToggle()
	for k,v in pairs(self.info_table) do
		v:SetEditor(false)
	end
end

-- 批量踢出公会
function GuildMemberView:OnClickBundleKickOut()
	local count = #self.select_member_list or 0
	if count > 0 then
		local describe = ""
		if count > 3 then
			describe = string.format(Language.Guild.KickoutMemberBundleTip4, self.select_member_list[1].role_name, self.select_member_list[2].role_name, self.select_member_list[3].role_name, count)
		elseif count > 2 then
			describe = string.format(Language.Guild.KickoutMemberBundleTip3, self.select_member_list[1].role_name, self.select_member_list[2].role_name, self.select_member_list[3].role_name)
		elseif count > 1 then
			describe = string.format(Language.Guild.KickoutMemberBundleTip2, self.select_member_list[1].role_name, self.select_member_list[2].role_name)
		else
			describe = string.format(Language.Guild.KickoutMemberBundleTip1, self.select_member_list[1].role_name)
		end
		local yes_func = function()
			local member_list = {}
			for k,v in pairs(self.select_member_list) do
				table.insert(member_list, v.uid)
			end
			GuildCtrl.Instance:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, count, member_list)
			self.select_member_list = {}
			self:ResetToggle()
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSelectRole)
	end
end

function GuildMemberView:OnClickKickout(uid, name)
	local _uid = uid or self.select_member_data.uid
	local _name = name or self.select_member_data.role_name
	local describe = string.format(Language.Guild.KickoutMemberBundleTip1, _name)
	local yes_func = BindTool.Bind(self.OnKickoutMemberHandler, self, _uid)
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 踢出仙盟二次确认
function GuildMemberView:OnKickoutMemberHandler(uid)
	if nil ~= uid then
		GuildCtrl.Instance:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, 1, {uid})
	end
end

function GuildMemberView:OnClickChangePost()
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG then
		for i = 1, 5 do
			self.node_list["ButtonTransfer" .. i]:SetActive(true)
		end
	elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		for i = 1, 4 do
			self.node_list["ButtonTransfer" .. i]:SetActive(true)
		end
	elseif post == GuildDataConst.GUILD_POST.ZHANG_LAO then
		for i = 1, 3 do
			self.node_list["ButtonTransfer" .. i]:SetActive(true)
		end
	else
		for i = 1, 5 do
			self.node_list["ButtonTransfer" .. i]:SetActive(false)
		end
	end
	self.node_list["Name"].text.text = self.select_member_data.role_name
	self.select_post = 1
	self.node_list["PostName"].text.text = Language.Guild.PuTong
	self.transfer_window:SetActive(true)
end

function GuildMemberView:OnClickTransfer(uid, name)
	local _uid = uid or self.select_member_data.uid
	local _name = name or self.select_member_data.role_name
	local describe = string.format(Language.Guild.ConfirmTransferMengZhuTip, _name)
	TipsCtrl.Instance:ShowCommonAutoView("", describe,
		function()
			GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, _uid, GuildDataConst.GUILD_POST.TUANGZHANG)
		end)
end

function GuildMemberView:InitFransfer()
	self.transfer_window = self.node_list["Transfer"]
	for i = 1, 5 do
		self.node_list["ButtonTransfer" .. i].button:AddClickListener(function() self:ClickTransfer(i) end)

	end
	self.node_list["ButtonYes"].button:AddClickListener(BindTool.Bind(self.ClickOK, self))

end

function GuildMemberView:ClickTransfer(index)
	if index == 1 then
		self.select_post = GUILD_POST.FU_TUANGZHANG

		self.node_list["PostName"].text.text = Language.Guild.FuMengZhu
	elseif index == 2 then
		self.select_post = GUILD_POST.ZHANG_LAO

		self.node_list["PostName"].text.text = Language.Guild.ZhangLao
	elseif index == 3 then
		self.select_post = GUILD_POST.HUFA
		self.node_list["PostName"].text.text = Language.Guild.HuFa
	elseif index == 4 then
		self.select_post = GUILD_POST.JINGYING

		self.node_list["PostName"].text.text = Language.Guild.JingYing
	elseif index == 5 then
		self.select_post = GUILD_POST.CHENG_YUAN
		self.node_list["PostName"].text.text = Language.Guild.PuTong
	end
end

function GuildMemberView:ClickOK()
	local uid = self.select_member_data.uid
	GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, uid, self.select_post)
end

-----------------------------------------------MemberInfoCell------------------------------------------------------

GuildMemberInfoCell = GuildMemberInfoCell or BaseClass(BaseCell)

function GuildMemberInfoCell:__init(instance, parent)
	if instance == nil then
		return
	end
	self.parent = parent
	self.toggle = self.root_node:GetComponent("Toggle")

	self:AddClickListen()
end

function GuildMemberInfoCell:SetToggleGroup(toggle_group)
	self.toggle_group = toggle_group
	self.toggle.group = toggle_group
end

function GuildMemberInfoCell:SetEditor(is_editor)
	self.node_list["HightLight"]:SetActive(not is_editor)
	self.node_list["ImgSelect"]:SetActive(is_editor)
	if is_editor then
		self.toggle.group = nil
	else
		self.toggle.group = self.toggle_group
	end
end

function GuildMemberInfoCell:OnClick(state)
	if self.click_callback then
		self.click_callback(self.data, state)
	end


end

function GuildMemberInfoCell:AddClickListen()
	self.node_list["MemberInfo"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClick, self))

end

function GuildMemberInfoCell:ClearClickListen()
	--self:ClearEvent("OnClick")
end

function GuildMemberInfoCell:OnFlush()
	if self.data then

		self.node_list["SexMale"]:SetActive(self.data.sex == 1)
		self.node_list["SexFmale"]:SetActive(self.data.sex == 0)

		self.node_list["Name"].text.text = self.data.role_name

		self.node_list["Job"].text.text = GuildData.Instance:GetGuildPostNameByPostId(self.data.post)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
		-- self.node_list["Level"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
		self.node_list["Level"].text.text = PlayerData.GetLevelString(self.data.level)
		self.node_list["FightPoint"].text.text = self.data.capability
		self.node_list["Contribution"].text.text = self.data.gongxian
		local is_online = self.data.is_online
		if(is_online ~= 0) then
			
			self.node_list["LastOnline"].text.text = Language.Common.OnLine
			UI:SetGraphicGrey(self.node_list["SexMale"], false)
			UI:SetGraphicGrey(self.node_list["SexFmale"], false)
			UI:SetGraphicGrey(self.node_list["Name"], false)
			UI:SetGraphicGrey(self.node_list["Job"], false)
			UI:SetGraphicGrey(self.node_list["Level"], false)
			UI:SetGraphicGrey(self.node_list["FightPoint"], false)
			UI:SetGraphicGrey(self.node_list["Contribution"], false)
			UI:SetGraphicGrey(self.node_list["LastOnline"], false)
		else

			UI:SetGraphicGrey(self.node_list["SexMale"], true)
			UI:SetGraphicGrey(self.node_list["SexFmale"], true)
			UI:SetGraphicGrey(self.node_list["Name"], true)
			UI:SetGraphicGrey(self.node_list["Job"], true)
			UI:SetGraphicGrey(self.node_list["Level"], true)
			UI:SetGraphicGrey(self.node_list["FightPoint"], true)
			UI:SetGraphicGrey(self.node_list["Contribution"], true)
			UI:SetGraphicGrey(self.node_list["LastOnline"], true)
			local now_time = TimeCtrl.Instance:GetServerTime()  -- 服务器的当前时间
			local last_login_time = self.data.last_login_time
			local t_time = TimeUtil.Timediff(now_time,last_login_time)
			local last_time = self:LastLoginTime(t_time)

			self.node_list["LastOnline"].text.text = last_time
		end
		if self.data.has_chose then
			self.toggle.isOn = true
		else
			self.toggle.isOn = false
		end
	end
end

-- 通过相差的时间，返回合适的时间
function GuildMemberInfoCell:LastLoginTime(t_time)
	local last_time = ""
	if t_time.year ~= 0 then
		last_time = string.format(Language.Common.BeforeXXYear, t_time.year)
		return last_time
	end
	if t_time.month ~= 0 then
		string.format(Language.Common.BeforeXXMonth, t_time.month)
		return last_time
	end
	if t_time.day ~= 0 then
		last_time = string.format(Language.Common.BeforeXXDay, t_time.day)
		return last_time
	end
	if t_time.hour ~= 0 then
		last_time = string.format(Language.Common.BeforeXXHour, t_time.hour)
		return last_time
	end
	if t_time.min ~= 0 then
		last_time = string.format(Language.Common.BeforeXXMinute, t_time.min)
		return last_time
	end
	last_time = string.format(Language.Common.BeforeXXSecond, t_time.sec)
	return last_time
end
