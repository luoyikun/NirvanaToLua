RebateData = RebateData or BaseClass()

function RebateData:__init()
	if RebateData.Instance then
		print_error("[RebateData] Attemp to create a singleton twice !")
	end
	RebateData.Instance = self
	RemindManager.Instance:Register(RemindName.Rebate, BindTool.Bind(self.GetRebateRemind, self))
	self.is_first_open = true
end

function RebateData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Rebate)
	if RebateData.Instance then
		RebateData.Instance = nil
	end
end

function RebateData:SetFirstOpenTag(is_show)
	self.is_first_open = is_show
end

function RebateData:GetFirstOpenTag()
	return self.is_first_open
end

function RebateData:GetBaiBeiItemCfg()
	return ConfigManager.Instance:GetAutoConfig("opengameactivity_auto").other[1]
end

function RebateData:GetFashionResId(prof_sex, index, part_type)
	if part_type == SHIZHUANG_TYPE.WUQI then
		local weapon_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").weapon_special_img
		for k,v in pairs(weapon_cfg) do
			if index == v.image_id and v["resouce" .. prof_sex] then
				return v["resouce" .. prof_sex]
			end
		end
	else
		local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").shizhuang_special_img
		for k,v in pairs(fashion_cfg) do
			if index == v.image_id and v["resouce" .. prof_sex] then
				return v["resouce" .. prof_sex]
			end
		end
	end
end

function RebateData:GetGiftInfoList()
	local gifts_info = self:GetBaiBeiItemCfg().baibeifanli_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	for i = 1, 6 do
		item_data_list[i] = {}
		item_data_list[i].item_id = gifts_cfg["item_"..i.."_id"]
		item_data_list[i].num = gifts_cfg["item_"..i.."_num"]
		item_data_list[i].is_bind = gifts_cfg["is_bind_"..i]
	end
	return item_data_list
end

function RebateData:GetRebateRemind()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0
	return (self:GetBaiBeiGiftAwardFlag() and history_recharge >= DailyChargeData.GetMinRecharge()) and 1 or 0
end

function RebateData:GetBaiBeiGiftAwardFlag()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local remind_day = PlayerPrefsUtil.GetInt("rebate_remind_day") or cur_day
	if cur_day ~= -1 and cur_day ~= remind_day and nil ~= RebateCtrl.Instance.is_buy then
		return RebateCtrl.Instance.is_buy
	end
	return false
end