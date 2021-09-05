BaoZangExchang = BaoZangExchang or BaseClass(BaseView)

local ExchangeType = 15
local COLUMN = 8
local MAX_GRID_NUM = 8
local ROW = 2
local COLUMN2 = 4
local CONVER_TYPE = 1

function BaoZangExchang:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/hunqiview_prefab", "BaozangExchange"}, 
	}
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_any_click_close = true

	local convert_cfg = ExchangeData.Instance:GetHunYinExchangeCfg()
	self.item_list_cfg = {}
	for k,v in pairs(convert_cfg) do
		if ExchangeType == v.price_type then
			table.insert(self.item_list_cfg, v)
		end
	end
end

function BaoZangExchang:__delect()

end

function BaoZangExchang:LoadCallBack()
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshExchangeCells, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Bg"].rect.sizeDelta = Vector3(1032, 675, 0)

	self.node_list["Txt"].text.text = Language.HunQi.DuiHuanTitle
	self.cell_list = {}

	self.page_toggle_list = {}
	self.total_page_count = {}
	for i = 1, 5 do
		self.page_toggle_list[i] = self.node_list["PageToggle" .. i].toggle
		self.total_page_count[i] = self.node_list["PageToggle" .. i]
	end
	self.page_count = 1
	self:FlushBagView()
end

function BaoZangExchang:ReleaseCallBack()
	self.page_toggle_list = nil
	self.total_page_count = nil

	if nil ~= self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil
end

function BaoZangExchang:OnFlush()
	self:FlushBagView()
end

function BaoZangExchang:FlushBagView()
	if self.node_list["ListView"] then
		if self.node_list["ListView"].scroller.isActiveAndEnabled then
			local item_list = self.item_list_cfg
			local diff = #item_list - MAX_GRID_NUM
			local more_then_num = ((diff > 0)) and (math.ceil(diff / ROW / COLUMN2)) or 0
			local list_page_scroll = self.node_list["ListView"].list_page_scroll

			if more_then_num > 0 and more_then_num <= 4 then
				for i = 1, more_then_num + 1 do
					self.total_page_count[i]:SetActive(true)
				end
				list_page_scroll:SetPageCount(more_then_num + 1)
			else
				self.total_page_count[1]:SetActive(true)
				list_page_scroll:SetPageCount(1)
			end

			if self.page_count ~= (more_then_num + 1) then
				self.node_list["ListView"].scroller:ReloadData(0)
				if self.cur_index then
					local page = self.cur_index > 0 and (math.floor(self.cur_index / ROW / COLUMN2) + 1) or 1
					if self.cur_index > 0 and self.cur_index % (ROW * COLUMN2) == 0 then
						if page > 1 then
							page = page - 1
						else
							page = 1
						end
					end
					list_page_scroll:JumpToPageImmidate(page)
					self.page_toggle_list[page].isOn = true
				end
			else
				self.node_list["ListView"].scroller:RefreshActiveCellViews()
			end
			self.cur_index = -1
			self.page_count = more_then_num
		end
	end
end

function BaoZangExchang:GetNumOfCells()
	return math.ceil(#self.item_list_cfg / COLUMN)
end

function BaoZangExchang:RefreshExchangeCells(cell, data_index)
	local group = self.cell_list[cell]
	local exchange_list = self.item_list_cfg
	if group == nil then
		group = BaoZangExchangeGroup.New(cell.gameObject)
		self.cell_list[cell] = group
	end

	if #self.item_list_cfg % COLUMN ~= 0
		and data_index == math.floor(#self.item_list_cfg / COLUMN) then
		for i = #self.item_list_cfg % COLUMN + 1, 8 do
			group:SetActive(i, false)
		end
		for i = 1, #self.item_list_cfg % COLUMN do
			local index = i + data_index * COLUMN
			group:SetData(i, exchange_list[index])
			group:ListenClick(i, BindTool.Bind(self.OnClickExChangeButton, self, index, exchange_list[index]))
		end
	else
		for i = 1, 8 do
			local index = i + data_index * COLUMN
			group:SetData(i, exchange_list[index])
			group:SetActive(i, true)
			group:ListenClick(i, BindTool.Bind(self.OnClickExChangeButton, self, index, exchange_list[index]))
		end
	end
end

function BaoZangExchang:OnClickExChangeButton(index, data)
	ExchangeCtrl.Instance:SendScoreToItemConvertReq(CONVER_TYPE, data.seq, 1)
end


----------------------------------------------------------------------
-- 兑换列表
BaoZangExchangeGroup = BaoZangExchangeGroup or BaseClass(BaseRender)

function BaoZangExchangeGroup:__init(instance)
	self.cells = {}
	for i = 1, 8 do
		self.cells[i] = {item = self.node_list["Item" .. i], cell = BaoZangExchangeCell.New(self.node_list["Item" .. i])}
	end
end

function BaoZangExchangeGroup:__delete()
	for k, v in pairs(self.cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.cells = {}
end

function BaoZangExchangeGroup:SetActive(i, value)
	self.cells[i].item:SetActive(value)
end

function BaoZangExchangeGroup:SetData(i, data)
	self.cells[i].cell:SetData(data)
end

function BaoZangExchangeGroup:ListenClick(i, handler)
	self.cells[i].cell:ListenClick(handler)
end

----------------------------------------------------------------
-- 兑换格子
BaoZangExchangeCell = BaoZangExchangeCell or BaseClass(BaseRender)

function BaoZangExchangeCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(instance.transform:FindHard("ItemCell"))
end

function BaoZangExchangeCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function BaoZangExchangeCell:SetData(data)
	if data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.item:SetData(data)
	self.node_list["NoLimitTxt"]:SetActive(data.limit_convert_count == 0)
	self.node_list["UseTxt"]:SetActive(data.limit_convert_count ~= 0)
	if item_cfg ~= nil then
		local name_str = "<color=" .. SOUL_NAME_COLOR[item_cfg.color] .. ">" .. item_cfg.name .. "</color>"
		self.node_list["Txtname"].text.text = name_str
		self.node_list["Txtcoin"].text.text = data.price
		self.node_list["UseTxt"].text.text = data.limit_convert_count
	end
end

function BaoZangExchangeCell:ListenClick(handler)
	--self:ClearEvent("click")
	self.node_list["ExchangeBtn"].toggle:AddClickListener(BindTool.Bind(handler, self))
end