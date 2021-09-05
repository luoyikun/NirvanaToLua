-- 防具材料副本
FuBenArmorView = FuBenArmorView or BaseClass(BaseRender)
function FuBenArmorView:__init(instance)
	self.cur_page = 1

	self.list = {}
	self.node_list["PageView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["PageView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	self.node_list["PageView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	local num = 2
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local max_pass_level = info.max_pass_level or -1

	self.node_list["PageView"].page_view:Reload()
	local cur_chapter = max_pass_level + num

	local chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(max_pass_level + num)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if chapter_cfg and chapter_cfg.need_level > role_level then
		cur_chapter = max_pass_level + 1
	end
	local index = (cur_chapter - 1) < 0 and 0 or (cur_chapter - 1)
	self.node_list["PageView"].page_view:JumpToIndex(index)

	self.enter_count = 0
	self.can_buy_count = 0
	self.cell_list = {}
	self.item_list = {}
	for i=1, 5 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["ItemCell" .. i])
		item_cell:SetShowOrangeEffect(true)
		self.item_list[i] = item_cell
	end

	self.node_list["BtnChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnClear"].button:AddClickListener(BindTool.Bind(self.OnSaodangEnter, self))
	self.node_list["ImgAdd"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.last_check_time = nil
end

function FuBenArmorView:GetGuideChallenge()
	if self.node_list["BtnChallenge"] then
		return self.node_list["BtnChallenge"], BindTool.Bind(self.OnClickEnter, self)
	end
end

function FuBenArmorView:__delete()
	for k, v in pairs(self.list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	if self.reset_timer then
		GlobalTimerQuest:CancelQuest(self.reset_timer)
		self.reset_timer = nil
	end
end

function FuBenArmorView:LoadCallBack()
	FuBenCtrl.Instance:SetArmorRemind()
end

function FuBenArmorView:OpenCallBack()
	self:Flush()
end

function FuBenArmorView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Bottom"], FuBenTweenData.Down)
end

function FuBenArmorView:SelectItemCallback(cell)
	if cell == nil or cell.data == nil then return end
	local num = FuBenData.Instance:GetTowerDefendChapterNum()
	self.node_list["PageView"].page_view:JumpToIndex(cell.data - 1, 0, 5 / num)
end

function FuBenArmorView:FlushSelectItem(index)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local max_pass_level = info.max_pass_level or -1
	if self.node_list["PageView"] then
		self.node_list["PageView"].page_view:Reload()
		local num = FuBenData.Instance:GetTowerDefendChapterNum()
		self.node_list["PageView"].page_view:JumpToIndex(index, 0, 5 / num)
	end
end

function FuBenArmorView:GetData(i)
	local chapter = self.cur_page + i - 3
	if chapter > 10 then
		chapter = chapter - 10
	elseif chapter < 1 then
		chapter = chapter + 10
	end
	return chapter
end

function FuBenArmorView:GetNumberOfCells()
	return FuBenData.Instance:GetTowerDefendChapterNum()
end

function FuBenArmorView:RefreshListCell(data_index, cell)
	local guard_item = self.list[cell]
	if guard_item == nil then
		guard_item = FbArmorItem.New(cell.gameObject)
		guard_item:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		guard_item.parent_view = self
		self.list[cell] = guard_item
	end
	guard_item:SetData(data_index + 1)
end

function FuBenArmorView:OnValueChanged()
	local other_cfg = FuBenData.Instance:GetArmorDefendCfgOther()
	local effect_level = other_cfg and other_cfg.effect_show
	local page = self.node_list["PageView"].page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page

		local max_num = FuBenData.Instance:GetTowerDefendChapterNum() or 0
		if self.cur_page > max_num then
			return
		end
		local info = FuBenData.Instance:GetTowerDefendRoleInfo()
		if nil == next(info) then return end

		local max_pass_level = info.max_pass_level or -1
		local chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(max_pass_level + 1)
		if chapter_cfg == nil then
			return
		end
		local clearGray = self.cur_page <= info.max_pass_level + 1 and info.max_pass_level + 1 <= 25 or self.cur_page < info.max_pass_level + 1
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		UI:SetButtonEnabled(self.node_list["BtnClear"], clearGray)
		local level = self.cur_page - 1
		local btn_challenge_gray = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
		UI:SetButtonEnabled(self.node_list["BtnChallenge"], btn_challenge_gray)

		local chapter_list = FuBenData.Instance:GetArmorDefendChapterCfg(self.cur_page)
		if chapter_list == nil then
			return
		end
		for i,v in ipairs(self.item_list) do
			if chapter_list.item_list[i] ~= nil then
				self.item_list[i]:SetData({item_id = tonumber(chapter_list.item_list[i])})
				self.item_list[i]:SetShowStar(chapter_list.equiment_star)
				self.item_list[i]:SetQualityByColor(chapter_list.equiment_quality)
				local func = function()
					local item_data = {item_id = tonumber(chapter_list.item_list[i])}
					TipsCtrl.Instance:OpenItem(item_data)
					GlobalTimerQuest:AddDelayTimer(function()
						TipsCtrl.Instance:SetQualityAndClor(chapter_list.equiment_quality)
						TipsCtrl.Instance:SetPropQualityAndClor(chapter_list.equiment_quality)
						TipsCtrl.Instance:SetOtherQualityAndClor(chapter_list.equiment_quality)
						end, 0.1)
				end
				if effect_level ~= nil and chapter_list.equiment_quality and chapter_list.equiment_quality >= effect_level then
					if chapter_list.equiment_quality == 4 then
						self.item_list[i]:ShowEquipOrangeEffect(true)
					elseif chapter_list.equiment_quality == 5 then
						self.item_list[i]:ShowEquipRedEffect(true)
					elseif chapter_list.equiment_quality == 6 then
						self.item_list[i]:ShowEquipFenEffect(true)
					end
				end
				self.item_list[i]:ShowHighLight(false)
				self.item_list[i]:ListenClick(func)
				self.item_list[i]:SetActive(true)
			else
				self.item_list[i]:SetActive(false)
			end
		end
	end
end

function FuBenArmorView:OnClickEnter(is_sd)
	if self.enter_count > 0 then
		if is_sd then
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
		else
			FuBenData.Instance:SetArmorSelectLevel(self.cur_page - 1)
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
			FuBenCtrl.Instance:CloseView()
		end
	else
		self:OnClickBuy()
	end
end

function FuBenArmorView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(266)
end

function FuBenArmorView:OnSaodangEnter()
	if FuBenData.Instance:GetIsInFuBenScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.FuBenNotSaoDang)
		return
	end
	self:OnClickEnter(true)
end

function FuBenArmorView:OnClickBuy()
	local ok_fun = function ()
		FuBenData.Instance:SetAromrBuyTimes(true)
		-- 策划要求防具本和个人塔防本整体对调
		FuBenCtrl.SendTowerDefendBuyJoinTimes()
		-- FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_BUY_JOIN_TIMES)
	end
	local data_fun = function ()
		local data = {}
		local info = FuBenData.Instance:GetTowerDefendRoleInfo()
		data[2] = info.buy_join_times or 0
		data[1] = FuBenData.Instance:GetTowerBuyCost(data[2] + 1)
		data[3] = VipPower:GetParam(VipPowerId.tower_defend_buy_count)
		data[4] = VipPower:GetParam(VipPowerId.tower_defend_buy_count, true)
		return data
	end
	local data = data_fun()
	FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4],VipPowerId.tower_defend_buy_count, ok_fun, data_fun)
end

function FuBenArmorView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "times" then
			self:FlushBuyTimes()
			FuBenData.Instance:SetAromrBuyTimes(false)
			return
		end
	end
	local other_cfg = FuBenData.Instance:GetArmorDefendCfgOther()
	local effect_level = other_cfg and other_cfg.effect_show
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(self.cur_page)
	if nil == chapter_cfg or nil == next(info) then return end

	self:FlushBuyTimes()
	for i,v in ipairs(self.item_list) do
		if chapter_cfg.item_list[i] ~= nil then
			self.item_list[i]:SetData({item_id = tonumber(chapter_cfg.item_list[i])})
		else
			-- self.item_list[i]:SetActive(false)
		end
		self.item_list[i]:SetShowStar(chapter_cfg.equiment_star)
		self.item_list[i]:SetQualityByColor(chapter_cfg.equiment_quality)
		if effect_level ~= nil and chapter_cfg.equiment_quality and chapter_cfg.equiment_quality >= effect_level then
			if chapter_cfg.equiment_quality == 4 then
				self.item_list[i]:ShowEquipOrangeEffect(true)
			elseif chapter_cfg.equiment_quality == 5 then
				self.item_list[i]:ShowEquipRedEffect(true)
			elseif chapter_cfg.equiment_quality == 6 then
				self.item_list[i]:ShowEquipFenEffect(true)
			end
		end
		local func = function()
			local item_data = {item_id = tonumber(chapter_cfg.item_list[i])}
			TipsCtrl.Instance:OpenItem(item_data)
			GlobalTimerQuest:AddDelayTimer(function()
				TipsCtrl.Instance:SetQualityAndClor(chapter_cfg.equiment_quality)
				TipsCtrl.Instance:SetPropQualityAndClor(chapter_cfg.equiment_quality)
				TipsCtrl.Instance:SetOtherQualityAndClor(chapter_cfg.equiment_quality)
				end, 0.1)
		end
		self.item_list[i]:ShowHighLight(false)
		self.item_list[i]:ListenClick(func)
	end

	self.can_buy_count = VipPower.Instance:GetParam(VipPowerId.tower_defend_buy_count) - info.buy_join_times
	self.node_list["TxtCanBuyNum"].text.text = string.format(Language.FuBen.CanBuyNumber, self.can_buy_count)
	local butGray = self.cur_page <= info.max_pass_level + 1 and info.max_pass_level + 1 <= 25 or self.cur_page < info.max_pass_level + 1
	UI:SetButtonEnabled(self.node_list["BtnClear"], butGray)

	for i,v in ipairs(self.item_list) do
		v:Flush()
	end

	local max_pass_level = info.max_pass_level or -1
	local cur_chapter = max_pass_level + 2
	local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	if chapter_cfg and chapter_cfg.need_level > role_level then
		cur_chapter = max_pass_level + 1
		local level = self.cur_page - 1
		local btn_challenge_gray = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
		UI:SetButtonEnabled(self.node_list["BtnChallenge"], btn_challenge_gray)
	end
	self.node_list["PageView"].page_view:Reload()
end

function FuBenArmorView:FlushBuyTimes()
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local other_cfg = FuBenData.Instance:GetArmorDefendCfgOther()
	self.enter_count = other_cfg.free_join_times + info.buy_join_times + info.item_buy_join_times - info.join_times
	local max_times = other_cfg.free_join_times + info.buy_join_times + info.item_buy_join_times
	local left_times_color = self.enter_count <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
	self.node_list["TxtCanChallengeNum"].text.text = string.format(Language.FuBen.ChallengeTime, ToColorStr(self.enter_count, left_times_color), max_times)
end


-- 跳转抽奖活动
function FuBenArmorView:OnClickChouJiang()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

-------------------------------------------------------------------------------------------
FbArmorItem = FbArmorItem or BaseClass(BaseRender)

function FbArmorItem:__init()
	self.monster_model = RoleModel.New()
	self.monster_model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE, true)

	self.node_list["BgButton"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function FbArmorItem:__delete()
	if self.monster_model ~= nil then
		self.monster_model:DeleteMe()
		self.monster_model = nil
	end
end

function FbArmorItem:SetData(data)
	self.data = data
	if self.data ~= nil then
		self:OnFlush()
		self:IsShowBoss()
	end
end

function FbArmorItem:SetClickCallback(handler)
	self.handler = handler
end

function FbArmorItem:OnClickItem()
	if self.handler then
		self.handler(self)
	end
end

function FbArmorItem:IsSelect(value)
	-- self.node_list["RawImgSelect"]:SetActive(value)
end

function FbArmorItem:OnFlush()
	if self.data == nil then return end
	self.node_list["TxtTitle"].text.text = string.format(Language.PersonalGoal.Chapter, self.data)
	local chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(self.data)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	if nil == chapter_cfg or nil == next(info) then
		return
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level

	local level = self.data - 1
	local is_open = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
	self.node_list["ImgState"]:SetActive(level < info.max_pass_level + 1)

	self.node_list["DisplayMask"]:SetActive(is_open)
	self.node_list["ImageLock"]:SetActive(not is_open)
	self.node_list["LockPanel"]:SetActive(not is_open)

	local color = chapter_cfg.need_level <= role_level and "89F201FF" or "ff0000"
	self.node_list["OpenText_1"].text.text = string.format(Language.TowerDefend.TowerChapterLimit1, color, PlayerData.GetLevelString(chapter_cfg.need_level))
	color = level <= info.max_pass_level + 1 and "89F201FF" or "ff0000"
	self.node_list["OpenText_2"].text.text = string.format(Language.TowerDefend.TowerChapterLimit3, color)

end

function FbArmorItem:IsShowBoss()
	local level = self.data - 1
	local chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(self.data)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	if nil == chapter_cfg or nil == next(info) then
		return
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local is_open = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
	local boss_data = BossData.Instance:GetMonsterInfo(chapter_cfg.show_resid)
	if is_open and boss_data then
		local fun = function ()
			--在回调里再拿一次数据
			chapter_cfg = FuBenData.Instance:GetArmorDefendChapterCfg(self.data)
			boss_data = BossData.Instance:GetMonsterInfo(chapter_cfg.show_resid)
			self.monster_model:SetScale(Vector3(boss_data.ui_scale, boss_data.ui_scale, boss_data.ui_scale))
			local y = boss_data.ui_position_y or 0
			self.monster_model:SetLocalPosition(Vector3(0, y, 0))
			self.monster_model:SetRotation(Vector3(0, -45, 0))
		end
		local bundle, asset = ResPath.GetMonsterModel(boss_data.resid)
		self.monster_model:SetMainAsset(bundle, asset, fun)
	end
end

