ShenYinRecycleView = ShenYinRecycleView or BaseClass(BaseView)
local COLUMN_NUM = 6
local EFFECT_CD = 1
local TOGGLE_COUNT = 5
local ROW_NUM = 35				--行数
local RECYCLE_ITEM_ID = 26681	--分解所得的物品现改为铭纹注灵石

function ShenYinRecycleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shenyinview_prefab", "ShenYinFenJie"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fenjie_list = {}
	self.effect_cd = 0
	self.select_all = {}
end

function ShenYinRecycleView:__delete()
	
end

function ShenYinRecycleView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.ShenYin.ShenYinTitle

	self.node_list["BtnZhuanHua"].button:AddClickListener(BindTool.Bind(self.BtnRecyleAndClose, self))
	self.node_list["BtnZhuLingShi"].button:AddClickListener(BindTool.Bind(self.OnBtnZhuLingShi, self))
	self.toggle_obj = {}
	self.cell_list = {}
	for i=1, TOGGLE_COUNT do
		self.toggle_obj[i] = self.node_list["Toggle" .. i - 1]
		self.node_list["Toggle" .. i - 1].toggle.isOn = false
		self.node_list["Toggle" .. i - 1].toggle:AddClickListener(BindTool.Bind(self.OnClickToggle, self, i))
	end

	local list_view_delegate = self.node_list["ListView"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.node_list["fenjie_count"].text.text = ItemData.Instance:GetItemNumInBagById(RECYCLE_ITEM_ID)			 --ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShenYinRecycleView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.toggle_obj = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShenYinRecycleView:OpenCallBack()
	for i = 1, TOGGLE_COUNT do
		if i == 1 then
			self.toggle_obj[i].toggle.isOn = true
		else
			self.toggle_obj[i].toggle.isOn = false
		end
	end
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self:SelectXiuLuoLi()
	self:OnClickToggle(1)
end

function ShenYinRecycleView:ItemDataChangeCallback(item_id)
	self:Flush()
end

function ShenYinRecycleView:CloseCallBack()
	self.select_all = {}
end

function ShenYinRecycleView:GetNumberOfCells()
	return ROW_NUM
end

function ShenYinRecycleView:RefreshView(cell, data_index)
	local group = self.cell_list[cell]
	if nil == group then 
		group = ShenYinFenJieItem.New(cell.gameObject)
		self.cell_list[cell] = group
	end
	for i=1,COLUMN_NUM do
		local index = data_index * COLUMN_NUM + i
		local data_list = ShenYinData.Instance:GetMarkBagInfo()
		group:SetGroupData(i, data_list[index])
		group:SetClickCallBack(i, BindTool.Bind(self.OnClickEquipItem, self, i, group.cell_list[i], index))
		group:SetGroupIndex(i, index)
		self:SetItemSelected(group.cell_list[i],  nil ~= self.select_all[index])
	end
end

function ShenYinRecycleView:OnFlush()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self.node_list["fenjie_count"].text.text = ItemData.Instance:GetItemNumInBagById(RECYCLE_ITEM_ID)				--ShenYinData.Instance:GetPastureSpiritImprintScoreInfo()
	if self.need_flush_bag then
		self.need_flush_bag = false
		-- ShenYinCtrl.SendTianXiangOperate(CS_SHEN_YIN_TYPE.SORT)
	end
end

function ShenYinRecycleView:OnClickToggle(select_index)
	--self.select_all = {}
	local data_list = ShenYinData.Instance:GetMarkBagInfo()
	if self.toggle_obj[select_index].toggle.isOn then
		for k,v in pairs(data_list) do
			if v.quanlity == select_index - 1 then
				self.select_all[k] = v
			end
		end
	else
		for k,v in pairs(data_list) do
			if v.quanlity == select_index - 1 then
				self.select_all[k] = nil
			end
		end
	end
	for k,v in pairs(self.cell_list) do
		for i = 1, COLUMN_NUM do
			local index = v:GetGroupIndex(i)
			self:SetItemSelected(v.cell_list[i], nil ~= self.select_all[index])
		end
	end
	local count = self:GetNeedFenJieCount()
	if count > 0 then count = " <color=#89F201>+" .. count .. "</color>" else count = "" end
	self.node_list["fenjie_count"].text.text = ItemData.Instance:GetItemNumInBagById(RECYCLE_ITEM_ID) .. count		--ShenYinData.Instance:GetPastureSpiritImprintScoreInfo() .. count
end

function ShenYinRecycleView:GetNeedFenJieCount()
	local need_count = 0
	for k,v in pairs(self.select_all) do
		need_count = ShenYinData.Instance:GetShenYinRecycle(v.item_id) + need_count
	end
	return need_count
end

function ShenYinRecycleView:OnClickEquipItem(i, item_cell, index)
	local item_data = item_cell:GetData()
	if nil == item_data.bag_index then return end
	if nil == self.select_all[index] then
		self.select_all[index] = item_data
	else
		self.select_all[index] = nil
	end
	self:SetItemSelected(item_cell, nil ~= self.select_all[index])
	local count = self:GetNeedFenJieCount()
	if count > 0 then count = " <color=#89F201>+" .. count .. "</color>" else count = "" end
	self.node_list["fenjie_count"].text.text = ItemData.Instance:GetItemNumInBagById(RECYCLE_ITEM_ID) .. count 		--ShenYinData.Instance:GetPastureSpiritImprintScoreInfo() .. count
end

function ShenYinRecycleView:SelectXiuLuoLi()
	local data_list = ShenYinData.Instance:GetMarkBagInfo()
	for k,v in pairs(data_list) do
		--策划说写死
		if v.item_id == 23991 or v.item_id == 23992 or v.item_id == 23993 then
			self.select_all[k] = v
		end
	end
	for k,v in pairs(self.cell_list) do
		for i = 1, COLUMN_NUM do
			local index = v:GetGroupIndex(i)
			self:SetItemSelected(v.cell_list[i], nil ~= self.select_all[index])
		end
	end
end

function ShenYinRecycleView:SetItemSelected(item_cell, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end

	--item_cell:SetToggle(is_select)
	item_cell:SetIconGrayVisible(is_select)
	item_cell:ShowHasGet(is_select)
	item_cell:ShowHighLight(false)
end

--播放分解成功特效
function ShenYinRecycleView:PlayAni()
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

function ShenYinRecycleView:OnBtnZhuLingShi()
	TipsCtrl.Instance:OpenItem({item_id = RECYCLE_ITEM_ID})
end

function ShenYinRecycleView:BtnRecyleAndClose()
	local recycle_list = {}
	-- for k,v in pairs(self.select_all) do
	-- 	recycle_list[#recycle_list + 1] = v
	-- 	recycle_list[#recycle_list].param1 = v.bag_index
	-- end
	for k,v in pairs(self.select_all) do
		table.insert(recycle_list, v.bag_index)
	end
	if #recycle_list <= 0 then
		return 
	end
	ShenYinCtrl.SendTianXiangRecycleOperate(#recycle_list, recycle_list)
	-- for k, v in pairs(recycle_list) do
	-- 	ShenYinCtrl.SendTianXiangOperate(11, v.param1, v.num)
	-- end
	self:PlayAni()
	for i = 1, TOGGLE_COUNT do
		self.node_list["Toggle" .. i - 1].toggle.isOn = false
	end
	self.select_all = {}
end


ShenYinFenJieItem = ShenYinFenJieItem or BaseClass(BaseRender)

function ShenYinFenJieItem:__init()
	-- local asset = "uis/views/shengeview/images_atlas"
	-- local bundle = "high_light"
	-- local size = 100
	self.cell_list = {}
	for i=1, COLUMN_NUM do
		self.cell_list[i] = ItemCell.New()
		self.cell_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		--self.cell_list[i]:ChangeHighLight(asset, bundle, size)
	end
end

function ShenYinFenJieItem:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenYinFenJieItem:OnFlush()

end

function ShenYinFenJieItem:SetClickCallBack(i, handler)
	self.cell_list[i]:ListenClick(handler)
end

function ShenYinFenJieItem:SetGroupIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function ShenYinFenJieItem:SetGroupData(i, data)
	self.cell_list[i]:SetData(data)
end

function ShenYinFenJieItem:GetGroupData(i, data)
	return self.cell_list[i]:GetData()
end

function ShenYinFenJieItem:GetGroupIndex(i)
	return self.cell_list[i]:GetIndex()
end