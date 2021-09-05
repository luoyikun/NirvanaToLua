ShenYinLieHunItem = ShenYinLieHunItem or BaseClass(BaseRender)

function ShenYinLieHunItem:__init(instance)
	self.item_cell = ItemCell.New()
end

function ShenYinLieHunItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.data = nil
end

function ShenYinLieHunItem:CloseCallBack()
	
end

function ShenYinLieHunItem:SetData(data)
	--data.id是猎魂物品表的index
	self.data = data
	if nil == data then return end
	local virtual_item_id = ShenYinData.Instance:GetHunShouVItemIdByIndex(data.id)
	local shenyin_cfg = ShenYinData.Instance:GetItemCFGByVItemID(virtual_item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(shenyin_cfg.item_id)
	if item_cfg then
		self.item_cell:SetActive(true)
		local str = "<color=%s>"..item_cfg.name.."</color>"
		self.node_list["NameTxt"].text.text = string.format(str, ITEM_COLOR[item_cfg.color])
		self.item_cell:SetInstanceParent(self.node_list["Icon"])
		self.item_cell:SetData({item_id = item_cfg.id, num = 1, is_bind = 1, 
			from_view = TipsFormDef.FROM_SHENYIN_LIEHUN, index = data.grid_index})
	else
		self.node_list["NameTxt"].text.text = ""
		self.item_cell:SetActive(false)
	end
end

function ShenYinLieHunItem:GetData()
	return self.data
end

function ShenYinLieHunItem:ListenClick(handler)
	self.item_cell:ListenClick(handler)
end

function ShenYinLieHunItem:CloseHighLight()
	self.item_cell:SetHighLight(false)
end
