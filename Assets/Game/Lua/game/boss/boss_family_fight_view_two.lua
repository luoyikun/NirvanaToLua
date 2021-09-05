BossFamilyFightViewTwo = BossFamilyFightViewTwo or BaseClass(BaseView)

function BossFamilyFightViewTwo:__init()
	self.ui_config = {{"uis/views/bossview_prefab", "BossFamilyFightView2"}}
	self.active_close = false
	self.click_flag = false
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.info_event = BindTool.Bind(self.Flush, self)
	self.last_remind_time = 0
end

function BossFamilyFightViewTwo:ReleaseCallBack()
	if self.boss_panel then
		self.boss_panel:DeleteMe()
		self.boss_panel = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	-- 清理变量和对象
	self.show_panel = nil
	self.show_refresh_text = nil
	self.ismax_level = nil
	self.have_left_count = nil
	self.show_tips = nil
	self.is_miku_scene = nil
end

function BossFamilyFightViewTwo:LoadCallBack()
	self.boss_panel = BossFamilybossViewTwo.New(self.node_list["BossPanel"])
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
	self.rank_view = BossFamilyBossRankViewTwo.New(self.node_list["ScoreRank"])
	self:Flush()
end

function BossFamilyFightViewTwo:ClickInfo()
	if self.click_flag == false then
		self.click_flag = true
		self:Flush("team_type")
		self:FlushTabHl(false)
	else
		ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
	end
end

function BossFamilyFightViewTwo:ClickBoss()
	self.click_flag = false
	self.boss_panel:Flush()
	self:FlushTabHl(true)
end

function BossFamilyFightViewTwo:ClickIcon()
	self.show_tips = false
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightViewTwo:CloseTips()
	self.show_tips = false
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightViewTwo:FlushTabHl(show_boss)
	self.node_list["ImgShowBossHL"]:SetActive(show_boss)
	self.node_list["ImgShowTeamHL"]:SetActive(not show_boss)
end

function BossFamilyFightViewTwo:SetIsMikuBossRange(is_active)
	if self.node_list["BtnInfo"] == nil or self.node_list["boss_btn"] == nil then
		return
	end
	self.node_list["BtnInfo"].toggle.isOn = is_active
	self.node_list["boss_btn"].toggle.isOn = not is_active
end

function BossFamilyFightViewTwo:OpenCallBack()
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
		GuajiCtrl.Instance:MoveToPos(info.scene_id, info.born_x, info.born_y, 10, 10)
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
end

function BossFamilyFightViewTwo:CloseCallBack()
	local boss_type = BossData.Instance:GetBossType()
	if BossData.Instance then
		BossData.Instance:RemoveListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
	end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.root_node.gameObject.activeSelf and self.node_list["track_info"].gameObject.activeSelf then
		self.node_list["boss_btn"].toggle.isOn = true
		self:FlushTabHl(true)
	end
	self.click_flag = false

	self:StopEliteTimeQuest()
end

--刷新精英怪描述
function BossFamilyFightViewTwo:RefreshEliteDes()
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

function BossFamilyFightViewTwo:StopEliteTimeQuest()
	if self.elite_time_quest then
		GlobalTimerQuest:CancelQuest(self.elite_time_quest)
		self.elite_time_quest = nil
	end
end

function BossFamilyFightViewTwo:StartEliteTimeQuest()
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

function BossFamilyFightViewTwo:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function BossFamilyFightViewTwo:FlushRankView()
	if self.rank_view then
		self.rank_view:Flush()
	end
end

function BossFamilyFightViewTwo:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	self.show_panel = state
	self.node_list["PanelContent"]:SetActive(self.show_panel and self.is_miku_scene)
	self.node_list["track_info"]:SetActive(self.show_panel)
	self.node_list["PanelTips"]:SetActive(self.show_tips and self.show_panel)
end

function BossFamilyFightViewTwo:OnFlush(param_t)
	local boss_type = BossData.Instance:GetBossType()
	self.is_miku_scene = false  -- 直接屏蔽
	self.node_list["PanelContent"]:SetActive(self.show_panel and self.is_miku_scene)
	-- self.boss_panel:SetCurIndex(0)
	for k,v in pairs(param_t) do
		if k == "boss_type" then
			BossData.Instance:AddListener(boss_type == BOSS_TYPE.FAMILY_BOSS and BossData.FAMILY_BOSS or BossData.MIKU_BOSS, self.info_event)
			self.boss_panel:Flush()
		elseif k == "open_flush" then
			self.node_list["boss_btn"].toggle.isOn = true
			self:FlushTabHl(true)
		elseif k == "elite" then
			self:RefreshEliteDes()
		else
			self.boss_panel:Flush()
		end
	end

	-- if boss_type == BOSS_TYPE.FAMILY_BOSS then
		self.node_list["TextWeary"]:SetActive(false)
	-- else
	-- 	local boss_data = BossData.Instance
	-- 	local max_wearry = boss_data:GetMikuBossMaxWeary()
	-- 	local weary = max_wearry - boss_data:GetMikuBossWeary()
	-- 	local pi_lao_text = ""
	-- 	if weary <= 0 then
	-- 		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
	-- 	else
	-- 		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.GREEN)
	-- 	end
	-- 	local max_text = ToColorStr(tostring(max_wearry), TEXT_COLOR.GREEN)
	-- 	self.node_list["TextWeary"]:SetActive(true)
	-- 	self.node_list["TextWeary"].text.text = string.format(Language.Boss.MiKiBossPiLaoValue, pi_lao_text .. " / " .. max_text)
	-- end
end

function BossFamilyFightViewTwo:SwitchButtonState(enable)
	if self.shrink_button_toggle and self:IsOpen() then
		self.shrink_button_toggle.isOn = not enable
	end
end

------------------------领主boss----------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
BossFamilybossViewTwo = BossFamilybossViewTwo or BaseClass(BaseRender)
function BossFamilybossViewTwo:__init()
	-- 获取控件
	self.item_t= {}
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.cur_index = 0
	self:Flush()
end

function BossFamilybossViewTwo:__delete()
	for _, v in pairs(self.item_t) do
		v:DeleteMe()
	end

	self.item_t= {}
end

function BossFamilybossViewTwo:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function BossFamilybossViewTwo:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossFamilyBossItemTwo.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end

	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function BossFamilybossViewTwo:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	local boss_type = BossData.Instance:GetBossType()
	if boss_type == BOSS_TYPE.FAMILY_BOSS then
		return BossData.Instance:GetBossFamilyList(scene_id)
	else
		return BossData.Instance:GetMikuBossList(scene_id)
	end
end

function BossFamilybossViewTwo:SetCurIndex(index)
	self.cur_index = index
end

function BossFamilybossViewTwo:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossFamilybossViewTwo:GetCurIndex()
	return self.cur_index
end

function BossFamilybossViewTwo:GetCurBossId()
	return self.select_boss_id
end

function BossFamilybossViewTwo:SetIsJump(enable)
	self.is_jump = enable
end

function BossFamilybossViewTwo:OnFlush()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
		if self.is_jump and self.cur_index > 1 then
			self.node_list["TaskList"].scroller:ReloadData(self.cur_index / (#self:GetDataList() or 0))
			self.is_jump = false
		end
	end
end

function BossFamilybossViewTwo:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end

------------------------------------------------------------------------
------------------BossFamilyBossItemTwo-------------------------------------
------------------------------------------------------------------------
BossFamilyBossItemTwo = BossFamilyBossItemTwo or BaseClass(BaseRender)

function BossFamilyBossItemTwo:__init(instance, parent)
	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function BossFamilyBossItemTwo:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossFamilyBossItemTwo:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.bossID)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.born_x, self.data.born_y, 10, 10)
	self.parent:FlushAllHl()
	return
end

function BossFamilyBossItemTwo:SetData(data)
	self.data = data
	self:Flush()
end

function BossFamilyBossItemTwo:GetBossData(boss_id)
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

function BossFamilyBossItemTwo:SetItemIndex(index)
	self.index = index
end

function BossFamilyBossItemTwo:Flush()
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
		self.time = Language.Dungeon.CanKill
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end

	self:FlushHl()
end

function BossFamilyBossItemTwo:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.bossID)
	end
end

function BossFamilyBossItemTwo:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ToColorStr(Language.Dungeon.CanKill, TEXT_COLOR.GREEN)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	else
		self.time = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
		self.node_list["TxtTime"].text.text = string.format("<color=%s>%s</color>", self.time_color, self.time)
	end
end

----------------------排行View----------------------
BossFamilyBossRankViewTwo = BossFamilyBossRankViewTwo or BaseClass(BaseRender)
function BossFamilyBossRankViewTwo:__init()
	-- 获取控件
	self.rank_data_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.item_t = {}
	self:Flush()
end

function BossFamilyBossRankViewTwo:__delete()
	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

-----------------------------------
-- ListView逻辑
-----------------------------------
function BossFamilyBossRankViewTwo:BagGetNumberOfCells()
	return math.max(#self.rank_data_list, 5)
end

function BossFamilyBossRankViewTwo:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = BossFamilyRankItemTwo.New(cell.gameObject)
		self.item_t[cell] = item
	end
	item:SetIndex(cell_index + 1)
	if self.rank_data_list[cell_index + 1] then
		item:SetData(self.rank_data_list[cell_index + 1])
	else
		item:SetData({name = "--", hurt = 0})
	end
end

function BossFamilyBossRankViewTwo:OnFlush()
	local info = BossData.Instance:GetMikuBossPersonalHurtInfo()
	self.node_list["name"].text.text = PlayerData.Instance.role_vo.name
	self.node_list["rank"].text.text = Language.Boss.NotOnRank
	if PlayerData.Instance.role_vo.name == nil then
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"]:SetActive(false)
		self.node_list["hurt"]:SetActive(false)
	end
	if info == nil or next(info) == nil then
		return
	end

	if info.my_rank > 0 and info.my_rank <= 3 then
		local bundle, asset = ResPath.GetRankIcon(info.my_rank)
		self.node_list["Img_rank"]:SetActive(true)
		self.node_list["rank"]:SetActive(false)
		self.node_list["Img_rank"].image:LoadSprite(bundle, asset)
	else
		self.node_list["rank"].text.text = (info.my_rank > 5 or info.my_rank == 0) and Language.Boss.NotOnRank or info.my_rank
		self.node_list["rank"]:SetActive(true)
		self.node_list["Img_rank"]:SetActive(false)
	end
	self.node_list["hurt"]:SetActive(true)
	self.node_list["hurt"].text.text = ToColorStr(CommonDataManager.ConverMoney2(info.my_hurt), TEXT_COLOR.GREEN)
	self.rank_data_list = info.rank_list
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

BossFamilyRankItemTwo = BossFamilyRankItemTwo or BaseClass(BaseRender)
function BossFamilyRankItemTwo:__init()

end

function BossFamilyRankItemTwo:SetIndex(index)
	self.index = index
end

function BossFamilyRankItemTwo:SetData(data)
	self.data = data
	self:Flush()
end

function BossFamilyRankItemTwo:OnFlush()
	if nil == self.data then
		return
	end
	if self.data.name == nil then
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

	self.node_list["name"].text.text = self.data.name
	self.node_list["score"].text.text = CommonDataManager.ConverMoney2(self.data.hurt)
end