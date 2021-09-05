ResetDoubleChongzhiData = PuTianTongQingData or BaseClass()

function ResetDoubleChongzhiData:__init()
	if ResetDoubleChongzhiData.Instance then
		print_error("[ResetDoubleChongzhiData] Attemp to create a singleton twice !")
	end
	ResetDoubleChongzhiData.Instance = self

	self.chong_zhi_info = {
		chongzhi_reward_flag = 0,
	}
	self.has_remind_num = 0

	RemindManager.Instance:Register(RemindName.ResetDoubleChongzhi, BindTool.Bind(self.GetResetDoubleChongzhiRemind, self))
end

function ResetDoubleChongzhiData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ResetDoubleChongzhi)
	self.has_remind_num = 0
	ResetDoubleChongzhiData.Instance = nil
end

function ResetDoubleChongzhiData:SetNum(num)
	self.has_remind_num = num
end

function ResetDoubleChongzhiData:GetResetDoubleChongzhiRemind()
	return self.has_remind_num
end

function ResetDoubleChongzhiData:SetChongzhiInfo(protocol)
	if not protocol then return end

	if not self.chong_zhi_info then
		self.chong_zhi_info = {}
	end

	self.chong_zhi_info.chongzhi_reward_flag = protocol.chongzhi_reward_flag or 0
end

function ResetDoubleChongzhiData:GetChongzhiInfo()
	return self.chong_zhi_info
end

function ResetDoubleChongzhiData:CheckIsFirstRechargeById(index)
	if not index or index < 0 then return true end

	if self.chong_zhi_info and self.chong_zhi_info.chongzhi_reward_flag then
		local flag = bit:d2b(self.chong_zhi_info.chongzhi_reward_flag)

		if flag and flag[32 - index] then
			return flag[32 - index] == 1
		end
	end
	return true
end

function ResetDoubleChongzhiData:IsAllRecharge()
	local cfg = RechargeData.Instance:GetRechargeIdList()
	if cfg then
		local is_all = true
		for k, v in pairs(cfg) do
			local is_charge = self:CheckIsFirstRechargeById(v)
			if not is_charge then
				is_all = false
				break
			end
		end
		return is_all
	end
	return true
end

function ResetDoubleChongzhiData:IsShowPuTianTongQing()
	local cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI)
	local level = 0
	if cfg and cfg.min_level then
		level = cfg.min_level
	end
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_REST_DOUBLE_CHONGZHI) and not self:IsAllRecharge() and PlayerData.Instance:GetRoleLevel() >= level then
		return true
	else
		return false
	end
end

function ResetDoubleChongzhiData:GetFightPower(item_cfg, show_item_id)
	local fight_power = 0
	local cfg = item_cfg
	if nil == cfg then
		return fight_power
	end
	local display_role = item_cfg.is_display_role
	fight_power = cfg.power
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FASHION or display_role == DISPLAY_TYPE.SHIZHUANG then
		local part_type = display_role == DISPLAY_TYPE.FASHION and SHIZHUANG_TYPE.WUQI or DISPLAY_TYPE.BODY
		for k, v in pairs(FashionData.Instance:GetShizhuangImgCfg()) do
			if v.item_id == show_item_id then
				if part_type == display_role == DISPLAY_TYPE.FASHION then
					cfg = FashionData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				else
					cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(v.image_id, 1)
				end
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == show_item_id then
					cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == show_item_id then
					cfg = FootData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
					break
				end
			end
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id == show_item_id then
				cfg = SpiritData.Instance:GetSpiritHuanhuaCfgById(v.active_image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LITTLEPET then
		for k, v in pairs(LittlePetData.Instance:GetLittlePetCfg()) do
			if v.active_item_id == show_item_id then
				local list = {
				maxhp = v.attr_value_0,
				gongji = v.attr_value_1,
				fangyu = v.attr_value_2,
				mingzhong = v.attr_value_3,
				shanbi = v.attr_value_4,
				baoji = v.attr_value_5,
				kangbao = v.attr_value_6,
				}
				cfg = TableCopy(list)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = FightMountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		for k, v in pairs(goddess_cfg.huanhua) do
			if v.active_item == show_item_id then
				cfg = GoddessData.Instance:GetXianNvHuanHuaLevelCfg(v.id, 1)
				if cfg then
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				end
			end
		end

	elseif display_role == DISPLAY_TYPE.BUBBLE then
		cfg = CoolChatData.Instance:GetBubbleCfgByItemId(show_item_id)
		if cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
		end
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		cfg = ZhiBaoData.Instance:FindZhiBaoHuanHuaByStuffID(show_item_id)
		if cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
		end
	elseif display_role == DISPLAY_TYPE.FABAO then
		for k, v in pairs(FaBaoData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == show_item_id then
				cfg = FaBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAOGUI then
		local cfg = EquipData.GetXiaoGuiCfgById(show_item_id)
		fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
	elseif display_role == DISPLAY_TYPE.TOUSHI then
		local toushi_special_cfg = TouShiData.Instance:GetSpecialImageCfg()
		for k, v in pairs(toushi_special_cfg) do
			if v.item_id == show_item_id then
				cfg = TouShiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.MASK then
		local mask_special_cfg = MaskData.Instance:GetSpecialImageCfg()
		for k, v in pairs(mask_special_cfg) do
			if v.item_id == show_item_id then
				cfg = MaskData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WAIST then
		local waist_special_cfg = WaistData.Instance:GetSpecialImageCfg()
		for k, v in pairs(waist_special_cfg) do
			if v.item_id == show_item_id then
				cfg = WaistData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.QILINBI then
		local qilinbi_special_cfg = QilinBiData.Instance:GetSpecialImageCfg()
		for k, v in pairs(qilinbi_special_cfg) do
			if v.item_id == show_item_id then
				cfg = QilinBiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGZHU then
		local lingzhu_special_cfg = LingZhuData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingzhu_special_cfg) do
			if v.item_id == show_item_id then
				cfg = LingZhuData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.XIANBAO then
		local xianbao_special_cfg = XianBaoData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(xianbao_special_cfg) do
			if v.item_id == show_item_id then
				cfg = XianBaoData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGTONG then
		local lingchong_special_cfg = LingChongData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingchong_special_cfg) do
			if v.item_id == show_item_id then
				cfg = LingChongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGGONG then
		local linggong_special_cfg = LingGongData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(linggong_special_cfg) do
			if v.item_id == show_item_id then
				cfg = LingGongData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.LINGQI then
		local lingqi_special_cfg = LingQiData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(lingqi_special_cfg) do
			if v.item_id == show_item_id then
				cfg = LingQiData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WEIYAN then
		local weiyan_special_cfg = WeiYanData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(weiyan_special_cfg) do
			if v.item_id == show_item_id then
				cfg = WeiYanData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHOUHUAN then
		local shouhuan_special_cfg = ShouHuanData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(shouhuan_special_cfg) do
			if v.item_id == show_item_id then
				cfg = ShouHuanData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.TAIL then
		local tail_special_cfg = TailData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(tail_special_cfg) do
			if v.item_id == show_item_id then
				cfg = TailData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FLYPET then
		local flypet_special_cfg = FlyPetData.Instance:GetSpecialImagesCfg()
		for k, v in pairs(flypet_special_cfg) do
			if v.item_id == show_item_id then
				cfg = FlyPetData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.TITLE then
		local item_cfg = ItemData.Instance:GetItemConfig(show_item_id)
		if not item_cfg then return end
		local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1)
		if title_cfg then
			fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(title_cfg))
		end
	end
	return fight_power
end