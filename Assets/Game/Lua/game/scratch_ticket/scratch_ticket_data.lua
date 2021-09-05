ScratchTicketData = ScratchTicketData or BaseClass()

function ScratchTicketData:__init()
	if ScratchTicketData.Instance ~= nil then
		ErrorLog("[ScratchTicketData] attempt to create singleton twice!")
		return
	end
	ScratchTicketData.Instance = self
	self.count = -1
	self.chest_shop_mode = -1
	self.reward_seq_list = {}

	RemindManager.Instance:Register(RemindName.GuaGuaLe, BindTool.Bind(self.GetGuaGuaLeRemind, self))
end

function ScratchTicketData:__delete()
	ScratchTicketData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.GuaGuaLe)
	self.count = nil
	self.chest_shop_mode = nil
end

function ScratchTicketData:GetGuaGuaLeOtherCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other
end

function ScratchTicketData:GetGuaGuaLeCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end

function ScratchTicketData:GetThirtyKeyNum()
	self.cfg = self:GetGuaGuaLeOtherCfg()
    local keynum = 0
	if self.cfg and self.cfg[1] and self.cfg[1].guagua_roll_item_id then
        keynum = ItemData.Instance:GetItemNumInBagById(self.cfg[1].guagua_roll_item_id)
    end
    
	return keynum
end

function ScratchTicketData:GetThirtyKeyItemID()
	self.cfg = self:GetGuaGuaLeOtherCfg()
    local item_id = 0
	if self.cfg and self.cfg[1] and self.cfg[1].guagua_roll_item_id then
        item_id = self.cfg[1].guagua_roll_item_id
    end
    
	return item_id
end

function ScratchTicketData:GetGuaGuaCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() and ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua
	if cfg == nil then 
		return cfg
    end

    local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	return data
end

function ScratchTicketData:GetGuaGuaCfgByList()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() and ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	local data_list = ListToMapList(data,"is_special")
	if cfg == nil and data_list == nil then
		return {}
	end

	return data_list[1]
end

function ScratchTicketData:GetGuaGuaRewardCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig() and ServerActivityData.Instance:GetCurrentRandActivityConfig().guagua_acc_reward
	if cfg == nil then
		return nil
	end
	local data = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_DINGGUAGUA)
	return data
end


function ScratchTicketData:GetReturnReward()
	local return_reward_list = self:GetGuaGuaRewardCfg()
	local return_reward_flag = self.guagua_acc_reward_has_fetch_flag_table
	local sort_list = {}
	local return_list = {}
	for k,v in pairs(return_reward_list) do
		local temp_list = {}
		temp_list.cfg = v
		temp_list.fetch_flag = return_reward_flag[32 - k + 1]
		table.insert(return_list, temp_list)
	end
	for k,v in pairs(return_list) do
		if v.fetch_flag == 0 then
			table.insert(sort_list, v)
		end
	end
	for k,v in pairs(return_list) do
		if v.fetch_flag == 1 then
			table.insert(sort_list, v)
		end
	end
	return sort_list
end

function ScratchTicketData:GetGuaGuaCfgBySeq()
	local cfg = self:GetGuaGuaCfg()
	return ListToMap(cfg,"seq")
end

function ScratchTicketData:SetRAGuaGuaInfo(protocol)
	self.guagua_acc_count = protocol.guagua_acc_count or 0
	self.guagua_acc_reward_has_fetch_flag_table = bit:d2b(protocol.guagua_acc_reward_has_fetch_flag)   
end

function ScratchTicketData:GuaGuaMultiReward(protocol)
	self.reward_count = protocol.reward_count
	self.is_bind = protocol.is_bind
	self.reward_seq_list = protocol.reward_seq_list
end

function ScratchTicketData:GetGuaGuaCount()
	return self.guagua_acc_count or 0
end

function ScratchTicketData:GetCanFetchFlag(index)
	if not self.guagua_acc_reward_has_fetch_flag_table then
		return false
	end

	return (1 == self.guagua_acc_reward_has_fetch_flag_table[33 - index]) and true or false
end

function ScratchTicketData:GetAccFlag()
	-- body
end

function  ScratchTicketData:GetGuaGuaIndex()
	return self.reward_seq_list
end

function ScratchTicketData:SetChestShopMode(mode)
	self.chest_shop_mode = mode
end

function ScratchTicketData:GetChestShopMode()
	return self.chest_shop_mode
end

function ScratchTicketData:GetChestCount()
	return self.count
end

function ScratchTicketData:GetGuaGuaLeRemind()
	local num = GetListNum(self:GetGuaGuaRewardCfg())
	local data = self:GetGuaGuaRewardCfg()
	if data ~= nil then 
		if self:GetThirtyKeyNum() > 0 then
		    return 1
		end

		for i = 1, num do
			if not data[i] or not data[i].acc_count then
				return 0
			end
			if not self:GetCanFetchFlag(i) and data[i] and self.guagua_acc_count and data[i].acc_count <= self.guagua_acc_count then
				return 1
			end
		end
	end

	return 0
end

function ScratchTicketData:GetChestShopItemInfo()
	local data = {}
	local cfg = self:GetGuaGuaCfgBySeq()
	if cfg and next(cfg) then
		for k,v in pairs(self.reward_seq_list) do
			table.insert(data,cfg[v].reward_item[0])
		end
	end
	return data
end