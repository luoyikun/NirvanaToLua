local CommonFunc = require("game/tips/tips_common_func")
local PAGE_COUNT = 6
local LEFT_PAGE_COUNT = 1
local DELAY_TIME = 3

ModelGiftView = ModelGiftView or BaseClass(BaseView)

function ModelGiftView:__init()
	self.ui_config = {{"uis/views/player_prefab", "ModelGiftView"}}

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp

	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
end

function ModelGiftView:__delete()
	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}
end

function ModelGiftView:ReleaseCallBack()
	for k,v in pairs(self.list_cell) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.list_cell = nil

	for k,v in pairs(self.left_list_cell) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.left_list_cell = nil

	if self.runquest_auto_move then
		GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
		self.runquest_auto_move = nil
	end
end

function ModelGiftView:LoadCallBack()
	self.list_cell = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.left_list_cell = {}
	local left_list_delegate = self.node_list["LeftListView"].list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.LeftGetNumberOfCells, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.LeftRefreshCell, self)

	self.node_list["LeftListView"].scroller.scrollerScrollingChanged = function(scroller, is_scrolling)
    	if is_scrolling == true then
			if nil ~= self.runquest_auto_move then
				GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
				self.runquest_auto_move = nil
			end
    	elseif is_scrolling == false then
			if nil ~= self.runquest_auto_move then
				GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
				self.runquest_auto_move = nil
			end
			self.runquest_auto_move = GlobalTimerQuest:AddRunQuest(function()
				if self.node_list["LeftListView"] and self.node_list["LeftListView"].scroller.isActiveAndEnabled then
					local gift_id = MojieData.Instance:GetModelGiftId()
					local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
					local page = self.node_list["LeftListView"].list_page_scroll:GetNowPage() + 1
					local count = math.ceil(#data_list / LEFT_PAGE_COUNT)
					if page >= count then
						page = 0
					end
					self.node_list["LeftListView"].list_page_scroll:JumpToPage(page)
				end
			end, DELAY_TIME)    		
    	end
  	end

	for i = 1, 40 do
		self.node_list["LeftToggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
	end

	for i = 1, 4 do
		local btn = self.node_list["Button" .. i]
		local text = btn.transform:FindHard("Text")
		self.buttons[i] = {btn = btn, text = text}
	end

	self:Flush()
end

-- 根据不同情况，显示和隐藏按钮
function ModelGiftView:ShowHandlerBtn()
	local from_view = MojieData.Instance:GetFromView()
	local data = MojieData.Instance:GetModelGiftData()

	if nil == from_view or nil == data then
		for k,v in pairs(self.buttons) do
			v.btn:SetActive(false)
		end
		return
	end

	local gift_id = MojieData.Instance:GetModelGiftId()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(gift_id)
	if item_cfg == nil then
		return
	end

	local handler_types = CommonFunc.GetOperationState(from_view, data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			tx = data.btn_text or tx
			v.btn:SetActive(true)
			v.text:GetComponent(typeof(UnityEngine.UI.Text)).text = tx

			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			local is_special = nil ~= IsSpecialHandlerType[handler_type]
			local asset = is_special and "btn_tips_side_yellow" or "btn_tips_side_blue"
			self.node_list["Button" .. k].image:LoadSprite("uis/images_atlas", asset)			
			self.button_handle[k] = self.node_list["Button" .. k].button:AddClickListener(BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function ModelGiftView:OnClickHandle(handler_type)
	local from_view = MojieData.Instance:GetFromView()
	local data = MojieData.Instance:GetModelGiftData()
	if nil == from_view or nil == data then
		return
	end

	local gift_id = MojieData.Instance:GetModelGiftId()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(gift_id)
	if item_cfg == nil then
		return
	end

	if not CommonFunc.DoClickHandler(data, item_cfg, handler_type, from_view, nil) then
		return
	end

	self:Close()
end


function ModelGiftView:OnClickToggle(i)
	if nil ~= self.runquest_auto_move then
		GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
		self.runquest_auto_move = nil
	end
	self.runquest_auto_move = GlobalTimerQuest:AddRunQuest(function()
		if self.node_list["LeftListView"] and self.node_list["LeftListView"].scroller.isActiveAndEnabled then
			local gift_id = MojieData.Instance:GetModelGiftId()
			local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
			local page = self.node_list["LeftListView"].list_page_scroll:GetNowPage() + 1
			local count = math.ceil(#data_list / LEFT_PAGE_COUNT)
			if page >= count then
				page = 0
			end
			self.node_list["LeftListView"].list_page_scroll:JumpToPage(page)
		end
	end, DELAY_TIME) 
end

function ModelGiftView:CloseWindow()
	self:Close()
end

function ModelGiftView:OpenCallBack()
	self:Flush()
end

function ModelGiftView:LeftGetNumberOfCells()
	local gift_id = MojieData.Instance:GetModelGiftId()
	local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
	local max_num = #data_list	
	return math.ceil(max_num / LEFT_PAGE_COUNT)
end

function ModelGiftView:LeftRefreshCell(cell, data_index)
	-- 构造Cell对象.
	local item = self.left_list_cell[cell]
	if nil == item then
		item = ModelGiftLeftGroup.New(cell)
		self.left_list_cell[cell] = item
	end
	local data = {}
	local gift_id = MojieData.Instance:GetModelGiftId()
	local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
	for i = 1, LEFT_PAGE_COUNT do
		if data_list[data_index * LEFT_PAGE_COUNT + i] then
			table.insert(data, data_list[data_index * LEFT_PAGE_COUNT + i])
		else
			break
		end
	end
	item:SetData(data)
end

function ModelGiftView:GetNumberOfCells()
	local gift_id = MojieData.Instance:GetModelGiftId()
	local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
	local max_num = #data_list	
	return math.ceil(max_num / PAGE_COUNT)
end

function ModelGiftView:RefreshCell(cell, data_index)
	-- 构造Cell对象.
	local item = self.list_cell[cell]
	if nil == item then
		item = ModelGiftGroup.New(cell)
		self.list_cell[cell] = item
	end
	local data = {}
	local gift_id = MojieData.Instance:GetModelGiftId()
	local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
	for i = 1, PAGE_COUNT do
		if data_list[data_index * PAGE_COUNT + i] then
			data_list[data_index * PAGE_COUNT + i].param_t = {select_index = data_index * PAGE_COUNT + i}
			data_list[data_index * PAGE_COUNT + i].from_view = TipsFormDef.FROM_LINGQU
			table.insert(data, data_list[data_index * PAGE_COUNT + i])
		else
			break
		end
	end
	item:SetData(data)
end

function ModelGiftView:OnFlush()
	local gift_id = MojieData.Instance:GetModelGiftId()
	local data_list = TableCopy(ItemData.Instance:GetGiftItemList(gift_id))
	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		local count = math.ceil(#data_list / PAGE_COUNT)
		for i = 1,7 do
			self.node_list["PageToggle" .. i]:SetActive(i <= count)
			if count == 1 then
				self.node_list["PageToggle" .. i]:SetActive(false)
			end
		end
		self.node_list["ListView"].list_page_scroll:SetPageCount(count)
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.node_list["LeftListView"] and self.node_list["LeftListView"].scroller.isActiveAndEnabled then
		local count = math.ceil(#data_list / LEFT_PAGE_COUNT)
		for i = 1, 40 do
			self.node_list["LeftToggle" .. i]:SetActive(i <= count)
			if count == 1 then
				self.node_list["LeftToggle" .. i]:SetActive(false)
			end
		end
		self.node_list["LeftListView"].list_page_scroll:SetPageCount(count)
		self.node_list["LeftListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	if nil ~= self.runquest_auto_move then
		GlobalTimerQuest:CancelQuest(self.runquest_auto_move)
		self.runquest_auto_move = nil
	end
	self.runquest_auto_move = GlobalTimerQuest:AddRunQuest(function()
		if self.node_list["LeftListView"] and self.node_list["LeftListView"].scroller.isActiveAndEnabled then
			local page = self.node_list["LeftListView"].list_page_scroll:GetNowPage() + 1
			local count = math.ceil(#data_list / LEFT_PAGE_COUNT)
			if page >= count then
				page = 0
			end
			self.node_list["LeftListView"].list_page_scroll:JumpToPage(page)
		end
	end, DELAY_TIME)

	self:ShowHandlerBtn()
end

----------------------------------------------------------------------------
--ModelGiftGroup 		列表滚动条格子
----------------------------------------------------------------------------

ModelGiftGroup = ModelGiftGroup or BaseClass(BaseCell)

function ModelGiftGroup:__init()
	self.cell_list = {}
	self.data = {}

	for i = 1, PAGE_COUNT do
		local async_loader = AllocAsyncLoader(self, "gift_group_loader_" .. i)
		async_loader:Load("uis/views/player_prefab", "ModelGiftItem", function (obj)
			if IsNil(obj) then
				return
			end
			local obj_transform = obj.transform
			obj_transform:SetParent(self.root_node.transform, false)
			local item = ModelGiftItem.New(obj)
			table.insert(self.cell_list, item)
			if #self.cell_list == PAGE_COUNT then
				self:SetData(self.data)
			end
		end)
	end
end

function ModelGiftGroup:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ModelGiftGroup:SetData(data)
	self.data = data
	if #self.cell_list < PAGE_COUNT then return end
	for k,v in pairs(self.cell_list) do
		v:SetData(data[k])
		v:SetIndex(k)
		v:SetActive(data[k] ~= nil)
	end
end

---------------------ModelGiftItem--------------------------------
ModelGiftItem = ModelGiftItem or BaseClass(BaseCell)

function ModelGiftItem:__init()
	self.node_list["ModelGiftItem"].button:AddClickListener(BindTool.Bind(self.OnClickTips, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLi"],"FightPower2")
end

function ModelGiftItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ModelGiftItem:OnFlush()
	if not self.data then
		return
	end
	self.item_cell:SetData(self.data)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_list["name"].text.text = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = ItemData.GetFightPower(self.data.item_id) or 0
	end
end

function ModelGiftItem:OnClickTips()
	self.item_cell:OnClickItemCell()
end


----------------------------------------------------------------------------
--ModelGiftLeftGroup 		列表滚动条格子
----------------------------------------------------------------------------

ModelGiftLeftGroup = ModelGiftLeftGroup or BaseClass(BaseCell)

function ModelGiftLeftGroup:__init()
	self.cell_list = {}
	self.data = {}

	for i = 1, LEFT_PAGE_COUNT do
		local async_loader = AllocAsyncLoader(self, "gift_item_loader_" .. i)
		async_loader:Load("uis/views/player_prefab", "ModelGiftLeftItem", function (obj)
			if IsNil(obj) then
				return
			end
			local obj_transform = obj.transform
			obj_transform:SetParent(self.root_node.transform, false)
			local item = ModelGiftLeftItem.New(obj)
			table.insert(self.cell_list, item)
			if #self.cell_list == LEFT_PAGE_COUNT then
				self:SetData(self.data)
			end
		end)
	end
end

function ModelGiftLeftGroup:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ModelGiftLeftGroup:SetData(data)
	self.data = data
	if #self.cell_list < LEFT_PAGE_COUNT then return end
	for k,v in pairs(self.cell_list) do
		v:SetData(data[k])
		v:SetIndex(k)
		v:SetActive(data[k] ~= nil)
	end
end

---------------------ModelGiftLeftItem--------------------------------
ModelGiftLeftItem = ModelGiftLeftItem or BaseClass(BaseCell)

function ModelGiftLeftItem:__init()
	self.fight_text = CommonDataManager.FightPower(self, self.node_list["ZhanLi"],"FightPower2")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)	
end

function ModelGiftLeftItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function ModelGiftLeftItem:OnFlush()
	if not self.data then
		return
	end

	if self.data.item_id then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		self.node_list["name"].text.text = item_cfg.name
		if self.fight_text and self.fight_text.text then
			self.fight_text.text.text = ItemData.GetFightPower(self.data.item_id) or 0
		end
		if item_cfg.is_display_role == DISPLAY_TYPE.HEAD_FRAME then
			self.node_list["Ani"]:SetActive(false)
			self.node_list["Display"]:SetActive(false)			
			self.node_list["HeadImg"]:SetActive(true)
			local index = HeadFrameData.Instance:GetPrefabByItemId(self.data.item_id)
			if index >= 0 then
				self.node_list["HeadImg"].image:LoadSprite(ResPath.GetHeadFrameIcon(index))
			end

		elseif item_cfg.is_display_role == DISPLAY_TYPE.BUBBLE then
			self.node_list["HeadImg"]:SetActive(false)
			self.node_list["Display"]:SetActive(false)
			self.node_list["Ani"]:SetActive(true)				
			local index = CoolChatData.Instance:GetBubbleIndexByItemId(self.data.item_id)
			if index > 0 then
				local PrefabName = "BubbleChat" .. index
				local async_loader = AllocAsyncLoader(self, "bubble_chat_load")
				local bundle = "uis/chatres/bubbleres/bubble" .. index .. "_prefab"
				async_loader:Load(bundle, PrefabName, function(obj)
					if not IsNil(obj) then
						obj.transform:SetParent(self.node_list["Ani"].transform, false)
					end
				end)
			end
		else
			self.node_list["Ani"]:SetActive(false)
			self.node_list["HeadImg"]:SetActive(false)
			self.node_list["Display"]:SetActive(true)
			self.model:ClearFoot()
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			self.model:ChangeModelByItemId(self.data.item_id)
		end
	end
end
