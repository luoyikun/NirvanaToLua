BabyBossView = BabyBossView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function BabyBossView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(4)
	self.select_index = 1
	-- self.select_monster_res_id = 0
	-- self.select_scene_id = 8201
	-- self.select_boss_id = 0
	self.scroll_change = false 			--记录画布是否在滚动中
	self.layer = 1
	self.boss_data = {}
	self.cell_list = {}
	self.toggle_list = {}
	self.show_hl_list = {}
	self.item_cell = {}
	self.is_first = true
	self.is_quick = false
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	-- self.toggle_list_delegate = self.node_list["ToggleGround"].list_simple_delegate
	-- self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	-- self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))
end

function BabyBossView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	self.is_first = false

	self.toggle_list_delegate = nil
	self.list_view_delegate = nil
end

function BabyBossView:CloseBossView()
	self.select_index = 1
	self.is_first = true
end

function BabyBossView:GetNumberOfCells()
	local baby_boss_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	return #baby_boss_list or 0
end

function BabyBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = BaoBaoBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function BabyBossView:ToActtack()
	BossData.Instance:SetBabyBossSelectInfo(self.select_scene_id, self.select_boss_id)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		MoveCache.end_type = MoveEndType.Auto
		local loc_x, loc_y = BossData.Instance:GetBabyBossLocationByBossID(self.select_scene_id, self.select_boss_id)
		GuajiCtrl.Instance:MoveToPos(self.select_scene_id, loc_x, loc_y, 10, 10)
		ViewManager.Instance:Close(ViewName.Boss)
		return
	end

	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local gold_cost, is_bind = BossData.Instance:GetBabyBossEnterCost()
	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
	-- 进入次数已达上限
	if enter_times >= enter_limit then
		if enter_limit < enter_times_max_vip then
			-- TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BABYBOSS_ENTER_TIMES)
			local data_fun = function ()
				local data = {}
				data[2] = 0
				data[1] = 0
				data[3] = VipPower:GetParam(VIPPOWER.BABYBOSS_ENTER_TIMES)
				data[4] = VipPower:GetParam(VIPPOWER.BABYBOSS_ENTER_TIMES, true)
				return data
			end
			local data = data_fun()
			BossCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.BABYBOSS_ENTER_TIMES, nil, data_fun)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BabyBossEnterTimesLimit)
		end
		return
	end

	local need_item_id, need_item_num = BossData.Instance:GetBabyEnterCondition()
	-- BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterBaby, Language.Boss.EnterBossConsum, function()
	-- 	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	-- end)
	self.is_quick = BossData.Instance:GetIsAutoBuy("baby_boss")
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
	local item_shop_cfg = ShopData.Instance:GetShopItemCfg(need_item_id)
	local item_price = 0
	local is_cost_bind = 1
	if nil ~= item_shop_cfg.bind_gold and item_shop_cfg.bind_gold ~= 0 then
		item_price = item_shop_cfg.bind_gold
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.bind_gold >= need_item_num * item_price then
		is_cost_bind = 1
	else
		is_cost_bind = 0
	end
	if self.is_quick and num > 0 and num < need_item_num then
		local rest_num = need_item_num - num
		MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_cost_bind, 0)
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif self.is_quick and num <= 0 then
		MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_cost_bind, 0)
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif self.is_quick and num >= need_item_num then
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif num >= need_item_num then
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, self.select_scene_id, self.select_boss_id)
	elseif num > 0 and num < need_item_num then
		local rest_num = need_item_num - num
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
			 if is_buy_quick then
				BossData.Instance:SetIsAutoBuy("baby_boss")
			end
		end)
	elseif num <= 0 then
		BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
			function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
			if is_buy_quick then
				BossData.Instance:SetIsAutoBuy("baby_boss")
			end
		end)
	end
end

function BabyBossView:OpenKillRecord()
	BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO, self.select_boss_id, self.select_scene_id)
end

function BabyBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_BAOBAO, self.select_boss_id, self.select_scene_id)
		end
	end
end

function BabyBossView:FlushFocusState()
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function BabyBossView:QuestionClick()
	local tips_id = 270 	--宝宝BOSS
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BabyBossView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function BabyBossView:FlushModel()
	local boss_data = BossData.Instance:GetMonsterInfo(self.select_boss_id)
	BossCtrl.Instance:SetBossDisPlay(boss_data)
end

function BabyBossView:FlushToggleHL()
end

function BabyBossView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function BabyBossView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()
	if least ~= nil and most ~= nil then
		return most - least + 1
	end
end

function BabyBossView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(4, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
end

function BabyBossView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(4, i)
		if my_level < cfg.show_min_lv then
			return cfg.boss_cengshu
		end
	end
	return MAX_FLOOR
end

function BabyBossView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = BaoBaoBossToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end

function BabyBossView:ClickBoss(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetBabyBossListClient()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetBabyBossCanToSceneLevel(v.scene_id)
				if not can_go then
					-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(min_level)
					-- local level_text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
					local level_text = PlayerData.GetLevelString(min_level)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v.scene_id
				local boss_list = BossData.Instance:GetBabyBossDataListByLayer(layer)
				self.select_boss_id = boss_list[1] and boss_list[1].boss_id
				break
			end
		end
		if self.is_first then
			self.is_first = false
		end
		self.select_index = 1
		self.layer = layer
		self:Flush()
	end
end

function BabyBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function BabyBossView:FlushItemList()
	local item_list = BossData.Instance:GetBabyBossFallList(self.select_boss_id)
	if nil == item_list then
		return
	end
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			local temp_list = Split(item_list[k], ",")
			local reward_item_id = tonumber(temp_list[1])
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(reward_item_id)
			if item_cfg ~= nil then
				if tonumber(temp_list[3]) == 1 then
					v:SetShowOrangeEffect(true)
				else
					v:SetShowOrangeEffect(false)
				end

				if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
					local data = BossData.Instance:GetShowEquipItemList(reward_item_id)
					v:SetData(data)
				else
					v:SetData({item_id = reward_item_id})
				end

				if tonumber(temp_list[2]) == 1 then
					v:SetShowZhuanShu(true)
				elseif tonumber(temp_list[2]) == 2 then
					v:SetShowDecorationTAG(true)
				else
					v:SetShowDecorationTAG(false)
					v:SetShowZhuanShu(false)
				end
			end
		else
			v:SetData(nil)
		end
	end
end

function BabyBossView:CheckFrameIsOpen()
	for i = 1, 3 do
		if self.toggle_list[i].toggle.isOn then
			self.toggle_list[i].toggle.isOn = false
			break
		end
	end
end

function BabyBossView:FlushInfoList()
	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	local left_times = enter_limit - enter_times
	if left_times <= 0 then
		left_times = ToColorStr(left_times, TEXT_COLOR.RED)
	else
		left_times = ToColorStr(left_times, TEXT_COLOR.GREEN)
	end
	local max_text = ToColorStr(tostring(enter_limit), TEXT_COLOR.GREEN)
	self.node_list["Txt_Entertimes"].text.text = Language.Boss.ResetEnterTimes .. left_times .. " / " .. max_text .. " " .. Language.Boss.VipAddEnterTimesTip
	if self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
	end
end

function BabyBossView:FlushBossList()
	local boss_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end
	if self.node_list["BossList"].gameObject.activeInHierarchy then
		self.node_list["BossList"].scroller:ReloadData(0)
	end
end

function BabyBossView:FlushToggles()
	local num = self:GetCanShowFloor()
	if self.node_list["ToggleGround"] and num > 0 then
		self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BabyBossView:OnFlush()
	self.select_index = 1
	local boss_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	self.select_boss_id = boss_list[1] and boss_list[1].boss_id or 0
	if self.is_first == true then
		-- local index = BossData.Instance:GetBabyBossCanGoLevel()
		local index = 1
		self:ClickBoss(index, true)
		self.is_first = false
	else
		self:FlushBossList()
		self:FlushInfoList()
		self:FlushFocusState()
		self:FlushToggleHL()
		-- self:FlushToggles()
		self:FlushTickNum()
	end
end

function BabyBossView:FlushTickNum()
	local need_item_id, need_item_num = BossData.Instance:GetBabyEnterCondition()
	if need_item_id and need_item_num then
		local has_num = ItemData.Instance:GetItemNumInBagById(need_item_id) or 0
		local color = 0
		if has_num >= need_item_num then
			color = TEXT_COLOR.GREEN
		else
			color = TEXT_COLOR.RED
		end
		self.node_list["TxtNeedTiky"].text.text = string.format(Language.Boss.Needtiky, color, has_num, need_item_num)
	end
end

function BabyBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BabyBossView:GetSelectIndex()
	return self.select_index or 1
end

function BabyBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function BabyBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function BabyBossView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetBabyBossDataListByLayer(self.layer) or 0
	local hide_num = max_num - 5
	if hide_num < 0 then
		return
	elseif hide_num == 0 then
		self.node_list["BossList"].scroll_rect.verticalNormalizedPosition = 0
		return
	end
	local differ = 4 / hide_num
	if self.node_list["BossList"].gameObject.activeInHierarchy then
		if self.node_list["BossList"].scroll_rect.verticalNormalizedPosition - differ <= 0 then
			self.node_list["BossList"].scroll_rect.verticalNormalizedPosition = 0
			return
		end
		self.node_list["BossList"].scroll_rect.verticalNormalizedPosition = self.node_list["BossList"].scroll_rect.verticalNormalizedPosition - differ
	end
end

------------------------------------------------------------------------------
BaoBaoBossItemCell = BaoBaoBossItemCell or BaseClass(BaseCell)

function BaoBaoBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function BaoBaoBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BaoBaoBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.boss_id)
		self.boss_view:FlushAllHL()
		self.boss_view:FlushFocusState()
		if self.data == nil or select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function BaoBaoBossItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level) 
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)

		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = monster_cfg.name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_7")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
	end

	self.next_refresh_time = self.data.next_refresh_time
	local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
	if diff_time <= 0 then
		self:UpdateKill(false)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	else
		self:UpdateKill(true)
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
		self:OnBossUpdate()
	end
	self:FlushHL()
end

function BaoBaoBossItemCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED)
	if time <= 0 then
		self:UpdateKill(false)
		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	else
		self:UpdateKill(true)
		self.node_list["Img_hasflush"]:SetActive(false)
		self.node_list["TxtRefreshTime"]:SetActive(true)
		self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED)
	end
end

function BaoBaoBossItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function BaoBaoBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
BaoBaoBossToggle = BaoBaoBossToggle or BaseClass(BaseCell)
function BaoBaoBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function BaoBaoBossToggle:__delete()

end

function BaoBaoBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickBoss(self.index, isOn)
	end
end

function BaoBaoBossToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end