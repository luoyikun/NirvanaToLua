KuaFu1v1ViewSeason = KuaFu1v1ViewSeason or BaseClass(BaseRender)

function KuaFu1v1ViewSeason:__init(instance)
	if instance == nil then
		return
	end
	self.season_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells,self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel,self)
end

function KuaFu1v1ViewSeason:__delete()
	if self.season_list then
		for k,v in pairs(self.season_list) do
			v:DeleteMe()
		end
	end
	self.season_list = {}
end

function KuaFu1v1ViewSeason:OpenCallBack()
	self:Flush()
end

function KuaFu1v1ViewSeason:OnFlush()
	local count = KuaFu1v1Data.Instance:GetSeasonJoinCount()
	local str = ""
	if count >=20 then
		str = "<color='#89f201FF'>"..count.."</color>"
	else
		str = "<color='#f9463bFF'>"..count.."</color>"
	end
	self.node_list["PiPeiTxt"].text.text = string.format(Language.Kuafu1V1.RewardTxt, str)
end


function KuaFu1v1ViewSeason:GetNumberOfCells()
	return KuaFu1v1Data.Instance:GetSeasonRewardCount()
end

function KuaFu1v1ViewSeason:CellRefreshDel(cellobj, index)
	local cell = self.season_list[cellobj]
	if cell == nil then
		cell = SeasonOneVOneItem.New(cellobj.gameObject)
		self.season_list[cellobj] = cell
	end
	cell:SetData(KuaFu1v1Data.Instance:GetSeasonRewardBySeq(index))

end

-----------------------SeasonOneVOneItem----------------------
SeasonOneVOneItem = SeasonOneVOneItem or BaseClass(BaseCell)

function SeasonOneVOneItem:__init()

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

function SeasonOneVOneItem:__delete()
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

-- function SeasonOneVOneItem:GetNumberOfCells()

-- 	return #self.data.reward_item + 1
-- end

-- function SeasonOneVOneItem:CellRefreshDel(cellobj,index)
-- 	local cell = self.item_list[cellobj]
-- 	if cell == nil then
-- 		cell = ItemCell.New()
-- 		cell:SetInstanceParent(cellobj.gameObject)
-- 		self.item_list[cellobj] = cell
-- 	end
-- 	cell:SetData(self.data.reward_item[index])

-- end

function SeasonOneVOneItem:OnFlush()
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
		local info = KuaFu1v1Data.Instance:GetRoleData()
		local my_score = info and info.cross_score_1v1 or 0
		local color = TEXT_COLOR.RED
		if my_score > self.data.score then
			color = TEXT_COLOR.GREEN
		end
		local score = ToColorStr(self.data.score, color)
		-- self.node_list["Score"].text.text = string.format(Language.Kuafu1V1.JiFenTxt, " " .. score)
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