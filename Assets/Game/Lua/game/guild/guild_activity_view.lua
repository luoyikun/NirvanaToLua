GuildActivityView = GuildActivityView or BaseClass(BaseRender)

function GuildActivityView:__init(instance)
	if instance == nil then
		return
	end
	self.scroller_rect = self.node_list["ScrollerRect"]:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.toggle_group = self.node_list["Scroller"].toggle_group
	self.node_list["ButtonJoin"].button:AddClickListener(BindTool.Bind(self.OnClickJoin, self))
	self.item_cell = {}
	for i = 1, 3 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.node_list["ItemCell" .. i]
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetShowOrangeEffect(true)
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end
	self.cell_list = {}
	self.activity_config = GuildData.Instance:GetActivityConfig()
	self.activity_id = 24
	if self.activity_config and self.activity_config[1] then
		self.activity_id = self.activity_config[1].activity_id
	end
	self.show_red_point_list = {}
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	self:InitScroller()
end

function GuildActivityView:__delete()
	for k,v in pairs(self.item_cell) do
		v.cell:DeleteMe()
	end
	self.item_cell = {}
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
	self.scroller_rect = nil
	self.toggle_group = nil
	self.select_data = nil 
end

function GuildActivityView:OpenCallBack()
	self:DoPanelTweenPlay()
	self:Flush()
end

function GuildActivityView:OnClickJoin()
	local select_activity_id = GuildCtrl.Instance:GetSelectActivityId()
	if select_activity_id == nil then
		return
	end
	if select_activity_id == ACTIVITY_TYPE.GUILD_BOSS then
		ViewManager.Instance:Open(ViewName.GuildBoss)
		return
	end
	local post = GuildData.Instance:GetGuildPost()
	if select_activity_id == ACTIVITY_TYPE.GUILD_SHILIAN then
		local status = GuildData.Instance:GetMiJingState()
		if status == 1 then
			GuildMijingCtrl.SendGuildFbEnterReq()
		elseif status == 0 then
			--if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
				GuildMijingCtrl.SendGuildFbStartReq()
			-- else
			-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CallGuilMiJing)
			--end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuilMiJingFinish)
		end
		return
	end

	if select_activity_id == ACTIVITY_TYPE.GUILD_MONEYTREE then
		ActivityCtrl.Instance:ShowDetailView(select_activity_id)
		return
	end

	if select_activity_id then
		if ActivityData.Instance:GetActivityIsOpen(select_activity_id) then
			ActivityCtrl.Instance:ShowDetailView(select_activity_id)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		end
	end
end

function GuildActivityView:DoPanelTweenPlay()
	UITween.MoveAlpahShowPanel(self.node_list["LeftContent"], GuildData.ActTweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["RightContent"], GuildData.ActTweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function GuildActivityView:Flush()
	self.show_red_point_list = {}
	self.show_red_point_list[ACTIVITY_TYPE.GUILD_BOSS] = GuildData.Instance.red_point_list[Guild_PANEL.boss]
	self.activity_config = GuildData.Instance:GetActivityConfig()
	if self.node_list["Scroller"].scroller.isActiveAndEnabled then
		self.node_list["Scroller"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildActivityView:Click(activity_id, des, item_cell)
	self.activity_id = activity_id
	local act_info = ActivityData.Instance:GetActivityInfoById(activity_id)
	if act_info then
		local tab_list = Split(act_info.item_label, ":")
		if des then
			self.node_list["HelpText"].text.text = des
			self.scroller_rect.normalizedPosition = Vector2(1, 1)
		end
		if item_cell then
			for i = 1, 3 do
				if tab_list[i] then
					tab_list[i] = tonumber(tab_list[i])
				end
				if item_cell[i] and item_cell[i].item_id > 0 then
					self.item_cell[i].cell:SetData(item_cell[i])
					if tab_list[i]then
						self.item_cell[i].cell:SetShowZhuanShu(tab_list[i] == 1)
					end
					self.item_cell[i].obj:SetActive(true)
				else
					self.item_cell[i].cell:SetData()
					self.item_cell[i].obj:SetActive(false)
				end
			end
		end
	end

end

function GuildActivityView:InitScroller()
	self.list_view_delegate = self.node_list["Scroller"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function GuildActivityView:GetNumberOfCells()
	if self.activity_config then
		return #self.activity_config
	end
	return 0
end

function GuildActivityView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = GuildActivityScrollCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
		group_cell:SetHandle(self)
		group_cell:SetToggleGroup(self.toggle_group)
	end
	local data = {data_index = data_index}
	if self.activity_config and self.activity_config[data_index + 1] then
		data.activity_id = self.activity_config[data_index + 1].activity_id
		data.button_name = self.activity_config[data_index + 1].button_name

	end
	group_cell:SetData(data)
end

function GuildActivityView:ActivityCallBack()
	self:Flush()
end

-------------------------------------------------------- GuildActivityScrollCell ----------------------------------------------------------

GuildActivityScrollCell = GuildActivityScrollCell or BaseClass(BaseCell)

local ACTIVITYTYPE = 1
function GuildActivityScrollCell:__init()
	-- self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["Toggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickDetails, self))

	self.play_introduction = ""

	self.node_list["RedPoint"]:SetActive(false)
end

function GuildActivityScrollCell:__delete()

end

function GuildActivityScrollCell:OnFlush()
	local asset_bundle, name = ResPath.GetActivityRawimage(ACTIVITYTYPE, self.data.activity_id) --ResPath.GetGuildActivtyBg(self.data.activity_id)

	self.node_list["Toggle"].raw_image:LoadURLSprite(asset_bundle, name)

	self.node_list["End"]:SetActive(false)
	self.node_list["NotStart"]:SetActive(false)
	self.node_list["Start"]:SetActive(false)
	self.node_list["Ready"]:SetActive(false)

	if self.data.activity_id == ACTIVITY_TYPE.GUILD_BONFIRE then
		local post = GuildData.Instance:GetGuildPost()
		local status = GuildData.Instance:GetMiJingState()
		if self.data.activity_id == ACTIVITY_TYPE.GUILD_BONFIRE then
			status = GuildData.Instance:GetBonFireState()
		end
		self.node_list["BtnName"].text.text = Language.Common.Join
		if status ~= 1 then
			if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then

				self.node_list["BtnName"].text.text = Language.Common.Open
			end
		end
	else
		self.node_list["BtnName"].text.text = self.data.button_name
	end

	if self.data.activity_id then
		local config = ActivityData.Instance:GetClockActivityByID(self.data.activity_id)
		if config and config.act_id then

			self.node_list["Name"].text.text = config.act_name
			-- local lv, zhuan = PlayerData.GetLevelAndRebirth(tonumber(config.min_level))
			self.node_list["TextLevel"].text.text = ToColorStr(PlayerData.GetLevelString(tonumber(config.min_level)), "#ff9e0e")
			-- self.node_list["TextLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv, zhuan)
			if ActivityData.Instance:GetActivityIsInToday(self.data.activity_id) then
				local str_time = config.open_time .. " - " .. config.end_time
				self.node_list["TextTime"].text.text = ToColorStr(str_time, TEXT_COLOR.RED)
			else
				local open_day_list = Split(config.open_day, ":")
				if open_day_list then
					local str = Language.Common.Week
					for i = 1, #open_day_list do
						local day = tonumber(open_day_list[i])
						day = Language.Common.DayToChs[day] or ""
						str = str .. day
						if i ~= #open_day_list then
							str = str .. "、"
						end
					end
					str = str .. Language.Common.Open

					self.node_list["TextTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
				end
			end
			self.play_introduction = config.play_introduction
			self.item_cell = {config.reward_item1, config.reward_item2, config.reward_item3}
		end
			self.node_list["Mask"]:SetActive(false)
			local config = ActivityData.Instance:GetClockActivityByID(self.data.activity_id)
			local though_time = true
			local is_today_open = false
			if config then
				local open_day_list = Split(config.open_day, ":")
				local server_time = TimeCtrl.Instance:GetServerTime()
				local now_weekday = tonumber(os.date("%w", server_time))
				if now_weekday == 0 then now_weekday = 7 end
				local server_time_str = os.date("%H:%M", server_time)
				for _, v in ipairs(open_day_list) do
					if tonumber(v) == now_weekday then
						is_today_open = true
						local open_time_tbl = Split(config.open_time, "|")
						local end_time_tbl = Split(config.end_time, "|")

						for k2, v2 in ipairs(end_time_tbl) do
							if v2 > server_time_str then
								though_time = false
								break
							end
						end
						break
					end
				end
			end

			local cfg = ActivityData.Instance:GetActivityConfig(self.data.activity_id) or {}
			if ActivityData.Instance:GetActivityIsOpen(self.data.activity_id) or cfg.is_allday == 1 then
				self.node_list["Start"]:SetActive(true)
			elseif ActivityData.Instance:GetActivityIsReady(self.data.activity_id) then  --添加活动准备中
				self.node_list["Ready"]:SetActive(true)
			elseif is_today_open and not though_time then
				self.node_list["NotStart"]:SetActive(true)
			else
				self.node_list["Mask"]:SetActive(true)
				self.node_list["End"]:SetActive(true)
			end
	end

	self.node_list["RedPoint"]:SetActive(false)
	if self.handle then
		if self.handle.activity_id == self.data.activity_id then
	
			self.node_list["Toggle"].toggle.isOn = true
		else
		
			self.node_list["Toggle"].toggle.isOn = false
		end
		if self.handle.show_red_point_list[self.data.activity_id] then
			self.node_list["RedPoint"]:SetActive(true)
		end
	end
end

function GuildActivityScrollCell:OnClickDetails(state)
	if state then
		if self.handle then
			self.handle:Click(self.data.activity_id, self.play_introduction, self.item_cell)
			GuildCtrl.Instance:SetSelectActivityId(self.data.activity_id)
		end
	end
end

function GuildActivityScrollCell:SetHandle(handle)
	self.handle = handle
end


function GuildActivityScrollCell:SetToggleGroup(toggle_group)
	self.node_list["Toggle"].toggle.group = toggle_group
end
