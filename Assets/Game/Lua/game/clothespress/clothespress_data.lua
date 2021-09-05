ClothespressData = ClothespressData or BaseClass(BaseEvent)

function ClothespressData:__init()
	if ClothespressData.Instance then
		print_error("[ClothespressData] Attempt to create singleton twice!")
		return
	end
	ClothespressData.Instance = self

	self.all_suit_info_list = {}

	self.cfg = ConfigManager.Instance:GetAutoConfig("dressing_room_auto") or {}

	self.other_cfg = self.cfg.other or {}
	self.suit_cfg = self.cfg.suit_des or {}
	self.all_suit_part = self.cfg.suit_cfg or {}
	self.all_suit_attr = self.cfg.suit_attr or {}
	self.exchange_suit_cfg = self.cfg.suit_open_time or {}

	self.all_suit_cfg = ListToMap(self.suit_cfg,"suit_index")
	self.all_suit_part_cfg = ListToMapList(self.all_suit_part,"suit_index")
	self.all_suit_attr_cfg = ListToMapList(self.all_suit_attr,"suit_index")

	-- 用于左侧列表挑选索引
	self.select_index = 1
end

function ClothespressData:__delete()
	ClothespressData.Instance = nil
end
-------------------------------协议相关---------------------------------
function ClothespressData:SetAllSuitInfo(protocol)
	self.all_suit_info_list = {}
	local suit_info_list = protocol.info_list or {}
	local count = protocol.single_img_count or 0
	if count == 0 or nil == next(suit_info_list) then return end

	self:SetAllSuitDataByInfo(count, suit_info_list)
end

function ClothespressData:SetSingleSuitInfo(protocol)
	local is_active = protocol.is_active or 0
	local info_list = protocol.info
	local suit_index = info_list and info_list.suit_index + 1
	local part_index = info_list and info_list.img_index + 1

	if self.all_suit_info_list and suit_index and part_index and 
		self.all_suit_info_list[suit_index] and self.all_suit_info_list[suit_index][part_index] then
		self.all_suit_info_list[suit_index][part_index] = is_active
	end
end
-------------------------------协议结束---------------------------------

-------------------------------套装相关---------------------------------
--套装配置
function ClothespressData:GetAllSuitCfg()
	return self.suit_cfg
end

--最后一个套装配置(版本活动用)
function ClothespressData:GetFinallySuitCfg()
	local finally_suit_cfg = {}
	if nil == next(self.suit_cfg) or nil == self.suit_cfg[#self.suit_cfg] then
		return finally_suit_cfg
	end

	finally_suit_cfg = self.suit_cfg[#self.suit_cfg]
	return finally_suit_cfg
end

--所有套装信息
function ClothespressData:SetAllSuitDataByInfo(count, info_list)
	for i=1, count do
		local list = info_list[i]
		local single_suit_list = list and bit:d2b(list)
		local suit_part = {}

		if single_suit_list then
			local num = self:GetSingleSuitPartNumBySuitIndex(i)
			if num > 0 then
				for i=0, num-1 do
					if single_suit_list[32 - i] then
						table.insert(suit_part, single_suit_list[32 - i])
					end
				end
			end
		end

		table.insert(self.all_suit_info_list, suit_part)
	end
end

--单个套装的部位数量	suit_index	从1开始
function ClothespressData:GetSingleSuitPartNumBySuitIndex(suit_index)
	local num = 0
	if nil == suit_index or nil == self.all_suit_part_cfg or nil == self.all_suit_part_cfg[suit_index - 1] then
		return num 
	end

	num = #self.all_suit_part_cfg[suit_index - 1]
	return num
end
function ClothespressData:GetItemIsInClothesSuitIndex(item_id)
	if self.all_suit_part_cfg then
		for k,v in pairs(self.all_suit_part_cfg) do
			if v then
				for m,n in pairs(v) do
					if n and n.img_item_id == item_id then
						return true, n.suit_index, n.sub_index
					end
				end
			end
		end
	end
	return false, -1, -1
end

--单个套装的部位配置	suit_index	从1开始
function ClothespressData:GetSingleSuitPartCfgBySuitIndex(suit_index)
	local cfg = {}
	if nil == suit_index or nil == self.all_suit_part_cfg or nil == self.all_suit_part_cfg[suit_index - 1] then
		return cfg 
	end

	cfg = self.all_suit_part_cfg[suit_index - 1]
	return cfg
end

--单个套装的部位激活信息	suit_index	从1开始
function ClothespressData:GetSingleSuitPartInfoBySuitIndex(suit_index)
	local info = {}
	if nil == suit_index or nil == self.all_suit_info_list or nil == self.all_suit_info_list[suit_index] then
		return info 
	end

	info = self.all_suit_info_list[suit_index]
	return info
end

--单个套装的部位激活数量	suit_index	从1开始
function ClothespressData:GetSingleSuitActivePartNum(suit_index)
	local num = 0
	if nil == suit_index or nil == self.all_suit_info_list or nil == self.all_suit_info_list[suit_index] then
		return num
	end

	local list = self.all_suit_info_list[suit_index]
	for k,v in pairs(list) do
		if v == 1 then
			num = num + 1
		end
	end
	
	return num
end

function ClothespressData:GetSingleSuitDesCfg(suit_index)
	local info = {}
	if nil == suit_index or nil == self.all_suit_cfg or nil == self.all_suit_cfg[suit_index - 1] then
		return info 
	end

	info = self.all_suit_cfg[suit_index - 1]
	return info
end

function ClothespressData:SetSelectSuitIndex(index)
	self.select_index =  index
end

function ClothespressData:GetSelectSuitIndex()
	return self.select_index or 1
end

function ClothespressData:SetSelectSuitItemIndex(index)
	self.select_item_index =  index
end

function ClothespressData:GetSelectSuitItemIndex()
	return self.select_item_index or 1
end

function ClothespressData:GetAllSuitInfo()
	return self.all_suit_info_list or {}
end

function ClothespressData:GetCurSuitNeedShowModelInfo(suit_index)
	local single_suit_cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)
	-- local info_list = self:SetRoleModleInfo(single_suit_cfg)
	return single_suit_cfg
end

function ClothespressData:SetRoleModleInfo(single_suit_cfg)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- local sprit_res_id = 0
	local xianbao_res_id = 0
	local mount_res_id = 0
	local fight_mount_res_id = 0
	local multi_mount_res_id = 0
	local weiyan_res_id = 0	
	local index = 0
	local info = {}
	info.prof = main_role_vo.prof
	info.sex = main_role_vo.sex
	info.appearance = {}

	local sprite_info = {}
	sprite_info.offset = -1.5
	sprite_info.res_id = 0
	sprite_info.lingzhu_res_id = 0

	local goddess_info = {}
	goddess_info.goddess_offset = -1.5
	goddess_info.goddess_res_id = 0
	goddess_info.goddess_halo_id = 0
	goddess_info.goddess_fazhen_id = 0

	local lingtong_info = {}
	lingtong_info.offset = -1.5
	lingtong_info.res_id = 0
	lingtong_info.linggong_res_id = 0
	lingtong_info.lingqi_res_id = 0

	local flypet_info = {}
	flypet_info.offset = 1.5
	flypet_info.res_id = 0

	local xianbao_info = {}
	xianbao_info.offset = -1.5
	xianbao_info.res_id = 0
	
	for k,v in pairs(single_suit_cfg) do
		if v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then 					-- 披风
			info.appearance.cloak_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then			-- 足迹
			info.appearance.footprint_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then				-- 光环
			info.appearance.halo_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FABAO then				-- 法宝
			info.appearance.fabao_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then				-- 面饰
			info.appearance.mask_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then				-- 麒麟臂
			info.appearance.qilinbi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then				-- 头饰
			info.appearance.toushi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then				-- 羽翼
			info.appearance.wing_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then				-- 腰饰
			info.appearance.yaoshi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then	-- 时装(武器)
			info.appearance.fashion_wuqi = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then	-- 时装(衣服)
			info.appearance.fashion_body = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHOUHUAN then 			-- 手环
			info.appearance.shouhuan_used_imageid = v.img_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TAIL then 				-- 尾巴
			info.appearance.tail_used_imageid = v.img_id	
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then			-- 仙宠
			sprite_info.res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGZHU then 			-- 灵珠
			sprite_info.lingzhu_res_id = v.img_res_id
			if sprite_info.res_id <= 0 then
				local special_spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(main_role_vo.used_sprite_id)
				local spirit_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[1]
				sprite_info.res_id = special_spirit_cfg and special_spirit_cfg.res_id or spirit_cfg.res_id
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENGONG then			-- 仙女光环
			goddess_info.goddess_halo_id = v.img_res_id
			if goddess_info.goddess_res_id <= 0 then
				local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_role_vo.use_xiannv_id)
				local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
				goddess_info.goddess_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENYI then				-- 仙女法阵
			goddess_info.goddess_fazhen_id = v.img_res_id
			if goddess_info.goddess_res_id <= 0 then
				local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_role_vo.use_xiannv_id)
				local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
				goddess_info.goddess_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then				-- 伙伴
			goddess_info.goddess_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then			-- 战骑
			fight_mount_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then				-- 坐骑
			mount_res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGTONG then 			-- 灵宠
			lingtong_info.res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGGONG then 			-- 灵弓
			lingtong_info.linggong_res_id = v.img_res_id
			if lingtong_info.res_id <= 0 then
				local special_lingtong_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(main_role_vo.lingchong_used_imageid)
				local lingtong_cfg = LingChongData.Instance:GetSpecialImagesCfg()[20]
				lingtong_info.res_id = special_lingtong_cfg and special_lingtong_cfg.res_id or lingtong_cfg.res_id
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGQI then 				-- 灵骑
			lingtong_info.lingqi_res_id = v.img_res_id
			if lingtong_info.res_id <= 0 then
				local special_lingtong_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(main_role_vo.lingchong_used_imageid)
				local lingtong_cfg = LingChongData.Instance:GetSpecialImagesCfg()[20]
				lingtong_info.res_id = special_lingtong_cfg and special_lingtong_cfg.res_id or lingtong_cfg.res_id
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WEIYAN then 				-- 尾焰
			weiyan_res_id = v.img_res_id
			if mount_res_id <= 0 then
				local special_mount_cfg = MountData.Instance:GetSpecialImageCfg(main_role_vo.mount_used_imageid)
				local mount_cfg = MountData.Instance:GetSpecialImagesCfg()[1]
				mount_res_id = special_mount_cfg and special_mount_cfg.res_id or mount_cfg.res_id
			end
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FLYPET then 				-- 飞宠
			flypet_info.res_id = v.img_res_id
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANBAO then 			-- 仙宝
			xianbao_info.res_id = v.img_res_id		
		elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then 		-- 双骑
			multi_mount_res_id = v.img_res_id
		end
		index = v.sub_index
	end

	local list = {}
	list.role_info = info
	list.sprite_info = sprite_info
	list.goddess_info = goddess_info
	list.mount_res_id = mount_res_id
	list.fight_mount_res_id = fight_mount_res_id
	list.lingtong_info = lingtong_info
	list.weiyan_res_id = weiyan_res_id
	list.flypet_info = flypet_info
	list.xianbao_info = xianbao_info
	list.multi_mount_res_id = multi_mount_res_id
	list.sub_index = index

	return list
end

function ClothespressData:GetSingleModleInfo(suit_index, sub_index)
	local model_list = self:GetCurSuitNeedShowModelInfo(suit_index)
	if model_list == nil or next(model_list) == nil then return end

	local select_index = sub_index - 1
	local system_type = 0
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- local sprit_res_id = 0
	local xianbao_res_id = 0
	local mount_res_id = 0
	local fight_mount_res_id = 0
	local multi_mount_res_id = 0
	local weiyan_res_id = 0	
	local index = 0
	local info = {}
	info.prof = main_role_vo.prof
	info.sex = main_role_vo.sex
	info.appearance = {}

	local sprite_info = {}
	sprite_info.offset = -1.5
	sprite_info.res_id = 0
	sprite_info.lingzhu_res_id = 0

	local goddess_info = {}
	goddess_info.goddess_offset = -1.5
	goddess_info.goddess_res_id = 0
	goddess_info.goddess_halo_id = 0
	goddess_info.goddess_fazhen_id = 0

	local lingtong_info = {}
	lingtong_info.offset = -1.5
	lingtong_info.res_id = 0
	lingtong_info.linggong_res_id = 0
	lingtong_info.lingqi_res_id = 0

	local flypet_info = {}
	flypet_info.offset = 1.5
	flypet_info.res_id = 0

	local xianbao_info = {}
	xianbao_info.offset = -1.5
	xianbao_info.res_id = 0
	
	for k,v in pairs(model_list) do
		if tonumber(v.sub_index) == select_index then
			if v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then 					-- 披风
				info.appearance.cloak_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then			-- 足迹
				info.appearance.footprint_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then				-- 光环
				info.appearance.halo_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FABAO then				-- 法宝
				info.appearance.fabao_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then				-- 面饰
				info.appearance.mask_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then				-- 麒麟臂
				info.appearance.qilinbi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then				-- 头饰
				info.appearance.toushi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then				-- 羽翼
				info.appearance.wing_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then				-- 腰饰
				info.appearance.yaoshi_used_imageid = v.img_id + GameEnum.MOUNT_SPECIAL_IMA_ID
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then	-- 时装(武器)
				info.appearance.fashion_wuqi = v.img_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then	-- 时装(衣服)
				info.appearance.fashion_body = v.img_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHOUHUAN then 			-- 手环
				info.appearance.shouhuan_used_imageid = v.img_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TAIL then 				-- 尾巴
				info.appearance.tail_used_imageid = v.img_id	
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then			-- 仙宠
				sprite_info.res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGZHU then 			-- 灵珠
				sprite_info.lingzhu_res_id = v.img_res_id
				if sprite_info.res_id <= 0 then
					local special_spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(main_role_vo.used_sprite_id)
					local spirit_cfg = SpiritData.Instance:GetSpiritHuanImageConfig()[1]
					sprite_info.res_id = special_spirit_cfg and special_spirit_cfg.res_id or spirit_cfg.res_id
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENGONG then			-- 仙女光环
				goddess_info.goddess_halo_id = v.img_res_id
				if goddess_info.goddess_res_id <= 0 then
					local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_role_vo.use_xiannv_id)
					local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
					goddess_info.goddess_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENYI then				-- 仙女法阵
				goddess_info.goddess_fazhen_id = v.img_res_id
				if goddess_info.goddess_res_id <= 0 then
					local special_goddess_cfg = GoddessData.Instance:GetHuanhuaIdAndResIdByItemId(main_role_vo.use_xiannv_id)
					local goddess_cfg = GoddessData.Instance:GetXianNvHuanHuaCfg(1)
					goddess_info.goddess_res_id = special_goddess_cfg and special_goddess_cfg.res_id or goddess_cfg.resid
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then				-- 伙伴
				goddess_info.goddess_res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then			-- 战骑
				fight_mount_res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then				-- 坐骑
				mount_res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGTONG then 			-- 灵宠
				lingtong_info.res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGGONG then 			-- 灵弓
				lingtong_info.linggong_res_id = v.img_res_id
				if lingtong_info.res_id <= 0 then
					local special_lingtong_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(main_role_vo.lingchong_used_imageid)
					local lingtong_cfg = LingChongData.Instance:GetSpecialImagesCfg()[20]
					lingtong_info.res_id = special_lingtong_cfg and special_lingtong_cfg.res_id or lingtong_cfg.res_id
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGQI then 				-- 灵骑
				lingtong_info.lingqi_res_id = v.img_res_id
				if lingtong_info.res_id <= 0 then
					local special_lingtong_cfg = LingChongData.Instance:GetLingChongImageCfgInfoByImageId(main_role_vo.lingchong_used_imageid)
					local lingtong_cfg = LingChongData.Instance:GetSpecialImagesCfg()[20]
					lingtong_info.res_id = special_lingtong_cfg and special_lingtong_cfg.res_id or lingtong_cfg.res_id
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WEIYAN then 				-- 尾焰
				weiyan_res_id = v.img_res_id
				if mount_res_id <= 0 then
					local special_mount_cfg = MountData.Instance:GetSpecialImageCfg(main_role_vo.mount_used_imageid)
					local mount_cfg = MountData.Instance:GetSpecialImagesCfg()[1]
					mount_res_id = special_mount_cfg and special_mount_cfg.res_id or mount_cfg.res_id
				end
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FLYPET then 				-- 飞宠
				flypet_info.res_id = v.img_res_id
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANBAO then 			-- 仙宝
				xianbao_info.res_id = v.img_res_id		
			elseif v.suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then 		-- 双骑
				multi_mount_res_id = v.img_res_id
			end
			system_type = v.suit_system_type
		end
	end

	local list = {}
	list.role_info = info
	list.sprite_info = sprite_info
	list.goddess_info = goddess_info
	list.mount_res_id = mount_res_id
	list.fight_mount_res_id = fight_mount_res_id
	list.lingtong_info = lingtong_info
	list.weiyan_res_id = weiyan_res_id
	list.flypet_info = flypet_info
	list.xianbao_info = xianbao_info
	list.multi_mount_res_id = multi_mount_res_id
	list.system_type = system_type

	return list
end

-------------------------------套装结束---------------------------------
-------------------------------套装属性---------------------------------
--得到套装属性面板的显示数据
function ClothespressData:GetSuitAttrDataListBySuitIndex(suit_index)
	local data_ist = {}
	local suit_cfg = self:GetAllSuitCfg()
	if nil == suit_index or nil == next(self.suit_cfg) or nil == self.suit_cfg[suit_index] then
		return data_ist
	end

	-- local desc = self.suit_cfg[suit_index].suit_effect or ""
	-- local desc_2 = self.suit_cfg[suit_index].suit_effect2 or ""
	-- local attr = self:GetSingleSuitAttrySuitIndex(suit_index)
	local suit_name = self.suit_cfg[suit_index].suit_name or ""
	local part_num = self:GetSingleSuitPartNumBySuitIndex(suit_index)
	local active_part_num = self:GetSingleSuitActivePartNum(suit_index)
	local suit_attr = self:GetClothesSuitAttr(suit_index)
	local suit_item_cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)
	-- data_ist.desc = desc
	-- data_ist.desc_2 = desc_2
	-- data_ist.attr = attr
	data_ist.suit_name = suit_name
	data_ist.part_num = part_num
	data_ist.active_part_num = active_part_num
	data_ist.suit_attr = suit_attr or {}
	data_ist.suit_item_cfg = suit_item_cfg

	return data_ist
end

function ClothespressData:GetAttrList()
	local attr = {}
	attr.maxhp = 0
	attr.gong_ji = 0
	attr.fang_yu = 0
	attr.power = 0

	return attr
end

function ClothespressData:GetSingleSuitAttrySuitIndex(suit_index)
	local attr = self:GetAttrList()
	local single_suit_cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)

	for k,v in pairs(single_suit_cfg) do
		local img_id = v.img_id or 0
		local suit_system_type = v.suit_system_type or 0
		local single_attr = self:GetSingleSuitPartAttr(img_id, suit_system_type)
		attr.maxhp = attr.maxhp + single_attr.maxhp
		attr.gong_ji = attr.gong_ji + single_attr.gong_ji
		attr.fang_yu = attr.fang_yu + single_attr.fang_yu
		attr.power = attr.power + single_attr.power
	end

	return attr
end

function ClothespressData:GetSingleSuitPartAttr(img_id, suit_system_type)
	local fight_power = 0
	local cfg = {}
	local attr = self:GetAttrList()

	if suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_CLOAK then    				-- 披风
		cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FIGHT_MOUNT then		-- 战骑
		cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FOOTPRINT then			-- 足迹
		cfg = FootData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_HALO then				-- 光环
		cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGZHU then			-- 灵珠
		cfg = LingZhuData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MASK then				-- 面饰
		cfg = MaskData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SHOUHUAN then							-- 手环
		cfg = ShouHuanData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TAIL then				-- 尾巴
		cfg = TailData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WEIYAN then 			-- 尾焰
		cfg = WeiYanData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MOUNT then				-- 坐骑
		cfg = MountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_QILINBI then			-- 麒麟臂
		cfg = QilinBiData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENGONG then			-- 仙女光环
		cfg = ShengongData.Instance:GetSpecialImages(img_id)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHENYI then			-- 仙女法阵
		cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_TOUSHI then			-- 头饰
		cfg = TouShiData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_WING then				-- 羽翼
		cfg = WingData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANBAO then			-- 仙宝
		cfg = XianBaoData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_YAOSHI then			-- 腰饰
		cfg = WaistData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_JINGLING then			-- 仙宠
		cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_XIANNV then			-- 仙女
		cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_0 then 	-- 时装:武器
		cfg = FashionData.Instance:GetEquipInfoCfg(img_id, 1, false, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_SHIZHUANG_PART_1 then	-- 时装:衣服
		cfg = FashionData.Instance:GetShizhuangImg(img_id, 1, false, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then		-- 双骑
		cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGGONG then			-- 灵弓
		cfg = LingGongData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGQI then			-- 灵骑
		cfg = LingQiData.Instance:GetHuanHuaCfgInfo(img_id, 1)	
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_LINGTONG then			-- 灵宠
		cfg = LingChongData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_FLYPET then			-- 飞宠
		cfg = FlyPetData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	elseif suit_system_type == SPECIAL_IMG_TYPE.SPECIAL_IMG_TYPE_MULIT_MOUNT then 		-- 双骑
		cfg = MultiMountData.Instance:GetHuanHuaCfgInfo(img_id, 1)
	end

	if nil == cfg then return attr end

	local attr_cfg = CommonDataManager.GetAttributteByClass(cfg)
	fight_power = CommonDataManager.GetCapabilityCalculation(attr_cfg)
	if attr_cfg.max_hp then
		attr.maxhp = attr_cfg.max_hp
		attr.gong_ji = attr_cfg.gong_ji
		attr.fang_yu = attr_cfg.fang_yu
	end
	attr.power = fight_power

	return attr
end

function ClothespressData:GetClothesSuitAttr(suit_index)
	return self.all_suit_attr_cfg[suit_index - 1]
end

-----------------------------套装属性结束-------------------------------

-------------------------------衣橱兑换---------------------------------
--得到可兑换套装配置
function ClothespressData:GetExchangeSuitCfg()
	local exchange_suit_cfg = {}
	if nil == next(self.exchange_suit_cfg) then
		return exchange_suit_cfg
	end

	local cur_time = TimeCtrl.Instance:GetServerTime()
	local cur_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in pairs(self.exchange_suit_cfg) do
		local open_time = self:DateConversion(v.open_date)
		if (v.open_day == 0 and open_time ~= 0 and cur_time >= open_time) or (v.open_day ~= 0 and cur_open_day >= v.open_day) then
			local single_suit_cfg = self.all_suit_cfg[v.suit_index]
			table.insert(exchange_suit_cfg, single_suit_cfg)
		end
	end

	if #exchange_suit_cfg > 1 then
		table.sort(exchange_suit_cfg, SortTools.KeyLowerSorters("suit_index"))
	end
	return exchange_suit_cfg
end

--是否有可兑换的套装
function ClothespressData:GetIsHaveCanExchangeSuit()
	local exchange_suit_cfg = self:GetExchangeSuitCfg() or {}
	return #exchange_suit_cfg > 0
end

--兑换套装部位所需材料id
function ClothespressData:GetExchangeNeedMaterials()
	local materials_id = self.other_cfg[1] and self.other_cfg[1].exchange_ticket_item_id or 0
	return materials_id
end

function ClothespressData:GetOpenLevel()
	return self.other_cfg[1].open_level or 999
end

--得到单个套装可兑换的部位配置			suit_index	从1开始
function ClothespressData:SingleSuitCanExchangePartCfgBySuitIndex(suit_index)
	local can_exchange_part_cfg = {}
	local cfg = self:GetSingleSuitPartCfgBySuitIndex(suit_index)
	for k,v in pairs(cfg) do
		if v.need_exchange_ticket_num and v.need_exchange_ticket_num > -1 then 	--等于-1表示不可兑换
			table.insert(can_exchange_part_cfg, v)
		end
	end

	if #can_exchange_part_cfg > 1 then
		table.sort(can_exchange_part_cfg, SortTools.KeyLowerSorters("sub_index"))
	end
	return can_exchange_part_cfg
end

--字符串时间转成时间戳	@timeString: 字符串时间 ,时间格式必须为 2018-10-09 00:00:00 @return: 返回时间戳(int)
function ClothespressData:DateConversion(timeString)
	if nil == timeString or type(timeString) ~= "string" then
		print_error("timeString is not a string") 
		return 0 
	end

	local fun = string.gmatch(timeString, "%d+")	--%d表示查找一个数字，而后面的+表示1个或者多个
	local y = fun()
	if nil == y then
		return 0 
	end

	local m = fun()
	if nil == m then
		return 0 
	end

	local d = fun()
	if nil == d then 
		return 0 
	end

	local H = fun()
	if nil == H then 
		return 0 
	end

	local M = fun()
	if nil == M then
		return 0 
	end

	local S = fun()
	if nil == S then	
		return 0 
	end
	
	return os.time({year=y, month=m, day=d, hour=H, min=M, sec=S})
end

-----------------------------衣橱兑换结束-------------------------------