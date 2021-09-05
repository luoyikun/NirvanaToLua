QingYuanContent = QingYuanContent or BaseClass(BaseRender)

local FIX_SHOW_TIME = 8
local FIRST_PAGE_RANK_NUM = 5
local NORMAL_PAGE_RANK_NUM = 6

function QingYuanContent:LoadCallBack()
	for k, v in pairs(COUPLE_RANK_TYPE) do
		RankCtrl.Instance:GetCoupleRankListReq(v)
	end

	self.toggle_cell_list = {}
	self.rank_cell_one_list = {}
	self.rank_cell_first_page_list = {}
	self.rank_cell_two_list = {}
	self.cur_type = 0
	self.cur_page = 1

	self.node_list["Btn_Left"].button:AddClickListener(BindTool.Bind(self.OnUpPage, self))
	self.node_list["Btn_Right"].button:AddClickListener(BindTool.Bind(self.OnDownPage, self))

	local first_list_view_delegate = self.node_list["ListView_first"].list_simple_delegate
	first_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsFirstPage, self)
	first_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellFirstPage, self)

	for i = 1, 3 do
		self.rank_cell_one_list[i] = RankCellOne.New(self.node_list["Rank" .. i])
	end

	local other_list_view_delegate = self.node_list["ListView_other"].list_simple_delegate
	other_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsOtherPage, self)
	other_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellOtherPage, self)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Zhanli"])
end

function QingYuanContent:__delete()
	for k, v in pairs(self.toggle_cell_list) do
		v:DeleteMe()
	end
	self.toggle_cell_list = {}

	for k, v in pairs(self.rank_cell_one_list) do
		v:DeleteMe()
	end
	self.rank_cell_one_list = {}

	for k, v in pairs(self.rank_cell_two_list) do
		v:DeleteMe()
	end
	self.rank_cell_two_list = {}

	for k,v in pairs(self.rank_cell_first_page_list) do
		v:DeleteMe()
	end
	self.rank_cell_first_page_list = {}
	self.fight_text = nil
	if TitleData.Instance ~= nil then
		for i = 0, 2 do
			TitleData.Instance:ReleaseTitleEff(self.node_list["Title" .. i])
		end
	end
end

function QingYuanContent:GetNumberOfCellsOtherPage()
	return NORMAL_PAGE_RANK_NUM
end

function QingYuanContent:RefreshCellOtherPage(cell, cell_index)
	local rank_data_list = RankData.Instance:GetRankListBytype(self.cur_type)
	if nil == rank_data_list then return end

	local rank_cell = self.rank_cell_two_list[cell]
	if nil == rank_cell then
		rank_cell = RankCellTwo.New(cell.gameObject)
		self.rank_cell_two_list[cell] = rank_cell
	end
	local index = cell_index + 1 + (self.cur_page - 2) * NORMAL_PAGE_RANK_NUM + FIRST_PAGE_RANK_NUM
	rank_cell:SetIndex(index)
	rank_cell:SetData(rank_data_list[index])
end

function QingYuanContent:GetNumberOfCellsFirstPage()
	return FIRST_PAGE_RANK_NUM - 3
end

function QingYuanContent:RefreshCellFirstPage(cell, cell_index)
	local rank_data_list = RankData.Instance:GetRankListBytype(self.cur_type)
	if nil == rank_data_list then return end

	local rank_cell = self.rank_cell_first_page_list[cell]
	if nil == rank_cell then
		rank_cell = RankCellTwo.New(cell.gameObject)
		self.rank_cell_first_page_list[cell] = rank_cell
	end
	rank_cell:SetIndex(cell_index + 4)
	rank_cell:SetData(rank_data_list[cell_index + 4])
end

function QingYuanContent:OnItemClick(index)
	self.cur_type = index
	self.cur_page = 1
	local type_to_id = {
		[0] = 1009,
		[1] = 1010,
		[2] = 1011,
	}
	local title_id = type_to_id[self.cur_type]
	local bundle, asset = ResPath.GetTitleIcon(title_id)
	self.node_list["TitleImg"].image:LoadSprite(bundle, asset, function()
			self.node_list["TitleImg"].image:SetNativeSize()
		end)

	for k, v in pairs(type_to_id) do
		self.node_list["Title" .. k]:SetActive(false)
	end
	TitleData.Instance:LoadTitleEff(self.node_list["Title" .. self.cur_type], title_id, true)
	self.node_list["Title" .. self.cur_type]:SetActive(true)

	self.node_list["TxtRankTitle"].text.text = Language.Rank["RankTitleTxt" .. self.cur_type]
	self:FlushRankPage()
end

function QingYuanContent:OnFlush()
	self:FlushRankPage()
end

function QingYuanContent:OnUpPage()
	if self.cur_page <= 1 then
		return
	end
	self.cur_page = self.cur_page - 1
	self:FlushRankPage()
end

function QingYuanContent:OnDownPage()
	local max_page = 1
	local rank_data_list = RankData.Instance:GetRankListBytype(self.cur_type)
	if nil == rank_data_list then return end

	if #rank_data_list > FIRST_PAGE_RANK_NUM then
		max_page = math.ceil((#rank_data_list - FIRST_PAGE_RANK_NUM) / NORMAL_PAGE_RANK_NUM + 1)
	end
	if self.cur_page >= max_page then
		return
	end
	self.cur_page = self.cur_page + 1
	self:FlushRankPage()
end

function QingYuanContent:FlushRankPage()
	self.node_list["FirstPageListView"]:SetActive(1 == self.cur_page)
	self.node_list["OtherRankListView"]:SetActive(1 ~= self.cur_page)

	if 1 == self.cur_page then
		self:FlushFirstPage()
	else
		self:FlushOtherPage()
	end

	local my_rank = 0
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local rank_data_list = RankData.Instance:GetRankListBytype(self.cur_type)
	if nil == rank_data_list then return end
	
	for k,v in pairs(rank_data_list) do
		if v.male_uid == role_id or v.female_uid == role_id then
			my_rank = k
			break
		end
	end
	local max_page = 1
	if #rank_data_list > FIRST_PAGE_RANK_NUM then
		max_page = math.ceil((#rank_data_list - FIRST_PAGE_RANK_NUM) / NORMAL_PAGE_RANK_NUM + 1)
	end
	self.node_list["Txt_rank"].text.text = my_rank ~= 0 and my_rank or Language.Rank.NoInRank
	self.node_list["TxtPage"].text.text = self.cur_page .. "/" .. max_page

	local rank_type = PERSON_RANK_TYPE.PERSON_RANK_TYPE_QINGYUAN
	for k,v in pairs(COUPLE_RANK_TYPE) do
		if v == self.cur_type then
			rank_type = k
		end
	end
	local power = RankData.Instance:GetMyPowerValue(rank_type)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power
	end
end

function QingYuanContent:FlushFirstPage()
	local rank_data_list = RankData.Instance:GetRankListBytype(self.cur_type)
	if not rank_data_list then return end

	self.node_list["ListView_first"].scroller:ReloadData(0)
	for i = 1, 3 do
		self.rank_cell_one_list[i]:SetData(rank_data_list[i])
	end
end

function QingYuanContent:FlushOtherPage()
	self.node_list["ListView_other"].scroller:ReloadData(0)
end


------------------------------
---- 前三名 RankCellOne
RankCellOne = RankCellOne or BaseClass(BaseCell)
function RankCellOne:__init()
	self.node_list["ImgIcon_left"].button:AddClickListener(BindTool.Bind(self.HeadClickLeft, self))
	self.node_list["ImgRaw_left"].button:AddClickListener(BindTool.Bind(self.HeadClickLeft, self))
	self.node_list["ImgIcon_right"].button:AddClickListener(BindTool.Bind(self.HeadClickRight, self))
	self.node_list["ImgRaw_right"].button:AddClickListener(BindTool.Bind(self.HeadClickRight, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtCap"])
end

function RankCellOne:__delete()
	self.fight_text = nil
end

function RankCellOne:OnFlush()
	if self.data then
		local data = self.data
		self.node_list["TxtName_left"].text.text = data.male_name
		self.node_list["TxtName_right"].text.text = data.female_name
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = data.male_rank_value + data.female_rank_value
		end
		self.node_list["ImgIcon_left"].image.enabled = true
		self.node_list["ImgIcon_right"].image.enabled = true
		self.node_list["ImgRaw_right"].raw_image.enabled = true
		self.node_list["ImgRaw_left"].raw_image.enabled = true
		AvatarManager.Instance:SetAvatar(data.male_uid, self.node_list["ImgRaw_left"], self.node_list["ImgIcon_left"], GameEnum.MALE, data.male_prof, false)
		AvatarManager.Instance:SetAvatar(data.female_uid, self.node_list["ImgRaw_right"], self.node_list["ImgIcon_right"], GameEnum.FEMALE, data.female_prof, false)

	else
		self.node_list["TxtName_left"].text.text = ""
		self.node_list["TxtName_right"].text.text = ""
		self.node_list["ImgIcon_left"].image.enabled = false
		self.node_list["ImgIcon_right"].image.enabled = false
		self.node_list["ImgRaw_right"].raw_image.enabled = false
		self.node_list["ImgRaw_left"].raw_image.enabled = false
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = 0
		end
	end
end

function RankCellOne:HeadClickLeft()
	CheckData.Instance:SetCurrentUserId(self.data.male_uid)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.male_uid)
	if self.data.male_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.male_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end

function RankCellOne:HeadClickRight()
	CheckData.Instance:SetCurrentUserId(self.data.female_uid)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.female_uid)
	if self.data.female_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.female_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end


--排行信息
RankCellTwo = RankCellTwo or BaseClass(BaseCell)
function RankCellTwo:__init()
	self.node_list["ImgIconLeft"].button:AddClickListener(BindTool.Bind(self.HeadClickLeft, self))
	self.node_list["RawImageLeft"].button:AddClickListener(BindTool.Bind(self.HeadClickLeft, self))
	self.node_list["ImgIconRight"].button:AddClickListener(BindTool.Bind(self.HeadClickRight, self))
	self.node_list["RawImageRight"].button:AddClickListener(BindTool.Bind(self.HeadClickRight, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Zhanli"])
end

function RankCellTwo:__delete()
	self.fight_text = nil
end

function RankCellTwo:OnFlush()
	if self.data then
		local data = self.data
		self.node_list["NodeIsShow"]:SetActive(true)
		self.node_list["TxtNum"].text.text = self.index
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = data.male_rank_value + data.female_rank_value
		end
		self.node_list["TxtNameLeft"].text.text = data.male_name
		self.node_list["TxtNameRight"].text.text = data.female_name
		AvatarManager.Instance:SetAvatar(data.male_uid, self.node_list["RawImageLeft"], self.node_list["ImgIconLeft"], GameEnum.MALE, data.male_prof, false)
		AvatarManager.Instance:SetAvatar(data.female_uid, self.node_list["RawImageRight"], self.node_list["ImgIconRight"], GameEnum.FEMALE, data.female_prof, false)
	else
		self.node_list["NodeIsShow"]:SetActive(false)
	end
end

function RankCellTwo:HeadClickLeft()
	CheckData.Instance:SetCurrentUserId(self.data.male_uid)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.male_uid)
	if self.data.male_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.male_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end

function RankCellTwo:HeadClickRight()
	CheckData.Instance:SetCurrentUserId(self.data.female_uid)
	CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.female_uid)
	if self.data.female_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.female_name)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
	end
end