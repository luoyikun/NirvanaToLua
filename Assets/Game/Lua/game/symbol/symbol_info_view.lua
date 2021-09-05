--喂养 InfoContent
SymbolInfoView = SymbolInfoView or BaseClass(BaseRender)

function SymbolInfoView:__init()
	self.cur_food_index = 1
	self.cur_act = false
	self.model_res = 0
	-- 监听UI事件
	self.node_list["Autodbtn"].button:AddClickListener(BindTool.Bind(self.OnClickAutoFeed, self))
	self.node_list["BtnJiasu"].button:AddClickListener(BindTool.Bind(self.OnClickAccelerate, self))
	self.node_list["BtnTopLook"].button:AddClickListener(BindTool.Bind(self.OnClickChange, self))
	self.node_list["BtnPackage"].button:AddClickListener(BindTool.Bind(self.OnClickActive, self))
	self.node_list["Onebtn"].button:AddClickListener(BindTool.Bind(self.OnClickFeed, self))
	self.node_list["Rewardbtn"].button:AddClickListener(BindTool.Bind(self.OnClickReward, self))
	self.node_list["Img_help"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))

	self.node_list["TxtFeedTip"].text.text = Language.Symbol.FeedTips

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtNumber"])

	self.cell_list = {}
	self.food_list = {}
	self.left_select = 0
	self:InitLeftScroller()
	self:InitMidScroller()
	self:InitRightScroller()
end

function SymbolInfoView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	if self.food_list then
		for k,v in pairs(self.food_list) do
			v:DeleteMe()
		end
	end
	self.food_list = {}
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.fight_text = nil
end

function SymbolInfoView:FlushModel(info)
	if info and info.element_level > 0 then
		if nil == self.model then
			self.model = RoleModel.New()
			self.model:SetDisplay(self.node_list["Display"].ui3d_display)
		end
		local model_res = SymbolData.ELEMENT_MODEL[info.wuxing_type]
		if self.model_res ~= model_res then
			self.model_res = model_res
			local asset, bundle = ResPath.GetSpiritModel(model_res)
			self.model:SetMainAsset(asset, bundle)
			self.model:SetScale(Vector3(1.5, 1.5, 1.5))
		end
	elseif self.model then
		self.model_res = 0
		self.model:ClearModel()
	end
end

function SymbolInfoView:InitLeftScroller()
	local delegate = self.node_list["LeftList"].list_simple_delegate
	-- 生成数量
	self.left_data = SymbolData.Instance:GetElementHeartOpencCfg()
	delegate.NumberOfCellsDel = function()
		return #self.left_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = YuanshuLeftCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.node_list["LeftList"].toggle_group)
		end

		target_cell:SetData(self.left_data[data_index + 1])
		target_cell:SetIndex(data_index)
		target_cell:IsOn(data_index == self.left_select)
		target_cell:SetClickCallBack(BindTool.Bind(self.ClickLeftListCell, self, target_cell))
	end
end

function SymbolInfoView:ClickLeftListCell(cell)
	if self.left_select ~= cell.index then
		local is_send_active = cell:OnLockClick()
		local info = SymbolData.Instance:GetElementInfo(cell.index)
		--是否已激活
		local cur_act = info ~= nil and info.element_level > 0
		if cur_act or is_send_active then
			self.left_select = cell.index
			self:Flush()
		end
		self:MidItemClick(self.food_list[1], 1)
	end
end

function SymbolInfoView:InitMidScroller()
	local delegate = self.node_list["MidList"].page_simple_delegate
	-- 生成数量
	self.mid_data = {}
	delegate.NumberOfCellsDel = function()
		return 4
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(data_index, cell)
		local index = 4 - data_index
		local target_cell = self.food_list[index]

		if nil == target_cell then
			self.food_list[index] =  ItemCell.New(cell.gameObject)
			target_cell = self.food_list[index]
			target_cell:SetToggleGroup(self.node_list["MidList"].toggle_group)
		end

		local data = self.mid_data[index]
		self:SetMidData(target_cell, data, index)
		target_cell:ListenClick(BindTool.Bind(self.MidItemClick, self, target_cell, index))
	end
	self.node_list["MidList"].list_view:JumpToIndex(0)
	self.node_list["MidList"].list_view:Reload()
end

function SymbolInfoView:SetMidData(cell, data, index)
	cell:SetData(data)
	cell:SetIndex(index)
	cell:SetInteractable(data ~= nil)
	cell:SetIconGrayScale(false)
	cell:ShowHighLight(self.cur_food_index == index and data ~= nil)
	cell:SetToggle(self.cur_food_index == index and data ~= nil)
	cell:ShowToLeft(index == 1 and data ~= nil)
	cell:SetTopLeftDes(Language.Symbol.ShuangBei)
	local num = data and data.num or 0
	cell:SetItemNumVisible(data ~= nil, num)
end

function SymbolInfoView:MidItemClick(cell, index)
	cell:ShowHighLight(true)
	cell:SetToggle(true)
	self.cur_food_index = index
end

function SymbolInfoView:InitRightScroller()
	local delegate = self.node_list["RightList"].list_simple_delegate
	-- 生成数量
	self.right_data = {}
	delegate.NumberOfCellsDel = function()
		return #self.right_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  YuanshuAttrcell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
		end
		target_cell:SetData(self.right_data[data_index])
	end
end

function SymbolInfoView:OpenCallBack()
	local right_pos = self.node_list["RightPanel"].transform.anchoredPosition
	local left_pos = self.node_list["LeftPanel"].transform.anchoredPosition
	local under_pos = self.node_list["UnderPanel"].transform.anchoredPosition
	local up_Look_pos = self.node_list["BtnTopLook"].transform.anchoredPosition
	local up_help_pos = self.node_list["Img_help"].transform.anchoredPosition
	local up_name_pos = self.node_list["UpTitleName"].transform.anchoredPosition
	local center_name_pos = self.node_list["CenterMove"].transform.anchoredPosition
	local node_reward_pos = self.node_list["NodeReward"].transform.anchoredPosition

	UITween.MoveShowPanel(self.node_list["NodeReward"], Vector3(node_reward_pos.x, node_reward_pos.y + 200, node_reward_pos.z))
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(right_pos.x + 500, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["LeftPanel"], Vector3(left_pos.x - 300, left_pos.y, left_pos.z))
	UITween.MoveShowPanel(self.node_list["UnderPanel"], Vector3(under_pos.x, under_pos.y - 200, under_pos.z))
	UITween.MoveShowPanel(self.node_list["BtnTopLook"], Vector3(up_Look_pos.x, up_Look_pos.y + 200, up_Look_pos.z))
	UITween.MoveShowPanel(self.node_list["Img_help"], Vector3(up_help_pos.x, up_help_pos.y + 200, up_help_pos.z))
	UITween.MoveShowPanel(self.node_list["UpTitleName"], Vector3(up_name_pos.x, up_name_pos.y + 200, up_name_pos.z))
	UITween.AlpahShowPanel(self.node_list["CenterMove"], true)

	self.model_res = 0
	self:Flush()
end

function SymbolInfoView:CloseCallBack()
	self.cur_food_index = 1
	TipsCtrl.Instance:ChangeAutoViewAuto(false)
	TipsCommonAutoView.AUTO_VIEW_STR_T.change_element = nil
end

function SymbolInfoView:OnClickAutoFeed()
	local food_data = self.mid_data[self.cur_food_index]
	if food_data then
		if food_data.num <= 0 then
			GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, food_data.item_id)
			return
		end
		SymbolCtrl.Instance:SendFeedElementHeartReq(self.left_select, food_data.item_id, food_data.num)
	end
end

function SymbolInfoView:OnClickFeed()
	local food_data = self.mid_data[self.cur_food_index]
	if food_data then
		if food_data.num <= 0 then
			GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, food_data.item_id)
			return
		end
		SymbolCtrl.Instance:SendFeedElementHeartReq(self.left_select, food_data.item_id, 1)
	end
end

function SymbolInfoView:OnClickReward()
	--local func = function()
		for i = 0, #self.left_data - 1 do
			local info = SymbolData.Instance:GetElementInfo(i)
			if info then
				if info.next_product_timestamp <= TimeCtrl.Instance:GetServerTime() then
					SymbolCtrl.Instance:SendRewardElementHeartReq(i)
				end
			end
		end
	--end
	-- local func2 = function()
	-- 	SymbolCtrl.Instance:SendRewardElementHeartReq(self.left_select)
	-- end
	-- TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Symbol.CanOnceReward, nil, nil, false, nil, nil, 
	-- 	nil, nil, nil, true, nil, nil, Language.Common.Cancel)
end

function SymbolInfoView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(246)
end

function SymbolInfoView:OnClickAccelerate()
	if not self.cur_act then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.NotActivitySymbol)
		return
	end
	local func = function ()
		SymbolCtrl.Instance:SendProductElementHeartReq(self.left_select)
	end
	local t = math.max(self.time - TimeCtrl.Instance:GetServerTime(), 0)
	t = math.ceil(t / 60)
	local other = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	local gold = other.ghost_product_up_seed_need_gold_per_min
	local id = other.ghost_product_up_seed_need_item_id
	local stuff_num = ItemData.Instance:GetItemNumInBagById(id)
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Symbol.AccelerateDescription, gold * t, gold, stuff_num))
end

function SymbolInfoView:OnClickChange()
	if not self.cur_act then
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.NotActivitySymbol)
		return
	end
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local price = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1].change_wuxing_type_need_gold
	local func = function ()
		if role_gold >= price then
			SymbolCtrl.Instance:SendChangeElementHeartReq(self.left_select)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	local str = string.format(Language.Symbol.ChangeElementDescription, price)
	TipsCtrl.Instance:ShowCommonAutoView("change_element", str, func, nil, nil, nil, nil, nil, true)
end

function SymbolInfoView:OnClickActive()
	SymbolCtrl.Instance:SendActiveElementHeartReq(self.left_select)
end

function SymbolInfoView:SetCanReward(value)
	self.node_list["TxtRewardPanel"]:SetActive(not value)
	--self.node_list["Rewardbtn"]:SetActive(value)
	UI:SetButtonEnabled(self.node_list["Rewardbtn"], value)
	self.node_list["Rewardbtn"].animator.enabled = value
	if value and not self.node_list["Rewardbtn"].animator:GetBool("Shake") then
		self.node_list["Rewardbtn"].animator:SetBool("Shake", value)
	end
	if value then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		self.node_list["TxtRewardBtn"].text.text = Language.Symbol.CanReward
	else
		self.node_list["Rewardbtn"].transform.eulerAngles = Vector3(0, 0, 0)
	end
	self.node_list["NodeEffect"]:SetActive(value)
end

function SymbolInfoView:OnFlush(param_t)
	local data = SymbolData.Instance
	local info = data:GetElementInfo(self.left_select)
	--是否已激活
	self.cur_act = info ~= nil and info.element_level > 0
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.node_list["ImgPackage"]:SetActive(data:GetSymbolYuanSuCanActive(self.left_select))
	-- 激活
	if self.cur_act then
		self.node_list["TxtTitle"].text.text = Language.Symbol.LvTxt .. info.element_level .. " " .. Language.Symbol.ElementsName[info.wuxing_type]
		--self.node_list["ImgTopLook"].image:LoadSprite(ResPath.GetSymbolImage("Element_" .. info.wuxing_type))
		local asset, bundle = ResPath.GetSymbolImage("Element_" .. info.wuxing_type)
		self.node_list["BtnTopLook"].image:LoadSprite(asset, bundle, function()
			self.node_list["BtnTopLook"].image:SetNativeSize()
			end)
		-- 产出时间
		self.time = info.next_product_timestamp
		if self.time > TimeCtrl.Instance:GetServerTime() then
			self:SetCanReward(false)
			self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		else
			self:SetCanReward(true)
		end

		self.mid_data = data:GetElementFoodsByType(info.wuxing_type)
		local level_cfg = data:GetElementHeartLevelCfg(info.element_level)
		local next_level_cfg = data:GetElementHeartLevelCfg(info.element_level + 1)
		local cur_attr = CommonDataManager.GetAttributteByClass(level_cfg)
		local next_attr = CommonDataManager.GetAttributteByClass(next_level_cfg)
		local add = data:GetElementXiLianAttrAdditionValue(self.left_select)
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = CommonDataManager.GetCapability(cur_attr) * (1 + add / 100)
		end

		if next_level_cfg then
			local wuxing_max = level_cfg.wuxing_max - level_cfg.wuxing_min + 1
			local cur_value = math.max(info.wuxing_bless - level_cfg.wuxing_min, 0)
			self.node_list["SliderProgressBG"].slider.value = cur_value / wuxing_max
			self.node_list["TxtProgressBG"].text.text = cur_value .. "/" .. wuxing_max
		else
			-- 满级
			self.node_list["SliderProgressBG"].slider.value = 1
			self.node_list["TxtProgressBG"].text.text = Language.Common.MaxLevel
			UI:SetButtonEnabled(self.node_list["Onebtn"], false)
			UI:SetButtonEnabled(self.node_list["Autodbtn"], false)
		end

		self.right_data = {}
		for k,v in ipairs(CommonDataManager.attrview_t) do
			local cur_val = cur_attr[v[2]] or 0
			local next_val = next_attr[v[2]] or 0
			if cur_val > 0 or next_val > 0 then
				table.insert(self.right_data, {key = v[2], cur_value = cur_val, next_value = next_val})
			end
		end
	-- 未激活
	else
		-- self.node_list["TxtTitle"].text.text = Language.Symbol.LvTxt .. 0
		-- self.node_list["TxtNumber"].text.text = tostring(0)
		-- self.node_list["SliderProgressBG"].slider.value = tostring(0)
		-- self.node_list["TxtProgressBG"].text.text = tostring(0)
		if 0 == self.left_select then
			SymbolCtrl.Instance:SendActiveElementHeartReq(self.left_select)
		end
		return
	end

	-- 刷新模型
	self:FlushModel(info)
	--self.node_list["NodeRewardPanel"]:SetActive(self.cur_act)
	self.node_list["RightArrList"]:SetActive(self.cur_act)
	-- self.node_list["BtnTopLook"]:SetActive(self.cur_act)
	self.node_list["NodeActivePanel"]:SetActive(not self.cur_act)
	UI:SetButtonEnabled(self.node_list["Onebtn"], self.cur_act)
	UI:SetButtonEnabled(self.node_list["Autodbtn"], self.cur_act)

	-- 自动选择材料
	--if self.mid_data[self.cur_food_index] == nil or self.mid_data[self.cur_food_index].num <= 0 then
		for i,v in ipairs(self.mid_data) do
			if self.mid_data[self.cur_food_index] and self.mid_data[self.cur_food_index].num > 0 then
				self.cur_food_index = self.cur_food_index
				break
			end
			if v.num > 0 then
				self.cur_food_index = i
				break
			end
		end
	--end

	if self.node_list["LeftList"].scroller.isActiveAndEnabled then
		self.node_list["LeftList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	for k,v in pairs(self.food_list) do
		if self.mid_data[k] then
			self:SetMidData(v, self.mid_data[k], k)
		else
			self:SetMidData(v, nil, k)
		end
	end

	if self.node_list["RightList"].scroller.isActiveAndEnabled then
		self.node_list["RightList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function SymbolInfoView:FlushNextTime()
	local time = self.time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self:SetCanReward(true)
	end
	if time > 3600 * 24 then
		local txt_time = TimeUtil.FormatSecond(time, 6)
		self.node_list["TxtRewardPanel"].text.text = string.format(Language.Symbol.RewardTime, txt_time)
		self.node_list["TxtRewardBtn"].text.text = txt_time
	elseif time > 3600 then
		local txt_time = TimeUtil.FormatSecond(time, 1)
		self.node_list["TxtRewardPanel"].text.text = string.format(Language.Symbol.RewardTime, txt_time)
		self.node_list["TxtRewardBtn"].text.text = txt_time
	elseif time > 0 then
		local txt_time = TimeUtil.FormatSecond(time, 2)
		self.node_list["TxtRewardPanel"].text.text = string.format(Language.Symbol.RewardTime, txt_time)
		self.node_list["TxtRewardBtn"].text.text = txt_time
	else
		self.node_list["TxtRewardBtn"].text.text = Language.Symbol.CanReward
	end
	self.node_list["NodeEffect"]:SetActive(time <= 0)
end

----------------------------滚动条格子-------------------------------------

YuanshuLeftCell = YuanshuLeftCell or BaseClass(BaseCell)

function YuanshuLeftCell:__init()
	self.node_list["ToggleCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function YuanshuLeftCell:__delete()

end

function YuanshuLeftCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function YuanshuLeftCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function YuanshuLeftCell:Lock(value)
	self.node_list["ImgIcon"]:SetActive(not value)
	self.node_list["BtnLock"]:SetActive(value)
end

function YuanshuLeftCell:OnLockClick()
	local l_info = SymbolData.Instance:GetElementInfo(self.index - 1)
	local l_cfg = SymbolData.Instance:GetElementLimitByID(self.index)
	local now_info = SymbolData.Instance:GetElementInfo(self.index)

	if l_info and l_cfg then
		if l_info.element_level >= l_cfg.condtion then
			if now_info.element_level <= 0 then
				SymbolCtrl.Instance:SendActiveElementHeartReq(self.index)
				return true
			end
		else
			local str = Language.Symbol.FreeActivation[l_cfg.condtion_type]
			if str and l_cfg.condtion > 0 then
				str = string.format(str, l_cfg.condtion)
			end
			TipsCtrl.Instance:ShowSystemMsg(str)
		end
	end
	return false
end

function YuanshuLeftCell:OnFlush()
	if nil == self.data then return end
	local element_data = SymbolData.Instance
	local info = element_data:GetElementInfo(self.data.id)
	local can_act = element_data:GetSymbolYuanSuCanActive(self.data.id)
	if info and info.element_level > 0 then
		self:Lock(false)
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. info.wuxing_type))
		self.node_list["TxtName"].text.text = Language.Symbol.LvTxt .. info.element_level
		local has_tuijian_food = element_data:GetHasTuijianElementFoods(info.wuxing_type) and element_data:GetElementMaxLevel() > info.element_level
		-- local can_reward = info.next_product_timestamp <= TimeCtrl.Instance:GetServerTime()
		self.node_list["ImgRed"]:SetActive(can_act or has_tuijian_food)-- or can_reward)
	else
		self.node_list["ImgRed"]:SetActive(can_act)
		local l_info = SymbolData.Instance:GetElementInfo(self.index - 1 <= 0 and 0 or self.index - 1)
		self:Lock(true)
		self.node_list["TxtName"].text.text = ""
	end
	local l_info = SymbolData.Instance:GetElementInfo(self.index - 1)
	local l_cfg = SymbolData.Instance:GetElementLimitByID(self.index)
	self.node_list["ToggleCell"].toggle.interactable = can_act
end

---------------------------------------------------------------------------

YuanshuAttrcell = YuanshuAttrcell or BaseClass(BaseCell)

function YuanshuAttrcell:__init()
end

function YuanshuAttrcell:__delete()
end

function YuanshuAttrcell:OnFlush()
	if nil == self.data then return end
	
	if self.data.next_value > 0 then
		self.node_list["ImgArrow"]:SetActive(true)
		self.node_list["TxtAttrAdd"]:SetActive(true)
		local pos = self.node_list["TxtAttr"].transform.anchoredPosition
		self.node_list["TxtAttr"].transform.anchoredPosition = Vector3(-40, pos.y, pos.z)
	else
		self.node_list["ImgArrow"]:SetActive(false)
		self.node_list["TxtAttrAdd"]:SetActive(false)
		local pos = self.node_list["TxtAttr"].transform.anchoredPosition
		self.node_list["TxtAttr"].transform.anchoredPosition = Vector3(10, pos.y, pos.z)
	end

	local hp = (ToColorStr(Language.Common.AttrName[self.data.key] .. "：", "#d0d8ff")) .. self.data.cur_value
	self.node_list["TxtAttr"].text.text = hp
	self.node_list["TxtAttrAdd"].text.text = self.data.next_value - self.data.cur_value
end