EquimentSuitData = EquimentSuitData or BaseClass()
XIANZUNKA_TYPE_MAX = 3
function EquimentSuitData:__init()
	if EquimentSuitData.Instance then
		print_error("[EquimentSuitData] attempt to create singleton twice!")
		return
	end

	EquimentSuitData.Instance = self
	self.suit_active_flag = {}
	self.suit_cfg = ConfigManager.Instance:GetAutoConfig("equipforge_auto").uplevel_suit
	RemindManager.Instance:Register(RemindName.EquimentSuit, BindTool.Bind(self.GetEquimentSuitRemind, self))
end

function EquimentSuitData:__delete()
		if EquimentSuitData.Instance then
			EquimentSuitData.Instance = nil
		end
		RemindManager.Instance:UnRegister(RemindName.EquimentSuit)
end

function EquimentSuitData:SetEquimentSuitLevel(protocol)
	self.suit_gard = protocol.suit_level 
	self.suit_active_flag = bit:d2b(protocol.suit_active_flag)
end

function EquimentSuitData:GetEquimentSuitLevel()
	return self.suit_gard or 0
end

function EquimentSuitData:SetSuitActiveFlag(index)
	return self.suit_active_flag[32 - index] == 1
end

function EquimentSuitData:GetEquimentSuitCfg(level)
	local suit_level = level + 1 > #self.suit_cfg and #self.suit_cfg or level + 1
	suit_level = suit_level < 2 and 2 or suit_level
	for k,v in pairs(self.suit_cfg) do 
		if v.order == suit_level then
			return v
		end
	end
end


function EquimentSuitData:GetEquimentSuitNeed(level)
	local data_list = EquipData.Instance:GetDataList()
	local num = 0
	for k, v in pairs(data_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id) 
		if item_cfg.limit_level >= level then
			num = num + 1
		end
	end
	return num 
end

function EquimentSuitData:GetEquimentSuitRemind()
	local suit_level = EquimentSuitData.Instance:GetEquimentSuitLevel()
	local data_list = EquimentSuitData.Instance:GetEquimentSuitCfg(suit_level)
	local act_flag = self:SetSuitActiveFlag(data_list.order)
	if data_list == nil then 
		return 0
	end
	local need_num = self:GetEquimentSuitNeed(data_list.equip_level)
	if need_num == data_list.need_count and not act_flag then
		return 1
	end
	return 0
end