ShengXiaoResolveView = ShengXiaoResolveView or BaseClass(BaseView)

local MAX_BAG_GRID_NUM = 210 	--总共个数
local COLUMN_NUM = 6			--列数
local ROW_NUM = 35				--行数
local TOGGLE_COUNT = 6
local EFFECT_CD = 1
function ShengXiaoResolveView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengxiaoview_prefab", "ShengXiaoFenJie"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fenjie_list = {}
	self.effect_cd = ItemData.Instance:GetItemNumInBagById(27009)
end

function ShengXiaoResolveView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.fenjie_list = {}
	self.list_view_delegate = nil

	if self.shengxiao_recycle_flush_delayer then
		GlobalTimerQuest:CancelQuest(self.shengxiao_recycle_flush_delayer)
		self.shengxiao_recycle_flush_delayer = nil
	end
end

function ShengXiaoResolveView:LoadCallBack()

	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.ShengXiao.ShengXiaoResolveView
	for i=1,TOGGLE_COUNT do
		self.node_list["Toggle" .. i].toggle.isOn = false
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
	end
	self.node_list["BtnZhuanHua"].button:AddClickListener(BindTool.Bind(self.OnClickFenJie, self))

	self.list_view_delegate = self.node_list["ListView"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.cell_list = {}
	self.fenjie_list = {}
	local need = self:GetNeedFenJieCount()
	local count = ItemData.Instance:GetItemNumInBagById(27009)
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
	self:Flush()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.node_list["Item"].button:AddClickListener(BindTool.Bind(self.OnClickItem, self))
end

function ShengXiaoResolveView:OnClickItem()
	-- 加一个点击回调，弹出27009，我也不知道为什么27009，这一页都是27009，我只是后来居上
	local data = {item_id = 27009}
	TipsCtrl.Instance:OpenItem(data)
end

function ShengXiaoResolveView:OpenCallBack()
	self.data_list = ShengXiaoData.Instance:GetBagEquipDataList()
	for i=1,TOGGLE_COUNT do
		if i == 1 or i == 2 then
			self.node_list["Toggle" .. i].toggle.isOn = true
			self:OnClickToggle(i)
		else
			self.node_list["Toggle" .. i].toggle.isOn = false
		end
	end
	-- self:Flush()
end
function ShengXiaoResolveView:OnClickFenJie()
	local list_num = GetListNum(self.fenjie_list)
	local use_table = {}
	local use_table2 = {}

	for k,v in pairs(self.fenjie_list) do
		if k > 100 then 
			table.insert(use_table2, v.index)
		else
			table.insert(use_table, v.index)
		end
	end

	if list_num <= 0 then
		return
	end
	if next(use_table2) ~= nil then
		ShengXiaoCtrl.Instance:SendZodiacRecycleEquip(list_num - 100, use_table2)
		list_num = 100
	end
	ShengXiaoCtrl.Instance:SendZodiacRecycleEquip(list_num, use_table)

	-- for k,v in pairs(self.fenjie_list) do
	-- 	ShengXiaoCtrl.Instance:SendZodiacRecycleEquip(1, v.index)
	-- end
	self.fenjie_list = {}

	self:PlayAni()
	local need = self:GetNeedFenJieCount()
	local count = ItemData.Instance:GetItemNumInBagById(27009)
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
end

function ShengXiaoResolveView:ItemDataChangeCallback(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if EquipData.IsShengXiaoEqType(item_cfg.sub_type) or item_id == 27009 then
		if self.shengxiao_recycle_flush_delayer then
			GlobalTimerQuest:CancelQuest(self.shengxiao_recycle_flush_delayer)
			self.shengxiao_recycle_flush_delayer = nil
		end
		self.shengxiao_recycle_flush_delayer = GlobalTimerQuest:AddDelayTimer(function()
			self:Flush()
		end, 0.5)
	end
end

function ShengXiaoResolveView:OnClickToggle(i)
	local active_list = ShengXiaoData.Instance:GetSameQualityItem(i)
	if self.node_list["Toggle" .. i].toggle.isOn then 
		for k,v in pairs(active_list) do
			self.fenjie_list[k] = v
		end
	else
		for k,v in pairs(active_list) do
			self.fenjie_list[k] = nil
		end
	end
	-- self.node_list["ListView"].scroller:RefreshActiveCellViews()
	-- local need = self:GetNeedFenJieCount()
	-- local count = ItemData.Instance:GetItemNumInBagById(27009)
	-- if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	-- self.node_list["fenjie_count"].text.text = count .. need
	self:Flush()
end

function ShengXiaoResolveView:OnFlush()
	-- self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self.data_list = ShengXiaoData.Instance:GetBagEquipDataList()
	if self.node_list["ListView"] and self.node_list["ListView"].scroller then
		self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
	end

	local need = self:GetNeedFenJieCount()
	local count = ItemData.Instance:GetItemNumInBagById(27009)
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
	if self.need_flush_bag then
		self.need_flush_bag = false
	end
end
function ShengXiaoResolveView:GetNeedFenJieCount()
	local need_count = 0
	for k,v in pairs(self.fenjie_list) do
		-- local data = ShengXiaoData.Instance:GetShengXiaoItemData(v)
		if v ~= nil then
			need_count = need_count + v.recyclget
		end
	end
	return need_count
end
function ShengXiaoResolveView:GetNumberOfCells()
	return ROW_NUM
end

function ShengXiaoResolveView:RefreshView(cell, data_index)
	local group = self.cell_list[cell]
	if nil == group then 
		group = ShengXiaoResolveViewItem.New(cell.gameObject)
		self.cell_list[cell] = group
	end
	for i=1,COLUMN_NUM do
		local index = data_index * COLUMN_NUM + i
		local data = self.data_list[index]
		group:SetParent(self)
		group:SetData(i , data , index)
		group:ListenClick(i, BindTool.Bind(self.OnClickEquipItem, self, i, group, index))
	end
end
--播放分解成功特效
function ShengXiaoResolveView:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guihuo_lizi")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
		self:Flush()
	end
	self.need_flush_bag = true
end
function ShengXiaoResolveView:OnClickEquipItem(i, group, index)
	local cell = group:GetCellByIndex(i)

	-- if not cell:IsHighLight() then return end 

	local data = ShengXiaoData.Instance:GetShengXiaoItemData(index)
	if nil == data or nil == next(data) then
		cell:SetHighLight(false)
		return
	end

	if self.fenjie_list[index] then 
		self.fenjie_list[index] = nil
		cell:SetHighLight(false)
	else
		self.fenjie_list[index] = data
		cell:SetHighLight(true)
	end

	local need = self:GetNeedFenJieCount()
	local count = ItemData.Instance:GetItemNumInBagById(27009)
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
end

ShengXiaoResolveViewItem = ShengXiaoResolveViewItem or BaseClass(BaseRender)

function ShengXiaoResolveViewItem:__init()
	local asset = "uis/views/shengxiaoview/images_atlas"
	local bundle = "high_light"
	local size = 100
	self.cell_list = {}
	for i=1,COLUMN_NUM do
		if nil == self.cell_list[i] then 
			local item = ItemCell.New()
			item:SetInstanceParent(self.node_list["Item" .. i])
			item:ChangeHighLight(asset, bundle, size)
			self.cell_list[i] = item
		end
	end
end

function ShengXiaoResolveViewItem:__delete()
	for k,v in pairs(self.cell_list) do
		if nil ~= self.cell_list[k] then 
			self.cell_list[k]:DeleteMe()
			self.cell_list[k] = nil
		end
	end
	self.need_parent = nil
end

function ShengXiaoResolveViewItem:SetParent(parent)
	self.need_parent = parent
end

function ShengXiaoResolveViewItem:SetData(i, data, index)
	self.cell_list[i]:SetData(data)
	self.cell_list[i]:SetIndex(index)
	-- if nil ~= data and nil ~= data.item_id and data.item_id >= 0 then 
	-- 	self.cell_list[i]:ShowHighLight(true)
	-- else
	-- 	self.cell_list[i]:ShowHighLight(false)
	-- end

	if nil == self.need_parent or nil == data or (data.item_id and data.item_id <= 0) then 
		self.cell_list[i]:SetHighLight(false)
	else
		self.cell_list[i]:SetHighLight(self.need_parent.fenjie_list[index] ~= nil)
	end
end

function ShengXiaoResolveViewItem:GetData(i)
	return self.cell_list[i]:GetData()
end

function ShengXiaoResolveViewItem:ListenClick(i, handler)
	local index = self.cell_list[i]:GetIndex()
	self.cell_list[i]:ListenClick(handler)
end

function ShengXiaoResolveViewItem:GetCellByIndex(i)
	return self.cell_list[i]
end
