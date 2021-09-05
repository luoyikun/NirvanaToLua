KuaFuBossTjFightView = KuaFuBossTjFightView or BaseClass(BaseView)

function KuaFuBossTjFightView:__init()
	self.ui_config = {
			{"uis/views/kuafuliujie_prefab","KuaFuBossTjFightView"},
	}
	self.active_close = false
	self.fight_info_view = true
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
	self.item_t = {}
	self.boss_xy = {}
	self.dabao_info_event = BindTool.Bind(self.Flush, self)
	self.is_boss = true
end

function KuaFuBossTjFightView:__delete()

end

function KuaFuBossTjFightView:ReleaseCallBack()
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
	end
	self.item_t = {}

	self:StopTimeQuest()

	-- 清理变量和对象
	-- self.anger = nil
	self.time = nil
	self.slider = nil
	self.show_limit = nil
	self.list_view = nil
	self.max_anger = nil
	self.name = nil
	self.is_count = nil
end

function KuaFuBossTjFightView:LoadCallBack()

	local max_anger = KuafuGuildBattleData.Instance:GetActiveMaxValue(Scene.Instance:GetSceneId())
	self.node_list["Txt_MaxAnger"].text.text = string.format(Language.Boss.BaoBaoMaxAnger, max_anger)

	self:Flush()
end

function KuaFuBossTjFightView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:Flush()
	end
end

function KuaFuBossTjFightView:BossClick(is_click)
	if is_click then
		self:Flush()
	end
end

function KuaFuBossTjFightView:BossChange()
	self:Flush()
end

function KuaFuBossTjFightView:CloseCallBack()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuaFuBossTjFightView:OpenCallBack()
	-- local scene_id = Scene.Instance:GetSceneId()
	-- GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	-- local info = nil
	-- info = KuafuGuildBattleData.Instance:GetTjSceneList(scene_id)
	-- -- boss_id = KuafuGuildBattleData.Instance:GetSelectBoss(scene_id)
	-- if info then
	-- 	local scene_cfg = ConfigManager.Instance:GetSceneConfig(info.scene_id)
	-- 	local cfg = KuafuGuildBattleData.Instance:GetTianjiangBossCfg()
	-- 	for _,v in ipairs(cfg.monster) do
	-- 		KuafuGuildBattleData.Instance:RegMonsterXY(scene_cfg, v.monster_id)
	-- 	end
	-- 	-- local boss_xy = KuafuGuildBattleData.Instance:GetBossXY(boss_id)
	-- 	-- if boss_xy then
	-- 	-- 	MoveCache.end_type = MoveEndType.Auto
	-- 	-- 	GuajiCtrl.Instance:MoveToPos(info.scene_id, boss_xy.x, boss_xy.y, 10, 10)
	-- 	-- end
	-- end
end

function KuaFuBossTjFightView:PortraitToggleChange(state)
	if state then
		self:Flush()
	end
end

function KuaFuBossTjFightView:StopTimeQuest()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuaFuBossTjFightView:OnFlush()
	
end

function KuaFuBossTjFightView:OnBossUpdate()

end

function KuaFuBossTjFightView:BagGetNumberOfCells()

end

function KuaFuBossTjFightView:BagRefreshCell(cell, data_index, cell_index)

end

function KuaFuBossTjFightView:GetDataList()

end

function KuaFuBossTjFightView:GetCurIndex()
	return self.cur_index
end

function KuaFuBossTjFightView:SetCurIndex(index)
	self.cur_index = index
end

function KuaFuBossTjFightView:FlushAllHl()

end

function KuaFuBossTjFightView:ClickTeam()
	-- ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
end