
ClashTerritoryInfoView = ClashTerritoryInfoView or BaseClass(BaseView)

function ClashTerritoryInfoView:__init()
	self.ui_config = {{"uis/views/clashterritory_prefab", "ClashTerritoryInfoView"}}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.active_close = false
	self.fight_info_view = true
end

function ClashTerritoryInfoView:__delete()

end

function ClashTerritoryInfoView:LoadCallBack()
	self.task_view = TerritoryTaskView.New(self.node_list["TaskView"])
	self.score_view = TerritoryScoreView.New(self.node_list["ScoreView"])
	self.prop_view = TerritoryPropViewView.New(self.node_list["PropView"])
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.MianUIOpenComlete, self))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
end

function ClashTerritoryInfoView:ReleaseCallBack()
	if self.task_view then
		self.task_view:DeleteMe()
		self.task_view = nil
	end
	if self.score_view then
		self.score_view:DeleteMe()
		self.score_view = nil
	end
	if self.prop_view then
		self.prop_view:DeleteMe()
		self.prop_view = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end

end

function ClashTerritoryInfoView:OpenCallBack()
	MainUICtrl.Instance:SetViewState(false)
	self:Flush()
end

function ClashTerritoryInfoView:CloseCallBack()
	MainUICtrl.Instance:SetViewState(true)
end

function ClashTerritoryInfoView:MianUIOpenComlete()
	MainUICtrl.Instance:SetViewState(false)
	self:Flush()
end

function ClashTerritoryInfoView:OnMainUIModeListChange(is_show)
	self.node_list["ClashTerritoryInfoPanel"]:SetActive(is_show)
end

function ClashTerritoryInfoView:OnFlush()

end

----------------------任务View----------------------
TerritoryTaskView = TerritoryTaskView or BaseClass(BaseRender)
function TerritoryTaskView:__init()
	self.node_list["BtnCollection"].button:AddClickListener(BindTool.Bind(self.CollectionClick, self))
	self.node_list["BtnShop"].button:AddClickListener(BindTool.Bind(self.ShopClick, self))
	self.info_change_callback = BindTool.Bind(self.Flush, self)
	self.global_info_change_callback = BindTool.Bind(self.Flush, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.GLOBAL_INFO_CHANGE, self.global_info_change_callback)
	self:Flush()
end

function TerritoryTaskView:__delete()
	if ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.GLOBAL_INFO_CHANGE, self.global_info_change_callback)
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TerritoryTaskView:CollectionClick()
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("territorywar_auto").other[1]
	local x, y = 0, 0
	if data.side == 0 then
		x = other_cfg.blue_guaji_pos_x
		y = other_cfg.blue_guaji_pos_y
	else
		x = other_cfg.red_guaji_pos_x
		y = other_cfg.red_guaji_pos_y
	end
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(other_cfg.scene_id, x, y, 1, 1)
end

function TerritoryTaskView:ShopClick()
	ViewManager.Instance:Open(ViewName.ClashTerritoryShop)
end

function TerritoryTaskView:Flush()
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()
	self:DoActivityCountDown()

	local red_per = data.red_fortress_curr_hp / data.red_fortress_max_hp
	local blue_per = data.blue_fortress_curr_hp / data.blue_fortress_max_hp
	self.node_list["SliderMine"].slider.value = (data.side == 0 and blue_per or red_per)
	self.node_list["SliderEnemy"].slider.value = (data.side == 0 and red_per or blue_per)
	self.node_list["SliderRevive"].slider.value = data.center_relive_curr_hp / data.center_relive_max_hp

	local color = data.center_relive_side == 1 and "ff0000" or (data.center_relive_side == 0 and "0000ff" or "ffffff")
	self.node_list["TextValueRevive"].slider.value = string.format(Language.ClashTerritory.ReviveBelong, color, Language.ClashTerritory.GuildColor[data.center_relive_side] or "")
end

function TerritoryTaskView:DoActivityCountDown()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.CLASH_TERRITORY)
	local end_time = activity_info and activity_info.next_time or 0
	local total_time = end_time - TimeCtrl.Instance:GetServerTime()
	self:SetCountDownByTotalTime(total_time)
end

function TerritoryTaskView:SetCountDownByTotalTime(total_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time2)
			if elapse_time >= total_time2 then
				self.node_list["TxtTime"].text.text = "00:00:00"
				if self.count_down then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end

			local left_time = math.ceil(total_time2 - elapse_time)
			local h, m, s = WelfareData.Instance:TimeFormat(left_time)
			self.node_list["TxtTime"].text.text = string.format("%02d:%02d:%02d", h, m, s)
		end

		diff_time_func(0, total_time)
		self.count_down = CountDown.Instance:AddCountDown(
			total_time, 1, diff_time_func)
	end
end

----------------------积分View----------------------
TerritoryScoreView = TerritoryScoreView or BaseClass(BaseRender)
function TerritoryScoreView:__init()
	self.info_change_callback = BindTool.Bind(self.Flush, self)
	self.global_info_change_callback = BindTool.Bind(self.Flush, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.GLOBAL_INFO_CHANGE, self.global_info_change_callback)
	self.cells = {}
	for i = 1, 3 do
		self.cells[i] = {}
		self.cells[i].obj = self.node_list["Item" .. i]
		self.cells[i].cell = ItemCell.New(self.cells[i].obj)
	end
	self:Flush()
end

function TerritoryScoreView:__delete()
	if ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.GLOBAL_INFO_CHANGE, self.global_info_change_callback)
	end
	for k,v in pairs(self.cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.cells = {}
end

function TerritoryScoreView:Flush()
	-- 可用积分
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()
	self.node_list["TxtScore"].text.text  = string.format(Language.ClashTerritory.CanUseScore, data.current_credit)

	-- 己方、敌方仙盟积分
	local my_guild_score = data.side == 0 and data.blue_guild_credit or data.red_guild_credit
	local enemy_score = data.side == 0 and data.red_guild_credit or data.blue_guild_credit
	self.node_list["TxtGuildScore"].text.text = string.format(Language.ClashTerritory.MineGuildScore, my_guild_score)
	self.node_list["TxtEnemyScore"].text.text = string.format(Language.ClashTerritory.EnemyGuildScore, enemy_score)

	-- 达到积分获得奖励
	local rewards, is_max_score = ClashTerritoryData.Instance:GetTerritoryRewawrdCfg()
	rewards = rewards or {}
	local MyHistoryScore = data.history_credit
	local ReachScore = rewards and rewards.person_credit_min or 0
	self.node_list["TxtReachScore"].text.text = string.format(Language.ClashTerritory.ReachTargetScore, MyHistoryScore, ReachScore)
	self.node_list["TxtMaxScore"]:SetActive(is_max_score or false)

	for k, v in ipairs(self.cells) do
		local reward = rewards["item" .. k]
		if reward and reward.item_id > 0 then
			v.obj:SetActive(true)
			v.cell:SetData(reward)
		else
			v.cell:SetData()
			v.obj:SetActive(false)
		end
	end
end

function TerritoryScoreView:RankClick()
end

----------------------道具面板----------------------
TerritoryPropViewView = TerritoryPropViewView or BaseClass(BaseRender)
function TerritoryPropViewView:__init()
	self.node_list["BtnFireMine"].button:AddClickListener(BindTool.Bind(self.OnClickFireMine, self))
	self.node_list["BtnIceMine"].button:AddClickListener(BindTool.Bind(self.OnClickIceMine, self))

	self.info_change_callback = BindTool.Bind(self.Flush, self)
	ClashTerritoryData.Instance:AddListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	self:Flush()
end

function TerritoryPropViewView:__delete()
	if ClashTerritoryData.Instance then
		ClashTerritoryData.Instance:RemoveListener(ClashTerritoryData.INFO_CHANGE, self.info_change_callback)
	end
end

function TerritoryPropViewView:OnClickFireMine()
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local x, y = main_role:GetLogicPos()
		ClashTerritoryCtrl.SendTerritorySetLandMine(0, x, y)
	end
end

function TerritoryPropViewView:OnClickIceMine()
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		local x, y = main_role:GetLogicPos()
		ClashTerritoryCtrl.SendTerritorySetLandMine(1, x, y)
	end
end

function TerritoryPropViewView:Flush()
	local data = ClashTerritoryData.Instance:GetTerritoryWarData()
	
	local is_active_layer = data.fire_landmine_count > 0 or data.ice_landmine_count > 0
	local is_active_fire_mine = data.fire_landmine_count > 0
	local is_active_ice_mine = data.ice_landmine_count > 0

	self.node_list["ImgLayer"]:SetActive(is_active_layer)
	self.node_list["BtnFireMine"]:SetActive(is_active_fire_mine)
	self.node_list["BtnIceMine"]:SetActive(is_active_ice_mine)

	self.node_list["FireMineNum"].text.text = data.fire_landmine_count
	self.node_list["IceMineNum"].text.text = data.ice_landmine_count
end
