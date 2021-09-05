CoupleHomePacketView = CoupleHomePacketView or BaseClass(BaseView)

local ROW = 4
local COLUMN = 2

function CoupleHomePacketView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/couplehome_prefab", "PacketView"}
	}
	self.select_house_index = 0
	self.furniture_index = -1
	self.max_page_num = 0
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.click_cell_call_back = BindTool.Bind(self.ClickCellCallBack, self)
end

function CoupleHomePacketView:__delete()
end

function CoupleHomePacketView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.page_des = nil
	self.list_view = nil
end

function CoupleHomePacketView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(840, 570, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.CoupleHome.PacketName

	self.cell_list = {}
	self.list_data = {}
	self.list_view = self.node_list["ListView"]
	self.list_view.list_page_scroll2.JumpToPageEvent = self.list_view.list_page_scroll2.JumpToPageEvent + BindTool.Bind(self.PageChangeEvent, self)
	local scroller_delegate = self.list_view.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	-- self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["ButtonPageUp"].button:AddClickListener(BindTool.Bind(self.PageUp, self))
	self.node_list["ButtonPageDown"].button:AddClickListener(BindTool.Bind(self.PageDown, self))
end

function CoupleHomePacketView:CloseWindow()
	self:Close()
end

function CoupleHomePacketView:PageUp()
	local now_page = self.list_view.list_page_scroll2:GetNowPage()
	if now_page <= 0 then
		return
	end

	now_page = now_page - 1
	self.list_view.list_page_scroll2:JumpToPage(now_page)
end

function CoupleHomePacketView:PageDown()
	local now_page = self.list_view.list_page_scroll2:GetNowPage()
	if now_page >= self.max_page_num - 1 then
		return
	end

	now_page = now_page + 1
	self.list_view.list_page_scroll2:JumpToPage(now_page)
end

function CoupleHomePacketView:ClickCellCallBack(cell)
	local data = cell:GetData()
	if data == nil then
		return
	end

	if self.call_back then
		self.call_back(data.item_id)
	end

	self:Close()
end

function CoupleHomePacketView:PageChangeEvent()
	self:FlushPageDes()
end

function CoupleHomePacketView:NumberOfCell()
	local list_num = #self.list_data
	return math.ceil(list_num / (ROW * COLUMN)) * (ROW * COLUMN)
end

function CoupleHomePacketView:CellRefresh(data_index, cell)
	local packet_cell = self.cell_list[cell]
	if packet_cell == nil then
		packet_cell = CoupleHomePacketCell.New(cell)
		packet_cell:SetClickCallBack(self.click_cell_call_back)
		self.cell_list[cell] = packet_cell
	end

	packet_cell:SetSelectHouseClientIndex(self.select_house_index)
	packet_cell:SetFurnitureIndex(self.furniture_index)

	local page = math.floor(data_index / (ROW * COLUMN))
	local cur_colunm = math.floor(data_index / ROW) + 1 - page * COLUMN
	local cur_row = math.floor(data_index % ROW) + 1
	local index = (cur_row - 1) * COLUMN - 1 + cur_colunm  + page * ROW * COLUMN
	packet_cell:SetData(self.list_data[index + 1])
	self:FlushUpArrow()
end

function CoupleHomePacketView:SetSelectHouseClientIndex(select_house_index)
	self.select_house_index = select_house_index
end

function CoupleHomePacketView:SetFurnitureIndex(furniture_index)
	self.furniture_index = furniture_index
end

function CoupleHomePacketView:SetCallBack(call_back)
	self.call_back = call_back
end

function CoupleHomePacketView:OpenCallBack()
	self:Flush()
end

function CoupleHomePacketView:FlushPageDes()
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	local max_page = self.max_page_num
	now_page = math.min(max_page, now_page)
	
	self.node_list["Page"].text.text = (now_page .. " / " .. max_page)

	self:FlushUpArrow()
end

function CoupleHomePacketView:FlushUpArrow()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:SetCoupleShowUpArrow()
		end
	end
end

function CoupleHomePacketView:OnFlush()
	local item_list = CoupleHomeHomeData.Instance:GetItemListInBagByIndex(self.furniture_index)
	self.list_data = item_list or {}
	self.max_page_num = math.ceil(#self.list_data / (ROW * COLUMN))
	self.list_view.list_page_scroll2:SetPageCount(self.max_page_num)

	self.list_view.list_view:Reload()
	self.list_view.list_view:JumpToIndex(0)

	self:FlushPageDes()
end

-----------------------CoupleHomePacketCell------------------------
CoupleHomePacketCell = CoupleHomePacketCell or BaseClass(BaseCell)
function CoupleHomePacketCell:__init()
	self.select_house_index = 0
	self.furniture_index = -1

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])

	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.node_list["ButtonReplace"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function CoupleHomePacketCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function CoupleHomePacketCell:SetSelectHouseClientIndex(select_house_index)
	self.select_house_index = select_house_index
end

function CoupleHomePacketCell:SetFurnitureIndex(furniture_index)
	self.furniture_index = furniture_index
end

--判断是否显示上升箭头
function CoupleHomePacketCell:CheckShowUpArrow()
	local show_up_arrow = false
	local house_info = CoupleHomeHomeData.Instance:GetHouseInfoByIndex(self.select_house_index)
	if house_info == nil then
		return
	end

	local function check(furniture_index)
		local furniture_info = house_info.furniture_list[furniture_index]
		if furniture_info then
			local item_id = furniture_info.item_id
			local item_list = CoupleHomeHomeData.Instance:GetFurnitureItemListById(item_id)
			if item_list then
				--当前装备的物品属性
				local item_info = item_list[1]
				local now_power = CommonDataManager.GetCapabilityCalculation(item_info)
				local power = CommonDataManager.GetCapabilityCalculation(self.data)
				if power > now_power then
					show_up_arrow = true
				end
			else
				show_up_arrow = true
			end
		end
	end

	local furniture_index = self.data.imprint_slot
	check(furniture_index)

	self.item_cell:SetShowUpArrow(show_up_arrow)
end

function CoupleHomePacketCell:SetCoupleShowUpArrow()
	if self.item_cell then
		self.item_cell:ResetUpArrowAni()
	end
end

function CoupleHomePacketCell:OnFlush()
	if self.data == nil then
		self:SetActive(false)
		return
	end
	self:SetActive(true)

	if self.furniture_index == self.data.imprint_slot then
		self.node_list["Button"]:SetActive(false)
		self.node_list["ButtonReplace"]:SetActive(true)
	else
		self.node_list["Button"]:SetActive(true)
		self.node_list["ButtonReplace"]:SetActive(false)
	end

	local item_id = self.data.item_id
	self.item_cell:SetData({item_id = item_id})

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg ~= nil then
		local color = ITEM_COLOR[item_cfg.color]
		local name = ToColorStr(item_cfg.name, color)
		self.node_list["Text"].text.text = name
	end

	local power = CommonDataManager.GetCapabilityCalculation(self.data)
	self.node_list["Power"].text.text = string.format(Language.CoupleHome.ZhanLi, power)

	self:CheckShowUpArrow()
end