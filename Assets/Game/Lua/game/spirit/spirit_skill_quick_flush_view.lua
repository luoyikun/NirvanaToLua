SpiritSkillQuickFlushView = SpiritSkillQuickFlushView or BaseClass(BaseView)
local COLUMN = 4
function SpiritSkillQuickFlushView:__init(  )
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "SpiritSkillQuickFlushView"}
	}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function SpiritSkillQuickFlushView:__delete()

end

function SpiritSkillQuickFlushView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(720, 545, 0)
	self.node_list["Txt"].text.text = Language.JingLing.AutoDivination

	local list_delegate = self.node_list["listview"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.cell_list = {}

	self.node_list["BtnCancel"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.ClickStart, self))
end

function SpiritSkillQuickFlushView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function SpiritSkillQuickFlushView:CloseWindow()
	self:Close()
end

function SpiritSkillQuickFlushView:CloseCallBack()
	SpiritData.Instance:SetIsStartQuickFlush(false)
end

function SpiritSkillQuickFlushView:OpenCallBack()
	self.select_list = {}
	self:Flush()
end

function SpiritSkillQuickFlushView:OnFlush()
	local need_pay_money = SpiritData.Instance:GetFlushTenCost()
	self.node_list["TipsText"].text.text = string.format(Language.JingLing.TipsText, need_pay_money)
end

function SpiritSkillQuickFlushView:CloseCallBack()
	self:CloseAllHL()
end

function SpiritSkillQuickFlushView:GetNumberOfCells()
	local auto_list = SpiritData.Instance:GetSpiritSkillHighAndSuperList()
	return math.ceil(#auto_list / COLUMN) or 0
end

function SpiritSkillQuickFlushView:RefreshCell(cell, cell_index)
	local cell_group = self.cell_list[cell]
	if nil == cell_group then
		cell_group = SkillQuickFlushGroup.New(cell.gameObject)
		self.cell_list[cell] = cell_group
	end
	local data_list = SpiritData.Instance:GetSpiritSkillHighAndSuperList()
	for i = 1, COLUMN do
		local index = (cell_index) * COLUMN + i
		local data = data_list[index]
		cell_group:SetIndex(i, index)
		cell_group:SetActive(i, (data ~= nil))
		cell_group:SetParent(i, self)
		cell_group:SetData(i, data)
	end
end

function SpiritSkillQuickFlushView:ClickStart()
	local ok_callback = function()
		SpiritData.Instance:SetIsStartQuickFlush(true)
		local other_cfg = SpiritData.Instance:GetSpiritOtherCfg()
		if other_cfg and other_cfg.skill_refresh_consume_id then
			local have_num = ItemData.Instance:GetItemNumInBagById(other_cfg.skill_refresh_consume_id) or 0
			if have_num >= other_cfg.refresh_ten_consume_count then
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, 1)
			else
				SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, 0, 1, 1)
			end
		end
		self:Close()
	end

	for k,v in pairs(self.select_list) do
		if v then
			ok_callback()
			return
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SelectTips)
end

function SpiritSkillQuickFlushView:CheckSelectSeq(seq)
	if self.select_list[seq] then
		self.select_list[seq] = nil
		SpiritData.Instance:SetSelectFlushList(seq, nil)
	else
		self.select_list[seq] = seq
		SpiritData.Instance:SetSelectFlushList(seq, seq)
	end
end

function SpiritSkillQuickFlushView:IsSelectSeq(seq)
	return self.select_list[seq]
end

function SpiritSkillQuickFlushView:CloseAllHL()
	for k,v in pairs(self.cell_list) do
		v:ClearState()
	end
end

------------------------------------------------------------
SkillQuickFlushGroup = SkillQuickFlushGroup or BaseClass(BaseRender)

function SkillQuickFlushGroup:__init(  )
	self.item_list = {}
	for i = 1, COLUMN do
		local cell = SkillQuickFlushCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, cell)
	end
end

function SkillQuickFlushGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function SkillQuickFlushGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function SkillQuickFlushGroup:SetParent(i, parent)
	self.item_list[i]:SetParent(parent)
end

function SkillQuickFlushGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function SkillQuickFlushGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function SkillQuickFlushGroup:IsShowHL(state)
	for i = 1, COLUMN do
		self.item_list[i]:IsShowHL(state)
	end
end

function SkillQuickFlushGroup:ClearState()
	for i = 1, COLUMN do
		self.item_list[i]:ClearState()
	end
end
------------------------------------------------------------
SkillQuickFlushCell = SkillQuickFlushCell or BaseClass(BaseCell)

function SkillQuickFlushCell:__init()
	self.seq = -1
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["ToggleImg"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
	self.cell:ListenClick(BindTool.Bind(self.OnClick, self))
end

function SkillQuickFlushCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
	self.item_cell = nil
	self.parent = nil
end

function SkillQuickFlushCell:SetData(data)
	if nil == data then return end 
	self.data = data
	self:Flush()
end

function SkillQuickFlushCell:SetIndex(index)
	self.index = index
end

function SkillQuickFlushCell:OnClick()
	self.cell:SetHighLight(false)
	if self.parent then
		self.parent:CheckSelectSeq(self.seq)
		self:IsShowHL(self.parent:IsSelectSeq(self.seq))
	end
end

function SkillQuickFlushCell:SetParent(parent)
	self.parent = parent
end

function SkillQuickFlushCell:IsShowHL(state)
	self.node_list["HL"]:SetActive(nil ~= state)
end

function SkillQuickFlushCell:ClearState()
	self.node_list["HL"]:SetActive(false)
end

function SkillQuickFlushCell:OnFlush()
	if nil == self.data then return end

	self.seq = self.data.skill_id or -1
	self:IsShowHL(self.parent:IsSelectSeq(self.seq))
	local reward_item = {item_id = self.data.book_id, num = 1, is_bind = 1}
	self.cell:SetData(reward_item)
	local item_id = self.data.book_id
	if item_id and item_id > 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.node_list["TxtName"].text.text = ToColorStr(item_cfg.name, SPRITE_SKILL_LEVEL_COLOR[item_cfg.color])
		self.node_list["TxtNameSelect"].text.text = item_cfg.name
	end
end