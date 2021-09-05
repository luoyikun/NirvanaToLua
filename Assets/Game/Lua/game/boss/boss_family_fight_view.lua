BossFamilyFightView = BossFamilyFightView or BaseClass(BaseView)
local TIRED_ITEM_ID = 23232                 --困难Boss疲劳卡
local FLUSH_ITEM_ID = 24605                 --BOSS刷新卡
function BossFamilyFightView:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "BossFamilyFightView"}}
	self.active_close = false
	self.click_flag = false
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true                        -- IphoneX适配
	self.info_event = BindTool.Bind(self.Flush, self)
	self.last_remind_time = 0
end

function BossFamilyFightView:ReleaseCallBack()
	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.team_panel then
		self.team_panel:DeleteMe()
		self.team_panel = nil
	end

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	-- 清理变量和对象
	self.show_panel = nil
	self.show_refresh_text = nil
	self.ismax_level = nil
	self.have_left_count = nil
	self.show_tips = nil
	self.is_miku_scene = nil
end

function BossFamilyFightView:LoadCallBack()
	self.boss_panel = BossFamilybossView.New(self.node_list["BossPanel"])
	self.team_panel = BossFamilyTeamInfo.New(self.node_list["TeamPanel"])
	self.show_refresh_text = true
	self.ismax_level = false
	self.have_left_count = false
	self.show_tips = false
	self.is_miku_scene = true
	self.show_panel = true
	self.node_list["BtnInfo"].toggle:AddClickListener(BindTool.Bind(self.ClickInfo, self))
	self.node_list["boss_btn"].toggle:AddClickListener(BindTool.Bind(self.ClickBoss, self))
	self.node_list["ImgIcon"].button:AddClickListener(BindTool.Bind(self.ClickIcon, self))
	self.node_list["PanelTips"].button:AddClickListener(BindTool.Bind(self.CloseTips, self))
	self.node_list["TiredCard"].button:AddClickListener(BindTool.Bind(self.ClickTiredCard, self))
	self.node_list["FlushCard"].button:AddClickListener(BindTool.Bind(self.ClickFlushCard, self))
	self:Flush()

	local item_cfg = ItemData.Instance:GetItemConfig(TIRED_ITEM_ID)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ImgCardIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgCardIcon"].image:SetNativeSize()
		end)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(FLUSH_ITEM_ID)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ImgFlushCardIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgFlushCardIcon"].image:SetNativeSize()
		end)
	end
end

function BossFamilyFightView:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function BossFamilyFightView:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush()
	self:FlushTabHl(true)
end

function BossFamilyFightView:ClickIcon()
	self.show_tips = false
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightView:CloseTips()
	self.show_tips = false
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightView:ClickTiredCard()
	local data = ItemData.Instance:GetItem(TIRED_ITEM_ID)
	local item_cfg = ItemData.Instance:GetItemConfig(TIRED_ITEM_ID)
	local des = ""
	if data and item_cfg then
		local name = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">" ..item_cfg.name.."</color>"
		des = string.format(Language.Boss.IsUseTiredCard, name)
		local func = function()
			PackageCtrl.Instance:SendUseItem(data.index, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	end
end

function BossFamilyFightView:ClickFlushCard()
	local scene_id = Scene.Instance:GetSceneId()
	BossData.Instance:UseFlushCard(scene_id)
end

function BossFamilyFightView:FlushTabHl(show_boss)
	self.node_list["ImgShowBossHL"]:SetActive(show_boss)
	self.node_list["ImgShowTeamHL"]:SetActive(not show_boss)

end

function BossFamilyFightView:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == TIRED_ITEM_ID then
		local scene_id = Scene.Instance:GetSceneId()
		self.node_list["TiredCard"]:SetActive(new_num > 0 and BossData.Instance:IsMikuBossScene(scene_id))
	elseif item_id == FLUSH_ITEM_ID then
		local scene_id = Scene.Instance:GetSceneId()
		self.node_list["FlushCard"]:SetActive(new_num > 0 and BossData.Instance:IsMikuBossScene(scene_id))
	end
end

function BossFamilyFightView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	local item_num = ItemData.Instance:GetItemNumInBagById(TIRED_ITEM_ID)
	self.node_list["TiredCard"]:SetActive(item_num > 0 and BossData.Instance:IsMikuBossScene(scene_id))

	local item_num_1 = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	self.node_list["FlushCard"]:SetActive(item_num_1 > 0 and BossData.Instance:IsMikuBossScene(scene_id))

	local boss_data = BossData.Instance
	local boss_type = BossData.Instance:GetBossType()
	local info = nil
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
	else
		info = boss_data:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	end
	if info then
		if boss_data:GetAutoComeFlag() then
			MoveCache.end_type = MoveEndType.Normal
			boss_data:SetAutoComeFlag(false)
		else
			MoveCache.end_type = MoveEndType.Auto
		end
		local callback = function()
			GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end

	if self.boss_panel and info then
		local list = self.boss_panel:GetDataList()
		if list then
			for k,v in pairs(list) do
				if info.bossID == v.bossID then
					self.boss_panel.cur_index = k
					self.boss_panel.select_boss_id = v.bossID
				end
			end
		end
		self.boss_panel:Flush()
	end

	self.show_tips = false
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
	self.node_list["TxtTipDes"].text.text = Language.Boss.BossMiKuTips

	self:RefreshEliteDes()
	self.boss_panel:SetIsJump(true)

	self:Flush("open_flush")
	self:Flush("team_type")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
end

function BossFamilyFightView:CloseCallBack()
	local boss_type = BossData.Instance:GetBossType()
	if BossData.Instance then
		BossData.Instance:RemoveListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
	end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end

	if self.root_node.gameObject.activeSelf and self.node_list["track_info"].gameObject.activeSelf then
		self.node_list["boss_btn"].toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = false

	self:StopEliteTimeQuest()
end

--刷新精英怪描述
function BossFamilyFightView:RefreshEliteDes()
	--先停止计时器
	self:StopEliteTimeQuest()

	local max_level = BossData.Instance:GetMiKuEliteDropMaxLevel(Scene.Instance:GetSceneId())
	if GameVoManager.Instance:GetMainRoleVo().level >= max_level then
		--等级过高不算时间
		self.ismax_level = true
		self.node_list["TxtRefresh"]:SetActive(self.show_refresh_text and (not self.ismax_level) and (not self.have_left_count))
		self.node_list["TxtLeftContent"]:SetActive(self.have_left_count and (not self.ismax_level))
		self.node_list["TxtMaxLevel"]:SetActive(self.ismax_level)
	else
		self.ismax_level = false
		self.node_list["TxtRefresh"]:SetActive(self.show_refresh_text and (not self.ismax_level) and (not self.have_left_count))
		self.node_list["TxtLeftContent"]:SetActive(self.have_left_count and (not self.ismax_level))
		self.node_list["TxtMaxLevel"]:SetActive(self.ismax_level)

		--获取是否有剩余精英怪(有就不进行倒计时了)
		local count = BossData.Instance:GetMikuEliteCountBySeceneId(Scene.Instance:GetSceneId())
		if count > 0 then
			self.have_left_count = true
			self.node_list["TxtRefresh"]:SetActive(self.show_refresh_text and (not self.ismax_level) and (not self.have_left_count))
			self.node_list["TxtLeftContent"]:SetActive(self.have_left_count and (not self.ismax_level))
			self.node_list["TxtTimeCount"].text.text = count
		else
			--开始计算精英怪刷新时间
			self.have_left_count = false
			self.node_list["TxtRefresh"]:SetActive(self.show_refresh_text and (not self.ismax_level) and (not self.have_left_count))
			self.node_list["TxtLeftContent"]:SetActive(self.have_left_count and (not self.ismax_level))
			self:StartEliteTimeQuest()
		end
	end
end

function BossFamilyFightView:StopEliteTimeQuest()
	if self.elite_time_quest then
		GlobalTimerQuest:CancelQuest(self.elite_time_quest)
		self.elite_time_quest = nil
	end
end

function BossFamilyFightView:StartEliteTimeQuest()
	self:StopEliteTimeQuest()

	local left_times = BossData.Instance:GetRefreshEliteLeftTimes()
	
	local function set_times()
		--组合字符串
		local des = ""
		if left_times >= 3600 then
			des = TimeUtil.FormatSecond(left_times)
		else
			des = TimeUtil.FormatSecond(left_times, 2)
		end
		self.node_list["TxtTime"].text.text = des
	end

	local function time_func()
		left_times = BossData.Instance:GetRefreshEliteLeftTimes()
		set_times()
	end

	set_times()
	self.elite_time_quest = GlobalTimerQuest:AddRunQuest(time_func, 1)
end

function BossFamilyFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function BossFamilyFightView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.show_panel = state
	self.node_list["PanelContent"]:SetActive(self.show_panel and self.is_miku_scene)
	self.node_list["track_info"]:SetActive(self.show_panel)
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightView:OnFlush(param_t)
	local boss_type = BossData.Instance:GetBossType()

	local item_num_1 = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	local scene_id = Scene.Instance:GetSceneId()
	self.node_list["FlushCard"]:SetActive(item_num_1 > 0 and BossData.Instance:IsMikuBossScene(scene_id))

	local num2 = ItemData.Instance:GetItemNumInBagById(TIRED_ITEM_ID)
	self.node_list["TiredCard"]:SetActive(num2 > 0 and BossData.Instance:IsMikuBossScene(scene_id))
	self.is_miku_scene = false  -- 直接屏蔽
	self.node_list["PanelContent"]:SetActive(self.show_panel and self.is_miku_scene)
	-- self.boss_panel:SetCurIndex(0)
	for k,v in pairs(param_t) do
		if k == "boss_type" then
			BossData.Instance:AddListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
			self.boss_panel:Flush()
		elseif k == "team_type" then
			self.team_panel:Flush()
		elseif k == "open_flush" then
			self.node_list["boss_btn"].toggle.isOn = true
			self:FlushTabHl(true)
		elseif k == "elite" then
			self:RefreshEliteDes()
		else
			self.boss_panel:Flush()
		end
	end

	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		self.node_list["TextWeary"]:SetActive(false)
	else
		local boss_data = BossData.Instance
		local max_wearry = boss_data:GetMikuBossMaxWeary()
		local weary = max_wearry - boss_data:GetMikuBossWeary()
		local pi_lao_text = ""
		if weary <= 0 then
			-- self.node_list["Text_tip"].text.text = Language.Boss.NoWearyTip 
			pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
		else
			pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.GREEN)
		end
		self.node_list["Text_tip"]:SetActive(weary <= 0)
		local max_text = ToColorStr(tostring(max_wearry), TEXT_COLOR.GREEN)
		self.node_list["TextWeary"]:SetActive(true)
		self.node_list["TextWeary"].text.text = string.format(Language.Boss.MiKiBossPiLaoValue, pi_lao_text .. " / " .. max_text)
	end
end

function BossFamilyFightView:SwitchButtonState(enable)
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
BossFamilybossView = BossFamilybossView or BaseClass(BaseRender)
function BossFamilybossView:__init()
	-- 获取控件
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t= {}
	self.cur_index = 0
	self.select_boss_id = 0
	self:Flush()
end

function BossFamilybossView:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function BossFamilybossView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function BossFamilybossView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossFamilyBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function BossFamilybossView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		return BossData.Instance:GetBossFamilyList(scene_id)
	else
		return BossData.Instance:GetMikuBossList(scene_id)
	end
end

function BossFamilybossView:SetCurIndex(index)
	self.cur_index = index
end

function BossFamilybossView:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossFamilybossView:GetCurIndex()
	return self.cur_index
end

function BossFamilybossView:GetCurBossId()
	return self.select_boss_id
end

function BossFamilybossView:SetIsJump(enable)
	self.is_jump = enable
end

function BossFamilybossView:Flush()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
		if self.is_jump and self.cur_index > 1 then
			self.node_list["TaskList"].scroller:ReloadData(self.cur_index / (#self:GetDataList() or 0))
			self.is_jump = false
		end
	end
end

function BossFamilybossView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

------------------------------------------------------------------------
------------------BossFamilyBossItem-------------------------------------
------------------------------------------------------------------------
BossFamilyBossItem = BossFamilyBossItem or BaseClass(BaseRender)

function BossFamilyBossItem:__init(instance, parent)
	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function BossFamilyBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossFamilyBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.bossID)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 10, 10)
	self.parent:FlushAllHl()
	return
end

function BossFamilyBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function BossFamilyBossItem:GetBossData(boss_id)
	local boss_info = nil
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		boss_info = BossData.Instance:GetFamilyBossInfo(self.data.scene_id)
	else
		boss_info = BossData.Instance:GetMikuBossInfoList(self.data.scene_id)
	end
	if nil == boss_info then
		return
	end
	for k,v in pairs(boss_info) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function BossFamilyBossItem:SetItemIndex(index)
	self.index = index
end

function BossFamilyBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		if monster_cfg.boss_type == 3 then
			self.node_list["TxtName"].text.text = ToColorStr(monster_cfg.name, TEXT_COLOR.YELLOW)
		end
		self.node_list["TextLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
	end
	self.node_list["Desc"].text.text = self.data.scene_show
	local boss_data = self:GetBossData(self.data.bossID)
	if boss_data then
		self.time_color = boss_data.status == 1 and TEXT_COLOR.GREEN_4 or "#ff0000ff"
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
		self.next_refresh_time = boss_data.next_refresh_time
		if boss_data.status == 1 then
			-- if self.time_coundown then
			--  GlobalTimerQuest:CancelQuest(self.time_coundown)
			--  self.time_coundown = nil
			--  self.time = Language.Dungeon.CanKill
			--  self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
			-- end
			self.time = Language.Dungeon.CanKill
			self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
		else
			if self.time_coundown == nil then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, 99999999)
			end
			self:OnBossUpdate()
		end
	else
		self.time_color = TEXT_COLOR.GREEN_4
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
		-- if self.time_coundown then
		--  GlobalTimerQuest:CancelQuest(self.time_coundown)
		--  self.time_coundown = nil
		-- end
		self.time = Language.Dungeon.CanKill
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end

	self:FlushHl()
end

function BossFamilyBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.bossID)
	end
end

function BossFamilyBossItem:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	else
		self.time = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end
end

--组队------------------------------------
------------------------------------------
------------------------------------------
BossFamilyTeamInfo = BossFamilyTeamInfo or BaseClass(BaseRender)
function BossFamilyTeamInfo:__init()
	self.team_cells = {}

	self.node_list["BtnExitButton"].button:AddClickListener(BindTool.Bind(self.ExitClick, self))
	self.node_list["BtnOpenTeam"].button:AddClickListener(BindTool.Bind(self.OpenTeam, self))
	self.node_list["ButtonCreateTeam"].button:AddClickListener(BindTool.Bind(self.CreateTeam, self))

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.contain_cell_list = {}
	local list_delegate = self.node_list["list_view"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function BossFamilyTeamInfo:__delete()
	self.add_exp_text = nil
	self.show_add_exp = nil
	self.show_exit_btn = nil
	self.show_create_team = nil

	self.team_cells = {}
	self.star_gray_list = {}

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function BossFamilyTeamInfo:GetNumberOfCells()
	return #self.team_list
end

function BossFamilyTeamInfo:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = BossFamilyTeamCell.New(cell.gameObject, self)
		contain_cell.parent = self
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.team_list[cell_index])
end

function BossFamilyTeamInfo:OnChangeScene()
	self:Flush()
end

function BossFamilyTeamInfo:ExitClick()
	ScoietyCtrl.Instance:ExitTeamReq()
end

function BossFamilyTeamInfo:OpenTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end

function BossFamilyTeamInfo:CreateTeam()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	local param_t = {}
	param_t.must_check = 0
	param_t.assign_mode = 1
	ScoietyCtrl.Instance:CreateTeamReq(param_t, true)
end

function BossFamilyTeamInfo:OnFlush()
	self.team_list = ScoietyData.Instance:GetMemberList()
	self.node_list["PanelShowCreat"]:SetActive(not next(self.team_list))
	for i = 1, 3 do
		UI:SetGraphicGrey(self.node_list["ImgGrayPerson" .. i], not (i <= #self.team_list and self.team_list[i].is_online == 1))
	end

	self.node_list["PanelShowPerson"]:SetActive(#self.team_list > 0)

	self.node_list["TxtAddExp"].text.text = string.format("EXP+%s", ScoietyData.Instance:GetTeamExp(self.team_list)) .. "%"

	self.node_list["BtnExitButton"]:SetActive(#self.team_list > 0)
	if self.node_list["list_view"].scroller.isActiveAndEnabled then
		self.node_list["list_view"].scroller:ReloadData(0)
	end
end

function BossFamilyTeamInfo:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyTeamInfo:GetSelectIndex()
	return self.select_index or 0
end

function BossFamilyTeamInfo:FlushAllHl()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushHl(self.select_index)
	end
end
---------------------------------------------------------------
BossFamilyTeamCell = BossFamilyTeamCell or BaseClass(BaseCell)
function BossFamilyTeamCell:__init()

	self.node_list["BossMenberItem"].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self))

end

function BossFamilyTeamCell:__delete()
	self.role_name = nil
	self.level_text = nil
	self.menber_state = nil
	self.parent = nil
end

function BossFamilyTeamCell:OnFlush()
	self.root_node.gameObject:SetActive(self.data ~= nil and next(self.data) ~= nil)
	if not self.data or not next(self.data) then return end

	-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
	local member_state = ScoietyData.Instance:GetMemberPosState(self.data.role_id, self.data.scene_id, self.data.is_online)
	self.node_list["TxtName"].text.text = self.data.name
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, PlayerData.GetLevelString(self.data.level))
	self.node_list["TxtState"].text.text = member_state

end

function BossFamilyTeamCell:ClickItem()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if main_role_id == self.data.role_id then
		self.node_list["ImgHL"]:SetActive(false)
		return
	end

	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()

	local function canel_callback()
		if self.root_node then
			self.node_list["ImgHL"]:SetActive(false)
		end
	end

	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.name, nil, canel_callback)
end

function BossFamilyTeamCell:FlushHl(cur_index)
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self.node_list["ImgHL"]:SetActive(self.data and cur_index == self.index and main_role_id ~= self.data.role_id)
end