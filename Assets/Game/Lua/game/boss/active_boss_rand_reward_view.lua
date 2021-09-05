ActiveBossRankRewardView = ActiveBossRankRewardView or BaseClass(BaseView)

function ActiveBossRankRewardView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/bossview_prefab","ActiveBossRankRewardView"},
	}
	self.view_layer = UiLayer.Pop
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.reward_data = {}
end

function ActiveBossRankRewardView:__delete()

end

function ActiveBossRankRewardView:ReleaseCallBack()
	for k,v in pairs(self.item_panel_list) do
		v:DeleteMe()
	end
	self.item_panel_list = {}
	self.reward_data = {}
	self.list_view = nil
end

function ActiveBossRankRewardView:LoadCallBack()
	self.item_panel_list = {}
	self.node_list["Bg"].rect.sizeDelta = Vector3(450, 530,0)
	self.node_list["Txt"].text.text = Language.Activity.BtnRankReward
	self.list_view = self.node_list["ListView"]
	local list_view_delegate = self.list_view.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
end

function ActiveBossRankRewardView:GetNumberOfCells()
	return #self.reward_data
end

function ActiveBossRankRewardView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.item_panel_list[cell]
	if boss_cell == nil then
		boss_cell = ActiveBossRankRewardCell.New(cell.gameObject)
		self.item_panel_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.reward_data[data_index])
end

function ActiveBossRankRewardView:OpenCallBack()
	local boss_id = BossData.Instance:GetActiveBossRankMonsterID()
	self.reward_data = self:GetActiveBossRewardList(boss_id)
	self:Flush()
end

function ActiveBossRankRewardView:CloseCallBack()
	self.reward_data = {}
end

function ActiveBossRankRewardView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function ActiveBossRankRewardView:GetActiveBossRewardList(boss_id)
	local list = BossData.Instance:GetActiveBossHurtRewardList(boss_id)
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local prof = PlayerData.Instance:GetRoleBaseProf(main_vo.prof) or 1
	local reward_list = {}
	if nil == list or nil == next(list) then
		return reward_list
	end

	for k,v in pairs(list) do
		local reward_single_list = {}
		reward_single_list.bossid = v.bossid
		reward_single_list.rank = v.rank
		reward_single_list.reward_item = v["reward_item_" .. prof]
		reward_list[k] = reward_single_list
	end

	return reward_list
end

function ActiveBossRankRewardView:SetData(boss_id)
	self.reward_data = self:GetActiveBossRewardList(boss_id)
	self:Flush()
end

--------------------------------------ActiveBossRankRewardCell-----------------------------------------

ActiveBossRankRewardCell = ActiveBossRankRewardCell or BaseClass(BaseCell)

function ActiveBossRankRewardCell:__init()
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["ItemCell" .. i])
	end
end

function ActiveBossRankRewardCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function ActiveBossRankRewardCell:OnFlush()
	if self.data then
		local rank = self.data.rank_value or self.data.rank
		self.node_list["Txt_rank"].text.text = rank
		if rank <= 3 then
			local bundle, asset = ResPath.GetRankIcon(rank)
			self.node_list["Img_rank"].image:LoadSprite(bundle, asset, function()
  				self.node_list["Img_rank"].image:SetNativeSize()
  				self.node_list["Img_rank"]:SetActive(true)
   			end)
		else
			self.node_list["Img_rank"]:SetActive(false)
		end
		for i = 1, 3 do
			local data = self.data.reward_item[i - 1]
			self.item_cell_list[i]:SetParentActive(data ~= nil)
			if data then
				self.item_cell_list[i]:SetData(data)
			end
		end
	end
end