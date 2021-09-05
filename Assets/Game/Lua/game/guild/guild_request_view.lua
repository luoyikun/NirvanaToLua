GuildRequestView = GuildRequestView or BaseClass(BaseRender)

function GuildRequestView:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["ButtonPageUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["ButtonPageDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
	self.node_list["ButtonFirstPage"].button:AddClickListener(BindTool.Bind(self.OnFirstPage, self))
	self.node_list["ButtonLastPage"].button:AddClickListener(BindTool.Bind(self.OnLastPage, self))
	--self.node_list["ButtonEnter"].button:AddClickListener(BindTool.Bind(self.OnPageJump, self))
	self.node_list["TextPage"].button:AddClickListener(BindTool.Bind(self.OnClickPageInput, self))
	self.node_list["ButtonCreat"].button:AddClickListener(BindTool.Bind(self.OnOpenCreatWindow, self))
	--self.node_list["InputField"].button:AddClickListener(BindTool.Bind(self.OnClickPageInput, self))
	self.node_list["ButtonSearch"].button:AddClickListener(BindTool.Bind(self.Search, self))
	self.node_list["ButtonReset"].button:AddClickListener(BindTool.Bind(self.Reset, self))
	self.node_list["ToggleAuto"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickAuto, self))
	self.node_list["AutoBtn"].button:AddClickListener(BindTool.Bind(self.AutoEnter, self))
	self.node_list["ButtonCreat2"].button:AddClickListener(BindTool.Bind(self.OnCreateGuildSuer, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Capability"])

	self.row = 5 -- 每一页有多少行，暂定为5行

	self.list_table = {}
	self.toggle_table = {}
	self.variables = {}
	self.toggle_group = self.node_list["Panel"]:GetComponent("ToggleGroup")


	self.search_input = self.node_list["SearchInput"]:GetComponent("InputField")

	self.auto_btn = self.node_list["AutoBtn"]

	self.creat_window_input = self.node_list["CreatInputField"]:GetComponent("InputField")



	local need_bind_gold = GuildData.Instance:GetGuildCreatBindGoldCount()

	self.node_list["TextCreatGuild1"].text.text = string.format(Language.Guild.CreateGuildByBindGold, need_bind_gold)

	self.is_search = false
	self.jump_page = 1

	self.last_join_time = 0
	self.join_cd = 3
	local other_cfg = GuildData.Instance:GetOtherConfig()
	if other_cfg then
		self.join_cd = other_cfg.atuo_join_guild_cd or 3
	end

	self.is_load = false

	local parent = self.node_list["Panel"].transform
	local load_count = 0

	for i = 1, self.row do
		local async_loader = AllocAsyncLoader(self, "req_info_item_loader_" .. i)
		async_loader:SetParent(parent)
		async_loader:Load("uis/views/guildview_prefab", "GuildRequestListInfo", function(obj)
			if IsNil(obj) then
				return
			end

			self.list_table[i] = U3DObject(obj)

			self.toggle_table[i] = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("Toggle"))
			self.toggle_table[i].toggle.group = self.toggle_group

			self.variables[i] = {}
			self.variables[i].has_request = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("Text"))

			self.variables[i].has_request2 = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("Button"))
			self.variables[i].guild_name = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("GuildName"))
			self.variables[i].master_name = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("HuiZhangName"))
			self.variables[i].guild_level = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("Level"))
			self.variables[i].member_count = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("MemberCount"))
			self.variables[i].total_fight_power = U3DObject(obj:GetComponent(typeof(UINameTable)):Find("FightPower"))

			U3DObject(obj:GetComponent(typeof(UINameTable)):Find("Button")).button:AddClickListener(function() self:OnJoinGuild(i) end)
			self.toggle_table[i].toggle:AddClickListener(function() self:OnSelectGuild() end)

			load_count = load_count + 1
			if load_count >= self.row then
				self.is_load = true
				self:Flush()
			end
		end)
	end
end

function GuildRequestView:__delete()
	self.fight_text = nil
	self.guild_list_view = nil
	self.toggle_group = nil
	self.search_input = nil
	self.auto_btn = nil
	self.creat_window_input = nil
end

function GuildRequestView:OpenCallBack()
	local left_pos = self.node_list["Left"].transform.anchoredPosition
	local right_pos = self.node_list["Right"].transform.anchoredPosition
	local soul_pos = self.node_list["Bottom"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["Left"], Vector3(left_pos.x, left_pos.y - 230, left_pos.z))
	UITween.MoveShowPanel(self.node_list["Right"], Vector3(right_pos.x + 420, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["Bottom"], Vector3(soul_pos.x, soul_pos.y - 100, soul_pos.z))
	
end

-- 刷新View
function GuildRequestView:Flush()
	local free_create_guild_times = GuildData.Instance:CreateFreeNum() or 0
	
	self.node_list["FreeNum"].text.text = string.format(Language.Guild.FreeCreateGuild, free_create_guild_times)
	if self.is_search then
		self.is_search = false
	else
		self.info_list = self:GetList()
	end
	local gold = GuildData.Instance:GetPlantNameGold(GLOBAL_CONFIG.package_info.config.agent_id)
	if gold > 0 then
		self.node_list["MoneyImg"]:SetActive(true)
		self.node_list["MoneyTxt"].text.text = gold
	else
		self.node_list["MoneyImg"]:SetActive(false)
	end

	self:FlushPageCount()
	self.current_page = 1
	self:FlushPage(self.current_page)
	self:FlushGuildDetails()
	if GuildData.Instance:IsCreateFree() then

		self.node_list["FreeNum"]:SetActive(true)
	else

		self.node_list["FreeNum"]:SetActive(false)
	end
end

-- 刷新页面数目
function GuildRequestView:FlushPageCount()
	self.info_count = self.info_list.count
	self.page_count = self.info_count / self.row
	self.page_count = math.ceil(self.page_count)
	if(self.page_count == 0) then
		self.page_count = 1
	end
end

-- 更新页面
function GuildRequestView:FlushPage(page)
	if(page > self.page_count or page < 1) or not self.is_load then
		return
	end
	self:ResetToggle()
	self.current_page = page
	self.node_list["TextPage"].text.text = self.current_page .. "/" .. self.page_count
	if(page == self.page_count) then  -- 如果是最后一页
		for i = 1, self.row do
			if(i <= page * self.row - self.info_count) then
				self.list_table[self.row + 1 - i]:SetActive(false)
			else
				self.list_table[self.row + 1 - i]:SetActive(true)
			end
		end
	else
		for i = 1, self.row do
			self.list_table[i]:SetActive(true)
		end
	end
	for i = (page - 1) * self.row + 1, page * self.row do
		if(i > self.info_count) then
			break
		end
		self:FlushRow(i)
	end
end

-- 更新每一行的信息
function GuildRequestView:FlushRow(index)
	if(index <= 0) or not self.is_load then
		return
	end
	local current_row = index % self.row
	if(current_row == 0) then
		current_row = self.row
	end

	local info = self.info_list.list[index]
	self.variables[current_row].guild_name.text.text = info.guild_name

	self.variables[current_row].master_name.text.text = info.tuanzhang_name

	self.variables[current_row].guild_level.text.text = info.guild_level

	self.variables[current_row].member_count.text.text = info.cur_member_count .. "/" .. info.max_member_count

	self.variables[current_row].total_fight_power.text.text = info.total_capability

	self.variables[current_row].has_request:SetActive(info.is_apply == 1)
	self.variables[current_row].has_request2:SetActive( info.is_apply ~= 1)
end

-- 重置Toggle
function GuildRequestView:ResetToggle()
	self.toggle_table[1].toggle.isOn = true
	self:OnSelectGuild()
end

function GuildRequestView:CreateGuildByItem()
	self:OnOpenCreatWindow()
	self.node_list["ToggleGuild2"].toggle.isOn = true
end
-- 向上翻页
function GuildRequestView:OnPageUp()
	self.current_page = self.current_page - 1
	self.current_page = self.current_page < 1 and 1 or self.current_page
	self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildRequestView:OnPageDown()
	self.current_page = self.current_page + 1
	self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
	self:FlushPage(self.current_page)
end

-- 跳转到首页
function GuildRequestView:OnFirstPage()
	self:FlushPage(1)
end

-- 跳转到尾页
function GuildRequestView:OnLastPage()
	self:FlushPage(self.page_count)
end

-- 跳转页面
function GuildRequestView:OnPageJump(index)
	local jump_num = tonumber(index)
	self:FlushPage(jump_num)

	self.node_list["JumpPage"].text.text = jump_num
end

-- 打开跳转窗口
function GuildRequestView:OnOpenJumpWindow()
	--self.node_list["JumpWindowList"]:SetActive(true)
	self.jump_page = self.current_page

	self.node_list["JumpPage"].text.text = self.jump_page
	TipsCtrl.Instance:OpenCommonInputView(self.jump_page, BindTool.Bind(self.PageInputEnd, self), nil, self.page_count)
end

-- 打开创建公会窗口
function GuildRequestView:OnOpenCreatWindow()
	self.node_list["CreatGuildWindow"]:SetActive(true)
	self:FlushCreatWindow()
	-- local guild_cfg = GuildData.Instance:GetGuildConfig()
	-- if guild_cfg and guild_cfg.other_config then
	-- 	local count = guild_cfg.other_config[1].create_coin_bind
	-- 	self.node_list["TextCreateCoin"].text.text = string.format(Language.Guild.TextCreateCoin, count)
	-- end
end

-- 刷新创建公会窗口
function GuildRequestView:FlushCreatWindow()
	self.creat_window_input.text = ""
	self.node_list["ToggleGuild1"].toggle.isOn = true
end

-- 选择公会
function GuildRequestView:OnSelectGuild()
	local index = 0
	for i = 1, self.row do
		if(self.toggle_table[i].toggle.isOn == true) then
			index = i
			break
		end
	end
	local info = self:GetInfoByIndex(index)
	if info then
		GuildCtrl.Instance:SendGuildInfoReq(info.guild_id)
	end
end

-- 申请加入公会
function GuildRequestView:OnJoinGuild(index)
	local info = self:GetInfoByIndex(index)
	if info then
		GuildCtrl.Instance:SendApplyForJoinGuildReq(info.guild_id)
		if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
			info.is_apply = 1
			self:FlushRow(index)
		end
	end
end

function GuildRequestView:GetInfoByIndex(index)
	local select_guild_index = (self.current_page - 1) * self.row + index
	return self.info_list.list[select_guild_index]
end

--是否确定创建公会
function GuildRequestView:OnCreateGuildSuer()
	local user_vo = GameVoManager.Instance:GetUserVo()
	local gold = GuildData.Instance:GetPlantNameGold(GLOBAL_CONFIG.package_info.config.agent_id)
	if(self.creat_window_input.text == "") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ShuRuXianMengMingZi)
		return
	end
	if gold > 0 then
		local describe = ""
		local yes_func = nil
		yes_func = BindTool.Bind(self.OnCreatGuild, self)
		describe = string.format(Language.Guild.ConfirmCreateGuild, gold)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		self:OnCreatGuild()
	end

end


-- 申请创建公会
function GuildRequestView:OnCreatGuild()

	local name = ""
	local guild_type = GuildCtrl.Instance.create_model.coin
	if(self.creat_window_input.text == "") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ShuRuXianMengMingZi)
		return
	else
		name = self.creat_window_input.text
	end
	if string.utf8len(name) > COMMON_CONSTS.GUILD_NAME_MAX then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildNameMaxLen)
		return
	end
	if ChatFilter.Instance:IsIllegal(name, true) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		return
	end
	local index = 0
	if(self.node_list["ToggleGuild1"].toggle.isOn == false) then   -- 使用建盟令创建
		guild_type = GuildCtrl.Instance.create_model.jianmengling
		local create_item_id = GuildData.Instance:GetOtherConfig().create_item_id
		index = ItemData.Instance:GetItemIndex(create_item_id)
	else -- 使用绑定钻石创建
		if not GuildData.Instance:IsCreateFree() then
			local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
			local need_bind_gold = GuildData.Instance:GetGuildCreatBindGoldCount()
			if bind_gold < need_bind_gold then
				local gold = GameVoManager.Instance:GetMainRoleVo().gold
				if bind_gold + gold < need_bind_gold then
					SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotBindGold)
					return
				end
			end
		end
			guild_type = GuildCtrl.Instance.create_model.coin
	end

		GuildCtrl.Instance:SendGuildBaseInfoReq(name, guild_type, index)

end

-- 关闭所有弹窗
function GuildRequestView:CloseAllWindow()
	self.node_list["CreatGuildWindow"]:SetActive(false)
end

-- 点击翻页输入框
function GuildRequestView:OnClickPageInput()
	TipsCtrl.Instance:OpenCommonInputView(self.jump_page, BindTool.Bind(self.OnPageJump, self), nil, self.page_count)
end

function GuildRequestView:PageInputEnd(str)
	local num = tonumber(str)
	if(num < 1) then
		num = 1
	elseif(num > self.page_count) then
		num = self.page_count
	end
	self.jump_page = num

	self.node_list["JumpPage"].text.text = self.jump_page
end

function GuildRequestView:Search()
	local str = self.search_input.text
	if not str or str == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ShuRuXianMengMingZi)
		return
	end

	local list = {}
	list.is_first = GuildDataConst.GUILD_INFO_LIST.is_first
	list.is_server_backed = GuildDataConst.GUILD_INFO_LIST.is_server_backed
	list.list = {}
	local count = 0
	local guild_list = GuildDataConst.GUILD_INFO_LIST.list
	for i = 1, GuildDataConst.GUILD_INFO_LIST.count do
		if nil ~= string.find(guild_list[i].guild_name, str) then
			table.insert(list.list, guild_list[i])
			count = count + 1
		end
	end
	list.count = count
	self.info_list = list
	self.is_search = true
	if count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSearch)
	end
	self:Flush()
end

function GuildRequestView:Reset()
	self:Flush()
end

function GuildRequestView:GetList()
	local list = {}
	list.is_first = GuildDataConst.GUILD_INFO_LIST.is_first
	list.is_server_backed = GuildDataConst.GUILD_INFO_LIST.is_server_backed
	list.list = {}
	local count = 0
	local guild_list = GuildDataConst.GUILD_INFO_LIST.list
	for i = 1, GuildDataConst.GUILD_INFO_LIST.count do
		if not self.node_list["ToggleAuto"].toggle.isOn or guild_list[i].applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS then
			table.insert(list.list, guild_list[i])
			count = count + 1
		end
	end
	list.count = count
	return list
end

function GuildRequestView:FlushGuildDetails()
	local info = GuildData.Instance:GetOtherGuildInfo()
	if info and next(info) then
		if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS then

			self.node_list["Level"]:SetActive(true)
			self.node_list["Capability"]:SetActive(true)
			self.node_list["Reminding"]:SetActive(false)
			self.node_list["Level1"].text.text = info.applyfor_need_level or 0
			if self.fight_text and self.fight_text.text then
				self.fight_text.text.text = info.applyfor_need_capability or 0
			end
		else
			self.node_list["Level"]:SetActive(false)
			self.node_list["Capability"]:SetActive(false)
			self.node_list["Reminding"]:SetActive(true)
			if info.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
				self.node_list["Reminding"].text.text = Language.Guild.NeedSupply
			else
				self.node_list["Reminding"].text.text = Language.Guild.RefuseSupply
			end
		end
		local guild_notice = info.guild_notice
		if guild_notice == nil or guild_notice == "" then
			guild_notice = Language.Guild.EmptyNotice
		end
		
		self.node_list["HelpText"].text.text = guild_notice
	else
		self:ClearDetails()
	end
end

function GuildRequestView:ClearDetails()

	self.node_list["Level1"].text.text = ""
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = ""
	end

	self.node_list["HelpText"].text.text = ""
	
	self.node_list["Level"]:SetActive(false)
	self.node_list["Capability"]:SetActive(false)
	self.node_list["Reminding"]:SetActive(true)
	
	self.node_list["Reminding"].text.text = Language.Common.ZanWu
end

function GuildRequestView:ClickAuto(switch)
	self:Flush()
end

function GuildRequestView:AutoEnter()
	if GuildDataConst.GUILD_INFO_LIST.count <= 0 then
		self:OnOpenCreatWindow()
		return
	end
	if self.last_join_time + self.join_cd <= Status.NowTime then
		self.last_join_time = Status.NowTime
		GuildCtrl.Instance:SendApplyForJoinGuildReq(0, 1)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CaoZuoTaiKuai)
	end
end

function GuildRequestView:GetAutoBtn()
	if self.node_list["AutoBtn"] then
		return self.node_list["AutoBtn"], BindTool.Bind(self.AutoEnter, self)
	end
end
