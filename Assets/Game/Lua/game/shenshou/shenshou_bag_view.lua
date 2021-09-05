
ShenShouBagView = ShenShouBagView or BaseClass(BaseView)
local BAG_MAX_GRID_NUM = 200			-- 最大格子数
function ShenShouBagView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/shenshouview_prefab", "ShenshouBagView"}
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
	self.play_audio = true
	self.bag_cell = {}
	self.equip_t = {}
	self.quality = 0
	self.star = 0
	self.open_q_sect = false
	self.open_s_sect = false
	self.shou_id = 1
	self.data_list = {}
	self.equip_txt_t = {}
	self.equip_up_t = {}
	self.cache_index = nil
end

function ShenShouBagView:__delete()

end

function ShenShouBagView:ReleaseCallBack()
	for k,v in pairs(self.equip_t) do
		v:DeleteMe()
	end
	self.equip_t = {}

	for k,v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self.bag_cell = {}
	self.equip_txt_t = {}
	self.equip_up_t = {}
end

function ShenShouBagView:LoadCallBack()
	self.node_list["Txt"].text.text = Language.Title.LongQiZhuangBei
	self.node_list["Bg"].rect.sizeDelta = Vector3(975,583,0)
	for i = 1, 5 do
		local item_cell = ShenShouEquip.New()
		item_cell:SetInstanceParent(self.node_list["Equip_Item" .. i])
		item_cell:ShowHighLight(false)
		self.equip_t[i] = item_cell
		self.equip_txt_t[i] = self.node_list["TxtEquip" .. i]
		self.equip_up_t[i] = self.node_list["Up" .. i]
		--self.equip_up_t[i].transform:SetAsLastSibling()
		self.node_list["BtnEquipBg" .. i].button:AddClickListener(BindTool.Bind(self.EquipCellClick, self, i, item_cell))
	end

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	for i = 0, 4 do
		self.node_list["Btn" .. i + 1].button:AddClickListener(BindTool.Bind(self.OnClickQuality, self, i))
	end
	for i = 0, 3 do
		self.node_list["BtnSelectStar" .. i + 1].button:AddClickListener(BindTool.Bind(self.OnClickStar, self, i))
	end
	for k=1,5 do
		self.node_list["BtnEquipHigh" .. k]:SetActive(false)
	end
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnActivate"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
	-- self.node_list["BtnQuality"].button:AddClickListener(BindTool.Bind(self.OnClickSelectQuality, self))
	-- self.node_list["BtnStar"].button:AddClickListener(BindTool.Bind(self.OnClickSelectStar, self))
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.node_list["Display"].ui3d_display, 0)

	local start_pos = Vector3(30 , -30 , 0)
	local end_pos = Vector3(30 , 0 , 0)
	UITween.MoveLoop(self.node_list["UpArrow"], start_pos, end_pos, 1)
end

function ShenShouBagView:EquipCellClick(i)
	for k=1,5 do
		self.node_list["BtnEquipHigh" .. k]:SetActive(false)
	end
	self.node_list["BtnEquipHigh" .. i]:SetActive(true)
	local slot_data = ShenShouData.Instance:GetOneSlotData(self.shou_id, i - 1)
	local is_filter = false
	if nil ~= slot_data then
		if slot_data.item_id > 0 then
			is_filter = false
		else
			is_filter = true
		end
	else
		is_filter = true
	end

	if is_filter then
		self:FilterShenShouBag(i)
	end
end

function ShenShouBagView:ItemDataChangeCallback()
	self:FlushShenShouBag()
end

function ShenShouBagView:EquipClick(i, cell)
	if cell.data and cell.data.item_id and  cell.data.item_id > 0 then
		local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(cell.data.item_id)
		if nil == shenshou_equip_cfg then return end

		self.shenshou_equip_cfg = shenshou_equip_cfg
		ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouEquipView, self.shou_id)
	end
end

function ShenShouBagView:OpenShenShouBag(shou_id, cache_index)
	if shou_id < 0 then return end
	self.shou_id = shou_id
	self.cache_index = cache_index
	self:Open()
end

function ShenShouBagView:FilterShenShouBag(i)
	local quality_requirement = ShenShouData.Instance:GetQualityRequirementCfg(self.shou_id, i - 1)
	local bag_cfg = ShenShouData.Instance:GetShenshouBackpackInfo()
	local list_1 = {}
	for k,v in pairs(bag_cfg) do
		if v.is_equip == 1 and v.slot_index == quality_requirement.slot and v.quality >= quality_requirement.slot_need_quality then
			list_1[#list_1 + 1] = v
		end
	end
	if #list_1 == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.NoRightEquip)
		-- TipsCtrl.Instance:ShowCommonAutoView("", Language.ShenShou.NoRightEquip, BindTool.Bind(self.OnClickGet, self), nil, nil, Language.ShenShou.GainEquip)
		return
	end

	self.quality = 0
	self.star = 0
	self:RecoverSelect()

	table.sort(list_1, ShenShouData.Instance:SortList("quality", "star_count", "is_equip"))

	self.data_list = list_1
	if self.node_list["ListView"] and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:JumpToIndex(0)
		self.node_list["ListView"].list_view:Reload()
	end
end

function ShenShouBagView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function ShenShouBagView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ShenShouCell.New(cellObj)
		-- cell.name = "shenshou_bag"
		cell:SetToggleGroup(self.node_list["ListView"].toggle_group)
		self.bag_cell[cellObj] = cell
	end

	local grid_index = math.floor(index / 4) * 4 + (4 - index % 4)
	-- 获取数据信息
	local data = self.data_list[grid_index] or {}
	cell:SetShouId(self.shou_id)
	cell:SetData(data, true, self.node_list["UpArrow"])
	cell:ShowHighLight(false)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell, grid_index))
end

function ShenShouBagView:HandleBagOnClick(cell, index)
	if nil == cell.data then return end
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(cell.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end
	if self.shenshou_equip_cfg.is_equip == 1 then
		ShenShouCtrl.Instance:SetDataAndOepnEquipTip(cell:GetData(), ShenShouEquipTip.FromView.ShenShouBagView, self.shou_id)
	else
		ShenShouCtrl.Instance:OpenShenShouStuffTip(cell.data)
	end
end


function ShenShouBagView:OnClickQuality(i)
	for k=1,5 do
		self.node_list["BtnEquipHigh" .. k]:SetActive(false)
	end
	self.quality = i
	self.open_q_sect = false
	self.node_list["PanelSelectQuality"]:SetActive(false)
	self:FlushShenShouBag()
end

function ShenShouBagView:OnClickStar(i)
	for k=1,5 do
		self.node_list["BtnEquipHigh" .. k]:SetActive(false)
	end
	self.star = i
	self.open_s_sect = false
	self.node_list["PanelSelectStar"]:SetActive(false)
	self:FlushShenShouBag()
end

function ShenShouBagView:FlushShenShouBag()
	self.node_list["TxtRightContent"].text.text = Language.ShenShou.ChooseBtnText[self.quality]
	self.node_list["TxtStar"].text.text = Language.ShenShou.ChooseBtnText2[self.star]

	local data_list = {}
	local shenshou_eq = ShenShouData.Instance:UpFilterShenShouEq(self.quality, self.star, self.shou_id)
	for k,v in pairs(shenshou_eq) do
		if v.is_equip ~= 0 then
			table.insert(data_list, v)
		end
	end
	self.data_list = data_list
	if self.node_list["ListView"] and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.node_list["ListView"].list_view:JumpToIndex(0)
		self.node_list["ListView"].list_view:Reload()
	end
end

function ShenShouBagView:OnClickGet()
	ViewManager.Instance:Close(ViewName.ShenShou)
	ViewManager.Instance:Close(ViewName.ShenShouBag)
	ViewManager.Instance:Open(ViewName.ShenYuBossView, TabIndex.kf_boss)
end

function ShenShouBagView:OnClickSelectQuality()
	self.open_q_sect = not self.open_q_sect
	self.node_list["PanelSelectQuality"]:SetActive(self.open_q_sect)
end

function ShenShouBagView:OnClickSelectStar()
	self.open_s_sect = not self.open_s_sect
	self.node_list["PanelSelectStar"]:SetActive(self.open_s_sect)
end

function ShenShouBagView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:Flush()
end


function ShenShouBagView:CloseCallBack()
	self:RecoverSelect()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShenShouBagView:RecoverSelect()
	self.quality = 0
	self.star = 0
	self.node_list["PanelSelectQuality"]:SetActive(false)
	self.node_list["PanelSelectStar"]:SetActive(false)
	self.open_q_sect = false
	self.open_s_sect = false
	self.node_list["TxtRightContent"].text.text = Language.ShenShou.ChooseBtnText[self.quality]
	self.node_list["TxtStar"].text.text = Language.ShenShou.ChooseBtnText2[self.star]
end

function ShenShouBagView:OnFlush(param_t)
	local shou_cfg = ShenShouData.Instance:GetShenShouCfg(self.shou_id)
	if next(shou_cfg) then 
		local model_id = shou_cfg.model_id
		local bundle, asset = ResPath.GetLongqiModel(model_id)
		self.model_view:SetMainAsset(bundle, asset)
	else
		self.model_view:ClearModel()
	end
	local is_active  = ShenShouData.Instance:IsShenShouActive(self.shou_id)
	--UI:SetGraphicGrey(self.node_list["DisplayBoss"], not is_active)
	UI:SetGraphicGrey(self.node_list["Display"], not is_active)
	local last_active = self.node_list["Feng"].gameObject.activeInHierarchy
	self.node_list["Feng"]:SetActive(not is_active)
	if not is_active and last_active == is_active then 
		UITween.ScaleShowPanel(self.node_list["Feng"], Vector3(0.7, 0.7, 0.7))
	end
	if self.cache_index then
		self:FilterShenShouBag(self.cache_index)
		self.cache_index = nil
	else
		self:FlushShenShouBag()
	end

	local quality_requirement = ShenShouData.Instance:GetQualityRequirement(self.shou_id)
	for k,v in pairs(quality_requirement) do
		local str = Language.ShenShou.ItemDesc[v.slot_need_quality] .. Language.ShenShou.ZhuangBeiLeiXing[v.slot]
		self.equip_txt_t[v.slot + 1].text.text = "<color=" .. ITEM_TIP_COLOR[v.slot_need_quality] .. ">" .. str .. "</color>"
	end

	local shenshou_list = ShenShouData.Instance:GetShenshouList(self.shou_id)
	local is_visible = ShenShouData.Instance:GetShenShouHasRemindImg(self.shou_id)
	local flag = false
	if shenshou_list then
		for k, v in pairs(shenshou_list.equip_list) do
			self.equip_t[k]:SetData(v)
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(v, self.shou_id, k)
			local is_up_arrow = flag
			self.equip_up_t[k].image.enabled = is_up_arrow
			self.equip_t[k].root_node:SetActive(v ~= nil and v.item_id > 0)
			if v.item_id > 0 then
				self.equip_t[k]:ListenClick(BindTool.Bind(self.EquipClick, self, k, self.equip_t[k]))
			end
		end
	else
		for k,v in pairs(self.equip_t) do
			flag = ShenShouData.Instance:GetHasBetterShenShouEquip(nil, self.shou_id, k)
			local is_up_arrow = flag
			self.equip_up_t[k].image.enabled = is_up_arrow
			v.root_node:SetActive(false)
		end
	end
	for k=1,5 do
		self.node_list["BtnEquipHigh" .. k]:SetActive(false)
	end
end

------------------------------------------------------------------------------------------------------------------

ShenShouCell = ShenShouCell or BaseClass(BaseCell)
function ShenShouCell:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["item"])
end

function ShenShouCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function ShenShouCell:ShowHighLight(value)
	self.item:ShowHighLight(value)
end

function ShenShouCell:SetToggleGroup(toggle_group)
	self.item:SetToggleGroup(toggle_group)
end

function ShenShouCell:ListenClick(handler)
	self.item:ListenClick(handler)
end

function ShenShouCell:SetData(data, is_from_bag, anim_obj)
	self.data = data
	self.item:SetData(data)
	if nil == data or not next(data) then
		self.item:ShowQuality(false)
		self.node_list["UpArrow"]:SetActive(false)
		self:AnimLoop(false , anim_obj)
		return
	end
	
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	self.shenshou_equip_cfg = shenshou_equip_cfg
	if nil == shenshou_equip_cfg then return end

	--设置图标
	local bundle, asset = ResPath.GetItemIcon(shenshou_equip_cfg.icon_id)
	self.item:SetAsset(bundle, asset)

	self.item:ShowQuality(true)
	local quality = shenshou_equip_cfg.quality
	if shenshou_equip_cfg.is_equip == 1 then
		quality = quality + 1
	else
		quality = quality + 2
	end
	self.item:SetQualityByColor(quality)

	-- local star_count = 0
	-- if self.data.attr_list then
	-- 	for k,v in pairs(self.data.attr_list) do
	-- 		if v.attr_type > 0 then
	-- 			local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(shenshou_equip_cfg.quality, v.attr_type) or {}
	-- 			if random_cfg.is_star_attr ==1 then
	-- 				star_count = star_count + 1
	-- 			end
	-- 		end
	-- 	end
	-- else
	-- 	star_count = self.data.param and self.data.param.star_level or 0
	-- end
	-- self.item:SetShowStar(star_count)

	local flag = ShenShouData.Instance:GetIsBetterShenShouEquip(self.data, self.select_shou_id or 0)
	self.node_list["UpArrow"]:SetActive(flag)
	self:AnimLoop(flag , anim_obj)

	if self.data.strength_level and self.data.strength_level > 0 then
		self.item:ShowStrengthLable(true)
		self.item:SetStrength(self.data.strength_level)
	else
		self.item:ShowStrengthLable(false)
	end
end

function ShenShouCell:SetShouId(select_shou_id)
	self.select_shou_id = select_shou_id
end

function ShenShouCell:AnimLoop(active , anim_obj)
	if active then 
		UITween.AddChildMoveLoop(self.node_list["UpArrow"] , anim_obj)
	else
		UITween.ReduceChildMoveLoop(self.node_list["UpArrow"] , anim_obj)
	end
end