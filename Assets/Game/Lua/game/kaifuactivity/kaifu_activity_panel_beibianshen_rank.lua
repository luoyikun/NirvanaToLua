BeiBianShenRank =  BeiBianShenRank or BaseClass(BaseRender)
--别变身排行
function BeiBianShenRank:__init()
	self.contain_cell_list = {}
	local list_delegate = self.node_list["ScrollerListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)

	self.node_list["TxtBeiBianShen"].text.text = KaifuActivityData.Instance:GetSpecialAppearancePassiveRoleChangeTimes()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["CellItem"])

	local item_cell_data = KaifuActivityData.Instance:GetSpecialAppearancePassiveRankJoinRewardCfg()
	self.item_cell:SetData(item_cell_data)
	self.reward_list = KaifuActivityData.Instance:GetSpecialAppearancePassiveRankCfg()

	self.node_list["Help"].button:AddClickListener(BindTool.Bind(self.OpenHelp,self))

	if self.node_list["Title"] and self.reward_list[1] and self.reward_list[1].title_change1 then
		local bundle, asset = ResPath.GetTitleIcon(self.reward_list[1].title_change1)
		self.node_list["Title"].image:LoadSprite(bundle, asset, function()
				self.node_list["Title"].image:SetNativeSize()
			end)
		TitleData.Instance:LoadTitleEff(self.node_list["Title"], self.reward_list[1].title_change1, true)
	end
end

function BeiBianShenRank:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function BeiBianShenRank:OpenCallBack()
end

function BeiBianShenRank:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function BeiBianShenRank:OnFlush()
	local my_rank = 0
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
 	local rank_list = KaifuActivityData.Instance:GetSpecialAppearancePassiveRankList()
	self.node_list["TxtBeiBianShen"].text.text = KaifuActivityData.Instance:GetSpecialAppearancePassiveRoleChangeTimes()
	for k,v in pairs(self.contain_cell_list) do
		v:SetRankData(rank_list)
		if v.item_cell_index and rank_list[v.item_cell_index] and role_id == rank_list[v.item_cell_index].uid then
			my_rank = v.item_cell_index
		end
	end

	self.node_list["TxtMyRank"].text.text = my_rank > 0 and my_rank or Language.Common.NoRank
end

function BeiBianShenRank:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.node_list["TxtRestTime"].text.text = str
end

function BeiBianShenRank:GetNumberOfCells()
	return KaifuActivityData.Instance:GetSpecialAppearancePassiveRankCount() or 0
end

function BeiBianShenRank:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = BeiBianShenRankCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	
	self:OnFlush()
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index].reward_item, cell_index)
end

function BeiBianShenRank:OpenHelp()
	local tips_id = 316
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------BeiBianShenRankCell---------------------------------
BeiBianShenRankCell = BeiBianShenRankCell or BaseClass(BaseCell)

function BeiBianShenRankCell:__init()
	self.item_cell_list = ItemCell.New()
	self.item_cell_list:SetInstanceParent(self.node_list["CellItem"])

	self.show_image = self.node_list["IconImage"]
	self.raw_image_obj = self.node_list["RawImage"]
end

function BeiBianShenRankCell:__delete()
	self.item_cell_list:DeleteMe()
	self.item_cell_list = nil
end

function BeiBianShenRankCell:SetItemData(data, index)
	self.reward_data = data or {}
	self.item_cell_index = index
	self:Flush()
end

function BeiBianShenRankCell:SetRankData(data)
	self.rank_data = data
end

function BeiBianShenRankCell:OnFlush()
	self.item_cell_list:SetData(self.reward_data)
	self.node_list["ImagRankFirst"]:SetActive(false)
	self.node_list["NodeImgLast"]:SetActive(false)

	if self.item_cell_index > 0 and self.item_cell_index <= 3 then
		self.node_list["ImagRankFirst"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(self.item_cell_index)
		self.node_list["ImagRankFirst"].image:LoadSprite(bundle, asset)
	else
		self.node_list["ImagRankFirst"]:SetActive(false)
		self.node_list["NodeImgLast"]:SetActive(true)
		self.node_list["TxtRankNum"].text.text = self.item_cell_index
	end

	self.node_list["TxtPlayername"].text.text = ""
	self.node_list["TxtBianShenCount"].text.text = 0

	self.data = self.rank_data[self.item_cell_index]
	if self.data == nil or next(self.data) == nil then return end
	
	if self.data and self.data.user_name ~= "" and self.data.change_num ~= 0 then
		self.node_list["TxtPlayername"].text.text = self.data.user_name
		self.node_list["TxtBianShenCount"].text.text = self.data.change_num
	end

	local role_id = self.data.uid
	local function download_callback(path)
		if nil == self.raw_image_obj or IsNil(self.raw_image_obj.gameObject) then
			return
		end
		if self.data.uid ~= role_id then
			return
		end
		self.show_image:SetActive(false)
		self.raw_image_obj:SetActive(true)
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.raw_image_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.uid ~= role_id then
				return
			end
		end)
	end
	self.show_image:SetActive(true)
	self.raw_image_obj:SetActive(false)
	CommonDataManager.NewSetAvatar(role_id, self.raw_image_obj, self.show_image, self.raw_image_obj, self.data.sex, self.data.prof, true, download_callback)
end