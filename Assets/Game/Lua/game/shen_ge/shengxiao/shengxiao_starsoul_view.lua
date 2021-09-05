ShengXiaoStarSoulView = ShengXiaoStarSoulView or BaseClass(BaseRender)

local HIDE_NUM = 7

local Effect_Res_List = {
	[1] = "UI_xingzuo_01",
	[2] = "UI_xingzuo_02",
	[3] = "UI_xingzuo_03",
	[4] = "UI_xingzuo_04",
	[5] = "UI_xingzuo_05",
}

local MOVE_TIME = 0.5
function ShengXiaoStarSoulView:UIsMove()
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(600 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , 200 , 0 ) , MOVE_TIME )


	UITween.MoveShowPanel(self.node_list["Left1"] , Vector3(0 , 200 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -200 , 0 ) , MOVE_TIME )
	--UITween.MoveShowPanel(self.node_list["MiddleCenter"] , Vector3(0 , -50 , 0 ) , 0.4 )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(30 , -80 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["MiddleUp"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.MoveShowPanel(self.node_list["Left2"] , Vector3(0 , -50 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Left2"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	--UITween.ScaleShowPanel(self.node_list["MiddleUpBg"] ,Vector3(0.7 , 0.7 , 0.7 ) , 0.4 )
	UITween.MoveShowPanel(self.node_list["LeftContent"], Vector3(-106, -37, 0), MOVE_TIME)
end

function ShengXiaoStarSoulView:__init()
	self.max_cell = 12
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["StuffItem"])

	self.node_list["AutoBuyToggle"].toggle:AddClickListener(BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0

	self.cell_list = {}
	local list_delegate = self.node_list["ShengXiaoList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.node_list["BtnLevelUp"].button:AddClickListener(BindTool.Bind(self.ClickLevelUp, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.OnClickListLeft, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.OnClickListRight, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["CellToggleLuckyItem"].button:AddClickListener(BindTool.Bind(self.LuckyItemClick, self))
	self.node_list["BtnFunc"].button:AddClickListener(BindTool.Bind(self.OnClickTotalAttr, self))

	self.attr_cell_list = {}
	local list_delegate = self.node_list["AttrList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self.equip_index = self.equip_index or 1
	self.list_index = self.list_index or 1
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])
	self:ReSetFlag()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- self.need_item = ItemCell.New()
	-- self.need_item:SetInstanceParent(self.node_list["ImgItemIcon"])
	ShengXiaoData.Instance:SetXingHunMaterialNum()
	RemindManager.Instance:Fire(RemindName.ShengXiao_StarSoul)
end

function ShengXiaoStarSoulView:__delete()
	self.fight_text = nil
	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for _,v in pairs(self.attr_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.attr_cell_list = {}

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.need_item then
		self.need_item:DeleteMe()
		self.need_item = nil
	end

	self.is_auto_buy_stone = 0
end

function ShengXiaoStarSoulView:CloseCallBack()
	ShengXiaoData.Instance:SetXingHunMaterialNum()
end

function ShengXiaoStarSoulView:HideEffectList()
	for i = 1, 10 do
		self.node_list["Effect" .. i]:SetActive(false)
	end
end

function ShengXiaoStarSoulView:ItemDataChangeCallback(item_id)
	self:FlushRightInfo()
	self:FlushListView()
end

--自动购买强化石Toggle点击时
function ShengXiaoStarSoulView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ShengXiaoStarSoulView:GetNumberOfAttrCells()
	return 3
end

function ShengXiaoStarSoulView:RefreshAttrCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetOrderAttrNameAndValue(one_level_attr)
	local data = {}
	if cur_starsoul_level == 0 then
		cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, 1)
		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		show_attr = CommonDataManager.GetOrderAttrNameAndValue(one_level_attr)
		data = show_attr[data_index]
		if data then
			data.value = 0
		end
	else
		data = show_attr[data_index]
	end
	if data then
		data.show_add = cur_starsoul_level < ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
		if cur_starsoul_level < ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index) then
			local next_equip_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level + 1)
			local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
			local next_show_attr = CommonDataManager.GetOrderAttrNameAndValue(attr_cfg)
			data.add_attr = next_show_attr[data_index].value - data.value
		else
			data.add_attr = 0
		end
	end
	attr_cell:SetData(data)
end

function ShengXiaoStarSoulView:GetNumberOfCells()
	return self.max_cell
end

function ShengXiaoStarSoulView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = StarSoulItem.New(cell.gameObject)
		star_cell.shengxiao_starsoul_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function ShengXiaoStarSoulView:ReSetFlag()
	self.use_lucky_item = 0
	self.node_list["ImgItemIcon"]:SetActive(false)
	self.node_list["ImgUseLuckyMark"]:SetActive(true)
end

--使用幸运符按钮按下
function ShengXiaoStarSoulView:LuckyItemClick()
	if self.use_lucky_item == 1 then
		self.node_list["ImgItemIcon"]:SetActive(false)
		self.node_list["ImgUseLuckyMark"]:SetActive(true)
		self.use_lucky_item = 0
	else
		if self:GetIsEnoughLuckyItem() then
			self.node_list["ImgItemIcon"]:SetActive(true)
			self.node_list["ImgUseLuckyMark"]:SetActive(false)
			self.use_lucky_item = 1
		else
			self.node_list["ImgItemIcon"]:SetActive(false)
			self.node_list["ImgUseLuckyMark"]:SetActive(true)
			self.use_lucky_item = 0
			local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
			local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
			TipsCtrl.Instance:ShowItemGetWayView(cur_cfg.protect_item_id)
		end
	end
end

--身上是否有足够的luck符
function ShengXiaoStarSoulView:GetIsEnoughLuckyItem()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	if cur_cfg then
		local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.protect_item_id)
		if item_num >= cur_cfg.protect_item_num then
			return true, item_num, cur_cfg.protect_item_num
		else
			return false, item_num, cur_cfg.protect_item_num
		end
	end
end

--是否需要luck符
function ShengXiaoStarSoulView:GetIsNeedLuckyItem()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	return cur_cfg.is_protect_level ~= 1
end

-- 显示使用幸运符图标
function ShengXiaoStarSoulView:SetLuckyItemNum(need_num, had_num)
	local had_text = ""
	local need_text = ToColorStr(' / '..need_num, TEXT_COLOR.GREEN_4)
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.GREEN_4)
	else
		had_text = ToColorStr(had_num,COLOR.RED)
	end
	self.node_list["TxtProStuff"].text.text = had_text .. need_text

	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.protect_item_id)
	-- self.need_item:SetData({item_id = cur_cfg.protect_item_id})
	local quality = ItemData.Instance:GetItemQuailty(cur_cfg.protect_item_id)
	self.node_list["Quality"].image:LoadSprite(ResPath.GetQualityIcon(quality))
	self.node_list["ItemIcon"].image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
end

-- 物品
function ShengXiaoStarSoulView:SetStuffItemInfo(need_num, had_num, item_id)
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	if max_level > 0 and cur_starsoul_level >= max_level then
		self.node_list["TxtStuff"].text.text = Language.Common.MaxLevelDesc
		self.stuff_cell:SetData({item_id = item_id or 26000})
		return 
	end
	local had_text = ""
	local need_text = ToColorStr(' / '..need_num, TEXT_COLOR.GREEN_4)
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.GREEN_4)
	else
		had_text = ToColorStr(had_num,COLOR.RED)
	end
	self.node_list["TxtStuff"].text.text = had_text .. need_text
	self.stuff_cell:SetData({item_id = item_id or 26000})
end

function ShengXiaoStarSoulView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(231)
end

function ShengXiaoStarSoulView:OnClickTotalAttr()
	local cur_suit_cfg , next_suit_cfg, total_level = ShengXiaoData.Instance:GetStarSoulTotal()
	TipsCtrl.Instance:ShowSuitAttrView(cur_suit_cfg, next_suit_cfg, total_level)
end

function ShengXiaoStarSoulView:OnClickListRight()
	if self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM >= 1 then
		self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = 1
		return
	end
	self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM
end

function ShengXiaoStarSoulView:OnClickListLeft()
	if self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM <= 0 then
		self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = 0
		return
	end
	self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition = self.node_list["ShengXiaoList"].scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM
end

function ShengXiaoStarSoulView:ClickLevelUp()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	if cur_starsoul_level < max_level then
		local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
		if bag_num >= cur_cfg.consume_stuff_num then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1,
				self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
		elseif self.node_list["AutoBuyToggle"].toggle.isOn then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, 
				self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
		else
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				--勾选自动购买
				if is_buy_quick then
					self.node_list["AutoBuyToggle"].toggle.isOn = true
					self.is_auto_buy_stone = 1
				end
			end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.consume_stuff_id)
			if cur_cfg.consume_stuff_num - bag_num == nil then
				MarketCtrl.Instance:SendShopBuy(cur_cfg.consume_stuff_id, 999, 0, 1)
			else
				TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.consume_stuff_id, nil, cur_cfg.consume_stuff_num - bag_num)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.MaxXingHun)
	end
end

--刷新右边面板
function ShengXiaoStarSoulView:FlushRightInfo()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	if cur_cfg == nil then return end
	local next_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level + 1)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
	local max_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, max_level)

	local show_attr = CommonDataManager.GetAdvanceAddNameAndValueByClass(max_cfg)
	if next(show_attr) then
		local next_add_cfg = ShengXiaoData.Instance:GetNextStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level, show_attr[1].attr)
		self.node_list["NodeAttrItem"]:SetActive(true)
		self.node_list["TxtCurrAttr"].text.text = show_attr[1].attr_name .. ": " .. "<color=#ffffff>" .. "+" .. cur_cfg[show_attr[1].attr] / 100 .. "%</color>"
		if nil ~= next_cfg then
			local per = (next_add_cfg[show_attr[1].attr] -  cur_cfg[show_attr[1].attr]) / 100
			local cur_level = ToColorStr(cur_starsoul_level, COLOR.RED)
			local next_add_level = ToColorStr(" / " .. next_add_cfg.level, TEXT_COLOR.GREEN_4)
			local txt = string.format("%s%%(%s%s)",per, cur_level, next_add_level)
			-- local txt =(next_add_cfg[show_attr[1].attr] -  cur_cfg[show_attr[1].attr]) / 100 .. "%(" .. ToColorStr(cur_starsoul_level, COLOR.RED) .. ToColorStr("/" .. next_add_cfg.level, COLOR.TEXT_COLOR.GREEN_4) .. ")"
			self.node_list["TxtAddAttr"].text.text = txt
		end
	else
		self.node_list["TxtCurrAttr"].text.text = ""
		self.node_list["TxtAddAttr"].text.text = ""
		self.node_list["NodeAttrItem"]:SetActive(false)
	end

	self:FlushPointEffect()
	self.node_list["AttrList"].scroller:ReloadData(0)

	local auto_fit_size = true
	local bundle, asset = ResPath.GetShengXiaoStarSoul(self.list_index)
	-- self.node_list["CenterDisplay"].load_raw_image.AutoFitNativeSize = auto_fit_size
	-- self.node_list["CenterDisplay"]:ChangeRawImageAsset(bundle, asset .. ".png")
	self.node_list["CenterDisplay"].raw_image:LoadSprite(bundle, asset, function()
		self.node_list["CenterDisplay"]:SetActive(true)
		self.node_list["CenterDisplay"].raw_image:SetNativeSize()
		end)

	self.node_list["TxtStarLevel"].text.text = ShengXiaoData.Instance:GetStarSoulMaxLevelByIndex(self.list_index)
	self.node_list["TxtTitleLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, cur_starsoul_level)
	local flag = max_level > 0 and cur_starsoul_level >= max_level
	self.node_list["TxtSuccesrate"]:SetActive(not flag)
	self.node_list["CellItem"]:SetActive(not flag)
	self.node_list["NodeAddAttr"]:SetActive(not flag)
	UI:SetButtonEnabled(self.node_list["BtnLevelUp"], not flag)

	self.node_list["TxtBtn"].text.text = cur_starsoul_level >= max_level and Language.ShengXiao.btnMaxLevel or Language.ShengXiao.UpGrade
	self.node_list["TxtRate"].text.text = string.format(Language.ShengXiao.SuccRate, cur_cfg.succ_percent)
	self:SetStuffItemInfo(cur_cfg.consume_stuff_num, item_num, cur_cfg.consume_stuff_id)
	for i = 1, 5 do
		UI:SetGraphicGrey(self.node_list["ImgStar" .. i], i > ShengXiaoData.Instance:GetStarSoulBaojiByIndex(self.list_index))
	end
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local one_level_power = CommonDataManager.GetCapability(one_level_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = one_level_power
	end
	if self:GetIsNeedLuckyItem() then
		self.node_list["CellItem"]:SetActive(true)
		local is_enough = false
		local need_num = 0
		local had_num = 0
		is_enough, had_num, need_num = self:GetIsEnoughLuckyItem()
		if not is_enough then
			self.use_lucky_item = 0
		end
		self:SetLuckyItemNum(need_num, had_num)
		self.node_list["ImgItemIcon"]:SetActive(self.use_lucky_item == 1)
		self.node_list["ImgUseLuckyMark"]:SetActive(self.use_lucky_item ~= 1)
	else
		self.node_list["CellItem"]:SetActive(false)
	end
end

function ShengXiaoStarSoulView:GetSelectIndex()
	return self.list_index or 1
end

function ShengXiaoStarSoulView:SetSelectIndex(index)
	if index == self.list_index then
		return
	end
	self.list_index = index
end

function ShengXiaoStarSoulView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ShengXiaoStarSoulView:FlushLeftInfo()
	
end

--刷新所有装备格子信息
function ShengXiaoStarSoulView:FlushListCell()
	-- for k,v in pairs(self.cell_list) do
	-- 	v:OnFlush()
	-- end
	-- self:FlushListView()
end

function ShengXiaoStarSoulView:FlushAll()
	self:FlushListView()
	self:FlushLeftInfo()
	self:FlushRightInfo()
end

function ShengXiaoStarSoulView:AfterSuccessUp(is_success)
	local bundle_name, asset_name = ResPath.GetMiscEffect("UI_ChengGongTongYong")
	TipsCtrl.Instance:OpenEffectView(bundle_name, asset_name, 1.5)
end

function ShengXiaoStarSoulView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end
	self.node_list["CenterDisplay"].rect:SetLocalPosition(0, 0, 0)
	self.node_list["CenterDisplay"].rect:SetLocalScale(0, 0, 0)
	self:HideEffectList()
	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.node_list["CenterDisplay"].rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.node_list["CenterDisplay"].rect:DOScale(target_scale, 0.7)
	self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end

function ShengXiaoStarSoulView:FlushPointEffect()
	local level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local big_level, small_level = math.modf(level / 10)
	small_level = string.format("%.2f", small_level * 10)
	small_level = math.floor(small_level)
	local image_list = {}
	
	if big_level > 0 then
		for j = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetStartEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end

		for i = small_level + 1, 10 do
			local res_id = Effect_Res_List[big_level]
			local bubble, asset = ResPath.GetStartEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	else
		for i = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetStartEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	end
	
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetStarSoulPointCfg(self.list_index)
	for i = 1, #image_list do
		self.node_list["Effect" .. i]:SetActive(true)
		self.node_list["Effect" .. i]:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(point_effect_pos_cfg[i].x, point_effect_pos_cfg[i].y)
		local va_res_path = image_list[i]

		if object_attach then
			if object_attach.BundleName ~= va_res_path[1] or object_attach.AssetName ~= va_res_path[2] then
				self.node_list["Effect" .. i]:ChangeAsset(va_res_path[1], va_res_path[2])
			end
		else
			self.node_list["Effect" .. i]:ChangeAsset(va_res_path[1], va_res_path[2])
		end
	end

	for i = #image_list + 1, 10 do
		self.node_list["Effect" .. i]:SetActive(false)
	end

end

function ShengXiaoStarSoulView:FlushListView()
	if self.node_list["ShengXiaoList"] and self.node_list["ShengXiaoList"].scroller.isActiveAndEnabled then
		self.node_list["ShengXiaoList"].scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------StarSoulItem--------------------------------
StarSoulItem = StarSoulItem or BaseClass(BaseCell)

function StarSoulItem:__init()
	self.shengxiao_starsoul_view = nil
	self.node_list["LockEffectObj"]:SetActive(false)
	self.boom_effect_index = 0
	self.old_zodiac_progress = 0

	self.node_list["StarSoulCell"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
	self.node_list["ImgLock"].button:AddClickListener(BindTool.Bind(self.ClickLock, self))
end

function StarSoulItem:__delete()

	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end

	self.shengxiao_starsoul_view = nil
end

function StarSoulItem:SetItemIndex(index)
	self.item_index = index
end

function StarSoulItem:OnFlush()
	self:FlushHL()
	local zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	self.node_list["ImgLock"]:SetActive(not ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) or self.item_index > zodiac_progress)
	self.node_list["ImgItem"]:SetActive(ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) and self.item_index <= zodiac_progress)
	self.node_list["ImgItem"].image:LoadSprite(ResPath.GetShengXiaoIcon(self.item_index))
	self.node_list["EffectLock"]:SetActive(ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) and self.item_index > zodiac_progress)
	self.node_list["NumberBg"]:SetActive(ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) and self.item_index <= zodiac_progress)
	self.node_list["TextLevel"].text.text = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.item_index)
	if self.boom_effect_index > 0 then
		if self.old_zodiac_progress < zodiac_progress then
			self.old_zodiac_progress = zodiac_progress
			self.boom_effect_index = 0
			self.node_list["LockEffectObj"]:SetActive(true)
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.node_list["LockEffectObj"]:SetActive(false) end, 0.5)
		end
	end

	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.item_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.item_index, cur_starsoul_level)
	if cur_cfg then
		local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
		if item_num >= cur_cfg.consume_stuff_num and ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) and 
			self.item_index <= zodiac_progress then
			self.node_list["ImgRedPoint"]:SetActive(true)
		else
			self.node_list["ImgRedPoint"]:SetActive(false)
		end
	end
end

function StarSoulItem:OnClickItem()
	local list_index = self.shengxiao_starsoul_view:GetSelectIndex()
	if list_index == self.item_index then
		return
	end
	local zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	if not ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) or self.item_index > zodiac_progress then
		return
	end
	self.shengxiao_starsoul_view:SetSelectIndex(self.item_index)
	self.shengxiao_starsoul_view:ReSetFlag()
	self.shengxiao_starsoul_view:FlushAllHL()
	self.shengxiao_starsoul_view:FlushLeftInfo()
	self.shengxiao_starsoul_view:FlushRightInfo()
end


function StarSoulItem:ClickLock()
	if ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGHUN_UNLOCK)
		self.boom_effect_index = self.item_index
		self.old_zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	else
		local cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.item_index, 0)
		local lase_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index - 1, 0)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.OpenCondition, lase_cfg.name, cfg.backwards_highest_level))
	end
end

function StarSoulItem:FlushHL()
	local list_index = self.shengxiao_starsoul_view:GetSelectIndex()
	self.node_list["ImgHighlight"]:SetActive(list_index == self.item_index)
end
