BiaoBaiQiangView = BiaoBaiQiangView or BaseClass(BaseView)

function BiaoBaiQiangView:__init()
	self.ui_config = {
		{"uis/views/biaobaiqiangview_prefab", "BiaoBaiQiangView_1"},
		{"uis/views/biaobaiqiangview_prefab", "BiaoBaiQiangView_2"},
	}
	self.full_screen = true
	self.play_audio = true
end

function BiaoBaiQiangView:LoadCallBack()
	self.select_index = BiaoBaiQiangData.Instance:GetSelectindex()
	self.cell_list = {}
	self.ranl_cell_list = {}
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end

	for i=1,3 do
		self.node_list["TabButton".. i].toggle:AddValueChangedListener(BindTool.Bind(self.ClickTab, self, i))
		local list_delegate = self.node_list["List" .. i].list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	end

	for i=4,5 do
		self.node_list["TabButton".. i].toggle:AddValueChangedListener(BindTool.Bind(self.ClickTab, self, i))
		local list_delegate = self.node_list["List" .. i].list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRankCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankCell, self)
	end
	self.my_cell = ALLBiaoBaiRankItem.New(self.node_list["MySelf"])
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["DisPlay"].ui3d_display,MODEL_CAMERA_TYPE.BASE)
	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.Help, self))
	self.node_list["Btn1"].button:AddClickListener(BindTool.Bind(self.ClickBiaoBai, self))
	self.node_list["Btn2"].button:AddClickListener(BindTool.Bind(self.ClickMarry, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Btn3"].button:AddClickListener(BindTool.Bind(self.ClickBiaoBai, self))
end


function BiaoBaiQiangView:Help()
	local tips_id = 301
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function BiaoBaiQiangView:ClickTab(i, state)
	local now_baby = BiaoBaiQiangData.Instance:GetBabySelectCfg()
	BiaoBaiQiangData.Instance:SetBabySelectCfg(i)
	BiaoBaiQiangData.Instance:SetSelectindex(i)
	if i == now_baby then return end
	self.select_index = i
	local param = {
	[1] = "common",
	[2] = "toself",
	[3] = "self",
	[4] = "nanshenrank",
	[5] = "nvshenrank",
}
	if i == 2 then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.BiaoBaiQiang, false)
	end
	if state then
		for i1=1,5 do
			self.node_list["Panel".. i1]:SetActive(i1 == i)
		end
		self:Flush(param[i])
		self:FlushRankInfo()
		self:SetBabyModel()
	end
end
function BiaoBaiQiangView:FlushRankInfo()
	if self.select_index == 4 then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_MALE)						-- 表白排行男榜
	elseif  self.select_index == 5 then
		RankCtrl.Instance:SendGetPersonRankListReq(PERSON_RANK_TYPE.PERSON_RANK_TYPE_RA_PROFESS_FEMALE)
	end
end

function BiaoBaiQiangView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	for _,v in pairs(self.ranl_cell_list) do
		v:DeleteMe()
	end
	self.ranl_cell_list = nil

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
end

function BiaoBaiQiangView:ClickBiaoBai()
	BiaoBaiQiangCtrl.Instance:OpenTips()
end

function BiaoBaiQiangView:GetNumberOfRankCells()
	local  nums = {
		[4] = #BiaoBaiQiangData.Instance:GetMaleRankInfo(),
		[5] = #BiaoBaiQiangData.Instance:GetFemaleRankInfo(),
	}
	return self.select_index > 3 and math.max(nums[self.select_index], 10) or 0
end

function BiaoBaiQiangView:RefreshRankCell(cell, index)
	index = index + 1

	local item_cell = self.ranl_cell_list[cell]
	if nil == item_cell then
		item_cell = ALLBiaoBaiRankItem.New(cell.gameObject)
		item_cell:SetClickCallBack(BindTool.Bind(self.ClickItem, self))
		item_cell.parent_view = self
		self.ranl_cell_list[cell] = item_cell
	end
	local data = {
		[4] = BiaoBaiQiangData.Instance:GetMaleRankInfo()[index],
		[5] = BiaoBaiQiangData.Instance:GetFemaleRankInfo()[index],
	}

	item_cell:SetIndex(index)
	item_cell:SetCurrent(self.select_index)
	item_cell:SetData(data[self.select_index])
end

function BiaoBaiQiangView:ClickItem(cell)
	local data = cell:GetData()
	if not data then
		return
	end
	if self.select_index == 4 then
		self.node_list["List4"].scroller:RefreshAndReloadActiveCellViews(false)
	elseif self.select_index == 5 then
		self.node_list["List5"].scroller:RefreshAndReloadActiveCellViews(false)
	end
end

function BiaoBaiQiangView:GetNumberOfCells()
	local  nums = {
		[1] = BiaoBaiQiangData.Instance:GetCommonWallNum(),
		[2] = BiaoBaiQiangData.Instance:GetToMyWallNum(),
		[3] = BiaoBaiQiangData.Instance:GetMyWallNum(),
	}
	return nums[self.select_index] or 0
end

function BiaoBaiQiangView:RefreshCell(cell, index)
	index = index + 1

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = BiaoBaiQiangItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	data = {
		[1] = BiaoBaiQiangData.Instance:GetDataInfo(index),
		[2] = BiaoBaiQiangData.Instance:GetToSelfDataInfo(index),
		[3] = BiaoBaiQiangData.Instance:GetMyDataInfo(index),
	}
	item_cell:SetIndex(index)
	item_cell:SetCurrent(self.select_index)
	item_cell:SetData(data[self.select_index])
	local num = math.ceil(BiaoBaiQiangData.Instance:GetCommonWallNum() / 4)

	if num > 1 then
		if index % 4 == 0 then
			self.node_list["TxtSub"].text.text = math.ceil(index / 4) .. "/" .. num
		end
		self.node_list["TxtSub"]:SetActive(false)
	else
		self.node_list["TxtSub"]:SetActive(false)
	end
end

function BiaoBaiQiangView:ClickMarry()
	if ViewManager.Instance:IsOpen(ViewName.Marriage) then
		self:Close()
	else
		ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_biaobai)
	end
end

function BiaoBaiQiangView:OnRoleDragSelf(data)
	if self.model then
		self.model:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function BiaoBaiQiangView:OpenCallBack()
	BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_INFO, 2)
	local select_index = BiaoBaiQiangData.Instance:GetSelectindex()
	self.node_list["TabButton".. select_index].toggle.isOn = true
	self:SetActivityTabButton()
	self:FlushRankInfo()
	local num = BiaoBaiQiangData.Instance:GetCommonWallNum()
	local count = math.ceil(num / 4)
end

function BiaoBaiQiangView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "common" and self.select_index == 1 then
			self.select_index = 1
			self.node_list["List1"]:SetActive(true)
			self.node_list["List1"].scroller:ReloadData(0)
		elseif k == "toself"and self.select_index == 2 then
			self.select_index = 2
			self.node_list["List2"]:SetActive(true)
			self.node_list["List2"].scroller:ReloadData(0)
		elseif k == "self" and self.select_index == 3 then
			self.select_index = 3
			self.node_list["List3"]:SetActive(true)
			self.node_list["List3"].scroller:ReloadData(0)
		elseif k == "nanshenrank" or self.select_index == 4 then
			self.select_index = 4
			self.node_list["List1"]:SetActive(false)
			self.node_list["List2"]:SetActive(false)
			self.node_list["List3"]:SetActive(false)
			self.node_list["Panel4"]:SetActive(true)
			self.node_list["List5"]:SetActive(false)
			self.node_list["List4"]:SetActive(true)
			self.node_list["List4"].scroller:RefreshAndReloadActiveCellViews(false)
		elseif k == "nvshenrank" or self.select_index == 5 then
			self.select_index = 5
			self.node_list["List1"]:SetActive(false)
			self.node_list["List2"]:SetActive(false)
			self.node_list["List3"]:SetActive(false)
			self.node_list["List4"]:SetActive(false)
			self.node_list["List5"]:SetActive(true)
			self.node_list["Panel4"]:SetActive(true)
			self.node_list["List5"].scroller:RefreshAndReloadActiveCellViews(false)
		end
	end
	self.node_list["Btn1"]:SetActive(self.select_index < 4)
	self.node_list["Btn2"]:SetActive(self.select_index < 4)
end

function BiaoBaiQiangView:SetBabyModel()
	if self.select_index > 3 then
		if self.time_quest == nil then
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
		self.my_cell:FlushMySelf()
			local item_id = BiaoBaiQiangData.Instance:GetShowItem()
			if item_id then
				local vo = GameVoManager.Instance:GetMainRoleVo()
				local sex_select = {
					[0] = 5,
					[1] = 4,
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
				local baby_id = 0
				local longfen_id = 0
				local scale = 1
				if vo.sex == 1 then
					baby_id, scale = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(1,10)
					longfen_id = 0
				else
					longfen_id = 1
					baby_id, scale = BaobaoData.Instance:GetMaxLongFenBaoBaoCfg(2,10)
				end
				-- local now_baby = BiaoBaiQiangData.Instance:GetBabyItemIdCfg()
				-- BiaoBaiQiangData.Instance:SetBabyItemIdCfg(baby_id)
				-- if now_baby ~= baby_id then

					self.model:SetMainAsset(ResPath.GetSpiritModel(baby_id))
					self.model:ResetRotation()
					self.model:SetScale(Vector3(scale, scale, scale))
					local transform = {position = Vector3(0, 0.98, 5.3), rotation = Quaternion.Euler(0, 180, 0)}
					self.model:SetCameraSetting(transform)
					local attr_cfg = BaobaoData.Instance:GetEquipBaoBaoLongFen(longfen_id,10)
					-- local fashion_power = CommonDataManager.GetCapabilityCalculation(attr_cfg) 
					self.node_list['Power'].text.text = attr_cfg
				-- end
			end
	end
end

function BiaoBaiQiangView:SetActivityTabButton()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PROFESS_RANK, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		for i=4,5 do
			self.node_list["TabButton".. i]:SetActive(true)
		end
	else
		for i=4,5 do
			self.node_list["TabButton".. i]:SetActive(false)
		end
	end
end


function BiaoBaiQiangView:FlushNextTime()
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

BiaoBaiQiangItem = BiaoBaiQiangItem or BaseClass(BaseCell)
function BiaoBaiQiangItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.current = 1

	if self.node_list["BtnClose"] then
		self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.ClickDelete, self))
	end
end

function BiaoBaiQiangItem:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
end
function BiaoBaiQiangItem:SetCurrent(index)
	self.current = index
end

function BiaoBaiQiangItem:ClickDelete()
	local yes_func = function()
		BiaoBaiQiangCtrl.Instance:SendProfessWallReq(PROFESS_WALL_REQ_TYPE.PROFESS_WALL_REQ_DELETE, 3 - self.current, self.data.profess_time, self.data.other_role_id)
	end
	local describe = Language.BiaoBai.Delete
	TipsCtrl.Instance:ShowCommonAutoView("buy_biaobai", describe, yes_func)
end

function BiaoBaiQiangItem:OnFlush()
	if self.data == nil then return end
	local cfg = BiaoBaiQiangData.Instance:GetCfgByType(self.data.gift_type)
	if cfg then
		self.node_list["NameTo"].text.text = string.format(Language.BiaoBai.NameTo,self.data.role_name_to or self.data.other_name)
		self.node_list["NameFrom"].text.text = self.data.role_name_from or self.data.other_name
		self.node_list["Des"].text.text = self.data.contract or self.data.content
		self.node_list["Time"].text.text = os.date("%Y/%m/%d", self.data.profess_time)
		self.item:SetData({item_id = cfg.gift_id, num = 0})
		-- self.node_list["Meili"].text.text = cfg.other_charm
		self.node_list["Exp"].text.text = cfg.exp
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.current == 2 then
		self.node_list["NameTo"].text.text = string.format(Language.BiaoBai.NameTo, vo.name)
	elseif self.current == 3 then
		self.node_list["NameFrom"].text.text = vo.name
	end
end

ALLBiaoBaiRankItem = ALLBiaoBaiRankItem or BaseClass(BaseCell)
function ALLBiaoBaiRankItem:__init()
	self.current = 4
	self.cur_int = 0

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])

	if self.node_list["ItemCell"] then
		self.node_list["ItemCell"].button:AddClickListener(BindTool.Bind(self.HeadClick, self))
	end
end

function ALLBiaoBaiRankItem:__delete()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end
	self.parent_view = nil
end


function ALLBiaoBaiRankItem:SetCurrent(index)
	self.current = index
end

function ALLBiaoBaiRankItem:OnFlush()
	-- if self.data == nil then return end
	if self.data then
		self.node_list["Name"].text.text = self.data.user_name
		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, self.data.rank_value)
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, self.data.flexible_int)
	else
		self.node_list["Name"].text.text = Language.BiaoBai.NoRank
		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, "--")
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, "--")
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
			if self.parent_view then
				if self.parent_view.select_index == 4 then
					if self.index - 1 <= v.rank_index then
						self.item:SetData(v.reward_item)
						self.node_list["Item"]:SetActive(v.reward_item.item_id ~= 0 )
						break
					end
				else
					if self.index - 1 <= v.rank_index then
						self.node_list["Item"]:SetActive(true)
						self.item:SetData(v.female_reward_item)
						self.node_list["Item"]:SetActive(v.female_reward_item.item_id ~= 0 )
						break
					end
				end
			else
				if self.index - 1 <= v.rank_index then
						self.node_list["Item"]:SetActive(true)
						local my_sex = GameVoManager.Instance:GetMainRoleVo().sex
						local data_list = my_sex > 0 and v.reward_item or  v.female_reward_item
						self.item:SetData(data_list)
						self.node_list["Item"]:SetActive(data_list.item_id ~= 0 )
						break
					end
			end
		end
	else
		self.node_list["Item"]:SetActive(false)
	end
end

function ALLBiaoBaiRankItem:SetHead()
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
		if self.current == 4 then
			prof = 1
			sex = 1
		else
			prof = 4
			sex = 0
		end
	end
	AvatarManager.Instance:SetAvatar(user_id, self.node_list["RawImageBtn"], self.node_list["IconBtn"], sex, prof, false)
end

function ALLBiaoBaiRankItem:FlushMySelf()
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
	else
		self.node_list["ImgRank"]:SetActive(false)
		self:Flush()
	end
		self.node_list["Jifen"].text.text = string.format(Language.BiaoBai.Jifen, info.ra_profess_score)
		self.node_list["Count"].text.text = string.format(Language.BiaoBai.Count, info.ra_profess_to_num + info.ra_profess_from_num)
end

function ALLBiaoBaiRankItem:HeadClick(state)
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

function ALLBiaoBaiRankItem:CloseBtnCallBack()
	local hl_user_id = CheckData.Instance:GetCurrentHLUserId()
	if hl_user_id then
		CheckData.Instance:SetCurrentUserId(hl_user_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(hl_user_id)
	end
end

function ALLBiaoBaiRankItem:SetHighLight(is_hl)
	if self.node_list["ImgHighLight"] then
		self.node_list["ImgHighLight"]:SetActive(is_hl)
	end
end