CombineServerChongZhiRank =  CombineServerChongZhiRank or BaseClass(BaseRender)

function CombineServerChongZhiRank:__init()
	self.contain_cell_list = {}
end

function CombineServerChongZhiRank:__delete()
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

function CombineServerChongZhiRank:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_INVALID)
	RemindManager.Instance:SetRemindToday(RemindName.ChongZhiRank)

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)

	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.ClickReChange, self))

	self.node_list["Txt11"].text.text = CommonDataManager.ConverMoney(HefuActivityData.Instance:GetChongZhiRankNum())

	local rank = HefuActivityData.Instance:GetChongZhiRank()
	if rank < 10 and rank > 0 and rank ~= nil then
		self.node_list["TxtRank"].text.text = rank
		self.node_list["TxtRank"].gameObject:SetActive(true)
		self.node_list["NoRank"].gameObject:SetActive(false)
	else
		self.node_list["TxtRank"].gameObject:SetActive(false)
		self.node_list["NoRank"].gameObject:SetActive(true)
	end

	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	self.chong_zhi_rank_info = HefuActivityData.Instance:GetChongZhiRankInfo()
	
end

function CombineServerChongZhiRank:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

function CombineServerChongZhiRank:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function CombineServerChongZhiRank:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetRankRewardCfgBySubType(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_CHONGZHI_RANK)
	self.chong_zhi_rank_info = HefuActivityData.Instance:GetChongZhiRankInfo()
	if self.node_list["ListView"] then
		self.node_list["ListView"].scroller:ReloadData(0)
	end
	if self.node_list["Txt11"] then
		self.node_list["Txt11"].text.text = CommonDataManager.ConverMoney(HefuActivityData.Instance:GetChongZhiRankNum())
	end

	local rank = HefuActivityData.Instance:GetChongZhiRank()
	if rank < 10 and rank > 0 and rank ~= nil then
		self.node_list["TxtRank"].text.text = rank
	else
		self.node_list["TxtRank"].text.text = Language.Common.NoRank
	end
end

function CombineServerChongZhiRank:SetTime(rest_time)
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
	-- 	self.node_list["TXt1"].text.text = str
	-- else
	-- 	local str = string.format(Language.Activity.ActivityTime5, temp.hour, temp.min, temp.s)
	-- 	self.node_list["TXt1"].text.text = str
	-- end
	local str = TimeUtil.FormatSecond(rest_time, 13)
	self.node_list["TXt1"].text.text = str
end

function CombineServerChongZhiRank:GetNumberOfCells()
	return  3
end

function CombineServerChongZhiRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell =CombineServerChongZhiRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetItemData(self.reward_list)

	contain_cell:SetPlayerData(self.chong_zhi_rank_info.user_list[cell_index]  or {})
	contain_cell:Flush()
end

----------------------------CombineServerChongZhiRankCell---------------------------------
CombineServerChongZhiRankCell = CombineServerChongZhiRankCell or BaseClass(BaseCell)

function CombineServerChongZhiRankCell:__init()
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

function CombineServerChongZhiRankCell:__delete()

	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

end

function CombineServerChongZhiRankCell:SetPlayerData(playerdata)
	self.player_data = playerdata
end

function CombineServerChongZhiRankCell:SetItemData(data)
	self.reward_data = data
end

function CombineServerChongZhiRankCell:SetIndex(index)
	self.index = index
end


function CombineServerChongZhiRankCell:LoadUserCallBack(user_id, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.player_data.role_id then
		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(user_id, false)
	end
	self.node_list["ImgIcon"]:SetActive(false)
	self.node_list["RawImage"]:SetActive(true)

	GlobalTimerQuest:AddDelayTimer(function()
		self.node_list["RawImage"].raw_image:LoadURLSprite(path)
		
	end, 0)
end

function CombineServerChongZhiRankCell:OnFlush()

	-- self.node_list["RawImage"].raw_image:LoadURLSprite("")
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

	-- local str = string.format(Language.Activity.ChongZhiRank, self.index, self.reward_data.rank_limit)
	-- local str2 = Language.Activity.ChongZhiRank3--string.format(Language.Activity.ChongZhiRank3)
	self.node_list["RankTxt"].text.text = self.index
	self.node_list["Operate"].text.text = Language.HefuActivity.Recharge
	self.node_list["Value"].text.text = self.reward_data.rank_limit
	-- self.node_list["TxtTitle"].text.text = str
	-- self.node_list["TxtTitle2"].text.text = str2
	--如果没有人上榜
	if self.player_data.role_id == 0 then

		self.node_list["TxtPlayerinfo"].text.text = ""

		self.node_list["NodePlayerinfo"]:SetActive(false)

		self.node_list["ImgIcon"]:SetActive(true)
		self.node_list["RawImage"]:SetActive(false)
	else

		self.node_list["TxtPlayerinfo"].text.text = self.player_data.user_name
		local base_prof = PlayerData.Instance:GetRoleBaseProf(self.player_data.prof)
		if base_prof >= 3 then
			self.player_data.sex = 0
		end
		AvatarManager.Instance:SetAvatar(self.player_data.role_id, self.node_list["RawImage"], self.node_list["ImgIcon"], self.player_data.sex, self.player_data.prof, false)
	end

end