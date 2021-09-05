AdvancedReturnData = AdvancedReturnData or BaseClass()

function AdvancedReturnData:__init()
	if AdvancedReturnData.Instance then
		print_error("[AdvancedReturnData] Attempt to create singleton twice!")
		return
	end
	AdvancedReturnData.Instance = self
	self.upgrade_return_info = {}
	-- RemindManager.Instance:Register(RemindName.BiPin, BindTool.Bind(self.GetBiPinRemind, self))
	-- RemindManager.Instance:Register(RemindName.BPCapabilityRemind, BindTool.Bind(self.GetBPCapabilityRemind, self))
	self.show_time = 0
	self.act_item = 0
	self.act_grade = 0
	self.need_gold = 0
	self.max_grade = 0
	self.config = ServerActivityData.Instance:GetCurrentRandActivityConfig().jinjie_return
	self.shop_buy = ConfigManager.Instance:GetAutoConfig("upgrade_card_buy_cfg_auto").buy_cfg
	self.shop_other = ConfigManager.Instance:GetAutoConfig("upgrade_card_buy_cfg_auto").other[1]
	RemindManager.Instance:Register(RemindName.FanHuan, BindTool.Bind(self.GetFanHuanRemind, self))
end

function AdvancedReturnData:__delete()

	AdvancedReturnData.Instance = nil
	self.is_first_open = true
	self.toggle_not_is_on = nil
end
--进阶返还
function AdvancedReturnData:SetUpGradeReturnInfo(protocol)
	self.upgrade_return_info.act_type = protocol.act_type
	self.upgrade_return_info.fetch_reward_flag = bit:d2b(protocol.fetch_reward_flag)
end

function AdvancedReturnData:SetUpgradeCardBuyInfo(protocol)
	if protocol.activity_id == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN then
		self.upgrade_return_info.grade = protocol.grade 
		self.upgrade_return_info.sign = protocol.is_already_buy
	end
end

function AdvancedReturnData:GetJiangLiCfg()
	local day = nil
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in ipairs(self.shop_buy) do 
		if v.related_activity_s == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN and (nil == day or v.open_game_day == day) and v.open_game_day >= open_day 
		and v.grade == self.upgrade_return_info.grade and self.upgrade_return_info.act_type == v.act_theme then
			day = v.open_game_day
			self.act_item = v.item_id
			self.act_grade = v.show_grade
			 self.show_time = v.act_theme
			 self.need_gold = v.price
		end
	end 
end

function AdvancedReturnData:GetReturnShowItemCfg()
	return self.act_item, self.act_grade 
end
function AdvancedReturnData:GetReturnNeedGoldCfg()
	return self.need_gold
end

function AdvancedReturnData:GetUpGradeReturnInfo()
	return self.upgrade_return_info
end

function AdvancedReturnData:GetUpGradeReturnActType()
	return self.upgrade_return_info.act_type or 0
end

function AdvancedReturnData:GetUpGradeReturnList()
	local info = self:GetUpGradeReturnInfo()
	local fetch_reward_t = info.fetch_reward_flag or {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ListToMapList(self.config, "act_type")
	local list = {}
	if cfg[self.upgrade_return_info.act_type] ~= nil then
		for i,v in ipairs(cfg[self.upgrade_return_info.act_type]) do
			fetch_reward_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
			local data = TableCopy(v)
			data.fetch_reward_flag = fetch_reward_flag
			table.insert(list, data)
		end
		table.sort(list, SortTools.KeyLowerSorter("fetch_reward_flag", "need_grade"))
	end
	return list
end


function AdvancedReturnData:GetImageResPath(image_type)
	local info = {}
	local cfg = {}
	local info_grade, res_id, bubble, asset = nil, nil, nil, nil
	if image_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		info_grade = MountData.Instance:GetGrade()
		cfg = MountData.Instance:GetMountImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetMountModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		info_grade = WingData.Instance:GetGrade()
		cfg = WingData.Instance:GetWingImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetWingModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		info_grade = FaBaoData.Instance:GetGrade()
		cfg = FaBaoData.Instance:GetFaBaoImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetFaBaoModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		info_grade = FashionData.Instance:GetWuQiGrade()
		cfg = FashionData.Instance:GetWuQiImageID()
		self:MaxLevelGrade(cfg)
		res_id =self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetWeaponModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		info_grade = FootData.Instance:GetGrade()
		cfg = FootData.Instance:GetFootImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetFootModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		info_grade = HaloData.Instance:GetGrade()
		cfg = HaloData.Instance:GetHaloImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetHaloModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		info_grade = FashionData.Instance:GetNowGrade()
		cfg = FashionData.Instance:GetShizhuangImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg,info_grade,image_type)
		bubble, asset = nil,nil--ResPath.GetFashionModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		info_grade = FightMountData.Instance:GetGrade()
		cfg = FightMountData.Instance:GetMountImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetImageResID(cfg,info_grade)
		bubble, asset = ResPath.GetFightMountModel(res_id)
	-- elseif image_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
	-- 	info = TouShiData.Instance:GetGrade() 
	-- 	cfg = TouShiData.Instance:GetTouShiImage()
	-- 	res_id = nil --self:GetImageResID(cfg,info)
	-- 	bubble, asset = nil ,nil  ResPath.GetTouShiModel(res_id)
	-- elseif image_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
	-- 	info = MaskData.Instance:GetMaskInfo()
	-- 	cfg = MaskData.Instance:GetMaskImage()
	-- 	res_id = self:GetImageResID(cfg,info_grade)
	-- 	bubble, asset = ResPath.GetMaskModel(res_id)
	-- elseif image_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
	-- 	info = WaistData.Instance:GetYaoShiInfo()
	-- 	cfg = WaistData.Instance:GetWaistImage()
	-- 	res_id = self:GetImageResID(cfg,info_grade)
	-- 	bubble, asset = ResPath.GetWaistModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		info_grade = QilinBiData.Instance:GetGrade()
		cfg = QilinBiData.Instance:GetQilinBiImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		local main_vo = GameVoManager.Instance:GetMainRoleVo()	
		bubble, asset = ResPath.GetQilinBiModel(res_id, main_vo.sex)
	elseif image_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		info_grade = LingChongData.Instance:GetGrade()
		cfg = LingChongData.Instance:GetLingChongImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		bubble, asset = ResPath.GetLingChongModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		cfg = LingGongData.Instance:GetLingGongImage()
		info_grade = LingGongData.Instance:GetGrade()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		bubble, asset = ResPath.GetLingGongModel(res_id)

	elseif image_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		info_grade = LingQiData.Instance:GetGrade()
		cfg = LingQiData.Instance:GetLingQiImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		bubble, asset = ResPath.GetLingQiModel(res_id)

	elseif image_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		info_grade = ShengongData.Instance:GetGrade()
		cfg = ShengongData.Instance:GetShengongImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		bubble, asset = ResPath.GetGoddessHaloModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		info_grade = ShenyiData.Instance:GetGrade() or {}
		cfg = ShenyiData.Instance:GetShenyiImageCfg()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg,info_grade,image_type)
		bubble, asset = ResPath.GetGoddessFaZhenModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		info_grade = FlyPetData.Instance:GetGrade()
		cfg = FlyPetData.Instance:GetFlyPetImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg, info_grade, image_type)
		bubble, asset = ResPath.GetFlyPetModel(res_id)
	elseif image_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		info_grade = WeiYanData.Instance:GetGrade()
		cfg = WeiYanData.Instance:GetWeiYanImage()
		self:MaxLevelGrade(cfg)
		res_id = self:GetFashionImageResID(cfg,info_grade,image_type)
		bubble, asset = ResPath.GetWeiYanModel(res_id)
	end
	return info_grade, bubble, asset,res_id
end

function AdvancedReturnData:GetImageResID(data_list,grade)
	local grade = grade >= #data_list and #data_list or grade 
	local grade_cfg = grade > 0 and grade or 1
	for k,v in ipairs(data_list) do
		if v.show_grade == grade_cfg then
			return v.res_id
		end
	end
end

function AdvancedReturnData:GetFashionImageResID(data_list, grade, type)
	local grade = grade >= #data_list and #data_list or grade 
	local grade_cfg = grade > 0 and grade or 1
	local role_vo = PlayerData.Instance:GetRoleVo()		--角色信息
	local prof = PlayerData.Instance:GetRoleBaseProf(role_vo.prof)
	for k,v in ipairs(data_list) do
		if v.image_id == grade_cfg then
			if type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
				return v["resouce" .. prof .. role_vo.sex]
			elseif type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
				return v["res_id" .. role_vo.sex .. "_h"]
			elseif type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN or type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
				return v.res_id_h
			else
				return v.res_id
			end
		end
	end
end

function AdvancedReturnData:ActivetyFuanHuanIsShow()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_RETURN) then
		if open_day > self.shop_other.limit_opengame_day and self.show_time ~= 0 then
			return true
		end
	end
	return false
end

function AdvancedReturnData:GetFanHuanRemind()
	local upgrade_return_info = self:GetUpGradeReturnInfo()
	if nil == upgrade_return_info or nil == next(upgrade_return_info) then
		return 0
	end
	local act_type = upgrade_return_info.act_type or 0
	local info = {}
	if act_type == TYPE_UPGRADE_RETURN.MOUNT_UPGRADE_RETURN then
		info = MountData.Instance:GetMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WING_UPGRADE_RETURN then
		info = WingData.Instance:GetWingInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FABAO_UPGRADE_RETURN then
		info = FaBaoData.Instance:GetFaBaoInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WUQI_UPGRADE_RETURN then
		info = FashionData.Instance:GetWuQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FOOT_UPGRADE_RETURN then
		info = FootData.Instance:GetFootInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.HALO_UPGRADE_RETURN then
		info = HaloData.Instance:GetHaloInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FASHION_UPGRADE_RETURN then
		info = FashionData.Instance:GetFashionInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FIGHTMOUNT_UPGRADE_RETURN then
		info = FightMountData.Instance:GetFightMountInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.TOUSHI_UPGRADE_RETURN then
		info = TouShiData.Instance:GetTouShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.MASK_UPGRADE_RETURN then
		info = MaskData.Instance:GetMaskInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WAIST_UPGRADE_RETURN then
		info = WaistData.Instance:GetYaoShiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.QILINBI_UPGRADE_RETURN then
		info = QilinBiData.Instance:GetQilinBiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGCHONG_UPGRADE_RETURN then
		info = LingChongData.Instance:GetLingChongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGGONG_UPGRADE_RETURN then
		info = LingGongData.Instance:GetLingGongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.LINGQI_UPGRADE_RETURN then
		info = LingQiData.Instance:GetLingQiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.SHENGONG_UPGRADE_RETURN then
		info = ShengongData.Instance:GetShengongInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.SHENYI_UPGRADE_RETURN then
		info = ShenyiData.Instance:GetShenyiInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.FLYPET_UPGRADE_RETURN then
		info = FlyPetData.Instance:GetFlyPetInfo()
	elseif act_type == TYPE_UPGRADE_RETURN.WEIYAN_UPGRADE_RETURN then
		info = WeiYanData.Instance:GetWeiYanInfo()
	end

	if nil == info or nil == next(info) or info.grade == nil then
		return 0
	end
	local current_grade = info.grade - 1
	local list = self:GetUpGradeReturnList()
	if list ~= nil and next(list) ~= nil then
		for k,v in pairs(list) do
			if v.fetch_reward_flag == 0 and current_grade >= v.need_grade then
				return 1
			end
		end
	end
	return 0
end


function AdvancedReturnData:MaxLevelGrade(info)
	self.max_grade = #info
end

function AdvancedReturnData:GetMaxLevelGrade()
	return self.max_grade
end

function AdvancedReturnData:GetActivitytimes(sever_time)
	local chongzhi_time_table = os.date('*t',sever_time)
	local chongzhi_cur_time = chongzhi_time_table.hour * 3600 + chongzhi_time_table.min * 60 + chongzhi_time_table.sec
	local time = 24 * 3600 - chongzhi_cur_time
	return time
end