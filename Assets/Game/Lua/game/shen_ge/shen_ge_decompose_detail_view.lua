ShenGeDecomposeDetailView = ShenGeDecomposeDetailView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数

function ShenGeDecomposeDetailView:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.ui_config = {{"uis/views/shengeview_prefab", "ShenGeDecomposeDetailView"}}
	self.play_audio = true
	self.fight_info_view = true
	self.quality = 0
	self.is_select = false
	self.max_pagg_count = 0
	self.now_page = 1

end

function ShenGeDecomposeDetailView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end

end

function ShenGeDecomposeDetailView:LoadCallBack()
	self.cell_list = {}

	self.node_list["BtnBg"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))

	self.node_list["BtnResolve"].button:AddClickListener(BindTool.Bind(self.OnClickDecompose, self))

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.node_list["ListView"].scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeDecomposeDetailView:OpenCallBack()
	self:SetScrollInfo()
	self:RefreshScroller()
	self:FlushFragments()
end

function ShenGeDecomposeDetailView:RefreshScroller()
	if self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:Reload()
		self.node_list["ListView"].list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenGeDecomposeDetailView:SetScrollInfo()
	self.list_data = ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality)

	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.node_list["ListView"].list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1

	self.node_list["TxtPages"].text.text = string.format("%s/%s", self.now_page, self.max_pagg_count)
end

function ShenGeDecomposeDetailView:SetQuality(quality)
	self.quality = quality or 0
end

function ShenGeDecomposeDetailView:SetCallBack(call_back)
	self.call_back = call_back
end

function ShenGeDecomposeDetailView:SetIsSelect(is_select)
	self.is_select = is_select
end

function ShenGeDecomposeDetailView:CloseCallBack()
	if nil ~= self.call_back then
		self.call_back(self.quality, self.is_select)
		self.call_back = nil
	end
end

function ShenGeDecomposeDetailView:CloseWindow()
	self:Close()
end

function ShenGeDecomposeDetailView:OnClickDecompose()
	local list = ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality)
	local send_index_list = {}
	for _, v in pairs(list) do
		if v.is_select then
			table.insert(send_index_list, v.shen_ge_data.index)
		end
	end

	if #send_index_list <= 0 then
		return
	end

	local ok_func = function()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, #send_index_list, send_index_list)
		ShenGeData.Instance:ClearOneKeyDecomposeData()
	end

	if self.quality >= 2 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.DecomposeTip , nil, nil, true, false, "decompose_detail_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

function ShenGeDecomposeDetailView:OnValueChanged(normalizedPosition)
	local now_page = self.node_list["ListView"].list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.now_page = now_page
	end

	self.node_list["TxtPages"].text.text = string.format("%s/%s", self.now_page, self.max_pagg_count)

	if self.max_pagg_count == 0 then
		self.node_list["TxtPages"].text.text = string.format("%s/%s", 0, self.max_pagg_count)
	end

end

function ShenGeDecomposeDetailView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if not self:IsOpen() then return end

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		self:SetScrollInfo()
		self:RefreshScroller()
		self:FlushFragments()
	end
end

function ShenGeDecomposeDetailView:GetNumberOfCells()
	return math.ceil(#ShenGeData.Instance:GetShenGeSameQualityItemData(self.quality) / COLUMN)
end

function ShenGeDecomposeDetailView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenGeDetailGroup.New(cellObj)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetShenGeQuality(i, self.quality)
		cell:SetData(i, data)
		cell:SetToggleChangeCallBack(i, BindTool.Bind(self.OnSelectCallBack, self))
	end
end

function ShenGeDecomposeDetailView:FlushFragments()
	local fragment_num = 0
	local return_score = 0
	for k, v in pairs(self.list_data) do
		if v.is_select then
			cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			return_score = cfg and cfg.return_score or 0
			fragment_num = fragment_num + return_score
		end
	end

	self.node_list["TxtButton"].text.text = string.format(Language.ShenGe.ShenGeJingHua, fragment_num)
end

function ShenGeDecomposeDetailView:OnSelectCallBack()
	self:FlushFragments()
end

-------------------ShenGeDetailGroup-----------------------
ShenGeDetailGroup = ShenGeDetailGroup or BaseClass(BaseRender)
function ShenGeDetailGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ShenGeDetailCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, bag_item)
	end
end

function ShenGeDetailGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGeDetailGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGeDetailGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function ShenGeDetailGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGeDetailGroup:SetShenGeQuality(i, quality)
	self.item_list[i]:SetShenGeQuality(quality)
end

function ShenGeDetailGroup:SetToggleChangeCallBack(i, call_back)
	self.item_list[i]:SetToggleChangeCallBack(call_back)
end


-------------------ShenGeDetailCell-----------------------
ShenGeDetailCell = ShenGeDetailCell or BaseClass(BaseCell)
function ShenGeDetailCell:__init()
	self.shen_ge_quality = 0
	local item = ItemCell.New()
	item:SetInstanceParent(self.node_list["ItemCell"])
	item:SetData()
	self.item_cell = item

	self.node_list["SelectToggle"].toggle.isOn = false
	self.root_node.toggle.isOn = false
	self.node_list["SelectToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnRootNodeToggleChange, self))
end

function ShenGeDetailCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ShenGeDetailCell:SetShenGeQuality(quality)
	self.shen_ge_quality = quality
end

function ShenGeDetailCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenGeDetailCell:SetToggleChangeCallBack(call_back)
	self.call_back = call_back
end

function ShenGeDetailCell:OnSelectToggleChange(is_on)
	self.data.is_select = is_on
	self.root_node.toggle.isOn = is_on

	if nil ~= self.call_back then
		self.call_back()
	end
end

function ShenGeDetailCell:OnRootNodeToggleChange(is_on)
	self.data.is_select = is_on
	self.node_list["SelectToggle"].toggle.isOn = is_on

	if nil ~= self.call_back then
		self.call_back()
	end
end

function ShenGeDetailCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data)
	self.item_cell.node_list["Icon"].image.preserveAspect = true
	self.node_list["SelectToggle"].toggle.isOn = self.data.is_select
	self.root_node.toggle.isOn = self.data.is_select

	local shen_ge_data = self.data.shen_ge_data
	if nil == shen_ge_data then
		return
	end

	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.node_list["TxtLevelDes"].text.text = level_to_color

	for i = 0, 1 do
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		if attr_value > 0 then
			if attr_type == 8 or attr_type == 9 then
				self.node_list["TxtAttrDes" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%"
			else
				self.node_list["TxtAttrDes" .. (i + 1)].text.text = Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value
			end
		else
			self.node_list["TxtAttrDes" .. (i + 1)].text.text = ""
		end
	end
end