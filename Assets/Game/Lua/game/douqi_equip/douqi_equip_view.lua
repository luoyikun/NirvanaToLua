DouqiEquipView = DouqiEquipView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 125			-- 最大格子数
local BAG_PAGE_NUM = 5					-- 页数
local BAG_PAGE_COUNT = 25				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 5					-- 列数



function DouqiEquipView:__init(instance)
	self.node_list["OpenRecovery"].button:AddClickListener(BindTool.Bind(self.OnOpenOrCloseRecovery, self, true))
	self.node_list["CloseRecovery"].button:AddClickListener(BindTool.Bind(self.OnOpenOrCloseRecovery, self, false))
	self.node_list["BlackBG"].button:AddClickListener(BindTool.Bind(self.OnOpenOrCloseRecovery, self, false))
	self.node_list["BtnSuitView"].button:AddClickListener(BindTool.Bind(self.OnBtnSuitView, self))
	self.node_list["BtnSuitAttrAll"].button:AddClickListener(BindTool.Bind(self.OnBtnSuitAttrAll, self))


	self.equip_item_list = {}
	for i = 1, 10 do
		local item_cell = EquipItemCell.New(self.node_list["Item" .. i])
		item_cell:SetIndex(i)
		-- item_cell:SetClickCallBack(BindTool.Bind(self.ClcikEquipItemCell, self))
		item_cell:SetFromView(TipsFormDef.FROM_DOUQI_VIEW_TAKEOFF)
		self.equip_item_list[i] = item_cell
	end

	self.douqi_euqip_datas = {}
	self.equip_cell_list = {}
	local list_delegate = self.node_list["EquipListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.EquipNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.EquipRefreshCell, self)

	self:FlushEquipList()

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["TextFight"])

	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display)

	if self.node_list["Display"].gameObject.activeInHierarchy then
		self.model_view:SetScale(Vector3(1.25, 1.25, 1.25))
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.model_view:ResetRotation()
		self.model_view:SetModelResInfo(role_vo, nil, nil, nil, nil, false)
	end

	local event_trigger = self.node_list["RotateEventTriggerSelf"].event_trigger_listener
	event_trigger:AddDragListener(BindTool.Bind(self.OnRoleDragSelf, self))
end


function DouqiEquipView:OnRoleDragSelf(data)
	if self.model_view then
		self.model_view:Rotate(0, -data.delta.x * 0.25, 0)
	end
end

function DouqiEquipView:__delete()
	for k, v in pairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.equip_cell_list) do
		v:DeleteMe()
	end
	self.equip_cell_list = {}

	self.fight_text = nil

	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
end

-- 装备格子
function DouqiEquipView:EquipNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function DouqiEquipView:EquipRefreshCell(index, cellObj)
	local cell = self.equip_cell_list[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.node_list["EquipListView"].toggle_group)
		cell:SetFromView(TipsFormDef.FROM_DOUQI_VIEW)
		cell:ListenClick(BindTool.Bind(self.ClickEquipItem, self, cell))
		self.equip_cell_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN

	local data = self.douqi_euqip_datas[grid_index + 1] or {}
	cell:SetIndex(grid_index + 1)
	cell:SetData(data)

	self:FlushCellFenjie(cell, data)
end

function DouqiEquipView:ClickEquipItem(cell)
	local data = cell:GetData()
	if nil == data or not next(data) then return end

	if DouQiData.Instance:GetIsOpenRecoveryView() then
		-- 打开分解情况下
		if DouQiData.Instance:IsInRecoveryTab(data.index) then
			-- 已经选中分解
			TipsCtrl.Instance:ShowSystemMsg(Language.Package.HaveLock)
		else
			DouQiData.Instance:AddRecoveryTab(data)
			self:FlushCellFenjie(cell, data)
			if self.call_back_fun then
				self.call_back_fun()
			end
		end
	else
		cell:OnClickItemCell()
	end
end

function DouqiEquipView:FlushCellFenjie(cell, data)
	if data and next(data) then
		if cell then
			local is_fenjie = DouQiData.Instance:IsInRecoveryTab(data.index)
			cell:SetIconGrayScale(is_fenjie)
			-- cell:ShowExtremeEffect(not is_fenjie)
			if not is_fenjie then
				local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
				if item_cfg then
					cell:ShowExtremeEffect(true, nil, item_cfg.color)
				end
			else
				cell:ShowExtremeEffect(false)
			end
			cell:ShowQuality(not is_fenjie)
		else
			DouQiData.Instance:RemoveRecoveryTab(data)
			for k, v in pairs(self.equip_cell_list) do
				local temp_data = v:GetData()
				if data.index == temp_data.index then
					local is_fenjie = DouQiData.Instance:IsInRecoveryTab(data.index)
					v:SetIconGrayScale(is_fenjie)
					if not is_fenjie then
						local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
						if item_cfg then
							v:ShowExtremeEffect(true, nil, item_cfg.color)
						end
					else
						v:ShowExtremeEffect(false)
					end
					v:ShowQuality(not is_fenjie)					
				end
			end
		end
	end	
end

function DouqiEquipView:FlushEquipList()
	if self.node_list["EquipListView"] and nil ~= self.node_list["EquipListView"].list_view
		and self.node_list["EquipListView"].list_view.isActiveAndEnabled then
		self.node_list["EquipListView"].list_view:Reload()
		self.node_list["EquipListView"].list_view:JumpToIndex(0) 
	end
end

function DouqiEquipView:OnFlush()
	self.douqi_euqip_datas = DouQiData.Instance:GetDouqiEquipInBag()
	self:FlushEquipList()
	self:FlushWearEquip()
end

function DouqiEquipView:FlushWearEquip()
	local fight_num = 0
	for k, v in pairs(self.equip_item_list) do
		local data = DouQiData.Instance:GetDouqiEquipByIndex(k)
		v:SetData(data)

		local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
		if item_cfg then
			fight_num = fight_num + CommonDataManager.GetCapability(item_cfg)
		end
	end

	local suit_fight_num = 0
	local suit_attr_data = DouQiData.Instance:GetSuitAllAttr()
	if suit_attr_data and next(suit_attr_data) then
		local sort_attr_data = {}
		local temp_grade_tab = {}
		for k, v in pairs(suit_attr_data) do
			if not temp_grade_tab[v.suit_order] then
				temp_grade_tab[v.suit_order] = true
				table.insert(sort_attr_data, v)
			end
		end

		for k, v in pairs(sort_attr_data) do
			local suit_attr = DouQiData.Instance:GetDouqiEquipSuitAttrCfg(v.suit_order, v.suit_type)
			suit_fight_num = suit_fight_num + CommonDataManager.GetCapability(suit_attr)
		end
	end

	self.fight_text.text.text = fight_num + suit_fight_num
end

function DouqiEquipView:OnOpenOrCloseRecovery(is_open)
	-- self.node_list["OpenRecovery"]:SetActive(not is_open)
	-- self.node_list["CloseRecovery"]:SetActive(is_open)

	DouQiCtrl.Instance:OpenEquipRecoveryView({is_open = is_open, call_back = function (callback_type, data)
		if 1 == callback_type then
			-- 设置反回调函数
			self.call_back_fun = data
		elseif 2 == callback_type then
			-- 取消分解装备data
			self:FlushCellFenjie(nil, data)
			if self.call_back_fun then
				self.call_back_fun()
			end
		elseif 3 == callback_type then
			-- 关闭界面刷新/点击toggle
			self:Flush()
		elseif 4 == callback_type then
			-- 改变按钮状态
			self.node_list["OpenRecovery"]:SetActive(not data)
			self.node_list["CloseRecovery"]:SetActive(data)		
			self.node_list["BlackBG"]:SetActive(data)	
		end
	end})
end

function DouqiEquipView:OnBtnSuitView()
	DouQiCtrl.Instance:OpenEquipSuitView()
end

function DouqiEquipView:OnBtnSuitAttrAll()
	TipsCtrl.Instance:OpenEquipAttrTipsView("douqi_suit_attr")
end





-------------------------------------
------ 装备格子 EquipItemCell
EquipItemCell = EquipItemCell or BaseClass(BaseCell)
function EquipItemCell:__init(instance, is_next)
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.node_list["EquipItem"])

	-- self.equip_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function EquipItemCell:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end
end

function EquipItemCell:ClickItem()

end

function EquipItemCell:SetItemCellHL(enable)

end

function EquipItemCell:SetFromView(from_view)
	if self.equip_cell then
		self.equip_cell:SetFromView(from_view)
	end
end

function EquipItemCell:OnFlush()
	if nil == self.data or nil == self.data.item_id or 0 >= self.data.item_id then
		self.node_list["EquidSketch"]:SetActive(true)
		self.equip_cell:SetData({})
		return
	end

	self.node_list["EquidSketch"]:SetActive(false)
	self.equip_cell:SetData(self.data)
end
