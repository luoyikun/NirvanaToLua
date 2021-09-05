WorldBossView = WorldBossView or BaseClass(BaseRender)
local TWEEN_TIME = 0.5
function WorldBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	-- self.select_boss_id = 10
	self.boss_data = {}
	self.cell_list = {}
	self.item_cell = {}
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end
	self.list_view = self.node_list["BossList"]
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestion"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))
end

function WorldBossView:__delete()
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
	self.model_display = nil
end

function WorldBossView:GetNumberOfCells()
	return #self.boss_data or 0
end

function WorldBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = WorldBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function WorldBossView:CloseBossView()
	self.select_index = 1
end

function WorldBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function WorldBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local min_level = BossData.Instance:GetBossCfgById(self.select_boss_id).min_lv
	if my_level >= min_level then
		if self.select_boss_id == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
			return
		end
		ViewManager.Instance:CloseAll()
		local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
		GuajiCtrl.Instance:FlyToScene(boss_data.scene_id)
	else
		limit_text = string.format(Language.Common.CanNotEnter, PlayerData.GetLevelString(min_level))
		TipsCtrl.Instance:ShowSystemMsg(limit_text)
	end
end

function WorldBossView:QuestionClick()
	local tips_id = 140 -- 世界boss
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WorldBossView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function WorldBossView:FlushTextLimit()
	-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
	-- local boss_list = BossData.Instance:GetWorldBossList()
	-- for k,v in pairs(boss_list) do
	-- 	if v.bossID == self.select_boss_id then
	-- 		self.node_list["TxtMaxLevel"]:SetActive(my_level > v.max_lv)
	-- 	end
	-- end
end

function WorldBossView:OpenKillRecord()
	BossCtrl.Instance:SendWorldBossKillerInfoReq(self.select_boss_id)
end

function WorldBossView:FlushModel()
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	BossCtrl.Instance:SetBossDisPlay(boss_data)
end

function WorldBossView:FlushItemList()
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	if nil == boss_data then
		return
	end
	local item_list = boss_data.item_list
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

				if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then		-- 红色装备写死3星
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

function WorldBossView:FlushInfoList()
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
	if boss_data == nil then
		return
	end
	if self.select_boss_id ~= 0 then
		self:FlushItemList(boss_data.item_list)
		self:FlushModel()
		-- self:FlushTextLimit()
	end
end

function WorldBossView:FlushBossList()
	local boss_list = BossData.Instance:GetWorldBossList()
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end
	if self.list_view.gameObject.activeInHierarchy then
		if self.select_index == 1 then
			self.list_view.scroller:ReloadData(0)
			self:JumpToNoFallBoss()
			self:FlushAllHL()
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function WorldBossView:OnFlush()
	self.select_index = 1
	self:FlushBossList()
	self:FlushInfoList()
end

function WorldBossView:JumpToNoFallBoss()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in ipairs(self.boss_data) do
		if my_level <= v.max_lv then
			self.select_index = k
			self.select_boss_id = v.bossID
			break
		end
	end
	if self.list_view.gameObject.activeInHierarchy and #self.boss_data > 0 then
		self.list_view.scroller:JumpToDataIndex(self.select_index - 1)
	end
end

function WorldBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function WorldBossView:GetSelectIndex()
	return self.select_index or 1
end

function WorldBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function WorldBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function WorldBossView:OnClickDownArrow()
	local max_num = #self.boss_data or 0
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

------------------------------------------------------------------
WorldBossItemCell = WorldBossItemCell or BaseClass(BaseCell)

function WorldBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function WorldBossItemCell:__delete()
end

function WorldBossItemCell:ClickItem(is_click)
	if is_click then
		local select_index = self.boss_view:GetSelectIndex()
		local boss_id = self.data.bossID
		self.boss_view:SetSelectBossId(boss_id)
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function WorldBossItemCell:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.data.bossID)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if nil ~= monster_cfg and monster_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)


		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = boss_data.boss_name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_1")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)

		-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
		-- self.node_list["Img_tag_diaoluo"]:SetActive(my_level > self.data.max_lv)
	end

	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, boss_data.boss_level)

	UI:SetGraphicGrey(self.node_list["image"], state == 0)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], state == 0)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], state == 0)

	local level_text = ""
	if self.data.min_lv > GameVoManager.Instance:GetMainRoleVo().level then
		level_text = ToColorStr(PlayerData.GetLevelString(self.data.min_lv) .. Language.Dungeon.CanKill, TEXT_COLOR.RED)
		self.node_list["TxtRefreshTime"]:SetActive(false)
		self.node_list["Img_hasflush"]:SetActive(false)
	else
		level_text = boss_data.boss_level
		self.node_list["TxtRefreshTime"]:SetActive(true)
		self.node_list["Img_hasflush"]:SetActive(true)

		local state = BossData.Instance:GetBossStatusByBossId(self.data.bossID)
		if state == 0 then
		local time_tab = os.date("*t", BossData.Instance:GetBossNextReFreshTime())
		local str = ""
		if time_tab.min ~= 0 then
			str = string.format("%d%s%02d%s%s", time_tab.hour, Language.Boss.Hour, time_tab.min, Language.Common.Minute, Language.Boss.BossFlush)
		else
			str = string.format("%d%s%s", time_tab.hour, Language.Boss.Hour, Language.Boss.BossFlush)
		end
			self.node_list["TxtRefreshTime"].text.text = ToColorStr(str, TEXT_COLOR.RED)
			self.node_list["Img_hasflush"]:SetActive(false)
		else
			self.node_list["TxtRefreshTime"]:SetActive(false)
		end
	end
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, level_text) 
	self:FlushHL()
end

function WorldBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end
