-- 仙盟仓库，捐献界面
-- ConTributeEquipView
ConTributeEquipView = ConTributeEquipView or BaseClass(BaseView)

local Equip_Cell_COUNT = 301
local BAG_COLUMN = 7  -- 列

function ConTributeEquipView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/guildview_prefab","ConTributeEquipView"},
	}

	self.is_modal = true
	self.is_any_click_close = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end


function ConTributeEquipView:LoadCallBack()
	self.node_list["Bg"].rect.sizeDelta = Vector3(714, 540, 0)
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.Close, self))
	self.node_list["Txt"].text.text = Language.Guild.GuildNameTitle
	self.node_list["BtnUpArrows_1"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnBgQuality"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnDownArrows_1"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipByQuality, self))
	self.node_list["BtnUpArrows_2"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["BtnBgPinJie"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["BtnDownArrows_2"].button:AddClickListener(BindTool.Bind(self.OnClickSelectEquipBySteps, self))
	self.node_list["BtnConTribute"].button:AddClickListener(BindTool.Bind(self.OnClickConTribute, self))

	self.equip_grid_list = {}
	self.equip_list = GuildData.Instance:GetGuildContributeEquipDataList()		-- 背包格子数据
	self.select_equip_list = {}	-- 挑选的格子数据
	self.is_select_equip_by_quality = false
	self.quality_index = 4		-- 默认是4橙色装备
	self.is_select_equip_by_steps = false
	self.steps_index = -1

	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function ConTributeEquipView:ReleaseCallBack()
	self.is_select_equip_by_quality = false
	self.is_select_equip_by_steps = false

	for k, v in pairs(self.equip_grid_list) do
		v:DeleteMe()
	end
	self.equip_grid_list = {}

	self.equip_grid_list = {}
	self.equip_list = {}		-- 背包格子数据
	self.select_equip_list = {}	-- 挑选的格子数据
	self.is_select_equip_by_quality = nil
	self.quality_index = nil
	self.is_select_equip_by_steps = nil
	self.steps_index = nil
end

function ConTributeEquipView:OpenCallBack()
	self.equip_list = GuildData.Instance:GetGuildContributeEquipDataList()		-- 背包格子数据
	self.select_equip_list = {}	-- 挑选的格子数据
	self.is_select_equip_by_quality = false
	self.quality_index = 4 		-- 默认是4橙色装备
	self.is_select_equip_by_steps = false
	self.steps_index = -1
	if self.quality_index == -1 then
		self.node_list["TextSelet_1"].text.text = Language.Guild.SeletListTitle[1]
	else
		self.node_list["TextSelet_1"].text.text = Language.Guild.SelectListName[2][self.quality_index - 3]
	end
	self.node_list["TextSelet_2"].text.text = Language.Guild.SeletListTitle[2]
	self:FlushGridList(nil, nil)
	self.node_list["ListView"].scroller:ReloadData(0)
end

function ConTributeEquipView:GetNumberOfCells()
	return Equip_Cell_COUNT / BAG_COLUMN
end

function ConTributeEquipView:RefreshCell(cell, cell_index)
	local contain_cell = self.equip_grid_list[cell]
	if contain_cell == nil then
		contain_cell = GuildConTributeEquipGrop.New(cell.gameObject)
		self.equip_grid_list[cell] = contain_cell
	end

	for i = 1, BAG_COLUMN do
		local index = cell_index * BAG_COLUMN + i
		local data = self.equip_list[index]
		contain_cell:SetGroupIndex(i, index)
		contain_cell:SetGroupData(i, data)
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
function ConTributeEquipView:OnClickItem(index, item_cell)
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

	self:FlushSelectEquipScore()
end

-- 选中物品格子
function ConTributeEquipView:SetItemSelected(item_cell, is_select)
	if IsNil(item_cell.root_node.gameObject) then
		return
	end

	item_cell:ShowExtremeEffect(false)
	item_cell:SetToggle(false)
	item_cell:ShowHighLight(false)
	item_cell:SetIconGrayVisible(is_select)
	item_cell:ShowHasGet(is_select)
end

-- 按照品质筛选
function ConTributeEquipView:OnClickSelectEquipByQuality()
	self.is_select_equip_by_quality = not self.is_select_equip_by_quality
	self.node_list["BtnUpArrows_1"]:SetActive(not self.is_select_equip_by_quality)
	self.node_list["BtnDownArrows_1"]:SetActive(self.is_select_equip_by_quality)

	local function close_call_back()
		self.is_select_equip_by_quality = not self.is_select_equip_by_quality
		self.node_list["BtnUpArrows_1"]:SetActive(not self.is_select_equip_by_quality)
		self.node_list["BtnDownArrows_1"]:SetActive(self.is_select_equip_by_quality)
	end

	local function func_cancle()
		self.quality_index = -1
		self.node_list["TextSelet_1"].text.text = Language.Guild.SeletListTitle[1]
		self:FlushGridList(-1, nil)
	end

	local function func_select(quality_index)
		self.quality_index = quality_index + 3
		self.node_list["TextSelet_1"].text.text = Language.Guild.SelectListName[2][quality_index]
		self:FlushGridList(self.quality_index, nil)
	end

	GuildCtrl.Instance:SetDropDownFixationViewParam(Vector3(-80, -135, 0), Language.Guild.SelectListName[2], func_select, func_cancle, close_call_back)
end

-- 按照品阶筛选
function ConTributeEquipView:OnClickSelectEquipBySteps()
	self.is_select_equip_by_steps = not self.is_select_equip_by_steps
	self.node_list["BtnUpArrows_2"]:SetActive(not self.is_select_equip_by_steps)
	self.node_list["BtnDownArrows_2"]:SetActive(self.is_select_equip_by_steps)
	local role = GameVoManager.Instance:GetMainRoleVo()
	local max_step, select_list_name = GuildData.Instance:GetMaxStepAndListDataByRoleLv(role.level, Language.Guild.SelectListName[4])

	local function close_call_back()
		self.is_select_equip_by_steps = not self.is_select_equip_by_steps
		self.node_list["BtnUpArrows_2"]:SetActive(not self.is_select_equip_by_steps)
		self.node_list["BtnDownArrows_2"]:SetActive(self.is_select_equip_by_steps)
	end

	local function func_select(steps_index)
		self.steps_index = max_step - steps_index + 1
		self.node_list["TextSelet_2"].text.text = select_list_name[steps_index + 1]
		self:FlushGridList(nil, self.steps_index)
	end

	local function func_cancle()
		self.steps_index = -1
		self.node_list["TextSelet_2"].text.text = Language.Guild.SeletListTitle[2]
		self:FlushGridList(nil, -1)
	end

	GuildCtrl.Instance:SetDropDownScrollViewParam(Vector3(88, -73, 0), select_list_name, func_select, func_cancle, close_call_back)
end

-- 点击捐献按钮
function ConTributeEquipView:OnClickConTribute()
	local yes_func = function()
		local num = 0
		local item_list = {}
		for k,v in pairs(self.select_equip_list) do
			num = num + 1
			table.insert(item_list, {item_index = v.index, param_1 = v.num})
		end
		GuildCtrl.Instance:SendStorgeOneKeyOperate(GUILD_STORGE_ONE_KEY_OPERATE.GUILD_STORGE_OPERATE_PUTON_ITEM_ONE_KEY, num, item_list)
		self:Flush()
	end

	local count = 0
	local score = 0
	for k,v in pairs(self.select_equip_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			score = item_cfg.guild_storage_score * v.num + score
		end
		count = count + 1
	end

	if count > 0 then
		local describe = string.format(Language.Guild.Donate, count, score)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSelect)
	end
end

function ConTributeEquipView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "contribute_success" then
			if self.node_list and self.node_list["ListView"] and self.node_list["ListView"].scroller and self.node_list["ListView"].scroller.isActiveAndEnabled then
				self.select_equip_list = {}
				self.equip_list = GuildData.Instance:GetGuildContributeEquipDataList()
				self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end
	self:FlushSelectEquipScore()
end

-- 刷新物品格子列表
function ConTributeEquipView:FlushGridList(quality_index, steps_index)
	self.select_equip_list = {}
	local quality_index = quality_index or self.quality_index
	local steps_index = steps_index or self.steps_index
	if quality_index == -1 then
		if steps_index == -1 then
			self.select_equip_list = {}
		else
			for k, v in pairs(self.equip_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg and item_cfg.order then
					if steps_index >= item_cfg.order then
						self.select_equip_list[k] = v
					end
				end
			end
		end
	else
		if steps_index == -1 then
			for k, v in pairs(self.equip_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg and item_cfg.color then
					if quality_index >= item_cfg.color then
						self.select_equip_list[k] = v
					end
				end
			end
		else
			for k, v in pairs(self.equip_list) do
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg and item_cfg.color and item_cfg.order then
					if quality_index >= item_cfg.color and steps_index >= item_cfg.order then
						self.select_equip_list[k] = v
					end
				end
			end
		end
	end

	for k, v in pairs(self.equip_grid_list) do
		for i = 1, BAG_COLUMN do
			local index = v:GetGroupIndex(i)
			self:SetItemSelected(v.item_cell_list[i], nil ~= self.select_equip_list[index])
		end
	end

	self:FlushSelectEquipScore()
end

-- 刷新获取的仓库积分
function ConTributeEquipView:FlushSelectEquipScore()
	local score = 0
	if self.equip_list and next(self.select_equip_list) then
		for k, v in pairs(self.select_equip_list) do
			if v.item_id then
				local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
				if item_cfg and item_cfg.guild_storage_score then
					score = score + item_cfg.guild_storage_score
				end
			end
		end
	end
	self.node_list["Textjifen"].text.text = score
end

-------------------------------------------------------------------------------
-- GuildConTributeEquipGrop

GuildConTributeEquipGrop = GuildConTributeEquipGrop or BaseClass(BaseCell)
function GuildConTributeEquipGrop:__init()
	self.item_cell_list = {}
	for i = 1, BAG_COLUMN do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetFromView(TipsHandleDef.CANGKUEQUIP_EXCHANGE)
		self.item_cell_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end	
end

function GuildConTributeEquipGrop:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function GuildConTributeEquipGrop:GetGroupIndex(i)
	return self.item_cell_list[i]:GetIndex()
end

function GuildConTributeEquipGrop:SetGroupIndex(i, index)
	self.item_cell_list[i]:SetIndex(index)
end

function GuildConTributeEquipGrop:SetGroupData(i, data)
	self.item_cell_list[i]:SetData(data)
	self.item_cell_list[i]:ShowStrengthLable(false)
end

function GuildConTributeEquipGrop:SetClickCallBack(i, call_back)
	self.item_cell_list[i]:ListenClick(call_back)
end

