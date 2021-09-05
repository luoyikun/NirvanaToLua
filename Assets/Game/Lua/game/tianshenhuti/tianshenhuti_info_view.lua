--无双装备
-- InfoPanel
TianshenhutiInfoView = TianshenhutiInfoView or BaseClass(BaseRender)

local EQUIO_SORT = {8, 5, 6, 7, 1, 2, 3, 4}
-- 常亮定义
local BAG_MAX_GRID_NUM = 120			-- 最大格子数
local BAG_PAGE_NUM = 5					-- 页数
local BAG_PAGE_COUNT = 24				-- 每页个数
local BAG_ROW = 6						-- 行数
local BAG_COLUMN = 4					-- 列数

function TianshenhutiInfoView:__init()
	
end

function TianshenhutiInfoView:LoadCallBack(instance)
	self.tz_index = 0

	self.equip_list = {}
	for i = 1,GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT do
		local item = ItemCell.New()
		item:SetInstanceParent(self.node_list["EquipItem" .. i])
		local index = EQUIO_SORT[i] or 0
		item:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, item, index - 1))
		self.equip_list[index] = item
	end

	for i = 0, 3 do
		if i > 0 then
			local type_name = TianshenhutiData.Instance:GetTaozhuangTypeName(i)
			self.node_list["ToggleText" .. i].text.text = type_name
			self.node_list["ToggleText_" .. i].text.text = type_name
		end
		self.node_list["ToggleTabTz" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickTz, self, i))
	end

	-- 获取控件
	self.bag_data_list = {}
	self.bag_cell = {}
	local list_delegate = self.node_list["BagList"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.node_list["BtnSumAttr"].button:AddClickListener(BindTool.Bind(self.OnClickAttrReview, self))

	self.fight_text = CommonDataManager.FightPower(self, self.node_list["FightPowerLabel"])
end

function TianshenhutiInfoView:__delete()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
		v = nil
	end
	self.equip_list = {}

	self.fight_text = nil
end

function TianshenhutiInfoView:OnClickAttrReview()
	local base_attr_list = CommonDataManager.GetAttributteNoParcent(TianshenhutiData.Instance:GetProtectEquipTotalAttr())
	-- local cap = TianshenhutiData.Instance:GetProtectEquipTotalCapability()
	TipsCtrl.Instance:ShowAttrView(base_attr_list)
end

function TianshenhutiInfoView:OnClickTz(index)
	self.tz_index = index
	self.need_jump = true
	self:Flush()
end

function TianshenhutiInfoView:OnClickEquipItem(item, index)
	local data = item:GetData()
	data.index = index
	TipsCtrl.Instance:OpenItem(data, TipsFormDef.TIANSHENHUTI_EQUIP_ITEM)
end

function TianshenhutiInfoView:FlushBagList()
	for k,v in pairs(self.node_list["BagList"].list_view.ActiveCells:ToTable()) do
		if self.bag_cell[v] then
			self:RefreshCell(self.bag_cell[v])
		end
	end
end

function TianshenhutiInfoView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function TianshenhutiInfoView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = TianshenhutiEquipItemCell.New(cellObj)
		self.bag_cell[cellObj] = cell
	end
	cell.local_index = index
	self:RefreshCell(cell)
end

--刷新背包格子
function TianshenhutiInfoView:RefreshCell(cell)
	local index = cell.local_index or 0
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN  + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	local cell_data = self.bag_data_list[grid_index]
	local data = {}
	if cell_data and cell_data.item_id > 0 then
		data = cell_data
	end

	cell:SetData(data)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, data))
end

--点击格子事件
function TianshenhutiInfoView:HandleBagOnClick(data)
	local equip_cfg = TianshenhutiData.Instance:GetEquipCfgByEquipId(data.item_id)
	if not equip_cfg then return end
	local item_data = {}
	item_data.item_id = equip_cfg.item_id
	item_data.suit_id = equip_cfg.equip_id
	item_data.index = data.index
	TipsCtrl.Instance:OpenItem(item_data, TipsFormDef.TIANSHENHUTI_BAG)
end

function TianshenhutiInfoView:OpenCallBack()
	self.need_jump = true
	self:Flush()
end

function TianshenhutiInfoView:CloseCallBack()

end

function TianshenhutiInfoView:OnFlush(param_t)
	local data = TianshenhutiData.Instance
	self.bag_data_list = data:GetBagListByType(self.tz_index)
	if next(self.bag_cell) ~= nil and (not self.need_jump or self.node_list["BagList"].list_page_scroll2:GetNowPage() == 0) then
		self:FlushBagList()
	else
		self.node_list["BagList"].list_view:Reload(function()
			self.node_list["BagList"].list_page_scroll2:JumpToPageImmidate(0)
		end)
		self.node_list["BagList"].list_view:JumpToIndex(0)
		self.need_jump = false
	end
	local equip_info = data:GetEquipList()
	for k,v in pairs(self.equip_list) do
		local item_data = {}
		if equip_info[k - 1] and equip_info[k - 1].item_id then
			local equip_cfg = data:GetEquipCfgByEquipId(equip_info[k - 1].item_id)
			if equip_cfg then
				item_data.item_id = equip_cfg.item_id
				item_data.suit_id = equip_cfg.equip_id
			end
		end
		v:SetData(item_data)
	end
	if self.fight_text and self.fight_text.text then
		self.fight_text.text.text = data:GetProtectEquipTotalCapability()
	end
end

function TianshenhutiInfoView:FlushModel()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
	for k,v in pairs(vo.appearance) do
		temp_vo.appearance[k] = v
	end
	temp_vo.appearance.halo_used_imageid = 0
	temp_vo.appearance.wing_used_imageid = 0
	UIScene:SetRoleModelResInfo(temp_vo)
	vo.is_normal_wuqi = vo.appearance.fashion_wuqi_is_special == 0 and true or false
	UIScene:SetRoleModelResInfo(vo)
	local base_prof = PlayerData.Instance:GetRoleBaseProf(PlayerData.Instance:GetAttr("prof"))
	local transform = RoleModel.GetModelCameraSettingByType(MODEL_CAMERA_TYPE.BASE, "role/" .. base_prof)
	transform.rotation = Quaternion.Euler(8, -165, 0)
	UIScene:SetCameraTransform(transform)
end

function TianshenhutiInfoView:UITween()
	UITween.MoveShowPanel(self.node_list["ItemView"], Vector3(450, -27, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["BtnSumAttr"], Vector3(-60, -121, 0), 0.7)
	UITween.MoveShowPanel(self.node_list["FightPowerLabel"], Vector3(-291, -100, 0), 0.7)
	UITween.AlpahShowPanel(self.node_list["EquipParent"], true, 0.5, DG.Tweening.Ease.InExpo)
end

-----------------------------------------------------------------------------

TianshenhutiEquipItemCell = TianshenhutiEquipItemCell or BaseClass(BaseCell)

function TianshenhutiEquipItemCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["ItemParent"])
end

function TianshenhutiEquipItemCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function TianshenhutiEquipItemCell:SetData(data)
	if data and data.item_id then
		-- 这里的item_id对应配置中equip_id
		local equip_cfg = TianshenhutiData.Instance:GetEquipCfgByEquipId(data.item_id)
		if not equip_cfg then
			return
		end
		local item_data = {}
		item_data.item_id = equip_cfg.item_id
		item_data.suit_id = equip_cfg.equip_id
		self.item:SetData(item_data)
		local is_up_arrow = TianshenhutiData.Instance:IsShowUpArrow(data.item_id)
		self.item:SetShowUpArrow(is_up_arrow)
	else
		self.item:SetData(nil)
	end
end

function TianshenhutiEquipItemCell:ListenClick(handler)
	self.item:ListenClick(handler)
end

