--强化
ShenYinQiangHuaView = ShenYinQiangHuaView or BaseClass(BaseRender)
local MOVE_TIME = 0.5	-- 界面动画时间
local MOVE_LOOP = 1
function ShenYinQiangHuaView:UIsMove()
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-200, -18, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleDown"], Vector3(0, 100, 0 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleUp"], Vector3(0, -200, 0 ), MOVE_TIME)
	UITween.ScaleShowPanel(self.node_list["MiddleScale"],Vector3(0.8, 0.8, 0.8 ), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleContent"], Vector3(0, -50, 0 ), MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["MiddleContent"],true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["Right1"], Vector3(0, 250, 0 ), MOVE_TIME)
end
function ShenYinQiangHuaView:__init()
	self.select_item_index = -1
	self.slot_num = 0
	self.use_safe = false
	self.is_automatic = false
	self.is_auto_qianghua = false
	self.cell_list = {}
	self.node_list["SafeBtn"].button:AddClickListener(BindTool.Bind(self.OnSafeBtn, self))
	self.node_list["BtnQiangHua"].button:AddClickListener(BindTool.Bind(self.OnBtnQiangHua,self))
	self.node_list["SelectToggle"].button:AddClickListener(BindTool.Bind(self.OnSelectToggle,self))
	self.node_list["AllAttrBtn"].button:AddClickListener(BindTool.Bind(self.OnAllAttrBtn,self))
	self.node_list["TipsImg"].button:AddClickListener(BindTool.Bind(self.OnTipsImg,self))
	self.node_list["BtnQiangHuaAuto"].button:AddClickListener(BindTool.Bind(self.OnClickAutoQiangHua,self))

	self.list = self.node_list["List"]
	self.item_left = ItemCell.New()
	self.item_left:SetInstanceParent(self.node_list["ItemLeft"])
	self.item_top = ItemCell.New()
	self.item_top:ListenClick(BindTool.Bind(self.OnClickTip, self))
	self.item_top:SetInstanceParent(self.node_list["ItemTop"])

	self.item_right = ItemCell.New()
	self.item_right:ListenClick(BindTool.Bind(self.OnSafeBtn, self))
	self.item_right:SetInstanceParent(self.node_list["ItemRight"])
	self.star_list = {}
	for i = 1, 10 do
		self.star_list[i] = self.node_list["StarImg" .. i]
	end
	self.list_view_delegate = self.list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	local start_pos = Vector3(30, -30, 0)
	local end_pos = Vector3(30, 0, 0)
	UITween.MoveLoop(self.node_list["UpArrow"], start_pos, end_pos, MOVE_LOOP)

	self.attr_list1 = {}
	local count = 1
	local child_number = self.node_list["AttrGroup1"].transform.childCount
	for i = 0, child_number - 1 do
		local obj = self.node_list["AttrGroup1"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local item_tab = {}
			item_tab.obj = obj
			item_tab.attr_name = variable_table["Attr"]
			item_tab.attr_value = variable_table["AttrValueNumber"]
			self.attr_list1[count] = item_tab
			count = count + 1
		end
	end
	self.attr_list2 = {}
	count = 1
	child_number = self.node_list["AttrGroup2"].transform.childCount
	for i = 0, child_number - 1 do
		local obj = self.node_list["AttrGroup2"].transform:GetChild(i).gameObject
		if string.find(obj.name, "Attr") ~= nil then
			local variable_table = U3DNodeList(obj:GetComponent(typeof(UINameTable)))
			local item_tab = {}
			item_tab.obj = obj
			item_tab.attr_name = variable_table["Attr"]
			item_tab.attr_value = variable_table["AttrValueNumber"]
			self.attr_list2[count] = item_tab
			count = count + 1
		end
	end

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["capabilityTxt"])
	self.fight_text_two = CommonDataManager.FightPower(self, self.node_list["Txtnext_capability"])

end

function ShenYinQiangHuaView:__delete()
	self.fight_text = nil
	self.fight_text_two = nil
	UITween.KillMoveLoop(self.node_list["UpArrow"])
	self.list = nil
	self.select_item_index = 0
	if self.item_top then
		self.item_top:DeleteMe()
		self.item_top = nil
	end
	if self.item_left then
		self.item_left:DeleteMe()
		self.item_left = nil
	end
	if self.item_right then
		self.item_right:DeleteMe()
		self.item_right = nil
	end
	self.star_list = {}
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.use_safe = false
	self.lowest_shenyin_index = nil
	self.click_list_index = nil
	self.is_show_plus = nil
	self.is_show_next_plus = nil
	self.is_automatic = false
	self.is_auto_qianghua = false
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if nil ~= self.time_qianghua then
		GlobalTimerQuest:CancelQuest(self.time_qianghua)
	end
	self.time_qianghua = nil
end

-- 物品不足，购买成功后刷新物品数量
function ShenYinQiangHuaView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	RemindManager.Instance:Fire(RemindName.ShenYin_QiangHua)
	self:Flush()
end

function ShenYinQiangHuaView:OpenCallBack(slot_index)
	if nil == slot_index then
		slot_index = -1
	end
	self.select_item_index = slot_index
	local slot_info, num = ShenYinData.Instance:GetWearShenYinList()
	self.slot_info = slot_info
	if -1 == self.select_item_index then
		if next(self.slot_info) then
			self.select_item_index = self.slot_info[0].imprint_slot
		end
	end
	self.slot_num = num
	self:Flush()
end

function ShenYinQiangHuaView:OnClickTip()
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = data[self.select_item_index]
	ShenYinCtrl.Instance:OpenYinJiTip(item_data, ShenYinYinJiTipView.FromView.ShenYinStrength)
end

function ShenYinQiangHuaView:OnFlush(param_t)
	local slot_info, num = ShenYinData.Instance:GetWearShenYinList()
	self.slot_info = slot_info
	self.slot_num = num
	local item_cfg = ShenYinData.Instance:GetMarkSlotInfo()
	if self.list.scroller.isActiveAndEnabled then
		self.list.scroller:RefreshAndReloadActiveCellViews(true)
		self.lowest_shenyin_index = nil
		for k,v in pairs(self.slot_info) do
			local item_data = item_cfg[v.imprint_slot]
			if self.lowest_shenyin_index then
				local lowest_item_data = item_cfg[self.slot_info[self.lowest_shenyin_index].imprint_slot]
				if item_data.grade < lowest_item_data.grade then 
					self.lowest_shenyin_index = k
				elseif item_data.grade == lowest_item_data.grade and item_data.level < lowest_item_data.level then 
					self.lowest_shenyin_index = k
				end
			else
				self.lowest_shenyin_index = k
			end
		end
	end

	if self.lowest_shenyin_index and self.slot_info and self.slot_info[self.lowest_shenyin_index] and self.slot_info[self.lowest_shenyin_index].imprint_slot then 
		local lowest_shenyin_data = item_cfg[self.slot_info[self.lowest_shenyin_index].imprint_slot]
		local max_cfg = ShenYinData.Instance:GetShenYinQiangHuaMax()
		local is_max_level = lowest_shenyin_data and lowest_shenyin_data.grade >= max_cfg.stage and lowest_shenyin_data.level >= max_cfg.level
		if is_max_level then 
			self.is_auto_qianghua = false
			UI:SetButtonEnabled(self.node_list["BtnQiangHuaAuto"], false)
		else
			UI:SetButtonEnabled(self.node_list["BtnQiangHuaAuto"], true)
		end
	else
		UI:SetButtonEnabled(self.node_list["BtnQiangHuaAuto"], false)
	end
	self.node_list["ItemTop"]:SetActive(true)
	self.node_list["ItemRight"]:SetActive(true)
	self.node_list["WarninText"]:SetActive(false)
	self.node_list["FpNode"]:SetActive(true)
	if self.slot_num == 0 then
		self:InitRightView()
		return
	end
	self:OnFlushRight()

	for k, v in pairs(param_t) do
		if k == "all" then
			if self.is_auto_qianghua then 
				if nil ~= self.time_qianghua then
					GlobalTimerQuest:CancelQuest(self.time_qianghua)
				end
				self.time_qianghua = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SendAutoQiangHua, self), 0.5)
				self.node_list["TxtBtnAuto"].text.text = Language.MingWen.Cancel
			else
				if nil ~= self.time_qianghua then
					GlobalTimerQuest:CancelQuest(self.time_qianghua)
					self.time_qianghua = nil
				end
				self.node_list["TxtBtnAuto"].text.text = Language.MingWen.AutoBtn
			end
		end
	end
	if self.is_auto_qianghua then 
		self.node_list["TxtBtnAuto"].text.text = Language.MingWen.Cancel
	else
		self.node_list["TxtBtnAuto"].text.text = Language.MingWen.AutoBtn
	end
end

function ShenYinQiangHuaView:InitRightView()
	self.use_safe = false
	self.node_list["ItemTop"]:SetActive(false)
	self.node_list["ItemRight"]:SetActive(false)
	self.node_list["FpNode"]:SetActive(false)
	self.node_list["Bag_numTxt"].text.text = ToColorStr(0, COLOR.RED) .. " / " .. 1
	self.node_list["Need_numTxt"].text.text = ToColorStr(0, COLOR.RED) .. " / " .. 0
	self.node_list["successTxt"].text.text = string.format(Language.ShenYin.odds,0) .. "%"
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = 0
	end
	self.node_list["safeImg"]:SetActive(true)
	self.node_list["WarninText"]:SetActive(true)
	self.node_list["rightTxt"].text.text = string.format(Language.MultiMount.Grade, CommonDataManager.GetDaXie(0))

	local max_cfg = ShenYinData.Instance:GetShenYinQiangHuaMax()
	self.item_left:SetData({item_id = max_cfg.consume_v_item_id or 0})

	for i = 1, 10 do
		self.star_list[i].image:LoadSprite(ResPath.GetImages("icon_star_0"))
	end
end

function ShenYinQiangHuaView:OnSafeBtn()
	if self.slot_num == 0 then
		return
	end
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = data[self.select_item_index]
	local up_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.select_item_index, item_data.grade, item_data.level)
	local need_protect_num = up_star_cfg.need_protect_num
	local bag_protect_num = ItemData.Instance:GetItemNumInBagById(up_star_cfg.protect_v_item_id)
	if bag_protect_num < need_protect_num then
		TipsCtrl.Instance:ShowItemGetWayView(up_star_cfg.protect_v_item_id)
		return
	end

	self.use_safe = not self.use_safe
	if self.item_right then
		self.item_right:SetHighLight(false)
	end
	self:OnFlushRight()
end

function ShenYinQiangHuaView:OnClickAutoQiangHua()
	self.is_auto_qianghua = not self.is_auto_qianghua
	self:Flush()
end

function ShenYinQiangHuaView:SendAutoQiangHua()
	local jump_to = true
	if self.root_node.gameObject.activeInHierarchy then 
		if self.select_item_index ~= self.lowest_shenyin_index and self.lowest_shenyin_index then 
			for k,v in pairs(self.cell_list) do
				if v:GetNeedIndex() == self.lowest_shenyin_index then 
					jump_to = false
				end
			end
			if jump_to then
				self.list.scroller:JumpToDataIndex(self.lowest_shenyin_index)
			end
		end
		if self.lowest_shenyin_index then
			self:ClickHander(self.slot_info[self.lowest_shenyin_index], false)
			self:OnBtnQiangHua()
		end
	else
		if nil ~= self.time_qianghua then
			GlobalTimerQuest:CancelQuest(self.time_qianghua)
			self.time_qianghua = nil
		end
		self.is_auto_qianghua = false
	end
end

function ShenYinQiangHuaView:StopAutoQiangHua()
	self.is_auto_qianghua = false
	self:Flush()
end

function ShenYinQiangHuaView:OnBtnQiangHua()
	if self.slot_num == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenYin.NoItem)
		return
	end
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		--勾选自动购买
		if is_buy_quick then
			self.is_automatic = true
		end
	end

	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = data[self.select_item_index]
	local up_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.select_item_index, item_data.grade, item_data.level)
	local num_bag = ItemData.Instance:GetItemNumInBagById(up_star_cfg.consume_v_item_id)
	local need_num = up_star_cfg.need_num
	if num_bag < need_num and not self.is_automatic then
		TipsCtrl.Instance:ShowCommonBuyView(func, up_star_cfg.consume_v_item_id, nil, need_num - num_bag)
		if nil ~= self.time_qianghua then
			GlobalTimerQuest:CancelQuest(self.time_qianghua)
			self.time_qianghua = nil
			self.is_auto_qianghua = false
			self:Flush()
		end
		return
	end

	ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.IMPRINT_UP_START, self.select_item_index, self.use_safe and 1 or 0, self.is_automatic and 1 or 0)
end

function ShenYinQiangHuaView:OnSelectToggle()
	self.is_automatic = not self.is_automatic
	self.node_list["automaticImg"]:SetActive(self.is_automatic)
end


function ShenYinQiangHuaView:OnAllAttrBtn()
	ShenYinCtrl.Instance:OpenQiangHuaAttrView(self.select_item_index)
end

function ShenYinQiangHuaView:OnTipsImg()
	TipsCtrl.Instance:ShowHelpTipView(242)
end

function ShenYinQiangHuaView:GetSelectIndex()
	return self.select_item_index
end

--滚动条数量
function ShenYinQiangHuaView:GetNumberOfCells()
	return self.slot_num
end

--滚动条刷新
function ShenYinQiangHuaView:RefreshView(cell, data_index)
	local item_cell = self.cell_list[cell]
	if item_cell == nil then
		item_cell = ShenYinQiangHuaItemCell.New(cell.gameObject, self)
		self.cell_list[cell] = item_cell
		self.cell_list[cell]:SetFromView(0)
		self.cell_list[cell]:SetToggleGroup(self.list.toggle_group)
	end

	self.cell_list[cell]:SetNeedIndex(data_index)
	self.cell_list[cell]:SetData(self.slot_info[data_index], self.node_list["UpArrow"])
	self.cell_list[cell]:SetClickHander(BindTool.Bind(self.ClickHander, self, self.slot_info[data_index]))
	self.cell_list[cell]:SetIndex(data_index + 1)
	item_cell:SetItemHL()
	item_cell:Flush()
end

function ShenYinQiangHuaView:OnFlushRight()
	self.node_list["automaticImg"]:SetActive(self.is_automatic)
	local data = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = data[self.select_item_index]
	if not item_data then return end
	
	self.item_top:SetData({item_id = item_data.item_id,
						is_bind = item_data.is_bind,
						num = item_data.item_num
						})
	local up_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.select_item_index, item_data.grade, item_data.level)
	self.item_left:SetData({item_id = up_star_cfg.consume_v_item_id or 0})
	self.item_right:SetData({})
	local color_stuff = ItemData.Instance:GetItemNumInBagById(up_star_cfg.consume_v_item_id) >= up_star_cfg.need_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4

	local str_stuff = ToColorStr(ItemData.Instance:GetItemNumInBagById(up_star_cfg.consume_v_item_id), color_stuff)
	self.node_list["Bag_numTxt"].text.text = str_stuff .. " / " .. up_star_cfg.need_num

	local need_protect_num = up_star_cfg.need_protect_num
	local bag_protect_num = self.use_safe and ItemData.Instance:GetItemNumInBagById(up_star_cfg.protect_v_item_id) or 0
	local color_safe_stuff = bag_protect_num >= need_protect_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	self.node_list["Need_numTxt"].text.text = ToColorStr(bag_protect_num, color_safe_stuff) .. " / " .. need_protect_num
	
	if self.use_safe then
		self.item_right:SetData({item_id = up_star_cfg.protect_v_item_id or 0})
	end
	self.node_list["rightTxt"].text.text = string.format(Language.MultiMount.Grade, CommonDataManager.GetDaXie(item_data.grade))
	
	local bundle, asset = ResPath.GetShenYinIcon(self.select_item_index + 1)
	self.node_list["safeImg"]:SetActive(not self.use_safe)
	self.node_list["successTxt"].text.text = string.format(Language.ShenYin.odds,up_star_cfg.rate or 100) .. "%"
	local grade = (item_data.grade + 1 > 10) and item_data.grade % 10 or item_data.grade
	for i = 1, 10 do
		if item_data.level < i then 
			self.star_list[i].image:LoadSprite(ResPath.GetImages("icon_star_0"))
		else
			self.star_list[i].image:LoadSprite(ResPath.GetImages("icon_star_6"))
		end
	end
	local max_cfg = ShenYinData.Instance:GetShenYinQiangHuaMax()
	local is_min_level = item_data.grade == 0 and item_data.level == 0
	local is_max_level = item_data.grade >= max_cfg.stage and item_data.level >= max_cfg.level
	self.node_list["FpNode"]:SetActive(not is_max_level)
	self.node_list["ImgArrows"]:SetActive(not is_max_level)
	if is_max_level then 
		UI:SetButtonEnabled(self.node_list["BtnQiangHua"], false)
		self.node_list["TxtBtnQiangHua"].text.text = Language.ShenYin.YiManJi
		self.node_list["Bag_numTxt"].text.text = Language.Common.MaxLevelDesc
	else
		if self.is_auto_qianghua then
			UI:SetButtonEnabled(self.node_list["BtnQiangHua"], false)
		else
			UI:SetButtonEnabled(self.node_list["BtnQiangHua"], true)
		end
		self.node_list["TxtBtnQiangHua"].text.text = Language.ShenYin.Zhuling
	end
	if item_data.grade >= max_cfg.stage and item_data.level >= max_cfg.level then
		self.node_list["ItemRight"]:SetActive(false)
		self.node_list["safeImg"]:SetActive(true)
		UI:SetButtonEnabled(self.node_list["SafeBtn"],false)
	else
		UI:SetButtonEnabled(self.node_list["SafeBtn"],true)
		self.node_list["ItemRight"]:SetActive(true)
	end

	local next_grade = item_data.level + 1 > 10 and item_data.grade + 1 or item_data.grade
	local next_level = item_data.level + 1 > 10 and 0 or item_data.level + 1
	-- if item_data.grade >= max_cfg.stage and item_data.level >= max_cfg.level then return end
	local next_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.select_item_index, next_grade, next_level)
	if next_star_cfg and not is_max_level then
		local attr_list, power = self:GetAttrTabAndFight(next_star_cfg)
		if self.fight_text_two and self.fight_text_two.text then
			self.fight_text_two.text.text = power
		end
		for k, v in pairs(self.attr_list2) do
			if k <= #attr_list then
				v.attr_name.text.text = attr_list[k].name .. '：'
				v.attr_value.text.text = attr_list[k].value
				v.obj:SetActive(true)
			else
				v.obj:SetActive(false)
			end
		end
		self.node_list["AttrBg2"]:SetActive(true)
	else
		self.node_list["AttrBg2"]:SetActive(false)
	end
	if up_star_cfg and next_star_cfg then
		local attr_list, power = self:GetAttrTabAndFight(up_star_cfg)
		local next_attr_list, _ = self:GetAttrTabAndFight(next_star_cfg)
		for k, v in pairs(self.attr_list1) do
			if k <= #attr_list then
				v.attr_name.text.text = attr_list[k].name .. '：'
				v.attr_value.text.text = attr_list[k].value
				v.obj:SetActive(true)
			else
				v.obj:SetActive(false)
			end
			if #attr_list == 0 and next_attr_list and next_attr_list[k] and next_attr_list[k].name then
				v.attr_name.text.text = next_attr_list[k].name .. '：'
				v.attr_value.text.text = 0
				v.obj:SetActive(true)
			end
		end
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = power
		end
	end
end

function ShenYinQiangHuaView:ClickHander(data, bool)
	self.use_safe = false
	if bool == nil then 
		self.is_automatic = false
	end
	self.select_item_index = data.imprint_slot
	if self.list.scroller.isActiveAndEnabled then
		self.list.scroller:RefreshActiveCellViews()
	end
	self:OnFlushRight()
	
end

function ShenYinQiangHuaView:GetAttrTabAndFight(attr_cfg)
	if nil == attr_cfg then 
		return {}, 0
	end
	
	local attr_tab = CommonDataManager.GetAttributteNoUnderline(attr_cfg)
	local cur_attr = CommonDataManager.GetOrderAttributte(attr_tab)
	local fight_power = CommonDataManager.GetCapability(attr_tab)
	local total_attr = {}
	local count = 1
	for k, v in pairs(cur_attr) do
		if v.value > 0 then
			total_attr[count] = {}
			total_attr[count].name = CommonDataManager.GetAttrName(v.key)
			total_attr[count].value = v.value
			count = count + 1
		end
	end
	return total_attr, fight_power
end

----------------------------------------------------------------------
ShenYinQiangHuaItemCell = ShenYinQiangHuaItemCell or BaseClass(BaseCell)

function ShenYinQiangHuaItemCell:__init(instance, parent)
	self.from_view = 0
	self.parent = parent
	self.click_hanser = nil
	self.display = ItemCell.New()
	self.display:SetInstanceParent(self.node_list["ItemCell"])
	self.display:ListenClick(BindTool.Bind(self.OnClickTip, self))
	self.node_list["StrongEquipContent"].toggle:AddValueChangedListener(BindTool.Bind(self.Onclick, self))
end

function ShenYinQiangHuaItemCell:__delete()
	if self.display then
		self.display:DeleteMe()
		self.display = nil
	end
end
function ShenYinQiangHuaItemCell:SetData(data, anim_obj)
	self.data = data
	if nil == self.anim_obj then 
		self.anim_obj = anim_obj
	end
	self:Flush()
end
function ShenYinQiangHuaItemCell:SetNeedIndex(value)
	self.need_value = value
end
function ShenYinQiangHuaItemCell:GetNeedIndex()
	return self.need_value or -1
end
function ShenYinQiangHuaItemCell:Onclick()
	if self.click_hanser then
		self.click_hanser()
	end
end

function ShenYinQiangHuaItemCell:SetClickHander(click_hanser)
	self.click_hanser = click_hanser
end

function ShenYinQiangHuaItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenYinQiangHuaItemCell:SetItemHL()
	self.node_list["HightlightImg"]:SetActive(self.parent:GetSelectIndex() == self.data.imprint_slot)
end

function ShenYinQiangHuaItemCell:OnFlush()
	local data = self.data
	
	local hunshou_name = ShenYinData.Instance:GetHunShou()	

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local item_name = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	self.display:SetData(data)
	local bundle, asset = ResPath.GetShenYinIcon(data.imprint_slot)
	self.node_list["IconImg"].image:LoadSprite(bundle, asset)

	if data.is_have_mark then
		self.node_list["IconImg"]:SetActive(false)
		self.display:ShowQuality(true)
		self.node_list["ItemNameTxt"].text.text = item_name
	else
		self.display:ShowQuality(false)
		self.node_list["IconImg"]:SetActive(true)
		self.node_list["ItemNameTxt"].text.text = ""
	end

	local item_cfg = ShenYinData.Instance:GetMarkSlotInfo()
	local item_data = item_cfg[data.imprint_slot]

	self.display:SetStarLevel(item_data.grade * 10 + item_data.level)

	self.node_list["PlaceNameTxt"].text.text = (string.format(Language.Rank.WingGrade, item_data.grade,item_data.level))
	self:SetShowUp()
end

function ShenYinQiangHuaItemCell:SetFromView(view_type)
	self.from_view = view_type
end

function ShenYinQiangHuaItemCell:SetShowUp()
	if 1 == self.from_view then
		self.node_list["UpArrow"]:SetActive(1 == ShenYinData.Instance:GetHasShenYinXiLianRedPointBySlot(self.data.imprint_slot))
		self:AnimLoop(1 == ShenYinData.Instance:GetHasShenYinXiLianRedPointBySlot(self.data.imprint_slot))
	elseif 0 == self.from_view then
		local item_cfg = ShenYinData.Instance:GetMarkSlotInfo()
		local item_data = item_cfg[self.data.imprint_slot]
		local up_star_cfg = ShenYinData.Instance:GetUpStarCFG(self.data.imprint_slot, item_data.grade, item_data.level)
		local max_cfg = ShenYinData.Instance:GetShenYinQiangHuaMax()
		if max_cfg and up_star_cfg then
			local is_max_level = item_data.grade >= max_cfg.stage and item_data.level >= max_cfg.level
			local is_active = ItemData.Instance:GetItemNumInBagById(up_star_cfg.consume_v_item_id) >= up_star_cfg.need_num and not is_max_level
			self.node_list["UpArrow"]:SetActive(is_active)
			self:AnimLoop(is_active)
		end
	end

end
function ShenYinQiangHuaItemCell:AnimLoop(active)
	if self.anim_obj and active then 
		UITween.AddChildMoveLoop(self.node_list["UpArrow"], self.anim_obj)
	else
		UITween.ReduceChildMoveLoop(self.node_list["UpArrow"], self.anim_obj)
	end
end
function ShenYinQiangHuaItemCell:OnClickTip()
	self.display:ShowHighLight(false)
	ShenYinCtrl.Instance:OpenYinJiTip(self.data, ShenYinYinJiTipView.FromView.ShenYinStrength)
end