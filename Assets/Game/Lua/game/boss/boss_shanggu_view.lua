ShangguBossView = ShangguBossView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function ShangguBossView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(5)
	self.select_index = 1
	self.select_type = 2
	self.select_item_data = nil
	self.layer = 1
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.item_cell = {}
	self.show_hl_list = {}
	self.toggle_list = {}
	self.is_quick = false
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end
	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.toggle_list_delegate = self.node_list["ToggleGround"].list_simple_delegate
	self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))

end

function ShangguBossView:__delete()
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

function ShangguBossView:ClickScene(layer, is_click)
	self.is_first = false
	if is_click then
		self.layer = layer
		self:Flush()
		self:FlushFocusState(false)
		BossData.Instance:SetSeclectlayer(layer)
	end
end

function ShangguBossView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function ShangguBossView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()
	if least ~= nil and most ~= nil then
		return most - least + 1
	end
end

function ShangguBossView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(5, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
end

function ShangguBossView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(5, i)
		if my_level < cfg.show_min_lv then
			return cfg.boss_cengshu
		end
	end
	return MAX_FLOOR
end

function ShangguBossView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = ShangguBossToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end

function ShangguBossView:CloseBossView()
	self.select_index = 1
	self.select_type = 2
	self.is_first = true
end

function ShangguBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ShangguBossView:GetNumberOfCells()
	local list = BossData.Instance:GetSGAllBossByLayer(self.layer)
	return list and #list or 0
end

function ShangguBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = ShangguBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function ShangguBossView:ToActtack()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		for k,v in pairs(self.cell_list) do
			if v.index == self.select_index then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				GuajiCtrl.Instance:MoveToPos(self.select_scene_id, v.data.x_pos, v.data.y_pos, 10, 10)
				ViewManager.Instance:Close(ViewName.Boss)
				return
			end
		end
	end

	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	local need_level = BossData.Instance:GetSgNeedLevel(self.layer - 1)
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if need_level and my_level < need_level then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Boss.EnterWorldBossLevel, need_level))
		return
	end

	if Scene.Instance:GetSceneType() == SceneType.SG_BOSS then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.OutFubenTip)
		return 
	end

	local enter_comsun = BossData.Instance:GetSGBossEnterComsun()
	local tiky_id = BossData.Instance:GetSGBossTikyId()
	local num = ItemData.Instance:GetItemNumInBagById(tiky_id)

	if self.is_quick and num > 0 and num < enter_comsun then
		local rest_num = enter_comsun - num
		MarketCtrl.Instance:SendShopBuy(tiky_id, rest_num, 0, 0)
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, self.layer - 1, self.select_boss_id)
	elseif self.is_quick and num <= 0 then
		MarketCtrl.Instance:SendShopBuy(tiky_id, enter_comsun, 0, 0)
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, self.layer - 1, self.select_boss_id)
	elseif self.is_quick and num >= enter_comsun then
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, self.layer - 1, self.select_boss_id)
	elseif num >= enter_comsun then
		BossCtrl.Instance:SendShangGuBossReq(SGBOSS_REQ_TYPE.ENTER, self.layer - 1, self.select_boss_id)
	elseif num > 0 and num < enter_comsun then
		local rest_num = enter_comsun - num
		BossCtrl.Instance:SetEnterBossComsunData(tiky_id, rest_num, Language.Boss.EnterSGBoss, Language.Boss.EnterBossConsum, 
			function(tiky_id, rest_num, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(tiky_id, rest_num, is_bind, is_use)
			 if is_buy_quick then
				self.is_quick = true
			end
			self:FlushBtnTxt()
		end)
	elseif num <= 0 then
		BossCtrl.Instance:SetEnterBossComsunData(tiky_id, enter_comsun, Language.Boss.EnterSGBoss, Language.Boss.EnterBossConsum, 
			function(tiky_id, enter_comsun, is_bind, is_use, is_buy_quick)
			 MarketCtrl.Instance:SendShopBuy(tiky_id, enter_comsun, is_bind, is_use)
			if is_buy_quick then
				self.is_quick = true
			end
			self:FlushBtnTxt()
		end)
	end
end

function ShangguBossView:QuestionClick()
	local tips_id = 268 	--上古BOSS
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShangguBossView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function ShangguBossView:FlushBtnTxt()
	local enter_times, max_enter_times = BossData.Instance:GetSgBossEnterTimes()
	local left_times = max_enter_times - enter_times
	-- local tire, max_tire = BossData.Instance:GetSgBossTire()
	-- local tire_value = max_tire - tire
	local enter_comsun = BossData.Instance:GetSGBossEnterComsun()
	local tiky_id = BossData.Instance:GetSGBossTikyId()
	if tiky_id and enter_comsun then
		local has_num = ItemData.Instance:GetItemNumInBagById(tiky_id) or 0
		local color = 0
		if has_num >= enter_comsun then
			color = TEXT_COLOR.GREEN
		else
			color = TEXT_COLOR.RED
		end
		self.node_list["TxtEnterTimes"].text.text = string.format(Language.Boss.ShangguResetEnterTimes, color, has_num, enter_comsun)
	end
	self.node_list["TxtRestTime"].text.text = string.format(Language.Boss.ShangguResetEnter, left_times, max_enter_times)
	if nil == self.select_item_data then
		return
	end
	-- if self.select_type == BossData.MonsterType.Monster or self.select_type == BossData.MonsterType.Gather or self.select_type == BossData.MonsterType.HideBoss then
	-- 	local left_num = BossData.Instance:GetShangGuBossSceneOtherInfo(self.select_item_data.layer + 1, self.select_type)
	-- 	if left_num ~= nil then
	-- 		self.node_list["Txt_Num"].text.text = string.format(Language.Boss.LeftNum, self.select_item_data.boss_name, left_num)
	-- 	end
	-- else
	-- 	self.node_list["Txt_Num"].text.text = ""
	-- end

	if self.select_type == BossData.MonsterType.Monster or self.select_type == BossData.MonsterType.Gather then
		self.node_list["PanelRight"]:SetActive(false)
		self.node_list["Btn_buttons"]:SetActive(false)
		self.node_list["Img_text_type"]:SetActive(true)
		local bundle, asset = ResPath.GetBossNoPackImage("Txt_Monster_type_" .. self.select_type)
		self.node_list["Img_text_type"].image:LoadSprite(bundle, asset)
		self.node_list["Img_text_type"].image:SetNativeSize()
		self.node_list["Txt_type_content"].text.text = Language.Boss.ShowContent[self.select_type]
	else
		self.node_list["Btn_buttons"]:SetActive(true)
		self.node_list["PanelRight"]:SetActive(true)
		self.node_list["Img_text_type"]:SetActive(false)
	end
end

function ShangguBossView:FlushModel()
	if self.select_type ~= BossData.MonsterType.Gather then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			BossCtrl.Instance:SetBossDisPlay(monster_cfg)
			return
		end
	else
		local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
		if gather_cfg ~= nil and gather_cfg[self.select_boss_id] ~= nil then
			local res_id = gather_cfg[self.select_boss_id].resid
			local bundle, asset = ResPath.GetShangguBOXModel(res_id)
			BossCtrl.Instance:SetBoxDisPlay(bundle, asset, res_id)
			return
		end
	end
end

function ShangguBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU, self.select_boss_id, self.select_scene_id)
		end
	end
end

function ShangguBossView:FlushFocusState(is_show)
	if is_show ~= nil then
		self.node_list["focus_toggle"]:SetActive(is_show)
	end
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function ShangguBossView:OpenKillRecord()
	BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_SHANGGU, self.select_boss_id, self.select_scene_id)
end

function ShangguBossView:FlushItemList()
	local item_list = {}
	for k,v in pairs(self.cell_list) do
		if v.index == self.select_index then
			item_list = v.data.drop_item_list
		end
	end
	if nil == item_list then
		return
	end
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			item_list[k] = tonumber(item_list[k])
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_list[k])
				if item_cfg ~= nil then
					if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
						local data = BossData.Instance:GetShowEquipItemList(item_list[k])
						v:SetData(data)
					else
						v:SetData({item_id = item_list[k]})
					end
				end
		else
			v:SetData(nil)
		end
	end
end

function ShangguBossView:FlushInfoList()
	self:FlushItemList()
	self:FlushModel()
end

function ShangguBossView:FlushBossList()
	local boss_list = BossData.Instance:GetSGAllBossByLayer(self.layer)
	if boss_list ~= nil and #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
		self.select_item_data = boss_list[1]
		self.select_boss_id = self.select_item_data.boss_id
	end
	if self.node_list["BossList"].gameObject.activeInHierarchy then
		if self.select_index == 1 then
			self.node_list["BossList"].scroller:ReloadData(0)
		else
			self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function ShangguBossView:FlushToggles()
	self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ShangguBossView:OnFlush()
	self.select_index = 1
	self.select_type = 2
	if self.is_first == true then
		self:FlushFocusState(false)
		local index = BossData.Instance:GetSgCanGoLayer()
		self:ClickScene(index, true)
	else
		self:FlushBossList()
		self:FlushInfoList()
		self:FlushToggles()
		self:FlushBtnTxt()
	end
end

function ShangguBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ShangguBossView:SetSelectType(data_type)
	if data_type then
		self.select_type = data_type
	end
end

function ShangguBossView:SetSelectData(item_data)
	if item_data then
		self.select_item_data = item_data
	end
end

function ShangguBossView:GetSelectIndex()
	return self.select_index or 1
end

function ShangguBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function ShangguBossView:SetSelectSceneId(scene_id)
	self.select_scene_id = scene_id
end

function ShangguBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ShangguBossView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetSGAllBossByLayer(self.layer) or 0
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
ShangguBossItemCell = ShangguBossItemCell or BaseClass(BaseCell)

function ShangguBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function ShangguBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ShangguBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.boss_id)
		self.boss_view:SetSelectSceneId(self.data.scene_id)
		self.boss_view:SetSelectType(self.data.type)
		self.boss_view:SetSelectData(self.data)
		self.boss_view:FlushAllHL()
		self.boss_view:FlushFocusState(self.data.type == BossData.MonsterType.Boss)
		self.boss_view:FlushBtnTxt()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushItemList()
		self.boss_view:FlushModel()
	end
end

function ShangguBossItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level) 
		if self.data.type == BossData.MonsterType.Boss or self.data.type == BossData.MonsterType.HideBoss then
			local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
			self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		end
		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = monster_cfg.name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_8")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
		-- self.node_list["PanelInfo"]:SetActive(self.data.type == 0)
	end

	if self.data.type == BossData.MonsterType.Monster then
		local bundle, asset = ResPath.GetBoss("monster_item")
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		local left_num = BossData.Instance:GetShangGuBossSceneOtherInfo(self.data.layer + 1, self.data.type)
		self.node_list["TxtLevel"].text.text = string.format(Language.Boss.LeftMonsterNum, left_num)
		self.node_list["TxtRefreshTime"].text.text = ""
		self:UpdateKill(false)
	end

	if self.data.type == BossData.MonsterType.Gather then
		-- self.node_list["ImgName"].text.text = self.data.boss_name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_8")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
		local bundle_1, asset_1 = ResPath.GetBoss("gather_item")
		self.node_list["image"].raw_image:LoadSprite(bundle_1, asset_1)
		local left_num = BossData.Instance:GetShangGuBossSceneOtherInfo(self.data.layer + 1, self.data.type)
		self.node_list["TxtLevel"].text.text = string.format(Language.Boss.LeftMonsterNum, left_num)
		self.node_list["TxtRefreshTime"].text.text = ""
		self:UpdateKill(false)
	end

	if self.data.type == BossData.MonsterType.HideBoss then
		local hide_boss_num = BossData.Instance:GetShangGuBossSceneOtherInfo(self.data.layer + 1, self.data.type)
		-- self.node_list["Txt_HideBoss"]:SetActive(true)
		self.node_list["TxtLevel"].text.text = string.format(Language.Boss.LeftMonsterNum, hide_boss_num)
		if hide_boss_num == 0 then
			self:UpdateKill(true)
			-- self.node_list["Txt_HideBoss"].text.text = Language.Boss.KillToShowHideBoss
			self.node_list["Img_hasflush"]:SetActive(false)
			self.node_list["TxtRefreshTime"]:SetActive(true)
		else
			self:UpdateKill(false)
			-- self.node_list["Txt_HideBoss"].text.text = Language.Boss.HasRefreshHideBoss
			self.node_list["Img_hasflush"]:SetActive(true)
			self.node_list["TxtRefreshTime"]:SetActive(false)
		end
	else
		-- self.node_list["Txt_HideBoss"]:SetActive(false)
		local data = BossData.Instance:GetBossRefreshInfoByBossId(self.data.boss_id)
		local reflash_time = 0
		if nil ~= data then
			reflash_time = data.next_refresh_time
		end
		if self.data.type == BossData.MonsterType.Boss then
			if reflash_time > 0 then
				local time_tab = os.date("*t", reflash_time)
				if time_tab.min ~= 0 then
					str = string.format("%d%s%02d%s%s", time_tab.hour, Language.Boss.Hour, time_tab.min, Language.Common.Minute, Language.Boss.BossFlush)
				else
					str = string.format("%d%s%s", time_tab.hour, Language.Boss.Hour, Language.Boss.BossFlush)
				end
				self.node_list["TxtRefreshTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
				if nil == self.time_coundown then
					self.time_coundown = GlobalTimerQuest:AddTimesTimer(
							BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime()
					)
				end
				self:UpdateKill(true)
				self.node_list["Img_hasflush"]:SetActive(false)
				self.node_list["TxtRefreshTime"]:SetActive(true)
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
		end
	end

	self:FlushHL()
end

function ShangguBossItemCell:OnBossUpdate()
	local boss_info = BossData.Instance:GetBossRefreshInfoByBossId(self.data.boss_id)
	if boss_info then
		local reflash_time = boss_info.next_refresh_time
		local flag = reflash_time <= TimeCtrl.Instance:GetServerTime()
		local time_tab = os.date("*t", reflash_time)
		local str = ""
		if time_tab.min ~= 0 then
			str = string.format("%d%s%02d%s%s", time_tab.hour, Language.Boss.Hour, time_tab.min, Language.Common.Minute, Language.Boss.BossFlush)
		else
			str = string.format("%d%s%s", time_tab.hour, Language.Boss.Hour, Language.Boss.BossFlush)
		end

		if flag then
			self.node_list["Img_hasflush"]:SetActive(true)
			self.node_list["TxtRefreshTime"]:SetActive(false)
		else
			self.node_list["Img_hasflush"]:SetActive(false)
			self.node_list["TxtRefreshTime"]:SetActive(true)
			self.node_list["TxtRefreshTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
		end
		-- self.node_list["TxtRefreshTime"].text.text = flag and ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN) or ToColorStr(str, TEXT_COLOR.RED)
		self:UpdateKill(not flag)
	end
end

function ShangguBossItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function ShangguBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
ShangguBossToggle = ShangguBossToggle or BaseClass(BaseCell)

function ShangguBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function ShangguBossToggle:__delete()

end

function ShangguBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickScene(self.index, isOn)
	end
end

function ShangguBossToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end
