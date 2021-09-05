BossActiveView = BossActiveView or BaseClass(BaseRender)

local SINGLE_ANGRY = 18
local MAX_FLOOR = 0
local TWEEN_TIME = 0.5
function BossActiveView:__init()
	MAX_FLOOR = BossData.Instance:GetBossTypeCengshu(3)
	self.select_index = 1
	self.select_monster_res_id = 0
	-- self.select_scene_id = 9040
	-- self.select_boss_id = BossData.Instance:GetActiveBossList(self.select_scene_id)[1].bossID
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.layer = 1
	self.item_cell = {}
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["Item" .. i])
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	self.list_view_delegate = self.node_list["BossList"].list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.show_hl_list = {}
	self.toggle_list = {}

	self.toggle_list_delegate = self.node_list["ToggleGround"].list_simple_delegate
	self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self.node_list["BtnToAttach"].button:AddClickListener(BindTool.Bind(self.ToActtack, self))
	self.node_list["BtnQuestionBtn"].button:AddClickListener(BindTool.Bind(self.QuestionClick, self))
	self.node_list["BtnDrop"].button:AddClickListener(BindTool.Bind(self.OpenBossDrop, self))
	self.node_list["BtnKill"].button:AddClickListener(BindTool.Bind(self.OpenKillRecord, self))
	self.node_list["focus_toggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.FocusOnClick, self))
	self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.BuyPiLaoClick, self))
	self.node_list["Btn_next"].button:AddClickListener(BindTool.Bind(self.OnClickDownArrow, self))


	self.active_list = BossData.Instance:GetActiveSceneList()
end

-- 功能引导按钮
function BossActiveView:GetBtnToAttach()
	return self.node_list["BtnToAttach"], BindTool.Bind(self.ToActtack, self)
end

function BossActiveView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k,v in pairs(self.toggle_list) do
		print(k,v)
	end
	self.toggle_list = {}

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}

	self.is_first = false
end

function BossActiveView:ClickScene(layer, is_click)
	if is_click then
		for k,v in pairs(self.active_list) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v)
				if not can_go then
					-- local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(min_level)
					-- local level_text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
					local level_text = PlayerData.GetLevelString(min_level)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v
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

function BossActiveView:DoPanelTweenPlay()
	UITween.MoveShowPanel(self.node_list["Btn_buttons"], BossData.TweenPosition.Up , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Left"], BossData.TweenPosition.Left , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["PanelRight"], BossData.TweenPosition.Right , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
	UITween.MoveShowPanel(self.node_list["Bottom"], BossData.TweenPosition.Down , TWEEN_TIME, DG.Tweening.Ease.InOutSine)
end

function BossActiveView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.Instance:SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_boss_id, self.select_scene_id)
		end
	end
end

function BossActiveView:FlushFocusState()
	self.node_list["focus_toggle"].toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function BossActiveView:GetToggleListNumOfCells()
	return self:GetCanShowFloor()
end

function BossActiveView:GetCanShowFloor()
	local least = self:GetLeastCeng()
	local most = self:GetMostCeng()
	if least ~= nil and most ~= nil then
		return most - least + 1
	end
	return 0
end

function BossActiveView:GetMostCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(3, i)
		if my_level < cfg.show_min_lv then
			return cfg.boss_cengshu
		end
	end
	return MAX_FLOOR
end


function BossActiveView:GetLeastCeng()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for i=1,MAX_FLOOR do
		local cfg = BossData.Instance:GetBossMiniMapCfg(3, i)
		if my_level >= cfg.show_min_lv and my_level <= cfg.show_max_lv then
			return cfg.boss_cengshu
		end
	end
end

function BossActiveView:ToggleRefreshView(cell, data_index)
	local least_index = self:GetLeastCeng()
	if least_index == nil then
		return
	end
	data_index = data_index + least_index
	local toggle_cell = self.toggle_list[cell]
	if nil == toggle_cell then
		toggle_cell = ActiveBossToggle.New(cell.gameObject)
		toggle_cell.node_list["Toggle_Layer"].toggle.group = self.node_list["ToggleGround"].toggle_group
		toggle_cell.boss_view = self
		self.toggle_list[cell] = toggle_cell
	end
	toggle_cell:SetIndex(data_index)
	toggle_cell:Flush()
end

function BossActiveView:CloseBossView()
	self.select_index = 1
	self.is_first = true
end

function BossActiveView:GetNumberOfCells()
	return #BossData.Instance:GetActiveBossList(self.select_scene_id) or 0
end

function BossActiveView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = ActiveBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.node_list["BossList"].toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function BossActiveView:ToActtack()
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

	if not BossData.Instance:IsActiveBossScene(scene_id) and not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.Instance:SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_scene_id, 1)
end

function BossActiveView:QuestionClick()
	local tips_id = 143
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossActiveView:OpenBossDrop()
	BossCtrl.Instance:ShowDropView(DROP_LOG_TYPE.DOPE_LOG_TYPE_BOSS)
	-- ViewManager.Instance:Open(ViewName.DropView)
end

function BossActiveView:FlushModel()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
	if monster_cfg then
		BossCtrl.Instance:SetBossDisPlay(monster_cfg)
	end
end

function BossActiveView:BuyPiLaoClick()
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.BUY_ACTIVE_COUNT]
	-- if BossData.Instance:GetBuyActiveWearyCount() < can_buy_count then
	-- 	local gold = GameVoManager.Instance:GetMainRoleVo().gold
	-- 	local buy_weary_gold = BossData.Instance:GetActiveBuyWearyGold()
	-- 	if gold >= buy_weary_gold then
	-- 		local describe = Language.Boss.BossBuyPiLao
	-- 		local call_back = function ()
	-- 			BossCtrl.Instance:SendBossFamilyOperate(BOSS_FAMILY_OPERATE_TYPE.BOSS_FAMILY_BUY_ACTIVE_WEARY)
	-- 		end

	-- 		local data_fun = function ()
	-- 			local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- 			local data = {}
	-- 			data[2] = BossData.Instance:GetBuyActiveWearyCount()
	-- 			data[1] = BossData.Instance:GetActiveBuyWearyGold()
	-- 			data[3] = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.BUY_ACTIVE_COUNT]
	-- 			data[4] = VipPower:GetParam(VIPPOWER.BUY_ACTIVE_COUNT, true)
	-- 			return data
	-- 		end
	-- 		local data = data_fun()
	-- 		FuBenCtrl.Instance:ShowExpBuyTip(data[1], data[2], data[3], data[4], VIPPOWER.BUY_ACTIVE_COUNT, call_back, data_fun, 1, describe)
	-- 	else
	-- 		TipsCtrl.Instance:ShowLackDiamondView()
	-- 	end
	-- else
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BossBuyPiLaoLimit)
	-- end

	local cfg = BossData.Instance.boss_family_cfg
	if cfg ~= nil and cfg.other[1] ~= nil and cfg.other[1].add_active_item ~= nil then
		local item_id = cfg.other[1].add_active_item
		local item_index = ItemData.Instance:GetItemIndex(item_id)

		PackageCtrl.Instance:SendUseItem(item_index, 1)
	end
end

function BossActiveView:OpenKillRecord()
	BossCtrl.Instance:SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_boss_id, self.select_scene_id)
end

function BossActiveView:FlushItemList()
	local item_list = BossData.Instance:GetActiveBossRewards(self.select_boss_id)
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

				-- if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
				-- 	local data = BossData.Instance:GetShowEquipItemList(reward_item_id)
				-- 	v:SetData(data)
				-- else
					v:SetData({item_id = reward_item_id})
				-- end

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

function BossActiveView:JumpToNoFallBoss()
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

function BossActiveView:FlushTextLimit()
	-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
	-- local boss_list = BossData.Instance:GetActiveBossList(self.select_scene_id)
	-- for k,v in pairs(boss_list) do
	-- 	if v.bossID == self.select_boss_id then
	-- 		self.node_list["TxtMaxLevel"]:SetActive(my_level > v.max_lv)
	-- 	end
	-- end
end

function BossActiveView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
		-- self:FlushTextLimit()
	end
end

function BossActiveView:FlushBossList()
	local boss_list = BossData.Instance:GetActiveBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
		self.select_boss_id = boss_list[1].bossID
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

function BossActiveView:FlushToggles()
	local num = self:GetCanShowFloor()
	if self.node_list["ToggleGround"] and num > 0 then
		self.node_list["ToggleGround"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossActiveView:OnFlush()
	self.select_index = 1
	self:FlushBossList()
	self:FlushFocusState()

	if self.is_first == true then
		local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
		self:ClickScene(index,true)
	else
		self:FlushInfoList()
		self:FlushToggles()
		self:FlushTextInfo()
	end

end

function BossActiveView:FlushTextInfo()
	local max_wearry = BossData.Instance:GetActiveBossMaxWeary()
	local weary = max_wearry - BossData.Instance:GetActiveBossWeary()
	local pi_lao_text = ""
	if weary <= 0 then
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
	else
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.GREEN)
	end
	local max_text = ToColorStr(tostring(max_wearry), TEXT_COLOR.GREEN)
	-- local buy_weary_gold = BossData.Instance:GetActiveBuyWearyGold()
	self.node_list["Txt_Pilao"].text.text = string.format(Language.Boss.ActiveBossPiLaoValue, pi_lao_text .. " / " .. max_text)
	-- self.node_list["Txt_Money"].text.text = buy_weary_gold
	-- self:FlushTextLimit()

	local cfg = BossData.Instance.boss_family_cfg
	if cfg ~= nil and cfg.other[1] ~= nil and cfg.other[1].add_active_item ~= nil then
		local item_id = cfg.other[1].add_active_item
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		self.node_list["BtnAdd"]:SetActive(num > 0)
	end
end

function BossActiveView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossActiveView:GetSelectIndex()
	return self.select_index or 1
end

function BossActiveView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossActiveView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function BossActiveView:OnClickDownArrow()
	local max_num = #BossData.Instance:GetActiveBossList(self.select_scene_id) or 0
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
ActiveBossItemCell = ActiveBossItemCell or BaseClass(BaseCell)

function ActiveBossItemCell:__init()
	self.node_list["BossSelectItem"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickItem, self))
end

function ActiveBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ActiveBossItemCell:ClickItem(is_click)
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
		self.boss_view:FlushInfoList()
	end
end

function ActiveBossItemCell:OnFlush()
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
		-- local bundle, asset = ResPath.GetBoss("boss_item_bg_3")
		-- self.node_list["BGImage"].raw_image:LoadSprite(bundle, asset)

		-- local my_level = GameVoManager.Instance:GetMainRoleVo().level
		-- self.node_list["Img_tag_diaoluo"]:SetActive(my_level > self.data.max_lv)
	end
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time > 0 then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:OnBossUpdate()
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

function ActiveBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	local time = math.max(0, reflash_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self:UpdateKill(false)
		self.node_list["Img_hasflush"]:SetActive(true)
		-- self.node_list["TxtRefreshTime"].text.text = ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN)
	else
		self:UpdateKill(true)
		self.node_list["Img_hasflush"]:SetActive(false)
		self.node_list["TxtRefreshTime"]:SetActive(true)
		self.node_list["TxtRefreshTime"].text.text = ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED)
	end
end

function ActiveBossItemCell:UpdateKill(is_kill)
	UI:SetGraphicGrey(self.node_list["image"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["BGImage"], is_kill)
	-- UI:SetGraphicGrey(self.node_list["Img_tag_diaoluo"], is_kill)
end

function ActiveBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.node_list["ImgSelect"]:SetActive(select_index == self.index)
end

--toggle展示
ActiveBossToggle = ActiveBossToggle or BaseClass(BaseCell)

function ActiveBossToggle:__init()
	self.node_list["Toggle_Layer"].toggle.onValueChanged:AddListener(BindTool.Bind(self.ClickToggle, self))
end

function ActiveBossToggle:__delete()

end

function ActiveBossToggle:ClickToggle(isOn)
	if isOn then
		self.boss_view:ClickScene(self.index, isOn)
	end
end

function ActiveBossToggle:OnFlush()
	self.node_list["Txt_layer"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["Txt_hl"].text.text = string.format(Language.Boss.Floor, self.index)
	self.node_list["HL"]:SetActive(self.index == self.boss_view.layer)
	self.node_list["Toggle_Layer"].toggle.interactable = not (self.index == self.boss_view.layer)
end
