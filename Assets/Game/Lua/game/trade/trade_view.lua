TradeView = TradeView or BaseClass(BaseView)

local MAX_NUM = 144
local COLUMN_NUM = 4
local ROW_NUM = 5

function TradeView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/tradeview_prefab", "TradeView"}}
	self.play_audio = true
	self.is_modal = true
	self.is_any_click_close = false
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.me_items = {}
	self.other_items = {}
	self.my_trade_item = {}
	self.item_cell_list = {}

	self.role_head = GlobalEventSystem:Bind(ObjectEventType.HEAD_CHANGE, BindTool.Bind(self.SetRoleHead, self))
end

function TradeView:__delete()
	if self.role_head ~= nil then
		GlobalEventSystem:UnBind(self.role_head)
		self.role_head = nil
	end
end

function TradeView:ReleaseCallBack()
	for k, v in pairs(self.me_items) do
		if v.item then
			v.item:DeleteMe()
		end
	end
	self.me_items = {}

	for k, v in pairs(self.other_items) do
		if v.item then
			v.item:DeleteMe()
		end
	end
	self.other_items = {}

	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function TradeView:OpenCallBack()
	self.is_click_lock = false
	self.is_click_sure = false
	self.node_list["ImgMeTradeInfoMask"]:SetActive(false)
	self.node_list["ImgOtherTradeInfoMask"]:SetActive(false)

	self.node_list["List"].scroller:RefreshAndReloadActiveCellViews(true)
	self:Flush("item_req")
end

function TradeView:CloseCallBack()
	self.is_click_lock = nil
	self.is_click_sure = nil
	self.me_path = nil
	self.other_path = nil
	self.my_trade_item = {}
	self.knapsack_index = nil
	self.cur_index = nil
	TradeData.Instance:ClearTradeItemData()
end

function TradeView:LoadCallBack()
	for i = 1, 4 do
		self.me_items[i] = {
			item = ItemCell.New(),
			name = self.node_list["TxtCell" .. i]
		}
		self.me_items[i].item:SetInstanceParent(self.node_list["MeItem" .. i])

		self.other_items[i] = {
			item = ItemCell.New(),
			name = self.node_list["TxtItemCell" .. i]
		}
		self.other_items[i].item:SetInstanceParent(self.node_list["OtherItem" .. i])

		self.node_list["Cell" .. i].button:AddClickListener(BindTool.Bind(self.OnClickMeTradeItem, self, i))
		self.node_list["Cell" .. i]:SetActive(false)
		self.node_list["ItemCell" .. i]:SetActive(false)
	end

	self.node_list["Bg"].rect.sizeDelta = Vector3(950,630,0)
	self.node_list["Txt"].text.text = Language.Trade.Trade
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["LockButton"].button:AddClickListener(BindTool.Bind(self.OnClickLock, self))
	self.node_list["SureButton"].button:AddClickListener(BindTool.Bind(self.OnClickSure, self))

	local list_delegate = self.node_list["List"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

end

function TradeView:FlushTradeView()
	self.node_list["List"].scroller:RefreshActiveCellViews()
end

function TradeView:GetNumberOfCells()
	return MAX_NUM / COLUMN_NUM
end

function TradeView:RefreshCell(cell, data_index)
	local group = self.item_cell_list[cell]
	if not group then
		group = TradeItemCellGroup.New(cell.gameObject)
		group:SetToggleGroup(self.node_list["List"].toggle_group)
		self.item_cell_list[cell] = group
	end

	local page = math.floor(data_index / COLUMN_NUM)
	local column = data_index - page * COLUMN_NUM
	local grid_count = COLUMN_NUM * ROW_NUM
	for i = 1, ROW_NUM do
		local index = (i - 1) * COLUMN_NUM  + column + (page * grid_count)

		-- 获取数据信息
		local data = nil
		data = ItemData.Instance:GetTradeList(index)
		data = data or {}
		data.locked = index >= ItemData.Instance:GetMaxKnapsackValidNum()
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:SetIconGrayVisible(i, data.is_bind == 1)
		group:SetIconGrayScale(i, data.is_bind == 1)
		group:ShowQuality(i, nil ~= data.item_id and data.is_bind ~= 1)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i))
		group:SetInteractable(i, nil ~= data.item_id)
		-- group:ShowHighLight(i, self.cur_index == index and data.is_bind ~= 1)

		if #self.my_trade_item > 0 then
			for k, v in pairs(self.my_trade_item) do
				if v.knapsack_index == data.index and nil ~= data.item_id then
					group:SetIconGrayVisible(i, true)
				end
			end
		end

		if self.knapsack_index then
			if self.knapsack_index == index then
				group:SetInteractable(i, true)
				self.knapsack_index = nil
			end
		end
	end
end

function TradeView:HandleBagOnClick(data, group, group_index)
	if self.is_click_lock then
		SysMsgCtrl.Instance:ErrorRemind(Language.Trade.TradeLuck)
		return
	end
	if not data.item_id then return end

	self.cur_index = data.index
	if data.is_bind == 1 or data.num == nil or data.num == 0 then
		return
	end

	local func = function (item_num)
		TradeCtrl.Instance:SendTradeItemReq(TradeData.Instance:GetMyTradeItemLen(), data.index, item_num)
		group:SetInteractable(group_index, false)
	end

	if data.num <= 1 then
		func(data.num)
		return
	end

	TipsCtrl.Instance:OpenCommonInputView(data.num, func, nil, data.num)
end

function TradeView:OnClickClose()
	TradeCtrl.Instance:SendTradeCancleReq()
	TradeData.Instance:ClearTradeItemData()
	self:Close()
end

function TradeView:OnClickSure()
	if self.is_click_sure and not self.is_click_lock then
		return
	end
	TradeCtrl.Instance:SendTradeAffirmReq()
	self.is_click_sure = true
end

function TradeView:OnClickLock()
	if self.is_click_lock then
		return
	end
	TradeCtrl.Instance:SendTradeLockReq()
	self.is_click_lock = true
end

-- 取消交易架上面的物品
function TradeView:OnClickMeTradeItem(index)
	local me_item_data = TradeData.Instance:GetMyTradeItem()[index]
	if me_item_data and not self.is_click_lock then
		TradeCtrl.Instance:SendTradeItemReq(index, -1, me_item_data.num)
	end
end

function TradeView:SetTradeInfo(protocol)
	self:SetRoleHead()
	
	if protocol.trade_state == TradeData.TradeState.Luck then
		self.node_list["ImgMeTradeInfoMask"]:SetActive(true)
	end

	if protocol.other_trade_state == TradeData.TradeState.Luck then
		self.node_list["ImgOtherTradeInfoMask"]:SetActive(true)
	end

	if protocol.trade_state == TradeData.TradeState.Luck and
		protocol.other_trade_state == TradeData.TradeState.Luck or protocol.other_trade_state == TradeData.TradeState.Affirm then
		UI:SetButtonEnabled(self.node_list["SureButton"], true)
	else
		UI:SetButtonEnabled(self.node_list["SureButton"], false)
	end
end

function TradeView:SetTradeItemData()
	for k, v in pairs(self.me_items) do
		local me_item_data = TradeData.Instance:GetMyTradeItem()[k]
		local other_item_data = TradeData.Instance:GetOtherTradeItem()[k]
		v.item:SetData(me_item_data or {})
		v.item:ShowStrengthLable(false)
		v.item:ListenClick(BindTool.Bind(self.OnClickMeTradeItemCell, self, k, me_item_data))

		self.other_items[k].item:SetData(other_item_data or {})
		self.other_items[k].item:ShowStrengthLable(false)
		self.other_items[k].item:ListenClick(BindTool.Bind(self.OnClickOtherTradeItemCell, self, k, other_item_data))
		if me_item_data then
			self.node_list["Cell" .. k]:SetActive(true)
			local item_cfg = ItemData.Instance:GetItemConfig(me_item_data.item_id)
			v.name.text.text = item_cfg.name
		else
			self.node_list["Cell" .. k]:SetActive(false)
			v.name.text.text = ""
		end

		if other_item_data then
			self.node_list["ItemCell" .. k]:SetActive(true)
			local item_cfg = ItemData.Instance:GetItemConfig(other_item_data.item_id)
			self.other_items[k].name.text.text = item_cfg.name
		else
			self.node_list["ItemCell" .. k]:SetActive(false)
			self.other_items[k].name.text.text = ""
		end
	end
end

function TradeView:OnClickMeTradeItemCell(index, me_item_data)
	TipsCtrl.Instance:OpenItem(me_item_data, nil, nil)
end

function TradeView:OnClickOtherTradeItemCell(index, me_item_data)
	TipsCtrl.Instance:OpenItem(me_item_data, nil, nil)
end

function TradeView:SetRoleHead()
	if not self:IsOpen() then
		return
	end

	local other_role_info = TradeData.Instance:GetSendTradeRoleInfo() or ScoietyData.Instance:GetSelectRoleInfo()
	self.node_list["TxtName2"].text.text = other_role_info.req_name or other_role_info.gamename or other_role_info.role_name

	local raw_image_obj = self.node_list["OtherRawImage"]
	local image_obj = self.node_list["OtherImage"]
	local role_id = other_role_info.req_uid or other_role_info.user_id or other_role_info.role_id
	local sex = other_role_info.sex
	local prof = other_role_info.prof
	AvatarManager.Instance:SetAvatar(role_id, raw_image_obj, image_obj, sex, prof, false)

	local me_role_info = GameVoManager.Instance:GetMainRoleVo()
	self.node_list["TxtName"].text.text = me_role_info.name

	local raw_image_obj = self.node_list["MeRawImage"]
	local image_obj = self.node_list["MeImage"]
	local role_id = me_role_info.role_id
	local sex = me_role_info.sex
	local prof = me_role_info.prof
	AvatarManager.Instance:SetAvatar(role_id, raw_image_obj, image_obj, sex, prof, false)
end

function TradeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "item_req" then
			if v.is_me == 0 then
				self.knapsack_index = v.knapsack_index
				self.my_trade_item = TradeData.Instance:GetMyTradeItem()
				self:FlushTradeView()
			end
			self:SetTradeItemData()
		elseif k == "trade_state" then
			if self:IsOpen() then
				self:SetTradeInfo(v)
				self:FlushTradeView()
				UI:SetButtonEnabled(self.node_list["LockButton"], not self.is_click_lock)
			end
		end
	end
end


TradeItemCellGroup = TradeItemCellGroup or BaseClass(BaseRender)

function TradeItemCellGroup:__init()
	self.cells = {}
	for i = 1, 5 do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function TradeItemCellGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function TradeItemCellGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function TradeItemCellGroup:SetInteractable(i, value)
	if self.cells[i] then
		self.cells[i]:SetInteractable(value)
	end
end

function TradeItemCellGroup:SetIconGrayScale(i, is_gray)
	self.cells[i]:SetIconGrayScale(is_gray)
end

function TradeItemCellGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function TradeItemCellGroup:ClearItemEvent(i)
	self.cells[i]:ClearItemEvent()
end

function TradeItemCellGroup:SetIconGrayVisible(i, value)
	self.cells[i]:SetIconGrayVisible(value)
	-- if value then
	-- 	self.cells[i]:SetIconGrayAlphe(100 / 255)
	-- end
end

function TradeItemCellGroup:SetToggleGroup(toggle_group)
	for k,v in pairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function TradeItemCellGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function TradeItemCellGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function TradeItemCellGroup:ShowQuality(i, enable)
	self.cells[i]:OnlyShowQuality(enable)
end