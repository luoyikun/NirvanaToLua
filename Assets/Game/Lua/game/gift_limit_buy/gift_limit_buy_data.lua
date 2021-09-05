GiftLimitBuyData = GiftLimitBuyData or BaseClass()

function GiftLimitBuyData:__init()
	if GiftLimitBuyData.Instance ~= nil then
		ErrorLog("[GiftLimitBuyData] Attemp to create a singleton twice !")
	end

	self.opengameactivity_cfg = ConfigManager.Instance:GetAutoConfig("opengameactivity_auto")
	self.giftlimitbuy_mainui_show = true
	GiftLimitBuyData.Instance = self
	self.selectindex = 1
	RemindManager.Instance:Register(RemindName.GiftLimitBuy, BindTool.Bind(self.GetGiftLimitBuyRemind, self))
end

function GiftLimitBuyData:__delete()
	RemindManager.Instance:UnRegister(RemindName.GiftLimitBuy)
	GiftLimitBuyData.Instance = nil
end

function GiftLimitBuyData:GetGiftLimitBuyRemind()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2) then
		return 0
	end
	if self.is_open_view then
		return 0
	end
	local is_remind = RemindManager.Instance:RemindToday(RemindName.GiftLimitBuy)
	if not is_remind then
		return 1
	end
	return 0
end

function GiftLimitBuyData:SetOpenViewState(enable)
	self.is_open_view = enable
end

function GiftLimitBuyData:SetGiftLimitBuyMainuiShow(is_show)
	self.giftlimitbuy_mainui_show = is_show
end

function GiftLimitBuyData:GetGiftLimitBuyMainuiShow()
	return self.giftlimitbuy_mainui_show
end

function GiftLimitBuyData:GetRealGiftShopCfg()
	if self.opengameactivity_cfg == nil then
		return {}
	end
	return self.opengameactivity_cfg.limit_buy_gift or {}
end

-- 限购礼包配置
function GiftLimitBuyData:GetGiftShopCfg()
	local cfg = {}
	local flag = self:GetGiftShopFlag()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.opengameactivity_cfg and self.opengameactivity_cfg.limit_buy_gift then
		for k, v in pairs(self.opengameactivity_cfg.limit_buy_gift) do
			if role_vo.level >= v.level and role_vo.level <= v.max_level and role_vo.vip_level >= v.vip_level then
				local temp_cfg = {}
				temp_cfg.reward_item_list = {}
				temp_cfg.sort_key = flag[32 - v.seq] == 1 and v.seq + 100 or v.seq
				temp_cfg.flag = flag[32 - v.seq]
				for k2, v2 in pairs(v) do
					if type(v2) == "table" and v2.item_id and v2.item_id > 0 then
						local data = {item_id = v2.item_id, num = v2.num, is_bind = v2.is_bind}
						local index = tonumber(string.sub(k2, -1))
						temp_cfg.reward_item_list[index + 1] = data
					else
						temp_cfg[k2] = v2
					end
				end
				table.insert(cfg, temp_cfg)
			end
		end

		table.sort(cfg, SortTools.KeyLowerSorter("sort_key"))
	end

	return cfg
end

function GiftLimitBuyData:GetGiftShopFlag()
	return bit:d2b(self.oga_gift_shop_flag or 0) or {}
end

-- 限购礼包活动信息
function GiftLimitBuyData:SetGiftShopFlag(protocol)
	self.oga_gift_shop_flag = protocol.buy_flag
end

function GiftLimitBuyData:SetSelect(index)
	self.selectindex = index
end

function GiftLimitBuyData:GetSelectIndex()
	return self.selectindex
end

function GiftLimitBuyData:IsOpenGiftLimitBuy()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2) then
		return false
	end
	if not ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPPER_GIFT2) then
		return false
	end

	if nil == self.oga_gift_shop_flag then
		return false
	end
	local flag = self:GetGiftShopFlag()
	local cfg = self:GetGiftShopCfg()
	for _, v in pairs(cfg) do
		if v.seq and flag[32 - v.seq] == 0 then
			return true
		end
	end
	return false
end
