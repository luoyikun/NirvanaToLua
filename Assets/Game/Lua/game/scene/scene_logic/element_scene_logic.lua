
--元素战场
ElementSceneLogic = ElementSceneLogic or BaseClass(CommonActivityLogic)

function ElementSceneLogic:__init()
end

function ElementSceneLogic:__delete()
end

function ElementSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.ElementBattleFightView)
	GlobalEventSystem:Fire(OtherEventType.GUAJI_TYPE_CHANGE, GuajiCache.guaji_type)
end

function ElementSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.ElementBattleFightView)
	GuajiType.IsManualState = false
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	Scene.Instance:ClearCgObj()
	GlobalEventSystem:Fire(OtherEventType.GUAJI_TYPE_CHANGE, GuajiCache.guaji_type)
end

function ElementSceneLogic:CanGetMoveObj()
	return true
end

function ElementSceneLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function ElementSceneLogic:GetRoleNameBoardText(role_vo)
	local role_kill = 0
	if role_vo.special_param and role_vo.special_param > 0 then
		role_kill = ElementBattleData.GetSpecialToKill(role_vo.special_param)
	end
	local role_side = ElementBattleData.GetSpecialToSide(role_vo.special_param)
	if role_vo.is_shadow == 1 then
		role_side = role_vo.shadow_param
	end
	local main_side = ElementBattleData.GetSpecialToSide(GameVoManager.Instance:GetMainRoleVo().special_param)

	local t = {}
	local index = 1

	local is_camp = (main_side == role_side)
	t[index] = {}
	t[index].color = is_camp and COLOR.WHITE or COLOR.RED
	t[index].text = role_vo.name

	if role_kill >= 5 then
		index = index + 1
		t[index] = {}
		t[index].color = COLOR.YELLOW
		t[index].text = string.format(Language.Dungeon.KillCount, role_kill)
	end
	return t
end

function ElementSceneLogic:IsRoleEnemy(target_obj, main_role)
	local target_side = ElementBattleData.GetSpecialToSide(target_obj:GetVo().special_param)
	if target_obj:GetVo().is_shadow == 1 then
		target_side = target_obj:GetVo().shadow_param
	end
	if ElementBattleData.GetSpecialToSide(main_role:GetVo().special_param) == target_side then			-- 同一边
		return false, Language.Fight.Side
	end

	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.QUNXIANLUANDOU)
	if act_info.status == 0 then
		return false
	end

	return true
end

function ElementSceneLogic:IsMonsterEnemy(target_obj, main_role)
	return false
end

function ElementSceneLogic:GetIsShowSpecialImage(obj)
	local role_side = ElementBattleData.GetSpecialToSide(obj:GetVo().special_param)
	if obj:GetVo().is_shadow == 1 then
		role_side = obj:GetVo().shadow_param
	end
	if role_side >= 0 and role_side <= 2 then
		return true, "uis/views/floatingtext/images_atlas", "icon_title" .. role_side
	end
	return false
end

function ElementSceneLogic:OnMainRoleRealive()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function ElementSceneLogic:GetGuajiPos()
	return ElementBattleData.Instance:GetGuajiXY()
end

function ElementSceneLogic:CheckProtectRange()

end
