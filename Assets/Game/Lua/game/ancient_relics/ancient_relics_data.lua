AncientRelicsData = AncientRelicsData or BaseClass()
AncientRelicsData.SCENE_ID = 1121
function AncientRelicsData:__init()
	if AncientRelicsData.Instance then
		print_error("[AncientRelicsData] Attempt to create singleton twice!")
		return
	end
	AncientRelicsData.Instance = self
	self.info = {
		today_gather_times = 0,
		today_buy_gather_times = 0,
		scene_leave_num = 0,
		normal_item_num = 0,
		rare_item_num = 0,
		unique_item_num = 0,
		next_refresh_time = 0,
	}
end

function AncientRelicsData:__delete()
	AncientRelicsData.Instance = nil
end

function AncientRelicsData.IsAncientRelics(scene_id)
	return scene_id == AncientRelicsData.SCENE_ID
end

--是否可采集
function AncientRelicsData:CanGather()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("shenzhou_weapon_auto").other[1]
	local max_times = other_cfg.role_day_gather_num + self.info.today_buy_gather_times
	if self.info.today_gather_times >= max_times then
		return false
	end
	return true
end

function AncientRelicsData:SetInfo(info)
	self.info.today_gather_times = info.today_gather_times
	self.info.today_buy_gather_times = info.today_buy_gather_times
	self.info.scene_leave_num = info.scene_leave_num
	self.info.normal_item_num = info.normal_item_num
	self.info.rare_item_num = info.rare_item_num
	self.info.unique_item_num = info.unique_item_num
	self.info.next_refresh_time = info.next_refresh_time
end

function AncientRelicsData:GetInfo()
	return self.info
end