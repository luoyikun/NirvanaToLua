KFMonthBlackWindHighSceneLogic = KFMonthBlackWindHighSceneLogic or BaseClass(CommonActivityLogic)
local develop_mode = require("editor/develop_mode")
function KFMonthBlackWindHighSceneLogic:__init()
end

function KFMonthBlackWindHighSceneLogic:__delete()

end

function KFMonthBlackWindHighSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	develop_mode:StopDevelopMode()
	ViewManager.Instance:Open(ViewName.KFMonthBlackWindHigh)
	local main_role = Scene.Instance:GetMainRole()
	local attck_mode = PlayerPrefsUtil.GetInt("attck_mode", -1)
	if attck_mode ~= nil and attck_mode ~= -1 then
		PlayerPrefsUtil.SetInt("attck_mode", attck_mode)
	else
		PlayerPrefsUtil.SetInt("attck_mode", tonumber(main_role.vo.attack_mode))
	end
	if main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_ALL then
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALL)
	end
end

function KFMonthBlackWindHighSceneLogic:Out(old_scene_type, new_scene_type)
	develop_mode:ResumeDevelopMode()
	KFMonthBlackWindHighData.Instance:RemovePlayerInfoBroadcast()
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, Scene.Instance:GetMainRole():GetObjId())
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.KFMonthBlackWindHigh)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function KFMonthBlackWindHighSceneLogic:GetIsShowSpecialImage(obj)
	local obj_type = obj:GetType()
	local box_num = KFMonthBlackWindHighData.Instance:GetCrossDarkNightPlayerInfoBroadcast(obj:GetVo().obj_id)
	if (obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole) then
		if box_num and box_num > 0 then
			return true, "uis/views/kuafumonthblackwindhigh/images_atlas", "BoxItem"
		else
			return false
		end
	end
	return false
end

function KFMonthBlackWindHighSceneLogic:GetIsShowSpecialImageRightNum(obj)
	local obj_type = obj:GetType()
	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
		return true
	end
	return false
end

function KFMonthBlackWindHighSceneLogic:IsCanAutoGather()
	return false
end