CombineServerConsubeRank =  CombineServerConsubeRank or BaseClass(BaseRender)

function CombineServerConsubeRank:__init()
	self.contain_cell_list = {}
	RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_DAY_CHONGZHI_NUM)
end

function CombineServerConsubeRank:__delete()
	if self.contain_cell_list then
		for k,v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

end

function CombineServerConsubeRank:ClickReChange()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.Shop)
end

function CombineServerConsubeRank:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)

	self.node_list["TXtNum"].text.text = CommonDataManager.ConverMoney(HefuActivityData.Instance:GetConsumeRankConsumeGold())
	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self.consube_rank_info = HefuActivityData.Instance:GetConsubeRankInfo()

	
end

function CombineServerConsubeRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end


function CombineServerConsubeRank:ShopCloseCallBack()
	--在商店关闭后接受协议

	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
end

function CombineServerConsubeRank:OnFlush()

	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CONSUME_RANK)
	self.consube_rank_info = HefuActivityData.Instance:GetConsubeRankInfo()
	
	if self.node_list["TXtNum"] then
		self.node_list["TXtNum"].text.text = CommonDataManager.ConverMoney(HefuActivityData.Instance:GetConsumeRankConsumeGold())
	end
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	--设置排名
	local rank = HefuActivityData.Instance:GetConsubeRank()
	if rank < 10 and rank > 0 and rank ~= nil then
		self.node_list["TXtChongZhiRankTXt"].text.text = rank
		self.node_list["TXtChongZhiRankTXt"].gameObject:SetActive(true)
		self.node_list["NoRank"].gameObject:SetActive(false)
	else
		self.node_list["TXtChongZhiRankTXt"].gameObject:SetActive(false)
		self.node_list["NoRank"].gameObject:SetActive(true)
	end
	
end

function CombineServerConsubeRank:SetTime(rest_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" then
	-- 		if v < 10 then
	-- 			v = tostring('0'..v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end

	-- if temp.day > 1 then
	-- 	local str = string.format(Language.Activity.ActivityTime6, temp.day, temp.hour)
	-- 	self.node_list["TXtRestTime"].text.text = str
	-- else
	-- 	local str = string.format(Language.Activity.ActivityTime5, temp.hour, temp.min, temp.s)
	-- 	self.node_list["TXtRestTime"].text.text = str
	-- end
	local str = TimeUtil.FormatSecond(rest_time, 13)
	self.node_list["TXtRestTime"].text.text = str
end

function CombineServerConsubeRank:GetNumberOfCells()
	return 3
end

function CombineServerConsubeRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell =CombineServerConsubeRankCell.New(cell.gameObject, self)
		
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetItemData(self.reward_list)
	contain_cell:SetIndex(cell_index)

	contain_cell:SetPlayerData(self.consube_rank_info.user_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CombineServerConsubeRankCell---------------------------------
CombineServerConsubeRankCell = CombineServerConsubeRankCell or BaseClass(BaseCell)

function CombineServerConsubeRankCell:__init()
	self.avatar_key = 0
	self.reward_data = {}

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self.node_list["item_"..i]
		item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
	
end

function CombineServerConsubeRankCell:__delete()

	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CombineServerConsubeRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CombineServerConsubeRankCell:SetItemData(data)
	self.reward_data = data
end

function CombineServerConsubeRankCell:SetIndex(index)
	self.index = index
end



function CombineServerConsubeRankCell:LoadUserCallBack(user_id, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.player_data.role_id then
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(not true)
		return
	end
	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end
	self.node_list["ImgIcon"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(not false)

	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawImage"].raw_image:LoadURLSprite(path)
	end, 0)
end

function CombineServerConsubeRankCell:OnFlush()

	self.node_list["TxtPlayerinfo"].text.text = ""

	local data = self.reward_data["reward_item_" .. self.index]
	local item_list = ItemData.Instance:GetGiftItemList(data.item_id)
	if #item_list == 0 then
		item_list[1] = data
	end

	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end
	
	-- local str = string.format(Language.Activity.XiaoFeiRankTips, self.index, self.reward_data.rank_limit)
	-- local str2 = Language.Activity.ChongZhiRank3--string.format(Language.Activity.ChongZhiRank3)
	-- self.node_list["TxtTitle"].text.text = str
	-- self.node_list["TxtTitle2"].text.text = str2
	self.node_list["RankTxt"].text.text = self.index
	self.node_list["Operate"].text.text = Language.HefuActivity.Consume
	self.node_list["Value"].text.text = self.reward_data.rank_limit

	--self:LoadUserCallBack()
	--如果没有人上榜
	if self.player_data.role_id == 0 then

		self.node_list["TxtPlayerinfo"].text.text = ""

		self.node_list["NodePlayerinfo"]:SetActive(false)

		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(not true)
	else
		self.node_list["TxtPlayerinfo"].text.text = self.player_data.user_name
		if (self.player_data.prof % 10) >= 3 then
			self.player_data.sex = 0
		end
		AvatarManager.Instance:SetAvatar(self.player_data.role_id, self.node_list["RawImage"], self.node_list["ImgIcon"], self.player_data.sex, self.player_data.prof, false)
	end
end