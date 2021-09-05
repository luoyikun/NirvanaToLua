FarmHuntingSceneLogic = FarmHuntingSceneLogic or BaseClass(CrossServerSceneLogic)
local PB_Monster_List = {}
function FarmHuntingSceneLogic:__init()
	if FarmHuntingData.Instance and FarmHuntingData.Instance.monster_cfg then
		for k,v in pairs(FarmHuntingData.Instance.monster_cfg) do
			local temp_list = {}
			temp_list.id = v.monster_id
			table.insert(PB_Monster_List, temp_list)
		end
	end
end

function FarmHuntingSceneLogic:__delete()

end

function FarmHuntingSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	self.now_scene_type = new_scene_type

	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FarmSceneView)
end

function FarmHuntingSceneLogic:GetIsShowScoreNum(obj)
	if self.now_scene_type ~= SceneType.FarmHunting then return false end
	local monster_id = obj:GetMonsterId()
	
	return FarmHuntingData.Instance:GetMonsterScore(monster_id)
end

function FarmHuntingSceneLogic:AlwaysShowMonsterName()
	return true
end

function FarmHuntingSceneLogic:NotShieldMonsterList()
	return PB_Monster_List, 1
end

function FarmHuntingSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FarmSceneView)
	MainUICtrl.Instance:SetViewState(true)
end