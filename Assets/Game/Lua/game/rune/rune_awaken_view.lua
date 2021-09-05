RuneAwakenView = RuneAwakenView or BaseClass(BaseView)
function RuneAwakenView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/rune_prefab", "RuneAwakenView"}
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RuneAwakenView:__delete()

end

function RuneAwakenView:ReleaseCallBack()

	for _, v in ipairs(self.slot_list) do
		v:DeleteMe()
	end
	self.slot_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	self.fight_text = nil
end

function RuneAwakenView:LoadCallBack()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLiNumTxt"])

	self.node_list["ButtonPropAwaken"].button:AddClickListener(BindTool.Bind(self.ClickPropAwaken, self))
	self.node_list["ButtonDiamondAwaken"].button:AddClickListener(BindTool.Bind(self.ClickDiamandAwaken, self))
	self.node_list["Rule"].button:AddClickListener(BindTool.Bind(self.ClickRule, self))
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.ClickClosen, self))
	self.node_list["BtnBall"].button:AddClickListener(BindTool.Bind(self.ClickGO, self))
	self.node_list["TitleText"].text.text = Language.Rune.TitleName1

	self.item_id = RuneData.Instance:GetCommonAwakenItemID()
	self.slot_list = {}
		for i = 0, 9 do
		local slot_obj = self.node_list["IconList"].transform:GetChild(i).gameObject
		local slot_cell = RuneAwakenRewardCell.New(slot_obj)
		slot_cell:SetIndex(i+1)
		table.insert(self.slot_list, slot_cell)
	end

	self.awaken_award = {}									-- 奖励列表
	self.data_table = {}									-- 数据列表
	self.needle_is_role = false

	self.red_point_list = {
		[RemindName.RuneAwake] = self.node_list["CanPropRep"],
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

end

-- 打开后调用
function RuneAwakenView:OpenCallBack()

	--初始化钻石
	local main_vo = GameVoManager.Instance:GetMainRoleVo()

	self.cell_index = RuneData.Instance:GetCellIndex()
	local data = RuneData.Instance:GetSlotDataByIndex(self.cell_index)
	local item_id = RuneData.Instance:GetRealId(data.quality, data.type)
	self.node_list["SlotCurrentImg"].image:LoadSprite(ResPath.GetItemIcon(item_id))

	local type_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local type_name = Language.Rune.AttrTypeName[data.type] or ""
	local type_des = string.format(Language.Rune.LevelDes, type_color, type_name, data.level)
	self.node_list["LevelTxt"].text.text = type_des

	self:FlushRightView()
	if 0 == self:GetPropCount() then
		self.node_list["Prop"].text.text = "<color=#f9463b>0</color>" .. " / 1"
	else
		self.node_list["Prop"].text.text = self:GetPropCount() .. " / 1"
	end

	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self:FlushDiamondCost()
end

function RuneAwakenView:ItemDataChangeCallback(item_id)
	self:Flush("prop_count")
end

-- 根据当前cell索引初始化数据
function RuneAwakenView:FlushRightView()
	-- 当前符文格属性table
	if 0 == self.cell_index then
		self.cell_index = 1
	end
	self.data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(self.cell_index)
	if nil == self.data_table then
		return
	end
	local layer = RuneData.Instance:GetPassLayer()
	local awaken_limit = RuneData.Instance:GetAwakenLimitByLevel(layer)
	local next_limit_layer = RuneData.Instance:GetNextLimitLayer(layer)
	local show_tips = false
	if self.data_table.maxhp == awaken_limit.maxhp_limit then
		self.node_list["hp"].text.text = self.data_table.maxhp .. Language.Rune.AttrFull
		show_tips = true
	else
		self.node_list["hp"].text.text = self.data_table.maxhp
	end
	if self.data_table.gongji == awaken_limit.gongji_limit then
		self.node_list["atk"].text.text = self.data_table.gongji .. Language.Rune.AttrFull
		show_tips = true
	else
		self.node_list["atk"].text.text = self.data_table.gongji
	end
	if self.data_table.fangyu == awaken_limit.fangyu_limit then
		self.node_list["def"].text.text = self.data_table.fangyu .. Language.Rune.AttrFull
		show_tips = true
	else
		self.node_list["def"].text.text = self.data_table.fangyu
	end

	local effect_amp = self.data_table.add_per * 0.01
	if effect_amp == (awaken_limit.addper_limit * 0.01) then
		
		self.node_list["amp"].text.text = effect_amp .. "%" .. Language.Rune.AttrFull
		show_tips = true
	else
		self.node_list["amp"].text.text = effect_amp .. "%"
	end

	if show_tips then
		local des = string.format(Language.Rune.AwakenTips, next_limit_layer)
		self.node_list["TipsTxt"].text.text = des
		if nil == next_limit_layer then
			self.node_list["TipsTxt"].text.text = ""
		end
	else
		self.node_list["TipsTxt"].text.text = ""
	end

	--当前符文格装备的符文属性table
	local curren_cell_data = RuneData.Instance:GetSlotDataByIndex(self.cell_index)
	-- 计算战斗力
	local attr_base_info = {
		attr_type_0 = curren_cell_data.attr_type_0,
		add_attributes_0 = curren_cell_data.add_attributes_0,
		attr_type_1 = curren_cell_data.attr_type_1,
		add_attributes_1 = curren_cell_data.add_attributes_1,
	}

	local power = 0
	local attr_type_1_is_calc = false
	local attr_type_2_is_calc = false
	if attr_base_info.attr_type_0 >= 9 then
		local add_attributes = attr_base_info.add_attributes_0
		add_attributes = add_attributes * (effect_amp/100)
		local temp_attr_info = CommonStruct.AttributeNoUnderline()
		local attr_type = Language.Rune.AttrType[attr_base_info.attr_type_0]
		RuneData.Instance:CalcAttr(temp_attr_info, attr_type, add_attributes)
		power = power + CommonDataManager.GetCapability(temp_attr_info)
		attr_type_1_is_calc = true
	end

	if attr_base_info.attr_type_1 >= 9 then
		local add_attributes = attr_base_info.add_attributes_1
		add_attributes = add_attributes * (effect_amp/100)
		local temp_attr_info = CommonStruct.AttributeNoUnderline()
		local attr_type = Language.Rune.AttrType[attr_base_info.attr_type_1]
		RuneData.Instance:CalcAttr(temp_attr_info, attr_type, add_attributes)
		power = power + CommonDataManager.GetCapability(temp_attr_info)
		attr_type_2_is_calc = true
	end

	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.Rune.AttrType[attr_base_info.attr_type_0]
	local attr_type_2 = Language.Rune.AttrType[attr_base_info.attr_type_1]

	if not attr_type_1_is_calc and attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, attr_base_info.add_attributes_0)
	end
	if not attr_type_2_is_calc and attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, attr_base_info.add_attributes_1)
	end

	for k,v in pairs(attr_info) do
		if v > 0 then
			attr_info[k] = attr_info[k] * effect_amp * 0.01
		end
	end
	power = power + CommonDataManager.GetCapability(attr_info)
	self:SetPower(self.data_table, power)
end

function RuneAwakenView:SetAwakenAttrInfoByIndex(cell_index)
	self.data_table = {}
	self.data_table = RuneData.Instance:GetAwakenAttrInfoByIndex(cell_index)
end

function RuneAwakenView:SetPower(data_table, extravalue)
	if nil == extravalue then
		extravalue = 0
	end
	if data_table then
		local capability = CommonDataManager.GetCapability(data_table)
		local power_count = capability + extravalue
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power_count
		end
	end
	for k,v in ipairs(self.slot_list) do
		v:Flush()
	end
end

-- function RuneAwakenView:PlayerDataChangeCallback()
-- 	self:Flush("money")
-- end

-- 关闭前调用
function RuneAwakenView:CloseCallBack()
	TipsFloatingManager.Instance:StartFloating()

	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.RuneAwakenView)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
end

function RuneAwakenView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetActive(num > 0)
	end
end

-- 刷新
function RuneAwakenView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "needle" then
			self:ShowAnimation(RuneData.Instance:GetAwakenSeq())
		end
		if k == "rightview" then
			self:FlushRightView()
		end
		if k == "prop_count" then
			if 0 == self:GetPropCount() then
				self.node_list["Prop"].text.text = "<color=#f9463b>0</color>" .. " / 1"
			else
				self.node_list["Prop"].text.text = self:GetPropCount() .. " / 1"
			end
		end
		-- if k == "money" then
			
		-- end
		if k == "diamondcost" then
			self:FlushDiamondCost()
		end
	end
end

function RuneAwakenView:FlushDiamondCost()
	local current_times = RuneData.Instance:GetAwakenTimes()
	local cost_info = RuneData.Instance:GetAwakenCostInfo()
	for k,v in pairs(cost_info) do
		if v.max_times >= current_times and v.min_times <= current_times then
			self.node_list["Diamond"].text.text = cost_info[k].gold_cost
			return
		end
	end
end

function RuneAwakenView:GetMoney()
	return CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold)
end
--道具觉醒
function RuneAwakenView:ClickPropAwaken()
	if self.needle_is_role then
		return
	end
	if not self.node_list["Check"].toggle.isOn then
		TipsFloatingManager.Instance:PauseFloating()
	end
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index - 1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_COMMON)
end

function RuneAwakenView:ClickGO()
	if 1 <= self:GetPropCount() then
		self:ClickPropAwaken()
	else
		self:ClickDiamandAwaken()
	end
end

--钻石觉醒
function RuneAwakenView:ClickDiamandAwaken()
	if self.needle_is_role then
		return
	end

	if not self.node_list["Check"].toggle.isOn then
		TipsFloatingManager.Instance:PauseFloating()
	end

	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN, self.cell_index - 1, RUNE_SYSTEM_AWAKEN_TYPE.RUEN_AWAKEN_TYPE_DIAMOND)
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_OTHER_INFO)
end

--index 需要停的位置 time 转的圈数
function RuneAwakenView:ShowAnimation(index, time)
	if self.node_list["Check"].toggle.isOn then
		-- 如果屏蔽了动画
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
		self.node_list["needle"].transform.localRotation = Quaternion.Euler(0, 0, -(index - 1 ) * 36)
		self:SetAwakenAttrInfoByIndex(self.cell_index)
		return
	end
	if self.needle_is_role then
		return
	end
	self.needle_is_role = true
	if self.tween then
		self.tween:Kill()
		self.tween = nil
	end
	if nil == time then
		time = 4
	end

	local angle = (index-1) * 36
	self.tween = self.node_list["needle"].transform:DORotate(
		Vector3(0, 0, -360 * time - angle),
		time,
		DG.Tweening.RotateMode.FastBeyond360)
	self.tween:SetEase(DG.Tweening.Ease.OutQuart)
	self.tween:OnComplete(function ()
		TipsFloatingManager.Instance:StartFloating()

		--动画播放完毕
		--当前奖励格子索引
		local current_reward_index = RuneData.Instance:GetAwakenSeq()
		--如果是属性
		local is_property = RuneData.Instance:GetIsPropertyByIndex(current_reward_index)
		if 1 == is_property then
			local awaken_type = RuneData.Instance:GetAwakenTypeInfoByIndex(current_reward_index).awaken_type
			local end_obj = nil
			if 1 == awaken_type then
				--攻击
				end_obj = self.node_list["atk"]
			end
			if 2 == awaken_type then
				--防御
				end_obj = self.node_list["def"]
			end
			if 3 == awaken_type then
				--血量
				end_obj = self.node_list["hp"]
			end
			if 4 == awaken_type then
				--增益
				end_obj = self.node_list["amp"]
			end
			if self:IsOpen() then
				local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guangdian1")
				TipsCtrl.Instance:ShowFlyEffectManager(ViewName.RuneAwakenView, bundle_name, asset_name, self.slot_list[current_reward_index].root_node , end_obj,
							nil, 1, BindTool.Bind(self.EffectComplete, self, current_reward_index))
			else
				self:EffectComplete()
			end
		end
		self.needle_is_role = false
	end)
end

function RuneAwakenView:EffectComplete()
	RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_AWAKEN_CALC_REQ)
end

--获取道具数量
function RuneAwakenView:GetPropCount()
	return ItemData.Instance:GetItemNumInBagById(self.item_id)
end

function RuneAwakenView:ClickRule()
	--显示规则信息
	TipsCtrl.Instance:ShowHelpTipView(182)
end

function RuneAwakenView:ClickClosen()
	self.node_list["Check"].toggle.isOn = false
	self:Close()  
end



-----------------------RuneAwakenRewardCell---------------------------

RuneAwakenRewardCell = RuneAwakenRewardCell or BaseClass(BaseCell)
function RuneAwakenRewardCell:__init()
	self.awaken_type = 0
end

function RuneAwakenRewardCell:__delete()
end

function RuneAwakenRewardCell:SetToggleIsOn(state)
	self.root_node.toggle.isOn = state
end

function RuneAwakenRewardCell:GetCurrentType()
	return self.awaken_type
end

function RuneAwakenRewardCell:OnFlush()
	-- 拿到当前符文格子的属性table
	local index = RuneData.Instance:GetCellIndex()
	local data = RuneData.Instance:GetAwakenTypeInfoByIndex(index)
	-- 当前奖励格子的索引
	local current_cell_index = self:GetIndex()
	local current_info = RuneData.Instance:GetAwakenTypeInfoByIndex(current_cell_index)
	-- 如果当前的奖励格子为属性奖励
	--根据当前seq值判断是什么属性（type值）
	--拿到当前等级最大值
	self.awaken_type = current_info.awaken_type
	if RuneData.Instance:GetIsPropertyByIndex(current_cell_index) == 1 then
		-- 符文塔等级
		local layer = RuneData.Instance:GetPassLayer()
		local awaken_limit = RuneData.Instance:GetAwakenLimitByLevel(layer)
		local gongji_limit = awaken_limit.gongji_limit
		local fangyu_limit = awaken_limit.fangyu_limit
		local maxhp_limit = awaken_limit.maxhp_limit
		local addper_limit = awaken_limit.addper_limit
		--拿到当前进度值
		local current_rune_data = RuneData.Instance:GetAwakenAttrInfoByIndex(index)

		local curren_limit = 0
		local current_value = 0
		if 1 == self.awaken_type then
			--攻击
			curren_limit = awaken_limit.gongji_limit
			current_value = current_rune_data.gongji
			self.node_list["PercentTxt"].text.text = "+" .. current_value
		end
		if 2 == self.awaken_type then
			--防御
			curren_limit = awaken_limit.fangyu_limit
			current_value = current_rune_data.fangyu
			self.node_list["PercentTxt"].text.text = "+" .. current_value
		end
		if 3 == self.awaken_type then
			--生命
			curren_limit = awaken_limit.maxhp_limit
			current_value = current_rune_data.maxhp
			self.node_list["PercentTxt"].text.text = "+" .. current_value
		end
		if 4 == self.awaken_type then
			--增幅
			curren_limit = awaken_limit.addper_limit
			current_value = current_rune_data.add_per
			self.node_list["PercentTxt"].text.text = "+" .. current_value / 100 .."%"
		end
		if self.node_list["Slider"] then
			self.node_list["Slider"].slider.value = 1
		end
	else
		self.node_list["PercentTxt"].text.text = ""
	end
	
	if self.node_list["PicImg"] then
		self.node_list["PicImg"].image:LoadSprite(ResPath.GetRuneRes("awk_icon_" .. self.awaken_type))
		self.node_list["PicImg"].image:SetNativeSize()
	else
		self.node_list["FillImg"].image:LoadSprite(ResPath.GetRuneRes("awk_icon_" .. self.awaken_type))
	end
	self.node_list["Text"].text.text = Language.Rune.AwakenType[self.awaken_type]
end

