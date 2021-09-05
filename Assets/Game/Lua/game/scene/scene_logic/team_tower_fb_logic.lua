TeamTowerSceneLogic = TeamTowerSceneLogic or BaseClass(BaseFbLogic)

function TeamTowerSceneLogic:__init()
	self.scene_all_load_complete_event = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneDetailLoadComplete, self))
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self.old_scene_type = -1
	self.new_scene_type = -1
end

function TeamTowerSceneLogic:__delete()
	GlobalEventSystem:UnBind(self.scene_all_load_complete_event)

	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function TeamTowerSceneLogic:OnSceneDetailLoadComplete()
	if self.old_scene_type ~= self.new_scene_type then
		FuBenData.Instance:ShowFBResult()
		self.old_scene_type = -1
		self.new_scene_type = -1
	end
end

function TeamTowerSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.FuBenTeamInfoView)
	FuBenData.Instance:SetTowerIsWarning(false)
end

function TeamTowerSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)

	self.old_scene_type = old_scene_type
	self.new_scene_type = new_scene_type

	FuBenData.Instance:ClearTeamTowerDefendAttrType()
	FuBenData.Instance:ClearFBDropInfo()
	TipsCtrl.Instance:CloseFBDropView()
	MainUICtrl.Instance:SetViewState(true)
	ViewManager.Instance:Close(ViewName.FuBenTeamInfoView)
	local role_level = PlayerData.Instance:GetRoleVo().level
	GlobalTimerQuest:AddDelayTimer(function()
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_team_tower)
			FuBenCtrl.Instance:FlushFBTeamInfo()
		end
	end, 0.5)

end

-- 获得捡取掉物品的最大距离
function TeamTowerSceneLogic:GetPickItemMaxDic(item_id)
	return 2
end

function TeamTowerSceneLogic:IsRoleEnemy()
	return false
end

function TeamTowerSceneLogic:GetGuajiPos()
	local other_cfg = FuBenData.Instance:GetGuaJiPos()
	return other_cfg.guaji_pos_x, other_cfg.guaji_pos_y
end

function TeamTowerSceneLogic:GetSpecialGuajiPos()
	local function start_call_back()
		FuBenData.Instance:SetTowerIsWarning(false)
	end
	if FuBenData.Instance:GetTowerIsWarning() then
		local pos_x, pos_y = self:GetGuajiPos()
		return pos_x, pos_y, start_call_back
	end
	return nil, nil, nil
end

-- 不屏蔽怪物的列表
function TeamTowerSceneLogic:NotShieldMonsterList()
	local monster_list = {{id = 1103},}
	return monster_list, 1
end

function TeamTowerSceneLogic:MainuiOpen()
	MainUICtrl.Instance:SetViewState(false)
end