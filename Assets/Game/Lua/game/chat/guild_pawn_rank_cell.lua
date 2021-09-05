--------------------------------------------------------------------------
-- GuildPawnRankCell 	骰子积分排名
--------------------------------------------------------------------------
GuildPawnRankCell = GuildPawnRankCell or BaseClass(BaseCell)

function GuildPawnRankCell:__init(instance)
	self:RankInit()
end

function GuildPawnRankCell:__delete()

end

function GuildPawnRankCell:RankInit()

end

function GuildPawnRankCell:OnFlush()
	if not next(self.data) then return end
	self.node_list["RankName"].text.text = self.data.name
	self.node_list["RankScore"].text.text = self.data.score
	self.node_list["RankNum"].text.text = self:GetIndex()

	self.node_list["RankNum"]:SetActive(self:GetIndex() > 3)
	self.node_list["No1"]:SetActive(self:GetIndex() == 1)
	self.node_list["No2"]:SetActive(self:GetIndex() == 2)
	self.node_list["No3"]:SetActive(self:GetIndex() == 3)
	local guild_rank_reward = PlayPawnData.Instance:GetRankReward(self:GetIndex())
	if guild_rank_reward and next(guild_rank_reward) then
		-- 奖励物品
		if guild_rank_reward.item_id then
			local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id)
			if item_cfg and next(item_cfg) then
				self.node_list["Imgitem"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
			end
		end
		if guild_rank_reward.num then
			self.node_list["TxtCount"].text.text = guild_rank_reward.num
		end
	end

	-- local name = GameVoManager.Instance:GetMainRoleVo().name or ""
	-- self.node_list["HighLight"]:SetActive(name == self.data.name)
end

function GuildPawnRankCell:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function GuildPawnRankCell:LoadUserCallBack(uid, raw_img_obj, path)

end