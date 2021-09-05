RuneInlayView = RuneInlayView or BaseClass(BaseRender)

local EFFECT_CD = 1
local MOVE_TIME = 0.5

function RuneInlayView:UIsMove()
	UITween.MoveShowPanel(self.node_list["BtnPanel"] , Vector3(-667 , 480 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right_panel"] , Vector3(250 , -28 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnAwaken"] , Vector3(-100 , 80 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Left_panel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["Left_panel"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME )
end

function RuneInlayView:__init()
	self.slot_list = {}
	self.goal_data = {}
	for i = 1, 9 do
		local slot_cell = RuneEquipCell.New(self.node_list["Slot_" .. i])
		slot_cell:SetIndex(i)
		slot_cell:SetClickCallBack(BindTool.Bind(self.SlotClick, self, i))
		table.insert(self.slot_list, slot_cell)
	end
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNumTxt"])

	self.node_list["BtnOverView"].button:AddClickListener(BindTool.Bind(self.OpenOverView, self))
	self.node_list["BtnReplace"].button:AddClickListener(BindTool.Bind(self.ClickRelpace, self))
	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.ClickUpGrade, self))
	self.node_list["GotToGet"].button:AddClickListener(BindTool.Bind(self.ClickGet, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))
	--觉醒
	self.node_list["BtnAwaken"].button:AddClickListener(BindTool.Bind(self.ClickAwaken, self))
	--监听红点变化
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.red_point_list = {
		[RemindName.RuneAwake] = self.node_list["BtnAwakenImg"],
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	RemindManager.Instance:Fire(RemindName.RuneAwake)
end

function RuneInlayView:LoadCallBack(instance)
	-- 一折抢购跳转
	local is_open, index, data = DisCountData.Instance:IsOpenYiZheBySystemId(Sysetem_Id_Jump.Zhan_Hun)
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
function RuneInlayView:StartCountDown(data, node_list)
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
function RuneInlayView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function RuneInlayView:__delete()
	for k, v in ipairs(self.slot_list) do
		v:DeleteMe()
	end
	self.slot_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.fight_text = nil
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])

	self:StopCountDown()
end

-- 用于功能引导
function RuneInlayView:GetGuideSlot(index)
	if self.slot_list[index] then
		local slot_list = RuneData.Instance:GetSlotList()
		return self.slot_list[index].root_node, BindTool.Bind(self.SlotClick, self, index, self.slot_list[index], slot_list[index])
	end
end

function RuneInlayView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

function RuneInlayView:FlshGoalContent()
	self.goal_info = RuneData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
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
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = RuneData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
				if goal_cfg_info then
					local attr_percent = RuneData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE)
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

function RuneInlayView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE, is_other_item)
end

function RuneInlayView:InitView()
	GlobalTimerQuest:AddDelayTimer(function()
		self.select_index = 0
		self.old_level = 0
		self.effect_cd = 0
		self.up_select_index = -1
		self:FlushView()
	end, 0)
end

function RuneInlayView:FlushView()
	local slot_list = RuneData.Instance:GetSlotList()
	for k, v in ipairs(self.slot_list) do
		local slot_data = slot_list[k]
		if self.select_index == 0 then
			if slot_data and slot_data.type >= 0 then
				--自动选择有装备的一个格子（顺序选择）
				self.select_index = k
				v:SetHighLight(true)
			end
		end
		v:SetData(slot_data)
		v:SetCurrentSelect(self.select_index)
	end
	RuneData.Instance:SetCurrentSelect(self.select_index)
	self:FlushRightView()
	local pass_layer = RuneData.Instance:GetPassLayer()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	local need_pass_layer = other_cfg.rune_awake_need_layer
	UI:SetGraphicGrey(self.node_list["BtnAwaken"], pass_layer < need_pass_layer)
end

function RuneInlayView:FlushAwakenAttr()
	local current_awaken_attr = RuneData.Instance:GetAwakenAttrInfoByIndex(self.select_index)
	if nil ~= current_awaken_attr then
		self.node_list["GongJiText"].text.text = string.format(Language.Rune.GongJi, current_awaken_attr.gongji)
		self.node_list["AmpText"].text.text = string.format(Language.Rune.ZhengFu,  (current_awaken_attr.add_per * 0.01).."%")
		self.node_list["FangYuText"].text.text = string.format(Language.Rune.FangYu, current_awaken_attr.fangyu)
		self.node_list["ShengMingText"].text.text = string.format(Language.Rune.ShengMing, current_awaken_attr.maxhp)
	end
end

function RuneInlayView:OnClinkOpenZongLan()
	RuneCtrl.Instance:OpenFuWenZongLan()
end

--打开符文总览界面
function RuneInlayView:OpenOverView()
	ViewManager.Instance:Open(ViewName.RunePreview)
end

--点击替换
function RuneInlayView:ClickRelpace()
	RuneCtrl.Instance:SetSlotIndex(self.select_index)
	ViewManager.Instance:Open(ViewName.RuneBag)
end

--点击升级
function RuneInlayView:ClickUpGrade()
	self.up_select_index = self.select_index
	local data = RuneData.Instance:GetSlotDataByIndex(self.select_index)
	self.old_level = data.level or 0
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_UPLEVEL, self.select_index - 1)
end

function RuneInlayView:ClickGet()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_treasure)
end

function RuneInlayView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(162)
end

--打开觉醒面板
function RuneInlayView:ClickAwaken()
	--如果当前未镶嵌符文
	local pass_layer = RuneData.Instance:GetPassLayer()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	local need_pass_layer = other_cfg.rune_compose_need_layer
	if pass_layer < need_pass_layer then
		local txt = string.format(Language.Rune.AwakenTips)
		SysMsgCtrl.Instance:ErrorRemind(txt)
		return
	end
	local solt_list = RuneData.Instance:GetSlotList()
	if nil == solt_list[self.select_index] or 0 == solt_list[self.select_index].level then
		local des = string.format(Language.Rune.NoRuneTips)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end
	if self.select_index == RuneData.SoltCenter then
		local tex = string.format(Language.Rune.NoRuneJueXing)
		SysMsgCtrl.Instance:ErrorRemind(tex)
		return
	end
	RuneData.Instance:SetCellIndex(self.select_index)
	ViewManager.Instance:Open(ViewName.RuneAwakenView)
end

function RuneInlayView:SlotClick(index, cell, data)
	if cell:IsLock() then
		local layer = RuneData.Instance:GetSlotOpenLayerByIndex(index)
		local des = string.format(Language.Rune.OpenSlotDes, layer)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end

	if data.quality < 0 then
		--没有物品时打开背包
		if index == 1 then
			local list_data = RuneData.Instance:GetBagList()
			local select_length = 0
			for k, v in pairs(list_data) do
				if v.type == GameEnum.RUNE_WUSHIYIJI_TYPE then
					select_length = select_length + 1
				end
			end
			if select_length == 0 then
				local str = Language.Rune.GetWuShiYiJi
				if nil ~= str then
					SysMsgCtrl.Instance:ErrorRemind(str)
				end
				return
			end
		end
		RuneCtrl.Instance:SetSlotIndex(index)
		ViewManager.Instance:Open(ViewName.RuneBag)
		return
	end
	self.old_level = 0
	self.effect_cd = 0
	cell.root_node.toggle.isOn = true
	if self.select_index == index then
		return
	end
	self.select_index = index
	self:FlushRightView()
end

function RuneInlayView:SetLevelDes(data)
	local type_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local type_name = Language.Rune.AttrTypeName[data.type] or ""
	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)

	self.node_list["AttrTypeDes"].text.text = type_des
end

function RuneInlayView:SetAttrDes(data)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type_0] or ""
	local attr_value_0 = data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(data.attr_type_0) then
		attr_value_0 = (data.add_attributes_0/100.00) .. "%"
	end
	local attr_des_1 = string.format(Language.Rune.AttrDes, attr_type_name_0, attr_value_0)
	self.node_list["AttrDes1Txt"].text.text = attr_des_1
	
	local show_two_attr = data.attr_type_1 > 0
	self.node_list["AttrDes2"]:SetActive(show_two_attr)
	self.node_list["UpContent2"]:SetActive(show_two_attr)

	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type_1] or ""
		local attr_value_1 = data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(data.attr_type_1) then
			attr_value_1 = (data.add_attributes_1/100.00) .. "%"
		end
		local attr_des_2 = string.format(Language.Rune.AttrDes, attr_type_name_1, attr_value_1)
		self.node_list["AttrDes2"].text.text = attr_des_2
	end

	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.Rune.AttrType[data.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[data.attr_type_1]

	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, data.add_attributes_0)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, data.add_attributes_1)
	end
	local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	local attr_data = RuneData.Instance:GetAttrInfo(data.quality, data.type, data.level)
	if attr_data and self.fight_text and self.fight_text.text then
		local num = attr_data.other_capability and attr_data.other_capability or 0
		self.fight_text.text.text = capability + num
	end
end

function RuneInlayView:SetLevelUpDes(data)
	local next_data = RuneData.Instance:GetAttrInfo(data.quality, data.type, data.level + 1)
	local attr_type_name_0 = Language.Rune.AttrName[data.attr_type_0] or ""
	local attr_value_0 = data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(data.attr_type_0) then
		now_attr_value_0 = (attr_value_0 / 100.00) .. "%"
	else
		now_attr_value_0 = attr_value_0
	end
	self.node_list["AttrName"].text.text = string.format("%s：", attr_type_name_0)

	self.node_list["NowAttr1"].text.text =  string.format("+%s", now_attr_value_0)

	if next(next_data) then
		local txt1 = next_data.add_attributes_0 - attr_value_0
		if RuneData.Instance:IsPercentAttr(next_data.attr_type_0) then
			next_attr_value_0 = (txt1 / 100.00) .. "%"
		else
			next_attr_value_0 = txt1
		end
		self.node_list["NextAttr1"].text.text = next_attr_value_0
	end

	local show_two_attr = data.attr_type_1 > 0
	if show_two_attr then
		local attr_type_name_1 = Language.Rune.AttrName[data.attr_type_1] or ""
		local attr_value_1 = data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(data.attr_type_1) then
			now_attr_value_1 = (attr_value_1 / 100.00) .. "%"
		else
			now_attr_value_1 = attr_value_1 
		end
		self.node_list["AttrName2"].text.text = string.format("%s：", attr_type_name_1)
		self.node_list["NowAttr2"].text.text = string.format("+%s", now_attr_value_1)

		if next(next_data) then
			local txt2 = next_data.add_attributes_1 - attr_value_1
			if RuneData.Instance:IsPercentAttr(next_data.attr_type_1) then
				next_attr_value_1 = (txt2 / 100.00) .. "%"
			else
				next_attr_value_1 = txt2
			end
			self.node_list["NextAttr2"].text.text = txt2
		end
	end
end

function RuneInlayView:FlushRightView()
	local select_index = self.select_index
	local cell = self.slot_list[select_index]
	if not cell then
		self.select_index = 0
		self.node_list["Icon"]:SetActive(false)
		self.node_list["LevelContent"]:SetActive(false)
		self.node_list["BtnReplace"]:SetActive(false)
		self.node_list["BtnUp"]:SetActive(false)
		self.node_list["NotSelect1"]:SetActive(true)
		self.node_list["NotSelect2"]:SetActive(true)
		self.node_list["UpContent"]:SetActive(false)
		return
	end
	local data = cell:GetData()
	if not data or not next(data) then
		self.select_index = 0
		self.node_list["Icon"]:SetActive(false)
		self.node_list["LevelContent"]:SetActive(false)
		self.node_list["BtnReplace"]:SetActive(false)
		self.node_list["BtnUp"]:SetActive(false)
		self.node_list["NotSelect1"]:SetActive(true)
		self.node_list["NotSelect2"]:SetActive(true)
		self.node_list["UpContent"]:SetActive(false)
		return
	end
	self.node_list["Icon"]:SetActive(true)
	self.node_list["LevelContent"]:SetActive(true)
	self.node_list["BtnReplace"]:SetActive(true)
	self.node_list["BtnUp"]:SetActive(true)
	self.node_list["NotSelect1"]:SetActive(false)
	self.node_list["NotSelect2"]:SetActive(false)
	self.node_list["UpContent"]:SetActive(true)

	local flag = data.level >= GameEnum.RUNE_MAX_LEVEL
	self.node_list["ButtonUpText"].text.text = flag and Language.Common.YiManJi or Language.Common.UpGrade
	UI:SetButtonEnabled(self.node_list["BtnUp"],not flag)
	self.node_list["NextAttr1"]:SetActive(not flag)
	self.node_list["Arrow1"]:SetActive(not flag)
	self.node_list["NextAttr2"]:SetActive(not flag)
	self.node_list["Arrow2"]:SetActive(not flag)

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.node_list["Icon"].image:LoadSprite(ResPath.GetItemIcon(item_id))
	end
	self.node_list["BtnReplaceImg"]:SetActive(cell:CanReplace())
	self.node_list["BtnUpImg"]:SetActive(cell:CanUpGrade())
	--设置等级描述
	self:SetLevelDes(data)

	--设置属性描述
	self:SetAttrDes(data)

	--设置升级描述
	self:SetLevelUpDes(data)

	--设置消耗描述
	local need_jinghua = data.uplevel_need_jinghua or 0
	local jing_hua = RuneData.Instance:GetJingHua()

	if data.level >= GameEnum.RUNE_MAX_LEVEL then
		self.node_list["CostNextAttr"].text.text = "--/--"
	elseif need_jinghua > jing_hua then
		self.node_list["CostNextAttr"].text.text = string.format("%s / %s",ToColorStr(jing_hua, TEXT_COLOR.RED_3), ToColorStr(need_jinghua, TEXT_COLOR.GREEN_4))
	else
		self.node_list["CostNextAttr"].text.text = ToColorStr(string.format("%s / %s",jing_hua, need_jinghua), TEXT_COLOR.GREEN_4) 
	end
	local now_max_level = RuneData.Instance:GetRuneLevelLimitInfo()
	if now_max_level and data.level >= now_max_level.rune_level then
		local next_pass_layer = RuneData.Instance:GetNextNeedPassLayer(now_max_level.rune_level)
		if next_pass_layer and next_pass_layer.need_rune_tower_layer then
			self.node_list["JieSuo"]:SetActive(true)
			self.node_list["CostContent"]:SetActive(true)
			self.node_list["TxtNextNeedLayer"].text.text = string.format(Language.Rune.TxtNextNeedLayer, next_pass_layer.need_rune_tower_layer)
		else
			self.node_list["JieSuo"]:SetActive(false)
			self.node_list["CostContent"]:SetActive(true)
		end
	else
		self.node_list["JieSuo"]:SetActive(false)
		self.node_list["CostContent"]:SetActive(true)
	end

	if self.up_select_index == self.select_index and self.old_level > 0 and self.old_level < data.level then
		--展示升级特效
		self:PlayUpEffect()
	end
	self:FlushAwakenAttr()
end

function RuneInlayView:PlayUpEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["Effect_Pos" .. self.select_index].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

-----------------------RuneEquipCell---------------------------
RuneEquipCell = RuneEquipCell or BaseClass(BaseRender)
function RuneEquipCell:__init()
	self.node_list["Slot"].toggle:AddClickListener(BindTool.Bind(self.Click, self))
	self.can_replace = false
	self.can_upgrade = false
end

function RuneEquipCell:__delete()
end

function RuneEquipCell:FlushInit()
	local index = self:GetIndex()
	local flag = true
	local slot_list = RuneData.Instance:GetSlotList()
	if slot_list[index] and slot_list[index].type < 0 then
		flag = false
	end
	if flag and self:GetIndex() ~= RuneData.SoltCenter then
		self.node_list["HightLine"]:SetActive(true)
	end
end

function RuneEquipCell:SetCurrentSelect(index)
	self.select_rune_index = index
	self:FlushInit()
end

function RuneEquipCell:Click()
	if self.clickcallback then
		self.clickcallback(self, self.data)
	end
	if self.root_node.toggle.isOn and self.index ~= RuneData.SoltCenter then
		self.node_list["HightLine"]:SetActive(true)
	end
end

function RuneEquipCell:SetClickCallBack(callback)
	self.clickcallback = callback
end

function RuneEquipCell:SetIndex(index)
	self.index = index
	
end

function RuneEquipCell:GetIndex()
	return self.index
end

function RuneEquipCell:ShowRedPoint(state)
	self.node_list["RedPoint"]:SetActive(state)
end

function RuneEquipCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneEquipCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data

	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	if item_id > 0 then
		self.node_list["ImgWuPin"].image:LoadSprite(ResPath.GetItemIcon(item_id))
	end

	self.lock_state = RuneData.Instance:GetIsLockByIndex(self.index)
	self.node_list["LockImage"]:SetActive(self.lock_state)
	self.node_list["ImgWuPin"]:SetActive(not self.lock_state)

	local openLayer = RuneData.Instance:GetSlotOpenLayerByIndex(self.index)
	self.last_cell_is_lock = RuneData.Instance:GetIsLock(self.index)
	self.node_list["IsShowTipsImg"]:SetActive(nil ~= self.last_cell_is_lock and self.last_cell_is_lock == self.index)
	self.node_list["ImgWuPin"]:SetActive(data.type >= 0)
	self.node_list["TipsText"].text.text = string.format(Language.Rune.OpenLayer, openLayer)
	self.root_node.toggle.enabled = not self.lock_state and data.type >= 0

	local show_red_point = false
	self.can_replace = false
	self.can_upgrade = false
	local limit_cfg = RuneData.Instance:GetRuneLevelLimitInfo()
	local pass_level = (limit_cfg and next(limit_cfg)) and limit_cfg.rune_level or 0
	local select_list = RuneData.Instance:GetBagList()
	local bag_list = {}
	for k, v in pairs(select_list) do
		if self.index == RuneData.SoltCenter and v.type == 20 then
			bag_list[k] = v
		elseif self.index ~= RuneData.SoltCenter then
			if v.type ~= 20 then
				bag_list[k] = v
			end
		end
	end
	if not self.lock_state then
		if data.quality >= 0 then
			local have_jinghua = RuneData.Instance:GetJingHua()
			local need_jinghua = data.uplevel_need_jinghua
			local level = data.level
			if level < RuneData.Instance:GetRuneMaxLevel() and have_jinghua >= need_jinghua and level < pass_level then
				--存在可升级的格子
				self.can_upgrade = true
				show_red_point = true
			end
			for k, v in pairs(bag_list) do
				if data.type == v.type and v.quality > data.quality then
					--存在可替换的格子
					self.can_replace = true
					show_red_point = true
					break
				end
			end
		end

		local is_same = RuneData.Instance:GetIsSameRune()
		if not show_red_point and not is_same then
			for k, v in pairs(bag_list) do
				if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
					if data.quality < 0 then
						--存在未镶嵌的格子
						show_red_point = true
						break
					end
				end
			end
		end
	end
	self.node_list["RedPoint"]:SetActive(show_red_point)
	if self.data.level <= 0 then
		self.node_list["LevelTxt"].text.text = ""
	else
		self.node_list["LevelTxt"].text.text = "Lv." .. data.level
	end
	self:FlushInit()
end

function RuneEquipCell:GetData()
	return self.data
end

function RuneEquipCell:IsLock()
	return self.lock_state
end

function RuneEquipCell:CanReplace()
	return self.can_replace
end

function RuneEquipCell:CanUpGrade()
	return self.can_upgrade
end
