RuneAnalyzeView = RuneAnalyzeView or BaseClass(BaseRender)

local CheckType = {
	[1] = "white",
	[2] = "blue",
	[3] = "purple",
	[4] = "orange",
}

local CheckList = {
	["white"] = true,
	["blue"] = true,
	["purple"] = false,
	["orange"] = false,
}

local CHECK_NUM = 4
local COLUMN = 4

local EFFECT_CD = 1
local MOVE_TIME = 0.5

function RuneAnalyzeView:UIsMove()
	UITween.MoveShowPanel(self.node_list["Bottom_Panel"] , Vector3(-60 , -40 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Right_Panel"] , Vector3(205 , -90 , 0 ) , MOVE_TIME )
	UITween.MoveShowPanel(self.node_list["Left_Panel"] , Vector3(-200 , 16 , 0 ) , MOVE_TIME )
	UITween.AlpahShowPanel(self.node_list["Right_Panel"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function RuneAnalyzeView:__init()
	self.list_data = {}
	self.cell_list = {}
	self.goal_data = {}

	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
	self.list_data = RuneData.Instance:GetAnalyList()
	for i = 1, CHECK_NUM do
		self["check" .. i] = self.node_list["Check" .. i]
		self["check" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckChange,self, i))
	end
	self.node_list["BtnAutoAnalyze"].button:AddClickListener(BindTool.Bind(self.AutoAnalyze, self))
end

function RuneAnalyzeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function RuneAnalyzeView:InitView()
	self.effect_cd = 0
	self.data_list = {}
	self.select_data = {}			--选择列表
	--初始化筛选
	for i = 1, CHECK_NUM do
		if i < 3 then
			self["check" .. i].toggle.isOn = true
			self:OnCheckChange(i, true)
		else
			self["check" .. i].toggle.isOn = false
		end
	end
	self:AddJingHua()
	self:FlushView()
end

function RuneAnalyzeView:FlushView()
	-- self.select_data = {}
	self.list_data = RuneData.Instance:GetAnalyList()
	-- self:AddJingHua()
	self.node_list["ListView"].scroller:ReloadData(0)
	self:FlushJingHua()
end

function RuneAnalyzeView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function RuneAnalyzeView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneAnalyzeGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)

		if data and self.select_data[data.index] then
			group_cell:SetToggleHighLight(i, true)
		else
			group_cell:SetToggleHighLight(i, false)
		end

		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneAnalyzeView:OpenTipsTitleLimit(is_model, is_other_item)
	local fun = function(click_type)
		RuneCtrl.Instance:SendBigSmallGoalOper(ROLE_BIG_SMALL_GOAL_OPERA_TYPE.ROLE_BIG_SMALL_GOAL_OPERA_FETCH, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE, click_type)
	end

	self.goal_data.from_panel = ""
	self.goal_data.call_back = fun
	TipsCtrl.Instance:ShowGoalTimeLimitTitleView(self.goal_data, is_model, ROLE_BIG_SMALL_GOAL_SYSTEM_TYPE.ROLE_BIG_SMALL_GOAL_SYSTEM_RUNE, is_other_item)
end

function RuneAnalyzeView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	if self.select_data[data.index] then
		self.select_data[data.index] = nil
	else
		self.select_data[data.index] = data
	end
	self:FlushJingHua()
end

function RuneAnalyzeView:FlushSelect(change_quality, state)
	local list_data = RuneData.Instance:GetAnalyList()
	if state then
		for k, v in ipairs(list_data) do
			local index = v.index
			if change_quality == v.quality and not self.select_data[index] and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.select_data[index] = v 
			end
		end
	else
		--清除选中列表
		for k, v in pairs(self.select_data) do
			if change_quality == v.quality and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.select_data[k] = nil
			end
		end
	end
	local stay_list = self:IsStay()
	for k1, v1 in pairs(stay_list) do
		if nil ~= v1 and self.select_data[v1.index] then
			self.select_data[v1.index] = nil
		end
	end

	-- local attr_list = self:IsStayDobuleAttr()
	-- for k1, v1 in pairs(attr_list) do
	-- 	if nil ~= v1 and self.select_data[v1.index] then
	-- 		self.select_data[v1.index] = nil
	-- 	end
	-- end

	local inlay_list = self:IsStayInlayType()
	for k1, v1 in pairs(inlay_list) do
		if nil ~= v1 and self.select_data[v1.index] then
			self.select_data[v1.index] = nil
		end
	end
	self.node_list["ListView"].scroller:RefreshActiveCellViews()
	self:FlushJingHua()
end

function RuneAnalyzeView:IsStay()
	local list_data = RuneData.Instance:GetAnalyList()
	local stay_list = {}
	for k, v in pairs(list_data) do
		local is_add = false
		if not v.is_repeat and v.type ~= GameEnum.RUNE_JINGHUA_TYPE then
			for k1, v1 in pairs (stay_list) do
				if v.type == v1.type then
					if v.quality > v1.quality then
						stay_list[v.type] = v
					elseif v.quality == v1.quality then
						if v.level > v1.level then
							stay_list[v.type] = v
						end
					end
				is_add =true
				end
			end
			if not is_add then
				stay_list[v.type] = v
			end
		end
	end
	return stay_list
end

function RuneAnalyzeView:IsStayDobuleAttr()
	local list_data = RuneData.Instance:GetAnalyList()
	local attr_list = {}
	for k, v in pairs(list_data) do
		if v.attr_type_0 > 0 and v.attr_type_1 > 0 then
			attr_list[v.index] = v
		end
	end
	return attr_list
end

function RuneAnalyzeView:IsStayInlayType()
	local slot_list = RuneData.Instance:GetSlotList()
	local stay_list = {}
	for k, v in pairs(slot_list) do
		local info = self:GetDianJiType(v)
		if info ~= v then
			stay_list[info.index] = info
		end
	end
	return stay_list
end

function RuneAnalyzeView:GetDianJiType(info)
	local list_data = RuneData.Instance:GetAnalyList()
	local stay_info = info
	for k, v in pairs (list_data) do
		if v.type == stay_info.type then
			if v.quality > stay_info.quality then
				stay_info = v
			elseif v.quality == stay_info.quality then
				if v.level > stay_info.level then
					stay_info = v
				end
			end
		end
	end
	return stay_info
end

function RuneAnalyzeView:AddJingHua()
--自动添加符文精华
	local list_data = RuneData.Instance:GetAnalyList()
	for k, v in ipairs(list_data) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE then
			if not self.select_data[v.index] then
				self.select_data[v.index] = v
			end
		end
	end
end

function RuneAnalyzeView:FlushJingHua()
	local jinghua = RuneData.Instance:GetJingHua()
	self.node_list["NowJingHuaTxt"].text.text = jinghua

	local add_jinghua = 0
	for k, v in pairs(self.select_data) do
		local dispose_fetch_jinghua = v.dispose_fetch_jinghua and v.dispose_fetch_jinghua or 0
		add_jinghua = add_jinghua + dispose_fetch_jinghua
	end
	local add_str = ""
	if add_jinghua > 0 then
		add_str = "+" .. add_jinghua
		self.node_list["AddJingHuaTxt"]:SetActive(true)
	else
		self.node_list["AddJingHuaTxt"]:SetActive(false)
	end
	self.node_list["AddJingHuaTxt"].text.text = add_str
end

function RuneAnalyzeView:OnCheckChange(i, ison)
	local str_type = CheckType[i]
	if nil ~= CheckList[str_type] then
		CheckList[str_type] = ison
		self:FlushSelect(i-1, ison)
	end
end

function RuneAnalyzeView:AutoAnalyze()
	if not next(self.select_data) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotSelectRune)
		return
	end

	local tbl = {}
	for k, v in pairs(self.select_data) do
		table.insert(tbl, k)
	end
	self.select_data = {}
	SortTools.SortAsc(tbl)
	local max_count = #tbl
	RuneCtrl.Instance:SendOneKeyAnalyze(max_count, tbl)
end

--播放分解成功特效
function RuneAnalyzeView:PlayAni()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		local bundle_name, asset_name = ResPath.GetUiXEffect("UI_guihuo_lizi")
		EffectManager.Instance:PlayAtTransformCenter(
			bundle_name,
			asset_name,
			self.node_list["EffectObj"].transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

--------------------RuneAnalyzeGroupCell---------------------------
RuneAnalyzeGroupCell = RuneAnalyzeGroupCell or BaseClass(BaseRender)
function RuneAnalyzeGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RuneAnalyzeItemCell.New(self.node_list["Item" .. i])
		table.insert(self.item_list, item_cell)
	end
end

function RuneAnalyzeGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneAnalyzeGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneAnalyzeGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneAnalyzeGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneAnalyzeGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function RuneAnalyzeGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

--------------------RuneAnalyzeItemCell----------------------
RuneAnalyzeItemCell = RuneAnalyzeItemCell or BaseClass(BaseCell)
function RuneAnalyzeItemCell:__init()
	self.node_list["Item1"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function RuneAnalyzeItemCell:__delete()

end

function RuneAnalyzeItemCell:SetToggleHighLight(state)
	self.root_node.toggle.isOn = state
end

function RuneAnalyzeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id and self.data.item_id > 0 then
		self.node_list["ImageRes"].image:LoadSprite(ResPath.GetItemIcon(self.data.item_id))
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	local level_str = ""
	if self.data.panel == 0 then
		level_str = ToColorStr(level_name, level_color)
	else
		level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	end
	self.node_list["LevelText"].text.text = level_str

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrText1"].text.text = str
		self.node_list["AttrText2"].text.text = ""
		return
	end

	attr_type_name = Language.Rune.AttrName[self.data.attr_type_0] or ""
	attr_value = self.data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.node_list["AttrText1"].text.text = attr_des

	if self.data.attr_type_1 and self.data.attr_type_1 > 0 then
		attr_type_name = Language.Rune.AttrName[self.data.attr_type_1] or ""
		attr_value = self.data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
			attr_value = (self.data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.node_list["AttrText2"].text.text = attr_des
	else
		self.node_list["AttrText2"].text.text = ""
	end
end
