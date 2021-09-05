require("game/player/luoshu/luoshu_item_view")
LuoShuView = LuoShuView or BaseClass(BaseRender)
local BAG_PAGE_COUNT = 8				-- 每页个数
local BAG_ROW = 2						-- 行数
local BAG_COLUMN = 4					-- 列数

local SHOW_HUNDUN = 0
local SHOW_WUZI = 1
local SHOW_HUAXIA = 2
local SHOW_SHENJIANG = 3

local LUOSHUMAXCOUNT = 16
local MOVE_TIME = 0.5

function LuoShuView:UIsMove()
	UITween.MoveShowPanel(self.node_list["RightView"], Vector3(500, -24, 0), MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["BtnHelp"], Vector3(-534, 500, 0), MOVE_TIME )
	self:BookAni()
end

function LuoShuView:ShenHuaMove()
	UITween.MoveShowPanel(self.node_list["HelpButton"], Vector3(-534, 500, 0), MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["ShenHuaView"], Vector3(500, -24, 0), MOVE_TIME )
	self:BookAni()
end

function LuoShuView:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemCell"])
	self.item:SetData()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerNumber"])
	self.fight_text1 = CommonDataManager.FightPower(self, self.node_list["FightPowerNumber1"])
	self.cell_list = {}
	self.show_state = SHOW_HUNDUN
	self:OnShowTab(SHOW_HUNDUN)
	self.cur_page = 0
	
	for i = 0, 3 do
		self.node_list["Button" .. i].toggle:AddClickListener(BindTool.Bind(self.OnShowTab, self, i))
	end
	self.node_list["BtnUpgrade"].button:AddClickListener(BindTool.Bind(self.OnClickUpgrade, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["HelpButton"].button:AddClickListener(BindTool.Bind(self.ClickBtnHelp, self))
	self.node_list["BtnRight"].button:AddClickListener(BindTool.Bind(self.ClickLastPage, self))
	self.node_list["BtnLeft"].button:AddClickListener(BindTool.Bind(self.ClickFirstPage, self))
	self.node_list["BtnRight1"].button:AddClickListener(BindTool.Bind(self.ClickLastPage, self))
	self.node_list["BtnLeft1"].button:AddClickListener(BindTool.Bind(self.ClickFirstPage, self))
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.node_list["ImageRollRight"].raw_image.color = Color.New(1, 1, 1, 0)
	self.node_list["ImageRollLeft"].raw_image.color = Color.New(1, 1, 1, 0)

	local event_trigger = self.node_list["Viewport"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnDrag, self))

	local event_trigger_1 = self.node_list["Draw"].event_trigger_listener
	event_trigger_1:AddDragListener(BindTool.Bind(self.OnDrag, self))
end


function LuoShuView:OnDrag(data)
	if data.delta.x > 35 then
		self:ClickFirstPage()
	end
	if data.delta.x < -35 then
		self:ClickLastPage()
	end
end

function LuoShuView:LoadCallBack()
	local tab_list = LuoShuData.Instance:GetTableIndex()
	tab_list = tab_list[1].child
	for i = 1, #tab_list do
		self.node_list["BtnTxt" .. i .. "1"].text.text = tab_list[i].seq_name
		self.node_list["BtnTxt" .. i .. "2"].text.text = tab_list[i].seq_name
	end
end

function LuoShuView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if nil ~= self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	self.cur_page = 0
	self.fight_text = nil
	self.fight_text1 = nil
end

function LuoShuView:OpenCallBack()
	self:OnShowTab(SHOW_HUNDUN)
end

function LuoShuView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(273)
end

function LuoShuView:ClickBtnHelp()
	TipsCtrl.Instance:ShowHelpTipView(274)
end

function LuoShuView:BookAni()
	UITween.AlpahShowPanel(self.node_list["LeftView"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
	UITween.ScaleShowPanel(self.node_list["LeftView"], Vector3(0.7, 0.7, 0.7))
end

function LuoShuView:OnShowTab(seq)
	if self.show_state ~= seq then
		self:BookAni()
		self.show_state = seq
	end
	self.cur_index = -1
	self.current_page = 1
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	self:FlushBagView()
	self:FlushRight()
end

function LuoShuView:OnFlush()
	self:OnFlushLuoShuView()
end

function LuoShuView:OnOpenLuoShu()
	for i = 0, 3 do
		self.node_list["Button" .. i]:SetActive(true)
	end
	self.node_list["RightView"]:SetActive(true)
	self.node_list["ShenHuaView"]:SetActive(false)
	self.node_list["BtnHelp"]:SetActive(true)
	self.node_list["HelpButton"]:SetActive(false)

	-- LuoShuData.Instance:SetLuoShuIndex(0)
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	self:OnFlushLuoShuView()

end

function LuoShuView:OnOpenShenHua()

end

function LuoShuView:OnFlushLuoShuView()
	self.node_list["ListView"].list_view:Reload()
	self:FlushRight()
end

function LuoShuView:FlushBagView(param)
	LuoShuData.Instance:SetHeShenLuoShuSelectSeq(self.show_state)
	LuoShuData.Instance:SetHeShenLuoShuSelectType(0)
	if nil ~= self.node_list["ListView"].list_view and self.node_list["ListView"].list_view.isActiveAndEnabled then
		if param == nil or self.show_state ~= SHOW_HUNDUN then
			self.cur_index = self.cur_index or -1
			if -1 == self.cur_index or self.show_state ~= SHOW_HUNDUN then
				self.node_list["ListView"].list_view:Reload()
			end
		else
			self.cur_index = -1
		end
	end
end

function LuoShuView:BagGetNumberOfCells()
	local max_index = LuoShuData.Instance:GetOpenMaxIndex()
	if max_index <= LUOSHUMAXCOUNT/2 then
		self.node_list["PageButtons"]:SetActive(false)
		return LUOSHUMAXCOUNT/2
	else
		self.node_list["PageButtons"]:SetActive(true)
		return LUOSHUMAXCOUNT
	end
end

function LuoShuView:BagRefreshCell(index, cell)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = LuoShuItemView.New(cell.gameObject)
		group_cell:SetToggleGroup(self.cell_list.toggle_group)
		self.cell_list[cell] = group_cell
	end
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN
	self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(page)

	-- local tab_index = LuoShuData.Instance:GetLuoShuIndex()
	local data = LuoShuData.Instance:GetHeShenLuoShuDataListByIndex(grid_index)
	local star_level = LuoShuData.Instance:GetLuoShuStarCount(0, data.seq, data.index)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	data = data or {}
	local cell_data = {}
	-- cell_data.tab_index = tab_index
	cell_data.star_level = star_level or -1
	cell_data.item_id = data.item_id
	cell_data.item_id_prof = data["item_id_" .. prof]
	cell_data.index = data.index
	cell_data.seq = data.seq
	cell_data.image_id = data.image_id

	group_cell:SetData(cell_data, true)
	group_cell:ListenClick(BindTool.Bind(self.OnClickItem, self, cell_data, cell))
	if self.cur_page ~= page then
		self.cur_page = page
		self:RollLuoShu(page)
	end
end

function LuoShuView:RollLuoShu(roll_type)
	local left_red = LuoShuData.Instance:RemindHeShenLuoShuPageRed(nil, 0)
	local right_red = LuoShuData.Instance:RemindHeShenLuoShuPageRed(nil, 1)
	self.node_list["First_Red"]:SetActive(left_red ~= 0 and self.cur_page ~= 0)
	self.node_list["Next_Red"]:SetActive(right_red ~= 0 and self.cur_page ~= 1)
	if roll_type == 0 then --1：向后翻，0：向前翻
		self.node_list["ListView"]:SetActive(false)
		self.node_list["ImageRollLeft"].raw_image.color = Color.New(1, 1, 1, 1)
		self.node_list["ImageRollRight"].raw_image.color = Color.New(1, 1, 1, 0)
		self.node_list["ImageRollLeft"].rect:SetLocalScale(-1, 1, 1)
		local func3 = function()
			self.node_list["ListView"]:SetActive(true)
			self.node_list["ImageRollLeft"].raw_image.color = Color.New(1, 1, 1, 0)
			self.node_list["ImageRollRight"].raw_image.color = Color.New(1, 1, 1, 0)
			self.node_list["ImageRollRight"].rect:SetLocalScale(1, 1, 1)
		end
		UITween.ScaleShowPanel(self.node_list["ImageRollLeft"], Vector3(1, 1, 1), 0.2, DG.Tweening.Ease.InExpo, func3)
	else
		self.node_list["ImageRollRight"].raw_image.color = Color.New(1, 1, 1, 1)
		self.node_list["ImageRollLeft"].raw_image.color = Color.New(1, 1, 1, 0)
		self.node_list["ImageRollRight"].rect:SetLocalScale(-1, 1, 1)
		self.node_list["ListView"]:SetActive(false)
		local func3 = function()
			self.node_list["ImageRollRight"].raw_image.color = Color.New(1, 1, 1, 0)
			self.node_list["ImageRollLeft"].raw_image.color = Color.New(1, 1, 1, 0)
			self.node_list["ListView"]:SetActive(true)
			self.node_list["ImageRollLeft"].rect:SetLocalScale(1, 1, 1)
		end
		UITween.ScaleShowPanel(self.node_list["ImageRollRight"], Vector3(1, 1, 1), 0.2, DG.Tweening.Ease.InExpo, func3)
	end
end

function LuoShuView:OnClickItem(cell_data, cell)
	if cell_data.tab_index == 1 then
		self.item_index = cell_data.index +1
	end
end

function LuoShuView:FlushRight()
	for i = 0, 3 do 
		local is_red = LuoShuData.Instance:RemindHeShenLuoShu(i)
		self.node_list["Remind" .. i]:SetActive(is_red ~= 0)
	end

	local right_red = LuoShuData.Instance:RemindHeShenLuoShuPageRed(nil, 1)
	local left_red = LuoShuData.Instance:RemindHeShenLuoShuPageRed(nil, 0)
	self.node_list["First_Red"]:SetActive(left_red ~= 0 and self.cur_page ~= 0)
	self.node_list["Next_Red"]:SetActive(right_red ~= 0 and self.cur_page ~= 1)

	for i = 1, 3 do
		self.node_list["NowAttr" .. i]:SetActive(false)
		self.node_list["NowValue" .. i]:SetActive(false)
		self.node_list["NextAttr" .. i]:SetActive(false)
		self.node_list["NextValue" .. i]:SetActive(false)
	end
	self.desc = ""
	local active_num = LuoShuData.Instance:GettHeShenLuoShuActiveNum()
	local total_cfg, next_total_cfg = LuoShuData.Instance:GetHeShenLuoShuSuitAttrCfg(active_num)

	local cur_attr = CommonDataManager.GetOrderAttributte(total_cfg)
	local next_attr = CommonDataManager.GetOrderAttributte(next_total_cfg)
	self.node_list["NextAttribute"]:SetActive(nil ~= next_total_cfg)
	if nil ~= cur_attr and nil ~= next(cur_attr) then
		local index = 0
		for k, v in pairs(cur_attr) do
			local attr_name = Language.Player.LuoShuAttrName[v.key]
			local per_attr_name = Language.Player.PerAttrName[v.key]
			if nil ~= attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NowAttr" .. index]:SetActive(true)
				self.node_list["NowValue" .. index]:SetActive(true)
				self.node_list["NowAttr" .. index].text.text = attr_name .. ":"
				self.node_list["NowValue" .. index].text.text = v.value
			end
			if nil ~= per_attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NowAttr" .. index]:SetActive(true)
				self.node_list["NowValue" .. index]:SetActive(true)
				self.node_list["NowAttr" .. index].text.text = per_attr_name .. ":"
				self.node_list["NowValue" .. index].text.text = v.value / 100 .. "%"
			end
		end
		local nownum = active_num >= total_cfg.suit_num and ToColorStr(active_num, TEXT_COLOR.GREEN_4) or ToColorStr(active_num, TEXT_COLOR.RED) 
		local num_text1 = nownum .. ToColorStr("/" ..total_cfg.suit_num, TEXT_COLOR.GREEN_4)
		self.node_list["TextNowNum"].text.text = string.format(Language.Player.GetLuoShu, num_text1)
	else
		local index = 0
		for k, v in pairs(next_attr) do
			local attr_name = Language.Player.LuoShuAttrName[v.key]
			local per_attr_name = Language.Player.PerAttrName[v.key]
			if nil ~= attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NowAttr" .. index]:SetActive(true)
				self.node_list["NowValue" .. index]:SetActive(true)
				self.node_list["NowAttr" .. index].text.text = attr_name .. ":"
				self.node_list["NowValue" .. index].text.text = 0
			end
			if nil ~= per_attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NowAttr" .. index]:SetActive(true)
				self.node_list["NowValue" .. index]:SetActive(true)
				self.node_list["NowAttr" .. index].text.text = per_attr_name .. ":"
				self.node_list["NowValue" .. index].text.text = 0.0 .. "%"
			end
		end
		self.node_list["TextNowNum"].text.text = Language.Player.LuoShuShuXing, num_text1
	end
	if nil ~= next_attr and nil ~= next(next_attr) then
		local index = 0
		for k, v in pairs(next_attr) do
			local attr_name = Language.Player.LuoShuAttrName[v.key]
			local per_attr_name = Language.Player.PerAttrName[v.key]
			if nil ~= attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NextAttr" .. index]:SetActive(true)
				self.node_list["NextValue" .. index]:SetActive(true)
				self.node_list["NextAttr" .. index].text.text = attr_name .. ":"
				self.node_list["NextValue" .. index].text.text = v.value
			end
			if nil ~= per_attr_name and v.value > 0 then
				index = index + 1
				self.node_list["NextAttr" .. index]:SetActive(true)
				self.node_list["NextValue" .. index]:SetActive(true)
				self.node_list["NextAttr" .. index].text.text = per_attr_name .. ":"
				self.node_list["NextValue" .. index].text.text = v.value / 100 .. "%"
			end
		end
		local nownum = active_num >= next_total_cfg.suit_num and ToColorStr(active_num, TEXT_COLOR.GREEN_4) or ToColorStr(active_num, TEXT_COLOR.RED) 
		local num_text2 = nownum .. ToColorStr("/" ..next_total_cfg.suit_num, TEXT_COLOR.GREEN_4)
		self.node_list["TextNextNum"].text.text = string.format(Language.Player.NextGetLuoShu, num_text2)
	end

	local total_attr = LuoShuData.Instance:GetHeShenLuoShuSeqAttr()
	local all_attr = CommonDataManager.GetOrderAttributte(total_attr)
	local total_attr_index = 0
	for k, v in pairs(all_attr) do
		local attr_name = Language.Common.AttrName[v.key]
		if nil ~= attr_name and v.value > 0 then
			total_attr_index = total_attr_index + 1
			self.node_list["BaseAttribute"]:SetActive(true)
			self.node_list["TxtTotalAttr" .. total_attr_index]:SetActive(true)
			self.node_list["TxtValue" .. total_attr_index]:SetActive(true)
			self.node_list["TxtTotalAttr" .. total_attr_index].text.text = attr_name .. ":"
			self.node_list["TxtValue" .. total_attr_index].text.text = v.value
		end
	end
	if total_attr_index == 0 then
		for i = 1, 3 do
			local attr_name = Language.Player.LuoShuTotalAttr[i]
			self.node_list["TxtTotalAttr" .. i]:SetActive(true)
			self.node_list["TxtValue" .. i]:SetActive(true)
			self.node_list["TxtTotalAttr" .. i].text.text = attr_name .. ":"
			self.node_list["TxtValue" .. i].text.text = 0
		end
	end
	local taozhuanpower = CommonDataManager.GetCapabilityCalculation(total_cfg)
	local fightpower = CommonDataManager.GetCapabilityCalculation(total_attr)
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = fightpower + taozhuanpower
	end
end

function LuoShuView:OnClickUpgrade()
	local data_list = LuoShuData.Instance:GetHeShenLuoShuAllUpgradeDataByTypeAndSeq()
	if data_list[self.item_index] then
		LuoShuCtrl.Instance:SendHeShenLuoShuReq(HESHENLUOSHU_REQ_TYPE.HESHENLUOSHU_REQ_TYPE_DECOMPOSE, data_list[self.item_index].item_id)
	end
end

function LuoShuView:ClickLastPage()
	local max_index = LuoShuData.Instance:GetOpenMaxIndex()
	if max_index <= LUOSHUMAXCOUNT/2 then
		return
	end
	if self.cur_page == 0 then
		self.cur_page = 1
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(1)
		self:RollLuoShu(1)
	end
end

function LuoShuView:ClickFirstPage()
	if self.cur_page == 1 then
		self.cur_page = 0
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
		self:RollLuoShu(0)
	end
end


