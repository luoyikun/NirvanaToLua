LuckyDrawAutoPopView = LuckyDrawAutoPopView or BaseClass(BaseView)
local COLUMN = 2
function LuckyDrawAutoPopView:__init(  )
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/luckydrawview_prefab", "LuckyDrawFlushView"}
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LuckyDrawAutoPopView:__delete()

end

function LuckyDrawAutoPopView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(695, 545, 0)
	self.node_list["Txt"].text.text = Language.LuckyDraw.AutoDivination

	local list_delegate = self.node_list["listview"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
end

function LuckyDrawAutoPopView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function LuckyDrawAutoPopView:CloseWindow()
	self:Close()
end

function LuckyDrawAutoPopView:OpenCallBack()
	self.select_list = {}
	self:Flush()
end

function LuckyDrawAutoPopView:OnFlush()
	local need_pay_money = LuckyDrawData.Instance:GetNeedPayMoney()
	self.node_list["TipsText"].text.text = string.format(Language.LuckyDraw.TipsText, need_pay_money)
end

function LuckyDrawAutoPopView:CloseCallBack()
	self:CloseAllHL()
end

function LuckyDrawAutoPopView:GetNumberOfCells()
	local auto_list = LuckyDrawData.Instance:GetCanAutoList()
	return math.ceil(#auto_list / COLUMN) or 0
end

function LuckyDrawAutoPopView:RefreshCell(cell, cell_index)
	local cell_group = self.cell_list[cell]
	if nil == cell_group then
		cell_group = AutoPopCellGroup.New(cell.gameObject)
		self.cell_list[cell] = cell_group
	end
	local data_list = LuckyDrawData.Instance:GetCanAutoList()
	for i = 1, COLUMN do
		local index = (cell_index) * COLUMN + i
		local data = data_list[index]
		cell_group:SetIndex(i, index)
		cell_group:SetActive(i, (data ~= nil))
		cell_group:SetParent(i, self)
		cell_group:SetData(i, data)
	end
end

function LuckyDrawAutoPopView:ClickStart()
	if not LuckyDrawData.Instance:IsEnoughGold() then
		TipsCtrl.Instance:ShowLackDiamondView()
		return 
	end

	if nil == next(self.select_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.LuckyDraw.AutoDivinationRemind)
		return
	end
	LuckyDrawData.Instance:SetCurSelectedList(self.select_list)
	LuckyDrawData.Instance:SetAutoFlag(true)

	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW, RA_TIANMING_DIVINATION_OPERA_TYPE.RA_TIANMING_DIVINATION_OPERA_TYPE_START_CHOU, 0, 0)
	self:Close()
end

function LuckyDrawAutoPopView:CheckSelectSeq(seq)
	if self.select_list[seq] then
		self.select_list[seq] = nil
	else
		self.select_list[seq] = seq
	end
end

function LuckyDrawAutoPopView:IsSelectSeq(seq)
	return self.select_list[seq]
end

function LuckyDrawAutoPopView:CloseAllHL()
	for k,v in pairs(self.cell_list) do
		v:ClearState()
	end
end

------------------------------------------------------------
AutoPopCellGroup = AutoPopCellGroup or BaseClass(BaseRender)

function AutoPopCellGroup:__init(  )
	self.item_list = {}
	for i = 1, COLUMN do
		local cell = AutoPopCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, cell)
	end
end

function AutoPopCellGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function AutoPopCellGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function AutoPopCellGroup:SetParent(i, parent)
	self.item_list[i]:SetParent(parent)
end

function AutoPopCellGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function AutoPopCellGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function AutoPopCellGroup:IsShowHL(state)
	for i = 1, COLUMN do
		self.item_list[i]:IsShowHL(state)
	end
end

function AutoPopCellGroup:ClearState()
	for i = 1, COLUMN do
		self.item_list[i]:ClearState()
	end
end
------------------------------------------------------------
AutoPopCell = AutoPopCell or BaseClass(BaseCell)

function AutoPopCell:__init()
	self.seq = -1
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["ToggleImg"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function AutoPopCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
	self.item_cell = nil
	self.parent = nil
end

function AutoPopCell:SetData(data)
	if nil == data then return end 
	self.data = data
	self:Flush()
end

function AutoPopCell:SetIndex(index)
	self.index = index
end

function AutoPopCell:OnClick()
	self.parent:CheckSelectSeq(self.seq)
	self:IsShowHL(self.parent:IsSelectSeq(self.seq))
end

function AutoPopCell:SetParent(parent)
	self.parent = parent
end

function AutoPopCell:IsShowHL(state)
	self.node_list["HL"]:SetActive(nil ~= state)
end

function AutoPopCell:ClearState()
	self.node_list["HL"]:SetActive(false)
end

function AutoPopCell:OnFlush()
	if nil == self.data then return end

	self.seq = self.data.seq or -1
	self:IsShowHL(self.parent:IsSelectSeq(self.seq))
	self.cell:SetData(self.data.reward_item)
	self.node_list["TxtChip"]:SetActive(self.data.can_add_lot == 1)
	self.node_list["TxtChipSelect"]:SetActive(self.data.can_add_lot == 1)
	local can_add_lot_list = LuckyDrawData.Instance:GetCanAddLotCfg()
	local add_lot_list = LuckyDrawData.Instance:GetAddLotList()
	for i,v in ipairs(can_add_lot_list) do
		if self.seq == v.seq then
			self.node_list["TxtChip"].text.text = string.format(Language.LuckyDraw.Chip, add_lot_list[i - 1])
			self.node_list["TxtChipSelect"].text.text = string.format(Language.LuckyDraw.Chip, add_lot_list[i - 1])
			if add_lot_list[i - 1] >= 2 then
				self.node_list["TxtChip"]:SetActive(true)
				self.node_list["TxtChipSelect"]:SetActive(true)				
			else
				self.node_list["TxtChip"]:SetActive(false)
				self.node_list["TxtChipSelect"]:SetActive(false)	
			end
			break
		end
	end

	local item_id = self.data.reward_item.item_id
	if item_id then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.node_list["TxtName"].text.text = item_cfg.name
		self.node_list["TxtNameSelect"].text.text = item_cfg.name
	end
end