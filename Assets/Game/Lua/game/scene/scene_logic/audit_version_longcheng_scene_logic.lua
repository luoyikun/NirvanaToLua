AuditVersionLongChengSceneLogic = AuditVersionLongChengSceneLogic or BaseClass(BaseSceneLogic)
local SCENE_AUDIT_VERSION_ROLE_CAMERA_ROTATION = {
	[1] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 2},
	[2] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 2},
	[3] = {ROTATION_X = 0, ROTATION_Y = -90, DISTANCE = 1.5},
	[4] = {ROTATION_X = -10, ROTATION_Y = -90, DISTANCE = 1.5},
}
function AuditVersionLongChengSceneLogic:__init()
end

function AuditVersionLongChengSceneLogic:__delete()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function AuditVersionLongChengSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:RotateTo(-88)
	end
	local prof = PlayerData.Instance:GetRoleBaseProf()
	Scene.Instance:SetGuideFixedCamera(SCENE_AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].ROTATION_X, SCENE_AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].ROTATION_Y, SCENE_AUDIT_VERSION_ROLE_CAMERA_ROTATION[prof].DISTANCE)
	MainCameraFollow.AllowRotation = false
	MainCameraFollow.AllowXRotation = false
	MainCameraFollow.AllowYRotation = false
	local scene_id = Scene.Instance:GetSceneId()
	if nil == self.delay_timer then
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function()
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(scene_id, 114, 113)
		end, 10)
	end
end

function AuditVersionLongChengSceneLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)

	MainCameraFollow.AllowRotation = true
	MainCameraFollow.AllowXRotation = true
	MainCameraFollow.AllowYRotation = true
end

function AuditVersionLongChengSceneLogic:StopDelayMove()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end