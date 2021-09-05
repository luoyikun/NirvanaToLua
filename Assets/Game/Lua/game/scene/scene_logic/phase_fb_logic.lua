PhaseFbLogic = PhaseFbLogic or BaseClass(BaseFbLogic)
local PHASE_CG_LIST = {
	[0] = {bundle = "cg/w3_fb_feijian_prefab", asset = "w3_fb_feijian_cg01"},
	[1] = {bundle = "cg/w3_fb_xingkong_prefab", asset = "w3_fb_xingkong_cg01"},
	[2] = {bundle = "cg/w3_fb_feichuan_prefab", asset = "w3_fb_feichuan_cg02"},
	[3] = {bundle = "cg/w3_fb_shenyi_prefab", asset = "w3_fb_shenyi_cg02"},
	[4] = {bundle = "cg/w3_fb_feijian_prefab", asset = "w3_fb_feijian_cg02"},
	[5] = {bundle = "cg/w3_fb_xingkong_prefab", asset = "w3_fb_xingkong_cg02"},
	[6] = {bundle = "cg/w3_fb_feichuan_prefab", asset = "w3_fb_feichuan_cg01"},
}
function PhaseFbLogic:__init()
	self.story = nil
end

function PhaseFbLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function PhaseFbLogic:Enter(old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBen)
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
	local phase_level = FuBenCtrl.Instance:GetPhaseLevle()
	local phase_index = PlayerPrefsUtil.GetInt("phaseindex")

	if phase_index == nil or PHASE_CG_LIST[phase_index] == nil then
		return
	end

	local func = function()
		BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
		ViewManager.Instance:Open(ViewName.FuBenPhaseInfoView)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		Scene.SendCancelMonsterStaticState()
	end
	if phase_level == 1 then
		local bundle, asset = PHASE_CG_LIST[phase_index].bundle, PHASE_CG_LIST[phase_index].asset
		CgManager.Instance:Play(BaseCg.New(bundle, asset), func)
	else
		BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
		ViewManager.Instance:Open(ViewName.FuBenPhaseInfoView)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		GlobalTimerQuest:AddDelayTimer(function()
			Scene.SendCancelMonsterStaticState()
		end, 3)
	end

end

-- 是否可以拉取移动对象信息
function PhaseFbLogic:CanGetMoveObj()
	return true
end

function PhaseFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenPhaseInfoView)
	ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	GuajiCtrl.Instance:StopGuaji()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if not ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		if fb_scene_info and fb_scene_info.is_pass == 1 and PlayerData.Instance:GetRoleVo().level >= 150 then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_phase, "click_next", {data = "all"})
			self.phase_end = GlobalTimerQuest:AddDelayTimer(function()
				GlobalTimerQuest:CancelQuest(self.phase_end)
				self.phase_end = nil
			end, 2)
		end
	else
		-- GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	end
	PlayerPrefsUtil.DeleteKey("phaseindex")
	FuBenData.Instance:ClearFBSceneLogicInfo()
	self.phase_delay = GlobalTimerQuest:AddDelayTimer(function()
		local role_level = PlayerData.Instance:GetRoleVo().level
		if role_level >= GameEnum.NOVICE_LEVEL then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_phase, "click_next", {data = "all"})
		end
		GlobalTimerQuest:CancelQuest(self.phase_delay)
		self.phase_delay = nil
	end, 1)
end

function PhaseFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function PhaseFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function PhaseFbLogic:IsSetAutoGuaji()
	return true
end