DabaoBossView = DabaoBossView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function DabaoBossView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(2)
	self.select_index = 1
	self.select_monster_res_id = 0
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.layer = 1
	self.item_cell = {}
	self.show_hl_list = {}
	self.toggle_list = {}
	self.is_quick = false
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetShowOrangeEffect(true)
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end
	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	-- self.toggle_list_delegate = self.node_list["ToggleGround"].list_simple_delegate
	-- self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	-- self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	-- self.node_list["AddButton"].button:AddClickListener(BindTool.Bind(self.OnClickBuyEnterTimes, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))

end

function DabaoBossView:__delete()
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
end

function DabaoBossView:ClickScene(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetDabaoBossClientCfg()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
				if not can_go then
					local text = string.format(Language.Boss.BossLimit, PlayerData.GetLevelString(min_level))
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v.scene_id
				break
			end
		end
		if self.is_first then
			self.is_first = false
		end
		self.layer = layer
		self:Flush()
	end
end

function DabaoBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function DabaoBossView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function DabaoBossView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()
	if least ~= nil and most ~= nil then
		return most - least + 1
	end
end

function DabaoBossView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(2, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
end

function DabaoBossView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(2, i)
		if my_level < cfg.show_min_lv then
			return cfg.boss_cengshu
		end
	end
	return MAX_FLOOR
end

function DabaoBossView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = DaBaoBossToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end

function DabaoBossView:OnClickBuyEnterTimes()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if BossData.Instance:GetCanBuyDaBaoEnter() and vip_level~= 15 then
		TipsCtrl.Instance:ShowLockVipView(15)
		return
	end
	local call_back = function ()
		BossCtrl.Instance:SendBossFamilyOperate(BOSS_FAMILY_OPERATE_TYPE.DA_BAO_BUY_ENTER_COUNT)
	end
	local cost = BossData.Instance:GetDaBaoEnterTimesCost()
	local describe = Language.Boss.BossBuyEnterTime

	local data_fun = function ()
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		local data = {}
		data[2] = BossData.Instance:GetDabaoButCount()
		data[1] = BossData.Instance:GetDaBaoEnterTimesCost()
		data[3] = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.DABAO_TIMES]
		data[4] = VipPower:GetParam(VIPPOWER.DABAO_TIMES, true)
		return data
	end
	local data = data_fun()
	FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.DABAO_TIMES, call_back, data_fun, 1, describe)

	-- TipsCtrl.Instance:ShowCommonAutoView("BuyDaBaoEnterTimes", describe, call_back, nil, nil, nil, nil, nil, true)
end

function DabaoBossView:CloseBossView()
	self.select_index = 1
	self.is_first = true
end

function DabaoBossView:GetNumberOfCells()
	return #BossData.Instance:GetDaBaoBossList(self.select_scene_id) or 0
end

function DabaoBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = DabaoBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function DabaoBossView:ToActtack()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		for k,v in pairs(self.cell_list) do
			if v.index == self.select_index then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(self.select_scene_id, v.data.born_x, v.data.born_y, 10, 10)
				ViewManager.Instance:Close(ViewName.Boss)
				return
			end
		end
	end

	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	if not BossData.Instance:GetCanToSceneLevel(self.select_scene_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.NotEnoughLevel)
		return
	end

	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	-- local _, _, need_item_id, need_item_num = BossData.Instance:GetBossVipLismit(self.select_scene_id)
	local enter_count = BossData.Instance:GetDabaoBossCount()
	local max_count = BossData.Instance:GetDabaoFreeTimes()
	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.DABAO_TIMES)
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.DABAO_TIMES, VipData.Instance:GetVipMaxLevel())
	local free_enter_times = BossData.Instance:GetDabaoFreeEnterTimes()
	local need_item_id, need_item_num = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)

	if free_enter_times > 0 then
		BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		return
	end
	if enter_count <= max_count then
		if enter_count >= enter_limit then
			if enter_limit < enter_times_max_vip then
				-- TipsCtrl.Instance:ShowLockVipView(VIPPOWER.DABAO_TIMES)
				local data_fun = function ()
					local data = {}
					data[2] = 0
					data[1] = 0
					data[3] = VipPower:GetParam(VIPPOWER.DABAO_TIMES)
					data[4] = VipPower:GetParam(VIPPOWER.DABAO_TIMES, true)
					return data
				end
				local data = data_fun()
				BossCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.DABAO_TIMES, nil, data_fun)
			else
				TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BabyBossEnterTimesLimit)
			end
			return
		end
		local num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		self.is_quick = BossData.Instance:GetIsAutoBuy("dabao_boss")
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
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif self.is_quick and num <= 0 then
			MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_cost_bind, 0)
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif self.is_quick and num >= need_item_num then
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif num >= need_item_num then
			BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		elseif num > 0 and num < need_item_num then
			local rest_num = need_item_num - num
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, rest_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, rest_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(need_item_id, rest_num, is_bind, is_use)
					if is_buy_quick then
						BossData.Instance:SetIsAutoBuy("dabao_boss")
					end
					self:FlushBtnTxt()
				end)
		elseif num <= 0 then
			BossCtrl.Instance:SetEnterBossComsunData(need_item_id, need_item_num, Language.Boss.EnterDabao, Language.Boss.EnterBossConsum, 
				function(need_item_id, need_item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(need_item_id, need_item_num, is_bind, is_use)
					if is_buy_quick then
						BossData.Instance:SetIsAutoBuy("dabao_boss")
					end
					self:FlushBtnTxt()
				end)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.BabyBossEnterTimesLimit)
	end
end

function DabaoBossView:QuestionClick()
	local tips_id = 267 	--打宝BOSS
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function DabaoBossView:OpenBossDrop()
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
	-- ViewManager.Instance:Open(ViewName.DropView)
end

function DabaoBossView:FlushBtnTxt()
	-- local min_level = BossData.Instance:GetConditionLevelByScene(self.select_scene_id)
	-- self.node_list["TxtLevelCondition"].text.text = string.format(Language.Boss.BossLimit, min_level)
	local enter_count = BossData.Instance:GetDabaoBossCount()
	local max_count = BossData.Instance:GetDabaoFreeTimes()
	local left_count = max_count - enter_count
	local free_enter_times = BossData.Instance:GetDabaoFreeEnterTimes()
	if free_enter_times <= 0 then
		self.node_list["TxtLevelCondition"]:SetActive(true)
		self.node_list["Txt_free_times"]:SetActive(false)
		free_enter_times = 0
		-- local _, _, need_item_id, need_item_num = BossData.Instance:GetBossVipLismit(self.select_scene_id)
		local need_item_id, need_item_num = BossData.Instance:GetDabaoBossEnterCostIdAndNumByTimes(enter_count)
		local bag_num = ItemData.Instance:GetItemNumInBagById(need_item_id)
		if bag_num < need_item_num then
			bag_num = ToColorStr(bag_num, TEXT_COLOR.RED)
		else
			bag_num = ToColorStr(bag_num, TEXT_COLOR.GREEN)
		end
		self.node_list["TxtLevelCondition"].text.text = string.format(Language.Boss.DabaoBossTicket, bag_num, need_item_num)
	else
		self.node_list["TxtLevelCondition"]:SetActive(false)
		self.node_list["Txt_free_times"]:SetActive(true)
		self.node_list["Txt_free_times"].text.text = string.format(Language.Boss.FreeToAttackTimes, free_enter_times)
	end
	if left_count <= 0 then
		left_count = ToColorStr(left_count, TEXT_COLOR.RED)
	else
		left_count = ToColorStr(left_count, TEXT_COLOR.GREEN)
	end
	max_count = ToColorStr(max_count, TEXT_COLOR.GREEN)
	self.node_list["EnterTimes"].text.text = Language.Boss.ResetEnterTimes .. left_count .. " / " .. max_count .. " " .. Language.Boss.VipAddEnterTimesTip
end

function DabaoBossView:FlushModel()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
	if monster_cfg then
		BossCtrl.Instance:SetBossDisPlay(monster_cfg)
	end
end

function DabaoBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_boss_id, self.select_scene_id)
		end
	end
end

function DabaoBossView:FlushFocusState()
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function DabaoBossView:OpenKillRecord()
	BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_boss_id, self.select_scene_id)
end

function DabaoBossView:FlushItemList()
	local item_list = BossData.Instance:GetDabaoBossRewards(self.select_boss_id)
	if nil == item_list then
		return
	end
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			local temp_list = Split(item_list[k], ",")
			local reward_item_id = tonumber(temp_list[1])
			item_list[k] = tonumber(item_list[k])
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

function DabaoBossView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
	end
end

function DabaoBossView:FlushBossList()
	local boss_list = BossData.Instance:GetDaBaoBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
		self.select_boss_id = boss_list[1].bossID
	end
	if self.node_list["BossList"].gameObject.activeInHierarchy then
		if self.select_index == 1 then
			self.node_list["BossList"].scroller:ReloadData(0)
		else
			self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function DabaoBossView:FlushToggles()
	local num = self:GetCanShowFloor()
	if self.node_list["ToggleGround"] and num > 0 then
		self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function DabaoBossView:OnFlush()
	self.select_index = 1
	if self.is_first == true then
		-- local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO)
		local index = 1
		self:ClickScene(index, true)
	else
		self:FlushBossList()
		self:FlushInfoList()
		-- self:FlushToggles()
		self:FlushBtnTxt()
	end
	self:FlushFocusState()
end

function DabaoBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function DabaoBossView:GetSelectIndex()
	return self.select_index or 1
end

function DabaoBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function DabaoBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function DabaoBossView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetDaBaoBossList(self.select_scene_id) or 0
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

----------------------------------------------------------------------
DabaoBossItemCell = DabaoBossItemCell or BaseClass(BaseCell)

function DabaoBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function DabaoBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DabaoBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushAllHL()
		self.boss_view:FlushFocusState()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushItemList()
		self.boss_view:FlushModel()
	end
end

function DabaoBossItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level) 
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)

		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = monster_cfg.name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_5")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
	end

	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time > 0 then
		self:UpdateKill(reflash_time > TimeCtrl.Instance:GetServerTime())
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:UpdateKill(true)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self:UpdateKill(false)
		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	end
	self:FlushHL()
end

function DabaoBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
	local time = math.max(0, reflash_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self:UpdateKill(false)
		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	else
		self:UpdateKill(true)
		self.node_list["Img_hasflush"]:SetActive(false)
		self.node_list["TxtRefreshTime"]:SetActive(true)
		self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED)
	end
end

function DabaoBossItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
end

function DabaoBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
DaBaoBossToggle = DaBaoBossToggle or BaseClass(BaseCell)

function DaBaoBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function DaBaoBossToggle:__delete()

end

function DaBaoBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickScene(self.index, isOn)
	end
end

function DaBaoBossToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end
