ShengXiaoEquipView = ShengXiaoEquipView or BaseClass(BaseRender)

local Defult_Icon_List = {
	27001, 27002, 27003, 27004, 27005
}
local HIDE_NUM = 7
local MOVE_TIME = 0.5
local BAG_MAX_GRID_NUM = 100
local COLUMN_NUM = 4
local ROW_NUM = 5
local BAG_PAGE_COUNT = 20
function ShengXiaoEquipView:UIsMove()
	UITween.MoveShowPanel(self.node_list["Right1"], Vector3(600, 0, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right2"], Vector3(0, 200, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["DownContent"], Vector3(self.node_list["DownContent"].transform.localPosition.x, -440, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-106, -37, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleDown"], Vector3(0, -200, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["RightBagPanel"], Vector3(420, -26, 0), MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleUp"], Vector3(69, -48, 0 ), MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["MiddleUp"], true, MOVE_TIME, DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["MiddleUpBg"], Vector3(0.7, 0.7, 0.7), MOVE_TIME)
end

function ShengXiaoEquipView:__init()
	self.equip_bag_cells = {}
	local list_delegate = self.node_list["PageView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBagNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.EquipBagRefreshCell, self)

	self.cell_list = {}
	local list_delegate = self.node_list["ShengXiaoList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.equip_up_t = {}
	self.equip_list = {}
	for i = 1, 5 do
		self.equip_list[i] = ShengXiaoEquipCell.New()
		self.equip_list[i]:SetInstanceParent(self.node_list["EquipCell" .. i])
		self.equip_list[i]:IgnoreArrow(true)
		-- self.equip_list[i]:ListenClick(BindTool.Bind(self.ClickEquipItem, self, i))
		self.equip_list[i].parent_view = self
		self.equip_up_t[i] = self.node_list["Improve" .. i]
		-- self.equip_up_t[i].transform.parent.transform:SetAsLastSibling()
	end

	self.cur_equip_cell = ShengXiaoEquipCell.New()
	self.cur_equip_cell:SetInstanceParent(self.node_list["CurEquip"])
	self.cur_equip_cell:IgnoreArrow(true)
	self.cur_equip_cell:SetIsShowTips(true)
	self.cur_equip_cell:ShowHighLight(true)
	self.cur_equip_cell.parent_view = self

	self.node_list["BtnUpLevel"].button:AddClickListener(BindTool.Bind(self.ClickLevelUp, self))
	self.node_list["BtnLeftArrows"].button:AddClickListener(BindTool.Bind(self.OnClickListLeft, self))
	self.node_list["BtnRightArrows"].button:AddClickListener(BindTool.Bind(self.OnClickListRight, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnSuit"].button:AddClickListener(BindTool.Bind(self.OnClickSuit, self))
	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.OnClickFenJie, self))
	
	-- self.attr_cell_list = {}
	-- local list_delegate = self.node_list["AttrList"].list_simple_delegate
	-- list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	-- list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtPower"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["TxtPower2"])

	self.equip_index = self.equip_index or 1
	self.list_index = self.list_index or 1

	self.data_list = ShengXiaoData.Instance:GetBagEquipDataList()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:FlushBagView()
end

function ShengXiaoEquipView:__delete()
	self.fight_text1 = nil
	self.fight_text2 = nil
	if nil ~= self.cur_equip_cell then
		self.cur_equip_cell:DeleteMe()
		self.cur_equip_cell = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for _,v in pairs(self.equip_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_list = {}
	for _,v in pairs(self.equip_bag_cells) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_bag_cells = {}

	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.shengxiao_recycle_flush_delayer then
		GlobalTimerQuest:CancelQuest(self.shengxiao_recycle_flush_delayer)
		self.shengxiao_recycle_flush_delayer = nil
	end
end

function ShengXiaoEquipView:CloseCallBack()
	ShengXiaoData.Instance:SaveEquipIsAutoBuy(false)
end

function ShengXiaoEquipView:ItemDataChangeCallback(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if EquipData.IsShengXiaoEqType(item_cfg.sub_type) or item_id == 27009 then
		if self.shengxiao_recycle_flush_delayer then
			GlobalTimerQuest:CancelQuest(self.shengxiao_recycle_flush_delayer)
			self.shengxiao_recycle_flush_delayer = nil
		end
		self.shengxiao_recycle_flush_delayer = GlobalTimerQuest:AddDelayTimer(function()
			-- if item_id == 27009 then
				self:FlushAll()
			-- end
			self:FlushBagView()
		end, 0.5)
	end

end

function ShengXiaoEquipView:GetNumberOfAttrCells()
	local num = ShengXiaoData.Instance:GetEquipAttrNumByIndex(self.list_index, self.equip_index)
	return num
end

-- function ShengXiaoEquipView:RefreshAttrCell(cell, data_index)
-- 	data_index = data_index + 1
-- 	local attr_cell = self.attr_cell_list[cell]
-- 	if attr_cell == nil then
-- 		attr_cell = AttrItem.New(cell.gameObject)
-- 		self.attr_cell_list[cell] = attr_cell
-- 	end

-- 	local shengxiaoIteminfo = ShengXiaoData.Instance:GetShengXiaoColorByIndex(self.list_index)
-- 	if shengxiaoIteminfo == nil then
-- 		return
-- 	end
-- 	local shengxiao_color = shengxiaoIteminfo.shengxiao_color

-- 	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
-- 	local cur_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level, shengxiao_color)
-- 	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
-- 	local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
-- 	local data = {}
-- 	if cur_equip_level == 0 then
-- 		cur_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, 1, shengxiao_color)
-- 		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
-- 		show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
-- 		data = show_attr[data_index]
-- 		if data then
-- 			data.value = 0
-- 		end
-- 	else
-- 		data = show_attr[data_index]
-- 	end
-- 	if data then
-- 		data.show_add = cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL
-- 		if cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
-- 			local next_equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1, shengxiao_color)
-- 			local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
-- 			local next_show_attr = CommonDataManager.GetAttrNameAndValueByClass(attr_cfg)
-- 			data.add_attr = next_show_attr[data_index].value - data.value
-- 		else
-- 			data.add_attr = 0
-- 		end
-- 	end
-- 	attr_cell:SetData(data)
-- end

function ShengXiaoEquipView:GetNumberOfCells()
	return 12
end

function ShengXiaoEquipView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = ShengXiaoItem.New(cell.gameObject)
		star_cell.root_node.toggle.group = self.node_list["ShengXiaoList"].toggle_group
		star_cell.shengxiao_equip_view = self
		self.cell_list[cell] = star_cell
	end

	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function ShengXiaoEquipView:GetBagNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ShengXiaoEquipView:EquipBagRefreshCell(index, cellObj)
	local group = self.equip_bag_cells[cellObj]
	if group == nil then
		group = ShengXiaoItemCell.New(cellObj.gameObject)
		self.equip_bag_cells[cellObj] = group
	end
	-- group:SetToggleGroup(self.node_list["PageView"].toggle_group)
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / ROW_NUM) + 1 - page * COLUMN_NUM
	local cur_row = math.floor(index % ROW_NUM) + 1
	local grid_index = (cur_row - 1) * COLUMN_NUM + cur_colunm + page * ROW_NUM * COLUMN_NUM
	-- local data_list = ShengXiaoData.Instance:GetBagEquipDataList()
	local data = self.data_list[grid_index]
	-- group:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, grid_index, data, group))
	-- group:SetInteractable(nil ~= data and nil ~= next(data))
	if data then
		data.from_view = TipsFormDef.FROM_SHENYIN_BAG
	end
	group:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, data, group))
	group:SetData(data, true)
end

function ShengXiaoEquipView:FlushBagView()
	if self.node_list["ListView"].scroller.isActiveAndEnabled then
		-- ShengXiaoData.Instance:GetBagEquipDataList()
		-- self.cur_bag_index = -1
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

--点击格子事件
function ShengXiaoEquipView:HandleBagOnClick(data, cell)
	if data == nil then return end
	self.view_state = ""
	-- if not is_click then return end

	cell:SetHighLight(true)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	-- cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		if self.view_state == BAG_SHOW_STORGE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_STORGE, nil, close_callback)
		elseif self.view_state == BAG_SHOW_SALE then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE,{{fromIndex = data.index}})
		elseif self.view_state == BAG_SHOW_SALE_JL then
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG_ON_BAG_SALE_JL, {fromIndex = data.index})
		elseif (item_cfg1.recycltype == 6 or item_cfg1.recycltype == 9 or item_cfg1.recycltype == 10) and self.view_state == BAG_SHOW_RECYCLE and big_type1 == GameEnum.ITEM_BIGTYPE_EQUIPMENT then
			if not cell.quality_enbale then
				TipsCtrl.Instance:ShowSystemMsg(Language.Package.HaveLock)
			else
				PackageData.Instance:AddItemToRecycleList(data)
				cell:SetIconGrayScale(true)
				self:FlushBagView()
				GlobalEventSystem:Fire(OtherEventType.RECYCLE_FLUSH_CONTENT)
			end
		else
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGXIAO_BAG, nil, close_callback)
		end
	end
end

function ShengXiaoEquipView:ClickEquipItem(data, index)
	self.equip_index = index
	ShengXiaoCtrl.Instance:SetShengXiaoEquipIndex(index)
	local bag_list = ShengXiaoData.Instance:GetBagEquipDataList()
	local has_on_bag = false
	for k, v in pairs(bag_list) do
		if v.sub_type ~= nil and (v.sub_type - 1300) == index - 1 then
			has_on_bag = true
			break
		end
	end
	local equip_id = ShengXiaoData.Instance:GetCurEquipindex(index - 1)
	if data == nil or equip_id == nil then return end
	if equip_id == 0 then
		if not has_on_bag then
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ShengXiaoError)
		else
			ViewManager.Instance:Open(ViewName.ShengXiaoEquipBag)
		end
	else
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SHENGXIAO_EQUIP, nil)
	end
end

function ShengXiaoEquipView:OnClickFenJie()
	ViewManager.Instance:Open(ViewName.ShengXiaoResolveView)
end

-- 点击套装
function ShengXiaoEquipView:OnClickSuit()
	ShengXiaoCtrl.Instance:SetSuitOpenCallBack(self.list_index)
end

function ShengXiaoEquipView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(176)
end

function ShengXiaoEquipView:OnClickListRight()
	if self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM >= 1 then
		self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = 1
		return
	end
	self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM
end

function ShengXiaoEquipView:OnClickListLeft()
	if self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM <= 0 then
		self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = 0
		return
	end
	self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM
end

function ShengXiaoEquipView:ClickLevelUp()
	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
	local is_auto_buy = ShengXiaoData.Instance:GetEquipIsAutoBuy()
	local shengxiaoIteminfo = ShengXiaoData.Instance:GetShengXiaoColorByIndex(self.list_index)
	if shengxiaoIteminfo == nil then
		return
	end
	local shengxiao_color = shengxiaoIteminfo.shengxiao_color

	if cur_equip_level < GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		local equip_next_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1, shengxiao_color)
		if not equip_next_cfg then return end 

		local bag_num = ItemData.Instance:GetItemNumInBagById(equip_next_cfg.consume_stuff_id)
		if bag_num < equip_next_cfg.consume_stuff_num then
			--快速购买初级星陨石
			if 27009 == equip_next_cfg.consume_stuff_id then
				local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					ShengXiaoData.Instance:SaveEquipIsAutoBuy(is_buy_quick)
				end

				local shop_item_cfg = ShopData.Instance:GetShopItemCfg(equip_next_cfg.consume_stuff_id)
				if not is_auto_buy then
					TipsCtrl.Instance:ShowCommonBuyView(func, equip_next_cfg.consume_stuff_id, nil, equip_next_cfg.consume_stuff_num - bag_num)
				else
					local item_cfg = ShopData.Instance:GetShopItemCfg(equip_next_cfg.consume_stuff_id)
					local single_price = 0
					if item_cfg then
						single_price = item_cfg.bind_gold
					else
						return
					end
					--默认使用绑钻买
					local is_bind = 1
					--如果绑钻数量不够
					local need_count = equip_next_cfg.consume_stuff_num - bag_num
					local player_bind_gold = CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold)
					if need_count * single_price > player_bind_gold then
						--如果身上还有部分绑钻
						if player_bind_gold >= single_price then
							--可购买的数量
							local count = player_bind_gold / single_price
							MarketCtrl.Instance:SendShopBuy(equip_next_cfg.consume_stuff_id, count, is_bind, 1)
							need_count = need_count - count
						end
						is_bind = 0
					end
					MarketCtrl.Instance:SendShopBuy(equip_next_cfg.consume_stuff_id, need_count, is_bind, 1)
				end
				ShengXiaoCtrl.Instance:SendPromoteEquipRequest(self.list_index - 1, self.equip_index - 1)
			else
				TipsCtrl.Instance:ShowItemGetWayView(equip_next_cfg.consume_stuff_id)
			end
		else
			ShengXiaoCtrl.Instance:SendPromoteEquipRequest(self.list_index - 1, self.equip_index - 1)
		end
	end
end

--刷新右边面板
function ShengXiaoEquipView:FlushRightInfo()
	UI:SetButtonEnabled(self.node_list["BtnUpLevel"], true)
	local cur_equip_level = ShengXiaoData.Instance:GetOneEquipLevel(self.list_index, self.equip_index)
	local data = {}
	local shengxiaoIteminfo = ShengXiaoData.Instance:GetShengXiaoColorByIndex(self.list_index)
	if shengxiaoIteminfo == nil then
		return
	end
	local shengxiao_color = shengxiaoIteminfo.shengxiao_color
	data.level = cur_equip_level
	data.item_id = ShengXiaoData.Instance:GetUpgradeNeedItemID(self.equip_index - 1, shengxiao_color)
	local equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level, shengxiao_color)
	if nil == equip_cfg then return end
	data.color = equip_cfg.quality
	local cur_name = equip_cfg.name or ""
	self.cur_equip_cell:SetData(data)
	self.node_list["TextName"].text.text = "Lv." .. cur_equip_level .. " " ..  equip_cfg.name
	if cur_equip_level >= GameEnum.CHINESE_ZODIAC_MAX_EQUIP_LEVEL then
		-- self.node_list["NextEquip"]:SetActive(false)
		self.node_list["TxtNeed"].text.text = Language.Common.MaxLevelDesc
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"], false)
		-- self.node_list["ImgArrow"]:SetActive(false)
		self.node_list["TxtButton"].text.text = Language.ShengXiao.btnMaxLevel
	else
		-- self.node_list["NextEquip"]:SetActive(true)
		-- self.node_list["ImgArrow"]:SetActive(true)
		local next_data = {}
		next_data.level = cur_equip_level + 1
		next_data.item_id = ShengXiaoData.Instance:GetUpgradeNeedItemID(self.equip_index - 1, shengxiao_color)
		local equip_next_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(self.equip_index - 1, cur_equip_level + 1, shengxiao_color)
		next_data.color = equip_next_cfg.quality

		local bag_num = ItemData.Instance:GetItemNumInBagById(next_data.item_id)
		local cost_desc = string.format(Language.ShengXiao.StuffDecs, bag_num, equip_next_cfg.consume_stuff_num)
		local cost_desc1 = string.format(Language.ShengXiao.StuffDecs2, bag_num, equip_next_cfg.consume_stuff_num)
		self.node_list["TxtNeed"].text.text = bag_num >= equip_next_cfg.consume_stuff_num and cost_desc or cost_desc1
		UI:SetButtonEnabled(self.node_list["BtnUpLevel"], true)

		local star_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.list_index)
		if star_level < equip_next_cfg.zodiac_level then
		self.node_list["TxtNeed"].text.text = string.format(Language.ShengXiao.OpenEquip, star_level, equip_next_cfg.zodiac_level)
			UI:SetButtonEnabled(self.node_list["BtnUpLevel"], false)
		end
		self.node_list["TxtButton"].text.text = Language.ShengXiao.UpGrade
	end
	self.node_list["AttrList"].scroller:ReloadData(0)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = CommonDataManager.GetCapability(equip_cfg)
	end
	if self.fight_text2 and self.fight_text2.text then
		self.fight_text2.text.text = ShengXiaoData.Instance:GetEquipAllCapByListIndex(self.list_index)
	end
end


function ShengXiaoEquipView:FlushEquipInfo()
	local equip_level_list = ShengXiaoData.Instance:GetEquipLevelListByindex(self.list_index)
	if equip_level_list == nil then
		return
	end
	local capability = 0
	local suit_capability, super_capability = ShengXiaoData.Instance:GetActiveSuitPower(self.list_index)
	for i = 1, 5 do
		local data = {}
		-- data.level = equip_level_list[i]
		if equip_level_list[i] > 0 then
			data.item_id = equip_level_list[i]
			self.equip_list[i]:SetEquipIconGrayScale(false)
			self.equip_list[i]:SetEquipQualityGrayScale(false)
			local item_cfg = ItemData.Instance:GetItemConfig(equip_level_list[i])
			local cur_num = CommonDataManager.GetCapability(item_cfg)
			capability = capability + cur_num
			local flag = ShengXiaoData.Instance:GetHasBetterEquip(data.item_id, false, self.list_index)
			self.equip_up_t[i]:SetActive(flag)
		else
			data.item_id = 65000 + i - 1
			self.equip_list[i]:SetEquipIconGrayScale(true)
			self.equip_list[i]:SetEquipQualityGrayScale(true)
			local flag = ShengXiaoData.Instance:GetHasBetterEquip(data.item_id, true, self.list_index)
			self.equip_up_t[i]:SetActive(flag)
		end

		-- local equip_cfg = ShengXiaoData.Instance:GetEquipCfgByIndexAndLevel(i - 1, data.level, shengxiao_color)
		-- if equip_cfg then
		-- 	data.quality = equip_cfg.quality
		-- end
		self.equip_list[i]:SetData(data)
		-- self.equip_list[i]:SetEquipLevel(i)
		self.equip_list[i]:ListenClick(BindTool.Bind(self.ClickEquipItem, self, data, i))
		-- self.equip_list[i]:SetHighLight(i == self.equip_index)
	end
	self.fight_text2.text.text = capability + suit_capability
	self.node_list["SuperPowerTxt"].text.text = string.format(Language.Common.GaoZhanLi, super_capability)
	self.node_list["SuitCapBg"]:SetActive(suit_capability > 0)
	self.node_list["SuperPowerImg"]:SetActive(suit_capability <= 0)
	self.node_list["center_display"].image:LoadSprite(ResPath.GetShengXiaoBigIcon(self.list_index))
	-- self.node_list["TxtPower2"].text.text = ShengXiaoData.Instance:GetEquipAllCapByListIndex(self.list_index)
end

function ShengXiaoEquipView:GetSelectIndex()
	return self.list_index or 1
end

function ShengXiaoEquipView:SetSelectIndex(index)
	if index then
		self.list_index = index
		ShengXiaoData.Instance:SetEquipListByindex(index)
	end
	self:FlushFlyAni()
end

function ShengXiaoEquipView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

--刷新所有装备格子信息
function ShengXiaoEquipView:FlushListCell()
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

function ShengXiaoEquipView:FlushAll()
	self:FlushListCell()
	self:FlushEquipInfo()
	-- self:FlushRightInfo()
	self:FlushAllHL()
end

function ShengXiaoEquipView:FlushBagView()
	self.data_list = ShengXiaoData.Instance:GetBagEquipDataList()
	if self.node_list["PageView"] and nil ~= self.node_list["PageView"].list_view
		and self.node_list["PageView"].list_view.isActiveAndEnabled then
		self.node_list["PageView"].list_view:Reload()
		self.node_list["PageView"].list_view:JumpToIndex(0) 
	end
end

function ShengXiaoEquipView:AfterSuccessUp()
	local bundle_name, asset_name = ResPath.GetUiXEffect("UI_ChengGongTongYong")
	TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, 1.5)
end

function ShengXiaoEquipView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end
	self.node_list["center_display"].rect:SetLocalPosition(0, 0, 0)
	self.node_list["center_display"].rect:SetLocalScale(0, 0, 0)

	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(0.8, 0.8, 0.8)
	self.tweener1 = self.node_list["center_display"].rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.node_list["center_display"].rect:DOScale(target_scale, 0.7)
end


---------------------ShengXiaoItem--------------------------------
ShengXiaoItem = ShengXiaoItem or BaseClass(BaseCell)

function ShengXiaoItem:__init()
	self.shengxiao_equip_view = nil
	self.node_list["ShengxiaoItem"].toggle:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function ShengXiaoItem:__delete()
	self.shengxiao_equip_view = nil
end

function ShengXiaoItem:SetItemIndex(index)
	self.item_index = index
end

function ShengXiaoItem:OnFlush()
	self:FlushHL()

	self.node_list["ImgIcon"]:SetActive(true)
	self.node_list["TxtText"]:SetActive(true)
	self.node_list["ImgLcok"]:SetActive(false)
	self.node_list["ImgGrid"]:SetActive(true)

	-- local level = ShengXiaoData.Instance:GetEquipActiveNum(self.item_index)
	local level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.item_index) or 0
	self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetShengXiaoIcon(self.item_index))
	self.node_list["TxtText"].text.text = level
	local shengxiao_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.item_index) or 0
	UI:SetGraphicGrey(self.node_list["ImgIcon"], shengxiao_level <= 0)
	self.node_list["ImgRedPoint"]:SetActive(ShengXiaoData.Instance:GetEquipRemindByStarIndex(self.item_index))
end

function ShengXiaoItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.shengxiao_equip_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end

		self.shengxiao_equip_view:SetSelectIndex(self.item_index)
		self.shengxiao_equip_view:FlushAllHL()
		self.shengxiao_equip_view:FlushEquipInfo()
		-- self.shengxiao_equip_view:FlushRightInfo()
	end
end

function ShengXiaoItem:FlushHL()
	local select_index = self.shengxiao_equip_view:GetSelectIndex()
	self.node_list["ImgHighlight"]:SetActive(select_index == self.item_index)
	self.node_list["ShengxiaoItem"].toggle.isOn = select_index == self.item_index
end

---------------------ShengXiaoEquipCell--------------------------------
ShengXiaoEquipCell = ShengXiaoEquipCell or BaseClass(ItemCell)

function ShengXiaoEquipCell:SetData(data, is_from_bag)
	local shengxiaoIteminfo = ShengXiaoData.Instance:GetShengXiaoColorByIndex(self.parent_view.list_index)
	if shengxiaoIteminfo == nil then
		return
	end
	local shengxiao_color = shengxiaoIteminfo.shengxiao_color

	ItemCell.SetData(self, data, is_from_bag)
	-- self:ShowQuality(false)
	self:ShowEquipGrade(false)
	self:ShowHighLight(false)
end

function ShengXiaoEquipCell:__delete()
	self.parent_view = nil
end

function ShengXiaoEquipCell:SetEquipIconGrayScale(flag)
	self:SetIconGrayScale(flag)
end

function ShengXiaoEquipCell:SetEquipQualityGrayScale(enable)
	self:SetQualityGrayScale(enable)
end

function ShengXiaoEquipCell:SetGrade(grade)
	local max_level = ShengXiaoData.Instance:GetColorMaxLevelByColor(self.data.quality)
	local function call_back(obj)
		if obj then
			obj:SetActive(true)
			local grade_level = grade % max_level > 0 and grade % max_level or max_level
			obj.text.text = tostring(grade_level .. Language.Common.Jie) or ""
		end
	end
	if self.SpecialGrade then
		call_back(self.SpecialGrade)
	else
		self:LoadChildObj({name = "Grade", pos = {-5.5, 25}, size = {90, 27.5}, callback = call_back})
	end
end

function ShengXiaoEquipCell:SetEquipLevel(index)
	local level = ShengXiaoData.Instance:GetOneEquipLevel(self.parent_view.list_index, index)
	self:ShowStrengthLable(true)
	self:SetStrength(level)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- 背包格子
ShengXiaoItemCell = ShengXiaoItemCell or BaseClass(BaseCell)

function ShengXiaoItemCell:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["item"])
end

function ShengXiaoItemCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function ShengXiaoItemCell:SetData(data , anim_obj)
	self.data = data
	self.item:SetData(data)
end

function ShengXiaoItemCell:ListenClick(handler)
	self.item:ListenClick(handler)
end

function ShengXiaoItemCell:SetHighLight(flag)
	self.item:SetHighLight(flag)
end