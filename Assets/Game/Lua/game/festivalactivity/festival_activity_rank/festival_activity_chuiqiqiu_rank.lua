-- 吹气球、虐狗排行榜-ChuiQiQiuRankContent
ChuiQiQiuRank =  ChuiQiQiuRank or BaseClass(BaseRender)

function ChuiQiQiuRank:__init()
	self.rank_list = {}

	self.rank_item_list = {}
	local rank_list_delegate = self.node_list["RankListView"].list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRankCells, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)

	self.part_reward = ItemCell.New()
	self.part_reward:SetInstanceParent(self.node_list["RewardItem"])

	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["HeadTitle"].button:AddClickListener(BindTool.Bind(self.OnClickTitle, self))
end

function ChuiQiQiuRank:__delete()

	for k,v in pairs(self.rank_item_list) do
		v:DeleteMe()
	end
	self.rank_item_list = {}

	if self.part_reward then
		self.part_reward:DeleteMe()
		self.part_reward = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ChuiQiQiuRank:LoadCallBack(instance)
	
end

function ChuiQiQiuRank:GetNumberOfRankCells()
	return FestivalActivityQiQiuData.Instance:GetPlantRankListCount()
end

function ChuiQiQiuRank:RefreshRankCell(cell, cell_index)
	cell_index = cell_index + 1
	local rank_cell = self.rank_item_list[cell]
	if rank_cell == nil then
		rank_cell = ChuiQiQiuRankCell.New(cell.gameObject, self)
		self.rank_item_list[cell] = rank_cell
	end
	rank_cell:SetIndex(cell_index)
	local reward_list = FestivalActivityQiQiuData.Instance:GetRankRewardByIndex(cell_index)
	if reward_list ~= nil then
		rank_cell:SetData(self.rank_list[cell_index], reward_list.planting_rank_reward)
	end
end

function ChuiQiQiuRank:OpenCallBack()
	local active_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE
	local send_type = RA_PLANTING_TREE_OPERA_TYPE.RA_PLANTING_TREE_OPERA_TYPE_RANK_INFO
	local rank_type = RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_PLANTING
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(active_type, send_type, rank_type)
	self:Flush()
end

function ChuiQiQiuRank:CloseCallBack()

end

function ChuiQiQiuRank:OnFlush(param_t)
	self.rank_list = FestivalActivityQiQiuData.Instance:GetPlantRankList()
	self:FlushTitle()
	self:FlushBottom()
	self.node_list["RankListView"].scroller:ReloadData(0)
end

function ChuiQiQiuRank:FlushTitle()

	local title_asset_id = FestivalActivityQiQiuData.Instance:GetPlantTitle()
	local bundle, asset = ResPath.GetTitleIcon(title_asset_id)
	self.node_list["Title"].image:LoadSprite(bundle, asset, function()
			self.node_list["Title"].image:SetNativeSize()
		end)
	TitleData.Instance:LoadTitleEff(self.node_list["Title"], title_asset_id, true)

	-- 刷新倒计时
	local activity_end_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE)
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
	self:ClearTimeDelay(activity_end_time)
	self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
		activity_end_time = activity_end_time - 1
		if activity_end_time > 0 then
			self.node_list["CountDown"].text.text = TimeUtil.FormatSecond(activity_end_time, 10)
		else
			self.node_list["CountDown"].text.text = TimeUtil.FormatSecond(activity_end_time, 3)
		end
	end)
end

-- 用于取消计时器延迟1s显示
function ChuiQiQiuRank:ClearTimeDelay(activity_end_time)
	activity_end_time = activity_end_time - 1
	if activity_end_time > 0 then
		self.node_list["CountDown"].text.text = TimeUtil.FormatSecond(activity_end_time, 10)
	else
		self.node_list["CountDown"].text.text = TimeUtil.FormatSecond(activity_end_time, 3)
	end
end

function ChuiQiQiuRank:FlushBottom()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	if nil == cfg then
		return
	end
	local part_reward_data = cfg.planting_tree_canyu_reward
	self.part_reward:SetData(part_reward_data)
	local my_rank = FestivalActivityQiQiuData.Instance:GetMyDaQiQiuInfo()
	
	if 0 == my_rank.rank then
		self.node_list["MyRank"].text.text = Language.Rank.NoInRank
	else
		self.node_list["MyRank"].text.text = my_rank.rank
	end
	self.node_list["MyTimes"].text.text = my_rank.times
end

function ChuiQiQiuRank:OnClickTitle()
	local title_asset_id = FestivalActivityQiQiuData.Instance:GetPlantTitle()
	local data = {item_id = title_asset_id, is_bind = 0, num = 1}
	TipsCtrl.Instance:OpenItem(data)
end

function ChuiQiQiuRank:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(288)
end

--------------------------ChuiQiQiuRankCell---------------------------------
ChuiQiQiuRankCell = ChuiQiQiuRankCell or BaseClass(BaseCell)

function ChuiQiQiuRankCell:__init()
	self.reward_item_list = {}
	for i = 1, 3 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end


end

function ChuiQiQiuRankCell:__delete()
	for k,v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
end

function ChuiQiQiuRankCell:SetData(data, reward_list)
	self.data = data
	if nil == data or nil == reward_list then
		return
	end
	self.node_list["Name"].text.text = data.role_name or ""
	self.node_list["Times"].text.text = data.opera_times or 0

	if self.index > 3 then
		self.node_list["Rank"].text.text = self.index
	else
		local bundle, asset = ResPath.GetRankIcon(self.index)
		self.node_list["RankImg"].image:LoadSprite(bundle, asset, function()
				self.node_list["RankImg"].image:SetNativeSize()
			end)
	end

	--代改
	for i = 1, 3 do
		if reward_list[i - 1] ~= nil then
			self.reward_item_list[i]:SetActive(true)
			self.reward_item_list[i]:SetData(reward_list[i - 1])
		else
			self.node_list["Item" .. i]:SetActive(false)
		end
	end

	-- 设置头像
	local role_id = self.data.uid

	AvatarManager.Instance:SetAvatar(role_id, self.node_list["RawHead"], self.node_list["Head"], self.data.sex, self.data.prof, false)
end