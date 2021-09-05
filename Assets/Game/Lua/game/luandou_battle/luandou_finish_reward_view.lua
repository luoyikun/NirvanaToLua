LuanDouFinishRewardView = LuanDouFinishRewardView or BaseClass(BaseView)

function LuanDouFinishRewardView:__init()
	self.ui_config = {{"uis/views/luandoubattleview_prefab", "LuanDouFinishRewardView"}}
	self.item_cells = {}
	self.is_modal = true
end

function LuanDouFinishRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v.item_cell:DeleteMe()
	end
	self.item_cells = {}
end

function LuanDouFinishRewardView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cells[i] = {item_obj = self.node_list["Item" .. i], item_cell = item_cell}
	end
end

function LuanDouFinishRewardView:OpenCallBack()
	self:Flush()
end

function LuanDouFinishRewardView:OnClickClose()
	self:Close()
end

function LuanDouFinishRewardView:OnFlush(param_t)
	local all_rewards_list = {}
	for k,v in pairs(param_t) do
		if k == "luandou" then
			all_rewards_list = LuanDouBattleData.Instance:GetAllRankReward()
		elseif k == "nuzhan" then
			all_rewards_list = KuaFuTuanZhanData.Instance:GetAllRankReward()
		end
	end
	if not all_rewards_list then 
		return
	end
	local fisish_rewards_id_list = {}
	local fisish_rewards_isbind_list = {}
	for key, value in pairs(all_rewards_list) do
		if not value.reward_item then 
			return 
		end
		for u, v in pairs(value.reward_item) do
			if v.item_id and v.item_id > 0 then
				fisish_rewards_id_list[v.item_id] = fisish_rewards_id_list[v.item_id] or 0
				fisish_rewards_id_list[v.item_id] = fisish_rewards_id_list[v.item_id] + v.num
				fisish_rewards_isbind_list[v.item_id] = v.is_bind
			end
		end
	end

	local item_list = {}
	for m, n in pairs(fisish_rewards_id_list) do
		if m and n and fisish_rewards_isbind_list[m] then
			table.insert(item_list, {is_bind = fisish_rewards_isbind_list[m], item_id = m, num = n})
		end
	end
	for k, v in pairs(self.item_cells) do
		v.item_obj:SetActive(item_list[k] ~= nil)
		if item_list[k] then
			v.item_cell:SetData(item_list[k])
		end
	end
end
