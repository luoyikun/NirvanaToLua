ShenGeFenJie = ShenGeFenJie or BaseClass(BaseView)

local MAX_BAG_GRID_NUM = 210 	--总共个数
local COLUMN_NUM = 6			--列数
local ROW_NUM = 35				--行数
local TOGGLE_COUNT = 6
local EFFECT_CD = 1
function ShenGeFenJie:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shengeview_prefab", "ShenGeFenJie"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fenjie_list = {}
	self.effect_cd = 0
end

function ShenGeFenJie:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.fenjie_list = {}
	self.list_view_delegate = nil
end

function ShenGeFenJie:LoadCallBack()

	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.ShenGe.ShenGeFenJie
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
	local count = ShenGeData.Instance:GetJiFenCount()
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
	self:Flush()

end
function ShenGeFenJie:OpenCallBack()
	for i=1,TOGGLE_COUNT do
		if i == 1 or i == 2 then
			self.node_list["Toggle" .. i].toggle.isOn = true
		else
			self.node_list["Toggle" .. i].toggle.isOn = false
		end
	end
	self:Flush()
end
function ShenGeFenJie:OnClickFenJie()
	local list_num = GetListNum(self.fenjie_list)
	local use_table = {}

	for k,v in pairs(self.fenjie_list) do
		table.insert(use_table , v)
	end

	if #use_table <= 0 then
		return
	end

	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, nil, nil, nil, list_num, use_table)
	self:PlayAni()
	self.fenjie_list = {}
	local need = self:GetNeedFenJieCount()
	local count = ShenGeData.Instance:GetJiFenCount()
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
end

function ShenGeFenJie:OnClickToggle(i)
	local active_list = ShenGeData.Instance:GetSameQuaItem(i - 1)
	if self.node_list["Toggle" .. i].toggle.isOn then 
		for k,v in pairs(active_list) do
			self.fenjie_list[k] = v
		end
	else
		for k,v in pairs(active_list) do
			self.fenjie_list[k] = nil
		end
	end
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	local need = self:GetNeedFenJieCount()
	local count = ShenGeData.Instance:GetJiFenCount()
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
end

function ShenGeFenJie:OnFlush()
	self.fenjie_list = {}
	for i = 1, TOGGLE_COUNT do
		if self.node_list["Toggle" .. i].toggle.isOn then
			self:OnClickToggle(i)
		end
	end

	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	local need = self:GetNeedFenJieCount()
	local count = ShenGeData.Instance:GetJiFenCount()
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
	if self.need_flush_bag then
		self.need_flush_bag = false
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_SORT_BAG)
	end
end
function ShenGeFenJie:GetNeedFenJieCount()
	local need_count = 0
	for k,v in pairs(self.fenjie_list) do
		local data = ShenGeData.Instance:GetShenGeItemData(v)
		if data ~= nil then
			local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.level)
			if nil ~= attr_cfg and nil ~= attr_cfg.return_score and type(attr_cfg.return_score) == "number" then 
				need_count = need_count + attr_cfg.return_score 
			end
		end
	end
	return need_count
end
function ShenGeFenJie:GetNumberOfCells()
	return ROW_NUM
end

function ShenGeFenJie:RefreshView(cell, data_index)
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local group = self.cell_list[cell]
	if nil == group then 
		group = ShenGeFenJieItem.New(cell.gameObject)
		self.cell_list[cell] = group
	end
	for i=1,COLUMN_NUM do
		local index = data_index * COLUMN_NUM + i
		local data = ShenGeData.Instance:GetShenGeItemData(index - 1)
		group:SetParent(self)
		group:SetData(i , data , index - 1)
		group:ListenClick(i, BindTool.Bind(self.OnClickEquipItem, self, i, group, index - 1))
	end
end
--播放分解成功特效
function ShenGeFenJie:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guihuo_lizi")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
	self.need_flush_bag = true
end
function ShenGeFenJie:OnClickEquipItem(i, group, index)
	local cell = group:GetCellByIndex(i)

	-- if not cell:IsHighLight() then return end 

	local data = ShenGeData.Instance:GetShenGeItemData(index)
	if nil == data or nil == next(data) then
		cell:SetIconGrayVisible(false)
		cell:ShowHasGet(false)
		return
	end

	if self.fenjie_list[index] then 
		self.fenjie_list[index] = nil
		cell:SetIconGrayVisible(false)
		cell:ShowHasGet(false)
	else
		self.fenjie_list[index] = index
		cell:SetIconGrayVisible(true)
		cell:ShowHasGet(true)
	end
	local need = self:GetNeedFenJieCount()
	local count = ShenGeData.Instance:GetJiFenCount()
	if need > 0 then need = " <color=#89F201>+" .. need .. "</color>" else need = "" end
	self.node_list["fenjie_count"].text.text = count .. need
end

ShenGeFenJieItem = ShenGeFenJieItem or BaseClass(BaseRender)

function ShenGeFenJieItem:__init()
	-- local asset = "uis/views/shengeview/images_atlas"
	-- local bundle = "high_light"
	-- local size = 100
	self.cell_list = {}
	for i=1,COLUMN_NUM do
		if nil == self.cell_list[i] then 
			local item = ItemCell.New()
			item:SetInstanceParent(self.node_list["Item" .. i])
			-- item:ChangeHighLight(asset, bundle, size)
			item:ShowHighLight(false)
			self.cell_list[i] = item
		end
	end
end

function ShenGeFenJieItem:__delete()
	for k,v in pairs(self.cell_list) do
		if nil ~= self.cell_list[k] then 
			self.cell_list[k]:DeleteMe()
			self.cell_list[k] = nil
		end
	end
	self.need_parent = nil
end

function ShenGeFenJieItem:SetParent(parent)
	self.need_parent = parent
end

function ShenGeFenJieItem:SetData(i, data, index)
	self.cell_list[i]:SetData(data)
	self.cell_list[i]:SetIndex(index)
	-- if nil ~= data and nil ~= data.item_id and data.item_id >= 0 then 
	-- 	self.cell_list[i]:ShowHighLight(true)
	-- else
	-- 	self.cell_list[i]:ShowHighLight(false)
	-- end
	if nil == self.need_parent or nil == data or data.item_id <= 0 then 
		self.cell_list[i]:SetIconGrayVisible(false)
		self.cell_list[i]:ShowHasGet(false)
	else
		self.cell_list[i]:SetIconGrayVisible(self.need_parent.fenjie_list[index] ~= nil)
		self.cell_list[i]:ShowHasGet(self.need_parent.fenjie_list[index] ~= nil)
	end
end

function ShenGeFenJieItem:GetData(i)
	return self.cell_list[i]:GetData()
end

function ShenGeFenJieItem:ListenClick(i, handler)
	local index = self.cell_list[i]:GetIndex()
	self.cell_list[i]:ListenClick(handler)
end

function ShenGeFenJieItem:GetCellByIndex(i)
	return self.cell_list[i]
end
