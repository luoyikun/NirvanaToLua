-- 积分面板
FishingTablePanelView = FishingTablePanelView or BaseClass(BaseRender)

function FishingTablePanelView:__init()
	self.obj_score_animator = false
	-- 监听UI事件
	self.old_first_name = nil

	self.node_list["BtnShrink"].toggle:AddClickListener(BindTool.Bind(self.OnClickScoreHandler, self))
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClickReceivebtn, self))

	----------------------------------------------------
	-- 列表生成日志滚动条
	self.fishing_rank_cell_list = {}
	self.rank_listview_data = {}
	local rank_list_delegate = self.node_list["RankList"].list_simple_delegate
	--生成数量
	rank_list_delegate.NumberOfCellsDel = function()
		return #self.rank_listview_data or 0
	end
	--刷新函数
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingRankListView, self)
end

function FishingTablePanelView:__delete()
	if self.item_cell_left then
		self.item_cell_left:DeleteMe()
		self.item_cell_left = nil
	end

	if self.item_cell_right then
		self.item_cell_right:DeleteMe()
		self.item_cell_right = nil
	end
	

	if self.fishing_rank_cell_list then
		for k,v in pairs(self.fishing_rank_cell_list) do
			v:DeleteMe()
		end
	end
	self.fishing_rank_cell_list = {}
	if self.item_cell_list then
		for k,v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
	end
end

function FishingTablePanelView:LoadCallBack(instance)
	self.item_cell_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ItemCellLeft"])
		self.item_cell_list[i] = item_cell
	end

	self:Flush()
end

function FishingTablePanelView:OnFlush(param_list)
	local fishing_score_info = CrossFishingData.Instance:GetFishingScoreStageInfo()
	local user_info = CrossFishingData.Instance:GetFishingUserInfo()
	local steal_count = CrossFishingData.Instance:GetFishingOtherCfg().steal_count
	local be_stealed_count = CrossFishingData.Instance:GetFishingOtherCfg().be_stealed_count
	local score_reward_cfg = CrossFishingData.Instance:GetFishingScoreRewardCfgByStage(fishing_score_info.cur_score_stage)
	local max_score = CrossFishingData.Instance:GetMaxRewardScore()
	UI:SetButtonEnabled(self.node_list["Button"], true)
	if not score_reward_cfg then
		UI:SetButtonEnabled(self.node_list["Button"], false)
		score_reward_cfg = CrossFishingData.Instance:GetFishingScoreRewardCfgByStage(#CrossFishingData.Instance:GetFishingCfg().score_reward - 1)
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp = score_reward_cfg and score_reward_cfg.exp_reward or 0
	
	local item = {}
	if score_reward_cfg and score_reward_cfg.reward_item then
		for k, v in pairs(score_reward_cfg.reward_item) do
			table.insert(item, v)
		end
	end
	table.insert(item, {item_id = ResPath.CurrencyToIconId.exp or 0,num = exp,is_bind = 0})
	for i = 1, 3 do
		if item[i] and item[i].item_id ~= 0 then
			self.item_cell_list[i]:SetData(item[i])
			self.item_cell_list[i]:SetActive(true)
		else
			self.item_cell_list[i]:SetActive(false)
		end
	end
	if fishing_score_info and user_info then
		local need_score = score_reward_cfg and score_reward_cfg.need_score or 0
		local text_color = fishing_score_info.fishing_score < need_score and TEXT_COLOR.RED_4 or TEXT_COLOR.GREEN_4
		self.node_list["TxtNext"].text.text = string.format(Language.Fishing.LabelNextStage, text_color, fishing_score_info.fishing_score, need_score)
		self.node_list["TxtScore"].text.text = string.format(Language.Fishing.LabelMyStealed, user_info.be_stealed_fish_count or 0 , be_stealed_count)
		self.node_list["TxtSteal"].text.text = string.format(Language.Fishing.LabelMySteal, user_info.steal_fish_count or 0 , steal_count)
		local flag = fishing_score_info.fishing_score >= max_score
		self.node_list["HasGet"]:SetActive(flag)
		-- self.node_list["ItemCellBg"]:SetActive(not flag)
	end
	self:OnFlushRank()
end

function FishingTablePanelView:OnFlushRank()
	-- 设置排行榜list数据
	local rank_info = CrossFishingData.Instance:GetCrossFishingScoreRankList()
	if nil == rank_info then
		return
	end
	self.rank_listview_data = rank_info.fish_rank_list
	if self.node_list["RankList"] and self.node_list["RankList"].scroller and self.node_list["RankList"].scroller.isActiveAndEnabled then
		self.node_list["RankList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.old_first_name ~= nil and self.rank_listview_data and self.rank_listview_data[1] ~= nil and self.old_first_name ~= self.rank_listview_data[1].user_name then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelExchange, self.rank_listview_data[1].user_name))
	end
	self.old_first_name = (self.rank_listview_data and self.rank_listview_data[1] ~= nil) and self.rank_listview_data[1].user_name or nil
	-- 自己的排行信息
	local my_rank_data = CrossFishingData.Instance:GetMyRankInfo()
	if my_rank_data and my_rank_data.rank_index and my_rank_data.total_score then
		self.node_list["TxtMyScore"].text.text = string.format(Language.Fishing.CurRank, my_rank_data.rank_index)
		self.node_list["TxtName"].text.text = string.format(Language.Fishing.Score, my_rank_data.total_score)
	else
		local fishing_score_info = CrossFishingData.Instance:GetFishingScoreStageInfo()
		if fishing_score_info then
			self.node_list["TxtMyScore"].text.text = string.format(Language.Fishing.CurRank,Language.Common.NoRank)
			self.node_list["TxtName"].text.text = string.format(Language.Fishing.Score, fishing_score_info.fishing_score)
		end
	end
	-- if not next(my_rank_data) then
	-- 	self.node_list["TxtNoRank"]:SetActive(false)
	-- 	self.node_list["TxtMyRank"]:SetActive(true)
	-- 	return
	-- end
	self.node_list["TxtNoRank"]:SetActive(false)
	self.node_list["TxtMyRank"]:SetActive(true)

	-- self.node_list["TxtRank"].text.text = my_rank_data.rank_index

	-- self.node_list["TxtName"].text.text = my_rank_data.user_name
	
end

-- 日志列表listview
function FishingTablePanelView:RefreshFishingRankListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local rank_cell = self.fishing_rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = FishingRankItemRender.New(cell.gameObject)
		self.fishing_rank_cell_list[cell] = rank_cell
	end
	rank_cell:SetIndex(data_index)
	rank_cell:SetData(self.rank_listview_data[data_index])
end

function FishingTablePanelView:OnClickScoreHandler()
	self.obj_score_animator = not self.obj_score_animator
	self.node_list["BtnArrows"].rect:DORotate(Vector3(0, 0, self.obj_score_animator and 180 or 0), 0.3)
end

function FishingTablePanelView:OnClickReceivebtn()
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_SCORE_REWARD)
end
----------------------------------------------------------------------------
--FishingRankItemRender	钓鱼排行榜itemder
----------------------------------------------------------------------------
FishingRankItemRender = FishingRankItemRender or BaseClass(BaseCell)
function FishingRankItemRender:__init()
end

function FishingRankItemRender:__delete()
end

function FishingRankItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	self.node_list["TxtRanking"].text.text = self.data.rank_index
	self.node_list["TxtName"].text.text = self.data.user_name
	self.node_list["TxtScore"].text.text = self.data.total_score
	if self.data.rank_index < 4 then
		self.node_list["TxtRanking"]:SetActive(false)
		local bundle,asset = ResPath.GetRankIcon(self.data.rank_index)
		self.node_list["ImgRank"].image:LoadSprite(bundle,asset)
		self.node_list["ImgRank"]:SetActive(true)
	else
		self.node_list["TxtRanking"]:SetActive(true)
		self.node_list["ImgRank"]:SetActive(false)
	end
end
