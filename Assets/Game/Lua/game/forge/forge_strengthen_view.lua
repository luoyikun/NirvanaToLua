--装备-强化
ForgeStrengthen = ForgeStrengthen or BaseClass(BaseRender)

function ForgeStrengthen:__init(instance, parent_view)
	self.parent_view = parent_view
	self.is_auto_buy_stone = 0
	self.use_lucky_item = 0

	self.node_list["AutoBuyToggle"].toggle.onValueChanged:AddListener(BindTool.Bind(self.AutoBuyChange, self))
	self.node_list["BtnStrength"].button:AddClickListener(BindTool.Bind(self.OnClickStrengthen, self))
	-- self.node_list["BtnStrengthSuit"].button:AddClickListener(BindTool.Bind(self.OpenTotalStrenthTips, self))
	self.node_list["ToggleLuckyItem"].button:AddClickListener(BindTool.Bind(self.LuckyItemClick, self))
	self.node_list["UseLuckyMark"].button:AddClickListener(BindTool.Bind(self.LuckyItemClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))

	self.material_cell = ItemCell.New()
	self.material_cell:SetInstanceParent(self.node_list["Material"])
	self.curr_state = StrengthStateCell.New(self.node_list["LeftFrame"])
	self.next_state = StrengthStateCell.New(self.node_list["RightFrame"], true)
	self.goal_data = {}

	ForgeData.Instance:SetStrengthStoneNum()
	RemindManager.Instance:Fire(RemindName.ForgeStrengthen)
end

function ForgeStrengthen:__delete()
	if self.curr_state then
		self.curr_state:DeleteMe()
		self.curr_state = nil
	end

	if self.next_state then
		self.next_state:DeleteMe()
		self.next_state = nil
	end

	if self.material_cell then
		self.material_cell:DeleteMe()
		self.material_cell = nil
	end

	self.parent_view = nil
	self.goal_data = {}
	
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ForgeStrengthen:CloseCallBack()
	ForgeData.Instance:SetStrengthStoneNum()
end

-- 功能引导强化按钮
function ForgeStrengthen:GetBtnStrength()
	return self.node_list["BtnStrength"], BindTool.Bind(self.OnClickStrengthen, self)
end

function ForgeStrengthen:ClickEquipListCallBack(index)
	self.select_index = index
	self:Flush()
end

function ForgeStrengthen:StopShowEffect()
	self.node_list["SuccessEffect"]:SetActive(false)
	self.node_list["FailEffect"]:SetActive(false)
end

function ForgeStrengthen:ShowStrengthenEffect(result)
	self:StopShowEffect()
	self.node_list["SuccessEffect"]:SetActive(result >= 1)
	self.node_list["FailEffect"]:SetActive(result <= 0)
end

function ForgeStrengthen:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "ui_tween" then
			local ui_cfg = ForgeData.Instance:GetUITweenCfg(TabIndex.forge_strengthen)
			UITween.MoveShowPanel(self.node_list["DownPanel"] , ui_cfg["DownPanel"], ui_cfg["MOVE_TIME"])
			UITween.AlpahShowPanel(self.node_list["UpPanel"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			-- UITween.AlpahShowPanel(self.node_list["BtnStrengthSuit"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			UITween.AlpahShowPanel(self.node_list["BtnHelp"] , ui_cfg["UpPanel"], ui_cfg["MOVE_TIME"], DG.Tweening.Ease.InExpo)
			UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, ui_cfg["MOVE_TIME"] , DG.Tweening.Ease.InExpo)
		end
	end	
	
	self:FlshGoalContent()

	if self.select_index == nil then return end

	self.cell_data = EquipData.Instance:GetGridData(self.select_index)
	if nil == self.cell_data or nil == self.cell_data.item_id then 
		return 
	end

	-- 请求宝石信息（强化到某个等级 开启宝石槽） 容错5级处理
	-- local level = self.cell_data.param.strengthen_level
	-- if  8 <= level and level <= 13 or 
	-- 	18 <= level and level <= 23 or 
	-- 	28 <= level and level <= 33 or 
	-- 	38 <= level and level <= 43 or 
	-- 	level == 50 then
	-- 	ForgeCtrl.Instance:SendStoneInfo()
	-- end

	local data = self.cell_data
	local next_data = TableCopy(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local max_level = ForgeData.Instance:GetMaxStrengthLevelByGrade(data.index)
	self.is_max_level = max_level and (max_level <= data.param.strengthen_level)
	self.next_cfg = {}
	if self.is_max_level then
		self.next_state:SetMaxLevel(true)
		self.next_cfg = ForgeData.Instance:GetStrengthCfg(data.index, data.param.strengthen_level)

		self.material_cell:SetData({})
		self.node_list["MaterialNumTxt"].text.text = ""
		self.node_list["SuccessRateTxt"].text.text = ""
		self.node_list["LuckyItemNumTxt"].text.text = ""
		self.node_list["ItemIcon"]:SetActive(false)
		self.node_list["UseLuckyMark"]:SetActive(false)
		self.node_list["MaterialContent"]:SetActive(false)
		self.node_list["BtnStrengthText"].text.text = Language.Common.YiManJi
		self.node_list["ToggleLuckyItem"]:SetActive(false)
		UI:SetButtonEnabled(self.node_list["BtnStrength"], false)
		UI:SetGraphicGrey(self.node_list["BtnStrength"], true)

		self.node_list["LeftFrame"]:SetActive(false)
		self.node_list["ArrowImage"]:SetActive(false)
	else
		self.next_state:SetMaxLevel(false)
		next_data.param.strengthen_level = next_data.param.strengthen_level + 1
		self.next_cfg = ForgeData.Instance:GetStrengthCfg(data.index, data.param.strengthen_level + 1)
		if not self.next_cfg then return end

		self.material_cell:SetData({item_id = self.next_cfg.stuff_id})
		local need_item_num = self.next_cfg.stuff_count
		local had_item_num = ItemData.Instance:GetItemNumInBagById(self.next_cfg.stuff_id)
		local need_item_text = " / " .. need_item_num
		local had_item_text = ""
		need_item_text = ToColorStr(need_item_text,TEXT_COLOR.GREEN_4)
		had_item_text = ToColorStr(had_item_num, (had_item_num < need_item_num and COLOR.RED or TEXT_COLOR.GREEN_4))
		self.node_list["MaterialNumTxt"].text.text = had_item_text .. need_item_text

		self.node_list["BtnStrengthText"].text.text = Language.Forge.QiangHua
		UI:SetButtonEnabled(self.node_list["BtnStrength"], true)
		UI:SetGraphicGrey(self.node_list["BtnStrength"], false)

		self.node_list["LeftFrame"]:SetActive(true)
		self.node_list["ArrowImage"]:SetActive(true)

		self:CalculateSuccessRata()
		
		if self:GetIsNeedLuckyItem() then
			self.node_list["ToggleLuckyItem"]:SetActive(true)
			local is_enough = false
			local need_num = 0
			local had_num = 0
			is_enough, had_num, need_num = self:GetIsEnoughLuckyItem()
			if is_enough then
				self:SetLuckyItemNum(need_num, had_num)
			else
				self:SetLuckyItemNum(need_num, had_num)
				self.use_lucky_item = 0
			end
			--是否使用中
			local is_use = self.use_lucky_item == 1
			self.node_list["ItemIcon"]:SetActive(is_use)
			self.node_list["ItemQuality"]:SetActive(is_use)
			self.node_list["UseLuckyMark"]:SetActive(not (is_use))
		else
			self.node_list["ToggleLuckyItem"]:SetActive(false)
		end
		self.node_list["MaterialContent"]:SetActive(true)
	end

	if self.next_cfg and next(self.next_cfg) then
		self.limit_grade = self.next_cfg.need_order
	end
	self.curr_state:SetData(data)
	self.next_state:SetData(next_data)
	self:CalculateStrengthenTotalLv()
end

-- 计算强化总等级
function ForgeStrengthen:CalculateStrengthenTotalLv()
	local equip_data = EquipData.Instance:GetDataList()
	local total_lv = 0
	for k, v in pairs(equip_data) do
		total_lv = total_lv + v.param.strengthen_level
	end
	self.node_list["TextStrengthenTotalLv"]:SetActive(total_lv ~= 0)
	self.node_list["TextStrengthenTotalLv"].text.text = string.format(Language.Forge.StrengthenTotalLv, Language.Forge.TabbarName["Strengthen"], total_lv)
end

--计算成功率
function ForgeStrengthen:CalculateSuccessRata()
	if not self.next_cfg or not next(self.next_cfg) then
		self.node_list["SuccessRateTxt"].text.text = ""
		return
	end

	local vip_str = ""
	local vip_param = VipPower.Instance:GetParam(VipPowerId.qianghua_suc)
	if vip_param ~= nil and vip_param > 0 then
		vip_str = vip_param and "+" .. vip_param .. "%" or ""
	end
	local rate_str = self.next_cfg.show_succ_rate .. "%"
	rate_str = rate_str
	self.node_list["SuccessRateTxt"].text.text = rate_str

	local is_active_card = ImmortalData.Instance:IsActive(1)
	self.node_list["LabelBuff"]:SetActive(is_active_card)
	if is_active_card then 
		local immort_cfg = ImmortalData.Instance:GetCardDescCfg(1)
		if immort_cfg == nil or next(immort_cfg) == nil then return end
		local succ_rate = immort_cfg.add_equip_strength_succ_rate / 100
		self.node_list["LabelBuff"].text.text = string.format(Language.Xianzunka.StrengthSucc, succ_rate or 0)
	end
end

-- 显示使用幸运符图标
function ForgeStrengthen:SetLuckyItemNum(need_num, had_num)
	local had_text = ""
	local need_text = ' / '..need_num
	need_text = ToColorStr(need_text,TEXT_COLOR.GREEN_4)
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.GREEN_4)
	else
		had_text = ToColorStr(had_num,COLOR.RED)
	end
	self.node_list["LuckyItemNumTxt"].text.text = had_text..need_text

	local item_cfg = ItemData.Instance:GetItemConfig(self.next_cfg.lucky_stuff_id)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		local bundle1, asset1 = ResPath.GetQualityIcon(item_cfg.color)
		self.node_list["ItemIcon"].image:LoadSprite(bundle, asset .. ".png")
		self.node_list["ItemQuality"].image:LoadSprite(bundle1, asset1)
	end
end

-- 强化按钮
function ForgeStrengthen:OnClickStrengthen()
	if self.cell_data == nil or self.cell_data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	local equip_cfg = ItemData.Instance:GetItemConfig(self.cell_data.item_id)
	if not equip_cfg then return end

	local equip_order = equip_cfg.order
	if not self.is_max_level and self.limit_grade and self.limit_grade > equip_order then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NotEnoughGrade)
		return
	elseif self.is_max_level then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.StrengthenGotLimit)
		return
	end

	local is_can_strength, item_id, need_num = self:CheckIsCanStrength()
	if is_can_strength == 0 then
		ForgeCtrl.Instance:SendQianghua(self.cell_data.index, self.is_auto_buy_stone, self.use_lucky_item)
	elseif is_can_strength == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.MaxLevel)
	elseif is_can_strength == 2 then
		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick and self.node_list and self.node_list["AutoBuyToggle"] then
				self.node_list["AutoBuyToggle"].toggle.isOn = true
				self.is_auto_buy_stone = 1
			end
		end
		local shop_item_cfg = ShopData.Instance:GetShopItemCfg(item_id)
		if need_num == nil then
			MarketCtrl.Instance:SendShopBuy(item_id, 999, 0, 1)
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, need_num)
		end
	end
end

--检查是否能强化,加上自动购买的条件 0、可以 1、到达顶级 2、不够材料
function ForgeStrengthen:CheckIsCanStrength()
	local flag, item_id, need_num = ForgeData.Instance:CheckStrengthIsCanImprove(self.cell_data)
	if flag == 0 then
		return 0
	elseif flag == 1 then
		return 1
	elseif flag == 2 then
		if self.is_auto_buy_stone == 1 then
			local stuff_id = self.next_cfg.stuff_id
			local stuff_count = self.next_cfg.stuff_count
			local test_shop_data = ConfigManager.Instance:GetAutoConfig("shop_auto").item
			local item_cfg = test_shop_data[stuff_id]

			if item_cfg ~= nil then
				local total_need_gold = item_cfg.gold * stuff_count
				local player_had_gold = PlayerData.Instance:GetRoleAllGold()
				if player_had_gold >= total_need_gold then
					return 0
				else
					return 2, stuff_id
				end
			end
		else
			return 2, item_id, need_num
		end
	end
end

--打开总强化奖励(屏蔽)
-- function ForgeStrengthen:OpenTotalStrenthTips()
-- 	local level = ForgeData.Instance:GetTotalStrengthLevel()
-- 	local cu_cfg, ne_cfg = ForgeData.Instance:GetTotalStrengthCfgByLevel(level)
-- 	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeSuitAtt, level, cu_cfg, ne_cfg)
-- end

--自动购买强化石Toggle点击时
function ForgeStrengthen:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ForgeStrengthen:HelpClick()
	local tips_id = 254
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--使用幸运符按钮按下
function ForgeStrengthen:LuckyItemClick()
	if self.use_lucky_item == 1 then
		self.node_list["ItemIcon"]:SetActive(false)
		self.node_list["ItemQuality"]:SetActive(false)
		self.node_list["UseLuckyMark"]:SetActive(true)
		self.use_lucky_item = 0
	else
		if self:GetIsEnoughLuckyItem() then
			self.node_list["ItemIcon"]:SetActive(true)
			self.node_list["ItemQuality"]:SetActive(true)
			self.node_list["UseLuckyMark"]:SetActive(false)
			self.use_lucky_item = 1
		else
			self.node_list["ItemIcon"]:SetActive(false)
			self.node_list["ItemQuality"]:SetActive(false)
			self.node_list["UseLuckyMark"]:SetActive(true)
			self.use_lucky_item = 0
			TipsCtrl.Instance:ShowItemGetWayView(self.next_cfg.lucky_stuff_id)
		end
	end
end

--身上是否有足够的luck符
function ForgeStrengthen:GetIsEnoughLuckyItem()
	local item_num = ItemData.Instance:GetItemNumInBagById(self.next_cfg.lucky_stuff_id)
	if item_num >= self.next_cfg.lucky_stuff_count then
		return true, item_num, self.next_cfg.lucky_stuff_count
	else
		return false, item_num, self.next_cfg.lucky_stuff_count
	end
end

--是否需要luck符
function ForgeStrengthen:GetIsNeedLuckyItem()
	if self.next_cfg.lucky_stuff_count > 0 then
		return true
	else
		return false
	end
end

-- 强化大小目标
function ForgeStrengthen:FlshGoalContent()
	self.goal_info = ForgeData.Instance:GetStrengthGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
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
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					if item_cfg == nil then
						return
					end
					local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
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

function ForgeStrengthen:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_EQUIP_STRENGTHEN, is_other_item)
end

--------------------------------------------------
------------- 装备状态 StrengthStateCell
--------------------------------------------------
StrengthStateCell = StrengthStateCell or BaseClass(BaseCell)
function StrengthStateCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])
	if not is_next then
		self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	else
		self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_COMPARE)
	end
	

	self.attr_list = {}
	local count = 1
	local child_number = self.node_list["AttrGroup"].transform.childCount
	for i = 0, child_number - 1 do
		local obj = self.node_list["AttrGroup"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local item_tab = {}
			item_tab.obj = obj
			item_tab.attr_value = variable_table["Attr"]
			item_tab.attr_valueNumber = variable_table["AttrValueNumber"]
			self.attr_list[count] = item_tab
			count = count + 1
		end
	end

	self.is_next = is_next or false

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightNum"])
end

function StrengthStateCell:__delete()
	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.parent_view = nil
	self.item_cfg = nil
	self.strength_cfg = nil
	self.fight_text = nil
end

function StrengthStateCell:OnFlush()
	if nil == self.data then return end

	if self.is_max_level then
		self.equip_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	elseif self.is_next then
		self.equip_cell:SetFromView(TipsFormDef.FROM_FORGE_COMPARE)
	end

	local data = self.data
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end

	local strength_cfg = ForgeData.Instance:GetStrengthCfg(data.index, data.param.strengthen_level)
	local total_attr, fight_power = self:GetAttrTabAndFight(strength_cfg)

	local str = "+" .. data.param.strengthen_level

	-- if self.is_next then
	-- 	str = self.is_max_level and Language.Common.YiManJi or (data.param.strengthen_level)
	-- else
	-- 	str = data.param.strengthen_level
	-- end

	local color_index = ForgeData.Instance:GetEquipColorIndex(data.index, data.param.quality)
	self.node_list["EquipName"].text.text = ToColorStr(item_cfg.name, ORDER_COLOR[color_index])
	self.node_list["LabelTitle"].text.text = str
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fight_power
	end
	self.equip_cell:SetData(data)
	self.equip_cell:ShowEquipGrade(false)

	for k, v in pairs(self.attr_list) do
		if k <= #total_attr then
			v.attr_value.text.text = total_attr[k].name .. '：'
			v.attr_valueNumber.text.text = total_attr[k].value
			v.obj:SetActive(true)
		else
			v.obj:SetActive(false)
		end	
	end
end

function StrengthStateCell:SetMaxLevel(is_max)
	self.is_max_level = is_max
end

function StrengthStateCell:GetAttrTabAndFight(strength_cfg)
	if nil == strength_cfg then 
		return {}, 0
	end
	
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(strength_cfg)
	local fight_power = CommonDataManager.GetCapabilityCalculation(attr_tab)
	local sort_attr = CommonDataManager.GetOrderAttributte(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(sort_attr) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = v.value
			count = count + 1
		end
	end
	return total_attr, fight_power
end
