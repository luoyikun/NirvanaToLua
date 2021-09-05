BianShenEquipBag = BianShenEquipBag or BaseClass(BaseView)
-- 常亮定义
local MAX_GRID_NUM = 16			-- 最大格子数

function BianShenEquipBag:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/bianshen_prefab", "BianShenEquip"},
	}
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.is_modal = true
	self.is_any_click_close = true
	self.slot_index = 0
end

function BianShenEquipBag:__delete()
	
end

function BianShenEquipBag:ReleaseCallBack()
	self.grid_list = {}
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
end

function BianShenEquipBag:LoadCallBack()
	self.node_list["Txt"].text.text = Language.SuitCollect.EquipBagTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(450, 510, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.bag_cell = {}
	for i = 1, MAX_GRID_NUM do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["ListCellView"])
		cell:SetIndex(i)
		self.bag_cell[i] = cell
	end
end

function BianShenEquipBag:SetSlotIndex(slot_index, quality, select_index)
	self.slot_index = slot_index			-- 槽位索引
	self.quality = quality					-- 神魔品质
	self.cur_select_index = select_index  	-- 当前名将索引
end

function BianShenEquipBag:CloseWindow()
	self:Close()
end

function BianShenEquipBag:OpenCallBack()
	self:FlushListCell()
end

function BianShenEquipBag:OnFlush()
	self:FlushListCell()
end

function BianShenEquipBag:BagGetNumberOfCells()
	return MAX_GRID_NUM
end

function BianShenEquipBag:FlushListCell()
	self.grid_list =  BianShenData.Instance:GetEquipmentBagBySlotIndex(self.slot_index - 1, self.quality)
	for i = 1, MAX_GRID_NUM do
		local guid_info = self.grid_list[i] or {}
		if guid_info then
			self.bag_cell[i]:SetItemNumVisible(false)
			self.bag_cell[i]:ListenClick(BindTool.Bind(self.CellOnClick, self, self.bag_cell[i], i))
			self.bag_cell[i]:SetData(guid_info, false)
			self.bag_cell[i]:ShowHighLight(false)	
		end
	end
end

function BianShenEquipBag:CellOnClick(cell, select_index)	
	local data = self.grid_list[select_index]
	if data == nil then
		return self:CloseWindow()
	end
	
	PackageCtrl.Instance:SendUseItem(data.index, 1, self.cur_select_index)
	self:CloseWindow()
end
