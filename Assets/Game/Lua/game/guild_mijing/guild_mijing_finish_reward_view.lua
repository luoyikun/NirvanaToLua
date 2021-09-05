GuildMijingFinishRewardView = GuildMijingFinishRewardView or BaseClass(BaseView)

function GuildMijingFinishRewardView:__init()
	self.ui_config = {{"uis/views/guildmijing_prefab", "GuildMijingFinishRewardView"}}
	self.item_cells = {}
	self.is_modal = true
end

function GuildMijingFinishRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v.item_cell:DeleteMe()
	end
	self.item_cells = {}
end

function GuildMijingFinishRewardView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cells[i] = {item_obj = self.node_list["Item" .. i], item_cell = item_cell}
	end
end

function GuildMijingFinishRewardView:OpenCallBack()
	self:Flush()
end

function GuildMijingFinishRewardView:OnClickClose()
	self:Close()
end

function GuildMijingFinishRewardView:OnFlush(param_t)
	local all_rewards_list = GuildMijingData.Instance:GetFinishDataList()
	if not all_rewards_list then 
		return 
	end
	for k, v in pairs(self.item_cells) do
		v.item_obj:SetActive(all_rewards_list[k] ~= nil)
		if all_rewards_list[k] and all_rewards_list[k].item_id and all_rewards_list[k].reward_item_num then
			v.item_cell:SetData({item_id = all_rewards_list[k].item_id, num = all_rewards_list[k].reward_item_num})
		end
	end		
end
