RewardContentView = RewardContentView or BaseClass(BaseRender)

function RewardContentView:__init(instance)
	RewardContentView.Instance = self
	self.node_list["reward_btn"].button:AddClickListener(BindTool.Bind(self.RewardOnClick, self))
	self.item_cell = self.node_list["item_cell"]
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.item_cell)
	self.reward_item_id = 0
end

function RewardContentView:__delete()
	self.reward_item:DeleteMe()
end

function RewardContentView:OnFlush()
	local rewrd_info = SettingData.Instance:GetRewardInfo()
	self.reward_item_id = rewrd_info.reward_item.item_id
	local data = {}
	data.item_id = rewrd_info.reward_item.item_id
	self.node_list["DetailText"].text.text = rewrd_info.explain
	self.reward_item:SetData(data)

	local server_version = SettingData.Instance:GetServerVersion()
	local fetch_reward_version = SettingData.Instance:FetchRewardVersion()
	if fetch_reward_version < server_version then
		UI:SetButtonEnabled(self.node_list["reward_btn"], true)
		self.node_list["BtnText"].text.text = Language.Common.LingQuJiangLi
	else
		UI:SetButtonEnabled(self.node_list["reward_btn"], false)
		self.node_list["BtnText"].text.text = Language.Common.YiLingQu
	end
	self:SetRedPoint()
end

function RewardContentView:SetRedPoint()
	local state = SettingData.Instance:GetRedPointState()
	self.node_list["RedPoint"]:SetActive(state)
end

function RewardContentView:RewardOnClick()
	local server_version = SettingData.Instance:GetServerVersion()
	local fetch_reward_version = SettingData.Instance:FetchRewardVersion()
	if fetch_reward_version < server_version then
		SettingCtrl.Instance:SendUpdateNoticeFetchReward()
	end
end



