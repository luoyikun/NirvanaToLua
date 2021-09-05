CongZhiRank =  CongZhiRank or BaseClass(BaseRender)
--每日充值排行 DayChongZhiRank
function CongZhiRank:__init()
	self.contain_cell_list = {}

end

function CongZhiRank:__delete()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
end

function CongZhiRank:LoadCallBack()
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function CongZhiRank:OpenCallBack()
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)

	self.node_list["BtnReCharge"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	local num = KaifuActivityData.Instance:GetDayChongZhiCount() or 0
	
	self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(num)

	local opengameday = TimeCtrl.Instance:GetCurOpenServerDay()
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local pass_day = ActivityData.Instance:GetActDayPassFromStart(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_CHONGZHI_RANK)
	self.reward_list, self.coset_list, self.rank_list = KaifuActivityData.Instance:GetDayChongZhiRankInfoListByDay(pass_day + 1, opengameday)
end

function CongZhiRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function CongZhiRank:ClickReChange()

	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CongZhiRank:OnFlush()
	local rank = KaifuActivityData.Instance:GetRank()
	self.node_list["ScrollerListView"].scroller:ReloadData(0)
	if rank and rank <= 50 and rank >= 1 then
		self.node_list["TxtRankLevel"].text.text = rank
	else
		self.node_list["TxtRankLevel"].text.text = Language.Common.NoRank
	end
end

function CongZhiRank:FlushChongZhi()
	if self.node_list["ScrollerListView"] then
		self.node_list["ScrollerListView"].scroller:ReloadData(0)
	end

	if self.node_list["TxtChongZhiCount"] then
		self.node_list["TxtChongZhiCount"].text.text = CommonDataManager.ConverMoney(KaifuActivityData.Instance:GetDayChongZhiCount() or 0)
	end
end

function CongZhiRank:SetTime(rest_time)
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
	self.node_list["TxtLastTime"].text.text = str
end

function CongZhiRank:GetNumberOfCells()
	return #self.reward_list
end

function CongZhiRank:RefreshCell(cell, cell_index)
	self.player_data_list = KaifuActivityData.Instance:GetDailyChongZhiRank()
	if nil == self.player_data_list then
		return
	end
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = CongZhiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetItemData(self.reward_list[cell_index])

	local rank = ""
	local last_rank = self.rank_list[cell_index - 1]
	local current_rank = self.rank_list[cell_index]
	local is_show = false

	if last_rank then
		if  current_rank - last_rank == 1 then
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
	contain_cell:SetCostData(self.coset_list[cell_index], rank, is_show)
	contain_cell:SetPlayerData(self.player_data_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CongZhiRankCell---------------------------------
CongZhiRankCell = CongZhiRankCell or BaseClass(BaseCell)

local MAX_CELL_NUM = 3

function CongZhiRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}
	self.item_cell_list = {}
	for i = 1, MAX_CELL_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["CellItem_" .. i])
	end
end

function CongZhiRankCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CongZhiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CongZhiRankCell:SetItemData(data)
	self.reward_data = data
end

function CongZhiRankCell:SetCostData(coset_text, rank, is_show)
	-- local str_1 = string.format(Language.Activity.ChongZhiRank2, rank,coset_text)
	-- local str_2 = string.format(Language.Activity.ChongZhiRank3, coset_text)
	-- RichTextUtil.ParseRichText(self.node_list["TxtTitleTips"].rich_text, str_1, 22)
	-- RichTextUtil.ParseRichText(self.node_list["TxtTitleTips2"].rich_text, str_2)
	self.node_list["TxtTitleTips"].text.text = rank
	self.node_list["TxtTitleTips2"].text.text = coset_text
	self.node_list["Nodeplayerinfo"]:SetActive(is_show)
end

function CongZhiRankCell:LoadUserCallBack(user_id, path)
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

function CongZhiRankCell:OnFlush()
	for k,v in pairs(self.reward_data.reward_item) do
		if v and self.item_cell_list[k + 1] then
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
		if self.player_data and self.player_data.prof and (self.player_data.prof % 10) >= 3 then
			self.player_data.sex = 0
		end
		AvatarManager.Instance:SetAvatar(self.player_data.user_id, self.node_list["RawPlayerIcon"], self.node_list["ImgPlayerIcon"], self.player_data.sex, self.player_data.prof, false)
	end
end