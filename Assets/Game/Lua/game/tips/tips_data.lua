TipsData = TipsData or BaseClass()
function TipsData:__init()
	if TipsData.Instance ~= nil then
		print_error("[TipsData] attempt to create singleton twice!")
		return
	end
	TipsData.Instance = self

	self.gongao_num = nil
	self.kuafu_laba_state = false
end

function TipsData:__delete()
	TipsData.Instance = nil
end

function TipsData:SetGongGaoData(data)
	self.gonggao_data = data
end

function TipsData:GetGongGaoData()
	return self.gonggao_data
end

function TipsData:GetGongGaoDataNum()
	if nil == self.gonggao_data then
		return 0
	end

	return #self.gonggao_data
end

function TipsData:GetBorrowVo(info)
	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.is_immobile_role = 1
	role_vo.role_id = 0
	role_vo.obj_id = 0
	role_vo.name = ""
	role_vo.level = 500
	role_vo.sex = PlayerData.Instance:GetRoleVo().sex
	role_vo.prof = PlayerData.Instance:GetRoleVo().prof
	role_vo.pos_x = 10000
	role_vo.pos_y = 10000
	role_vo.move_speed = 100
	role_vo.max_hp = 100
	role_vo.hp = 100
	role_vo.appearance = TableCopy(PlayerData.Instance:GetRoleVo().appearance)
	role_vo.appearance.wuqi_id = 1
	role_vo.appearance.mount_used_imageid = 0
	role_vo.appearance.wing_used_imageid = 1
	role_vo.name_color = 0
	role_vo.wing_used_imageid = 0
	role_vo.multi_mount_res_id = 0
	role_vo.mount_appeid = 0
	role_vo.fight_mount_appeid = 0
	role_vo.special_param = -1
	if info then
		role_vo.role_id = info.role_id or 0
		role_vo.level = info.level or 0
		role_vo.plat_name = info.plat_name or 0
		role_vo.guild_id = info.guild_id or 0
		role_vo.guild_post = info.guild_post or 0
		role_vo.guild_name = info.guild_name or ""
		role_vo.name = info.role_name or ""
		role_vo.role_name = info.role_name or ""
		role_vo.prof = info.prof or role_vo.prof
		role_vo.sex = info.sex or role_vo.sex
		role_vo.pos_x = info.pos_x
		role_vo.pos_y = info.pos_y
		role_vo.role_name = (info.role_name or info.name)
		role_vo.appearance.baojia_image_id = info.baojia_use_image_id or 0
		role_vo.appearance.baojia_texiao_id = 0
		if info.shizhuang_part_list then
			local wuqi_info = info.shizhuang_part_list[1]
			role_vo.appearance.fashion_wuqi_is_special = wuqi_info.use_special_img > 0 and 1 or 0
			role_vo.appearance.fashion_wuqi = wuqi_info.use_special_img == 0 and wuqi_info.use_id or wuqi_info.use_special_img
			if info.equipment_info and info.equipment_info[7] then
				role_vo.appearance.wuqi_id = info.equipment_info[7].equip_id
			end

			local fashion_info = info.shizhuang_part_list[2]
			role_vo.appearance.fashion_body_is_special = fashion_info.use_special_img > 0 and 1 or 0
			role_vo.appearance.fashion_body = fashion_info.use_special_img == 0 and fashion_info.use_id or fashion_info.use_special_img
		end
	end
	return role_vo
end

function TipsData:SetKuaFuLaBaState(state)
	self.kuafu_laba_state = state
end

--是否开放跨服喇叭（根据渠道配置）
function TipsData:GetKuaFuLabaState()
	return self.kuafu_laba_state
end