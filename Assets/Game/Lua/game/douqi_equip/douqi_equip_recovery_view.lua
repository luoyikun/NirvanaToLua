DouqiEquipRecoveryView = DouqiEquipRecoveryView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 144			-- 最大格子数
local BAG_MIX_GRID_NUM = 6				
local BAG_PAGE_NUM = 1					-- 页数
local BAG_PAGE_COUNT = 144				-- 每页个数
local BAG_ROW = 4						-- 行
local BAG_COLUMN = 6					-- 列

function DouqiEquipRecoveryView:__init()
	self.ui_config = {
		-- {"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/douqiview_prefab", "DouqiEquipRecoveryView"}
	}
	-- self.is_modal = true
	-- self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	-- self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function DouqiEquipRecoveryView:__delete()
end

function DouqiEquipRecoveryView:ReleaseCallBack()
	for k, v in pairs(self.recovery_cell_list) do
		v:DeleteMe()
	end
	self.recovery_cell_list = {}
	self.tween = nil
end

function DouqiEquipRecoveryView:LoadCallBack()
	for i = 1, 4 do
		self.node_list["RecoveryToggle" .. i].button:AddClickListener(BindTool.Bind(self.OnBtnRecoveryToggle, self, i))

		local flag = DouQiData.Instance:GetDouqiRecoveryFlag(i)
		self.node_list["Image" .. i]:SetActive(flag == 1)

		if 4 == i then
			self.node_list["AutoEff"]:SetActive(flag == 0)
		end
	end

	self.node_list["MojingImage"].button:AddClickListener(BindTool.Bind(self.ClickVritualItem, self, ResPath.CurrencyToIconId["shengwang"]))
	self.node_list["FragmentImage"].button:AddClickListener(BindTool.Bind(self.ClickVritualItem, self, ResPath.CurrencyToIconId["DouqiFragment"]))
	self.node_list["BlackBG"].button:AddClickListener(BindTool.Bind(self.OpenViewWithData, self))
	self.node_list["BtnRecovery"].button:AddClickListener(BindTool.Bind(self.OnBtnRecovery, self))

	self.equip_datas = {}
	self.recovery_cell_list = {}
	local recovery_list_delegate = self.node_list["RecoveryListView"].page_simple_delegate
	recovery_list_delegate.NumberOfCellsDel = BindTool.Bind(self.RecoveryNumberOfCells, self)
	recovery_list_delegate.CellRefreshDel = BindTool.Bind(self.RecoveryRefreshCell, self)
	self:FlushRecoveryList()
end


function DouqiEquipRecoveryView:FlushRecoveryList()
	if self.node_list["RecoveryListView"] and nil ~= self.node_list["RecoveryListView"].list_view
		and self.node_list["RecoveryListView"].list_view.isActiveAndEnabled then
		self.node_list["RecoveryListView"].list_view:Reload()
		self.node_list["RecoveryListView"].list_view:JumpToIndex(0) 
	end
end

function DouqiEquipRecoveryView:OpenViewWithData(data)
	if nil == data or not data.is_open then 
		if self.node_list and self.node_list["RecoveryPanel"] then
			if self.call_back then
				self.call_back(4, false)
			end
			-- self.node_list["BlackBG"]:SetActive(false)
			self.tween = nil
			self.tween = self.node_list["RecoveryPanel"].transform:DOAnchorPos(Vector3(-313, 0, 0), 0.5)
			self.tween:SetEase(DG.Tweening.Ease.OutCubic)
			self.tween:OnComplete(function ()
				self.tween = nil
				-- self.node_list["BlackBG"]:SetActive(true)
				self:Close()
			end)
		end
		-- UITween.MoveShowPanel(self.node_list["RecoveryPanel"] , Vector3(299, 0, 0), 0.5, function ()
		-- 	self:Close()
		-- end)
		return
	end

	self.call_back = data.call_back
	if self.call_back then
		self.call_back(1, BindTool.Bind(self.CallBackFun, self))
	end
	self:Open()
end

function DouqiEquipRecoveryView:OpenCallBack()
	self.tween = nil
	self.tween = self.node_list["RecoveryPanel"].transform:DOAnchorPos(Vector3(299, 0, 0), 0.5)
	self.tween:SetEase(DG.Tweening.Ease.OutCubic)
	self.tween:OnComplete(function ()
		self.tween = nil
	end)
	-- UITween.MoveShowPanel(self.node_list["RecoveryPanel"] , Vector3(-313, 0, 0), 0.5)
	if self.call_back then
		self.call_back(4, true)
	end
	DouQiData.Instance:SetRecoveryDataList()
	DouQiData.Instance:SetIsOpenRecoveryView(true)
	self:Flush()
	if self.call_back then
		self.call_back(3)
	end
end

function DouqiEquipRecoveryView:CloseCallBack()
	self.tween = nil
	DouQiData.Instance:SetIsOpenRecoveryView(false)
	DouQiData.Instance:ClearRecoveryTab()
	if self.call_back then
		self.call_back(3)
		self.call_back = nil
	end
	self.equip_datas = {}
end

-- 分解格子
function DouqiEquipRecoveryView:RecoveryNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function DouqiEquipRecoveryView:RecoveryRefreshCell(index, cellObj)
	local cell = self.recovery_cell_list[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.node_list["RecoveryListView"].toggle_group)
		-- cell:SetHideEffect(true)
		cell:ListenClick(BindTool.Bind(self.ClickCell, self, cell))
		self.recovery_cell_list[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_row = math.floor(index / BAG_COLUMN) + 1 - page * BAG_COLUMN
	local cur_colunm = math.floor(index % BAG_COLUMN) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	local data = self.equip_datas[grid_index + 1] or {}
	cell:SetData(data)
end

function DouqiEquipRecoveryView:ClickCell(cell)
	local data = cell:GetData()
	if nil == data or not next(data) then return end

	cell:SetData({})
	if self.call_back then
		self.call_back(2, data)
	end
end

function DouqiEquipRecoveryView:OnFlush()
	self.equip_datas = DouQiData.Instance:GetRecoveryDataTab()
	self:FlushRecoveryList()

	local recovery_fragment = 0
	local recovery_mojing = 0
	for k, v in pairs(self.equip_datas) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			if item_cfg.recycltype == 6 then
				recovery_mojing = recovery_mojing + item_cfg.recyclget
			elseif item_cfg.recycltype == 14 then
				recovery_fragment = recovery_fragment + item_cfg.recyclget
			end
		end
	end
	self.node_list["GetRecycle"].text.text = recovery_mojing
	self.node_list["GetRecycle2"].text.text = recovery_fragment
end

function DouqiEquipRecoveryView:CallBackFun()
	self:Flush()
end

function DouqiEquipRecoveryView:OnBtnRecovery()
	local index_list = {}
	local count = 0
	for k, v in pairs(self.equip_datas) do
		count = count + 1
		index_list[count] = v
	end

	PackageCtrl.Instance:SendBatchDiscardItem(count, index_list)
	DouQiData.Instance:ClearRecoveryTab()
end

-- 1蓝装以下 2紫装 3橙装 4自动分解 
function DouqiEquipRecoveryView:OnBtnRecoveryToggle(btn_type)
	local flag = DouQiData.Instance:GetDouqiRecoveryFlag(btn_type) == 0 and 1 or 0
	DouQiData.Instance:SetDouqiRecoveryFlag(btn_type, flag)
	DouQiData.Instance:SetRecoveryDataList()
	self:Flush()
	self:FlushHL(btn_type)

	if self.call_back then
		self.call_back(3)
	end
end

function DouqiEquipRecoveryView:FlushHL(btn_type)
	local flag = DouQiData.Instance:GetDouqiRecoveryFlag(btn_type)
	self.node_list["Image" .. btn_type]:SetActive(flag == 1)

	if 4 == btn_type then
		self.node_list["AutoEff"]:SetActive(flag == 0)
	end
end

function DouqiEquipRecoveryView:ClickVritualItem(item_id)
	TipsCtrl.Instance:OpenItem({item_id = item_id})
end


