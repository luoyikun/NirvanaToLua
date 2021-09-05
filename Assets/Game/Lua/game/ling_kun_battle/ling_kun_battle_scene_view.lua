LingKunBattleSceneView = LingKunBattleSceneView or BaseClass(BaseView)
local ZONE_NAME_LIST = {
	[0] = "鲲王大陆",
	[1] = "西海",
	[2] = "北海",
	[3] = "南海",
	[4] = "东海",
}
function LingKunBattleSceneView:__init()
	self.ui_config = {
		{"uis/views/lingkunbattleview_prefab", "LingKunFightView"},
	}

	self.cell_list = {}
	self.time_stamp = {}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function LingKunBattleSceneView:ReleaseCallBack()
	self.select_index = 0

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	if self.item_t then
		for k,v in pairs(self.item_t) do
			v:DeleteMe()
		end
	end
	self.item_t = {}
end

function LingKunBattleSceneView:OpenCallBack()
	self.select_index = 0
	self:ReloadCellList()
	local scene_id = Scene.Instance:GetSceneId() or 0
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	local name = scene_cfg and scene_cfg.name or ""
	self.node_list["TxtNameNormal"].text.text = name
	self.node_list["TxtNameSelect"].text.text = name
	self.node_list["Txt_tip"]:SetActive(scene_id ~= 1150)

	self:FlushHurtRankList()
end

function LingKunBattleSceneView:CloseCallBack()
	if nil ~= self.CountDownTimer then
		CountDown.Instance:RemoveCountDown(self.CountDownTimer)
		self.CountDownTimer = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.select_index = 0
end


function LingKunBattleSceneView:OnFlush(param_list)
	self:CheckTheStamp()
	self:FlushCellList()
end

function LingKunBattleSceneView:FlushHurtRankList()
	local info = LingKunBattleData.Instance:GetCrossLieKunFBBossHurtInfo()
	self.node_list["name"].text.text = PlayerData.Instance.role_vo.guild_name
	self.node_list["rank"].text.text = Language.Boss.NotOnRank
	if PlayerData.Instance.role_vo.guild_name == nil then
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["hurt"]:SetActive(false)
	end
	if info == nil or next(info) == nil then
		return
	end

	if info.own_guild_rank > 0 and info.own_guild_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(info.own_guild_rank)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["rank"].text.text = (info.own_guild_rank > 5 or info.own_guild_rank == 0) and Language.Boss.NotOnRank or info.own_guild_rank
		self.node_list["rank"]:SetActive(true)
		self.node_list["Img_rank"]:SetActive(false)
	end
	self.node_list["hurt"]:SetActive(true)
	self.node_list["hurt"].text.text = CommonDataManager.ConverMoney2(info.own_guild_hurt)
	self.rank_data_list = info.hurt_list
	if self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function LingKunBattleSceneView:BagGetNumberOfCells()
	if self.rank_data_list and #self.rank_data_list then
		return #self.rank_data_list
	end
	return 0
end

function LingKunBattleSceneView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = LingKunHurtRankItem.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function LingKunBattleSceneView:SetIsLingKunBossRange(is_active)
	if nil == self.node_list or self.node_list["Task"] == nil or self.node_list["Hurt"] == nil then
		return
	end
	if self.node_list["Hurt"].toggle and self.node_list["Hurt"].toggle.isActiveAndEnabled then
		self.node_list["Hurt"].toggle.isOn = is_active
	end
	if self.node_list["Task"].toggle and self.node_list["Task"].toggle.isActiveAndEnabled then
		self.node_list["Task"].toggle.isOn = not is_active
	end
end

function LingKunBattleSceneView:FlushScroller()
	if self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function LingKunBattleSceneView:CheckTheStamp()
	local time_stamp_list = LingKunBattleData.Instance:GetLingKunFBSceneinfo().boss_next_flush_timestamp
	if next(self.time_stamp) then
		for k, v in pairs(self.time_stamp) do
			if v ~= time_stamp_list[k] then
				self.time_stamp = {}
				self.time_stamp = time_stamp_list
				-- self:FlushCellList()
				self:FlushCountDown()
				return
			end
		end
	else
		self.time_stamp = time_stamp_list
	end
end

function LingKunBattleSceneView:FlushCountDown()
	if nil ~= self.CountDownTimer then
		CountDown.Instance:RemoveCountDown(self.CountDownTimer)
		self.CountDownTimer = nil
	end

	local ClearTimes = ActivityData.Instance:GetActivityStatuByType(3087).next_time
	local ServerTimes = TimeCtrl.Instance:GetServerTime()
	local end_time = ClearTimes - ServerTimes
	
	local RemindDes
	if nil == self.CountDownTimer then
		self.CountDownTimer = CountDown.Instance:AddCountDown(end_time, 1, function ()
			end_time = end_time - 1
			local FinalTime = TimeUtil.Format2TableDHMS(end_time)
			if FinalTime.s == 0 then
				if FinalTime.min >= 16 and  FinalTime.min < 20 then
					RemindDes = string.format(Language.LingKunBattle.DoorCloseRemind, FinalTime.min - 15)
					TipsCtrl.Instance:ShowActivityNoticeMsg(RemindDes)
				elseif FinalTime.min > 0 and  FinalTime.min <= 5 then
					RemindDes = string.format(Language.LingKunBattle.ActivityCloseRemind, FinalTime.min)
					TipsCtrl.Instance:ShowActivityNoticeMsg(RemindDes)
				end
			end
		end)
	end

end

function LingKunBattleSceneView:LoadCallBack()
	self.item_t = {}
	self.rank_data_list = {}
	self.select_index = 0
	self:InitScroller()
	self.node_list["Txt_tip"].text.text = Language.LingKunBattle.SceneTip
	self:FlushCountDown()
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
	BindTool.Bind(self.PortraitToggleChange, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.node_list["Hurt"].toggle:AddClickListener(BindTool.Bind(self.FlushScroller, self))
end

function LingKunBattleSceneView:PortraitToggleChange(state)
	if self.node_list and self.node_list["TaskParent"] then
		self.node_list["TaskParent"]:SetActive(state)
	end
end

function LingKunBattleSceneView:InitScroller()
	local list_view_delegate = self.node_list["TaskList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function LingKunBattleSceneView:GetNumberOfCells()
	local info = LingKunBattleData.Instance:GetLingKunFBSceneinfo()
	if info then
		local boss_info = info.boss_list
		if next(boss_info) then
			return #boss_info
		end
	end
	return 0
end

function LingKunBattleSceneView:SetSelectIndex(index)
	self.select_index = index
end

function LingKunBattleSceneView:GetSelectIndex()
	return self.select_index
end

function LingKunBattleSceneView:FlushCellHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHl()
	end
end

function LingKunBattleSceneView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = LingKunSceneBossItem.New(cell.gameObject) --实例化item
		self.cell_list[cell] = group_cell
		self.cell_list[cell]:SetInstanceParent(self)
		self.cell_list[cell].mother_view = self
	end

	-- local boss_info = LingKunBattleData.Instance:GetLingKunFBSceneinfo()
	local data = self:ResetCellData(data_index + 1)

	if data then
		self.cell_list[cell]:SetItemIndex(self.cell_list[cell])
		self.cell_list[cell]:SetNumIndex(data_index + 1)
		self.cell_list[cell]:SetData(data)
	end

end

function LingKunBattleSceneView:ResetCellData(index)
	local scene_info = LingKunBattleData.Instance:GetLingKunFBSceneinfo()
	local info_list = {}
	info_list.boss_info = scene_info.boss_list[index]
	info_list.guild_id = scene_info.guild_id[index]
	info_list.boss_next_flush_timestamp = scene_info.boss_next_flush_timestamp[index]
	info_list.zone = scene_info.zone
	return info_list
end

function LingKunBattleSceneView:FlushCellList()
	if self.node_list and self.node_list["TaskList"] and self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshActiveCellViews()
	end
end

function LingKunBattleSceneView:ReloadCellList()
	if self.node_list and self.node_list["TaskList"] and self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function LingKunBattleSceneView:ShowTrunTableInfo()

end

-------------LingKunSceneBossItem---------------
LingKunSceneBossItem = LingKunSceneBossItem or BaseClass(BaseRender)
function LingKunSceneBossItem:__init(instance, parent)
	self.parent = parent
	self.zone = -1
	self.index = 0
	self.num = 0
	self.boss_id = 0
	self.next_refresh_time = 0
	self.is_main_live_flag = nil
	self.node_list["BosstItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function LingKunSceneBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
	self.mother_view = nil
end

function LingKunSceneBossItem:SetNumIndex(index)
	self.num = index
end

function LingKunSceneBossItem:ClickKill(is_click)
	if self.pos_x and self.pos_y then
		self:ClickKillCallBack(self.pos_x, self.pos_y)
	end
end

function LingKunSceneBossItem:ClickKillCallBack(born_x,born_y)
	if self.data == nil then return end
	if ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB) then
		return
	end
	self.mother_view:SetSelectIndex(self.num)
	local info = LingKunBattleData.Instance:GetLingKunFBSceneinfo()
	if info and info.boss_list then
		local boss_info = info.boss_list[self.num] 				-- 如果数据做了排序，那么需要拿一个标志来拿Boss的位置
		if boss_info then
			MoveCache.param1 = boss_info.boss_id
			GuajiCache.monster_id = boss_info.boss_id
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), born_x, born_y, 3, 3)
		end
	end

	self.mother_view:FlushCellHl()
end

function LingKunSceneBossItem:SetData(data)
	self.data = data
	if self.data.zone < 0 then
		local scene_id = Scene.Instance:GetSceneId()
		local config = ConfigManager.Instance:GetSceneConfig(scene_id)
		if config then
			for k,v in pairs(ZONE_NAME_LIST) do
				if v and v == config.name then
					self.zone = k
				end
			end
		end
	else
		self.zone = self.data.zone
	end
	local list = LingKunBattleData.Instance:GetBossZonePosCfg(self.zone)
	if list ~= nil then
		for k,v in pairs(list) do
			if k == "boss_pos_" .. (self.num - 1) then
				local pos = Split(v ,",")
				self:SetPos(tonumber(pos[1]),tonumber(pos[2]))
			end

			if k == "boss_id_" .. (self.num - 1) then
				self.boss_id = v
			end
		end
	end
	self:Flush()
end

function LingKunSceneBossItem:FlushHl()
	self.node_list["ImgHL"]:SetActive(self.num == self.mother_view:GetSelectIndex())
end

function LingKunSceneBossItem:SetItemIndex(index)
	self.index = index
end

function LingKunSceneBossItem:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end

	local boss_id = 0
	local is_ready = ActivityData.Instance:GetActivityIsReady(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_LIEKUN_FB)
	if is_ready then
		boss_id = self.boss_id
	else
		boss_id = self.data.boss_info.boss_id
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[boss_id]

	local name_str
	local list = LingKunBattleData.Instance:GetBossInfomationCfg()
	for k,v in pairs(list) do
		if v.zone == self.data.zone and v.index == self.data.boss_info.index then
			name_str = v.name
		end
	end
	local guild_info = LingKunBattleData.Instance:GetLingKunFBGuildMsgInfo()
	self.is_main_live_flag = guild_info.is_main_live_flag
	local str1 = monster_cfg and monster_cfg.name or name_str
	local str2 = monster_cfg and monster_cfg.level or "100"

	self.node_list["NameTxt"].text.text = str1
	self.node_list["LevelTxt"].text.text = string.format("Lv.%s", str2)

	local boss_data = self.data
	if boss_data then
		self.flush_time = self.data.boss_next_flush_timestamp
		self.statu = self.data.status
		if self.flush_time <= 0 and self.num ~= 1 then
			if not is_ready then
				self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN_4)
			else
				self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.NotRefresh, TEXT_COLOR.RED_4)
			end
		elseif self.flush_time <= 0 and self.num == 1 then 
			if self.is_main_live_flag == 0 then
				self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.HasKill, TEXT_COLOR.RED_4)
			else
				if not is_ready then
					self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN_4)
				else
					self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.NotRefresh, TEXT_COLOR.RED_4)
				end
			end
		else
			if self.time_coundown then
				GlobalTimerQuest:CancelQuest(self.time_coundown)
				self.time_coundown = nil
			end
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
			end
		end

		local scene_id = Scene.Instance:GetSceneId()
		local config = ConfigManager.Instance:GetSceneConfig(scene_id)
		local pos = ""
		if self.pos_x and self.pos_y then
			pos = string.format("%s(%s,%s)", config.name, self.pos_x, self.pos_y)
		else
			pos = string.format("%s", config.name)
		end
		self.node_list["DescTxt"].text.text = pos
	end
	self.node_list["ImgHL"]:SetActive(self.num == self.mother_view:GetSelectIndex())
end

function LingKunSceneBossItem:OnBossUpdate()
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if self.node_list and self.node_list["TimeTxt"] then
		if time <= 0 then
			self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.CanKill, TEXT_COLOR.GREEN_4)
			if self.num == 1 and self.is_main_live_flag == 0 then
				self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.HasKill, TEXT_COLOR.RED_4)
			end
		else
			if nil == self.node_list then return end
			self.node_list["TimeTxt"].text.text = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED_4)
		end
	end
end

function LingKunSceneBossItem:SetPos(x, y)
	self.pos_x = x
	self.pos_y = y
end

function LingKunSceneBossItem:MainBossHasKill()
	if self.num == 1 and self.is_main_live_flag == 0 then
		self.node_list["TimeTxt"].text.text = ToColorStr(Language.Boss.HasKill, TEXT_COLOR.RED_4)
	end
end

-------------LingKunSceneBossItem-END--------------


LingKunHurtRankItem = LingKunHurtRankItem or BaseClass(BaseRender)
function LingKunHurtRankItem:__init()

end

function LingKunHurtRankItem:SetIndex(index)
	self.index = index
end

function LingKunHurtRankItem:SetData(data)
	self.data = data
	self:Flush()
end

function LingKunHurtRankItem:OnFlush()
	if nil == self.data then
		return
	end

	if self.data.guild_name == nil then
		self.node_list["name"]:SetActive(false)
		self.node_list["score"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["rank"]:SetActive(false)
	else
		if self.index <= 3 then
			local bundle, asset = ResPath.GetRankIcon(self.index)
			self.node_list["rank"]:SetActive(false)
			self.node_list["Img_rank"]:SetActive(true)
			self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
		else
			self.node_list["Img_rank"]:SetActive(false)
			self.node_list["rank"]:SetActive(true)
			self.node_list["rank"].text.text = self.index
		end
		self.node_list["name"]:SetActive(true)
		self.node_list["score"]:SetActive(true)
	end

	self.node_list["name"].text.text = self.data.guild_name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt)
end