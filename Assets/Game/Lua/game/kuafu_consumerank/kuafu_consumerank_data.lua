KuaFuConsumeRankData = KuaFuConsumeRankData or BaseClass()


local CEll_COUNT = 3
function KuaFuConsumeRankData:__init()
	if KuaFuConsumeRankData.Instance then
		print_error("[KuaFuConsumeRankData] Attempt to create singleton twice!")
		return
	end
	KuaFuConsumeRankData.Instance=self
	local kuafuconsume_cfg = ConfigManager.Instance:GetAutoConfig("cross_randactivity_cfg_1_auto")
	self.kuafuconsume_cfg_reward_rank = kuafuconsume_cfg.consume_rank
	self.rank_list = {}
	self.total_consume = 0
	self.rank_count = 0
	self.end_time = 0
	self.begin_time = 0
	self.modify_id = 0
end

function KuaFuConsumeRankData:__delete()
	KuaFuConsumeRankData.Instance = nil
end

function KuaFuConsumeRankData:GetConsumeRank()
	return self.kuafuconsume_cfg_reward_rank
end

function KuaFuConsumeRankData:SetConsumeInfo(protocol)
	self.total_consume = protocol.total_consume
end

function KuaFuConsumeRankData:GetConsumeInfo()
	return self.total_consume
end

function KuaFuConsumeRankData:SetCrossRAConsumeRankGetRankACK(protocol)
	self.modify_id = protocol.modify_id
	self.rank_list = protocol.rank_list
	self.rank_count = protocol.rank_count
	if next(self.rank_list)	 == nil then
		return
	end
	table.sort(self.rank_list, SortTools.KeyUpperSorter("total_consume"))
end

function KuaFuConsumeRankData:GetCrossRankInfo()
	return self.rank_list
end

function KuaFuConsumeRankData:GetRankCount()
	return self.rank_count
end

function KuaFuConsumeRankData:GetModifyId()
	return self.modify_id
end

function KuaFuConsumeRankData:GetGiftCfgById(item_id)
	if not item_id then
		return nil
	end

	local cfg = ItemData.Instance:GetItemConfig(item_id)

	if cfg then
		local list = {}

		for i = 1, CEll_COUNT do
			local item_data = {}
			item_data.item_id = cfg["item_".. i .."_id"] or 0
			item_data.num = cfg["item_".. i .."_num"] or 0
			item_data.is_bind = cfg["is_bind_".. i] or 0

			if item_data.item_id ~= 0 and item_data.num ~= 0 and item_data.is_bind ~= 0 then
				list[i] = item_data
			end
		end

		return #list > 0 and list or nil
	end

	return nil
end