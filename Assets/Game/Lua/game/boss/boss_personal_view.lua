PersonalBossView = PersonalBossView or BaseClass(BaseRender)

local TWEEN_TIME = 0.5
function PersonalBossView:__init()
	self.select_monster_res_id = 0

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
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))
	-- self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAdd, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function PersonalBossView:__delete()
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

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function PersonalBossView:GetNumberOfCells()
	return #self.boss_data or 0
end

function PersonalBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = PersonalBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetTheIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function PersonalBossView:CloseBossView()
	self.select_index = 1
end

function PersonalBossView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function PersonalBossView:OnClickAdd()
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- if BossData.Instance:GetCanEnterPersonalBoss() and vip_level ~= 15 then
	-- 	TipsCtrl.Instance:ShowLockVipView(15)
	-- 	return
	-- end
	local call_back = function ()
		-- if BossData.Instance:GetCanEnterPersonalBoss() then
		-- 	return
		-- end
		SuitCollectionCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.PERSONAL_BUY_TIMES)
	end
	local describe = Language.Boss.BossBuyEnterTime

	local data_fun = function ()
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		local data = {}
		local buy_time = BossData.Instance:GetPersonalBossBuyTimes()
		data[2] = buy_time
		data[1] = BossData.Instance:GetPersonBossTimesCost(buy_time + 1)
		data[3] = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PERSON_BOSS_TIMES]
		data[4] = VipPower:GetParam(VIPPOWER.PERSON_BOSS_TIMES, true)
		return data
	end
	local data = data_fun()
	FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.PERSON_BOSS_TIMES, call_back, data_fun, 1, describe)

	-- TipsCtrl.Instance:ShowCommonAutoView("BuyDaBaoEnterTimes", describe, call_back, nil, nil, nil, nil, nil, true)
end

function PersonalBossView:ToActtack()
	if Scene.Instance:GetSceneType() == SceneType.PERSON_BOSS then
		TipsCtrl.Instance:ErrorRemind(Language.Boss.OutFubenTip)
		return
	end

	if TaskData.Instance:GetTaskAcceptedIsBeauty() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotEnterFb)
		return
	end
	
	local boss_data = self.boss_data[self.select_index]
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	if my_level < boss_data.need_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Boss.EnterWorldBossLevel, tostring(boss_data.need_level)))
		return
	end

	local left_enter_num = BossData.Instance:GetPersonalBossEnterTimeBylayer(boss_data.layer)
	local max_enter_num = BossData.Instance:GetPersonalBossMaxEnterTimeBylayer(boss_data.layer)
	if left_enter_num then
		left_enter_num = max_enter_num - left_enter_num
	end
	-- local level = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- if level < 4 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Boss.VIP4CanEnter)
	-- 	return b
	if left_enter_num and left_enter_num == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.NoPerBossEnter)
		return
	end

	local num = ItemData.Instance:GetItemNumInBagById(boss_data.need_item_id)
	if num < boss_data.need_item_num then
		BossCtrl.Instance:SetEnterBossComsunData(boss_data.need_item_id, boss_data.need_item_num, Language.Boss.EnterPersonal, Language.Boss.EnterBossConsum, function()
		end)
	else
		FuBenCtrl.Instance:SendEnterFBReq(BOSS_ENTER_TYPE.TYPE_BOSS_PERSONAL, boss_data.layer)
	end
end

function PersonalBossView:GetToActtackBtn()
	if self.node_list["BtnToAttach"] then
		return self.node_list["BtnToAttach"], BindTool.Bind(self.ToActtack, self)
	end
end

function PersonalBossView:QuestionClick()
	local tips_id = 269 -- 个人boss
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PersonalBossView:OpenBossDrop()
	-- ViewManager.Instance:Open(ViewName.DropView)
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
end

function PersonalBossView:FlushModel()
	local boss_data = BossData.Instance:GetMonsterInfo(self.select_boss_id)
	BossCtrl.Instance:SetBossDisPlay(boss_data)
end

function PersonalBossView:FlushItemList()
	local item_list = BossData.Instance:GetPersonalBossInfoByBossID(self.select_boss_id)
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
						v:SetData({item_id = reward_item_id, num = 1})
					end
					if tonumber(temp_list[2]) == 1 then
						v:SetShowZhuanShu(true)
					else
						v:SetShowZhuanShu(false)
					end
				end
		else
			v:SetData(nil)
		end
	end
end

function PersonalBossView:FlushInfoList()
	if self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
	end
	local left_enter_num = BossData.Instance:GetPersonalBossEnterTimeBylayer(self.layer)
	local max_enter_num = BossData.Instance:GetPersonalBossMaxEnterTimeBylayer(self.layer)
	if left_enter_num then
		left_enter_num = max_enter_num - left_enter_num
	end

	if left_enter_num then
		if left_enter_num <= 0 then
			left_enter_num = ToColorStr(left_enter_num, TEXT_COLOR.RED)
		else
			left_enter_num = ToColorStr(left_enter_num, TEXT_COLOR.GREEN)
		end
	end

	max_enter_num = ToColorStr(max_enter_num, TEXT_COLOR.GREEN)
	if left_enter_num and max_enter_num then
		self.node_list["Txt_EnterTimes"].text.text = Language.Boss.ResetEnterTimes .. left_enter_num .. " / " .. max_enter_num
	end

	local boss_data = self.boss_data[self.select_index]
	if boss_data and boss_data.need_item_id and boss_data.need_item_num then
		local has_num = ItemData.Instance:GetItemNumInBagById(boss_data.need_item_id) or 0
		local color = 0
		if has_num >= boss_data.need_item_num then
			color = TEXT_COLOR.GREEN
		else
			color = TEXT_COLOR.RED
		end
		self.node_list["Txt_Vip_Condition"].text.text = string.format(Language.Boss.Needtiky, color, has_num, boss_data.need_item_num)
	end
end

function PersonalBossView:ItemDataChangeCallback(item_id)
	local boss_data = self.boss_data[self.select_index]
	if boss_data and boss_data.need_item_id == item_id then
		self:FlushInfoList()
		RemindManager.Instance:Fire(RemindName.Boss_Personal)
	end
end


function PersonalBossView:FlushBossList()
	local boss_list = BossData.Instance:GetPersonalBossList()
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end
	if self.list_view.gameObject.activeInHierarchy then
		if self.select_index == 1 then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function PersonalBossView:OnFlush()
	self:FlushBossList()
	local max_level_info = BossData.Instance:GetPersonalCanGoMaxLevelBossInfo()
	if max_level_info then
		self.select_index = max_level_info.index
		self.select_boss_id = max_level_info.boss_id
	end
	local boss_data = self.boss_data[self.select_index]
	if boss_data then
		self.layer = boss_data.layer
	end
	self:FlushInfoList()
	local num = self:GetNumberOfCells()
	if self.list_view and self.list_view.gameObject.activeInHierarchy and self.select_index and num > 0 then
		self.list_view.scroller:ReloadData(1)
		self:FlushAllHL()
	end
end

function PersonalBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function PersonalBossView:SetLayer(layer)
	self.layer = layer
end

function PersonalBossView:GetSelectIndex()
	return self.select_index or 1
end

function PersonalBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function PersonalBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function PersonalBossView:OnClickDownArrow()
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
PersonalBossItemCell = PersonalBossItemCell or BaseClass(BaseCell)

function PersonalBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function PersonalBossItemCell:__delete()
end

function PersonalBossItemCell:SetTheIndex(index)
	self.the_index = index
end

function PersonalBossItemCell:ClickItem(is_click)
	if is_click then
		local select_index = self.boss_view:GetSelectIndex()
		local boss_id = self.data.boss_id
		self.boss_view:SetSelectBossId(boss_id)
		self.boss_view:SetSelectIndex(self.the_index)
		self.boss_view:SetLayer(self.data.layer)
		self.boss_view:FlushAllHL()
		-- if select_index == self.the_index then
		-- 	return
		-- end
		self.boss_view:FlushInfoList()
	end
end

function PersonalBossItemCell:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	-- local boss_data = BossData.Instance:GetPersonalBossInfoByBossID(self.data.boss_id)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if nil ~= monster_cfg and monster_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.node_list["image"].raw_image:LoadSprite(bundle, asset)

		-- self.node_list["ImgName"]:SetActive(true)
		-- self.node_list["TxtNameSpecial"]:SetActive(false)
		-- self.node_list["ImgName"].text.text = monster_cfg.boss_name or ""
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_6")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)
	end

	-- self.node_list["ImgName"].text.text = self.data.boss_name or ""
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, self.data.boss_level)

	local level_text = ""
	local txt_color = TEXT_COLOR.GREEN
	if self.data.need_level > GameVoManager.Instance:GetMainRoleVo().level then
		-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(self.data.need_level)
		-- level_text = ToColorStr(string.format(Language.Common.ZhuanShneng, lv1, zhuan1) .. Language.Dungeon.CanKill, TEXT_COLOR.RED)
		level_text = PlayerData.GetLevelString(self.data.need_level) .. Language.Dungeon.CanKill
		txt_color = TEXT_COLOR.RED
	else
		level_text = self.data.boss_level
		-- level_text = PlayerData.GetLevelString(self.data.boss_level)
	end
	self.node_list["TxtLevel"].text.text = ToColorStr(string.format(Language.Common.ShenGongHuanHuaLevel, level_text), txt_color)


	local left_enter_num = BossData.Instance:GetPersonalBossEnterTimeBylayer(self.data.layer)
	local max_enter_num = BossData.Instance:GetPersonalBossMaxEnterTimeBylayer(self.data.layer)
	if left_enter_num then
		left_enter_num = max_enter_num - left_enter_num
	end
	if left_enter_num then
		if left_enter_num <= 0 then
			UI:SetGraphicGrey(self.node_list["image"], true)
			UI:SetGraphicGrey(self.node_list["TxtLevel"], true)
		else
			UI:SetGraphicGrey(self.node_list["image"], false)
			UI:SetGraphicGrey(self.node_list["TxtLevel"], false)
		end
	end
	self:FlushHL()
end

function PersonalBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.the_index)
end