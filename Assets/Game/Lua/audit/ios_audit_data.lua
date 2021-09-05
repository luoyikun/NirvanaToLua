IosAuditData = IosAuditData or {}
IosAuditData.is_audit = false
local self = IosAuditData

function IosAuditData:GetPlayerData()
	local t = {}
	local vo = PlayerData.Instance:GetRoleVo()
	t.name = vo.name
	t.level = "等级：" .. vo.level
	t.prof = vo.prof
	t.sex = vo.sex
	t.hp = vo.hp
	t.max_hp = vo.max_hp
	t.mp = vo.mp
	t.max_mp = vo.max_mp
	t.exp = vo.exp
	t.max_exp = vo.max_exp
	t.capability = vo.capability
	t.gold = vo.gold
	t.coin = vo.coin

	t.data_type = "PlayerData"
	return t
end

function IosAuditData:GetTaskData()
	local t = {}
	t.task_list = {}
	local task_data = MainUIData.Instance:GetTaskData()
	local i = 0
	for _, v in ipairs(task_data) do
		local task_config = TaskData.Instance:GetTaskConfig(v.task_id)
		if task_config and next(task_config) then
			t.task_list[i] = {}
			t.task_list[i].task_id = v.task_id
			t.task_list[i].task_status = v.task_status
			t.task_list[i].task_name = task_config.task_name
			if v.task_status == TASK_STATUS.NONE or v.task_status == TASK_STATUS.CAN_ACCEPT then
				t.task_list[i].task_desc = task_config.accept_desc
			elseif v.task_status == TASK_STATUS.ACCEPT_PROCESS then
				t.task_list[i].task_desc = task_config.progress_desc
				if task_config.progress_desc and task_config.progress_desc ~= "" and string.find(task_config.progress_desc, "%(") then
					local progress_desc = Split(task_config.progress_desc, "%(")
					if progress_desc and progress_desc[1] then
						t.task_list[i].task_desc = progress_desc[1]
					end
				end
			else
				t.task_list[i].task_desc = task_config.commit_desc
			end
			i = i + 1
		end
	end
	t.length = i
	t.data_type = "TaskData"
	return t
end

function IosAuditData:GetSkillData()
	local t = {}
	t.skill_data = {}
	local now_skill_data = MainUIData.Instance:GetSkillData()
	local i = 0
	for k,v in pairs(now_skill_data) do
		t.skill_data[i] = {}
		t.skill_data[i].is_exist = v.is_exist and 1 or 0
		i = i + 1
	end
	t.length = i
	t.data_type = "SkillData"
	return t
end

function IosAuditData:GetShopData()
	local t = {}
	t.shop_list = {}
	local now_shop_data = ShopData.Instance:GetAuditShenMiShop()
	local i = 0
	for k,v in pairs(now_shop_data) do
		t.shop_list[i] = {}
		t.shop_list[i].seq = v.seq
		t.shop_list[i].isbuy_status = v.isbuy_status
		t.shop_list[i].item_name = "[color=" .. ITEM_COLOR[v.item_color] .."]" .. v.item_name .."[/color]"
		t.shop_list[i].item_color = v.item_color
		t.shop_list[i].item_id = v.item_id
		t.shop_list[i].num = v.num
		t.shop_list[i].is_bind = v.is_bind
		t.shop_list[i].item_price = v.item_price
		local num_des = v.num > 1 and "*" .. v.num or ""
		local name_des = "[color=" .. ITEM_COLOR[v.item_color] .."]" .. v.item_name .. num_des .. "[/color]"
		local des = string.format(Language.Shop.AuditShopGouMai, v.item_price, name_des)
		t.shop_list[i].des = des or ""
		i = i + 1
	end
	t.length = i
	t.data_type = "ShopData"
	return t
end

function IosAuditData:GetPackageData()
	local t = {}
	t.package_list = {}
	local now_package_data = ItemData.Instance:GetBagItemDataList()
	local i = 0
	for k,v in pairs(now_package_data) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg and next(item_cfg) then
			t.package_list[i] = {}
			t.package_list[i].item_id = v.item_id
			t.package_list[i].num = v.num
			t.package_list[i].is_bind = v.is_bind
			t.package_list[i].icon_id = item_cfg.icon_id
			t.package_list[i].color = item_cfg.color
			i = i + 1
		end
	end
	t.length = i
	t.data_type = "PackageData"
	return t
end

function IosAuditData:GetPlayerAttrInfoData()
	local t = {}
	local vo = GameVoManager.Instance:GetMainRoleVo()
	t.name = vo.name
	local prof, grade = PlayerData.Instance:GetRoleBaseProf()
	t.prof_name = ZhuanZhiData.Instance:GetProfNameCfg(prof, grade)
	t.exp = vo.exp
	t.max_exp = vo.max_exp
	t.capability = vo.capability
	if vo.guild_name == ""	then
		t.guild_name = Language.Role.NoGuild
	else
		t.guild_name = vo.guild_name
	end
	t.all_charm = vo.all_charm
	t.evil = vo.evil
	t.base_gongji = vo.base_gongji
	t.base_fangyu = vo.base_fangyu
	t.base_max_hp = vo.base_max_hp
	t.base_mingzhong = vo.base_mingzhong
	t.base_shanbi = vo.base_shanbi
	t.base_baoji = vo.base_baoji
	t.base_jianren = vo.base_jianren

	t.data_type = "PlayerInfoAttrData"
	return t
end

function IosAuditData:GetAuditSkillRestTimeData()
	local t = {}
	t.skill_rest_time_list = {}
	-- local skill_rest_time_list = MainUIData.Instance:GetSkillRestTimeData()
	-- for k,v in pairs(skill_rest_time_list) do
	-- 	t.skill_rest_time_list.skill_index = v.skill_index
	-- 	t.skill_rest_time_list.skill_id = v.skill_id
	-- 	t.skill_rest_time_list.cd_end_time = v.cd_end_time
	-- end
	t.data_type = "SkillRestTimeData"
	return t
end

function IosAuditData:GetChongZhiData()
	local t = {}
	t.chongzhi_data = {}
	local recharge_list = RechargeData.Instance:GetRechargeIdList()
	local i = 0
	for k, v in pairs(recharge_list) do
		local recharge_data = RechargeData.Instance:GetRechargeInfo(v)
		if recharge_data and next(recharge_data) then
			t.chongzhi_data[i] = {}
			t.chongzhi_data[i].title = "¥" .. recharge_data.money
			t.chongzhi_data[i].chongzhi_value= "获得" .. recharge_data.gold
			t.chongzhi_data[i].gold_icon = recharge_data.gold_icon
			t.chongzhi_data[i].money = recharge_data.money
			i = i + 1
		end
	end
	t.length = i
	t.data_type = "ChongZhiData"
	return t
end

function IosAuditData:GetItemData()
	local t ={}
end