require("game/guild_fight/guild_fight_reward_view")


GuildFightView = GuildFightView or BaseClass(BaseView)

function GuildFightView:__init()
	self.ui_config = {{"uis/views/guildfight_prefab", "GuildFightView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.mainui_state = true
	self.item_t = {}
end

function GuildFightView:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}

	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end
end

function GuildFightView:LoadCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.toggle_group = self.node_list["FlagPanel"].toggle_group

	self.item_cell = {}
	for i = 1, 3 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
	-- self.node_list["ButtonJiFen"].button:AddClickListener(BindTool.Bind(self.OpenRank, self))
	self.node_list["BtnGuildShow"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))
	self.node_list["BtnBaiYe"].button:AddClickListener(BindTool.Bind(self.OnClickBaiYe, self))
	self.node_list["BaiYeShow"]:SetActive(false)

	self.is_show_remind_bai_ye = true 

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	local info = GuildFightData.Instance:GetRoleInfo()
	self.last_score = info.history_get_person_credit or 0
	self:InitFlagPanel()
	self:Flush()
end

function GuildFightView:CloseCallBack()
	if nil ~= self.down_time then
		CountDown.Instance:RemoveCountDown(self.down_time)
		self.down_time = nil
	end

	if nil ~= self.bai_ye_cd then
		CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
		self.bai_ye_cd = nil
	end
end

-- 拜谒按钮监听
function GuildFightView:OnClickBaiYe()
	GuajiCtrl.Instance:StopGuaji()
	GuajiType.IsManualState = false

	-- 寻路，发送拜谒请求
	self.is_show_remind_bai_ye = false
	local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GUILDBATTLE)
	local pos_x = bai_ye_cfg.worship_pos_x
	local pos_y = bai_ye_cfg.worship_pos_y
	if bai_ye_cfg then
		local main_role = Scene.Instance:GetMainRole()
		local main_pos_x, main_pos_y = main_role:GetLogicPos()
		local distance = GameMath.GetDistance(main_pos_x, main_pos_y, pos_x, pos_y, false)		
		if distance <= 10 * 10 then
			CityCombatCtrl.Instance:SendBaiYeReq()
		else
			MoveCache.end_type = MoveEndType.BAIYE
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos_x + math.floor(math.random(-8, 8)), pos_y + math.floor(math.random(-8, 8)), 0, 0)
		end
	 end
end

-- 设置拜谒计时器
function GuildFightView:SetBaiYeDownTime()
	if nil == self.down_time then
		local complere_fun = function()
			FuBenCtrl.Instance:SendExitFBReq()
			if nil ~= self.down_time then
				CountDown.Instance:RemoveCountDown(self.down_time)
				self.down_time = nil
			end
		end

		local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GUILDBATTLE)
		local remaining_time = bai_ye_cfg.worship_time
		self.down_time = CountDown.Instance:AddCountDown(remaining_time, 1, function(elapse_time, total_time)
			local remaining_time = math.floor(total_time - elapse_time)
			self.node_list["TextDownTime"].text.text = TimeUtil.FormatSecond(remaining_time, 2)
		end, complere_fun)
	end
end

-- 设置拜谒气泡提示框倒计时
function GuildFightView:SetRemindBubbleActive()
	if nil ~= self.remind_bubble_delay_timer then
		GlobalTimerQuest:CancelQuest(self.remind_bubble_delay_timer)
	end

	self.remind_bubble_delay_timer = GlobalTimerQuest:AddDelayTimer(function()
		if self.node_list["RemindBaiYe"] then
			self.node_list["RemindBaiYe"]:SetActive(false)
		end
	end, 5)
end

function GuildFightView:GetIsBaiYe()
	return nil ~= self.down_time
end

-- 刷新拜谒按钮CD
function GuildFightView:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
	self.node_list["CDText"].text.text = ""
	self.node_list["CDMask"].image.fillAmount = 0

	local complere_fun = function()
		self.node_list["CDText"].text.text = ""
		self.node_list["CDMask"].image.fillAmount = 0
	end

	if bai_ye_info.next_worship_timestamp > 0 then
		if nil ~= self.bai_ye_cd then
			CountDown.Instance:RemoveCountDown(self.bai_ye_cd)
			self.bai_ye_cd = nil
		end
		
		local remaining_time = bai_ye_info.next_worship_timestamp - TimeCtrl.Instance:GetServerTime()
		self.bai_ye_cd = CountDown.Instance:AddCountDown(remaining_time, 0.05, function(elapse_time, total_time)
			local daiff_value = math.ceil(total_time - elapse_time)
			self.node_list["CDText"].text.text = daiff_value
			self.node_list["CDMask"].image.fillAmount = (total_time - elapse_time) / bai_ye_cfg.worship_click_cd
			if daiff_value < 0 then
				self.node_list["CDText"].text.text = ""
				self.node_list["CDMask"].image.fillAmount = 0
			end
		end, complere_fun)
	end
end


function GuildFightView:BagGetNumberOfCells()
	local data_list = GuildFightData.Instance:GetGuildFightRankList() or {}
	return #data_list
end

function GuildFightView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = GuildFightRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	local data_list = GuildFightData.Instance:GetGuildFightRankList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
end

-- 打开仙盟输出展示面板
function GuildFightView:OnClickGuildShowView()
	GuildCtrl.Instance:OpenGuildShowView(ACTIVITY_TYPE.GUILDBATTLE)
end

function GuildFightView:ReleaseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self.show_track_info = nil
	self.toggle_group = nil
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	if self.flag_list then
		for k,v in pairs(self.flag_list) do
			v:DeleteMe()
		end
	end
	self.flag_list = {}
end

function GuildFightView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "open_rank" then
			self:OpenRank()
		elseif k == "mvp_name" then
			local name_str = GuildData.Instance:GetGuildMvpInfo()
			self.node_list["MvpName"].text.text = name_str or Language.GuildShowView.XuWieYiDai
		elseif k == "bai_ye" then
			local fu_ben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
			fu_ben_icon_view:SetDownTimeActive(false)

			self.node_list["BaiYeShow"]:SetActive(true)
			local bai_ye_info = CityCombatData.Instance:GetBaiYeInfo()
			local bai_ye_cfg = ActivityData.Instance:GetBaiJieCfgByActivityType(ACTIVITY_TYPE.GUILDBATTLE)
			self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times)
			if bai_ye_info and next(bai_ye_info) and bai_ye_cfg then
				self.node_list["TextCount"].text.text = string.format(Language.CityCombat.ShengYuCount, bai_ye_cfg.worship_click_times - bai_ye_info.worship_times)
				self.node_list["RemindBaiYe"]:SetActive(self.is_show_remind_bai_ye)
				self:UpdateBaiYeBtnCD(bai_ye_info, bai_ye_cfg)
			end
		end
	end
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.node_list["PanelInfo"]:SetActive(self.mainui_state or false)
	self:FlushInfo()
	self:FlushRank()
end

function GuildFightView:SwitchButtonState(state)
	self.mainui_state = state
	self.node_list["PanelInfo"]:SetActive(state)
end

function GuildFightView:OpenRank()
	-- self:FlushRank()
	-- GuildFightCtrl.Instance:OpenRankView()
end

function GuildFightView:FlushRank()
	local global_info = GuildFightData.Instance:GetGlobalInfo()
	for k,v in ipairs(self.flag_list) do
		local data = global_info.hold_point_guild_list[k]
		v:SetData(data)
	end
end

function GuildFightView:FlushInfo()
	local role_info = GuildFightData.Instance:GetRoleInfo()
	if role_info.history_get_person_credit - self.last_score > 0 then
		TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.GuildBattle.HuoDeJiFen, role_info.history_get_person_credit - self.last_score))
		self.last_score = role_info.history_get_person_credit
	end
	
	local config, next_config = GuildFightData.Instance:GetRewardInfoByScore(role_info.history_get_person_credit)
	local all_num = GuildFightData.Instance:GetMaxGongHui()
	self.node_list["Bg_black"]:SetActive(role_info.history_get_person_credit >= all_num)

	if not next_config then
		self.node_list["JiFen"].text.text = role_info.history_get_person_credit
		-- self.node_list["Reward"].text.text = Language.Guild.QuanBuLingQi
		self.node_list["Reward"].text.text = string.format(Language.Guild.DaDaoJiFen, role_info.history_get_person_credit, all_num)
		next_config = config
	else
		self.node_list["Bg_black"]:SetActive(false)
		if role_info.history_get_person_credit >=  next_config.reward_credit_min then
			self.node_list["Reward"].text.text = string.format(Language.Guild.DaDaoJiFen, role_info.history_get_person_credit, next_config.reward_credit_min)
		else
			self.node_list["Reward"].text.text = string.format(Language.Guild.DaDaoJiFenTwo, role_info.history_get_person_credit, next_config.reward_credit_min)
		end
		self.node_list["JiFen"].text.text = role_info.history_get_person_credit .. " / " .. next_config.reward_credit_min
	end


	if next_config and next_config.reward_item then
		local item_list = {}
		for k,v in pairs(next_config.reward_item) do
			if v and v.item_id > 0 then
				table.insert(item_list, v)
			end
		end

		for i = 1, 3 do
			local item_info = item_list[i]
			if item_info then
				self.item_cell[i]:SetParentActive(true)
				self.item_cell[i]:SetData(item_info)
			else
				self.item_cell[i]:SetParentActive(false)
			end
		end
	end
end

function GuildFightView:OnClickFlag(index)
	local x, y = GuildFightData.Instance:GetFlagPositionByIndex(index)
	local cfg = GuildFightData.Instance:GetConfig()
	local monster_id = 0
	if cfg and cfg.point then
		monster_id = cfg.point[index].boss_id or 0
	end
	
	local callback = function()
		MoveCache.param1 = monster_id
		GuajiCache.monster_id = monster_id
		MoveCache.end_type = MoveEndType.FightByMonsterId
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 3, 3)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
end

function GuildFightView:InitFlagPanel()
	self.flag_list = {}

	local count = 0
	for i = 1, 5 do
		local async_loader = AllocAsyncLoader(self, "cell_loader" .. i)
		async_loader:Load("uis/views/guildfight_prefab", "GuildFightFlagCell", function(obj)
			if IsNil(obj) then
				return
			end

			local obj_transform = obj.transform
			obj_transform:SetParent(self.node_list["FlagPanel"].transform, false)
			local info_cell = GuildFightFlagCell.New(obj)
			info_cell:SetToggleGroup(self.node_list["FlagPanel"].toggle_group)
			info_cell:SetFlagColor(i)
			info_cell:SetClickCallBack(BindTool.Bind(self.OnClickFlag, self, i))
			self.flag_list[i] = info_cell
			count = count + 1
			if count >= 5 then
				self:FlushRank()
			end
		end)

	end
end

----------------------------------------------GuildFightFlagCell--------------------------------------------

GuildFightFlagCell = GuildFightFlagCell or BaseClass(BaseCell)

function GuildFightFlagCell:__init()
	self.hp_index = 1
end

function GuildFightFlagCell:LoadCallBack( )
	self.node_list["GuildFightFlagCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function GuildFightFlagCell:__delete()

end

function GuildFightFlagCell:OnFlush()
	self.node_list["Icon1"]:SetActive(false)
	self.node_list["Icon2"]:SetActive(true)
	self.node_list["Image"].image:LoadSprite(ResPath.GetGuildFightProgress("red"))
	self.node_list["Line1"].image:LoadSprite(ResPath.GetGuildFightLine("red"))
	self.node_list["Line2"].image:LoadSprite(ResPath.GetGuildFightLine("red"))
	self.node_list["Line3"].image:LoadSprite(ResPath.GetGuildFightLine("red"))
	local guild_name = ""
	if self.data then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if self.data.guild_id > 0 then
			if self.data.guild_id == guild_id then
				self.node_list["Icon1"]:SetActive(true)
				self.node_list["Icon2"]:SetActive(false)
				guild_name = ToColorStr(self.data.guild_name, TEXT_COLOR.BLUE)
				self.node_list["Image"].image:LoadSprite(ResPath.GetGuildFightProgress("green"))
				self.node_list["Line1"].image:LoadSprite(ResPath.GetGuildFightLine("green"))
				self.node_list["Line2"].image:LoadSprite(ResPath.GetGuildFightLine("green"))
				self.node_list["Line3"].image:LoadSprite(ResPath.GetGuildFightLine("green"))
			else
				guild_name = ToColorStr(self.data.guild_name, TEXT_COLOR.RED)
			end
		end
		local value = self.data.max_blood > 0 and self.data.blood / self.data.max_blood or 1
		self.node_list["Progress"].slider.value = value
		self.node_list["GFNodeEffect"]:SetActive(false)
		-- 如果hp值发生变化,则
		if self.hp_index ~= value then
			self.hp_index = self.data.max_blood > 0 and self.data.blood / self.data.max_blood or 1
			self.node_list["GFNodeEffect"]:SetActive(true)
		end

	end
	if guild_name == "" then
		guild_name = Language.GuildBattle.ZanWuZhanLing
	end
	self.node_list["GuildName"].text.text = guild_name
end

function GuildFightFlagCell:SetFlagColor(index)
	self.node_list["FlagGreen"]:SetActive(index == 2)
	self.node_list["FlagRed"]:SetActive(index == 1)
	self.node_list["FlagBlue"]:SetActive(index == 3)
	self.node_list["FlagPurple"]:SetActive(index == 4)
	self.node_list["FlagWhite"]:SetActive(index == 5)
end

function GuildFightFlagCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

GuildFightRankItem = GuildFightRankItem or BaseClass(BaseRender)

function GuildFightRankItem:__init()

end

function GuildFightRankItem:SetIndex(index)
	self.node_list["TxtRank"].text.text = index
	if index <= 3 then
		self.node_list["TxtRank"]:SetActive(false)
		self.node_list["Rankindex"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(index)
		self.node_list["Rankindex"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["TxtRank"]:SetActive(true)
		self.node_list["Rankindex"]:SetActive(false)
	end
end

function GuildFightRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function GuildFightRankItem:Flush()
	if nil == self.data then
		return
	end
	local color = nil
	if self.data.side == 0 then
		color = TEXT_COLOR.BLUE
	elseif self.data.side == 1 then
		color = TEXT_COLOR.RED
	elseif self.data.side == 2 then
		color = TEXT_COLOR.GREEN
	end
	color = color or TEXT_COLOR.WHITE
	if self.data.score == 0 then
		self.node_list["TxtDamage"].text.text = "--"
		self.node_list["TxtName"].text.text = "--"
	else
		self.node_list["TxtDamage"].text.text = self.data.score
		self.node_list["TxtName"].text.text = ToColorStr(self.data.guild_name, color)
	end
end

