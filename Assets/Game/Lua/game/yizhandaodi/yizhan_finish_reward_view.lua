YiZhanFinishRewardView = YiZhanFinishRewardView or BaseClass(BaseView)

function YiZhanFinishRewardView:__init()
	self.ui_config = {{"uis/views/yizhandaodiview_prefab", "YiZhanFinishRewardView"}}
	self.item_cells = {}
	self.is_modal = true
end

function YiZhanFinishRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v.item_cell:DeleteMe()
	end
	self.item_cells = {}
end

function YiZhanFinishRewardView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cells[i] = {item_obj = self.node_list["Item" .. i], item_cell = item_cell}
	end
end

function YiZhanFinishRewardView:OpenCallBack()
	self:Flush()
end

function YiZhanFinishRewardView:OnClickClose()
	self:Close()
end

function YiZhanFinishRewardView:OnFlush(param_t)
	local info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiUserInfo()
	if not info then 
		return 
	end
	local all_rewards_list = info.kill_num_reward_list
	if not all_rewards_list then 
		return 
	end
	for k, v in pairs(self.item_cells) do
		v.item_obj:SetActive(all_rewards_list[k] ~= nil)
		if all_rewards_list[k] then
			v.item_cell:SetData(all_rewards_list[k])
		end
	end		
end
