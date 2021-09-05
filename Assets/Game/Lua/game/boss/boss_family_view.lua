BossFamilyView = BossFamilyView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function BossFamilyView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(0)
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9000
	self.select_clent_scene_id = 9000
	self.select_boss_id = 10
	self.is_cross = 0
	self.scroll_change = false 			--记录画布是否在滚动中
	self.layer = 1
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.item_cell = {}
	self.toggle_list = {}
	self.show_hl_list = {}

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

	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))
	self.family_list = BossData.Instance:GetBossFamilyListClient()
end

function BossFamilyView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k,v in pairs(self.toggle_list) do
		v:DeleteMe()
	end
	self.toggle_list = {}

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	self.is_first = true
end

function BossFamilyView:CloseBossView()
	self.select_index = 1
	self.is_first = true
end

function BossFamilyView:CloseBossView()
	self.select_index = 1
end

function BossFamilyView:GetNumberOfCells()
	return #BossData.Instance:GetBossFamilyList(self.select_scene_id, true) or 0
end

function BossFamilyView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function BossFamilyView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()

	if least ~= nil and most ~= nil then
		local num = self:CheckVipLevel(least, most)
		return num
	end
end

function BossFamilyView:CheckVipLevel(least, most)
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	local num = 0
	for i = least, most do
		local cfg = BossData.Instance:GetBossMiniMapCfg(0, i)
		if cfg then
			local vip_level = BossData.Instance:GetBossVipLismit(cfg.scene_id)
			if my_vip >= vip_level then
				num = num + 1
			end
		end
	end
	if num < MAX_FLOOR then
		num = num + 1
	end
	return num
end

function BossFamilyView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(0, i)
		if cfg then
			if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
				return cfg.boss_cengshu
			end
		end
	end
end

function BossFamilyView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(0, i)
		if cfg then
			if my_level < cfg.show_min_lv then
				return cfg.boss_cengshu
			end
		end
	end
	return MAX_FLOOR
end

function BossFamilyView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = FamilyBossToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end

function BossFamilyView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = BossFamilyItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function BossFamilyView:ToActtack()
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

	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	local _, cost_gold = BossData.Instance:GetBossVipLismit(self.select_scene_id)
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold >= cost_gold then
			ViewManager.Instance:CloseAll()
			self:SendToActtack()
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end

	
	if BossData.Instance:GetFamilyBossCanGoByVip(self.select_scene_id) then
		self:SendToActtack()
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Boss.BossFamilyLimit, cost_gold))
	end
end

function BossFamilyView:SendToActtack()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	if self.is_cross == 1 then
		local select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_scene_id)
		BossData.Instance:SetCurInfo(select_scene_id, self.select_boss_id)
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, select_scene_id, self.select_boss_id)
	else
		BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id)
	end
end

function BossFamilyView:QuestionClick()
	local tips_id = 141 -- boss之家
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossFamilyView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function BossFamilyView:OpenKillRecord()
	if self.is_cross == 1 then
		local select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_scene_id) or 0
		BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, select_scene_id)
	else
		BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, self.select_scene_id)
	end
end

function BossFamilyView:FlushModel()
	local boss_data = BossData.Instance:GetMonsterInfo(self.select_boss_id)
	BossCtrl.Instance:SetBossDisPlay(boss_data)
end

function BossFamilyView:FlushRemainCount()
	local boss_data = BossData.Instance
	local boss_id_list = boss_data:GetBossFamilyIdList()
	local text = ""
	for k,v in pairs(boss_id_list) do
		local count = boss_data:GetBossFamilyRemainEnemyCount(v, self.select_scene_id)
		if count <= 0 then
			text = ToColorStr(tostring(count), TEXT_COLOR.RED)
		else
			text = ToColorStr(tostring(count), TEXT_COLOR.GREEN)
		end
	end
end

function BossFamilyView:ClickBoss(layer, is_click)
	if is_click then
		for k,v in pairs(self.family_list) do
			if layer == k then
				self.select_clent_scene_id = v.scene_id
				local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
				self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
				self.is_cross = boss_list[1] and boss_list[1].is_cross or 0
				-- if self.is_cross == 1 then
				-- 	self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
				-- else
					self.select_scene_id = self.select_clent_scene_id
				-- end
				break
			end
		end
		if self.is_first then
			self.is_first = false
		end
		self.layer = layer
		self.select_index = 1
		self:Flush()
	end
end

function BossFamilyView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function BossFamilyView:FlushItemList()
	local item_list = BossData.Instance:GetBossFamilyFallList(self.select_boss_id)
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

function BossFamilyView:FlushTextLimit()
	-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
	-- local boss_list = BossData.Instance:GetBossFamilyList(self.select_scene_id, true)
	-- for k,v in pairs(boss_list) do
	-- 	if v.bossID == self.select_boss_id then
	-- 		self.node_list["TxtMaxLevel"]:SetActive(my_level > v.max_lv)
	-- 	end
	-- end
end

function BossFamilyView:FlushFocusState()
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function BossFamilyView:FocusOnClick(is_click)
	local select_scene_id = self.select_scene_id
	if self.is_cross == 1 then
		select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_scene_id)
	end
	
	if select_scene_id then
		if is_click then
			if not BossData.Instance:BossIsFollow(self.select_boss_id) then
				BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, select_scene_id)
			end
		else
			if BossData.Instance:BossIsFollow(self.select_boss_id) then
				BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, select_scene_id)
			end
		end
	end
	
end

function BossFamilyView:CheckFrameIsOpen()
	for i = 1, 3 do
		if self.toggle_list[i].toggle.isOn then
			self.toggle_list[i].toggle.isOn = false
			break
		end
	end
end

function BossFamilyView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		self:FlushItemList()
		-- self:FlushTextLimit()
		self:FlushModel()
	end
end

function BossFamilyView:FlushBossList()
	local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
	if nil ~= boss_list then
		if #boss_list > 0 then
			for i = 1, #boss_list do
				self.boss_data[i] = boss_list[i]
			end
		end
	end

	if self.node_list["BossList"].gameObject.activeInHierarchy then
		if self.select_index == 1 then
			self.node_list["BossList"].scroller:ReloadData()
			self:JumpToNoFallBoss()
			self:FlushAllHL()
		else
			self.node_list["BossList"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function BossFamilyView:JumpToNoFallBoss()
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
	if self.node_list["BossList"].gameObject.activeInHierarchy then
		self.node_list["BossList"].scroller:JumpToDataIndex(self.select_index - 1)
	end
end

function BossFamilyView:FlushToggles()
	local num = self:GetCanShowFloor()
	if self.node_list["ToggleGround"] and num > 0 then
		self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossFamilyView:FlushBtnTxt()
	self.node_list["TxtEnter"].text.text = BossData.Instance:GetFamilyBossCanGoByVip(self.select_scene_id) and Language.Boss.FreeToAttack or Language.Boss.BuyTicket

	local vip_level = BossData.Instance:GetBossVipLismit(self.select_scene_id)
	self.node_list["Txtneed_vip_level"].text.text = string.format(Language.Boss.BossVipLevelCondition, vip_level)

end

function BossFamilyView:OnFlush()
	self.select_index = 1
	local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
	self.select_boss_id = boss_list[1] and boss_list[1].bossID or nil
	self.is_cross = boss_list[1] and boss_list[1].is_cross or 0
	-- if self.is_cross == 1 then
	-- 	self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
	-- else
		self.select_scene_id = self.select_clent_scene_id
	-- end
	if self.is_first == true then
		local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
		self:ClickBoss(index, true)
	else
		self:FlushBossList()
		self:FlushFocusState()
		self:FlushInfoList()
		self:FlushToggles()
		self:FlushBtnTxt()
		-- self:FlushTextLimit()
	end
end

function BossFamilyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyView:GetSelectIndex()
	return self.select_index or 1
end

function BossFamilyView:SetSelectBossId(boss_id, is_cross)
	self.select_boss_id = boss_id
	self.is_cross = is_cross
	-- if self.is_cross == 1 then
	-- 	self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
	-- else
		self.select_scene_id = self.select_clent_scene_id
	-- end
end

function BossFamilyView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function BossFamilyView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetBossFamilyList(self.select_scene_id, true) or 0
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

-------------------------------------------------------------------------
BossFamilyItemCell = BossFamilyItemCell or BaseClass(BaseCell)

function BossFamilyItemCell:__init()
	self.index = 0
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function BossFamilyItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.node_list["Img_kuafu"]:SetActive(false)
end

function BossFamilyItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID, self.data.is_cross)
		self.boss_view:FlushFocusState()
		self.boss_view:FlushAllHL()
		if self.data == nil or select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function BossFamilyItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, monster_cfg.level)
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)

		if BOSS_TYPE_INFO.RARE == monster_cfg.boss_type or self.data.is_cross == 1 then
			self.node_list["Img_kuafu"]:SetActive(self.data.is_cross == 1)
		else
			self.node_list["Img_kuafu"]:SetActive(false)
		end
	end

	self.next_refresh_time = BossData.Instance:GetFamilyBossRefreshTime(self.data.bossID, self.data.scene_id)
	self:UpdateKill(self.next_refresh_time > TimeCtrl.Instance:GetServerTime())
	if self.next_refresh_time > TimeCtrl.Instance:GetServerTime() then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:OnBossUpdate()
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end

		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	end
	self:FlushHL()
end

function BossFamilyItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function BossFamilyItemCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
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

function BossFamilyItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
FamilyBossToggle = FamilyBossToggle or BaseClass(BaseCell)

function FamilyBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function FamilyBossToggle:__delete()

end

function FamilyBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickBoss(self.index, isOn)
	end
end

function FamilyBossToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end