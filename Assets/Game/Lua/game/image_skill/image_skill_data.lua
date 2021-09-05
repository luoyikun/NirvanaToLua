ImageSkillData = ImageSkillData or BaseClass()

function ImageSkillData:__init()
	if ImageSkillData.Instance then
		print_error("[ImageSkillData] Attemp to create a singleton twice !")
	end
	ImageSkillData.Instance = self
	RemindManager.Instance:Register(RemindName.ImageSkill, BindTool.Bind(self.GetImageSkillRemind, self))
	self.is_first_open = true
	self.close_time = 0
end

function ImageSkillData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ImageSkill)
	if ImageSkillData.Instance then
		ImageSkillData.Instance = nil
	end
end

function ImageSkillData:SetFirstOpenTag(is_show)
	self.is_first_open = is_show
end

function ImageSkillData:GetFirstOpenTag()
	return self.is_first_open
end

function ImageSkillData:GetBaiBeiItemCfg()
	return ConfigManager.Instance:GetAutoConfig("opengameactivity_auto").other[1]
end

-- function ImageSkillData:GetFashionResId(prof_sex, index, part_type)
-- 	if part_type == SHIZHUANG_TYPE.WUQI then
-- 		local weapon_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
-- 		for k,v in pairs(weapon_cfg) do
-- 			if index == v.image_id and v["resouce" .. prof_sex] then
-- 				return v["resouce" .. prof_sex]
-- 			end
-- 		end
-- 	else
-- 		local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
-- 		for k,v in pairs(fashion_cfg) do
-- 			if index == v.image_id and v["resouce" .. prof_sex] then
-- 				return v["resouce" .. prof_sex]
-- 			end
-- 		end
-- 	end
-- end

function ImageSkillData:GetGiftInfoList()
	local gifts_info = self:GetBaiBeiItemCfg().baibeifanli_item_2
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	for i = 1, 6 do
		if gifts_cfg then
			item_data_list[i] = {}
			item_data_list[i].item_id = gifts_cfg["item_"..i.."_id"]
			item_data_list[i].num = gifts_cfg["item_"..i.."_num"]
			item_data_list[i].is_bind = gifts_cfg["is_bind_"..i]
		end
	end
	return item_data_list
end

function ImageSkillData:GetImageSkillRemind()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	return (self:GetBaiBeiGiftAwardFlag() and history_recharge >= DailyChargeData.GetMinRecharge()) and 1 or 0
end

function ImageSkillData:GetBaiBeiGiftAwardFlag()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = UnityEngine.PlayerPrefs.GetInt("image_skill_remind_day") or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day and nil ~= ImageSkillCtrl.Instance.is_buy then
		return ImageSkillCtrl.Instance.is_buy
	end
	return false
end

function ImageSkillData:SetActivityTime(protocol)
	self.close_time = protocol.close_time
end

function ImageSkillData:GetImageSkillTime()
	return self.close_time
end