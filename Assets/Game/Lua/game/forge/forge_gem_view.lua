--装备-宝石
ForgeGem = ForgeGem or BaseClass(BaseRender)

function ForgeGem:__init(instance, parent_view)
	UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], true)
	UI:SetGraphicGrey(self.node_list["AutoUpgradeText"], false)
	self.node_list["BtnStop"]:SetActive(false)

	self.node_list["CloseBtn"].button:AddClickListener(BindTool.Bind(self.ShowOrHideGemList, self, false))
	self.node_list["ListBlackBG"].button:AddClickListener(BindTool.Bind(self.ShowOrHideGemList, self, false))
	self.node_list["OptionBlackBG"].button:AddClickListener(BindTool.Bind(self.ShowOrHideGemOption, self, false))
	self.node_list["UnloadButton"].button:AddClickListener(BindTool.Bind(self.UnloadClick, self))
	self.node_list["LevelUpButton"].button:AddClickListener(BindTool.Bind(self.LevelUpClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	-- self.node_list["BtnTotalGem"].button:AddClickListener(BindTool.Bind(self.ShowOrHideTotalGem, self, false))
	self.node_list["BtnAutoUpgrade"].button:AddClickListener(BindTool.Bind(self.AutoUpgradeClick, self))
	self.node_list["BtnStop"].button:AddClickListener(BindTool.Bind(self.CancelAutoUpgradeClick, self))
	self.node_list["BtnReplace"].button:AddClickListener(BindTool.Bind(self.ReplaceClick, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))

	self.gem_list = {}
	local child_number = self.node_list["GemGroup"].transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = self.node_list["GemGroup"].transform:GetChild(i).gameObject
		obj = obj.transform:GetChild(0)
		if string.find(obj.name, "GemCell") ~= nil then
			self.gem_list[count] = GemSoltCell.New(obj)
			self.gem_list[count]:SetIndex(i)
			self.gem_list[count]:SetClickCallBack(BindTool.Bind(self.ClickGemSlotCell, self))
			count = count + 1
		end
	end

	-- self.bag_gem_list = {}
	-- local list_view_delegate = self.node_list["BagGemScroller"].list_simple_delegate
	-- list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipCell"])
	self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	
	self.goal_data = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["PowerNum"])
end

function ForgeGem:__delete()
	-- for k, v in pairs(self.bag_gem_list) do
	-- 	v:DeleteMe()
	-- end
	-- self.bag_gem_list = {}
	self.gem_list = {}

	if self.equip_cell then
		self.equip_cell:DeleteMe()
	end
	self.equip_cell = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.goal_data = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ForgeGem:ClickEquipListCallBack(index)
	self:CancelAutoUpgradeClick()
	self.select_index = index
	self:Flush()
end

function ForgeGem:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_gem)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			-- UITween.AlpahShowPanel(self.node_list["BtnTotalGem"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			UITween.AlpahShowPanel(self.node_list["BtnHelp"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, ui_cfg["MOVE_TIME"] , DG.Tweening.Ease.InExpo)
		end
	end
	self:FlshGoalContent()

	if self.select_index == nil then
		for i = 1, 6 do
			self.gem_list[i]:SetOnEquipDataState()
		end
		return 
	end

	local data_list = EquipData.Instance:GetDataList()
	self.cell_data = EquipData.Instance:GetGridData(self.select_index)
	if nil == self.cell_data or nil == self.cell_data.item_id then
		for i = 1, 6 do
			self.gem_list[i]:SetOnEquipDataState()
		end
		return 
	end

	self.equip_cell:SetData(self.cell_data)
	self.equip_cell:ShowEquipGrade(false)
	self.equip_cell:ShowStrengthLable(true)
	self.gem_slot_data = ForgeData.Instance:GetEquipGemInfo(self.cell_data.index)
	self.bag_other_gem_data = ForgeData.Instance:GetCurBagGemList(self.cell_data.index)
	self.bag_had_gem_data = ForgeData.Instance:GetHadGemsInBag()
	self.bag_gem_list_data = self.bag_other_gem_data
	for i = 1, 6 do
		self.gem_list[i]:SetOtherData(self.cell_data, self.bag_other_gem_data, self.bag_had_gem_data)
		self.gem_list[i]:SetData(self.gem_slot_data[i - 1])
	end

	local power = ForgeData.Instance:GetGemPowerByIndex(self.cell_data.index)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = power or 0
	end

	local gem_total_lv = ForgeData.Instance:GetGemTotalLevel()
	self.node_list["TextGemTotalLv"]:SetActive(gem_total_lv ~= 0)
	self.node_list["TextGemTotalLv"].text.text = string.format(Language.Forge.StrengthenTotalLv, Language.Forge.TabbarName["BaoShi"], gem_total_lv)
end

-- 1 宝石操作  2 打开背包宝石
function ForgeGem:ClickGemSlotCell(click_type ,slot_index, pos, is_up_power, is_can_replace)
	self.select_slot_index = slot_index
	if click_type == 1 then
		if is_can_replace then
			local item_id = self.gem_slot_data[self.select_slot_index].gem_id
			local gem_cfg = ForgeData.Instance:GetGemCfg(item_id)
			if gem_type then
				local gem_type = gem_cfg.stone_type
				local gem_type_tab = self.bag_had_gem_data[gem_type]	
				local tab = {}
				for k,v in pairs(gem_type_tab) do
					if v.item_id > item_id then
						table.insert(tab, v)
					end
				end
				self.bag_gem_list_data = tab
				table.sort(self.bag_gem_list_data, SortTools.KeyUpperSorter("item_id"))
			end
			-- self.node_list["BagGemScroller"].scroller:ReloadData(0)
		end
		self.node_list["BtnReplace"]:SetActive(is_can_replace)
		self.node_list["LevelUpButton"]:SetActive(is_up_power)
		self:ShowOrHideGemOption(true, pos)
	elseif click_type == 2 then
		-- self.node_list["BagGemScroller"].scroller:ReloadData(0)
		self:ShowOrHideGemList(true)
	end
end

-- function ForgeGem:GetNumberOfCells()
-- 	return #self.bag_gem_list_data or 0
-- end

-- -- 背包宝石列表
-- function ForgeGem:RefreshListView(cell, cell_index)
-- 	cell_index = cell_index + 1
-- 	local item_cell = self.bag_gem_list[cell]
-- 	if nil == item_cell then
-- 		item_cell = GemScrollerCell.New(cell.gameObject)
-- 		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickGemListCell, self))
-- 		self.bag_gem_list[cell] = item_cell
-- 	end

-- 	local data = self.bag_gem_list_data[cell_index]
-- 	item_cell:SetIndex(cell_index)
-- 	item_cell:SetSelectHL(cell_index == self.select_gem_list_index)
-- 	item_cell:SetData(data)
-- end

-- --显示或隐藏可镶嵌列表
function ForgeGem:ShowOrHideGemList(is_show)
	-- self.node_list["GemList"]:SetActive(is_show)
	if not is_show then
		self.select_gem_bag_index = nil
		self.select_gem_list_index = 0
		self.bag_gem_list_data = self.bag_other_gem_data
	else
		local replace_data = {}
		if self.replace_flag then
			replace_data = ForgeData.Instance:GetCurBagGemReplaceList(self.cell_data.index)
		end
		local data = {
			gem_list = self.replace_flag and replace_data or self.bag_gem_list_data,
			select_index = self.select_index,
			select_slot_index = self.select_slot_index,
			replace_flag = self.replace_flag
		}
		ForgeCtrl.Instance:OpenGemListView(data)
		self.replace_flag = false
	end
end

function ForgeGem:OnClickGemListCell(gem_cell)
	local data = gem_cell:GetData()
	if nil == data then return end

	self.select_gem_bag_index = data.index
	self.select_gem_list_index = gem_cell:GetIndex()
	for k, v in pairs(self.bag_gem_list) do
		v:SetSelectHL(self.select_gem_list_index == v:GetIndex())
	end
	self:InlayClick()
end

-- --镶嵌按下后
function ForgeGem:InlayClick()
	if nil == next(self.bag_gem_list_data) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NotSelectGem)
		return
	end

	if self.replace_flag then
		ForgeCtrl.Instance:SendStoneInlay(self.select_index, self.select_slot_index, 0, 0)
		self.replace_flag = false
	end

	ForgeCtrl.Instance:SendStoneInlay(self.select_index, self.select_slot_index, self.select_gem_bag_index, 1)
	self:ShowOrHideGemList(false)
end

-- 宝石槽操作显示
function ForgeGem:ShowOrHideGemOption(is_show, pos)
	self.node_list["GemOption"]:SetActive(is_show)
	if is_show then
		self.node_list["GemOptionPlane"].transform.position = pos
	end
end
-- 摘下
function ForgeGem:UnloadClick()
	ForgeCtrl.Instance:SendStoneInlay(self.select_index, self.select_slot_index, 0, 0)
	self:ShowOrHideGemOption(false)
end

-- 升级
function ForgeGem:LevelUpClick()
	self.gem_list[self.select_slot_index + 1]:ImproveClick()
	self:ShowOrHideGemOption(false)
end

-- 替换
function ForgeGem:ReplaceClick()
	self.replace_flag = true
	self:ShowOrHideGemList(true)
	self:ShowOrHideGemOption(false)
end

function ForgeGem:ClickHelp()
	local tips_id = 255
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--打开或关闭全身宝石奖励(屏蔽)
-- function ForgeGem:ShowOrHideTotalGem()
-- 	local level, current_cfg, next_cfg = ForgeData.Instance:GetTotalGemCfg()
-- 	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeGemSuitAtt, level, current_cfg, next_cfg)
-- end

--按下了自动升级
function ForgeGem:AutoUpgradeClick()
	if self.cell_data == nil or self.cell_data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	self.node_list["BtnStop"]:SetActive(true)
	self.node_list["BtnAutoUpgrade"]:SetActive(false)
	self:AutoUpgrade()
end

--自动升级
function ForgeGem:AutoUpgrade()
	local reason_list = {}
	for i = 1, #self.gem_list do
		local have_upgrade, reason = self.gem_list[i]:AutoUpgrade()
		reason_list[i] = reason
		if have_upgrade then
			UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], false)
			UI:SetGraphicGrey(self.node_list["AutoUpgradeText"], true)
			self:CancelQuest()
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
				local bag_empty_num = ItemData.Instance:GetEmptyNum()
				if bag_empty_num ~= 0 then
					self:AutoUpgrade()
				else
					self:CancelAutoUpgradeClick()
				end
			end, 0.5)
			return
		end
	end
	UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], true)
	UI:SetGraphicGrey(self.node_list["AutoUpgradeText"], false)

	self.node_list["BtnStop"]:SetActive(false)
	self.node_list["BtnAutoUpgrade"]:SetActive(true)
	if self.cell_data.param.strengthen_level == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.OpenMorePos)
		return
	end
	for k,v in pairs(reason_list) do
		if v ~= 1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoEnoughGem)
			return
		end
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.Forge.AllGemMaxLevel)
end

function ForgeGem:CancelAutoUpgradeClick()
	self.node_list["GemOption"]:SetActive(false)
	self.node_list["GemList"]:SetActive(false)

	self.node_list["BtnStop"]:SetActive(false)
	self.node_list["BtnAutoUpgrade"]:SetActive(true)
	UI:SetButtonEnabled(self.node_list["BtnAutoUpgrade"], true)
	UI:SetGraphicGrey(self.node_list["AutoUpgradeText"], false)
	self:CancelQuest()
end

function ForgeGem:CancelQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

-- 宝石大小目标
function ForgeGem:FlshGoalContent()
	self.goal_info = ForgeData.Instance:GetGemGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
				if goal_cfg_info then
					local title_id = goal_cfg_info.reward_show
					local item_id = goal_cfg_info.reward_item[0].item_id
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[0] == 1

					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					local cfg = TitleData.Instance:GetTitleCfg(title_id)
					if nil == cfg then
						return
					end
					local zhanli = CommonDataManager.GetCapabilityCalculation(cfg)
					local bundle, asset = ResPath.GetTitleIcon(title_id)
					self.node_list["Img_chenghao"].image:LoadSprite(bundle, asset, function() 
						TitleData.Instance:LoadTitleEff(self.node_list["Img_chenghao"], title_id, true)
						UI:SetGraphicGrey(self.node_list["Img_chenghao"], self.goal_info.active_flag[0] == 0)
						end)
					self.node_list["Txt_fightpower"].text.text = Language.Goal.PowerUp .. zhanli
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					-- local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
					local item_bundle, item_asset = ResPath.GetBigGoalImg(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE)
					self.node_list["Img_touxiang"].image:LoadSprite(item_bundle, item_asset)
					self.goal_data.item_id = item_id
					self.goal_data.cost = goal_cfg_info.cost
					self.goal_data.can_fetch = self.goal_info.active_flag[1] == 1
					diff_time = diff_time + goal_cfg_info.free_time_since_open * 3600
					self.node_list["Txt_shuxing"].text.text = string.format(Language.Goal.AttrAdd, attr_percent/100) .. "%"
					self.node_list["NodeGoal"].animator:SetBool("IsShake" , self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
				end
			else
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(false)
				self.node_list["Txt_shuxing"]:SetActive(false)
			end
		end

		self.goal_data.left_time = diff_time
		if self.count_down == nil then
			function diff_time_func(elapse_time, total_time)
				local left_time = math.floor(diff_time - elapse_time + 0.5)
				if left_time <= 0 then
					if self.count_down ~= nil then
						self.node_list["Txt_lefttime"]:SetActive(false)
						CountDown.Instance:RemoveCountDown(self.count_down)
						self.count_down = nil
					end
					return
				end
				if left_time > 0 then
					self.node_list["Txt_lefttime"]:SetActive(true)
					self.node_list["Txt_lefttime"].text.text = Language.Goal.FreeTime .. TimeUtil.FormatSecond(left_time, 10)
				else
					self.node_list["Txt_lefttime"]:SetActive(false)
				end

				if self.goal_info.fetch_flag[0] == 1 and self.goal_info.fetch_flag[1] == 1 then
					self.node_list["Txt_lefttime"]:SetActive(false)
				end
			end

			diff_time_func(0, diff_time)
			self.count_down = CountDown.Instance:AddCountDown(
				diff_time, 0.5, diff_time_func)
		end
	end
end

function ForgeGem:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_STONE, is_other_item)
end


-- ---------------------------
-- ----------- 宝石槽 GemSoltCell
GemSoltCell = GemSoltCell or BaseClass(BaseCell)

function GemSoltCell:__init()
	self.node_list["ImproveButton"].button:AddClickListener(BindTool.Bind(self.ImproveClick, self))
	self.node_list["GemIcon"].button:AddClickListener(BindTool.Bind(self.GemIconClick, self))
	self.node_list["PlusButton"].button:AddClickListener(BindTool.Bind(self.PlusClick, self))

end

function GemSoltCell:__delete()
	if self.effect_obj then
		ResPoolMgr:Release(self.effect_obj)
		self.effect_obj = nil
	end		
end

function GemSoltCell:SetOtherData(equip_data, bag_other_gem, bag_had_gem)
	self.equip_data = equip_data
	self.bag_other_gem = bag_other_gem
	self.bag_had_gem = bag_had_gem
end

--宝石格子的状态: 0、锁定 1、可镶嵌 2、已镶嵌
function GemSoltCell:OnFlush()
	self.is_can_inlay = false
	self.is_can_upgrade = false
	self.is_can_up_power = false
	self.is_can_replace = false
	self.best_gem = nil
	self.node_list["ImproveButton"]:SetActive(false)
	self.node_list["Attr1"]:SetActive(true)
	self.node_list["Attr2"]:SetActive(true)
	self.node_list["GemName"].text.text = ""
	if nil == self.data or nil == self.equip_data then return end

	if self.data.gem_state == 0 then
		self:LockState()
	elseif self.data.gem_state == 1 then
		self:OpenState()
	elseif self.data.gem_state == 2 then
		self:InlayState()
	end
end

function GemSoltCell:LockState()
	self.node_list["Icon_Lock"]:SetActive(true)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["ImproveButton"]:SetActive(false)
	self.node_list["GemIcon"]:SetActive(false)
	self.node_list["GemIconBg"]:SetActive(false)		
	self.node_list["Attr2"].text.text = ""

	self:SetCellEffect(false)
	local limit_cfg = ForgeData.Instance:GetGemOpenLimitCfg(self.equip_data.index, self.index)
	if limit_cfg then
		local text_value = (string.format(Language.Forge.GemOpenLimit[limit_cfg.limit], limit_cfg.param1))
		self.node_list["Attr1"].text.text = text_value
	else
		self.node_list["Attr1"].text.text = ""
	end
end

function GemSoltCell:OpenState()
	self.node_list["Icon_Lock"]:SetActive(false)
	self.node_list["PlusButton"]:SetActive(true)
	self.node_list["GemIcon"]:SetActive(false)
	self.node_list["GemIconBg"]:SetActive(false)
	self.node_list["Attr1"].text.text = ""
	self.node_list["Attr2"].text.text = ""

	self:SetCellEffect(false)
	if (self.bag_other_gem ~= nil) and (next(self.bag_other_gem) ~= nil) then
		self.is_can_inlay = true
	end
	self.node_list["ImproveButton"]:SetActive(self.is_can_inlay)
end

function GemSoltCell:InlayState()
	self.node_list["Icon_Lock"]:SetActive(false)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["GemIcon"]:SetActive(true)
	self.node_list["GemIconBg"]:SetActive(true)

	local icon_cfg = ItemData.Instance:GetItemConfig(self.data.gem_id)
	local asset = QUALITY_ICON[icon_cfg.color]
	self.node_list["GemIconBg"].image:LoadSprite(ResPath.GetImages(asset))
	self.node_list["GemIcon"].image:LoadSprite(ResPath.GetItemIcon(self.data.gem_id))
	self.node_list["GemName"].text.text = ToColorStr(icon_cfg.name,  ORDER_COLOR[icon_cfg.color])

	-- self:SetCellEffect(true, icon_cfg.color)

	local attrs = ForgeData.Instance:GetGemAttr(self.data.gem_id)
	for i = 1, 2 do
		if attrs[i] == nil or attrs[i] == 0 then
			self.node_list["Attr"..i].text.text = ""
		else
			self.node_list["Attr"..i].text.text = attrs[i].attr_name .. ':  ' .. attrs[i].attr_value
		end
	end
	
	local gem_type = ForgeData.Instance:GetGemTypeByid(self.data.gem_id)
	self.bag_type_gem = self.bag_had_gem[gem_type]
	if not self.bag_type_gem then return end
	--处理可替换
	local max_id = self.data.gem_id
	for k,v in pairs(self.bag_type_gem) do
		if v.item_id > max_id then
			self.is_can_replace = true
			self.best_gem = v
			max_id = v.item_id
		end
	end
	self.max_level = false
	if self.best_gem == nil then
		--处理可升级
		local forge_gem_cfg = ForgeData.Instance:GetGemCfg(self.data.gem_id)
		if forge_gem_cfg then
			local level = forge_gem_cfg.level
			local next_cfg = ForgeData.Instance:GetGemCfgByTypeAndLevel(forge_gem_cfg.stone_type, level + 1)
			if next_cfg ~= nil then
				local upgrade_need_energy = math.pow(next_cfg.level_need_num, level) - math.pow(next_cfg.level_need_num, level - 1)
				local had_energy = 0
				for k,v in pairs(self.bag_type_gem) do
					if v.item_id <= forge_gem_cfg.item_id then
						local tmp_forge_gem_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
						if tmp_forge_gem_cfg then
							had_energy = had_energy + (math.pow(tmp_forge_gem_cfg.level_need_num, tmp_forge_gem_cfg.level - 1) * v.num)
						end
					end
				end
				if had_energy >= upgrade_need_energy then
					self.is_can_upgrade = true
					self.is_can_up_power = true
					self.node_list["ImproveButton"]:SetActive(true)
				end
			else
				self.max_level = true
			end
		end
	else
		self.is_can_up_power = true
		self.node_list["ImproveButton"]:SetActive(true)
	end		
end

function GemSoltCell:SetCellEffect(is_show, color)
	if self.effect_obj then
		self.effect_obj:SetActive(is_show)
	else
		if is_show then
			local effect_bundle, effect_asset = ResPath.GetItemEffect(color)
			ResPoolMgr:GetEffectAsync(effect_bundle, effect_asset, function(obj)
				if nil == obj then
					return
				end
				obj.transform:SetParent(self.node_list["GemIconBg"].transform)
				obj.name = "effect_obj"
				obj.gameObject.transform.localScale = Vector3(1, 1, 1)
				obj.gameObject.transform.localPosition = Vector3(0, 0, 0)
				self.effect_obj = obj
			end)
		end
	end
end

-- --按下了自动镶嵌/替换/升级
function GemSoltCell:ImproveClick()
	if nil == self.equip_data then return end

	if self.is_can_inlay then
		self:PlusClick()
		return
	end

	if self.best_gem ~= nil then
		--可换更好的宝石
		ForgeCtrl.Instance:SendStoneInlay(self.equip_data.index, self.index, 0, 0)
		ForgeCtrl.Instance:SendStoneInlay(self.equip_data.index, self.index, self.best_gem.index, 1)
		return true
	elseif self.is_can_upgrade then
		--可升级
		ForgeCtrl.Instance:SendStoneUpgrade(self.equip_data.index, self.index, 1)
		return true
	else
		if self.max_level then
			return false, 1
		else
			return false, 0
		end
	end
end

function GemSoltCell:GemIconClick()
	local dis = 10
	local pos = self.root_node.transform.position
	if self.index < 2 then
		pos.x = pos.x - dis
	else
		pos.x = pos.x + dis
	end
	self.click_callback(1, self.index, pos, self.is_can_up_power, self.is_can_replace)
end

function GemSoltCell:PlusClick()
	if nil == self.equip_data then return end
	
	if self.is_can_inlay then
		self.click_callback(2, self.index)
	else
		local gem_type = ForgeData.Instance:GetMinType(self.equip_data.index)
		local gem_cfg = ForgeData.Instance:GetMinLevelGemTypeCfg(gem_type)
		if nil == gem_cfg then return end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, gem_cfg.item_id, nil, 1)
	end
end

--自动提升
function GemSoltCell:AutoUpgrade()
	local sort_type_tab = {
		[2] = 1, [1] = 2, [0] = 3,
		[4] = 4, [3] = 5, [5] = 6
	}

	if self.is_can_inlay then
		local max_id = 0
		local best_gem = nil
		for k, v in pairs(self.bag_other_gem) do
			local id_cfg = ForgeData.Instance:GetGemCfg(v.item_id)
			local max_id_cfg = ForgeData.Instance:GetGemCfg(max_id)
			local id_sort_index = sort_type_tab[id_cfg.stone_type]
			local max_sort_index = max_id_cfg and sort_type_tab[max_id_cfg.stone_type] or -1

			if not max_id_cfg or (id_sort_index >= max_sort_index) then
				if id_sort_index == max_sort_index and max_id_cfg and tonumber(id_cfg.level) > tonumber(max_id_cfg.level) then
					best_gem = v
					max_id = v.item_id
				elseif id_sort_index ~= max_sort_index then
					best_gem = v
					max_id = v.item_id
				end
			end
		end

		if best_gem then
			ForgeCtrl.Instance:SendStoneInlay(self.equip_data.index, self.index, best_gem.index, 1)
		end
		return true
	-- else 屏蔽升级宝石功能
		-- local have_improve, reason = self:ImproveClick()
		-- return have_improve, reason
	end
end

-- 没有数据时的格子状态
function GemSoltCell:SetOnEquipDataState()
	self.node_list["Icon_Lock"]:SetActive(true)
	self.node_list["PlusButton"]:SetActive(false)
	self.node_list["GemIcon"]:SetActive(false)
	self.node_list["GemIconBg"]:SetActive(false)
	self.node_list["ImproveButton"]:SetActive(false)
end

-----------------------------------------
-- 背包宝石 GemScrollerCell  obj_name:GemItem

-- GemScrollerCell = GemScrollerCell or BaseClass(BaseCell)
-- function GemScrollerCell:__init()
-- 	self.item_cell = ItemCell.New()
-- 	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
-- 	self.item_cell:ListenClick(function()end)

-- 	self.root_node.button:AddClickListener(BindTool.Bind(self.OnClickCell, self))
-- end

-- function GemScrollerCell:__delete()
-- 	if self.item_cell then
-- 		self.item_cell:DeleteMe()
-- 	end
-- end

-- function GemScrollerCell:OnFlush()
-- 	self.item_cell:SetData(self.data)
-- 	self.node_list["NameTxt"].text.text = self.data.cfg.name
-- end

-- function GemScrollerCell:OnClickCell()
-- 	BaseCell.OnClick(self)
-- end

-- function GemScrollerCell:SetSelectHL(is_hl)
-- 	self.node_list["HLBg"]:SetActive(is_hl)
-- end

