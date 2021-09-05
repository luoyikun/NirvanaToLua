-- 仙盟仓库
-- GuildWarehouseView

GuildWarehouseView = GuildWarehouseView or BaseClass(BaseView)

local Warehouse_Cell_COUNT = 102   -- 右边仓库格子数量

-- 仓库的状态
local Warehouse_Cell_State = {
	Normal = 0,				-- 正常状态
	Manger = 1,				-- 清理状态,盟主或副盟主独有
}

function GuildWarehouseView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseSecondPanel"},
		{"uis/views/guildview_prefab", "GuildWarehouseView"},
	}
	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GuildWarehouseView:__delete()
	self.log_data_list = {}
	self.equip_list = {}
	self.select_equip_list = {}	
	self.is_select_equip_by_quality = false
	self.quality_index = -1
	self.is_select_equip_by_steps = false
	self.steps_index = -1
end

function GuildWarehouseView:ReleaseCallBack()
	for k, v in pairs(self.guild_warehouse_log_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.guild_warehouse_log_cell_list = {}

	for k, v in pairs(self.guild_warehouse_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.guild_warehouse_cell_list = {}
end

function GuildWarehouseView:LoadCallBack()
	self.node_list["TitleText"].text.text = Language.Guild.GuildWarehouseTitle
	self.node_list["CloseButton"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["BtnClear"].button:AddClickListener(BindTool.Bind(self.OnClickClear, self))
	self.node_list["BtnContribute"].button:AddClickListener(BindTool.Bind(self.OnClickContribute, self))
	self.node_list["BtnExitManger"].button:AddClickListener(BindTool.Bind(self.OnClickExitManger, self))
	self.node_list["BtnDestroy"].button:AddClickListener(BindTool.Bind(self.OnClickDestroy, self))
	self.node_list["ToggleProf"].toggle:AddClickListener(BindTool.Bind(self.OnToggleProf, self))
	self.node_list["BtnUpArrows_1"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnBgQuality"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnDownArrows_1"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnUpArrows_2"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["BtnBgPinJie"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["BtnDownArrows_2"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["IconJiFen"].button:AddClickListener(function ()
			TipsCtrl.Instance:OpenItem({item_id = COMMON_CONSTS.VIRTUAL_ITEM_WAREHOUSE_SCORE})	-- 仙盟仓库积分
		end)

	self.warehouse_cell_state = Warehouse_Cell_State.Normal  -- 状态
	self.log_data_list = GuildData.Instance:GetGuildWarehouseLogDataList()		-- 日志数据列表
	-- self.equip_list = GuildData.Instance:GetGuildWarehouseDataList()			-- 格子所有装备列表, 背包显示的装备
	self.select_equip_list = {}				-- 挑选的装备数据列表, 挑选用于清理的装备
	self.is_select_equip_by_quality = false	-- 是否按品质挑选装备
	self.quality_index = -1					-- 挑选的品质索引
	self.is_select_equip_by_steps = false 	-- 是否按品阶挑选装备
	self.steps_index = -1					-- 挑选的品阶索引

	self.guild_warehouse_log_cell_list = {}
	local left_list_delegate = self.node_list["LeftListView"].list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLeftListNumberOfCell, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellLeftList, self)

	self.guild_warehouse_cell_list = {}
	local right_list_delegate = self.node_list["WarehouseListView"].list_simple_delegate
	right_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsRight, self)
	right_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)
end

function GuildWarehouseView:OpenCallBack()
	ForgeData.Instance:SetIsFlushEquipPower(true)
	self.warehouse_cell_state = Warehouse_Cell_State.Normal
	self.log_data_list = GuildData.Instance:GetGuildWarehouseLogDataList()
	self.equip_list = GuildData.Instance:GetGuildWarehouseDataList()
	self:Flush("flush_state_panel")
	self:Flush("warehouse_score")
end

function GuildWarehouseView:GetLeftListNumberOfCell()
	return #self.log_data_list or 0
end

function GuildWarehouseView:RefreshCellLeftList(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.guild_warehouse_log_cell_list[cell]
	if cell_item == nil then
		cell_item = GuildWarehouseLogCell.New(cell.gameObject)
		self.guild_warehouse_log_cell_list[cell] = cell_item
	end
	local data = self.log_data_list and self.log_data_list[data_index] or {}
	cell_item:SetData(data)
end

function GuildWarehouseView:GetNumberOfCellsRight()
	return  Warehouse_Cell_COUNT / 6
end

function GuildWarehouseView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.guild_warehouse_cell_list[cell]
	if contain_cell == nil then
		contain_cell = GuildWarehouseGrop.New(cell.gameObject)
		self.guild_warehouse_cell_list[cell] = contain_cell
	end

	for i = 1, 6 do
		local index = cell_index * 6 + i
		local data = self.equip_list[index]
		contain_cell:SetGroupIndex(i, index)
		contain_cell:SetGroupData(i, data, self.warehouse_cell_state)
		local item_cell = contain_cell.item_cell_list[i]
		if data then
			item_cell:SetInteractable(true)
			contain_cell:SetClickCallBack(i, BindTool.Bind(self.OnClickItem, self, index, contain_cell.item_cell_list[i]))
		else
			item_cell:SetInteractable(false)
		end
		self:SetItemSelected(item_cell, nil ~= self.select_equip_list[index])
	end
end

-- 点击物品格子
function GuildWarehouseView:OnClickItem(index, item_cell)
	local item_data = item_cell:GetData()
	if nil == item_data or nil == next(item_data) then
		return
	end

	local is_show = item_cell:IsHaseGet()
	self:SetItemSelected(item_cell, not is_show)

	if not is_show then
		self.select_equip_list[index] = item_data
	else
		self.select_equip_list[index] = nil
	end
end

-- 选中物品格子
function GuildWarehouseView:SetItemSelected(item_cell, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end

	item_cell:SetToggle(false)
	item_cell:ShowHighLight(false)
	local is_gray = false
	local item_data = item_cell:GetData()
	if item_data then
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_data.item_id)
		if item_cfg then
			local gamevo = GameVoManager.Instance:GetMainRoleVo()
			local equip_index = EquipData.Instance:GetEquipIndexByType(item_cfg.sub_type)
			if big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT and equip_index >= 0 then
				if (gamevo.prof % 10) ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
					is_gray = true
				end
			end
		end
	end
	item_cell:SetIconGrayVisible(is_select or is_gray)
	item_cell:ShowExtremeEffect(false)
	item_cell:SetLimitUse()
	item_cell:ShowHasGet(is_select)
end

function GuildWarehouseView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "warehouse_score" then
			local storge_info = GuildData.Instance:GetGuildStorgeInfo()
			if storge_info then
				self.node_list["TextScore"].text.text = storge_info.storage_score or 0
			end
		elseif k == "warehouse_log" then
			self.log_data_list = GuildData.Instance:GetGuildWarehouseLogDataList()
			self.node_list["LeftListView"].scroller:ReloadData(0)
		elseif k == "warehouse_equip" then
			self:FlushSelectList()
		elseif k == "contribute_success" then
			if self.node_list and self.node_list["WarehouseListView"] and self.node_list["WarehouseListView"].scroller and self.node_list["WarehouseListView"].scroller.isActiveAndEnabled then
				self.select_equip_list = {}
				-- self.equip_list = GuildData.Instance:GetGuildWarehouseDataList()
				self:FlushSelectList()
				self.node_list["WarehouseListView"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		elseif k == "flush_state_panel" then
			self:FlushStatePanel()
		end
	end
end

-- 刷新界面状态
function GuildWarehouseView:FlushStatePanel()
	if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
		self.node_list["NormalPanel"]:SetActive(true)
		self.node_list["ManagerPanel"]:SetActive(false)
		self.node_list["ToggleProf"]:SetActive(true)
	elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
		self.node_list["NormalPanel"]:SetActive(false)
		self.node_list["ManagerPanel"]:SetActive(true)
		self.node_list["ToggleProf"]:SetActive(false)
	end
	self.select_equip_list = {}
	self.node_list["TextSelet_1"].text.text = Language.Guild.SeletListTitle[1]
	self.node_list["TextSelet_2"].text.text = Language.Guild.SeletListTitle[2]
	self.node_list["ToggleProf"].toggle.isOn = false
	self.is_select_equip_by_quality = false
	self.quality_index = -1
	self.is_select_equip_by_steps = false
	self.steps_index = -1
	self:FlushSelectList()
	self.node_list["WarehouseListView"].scroller:ReloadData(0)
end

-- 点击清空装备
function GuildWarehouseView:OnClickClear()
	-- 是否是盟主或者副盟主
	local post = GuildData.Instance:GetGuildPost()
	if post ~= GuildDataConst.GUILD_POST.TUANGZHANG and post ~= GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.GuildWarehouseTip)
		return
	end

	self.warehouse_cell_state = Warehouse_Cell_State.Manger
	self:FlushStatePanel()
end

-- 捐献装备
function GuildWarehouseView:OnClickContribute()
	GuildCtrl.Instance:OpenConTributeView()
end

-- 退出管理
function GuildWarehouseView:OnClickExitManger()
	self.warehouse_cell_state = Warehouse_Cell_State.Normal
	self:FlushStatePanel()
end

-- 销毁装备
function GuildWarehouseView:OnClickDestroy()
	if self.select_equip_list and GetListNum(self.select_equip_list) > 0 then
		local last_select_item_list = {}
		local num = 0
		for k,v in pairs(self.select_equip_list) do
			if v then
				num = num + 1
				table.insert(last_select_item_list, {item_index = v.index, param_1 = v.item_id})
			end
		end
		if last_select_item_list and num > 0 then
			GuildCtrl.Instance:SendStorgeOneKeyOperate(GUILD_STORGE_ONE_KEY_OPERATE.GUILD_STORGE_OPERATE_DISCARD_ITEM_ONE_KEY, num, last_select_item_list)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.PleaseSelect)
	end
end

function GuildWarehouseView:OnToggleProf()
	self:FlushSelectList()
end

-- 点击挑选装备按品质
function GuildWarehouseView:OnClickSelectEquipByQuality()
	self.is_select_equip_by_quality = not self.is_select_equip_by_quality
	self.node_list["BtnUpArrows_1"]:SetActive(self.is_select_equip_by_quality)
	self.node_list["BtnDownArrows_1"]:SetActive(not self.is_select_equip_by_quality)

	local function close_call_back()
		self.is_select_equip_by_quality = not self.is_select_equip_by_quality
		self.node_list["BtnUpArrows_1"]:SetActive(self.is_select_equip_by_quality)
		self.node_list["BtnDownArrows_1"]:SetActive(not self.is_select_equip_by_quality)
	end

	local function func_cancle()
		self.quality_index = -1
		self.node_list["TextSelet_1"].text.text = Language.Guild.SeletListTitle[1]
		self:FlushSelectList()
	end

	local function func_select(quality_index)
		self.quality_index = quality_index + 3
		if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
			self.node_list["TextSelet_1"].text.text = Language.Guild.SelectListName[1][quality_index]
		elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
			self.node_list["TextSelet_1"].text.text = Language.Guild.SelectListName[2][quality_index]
		end
		self:FlushSelectList()
	end

	if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
		GuildCtrl.Instance:SetDropDownFixationViewParam(Vector3(185, 200, 0), Language.Guild.SelectListName[1], func_select, func_cancle, close_call_back)
	elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
		GuildCtrl.Instance:SetDropDownFixationViewParam(Vector3(185, 200, 0), Language.Guild.SelectListName[2], func_select, func_cancle, close_call_back)
	end
end

-- 点击挑选装备按品阶
function GuildWarehouseView:OnClickSelectEquipBySteps()
	self.is_select_equip_by_steps = not self.is_select_equip_by_steps
	self.node_list["BtnUpArrows_2"]:SetActive(self.is_select_equip_by_steps)
	self.node_list["BtnDownArrows_2"]:SetActive(not self.is_select_equip_by_steps)
	local role = GameVoManager.Instance:GetMainRoleVo()
	local max_step, select_list_name = GuildData.Instance:GetMaxStepAndListDataByRoleLv(role.level, Language.Guild.SelectListName[3])
	local _, select_list_name_two = GuildData.Instance:GetMaxStepAndListDataByRoleLv(role.level, Language.Guild.SelectListName[4])

	local function close_call_back()
		self.is_select_equip_by_steps = not self.is_select_equip_by_steps
		self.node_list["BtnUpArrows_2"]:SetActive(self.is_select_equip_by_steps)
		self.node_list["BtnDownArrows_2"]:SetActive(not self.is_select_equip_by_steps)
	end

	local function func_cancle()
		self.steps_index = -1
		self.node_list["TextSelet_2"].text.text = Language.Guild.SeletListTitle[2]
		self:FlushSelectList()
	end

	local function func_select(steps_index)
		self.steps_index = max_step - steps_index + 1
		if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
			self.node_list["TextSelet_2"].text.text = select_list_name[steps_index + 1]
		elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
			self.node_list["TextSelet_2"].text.text = select_list_name_two[steps_index + 1]
		end
		self:FlushSelectList()
	end

	if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
		GuildCtrl.Instance:SetDropDownScrollViewParam(Vector3(410, 138, 0), select_list_name, func_select, func_cancle, close_call_back)
	elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
		GuildCtrl.Instance:SetDropDownScrollViewParam(Vector3(410, 138, 0), select_list_name_two, func_select, func_cancle, close_call_back)
	end
end

-- 刷新物品格子列表
function GuildWarehouseView:FlushSelectList()
	self.equip_list = GuildData.Instance:GetGuildWarehouseDataList()
	if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
		local new_equip_list = {}
		if self.quality_index ~= -1 or self.steps_index ~= -1 or self.node_list["ToggleProf"].toggle.isOn then
			local item_id = GuildData.Instance:GetOtherConfig().storage_constant_item_id or 0
			table.insert(new_equip_list, {item_id = item_id, is_bind = 1})
		end
		if self.node_list["ToggleProf"].toggle.isOn then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			if self.quality_index == -1 then
				if self.steps_index == -1 then
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if base_prof == item_cfg.limit_prof then
							table.insert(new_equip_list, v)
						end
					end
				else
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.steps_index == item_cfg.order and base_prof == item_cfg.limit_prof then
							table.insert(new_equip_list, v)
						end
					end
				end
			else
				if self.steps_index == -1 then
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.quality_index == item_cfg.color and base_prof == item_cfg.limit_prof then
							table.insert(new_equip_list, v)
						end
					end
				else
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.quality_index == item_cfg.color and self.steps_index == item_cfg.order and base_prof == item_cfg.limit_prof then
							table.insert(new_equip_list, v)
						end
					end
				end
			end
		else
			if self.quality_index == -1 then
				if self.steps_index == -1 then
					for k, v in pairs(self.equip_list) do
						table.insert(new_equip_list, v)
					end
				else
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.steps_index == item_cfg.order then
							table.insert(new_equip_list, v)
						end
					end
				end
			else
				if self.steps_index == -1 then
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.quality_index == item_cfg.color then
							table.insert(new_equip_list, v)
						end
					end
				else
					for k, v in pairs(self.equip_list) do
						local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
						if self.quality_index == item_cfg.color and self.steps_index == item_cfg.order then
							table.insert(new_equip_list, v)
						end
					end
				end
			end
		end
		self.equip_list = new_equip_list
		self.node_list["WarehouseListView"].scroller:RefreshAndReloadActiveCellViews(true)
	elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
		self.select_equip_list = {}
		local new_equip_list = TableCopy(self.equip_list)
		local item_id = GuildData.Instance:GetOtherConfig().storage_constant_item_id or 0
		for k,v in pairs(new_equip_list) do
			if v and v.item_id == item_id then
				table.remove(new_equip_list, k)
			end
		end
		self.equip_list = new_equip_list
		if self.quality_index == -1 then
			if self.steps_index == -1 then
				self.select_equip_list = {}
			else
				for k, v in pairs(self.equip_list) do
					local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
					if item_cfg and item_cfg.order then
						if self.steps_index >= item_cfg.order then
							self.select_equip_list[k] = v
						end
					end
				end
			end
		else
			if self.steps_index == -1 then
				for k, v in pairs(self.equip_list) do
					local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
					if item_cfg and item_cfg.color then
						if self.quality_index >= item_cfg.color then
							self.select_equip_list[k] = v
						end
					end
				end
			else
				for k, v in pairs(self.equip_list) do
					local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
					if item_cfg and item_cfg.color and item_cfg.order then
						if self.quality_index >= item_cfg.color and self.steps_index >= item_cfg.order then
							self.select_equip_list[k] = v
						end
					end
				end
			end
		end

		for k, v in pairs(self.guild_warehouse_cell_list) do
			for i = 1, 6 do
				local index = v:GetGroupIndex(i)
				self:SetItemSelected(v.item_cell_list[i], nil ~= self.select_equip_list[index])
			end
		end
	end
end

----------------------------------------------------------------------------
-- 日志记录
-- GuildWarehouseLogCell

GuildWarehouseLogCell = GuildWarehouseLogCell or BaseClass(BaseCell)

function GuildWarehouseLogCell:__init()

end

function GuildWarehouseLogCell:__delete()

end

function GuildWarehouseLogCell:OnFlush()
	if not self.data or self.data == {} then
		return
	end
	self.node_list["Text_1"].text.text = os.date("%m-%d %H:%M", self.data.log_time)
	self.node_list["Text_2"].text.text = string.format(Language.Common.ShowGreenStr, self.data.log_owner_name)
	self.node_list["Text_3"].text.text = self.data.opt_type == GuildData.GUILD_STORE_OPTYPE.GUILD_STORE_OPTYPE_TAKEOUT and Language.Guild.DuiHuan or Language.Guild.JuanXian
	
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local str_dec = ""
	if item_cfg then
		local str = self.data.opt_type == GuildData.GUILD_STORE_OPTYPE.GUILD_STORE_OPTYPE_TAKEOUT and Language.Guild.XiaoHao or Language.Guild.HuoDe
		str_dec = string.format(str, item_cfg.guild_storage_score)
	end

	local xianpin_type_list_str = ""
	for k, v in pairs(self.data.xianpin_type_list) do
		xianpin_type_list_str = xianpin_type_list_str .. v .. "|"
	end
	
	local rich_str = string.format("{guild_item;%s;%s;}%s", self.data.item_id, xianpin_type_list_str, str_dec)
	RichTextUtil.ParseRichText(self.node_list["Text"].rich_text, rich_str)

end

----------------------------------------------------------------------------
-- 仓库格子
-- GuildWarehouseCell
GuildWarehouseGrop = GuildWarehouseGrop or BaseClass(BaseCell)
function GuildWarehouseGrop:__init()
	self.item_cell_list = {}
	for i = 1, 6 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end	
end

function GuildWarehouseGrop:__delete()
	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function GuildWarehouseGrop:GetGroupIndex(i)
	return self.item_cell_list[i]:GetIndex()
end

function GuildWarehouseGrop:SetGroupIndex(i, index)
	self.item_cell_list[i]:SetIndex(index)
end

function GuildWarehouseGrop:SetGroupData(i, data, state)
	self.item_cell_list[i]:SetData(data, true)
	self.item_cell_list[i]:ShowStrengthLable(false)
	self.warehouse_cell_state = state
end

function GuildWarehouseGrop:SetClickCallBack(i, call_back)
	if self.warehouse_cell_state == Warehouse_Cell_State.Normal then
		local item_id = GuildData.Instance:GetOtherConfig().storage_constant_item_id or 0
		local data = self.item_cell_list[i]:GetData()
		if data.item_id == item_id then
			self.item_cell_list[i]:ListenClick(function()
				GuildCtrl.Instance:OpenGuildDuiHuanView(item_id, data.is_bind)
			end)
		else
			local data_list = {} 
			data_list.item_id = data.item_id
			data_list.guild_warehouse_index = data.index
			for k, v in pairs(data.param.xianpin_type_list) do
				if v ~= 0 then
					data_list.index = -1
					data_list.param = {}
					data_list.param.xianpin_type_list = data.param.xianpin_type_list
					break
				end
			end
			self.item_cell_list[i]:ListenClick(function()
				TipsCtrl.Instance:OpenItem(data_list, TipsHandleDef.CANGKUEQUIP_EXCHANGE, nil, nil)
			end)
		end
	elseif self.warehouse_cell_state == Warehouse_Cell_State.Manger then
		self.item_cell_list[i]:ListenClick(call_back)
	end
end