XiaoFeiRank =  XiaoFeiRank or BaseClass(BaseRender)
--每日消费排行 DayXiaoFeiRank
function XiaoFeiRank:__init()
	self.contain_cell_list = {}
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_XIAOFEI_NUM)
end

function XiaoFeiRank:__delete()
	self.list_view = nil
	self.player_data_list = nil
	if self.contain_cell_list ~= nil then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
end

function XiaoFeiRank:OpenCallBack()
	self.player_data_list = KaifuActivityData.Instance:GetDailyXiaoFeiRank()
	
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
		rest_time = rest_time - 1
		self:SetTime(rest_time)
	end)
	
	local gold = KaifuActivityData.Instance:GetDayConsumeRankInfo() or 0
	self.node_list["TxtXiaoFeiCount"].text.text = CommonDataManager.ConverMoney(gold)

	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_XIAOFEI_RANK)
	self.reward_list, self.coset_list, self.rank_list, self.fanli_rate = KaifuActivityData.Instance:GetDayConsumeRankRewardInfoListByDay(pass_day + 1)
	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
end

function XiaoFeiRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function XiaoFeiRank:ClickReChange()
	ViewManager.Instance:Open(ViewName.Shop, TabIndex.shop_youhui)
end

function XiaoFeiRank:OnFlush()
	self.player_data_list = KaifuActivityData.Instance:GetDailyXiaoFeiRank()
	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end
	local rank = 0 	--KaifuActivityData.Instance:GetRankLevel()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		for k,v in pairs(self.player_data_list) do
			if v.user_id == role_id then
				rank = k
			end
		end
	if rank and rank <= 50 and rank >= 1 then
		self.node_list["TxtRank"].text.text = rank
	else
		self.node_list["TxtRank"].text.text = Language.Common.NoRank
	end
	
end

function XiaoFeiRank:FlushXiaoFei()
	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end
	local gold = KaifuActivityData.Instance:GetDayConsumeRankInfo() or 0
	self.node_list["TxtXiaoFeiCount"].text.text = CommonDataManager.ConverMoney(gold)
end

function XiaoFeiRank:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" and k ~= "hour" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = ""
	if temp.day > 1 then
		str = string.format(Language.Activity.ActivityTime8, temp.day, temp.hour)
	else
		str = string.format(Language.Activity.ActivityTime9, temp.hour, temp.min, temp.s)
	end
	self.node_list["TxtRestTime"].text.text = str
end

function XiaoFeiRank:GetNumberOfCells()
	return #self.reward_list
end

function XiaoFeiRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = XiaoFeiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	local rank = ""
	local last_rank = self.rank_list[cell_index - 1]
	local current_rank = self.rank_list[cell_index]
	local is_show = false

	if last_rank then
		if current_rank - last_rank == 1 then
			rank = tostring(current_rank)
			is_show = true
		else
			rank = tostring((last_rank + 1) .. "-" .. current_rank)
		end
	else
		if current_rank == 1 then
			rank = 1
			is_show = true
		else
			rank = tostring("0-" .. current_rank)
		end
	end

	contain_cell:SetCostData(self.coset_list[cell_index], rank, self.fanli_rate[cell_index],is_show)
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------XiaoFeiRankCell---------------------------------
XiaoFeiRankCell = XiaoFeiRankCell or BaseClass(BaseCell)

local MAX_REWARD_CELL_NUM = 3

function XiaoFeiRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.item_cell_list = {}
	for i = 1, MAX_REWARD_CELL_NUM do
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.node_list["CellItem_" .. i])
	end
end

function XiaoFeiRankCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function XiaoFeiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function XiaoFeiRankCell:SetItemData(data)
	self.reward_data = data
end

function XiaoFeiRankCell:SetCostData(coset_text, rank, fanli_rate, is_show)
	-- local str_1 = string.format(Language.Activity.XiaoFeiRankTips2, rank,coset_text)
	-- local str_2 = string.format(Language.Activity.ChongZhiRank3, coset_text)
	self.node_list["TxtRankTips"] .text.text = rank
	-- RichTextUtil.ParseRichText(self.node_list["TxtRankTips"].rich_text, str_1, 22)
	self.node_list["TxtRankTips2"] .text.text = coset_text
	self.node_list["Nodeplayerinfo"]:SetActive(is_show)
end

function XiaoFeiRankCell:LoadTextureCallBack(user_id, path)
	if self.player_data == nil then
		return
	end

	if user_id ~= self.player_data.user_id then
		self.node_list["ImgPlayerIcon"]:SetActive(true)
		self.node_list["RawPlayerIcon"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end

	self.node_list["ImgPlayerIcon"]:SetActive(false)
	self.node_list["RawPlayerIcon"]:SetActive(true)

	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawPlayerIcon"].raw_image:LoadURLSprite(path)
	end, 0)
end

function XiaoFeiRankCell:OnFlush()
	-- self.node_list["RawPlayerIcon"].raw_image:LoadURLSprite("")
	for k,v in pairs(self.reward_data.reward_item) do
		if v and self.item_cell_list[k + 1]then
			if self.reward_data.is_specil then
				local split_tbl = Split(self.reward_data.is_specil, ",")
				self.item_cell_list[k + 1]:SetShowOrangeEffect(split_tbl[k + 1] and tonumber(split_tbl[k + 1]) == 1)
			end
			self.item_cell_list[k + 1]:SetData(v)
		end
	end
	--如果没有人上榜
	if not next(self.player_data) then
		self.node_list["TxtPlayerName"].text.text = ""
		self.node_list["Nodeplayerinfo"]:SetActive(false)
		self.node_list["ImgPlayerIcon"]:SetActive(true)
		self.node_list["RawPlayerIcon"]:SetActive(false)
	else
		self.node_list["TxtPlayerName"].text.text = self.player_data.user_name
		if (self.player_data.prof % 10) >= 3 then
			self.player_data.sex = 0
		end
		AvatarManager.Instance:SetAvatar(self.player_data.user_id, self.node_list["RawPlayerIcon"], self.node_list["ImgPlayerIcon"], self.player_data.sex, self.player_data.prof, true)
	end
end