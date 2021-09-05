TipsRewardView = TipsRewardView or BaseClass(BaseView)

function TipsRewardView:__init()
	self.ui_config = {{"uis/views/tips/rewardtips_prefab", "RewardTips"}}
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.reward_state = false
end

function TipsRewardView:__delete()
	
end

function TipsRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	
	self.data_list = nil
end

function TipsRewardView:SetData(items)
	self.data_list = items
end

function TipsRewardView:SetTittle(tittle)
	-- self.tittle_name = tittle --名字在预置体里面变成图片了
	self.reward_state = tittle
end

function TipsRewardView:LoadCallBack()
	local item_manager = self.node_list["ItemManager"]
	local child_number = item_manager.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = item_manager.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.item_list[count] = ItemCellReward.New()
			self.item_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end
end

function TipsRewardView:CloseView()
	self:Close()
end

function TipsRewardView:OpenCallBack()
	for k,v in pairs(self.item_list) do
		v:SetParentActive(self.data_list[k-1] ~= nil)
		if self.data_list[k-1] then
			v:SetData(self.data_list[k-1])
		end
	end

	self.node_list["Reward"]:SetActive(self.reward_state)
	self.node_list["CanReward"]:SetActive(not self.reward_state)
end
