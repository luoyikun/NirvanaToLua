CrossMiZangBossInfoView = CrossMiZangBossInfoView or BaseClass(BaseView)
local FLUSH_ITEM_ID = 24605 				--BOSS刷新卡

function CrossMiZangBossInfoView:__init()
	self.ui_config = {{"uis/views/shenyubossview_prefab", "CrossFightBossInfoView"}}
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.item_t = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
end

function CrossMiZangBossInfoView:__delete()

end

function CrossMiZangBossInfoView:ReleaseCallBack()
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

	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end
end

function CrossMiZangBossInfoView:LoadCallBack()
	local list_delegate = self.node_list["TaskList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,BindTool.Bind(self.PortraitToggleChange, self))
	self.node_list["Text_tip"].text.text = Language.Boss.TeamDropTip2

	self.node_list["FlushCard"].button:AddClickListener(BindTool.Bind(self.ClickFlushCard, self))

	local item_cfg = ItemData.Instance:GetItemConfig(FLUSH_ITEM_ID)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.node_list["ImgFlushCardIcon"].image:LoadSprite(bundle, asset, function()
			self.node_list["ImgFlushCardIcon"].image:SetNativeSize()
		end)
	end
	self:Flush()
end

function CrossMiZangBossInfoView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function CrossMiZangBossInfoView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end

	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end
end

function CrossMiZangBossInfoView:OpenCallBack()
	local scene_id = Scene.Instance:GetSceneId()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	self.item_data_change_callback = BindTool.Bind1(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)

	local item_num_2 = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	local scene_id = Scene.Instance:GetSceneId()
	self.node_list["FlushCard"]:SetActive(item_num_2 > 0 and BossData.Instance:IsShenYuBossScene(scene_id))

	local info = nil
	info = ShenYuBossData.Instance:GetCurBossInfo(BOSS_ENTER_TYPE.TYPE_BOSS_MiZang)
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

	local list = self:GetDataList()
	if info then
		if list then
			for k,v in pairs(list) do
				if info.boss_id == v.boss_id then
					self.cur_index = k
					self.select_boss_id = v.boss_id
				end
			end
		end
	end

	if self.node_list["TaskList"] and self.node_list["TaskList"].scroller then
		if self.cur_index and self.cur_index > 1 then
			self.node_list["TaskList"].scroller:ReloadData(self.cur_index / #list)
		else
			self.node_list["TaskList"].scroller:ReloadData(0)
		end
	end
	self:AutoGoKillBoss()
end

function CrossMiZangBossInfoView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
	self.node_list["PanelInfo"]:SetActive(state)
	self.node_list["TaskParent"]:SetActive(state)
end

function CrossMiZangBossInfoView:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == FLUSH_ITEM_ID then
		local scene_id = Scene.Instance:GetSceneId()
		self.node_list["FlushCard"]:SetActive(new_num > 0 and BossData.Instance:IsShenYuBossScene(scene_id))
	end
end

function CrossMiZangBossInfoView:ClickFlushCard()
	local scene_id = Scene.Instance:GetSceneId()
	BossData.Instance:UseFlushCard(scene_id)
end

function CrossMiZangBossInfoView:OnFlush()
	if self.node_list["TaskList"].scroller.isActiveAndEnabled then
		self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local tire, max_tire = ShenYuBossData.Instance:GetCrossBossTire()
	local tire_value = max_tire - tire
	if tire_value <= 0 then
		-- self.node_list["Text_tip"].text.text = Language.Boss.NoWearyTip
		tire_value = ToColorStr(tire_value, TEXT_COLOR.RED)
	else
		self.node_list["Text_tip"].text.text = Language.Boss.TeamDropTip2
		tire_value = ToColorStr(tire_value, TEXT_COLOR.GREEN)
	end
	max_tire = ToColorStr(max_tire, TEXT_COLOR.GREEN)
	self.node_list["TextWeary"].text.text = string.format(Language.Boss.CrossBossTireValue, tire_value .. " / " .. max_tire)
	self.node_list["TextWeary"]:SetActive(true)
	local num = ItemData.Instance:GetItemNumInBagById(FLUSH_ITEM_ID)
	local scene_id = Scene.Instance:GetSceneId()
	self.node_list["FlushCard"]:SetActive(num > 0 and BossData.Instance:IsShenYuBossScene(scene_id))

end

function CrossMiZangBossInfoView:BagGetNumberOfCells()
	local data_list = self:GetDataList() or {}
	return #data_list
end

function CrossMiZangBossInfoView:BagRefreshCell(cell, data_index, cell_index)
	local item = self.item_t[cell]
	if nil == item then
		item = CrossMiZangBossItem.New(cell.gameObject, self)
		self.item_t[cell] = item
	end

	local data_list = self:GetDataList() or {}
	if data_list[cell_index + 1] then
		item:SetData(data_list[cell_index + 1])
	end
	item:SetItemIndex(cell_index + 1)
	item:FlushHl()
end

function CrossMiZangBossInfoView:GetDataList()
	local scene_id = Scene.Instance:GetSceneId()
	local data_list = ShenYuBossData.Instance:GetCrossLayerBossBySceneID(scene_id)
	return data_list
end

function CrossMiZangBossInfoView:AutoGoKillBoss()
	local select_boss_id = ShenYuBossData.Instance:GetSelectBoss()
	if select_boss_id then
		local data_list = self:GetDataList() or {}
		for k,v in pairs(data_list) do
			if select_boss_id == v.boss_id then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				local callback = function()
					GuajiCtrl.Instance:MoveToPos(v.scene_id, v.x_pos, v.y_pos, 0, 0)
				end
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
				return
			end
		end
	end
end

function CrossMiZangBossInfoView:GetCurIndex()
	return self.cur_index
end

function CrossMiZangBossInfoView:GetCurBossId()
	return self.select_boss_id
end

function CrossMiZangBossInfoView:SetCurBossId(boss_id)
	self.select_boss_id = boss_id
end

function CrossMiZangBossInfoView:SetCurIndex(index)
	self.cur_index = index
end

function CrossMiZangBossInfoView:FlushAllHl()
	for k,v in pairs(self.item_t) do
		v:FlushHl()
	end
end
----------------------------打宝bossItem
CrossMiZangBossItem = CrossMiZangBossItem or BaseClass(BaseRender)

function CrossMiZangBossItem:__init(instance, parent)

	self.parent = parent

	self.time = ""
	self.time_color = "#32d45eff"
	self.index = 0
	self.next_refresh_time = 0
	self.node_list["BossFamilyItem"].button:AddClickListener(BindTool.Bind(self.ClickKill, self))
end

function CrossMiZangBossItem:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.parent = nil
end

function CrossMiZangBossItem:ClickKill(is_click)
	if self.data == nil then return end
	self.parent:SetCurIndex(self.index)
	self.parent:SetCurBossId(self.data.boss_id)
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

function CrossMiZangBossItem:SetData(data)
	self.data = data
	self:Flush()
end

function CrossMiZangBossItem:GetBossData(boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_info = ShenYuBossData.Instance:GetCrossLayerBossBySceneID(scene_id)
	for k,v in pairs(boss_info) do
		if v.boss_id == boss_id then
			return v
		end
	end
end

function CrossMiZangBossItem:SetItemIndex(index)
	self.index = index
end

function CrossMiZangBossItem:Flush()
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
		local left_num = ShenYuBossData.Instance:GetCrossLeftNumInScene(self.data.layer, self.data.type)
		self.flush_time = ShenYuBossData.Instance:GetCrossOtherNextFlushTimestamp(self.data.layer, self.data.type) or 0
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
			self.flush_time = ShenYuBossData.Instance:GetCrossBossFlushTimesByBossId(self.data.boss_id, self.data.scene_id) or 0
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

function CrossMiZangBossItem:FlushHl()
	if self.node_list["ImgHL"] then
		self.node_list["ImgHL"]:SetActive(self.parent:GetCurBossId() == self.data.boss_id)
	end
end

function CrossMiZangBossItem:OnBossUpdate()
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

function CrossMiZangBossItem:OnOtherUpdate()
	if nil == self.time_coundown then return end
	local time = math.max(0, self.flush_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time = ""
	else
		self.time = TimeUtil.FormatSecond(time)
		self.node_list["Desc"].text.text = string.format(Language.Boss.KFbossFulsh, ToColorStr(self.time, self.time_color))
	end
end