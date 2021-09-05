ShengXiaoRecycleView = ShengXiaoRecycleView or BaseClass(BaseView)
local COLUMN_NUM = 6
local EFFECT_CD = 1
local TOGGLE_COUNT = 5
local ROW_NUM = 35				--行数
local RECYCLE_ITEM_ID = 26681	--分解所得的物品现改为铭纹注灵石

function ShengXiaoRecycleView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/xingxiangview_prefab", "XingXiangFenJie"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.fenjie_list = {}
	self.effect_cd = 0
	self.select_all = {}
	self.grade_cell_list = {}
end

function ShengXiaoRecycleView:__delete()
	
end

function ShengXiaoRecycleView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.ShengXiao.ShengXiaoResolveView

	self.node_list["BtnZhuanHua"].button:AddClickListener(BindTool.Bind(self.BtnRecyleAndClose, self))
	self.toggle_obj = {}
	self.cell_list = {}

	self.node_list["Btncondition"].button:AddClickListener(BindTool.Bind(self.OpenConditonList, self))
	self.node_list["ConditionItem"].toggle:AddClickListener(BindTool.Bind(self.CleanOrder, self))
	self.node_list["BtnBlock"].button:AddClickListener(BindTool.Bind(self.OnClickBolck, self))

	local list_view_delegate = self.node_list["ListView"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.node_list["fenjie_count"].text.text = XingXiangData.Instance:GetJingHuangNum()
	self:CreateGradeList()
end

function ShengXiaoRecycleView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.toggle_obj = {}

	for k, v in pairs(self.grade_cell_list) do
		v:DeleteMe()
	end
	self.grade_cell_list = {}
end

function ShengXiaoRecycleView:CreateGradeList()
	local list_delegate = self.node_list["ConditionList"].list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #Language.ShengXiao.SelectType2
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.grade_cell_list[cell]
		if cell_item == nil then
			cell_item = OrderListCellSX.New(cell.gameObject)
			self.grade_cell_list[cell] = cell_item
		end
		cell_item:SetData(data_index + 1)
		cell_item:ListenClick(BindTool.Bind(self.OnClickGradeCell, self, data_index + 1))
	end
end

function ShengXiaoRecycleView:OnClickGradeCell(index)
	self:OnClickToggle(index)
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.is_show_condition_list = false
	local col_index = XingXiangData.Instance:GetTxtColor(index)
	local color = "#ffffff"
	if col_index > 0 then
		color = ORDER_COLOR[col_index]
	end
	self.node_list["BtnconditionTxt"].text.text = string.format(Language.ShengXiao.SelectType2[index], color)
end

function ShengXiaoRecycleView:OpenConditonList()
	self.is_show_condition_list = not self.is_show_condition_list
	self.node_list["ListScreenObj"]:SetActive(self.is_show_condition_list)
	self.node_list["BtnBlock"]:SetActive(self.is_show_condition_list)
end

function ShengXiaoRecycleView:CleanOrder()
	self.select_all = {}
	self:FlushChoseCell()
	self.is_show_condition_list = false
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
	self.node_list["BtnconditionTxt"].text.text = Language.Player.ClearSelect
end

function ShengXiaoRecycleView:OnClickBolck()
	self.is_show_condition_list = false
	self.node_list["ListScreenObj"]:SetActive(false)
	self.node_list["BtnBlock"]:SetActive(false)
end

function ShengXiaoRecycleView:OpenCallBack()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
end

function ShengXiaoRecycleView:ItemDataChangeCallback(item_id)
	self:Flush()
end

function ShengXiaoRecycleView:CloseCallBack()
	self.select_all = {}
end

function ShengXiaoRecycleView:GetNumberOfCells()
	return ROW_NUM
end

function ShengXiaoRecycleView:RefreshView(cell, data_index)
	local group = self.cell_list[cell]
	if nil == group then 
		group = ShenXiaoFenJieItem.New(cell.gameObject)
		self.cell_list[cell] = group
	end
	for i=1,COLUMN_NUM do
		local index = data_index * COLUMN_NUM + i
		local data_list = XingXiangData.Instance:GetXingXiangBagData()
		group:SetGroupData(i, data_list[index])
		group:SetClickCallBack(i, BindTool.Bind(self.OnClickEquipItem, self, i, group.cell_list[i], index))
		group:SetGroupIndex(i, index)
		self:SetItemSelected(group.cell_list[i],  nil ~= self.select_all[index])
	end
end

function ShengXiaoRecycleView:OnFlush()
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self.node_list["fenjie_count"].text.text = XingXiangData.Instance:GetJingHuangNum()
	if self.need_flush_bag then
		self.need_flush_bag = false
	end
end

function ShengXiaoRecycleView:OnClickToggle(select_index)
	self.select_all = {}
	
	local data_list = XingXiangData.Instance:GetXingXiangBagData()
	if select_index > 1 then
		for k,v in pairs(data_list) do
			if v.zodiac_index == select_index - 2 and XingXiangData.Instance:CanRecycle(v) then 
				v.bag_index = k - 1
				self.select_all[k] = v
			end
		end
	elseif select_index == 1 then
		for k,v in pairs(data_list) do
			if XingXiangData.Instance:CanRecycle(v)  then
				v.bag_index = k - 1
				self.select_all[k] = v
			end
		end
	end
	self:FlushChoseCell()
end

function ShengXiaoRecycleView:FlushChoseCell()
	for k,v in pairs(self.cell_list) do
		for i = 1, COLUMN_NUM do
			local index = v:GetGroupIndex(i)
			self:SetItemSelected(v.cell_list[i], nil ~= self.select_all[index])
		end
	end
	local count = self:GetNeedFenJieCount()
	if count > 0 then count = " <color=#89F201>+" .. count .. "</color>" else count = "" end
	self.node_list["fenjie_count"].text.text = XingXiangData.Instance:GetJingHuangNum() .. count
end

function ShengXiaoRecycleView:GetNeedFenJieCount()
	local need_count = 0
	for k,v in pairs(self.select_all) do
		need_count = need_count + XingXiangData.Instance:GetJingHuaByIndex(v.zodiac_index, v.suipian_index)
	end
	return need_count
end

function ShengXiaoRecycleView:OnClickEquipItem(i, item_cell, index)
	local item_data = item_cell:GetData()

	if nil == item_data.zodiac_index then return end
	if nil == self.select_all[index] then
		item_data.bag_index = index - 1
		self.select_all[index] = item_data
	else
		self.select_all[index] = nil
	end
	self:SetItemSelected(item_cell, nil ~= self.select_all[index])
	local count = self:GetNeedFenJieCount()
	if count > 0 then count = " <color=#89F201>+" .. count .. "</color>" else count = "" end
	self.node_list["fenjie_count"].text.text = XingXiangData.Instance:GetJingHuangNum() .. count 	
end

function ShengXiaoRecycleView:SetItemSelected(item_cell, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end
	item_cell:SetIconGrayVisible(is_select)
	item_cell:ShowHasGet(is_select)
	item_cell:ShowHighLight(false)
end

--播放分解成功特效
function ShengXiaoRecycleView:PlayAni()
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

function ShengXiaoRecycleView:OnBtnZhuLingShi()
	TipsCtrl.Instance:OpenItem({item_id = RECYCLE_ITEM_ID})
end

function ShengXiaoRecycleView:BtnRecyleAndClose()
	local recycle_list = {}
	for k,v in pairs(self.select_all) do
		table.insert(recycle_list, v.bag_index)
	end
	if #recycle_list <= 0 then
		return 
	end
	XingXiangCtrl.Instance:SendRecycleXingXiang(#recycle_list, recycle_list)
	self:PlayAni()
	self.select_all = {}
end


ShenXiaoFenJieItem = ShenXiaoFenJieItem or BaseClass(BaseRender)

function ShenXiaoFenJieItem:__init()
	self.cell_list = {}
	for i=1, COLUMN_NUM do
		self.cell_list[i] = ItemCell.New()
		self.cell_list[i]:SetInstanceParent(self.node_list["Item" .. i])
	end
end

function ShenXiaoFenJieItem:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ShenXiaoFenJieItem:OnFlush()
end

function ShenXiaoFenJieItem:SetClickCallBack(i, handler)
	self.cell_list[i]:ListenClick(handler)
end

function ShenXiaoFenJieItem:SetGroupIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function ShenXiaoFenJieItem:SetGroupData(i, data)
	self.cell_list[i]:SetData(data)
end

function ShenXiaoFenJieItem:GetGroupData(i, data)
	return self.cell_list[i]:GetData()
end

function ShenXiaoFenJieItem:GetGroupIndex(i)
	return self.cell_list[i]:GetIndex()
end

OrderListCellSX = OrderListCellSX or BaseClass(BaseCell)

function OrderListCellSX:__init(instance)

end

function OrderListCellSX:__delete()

end

function OrderListCellSX:OnFlush()
	local col_index = XingXiangData.Instance:GetTxtColor(self.data)
	local color = "#ffffff"
	if col_index > 0 then
		color = ORDER_COLOR[col_index]
	end
	self.node_list["TxtBtn"].text.text = string.format(Language.ShengXiao.SelectType2[self.data], color) 
end

function OrderListCellSX:ListenClick(handler)
	self.node_list["ConditionItem"].toggle:AddClickListener(handler)
end