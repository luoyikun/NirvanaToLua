CoupleHomeShopData = CoupleHomeShopData or BaseClass()

function CoupleHomeShopData:__init()
	if CoupleHomeShopData.Instance then
		print_error("[CoupleHomeShopData] Attempt to create singleton twice!")
		return
	end

	local spouse_home_cfg = ConfigManager.Instance:GetAutoConfig("spouse_home_cfg_auto")
	self.furniture_shop_theme_type_cfg = ListToMapList(spouse_home_cfg.furniture_shop, "theme_type")
	self.furniture_shop_item_cfg = ListToMap(spouse_home_cfg.furniture_shop, "item_id")

	CoupleHomeShopData.Instance = self
end

function CoupleHomeShopData:__delete()
	CoupleHomeShopData.Instance = nil
end

function CoupleHomeShopData:GetShopInfoByThemeType(theme_type)
	return self.furniture_shop_theme_type_cfg[theme_type]
end

function CoupleHomeShopData:GetShopInfoByItemId(item_id)
	return self.furniture_shop_item_cfg[item_id]
end