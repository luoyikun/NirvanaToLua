ShenYuBossYouMingView = ShenYuBossYouMingView or BaseClass(BaseRender)

local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function ShenYuBossYouMingView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(6)
	self.select_index = 1
	self.select_type = 2
	self.layer = 1
	self.select_item_data = nil
	self.select_boss_index = 0
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.item_cell = {}
	self.show_hl_list = {}
	self.toggle_list = {}

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

function ShenYuBossYouMingView:__delete()
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

function ShenYuBossYouMingView:ClickScene(layer, is_click)
	self.is_first = false
	if is_click then
		self.layer = layer
		self.select_scene_id = ShenYuBossData.Instance:GetCrossYouMingSceneIDByLayer(layer)
		self:ShowIndex()
	end
end

function ShenYuBossYouMingView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function ShenYuBossYouMingView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()
	if least ~= nil and most ~= nil then
		return most - least + 1
	end
end

function ShenYuBossYouMingView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(6, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
end

function ShenYuBossYouMingView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(6, i)
		if my_level < cfg.show_min_lv then
			local num = cfg.boss_cengshu - 1 <= 0 and 0 or cfg.boss_cengshu - 1
			return num
		end
	end
	return MAX_FLOOR
end

function ShenYuBossYouMingView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = ShenYuYouMingToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end


function ShenYuBossYouMingView:CloseBossView()
	self.is_first = true
end

function ShenYuBossYouMingView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function ShenYuBossYouMingView:GetNumberOfCells()
	local list = ShenYuBossData.Instance:GetCrossYouMingLayerBossBylayer(self.layer)
	return list and #list or 0
end

function ShenYuBossYouMingView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = ShenYuYouMingItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function ShenYuBossYouMingView:ToActtack()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == self.select_scene_id then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.OnArrive)
		for k,v in pairs(self.cell_list) do
			if v.index == self.select_index then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				MoveCache.end_type = MoveEndType.Auto
				local callback = function()
					GuajiCtrl.Instance:MoveToPos(self.select_scene_id, v.data.x_pos, v.data.y_pos, 10, 10)
				end
				callback()
				GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
				ViewManager.Instance:Close(ViewName.Boss)
				return
			end
		end
	end
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	ShenYuBossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_CROSS_YOUMING_BOSS, self.layer)
end

function ShenYuBossYouMingView:QuestionClick()
	local tips_id = 308 	--跨服BOSS
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenYuBossYouMingView:OpenBossDrop()
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_OTHER)
end

function ShenYuBossYouMingView:FlushBtnTxt()
	local tire, max_tire = ShenYuBossData.Instance:GetYouMingCrossBossTire()
	local tire_value = max_tire - tire
	self.node_list["TxtEnterTimes"].text.text = string.format(Language.Boss.CrossBossTireValue, tire_value)
	self.node_list["TxtEnterTimes"]:SetActive(true)
	if nil == self.select_item_data then
		return
	end
	if self.select_type == BossData.MonsterType.Monster or self.select_type == BossData.MonsterType.Gather or self.select_type == BossData.MonsterType.HideBoss then
		local left_num = ShenYuBossData.Instance:GetCrossYouMingLeftNum(self.select_item_data.layer, self.select_type)
		if left_num ~= nil then
			self.node_list["Txt_Num"].text.text = string.format(Language.Boss.LeftNum, self.select_item_data.boss_name, left_num)
		end
		local GatherTimes = ShenYuBossData.Instance:GetYouMingLeftTreasureGatherTimes()
		if self.select_type == BossData.MonsterType.Gather and nil ~= GatherTimes then
			self.node_list["TxtEnterTimes"].text.text = string.format(Language.Boss.LeftGatherTimes, self.select_item_data.boss_name, GatherTimes)
		end
	else
		self.node_list["Txt_Num"].text.text = ""
	end

	if self.select_type == BossData.MonsterType.Monster or self.select_type == BossData.MonsterType.Gather then
		self.node_list["PanelRight"]:SetActive(false)
		self.node_list["Btn_buttons"]:SetActive(false)
		self.node_list["Img_text_type"]:SetActive(true)
		local bundle, asset = ResPath.GetBossNoPackImage("Txt_Monster_type_0" .. self.select_type)
		self.node_list["Img_text_type"].image:LoadSprite(bundle, asset)
		self.node_list["Img_text_type"].image:SetNativeSize()
		self.node_list["Txt_type_content"].text.text = Language.Boss.ShowContent[self.select_type]
	else
		self.node_list["Btn_buttons"]:SetActive(true)
		self.node_list["PanelRight"]:SetActive(true)
		self.node_list["Img_text_type"]:SetActive(false)
	end
end

function ShenYuBossYouMingView:FlushModel()
	if self.select_type ~= BossData.MonsterType.Gather then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			ShenYuBossCtrl.Instance:SetBossDisPlay(monster_cfg)
			return
		end
	else
		local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list
		if gather_cfg ~= nil and gather_cfg[self.select_boss_id] ~= nil then
			local res_id = gather_cfg[self.select_boss_id].resid
			local bundle, asset = ResPath.GetShangguBOXModel(res_id)
			ShenYuBossCtrl.Instance:SetBoxDisPlay(bundle, asset, res_id)
			return
		end
	end
end

function ShenYuBossYouMingView:FocusOnClick(is_click)
	if is_click then
		if not ShenYuBossData.Instance:GetCrossYouMingBossIsConcern(self.layer, self.select_boss_index) then
			ShenYuBossCtrl.Instance:SendCrossYouMingBossBossInfoReq(CROSS_YOUMING_BOSS_OPERA_TYPE.CROSS_YOUMING_BOSS_OPERA_TYPE_CONCERN_BOSS, self.layer, self.select_boss_id)
		end
	else
		if ShenYuBossData.Instance:GetCrossYouMingBossIsConcern(self.layer, self.select_boss_index) then
			ShenYuBossCtrl.Instance:SendCrossYouMingBossBossInfoReq(CROSS_YOUMING_BOSS_OPERA_TYPE.CROSS_YOUMING_BOSS_OPERA_TYPE_UNCONCERN_BOSS, self.layer, self.select_boss_id)
		end
	end
end

function ShenYuBossYouMingView:FlushFocusState(is_show)
	if is_show ~= nil then
		self.node_list["focus_toggle"]:SetActive(false)
	end
	self.node_list["focus_toggle"].toggle.isOn = ShenYuBossData.Instance:GetCrossYouMingBossIsConcern(self.layer, self.select_boss_index)
end

function ShenYuBossYouMingView:OpenKillRecord()
	ShenYuBossCtrl.Instance:SendCrossYouMingBossBossInfoReq(CROSS_YOUMING_BOSS_OPERA_TYPE.CROSS_YOUMING_BOSS_OPERA_TYPE_BOSS_KILL_RECORD, self.layer, self.select_boss_id)
end

function ShenYuBossYouMingView:FlushItemList()
	local item_list = ShenYuBossData.Instance:GetYouMingBossFallList(self.select_boss_id)
	if nil == item_list then return end
	
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			item_list[k] = tonumber(item_list[k])
			local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_list[k])
				if item_cfg ~= nil then
					if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
						local data = BossData.Instance:GetShowEquipItemList(item_list[k])
						v:SetData(data)
					else
						v:SetData({item_id = tonumber(item_list[k])})
					end
				end
		else
			v:SetData(nil)
		end
	end
end

function ShenYuBossYouMingView:FlushInfoList()
	if self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
	end
end

function ShenYuBossYouMingView:FlushBossList()
	local boss_list = ShenYuBossData.Instance:GetCrossYouMingLayerBossBylayer(self.layer)
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

function ShenYuBossYouMingView:FlushToggles()
	self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
end

function ShenYuBossYouMingView:ShowIndex()
	self.select_index = 1
	self.select_type = 2
	self:Flush()
end

function ShenYuBossYouMingView:OnFlush()
	if self.is_first == true then
		self:FlushFocusState(false)
		local index = ShenYuBossData.Instance:GetCrossYouMingBossCanGoLevel()
		self:ClickScene(index, true)
	else
		self:FlushBossList()
		self:FlushInfoList()
		self:FlushToggles()
		self:FlushBtnTxt()
	end
end

function ShenYuBossYouMingView:SetSelectIndex(index, boss_index)
	if index then
		self.select_index = index
	end
	self.select_boss_index = boss_index or 0
end

function ShenYuBossYouMingView:SetSelectType(data_type)
	if data_type then
		self.select_type = data_type
	end
end

function ShenYuBossYouMingView:SetSelectData(item_data)
	if item_data then
		self.select_item_data = item_data
	end
end

function ShenYuBossYouMingView:GetSelectIndex()
	return self.select_index or 1
end

function ShenYuBossYouMingView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function ShenYuBossYouMingView:SetSelectSceneId(scene_id)
	self.select_scene_id = scene_id
end

function ShenYuBossYouMingView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ShenYuBossYouMingView:OnClickDownArrow()
	local max_num = #ShenYuBossData.Instance:GetCrossYouMingLayerBossBylayer(self.layer) or 0
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
ShenYuYouMingItemCell = ShenYuYouMingItemCell or BaseClass(BaseCell)

function ShenYuYouMingItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function ShenYuYouMingItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ShenYuYouMingItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index, self.data.boss_index)
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

function ShenYuYouMingItemCell:OnFlush()
	if not self.data then return end

	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.node_list["TxtLevel"].text.text = monster_cfg.level
		if self.data.type == BossData.MonsterType.Boss or self.data.type == BossData.MonsterType.HideBoss then
			local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
			self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		end
	end

	if self.data.type == BossData.MonsterType.Monster then
		local bundle, asset = ResPath.GetBoss("monster_item_" .. self.boss_view.layer)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)
		self.node_list["TxtLevel"].text.text = ""
		self.node_list["TxtRefreshTime"].text.text = ""
		self:UpdateKill(false)
	end

	if self.data.type == BossData.MonsterType.Gather then
		local bundle_1, asset_1 = ResPath.GetBoss("gather_item_" .. self.boss_view.layer)
		self.node_list["image"].raw_image:LoadSprite(bundle_1, asset_1)
		self.node_list["TxtLevel"].text.text = ""
		self.node_list["TxtRefreshTime"].text.text = ""
		self:UpdateKill(false)
	end

	local reflash_time = self.data.next_refresh_time or 0
	if self.data.type == 0 then
		if reflash_time > 0 then
			local time_tab = os.date("*t", reflash_time)
			local str = ""
			if time_tab.min ~= 0 then
				str = string.format("%d%s%02d%s%s", time_tab.hour, Language.Boss.Hour, time_tab.min, Language.Common.Minute, Language.Boss.BossFlush)
			else
				str = string.format("%d%s%s", time_tab.hour, Language.Boss.Hour, Language.Boss.BossFlush)
			end
			self.node_list["TxtRefreshTime"]:SetActive(true)
			self.node_list["Img_hasflush"]:SetActive(false)
			self.node_list["TxtRefreshTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
			if nil == self.time_coundown then
				self.time_coundown = GlobalTimerQuest:AddTimesTimer(
						BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime()
				)
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
		end
	end
	self:FlushHL()
end

function ShenYuYouMingItemCell:OnBossUpdate()
	local reflash_time = self.data.next_refresh_time or 0
	if reflash_time <= TimeCtrl.Instance:GetServerTime() then
		self:UpdateKill(false)
		self.node_list["Img_hasflush"]:SetActive(true)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	else
		local time_tab = os.date("*t", reflash_time)
		if time_tab.min ~= 0 then
			str = string.format("%d%s%02d%s%s", time_tab.hour, Language.Boss.Hour, time_tab.min, Language.Common.Minute, Language.Boss.BossFlush)
		else
			str = string.format("%d%s%s", time_tab.hour, Language.Boss.Hour, Language.Boss.BossFlush)
		end
		self.node_list["TxtRefreshTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
		self:UpdateKill(true)
		self.node_list["Img_hasflush"]:SetActive(false)
		self.node_list["TxtRefreshTime"]:SetActive(true)
	end
end

function ShenYuYouMingItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function ShenYuYouMingItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
ShenYuYouMingToggle = ShenYuYouMingToggle or BaseClass(BaseCell)

function ShenYuYouMingToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function ShenYuYouMingToggle:__delete()

end

function ShenYuYouMingToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickScene(self.index, isOn)
	end
end

function ShenYuYouMingToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end
