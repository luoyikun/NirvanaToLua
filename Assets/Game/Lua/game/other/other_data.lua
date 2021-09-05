OtherData = OtherData or BaseClass()

function OtherData:__init()
	if OtherData.Instance then
		print_error("[OtherData] Attempt to create singleton twice!")
		return
	end
	OtherData.Instance = self

	self.forbid_change_avatar_state = false

	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
	self.other_client_cfg = ListToMap(cfg.client_config, "plat_name")
	self.other_cfg = cfg.other[1]

	--创建根据渠道需要屏蔽的商店物品列表
	self:CreateHideInShopItemList()
end

function OtherData:__delete()
	OtherData.Instance = nil
end

function OtherData:CreateHideInShopItemList()
	self.hide_shop_item_list = {}
	for k, v in pairs(self.other_client_cfg) do
		self.hide_shop_item_list[k] = {}
		local hide_shop_item = v.hide_shop_item
		for _, v2 in pairs(hide_shop_item) do
			self.hide_shop_item_list[k][v2.item_id] = true
		end
	end
end

function OtherData:SetForbidChangeAvatarState(state)
	self.forbid_change_avatar_state = state
end

--是否可以更换头像（根据渠道配置）
function OtherData:CanChangePortrait()
	return not self.forbid_change_avatar_state
	-- local spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id or 0)
	-- local plat_cfg = self.other_client_cfg[spid]
	-- if plat_cfg then
	-- 	return plat_cfg.change_portrait == 1
	-- end

	-- return self.other_client_cfg["default"] and self.other_client_cfg["default"].change_portrait == 1 or false
end

--是否可以跨服聊天
function OtherData:IsCanCrossChat()
	if IS_ON_CROSSSERVER then
		local agent_id = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
		local cfg = self.other_client_cfg[agent_id]
		if cfg then
			if cfg.forbid_cross_chat == 1 then
				return false
			end
		end
	end
	return true
end

--是否显示跨服喇叭
function OtherData:IsShowCrossHron()
	local agent_id = tostring(GLOBAL_CONFIG.package_info.config.agent_id)
	local cfg = self.other_client_cfg[agent_id]
	if cfg then
		if cfg.hide_horn == 1 then
			return false
		end
	end
	return true
end

--是否开启举报功能
function OtherData:CanShowReport()
	local spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id or 0)
	local plat_cfg = self.other_client_cfg[spid]
	if plat_cfg then
		return plat_cfg.open_report == 1
	end

	return self.other_client_cfg["default"] and self.other_client_cfg["default"].open_report == 1 or false
end

--是否需要在商城屏蔽的物品
function OtherData:IsHideInShopItem(item_id)
	local spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id or 0)
	local item_list = self.hide_shop_item_list[spid]
	if item_list and item_list[item_id] then
		return true
	end

	return false
end