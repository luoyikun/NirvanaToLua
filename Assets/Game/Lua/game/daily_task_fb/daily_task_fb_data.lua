DailyTaskFbData = DailyTaskFbData or BaseClass()

DailyTaskFbData.FB_TYPE = {
	SCORE = 1,
	STATUE = 2,
	DAZHAO = 3,
	XIXUE = 4,
	SHENZHU = 5,
}

function DailyTaskFbData:__init()
	if DailyTaskFbData.Instance then
		print_error("[DailyTaskFbData] Attempt to create singleton twice!")
		return
	end
	DailyTaskFbData.Instance = self
	local dailytaskfbconfig_auto = ConfigManager.Instance:GetAutoConfig("dailytaskfbconfig_auto")
	self.fb_cfg = ListToMapList(dailytaskfbconfig_auto.fb_cfg, "branch_fb_type")
	self.fb_cfg2 = ListToMapList(dailytaskfbconfig_auto.fb_cfg, "scene_id")
end

function DailyTaskFbData:__delete()
	DailyTaskFbData.Instance = nil
end

function DailyTaskFbData:GetFbCfg(branch_fb_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.fb_cfg[branch_fb_type] then
		for k,v in pairs(self.fb_cfg[branch_fb_type]) do
			if level <= v.max_level and level >= v.min_level then
				return v
			end
		end
	end
	return nil
end

function DailyTaskFbData:GetFbCfg2(scene_id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.fb_cfg2[scene_id] then
		for k,v in pairs(self.fb_cfg2[scene_id]) do
			if level <= v.max_level and level >= v.min_level then
				return v
			end
		end
	end
	return nil
end
