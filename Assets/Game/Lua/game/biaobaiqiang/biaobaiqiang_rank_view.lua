BiaoBaiRankView = BiaoBaiRankView or BaseClass(BaseView)

function BiaoBaiRankView:__init()
	self.ui_config = {
		{"uis/views/biaobaiqiangview_prefab", "BiaoBaiRankView"},
		{"uis/views/biaobaiqiangview_prefab", "BiaoBaiQiangView_2"},
	}
	self.full_screen = true
end

function BiaoBaiRankView:LoadCallBack()
	self.select_index = 1
	self.cell_list = {}
	for i=1,2 do
		self.node_list["TabButton".. i].toggle:AddValueChangedListener(BindTool.Bind(self.ClickTab, self, i))
		local list_delegate = self.node_list["List" .. i].list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	end
	self.my_cell = BiaoBaiRankItem.New(self.node_list["MySelf"])

	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.ClickBiaoBai, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.Help, self))

	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisPlay"].ui3d_display,MODEL_CAMERA_TYPE.BASE)

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"])

	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
end

function BiaoBaiRankView:Help()
	local tips_id = 301
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BiaoBaiRankView:ClickTab(i, state)
	self.select_index = i
	if state then
		for i1 =1,2 do
			self.node_list["Panel".. i1]:SetActive(i1 == i)
		end
		self:FlushRankInfo()
		self:Flush()
	end
end

function BiaoBaiRankView:OpenCallBack()
	self:FlushRankInfo()
	self:Flush()
end

function BiaoBaiRankView:OnRoleDragSelf(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function BiaoBaiRankView:FlushRankInfo()
	if self.select_index == 1 then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_MALE)						-- 表白排行男榜
	else
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_FEMALE)
	end
end

function BiaoBaiRankView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	if self.my_cell then
		self.my_cell:DeleteMe()
		self.my_cell = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.fight_text = nil
end

function BiaoBaiRankView:ClickBiaoBai()
	BiaoBaiQiangCtrl.Instance:OpenTips()
end

function BiaoBaiRankView:GetNumberOfCells()
	local  nums = {
		[1] = #BiaoBaiQiangData.Instance:GetMaleRankInfo(),
		[2] = #BiaoBaiQiangData.Instance:GetFemaleRankInfo(),
	}
	return math.max(nums[self.select_index], 10)
end

function BiaoBaiRankView:RefreshCell(cell, index)
	index = index + 1

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = BiaoBaiRankItem.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClickItem, self))
		self.cell_list[cell] = item_cell
	end
	local data = {
		[1] = BiaoBaiQiangData.Instance:GetMaleRankInfo()[index],
		[2] = BiaoBaiQiangData.Instance:GetFemaleRankInfo()[index],
	}

	item_cell:SetIndex(index)
	item_cell:SetCurrent(self.select_index)
	item_cell:SetData(data[self.select_index])
end

function BiaoBaiRankView:ClickItem(cell)
	local data = cell:GetData()
	if not data then
		return
	end
	-- local cur_int = BiaoBaiQiangData.Instance:GetCurIndex()
	-- for _,v in pairs(self.cell_list) do
	-- 	v:SetHighLight(cur_int == v.index)
	-- end
	if self.select_index == 1 then
		self.node_list["List1"].scroller:RefreshAndReloadActiveCellViews(false)
	elseif self.select_index == 2 then
		self.node_list["List2"].scroller:RefreshAndReloadActiveCellViews(false)
	end
end

function BiaoBaiRankView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end

	if self.select_index == 1 then
		self.node_list["List1"].scroller:RefreshAndReloadActiveCellViews(false)
	elseif self.select_index == 2 then
		self.node_list["List2"].scroller:RefreshAndReloadActiveCellViews(false)
	end

	self.my_cell:FlushMySelf()

	local item_id = BiaoBaiQiangData.Instance:GetShowItem()
	if item_id then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local sex_select = {
			[0] = 2,
			[1] = 1,
		}

		if self.select_index ~= sex_select[vo.sex] then
			local first_role = BiaoBaiQiangData.Instance:GetRankFirst(self.select_index)
			if first_role then
				vo = first_role
			else
				local sex = vo.sex == 0 and 1 or 0
				local prof = vo.sex == 0 and 1 or 3
				vo = {sex = sex, prof = prof}
			end
		end
		local res_id = FashionData.GetFashionResByItemId(item_id, vo.sex, (vo.prof % 10))
		local fashion_cfg = FashionData.Instance:GetFashionCfg(item_id)
		local attr_cfg = FashionData.Instance:GetShizhuangSpecialImgUpgradeById(fashion_cfg.image_id, 1)
		local fashion_power = CommonDataManager.GetCapabilityCalculation(attr_cfg)
		self.model:SetRoleResid(res_id)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = fashion_power
		end
	end
end

function BiaoBaiRankView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local str = ""
	if time > 3600 * 24 then
		str = ("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 6) .. "</color>")
	elseif time > 3600 then
		str = ("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 1) .. "</color>")
	else
		str = ("<color='#00ff00'>" .. TimeUtil.FormatSecond(time, 2) .. "</color>")
	end
	self.node_list["Time"].text.text = string.format(Language.BiaoBai.RankClose, str)
end

BiaoBaiRankItem = BiaoBaiRankItem or BaseClass(BaseCell)
function BiaoBaiRankItem:__init()
	self.current = 1
	self.cur_int = 0

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	if self.node_list["ItemCell"] then
		self.node_list["ItemCell"].button:AddClickListener(BindTool.Bind(self.HeadClick, self))
		-- self.node_list["Icon"].button:AddClickListener(BindTool.Bind(self.HeadClick, self, true))
	end	
end

function BiaoBaiRankItem:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end

-- function BiaoBaiRankItem:SetToggleGroup(toggle_group)
-- 	if self.node_list["ItemCell"] then
-- 		self.node_list["ItemCell"].toggle.group = toggle_group
-- 	end
-- end

function BiaoBaiRankItem:SetCurrent(index)
	self.current = index
end

function BiaoBaiRankItem:OnFlush()
	-- if self.data == nil then return end
	if self.data then
		self.node_list["Name"].text.text = self.data.user_name
		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, self.data.rank_value)
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, self.data.flexible_ll)
	else
		self.node_list["Name"].text.text = Language.BiaoBai.NoRank
		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, 0)
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, 0)
	end
	if self.index <= 3 then
		self.node_list["ImgRank1"]:SetActive(true)
		self.node_list["ImgRank2"]:SetActive(false)
		local bundle, asset = ResPath.GetBiaoBaiRankImg("rank_" .. self.index)
		self.node_list["ImgImage"].image:LoadSprite(bundle, asset .. ".png")
	else
		self.node_list["TxtNum"].text.text = self.index
		self.node_list["ImgRank1"]:SetActive(false)
		self.node_list["ImgRank2"]:SetActive(true)
	end

	local cur_int = BiaoBaiQiangData.Instance:GetCurIndex()
	self:SetHighLight(self.index == cur_int)
	self:SetHead()

	local cfg = BiaoBaiQiangData.Instance:GetRankCfg()
	if next(cfg) then
		self.node_list["Item"]:SetActive(true)
		for i,v in ipairs(cfg) do
			if self.index - 1 <= v.rank_index then
				self.item:SetData(v.reward_item)
				break
			end
			-- self.node_list["Item"]:SetActive(false)
		end
	else
		self.node_list["Item"]:SetActive(false)
	end
end

function BiaoBaiRankItem:SetHead()
	self.node_list["IconBtn"]:SetActive(false)
	self.node_list["RawImageBtn"]:SetActive(false)
	local user_id = 0
	local avatar_key_big = 0
	local avatar_key_small = 0
	local prof = 0
	local sex = 0
	if self.data then
	user_id = self.data.user_id
	user_name = self.data.user_name
	avatar_key_big = self.data.avatar_key_big
	avatar_key_small = self.data.avatar_key_small
	prof = self.data.prof
	sex = self.data.sex
	else
		user_id = 0
		avatar_key_big = 0
		avatar_key_small = 0
		if self.current == 1 then
			prof = 1
			sex = 1
		else
			prof = 4
			sex = 0
		end
	end
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImageBtn"], self.node_list["IconBtn"], sex, prof, false)
end

function BiaoBaiRankItem:FlushMySelf()
	local info = BiaoBaiQiangData.Instance:GetMyRankInfo()
	if not info then return end

	self.index = info.rank
	local game_role = GameVoManager.Instance:GetMainRoleVo()
	self.data = {
		user_name = game_role.role_name,
		rank_value = info.ra_profess_score,
		flexible_ll = info.ra_profess_to_num + info.ra_profess_from_num,
		user_id = game_role.role_id,
		avatar_key_big = game_role.avatar_key_big,
		avatar_key_small = game_role.avatar_key_small,
		prof = game_role.prof,
		sex = game_role.sex,
	}
	if info.rank == 0 then
		self.node_list["ImgRank1"]:SetActive(false)
		self.node_list["ImgRank2"]:SetActive(false)
		self.node_list["Item"]:SetActive(false)
		self.node_list["ImgRank"]:SetActive(true)
		self.node_list["Name"].text.text = game_role.role_name
		self:SetHead()

		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, info.ra_profess_score)
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, info.ra_profess_to_num + info.ra_profess_from_num)
	else
		self.node_list["ImgRank"]:SetActive(false)
		self:Flush()
	end
end

function BiaoBaiRankItem:HeadClick(state)
	if not self.data then return end
	BiaoBaiQiangData.Instance:SetCurrent(self.index)
	if self.data.user_id ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		CheckData.Instance:SetCurrentUserId(self.data.user_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.data.user_id)
		ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, self.data.user_name, nil, nil, BindTool.Bind(self.CloseBtnCallBack, self))
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.CanNoyCheckSelf)
		return
	end
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function BiaoBaiRankItem:CloseBtnCallBack()
	local hl_user_id = CheckData.Instance:GetCurrentHLUserId()
	if hl_user_id then
		CheckData.Instance:SetCurrentUserId(hl_user_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(hl_user_id)
	end
end

function BiaoBaiRankItem:SetHighLight(is_hl)
	if self.node_list["ImgHighLight"] then
		self.node_list["ImgHighLight"]:SetActive(is_hl)
	end
end