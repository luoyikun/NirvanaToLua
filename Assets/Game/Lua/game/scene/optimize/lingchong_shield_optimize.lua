LingChongShieldOptimize = LingChongShieldOptimize or BaseClass(BaseShieldOptimize)

function LingChongShieldOptimize:__init()
	self.max_appear_count = 10
	self.min_appear_count = 3
end

function LingChongShieldOptimize:__delete()

end

function LingChongShieldOptimize:GetAllObjIds()
	local all_objids = {}
	local appear_count = 0

	local role_list = Scene.Instance:GetRoleList()
	for _, v in pairs(role_list) do
		local is_visible = v:IsRoleVisible()
		all_objids[v:GetObjId()] = is_visible
		
		if is_visible then
			appear_count = appear_count + 1
		end
	end

	return all_objids, appear_count
end

function LingChongShieldOptimize:AppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_LINGCHONG) then -- 已经屏仙宠
		return false
	end

	obj:SetLingChongVisible(true)

	return true
end

function LingChongShieldOptimize:DisAppearObj(obj_id)
	local obj = Scene.Instance:GetObj(obj_id)
	if obj == nil or obj:GetType() ~= SceneObjType.Role then
		return false
	end

	if SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_LINGCHONG) then -- 已经屏仙宠
		return false
	end

	obj:SetLingChongVisible(false)

	return true
end
