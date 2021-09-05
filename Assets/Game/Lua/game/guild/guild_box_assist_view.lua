GuildAssistView = GuildAssistView or BaseClass(BaseView)

function GuildAssistView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_1"},
		{"uis/views/guildview_prefab", "AssistWindow"},
		{"uis/views/commonwidgets_prefab", "BaseThreePanel_2"},
	}
	self.is_modal = true
	self.is_any_click_close = true
end

-- 打开操作面板
function GuildAssistView:LoadCallBack()
	-- self.node_list["AutoToggle"].toggle:AddClickListener(BindTool.Bind(self.ClickAutoClear, self))
	-- self.node_list["ButtonClearTime"].button:AddClickListener(BindTool.Bind(self.ClickClearTime, self))
	self.node_list["Txt"].text.text = Language.Guild.AssistTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(791,540,0)
	self.node_list["Bg1"].rect.sizeDelta = Vector3(791,540,0)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["TextNoAssist"].text.text = ""
	self.node_list["Imagebox"].button:AddClickListener(BindTool.Bind(self.OnClickBox, self))
	
	self.other_config = GuildData.Instance:GetOtherConfig()
	self:InitScrollerAssist()
end

function GuildAssistView:__delate()
end

function GuildAssistView:ReleaseCallBack()
	for k,v in pairs(self.cell_list_assist) do
		v:DeleteMe()
	end
	self.cell_list_assist = {}

	-- if self.count_down then
	-- 	CountDown.Instance:RemoveCountDown(self.count_down)
	-- 	self.count_down = nil
	-- end

	self.enhanced_cell_type_assist = nil
	self.list_view_delegate_assist = nil
end

function GuildAssistView:OpenCallBack()
	self:Flush()
end

function GuildAssistView:OnClickBox()
		local config = GuildData.Instance:GetOtherConfig()
		if config then
			local reward = {{item_id = config.assist, num = config.number,is_bind = 1}}
			TipsCtrl.Instance:ShowRewardView(reward)
		end
end

-- function GuildAssistView:ClickAutoClear(state)
-- 	if state then
-- 		local des = Language.Guild.AutoClearTime
-- 		TipsCtrl.Instance:ShowCommonAutoView(nil, des, nil, function() self.node_list["AutoToggle"].toggle.isOn = false end)
-- 	end
-- end

-----------------------------------------------------------协助窗口----------------------------------------------------
--初始化滚动条
function GuildAssistView:InitScrollerAssist()
	self.cell_list_assist = {}
	self.list_view_delegate_assist = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/guildview_prefab", "AssistInfo", nil, function (obj)
		if nil == obj then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))

		self.enhanced_cell_type_assist = enhanced_cell_type
		self.node_list["ScrollerAssist"].scroller.Delegate = self.list_view_delegate_assist

		self.list_view_delegate_assist.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsAssist, self)
		self.list_view_delegate_assist.cellViewSizeDel = BindTool.Bind(self.GetCellSizeAssist, self)
		self.list_view_delegate_assist.cellViewDel = BindTool.Bind(self.GetCellViewAssist, self)
	end)
end

--滚动条数量
function GuildAssistView:GetNumberOfCellsAssist()
	local info = GuildData.Instance:GetAssistInfo()
	if info then
		if info.box_count > 0 then
			self.node_list["TextNoAssist"].text.text = ""
		else
			self.node_list["TextNoAssist"].text.text = Language.Guild.ZanWuXieZhu
		end
		return info.box_count
	end
	return 0
end

--滚动条大小
function GuildAssistView:GetCellSizeAssist(data_index)
	return 126
end

--滚动条刷新
function GuildAssistView:GetCellViewAssist(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type_assist)

	local cell = self.cell_list_assist[cell_view]
	if cell == nil then
		self.cell_list_assist[cell_view] = GuildAssistViewScrollAssistCell.New(cell_view)
		cell = self.cell_list_assist[cell_view]
		-- cell.sell_view = self
		cell:SetCallBack(BindTool.Bind(self.Flush, self))
		cell:ListenAllEvent()
	end
	local info = GuildData.Instance:GetAssistInfo().info_list
	table.sort(info, SortTools.KeyUpperSorter("box_level"))
	if info then
		local data = info[data_index + 1]
		if data then
			data.data_index = data_index
			cell:SetData(data)
		end
	end
	return cell_view
end

-- function GuildAssistView:OnClickAssist(info)
	
-- end

function GuildAssistView:OnFlush()
	if self.node_list["ScrollerAssist"].scroller.isActiveAndEnabled then
		self.node_list["ScrollerAssist"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	local rest_assist_count = GuildData.Instance:GetRestAssistCount()
	self.node_list["AssitCount"].text.text = rest_assist_count or 0
	-- self:FlushAssistTime()
	-- self:StartCountDown()
end

-- function GuildAssistView:StartCountDown()
-- 	if self.count_down then return end
-- 	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushAssistTime, self, nil))
-- end

-- function GuildAssistView:FlushAssistTime()
-- 	local now_time = TimeCtrl.Instance:GetServerTime()
-- 	local info = GuildData.Instance:GetBoxInfo()
-- 	local assist_info = GuildData.Instance:GetAssistInfo()
-- 	if info then
-- 		-- if info.assist_cd_end_time > now_time then
-- 		-- 	local t_time = TimeUtil.Timediff(info.assist_cd_end_time, now_time)
-- 		-- 	local min = t_time.min
-- 		-- 	local sec = t_time.sec
-- 		-- 	local hour = t_time.hour

-- 		-- 	self.min = min
-- 		-- 	self.sec = sec
-- 		-- 	self.hour = hour

-- 		-- 	local flag = false
-- 		-- 	if assist_info then
-- 		-- 		if assist_info.box_count > 0 then
-- 		-- 			if self.rest_assist_count > 0 then
-- 		-- 				local other_config = GuildData.Instance:GetOtherConfig()
-- 		-- 				if other_config then
-- 		-- 					local box_assist_cd_limit = other_config.box_assist_cd_limit
-- 		-- 					if box_assist_cd_limit then
-- 		-- 						if info.assist_cd_end_time - now_time > box_assist_cd_limit then
-- 		-- 							flag = true
-- 		-- 						end
-- 		-- 					end
-- 		-- 				end
-- 		-- 			else
-- 		-- 				flag = true
-- 		-- 			end
-- 		-- 		end
-- 		-- 	end

-- 		-- 	if min < 10 then
-- 		-- 		min = 0 .. min
-- 		-- 	end
-- 		-- 	if hour < 10 then
-- 		-- 		hour = 0 .. hour
-- 		-- 	end
-- 		-- 	if sec < 10 then
-- 		-- 		sec = 0 .. sec
-- 		-- 	end
-- 		-- 	local str = hour .. ":" .. min .. ":" .. sec
-- 		-- 	if flag then
-- 		-- 		str = ToColorStr(str, TEXT_COLOR.RED)
-- 		-- 	end
-- 		-- 	-- self.node_list["TimeText"].text.text = str
-- 		-- else
-- 		-- 	-- self.min = 0
-- 			-- self.sec = 0
-- 			-- self.hour = 0
-- 			-- local str = "00:00:00"
-- 			-- if assist_info then
-- 			-- 	if assist_info.box_count > 0 then
-- 			-- 		if self.rest_assist_count <= 0 then
-- 			-- 			str = ToColorStr(str, TEXT_COLOR.RED)
-- 			-- 		end
-- 			-- 	end
-- 			-- end
-- 			-- self.node_list["TimeText"].text.text = str
-- 		-- end
-- 	end
-- end

-- function GuildAssistView:ClickClearTime()
-- 	if self.rest_assist_count <= 0 then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxAssist)
-- 		return
-- 	end

-- 	if self.hour == 0 and self.min < 20 then
-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotNeedBuyAssistTime)
-- 		return
-- 	end

-- 	local gold = GameVoManager.Instance:GetMainRoleVo().gold
-- 	local cost = math.ceil((self.hour * 60 + self.min + (self.sec > 0 and 1 or 0)) / 2)
-- 	local str = ""
-- 	if cost <= gold then
-- 		str = ToColorStr(cost, TEXT_COLOR.GREEN)
-- 	else
-- 		str = ToColorStr(cost, TEXT_COLOR.RED)
-- 	end
-- 	local describe = string.format(Language.Guild.BuyAssistTime, str)
-- 	local yes_func = function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_CLEAN_ASSIST_CD) end
-- 	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
-- end


--------------------------------------------------------------AssistCell---------------------------------------------------------
GuildAssistViewScrollAssistCell = GuildAssistViewScrollAssistCell or BaseClass(BaseCell)

function GuildAssistViewScrollAssistCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.callback = nil
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["Reward"])
end

function GuildAssistViewScrollAssistCell:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
	self.callback = nil
	-- self.sell_view = nil
end

function GuildAssistViewScrollAssistCell:SetCallBack(callback)
	self.callback = callback
end

function GuildAssistViewScrollAssistCell:Flush()
	local index = self.data.box_level
	local str = Language.Guild.GuildBox[index + 1]
	self.node_list["Name"].text.text = str

	local bundle, asset = ResPath.GetGuildJianLuIcon(index)
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	self.node_list["MasterName"].text.text = self.data.user_name

	local config = GuildData.Instance:GetBoxConfig()[self.data.box_level]
	if config then
		local item_id = config.assist_reward.item_id
		local num = config.assist_reward.num
		self.reward_cell:SetData({item_id = item_id, num = num})
	end
end

function GuildAssistViewScrollAssistCell:ListenAllEvent()
	self.node_list["ButtonHelp"].button:AddClickListener(function() 
		self:OnClickAssist(self.data)
		GlobalTimerQuest:AddDelayTimer(function()
			GuildCtrl.Instance:GuildFlushView("guild_box")
			-- self.sell_view:Flush()
			if self.callback then
				self.callback()
			end
			end , 0.5)
		end)
end

function GuildAssistViewScrollAssistCell:OnClickAssist(info)
	local rest_assist_count = GuildData.Instance:GetRestAssistCount()
	if rest_assist_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxAssist)
		return
	end
	if info.open_time <= TimeCtrl.Instance:GetServerTime() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxCanNotAssist)
		return
	end
	-- if self.node_list["AutoToggle"].isOn == true then
		-- if info.box_level >= 3 and self.box_info.assist_cd_end_time ~= 0 then
			-- if self.hour > 0 or self.min >= 20 then
				GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_CLEAN_ASSIST_CD)
				GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_ASSIST, info.box_index, info.uid) end , 0.5)
				-- return
			-- end
		-- end
	-- end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_ASSIST, info.box_index, info.uid)
end