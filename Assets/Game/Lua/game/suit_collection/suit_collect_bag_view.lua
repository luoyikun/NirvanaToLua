SuitCollectBagView = SuitCollectBagView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 48			-- 最大格子数
local BAG_PAGE_NUM = 3					-- 页数
local BAG_PAGE_COUNT = 16				-- 每页个数
local BAG_ROW = 6						-- 行数
local BAG_COLUMN = 6					-- 列数

function SuitCollectBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/suitcollection_prefab", "SuitEquipBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.slot_index = 0
end

function SuitCollectBagView:__delete()

end

function SuitCollectBagView:ReleaseCallBack()
	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function SuitCollectBagView:CloseWindow()
	self:Close()
end

function SuitCollectBagView:OnItemDataChange()
	self:Flush()
end

function SuitCollectBagView:CloseCallBack()
	self.equip_id = nil
	self.index = nil
	self.seq = nil
	self.choose_item_data = {}
	for k, v in pairs(self.item_cell_list) do
		v:SetData({})
	end
end

function SuitCollectBagView:SetEquipData(data)
	if nil == data.equip_id or nil == data.index or nil == data.seq then
		return
	end
	self.equip_id = data.equip_id
	self.index = data.index
	self.seq = data.seq
	self.is_show_tip = data.is_show_tip

	self:Open()
end

function SuitCollectBagView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.SuitCollect.EquipBagTitle
	self.node_list["Bg"].rect.sizeDelta = Vector3(450, 550, 0)

	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["ButtonWear"].button:AddClickListener(BindTool.Bind(self.OnButtonWear, self))

	self.item_cell_list = {}
	for i = 1, 25 do
		local cell = ItemCell.New()
		cell:SetInstanceParent(self.node_list["ListView"])
		cell:SetIndex(i)
		cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, i))
		self.item_cell_list[i] = cell
	end

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function SuitCollectBagView:OpenCallBack()
	self.choose_index = 1
	self:Flush()
end

function SuitCollectBagView:HandleBagOnClick(index)
	local data = self.item_cell_list[index]:GetData()
	if nil == data or not next(data) then return end

	for k, v in pairs(self.item_cell_list) do
		if v:GetIndex() == index then
			local data = v:GetData()
			if nil == data or not next(data) then return end
			self.choose_item_data = data
			v:ShowHighLight(true)
		else
			v:ShowHighLight(false)
		end
	end
	self.choose_index = index
end

function SuitCollectBagView:OnFlush()
	if not self.equip_id then 
		return
	end

	local bag_item = SuitCollectionData.Instance:GetEquipByItemId(self.equip_id)
	for k, v in pairs(self.item_cell_list) do
		if bag_item[k] then
			v:SetData(bag_item[k])
			if k == self.choose_index then
				v:ShowHighLight(true)
				self.choose_item_data = bag_item[k]
			else
				v:ShowHighLight(false)
			end
		else
			v:ShowHighLight(false)
			v:SetData({})
		end
	end
end

function SuitCollectBagView:OnButtonWear()
	if self.choose_item_data and next(self.choose_item_data) then
		local function ok_callback()
			SuitCollectionCtrl.Instance:SendReqCommonOpreate(COMMON_OPERATE_TYPE.COT_REQ_RED_EQUIP_COLLECT_TAKEON, 
				self.seq, self.index, self.choose_item_data.index)
			self:Close()
		end	

		if self.is_show_tip then
			local des = Language.SuitCollect.TipConfirmDesc
			TipsCtrl.Instance:ShowCommonAutoView("red_suitcollect", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
		else
			ok_callback()
			self:Close()
		end
	end
end
