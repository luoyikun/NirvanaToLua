ItemCellReward = ItemCellReward or BaseClass(ItemCell)

function ItemCellReward:__init()
	self:ShowHighLight(false)

	self:SetNotShowRedPoint(true)
end