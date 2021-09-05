GuildBoxView = GuildBoxView or BaseClass(BaseRender)

local ListViewDelegate = ListViewDelegate
local Invite_Time = 10
function GuildBoxView:__init(instance)
	if instance == nil then
		return
	end

	self.node_list["ButtonFree"].button:AddClickListener(BindTool.Bind(self.LevelUpFree, self))

	self.node_list["BoxName"].button:AddClickListener(BindTool.Bind(self.OpenColorList, self))
	self.node_list["ButtonArrow"].toggle:AddClickListener(BindTool.Bind(self.OpenColorList, self))

	self.node_list["ButtonDig"].button:AddClickListener(BindTool.Bind(self.WaBao, self))
	self.node_list["Btn_invite"].button:AddClickListener(BindTool.Bind(self.ClickInvite, self))

	self.node_list["ButtonPay"].button:AddClickListener(BindTool.Bind(self.LevelUpPay, self))

	self.node_list["ButtonAssist"].button:AddClickListener(BindTool.Bind(self.AssistList, self))
	self.node_list["BlockClossColorList"].button:AddClickListener(BindTool.Bind(self.CloseColorList, self))
	self.node_list["Toggle"].toggle:AddValueChangedListener(BindTool.Bind(self.StopAutoLevelUp, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["ButtonPre"].button:AddClickListener(BindTool.Bind(self.ClickPre, self))
	self.node_list["ButtonNext"].button:AddClickListener(BindTool.Bind(self.ClickNext, self))
	for i = 1, GUILD_MAX_BOX_LEVEL do
		self.node_list["BoxImage" .. i].button:AddClickListener(BindTool.Bind(self.OnClickBox, self, i - 1))
	end
	
	self.node_list["ButtonPreView"].button:AddClickListener(BindTool.Bind(self.OnClikePreView, self))

	for i = 1, 4 do
		self.node_list["BtnColor" .. i].button:AddClickListener(function() self:OnClickColor(i) end)
	end


	-- self.reward_cell = ItemCell.New()
	-- self.reward_cell:SetInstanceParent(self.node_list["Reward"])

	self.node_list["BlockClossColorList"]:SetActive(false)

	self.node_list["ColorToggle"]:SetActive(false)
	self.node_list["PanelColorList"]:SetActive(false)

	self.node_list["Block"]:SetActive(false)



	self.other_config = GuildData.Instance:GetOtherConfig()
	self.box_config = GuildData.Instance:GetBoxConfig()

	self.free_count = true
	self.rest_box_count = 0
	self.temp_level_up_count = 0
	self.select_color = 3
	self.min = 0
	self.sec = 0
	self.hour = 0
	self.cur_shake_box = 1
	self.current_box_index = 0
	self.cur_shake_box_info = nil
	self.shake_box_list = {}
	self.cell_list = {}
	self.show_free_value = true
	self.is_have_tips = false
	self:OnClickColor(self.select_color)

	if self.other_config then
		local price = self.other_config.box_up_gold or 0
		
		-- self.node_list["Price"].text.text = price
		self.node_list["BoxBlock"].text.text = price
	end

	-- self:InitPreview()
	self:InitScroller()
	-- self:InitScrollerAssist()

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function GuildBoxView:__delete()
	self:RemoveCountDown()
	self:StopAutoLevelUp()
	-- if self.reward_cell then
	-- 	self.reward_cell:DeleteMe()
	-- 	self.reward_cell = nil
	-- end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	if self.invite_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.invite_count_down)
		self.invite_count_down = nil
	end
end

--初始化滚动条
function GuildBoxView:InitScroller()
	self.list_view_delegate = ListViewDelegate()
	
	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/guildview_prefab", "BoxCell", nil, function (obj)
		if nil == obj then
			return
		end
		local enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))

		self.enhanced_cell_type = enhanced_cell_type
		self.node_list["Scroller"].scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

function GuildBoxView:OnItemDataChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num)
	-- if put_reason == PUT_REASON_TYPE.PUT_REASON_GUILD_BOX_REWARD then
	-- 	local get_num = new_num - old_num
		-- TipsCtrl.Instance:OpenGuildRewardView({item_id = change_item_id, num = get_num})
	-- end
end

--滚动条数量
function GuildBoxView:GetNumberOfCells()
	local count = 0
	self.box_info = GuildData.Instance:GetBoxInfo()
	if self.box_info then
		if self.box_info.info_list then
			for i = 1, GameEnum.MAX_GUILD_BOX_COUNT do
				if self.box_info.info_list[i] then
					if self.box_info.info_list[i].open_time ~= 0 then
						count = count + 1
					end
				end
			end
		end
	end
	return count
end

--滚动条大小
function GuildBoxView:GetCellSize(data_index)
	return 170
end

function GuildBoxView:OnClikePreView()
	GuildCtrl.Instance:OpenPreView()
end

--滚动条刷新
function GuildBoxView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)

	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = GuildBoxViewScrollCell.New(cell_view)
		cell = self.cell_list[cell_view]
		cell.sell_view = self
		cell:SetClickCallBack(BindTool.Bind(self.OpenBox, self))
	end

	local data = self.temp_info_list[data_index + 1]
	data.data_index = data_index
	cell:SetData(data)
	return cell_view
end

function GuildBoxView:ClickPre()
	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local index = self.node_list["Scroller"].scroller:GetCellViewIndexAtPosition(position)
	index = index - 1
	self:JumpToIndex(index)
end

function GuildBoxView:ClickNext()
	local position = self.node_list["Scroller"].scroller.ScrollPosition
	local index = self.node_list["Scroller"].scroller:GetCellViewIndexAtPosition(position)
	index = index + 1
	self:JumpToIndex(index)
end

function GuildBoxView:CloseTips()
	-- self.node_list["PanelTips"]:SetActive(false)
	self.show_free_value = true
end

function GuildBoxView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildBoxView:SetHaveTips(state)
	self.is_have_tips = state
end

function GuildBoxView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["TopContent"], GuildData.BoxTweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelDig"], GuildData.BoxTweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.AlpahShowPanel(self.node_list["Content"], true, TWEEN_TIME, DG.Tweening.Ease.InExpo)
end

function GuildBoxView:JumpToIndex(index)
	local max_count = self:GetNumberOfCells()
	index = index >= max_count and max_count - 1 or index
	if index < 0 then
		index = 0
	end
	local width = self.node_list["Scroller"].transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.node_list["Scroller"].scroller.spacing
	-- 当前页面可以显示的数量
	local count = math.floor((width + space) / (self:GetCellSize() + space))
	if max_count <= count or index + count > max_count then
		return
	end

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["Scroller"].scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.node_list["Scroller"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GuildBoxView:Flush()
	self:CloseColorList()
	self.box_info = GuildData.Instance:GetBoxInfo()
	self.temp_info_list = {}
	local count = 1
	for k,v in pairs(self.box_info.info_list) do
		if v.open_time ~= 0 then
			self.temp_info_list[count] = v
			count = count + 1
		end
	end
	table.sort(self.temp_info_list, function(a, b)
			-- if a.is_reward == 0 and b.is_reward == 0 then
			-- 	if a.assist_uid[1] == 0 and b.assist_uid[1] > 0 then
			-- 		return false
			-- 	elseif a.assist_uid[1] > 0 and b.assist_uid[1] == 0 then
			-- 		return true
			-- 	else
			-- 		return a.open_time < b.open_time
			-- 	end
			-- else
			-- 	return a.is_reward < b.is_reward
			-- end
			return a.open_time > b.open_time
		end)

	--

	local up_count = math.max(self.other_config.box_free_up_count - self.box_info.uplevel_count, 0) .. " / " .. self.other_config.box_free_up_count
	local free_count = string.format(Language.Guild.AutoBoxLevelUp3, up_count)

	if self.box_info then
		self.temp_level_up_count = self.box_info.uplevel_count

		if self.box_info.uplevel_count >= self.other_config.box_free_up_count then
			self.node_list["PanelPrice"]:SetActive(true)
			self.node_list["ButtonPay"]:SetActive(true)
			self.node_list["ButtonFree"]:SetActive(false)
			self.node_list["FreeText"]:SetActive(false)
			GuildData.Instance:SetBoxTipsData(false, free_count, up_count)
			GuildCtrl.Instance:FlushBoxTips()
			self.free_count = false
		else
			self.node_list["PanelPrice"]:SetActive(false)
			self.node_list["ButtonPay"]:SetActive(false)
			self.node_list["ButtonFree"]:SetActive(true)
			self.node_list["FreeText"]:SetActive(true)
			GuildData.Instance:SetBoxTipsData(true, free_count, up_count)
			GuildCtrl.Instance:FlushBoxTips()
			self.free_count = true
		end
		if self.box_info.info_list then
			local has_no_open_box = false
			for i = 1, GameEnum.MAX_GUILD_BOX_COUNT do
				if self.box_info.info_list[i] then
					if self.box_info.info_list[i].is_reward == 0 and self.box_info.info_list[i].open_time == 0 then
						self.current_box_index = i - 1
						-- local bundle, asset = ResPath.GetGuildBoxIcon(self.box_info.info_list[i].box_level)
						-- self.node_list["BoxImage"].image:LoadSprite(bundle, asset, function()
							-- self.node_list["BoxImage"].image:SetNativeSize()
						 						-- end)
						if self.box_info and self.box_config and self.box_config[self.current_box_index] then
							local rest_assist_count = self.box_config[self.current_box_index].can_be_assist_max_count - self.box_info.be_assist_count
							-- UI:SetButtonEnabled(self.node_list["Btn_invite"], rest_assist_count ~= 0)
						end
						local str = Language.Guild.GuildBox[self.box_info.info_list[i].box_level + 1]
						GuildData.Instance:SetBoxTipsColor(string.format(Language.Guild.ColorBox, str))
						-- if self.box_config then
						-- 	local config = self.box_config[self.box_info.info_list[i].box_level + 1]
						-- 	if config then
						-- 		local item_id = ResPath.CurrencyToIconId.bind_diamond
						-- 		local num = config.be_assist_reward_bind_gold
						-- 		self.reward_cell:SetData({item_id = item_id, num = num})
						-- 	end
						-- end
						has_no_open_box = true
						break
					end
				end
			end
			if not has_no_open_box then
				-- self.node_list["PanelOpenBox"]:SetActive(false)
				-- self.node_list["BoxImage2"]:SetActive(true)
				-- self.node_list["TextUsdAll"]:SetActive(true)
				-- if not TipsCtrl.Instance:GetIsLockVipViewShow(VIPPOWER.GUILD_BOX_COUNT) then
				local rest_count = GuildData.Instance:GetRestOpenBoxCount()
				if rest_count <= 0 then
					UI:SetButtonEnabled(self.node_list["ButtonDig"], false)
					UI:SetButtonEnabled(self.node_list["Btn_invite"], false)
				else
					UI:SetButtonEnabled(self.node_list["ButtonDig"], true)
				end
			-- else
				-- self.node_list["PanelOpenBox"]:SetActive(true)
				-- self.node_list["BoxImage2"]:SetActive(false)
				-- self.node_list["TextUsdAll"]:SetActive(false)
			end
		end
		
		self.node_list["LevelUpCount"].text.text = math.max(self.other_config.box_free_up_count, 0) .. " / " .. self.other_config.box_free_up_count

		-- self.select_color = 4
		self:OnClickColor(self.select_color)

		local rest_count = GuildData.Instance:GetRestOpenBoxCount()
		if rest_count then
			self.rest_box_count = rest_count
			local str = math.max(rest_count, 0)
			if rest_count <= 0 then
				str = ToColorStr(str, TEXT_COLOR.RED)
			end
			self.node_list["RestCount"].text.text = str

			if rest_count > 0 and not GuildData.Instance:IsGuildCD() and GuildData.Instance:IsGuildBoxStart() and GuildData.Instance:IsCanWaQuBox() then

				self.node_list["RedPointDig"]:SetActive(true)
			else
				self.node_list["RedPointDig"]:SetActive(false)
			end
		end
	end
	for i = 1, GUILD_MAX_BOX_LEVEL do
		self.node_list["HighLight" .. i]:SetActive(false)
	end
	local num = math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0)
	self.node_list["FreeTimes"].text.text = num .. Language.Common.TimesNumber
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	local assist_info = GuildData.Instance:GetAssistInfo()
	local rest_assist_count = self.other_config.box_assist_max_count - self.box_info.assist_count
	-- if assist_info and assist_info.box_count > 0 and rest_assist_count > 0 then
	-- 	self.node_list["RedPointAssist"]:SetActive(true)
	-- else
		self.node_list["RedPointAssist"]:SetActive(false)
	-- end
	self:StartCountDown()

	local info = self.box_info.info_list[self.current_box_index + 1]
	if nil ~= info then
		self.node_list["HighLight" .. (info.box_level + 1)]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["ButtonPay"], (info.box_level + 1) < GUILD_MAX_BOX_LEVEL and self.rest_box_count > 0)
	end
end

function GuildBoxView:AssistList()
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
	GuildCtrl.Instance:OpenAssistView()
end

function GuildBoxView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(149)
end

function GuildBoxView:LevelUpFree()
	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		return
	end

	if GuildData.Instance:IsGuildCD() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ExitGuildBoxCD)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		return
	end

	local info = self.box_info.info_list[self.current_box_index + 1]
	if info then
		-- if self.node_list["Toggle"].toggle.isOn == true then
		-- 	if info.box_level >= self.select_color then
		-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
		-- 		return
		-- 	end
		-- else
			if info.box_level >= GUILD_MAX_BOX_LEVEL - 1 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel)
				return
			end
		-- end
	end

	if self.node_list["Toggle"].toggle.isOn == true then
		self:AutoLevelUp()
		return
	end
	local free_times = self.other_config.box_free_up_count - self.temp_level_up_count
	self.temp_level_up_count = self.temp_level_up_count + 1

	local free_num = math.max(free_times, 0) .. " / " .. self.other_config.box_free_up_count

	local free_count = string.format(Language.Guild.AutoBoxLevelUp3, free_num)
	local up_count = math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) .. " / " .. self.other_config.box_free_up_count

	if self.temp_level_up_count >= 2 then
		self.node_list["PanelPrice"]:SetActive(true)
		self.node_list["ButtonPay"]:SetActive(true)
		self.node_list["ButtonFree"]:SetActive(false)
		self.node_list["FreeText"]:SetActive(false)
		GuildData.Instance:SetBoxTipsData(false, free_count, up_count)
		GuildCtrl.Instance:FlushBoxTips()
		self.free_count = false
	else
		self.node_list["PanelPrice"]:SetActive(false)
		self.node_list["ButtonPay"]:SetActive(false)
		self.node_list["ButtonFree"]:SetActive(true)
		self.node_list["FreeText"]:SetActive(true)
		GuildData.Instance:SetBoxTipsData(true, free_count, up_count)
		GuildCtrl.Instance:FlushBoxTips()
		self.free_count = true
	end

	
	self.node_list["LevelUpCount"].text.text = math.max(self.other_config.box_free_up_count, 0) 				-- .. " / " .. self.other_config.box_free_up_count
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
end

function GuildBoxView:LevelUpPay()
	local info = self.box_info.info_list[self.current_box_index + 1]
	if info then
		if self.node_list["Toggle"].toggle.isOn == true then
			if info.box_level >= self.select_color then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
				return
			end
		else
			if info.box_level >= GUILD_MAX_BOX_LEVEL - 1 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel)
				return
			end
		end
	end

	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		return
	end

	if GuildData.Instance:IsGuildCD() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ExitGuildBoxCD)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		return
	end

	if self.node_list["Toggle"].toggle.isOn == true then
		self:AutoLevelUp()
		return
	end

	local describe = string.format(Language.Guild.PayBoxLevelUp, self.other_config.box_up_gold)
	local yes_func = function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index) end

	TipsCtrl.Instance:ShowCommonAutoView("guild_box" ,describe, yes_func)
end

function GuildBoxView:AutoLevelUp()

	local index = self.select_color
	self:DoAutoLevelUp(index)
end

function GuildBoxView:DoAutoLevelUp(color)
	self.aim_color = color
	if self.rest_box_count == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevelUp)
		self:StopAutoLevelUp()
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		self:StopAutoLevelUp()
		return
	end

	self.node_list["Block"]:SetActive(true)
	if self.box_info then
		local info = self.box_info.info_list[self.current_box_index + 1]
		if info then
			if info.box_level >= self.aim_color then
				self:StopAutoLevelUp()
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MaxBoxLevel2)
			else
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if self.temp_level_up_count >= self.other_config.box_free_up_count and main_role_vo.gold < self.other_config.box_up_gold then
					self:StopAutoLevelUp()
					GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
				else
					GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_UPLEVEL, self.current_box_index)
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DoAutoLevelUp, self, self.aim_color), 0.5)

					self.temp_level_up_count = self.temp_level_up_count + 1
					local num = math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) 					-- .. " / " .. self.other_config.box_free_up_count
					local free_count = string.format(Language.Guild.AutoBoxLevelUp3, num)
					local up_count = math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) .. " / " .. self.other_config.box_free_up_count
					if self.temp_level_up_count >= 2 then
						self.node_list["PanelPrice"]:SetActive(true)
						self.node_list["ButtonPay"]:SetActive(true)
						self.node_list["ButtonFree"]:SetActive(false)
						self.node_list["FreeText"]:SetActive(false)
						GuildData.Instance:SetBoxTipsData(false, free_count, up_count)
						GuildCtrl.Instance:FlushBoxTips()
					else
						self.node_list["PanelPrice"]:SetActive(false)
						self.node_list["ButtonPay"]:SetActive(false)
						self.node_list["ButtonFree"]:SetActive(true)
						self.node_list["FreeText"]:SetActive(true)
						GuildData.Instance:SetBoxTipsData(true, free_count, up_count)
						GuildCtrl.Instance:FlushBoxTips()
					end
					
					self.node_list["LevelUpCount"].text.text = math.max(self.other_config.box_free_up_count - self.temp_level_up_count, 0) .. " / " .. self.other_config.box_free_up_count
				end
			end
		end
	end
end

function GuildBoxView:StopAutoLevelUp()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	self.node_list["Block"]:SetActive(false)
end

function GuildBoxView:OpenColorList()
	local state = self.node_list["ColorToggle"].animator:GetBool("Open")
	if state then
		self.node_list["ColorToggle"].animator:SetBool("Open", false)
		self.node_list["BlockClossColorList"]:SetActive(false)
	else
		self.node_list["BlockClossColorList"]:SetActive(true)
		self.node_list["ColorToggle"]:SetActive(true)
		self.node_list["PanelColorList"]:SetActive(true)

		self.node_list["ColorToggle"].animator:SetBool("Open", true)
	end
end

function GuildBoxView:CloseColorList()
	if self.node_list["ColorToggle"].animator.isActiveAndEnabled then
		self.node_list["ColorToggle"].animator:SetBool("Open", false)
		self.node_list["BlockClossColorList"]:SetActive(false)
	end
end

function GuildBoxView:ShowColorList(state)
	self.node_list["ColorToggle"]:SetActive(false)
	self.node_list["PanelColorList"]:SetActive(false)

end

function GuildBoxView:OnClickColor(index)
	-- self.select_color = index
	local str = Language.Guild.GuildBox[index]

	self.node_list["BoxName"].text.text = str
	self:CloseColorList()
end

function GuildBoxView:WaBao()
	if self.rest_box_count == 0 then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.GUILD_BOX_COUNT)
		return
	end

	if not GuildData.Instance:IsCanWaQuBox() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CanNotWaBao)
		return
	end

	if not GuildData.Instance:IsGuildBoxStart() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxNotStart)
		self:StopAutoLevelUp()
		return
	end

	if self.other_config.box_free_up_count - self.box_info.uplevel_count > 0 and self.show_free_value then
		local up_count = math.max(self.other_config.box_free_up_count - self.box_info.uplevel_count, 0) .. " / " .. self.other_config.box_free_up_count
		local free_count = string.format(Language.Guild.AutoBoxLevelUp3, up_count)
		local tipsview = GuildCtrl.Instance:GetBoxTips()
		if tipsview ~= nil then
			tipsview:SetLevelUpFree(BindTool.Bind(self.LevelUpFree, self))
			tipsview:SetWaBao(BindTool.Bind(self.WaBao, self))
			tipsview:SetLevelUp(BindTool.Bind(self.LevelUpPay, self))
		end
		GuildData.Instance:SetBoxTipsData(true, free_count, up_count)
		GuildCtrl.Instance:OpenBoxTips()
		self.show_free_value = false
		return
	else
		self.show_free_value = true
		GuildCtrl.Instance:CloseBoxTips()
	end

	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_OPEN, self.current_box_index)
end

function GuildBoxView:ClickInvite()
	if not GuildData.Instance:IsCanInviteBox() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoneBoxInvite)
		return
	end
	GuildCtrl.Instance:OpenInviteView(BindTool.Bind(self.InviteCallBack, self))
end

function GuildBoxView:InviteCallBack(uid)
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_INVITE_ASSIST, uid)
	self:SetInviteCountDown(Invite_Time)
end

function GuildBoxView:SetInviteCountDown(time)
	local diff_time = time
	if self.invite_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(total_time - elapse_time + 0.5)
			if self.node_list and self.node_list["Btn_invite"] then
				UI:SetButtonEnabled(self.node_list["Btn_invite"],left_time <= 0)
			end
			if total_time <= elapse_time then
				if self.invite_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.invite_count_down)
					self.invite_count_down = nil
				end
				if self.node_list and self.node_list["Txt_invite"] and self.node_list["Txt_invite"].text then
					self.node_list["Txt_invite"].text.text = Language.Guild.InviteCDTime
				end
				return
			end
			if self.node_list and self.node_list["Txt_invite"] and self.node_list["Txt_invite"].text then
				self.node_list["Txt_invite"].text.text = Language.Guild.InviteCDTime .. "(" .. left_time .. ")"
			end
		end

		diff_time_func(0, diff_time)
		self.invite_count_down = CountDown.Instance:AddCountDown(
			diff_time, 1, diff_time_func)
	end
end

function GuildBoxView:StartCountDown()
	if self.count_down then return end
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.CountDown, self, nil))
end

function GuildBoxView:CountDown(callback, elapse_time, total_time)
	for k,v in pairs(self.cell_list) do
		v:FlushTime(elapse_time)
	end
	self:ShakeBox()
end

function GuildBoxView:ShakeBox()
	local count = #self.shake_box_list
	if self.cur_shake_box > count then
		self.cur_shake_box = 1
		self.shake_box_list = {}
		for k,v in pairs(self.cell_list) do
			if v.can_open then
				table.insert(self.shake_box_list, v)
			end
		end
		table.sort(self.shake_box_list, function(a,b) return a.data.data_index < b.data.data_index end)
	end
	local box = self.shake_box_list[self.cur_shake_box]
	while(true) do
		self.cur_shake_box_info = box
		if box == nil then break end
		if box.can_open then
			box:Shake()
			self.cur_shake_box = self.cur_shake_box + 1
			break
		else
			table.remove(self.shake_box_list)
			box = self.shake_box_list[self.cur_shake_box]
		end
	end
end

function GuildBoxView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GuildBoxView:OpenBox(info)
	if not info.index then return end
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_FETCH, info.index)
	if self.cur_shake_box_info and self.cur_shake_box_info.data.index == info.index then
		GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end, 1)
	else
		GlobalTimerQuest:AddDelayTimer(function() GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end, 0.1)
	end
end

function GuildBoxView:OnClickBox(color)
	-- local info = self.box_info.info_list[self.current_box_index + 1]
	-- if info then
		-- local config = GuildData.Instance:GetBoxConfigByLevel(info.box_level)
		local config = GuildData.Instance:GetBoxConfigByLevel(color)
		if config then
			local reward = {config.show}
			TipsCtrl.Instance:ShowRewardView(reward)
		end
	-- end
end

--------------------------------------------------------------Cell---------------------------------------------------------
GuildBoxViewScrollCell = GuildBoxViewScrollCell or BaseClass(BaseCell)
local eff_pos_y_list = {[0] = -36, [1] = -36, [2] = -36, [3] = -36}

function GuildBoxViewScrollCell:__init()
	self.node_list["Icon"].button:AddClickListener(BindTool.Bind(self.OnClickBox, self))

	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)
	self.anim = self.node_list["Icon"].animator
	self.can_open = false
	self.callback = nil


	self.node_list["HasOpen"]:SetActive(false)
end

function GuildBoxViewScrollCell:__delete()
	self.anim = nil
end

function GuildBoxViewScrollCell:OnFlush()

	local bundle, asset = ResPath.GetGuildJianLuIcon(self.data.box_level, false)
	self:SetRoleName()
	self.node_list["Icon"].image:LoadSprite(bundle, asset)
	if self.data.is_reward == 0 then
		self.node_list["Time"].text.text = Language.Common.CanOpen
		self.node_list["HasOpen"]:SetActive(false)
		self.node_list["Icon"].button.interactable = true
		local effect_bundle, effect_asset = ResPath.GetUiXEffect("guild_luzi" .. self.data.box_level)
		self.node_list["Effect"]:ChangeAsset(effect_bundle, effect_asset)
		self.node_list["Effect"]:SetActive(true)
	else
		self.node_list["HasOpen"]:SetActive(true)
		self.node_list["Icon"].button.interactable = false
		self.node_list["Time"].text.text = ""
		self.node_list["RedPoint"]:SetActive(false)
		self.can_open = false
		bundle, asset = ResPath.GetGuildJianLuIcon(self.data.box_level, true)
		self.node_list["Icon"].image:LoadSprite(bundle, asset)
		self.node_list["Effect"]:SetActive(false)
	end
	self:ShowTime()
end

function GuildBoxViewScrollCell:SetRoleName()
	if self.data and self.data.assist_name[1] ~= nil and self.data.assist_uid[1] ~= nil and self.data.assist_uid[1] > 0 then
		self.node_list["Name"].text.text = string.format(Language.Guild.AssistThank, self.data.assist_name[1]) 
		self.node_list["BtnThank"].button:AddClickListener(BindTool.Bind(self.OnClikeThank, self, self.data.assist_name[1]))
		if self.data.is_thank_assist_uid[1] == 1 then
			-- UI:SetButtonEnabled(self.node_list["BtnThank"], false)
			UI:SetGraphicGrey(self.node_list["BtnThank"], false)
			self.node_list["BtnThank"]:SetActive(false)
			self.node_list["BtnThank2"]:SetActive(true)
		else
			-- UI:SetButtonEnabled(self.node_list["BtnThank"], true)
			UI:SetGraphicGrey(self.node_list["BtnThank"], true)
			self.node_list["BtnThank"]:SetActive(true)
			self.node_list["BtnThank2"]:SetActive(false)
		end
		self.node_list["Name"]:SetActive(true)
		self.node_list["Panel"]:SetActive(true)
	else
		self.node_list["Name"]:SetActive(false)
		self.node_list["Panel"]:SetActive(false)
	end
end

function GuildBoxViewScrollCell:OnClikeThank()
	GuildCtrl.Instance:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_THANK_ASSIST, self.data.index, self.data.assist_uid[1])
end

function GuildBoxViewScrollCell:SetClickCallBack(callback)
	self.callback = callback
end

function GuildBoxViewScrollCell:OnClickBox()
	local config = GuildData.Instance:GetBoxConfigByLevel(self.data.box_level)
	if not self.can_open and self.data.is_reward == 0 then
		
		if config then
			local reward = {config.show}
			TipsCtrl.Instance:ShowRewardView(reward)
			self:Flush()
		end
	else
		-- self.callback(self.data)
		if config then
			local reward = {config.show}
			TipsCtrl.Instance:OpenGuildRewardView(config.show, nil, self.callback, self.data)
		end
		-- GuildCtrl.Instance:SetBoxGetTips(self.data, self.callback)
	end
end

function GuildBoxViewScrollCell:FlushTime(elapse_time)
	if not self.t_time then
		return
	end
	self:ShowTime()
end

function GuildBoxViewScrollCell:Shake()
	self.anim:SetTrigger("Shake")
end

function GuildBoxViewScrollCell:ShowTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if self.data.open_time > now_time then
		self.node_list["RedPoint"]:SetActive(false)
		self.can_open = false
		self.t_time = TimeUtil.Timediff(self.data.open_time, now_time)
		local min = self.t_time.min
		local sec = self.t_time.sec
		local hour = self.t_time.hour
		if min < 10 then
			min = 0 .. min
		end
		if sec < 10 then
			sec = 0 .. sec
		end
		if hour <= 0 then
			self.node_list["Time"].text.text = min .. Language.Common.Minute .. sec .. Language.Common.Second
		else
			self.node_list["Time"].text.text = hour .. Language.Common.Hour .. min .. Language.Common.Minute
		end
	else
		if self.data.is_reward == 0 then
			self.node_list["Time"].text.text = Language.Common.CanOpen
			self.node_list["RedPoint"]:SetActive(true)
			self.can_open = true
		end
		self.t_time = nil
	end
end