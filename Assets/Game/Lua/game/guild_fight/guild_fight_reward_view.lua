GuildFightRewardView = GuildFightRewardView or BaseClass(BaseView)

function GuildFightRewardView:__init()
	self.ui_config = {{"uis/views/guildfight_prefab", "GuildFightRewardView"}}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
end

function GuildFightRewardView:__delete()

end

function GuildFightRewardView:LoadCallBack()
	self.item_cell = {}
	for i = 1, 6 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
		self.item_cell[i]:SetParentActive(false)
	end

	self.node_list["ButtonConfirm"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnXianMengShuChu"].button:AddClickListener(BindTool.Bind(self.OnClickGuildShowView, self))

end

-- 打开仙盟输出展示面板
function GuildFightRewardView:OnClickGuildShowView()
	self:Close()
	GuildCtrl.Instance:OpenGuildShowView(ACTIVITY_TYPE.GUILDBATTLE)
end

function GuildFightRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function GuildFightRewardView:OpenCallBack()
	self:Flush()
end

function GuildFightRewardView:OnFlush()
	local role_info = GuildFightData.Instance:GetRoleInfo()
	self.node_list["GongXian"].text.text = 0
	if role_info then
		local score = role_info.history_get_person_credit
		local info, next_info, total_reward = GuildFightData.Instance:GetRewardInfoByScore(score)
		-- if total_reward and total_reward.banggong > 0 then
		-- 	local bang_gong = {item_id = 90009, num = total_reward.banggong, is_bind = 1}
		-- 	table.insert(total_reward.reward_item, bang_gong)
		-- end
		-- if total_reward and total_reward.shengwang > 0 then
		-- 	local shengwang = {item_id = 90003, num = total_reward.shengwang, is_bind = 1}
		-- 	table.insert(total_reward.reward_item, shengwang)
		-- end

		if total_reward then
			for i = 1, 6 do
				local item_info = total_reward.reward_item[i - 1]
				if item_info then
					self.item_cell[i]:SetParentActive(true)
					self.item_cell[i]:SetData(item_info)
				else
					self.item_cell[i]:SetParentActive(false)
				end
			end
			self.node_list["GongXian"].text.text = total_reward.banggong
		end
	end
end