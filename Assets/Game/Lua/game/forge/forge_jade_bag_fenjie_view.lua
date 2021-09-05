ForgeJadeBagFenJieView = ForgeJadeBagFenJieView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 72			-- 最大格子数
local BAG_PAGE_NUM = 3					-- 页数
local BAG_PAGE_COUNT = 24				-- 每页个数
local BAG_ROW = 4						-- 行数
local BAG_COLUMN = 6					-- 列数
local TOGGLE_COUNT = 6
local EFFECT_CD = 1

function ForgeJadeBagFenJieView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/forgeview_prefab", "JadeBagFenJieView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
end

function ForgeJadeBagFenJieView:__delete()
end

function ForgeJadeBagFenJieView:ReleaseCallBack()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}
	self.select_length = nil
end

function ForgeJadeBagFenJieView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.Forge.RecycleJade
	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["ButtonFenJie"].button:AddClickListener(BindTool.Bind(self.ButtonFenJie, self))

	self.choose_recycle_list = {}
	self.effect_cd = 0

	self.bag_cell = {}
	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	for i=1,TOGGLE_COUNT do
		self.node_list["Toggle" .. i].toggle.isOn = false
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.AutoRecyleColor, self, i))
	end
	self:InitView()
	
end

function ForgeJadeBagFenJieView:InitView()
	self.bag_jade_data = ForgeData.Instance:GetAllJadesInBag()
	self.selected_data_list = {}
	for i=1,TOGGLE_COUNT do
		if i == 1 or i == 2 then
			self.node_list["Toggle" .. i].toggle.isOn = true
			self:AutoRecyleColor(i)
		else
			self.node_list["Toggle" .. i].toggle.isOn = false
		end
	end
end

function ForgeJadeBagFenJieView:CloseWindow()
	self.choose_recycle_list = {}
	for i=1,TOGGLE_COUNT do
		self.node_list["Toggle" .. i].toggle.isOn = false
	end
	self:Close()
end

function ForgeJadeBagFenJieView:OpenCallBack()
	self.choose_recycle_list = {}
	for i=1,TOGGLE_COUNT do
		self.node_list["Toggle" .. i].toggle.isOn = false
	end
	self:Flush()
end


----------------------------
------ 玉石List
function ForgeJadeBagFenJieView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ForgeJadeBagFenJieView:BagRefreshCell(index, cellObj)
	--构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm + page * BAG_ROW * BAG_COLUMN
	-- 获取数据信息
	local data = nil
	data = self.bag_jade_data[grid_index] or {}
	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetData(cell_data, true)
	if self.choose_recycle_list[cell_data.index] then
		cell:ShowHighLight(true)
	else
		cell:ShowHighLight(false)
	end
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
end

function ForgeJadeBagFenJieView:HandleBagOnClick(cell_data, cell)
	if nil == cell_data.item_id then return end

	local bag_index = cell_data.index

	if self.choose_recycle_list[bag_index] then
		self.choose_recycle_list[bag_index] = nil
	else
		self.choose_recycle_list[bag_index] = bag_index
	end
	self:FlushChooseCellHL()
end

function ForgeJadeBagFenJieView:AutoRecyleColor(index)
	for k, v in pairs(self.bag_jade_data) do
		if v.jade_level == index then
			if self.node_list["Toggle" .. index].toggle.isOn then 
				self.choose_recycle_list[v.index] = v.index
			else
				self.choose_recycle_list[v.index] = nil
			end
		end
	end
	self:FlushChooseCellHL()
end

function  ForgeJadeBagFenJieView:OnFlush()
	self.bag_jade_data = ForgeData.Instance:GetAllJadesInBag()
	if self.node_list["ListView"] and self.node_list["ListView"].list_page_scroll2.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidate(0)
	end

	local ji_fen = ForgeData.Instance:GetJadeScore()
	ji_fen = CommonDataManager.ConverMoney(ji_fen)
	self.node_list["RecycleScore"].text.text = ji_fen
end

-- 分解
function ForgeJadeBagFenJieView:ButtonFenJie()
	local score = 0
	for k, v in pairs(self.choose_recycle_list) do
		local item_data = ItemData.Instance:GetGridData(v)
		if item_data and item_data.item_id then
			score = score + ForgeData.Instance:GetJadeResolveCfg(item_data.item_id) * item_data.num
		end
		ForgeCtrl.Instance:SendCSZhuanzhiEquipOpe(ZHUANZHI_EQUIP_OPERATE_TYPE.ZHUANZHI_EQUIP_OPERATE_TYPE_STONE_RESOLVE, v)
	end
	self.choose_recycle_list = {}
	if score > 0 then
		TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.Forge.GetJadeScore, score))
		self:PlayAni()
	end
	-- self.node_list["RecycleScore"].text.text = ForgeData.Instance:GetJadeScore()
end

-- 刷新格子高亮
function ForgeJadeBagFenJieView:FlushChooseCellHL()
	local score = 0
	for k, v in pairs(self.bag_cell) do
		if v:GetActive() then
			local data_index = v:GetData().index
			if data_index and self.choose_recycle_list[data_index] then
				v:ShowHighLight(true)
			else
				v:ShowHighLight(false)
			end
		end
	end
	for k, v in pairs(self.choose_recycle_list) do
		local item_data = ItemData.Instance:GetGridData(v)
		if item_data and item_data.item_id then
			score = score + ForgeData.Instance:GetJadeResolveCfg(item_data.item_id) * item_data.num
		end
	end
	if score > 0 then 
		score = " <color=#89F201>+" .. score .. "</color>" 
	else 
		score = "" 
	end
	local ji_fen = ForgeData.Instance:GetJadeScore()
	ji_fen = CommonDataManager.ConverMoney(ji_fen)
	self.node_list["RecycleScore"].text.text = ji_fen .. score
end

--播放分解成功特效
function ForgeJadeBagFenJieView:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guihuo_lizi")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end


