-- 仙宠灵魂分解-SoulResolveView
SoulResolveView = SoulResolveView or BaseClass(BaseView)

local EFFECT_CD = 1

local SOUL_MAX_GRID_NUM = 72
local SOUL_ROW = 4
local SOUL_COLUMN = 6

function SoulResolveView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/spiritview_prefab", "SoulResolveView",}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.effect_cd = 0
end

function SoulResolveView:__delete()
	
end

function SoulResolveView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.JingLing.TabbarName[15]
	self.node_list["Bg"].rect.sizeDelta = Vector3(920, 580, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.ClickResolve, self))

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local total_exp = SpiritData.Instance:GetSpiritSlotSoulInfo().total_exp
	self.node_list["TxtLingXing"].text.text = nil ~= total_exp and total_exp or "0"

	self.check_list_obj = {}
	for i = 1, 5 do
		self.check_list_obj[i] = self.node_list["Check_" .. i]
		self.node_list["Check_" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.Click, self, i))
	end

	self.curren_click_cell_index = -1
	self.select_item_id = 0
	self.current_click_item_id = 0 

	self.select_all = {}
	self.cell_list = {}
	self.is_first_in = true

	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

end

function SoulResolveView:ReleaseCallBack()
	self.curren_click_cell_index = -1
	self.check_list_obj = {}
	self.is_first_in = false
	self.select_all = {}

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

-- 打开后调用
function SoulResolveView:OpenCallBack()
	self.bag_list = SpiritData.Instance:GetAllSoulInfo()
	self:Flush()
end


local num = 0
function SoulResolveView:OnItemDataChange()
	if ViewManager.Instance:IsOpen(ViewName.SpiritSoulResolveView) then
		-- 下边是判断是否播放分解成功特效的，好坑
		local tmp_bag_list = SpiritData.Instance:GetAllSoulInfo()
		if #tmp_bag_list < #self.bag_list then
			self:PlayAni()
		end
		self.bag_list = TableCopy(tmp_bag_list)

		self:Flush()
	end
end

-- 关闭前调用
function SoulResolveView:CloseCallBack()
	self.select_all = {}
	self.bag_list = {}
	for color_index, check_node in pairs(self.check_list_obj) do
		check_node.toggle.isOn = false
	end
end

-- 刷新
function SoulResolveView:OnFlush(param_list)
	if self.node_list["ListView"] and self.node_list["ListView"].scroller.isActiveAndEnabled then
		self.node_list["ListView"].scroller:RefreshActiveCellViews()
	end
end

function SoulResolveView:GetNumOfCells()
	return SOUL_MAX_GRID_NUM / SOUL_COLUMN
end

--格子每次进来刷新
function SoulResolveView:RefreshCell(cell, data_index)
	local bag_list = SpiritData.Instance:GetAllSoulInfo()
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = SoulResolveViewGroup.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, SOUL_COLUMN do
		local index = data_index * SOUL_COLUMN + i
		group_cell:SetGroupIndex(i, index)
		local item_cell = group_cell.item_list[i]
		group_cell:SetGroupData(i, nil)
		
		if bag_list[index] then
			local data = bag_list[index]
			group_cell:SetGroupData(i, data)
			item_cell:SetInteractable(true)
			group_cell:SetClickCallBack(i, BindTool.Bind(self.OnClickItem, self, index, group_cell.item_list[i]))
		else
			item_cell:SetInteractable(false)
		end
		self:SetItemSelected(item_cell, index, nil ~= self.select_all[index])
	end
end

function SoulResolveView:OnClickItem(data_index, item_cell)
	local item_data = item_cell:GetData()
	if nil == item_data or nil == next(item_data) then
		return
	end

	local is_show = item_cell:IsHaseGet()
	self:SetItemSelected(item_cell, data_index, not is_show)
end

function SoulResolveView:SetItemSelected(item_cell, data_index, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end
	
	item_cell:SetToggle(false)
	item_cell:SetIconGrayVisible(is_select)
	item_cell:ShowHasGet(is_select)
	item_cell:ShowHighLight(false)

	if is_select then
		self.select_all[data_index] = item_cell:GetData()
	else
		self.select_all[data_index] = nil
	end
	self:FlsuhScore()
end

-- 刷新分数
function SoulResolveView:FlsuhScore()
	local score = 0
	local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
	local other_cfg = lieming_cfg.other
	for k, v in pairs(self.select_all) do
		local soul_cfg_exp = SpiritData.Instance:GetSoulAttrCfg(v.item_id,  v.level or 1, true)
		if soul_cfg_exp then
			score = score + (soul_cfg_exp * other_cfg[1].hunshou_exp_discount_rate * 0.01)
		end
	end
	self:FlushLingXingZhi(score)
end

function SoulResolveView:Click(index)
	self.select_all = {}
	local temp_select = {}
	local bag_list = SpiritData.Instance:GetAllSoulInfo()
	for color_index, check_node in pairs(self.check_list_obj) do
		if check_node.toggle.isOn == true then
			for k,v in pairs(bag_list) do
				if v.color == color_index then
					temp_select[k] = v
					self.select_all[k] = v
				end
			end
		end
	end

	for k, v in pairs(self.cell_list) do
		for i = 1, SOUL_COLUMN do
			local data_index = v:GetGroupIndex(i)
			self:SetItemSelected(v.item_list[i], data_index, nil ~= temp_select[data_index])
		end
	end
end

function SoulResolveView:FlushLingXingZhi(add_value)
	add_value = add_value or 0
	local current_exp = SpiritData.Instance:GetSpiritSlotSoulInfo().total_exp
	if 0 ~= add_value then
		self.node_list["TxtLingXing"].text.text = string.format(Language.HunQi.TxtLingXing, current_exp, add_value)
	else
		self.node_list["TxtLingXing"].text.text = nil ~= current_exp and current_exp or "0"
	end
end

-- 点击分解
function SoulResolveView:ClickResolve()
	
	-- for k, v in pairs(self.select_all) do
	-- 	PackageCtrl.Instance:SendDiscardItem(v.index, 1, v.item_id, 1, 1)
	-- end

	local index_list = {}
	local index_list2 = {}
	local key = 0
	for k,v in pairs(self.select_all) do
		key = key + 1
		if key <= 200 then
			index_list[key] = {}
			index_list[key].index = v.index
			index_list[key].item_id = v.item_id
			index_list[key].num = 1
		else
			index_list2[key] = {}
			index_list2[key].index = v.index
			index_list2[key].item_id = v.item_id
			index_list2[key].num = 1
		end
	end

	local number = GetListNum(index_list) 
	if number <= 0 then
		return 0
	end

	if next(index_list) then
		PackageCtrl.Instance:SendBatchDiscardItem(number, index_list)
	elseif next(index_list2) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list2, index_list2)
	end

	for k, v in pairs(self.cell_list) do
		for i = 1, SOUL_COLUMN do
			local index = v:GetGroupIndex(i)
			if nil ~= self.select_all[index] then
				v:SetGroupData(i, nil)
			end
		end
	end

	self.select_all = {}
end

function SoulResolveView:CloseWindow()
	for k, v in pairs(self.cell_list) do
		for i = 1, SOUL_COLUMN do
			v.item_list[i]:SetHighLight(false)
		end
	end
	self.select_all = {}
	self:Close()
end

function SoulResolveView:OnMoveEnd(obj)
	if not IsNil(obj) then
		ResPoolMgr:Release(obj)
	end
	self.node_list["TxtLingzhi2"].text.text = self.current_purple
	self.node_list["TxtLingzhi"].text.text = self.current_blue
	self.node_list["TxtLingzhi1"].text.text = self.current_orange
end

function SoulResolveView:ShowFlyText(begin_obj, value)
	ResPoolMgr:GetDynamicObjAsync("uis/views/hunqiview_prefab", "LingZhiText", function(obj)
		local name_table = obj:GetComponent(typeof(UINameTable))
		if name_table then
			local txt_obj = U3DObject(name_table:Find("LingZhiText"))
			txt_obj.text.text = "+" .. value
		end
		obj.transform:SetParent(begin_obj.transform, false)
		local tween = obj.transform:DOLocalMoveY(10, 1)
		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self, obj))
	end)
end

--播放分解成功特效
function SoulResolveView:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_yihuo_juji")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

------------------------------------------------------------------------------------------------------------------------------
SoulResolveViewGroup = SoulResolveViewGroup or BaseClass(BaseRender)
function SoulResolveViewGroup:__init()
	self.item_list = {}
	for i = 1, SOUL_COLUMN do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["SoulResolveFrame" .. i].gameObject)
	end
	self.effects = {}
end

function SoulResolveViewGroup:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.effects) do
		GlobalTimerQuest:CancelQuest(self.effects[k])
	end
end

function SoulResolveViewGroup:SetGroupIndex(i, index)
	self.item_list[i]:SetIndex(index)

end

function SoulResolveViewGroup:SetGroupData(i, data)
	self.item_list[i]:SetData(data)
	-- self.item_list[i]:ShowStrengthLable(nil ~= data)
	if data and data.level then
		self.item_list[i]:SetSoulResolveStrength(true, data.level)
	end
end

function SoulResolveViewGroup:SetClickCallBack(i, call_back)
	self.item_list[i]:ListenClick(call_back)
end

function SoulResolveViewGroup:GetGroupIndex(i)
	return self.item_list[i]:GetIndex()
end

function SoulResolveViewGroup:SetGroupActive(i, is_show)
	self.item_list[i].root_node:SetActive(is_show)
end