SkyMoneyRewardView = SkyMoneyRewardView or BaseClass(BaseView)

function SkyMoneyRewardView:__init()
	self.ui_config = {{"uis/views/skymoney_prefab", "SkyMoneyRewardView"}}
	self.item_cells = {}
	self.is_modal = true
end

function SkyMoneyRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		v.item_cell:DeleteMe()
	end
	self.item_cells = {}
end

function SkyMoneyRewardView:LoadCallBack()
	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

	for i = 1, 6 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cells[i] = {item_obj = self.node_list["Item" .. i], item_cell = item_cell}
	end
end

function SkyMoneyRewardView:OpenCallBack()
	self:Flush("all")
end

function SkyMoneyRewardView:OnClickClose()
	self:Close()
	SkyMoneyData.Instance:CloseCallBack()
end

function SkyMoneyRewardView:OnFlush(param_t)
	local item_list = {}

	for k, v in pairs(param_t) do
		if k == "sky_money" then
			item_list = SkyMoneyData.Instance:GetSkyMoneyItemList()
			local bind_gold_num = SkyMoneyData.Instance:GetSkyMoneyGoldNum()
			local index = 0
			if item_list[k] then
				index = k
			end

			if bind_gold_num > 0 then
				local data = {item_id = 65533, num = bind_gold_num}
				if self.item_cells[index + 1] then
					self.item_cells[index + 1].item_obj:SetActive(true)
					self.item_cells[index + 1].item_cell:SetData(data)
				else
					self.item_cells[index - 1].item_obj:SetActive(true)
					self.item_cells[index - 1].item_cell:SetData(data)
				end
			end
		elseif k == "money_tree" then
			item_list = GuildData.Instance:GetMoneyTreeReward()
			local my_rank = GuildData.Instance:GetMoneyTreeRank()
			if my_rank > 0 then
				self.node_list["TextRank"]:SetActive(true)
				self.node_list["TextRank"].text.text = string.format(Language.Guild.MoneyTreeMyRank, my_rank)
			end
		end
	end

	if item_list == nil then return end
	for k, v in pairs(self.item_cells) do
		v.item_obj:SetActive(item_list[k] ~= nil)
		if item_list[k] then
			v.item_cell:SetData(item_list[k])
		end
	end
end
