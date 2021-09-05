FunGuideFbLogic = FunGuideFbLogic or BaseClass(BaseGuideFbLogic)
local rotation_x = 20
local rotation_y = -100
function FunGuideFbLogic:__init()
	self.story_name = self:GetStoryName()
end

function FunGuideFbLogic:__delete()

end

function FunGuideFbLogic:Enter(old_scene_type, new_scene_type)
	BaseGuideFbLogic.Enter(self, old_scene_type, new_scene_type)
	local scene_id = Scene.Instance:GetSceneId()
	if 120 == scene_id then
		TaskCtrl.Instance:SetGuideFbEff(TASK_WEATHER_INDEX.DALEI)
		--第一个引导副本写死视角
		Scene.Instance:SetGuideFixedCamera(rotation_x, rotation_y)
	end
end

function FunGuideFbLogic:GetStoryName()
	local scene_id = Scene.Instance:GetSceneId()

	if 160 == scene_id then return "gongchengzhan_guide" end
	if 161 == scene_id then return "husong_guide" end
	if 166 == scene_id then return "rob_boss_guide" end
	if 165 == scene_id then return "be_robed_boss_guide" end
	if 164 == scene_id then return "shuijing_guide" end
	if 169 == scene_id then return "field_boss" end
	if 120 == scene_id then return "taoyuan_cg" end
	if 121 == scene_id then return "zhucheng_fb" end

	return ""
end