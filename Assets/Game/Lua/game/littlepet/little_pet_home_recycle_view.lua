-- 宠物家园回收
LittlePetHomeRecycleView = LittlePetHomeRecycleView or BaseClass(BaseView)
-- local Max_PAGE_COUNT = 9
local PACKAGE_MAX_GRID_NUM = 210	-- 6行 * 5列 * 4页
local PACKAGE_ROW = 6
local PACKAGE_COLUMN = 35
local TOGGLE_COUNT = 6
local EFFECT_CD = 1
function LittlePetHomeRecycleView:__init()
	self.ui_config = {
	{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
	{"uis/views/littlepetview_prefab","ShowHomeRecyclePetView"}
}
	self.data_list = {}
	self.selected_data_list = {}
	self.recycle_type_num_list = {}
	self.is_modal = true    
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function LittlePetHomeRecycleView:__delete()
end

function LittlePetHomeRecycleView:LoadCallBack()
	LittlePetData.Instance:ClearRecycleConditon()
	self.node_list["Bg"].rect.sizeDelta = Vector3(958,558,0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))
	self.node_list["Txt"].text.text = Language.LittlePet.RecycleTitle

	self.effect_cd = 0

	--self.recycle_score = self:FindVariable("Score")
	self:FlushScore()
	--self.page = self:FindVariable("Page")
	self.package_pet_cell = {}
	self.package_list_view = self.node_list["ListView"]
	local list_delegate = self.package_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.PackageGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.PackageRefreshCell, self)

	-- self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	-- self:ListenEvent("OnClickExchangeButton", BindTool.Bind(self.OnClickExchangeButton, self))
	-- self:ListenEvent("OnClickRecycleButton", BindTool.Bind(self.OnClickRecycleButton, self))
	-- self:ListenEvent("OnClickAutoFilt", BindTool.Bind(self.OnClickAutoFilt, self))

	-- self.node_list["ButtonExchange"].button:AddClickListener(BindTool.Bind(self.OnClickExchangeButton, self))
	self.node_list["ButtonRecycle"].button:AddClickListener(BindTool.Bind(self.OnClickRecycleButton, self))
	-- self.node_list["ButtonAutoFilt"].button:AddClickListener(BindTool.Bind(self.OnClickAutoFilt, self))
	for i=1,TOGGLE_COUNT do
		self.node_list["Toggle" .. i].toggle.isOn = false
		self.node_list["Toggle" .. i].toggle:AddClickListener(BindTool.Bind(self.AutoRecyleColor, self, i))
	end

end

function LittlePetHomeRecycleView:ReleaseCallBack()
	for k,v in pairs(self.package_pet_cell) do
		if v then
			v:DeleteMe()
		end
	end
	self.package_pet_cell = {}
	self.package_list_view = nil
	--self.page = nil
	--self.recycle_score = nil
end

function LittlePetHomeRecycleView:OpenCallBack()
	-- 计算页数
	local total_page_count = PACKAGE_MAX_GRID_NUM / (PACKAGE_ROW * PACKAGE_COLUMN)
	-- self.package_list_view.list_page_scroll:SetPageCount(total_page_count)
	-- for i = 1, Max_PAGE_COUNT do
	-- 	if total_page_count < i then 
	-- 		self.node_list["PageToggle" .. i]:SetActive(false)
	-- 	else
	-- 		self.node_list["PageToggle" .. i]:SetActive(true)
	-- 	end
	-- end
	-- 回收选择列表
	self.selected_data_list = {}
	-- 回收积分初始化为0
	-- self.node_list["Score"].text.text = string.format(Language.LittlePet.GetJiFen , 0)
	self.data_list = LittlePetData.Instance:GetLittlePetRecycleData()
	for i=1,TOGGLE_COUNT do
		if i == 1 or i == 2 then
			self.node_list["Toggle" .. i].toggle.isOn = true
			self:AutoRecyleColor(i)
		else
			self.node_list["Toggle" .. i].toggle.isOn = false
		end
	end

	self:Flush()
end

function LittlePetHomeRecycleView:CloseCallBack()
	self.recycle_type_num_list = {}
	LittlePetData.Instance:ClearRecycleConditon()
end

function LittlePetHomeRecycleView:OnClickClose()
	LittlePetCtrl.Instance:CloseRecyleView()
	self:Close()
end

function LittlePetHomeRecycleView:OnFlush(param_t)
	self.data_list = LittlePetData.Instance:GetLittlePetRecycleData()
	for k,v in pairs(param_t) do
		if k == "clear" then
			-- 回收选择列表
			self.selected_data_list = {}
			-- 回收积分初始化为0
			local ji_fen = LittlePetData.Instance:GetCurJiFenByInfo()
			ji_fen = CommonDataManager.ConverMoney(ji_fen)
			self.node_list["Score"].text.text = ji_fen
			-- self.package_list_view.scroller:RefreshActiveCellViews()
		end
	end
	if self.package_list_view then
		if next(self.data_list) then
			self.package_list_view.scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.package_list_view.scroller:ReloadData(0)
		end
	end
end

function LittlePetHomeRecycleView:PackageGetNumberOfCells()
	return PACKAGE_COLUMN
end

function LittlePetHomeRecycleView:PackageRefreshCell(cell, data_index)
	local group = self.package_pet_cell[cell]
	if group == nil then
		group = LittlePetHomeRecycleGroup.New(cell.gameObject)
		self.package_pet_cell[cell] = group
	end

	group:SetToggleGroup(self.package_list_view.toggle_group)
	-- local page = math.floor(data_index / PACKAGE_COLUMN)
	-- local column = data_index - page * PACKAGE_COLUMN
	local grid_count = PACKAGE_COLUMN * PACKAGE_ROW
	for i = 1, PACKAGE_ROW do
		-- local index = (i - 1) * PACKAGE_COLUMN + column + (page * grid_count)
		local index = data_index * PACKAGE_ROW + i
		local data = nil
		data = self.data_list[index]
		data = data or {}
		if data.index == nil then
			data.index = index
		end

		group:SetData(i, {item_id = data.item_id, num = data.num})--, is_up_arrow = up_arrow_flag
		group:ListenClick(i, BindTool.Bind(self.HandlePackageOnClick, self, data, group, i, index))
		group:SetInteractable(i, nil ~= data.item_id)
		group:ShowHighLight(i, false)
		group:SetSelected(i, data.index ~= nil and self.selected_data_list[index] ~= nil)
	end
end

function LittlePetHomeRecycleView:HandlePackageOnClick(data, group, group_index, data_index, is_higher_power)
	local fun = function ()
		if self.selected_data_list[data_index] then
			self.selected_data_list[data_index] = nil
			group:SetSelected(group_index, false)
			group:SetHighed(group_index, false)
		else
			local temp_list = {}
			local recycle_score, recycle_type = LittlePetData.Instance:GetRecycleDataByItemID(data.item_id)
			temp_list.item_id = data.item_id or 0
			temp_list.recycle_score = recycle_score or 0
			temp_list.recycle_type = recycle_type or 0
			temp_list.num = data.num or 1
			temp_list.index = data.index
			self.selected_data_list[data_index] = temp_list
			group:SetSelected(group_index, true)
			group:SetHighed(group_index, true)
		end

		self:FlushScore()
	end
	fun()
	-- if is_higher_power then
	-- 	local describe = Language.LittlePet.FenJieHighPowerPet
	-- 	--TipsCtrl.Instance:ShowCommonAutoView(nil, describe, fun, nil, nil, nil, nil, nil, true)
	-- else
	-- 	fun()
	-- end
end

function LittlePetHomeRecycleView:SetItemHighLight()
end

-- function LittlePetHomeRecycleView:OnClickExchangeButton()
--    ViewManager.Instance:Open(ViewName.LittlePetView, TabIndex.little_pet_exchange)
--    self:Close()
-- end

function LittlePetHomeRecycleView:OnClickRecycleButton()
	local total_score = 0
	local index_list = {}
	local index_list2 = {}

	for k,v in pairs(self.selected_data_list) do
		if k <= 200 then
			table.insert(index_list, v)
		else
			table.insert(index_list2, v)
		end
		total_score = total_score + v.recycle_score * v.num
		-- PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
	end

	if #index_list <= 0 then
		return 0
	end

	if next(index_list) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list, index_list)
	elseif next(index_list2) then
		PackageCtrl.Instance:SendBatchDiscardItem(#index_list2, index_list2)
	end

	if total_score > 0 then
		self:PlayAni()
	end
	self.selected_data_list = {}
end

-- function LittlePetHomeRecycleView:OnClickAutoFilt()
-- 	LittlePetCtrl.Instance:OpenRecyleView(BindTool.Bind(self.AutoRecyleColor, self))
-- end

function LittlePetHomeRecycleView:AutoRecyleColor(color)
	self.recycle_type_num_list = {}
	local small_power = LittlePetData.Instance:HomeEquipPowerPet() or 0
	if self.data_list then
		for i = 1, #self.data_list do
			if self.data_list[i] and not LittlePetData.Instance:IsFeedItem(self.data_list[i].item_id) then
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data_list[i].item_id)
				local func = function()
					local temp_list = {}
					local recycle_score, recycle_type = LittlePetData.Instance:GetRecycleDataByItemID(self.data_list[i].item_id)
					temp_list.item_id = self.data_list[i].item_id or 0
					temp_list.recycle_score = recycle_score or 0
					temp_list.recycle_type = recycle_type or 0
					temp_list.num = 1
					temp_list.index = self.data_list[i].index
					if self.node_list["Toggle" .. color].toggle.isOn then 
						self.selected_data_list[i] = temp_list
					else
						self.selected_data_list[i] = nil
					end
				end
				if item_cfg.sub_type >= 1200 and item_cfg.sub_type <= 1203 then
					local max_color = LittlePetData.Instance:GetLittlePetEquipMaxColorByType(item_cfg.sub_type)
					if item_cfg.color >= max_color and color == max_color then
						if self.recycle_type_num_list[item_cfg.sub_type] == nil then
							self.recycle_type_num_list[item_cfg.sub_type] = 0
						end
						if self.recycle_type_num_list[item_cfg.sub_type] < 5 then
							self.recycle_type_num_list[item_cfg.sub_type] = self.recycle_type_num_list[item_cfg.sub_type] + 1
						else
							if item_cfg.color == color and item_cfg.color == max_color then
								max_color = max_color + 1
							end
						end
					end
					if item_cfg.color == color and item_cfg.color < max_color then
						func()
					end
				elseif GameEnum.USE_TYPE_LITTLE_PET == item_cfg.sub_type then
					local select_flag = LittlePetData.Instance:CheckIsHigherPowerPet(self.data_list[i], small_power)
					if item_cfg.color == color and not select_flag then
						func()
					end
				end
			end
		end
	end


	-- for k,v in pairs(self.selected_data_list) do
	-- 	local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
	-- 	if GameEnum.ITEM_BIGTYPE_EQUIPMENT == big_type then
	-- 		if self.recycle_type_num_list[big_type] == nil then
	-- 			self.recycle_type_num_list[big_type] = 0
	-- 		end
	-- 		if self.recycle_type_num_list[big_type] < 5 then
	-- 			self.recycle_type_num_list[big_type] = self.recycle_type_num_list[big_type] + 1
	-- 		else

	-- 		end
	-- 	end
	-- end


	if self.package_list_view then
		self.package_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:FlushScore()
end

function LittlePetHomeRecycleView:FlushScore()
	local total_score = 0
	for k,v in pairs(self.selected_data_list) do
		total_score = total_score + v.recycle_score * v.num
	end
	if total_score > 0 then 
		total_score = " <color=#89F201>+" .. total_score .. "</color>" 
	else 
		total_score = "" 
	end
	local ji_fen = LittlePetData.Instance:GetCurJiFenByInfo()
	ji_fen = CommonDataManager.ConverMoney(ji_fen)
	self.node_list["Score"].text.text = ji_fen .. total_score
end

--播放分解成功特效
function LittlePetHomeRecycleView:PlayAni()
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

---------------------- 小宠物背包组 ----------------------
LittlePetHomeRecycleGroup = LittlePetHomeRecycleGroup or BaseClass(BaseCell)

function LittlePetHomeRecycleGroup:__init(instance)
	local asset = "uis/views/shengeview/images_atlas"
	local bundle = "high_light"
	local size = 100
	self.cells = {}
	self.selected_list = {}
	self.data = {}
	for i = 1, PACKAGE_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:ChangeHighLight(asset, bundle, size)
		self.cells[i]:SetInstanceParent(self.node_list["Item"..i])
		--self.selected_list[i] = self:FindVariable("IsSelected"..i)
	end
end

function LittlePetHomeRecycleGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function LittlePetHomeRecycleGroup:SetData(i, data)
	self.data[i] = data
	self.cells[i]:SetData(data)
end

function LittlePetHomeRecycleGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function LittlePetHomeRecycleGroup:SetToggleGroup(toggle_group)
	-- for k, v in ipairs(self.cells) do
	-- 	v:SetToggleGroup(toggle_group)
	-- end
end

function LittlePetHomeRecycleGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function LittlePetHomeRecycleGroup:SetSelected(i, enable)
	-- self.node_list["IsSelected" .. i]:SetActive(enable)
	if self.data[i].item_id then
		self.cells[i]:SetIconGrayVisible(enable)
		--self.cells[i]:ShowHighLight(enable)
		self.cells[i]:ShowHasGet(enable)
		return
	end
	--self.cells[i]:ShowHasGet(false)
end

function LittlePetHomeRecycleGroup:SetHighed(i, enable)
	if self.data[i].item_id then
		--self.cells[i]:ShowHighLight(enable)
		self.cells[i]:SetIconGrayVisible(enable)
		self.cells[i]:ShowHasGet(enable)
	end
end
function LittlePetHomeRecycleGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end