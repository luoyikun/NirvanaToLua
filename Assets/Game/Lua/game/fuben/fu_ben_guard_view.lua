-- 守护副本
FuBenGuardView = FuBenGuardView or BaseClass(BaseRender)

local mW = 320
local W = 1000
local MID_X = 3 * mW - W
local CUR_MID_X = 3 * mW - W
function FuBenGuardView:__init(instance)
	self.cur_page = 1

	self.list = {}
	self.node_list["PageView"].page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.node_list["PageView"].page_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	self.node_list["PageView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.node_list["PageView"].page_view:Reload()

	local num = 2
	local info = FuBenData.Instance:GetArmorDefendRoleInfo()
	local max_pass_level = info.max_pass_level or -1
	local cur_chapter = max_pass_level + num
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg2(max_pass_level + num)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if chapter_cfg and chapter_cfg.need_level > role_level then
		cur_chapter = max_pass_level + 1
	end
	local index = cur_chapter - 1 < 0 and 0 or cur_chapter - 1
	FuBenData.Instance:SetSelectLevel(index)
	-- self.node_list["PageView"].page_view:JumpToIndex(index)

	self.enter_count = 0
	self.can_buy_count = 0
	self.cell_list = {}
	self.item_list = {}

	self.rewarditem_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		self.rewarditem_list[i] = item
	end

	self.node_list["BtnChallenge"].button:AddClickListener(BindTool.Bind(self.OnClickEnter, self))
	self.node_list["BtnClear"].button:AddClickListener(BindTool.Bind(self.OnSaodangEnter, self))
	self.node_list["ImgAdd"].button:AddClickListener(BindTool.Bind(self.OnClickBuy, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnChouJiang"].button:AddClickListener(BindTool.Bind(self.OnClickChouJiang, self))

	self.last_check_time = nil
end

function FuBenGuardView:__delete()
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
	for k,v in pairs(self.rewarditem_list) do
		v:DeleteMe()
	end
	self.rewarditem_list = {}
end

function FuBenGuardView:LoadCallBack()
	FuBenCtrl.Instance:SetGuardRemind()
end

function FuBenGuardView:OpenCallBack()
	self:Flush()
end

function FuBenGuardView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["BottomArea"], FuBenTweenData.Down)
end

function FuBenGuardView:SelectItemCallback(cell)
	if cell == nil or cell.data == nil then return end
	local num = FuBenData.Instance:GetArmorMaxLevel()
	self.node_list["PageView"].page_view:JumpToIndex(cell.data - 1, 0, 5 / num)
	FuBenData.Instance:SetSelectLevel(cell.data - 1)
end

function FuBenGuardView:FlushScollView(index)
	if self.node_list["PageView"] then
		local num = FuBenData.Instance:GetArmorMaxLevel()
		self.node_list["PageView"].page_view:JumpToIndex(index, 0, 5 / num)
	end
end

function FuBenGuardView:GetData(i)
	local chapter = self.cur_page + i - 3
	if chapter > 10 then
		chapter = chapter - 10
	elseif chapter < 1 then
		chapter = chapter + 10
	end
	return chapter
end

function FuBenGuardView:GetNumberOfCells()
	-- FuBenData:GetArmorMaxLevel()
	return FuBenData.Instance:GetArmorMaxLevel()
end
function FuBenGuardView:RefreshListCell(data_index, cell)
	local guard_item = self.list[cell]
	if guard_item == nil then
		guard_item = FbGuardItem.New(cell.gameObject)
		guard_item:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		guard_item.parent_view = self
		self.list[cell] = guard_item
	end
	guard_item:SetData(data_index + 1)
	guard_item:IsSelect(data_index + 1 == self.cur_page)
end

function FuBenGuardView:OnValueChanged()
	local page = self.node_list["PageView"].page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		for k, v in pairs(self.list) do
			v:IsSelect(v.data == self.cur_page)
		end
		self:Flush()
	end
end

function FuBenGuardView:OnClickEnter(is_sd)
	if self.enter_count > 0 then
		if is_sd then
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ARMOR_FB, self.cur_page - 1)
		else
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ARMOR_FB, self.cur_page - 1)
			FuBenCtrl.Instance:CloseView()
		end
	else
		-- if self.can_buy_count > 0 then
		local ok_fun = function ()
			FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_BUY_JOIN_TIMES)
			-- FuBenCtrl.SendTowerDefendBuyJoinTimes()
			if is_sd then
				FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ARMOR_FB, self.cur_page - 1)
			else
				-- FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ARMOR_FB, self.cur_page - 1)
				-- FuBenCtrl.Instance:CloseView()
				-- FuBenCtrl.Instance:ColseExpBuyFBRoleInfo()
			end
		end
		local data_fun = function ()
			local data = {}
			local info = FuBenData.Instance:GetArmorDefendRoleInfo()
			data[2] = info.buy_join_times or 0			
			data[1] = FuBenData.Instance:GetArmorDefendBuyCost(data[2] + 1)
			data[3] = VipPower:GetParam(VipPowerId.armor_fb_buy_times)
			data[4] = VipPower:GetParam(VipPowerId.armor_fb_buy_times, true)
			return data
		end
		local data = data_fun()
		-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VipPowerId.armor_fb_buy_times, ok_fun, data_fun)
		-- else
		-- 	local count = VipPower.Instance:GetParam(VipPowerId.armor_fb_buy_times)
		-- 	local level, param = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.armor_fb_buy_times, count + 1)
		-- 	if level < 0 then
		-- 		SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.EnterLimitTip)
		-- 	else
		-- 		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TOWER_DEFEND_COUNT)
		-- 	end
		-- end
	end
end

function FuBenGuardView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(199)
end

function FuBenGuardView:OnSaodangEnter()
	if FuBenData.Instance:GetIsInFuBenScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.FuBenNotSaoDang)
		return
	end
	self:OnClickEnter(true)
end

function FuBenGuardView:OnClickBuy()
	-- if self.can_buy_count > 0 then
		local ok_fun = function ()
			-- FuBenCtrl.SendTowerDefendBuyJoinTimes()
			FuBenCtrl.Instance:SendArmorDefendRoleReq(ARMOR_DEFEND_REQTYPE.ARMOR_DEFEND_BUY_JOIN_TIMES)
		end
		local data_fun = function ()
			local data = {}
			local info = FuBenData.Instance:GetArmorDefendRoleInfo()
			data[2] = info.buy_join_times or 0
			data[1] = FuBenData.Instance:GetArmorDefendBuyCost(data[2]+ 1)
			data[3] = VipPower:GetParam(VipPowerId.armor_fb_buy_times)
			data[4] = VipPower:GetParam(VipPowerId.armor_fb_buy_times, true)
			return data
		end
		local data = data_fun()
		-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VipPowerId.armor_fb_buy_times, ok_fun, data_fun)
	-- else
	-- 	local count = VipPower.Instance:GetParam(VipPowerId.armor_fb_buy_times)
	-- 	local level, param = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.armor_fb_buy_times, count + 1)
	-- 	if level < 0 then
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.BuyLimitTip)
	-- 	else
	-- 		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TOWER_DEFEND_COUNT)
	-- 	end
	-- end
end
function FuBenGuardView:SetCurPage()
	local info = FuBenData.Instance:GetArmorDefendRoleInfo()
	if info and next(info) then
		self.cur_page = info.max_pass_level + 2
	end
	self.node_list["PageView"].page_view:Reload()
	self.node_list["PageView"].page_view:JumpToIndex(self.cur_page - 1)
end

function FuBenGuardView:OnFlush()
	local info = FuBenData.Instance:GetArmorDefendRoleInfo()
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg2(self.cur_page)
	if nil == chapter_cfg or nil == next(info) then return end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	local effect_level = other_cfg and other_cfg.effect_show
	self.enter_count = other_cfg.free_join_times + info.buy_join_times - info.join_times
	local max_times = other_cfg.free_join_times + info.buy_join_times
	local left_times_color = self.enter_count <= 0 and TEXT_COLOR.RED or TEXT_COLOR.GREEN
	self.node_list["TxtCanChallengeNum"].text.text = string.format(Language.FuBen.ChallengeTime, ToColorStr(self.enter_count, left_times_color), max_times)
	self.can_buy_count = VipPower.Instance:GetParam(VipPowerId.armor_fb_buy_times) - info.buy_join_times
	self.node_list["TxtCanBuyNum"].text.text = string.format(Language.FuBen.CanBuyNumber, self.can_buy_count)
	-- self.node_list["TexDefenseTitle"].text.text = chapter_cfg.fb_name
	self.node_list["TextDsc"].text.text = Language.FuBen.FuBenGuardDsc
	
	local butGray = self.cur_page > info.max_pass_level + 1 and info.max_pass_level < 9
	UI:SetButtonEnabled(self.node_list["BtnClear"], not butGray)
	UI:SetGraphicGrey(self.node_list["BtnClearText"], butGray)
	if self.cur_page == info.max_pass_level + 2 then --and info.personal_last_level_star == 3 
		UI:SetButtonEnabled(self.node_list["BtnClear"], false)
		UI:SetGraphicGrey(self.node_list["BtnClearText"], true)
	end
	for i,v in ipairs(self.item_list) do
		v:Flush()
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local level = self.cur_page - 1
	local btn_challenge_gray = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
	UI:SetButtonEnabled(self.node_list["BtnChallenge"], btn_challenge_gray)
	UI:SetGraphicGrey(self.node_list["BtnChallengeText"], not btn_challenge_gray)
	local item_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(self.cur_page)
	local item_cfg2 = FuBenData.Instance:GetTowerDefendChapterCfg2(self.cur_page)
	if item_cfg then
		-- self.rewarditem_list[1]:SetData({item_id = item_cfg.show_reward, num = 1, is_bind = 0})
		-- self.rewarditem_list[1]:SetShowStar(item_cfg.equiment_star)
		-- self.rewarditem_list[1]:SetQualityByColor(item_cfg.item_quality1)
		
		-- self.rewarditem_list[2]:SetData({item_id = item_cfg.show_reward_2, num = 1, is_bind = 0})
		-- self.rewarditem_list[2]:SetShowStar(item_cfg.equiment_star)
		-- self.rewarditem_list[2]:SetQualityByColor(item_cfg.item_quality2)
		for i,v in ipairs(self.rewarditem_list) do
			if item_cfg.item_list[i] then
				self.rewarditem_list[i]:SetActive(true)
				self.rewarditem_list[i]:SetData({item_id = tonumber(item_cfg.item_list[i])})
				-- self.rewarditem_list[i]:SetQualityByColor(item_cfg2["item_quality" .. i])
				-- print_error('@@@@@@@@@@',item_cfg2["item_quality" .. i])
			else
				self.rewarditem_list[i]:SetData(nil)
				self.rewarditem_list[i]:SetActive(false)
			end
			if item_cfg2["item_quality" .. i] then
				if effect_level ~= nil and tonumber(item_cfg2["item_quality" .. i]) >= tonumber(effect_level) then
					if item_cfg2["item_quality" .. i] == 4 then
						self.rewarditem_list[i]:ShowEquipOrangeEffect(true)
					elseif item_cfg2["item_quality" .. i] == 5 then
						self.rewarditem_list[i]:ShowEquipRedEffect(true)
					elseif item_cfg2["item_quality" .. i] == 6 then
						self.rewarditem_list[i]:ShowEquipFenEffect(true)
					end
				end
			end
			
		end

		self.node_list["PageView"].page_view:Reload()
		self:ShowChouJiangEffect()
	end
	
end

-- 跳转抽奖活动
function FuBenGuardView:OnClickChouJiang()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

-- 转盘抽奖按钮特效显示
function FuBenGuardView:ShowChouJiangEffect()
	if self.node_list["Effect"] then
		self.node_list["Effect"]:SetActive(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	end
end

-- 用于功能引导按钮
function FuBenGuardView:Challenge()
	return self.node_list["BtnChallenge"], BindTool.Bind(self.OnClickEnter, self)
end
-------------------------------------------------------------------------------------------
FbGuardItem = FbGuardItem or BaseClass(BaseRender)

function FbGuardItem:__init()
	-- self.item_list = {}
	-- for i = 1, 2 do
	-- 	local item = ItemCell.New()
	-- 	item:SetInstanceParent(self.node_list["Item" .. i])
	-- 	table.insert(self.item_list, item)
	-- end

	self.node_list["ImgItemBg"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function FbGuardItem:__delete()
	-- for k,v in pairs(self.item_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.item_list = {}
end

function FbGuardItem:SetData(data)
	self.data = data
	if self.data ~= nil then
		self:OnFlush()
	end
end

function FbGuardItem:SetClickCallback(handler)
	self.handler = handler
end

function FbGuardItem:OnClickItem()
	if self.handler then
		self.handler(self)
	end
end

function FbGuardItem:IsSelect(value)
	self.node_list["RawImgSelect"]:SetActive(value)
end

function FbGuardItem:OnFlush()
	if self.data == nil then return end
	self.node_list["TxtTitle"].text.text = string.format(Language.PersonalGoal.Chapter, self.data)
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg2(self.data)
	local info = FuBenData.Instance:GetArmorDefendRoleInfo()
	if nil == chapter_cfg or nil == next(info) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local role_level = vo and vo.level or 0
	local capability = vo and vo.capability or 0
	local bundle, asset = ResPath.GetFubenDefenseRawImage(chapter_cfg.level_pic)
	self.node_list["ImgItemBg"].raw_image:LoadSprite(bundle, asset)
	local level = self.data - 1
	local Is_HasPass = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
	local IsOpen = chapter_cfg.need_level <= role_level
	UI:SetGraphicGrey(self.node_list["ImgItemBg"], not Is_HasPass)
	self.node_list["LockPanel"]:SetActive(not Is_HasPass)
	self.node_list["OpenText"]:SetActive(not IsOpen)
	self.node_list["OpenText_1"]:SetActive(not IsOpen)
	self.node_list["OpenText_2"]:SetActive(not Is_HasPass)

	local color = chapter_cfg.need_level <= role_level and "89F201FF" or "f9463bFF"
	self.node_list["OpenText_1"].text.text = string.format(Language.TowerDefend.TowerChapterLimit1, color, PlayerData.GetLevelString(chapter_cfg.need_level))
	
	color = level <= info.max_pass_level + 1 and "89F201FF" or "f9463bFF"
	local layer = self.data - 1 > 0 and self.data - 1 or 1
	self.node_list["OpenText_2"].text.text = string.format(Language.TowerDefend.TowerChapterLimit2, color, layer)

	self.node_list["FightPower"]:SetActive(false)
	self.node_list["LockPanel2"]:SetActive(not Is_HasPass)
	
	local flag = chapter_cfg.capability and capability >= chapter_cfg.capability or false
	self.node_list["TxtZhanli_2"].text.text = flag and chapter_cfg.capability or ""
	self.node_list["TxtZhanli_1"].text.text = flag and "" or chapter_cfg.capability

	if info.max_pass_level + 1 < level then
		for i = 1, 3 do
			UI:SetGraphicGrey(self.node_list["ImgStar" .. i], true)
		end
		self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_unopen.png")
	elseif info.max_pass_level + 1 == level then
		if chapter_cfg.need_level <= role_level then
			for i = 1, 3 do
				-- UI:SetGraphicGrey(self.node_list["ImgStar" .. i], not (i <= info.personal_last_level_star))
			end
			self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_doing.png")
		else
			for i = 1, 3 do
				UI:SetGraphicGrey(self.node_list["ImgStar" .. i], true)
			end
			self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_unopen.png")
		end
	else
		for i = 1, 3 do
			UI:SetGraphicGrey(self.node_list["ImgStar" .. i], false)
		end
		self.node_list["ImgState"].image:LoadSprite("uis/views/fubenview/images_atlas", "defense_state_finish.png")
	end
end
