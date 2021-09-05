HeFuBossView = HeFuBossView or BaseClass(BaseRender)

local TOGGLE_NUM = 2

function HeFuBossView:__init(instance)
	self.cur_index = false
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickTips, self))

	self.combine_boss_info_view = HeFuBossInfoView.New(self.node_list["BossInfo"])
	
	self.combine_rank = self.node_list["RankInfo"]
	self.combine_rank_info_view = HeFuBossRankView.New(self.node_list["RankInfo"])
	self.node_list["BossInfo"]:SetActive(true)
	self.node_list["RankInfo"]:SetActive(false)
	-- self.node_list["TopToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self))
	self.node_list["BtnBoss"].toggle:AddClickListener(BindTool.Bind(self.OnBoss, self))
	self.node_list["BtnRank"].toggle:AddClickListener(BindTool.Bind(self.OnRank, self))
	-- self:OnClickToggle()
end

function HeFuBossView:__delete()
	if self.combine_boss_info_view then
		self.combine_boss_info_view:DeleteMe()
		self.combine_boss_info_view = nil
	end
	if self.combine_rank_info_view then
		self.combine_rank_info_view:DeleteMe()
		self.combine_rank_info_view = nil
	end

	self.cur_index = true
end

function HeFuBossView:OpenCallBack()
	self:OpenSelectView()
end

function HeFuBossView:OnBoss()
	self.cur_index = false
	self.node_list["BossInfo"]:SetActive(true)
	self.node_list["RankInfo"]:SetActive(false)
	self:OpenSelectView()
end

function HeFuBossView:OnRank()
	self.cur_index = true
	self.node_list["BossInfo"]:SetActive(false)
	self.node_list["RankInfo"]:SetActive(true)
	self:OpenSelectView()
end

function HeFuBossView:OnClickTips()
	TipsCtrl.Instance:ShowHelpTipView(230)
end

function HeFuBossView:OpenSelectView()
	if not self.cur_index and self.combine_boss_info_view then
		self.combine_boss_info_view:OpenCallBack()
	elseif self.combine_rank_info_view then
		self.combine_rank_info_view:OpenCallBack()
	end
end

function HeFuBossView:UpdataView()
	if self.cur_index then
		self:FlushBossList()
	else
		self:FlushBossRank()
	end
end

function HeFuBossView:Flush()
	if not self.cur_index and self.combine_boss_info_view then
		self.combine_boss_info_view:Flush()
	elseif self.combine_rank_info_view then
		self.combine_rank_info_view:Flush()
	end
end

----------------------
HeFuBossInfoView = HeFuBossInfoView or BaseClass(BaseRender)

function HeFuBossInfoView:__init(instance)
	self.red_point_list = {}
	self.node_list["BtnGertReward"].button:AddClickListener(BindTool.Bind(self.OnClickGoToBoss, self))

	self.reward_item_list = {}
	self.cell_list = {}
	self.list_view_delegate = self.node_list["BossItemCellList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)


	self.boss_list = {}
	self:InitShow()
end

function HeFuBossInfoView:__delete()
	for k, v in pairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}
	self.boss_list = {}

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function HeFuBossInfoView:GetNumberOfCells()
	return #self.boss_list or 0
end

function HeFuBossInfoView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = ConbineServerBossCell.New(cell.gameObject)
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_list[data_index])
end

function HeFuBossInfoView:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
	self:Flush()
end
local boss_item_num = 5
function HeFuBossInfoView:InitShow()
	self.reward_item_list = {}
	for i = 1, boss_item_num do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["ItemCell".. i])
	end

end

function HeFuBossInfoView:FlushBossList()
	local refresh_state = HefuActivityData.Instance:GetRefreshState()
	if refresh_state == 0 then
		self.node_list["TitleText"].text.text = Language.HefuActivity.RiChangBoss
		self.boss_list = HefuActivityData.Instance:GetCombineServerBossCfg()
	elseif refresh_state == 1 then
		self.node_list["TitleText"].text.text = Language.HefuActivity.HuoDongBoss
		self.boss_list = HefuActivityData.Instance:GetActivityCombineServerBossCfg()
	end

	self.node_list["BossItemCellList"].scroller:RefreshAndReloadActiveCellViews(true)
	self:SetRewardItemData()
end

function HeFuBossInfoView:OnClickBossItem(index)
	if not index then return end

	for k, v in pairs(self.boss_list) do
		if k == index then
			TipsCtrl.Instance:ShowBossInfoView(v.id)
			return
		end
	end
end

function HeFuBossInfoView:SetRewardItemData()
	local item_list = HefuActivityData.Instance:GetCombineServerBossItemList()
	for i = 1, boss_item_num do
		self.reward_item_list[i]:SetData(item_list[i])
	end
end

function HeFuBossInfoView:OnClickGoToBoss()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ENTER)
end

function HeFuBossInfoView:OnFlush()
	self:FlushBossList()
end


ConbineServerBossCell = ConbineServerBossCell or BaseClass(BaseCell)

function ConbineServerBossCell:__init(instance)

end

function ConbineServerBossCell:__delete()

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
	end
	self.count_down = nil
end

function ConbineServerBossCell:OnFlush()
	if self.data == nil then
		return
	end

	local refresh_state = HefuActivityData.Instance:GetRefreshState()
	local bundle, asset = ResPath.GetBossIcon(self.data.headid)
	self.node_list["ImgBoosIcon"].image:LoadSprite(bundle, asset)
	self.node_list["TXtBoosName"].text.text = self.data.name
	local str = self.data.next_refresh_time == 0 and Language.Boss.HasRefresh or TimeUtil.FormatSecond(self.data.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if refresh_state == 1 and self.data.next_refresh_time == 1 then
		str = Language.Boss.DaiShuaXin
	end
	local color = self.data.next_refresh_time == 0 and "#00EA00FF" or CHAT_TEXT_COLOR.RAND_RED
	self.node_list["TXtBoosTime"].text.text = "<color=" .. color ..">" .. str .. "</color>"

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down == nil and refresh_state == 0 then
		local total_time = self.data.next_refresh_time - TimeCtrl.Instance:GetServerTime()
		if total_time > 0 then
			self.count_down = CountDown.Instance:AddCountDown(total_time, 1, BindTool.Bind(self.SetTime, self, k))
		else
			self.node_list["TXtBoosTime"].text.text = "<color=#00EA00FF>" .. Language.Boss.HasRefresh .. "</color>"
		end
	end
end

function ConbineServerBossCell:SetTime(k, elapse_time, total_time)
	if elapse_time >= total_time then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.node_list["TXtBoosTime"].text.text = "<color=#00EA00FF>" .. Language.Boss.HasRefresh .. "</color>"
		return
	end
	local left_time = math.floor(total_time - elapse_time)
	local time_str = TimeUtil.FormatSecond(left_time)
	self.node_list["TXtBoosTime"].text.text = "<color=#fb1212ff>" .. time_str .. "</color>"
end


--------------------------rank------------
HeFuBossRankView = HeFuBossRankView or BaseClass(BaseRender)
local rank_gift_num = 5
function HeFuBossRankView:__init(instance)
	self.cell_list = {}
	self.index = 0
	self.str = ""

	local list_delegate = self.node_list["PersonList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPersonCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshPersonCell, self)
	self.node_list["PersonList"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	local list_delegate = self.node_list["GroupList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfPersonCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshGroupCell, self)
	self.node_list["GroupList"].scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.reward_item_list = {}
	for i = 1, rank_gift_num do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["ItemCell"..i])
	end

	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()
	self.guild_rank = HefuActivityData.Instance:GetCombineServerBossGuildRank()
	
	self:SetRewardItemData()
end

function HeFuBossRankView:__delete()
	self.person_rank_list = nil
	self.guild_rank = nil


	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for k,v in pairs(self.reward_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_item_list = nil
end
function HeFuBossRankView:OpenCallBack()
	self:Flush()
end

local rank_item_num = 10
function HeFuBossRankView:GetNumberOfPersonCells()
	return rank_item_num
end

function HeFuBossRankView:RefreshPersonCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.node_list["PersonList"].toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "person")
	the_cell:SetData(self.person_rank_list[cell_index])
	the_cell:SetHighLigh(cell_index == self.index and self.str == "person")
	the_cell:Flush()
	self.is_cell_active = true
end

function HeFuBossRankView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_cell_active and self.jump_flag == true then
		self:CheckToJump()
	end
end

function HeFuBossRankView:FlushSelfRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local guild_id = main_role_vo.guild_id

	self.node_list["TXtName2"].text.text = guild_id > 0 and main_role_vo.guild_name or Language.Common.No
	self.node_list["TxtNumber"].text.text = string.format("%s", HefuActivityData.Instance:GetCombineServerBossGuildKill())
	if guild_id > 0 then
		local rank = 0
		for k,v in pairs(self.guild_rank) do
			if v and v.id == main_role_vo.guild_id then
				rank = k
				break
			end
		end
		if 0 < rank and rank <= 3 then
			self.node_list["ImgRankInfo2"]:SetActive(true)
			self.node_list["NodeRankInfo2"]:SetActive(false)
			self.node_list["ImgRankInfo2"].image:LoadSprite(ResPath.GetRankIcon(rank))
		elseif 0 <= rank then
			self.node_list["ImgRankInfo2"]:SetActive(false)
			self.node_list["NodeRankInfo2"]:SetActive(true)
			self.node_list["TXtInfo2"].text.text = string.format(Language.Common.NumToChs[1])
		else
			self.node_list["ImgRankInfo2"]:SetActive(false)
			self.node_list["NodeRankInfo2"]:SetActive(true)
			self.node_list["TXtInfo2"].text.text = rank
		end
	else
		self.node_list["ImgRankInfo2"]:SetActive(false)
		self.node_list["NodeRankInfo2"]:SetActive(true)
		self.node_list["TXtInfo2"].text.text = string.format(Language.Common.NumToChs[1])
	end

	self.node_list["TXtName"].text.text = main_role_vo.name
	self.node_list["TxtTextFrame"].text.text = string.format("%s", HefuActivityData.Instance:GetCombineServerBossPersonKill())
	local person_rank = 0
	for k,v in pairs(self.person_rank_list) do
		if v and v.id == main_role_vo.role_id then
			person_rank = k
			break
		end
	end
	if 0 < person_rank and person_rank <= 3 then
		self.node_list["ImgRankInfo1"]:SetActive(true)
		self.node_list["NodeRankInfo1"]:SetActive(false)
		self.node_list["ImgRankInfo1"].image:LoadSprite(ResPath.GetRankIcon(person_rank))
	elseif 3 < person_rank and person_rank <= 10 then
		sself.node_list["ImgRankInfo1"]:SetActive(false)
		self.node_list["NodeRankInfo1"]:SetActive(true)
		self.node_list["TXtRankImage2"].text.text = person_rank
	else
		self.node_list["ImgRankInfo1"]:SetActive(false)
		self.node_list["NodeRankInfo1"]:SetActive(true)
		self.node_list["TXtRankImage2"].text.text = Language.Common.NumToChs[1]
	end
end

function HeFuBossRankView:RefreshGroupCell(cell, cell_index)
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = CombineServerRankItem.New(cell.gameObject,self)
		the_cell:SetToggleGroup(self.node_list["GroupList"].toggle_group)
		self.cell_list[cell] = the_cell
	end
	cell_index = cell_index + 1
	the_cell:SetIndex(cell_index, "guild")

	the_cell:SetData(self.guild_rank[cell_index])
	the_cell:Flush()
	the_cell:SetHighLigh(cell_index == self.index and self.str == "guild")
	self.is_cell_active = true
end

function HeFuBossRankView:SetRewardItemData()
	local gift_list = HefuActivityData.Instance:GetCombineServerBossRankGiftList()
	for i = 1, rank_gift_num do
		self.reward_item_list[i]:SetData(gift_list[i])
	end
end

function HeFuBossRankView:OnFlush()
	self.person_rank_list = HefuActivityData.Instance:GetCombineServerBossPersonRank()
	self.guild_rank = HefuActivityData.Instance:GetCombineServerBossGuildRank()
	self:FlushSelfRank()
end

function HeFuBossRankView:SetCurIndex(index, str)
	self.index = index
	self.str = str
end

function HeFuBossRankView:SetHighLighFalse()
	for k,v in pairs(self.cell_list) do
		v:SetHighLigh(false)
	end
end

---------------
CombineServerRankItem = CombineServerRankItem  or BaseClass(BaseCell)

function CombineServerRankItem:__init(instance, parent)
	self.parent = parent
	self.rank = -1
	self.str = ""
	self.node_list["RankItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.OnItemClick, self))
	self.show_img_list = {}
	for i = 1, 2 do
		self.show_img_list[i] = self.node_list["ImgRank" .. i]
	end

end

function CombineServerRankItem:__delete()
	self.parent = nil
	self.show_img_list = {}
	self.rank = -1

end

function CombineServerRankItem:OnFlush()
	self:FlushName()
end

function CombineServerRankItem:SetHighLigh(show_hl)
	self.node_list["ImgHighLight"]:SetActive(show_hl)
end

function CombineServerRankItem:SetIndex(cell_index, str)
	self.rank = cell_index
	self.str = str
end

function CombineServerRankItem:SetData(data)
	self.data = data
end

function CombineServerRankItem:FlushName()
	if self.index == -1 or not self.data then return end

	if self.rank <= 3 then
		self.show_img_list[1]:SetActive(true)
		self.show_img_list[2]:SetActive(false)
		local bundle, asset = ResPath.GetRankIcon(self.rank)
		local bundle1, asset1 = ResPath.GetRankBgIcon(self.rank)
		self.node_list["ImgRank1"].image:LoadSprite(bundle, asset)
		self.node_list["RankBg"].image:LoadSprite(bundle1, asset1, function()
			self.node_list["RankBg"]:SetActive(true)
		end)
	else
		self.node_list["RankBg"]:SetActive(false)
		self.node_list["TxtRank"].text.text = self.rank
		self.show_img_list[1]:SetActive(false)
		self.show_img_list[2]:SetActive(true)
	end
	self.node_list["TxtName"].text.text = self.data.name ~= "" and self.data.name or Language.Competition.NoRank
	self.node_list["TxtFrame"].text.text = string.format("%s", self.data.rank_value)
end

function CombineServerRankItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function CombineServerRankItem:OnItemClick(is_click)
	if is_click then
		self.parent:SetHighLighFalse()
		self.node_list["ImgHighLight"]:SetActive(true)
		self.parent:SetCurIndex(self.rank, self.str)
	end
end