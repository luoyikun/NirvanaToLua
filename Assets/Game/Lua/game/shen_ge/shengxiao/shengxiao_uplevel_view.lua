ShengXiaoUpLevelView = ShengXiaoUpLevelView or BaseClass(BaseRender)
local EFFECT_CD = 1
local MOVE_TIME = 0.5
function ShengXiaoUpLevelView:UIsMove()
	UITween.MoveShowPanel(self.node_list["BtnEnter"] , Vector3(0 , 400 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right1"] , Vector3(600 , 0 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right2"] , Vector3(0 , 400 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleDown"] , Vector3(0 , -200 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["MiddleUp"] , Vector3(0 , -50 , 0 ) , MOVE_TIME )
	--UITween.MoveShowPanel(self.node_list["MiddleCenter"] , Vector3(0 , -50 , 0 ) , 0.4 )
	UITween.AlpahShowPanel(self.node_list["MiddleUp"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.AlpahShowPanel(self.node_list["NodeGoal"], true, MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["Bg"] ,Vector3(0.7 , 0.7 , 0.7 ) , MOVE_TIME )
end

function ShengXiaoUpLevelView:__init()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	--获取组件
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self.node_list["StuffCell"])
	self.node_list["AutoBuyToggle"].toggle:AddClickListener(BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0
	self.effect_cd = 0
	self.boom_effect_index = 0
	--self.old_zodiac_progress = 0
	self.point_effect_list = {}
	self.attr_cell_list = {}
	self.goal_data = {}
	local list_delegate = self.node_list["attr_list"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	--装备位置列表
	self.equip_position_list = {}
	for i = 1, 12 do
		self.node_list["item" .. i].toggle:AddClickListener(BindTool.Bind(self.ClickItem, self, i))
		self.node_list["ImgLock" .. i].button:AddClickListener(BindTool.Bind(self.ClickLock, self, i))
		local position = self.node_list["item" .. i].rect.position
		table.insert(self.equip_position_list, position)
	end
	for i = 1, 12 do
		self.node_list["Effect" .. i]:SetActive(false)
	end
	self.node_list["BtnJiHuo"].button:AddClickListener(BindTool.Bind(self.ClickLevelUp, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
	self.node_list["BtnFunc1"].button:AddClickListener(BindTool.Bind(self.OnClickMiji, self))
	--self.node_list["BtnFunc"].button:AddClickListener(BindTool.Bind(self.OpenAtrrTips, self)) --屏蔽功能
	self.node_list["BtnEnter"].button:AddClickListener(BindTool.Bind(self.ClickEnter, self))
	self.node_list["Img_chenghao"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false))
	self.node_list["Node_big_goal"].button:AddClickListener(BindTool.Bind(self.OpenTipsTitleLimit, self, false, true))
	self.node_list["BtnBuy"].button:AddClickListener(BindTool.Bind(self.OnClickOpen, self))
	self.select_index = ShengXiaoData.Instance:GetUplevelIndex()
	self.cur_level = 0
	self:FlushFlyAni(self.select_index)

	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber"])
	self.fight_text2 = CommonDataManager.FightPower(self, self.node_list["NextPower"])
	self.fight_text3 = CommonDataManager.FightPower(self, self.node_list["TxtFightNumber2"])

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end


function ShengXiaoUpLevelView:__delete()
	self.fight_text1 = nil
	self.fight_text2 = nil
	self.fight_text3 = nil

	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	for k,v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
	self.attr_cell_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	
	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self:DelePointEffectList()
	if ShengXiaoData.Instance then
		ShengXiaoData.Instance:SetUplevelIndex(1)
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	self:RemoveDelayTime()
	self.is_auto_buy_stone = 0
	self.equip_position_list = {}
	TitleData.Instance:ReleaseTitleEff(self.node_list["Img_chenghao"])
end

function ShengXiaoUpLevelView:ItemDataChangeCallback(item_id)
	if self:IsOpen() and (item_id == 27007 or item_id == 27008 or item_id == 27009 or item_id == 27010) then
		self:FlushAll()
	end
end

--自动购买强化石Toggle点击时
function ShengXiaoUpLevelView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

-- function ShengXiaoUpLevelView:OpenAtrrTips()
-- 	local attr_list, is_show_cur, is_show_next = ShengXiaoData.Instance:GetTotalAttrListAndAttrState()
-- 	local cur_attr_list = nil
-- 	local next_attr_list = nil
-- 	if is_show_cur then
-- 		cur_attr_list = attr_list
-- 		if is_show_next then
-- 			next_attr_list = ShengXiaoData.Instance:GetTotalAttrListAndAttrState(true)
-- 		end
-- 	else
-- 		next_attr_list = attr_list
-- 	end
-- 	TipsCtrl.Instance:ShowSuitAttrView(cur_attr_list, next_attr_list, ShengXiaoData.Instance:GetTotalLevel())
-- end

function ShengXiaoUpLevelView:GetNumberOfCells()
	return 3
end

function ShengXiaoUpLevelView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end
	local cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
	local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, cur_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetOrderAttrNameAndValue(one_level_attr)
	local data = {}
	if cur_level == 0 then
		cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, 1)
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
		data.show_add = cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT
		if cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
			local next_equip_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, cur_level + 1)
			local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
			local next_show_attr = CommonDataManager.GetOrderAttrNameAndValue(attr_cfg)
			data.add_attr = next_show_attr[data_index].value - data.value
		else
			data.add_attr = 0
		end
	end
	attr_cell:SetData(data)
end

function ShengXiaoUpLevelView:OnClickOpen()
	MarketData.Instance:SetPurchaseItemId(10)
	ViewManager.Instance:Open(ViewName.Market, TabIndex.market_purchase, "select_purchase", {select_index == 10})
end

function ShengXiaoUpLevelView:ClickItem(index)
	if index == self.select_index then
		return
	end
	self.select_index = index
	self:FlushRightInfo()
	self:FlushFlyAni(index)
end

function ShengXiaoUpLevelView:ClickLock(index)
	if ShengXiaoData.Instance:GetCurCanUpByIndex(index) then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_UNLOCK_REQ)
		self.boom_effect_index = index
		--self.old_zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
		self:ClickItem(index)
	else
		local cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(index, 1)
		local lase_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(index - 1, 1)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.OpenNext, lase_cfg.name, cfg.level_limit))
	end
end

function ShengXiaoUpLevelView:FlushPointEffect()
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetPointEffectCfg(self.select_index)
	if not next(point_effect_pos_cfg) then return end
	for k,v in pairs(point_effect_pos_cfg) do
		local bundle, asset = ResPath.GetUiXEffect("UI_guangdian1_01")
		local async_loader = AllocAsyncLoader(self, "point_effect_loader_" .. k)
		async_loader:Load(bundle, asset, function(prefab)
			if not IsNil(prefab) then
				local obj = ResMgr:Instantiate(prefab)
				local transform = obj.transform
				transform:SetParent(self.node_list["PointEffect"].transform, false)
				local tttt = transform:GetComponent(typeof(UnityEngine.RectTransform))
				tttt.anchoredPosition = Vector2(v.x, v.y)
				self.point_effect_list[k] = obj.gameObject
			end
		end)
	end
end

--刷新右边面板
function ShengXiaoUpLevelView:FlushRightInfo()
	local level_data_list = ShengXiaoData.Instance:GetZodiacLevelList()
	-- UI:SetGraphicGrey(self.node_list["ImgCenter"], level_data_list[self.select_index] == 0)
	UI:SetButtonEnabled(self.node_list["BtnJiHuo"], true)
	self.node_list["ImgCenter"].image:LoadSprite(ResPath.GetShengXiaoBigIcon(self.select_index))
	self.cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
	if self.cur_level > 0 then
		local txt = self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT and Language.ShengXiao.UpGrade or Language.ShengXiao.btnMaxLevel
		self.node_list["TxtBtn"].text.text = txt
		UI:SetButtonEnabled(self.node_list["BtnJiHuo"], self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT)
	else
		self.node_list["TxtBtn"].text.text = Language.ShengXiao.Active
	end
	local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level)
	local next_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
	if next_cfg and self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then 
		self.stuff_cell:SetData({item_id = next_cfg.item_id})
		-- self.node_list["StuffCell"]:SetActive(true)
	elseif cur_cfg then
		-- self.node_list["StuffCell"]:SetActive(false)
		self.stuff_cell:SetData({item_id = cur_cfg.item_id})
	end
	if cur_cfg then
		self.node_list["TxtTitle"].text.text = "Lv." .. self.cur_level .. " " ..  cur_cfg.name
	end
	if self.cur_level >= GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		self.node_list["TxtNeed"].text.text = Language.Common.MaxLevelDesc
	else
		if next_cfg and cur_cfg then
			local bag_num = ItemData.Instance:GetItemNumInBagById(next_cfg.item_id)
			local item_name = ItemData.Instance:GetItemName(cur_cfg.item_id)
			local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.item_id)
			local item_color = SOUL_NAME_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
			self.node_list["BtnBuy"]:SetActive(item_cfg.color > 3)
			-- local cost_desc = string.format(Language.ShengXiao.StuffDecs, item_color, item_name, bag_num, next_cfg.expend)
			-- local cost_desc1 = string.format(Language.ShengXiao.StuffDecs2, item_color, item_name, bag_num, next_cfg.expend)
			local cost_desc = string.format(Language.ShengXiao.StuffDecsNoName, bag_num, next_cfg.expend)
			local cost_desc1 = string.format(Language.ShengXiao.StuffDecs2NoName, bag_num, next_cfg.expend)
			self.node_list["TxtNeed"].text.text = bag_num >= next_cfg.expend and cost_desc or cost_desc1

			if self.select_index > 1 then
				local level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
				if level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
					local cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, level + 1)
					local last_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index - 1, 1)
					local limit_level = string.format(Language.ShengXiao.Levellimit, last_cfg.name, cfg.level_limit)
					if level == 0 then
						limit_level = string.format(Language.ShengXiao.Levellimit2, last_cfg.name, cfg.level_limit)
					end
					local last_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index - 1)
					if last_level < cfg.level_limit then
						self.node_list["TxtNeed"].text.text = limit_level
						UI:SetButtonEnabled(self.node_list["BtnJiHuo"], false)
					end
				end
			end
		end
	end
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local one_level_power = CommonDataManager.GetCapability(one_level_attr)
	local next_level_attr = CommonDataManager.GetAttributteNoUnderline(next_cfg)
	local next_add_power = CommonDataManager.GetCapability(next_level_attr)
	if self.fight_text1 and self.fight_text1.text then
		self.fight_text1.text.text = one_level_power
	end
	if self.cur_level == 0 then
		self.fight_text1.text.text = next_add_power - one_level_power
	end
	if self.fight_text3 and self.fight_text3.text then
		self.fight_text3.text.text = ShengXiaoData.Instance:GetShengXiaoLevelAllCap()
	end
	if self.fight_text2 and self.fight_text2.text then
		if next_add_power < one_level_power then 
			self.fight_text2.text.text = one_level_power
		else
			self.fight_text2.text.text = next_add_power - one_level_power
		end
	end
	self.node_list["attr_list"].scroller:ReloadData(0)
	local auto_toggle = self.select_index <= ShengXiaoData.SHENGXIAOCOUNT or self.cur_level ~= 0
	--self.node_list["AutoBuy"]:SetActive(auto_toggle)
	if not auto_toggle then 
		self.node_list["AutoBuyToggle"].toggle.isOn = false
	end
end

function ShengXiaoUpLevelView:FlushLeftInfo()
	local level_data_list = ShengXiaoData.Instance:GetZodiacLevelList()
	for k,v in pairs(level_data_list) do
		self.node_list["TxtLevel" .. k].text.text = v
		self.node_list["item" .. k].toggle.isOn = k == self.select_index
	end
	--local zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
	for i =1 , 12 do 
		if i <= ShengXiaoData.SHENGXIAOCOUNT then
			-- local next_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
			local level = ShengXiaoData.Instance:GetZodiacLevelByIndex(i) or 0
			local next_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(i, level + 1)
			if next_cfg then
				local bag_num = ItemData.Instance:GetItemNumInBagById(next_cfg.item_id)
				self.node_list["LockEffect" .. i]:SetActive(ShengXiaoData.Instance:GetCurCanUpByIndex(i) and level_data_list[i] == 0 and bag_num >= next_cfg.expend)
			else
				self.node_list["LockEffect" .. i]:SetActive(false)
			end
			self.node_list["ImgLock" .. i]:SetActive(false)
			self.node_list["item" .. i]:SetActive(true)
			self.node_list["ImgLevel" .. i]:SetActive(true)
			--self.node_list["BtnImprove" .. i]:SetActive(ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(i) and level_data_list[i] ~= 0)
			self.node_list["BtnImprove" .. i].image.enabled = ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(i) and level_data_list[i] ~= 0
		else
			self.node_list["ImgLock" .. i]:SetActive(false)
			self.node_list["LockEffect" .. i]:SetActive(ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(i) and level_data_list[i] == 0)
			self.node_list["item" .. i]:SetActive(true)
			self.node_list["ImgLevel" .. i]:SetActive(true)
			--self.node_list["BtnImprove" .. i]:SetActive(ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(i) and level_data_list[i] ~= 0)
			self.node_list["BtnImprove" .. i].image.enabled = ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(i) and level_data_list[i] ~= 0
		end

		local is_show, _, cfg = DisCountData.Instance:IsOpenYiZheAllBySystemId(Sysetem_Id_Jump.Sheng_Xiao)
		self.node_list["XianShiImg" .. i]:SetActive(false)
		if is_show and cfg and cfg.system_index then
			for k, v in pairs(cfg.system_index) do
				local index_list = Split(v, "|")
				for k, v in pairs(index_list) do
					if tonumber(v) == i then
						self.node_list["XianShiImg" .. i]:SetActive(true)
						break
					end
				end
			end
		end
		--UI:SetGraphicGrey(self.node_list["item" .. i], level_data_list[i] == 0)
	end
	self.node_list["img_bg"].image.fillAmount = (ShengXiaoData.Instance:GetShowRate() - 2) / 12
	if ShengXiaoData.Instance:GetCurCanUpByIndex(12) then
		self.node_list["img_bg"].image.fillAmount = 1
	end
	-- if self.boom_effect_index > 0 then
	-- 	if self.old_zodiac_progress < zodiac_progress then
	-- 		self.old_zodiac_progress = zodiac_progress
	-- 		local index = self.boom_effect_index
	-- 		self.boom_effect_index = 0
	-- 		self.node_list["Effect" .. index]:SetActive(true)
	-- 		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.node_list["Effect" .. index]:SetActive(false) end, 0.5)
	-- 	end
	-- end
	self:SetRelicInfo()
end

function ShengXiaoUpLevelView:ActivityCallBack(activity_type)
	if activity_type ~= ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI then
		return
	end
	self:SetRelicInfo()
end

function ShengXiaoUpLevelView:SetRelicInfo()
	-- self.node_list["EffectEnter"]:SetActive(RelicData.Instance:IsShowBtnEffect())
	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
	-- local max_count = RelicData.Instance:GetOneDayGatherBoxMaxNum()
	local cfg = RelicData.Instance:GetRelicCfg().other[1]
	self.node_list["EffectEnter"]:SetActive((cfg.common_box_gather_limit - gahter_count) > 0) --特效改成次數為零不顯示
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI)
	local txt = is_open and Language.Boss.HasRefresh or string.format(Language.ShengXiao.FlushTime, (cfg.common_box_gather_limit - gahter_count))
	self.node_list["TxtEnter"].text.text = txt
	
end

function ShengXiaoUpLevelView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(175)
end


function ShengXiaoUpLevelView:OnClickMiji()
	local min_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(1)
	if min_level > 0 then
		ViewManager.Instance:Open(ViewName.ShengXiaoMijiView)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ActiveFirst)
	end
end

function ShengXiaoUpLevelView:ClickLevelUp()
	if self.select_index <=ShengXiaoData.SHENGXIAOCOUNT then 
		if self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
			local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
			local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.item_id)
			if bag_num >= cur_cfg.expend then
				ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
			elseif self.node_list["AutoBuyToggle"].toggle.isOn then
				ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
			else
				local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
					--勾选自动购买
					if is_buy_quick then
						self.node_list["AutoBuyToggle"].toggle.isOn = true
						self.is_auto_buy_stone = 1
					end
				end
				local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.item_id)
				if cur_cfg.expend - bag_num == nil then
					MarketCtrl.Instance:SendShopBuy(cur_cfg.item_id, 999, 0, 1)
				else
					TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.item_id, nil, cur_cfg.expend - bag_num)
				end
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.Max)
		end
	else
		if self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
			local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
			if not cur_cfg then return end
			
			local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.item_id)
			if bag_num >= cur_cfg.expend then
				ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
			elseif self.node_list["AutoBuyToggle"].toggle.isOn and self.cur_level > 0 then
				ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
			else
				if self.cur_level > 0 then 
					local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
						MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
						--勾选自动购买
						if is_buy_quick then
							self.node_list["AutoBuyToggle"].toggle.isOn = true
							self.is_auto_buy_stone = 1
						end
					end
					local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.item_id)
					if cur_cfg.expend - bag_num == nil then
						MarketCtrl.Instance:SendShopBuy(cur_cfg.item_id, 999, 0, 1)
					else
						TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.item_id, nil, cur_cfg.expend - bag_num)
					end
				else
					SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.JiHuoKaBuZu)
				end
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.Max)
		end
	end

end

function ShengXiaoUpLevelView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ShengXiaoUpLevelView:ClickEnter()
	-- local is_shwo =  RelicData.Instance:GetIsShow()
	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
	local cfg = RelicData.Instance:GetRelicCfg().other[1]
	local num = cfg.common_box_gather_limit - gahter_count
	local complete_func = function()
		if num > 0 then self:OnClickQuick() return end
	end
	local ok_func = function()
		-- if is_shwo and num > 0 then self:OnClickQuick() return end
	--在非普通场景或者特殊的普通场景不能传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end
		ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
		ViewManager.Instance:CloseAll()
	end

	if num <= 0 then ok_func() return end
	TipsCtrl.Instance:ShowCommonExplainView(Language.ShengXiao.XingZuoYiJiExplain, ok_func, complete_func, "enter_xingzuoyiji")
end


function ShengXiaoUpLevelView:OnClickQuick()
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI, 1)
	end
	local cancel_callback = function ()
	-- --在非普通场景或者特殊的普通场景不能传送
	-- 	local scene_type = Scene.Instance:GetSceneType()
	-- 	if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
	-- 		return
	-- 	end
	-- 	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
	-- 	ViewManager.Instance:CloseAll()
		TipsCtrl.Instance:CloseQuickCompletionView()
	end
	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
	local cfg = RelicData.Instance:GetRelicCfg().other[1]
	local num = cfg.common_box_gather_limit - gahter_count
	local consume = RelicData.Instance:GetConsume(1)
	local gold = num * consume
	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI], gold,num)
	local txt1 = Language.Common.Confirm
	local txt2 = Language.Common.Cancel
	TipsCtrl.Instance:ShowQuickCompletionView("", true, str, ok_callback, cancel_callback, true, nil, txt1, txt2)
end

function ShengXiaoUpLevelView:FlushAll()
	self:FlushLeftInfo()
	self:FlushRightInfo()
	self:FlshGoalContent()
end

-- 升级时刷新特效
function ShengXiaoUpLevelView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiEffect("UI_shengjichenggong")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectRoot"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShengXiaoUpLevelView:DelePointEffectList()
	if self.point_effect_list then
		for k,v in pairs(self.point_effect_list) do
			ResMgr:Destroy(v)
			v = nil
		end
	end
	self.point_effect_list = {}
end

function ShengXiaoUpLevelView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end

	self:DelePointEffectList()
	local position = self.equip_position_list[index]
	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, position)
	--转换屏幕坐标为本地坐标
	local rect = self.node_list["Bg"]:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	self.node_list["ImgCenter"].rect:SetLocalPosition(local_pos_tbl.x, local_pos_tbl.y, 0)
	self.node_list["ImgCenter"].rect:SetLocalScale(0, 0, 0)
	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1.1, 1.1, 1.1)
	self.tweener1 = self.node_list["ImgCenter"].rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.node_list["ImgCenter"].rect:DOScale(target_scale, 0.7)
	self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end

function ShengXiaoUpLevelView:FlshGoalContent()
	self.goal_info = ShengXiaoData.Instance:GetGoalInfo()
	if self.goal_info then
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local diff_time = self.goal_info.open_system_timestamp - sever_time
		if self.goal_info.fetch_flag[0] == 0 then
			local is_show_little_goal = RuneData.Instance:IsShowJGoalRewardIcon(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
			if is_show_little_goal then
				self.node_list["Node_little_goal"]:SetActive(true)
				local goal_cfg_info = ShengXiaoData.Instance:GetItemGoalInfo(0, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
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
			local is_show_big_goal = RuneData.Instance:IsShowJGoalRewardIcon(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
			if is_show_big_goal then
				self.node_list["Node_little_goal"]:SetActive(false)
				self.node_list["Node_big_goal"]:SetActive(true)
				self.node_list["Txt_shuxing"]:SetActive(true)
				UI:SetGraphicGrey(self.node_list["Img_touxiang_frame"], not(self.goal_info.active_special_attr_flag == 1 and self.goal_info.fetch_flag[1] == 1))
				self.node_list["Effect"]:SetActive(self.goal_info.fetch_flag[1] == 0)
				local goal_cfg_info = ShengXiaoData.Instance:GetItemGoalInfo(1, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
				if goal_cfg_info then
					local attr_percent = ShengXiaoData.Instance:GetGoalAttr(ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC)
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

function ShengXiaoUpLevelView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_CHINESE_ZODIAC, is_other_item)
end

---------------------AttrItem--------------------------------
AttrItem = AttrItem or BaseClass(BaseCell)
function AttrItem:__init()
end
function AttrItem:__delete()
end
function AttrItem:OnFlush()
	if self.data == nil then return end
	self.node_list["TxtCurrAttr"].text.text = self.data.value
	self.node_list["TxtAddAttr"].text.text = self.data.add_attr
	self.node_list["NodeAddAttr"]:SetActive(self.data.show_add)
	self.node_list["TxtAttrName"].text.text = self.data.attr_name .. "："
end