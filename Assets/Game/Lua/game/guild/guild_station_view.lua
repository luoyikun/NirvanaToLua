GuildStationView = GuildStationView or BaseClass(BaseView)

local RewardCount = 3

function GuildStationView:__init()
	self.ui_config = {{"uis/views/guildview_prefab", "GuildStationView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true						-- IphoneX适配
	self.last_chat_time = -10
	self.cur_star = 0
end

function GuildStationView:__delete()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	if self.skill_render then
		self.skill_render:DeleteMe()
		self.skill_render = nil
	end
end

function GuildStationView:ReleaseCallBack()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k,v in pairs(self.rank_dps_cell_list) do
		v:DeleteMe()
	end
	self.rank_dps_cell_list = nil

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
	self.list_view = nil
end

function GuildStationView:LoadCallBack()
	self.rank_dps_cell_list = {}
	self.item_cell = {}
	for i = 1, RewardCount do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self.node_list["ItemCell" .. i]
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
		self.item_cell[i].cell:SetInteractable(false)
		if i > 1 then
			self.item_cell[i].obj:SetActive(false)
		end
	end

	self.NoCall = false

	self.node_list["ButtonKill"].button:AddClickListener(BindTool.Bind(self.OnClickKill, self))
	self.node_list["ButtonRemind"].button:AddClickListener(BindTool.Bind(self.OnClickReminder, self))
	self.node_list["ProgressRed"].slider.value = 1
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:InitTreasureBoxScroller()
	self.node_list["BoxNumTxt"].text.text = ""

 	self.cell_list = {}
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMoneyNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GuildStationView:GetMoneyNumberOfCells()
	return GuildData.Instance:GetRankListNum() or 0
end

function GuildStationView:RefreshCell(cell, cell_index)
	local rank_cfg = GuildData.Instance:GetRankInfoList()
	if nil == rank_cfg then
		return
	end

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = TreeRankItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	item_cell:SetData(rank_cfg[cell_index + 1])
end

function GuildStationView:OpenCallBack()
	self:Flush()
	self:SetStarCountDown()
	if MainUICtrl.Instance:IsLoaded()then
		local state = MainUICtrl.Instance:GetMenuToggleState()
		self.node_list["PanelInfo"]:SetActive(not state or false)
	end

	self.cur_star = 0
end

function GuildStationView:MoveToTreeState(state)
	if state then
		local loader = AllocAsyncLoader(self, "skill_button_loader")
		loader:Load("uis/views/guildview_prefab", "GuildYanHuiSkill", function (obj)
			if IsNil(obj) then
				return
			end

			MainUICtrl.Instance:ShowActivitySkill(obj)
			if nil ~= obj then
				if self.skill_render then
					self.skill_render:DeleteMe()
					self.skill_render = nil
				end
				self.skill_render = GuildYanHuiSkillRender.New(obj)
			end
		end)
	else
		MainUICtrl.Instance:ShowActivitySkill(false)
		if self.skill_render then
			self.skill_render:DeleteMe()
			self.skill_render = nil
		end
	end
end

function GuildStationView:CloseCallBack()
	self:RemoveCountDown()
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	self.cur_star = 0

	self:MoveToTreeState(false)
end

function GuildStationView:OnFlush()
	self.moneytree = GuildData.Instance:GetMoneyTreeState()
	self.node_list["MoneyTree"]:SetActive(self.moneytree)
	self.node_list["MoneyTreeTitle"]:SetActive(self.moneytree)
	self.node_list["MoneyButtons"]:SetActive(self.moneytree)
	--  屏蔽仙盟boss设为false
	self.node_list["BossPanel"]:SetActive(false)
	--
	--  屏蔽仙盟boss设为false
	self.node_list["BossButtons"]:SetActive(false)
	--

	if self.moneytree then
		self:FlushMoneyTree()
	else
		self:FlushTreasureScor()
		local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
		if boss_activity_info then
			self.node_list["TextExp"].text.text = boss_activity_info.totem_exp
			local boss_info = GuildData.Instance:GetBossInfo()
			self.node_list["BossName"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["ProgressRed"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["TextKillRewad"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["RewardPanel"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["ButtonKill"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["NoticeText"]:SetActive(boss_activity_info.boss_id == 0)
			self.node_list["BoxNumTxt"]:SetActive(boss_activity_info.boss_id == 0)
			--self.node_list["TipsTxt"]:SetActive(boss_activity_info.boss_id == 0)
			self.node_list["Star"]:SetActive(boss_activity_info.boss_id ~= 0)
			self.node_list["ButtonRemind"]:SetActive(boss_activity_info.boss_id == 0 and self.NoCall)
			self.NoCall = boss_activity_info.boss_id ~= 0
			if boss_activity_info.boss_id == 0 then	
				local notice = Language.Guild.BossDontCall
				if boss_info then
					if boss_info.boss_normal_call_count > 0 then
						notice = Language.Guild.BossHasKilled
					else
						local post = GuildData.Instance:GetGuildPost()
						if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
					
							self.NoCall = true
							self.node_list["ButtonRemind"]:SetActive(true)
						end
					end
				end
				self.node_list["NoticeText"].text.text = notice
				self:RemoveCountDown()
			else
				local boss_type = Language.Guild.NormalBoss
				if boss_activity_info.is_surper_boss == 1 then
					boss_type = Language.Guild.SurperBoss
				end

				local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
				local temp_config = monster_cfg[boss_activity_info.boss_id]
				if temp_config then
					local superbossname = temp_config.name
					local supername = Split(temp_config.name, "·")
					local name = supername[2]
					boss_name = string.format(boss_type, CommonDataManager.GetDaXie(boss_info.boss_level), name)
					self.node_list["BossName"].text.text = "【" .. boss_name .. "】"
				end
			
				local boss_config = GuildData.Instance:GetGuildActiveConfig().boss_cfg
				if boss_config then
					local config = boss_config[boss_activity_info.boss_level]
					if config then
						self.item_cell[1].cell:SetData(config.normal_item_reward)
						self.item_cell[1].cell:SetInteractable(true)
					end
				end
				if not self.count_down then
					self.count_down = CountDown.Instance:AddCountDown(999999, 0.5, BindTool.Bind(self.BossHpUpdate, self))
				end
			end
		end
		self:SetStarCountDown()
		self:GatherBoxNum()
	end
end

-- Boss血量改变
function GuildStationView:BossHpUpdate()
	local boss_obj_id = -1
	local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
	if boss_activity_info then
		boss_obj_id = boss_activity_info.boss_obj_id
	end
	local boss_obj = Scene.Instance:GetObj(boss_obj_id)
	if not boss_obj then return end

	local value = boss_obj:GetAttr("hp") / boss_obj:GetAttr("max_hp")
	self.node_list["ProgressRed"].slider.value = value
	value = value * 100
	value = value - value % 0.1
	
end

function GuildStationView:OnClickKill()
	local boss_config = GuildData.Instance:GetGuildActiveConfig().boss_cfg
	if boss_config then
		local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
		if boss_activity_info then
			local config = boss_config[boss_activity_info.boss_level]
			if config then
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), config.pos_x, config.pos_y)
			end
		end
	end
end

function GuildStationView:SwitchButtonState(state)
	if state then
		state = false
	else
		state = true
	end
	
	self.node_list["PanelInfo"]:SetActive(not state)
end

function GuildStationView:OnClickReminder()
	if self.last_chat_time + 10 >= Status.NowTime then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.SpeackMax)
	else
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, Language.Guild.BossActivity)
		self.last_chat_time = Status.NowTime
	end
end

function GuildStationView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GuildStationView:FlushMoneyTree()
	local tree_info = GuildData.Instance:GetMoneyTreeInfo()
	local num_now = tree_info.gather_num or 0
	local num_max = tree_info.tianci_tongbi_max_gather_num or 0
	local percent_now = tree_info.tianci_tongbi_tree_maturity_degree or 0
	local percent_max = tree_info.tianci_tongbi_tree_max_maturity_degree or 0
	local tree_percent = 0

	if percent_max > 0 then
		tree_percent = percent_now / percent_max
	end

	if self:IsOpen() then
		if self.list_view and self.list_view.scroller and self.list_view.scroller.isActiveAndEnabled then
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
		self.node_list["GatherNum"].text.text = string.format(Language.Guild.MoneyTreeGatherNum, num_now, num_max)
		self.node_list["ProgressTree"].slider.value = tree_percent
		self.node_list["TextMaturity"].text.text = percent_now .. "/" .. percent_max
	end
end

-- 评星
function GuildStationView:SetStarCountDown()
	-- 星级
	local star_info = GuildData.Instance:GetBossActivityInfo()
	if star_info == nil then return end
	-- 相等情况下说明数据没更新，不执行刷新
	if self.cur_star == star_info.cur_star_level then
		return
	end
	local star_num = 3

	local left_time = star_info.next_change_star_time - TimeCtrl.Instance:GetServerTime()
	self.cur_star = star_info.cur_star_level
	local function diff_time_fun(elapse_time, total_time)
		local star_time = math.floor(total_time - elapse_time + 0.5)
		local count_down_text = string.format(Language.ExpFuBen.GreenText, TimeUtil.FormatSecond(star_time, 2))
		local next_star = math.max(self.cur_star - 1, 1)
		self.node_list["StarTxt"].text.text = string.format(Language.FuBen.NetStar, count_down_text, next_star)

		if self.cur_star > 0 then
			for i = 1,star_num do
				local is_gray = i > self.cur_star
				UI:SetGraphicGrey(self.node_list["ImgStar" .. i], is_gray)
			end
		end
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	self.star_count_down = CountDown.Instance:AddCountDown(left_time, 0.5, diff_time_fun)
end

function GuildStationView:GatherBoxNum()
	if self.cur_star == 0 then return end
	local star_info = GuildData.Instance:GetBossActivityInfo()
	if star_info == nil then return end
	local star_cfg = GuildData.Instance:GetBossStarConfig()
	if star_cfg == nil then return end
	local box_max_num = star_cfg[self.cur_star].limit_num
	local box_gather_num = star_info.gather_num
	self.node_list["BoxNumTxt"].text.text = string.format(Language.GuildBoss.BoxNum, box_gather_num, box_max_num)
end

-- 排行榜
function GuildStationView:InitTreasureBoxScroller()
	local list_delegate = self.node_list["InfoScroller"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTreasureBoxCell, self)
end

function GuildStationView:GetNumberOfCells()
	--排行信息
	local rank_list = GuildData.Instance:GetBossActivityInfo().rank_list or {}
	return #rank_list
end

function GuildStationView:RefreshTreasureBoxCell(cell, cell_index)
	local dps_cell = self.rank_dps_cell_list[cell]
	if dps_cell == nil then
		dps_cell = DpsRankItem.New(cell.gameObject, self)
		self.rank_dps_cell_list[cell] = dps_cell
	end
	cell_index = cell_index + 1
	dps_cell:SetIndex(cell_index)
	dps_cell:Flush()
end

function GuildStationView:FlushTreasureScor()
	if self.node_list["InfoScroller"] and self.node_list["InfoScroller"].scroller.isActiveAndEnabled then
		self.node_list["InfoScroller"].scroller:ReloadData(0)
	end
end

------前往技能------------------------------------------------

GuildYanHuiSkillRender = GuildYanHuiSkillRender or BaseClass(BaseCell)

function GuildYanHuiSkillRender:__init()
	
end

function GuildYanHuiSkillRender:__delete()
	
end

function GuildYanHuiSkillRender:LoadCallBack()
	self.node_list["HandOn"].button:AddClickListener(BindTool.Bind(self.ClickHandOn, self))
end

function GuildYanHuiSkillRender:ClickHandOn()
	GuildCtrl.Instance:GoToMoneyTree()
end


--Dps排名滚动条格子------------------------------------------------------
DpsRankItem = DpsRankItem or BaseClass(BaseCell)

function DpsRankItem:__init(instance, view)
	self.parent = view
end

function DpsRankItem:__delete()
	self.parent = nil
end

function DpsRankItem:OnFlush()
	local rank_info = GuildData.Instance:GetRankInfo(self.index)
	self:SetActive(rank_info and rank_info.user_name ~= "")
	if not rank_info then return end

	self.node_list["Name"].text.text = rank_info.user_name
	self.node_list["Rank"].text.text = self.index
	self.node_list["DpsNum"].text.text = rank_info.hurt_val

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["Bg"]:SetActive(rank_info.user_name == main_role_vo.role_name)
end

TreeRankItem = TreeRankItem or BaseClass(BaseCell)
function TreeRankItem:__init()

end

function TreeRankItem:__delete()

end

function TreeRankItem:OnFlush()
	if nil == self.data then
		return
	end
	self.node_list["Rank"].text.text = self.data.rank_info
	self.node_list["Name"].text.text = self.data.user_name
	self.node_list["MoJing"].text.text = self.data.longhun
	-- self.node_list["BangYuan"].text.text = self.data.coin_bind
	self.node_list["BangYuan"].text.text = self.data.total_gather_exp_count
end