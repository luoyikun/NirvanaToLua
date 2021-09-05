DefenseFbSceneLogic = DefenseFbSceneLogic or BaseClass(BaseFbLogic)

function DefenseFbSceneLogic:__init()
	self.defense_tower_list = {}
	self.obj_pos_list = FuBenData.Instance:GetDefensePosList()
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function DefenseFbSceneLogic:__delete()
	self.defense_tower_list = {}

	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function DefenseFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	self.defense_pos_list = TableCopy(FuBenData.Instance:GetDefensePosList())
	for k, v in ipairs(self.defense_pos_list)do
		local defense_vo = GameVoManager.Instance:CreateVo(DefenseVo)
		defense_vo.gather_id = FuBenData.Instance:GetDefenseTowerOtherCfg().tower_getherid or 232
		defense_vo.pos_x = v.pos_x
		defense_vo.pos_y = v.pos_y
		defense_vo.pos_index = v.pos_index
		defense_vo.obj_id = v.pos_index + 900
		local obj = Scene.Instance:CreateObj(defense_vo, SceneObjType.DefenseObj)
		self.defense_tower_list[#self.defense_tower_list + 1] = obj
	end

	MainCameraFollow.Distance = 13
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Close(ViewName.FuBen)
	ViewManager.Instance:Open(ViewName.FuBenDefenseInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	self:FlushDefenseObjVisible()
end

function DefenseFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function DefenseFbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.FuBenDefenseInfoView)
	self.open_delay = GlobalTimerQuest:AddDelayTimer(function()
		local role_level = PlayerData.Instance:GetRoleVo().level
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_defense)
		end
		GlobalTimerQuest:CancelQuest(self.open_delay)
		self.open_delay = nil
	end, 0.5)
end

function DefenseFbSceneLogic:OnSceneDetailLoadComplete()
	self:UpdateCameraFollow()
end

function DefenseFbSceneLogic:UpdateCameraFollow()
	-- MainCameraFollow:ChangeAngle(Vector2(30, 150))
	-- MainCameraFollow.transform.localPosition = Vector3(-136.46, 4.31598, -78.517)
end

function DefenseFbSceneLogic:FlushDefenseObjVisible()
	local defense_data = FuBenData.Instance:GetBuildTowerFBInfo()
	local tower_info_list = defense_data.tower_info_list
	if not tower_info_list then
		return
	end

	for k,v in ipairs(self.defense_tower_list) do
		if v.vo and tower_info_list[v.vo.pos_index] then
			local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
			v.draw_obj:SetVisible(tower_info_list[v.vo.pos_index].tower_type == -1)
			if tower_info_list[v.vo.pos_index].tower_type == -1 then
				follow_ui:Show()
			else
				follow_ui:Hide()
			end
		end
	end

	local obj_list = Scene.Instance:GetObjList()
	for k, v in pairs(obj_list) do
		local vo = v:GetVo()
		for k1, v1 in pairs(self.obj_pos_list) do
			if vo.obj_id < 900 and v1.pos_x == vo.pos_x and v1.pos_y == vo.pos_y then
				local defense_tower = tower_info_list[v1.pos_index] 
				-- local follow_ui = v.draw_obj:GetSceneObj():GetFollowUi()
				if defense_tower and FuBenData.Instance:GetUpDefenseTower(defense_tower.tower_type, defense_tower.tower_level) then
					if v.SetShowUpImage then
						v:SetShowUpImage(true)
					end
				else
					if v.SetShowUpImage then
						v:SetShowUpImage(false)
					end
				end
			end
		end
	end
end

function DefenseFbSceneLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end