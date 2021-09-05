-----------------------------------公会排行列表----------------------------------
GuildRankCell = GuildRankCell or BaseClass(BaseCell)
function GuildRankCell:__init(instance, parent)
	self.parent = parent
end

function GuildRankCell:__delete()
	self.parent = nil
end

function GuildRankCell:OnFlush()
	local cur_index = self.parent:GetCurIndex()
	if cur_index == GUILD_TOP_TOGGLE_NAME.QUESTION then
		local reward_cfg = {}
		local reward_num = reward_cfg.num
		local rank_list = WorldQuestionData.Instance:GetGuildQuestionRank()
		self.root_node.gameObject:SetActive(true)
		if self.index < 4 then
			reward_cfg = WorldQuestionData.Instance:GetGuildAnswerRewardList()[self.index]
			if rank_list and next(rank_list) then
				if rank_list[self.index] and next(rank_list[self.index]) and rank_list[self.index].uid ~= 0 then
					self.root_node.gameObject:SetActive(true)
					self.node_list["TxtRank"].text.text = self.index
					self.node_list["TxtName"].text.text = rank_list[self.index].name
					self.node_list["TxtCount1"].text.text = rank_list[self.index].right_answer_num
				else
					self.root_node.gameObject:SetActive(false)
				end
			else
				self.root_node.gameObject:SetActive(false)
			end
		else
			--自己排名
			local role_name = GameVoManager.Instance:GetMainRoleVo().role_name
			local my_answer = WorldQuestionData.Instance:GetMyQustionNum(WORLD_GUILD_QUESTION_TYPE.GUILD)
			local my_rank = WorldQuestionData.Instance:GetMyRank()
			reward_cfg = WorldQuestionData.Instance:GetMyReward(my_rank)
			local rank_text = my_rank == -1 and "-" or tostring(my_rank)
			self.node_list["TxtRank"].text.text = rank_text
			self.node_list["TxtName"].text.text = role_name
			self.node_list["TxtCount1"].text.text = my_answer
		end

		self.node_list["TxtCount2"].text.text = reward_cfg.num
		local item_cfg = ItemData.Instance:GetItemConfig(reward_cfg.item_id)
		if item_cfg and next(item_cfg) then
			self.node_list["ImgItem"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
		end
	elseif cur_index == GUILD_TOP_TOGGLE_NAME.SHAI_ZI then --骰子

	end
end