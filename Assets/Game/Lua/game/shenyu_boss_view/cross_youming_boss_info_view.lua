CrossYouMingBossInfoView = CrossYouMingBossInfoView or BaseClass(BaseView)

function CrossYouMingBossInfoView:__init()
	self.ui_config = {{"uis/views/shenyubossview_prefab", "CrossFightBossInfoView"}}
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.item_t = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function CrossYouMingBossInfoView:__delete()

end

function CrossYouMingBossInfoView:ReleaseCallBack()
	if BossData.Instance then
		BossData.Instance:RemoveListener(BossData.ACTIVE_BOSS, self.dabao_info_event)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end

	for k,v in pairs(self.item_t) do
		v:DeleteMe()
	end
	self.item_t = {}
end

function CrossYouMingBossInfoView:LoadCallBack()
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self:Flush()
end

function CrossYouMingBossInfoView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function CrossYouMingBossInfoView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function CrossYouMingBossInfoView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	local info = nil
	info = ShenYuBossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_YouMing)
	if info then
		MoveCache.param1 = info.boss_id
		GuajiCache.monster_id = info.boss_id
		MoveCache.end_type = MoveEndType.FightByMonsterId
		local callback = function()
			GuajiCtrl.Instance:MoveToPos(info.scene_id, info.x_pos, info.y_pos, 10, 10)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller then
		self.node_list["TaskList"].scroller:ReloadData(0)
	end

end

function CrossYouMingBossInfoView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["PanelInfo"]:SetActive(state)
end

function CrossYouMingBossInfoView:OnFlush()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshActiveCellViews()
	end
end

function CrossYouMingBossInfoView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function CrossYouMingBossInfoView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = CrossYouMingBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function CrossYouMingBossInfoView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	local data_list = ShenYuBossData.Instance:GetCrossYouMingLayerBossBySceneID(scene_id)
	return data_list
end

function CrossYouMingBossInfoView:GetCurIndex()
	return self.cur_index
end

function CrossYouMingBossInfoView:SetCurIndex(index)
	self.cur_index = index
end

function CrossYouMingBossInfoView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end
----------------------------打宝bossItem
CrossYouMingBossItem = CrossYouMingBossItem or BaseClass(BaseRender)

function CrossYouMingBossItem:__init(instance, parent)

	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function CrossYouMingBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
end

function CrossYouMingBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local callback = function()
		GuajiCtrl.Instance:MoveToPos(self.data.scene_id, self.data.x_pos, self.data.y_pos, 0, 0)
	end
	callback()
	GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	self.parent:FlushAllHl()
	return
end

function CrossYouMingBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function CrossYouMingBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = ShenYuBossData.Instance:GetCrossYouMingLayerBossBySceneID(scene_id)
	for k,v in pairs(boss_info) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function CrossYouMingBossItem:SetItemIndex(index)
	self.index = index
end

function CrossYouMingBossItem:Flush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	else
		self.root_node:SetActive(true)
	end
	-- self.node_list["Desc"]:SetActive(false)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.node_list["TxtName"].text.text = monster_cfg.name
		self.node_list["TextLevel"].text.text = string.format("Lv.%s", monster_cfg.level)
		self.node_list["TextLevel"]:SetActive(true)
		self.node_list["TxtTime"]:SetActive(true)
	end
	self.node_list["special_txt"]:SetActive(false)
	if self.data.type == 2 or self.data.type == 1 then
		local left_num = ShenYuBossData.Instance:GetCrossYouMingLeftNumInScene(self.data.layer, self.data.type)
		self.flush_time = ShenYuBossData.Instance:GetCrossYouMingOtherNextFlushTimestamp(self.data.layer, self.data.type) or 0
		-- self.node_list["TxtName"].text.text = self.data.boss_name .. "(" .. tostring(left_num) .. ")"
		self.node_list["TxtName"].text.text = string.format(Language.Boss.KFbossSJName, self.data.boss_name) 
		self.node_list["special_txt"]:SetActive(true)
		self.node_list["TextLevel"]:SetActive(false)
		self.node_list["TxtTime"]:SetActive(false)
		if left_num > 0 then
			self.node_list["special_txt"].text.text = string.format(Language.Boss.KFBOSSSYSJ, left_num)
		else
			self.node_list["special_txt"].text.text = string.format(Language.Boss.KFBOSSSYSJT, left_num)
		end
		
		self.node_list["TextLevel"].text.text = ""
		self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
		self.node_list["Desc"]:SetActive(self.flush_time > 0)
		self.node_list["Desc"].text.text = string.format(Language.Boss.KFbossFulsh, ToColorStr(self.time, self.time_color))
		if self.flush_time <= 0 or self.data.type == 1 then
			self.node_list["Desc"].text.text = ""
		else
			if nil == self.time_coundown then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnOtherUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
			end
			self:OnOtherUpdate()
		end
	end
	
	if self.data.type == 0 then
		local boss_data = self:GetBossData(self.data.boss_id)
		self.node_list["Desc"].text.text = self.data.scene_show
		if boss_data then
			self.flush_time = ShenYuBossData.Instance:GetCrossYouMingBossFlushTimesByBossId(self.data.boss_id, self.data.scene_id) or 0
			self.time_color = self.flush_time <= 0 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
			self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
			if self.flush_time <= 0 then
				self.time = Language.Boss.CanKill
				self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
			else
				if nil == self.time_coundown then
					self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.OnBossUpdate, self), 1, self.flush_time - TimeCtrl.Instance:GetServerTime())
				end
				self:OnBossUpdate()
			end
		end
	end
	self:FlushHl()
end

function CrossYouMingBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurIndex() == self.index)
	end
end

function CrossYouMingBossItem:OnBossUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = Language.Boss.CanKill
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
	else
		self.time = TimeUtil.FormatSecond(time)
		self.node_list["TxtTime"].text.text = ToColorStr(self.time, self.time_color)
	end
end

function CrossYouMingBossItem:OnOtherUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ""
	else
		self.time = TimeUtil.FormatSecond(time)
		self.node_list["Desc"].text.text = string.format(Language.Boss.KFbossFulsh, ToColorStr(self.time, self.time_color))
	end
end