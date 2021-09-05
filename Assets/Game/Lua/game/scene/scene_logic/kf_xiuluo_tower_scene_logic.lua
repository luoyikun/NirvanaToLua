KFXiuLuoTowerSceneLogic = KFXiuLuoTowerSceneLogic or BaseClass(CrossServerSceneLogic)

function KFXiuLuoTowerSceneLogic:__init()

end

function KFXiuLuoTowerSceneLogic:__delete()

end

-- 进入场景
function KFXiuLuoTowerSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
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
	if old_scene_type ~= new_scene_type then
		KuaFuXiuLuoTowerCtrl.Instance:OpenFubenView()
		MainUICtrl.Instance:SetViewState(false)
	end
end

-- 退出
function KFXiuLuoTowerSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		GuajiType.IsManualState = false
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		KuaFuXiuLuoTowerCtrl.Instance:CloseFubenView()
		MainUICtrl.Instance:SetvisibleGath()
	end

end

function KFXiuLuoTowerSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		MainUICtrl.Instance:SetViewState(true)
	end
end

-- function KFXiuLuoTowerSceneLogic:GetIsShowSpecialImage(obj)
-- 	local obj_type = obj:GetType()
-- 	if obj_type == SceneObjType.Role or obj_type == SceneObjType.MainRole then
-- 		if obj.vo.special_param == 1 then
-- 			return true, "uis/images_atlas", "box_01"
-- 		end
-- 	end
-- 	return false
-- end

function KFXiuLuoTowerSceneLogic:OnMainRoleRealive()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function KFXiuLuoTowerSceneLogic:GetGuajiPos()
	return KuaFuXiuLuoTowerData.Instance:GetGuajiXY()
end