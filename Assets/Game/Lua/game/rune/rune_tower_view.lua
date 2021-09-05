RuneTowerView = RuneTowerView or BaseClass(BaseRender)

local TOP_CELL_SIZE = 354		-- 塔顶塔格子的大小
local BOTTOM_CELL_SIZE = 280	-- 塔底塔格子的大小
local NORMAL_CELL_SIZE = 165	-- 正常塔格子的大小

function RuneTowerView:__init()
	self.cell_list = {}
	self.rank_cell_list = {}
	self.cur_layer = -1
	self.is_cell_active = false
	-- self.is_first_set_offtime = true
	self.old_offline_time = 0

	self.node_list["EnterButton"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["AutoBtn"].button:AddClickListener(BindTool.Bind(self.OnClickAuto, self))


	self.is_onekey_saodang = false
	self.list_view = self.node_list["ListView"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTowerCell, self)
	list_delegate.CellSizeDel = BindTool.Bind(self.CellSizeDel, self)

	self.list_view.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)
	-- self.list_view.scroller.cellViewVisibilityChanged = BindTool.Bind(self.CellViewVisibilityChanged, self)

	self.rank_list_view = self.node_list["RankListView"]
	local rank_list_delegate = self.rank_list_view.list_simple_delegate
	rank_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	rank_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTowerRankCell, self)

	self.item_cells = {}
	self.show_reward_list = {}
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.item_cells[i]:SetShowOrangeEffect(true)
		self.show_reward_list[i] = self.node_list["Item" .. i]
	end

	self.unlock_item_list = {}
	self.unlock_top_item_list = {}
	for i = 1, 3 do
		self.unlock_item_list[i] = ItemCell.New()
		self.unlock_item_list[i]:SetInstanceParent(self.node_list["UnLockItem"..i])
		self.unlock_top_item_list[i] = ItemCell.New()
		self.unlock_top_item_list[i]:SetInstanceParent(self.node_list["ItemCellTop"..i])
	end
end

function RuneTowerView:GetNumberOfCells()
	return GuaJiTaData.Instance:GetRuneMaxLayer() + 2
end

function RuneTowerView:RefreshTowerCell(cell, data_index)
	data_index = data_index
	local tower_view = self.cell_list[cell]
	if tower_view == nil then
		tower_view = RuneTowerListView.New(cell.gameObject)
		self.cell_list[cell] = tower_view
	end
	local data = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(data_index)
	tower_view:SetData(data, data_index)
	tower_view:ListenClick(BindTool.Bind(self.OnClickEnter, self))

	if self.is_onekey_saodang and data_index == self.cur_layer + 1 then
		tower_view:SetSaodangEffectEnable(true)
	end

	self.is_cell_active = true
end

function RuneTowerView:CellSizeDel(data_index)
	if data_index == 0 then
		return TOP_CELL_SIZE
	elseif data_index == (GuaJiTaData.Instance:GetRuneMaxLayer() + 1) then
		return BOTTOM_CELL_SIZE
	end
	return NORMAL_CELL_SIZE
end

function RuneTowerView:JumpToIndex()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		local jump_index = GuaJiTaData.Instance:GetRuneTowerInfo().fb_today_layer or 0
		local bottom_index = jump_index == 0

		jump_index = GuaJiTaData.Instance:GetRuneMaxLayer() - jump_index - 1
		if bottom_index then
			jump_index = jump_index + 1
		end
		local scrollerOffset = 0
		local cellOffset = -1
		local useSpacing = false
		local scrollerTweenType = self.list_view.scroller.snapTweenType
		local scrollerTweenTime = 0
		local scroll_complete = function()
			self.cur_layer = jump_index
		end

		self.list_view.scroller:JumpToDataIndex(
			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	end
end

function RuneTowerView:ScrollerScrolledDelegate(go, param1, param2, param3)
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local pass_layer = rune_info.fb_today_layer or 0
	local cur_layer = GuaJiTaData.Instance:GetRuneMaxLayer() - pass_layer
	if self.cur_layer ~= cur_layer and self.is_cell_active then
		self:JumpToIndex()
	end
end

-- function RuneTowerView:CellViewVisibilityChanged(obj, param1, param2)
-- end

function RuneTowerView:GetRankNumberOfCells()
	return #RuneData.Instance:GetRuneRankInfo()
end

function RuneTowerView:RefreshTowerRankCell(cell, data_index)
	data_index = data_index + 1
	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = RuneTowerRankListView.New(cell.gameObject)
		self.rank_cell_list[cell] = rank_cell
	end
	local data = RuneData.Instance:GetRuneRankInfo()
	rank_cell:SetData(data[data_index], data_index)
end

function RuneTowerView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	for k, v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = {}
	for k, v in pairs(self.item_cells) do
		self.show_reward_list[k] = nil
		v:DeleteMe()
	end
	self.item_cells = {}

	for _, v in ipairs(self.unlock_item_list) do
		v:DeleteMe()
	end
	self.unlock_item_list = {}
	for _, v in ipairs(self.unlock_top_item_list) do
		v:DeleteMe()
	end
	self.unlock_top_item_list = {}
end

function RuneTowerView:InitView()
	UITween.AlpahShowPanel(self.node_list["LeftPanel"], true)
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(950, 6, 0))
	UITween.MoveShowPanel(self.node_list["ShowTopFunOpen"], Vector3(-312, 500, 0))
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(-240, 445, 0))
	UITween.MoveShowPanel(self.node_list["RewardContent"], Vector3(-20, -400, 0))
	RemindManager.Instance:Fire(RemindName.RuneTower, true)
	self:FlushView()
end

function RuneTowerView:CloseCallBack()
	self.cur_layer = -1
	-- self.is_first_set_offtime = true

	-- if self.animtion_timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.animtion_timer_quest)
	-- 	self.animtion_timer_quest = nil
	-- end
	-- self.is_cell_active = false
	self.is_onekey_saodang = false
	-- for _, v in pairs(self.cell_list) do
	-- 	v:SetSaodangEffectEnable(false)
	-- end
end

-- 进入挂机塔
function RuneTowerView:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GUAJI_TA)
end

-- 扫荡
function RuneTowerView:OnClickAuto()
	GuaJiTaCtrl.Instance:SendRuneTowerAuto(RUNE_TOWER_FB_OPER_TYPE.RUNE_TOWER_FB_OPER_AUTOFB)
	self.is_onekey_saodang = true
end

function RuneTowerView:OnClickHelp()
	local tip_id = 161
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

function RuneTowerView:FlushRank()
	if self.rank_list_view.scroller.isActiveAndEnabled then
		self.rank_list_view.scroller:ReloadData(0)
	end
	self:FlushMyRankInfo()
end

function RuneTowerView:FlushMyRankInfo()
	local my_rank_info = RuneData.Instance:GetMyRankInfo()

	if my_rank_info ~= "" then
		if my_rank_info.rank <= 3 then
			self.node_list["MyRank"]:SetActive(false)
			self.node_list["MyRankImage"]:SetActive(true)
			local bundle, asset = ResPath.GetRankIcon(my_rank_info.rank)
			self.node_list["MyRankImage"].image:LoadSprite(bundle, asset)
		else
			-- 大于100名后，显示未上榜
			self.node_list["MyRank"].text.text = my_rank_info.rank > 100 and Language.Rune.MyNotListed or my_rank_info.rank
			self.node_list["MyRank"]:SetActive(true)
			self.node_list["MyRankImage"]:SetActive(false)
		end
		self.node_list["MyPassLayer"].text.text = string.format(Language.Rune.Ceng, my_rank_info.rank_value)
		self.node_list["MyName"].text.text = my_rank_info.user_name
		local bundle, asset = ResPath.GetVipLevelIcon(my_rank_info.vip_level)
		self.node_list["MyImgVip"].image:LoadSprite(bundle, asset)
		self.node_list["MyValue"].text.text = string.format(Language.FuBen.Capbility, my_rank_info.flexible_int)
	end
end

function RuneTowerView:GetEnterBut()
	return self.node_list["EnterButton"], BindTool.Bind(self.OnClickEnter, self)
end

function RuneTowerView:FlushView()
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	if rune_info == nil or next(rune_info) == nil then
		return
	end
	local max_layer = GuaJiTaData.Instance:GetRuneMaxLayer()
	local pass_layer = rune_info.pass_layer + 1 > max_layer and max_layer + 1 or rune_info.pass_layer + 1
	local today_pass = rune_info.fb_today_layer + 1 > max_layer and max_layer or rune_info.fb_today_layer + 1

	-- 跳转到目标层
	if self.is_cell_active then
		self.list_view.scroller:ReloadData(0)
		self:JumpToIndex()
	end

	--设置解锁信息
	if pass_layer <= max_layer then
		self:ChangeUnlockContent(pass_layer)
		self:ChangeContent(today_pass, pass_layer)
	else
		-- self.node_list["CurLayer"]:SetActive(false)
		self.node_list["ShowTopFunOpen"]:SetActive(false)
	end
		
	self:FlushMyRankInfo()
	-- local cur_cfg = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(pass_layer + 1)
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local normal_layer = pass_layer > 1 and pass_layer - 1 or 1
	local reward_cfg = fuben_cfg[normal_layer].normal_reward_item
	if today_pass == pass_layer then
		reward_cfg = fuben_cfg[pass_layer].first_reward_item
	end

	for i = 2, 3 do
		self.show_reward_list[i]:SetActive(false)
		self.item_cells[i]:SetActive(false)
		if reward_cfg[i - 2] and reward_cfg[i - 2].item_id > 0 then
			self.show_reward_list[i]:SetActive(true)
			self.item_cells[i]:SetActive(true)
			self.item_cells[i]:SetData(reward_cfg[i - 2])
		end
	end
	self.show_reward_list[1]:SetActive(true)
	self.item_cells[1]:SetActive(true)
	if pass_layer ~= today_pass then 
		self.item_cells[1]:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = fuben_cfg[pass_layer - 1].normal_reward_rune_exp, is_bind = 1})
	else
		self.item_cells[1]:SetData({item_id = ResPath.CurrencyToIconId.rune_jinghua, num = fuben_cfg[pass_layer].first_reward_rune_exp, is_bind = 1})
	end

	UI:SetButtonEnabled(self.node_list["AutoBtn"], pass_layer ~= today_pass and today_pass < max_layer)
	-- UI:SetButtonEnabled(self.node_list["EnterButton"], pass_layer <= today_pass)
	self.node_list["AutoBtn"]:SetActive(pass_layer ~= today_pass)
	if pass_layer ~= today_pass then
		self.node_list["RewaredText"].text.text = Language.FuBen.RewardTowerOne
	else
		self.node_list["RewaredText"].text.text = Language.FuBen.RewardTower
	end
	self.node_list["EnterButton"]:SetActive(pass_layer == today_pass)-- and pass_layer ~= max_layer
	self.node_list["TuiJian"]:SetActive(pass_layer == today_pass)
	local temp_data = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(today_pass)
	if nil == temp_data.capability then 
		self.node_list["TxtPower"]:SetActive(false)
		self.node_list["TxtPower"].text.text = 0
	else 
		self.node_list["TxtPower"]:SetActive(true)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo and main_role_vo.capability then
			local color = main_role_vo.capability >= temp_data.capability and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED
			self.node_list["TxtPower"].text.text = string.format(Language.FuBen.RecommendCap, ToColorStr(temp_data.capability,color))
		end
	end
end

local RuneType = 1 				--开启的符文类型
local RuneSlot = 2 				--开启的符文槽
local RuneLevel = 3 			--开启的符文等级
function RuneTowerView:ChangeUnlockContent(pass_layer)
	local unlock_text = Language.Rune.UnLockText1
	local unlock_reward_state = -2							-- -2代表无, -1代表符文等级，0代表符文槽，大于1代表符文类型数量
	local next_fun_open_info = GuaJiTaData.Instance:GetNextFunOpenInfo(pass_layer)

	if next_fun_open_info == nil or next_fun_open_info == "" then 
		self.node_list["ShowTopFunOpen"]:SetActive(false)
		return 
	end

	local sp_show = next_fun_open_info.sp_show
	if RuneSlot == next_fun_open_info.sp_type then
		unlock_reward_state = 2
		unlock_text = Language.Rune.UnLockText2

	elseif RuneLevel == next_fun_open_info.sp_type then
		unlock_reward_state = 3
		local level_limit_info = RuneData.Instance:GetRuneLevelLimitInfo() or {}
		local add_level = sp_show - (level_limit_info.rune_level or 0)
		unlock_text = string.format(Language.Rune.UnLockText3, add_level)

	elseif RuneType == next_fun_open_info.sp_type then
		sp_show = Split(sp_show, "#")
		unlock_reward_state = 1

		for k, v in ipairs(sp_show) do
			if self.unlock_top_item_list[k] then
				self.unlock_top_item_list[k]:SetData({item_id = tonumber(v)})
			end
		end
	end

	self.node_list["LevelText1"].text.text = string.format(Language.Rune.Ceng, next_fun_open_info.fb_layer)
	local scale = 1.3
	if next_fun_open_info.fb_layer >= 10 and next_fun_open_info.fb_layer < 100 then
		scale = 1.4
	elseif next_fun_open_info.fb_layer >= 100 then
		scale = 1.5
	end
	self.node_list["Effect"].transform.localScale = Vector3(scale, 1, 1)

	self.node_list["ShowItemTop"]:SetActive(unlock_reward_state == RuneType)
	self.node_list["ImgFunOpenTop1"]:SetActive(unlock_reward_state == RuneSlot)
	self.node_list["ImgFunOpenTop2"]:SetActive(unlock_reward_state == RuneLevel)
	self.node_list["TextUnLock"].text.text = unlock_text
end

function RuneTowerView:ChangeContent(today_pass, pass_layer)
	local unlock_reward_state = -2
	local next_fun_open_info = GuaJiTaData.Instance:GetNextInfo(today_pass)
	if next_fun_open_info == nil or next_fun_open_info == "" then return end

	local sp_show = next_fun_open_info.sp_show
	if RuneSlot == next_fun_open_info.sp_type then
		unlock_reward_state = 2

	elseif RuneLevel == next_fun_open_info.sp_type then
		unlock_reward_state = 3

	elseif RuneType == next_fun_open_info.sp_type then
		sp_show = Split(sp_show, "#")
		unlock_reward_state = 1

		for k, v in ipairs(sp_show) do
			if self.unlock_item_list[k] then
				self.unlock_item_list[k]:SetData({item_id = tonumber(v)})
			end
		end
	end

	self.node_list["CurLevel"].text.text = today_pass
	self.node_list["ShowFunOpen"]:SetActive(next_fun_open_info.fb_layer == today_pass and next_fun_open_info.fb_layer >= pass_layer)
	self.node_list["ShowItem"]:SetActive(unlock_reward_state == RuneType)
	self.node_list["ImgFunOpen1"]:SetActive(unlock_reward_state == RuneSlot)
	self.node_list["ImgFunOpen2"]:SetActive(unlock_reward_state == RuneLevel)
end

--符文塔格子
RuneTowerListView = RuneTowerListView or BaseClass(BaseRender)

function RuneTowerListView:__init(instance)
	self.had_show_first = self.node_list["HadPassShowFirst"]
	self.lock_show_first = self.node_list["LockShowFirst"]
	self.text_show_first = self.node_list["TextShowFirst"]

	self.is_cur_challenge = false
end

function RuneTowerListView:__delete()
end

function RuneTowerListView:SetData(data, data_index)
	local is_top = data_index == 0
	local is_bottom = data_index == (GuaJiTaData.Instance:GetRuneMaxLayer() + 1)
	-- self.node_list["TuijianFightPower"]:SetActive(not is_top and not is_bottom)

	if data and data.fb_layer then
		local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()
		if rune_info == nil or next(rune_info) == nil then
			return
		end
		local level = GuaJiTaData.Instance:GetRuneMaxLayer() - data.fb_layer + 1
		local temp_data = GuaJiTaData.Instance:GetRuneTowerLayerCfgByLayer(level)
		local max_layer = GuaJiTaData.Instance:GetRuneMaxLayer()
		local is_pass = rune_info.pass_layer >= level
		local today_pass = 0
		if rune_info.fb_today_layer == 0 then
			today_pass = 1
		elseif rune_info.fb_today_layer == max_layer then
			today_pass = rune_info.fb_today_layer
		else
			today_pass = rune_info.fb_today_layer + 1
		end

		self.node_list["CurLevel"].text.text = (level)
		UI:SetGraphicGrey(self.node_list["ImageGray"], not is_pass)
		self.node_list["ImgLock"]:SetActive(rune_info.pass_layer + 1 < level)
		self.node_list["TextFightPower"].text.text = temp_data.capability
		self.node_list["TextCurLayer"]:SetActive(today_pass == level)
		self.node_list["ShowSelect"]:SetActive(today_pass == level)
		-- self.node_list["TuijianFightPower"]:SetActive(today_pass == level)

		-- local str = ""
		-- if is_pass then
		-- 	if today_pass >= level then
		-- 		str = Language.Rune.PassLayer
		-- 	else
		-- 		str = Language.Rune.NotSaoDang
		-- 	end
		-- else
		-- 	str = Language.Rune.NotPassLayer
		-- end
		-- self.text_show_first.text.text = str
	end

	self.node_list["TowerFBList"]:SetActive(nil ~= data.fb_layer)
	self.node_list["ShowTop"]:SetActive(is_top)
	self.node_list["ShowBottom"]:SetActive(is_bottom)
end

function RuneTowerListView:ListenClick(handler)
	if not self.is_cur_challenge then return end
	self.node_list["BtnFirstChallenge"].button:AddClickListener(handler or  BindTool.Bind(self.OnClickChallenge, self))
	self.node_list["BtnChallenge"].button:AddClickListener(handler or  BindTool.Bind(self.OnClickChallenge, self))
end

function RuneTowerListView:GetContents()
	return self.contents
end

function RuneTowerListView:SetIndex(index)
	self.index = index
end

function RuneTowerListView:GetIndex()
	return self.index
end

function RuneTowerListView:GetHeight()
	return self.root_node.rect.rect.height
end

function RuneTowerListView:SetSaodangEffectEnable(value)
	self.node_list["ShowSaodangEffect"]:SetActive(value)
end

----------------------------------------------------
RuneTowerRankListView = RuneTowerRankListView or BaseClass(BaseRender)

function RuneTowerRankListView:__init(instance)
	self.rank = 0
	self.is_click = false
	-- self.node_list["RankItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ToggleClick, self))
end

function RuneTowerRankListView:__delete()
	self.parent = nil
end

function RuneTowerRankListView:SetData(data, data_index)
	self.data = data

	if self.data == nil then
		return
	end

	if data_index <= 3 then
		self.node_list["ImgRankImage"]:SetActive(true)
		local bundle, asset = ResPath.GetRankIcon(data_index)
		self.node_list["ImgRankImage"].image:LoadSprite(bundle, asset)
	else
		self.node_list["TxtRank"].text.text = data_index
		self.node_list["ImgRankImage"]:SetActive(false)
	end

	if self.data then
		-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.level)
		-- self.node_list["TxtLevel"].text.text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
		self.node_list["TxtName"].text.text = self.data.user_name
		self.node_list["TxtLevel"].text.text = string.format(Language.Rune.Ceng, self.data.rank_value)
		local bundle, asset = ResPath.GetVipLevelIcon(self.data.vip_level)
		self.node_list["ImgVip"].image:LoadSprite(bundle, asset)
		self.node_list["TxtRankValue"].text.text = string.format(Language.FuBen.Capbility, self.data.flexible_int)
	end
end