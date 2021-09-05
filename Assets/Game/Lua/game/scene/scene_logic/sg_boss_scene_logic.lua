SgBossSceneLogic = SgBossSceneLogic or BaseClass(BaseFbLogic)
SgBossSceneLogic.SGBOXES = {198, 197}
function SgBossSceneLogic:__init()
	
end

function SgBossSceneLogic:__delete()

end

-- 进入场景
function SgBossSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)

	ViewManager.Instance:Close(ViewName.Boss)
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.Instance:IsSgBossScene(scene_id) then
		ViewManager.Instance:Open(ViewName.ShangguBossFightView)
	end

	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)

	self:GetSelectBossPos()
end

function SgBossSceneLogic:GetSelectBossPos()
	local _, boss_id = BossCtrl.Instance:GetShangGuBossSelectLayerandBossID()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	local scene_id = Scene.Instance:GetSceneId()
	local list = BossData.Instance:GetSGBossListBySceneId(scene_id)
	for k,v in pairs(list) do
		if v.boss_id == boss_id then
			local callback = function()
				GuajiCtrl.Instance:MoveToPos(scene_id, v.x_pos, v.y_pos, 0, 0)
			end
			callback()
			GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
		end
	end
end



function SgBossSceneLogic:Out(old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	BossCtrl.Instance:CloseShangguFightView()
	BossCtrl.Instance:CancelDpsFlag()
end

function SgBossSceneLogic:GetIsShowSpecialImage(obj)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if obj.vo and obj.vo.obj_id == vo.obj_id then
		local tire_value, max_use_time = BossData.Instance:GetSgBossTire()
		if tire_value and max_use_time and tire_value >= max_use_time then
			return true ,"uis/views/fubenview/images_atlas" , "icon_max_tired", 1.5
		else
			return false
		end
	end
end
