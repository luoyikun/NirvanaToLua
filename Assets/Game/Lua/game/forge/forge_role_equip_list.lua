ForgeRoleEquipList = ForgeRoleEquipList or BaseClass(BaseRender)
--装备格列表和数据列表都是从0开始的
local MOVE_TIME = 0.5

function ForgeRoleEquipList:__init()
	self.cell_list = {}
	self.view_click_index = {}
end

function ForgeRoleEquipList:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	
	self.select_callback = nil
	self.select_index = nil
	self.old_view = nil
	self.role_view_index = nil
end

function ForgeRoleEquipList:LoadCallBack()
	self:GetEquipDataList()
	
	local list_view_delegate = self.node_list["EquipList"].list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)
end

function ForgeRoleEquipList:GetEquipDataList()
	self.curr_equip_type = "" 			-- 防止List没清除数据，点不到第一个装备
	self.equip_data = {}
	if not self:GetIsZhuanzhiEquip() then
		local sort_tab = {
			[0] = 6, [1] = 5, [2] = 10,
			[3] = 7, [4] = 9, [5] = 4,
			[6] = 0, [7] = 1, [8] = 8, 
			[9] = 2, [10] = 3
		}
		local equip_data = EquipData.Instance:GetDataList()

		local count = 1
		for k, v in pairs(sort_tab) do
			if equip_data[v] and equip_data[v].item_id > 0 then
				self.equip_data[count] = {}
				self.equip_data[count].data_index = v
				self.equip_data[count].click_index = k
				self.equip_data[count].equip_type = "base_equip"
				count = count + 1
			end
		end
		self.curr_equip_type = "base_equip"
	else
		-- 排序列表
		local sort_tab = {
			[0] = 0, [1] = 1, [2] = 2,
			[3] = 3, [4] = 4, [5] = 8,
			[6] = 5, [7] = 6, [8] = 7, [9] = 9,
		}
		local equip_data = ForgeData.Instance:GetZhuanzhiEquipAll()
		-- local is_hide = self:GetZhuanzhiIsHideIndex()
		local count = 1
		for k, v in pairs(sort_tab) do
			if equip_data[v] and equip_data[v].item_id > 0 then
				self.equip_data[count] = {}
				self.equip_data[count].data_index = v
				self.equip_data[count].click_index = v
				self.equip_data[count].equip_type = "zhuanzhi_equip"
				count = count + 1
			end
		end

		-- if is_hide then
		-- 	for i = #self.equip_data, 1, -1 do
		-- 		if self.equip_data[i].data_index == 9 or self.equip_data[i].data_index == 0 then
		-- 			table.remove(self.equip_data, i)
		-- 		end
		-- 	end
		-- end
		self.curr_equip_type = "zhuanzhi_equip"
	end
end

function ForgeRoleEquipList:GetNumberOfCells()
	return #self.equip_data or 0
end

function ForgeRoleEquipList:RefreshListView(cell, cell_index)
	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = EquipCell.New(cell.gameObject)
		item_cell:SetToggleGroup(self.node_list["EquipList"].toggle_group)
		item_cell:SetParentView(self)
		item_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCell, self))
		self.cell_list[cell] = item_cell
	end

	local data = self.equip_data[cell_index + 1]
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data)
	local select_index = self.view_click_index[self.role_view_index] or self.select_index
	item_cell:SetSelectHL(select_index == data.click_index)
end

function ForgeRoleEquipList:OnFlush(param_t)
	self:GetEquipDataList()
	for k,v in pairs(param_t) do
		if k == "uitween" then
			UITween.MoveShowPanel(self.node_list["Bg"] , Vector3(-140, -407, 0) , MOVE_TIME)
			UITween.AlpahShowPanel(self.node_list["Bg"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)			
		elseif k == "click" then
			self.node_list["EquipList"].scroller:ReloadData(0)

			if nil == self.delay_flush_timer then
				self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(function ()
					if self.delay_flush_timer ~= nil then
						GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
						self.delay_flush_timer = nil
					end
					self:ClickItemCellByShowIndex()
				end, 0)
			end
		elseif k == "flushview" then
			self.node_list["EquipList"].scroller:RefreshActiveCellViews()
		elseif k == "reload" then
			self.node_list["EquipList"].scroller:ReloadData(0)
			if nil == self.delay_flush_timer then
				self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(function ()
					if self.delay_flush_timer ~= nil then
						GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
						self.delay_flush_timer = nil
					end
					self:ClickItemCellByShowIndex()
				end, 0)
			end
		end
	end
end

function ForgeRoleEquipList:OnClickItemCell(cell)
	local index = cell:GetDataIndex()
	local click_index = cell:GetClickIndex()
	if self.select_index == click_index and self.old_view == self.role_view_index then
		return
	end

	self:FlushCellHL(click_index)
	self.select_index = click_index
	self.old_view = self.role_view_index
	if nil ~= self.select_callback then
		self.select_callback(index)
	end

	self.view_click_index[self.role_view_index] = click_index
end

function ForgeRoleEquipList:ClickItemCellByShowIndex()
	local first_cell_index = nil
	if nil == self.view_click_index[self.role_view_index] then
		for k, v in pairs(self.cell_list) do
			if ((not first_cell_index) or first_cell_index > v:GetClickIndex()) and self.curr_equip_type == v:GetDataEquipType() then
				first_cell_index = v:GetClickIndex()
			end
		end
	end

	local click_index = first_cell_index and first_cell_index or self.view_click_index[self.role_view_index]
	local is_false_hl = true
	for k, v in pairs(self.cell_list) do
		if v:GetClickIndex() == click_index then
			self:OnClickItemCell(v)
			is_false_hl = false
		end
	end

	if is_false_hl then
		for k, v in pairs(self.cell_list) do
			v:SetSelectHL(false)
		end
	end
end

function ForgeRoleEquipList:FlushCellHL(index)
	for k, v in pairs(self.cell_list) do
		v:SetSelectHL(index == v:GetClickIndex())
	end
end

function ForgeRoleEquipList:SetSelectCallBack(callback)
	self.select_callback = callback
end

-- 设定当前选择了哪个面板
function ForgeRoleEquipList:SetViewIndex(index)
	self.role_view_index = index
end

function ForgeRoleEquipList:GetViewIndex()
	return self.role_view_index
end

-- 转职装备面板隐藏武器和护符0 和 9
function ForgeRoleEquipList:GetZhuanzhiIsHideIndex()
	return (self.role_view_index == TabIndex.forge_deity_suit)
end

-- 转职装备
function ForgeRoleEquipList:GetIsZhuanzhiEquip()
	return (self.role_view_index == TabIndex.forge_jade or self.role_view_index == TabIndex.forge_jade_refine
			or self.role_view_index == TabIndex.forge_deity_intersify or self.role_view_index == TabIndex.forge_jue_xing)
end


----------------------------------------------------------
-----------装备格子 EquipCell
----------------------------------------------------------
EquipCell = EquipCell or BaseClass(BaseCell)
function EquipCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.item_cell:SetFromView(TipsFormDef.FROM_BAG_EQUIP)
	-- self.toggle = self.root_node.toggle
	-- self.node_list["ShengText"]:SetActive(false)
	self.node_list["BaseEquipCell"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function EquipCell:SetParentView(parent_view)
	self.parent_view = parent_view
end

function EquipCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function EquipCell:OnFlush()
	local equip_data = {}
	if self.parent_view:GetIsZhuanzhiEquip() then
		equip_data = ForgeData.Instance:GetZhuanzhiEquip(self.data.data_index)
	else
		equip_data = EquipData.Instance:GetGridData(self.data.data_index)
	end

	if nil == equip_data or nil == equip_data.item_id then
		return
	end

	self.item_cell:SetData(equip_data)
	self.item_cell:SetInteractable(true)
	self.item_cell:SetIconGrayVisible(false)
	self.item_cell:SetIconGrayScale(false)
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	if nil == item_cfg then return end
	
	local role_view_index = self.parent_view:GetViewIndex()

	self.node_list["Name"].text.text = item_cfg.name
	self.node_list["HLName"].text.text = item_cfg.name

	self:SetItemCell(role_view_index, equip_data)

	local can_improve = ForgeData.Instance:CheckFunIsCanImprove(equip_data, role_view_index)
	if can_improve == 0 then
		self.node_list["RedPoint"]:SetActive(true)
	else
		self.node_list["RedPoint"]:SetActive(false)
	end
end

function EquipCell:SetItemCell(role_view_index, equip_data)
	self.node_list["Star"]:SetActive(false)
	self.node_list["Level"]:SetActive(false)
	-- self.node_list["Level"].text.text = ""
	self.item_cell:ShowEquipGrade(false)
	self.item_cell:ShowStrengthLable(false)
	
	if role_view_index == TabIndex.forge_advance then
		self.item_cell:ShowEquipGrade(true)
	elseif role_view_index == TabIndex.forge_strengthen then
		self.item_cell:ShowEquipGrade(true)
		if equip_data.param.strengthen_level > 0 then
			self.item_cell:ShowStrengthLable(true)
		end
		self.node_list["Level"].text.text = string.format(Language.Forge.StrengthLevel, equip_data.param.strengthen_level)
		self.node_list["Level"]:SetActive(true)
	elseif  role_view_index == TabIndex.forge_gem then
		self.item_cell:ShowEquipGrade(true)

	elseif role_view_index == TabIndex.forge_cast then
		self:ShowStarByLevel(equip_data.param.shen_level)
		self.node_list["Star"]:SetActive(true)
	elseif role_view_index == TabIndex.forge_quality then
		local quality_cfg = ForgeData.Instance:GetForgeQualityCfg(self.data.data_index, equip_data.param.quality)
		if quality_cfg then
			self.node_list["Level"].text.text = ToColorStr(quality_cfg.pre, ORDER_COLOR[quality_cfg.c_quality])
		else
			self.node_list["Level"].text.text = ""
		end
		self.node_list["Level"]:SetActive(true)
	elseif  role_view_index == TabIndex.forge_jade then
		self.item_cell:ShowEquipGrade(true)
	elseif role_view_index == TabIndex.forge_jade_refine then
		local jade_info = ForgeData.Instance:GetEquipJadeInfo(self.data.data_index)
		local refine_level = jade_info and jade_info.refine_level or 0
		self.node_list["Level"].text.text = "+" .. refine_level
		self.node_list["Level"]:SetActive(true)
	elseif role_view_index == TabIndex.forge_jue_xing then
		self.item_cell:ShowEquipGrade(true)
		local equip_list = ForgeData.Instance:GetLeftEquipAwakeningAllInfoByIndex(equip_data.index)
		local level = 0
		if equip_list then
			for i=1, GameEnum.MAX_ZHUANZHI_EQUIP_AWAKENING_COUNT do
				level = level + equip_list[i].level
			end
		end
		
		self.node_list["Level"].text.text = string.format(Language.Forge.HuaShenLevel, level)
		self.node_list["Level"]:SetActive(true)

	elseif  role_view_index == TabIndex.forge_deity_intersify then
		self.item_cell:ShowEquipGrade(true)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	if EquipData.Instance:IsZhuanzhiEquipType(item_cfg.sub_type) and role_view_index ~= TabIndex.forge_jue_xing then
		self.node_list["Desc"]:SetActive(true)
		if equip_data.index == 5 or equip_data.index == 6 or equip_data.index == 7 then
			self.node_list["Desc"].text.text = Language.Forge.ShouShiDec
		else
			self.node_list["Desc"].text.text = ""
		end
	else
		self.node_list["Desc"]:SetActive(false)
		self.node_list["Desc"].text.text = ""
	end

end

function EquipCell:OnClick(is_bool)
	BaseCell.OnClick(self)
end

function EquipCell:SetSelectHL(is_hl)
	self.node_list["HLBg"]:SetActive(is_hl)
end

function EquipCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function EquipCell:GetDataIndex()
	return self.data and self.data.data_index
end

function EquipCell:GetClickIndex()
	return self.data and self.data.click_index
end

function EquipCell:GetDataEquipType()
	return self.data and self.data.equip_type
end

-- 神铸
function EquipCell:ShowStarByLevel(star_level)
	if star_level <= 0 then 
		for i = 1, 5 do
			self.node_list["Star" .. i]:SetActive(false)
		end
		return
	end

	local star_type = math.floor(star_level / 5)
	local star_count = star_level % 5

	for i = 1, 5 do
		local name = ""
		if i <= star_count then
			self.node_list["Star" .. i]:SetActive(true)
			if star_type + 1 == 6 then
				name = ("cast_icon_star_big6")
			else
				name = ("icon_star_big" .. star_type + 1)
			end
		else
			if star_level < 5 then
				self.node_list["Star" .. i]:SetActive(false)
			else
				self.node_list["Star" .. i]:SetActive(true)
				if star_type == 6 then
					name = ("cast_icon_star_big6")
				else
					name = ("icon_star_big" .. star_type)
				end
			end
		end
		if name ~= "" then
			local bubble, asset = ResPath.GetImages(name)
			self.node_list["Star" .. i].image:LoadSprite(bubble, asset)
		end
	end
end
