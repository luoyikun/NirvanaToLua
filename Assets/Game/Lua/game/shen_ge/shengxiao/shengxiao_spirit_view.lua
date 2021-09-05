ShengXiaoSpiritView = ShengXiaoSpiritView or BaseClass(BaseRender)
local MOVE_TIME = 0.5
function ShengXiaoSpiritView:UIsMove()
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(600 , 0 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , 200 , 0 ) , MOVE_TIME)

	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -200 , 0 ) , MOVE_TIME)
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , 200 , 0 ) , MOVE_TIME)
	--UITween.MoveShowPanel(self.node_list["MiddleCenter"] , Vector3(0 , -50 , 0 ) , 0.4)
	UITween.MoveShowPanel(self.node_list["MiddleCenter"] , Vector3(0 , -50 , 0 ) , MOVE_TIME)
	UITween.AlpahShowPanel(self.node_list["MiddleCenter"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["MiddleCenter"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME)
end

function ShengXiaoSpiritView:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["item_cell"])

	self.point_effect_list = {}
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])

	self.node_list["BtnUp"].button:AddClickListener(BindTool.Bind(self.OnPageUp, self))
	self.node_list["BtnDown"].button:AddClickListener(BindTool.Bind(self.OnPageDown, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickUplevel, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickTip, self))

	self.attr_cell_list = {}
	local list_delegate = self.node_list["attr_list"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self.cur_select = self:SetOpenSelect()
	self:FlushItemImage()
	self:FlushAll()

	--自动购买Toggle
	self.node_list["AutoBuyToggle"].toggle:AddClickListener(BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShengXiaoSpiritView:__delete()
	self.fight_text = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for k,v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
	self.attr_cell_list = {}
	self.cur_select = nil
	self.is_auto_buy_stone = 0
	self.cur_select = 0
	self:DelePointEffectList()

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShengXiaoSpiritView:ItemDataChangeCallback(item_id)
	if item_id == COMMON_CONSTS.SPIRIT_ID then
		self:FlushAll()
	end
end

function ShengXiaoSpiritView:SetOpenSelect()
	local info = ShengXiaoData.Instance:GetXingLingAllInfo()
	local max_select = self:SetMaxSelect()
	local now_chatpter = 1
	for k, v in ipairs(info.xingling_list) do
		if v.level < 39 or max_select <= k then
			return k
		end
	end
end

function ShengXiaoSpiritView:SetMaxSelect()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local max_select = 1
	if max_chatpter > 1 then
		max_select = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		max_select = 5
	end
	return max_select
end

function ShengXiaoSpiritView:OnPageUp()
	if self.cur_select <= 1 then return end
	self.cur_select = self.cur_select - 1
	self:OnBtnRecharge(self.cur_select, false)
end

function ShengXiaoSpiritView:OnPageDown()
	local max_select = self:SetMaxSelect()
	if self.cur_select >= GameEnum.TIAN_XIANG_SPIRIT_CHAPTER_NUM then
		return
	end
	if self.cur_select >= max_select and self.cur_select ~= 5 then
	local cur_chapter_cfg = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_select + 1)
		local tip_str = string.format(Language.ShengXiao.LastChapter, cur_chapter_cfg.name)
		SysMsgCtrl.Instance:ErrorRemind(tip_str)
		return
	end
	self.cur_select = self.cur_select + 1
	self:OnBtnRecharge(self.cur_select, false)
end

function ShengXiaoSpiritView:OnBtnRecharge(index, is_click)
	self.cur_select = index
	self:FlushItemImage()
	self:FlushAll()
end

function ShengXiaoSpiritView:FlushAll()
	local info = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select)
	local chapter_info = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_select)
	self.node_list["TxtTitle"].text.text = chapter_info.xingling_name

	local level = info.level
	self.node_list["TxtLevel"].text.text = string.format(Language.Common.ShenGongHuanHuaLevel, level + 1)

	local cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, level)
	
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local now_chatpter = 1
	if max_chatpter > 1 then
		now_chatpter = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		now_chatpter = 5
	end
	local total_cap = 0
	local num = ShengXiaoData.Instance:GetChapterActiveNum(self.cur_select)
	local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_select - 1) * 3)
	local capability = CommonDataManager.GetCapability(one_combine_cfg)
	local bass_zhan_li = CommonDataManager.GetCapability(cfg)
	local add_zhan_li = 0
	local xingtu_add_prob = 0
	if next(cfg) then
		add_zhan_li = math.floor(capability * (cfg.xingtu_add_prob / 10000) * num)
		xingtu_add_prob = cfg.xingtu_add_prob / 100
	end
	if level == -1 then
		bass_zhan_li = 0
		xingtu_add_prob = 0
		add_zhan_li = 0
	end
	self.node_list["NodeNextAttr"]:SetActive(info.level < 39)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = bass_zhan_li + add_zhan_li
	end
	self.node_list["TxtAttrValue"].text.text = "+".. xingtu_add_prob .. "%"
	local bless = info.bless
	local bless_val = next(cfg) and (bless / cfg.bless_val_limit) or 0
	local item_cfg = {}
	if info.level < 39 then
		local next_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, level + 1)
		item_cfg = ShengXiaoData.Instance:GetShowItems(self.cur_select - 1, level + 1)
		if next_cfg and next(next_cfg) then
			bless_val = bless / next_cfg.bless_val_limit
			bless = bless .. "/" .. next_cfg.bless_val_limit
			local next_attr = next_cfg.xingtu_add_prob / 100 - xingtu_add_prob
			self.node_list["TxtNxetValue"].text.text = next_attr .. "%"
			 local need_text = ToColorStr(' / '.. next_cfg.uplevel_stuff_num, "#89f201")
			 local item_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
			if item_num < next_cfg.uplevel_stuff_num then
				item_num = string.format(Language.Common.ShowRedNum, item_num)
			else
				item_num = ToColorStr(item_num, TEXT_COLOR.GREEN_4)
			end
			self.node_list["TxtPage2"].text.text = item_num .. need_text
		end
		UI:SetButtonEnabled(self.node_list["BtnStart"], true)
		self.node_list["BtnTxt"].text.text = Language.ShengXiao.QiLing
	else
		item_cfg = ShengXiaoData.Instance:GetShowItems(self.cur_select - 1, level)
		bless = Language.Common.YiMan
		bless_val = 1
		self.node_list["TxtPage2"].text.text = Language.Common.MaxLevelDesc
		UI:SetButtonEnabled(self.node_list["BtnStart"], false)
		self.node_list["BtnTxt"].text.text = Language.Common.YiManJi
	end
	self.item_cell:SetData(item_cfg)
	self.node_list["TxtProgress"].text.text = bless
	self.node_list["ImgProgressBg"].slider.value = bless_val

	local bundle, asset = nil, nil
	bundle, asset = ResPath.GetXingLingRes(self.cur_select)
	self.node_list["center_display"]:ChangeAsset(bundle, asset)
	self.node_list["TxtPage"].text.text = self.cur_select .. "/" .. now_chatpter

	self:FlushItemImage()
	self.node_list["attr_list"].scroller:ReloadData(0)
end

function ShengXiaoSpiritView:GetNumberOfAttrCells()
	return 3
end

function ShengXiaoSpiritView:RefreshAttrCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	local cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetOrderAttrNameAndValue(one_level_attr)
	local data = {}
	if cur_level < 0 then
		cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, 0)
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
		data.show_add = cur_level < 39
		if cur_level < 39 then
			local next_equip_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level + 1)
			local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
			local next_show_attr = CommonDataManager.GetOrderAttrNameAndValue(attr_cfg)
			if next_show_attr and next_show_attr[data_index] then
				data.add_attr = next_show_attr[data_index].value - data.value
			end
		else
			data.add_attr = 0
		end
	end
	attr_cell:SetData(data)
end

function ShengXiaoSpiritView:OnClickUplevel()
	local cur_level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	if cur_level and cur_level < 39 then
		local cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level + 1)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.uplevel_stuff_id)
		if cur_cfg.uplevel_stuff_num and bag_num >= cur_cfg.uplevel_stuff_num then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGLING, self.cur_select - 1, self.is_auto_buy_stone)
		elseif self.node_list["AutoBuyToggle"].toggle.isOn then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGLING, self.cur_select - 1, self.is_auto_buy_stone)
		else
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					--勾选自动购买
					if is_buy_quick then
						self.node_list["AutoBuyToggle"].toggle.isOn = true
						self.is_auto_buy_stone = 1
					end
				end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.uplevel_stuff_id)
			if next(cur_cfg) then
				if cur_cfg.uplevel_stuff_num - bag_num == nil then
					MarketCtrl.Instance:SendShopBuy(cur_cfg.uplevel_stuff_id, 999, 0, 1)
				else
					TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.uplevel_stuff_id, nil, cur_cfg.uplevel_stuff_num - bag_num)
				end
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.Max)
	end
end

function ShengXiaoSpiritView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(181)
end

--自动购买强化石Toggle点击时
function ShengXiaoSpiritView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

-- 升级时刷新特效
function ShengXiaoSpiritView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["point_effect"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShengXiaoSpiritView:DelePointEffectList()
	if self.point_effect_list then
		for k,v in pairs(self.point_effect_list) do
			ResMgr:Destroy(v)
			v = nil
		end
	end
	self.point_effect_list = {}
end

function ShengXiaoSpiritView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end

	self:DelePointEffectList()
	self.node_list["center_display"].rect:SetLocalPosition(0, 0, 0)
	self.node_list["center_display"].rect:SetLocalScale(0, 0, 0)

	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.node_list["center_display"].rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.node_list["center_display"].rect:DOScale(target_scale, 0.7)
	self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end

function ShengXiaoSpiritView:FlushPointEffect()
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetXinglingPointEffectCfg(self.cur_select)
	if not next(point_effect_pos_cfg) then return end

	for k,v in pairs(point_effect_pos_cfg) do
		local bundle, asset = ResPath.GetUiXEffect("UI_guangdian1_01")
		local async_loader = AllocAsyncLoader(self, "point_effect_loader_" .. k)
		async_loader:Load(bundle, asset, function(prefab)
			if not IsNil(prefab) then
				local obj = ResMgr:Instantiate(prefab)
				local transform = obj.transform
				transform:SetParent(self.node_list["point_effect_root"].transform, false)
				local tttt = transform:GetComponent(typeof(UnityEngine.RectTransform))
				tttt.anchoredPosition = Vector2(v.x, v.y)
				self.point_effect_list[k] = obj.gameObject
			end
		end)
	end
end

function ShengXiaoSpiritView:FlushItemImage()
	local level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	if nil ~= level then
		level = level + 1
		local whole = math.floor(level / 8)
		local more = level % 8
		for i = 1, 8 do
			local key = whole
			if more >= i then
				key = whole + 1
			end
			self.last_key_list = self.last_key_list or {}
			if self.last_key_list[i] ~= key then
				self.last_key_list[i] = key
				if key == 0 then
					self.node_list["Effect" .. i]:SetActive(false)
					self.node_list["Effects" .. i]:SetActive(true)
				else
					local bundle2, asset2 = ResPath.GetXingLingEffect(key)
					self.node_list["Effect" .. i]:ChangeAsset(bundle2, asset2)
					self.node_list["Effect" .. i]:SetActive(true)
					self.node_list["Effects" .. i]:SetActive(false)
				end
			end
		end
	end
end
