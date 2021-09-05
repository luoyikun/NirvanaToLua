require("game/spirit/spirit_aptitude_view")
-- 仙宠-成长-SpiritContent
SonSpiritView = SonSpiritView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 96
local BAG_ROW = 4
local BAG_COLUMN = 4
local EFFECT_CD = 1
local APTITUDE_TYPE = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
local ATTR_TYPE = {"gongji", "fangyu", "maxhp"}

function SonSpiritView:__init(instance)

end

function SonSpiritView:LoadCallBack()
	-- self.node_list["BackpackButton"].toggle:AddClickListener(BindTool.Bind(self.OnClickBackPack, self))
	self.node_list["HuanHuaBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHuanHua, self))
	self.node_list["BtnChuZhan"].button:AddClickListener(BindTool.Bind(self.OnClickZhaoHui, self))
	self.node_list["BtnNorml"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["OneKeyEquipBtn"].button:AddClickListener(BindTool.Bind(self.OnClickOneKeyEquip, self))
	self.node_list["BackBtn"].button:AddClickListener(BindTool.Bind(self.OnClickReturn, self))
	-- self.node_list["BtnAttribute"].toggle:AddClickListener(BindTool.Bind(self.OnClickReturn, self))
	self.node_list["HelpBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["ReNameImg"].button:AddClickListener(BindTool.Bind(self.OnClickReName, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, true))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OpenWuXingDanBuy, self))
	self.node_list["ToggleChengZhang"].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, 1))
	self.node_list["ToggleWuXing"].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, 2))

	self.attr_view = SpiritAttrView.New(self.node_list["AttrView"])
	self.aptitude_view = SpiritAptitudeView.New(self.node_list["AptitudeView"])

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightingCapacity"])

	self.items = {}
	self.takeoff_image_list = {}
	self.show_fight_out_list = {}
	self.show_improve = {}
	self.show_remind_list = {}
	self.item_cell_list = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["Item" .. i])
		item_cell:SetToggleGroup(self.node_list["ItemToggleGroup"].toggle_group)
		self.items[i] = {item = self.node_list["Item" .. i], cell = item_cell}
		self.takeoff_image_list[i] = self.node_list["ImageBtn" .. i]
		self.node_list["ImageBtn" .. i].button:AddClickListener(BindTool.Bind(self.OnClickTakeOff, self, i))
		self.node_list["ItemBtn" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self, i, item_cell))
		item_cell:ListenClick(BindTool.Bind(self.OnClickBlock, self, i, item_cell))
		self.item_cell_list[i] = item_cell
		self.show_fight_out_list[i] = self.node_list["FightOutImg" .. i]
		self.show_improve[i] = self.node_list["PicImg" .. i]
		self.show_remind_list[i] = self.node_list["Remdind" .. i]
	end

	local list_delegate = self.node_list["PackListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.on_attr_view = false
	self.cur_click_index = 0
	self.spirit_cells = {}
	self.is_first = true
	self.is_click_item = false
	self.res_id = 0
	self.temp_spirit_list = {}
	self.goal_data = {}
	self.is_click_bag = false
	self.effect_cd = 0
	self.old_count = 0

	self.upgrade_jump_show = false

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritBag)

	self.is_first_open = true

	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Spirit)
	if is_open then
		local callback = function(node_list)
				node_list["BtnYiZhe"].button:AddClickListener(function()
				ViewManager.Instance:CloseAll()
				ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
			end)
				node_list["TextYiZhe"].text.text = data.button_name
				self:StartCountDown(data, node_list)
		end
		CommonDataManager.SetYiZheBtnJump(self, self.node_list["BtnYiZheJump"], callback)
	end

end

-- 一折抢购跳转
function SonSpiritView:StartCountDown(data, node_list)
	self:StopCountDown()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				self.node_list["BtnYiZheJump"]:SetActive(false)
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 一折抢购跳转
function SonSpiritView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function SonSpiritView:GetSonGuide()
	if self.node_list["ItemBtn1"] then
		return self.node_list["ItemBtn1"], BindTool.Bind(self.OnClickItem, self, 1, self.item_cell_list[1])
	end
end

function SonSpiritView:__delete()
	RemindManager.Instance:UnBind(self.remind_change, k)

	if self.spirit_cells ~= nil then
		for k, v in pairs(self.spirit_cells) do
			v:DeleteMe()
		end
	end
	if self.item_cell_list ~= nil then
		for k, v in pairs(self.item_cell_list) do
			v:DeleteMe()
		end
		self.item_cell_list = {}
	end

	for k, v in pairs(self.items) do
		v.cell:DeleteMe()
	end
	self.items = {}

	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end

	if self.aptitude_view then
		self.aptitude_view:DeleteMe()
		self.aptitude_view = nil
	end

	self.cur_bag_index = nil
	self.spirit_cells = {}
	self.is_first = nil
	self.cur_click_index = 0
	self.is_click_bag = nil
	self.temp_spirit_list = {}
	self.effect_cd = nil
	self.res_id = nil
	self.guide_cell = nil
	if self.time_quest then 
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.fight_text = nil
	self.first_time = nil

	self:StopCountDown()
end

function SonSpiritView:OpenCallBack()
	self.is_first = true
	self.is_click_bag = false
	self.res_id = nil
	self.temp_spirit_list = {}
	self:Flush()

	self.node_list["AptitudeView"]:SetActive(false)
	self.node_list["BtnBuy"]:SetActive(false)
	self.node_list["ToggleChengZhang"].toggle.isOn = true
	self.node_list["ToggleWuXing"].toggle.isOn = false

	if not is_show_bag then
		self.on_attr_view = true
	end
end

function SonSpiritView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.time_quest = nil
	self.res_id = 0
	self.is_first = true
end

function SonSpiritView:FlshGoalContent()
	self.goal_info = SpiritData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
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
					self.node_list["little_goal_redpoint"]:SetActive(self.goal_data.can_fetch)
				end
			else
				self.node_list["Txt_lefttime"]:SetActive(false)
				self.node_list["Node_little_goal"]:SetActive(false)
			end
		else
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
					local item_id = goal_cfg_info.reward_item[0].item_id
					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					local type_cfg = SpiritData.Instance:GetSpecialSpiritImageCfgByItemID(item_id)
					local spirit_info = SpiritData.Instance:GetSpiritInfo()
					if spirit_info == nil or type_cfg == nil then
						return
					end
					local huanhua_id = type_cfg.active_image_id
					local bit_list = spirit_info.special_img_active_flag
					local active = bit_list[huanhua_id] == 1
					self.node_list["Effect"]:SetActive(not active)

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
					self.node_list["big_goal_redpoint"]:SetActive(self.goal_data.can_fetch and self.goal_info.fetch_flag[1] ~= 1)
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

function SonSpiritView:RemindChangeCallBack(remind_name, num)
	if RemindName.SpiritBag == remind_name then
		self.node_list["RedImg"]:SetActive(num > 0)
	end
end

function SonSpiritView:OpenTipsTitleLimit(is_model)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_XIANCHONG)
end

-- 打开悟性丹收购
function SonSpiritView:OpenWuXingDanBuy()
	MarketData.Instance:SetPurchaseItemId(2)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 2})
	-- ViewManager.Instance:Open(ViewName.SpiritWuxingdanBuyView)
end

function SonSpiritView:OnClickToggle(index)
	self:FlushBuyButton()
	if index == 1 then
		self.node_list["BtnBuy"]:SetActive(false)
	end
end

-- 物品不足，购买成功后刷新物品数量
function SonSpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushBagView()
end

function SonSpiritView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function SonSpiritView:BagRefreshCell(cell, data_index)
	local group = self.spirit_cells[cell]
	if group == nil then
		group = SpiritBagGroup.New(cell.gameObject)
		self.spirit_cells[cell] = group
	end
	group:SetToggleGroup(self.node_list["PackListView"].toggle_group)
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = nil
		data = SpiritData.Instance:GetBagBestSpirit()[index + 1]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ShowHighLight(i, not data.locked)
		group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
		group:SetInteractable(i, nil ~= data.item_id)
	end
end

function SonSpiritView:FlushBagView()
	if self.node_list["PackListView"].scroller.isActiveAndEnabled then
		SpiritData.Instance:GetBagBestSpirit()
		self.cur_bag_index = -1
		self.node_list["PackListView"].scroller:RefreshActiveCellViews()
	end
end

-- 点击格子事件
function SonSpiritView:HandleBagOnClick(data, group, group_index, data_index)
	local page = math.ceil((data.index + 1) / BAG_COLUMN)
	if data.locked then
		return
	end
	self.cur_bag_index = data_index
	group:SetHighLight(group_index, self.cur_bag_index == data.index)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	local close_callback = function()
		group:SetHighLight(group_index, false)
		self.cur_bag_index = -1
	end
	if nil ~= item_cfg1 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SPIRIT_BAG, nil, close_callback)
	end
end

-- 点击仙宠改名
function SonSpiritView:OnClickReName()
	local cost_num = SpiritData.Instance:GetSpiritOtherCfg().rename_cost
	local des = Language.Common.IsXiaoHao
	local des_2 = string.format(Language.Common.ReSpiritName, cost_num)
	local callback = function(name)
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_RENAME,
		0, 0, 0, 0, name)
	end
	TipsCtrl.Instance:ShowRename(callback, false, nil, des, des_2)
end

function SonSpiritView:OnClickHelp()
	local tip_id = 40
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 一键装备
function SonSpiritView:OnClickOneKeyEquip()
	SpiritCtrl.Instance:AutoEquipOrChange()
end

function SonSpiritView:OnClickTakeOff(index)
	self.upgrade_jump_show = false
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list
	spirit_list = spirit_list or {}
	if spirit_list[index - 1] == nil then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(spirit_list[index - 1].item_id)
	if not item_cfg then return end
	self.res_id = 0

	if spirit_info.use_jingling_id == spirit_list[index-1].item_id then
		self:FightOutNext(index - 1)
	end

	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF, index - 1, 0, 0, 0, item_cfg.name)
end


function SonSpiritView:SetBackPackState(enable)
	-- self.node_list["BackpackButton"]:SetActive(not enable)
	-- self.node_list["BtnAttribute"]:SetActive(enable)
	-- self.node_list["RightBagPanel"]:SetActive(enable)
	self.node_list["AttrView"]:SetActive(not enable)
	self.node_list["AptitudeView"]:SetActive(not enable)

end

function SonSpiritView:OnClickBlock(index, cell)
	cell:SetHighLight(false)
end

function SonSpiritView:OnClickItem(index, cell)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list
	local data = spirit_list[index - 1]
	self.cur_click_index = index
	SpiritData.Instance:SetSelectSpiritIndex(self.cur_click_index)
	
	local is_show_arrow = SpiritData.Instance:IsCanReplaceSpirit(index - 1)
	if nil == data then 
		if not is_show_arrow then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.JingLingError)
		else
			SpiritCtrl.Instance:ShowSpiritBagView()	
		end
		return 
	else
		-- 有空格子的时候不让点击
		for i = 1, 4 do
			if spirit_list[i - 1] == nil then
				is_show_arrow = false
			end
		end
	end

	if is_show_arrow then
		SpiritCtrl.Instance:ShowSpiritBagView()	
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
	local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["NameNode"]:SetActive(item_cfg ~= nil)
	local is_not_max_level = SpiritData.Instance:GetStrenthMaxLevelByid(self.cur_click_index - 1)

	if nil ~= item_cfg and spirit_level_cfg ~= nil then
		self.cur_data = data
		local name_str = ""
		if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
			name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. spirit_info.jingling_name .. "</color>"
		else
			name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		end
		self.node_list["piritNameTxt"].text.text = name_str
		for i = 1, 4 do
			local is_show = self.cur_click_index and self.cur_click_index == i or false
			self.node_list["HL" .. i]:SetActive(is_show)
		end
		self.node_list["SpiritLevelTxt"].text.text = string.format("Lv.%s·", spirit_list[index - 1].param.strengthen_level)
		local cost = spirit_level_cfg.cost_lingjing
		local count = vo.lingjing
		local progress_pre = cost > count and count or cost

		if is_not_max_level then
			self.node_list["ProgressSlider"].slider.value = data.param.param3 / cost
		else
			self.node_list["ProgressSlider"].slider.value = 1
		end

		cost = CommonDataManager.ConverMoney(cost)
		self.node_list["NeedProTxt"].text.text = string.format("%s<color='#ffff00'>+%s</color>/%s", data.param.param3, progress_pre, cost)
		count = CommonDataManager.ConverMoney(count)
		self.attr_view:SetSpiritAttr(data)
		self:FlushModel(self.cur_data.item_id)
	end

	local is_show_chuzhan_btn = spirit_info.use_jingling_id ~= self.cur_data.item_id
	self.node_list["BtnChuZhan"]:SetActive(is_show_chuzhan_btn)
	self.node_list["FightingCapacity"]:SetActive(not is_show_chuzhan_btn)
	cell:SetHighLight(false)
	self.node_list["MaxTxt"]:SetActive(not is_not_max_level)
	self.node_list["NeedProTxt"]:SetActive(is_not_max_level)
	UI:SetButtonEnabled(self.node_list["BtnNorml"], is_not_max_level)
	self.node_list["BtnNormlText"].text.text = is_not_max_level and Language.Common.UpGrade or Language.Common.YiManJi
	self.node_list["UseImg1"]:SetActive(spirit_list[self.cur_click_index - 1] ~= nil)
	self.node_list["HaveProTxt"]:SetActive(spirit_list[self.cur_click_index - 1] ~= nil)
	self.is_click_item = true
	self.is_click_bag = false
	self.aptitude_view:FlushData(self.cur_click_index and spirit_list[self.cur_click_index - 1] or {})
	self:SetWuXingRemind()
	self:FlushTotlePower()

	-- 刷新成长、悟性、属性按钮的红点提示
	local is_remind_cz = SpiritData.Instance:CanUpgradeByID(self.cur_click_index - 1)
	local is_remind_wx = SpiritData.Instance:CanUpgradeWuxingByIndex(self.cur_click_index - 1)
	self.node_list["RedPointChengZhang"]:SetActive(is_remind_cz)
	self.node_list["RemindBtnAttr"]:SetActive(is_remind_cz or is_remind_wx)

	self:FlushBuyButton()
end

function SonSpiritView:OnClickBackPack()
	self.is_click_item = false
	self.on_attr_view = false

	self.upgrade_jump_show = false
	self.node_list["AttrView"]:SetActive(false)
	self.node_list["AptitudeView"]:SetActive(false)
	-- self.node_list["RightBagPanel"]:SetActive(true)
	-- UITween.MoveShowPanel(self.node_list["RightBagPanel"], Vector3(1000, 2.1, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Background"], Vector3(1000, 2.1, 0), 0.7)

	if not self.is_click_bag then
		self:FlushBagView()
		self:Flush()
	end

	self.is_click_bag = false
	-- self.node_list["BackpackButton"]:SetActive(false)
	self:SwitchToggleLable(false)
	-- self.node_list["BtnAttribute"]:SetActive(true)
end

function SonSpiritView:OnClickHuanHua()
	self.is_click_item = false

	self.upgrade_jump_show = false
	ViewManager.Instance:Open(ViewName.SpiritHuanHuaView)
end

-- 出战
function SonSpiritView:OnClickZhaoHui()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if self.cur_click_index == nil or self.cur_data == nil or spirit_info == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
	if spirit_info.use_jingling_id == self.cur_data.item_id then
		if spirit_info.count ~= 1 then
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CALLBACK,
			self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
			self:FightOutNext(self.cur_click_index - 1)
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.MustFightOut)
		end
	else
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
		self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
	end
	self.node_list["BtnChuZhan"]:SetActive(false)
	self.node_list["FightingCapacity"]:SetActive(true)
end

function SonSpiritView:FightOutNext(cur_index)
	for i = 0, 3 do
		if self.temp_spirit_list[i] and i ~= cur_index then
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
			i, 0, 0, 0, self.temp_spirit_list[i].name)
			return
		end
	end

end

function SonSpiritView:OnClickUpgrade()
	self.upgrade_jump_show = true
	if SpiritData.Instance:HasNotSprite() then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.PleaseEquipJingLing)
		return
	end
	if self.cur_data then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
		local  vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.lingjing <= 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.LingJIngLack)
		end
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL, self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
	end
end

function SonSpiritView:OnFlush(param_list)
	self.cur_data = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}

	-- 底下四个仙宠格子的刷新
	self:FlushCell(spirit_list, vo)
	
	local select_spirit_index = self.cur_click_index - 1
	local select_spirit = spirit_list[select_spirit_index]

	for i = 1, 4 do
		local is_show = select_spirit and self.cur_click_index == i or false
		if select_spirit == nil and spirit_list[i - 1] then
			is_show = spirit_list[i - 1].item_id == spirit_info.use_jingling_id
		end
		self.node_list["HL" .. i]:SetActive(is_show)
		if is_show then
			self.cur_click_index = i
			select_spirit = spirit_list[i - 1]
		end
	end

	if select_spirit then
		self:FlushRightPanel(select_spirit, spirit_info, vo)
		self.cur_data = select_spirit
	end
	-- 仙宠出战图标
	for k, v in pairs(self.show_fight_out_list) do
		v:SetActive(spirit_list[k - 1] and spirit_list[k - 1].item_id == spirit_info.use_jingling_id or false)
	end

	local is_xianchong_state = SpiritData.Instance:GetStrenthMaxLevelByid(select_spirit_index)
	self.node_list["NameNode"]:SetActive(self.cur_click_index and select_spirit ~= nil or false)
	self.node_list["NeedProTxt"]:SetActive(is_xianchong_state)
	self.node_list["MaxTxt"]:SetActive(not is_xianchong_state)
	UI:SetButtonEnabled(self.node_list["BtnNorml"], is_xianchong_state)
	self.node_list["BtnNormlText"].text.text = is_xianchong_state and Language.Common.UpGrade or Language.Common.YiManJi
	self.node_list["UseImg1"]:SetActive(self.cur_click_index and select_spirit ~= nil or false)
	self.node_list["HaveProTxt"]:SetActive(self.cur_click_index and select_spirit ~= nil or false)

	self.attr_view:SetSpiritAttr(self.cur_click_index and select_spirit or {})
	self.aptitude_view:FlushData(self.cur_click_index and select_spirit or {})
	
	-- 刷新模型、出战按钮、战斗力值显示
	if self.cur_data ~= nil then
		local is_show_chuzhan_btn = spirit_info.use_jingling_id ~= self.cur_data.item_id
		self.node_list["BtnChuZhan"]:SetActive(is_show_chuzhan_btn)
		self.node_list["FightingCapacity"]:SetActive(not is_show_chuzhan_btn)
		self:FlushModel(self.cur_data.item_id)
	else
		self.node_list["NeedProTxt"].text.text = string.format("%s<color='#ffff00'>+%s</color>/%s", 0, 0, 0)
		self.node_list["BtnChuZhan"]:SetActive(false)
		self.node_list["FightingCapacity"]:SetActive(true)
		local state = SpiritCtrl.Instance:GetHuanHuaState()
		if not state then
			UIScene:DeleteModel()
		end
		self.node_list["AttrView"]:SetActive(true)
		self.node_list["AptitudeView"]:SetActive(false)
		self.node_list["ToggleGrop"]:SetActive(true)
		self.node_list["BtnBuy"]:SetActive(false)
		self.node_list["ToggleChengZhang"].toggle.isOn = true
		self.node_list["ToggleWuXing"].toggle.isOn = false
	end

	-- 自动出战
	if not next(self.temp_spirit_list) and not self.is_first then
		for k, v in pairs(spirit_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
			k, 0, 0, 0, item_cfg.name)
			break
		end
	end

	local is_flush_bag = false
	for k, v in pairs(self.temp_spirit_list) do
		if not spirit_list[k] then
			is_flush_bag = true
			break
		elseif spirit_list[k].item_id ~= v.item_id then
			is_flush_bag = true
			break
		end
	end
	self.temp_spirit_list = spirit_list

	if self.is_first or is_flush_bag then
		self:FlushBagView()
	end
	self.is_first = false
	local list_num = GetListNum(spirit_list) or 0
	-- 仙宠格子提示
	for i = 1, 4 do
		local level_can_show = SpiritData.Instance:CanUpgradeByID(i - 1) and not SpiritData.Instance:IsMaxLevel(i - 1)
		local wuxing_can_show = SpiritData.Instance:CanUpgradeWuxingByIndex(i - 1) and not SpiritData.Instance:IsMaxWuXing(i -1)
		local is_show_arrow = false
		if spirit_list[i - 1] == nil or list_num == 4 then
			is_show_arrow = SpiritData.Instance:IsCanReplaceSpirit(i - 1)
		end
		self.show_improve[i]:SetActive(is_show_arrow)
		local is_show_remind = (level_can_show or wuxing_can_show) and (not is_show_arrow)
		self.show_remind_list[i]:SetActive(is_show_remind)
	end

	self:FlushTotlePower()
	
	-- 刷新成长、悟性、属性按钮的红点提示
	self:SetWuXingRemind()
	local is_remind_cz = SpiritData.Instance:CanUpgradeByID(select_spirit_index)
	local is_remind_wx = SpiritData.Instance:CanUpgradeWuxingByIndex(select_spirit_index)
	self.node_list["RedPointChengZhang"]:SetActive(is_remind_cz)
	self.node_list["RemindBtnAttr"]:SetActive(is_remind_cz or is_remind_wx)

	local cfg = SpiritData.Instance:GetSpiritResourceCfg()
	if SpiritData.Instance:GetSpiritListLength() == 1 then
		for k,v in pairs(spirit_list) do
			if v.item_id then
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
				v.index, 0, 0, 0, SpiritData.Instance:GetSpiritNameById(v.item_id))
				break
			end
		end
	end
	self.node_list["UseImg2"]:SetActive(nil ~= SpiritData.Instance:CanHuanhuaUpgrade())

	self:FlshGoalContent()

	local open_bag_view = SpiritData.Instance:GetSpiritBagRemind()
	if self.is_first_open and self.cur_click_index > 0 and open_bag_view == 0 then
		self.is_first_open = false
		-- self:OnClickReturn()
	end
	self:FlushBuyButton()
end

function SonSpiritView:FlushBuyButton()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if spirit_info and spirit_info.jingling_list then
		local spirit_list = spirit_info.jingling_list or {}
		if spirit_list[self.cur_click_index - 1] then
			local info = spirit_list[self.cur_click_index - 1]
			local color = ItemData.Instance:GetItemQuailty(info.item_id)
			self.node_list["BtnBuy"]:SetActive(color > 3 and self.node_list["ToggleWuXing"].toggle.isOn)
		end
	end
end

function SonSpiritView:FlushTotlePower()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local power = 0
	for k, v in pairs(spirit_list) do
		local aptitude_data = SpiritData.Instance:GetSpiritTalentAttrCfgById(v.item_id)
		if v.param then
			local wuxing = v.param.param1 or 0
			local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(v.item_id, v.param.strengthen_level,aptitude_data,wuxing)
			power = power + CommonDataManager.GetCapability(CommonDataManager.GetAttributteNoUnderline(total_attr_list, true))
		else
			local total_attr_list = SpiritData.Instance:GetSpiritLevelAptitude(v.item_id, 1,aptitude_data,0)
			power = power + CommonDataManager.GetCapability(CommonDataManager.GetAttributteNoUnderline(total_attr_list, true))
		end
	end

	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = math.ceil(power)
	end
end

-- OnFlush拆分----
function SonSpiritView:ClearCell(cell)
	cell:SetData({})
	cell:SetInteractable(false)
	cell:SetHighLight(false)
end

function SonSpiritView:PlayUpgradeEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		AudioService.Instance:PlayAdvancedAudio()
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectRoot"].transform,
		1.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

-- 刷新底下四个仙宠格子 
function SonSpiritView:FlushCell(spirit_list, vo)
	--self.cur_click_index = 0
	for k, v in pairs(self.items) do
		-- print_warning("<color=#07F862FF>格子" .. k .. "</color>")
		local cell = v.cell
		local cell_data = cell:GetData()
		local spirit = spirit_list[k - 1]
		local cur_cheng_zhang_state = self.aptitude_view:GetUpgradeJumpShow()
		if vo.used_sprite_id == cell_data.item_id and not self.upgrade_jump_show  and not cur_cheng_zhang_state and not self.first_time then --and not self.on_attr_view then
			self.first_time = true
			self.cur_click_index = k
		end
		local is_select_cell = self.cur_click_index == k
		if cell_data.item_id then
			if spirit == nil then
				self.res_id = 0
				self:ClearCell(cell)
			else
				local spirit_param = spirit.param
				local cell_data_param = cell_data.param
				local is_play_upgrade_effect = cell_data_param.strengthen_level < spirit_param.strengthen_level
											   or cell_data_param.param1 < spirit_param.param1
				if is_play_upgrade_effect then
					self:PlayUpgradeEffect()
				end

				cell:IsDestroyEffect(false)
				cell:SetData(spirit)
				cell:SetHighLight(false)
			end
		elseif spirit then
			local spirit_param = spirit.param
			cell:SetData(spirit)
			self.cur_click_index = k
			cell:SetHighLight(false)
		else
			self:ClearCell(cell)
		end
		self.takeoff_image_list[k]:SetActive(nil ~= spirit)
	end
end

function SonSpiritView:FlushRightPanel(select_spirit, spirit_info, vo)
	local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(select_spirit.index)
	if spirit_level_cfg == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(select_spirit.item_id)
	local name = ""
	local is_not_max_level = SpiritData.Instance:GetStrenthMaxLevelByid(self.cur_click_index - 1)
	-- 是否有玩家自定义名字
	local is_use_player_name = spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= ""
	
	if is_use_player_name then
		name = spirit_info.jingling_name
	else
		name = item_cfg.name
	end

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">" .. name .. "</color>"
	self.node_list["piritNameTxt"].text.text = name_str
	self.node_list["SpiritLevelTxt"].text.text = string.format("Lv.%s·", select_spirit.param.strengthen_level)
	self.node_list["ChengZhangTxt"].text.text = string.format("%s Lv.%s", Language.JingLing.TabbarName[7], select_spirit.param.strengthen_level)

	local cost = spirit_level_cfg.cost_lingjing
	local count = vo.lingjing
	local progress_pre = cost > count and count or cost

	if is_not_max_level then
		self.node_list["ProgressSlider"].slider.value = select_spirit.param.param3 / cost
	else
		self.node_list["ProgressSlider"].slider.value = 1
	end

	cost = CommonDataManager.ConverNum(cost)
	self.node_list["NeedProTxt"].text.text = string.format("%s<color=#ffff00>+%s</color>/%s",select_spirit.param.param3, progress_pre, cost)

	count = CommonDataManager.ConverNum(count)
	self.node_list["HaveProTxt"].text.text = ToColorStr(count,TEXT_COLOR.BLUE_1)
end

function SonSpiritView:FlushModel(cur_data_id)
	local state = SpiritCtrl.Instance:GetHuanHuaState()
	if state then
		return
	end
	local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(cur_data_id)
	if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
		if spirit_cfg.res_id ~= self.res_id then
			local call_back = function(model, obj)
				if obj then
					model:SetTrigger(ANIMATOR_PARAM.REST)
					obj.gameObject.transform.localRotation = Quaternion.Euler(0, -15, 0)
				end
			end
			UIScene:SetModelLoadCallBack(call_back)

			PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			UIScene:LoadSceneEffect(bundle, asset)
			local load_list = {{bundle, asset}}
			self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)
			self.res_id = spirit_cfg.res_id
		end
	end
end

-- OnFlush拆分End----

-- 属性按钮、背包下的返回按钮
function SonSpiritView:OnClickReturn()	
	if SpiritData.Instance:HasNotSprite() then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.PleaseEquipJingLing)
		return
	end
	self:Flush()
	-- self.node_list["BtnAttribute"]:SetActive(false)
	-- self.node_list["BackpackButton"]:SetActive(true)
	-- self.node_list["RightBagPanel"]:SetActive(false)
	self.on_attr_view = true
	self:SwitchToggleLable(true)
	UITween.MoveShowPanel(self.node_list["RightAttrPanel"], Vector3(1000, 2.1, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Background"], Vector3(1000, 2.1, 0), 0.7)
end

-- 设置仙宠成长和悟性的切换标签
function SonSpiritView:SwitchToggleLable(is_on_attr_view)
	self.node_list["ToggleGrop"]:SetActive(is_on_attr_view)
	-- self.node_list["BtnBuy"]:SetActive(is_on_attr_view)
	-- 当背包按钮显示和toggle选中悟性时，需要重置toggle
	if is_on_attr_view and self.node_list["ToggleWuXing"].toggle.isOn then
		self.node_list["ToggleChengZhang"].toggle.isOn = true
		self.node_list["ToggleWuXing"].toggle.isOn = false
	end
	self:FlushBuyButton() 
	-- if self.node_list["ToggleChengZhang"].toggle.isOn then
	-- 	self.node_list["BtnBuy"]:SetActive(false)
	-- end
end

-- 设置仙宠仙宠悟性红点显示，根据选中的仙宠显示红点
function SonSpiritView:SetWuXingRemind()
	local is_remind_wuxing = SpiritData.Instance:CanUpgradeWuxingByIndex(self.cur_click_index - 1) and not SpiritData.Instance:IsMaxLevel(self.cur_click_index - 1)
	self.node_list["RedPointWuXing"]:SetActive(is_remind_wuxing)
end

function SonSpiritView:UITween()
	-- UITween.MoveShowPanel(self.node_list["RightBagPanel"], Vector3(1000, 2.1, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Background"], Vector3(1000, 2.1, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BottomPanel"], Vector3(-422, -6, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["Buttons"], Vector3(-53, -236, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["HuanHuaBtn"], Vector3(-51.15, 70, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["HelpBtn"], Vector3(69, 380, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["RightAttrPanel"], Vector3(1000, 2.1, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["NameNode"], true, 0.5, DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, 0.5 , DG.Tweening.Ease.InExpo)

	
end

-----------------------------------------------------------------------------------------------------
-- 仙宠成长属性
SpiritAttrView = SpiritAttrView or BaseClass(BaseRender)

function SpiritAttrView:__init(instance)
	self.base_attr_list = {}
	for i = 1, 7 do
		self.base_attr_list[i] = {
			value = self.node_list["AttrTxt" .. i],
			is_show = self.node_list["GongjiNode" .. i], 
			next_value = self.node_list["NextAttrTxt" .. i],
			show_image = self.node_list["GongjiImg" .. i],
			show_next_value = self.node_list["NextAttrNode" .. i],
		}
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["NumTxt"])
	self.node_list["BtnLingJing"].button:AddClickListener(BindTool.Bind(self.ClickLingJing, self))
end

function SpiritAttrView:__delete()
	self.fight_text = nil
end

-- 点击灵晶提示框
function SpiritAttrView:ClickLingJing()
	local data = {item_id = ResPath.CurrencyToIconId["lingjing"]}
	TipsCtrl.Instance:OpenItem(data)
end

local sort_t = {
	gongji = 1,
	fangyu = 2,
	maxhp = 3,
}

function SpiritAttrView:SetSpiritAttr(data)
	if data == nil or data.param == nil then 
		self.node_list["ChengZhangTxt"].text.text = string.format("%s Lv.%s", Language.JingLing.TabbarName[7], 0)
		for i = 1, 3 do
			self.node_list["AttrTxt" .. i].text.text = Language.JingLing.JingLingAttrName[i] .. 0
			self.node_list["NextAttrTxt" .. i].text.text = 0
		end
		self.fight_text.text.text = 0
		return 
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
	local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
	local talent_attr = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
	local had_base_attr = {}
	local wuxing = data.param.param1
	if item_cfg and spirit_level_cfg then
		local spirit_next_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index, spirit_info.jingling_list[data.index].param.strengthen_level + 1)
		local next_attr = CommonDataManager.GetAttributteNoUnderline(spirit_next_level_cfg, true)
		for k, v in pairs(attr) do
			if v > 0 then
				if next_attr[k] and next_attr[k] > 0 then
					table.insert(had_base_attr, {key = k, value = v, next_value = next_attr[k]})
				else
					table.insert(had_base_attr, {key = k, value = v, next_value = 0})
				end
			end
		end
		table.sort(had_base_attr, function (a, b)
			local a_value = sort_t[a.key] or 100
			local b_value = sort_t[b.key] or 100
			return a_value < b_value
		end)
		local aptitude = {}
		for i = 1, 3 do
			table.insert(aptitude,talent_attr[APTITUDE_TYPE[i]])
		end
		local attr_after_aptitude = {}
		if next(had_base_attr) then
			for k, v in pairs(self.base_attr_list) do
				v.is_show:SetActive(had_base_attr[k] ~= nil)
				if had_base_attr[k] ~= nil then
					v.value.text.text = Language.Common.AttrNameUnderline[had_base_attr[k].key] .. "：".. string.format("<color=#FFFFFFFF>%s</color>", had_base_attr[k].value)
					if spirit_info.jingling_list[data.index].param.strengthen_level + 1 <= SpiritData.Instance:GetMaxSpiritUplevel(data.item_id) then
						v.show_image:SetActive(true)
						v.show_next_value:SetActive(true)
						local attr_add = had_base_attr[k].next_value - had_base_attr[k].value
						v.next_value.text.text = attr_add
					else
						v.show_image:SetActive(false)
						v.show_next_value:SetActive(false)
					end
					attr_after_aptitude[ATTR_TYPE[k]] = had_base_attr[k].value
				end
			end
		end
		local fight_power = CommonDataManager.GetCapabilityCalculation(attr_after_aptitude)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = fight_power
		end

		local name_str = ""
		if spirit_info.use_jingling_id == item_cfg.id then
			if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
				name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. spirit_info.jingling_name .. "</color>"
			else
				name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
			end
		else
			name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		end
		self.node_list["piritNameTxt"].text.text = name_str

		self.node_list["SpiritLevelTxt"].text.text = string.format("Lv.%s·", data.param.strengthen_level)
		self.node_list["ChengZhangTxt"].text.text = string.format("%s Lv.%s", Language.JingLing.TabbarName[7], data.param.strengthen_level)
		local max_skill = SpiritData.Instance:GetMaxSkillNumByID(data.item_id) ==  spirit_level_cfg.skill_num
		self.node_list["OtherAttrImg"]:SetActive(not max_skill)
		self.node_list["OtherNextAttrNode"]:SetActive(not max_skill)

		local cur_level = "<color=" .. TEXT_COLOR.RED .. ">" .. data.param.strengthen_level .. "</color>"
		local next_level = SpiritData.Instance:GetSkillNumNextLevelById(data.item_id, spirit_level_cfg.skill_num)
		self.node_list["CurAttrTxt"].text.text = string.format(Language.JingLing.JiNengCao, spirit_level_cfg.skill_num)
		self.node_list["OtherNextAttr"].text.text = string.format(Language.Common.jIShu, 1, cur_level, next_level)

	end
end

-- 区分出战与不出战仙宠战力
function SpiritAttrView:GetNewFightPower()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local chuzhan_spirit_item_id = spirit_info.use_jingling_id
	
	local fight_power = 0
	for k,v in pairs(spirit_list) do
		if v.item_id == chuzhan_spirit_item_id then
			local spirit_level_cfg = SpiritNewSysData.Instance:GetLevelCfg()[v.index]
			if spirit_level_cfg then
				fight_power = fight_power + CommonDataManager.GetCapabilityCalculation(spirit_level_cfg)
			end
		else
			local no_fight_spirit_level_cfg = SpiritNewSysData.Instance:GetUnFightLevelCfg()[v.index]
			if no_fight_spirit_level_cfg then
				fight_power = fight_power + CommonDataManager.GetCapabilityCalculation(no_fight_spirit_level_cfg)
			end
		end
	end
	return fight_power
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- 背包格子
SpiritBagGroup = SpiritBagGroup or BaseClass(BaseRender)

function SpiritBagGroup:__init(instance)
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item"..i])
	end
end

function SpiritBagGroup:GetGuideCell()
	if self.cells[1] then
		return self.cells[1].root_node
	end
end

function SpiritBagGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpiritBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function SpiritBagGroup:SetHighLight(i, enable)
	local is_hight = enable or false
	if self.cells[i] then
		self.cells[i]:SetHighLight(is_hight)
	end
end

function SpiritBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end