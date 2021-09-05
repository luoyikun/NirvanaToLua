RuneExchangeView = RuneExchangeView or BaseClass(BaseRender)

local COLUMN = 4
local MOVE_TIME = 0.5

function RuneExchangeView:UIsMove()
	UITween.MoveShowPanel(self.node_list["Panel"] , Vector3(0 , -700 , 0 ) , MOVE_TIME )
end

function RuneExchangeView:__init()

	self.list_data = {}
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function RuneExchangeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function RuneExchangeView:InitView()
	GlobalTimerQuest:AddDelayTimer(function()
		self.list_data = RuneData.Instance:GetExchangeList()
		self.node_list["ListView"].scroller:ReloadData(0)
	end, 0)
end

function RuneExchangeView:FlushView()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function RuneExchangeView:GetCellNumber()
	return math.ceil(#self.list_data / COLUMN)
end

function RuneExchangeView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneExchangeGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = data_index * COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)

		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneExchangeView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	--层数不够
	local pass_layer = RuneData.Instance:GetPassLayer()
	local need_pass_layer = data.in_layer_open
	if pass_layer < need_pass_layer then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Rune.OpenSlotDes, need_pass_layer))
		return
	end

	--符文碎片不足
	local have_suipian = RuneData.Instance:GetSuiPian()
	local need_suipian = data.convert_consume_rune_suipian
	if have_suipian < need_suipian then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rune.SuiPianNotEnough)
		return
	end

	local function ok_callback()
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_CONVERT, data.item_id)
	end
	local level_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[data.type] or ""
	local name_str = ToColorStr(level_name, level_color)
	local des = string.format(Language.Rune.SuiPianExchange, need_suipian, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("rune_exchange", des, ok_callback)
end

------------------RuneExchangeGroupCell----------------------
RuneExchangeGroupCell = RuneExchangeGroupCell or BaseClass(BaseRender)
function RuneExchangeGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RuneExChangeItemCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end

end

function RuneExchangeGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneExchangeGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneExchangeGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneExchangeGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneExchangeGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

--------------------RuneExChangeItemCell----------------------
RuneExChangeItemCell = RuneExChangeItemCell or BaseClass(BaseCell)
function RuneExChangeItemCell:__init()
	self.node_list["ExchangeItem"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["Power"], "FightPower3")
end

function RuneExChangeItemCell:__delete()
	self.fight_text = nil
end

function RuneExChangeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id > 0 then
		self.node_list["ImageRes"].image:LoadSprite(ResPath.GetItemIcon(self.data.item_id))
		--展示特殊特效
		if self.node_list["ShowSpecialEffect"] then
			if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.node_list["ShowSpecialEffect"]:SetActive(true)
			else
				self.node_list["ShowSpecialEffect"]:SetActive(false)
			end
		end
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	self.node_list["TiteName"].text.text = level_str

	local have_suipian = RuneData.Instance:GetSuiPian()
	local need_suipian = self.data.convert_consume_rune_suipian
	local color = "#fde45c"
	local suipian_str = ""
	if have_suipian < need_suipian then
		color = TEXT_COLOR.RED_4
	end
	suipian_str = ToColorStr(need_suipian, color)
	self.node_list["SuiPian"].text.text = suipian_str

	local pass_layer = RuneData.Instance:GetPassLayer()
	local need_pass_layer = self.data.in_layer_open
	local pass_des = ""
	if pass_layer < need_pass_layer then
		pass_des = string.format(Language.Rune.OpenSlotDes, need_pass_layer)
	end
	self.node_list["PassLayerDes"].text.text = pass_des
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = self.data.power
	end

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrDes1"].text.text = str
		self.node_list["AttrDes2"].text.text = ""
		self.node_list["AttrDes2"]:SetActive(false)
		return
	end

	attr_type_name = Language.Rune.AttrName[self.data.attr_type_0] or ""
	attr_value = self.data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.node_list["AttrDes1"].text.text = attr_des
	if self.data.attr_type_1 > 0 then
		attr_type_name = Language.Rune.AttrName[self.data.attr_type_1] or ""
		attr_value = self.data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
			attr_value = (self.data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrDes2"].text.text =attr_des
		self.node_list["AttrDes2"]:SetActive(true)
	else
		self.node_list["AttrDes2"].text.text = ""
		self.node_list["AttrDes2"]:SetActive(false)
	end
end