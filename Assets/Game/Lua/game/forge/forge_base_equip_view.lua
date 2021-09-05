ForgeBaseEquip = ForgeBaseEquip or BaseClass(BaseRender)

--服务端要求 1是自动购买 0是取消自动购买
local AUTO_BUY_TAB_INDEX = {
	AUTO_BUY = 1,
	CANCEL_AUTO_BUY = 0,
}

--继承锻造的基础面板
function ForgeBaseEquip:__init()
	self.node_list["BtnUpQuality"].button:AddClickListener(BindTool.Bind(self.OnClickUpQuality,self))
	self.node_list["CellLuckItemCell"].button:AddClickListener(BindTool.Bind(self.OnClickUseLuckyItem,self))
	self.node_list["ToggleLevel"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickLevel, self))
	self.node_list["ToggleQuality"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickQuality,self))
	self.node_list["ToggleAutoBuy"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickAutoBuy,self))
	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.OnClickUpLevel,self))

	--升品需要的材料
	local up_quality_stuff_obj = self.node_list["CellUpQualityStuff"]
	self.up_quality_stuff = ItemCellReward.New()
	self.up_quality_stuff:SetInstanceParent(up_quality_stuff_obj)
	--升级需要的材料
	local up_lv_stuff_obj = self.node_list["CellUpLvStuff"]
	self.up_level_stuff = ItemCellReward.New()
	self.up_level_stuff:SetInstanceParent(up_lv_stuff_obj)

	--状态格子
	local current_cell_obj = self.node_list["CellCurrentItem"]
	self.current_cell = ItemCell.New()
	self.current_cell:SetInstanceParent(current_cell_obj)

	local next_cell = self.node_list["CellNextItem"]
	self.next_cell = ItemCell.New()
	self.next_cell:SetInstanceParent(next_cell)
	self.current_attr_list = {}
	self.next_attr_list = {}

	--左边拖动条的数据存储列表
	self.quality_cell_list = {}
	self.level_cell_list = {}

	--状态类的个数
	local count = self.node_list["NodeCurrentAttr"].transform.childCount
	local next_count = self.node_list["NodeNextAttr"].transform.childCount

	for i = 0,count-1 do
		local attr_obj = self.node_list["NodeCurrentAttr"].transform:GetChild(i).gameObject
		local attr = AttrBaseCell.New(attr_obj)
		table.insert(self.current_attr_list,attr)
	end

	for i = 0, next_count-1 do
		local attr_obj = self.node_list["NodeNextAttr"].transform:GetChild(i).gameObject
		local attr = AttrBaseCell.New(attr_obj)
		table.insert(self.next_attr_list,attr)
	end
	--是否第一次打开面板
	self.first_open_level_view = true
	self.first_open_quality_view = true

	self.is_auto_buy = AUTO_BUY_TAB_INDEX.CANCEL_AUTO_BUY

	self.quality_scroller_data = nil
	self.level_scroller_data = nil
	-- 选择的数据,用于给forgebase传数据使用
	self.select_equip_data = nil
	--用于保存标签切换时候的临时索引
	self.select_level_equip_index = -1
	self.select_quality_equip_index = -1
	--等级提升 为0  品质提升为 1
	self.select_type = -1

	self.node_list["BtnLevelSuit"]:SetActive(true)	
	self.node_list["BtnQualitySuit"]:SetActive(false)
	self.node_list["NodeQualityStuff"]:SetActive(false)
	self.node_list["ImgQualityMaxTips"]:SetActive(false)
	self.node_list["ImgLevelMaxTips"]:SetActive(false)
	self.node_list["NodeUpAfterAttr"]:SetActive(false)
	--初始化toggle
	self:FritsFlushView()
	self:InitScroller()
	self:InitToggle()
	self:FirstSelectToggle()
	
end

function ForgeBaseEquip:FirstSelectToggle()
	if self.level_scroller_data[1] then
		self.select_level_equip_index = 1
	end

	if self.quality_scroller_data[1] then
		self.select_quality_equip_index = 1
	end

	self:AttrFlush()
end

function ForgeBaseEquip:__delete()
	self.level_cell_list = {}
	self.quality_cell_list = {}
	self.current_cell = nil
	for k,v in pairs(self.current_attr_list) do
		v:DeleteMe()
	end
	self.current_attr_list = {}
	for k,v in pairs(self.next_attr_list) do
		v:DeleteMe()
	end
	self.next_attr_list = {}

	if self.up_quality_stuff then
		self.up_quality_stuff:DeleteMe()
		self.up_quality_stuff = nil
	end

	if self.up_level_stuff then
		self.up_level_stuff:DeleteMe()
		self.up_level_stuff = nil
	end

	if self.current_cell then
		self.current_cell:DeleteMe()
		self.current_cell = nil
	end

	if self.next_cell then
		self.next_cell:DeleteMe()
		self.next_cell = nil
	end	
	
	if self.select_equip_data then
		self.up_quality_stuff = nil
	end
end

function ForgeBaseEquip:InitView(open_view)
	--决定显示哪一个版块
	if open_view then
		self.node_list["NodeLevelBottom"]:SetActive(true)
		self.node_list["NodeQualityBottom"]:SetActive(false)
		self.node_list["BtnQualitySuit"]:SetActive(false)
		self.node_list["BtnLevelSuit"]:SetActive(true)
		self.node_list["ScrollerLevel"]:SetActive(true)
		self.node_list["ScrollerQuality"]:SetActive(false)
	else
		self.node_list["NodeLevelBottom"]:SetActive(false)
		self.node_list["NodeQualityBottom"]:SetActive(true)
		self.node_list["BtnQualitySuit"]:SetActive(true)
		self.node_list["BtnLevelSuit"]:SetActive(false)
		self.node_list["ScrollerLevel"]:SetActive(false)
		self.node_list["ScrollerQuality"]:SetActive(true)
	end
end

--强化后回调该函数
function ForgeBaseEquip:OnFlush()
	if self.select_equip_data and self.node_list["ToggleLevel"].toggle.isOn then
		--用于选择保护符个数后刷新界面的成功率
		self:FlushSuccedRate()
	end
	self:FritsFlushView()
	self:FlushCell()
	self:AttrFlush()
	self:StuffFlush()
	self:FlushRedPoint()
end

function ForgeBaseEquip:FlushRedPoint()
	self.node_list["ImgLevelRemind"]:SetActive(ForgeData.Instance:IsShowBaseEquipToggleRedPoint(ForgeData.BASEEQUIPTAG.LEVEL))
	self.node_list["ImgQualityRemind"]:SetActive(ForgeData.Instance:IsShowBaseEquipToggleRedPoint(ForgeData.BASEEQUIPTAG.QUALITY))
end

function ForgeBaseEquip:FlushSuccedRate()
	local select_equip_cfg = ForgeData.Instance:GetBaseEquipLevelData(self.select_equip_data.item_id)

	if nil == select_equip_cfg then
		return
	end

	local all_succeed_rate = self:GetAllSucceedRate(select_equip_cfg)

	if nil == all_succeed_rate then
		self.node_list["TxtSuccessRate"].text.text = ""
		return
	end

	local all_succeed_rate_str = string.format(Language.Forge.SucceedRate,all_succeed_rate)
	self.node_list["TxtSuccessRate"].text.text = all_succeed_rate_str
end

function ForgeBaseEquip:OnClickLevel()
	self:InitView(true)
	self:FritsFlushView()
	self:FlushCell()
	self:AttrFlush()
	self:StuffFlush()
end

function ForgeBaseEquip:OnClickQuality()
	self:InitView(false)
	self:FritsFlushView()
	self:FlushCell()
	self:AttrFlush()
	self:StuffFlush()
end

--服务端的数据匹配 1为自动购买  0为取消该自动购买
function ForgeBaseEquip:OnClickAutoBuy()
	self.is_auto_buy = self.is_auto_buy == AUTO_BUY_TAB_INDEX.AUTO_BUY and AUTO_BUY_TAB_INDEX.CANCEL_AUTO_BUY or AUTO_BUY_TAB_INDEX.AUTO_BUY
end

--请求升级品质
function ForgeBaseEquip:OnClickUpQuality()
	if self.select_equip_data then
		ForgeCtrl.Instance:SendUpQualityReq(self.select_equip_data.index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
	end
end

--使用幸运符的格子
function ForgeBaseEquip:OnClickUseLuckyItem()
	if nil == self.select_equip_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	local up_level_cfg = ForgeData.Instance:GetBaseEquipLevelData(self.select_equip_data.item_id)

	if nil == up_level_cfg then
		return
	end
	--如果背包没有这个道具,则弹出获取途径
	local last_item_num = ItemData.Instance:GetItemNumIsEnough(up_level_cfg.lucky_stuff_id,1)

	if last_item_num then
		local data = {}
		data.item_id = up_level_cfg.lucky_stuff_id
		data.add_succeed_rate = up_level_cfg.lucky_add_rate
		data.equip_id = self.select_equip_data.item_id
		TipsCtrl.Instance:ShowUseLuckyItemView(data)
	else
		TipsCtrl.Instance:ShowItemGetWayView(up_level_cfg.lucky_stuff_id)
	end
end

function ForgeBaseEquip:OnClickUpLevel()
	--如果没有选装备
	if nil == self.select_equip_data then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end

	local select_data_cfg  = ForgeData.Instance:GetBaseEquipLevelData(self.select_equip_data.item_id)

	if nil == select_data_cfg then
		return
	end

	local has_num = ItemData.Instance:GetItemNumInBagById(select_data_cfg.stuff_id)
	local need_num = select_data_cfg.stuff_count

	if has_num < need_num and self.is_auto_buy == AUTO_BUY_TAB_INDEX.CANCEL_AUTO_BUY then
		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use,is_buy_quick)
			--勾选自动购买
			if is_buy_quick then
				self.node_list["ToggleAutoBuy"].toggle.isOn = true
				self.is_auto_buy = AUTO_BUY_TAB_INDEX.AUTO_BUY
			end
		end
		need_num = need_num - has_num
		TipsCtrl.Instance:ShowCommonBuyView(func, select_data_cfg.stuff_id, nil, need_num)
		return
	end

	--发送强化请求
	local send_data = {}
	send_data.equip_index = self.select_equip_data.index
	send_data.is_auto_buy = self.is_auto_buy
	local use_lucky_num = ForgeData.Instance:GetLevelUpLuckyItemUseNum()
	--服务端要求 use_lucky_item 数量大于0为使用 0为不使用
	if use_lucky_num > 0 then
		send_data.use_lucky_item_num = use_lucky_num
	else
		send_data.use_lucky_item_num = 0
	end
	ForgeCtrl.Instance:SendUpLevelReq(send_data)
	ForgeData.Instance:SetLevelUpLuckyItemUseNum(0)
end

function ForgeBaseEquip:InitToggle()
	self.node_list["ToggleLevel"].toggle.isOn = true
	if self.node_list["ToggleLevel"].toggle.isOn then
		self.node_list["NodeLevelBottom"]:SetActive(true)
		self.node_list["NodeQualityBottom"]:SetActive(false)
	end
end

function ForgeBaseEquip:InitScroller()
	local quality_list_view_delegate = ListViewDelegate()
	local level_list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "cell_res_async_loader")
	res_async_loader:Load("uis/views/forgeview_prefab", "BaseEquipCell", nil,
		function(obj)
			if nil == obj then
				return
			end

			self.enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))

			self.node_list["ScrollerQuality"].scroller.Delegate = quality_list_view_delegate
			quality_list_view_delegate.numberOfCellsDel =  BindTool.Bind(self.GetNumberOfQualityCells, self)
			quality_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
			quality_list_view_delegate.cellViewDel = BindTool.Bind(self.GetQualityCell, self)

			self.node_list["ScrollerLevel"].scroller.Delegate = level_list_view_delegate
			level_list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfLevelCells, self)
			level_list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
			level_list_view_delegate.cellViewDel = BindTool.Bind(self.GetLevelCell, self)
		end
	)

	self.node_list["ScrollerQuality"]:SetActive(false)
end

--根据装备的数量来生成格子的数量
function ForgeBaseEquip:GetNumberOfQualityCells(...)
	if self.quality_scroller_data then
		return #self.quality_scroller_data
	else
		return 0
	end
end

function ForgeBaseEquip:GetNumberOfLevelCells(...)
	if self.level_scroller_data then
		return #self.level_scroller_data 
	else
		return 0
	end
end

--格子的大小
function ForgeBaseEquip:GetCellSize()
	return 110
end

--滚动条的刷新
function ForgeBaseEquip:GetQualityCell(scroller,data_index,cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local scroller_cell = self.quality_cell_list[cell]

	if scroller_cell == nil then
		self.quality_cell_list[cell] = BaseEquipCell.New(cell.gameObject)
		scroller_cell = self.quality_cell_list[cell]
		scroller_cell.mother_view = self
		scroller_cell.root_node.toggle.group = self.node_list["ScrollerQuality"].toggle_group
	end

	self.quality_scroller_data[data_index].cell_index = data_index
	scroller_cell:SetIndex(data_index)
	scroller_cell:SetData(self.quality_scroller_data[data_index])
	return cell
end

function ForgeBaseEquip:GetLevelCell(scroller,data_index,cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local scroller_cell = self.level_cell_list[cell]

	if scroller_cell == nil then
		self.level_cell_list[cell] = BaseEquipLevelCell.New(cell.gameObject)
		scroller_cell = self.level_cell_list[cell]
		scroller_cell.mother_view = self
		scroller_cell.root_node.toggle.group = self.node_list["ScrollerLevel"].toggle_group
	end

	self.level_scroller_data[data_index].cell_index = data_index
	scroller_cell:SetIndex(data_index)
	scroller_cell:SetData(self.level_scroller_data[data_index])
	return cell
end

--刷新格子
function ForgeBaseEquip:FlushCell()
	if self.node_list["ScrollerQuality"] then
		self.node_list["ScrollerQuality"].scroller:ReloadData(0)
	end

	if self.node_list["ScrollerLevel"] then
		self.node_list["ScrollerLevel"].scroller:ReloadData(0)
	end
end

function ForgeBaseEquip:SetQualityScrollerData(data)
	self.quality_scroller_data = data
end

function ForgeBaseEquip:SetLevelScrollerData(data)
	self.level_scroller_data = data
end

function  ForgeBaseEquip:FritsFlushView()
	--获取装备
	local temp_equip_list_data  = ForgeData.Instance:ReorderEquipList()
	--根据等级品质的标签来确定显示的列表,只取与配表中一样的装备
	local temp_level_equip_data = ForgeData.Instance:GetLevelUpBaseEquip(temp_equip_list_data)
	self:SetQualityScrollerData(temp_equip_list_data)
	self:SetLevelScrollerData(temp_level_equip_data)

	local use_num = ForgeData.Instance:GetLevelUpLuckyItemUseNum()
	local use_str = string.format(Language.Forge.LuckyItemUseTips,use_num)
	local had_luck_item_num = 0

	self.node_list["TxtUseLuckyItemNum"].text.text = use_str

	if temp_level_equip_data  then
		self.node_list["NodeShowLuck"]:SetActive(true)
	else
		self.node_list["NodeShowLuck"]:SetActive(false)
		return
	end

	--幸运符格子的刷新
 	if temp_level_equip_data[1] then
 		local equip_id = temp_level_equip_data[1].item_id
 		--获得幸运符id
 		local level_equip_cfg = ForgeData.Instance:GetBaseEquipLevelData(equip_id)
 		if level_equip_cfg then
 			lucky_item_id = level_equip_cfg.lucky_stuff_id
 			had_luck_item_num = ItemData.Instance:GetItemNumInBagById(lucky_item_id)
 		else
 			self.node_list["NodeShowLuck"]:SetActive(false)
 		end
	end

	self:LuckyItemCellState(had_luck_item_num, use_num)
end


function ForgeBaseEquip:SelectToggleFlush(data,cell_index)
	ForgeData.Instance:SetLevelUpLuckyItemUseNum(0)

	local use_num = ForgeData.Instance:GetLevelUpLuckyItemUseNum()
	local use_str = string.format(Language.Forge.LuckyItemUseTips,use_num)
	self.node_list["TxtUseLuckyItemNum"].text.text = use_str

	if data and self.node_list["ToggleLevel"].toggle.isOn then
		local equip_id = data.item_id
 		local level_equip_cfg = ForgeData.Instance:GetBaseEquipLevelData(equip_id)
 		--获得幸运符id
 		if level_equip_cfg then
 			lucky_item_id = level_equip_cfg.lucky_stuff_id
 			had_luck_item_num = ItemData.Instance:GetItemNumInBagById(lucky_item_id)
 		else
 			self.node_list["NodeShowLuck"]:SetActive(false)
 		end
 		self:LuckyItemCellState(had_luck_item_num, use_num)
 	end	

	if self.node_list["ToggleLevel"].toggle.isOn and data then
		self.select_level_equip_index = cell_index
	elseif self.node_list["ToggleQuality"].toggle.isOn and data then
		self.select_quality_equip_index = cell_index
	end

	self:AttrFlush()
	self:StuffFlush()
end

--显示幸运符的状态的状态
function ForgeBaseEquip:LuckyItemCellState(had_luck_item_num, use_num)
	if had_luck_item_num == 0 then
		self.node_list["TxtUseLuckyItemNum"]:SetActive(false)
		self.node_list["ImgLock"]:SetActive(true)
		self.node_list["ImgPlus"]:SetActive(false)
		self.node_list["ImgLuckyItemIcon"]:SetActive(false)
	elseif use_num > 0 then
		self.node_list["TxtUseLuckyItemNum"]:SetActive(true)
		self.node_list["ImgLuckyItemIcon"]:SetActive(true)
		self.node_list["ImgLock"]:SetActive(false)
		self.node_list["ImgPlus"]:SetActive(false)
	elseif use_num == 0 then
		self.node_list["TxtUseLuckyItemNum"]:SetActive(true)
		self.node_list["ImgLuckyItemIcon"]:SetActive(false)
		self.node_list["ImgLock"]:SetActive(false)
		self.node_list["ImgPlus"]:SetActive(true)
	end
end

--刷新状态以及战力信息
function ForgeBaseEquip:AttrFlush()
	local data = nil
	-----提升等级-----
	if self.node_list["ToggleLevel"].toggle.isOn then
		if self.select_level_equip_index > 0 then
			data = self.level_scroller_data[self.select_level_equip_index]
			self.node_list["NodeUpAfterAttr"]:SetActive(true)
			self.node_list["CellCurrentItem"]:SetActive(true)
			self.node_list["CellNextItem"]:SetActive(true)
			self.node_list["NodeCurrentAllAttr"]:SetActive(true)
		else
			self:ShowEmpty()
			return
		end

		if nil == data then
			return
		end
		self.select_equip_data = data
		self:SetLevelAttr(data)
	end
	-----提升品质-----
	if self.node_list["ToggleQuality"].toggle.isOn then
		if self.select_quality_equip_index > 0 then
			data = self.quality_scroller_data[self.select_quality_equip_index]
			self.node_list["NodeUpAfterAttr"]:SetActive(true)
			self.node_list["CellCurrentItem"]:SetActive(true)
			self.node_list["CellNextItem"]:SetActive(true)
			self.node_list["NodeCurrentAllAttr"]:SetActive(true)
		else
			self:ShowEmpty()
			return
		end

		if nil == data then
			return
		end
		self.select_equip_data = data
		self:SetQualityAttr(data)
	end
end

function ForgeBaseEquip:ShowEmpty()
	self.node_list["TxtUpBeforeLv"].text.text = ""
	self.node_list["TxtNameBefore"].text.text = ""
	self.node_list["TxtUpAfterLv"].text.text = ""
	self.node_list["TxtAfterName"].text.text = ""
	self.node_list["CellCurrentItem"]:SetActive(false)
	self.node_list["NodeCurrentAllAttr"]:SetActive(false)
	self.node_list["CellNextItem"]:SetActive(false)
	self.node_list["NodeUpAfterAttr"]:SetActive(false)
end

function ForgeBaseEquip:SetQualityAttr(data)
	local fight_power,attribute,count,quality = self:GetQualityAndAttr(data,true)
	self.node_list["TxtLeftFightPowerNum"].text.text = fight_power

	for k,v in pairs(self.current_attr_list) do
		self.current_attr_list[k].attr.text.text = ""
	end
	--提升品质对当前状态格子进行赋值
	for i = 1, count-1 do
		self.current_attr_list[i].attr.text.text = attribute[i]
	end

	local current_quality_name = quality.pre .. "·" .. Language.Forge.BaseEquipStartNum[quality.star_num]
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.node_list["TxtUpBeforeLv"].text.text = current_quality_name
	self.node_list["TxtUpQualityBtn"].text.text = Language.Forge.BtnEnable
	UI:SetButtonEnabled(self.node_list["BtnUpQuality"], true)

	if nil == item_cfg then
		return
	end

	self.current_cell:SetData(data)
	self.current_cell:SetShowStar(quality.star_num)
	self.node_list["TxtNameBefore"].text.text = item_cfg.name
	self.node_list["TxtAfterName"].text.text = item_cfg.name
	--判断有没有满级
	local is_can_up = ForgeData.Instance:GetIsCanUpEquipQuality(data)
	self.next_cell:SetData(data)
	--未满级
	self.node_list["NodeQualityStuff"]:SetActive(is_can_up)
	self.node_list["ImgQualityMaxTips"]:SetActive(not is_can_up)
	self.node_list["NodeUpAfterAttr"]:SetActive(is_can_up)
	UI:SetButtonEnabled(self.node_list["BtnUpQuality"], is_can_up)

	if not is_can_up then
		self.node_list["TxtUpQualityBtn"].text.text = Language.Forge.BtnDisable
		UI:SetButtonEnabled(self.node_list["BtnUpQuality"], false)
		self.node_list["TxtUpAfterLv"].text.text = current_quality_name
		self.next_cell:SetShowStar(quality.star_num)
		return 
	end

	---提升品质如果和上面的data同一个索引,会把data的quality也加上去
	local temp_data = TableCopy(data)
	temp_data.param.quality = temp_data.param.quality + 1

	local fight_power_after,attribute_after,count_after,quality_after = self:GetQualityAndAttr(temp_data,true)
	local next_quality_name = quality_after.pre .. "·" .. Language.Forge.BaseEquipStartNum[quality_after.star_num]

	self.node_list["TxtUpAfterLv"].text.text = next_quality_name
	self.node_list["TxtUpAfterPower"].text.text = fight_power_after
	self.next_cell:SetShowStar(quality_after.star_num)

	for k,v in pairs(self.next_attr_list) do
		self.next_attr_list[k].attr.text.text = ""
	end

	for i = 1, count_after-1 do
		self.next_attr_list[i].attr.text.text = attribute_after[i]
	end	
end

function ForgeBaseEquip:SetLevelAttr(data)	
	local fight_power,attribute,count = self:GetQualityAndAttr(data,false)
	self.node_list["TxtLeftFightPowerNum"].text.text = fight_power

	for k,v in pairs(self.current_attr_list) do
		self.current_attr_list[k].attr.text.text = ""
	end

	--提升等级对当前状态格子进行赋值
	for i = 1, count-1 do
		self.current_attr_list[i].attr.text.text = attribute[i]
	end

	local toponym = Language.Forge.EquipName[data.index]
	local equip_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[data.item_id]
	local order = Language.Forge.EquipOrder[equip_cfg.order]

	self.node_list["TxtUpBeforeLv"].text.text = order .. "·" .. toponym 
	self.node_list["TxtBtnUpLv"].text.text = Language.Forge.BtnEnable
	UI:SetButtonEnabled(self.node_list["BtnUpLevel"], true)

	local up_level_cfg = ForgeData.Instance:GetBaseEquipLevelData(data.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)

	if nil == up_level_cfg and  nil == item_cfg then
		return
	end

	self.current_cell:SetData(data)
	self.node_list["TxtNameBefore"].text.text = item_cfg.name
	--获得下一阶的物品
	local temp_data = TableCopy(data)
	temp_data.item_id = up_level_cfg.new_equip_id
	local is_can_up = ForgeData.Instance:GetIsCanUpEquipLevel(temp_data)

	self.node_list["NodeQualityStuff"]:SetActive(is_can_up)
	self.node_list["NodeUpLevelDes"]:SetActive(is_can_up)
	self.node_list["ImgLevelMaxTips"]:SetActive(not is_can_up)
	self.node_list["NodeUpAfterAttr"]:SetActive(is_can_up)
	UI:SetButtonEnabled(self.node_list["BtnUpLevel"], is_can_up)
	--是否满级了
	if not is_can_up then 
		self.node_list["TxtBtnUpLv"].text.text = Language.Forge.BtnDisable
		self.node_list["TxtAfterName"].text.text = item_cfg.name
		self.node_list["TxtUpAfterLv"].text.text = order .. "·" .. toponym
		self.next_cell:SetData(data)
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"],is_can_up)
		return
	end	

	local next_data_cfg = ItemData.Instance:GetItemConfig(temp_data.item_id)

	if nil == next_data_cfg then
		return
	end

	local next_name = next_data_cfg.name
	self.node_list["TxtAfterName"].text.text = next_name
	self.next_cell:SetData(temp_data)
	local next_order = Language.Forge.EquipOrder[next_data_cfg.order]
	self.node_list["TxtUpAfterLv"].text.text = next_order .. "·" .. toponym	


	local fight_power_next,attribute_next,count_next = self:GetQualityAndAttr(temp_data)
	self.node_list["TxtUpAfterPower"].text.text = fight_power_next

	for k,v in pairs(self.next_attr_list) do
		self.next_attr_list[k].attr.text.text = ""
	end

	for i = 1, count_next-1 do
		self.next_attr_list[i].attr.text.text = attribute_next[i]
	end	

	local all_succeed_rate = self:GetAllSucceedRate(up_level_cfg)

	if not all_succeed_rate then
		self.node_list["TxtSuccessRate"].text.text = ""
		return
	end

	local succeed_rate = string.format(Language.Forge.SucceedRate,all_succeed_rate)
	self.node_list["TxtSuccessRate"].text.text = succeed_rate
	local lucky_img_asset,lucky_img_bundle = ResPath.GetItemIcon(up_level_cfg.lucky_stuff_id)
	self.node_list["ImgLuckyItemIcon"].image:LoadSprite(lucky_img_asset,lucky_img_bundle)
end

--基础装总成功率
function ForgeBaseEquip:GetAllSucceedRate(select_data_cfg)
	if not select_data_cfg then
		return
	end

	local equip_data_cfg = select_data_cfg
	local base_succeed_rate = equip_data_cfg.base_succ_rate
	local lucky_item_num = ForgeData.Instance:GetLevelUpLuckyItemUseNum()
	local add_succeed_rate = equip_data_cfg.lucky_add_rate * lucky_item_num
	local all_succeed_rate = base_succeed_rate + add_succeed_rate

	all_succeed_rate = all_succeed_rate >= 100 and 100 or all_succeed_rate
	return all_succeed_rate
end

--传装备数据进来,升级前后两边公用,获得基础装品质的配表信息,attr信息,是否is_next取得下一品的属性
function ForgeBaseEquip:GetQualityAndAttr(data,is_quality_attr)
	--获得配表信息
	local quality_list = ForgeData.Instance:GetBaseEquipQualityData(data.index,data.param.quality)  
	local attr_list,fight_power = ForgeData.Instance:GetEquipAttrAndPower(data,FORGE_TYPE.BASEEQUIP,is_quality_attr)
	--筛选掉值为0的数据
	local attribute = {}
	local count = 1
	for k,v in pairs(attr_list) do
		if v > 0 then
			attribute[count] = k .. "：<color=white>" .. v .. "</color>"
			count = count + 1 
		end
	end
	--返回配表的质量,战力,状态列表,以及attr状态个数(不包括战力)
	return fight_power,attribute,count,quality_list
end

--刷新使用材料
function ForgeBaseEquip:StuffFlush()
	--获取锻造配表信息
	if nil == self.select_equip_data then
		return
	end
	local data = self.select_equip_data

	if self.node_list["ToggleQuality"].toggle.isOn then 
		local quality_cfg = ForgeData.Instance:GetBaseEquipQualityData(data.index,data.param.quality)

		if nil == quality_cfg then
			return
		end

		local quality_data = {}
		quality_data.item_id = quality_cfg.stuff_id
		self.up_quality_stuff:SetData(quality_data)
		local up_quality_need_num = quality_cfg.stuff_count or 0
		local up_quality_has_num = ItemData.Instance:GetItemNumInBagById(quality_data.item_id) or 0
		local up_quality_stuff_num_str = up_quality_has_num .. "/" .. up_quality_need_num

		up_quality_stuff_num_str = up_quality_has_num >= up_quality_need_num and
		ToColorStr(up_quality_stuff_num_str, COLOR.GREEN) or ToColorStr(up_quality_stuff_num_str, COLOR.RED)

		self.node_list["TxtConsumeNum"].text.text = up_quality_stuff_num_str
	end

	if self.node_list["ToggleLevel"].toggle.isOn then
		local up_level_cfg = ForgeData.Instance:GetBaseEquipLevelData(data.item_id)
		if nil == up_level_cfg then
			return
		end
		local level_data = {}
		level_data.item_id = up_level_cfg.stuff_id
		self.up_level_stuff:SetData(level_data)
		local up_level_need_num = up_level_cfg.stuff_count
		local up_level_has_num = ItemData.Instance:GetItemNumInBagById(level_data.item_id)
		local up_level_stuff_num_str = up_level_has_num .. "/" .. up_level_need_num

		up_level_stuff_num_str = up_level_has_num >= up_level_need_num and 
		ToColorStr(up_level_stuff_num_str, COLOR.GREEN) or ToColorStr(up_level_stuff_num_str, COLOR.RED)

		self.node_list["TxtUpLvStuffNum"].text.text = up_level_stuff_num_str
	end
end

------------------------------BaseEquipCell-------------------------------------
---------------------------基础装备品质的格子------------------------------------
BaseEquipCell = BaseEquipCell or BaseClass(BaseCell)

function BaseEquipCell:__init()
	self.data = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])	
	self.root_node.toggle:AddClickListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function BaseEquipCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function BaseEquipCell:SetData(data)
	if not next(data) or nil == data.item_id then
		return
	end
	if self:GetIndex() == self.mother_view.select_quality_equip_index and self.mother_view.first_open_quality_view then
		self.root_node.toggle.isOn = true
		self.mother_view.first_open_quality_view = false
	end

	local is_can_up = ForgeData.Instance:GetIsCanUpEquipQuality(data)
	self.node_list["UpArrow"]:SetActive(is_can_up)

	local quality_equip_cfg = ForgeData.Instance:GetBaseEquipQualityData(data.index,data.param.quality)
	local is_can_up = ForgeData.Instance:GetIsCanUpEquipQuality(data)
	if is_can_up and quality_equip_cfg then
		local quality_stuff_id = quality_equip_cfg.stuff_id
		local need_stuff_num = quality_equip_cfg.stuff_count
		local had_stuff_num = ItemData.Instance:GetItemNumInBagById(quality_stuff_id)
		--提升等级的格子获取材料信息
		local is_enough_stuff = had_stuff_num >= need_stuff_num
		self.node_list["UpArrow"]:SetActive(is_can_up and is_enough_stuff)
	else
		self.node_list["UpArrow"]:SetActive(is_can_up)
	end

	self.data = data
	self.item_cell:SetData(self.data)
	--设置物品的星级
	self.item_cell:SetShowStar(quality_equip_cfg.star_num)
	self:Flush()
end

function BaseEquipCell:OnFlush()
	local quality_cfg = ForgeData.Instance:GetBaseEquipQualityData(self.data.index,self.data.param.quality)

	if nil == quality_cfg then
		return
	end

	local quality_in_data = quality_cfg.pre .. "·" .. Language.Forge.BaseEquipStartNum[quality_cfg.star_num]
	self.node_list["TxtClassName"].text.text = quality_in_data 
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_list["TxtName"].text.text = item_cfg.name
end

function BaseEquipCell:OnToggleValueChange()
 	self.mother_view:SelectToggleFlush(self.data,self:GetIndex())
end

------------------------------BaseEquipLevelCell-------------------------------------
-------------------------------提升等级的格子----------------------------------------
BaseEquipLevelCell = BaseEquipLevelCell or BaseClass(BaseCell)

function BaseEquipLevelCell:__init()
	self.data = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.root_node.toggle:AddClickListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function BaseEquipLevelCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function BaseEquipLevelCell:SetData(data)
	if not next(data) or nil == data.item_id then
		return
	end

	if self:GetIndex() == self.mother_view.select_level_equip_index and self.mother_view.first_open_level_view then
		self.root_node.toggle.isOn = true
		self.mother_view.first_open_level_view = false
	end

	local level_equip_cfg = ForgeData.Instance:GetBaseEquipLevelData(data.item_id)
	local temp_data = {}

	if nil == level_equip_cfg then
		return
	end

	temp_data.item_id = level_equip_cfg.new_equip_id
	local is_can_up = ForgeData.Instance:GetIsCanUpEquipLevel(temp_data)

	if is_can_up then
		local level_stuff_id = level_equip_cfg.stuff_id
		local need_stuff_num = level_equip_cfg.stuff_count
		local had_stuff_num = ItemData.Instance:GetItemNumInBagById(level_stuff_id)
		local is_enough_stuff = had_stuff_num >= need_stuff_num
		self.node_list["UpArrow"]:SetActive(is_can_up and is_enough_stuff)
	else
		self.node_list["UpArrow"]:SetActive(is_can_up)
	end

	self.data = data
	self.item_cell:SetData(self.data)
	self:Flush()
end

function BaseEquipLevelCell:OnFlush()
	--服务端传来数据,id1101后没有item_cfg参数
	local equip_cfg = ConfigManager.Instance:GetAutoItemConfig("equipment_auto")[self.data.item_id]

	if equip_cfg then
		local toponym = Language.Forge.EquipName[self.data.index]
		local order = Language.Forge.EquipOrder[equip_cfg.order]
		self.node_list["TxtClassName"].text.text = order .. "·" .. toponym
		self.node_list["TxtName"].text.text = equip_cfg.name
	end
end

function BaseEquipLevelCell:OnToggleValueChange()
 	self.mother_view:SelectToggleFlush(self.data,self:GetIndex())
end

------------------------------AttrBaseCell---------------------------------------------------------
----------------------------状态类的格子,,继承ForgeBaseCell----------------------------------------
--不要相信策划说的装备状态的个数,变化很大,每个状态绑定一个text
AttrBaseCell = AttrBaseCell or BaseClass(BaseCell)

function AttrBaseCell:__init()
	self.attr = self.node_list["TxtAttr"]
end



