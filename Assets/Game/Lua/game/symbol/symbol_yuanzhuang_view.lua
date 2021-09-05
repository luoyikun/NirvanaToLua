--灵药 YuanzhuangContent
require("game/symbol/symbol_yuanzhuang_recyle_view")
SymbolYuanzhuangView = SymbolYuanzhuangView or BaseClass(BaseRender)

--常量定义
local BAG_MAX_GRID_NUM = 140			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 4					-- 列数

local EQUIP_COUNT = 6					-- 元素之灵装备数
local SYMBOL_COUNT = 5					-- 元素之灵的个数

local BUY_ITEM_COUNT = 8				-- 刷新界面的item个数

function SymbolYuanzhuangView:__init(instance)
	self.is_auto = false
	self.stuff_item_id = 0
	self.model_res = 0
	self.free_shuaxin_times = 0
	self.equip_cells = {} 				--元装的6个装备
	self.buy_list = {}					--刷新界面的item个数
	self.bag_cell_list = {} 			--背包里的ItemCell格子表

	self.bag_cell = {}
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	-- self.node_list["ListView"].list_view:JumpToIndex(0)
	-- self.node_list["ListView"].list_view:Reload()

	self.toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		if nil ~= self.node_list["PageToggle_" .. i] then
			node = U3DObject(self.node_list["PageToggle_" .. i].gameObject, self.node_list["PageToggle_" .. i])
			if node then
				self.toggle_list[i] = node
			end
		end
	end

	self.consum_cell = ItemCell.New()
	self.consum_cell:SetInstanceParent(self.node_list["Consum_Img"])

	for i = 1, EQUIP_COUNT do
		local child = self.node_list["Equip_" .. i].transform:GetChild(0)
		self.equip_cells[i] = YuanshuEquipCell.New(child)
	end

	for i = 1, BUY_ITEM_COUNT do
		self.buy_list[i] = ShuaxinCell.New(self.node_list["BuyItem_" .. i])
	end

	self.node_list["TxtFenjie"].text.text = Language.Symbol.FenjieBtnTxt[1]
	self:SetIsAuto(false)

	self.star_list = {}
	for i = 1, 5 do
		self.star_list[i] = self.node_list["ImgStar"..i].image
	end

	self.recycle_view = YuanzhuangRecycleView.New(self.node_list["RecyclePanel"], instance, self)

	local other_cfg = SymbolData.Instance:GetSymbolOtherConfig()
	if other_cfg then
		self.node_list["TxtCostNum"].text.text = other_cfg.shop_refresh_need_gold
	end

	self.node_list["BtnYijian"].button:AddClickListener(BindTool.Bind(self.YijianClick, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.HelpClick, self))
	self.node_list["BtnHelp2"].button:AddClickListener(BindTool.Bind(self.HelpClick2, self))
	self.node_list["BtnShuaxin"].button:AddClickListener(BindTool.Bind(self.ShuaxinClick, self))
	self.node_list["BtnRecycle"].button:AddClickListener(BindTool.Bind(self.OnClickDecompose, self))
	self.node_list["ImgClose"].button:AddClickListener(BindTool.Bind(self.OnClickDecompose, self))
	self.node_list["Toggle_Yuanzhuang"].toggle:AddClickListener(BindTool.Bind(self.OnToggleYuanZhuang, self))
	self.node_list["Toggle_Shuaxin"].toggle:AddClickListener(BindTool.Bind(self.OnToggleShuaXin, self))

	self.cell_list = {}
	self.left_select = 0
	self:InitLeftScroller()
	self.global_event = GlobalEventSystem:Bind(OtherEventType.FLUSH_ELEMENT_BAG_GRID, BindTool.Bind(self.YuanZhuangRightFlush, self))
end

function SymbolYuanzhuangView:__delete()
	for i,v in ipairs(self.bag_cell_list) do
		v:DeleteMe()
	end
	self.bag_cell_list = {}

	for i,v in ipairs(self.buy_list) do
		v:DeleteMe()
	end
	self.buy_list = {}

	if self.consum_cell then
		self.consum_cell:DeleteMe()
		self.consum_cell = nil
	end
	
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.equip_cells) do
		v:DeleteMe()
	end
	self.equip_cells = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.recycle_view then
		self.recycle_view:DeleteMe()
		self.recycle_view = nil
	end

	if nil ~= self.global_event then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end

	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.on_diamond_remind then
		GlobalTimerQuest:CancelQuest(self.on_diamond_remind)
		self.on_diamond_remind = nil
	end
end

function SymbolYuanzhuangView:InitLeftScroller()
	local delegate = self.node_list["LeftList"].list_simple_delegate
	-- 生成数量
	self.left_data = SymbolData.Instance:GetElementHeartOpencCfg()
	delegate.NumberOfCellsDel = function()
		return #self.left_data or 0
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  YuanshuLeftTypeCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell:SetToggleGroup(self.node_list["LeftList"].toggle_group)
		end
		target_cell:SetData(self.left_data[data_index + 1])
		target_cell:SetIndex(data_index)
		target_cell:IsOn(data_index == self.left_select)
		target_cell:SetClickCallBack(BindTool.Bind(self.ClickLeftListCell, self, target_cell))
	end
end

function SymbolYuanzhuangView:ClickLeftListCell(cell)
	self.left_select = cell.index
	self:YuanZhuangFlush()
end

function SymbolYuanzhuangView:OpenCallBack()
	self.model_res = 0
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event, true)
	end
	self:ChangeDecomposeState(false)
end

function SymbolYuanzhuangView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self:SetIsAuto(false)
end

function SymbolYuanzhuangView:ItemDataChangeCallback()
	if self.node_list["Toggle_Yuanzhuang"].toggle.isOn then
		self:YuanZhuangFlush()
	end
end

function SymbolYuanzhuangView:OnFlush(param_t)
	if self.node_list["Toggle_Yuanzhuang"].toggle.isOn then
		--刷新元装界面
		self:YuanZhuangFlush()
	elseif self.node_list["Toggle_Shuaxin"].toggle.isOn then
		--刷新商店界面
		self:ShuaXinFlush()
	end

	if nil == self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 0.5)
	end
end

--元装界面
function SymbolYuanzhuangView:YuanZhuangFlush()
	self:YuanZhuangLeftFlush()
	self:YuanZhuangRightFlush()
end

--元装中间
function SymbolYuanzhuangView:YuanZhuangLeftFlush()
	if self.node_list["LeftList"].scroller.isActiveAndEnabled then
		self.node_list["LeftList"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local info = SymbolData.Instance:GetElementEquipDataList(self.left_select)

	local equip_total_attr = SymbolData.Instance:GetYuanzhuangEquipLevelAttr(info.real_level - 1)

	for i = 1, EQUIP_COUNT do
		self.equip_cells[i]:SetData(info.equip_data_list[i])

		local equip_cfg = SymbolData.Instance:GetEquipmentAttrCfg(info.equip_data_list[i].item_id)
		if 1 == info.equip_data_list[i].active_flag and nil ~= equip_cfg then
			local equip_attr = CommonDataManager.GetAttributteByClass(equip_cfg)
			equip_total_attr = CommonDataManager.AddAttributeAttr(equip_total_attr, equip_attr)
		end
	end

	local level_cfg = SymbolData.Instance:GetElementEquipLevelCfg(info.real_level)
	if not level_cfg then return end

	self.stuff_item_id = level_cfg.comsume_item_id
	local num = ItemData.Instance:GetItemNumInBagById(level_cfg.comsume_item_id)

	for k, v in ipairs(self.star_list) do
		if k > level_cfg.level then
			v:LoadSprite("uis/images_atlas", "icon_star_2.png")
		else
			v:LoadSprite("uis/images_atlas", "icon_star_1.png")
		end
	end

	local next_cfg = SymbolData.Instance:GetElementEquipLevelCfg(info.real_level + 5)
	self.node_list["Img_addpercent"]:SetActive(nil ~= next_cfg)
	self.node_list["Nodecur_percent"]:SetActive(nil == next_cfg)
	self.node_list["Txt_percent"].text.text = (level_cfg.attr_total_percent / 100) .. "%"
	self.node_list["Txt_addpercent"].text.text = (level_cfg.attr_total_percent / 100) .. "%"

	if next_cfg then
		self.node_list["TxtNextPercent"].text.text = (next_cfg.attr_total_percent / 100) .. "%"
	end

	local txt_color = num >= level_cfg.comsume_item_num and TEXT_COLOR.GREEN_4 or TEXT_COLOR.RED_4
	self.node_list["TxtNum"].text.text = ("<color=" .. txt_color .. ">" ..  num .. "</color>") .. " / " .. level_cfg.comsume_item_num
	self.node_list["SliderUpgrade"].slider.value = (info.upgrade_progress / level_cfg.upgrade_progress)
	self.node_list["TxtProg"].text.text = (info.upgrade_progress .. "/" ..  level_cfg.upgrade_progress)

	local attribute = CommonDataManager.GetAttributteByClass(level_cfg)
	attribute = CommonDataManager.AddAttributeAttr(equip_total_attr, attribute)
	self.node_list["TxtZhanliNum"].text.text = (math.floor(CommonDataManager.GetCapability(attribute) * (1 + level_cfg.attr_total_percent / 10000)))

	self.consum_cell:SetData({item_id = level_cfg.comsume_item_id, num = 1, is_bind = 0})

	local element_info = SymbolData.Instance:GetElementInfo(self.left_select)
	self:FlushModel(element_info)
	self.node_list["TxtGradeStr"].text.text = ("<color=" .. SOUL_NAME_COLOR[level_cfg.grade] .. ">" .. level_cfg.name .. "</color>")
end

function SymbolYuanzhuangView:FlushModel(info)
	if info and info.element_level > 0 then
		if nil == self.model then
			self.model = RoleModel.New()
			self.model:SetDisplay(self.node_list["Display"].ui3d_display)
		end
		local model_res = SymbolData.ELEMENT_MODEL[info.wuxing_type]
		if self.model_res ~= model_res then
			self.model_res = model_res
			local asset, bundle = ResPath.GetSpiritModel(self.model_res)
			self.model:SetMainAsset(asset, bundle)
		end
	elseif self.model then
		self.model_res = 0
		self.model:ClearModel()
	end
end

function SymbolYuanzhuangView:FlushNextTime()
	local shop_info = SymbolData.Instance:GetElementShopInfo()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local flush_time_countdown = shop_info.next_refresh_timestamp - server_time

	if self.node_list["TxtFlushTime"] then
		self.node_list["TxtFlushTime"].text.text = string.format(Language.Symbol.ShopFlushTimeStr, TimeUtil.FormatSecond2Str(flush_time_countdown))
	end
end

--元装右边 更新
function SymbolYuanzhuangView:YuanZhuangRightFlush()
	local info = SymbolData.Instance:GetElementInfo(self.left_select)
	self.bag_list = SymbolData.Instance:GetAllEquipmentItemList()
	local equip_info = info.equip_param
	if nil ~= self.node_list["ListView"].list_view and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:JumpToIndex(0)
		self.node_list["ListView"].list_view:Reload()
	end
end

--商店界面 更新
function SymbolYuanzhuangView:ShuaXinFlush()
	local shop_info = SymbolData.Instance:GetElementShopInfo()
	local other_cfg = SymbolData.Instance:GetSymbolOtherConfig()
	if not shop_info or not other_cfg then return end

	for i = 1, BUY_ITEM_COUNT do
		self.buy_list[i]:SetData(shop_info.shop_item_list[i - 1])
	end

	local free_times = other_cfg.shop_refresh_free_times - shop_info.today_shop_flush_times
	if free_times < 0 then free_times = 0 end
	self.free_shuaxin_times = free_times
	self.node_list["TxtShuaxinNum"].text.text = free_times
end

function SymbolYuanzhuangView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function SymbolYuanzhuangView:BagRefreshCell(index, obj)
	self.cell = self.bag_cell_list[obj]
	if nil == self.cell then
		self.cell = ItemCell.New(obj)
		self.cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.bag_cell_list[obj] = self.cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	-- local data_list = SymbolData.Instance:GetAllEquipmentItemList()
	local data = self.bag_list[grid_index + 1] or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind

	self.cell:SetIconGrayScale(false)
	self.cell:ShowQuality(nil ~= cell_data.item_id)
	local recycle_list = SymbolData.Instance:GetRecycleItemDataList()
	for k,v in pairs(recycle_list) do
		if cell_data.item_id == v.item_id and cell_data.index == v.index then
			self.cell:SetIconGrayScale(true)
			self.cell:ShowQuality(false)
		end
	end

	self.cell:SetData(cell_data, true)
	self.cell:SetHighLight(false)
	self.cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, self.cell))
	self.cell:SetInteractable(true)
end

--点击格子事件
function SymbolYuanzhuangView:HandleBagOnClick(data, cell)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	cell:SetHighLight(not self.is_recyle)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		if self.is_recyle and SymbolData.Instance:CanDecomposeItem(data.item_id) then
			if cell:GetIconGrayScaleIsGray() then
				TipsCtrl.Instance:ShowSystemMsg(Language.Symbol,Lock)
			else
				SymbolData.Instance:AddItemToRecycleList(data)
				cell:SetIconGrayScale(true)
				self:YuanZhuangRightFlush()
				self.recycle_view:FlushRecycleView()
			end
		else
			TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
		end
	end
end

--一键升级
function SymbolYuanzhuangView:YijianClick()
	if self.is_auto then
		self:SetIsAuto(false)
		return
	end
	self:SetIsAuto(true)
	self:DoUpGrade()
end

--一键升级
function SymbolYuanzhuangView:DoUpGrade()
	if ItemData.Instance:GetItemNumInBagById(self.stuff_item_id) <= 0 and not self.node_list["AutoBuyToggle"].toggle.isOn then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.stuff_item_id]
		if item_cfg then
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				if is_buy_quick then
					self.node_list["AutoBuyToggle"].toggle.isOn = true
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, self.stuff_item_id, nofunc, 1)
			self:SetIsAuto(false)
			return
		end
	end
	local auto_buy = self.node_list["AutoBuyToggle"].toggle.isOn and 1 or 0
	SymbolCtrl.Instance:SendEquipUpgrade(self.left_select, auto_buy)
	-- self.jinjie_next_time = Status.NowTime +  0.1
end

function SymbolYuanzhuangView:AutoUpGradeOnce()
	if self.is_auto then
		self:DoUpGrade()
	end
end

function SymbolYuanzhuangView:SymbolYuanzhuangUpgradeResult(result)
	if 0 == result then
		self:SetIsAuto(false)
	else
		self:AutoUpGradeOnce()
	end
end

-- 设置进阶按钮状态
function SymbolYuanzhuangView:SetIsAuto(value)
	self.is_auto = value
	self.node_list["TxtYijian"].text.text = self.is_auto and Language.Symbol.YijianBtnTxt[2] or Language.Symbol.YijianBtnTxt[1]
end

--刷新 点击
function SymbolYuanzhuangView:OnClickDecompose()
	self:ChangeDecomposeState(not self.is_recyle)
end

--刷新 点击
function SymbolYuanzhuangView:ChangeDecomposeState(value)
	if self.is_recyle ~= value then
		SymbolData.Instance:EmptyRecycleList()
		self.is_recyle = value
		self.node_list["RecyclePanel"]:SetActive(self.is_recyle)
		self.node_list["TxtFenjie"].text.text = (self.is_recyle and Language.Symbol.FenjieBtnTxt[2] or Language.Symbol.FenjieBtnTxt[1])
		if value then
			self.recycle_view:OpenCallBack()
		end
		self:YuanZhuangRightFlush()
	end
end

--刷新 点击
function SymbolYuanzhuangView:ShuaxinClick()
	local has_rare = false
	local shop_info = SymbolData.Instance:GetElementShopInfo()

	for i = 1, BUY_ITEM_COUNT do
		local item_data = shop_info.shop_item_list[i - 1]
		local shop_cfg = SymbolData.Instance:GetElementShopCfg(item_data.shop_seq)
		if shop_cfg then
			if 1 == shop_cfg.is_rare and 0 == item_data.has_buy then
				has_rare = true
				break
			end
		end
	end

	if has_rare then
		self:OnRareRemind()
	else
		self:OnDiamondRemind()
	end
end

function SymbolYuanzhuangView:OnDiamondRemind()
	local fun = function()
		SymbolCtrl.Instance:SendShopRefreshtReq()
	end

	if SettingData.Instance:GetCommonTipkey("flush_yuanzhuang_item") or self.free_shuaxin_times > 0 then
		fun()
		return
	end

	local other_cfg = SymbolData.Instance:GetSymbolOtherConfig()
	if other_cfg then
		local str = string.format(Language.Symbol.RefreshItemTips, other_cfg.shop_refresh_need_gold)
		TipsCtrl.Instance:ShowCommonTip(fun, nil, str, nil, nil, true, false, "flush_yuanzhuang_item")
	end
end

function SymbolYuanzhuangView:OnRareRemind()
	local fun = function ()
		if not self.on_diamond_remind then
			self.on_diamond_remind = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnDiamondRemind, self), 0)
		end
	end

	if SettingData.Instance:GetCommonTipkey("flush_yuanzhuang_item_rare") then
		fun()
		return
	end

	TipsCtrl.Instance:ShowCommonTip(fun, nil, Language.Symbol.ShopRareRemind, nil, nil, true, false, "flush_yuanzhuang_item_rare")
end

--帮忙 点击
function SymbolYuanzhuangView:HelpClick()
	local tips_id = 241
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function SymbolYuanzhuangView:HelpClick2()
	local tips_id = 244
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function SymbolYuanzhuangView:OnToggleYuanZhuang()
	self:SetIsAuto(false)
	self:YuanZhuangFlush()
	self:ChangeDecomposeState(false)
end

function SymbolYuanzhuangView:OnToggleShuaXin()
	self:SetIsAuto(false)
	self:ShuaXinFlush()
end

---------------------------------------------------------------
--滚动条格子
YuanshuLeftTypeCell = YuanshuLeftTypeCell or BaseClass(BaseCell)

function YuanshuLeftTypeCell:__init()
	self.node_list["ToggleCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function YuanshuLeftTypeCell:__delete()

end

function YuanshuLeftTypeCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function YuanshuLeftTypeCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function YuanshuLeftTypeCell:Lock(value)
	self.node_list["ToggleCell"].toggle.interactable = not value
	self.node_list["ImgIcon"]:SetActive(not value) 
	self.node_list["BtnLock"]:SetActive(value)
end

function YuanshuLeftTypeCell:OnFlush()
	if nil == self.data then return end
	local info = SymbolData.Instance:GetElementInfo(self.data.id)

	if info and info.element_level > 0 then
		self:Lock(false)
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_" .. info.wuxing_type))
		self.node_list["ImgRed"]:SetActive(SymbolData.Instance:GetOneSymbolYuanZhuangRemind(self.data.id))
		local equip_info = SymbolData.Instance:GetElementEquipDataList(self.data.id)
		if equip_info then
			local level_cfg = SymbolData.Instance:GetElementEquipLevelCfg(equip_info.real_level)
			if level_cfg then
				local name = string.format(Language.Symbol.YuanZhuangLv, level_cfg.name, level_cfg.level)
				self.node_list["TxtName"].text.text = "<color=" .. SOUL_NAME_COLOR[level_cfg.grade] .. ">" .. name .. "</color>"
			end
		end
	else
		self:Lock(true)
		self.node_list["ImgRed"]:SetActive(false)
		self.node_list["ImgIcon"].image:LoadSprite(ResPath.GetSymbolImage("yuansu_icon_lock"))
		self.node_list["TxtName"].text.text = ""
	end
end

-------------------------物体名YuanZhuangEquipCell--------------------------------------
--装备格子
YuanshuEquipCell = YuanshuEquipCell or BaseClass(BaseRender)

function YuanshuEquipCell:__init(instance)
	self.node_list["NodeEquipCell"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["BtnPlus"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function YuanshuEquipCell:__delete()

end

function YuanshuEquipCell:SetData(data)
	self.data = data

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then
		self.node_list["ItemIcon"]:SetActive(false)
		self.node_list["ImgLock"]:SetActive(true)
		self.node_list["BtnPlus"]:SetActive(false)
		return
	end

	self.node_list["ImgLock"]:SetActive(false)
	self.node_list["ItemIcon"]:SetActive(true)

	local num = ItemData.Instance:GetItemNumInBagById(data.item_id)
	self.node_list["BtnPlus"]:SetActive(0 == data.active_flag and num > 0)

	UI:SetGraphicGrey(self.node_list["ItemIcon"], 0 == data.active_flag)

	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	self.node_list["ItemIcon"].image:LoadSprite(bundle,asset)
end

function YuanshuEquipCell:OnClick()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local num = ItemData.Instance:GetItemNumInBagById(self.data.item_id)
	if 0 == self.data.active_flag and num > 0 then
		SymbolCtrl.Instance:SendPutOnEquipment(self.data.element_id, self.data.index)
		return
	end

	TipsCtrl.Instance:OpenItem({item_id = self.data.item_id})
end

-------------------------刷新界面的item格子BuyItem_i-----------------------------

ShuaxinCell = ShuaxinCell or BaseClass(BaseCell)

function ShuaxinCell:__init()
	self.node_list["ImgBlock"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function ShuaxinCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShuaxinCell:OnFlush()
	if nil == self.data then return end
	local cfg = SymbolData.Instance:GetElementShopCfg(self.data.shop_seq)
	if nil == cfg then return end

	if self.item_cell == nil then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self.node_list["Item_Img"])
	end

	self.item_cell:SetData(cfg.reward_item)
	if cfg.is_rare == 1 then
		local bunble, asset = ResPath.GetItemActivityEffect()
		self.item_cell:SetSpecialEffect(bunble, asset)
	end
	
	self.item_cell:ShowSpecialEffect(cfg.is_rare == 1)
	self.node_list["TxtCost"].text.text = cfg.cost_gold
	self.node_list["ImgTopLeft"]:SetActive(cfg.is_rare == 1)

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.reward_item.item_id)
	if not item_cfg then return end

	self.node_list["TxtName"].text.text = ("<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>")
	self.node_list["ImgIsBuyBg"]:SetActive(0 ~= self.data.has_buy)
end

function ShuaxinCell:OnClick()
	if nil == self.data then return end

	local fun = function()
		SymbolCtrl.Instance:SendShopBuyReq(self.data.index)
	end

	if SettingData.Instance:GetCommonTipkey("buy_yuanzhuang_item") then
		fun()
		return
	end

	local cfg = SymbolData.Instance:GetElementShopCfg(self.data.shop_seq)
	if nil == cfg then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(cfg.reward_item.item_id)
	if not item_cfg then return end

	local str = string.format(Language.Symbol.BuyItemTips, cfg.cost_gold, item_cfg.name)
	TipsCtrl.Instance:ShowCommonTip(fun, nil, str, nil, nil, true, false, "buy_yuanzhuang_item")
end
