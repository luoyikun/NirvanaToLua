KFPVPViewSeason = KFPVPViewSeason or BaseClass(BaseRender)

function KFPVPViewSeason:__init(instance)
	if instance == nil then
		return
	end
	self.season_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
end

function KFPVPViewSeason:__delete()
	if self.season_list then
		for k,v in pairs(self.season_list) do
			v:DeleteMe()
		end
	end
	self.season_list = {}
end

function KFPVPViewSeason:OpenCallBack()
	self:Flush()
end

function KFPVPViewSeason:OnFlush()
	local kf_info = KuafuPVPData.Instance:GetActivityInfo()
	local count = kf_info.challenge_total_match_count
	local str = ""
	if count >=20 then
		str = "<color='#89f201FF'>"..count.."</color>"
	else
		str = "<color='#f9463bFF'>"..count.."</color>"
	end
	self.node_list["PiPeiTxt"].text.text = string.format(Language.Kuafu1V1.RewardTxt, str)
end


function KFPVPViewSeason:GetNumberOfCells()
	return KuafuPVPData.Instance:GetSeasonRewardCount()
end

function KFPVPViewSeason:CellRefreshDel(cellobj, index)
	local cell = self.season_list[cellobj]
	if cell == nil then
		cell = SeasonItem.New(cellobj.gameObject)
		self.season_list[cellobj] = cell
	end
	cell:SetData(KuafuPVPData.Instance:GetSeasonRewardBySeq(index))

end

-----------------------SeasonItem----------------------
SeasonItem = SeasonItem or BaseClass(BaseCell)

function SeasonItem:__init()

	self.item_list = {}
	self.number_cell = 0

	-- self.node_list["ItemListView"].scroll_rect.horizontal = false
	-- local list_delegate = self.node_list["ItemListView"].list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)

	for i = 1, 6 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["Item" .. i])
		self.item_list[i] = cell
	end
end

function SeasonItem:__delete()
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

-- function SeasonItem:GetNumberOfCells()
-- 	return #self.data.reward_item + 1
-- end

-- function SeasonItem:CellRefreshDel(cellobj,index)
-- 	local cell = self.item_list[cellobj]
-- 	if cell == nil then
-- 		cell = ItemCell.New()
-- 		cell:SetInstanceParent(cellobj.gameObject)
-- 		self.item_list[cellobj] = cell
-- 	end
-- 	cell:SetData(self.data.reward_item[index])

-- end

function SeasonItem:OnFlush()
	-- self.node_list["ItemListView"].scroller:RefreshAndReloadActiveCellViews(true)
	self.node_list["SeasonText"].text.text = self.data.name
	local bundle, asset = ResPath.GetKF1v1RankIcon()
	if self.data.grade <= 3 then
		self.node_list["ImageTab1"]:SetActive(true)
		self.node_list["ImageTab2"]:SetActive(false)
		bundle, asset = ResPath.GetKF1v1RankIcon(self.data.grade)

		self.node_list["Score"].text.text = ""
	else
		self.node_list["ImageTab2"]:SetActive(true)
		self.node_list["ImageTab1"]:SetActive(false)

		self.node_list["Score"]:SetActive(true)
		local info = KuafuPVPData.Instance:GetActivityInfo()
		local my_score = info and info.challenge_score or 0
		local color = TEXT_COLOR.RED
		if my_score > self.data.score then
			color = TEXT_COLOR.GREEN
		end
		local score = self.data.score
		self.node_list["Score"].text.text = ToColorStr(string.format(Language.Kuafu1V1.JiFenTxt, " " .. score), color)
	end
	self.node_list["RankImg"].image:LoadSprite(bundle, asset, function ()
		self.node_list["RankImg"].image:SetNativeSize()
	end)

	for k, v in pairs(self.item_list) do
		if self.data.reward_item[k - 1] then
			self.node_list["Item" .. k]:SetActive(true)
			v:SetData(self.data.reward_item[k - 1])
		else
			self.node_list["Item" .. k]:SetActive(false)
		end
	end
end