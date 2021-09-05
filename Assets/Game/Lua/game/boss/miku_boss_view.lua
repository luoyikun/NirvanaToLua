MikuBossView = MikuBossView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function MikuBossView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(1)
	self.select_index = 1
	self.select_monster_res_id = 0
	self.layer = 1
	self.boss_data = {}
	self.cell_list = {}
	self.toggle_list = {}
	self.show_hl_list = {}
	self.item_cell = {}
	self.is_first = true
	--引导用按钮
	self.fatigue_guide = self.node_list["FatigueGuide"]

	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	self.toggle_list_delegate = self.node_list["ToggleGround"].list_simple_delegate
	self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["QuestionBtn2"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.BuyPiLaoClick, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))
	self.node_list["BossTouziViewIcon"].button:AddClickListener(BindTool.Bind(self.OnClickBossTouzi, self))

	self.node_list["Txt_peace_tip"].text.text = Language.Boss.MiKuPeaceTip2
end

function MikuBossView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end

	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end

	self.item_cell = {}
	self.is_first = false

end

function MikuBossView:CloseBossView()
	self.select_index = 1
	self.is_first = true

	if self.day_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.day_count_down)
		self.day_count_down = nil
	end

	if self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end
end

function MikuBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["BossTouziViewIcon"], Vector3(-412, 50, 0) , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function MikuBossView:GetNumberOfCells()
	return #BossData.Instance:GetMikuBossList(self.select_scene_id) or 0
end

function MikuBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = MikuBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function MikuBossView:ToActtack()
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

	if TaskData.Instance:GetTaskAcceptedIsBeauty() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotEnterFb)
		return
	end

	if not BossData.Instance:IsMikuBossScene(scene_id) and not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level or 0
	local can_go, min_level = BossData.Instance:GetCanToSceneLevel(self.select_scene_id)
	if min_level and min_level > my_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Boss.LeastEnterLevel, min_level))
		return
	end
	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_scene_id)
end

function MikuBossView:OpenKillRecord()
	BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id)
end

function MikuBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id)
		end
	end
end

function MikuBossView:BuyPiLaoClick()
	local cfg = BossData.Instance.boss_family_cfg
	if cfg ~= nil and cfg.other[1] ~= nil and cfg.other[1].add_weary_item ~= nil then
		local item_id = cfg.other[1].add_weary_item
		local item_index = ItemData.Instance:GetItemIndex(item_id)

		PackageCtrl.Instance:SendUseItem(item_index, 1)
	end
end

function MikuBossView:FlushFocusState()
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function MikuBossView:QuestionClick()
	local tips_id = 142
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MikuBossView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function MikuBossView:FlushModel()
	local boss_data = BossData.Instance:GetMonsterInfo(self.select_boss_id)
	if boss_data ~= nil then
		BossCtrl.Instance:SetBossDisPlay(boss_data)
	end

end

function MikuBossView:FlushToggleHL()
end

function MikuBossView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function MikuBossView:GetCanShowFloor()
	local num = self:GetCengNum()
	return num
end

function MikuBossView:GetCengNum()
	self.ceng_cfg_list = {}
	local num = 0
	local most_ceng = 0
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(1, i)
		if cfg then
			if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
				num = num + 1
				most_ceng = cfg.boss_cengshu
				table.insert(self.ceng_cfg_list, cfg)
			end
		end
	end
	if most_ceng < MAX_FLOOR then
		num = num + 1
		local cfg = BossData.Instance:GetBossMiniMapCfg(1, most_ceng + 1)
		table.insert(self.ceng_cfg_list, cfg)
	end
	return num
end


function MikuBossView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	if self.ceng_cfg_list[data_index] and self.ceng_cfg_list[data_index].boss_cengshu then
		data_index = self.ceng_cfg_list[data_index].boss_cengshu
		local toggle_cell = self.toggle_list[cell]
		if nil == toggle_cell then
			toggle_cell = MikuBossToggle.New(cell.gameObject)
			toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
			toggle_cell.boss_view = self
			self.toggle_list[cell] = toggle_cell
		end
		toggle_cell:SetIndex(data_index)
		toggle_cell:Flush()
	end
end

function MikuBossView:ClickBoss(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetMikuBossListClient()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
				if not can_go then
					local text = string.format(Language.Boss.BossLimit, PlayerData.GetLevelString(min_level))
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v.scene_id
				local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
				self.select_boss_id = boss_list[1] and boss_list[1].bossID
				break
			end
		end

		self.select_index = 1
		self.layer = layer
		if self.is_first then
			self.is_first = false
		end
		self:Flush()
	end
end

function MikuBossView:RefeshEliteDes()
	-- local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
	-- for k,v in pairs(boss_list) do
	-- 	if v.bossID == self.select_boss_id then
	-- 		self.node_list["TxtMaxLevel"]:SetActive(my_level > v.max_lv)
	-- 	end
	-- end
end

function MikuBossView:FlushItemList()
	local item_list = BossData.Instance:GetMikuBossFallList(self.select_boss_id)
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
						local data = BossData.Instance:GetShowEquipItemList2(reward_item_id)
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

function MikuBossView:FlushRemainCount()
	local boss_data = BossData.Instance
	local boss_id_list = boss_data:GetBossMikuIdList()
	local text = ""
	for k,v in pairs(boss_id_list) do
		local count = boss_data:GetBossMikuRemainEnemyCount(v, self.select_scene_id)
		if count <= 0 then
			text = ToColorStr(tostring(count), TEXT_COLOR.RED)
		else
			text = ToColorStr(tostring(count), TEXT_COLOR.GREEN)
		end
	end
end

function MikuBossView:CheckFrameIsOpen()
	for i = 1, 3 do
		if self.toggle_list[i].toggle.isOn then
			self.toggle_list[i].toggle.isOn = false
			break
		end
	end
end

function MikuBossView:FlushInfoList()
	-- local is_peace = self.layer == 1
	-- if not is_peace then
		local boss_data = BossData.Instance
		local max_wearry = boss_data:GetMikuBossMaxWeary()
		local weary = max_wearry - boss_data:GetMikuBossWeary()
		local pi_lao_text = ""
		if weary <= 0 then
			pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
		else
			pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.GREEN)
		end
		local max_text = ToColorStr(tostring(max_wearry), TEXT_COLOR.GREEN)
		self.node_list["Txtpilao"].text.text = string.format(Language.Boss.MiKiBossPiLaoValue, pi_lao_text .. " / " .. max_text)
	-- end
	self.node_list["Node_peace_text"]:SetActive(false)
	self.node_list["Node_nomal_text"]:SetActive(true)

	local cfg = BossData.Instance.boss_family_cfg
	if cfg ~= nil and cfg.other[1] ~= nil and cfg.other[1].add_weary_item ~= nil then
		local item_id = cfg.other[1].add_weary_item
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		self.node_list["BtnAdd"]:SetActive(num > 0)
	end

	local red_point_bosstouzi = false
	local data_list = KaifuActivityData.Instance:GetBossTouZiDataList()
	for i, v in ipairs(data_list) do
		if not InvestData.Instance:CheckIsFetchedBossByID(v.index + 1) and InvestData.Instance:CheckIsActiveBossByID(v.index + 1) then
			red_point_bosstouzi = true
		end
	end
	local all_reward = KaifuActivityData.Instance:IsAllFetchBossTouZi() == true
	local is_open_activity = OpenFunData.Instance:CheckIsHide("kaifuactivityview")
	local has_buy = InvestData.Instance:CheckIsActiveBossByID(1)
	local differ_time = self:GetDifferTimeOpenSever()
	local can_show = false
	if has_buy then
		can_show = true
		self.node_list["refresh_tips"]:SetActive(false)
		self.node_list["effect"]:SetActive(false)
	else
		if differ_time > 0 then
			can_show = true
		end
	end
	self.node_list["IconRemind"]:SetActive(red_point_bosstouzi)

	if red_point_bosstouzi and self.count_down_quest == nil then
		self.count_down_quest = GlobalTimerQuest:AddRunQuest(function ()
			self.node_list["Icon"].animator:SetTrigger("shake")
		end, 2)
	end

	if not red_point_bosstouzi and self.count_down_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_quest)
		self.count_down_quest = nil
	end

	self.node_list["BossTouziViewIcon"]:SetActive(can_show and is_open_activity and not all_reward)

	if self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
		-- self:RefeshEliteDes()
	end
end

function MikuBossView:SetReMainTime()
	local diff_time = self:GetDifferTimeOpenSever()
	local has_buy = InvestData.Instance:CheckIsActiveBossByID(1)
	if self.day_count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				self.node_list["BossTouziViewIcon"]:SetActive(false)
				self.node_list["refresh_tips"].text.text = ""
				if self.day_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.day_count_down)
					self.day_count_down = nil
				end
				return
			end
			local time_str = TimeUtil.FormatSecond(left_time, 18)
			self.node_list["refresh_tips"].text.text = time_str
		end

		diff_time_func(0, diff_time)
		if not has_buy then
			if self.day_count_down == nil then
				self.day_count_down = CountDown.Instance:AddCountDown(
					diff_time, 0.5, diff_time_func)
			end
		else
			if self.day_count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.day_count_down)
				self.day_count_down = nil
			end
			self.node_list["refresh_tips"]:SetActive(false)
		end
	end
end

function MikuBossView:GetDifferTimeOpenSever()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local differ_day = 4 - server_open_day
	local str = os.date("%X", cur_time)
	local time_tab = Split(str, ":")
	local time = tonumber(time_tab[1]) * 3600 + tonumber(time_tab[2]) * 60 + tonumber(time_tab[3])
	local diff_time = 86400 * differ_day - time
	return diff_time or 0
end

function MikuBossView:FlushBossList()
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end
	if self.node_list["BossList"] and self.node_list["BossList"].gameObject.activeInHierarchy then
		self.node_list["BossList"].scroller:ReloadData()
	end
	self:JumpToNoFallBoss()
	self:FlushAllHL()
end

function MikuBossView:JumpToNoFallBoss()
	if nil == self.boss_data or next(self.boss_data) == nil then
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in ipairs(self.boss_data) do
		if my_level <= v.max_lv then
			self.select_index = k
			self.select_boss_id = v.bossID
			break
		end
	end
	if self.node_list["BossList"] and self.node_list["BossList"].gameObject.activeInHierarchy then
		self.node_list["BossList"].scroller:JumpToDataIndex(self.select_index - 1)
	end
end

function MikuBossView:FlushToggles()
	local num = self:GetCanShowFloor()
	if self.node_list["ToggleGround"] and num > 0 then
		self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MikuBossView:OnFlush()
	self.select_index = 1
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	self.select_boss_id = boss_list[1] and boss_list[1].bossID
	if self.is_first == true then
		local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
		-- self.node_list["ToggleGround"].scroller:ReloadData(index / MAX_FLOOR)
		self:ClickBoss(index,true)
	else
		self:FlushBossList()
		self:FlushInfoList()
		self:FlushFocusState()
		self:FlushToggleHL()
		self:FlushToggles()
		-- self:RefeshEliteDes()
	end
end

function MikuBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function MikuBossView:GetSelectIndex()
	return self.select_index or 1
end

function MikuBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function MikuBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function MikuBossView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetMikuBossList(self.select_scene_id) or 0
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

function MikuBossView:OnClickBossTouzi()
	ViewManager.Instance:Open(ViewName.TouziActivityView, 67)
end

------------------------------------------------------------------------------
MikuBossItemCell = MikuBossItemCell or BaseClass(BaseCell)

function MikuBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function MikuBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function MikuBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushAllHL()
		self.boss_view:FlushFocusState()
		if self.data == nil or select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function MikuBossItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level)
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		self.node_list["Img_rare"]:SetActive(monster_cfg.boss_type == 3)
		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = monster_cfg.name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_2")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)

		-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
		-- self.node_list["Img_tag_diaoluo"]:SetActive(my_level > self.data.max_lv)
	end

	self.next_refresh_time = BossData.Instance:GetMikuBossRefreshTime(self.data.bossID, self.data.scene_id)
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

function MikuBossItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function MikuBossItemCell:OnBossUpdate()
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

function MikuBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
MikuBossToggle = MikuBossToggle or BaseClass(BaseCell)

function MikuBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function MikuBossToggle:__delete()

end

function MikuBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickBoss(self.index, isOn)
	end
end

function MikuBossToggle:OnFlush()
	-- if self.index == 1 then
	-- 	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.PeaceFloor)
	-- else
	-- 	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index -1)
	-- end
	-- if self.index == 1 then
	-- 	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.PeaceFloor)
	-- else
	-- 	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index - 1)
	-- end
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end