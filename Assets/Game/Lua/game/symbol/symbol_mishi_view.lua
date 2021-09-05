-- 唤灵 MishiContent
local BAG_MAX_GRID_NUM = 175			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 25				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 5					-- 列数
local TWEEN_TIME = 5					-- 动画时间

SymbolMishiView = SymbolMishiView or BaseClass(BaseRender)
local item_pos = {
	{x = 102, y = -148},
	{x = -72.1, y = 111.5},
	{x = 9.8, y = -144.9},
	{x = -82.4, y = 32.3},
	{x = -78.4, y = -134},
	{x = 48.6, y = 120.7},
	{x = -146.3, y = -77.2},
	{x = 119.7, y = 64.7},
	{x = -158.2, y = 12},
	{x = 162.8, y = -11},
	{x = -74.2, y = -51.1},
	{x = 176.5, y = -98.8},
	{x = 0.8, y = -60.6},
	{x = 89.3, y = -53.4},
	{x = -11.7, y = 47.6},
	{x = 60.9, y = 15.2},
}

local fall_item_y = -150
local max_count = 16
function SymbolMishiView:__init()
	self.enough_consume1 = false
	self.enough_consume10 = false

	self.is_free = false
	self.consume_score = false
	self.is_use_gold = false
	self.is_moving = false

	self.node_table = self.node_list["MishCell"]:GetComponent(typeof(UINameTable))
	self.bag_cell = {}

	local list_delegate = self.node_list["ListView"].page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	-- self.node_list["ListView"].list_view:JumpToIndex(0)
	-- self.node_list["ListView"].list_view:Reload()

	self.toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		local transform = self.node_list["PageButtons"].transform:FindHard("Toggle" .. i)
		if transform ~= nil then
			node = U3DObject(transform.gameObject, transform)
			if node then
				self.toggle_list[i] = node
			end
		end
	end

	self.gift_list = {}
	self.tweent_list = {}
	local res_list = SymbolData.Instance:GetItemResList()
	for i = 1, max_count do
		ResPoolMgr:GetDynamicObjAsync("uis/views/symbol_prefab", "MishiCell", function(obj)
				if nil == obj then return end
				obj.transform:SetParent(self.node_list["ItemPanel"].transform, false)

				local  node_table = obj:GetComponent(typeof(UINameTable))
				local  icon = node_table:Find("ImgItem")
				icon = U3DObject(icon, icon.transform, self)
				icon.image:LoadSprite(ResPath.GetItemIcon(res_list[i] or res_list[math.random(1, #res_list)]))

				local x = item_pos[i] and item_pos[i].x or item_pos[1].x
				local y = item_pos[i] and item_pos[i].y or item_pos[1].y
				obj.transform:SetLocalPosition(x, y, 0)
				self.gift_list[i] = obj.transform
			end)
	end

	self.one_chou_item_id = SymbolData.Instance:GetSyebolOneChouJiangItemId()
	self.ten_chou_item_id = SymbolData.Instance:GetSyebolTenChouJiangItemId()

	self.node_list["BtnOne"].button:AddClickListener(BindTool.Bind(self.OnClickOne, self))
	self.node_list["BtnTen"].button:AddClickListener(BindTool.Bind(self.OnClickTen, self))
	--self.node_list["BtnAdd"].button:AddClickListener(BindTool.Bind(self.OnClickAddScore, self))
	self.node_list["ImgCheckBox"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickMask, self))
	self.node_list["ImgCheckBox2"].toggle:AddValueChangedListener(BindTool.Bind(self.OnClickConsumeScore, self))
end

function SymbolMishiView:__delete()
	for _,v in ipairs(self.gift_list) do
		ResPoolMgr:Release(v.gameObject)
	end
	self.gift_list = {}

	if self.bag_cell then
		for k,v in pairs(self.bag_cell) do
			v:DeleteMe()
		end
		self.bag_cell = {}
	end

	self.is_free = nil
	self.consume_score = nil
	self.is_moving = nil
	self.one_chou_item_id = nil
	self.ten_chou_item_id = nil
end

-- ListView逻辑
function SymbolMishiView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function SymbolMishiView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	local data = self.bag_data_list[grid_index + 1] or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)

	cell:SetData(cell_data, true)
	cell:SetHighLight(false)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
	cell:SetInteractable(true)
end


--点击格子事件
function SymbolMishiView:HandleBagOnClick(data, cell)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
	end
end

function SymbolMishiView:OpenCallBack()
	local right_pos = self.node_list["RightPanel"].transform.anchoredPosition
	local left_pos = self.node_list["LeftPanel"].transform.anchoredPosition
	UITween.MoveShowPanel(self.node_list["RightPanel"], Vector3(right_pos.x + 800, right_pos.y, right_pos.z))
	UITween.MoveShowPanel(self.node_list["LeftPanel"], Vector3(left_pos.x - 600, left_pos.y, left_pos.z))

	self.is_moving = false
	self:SetButtonStated(not self.is_moving)

	for k,v in pairs(self.gift_list) do
		local x = item_pos[k] and item_pos[k].x or item_pos[1].x
		local y = item_pos[k] and item_pos[k].y or item_pos[1].y
		v:SetLocalPosition(x, y, 0)
	end
	self:Flush()
end

function SymbolMishiView:CloseCallBack()
	if self.tweent_list then
		for k,v in pairs(self.tweent_list) do
			v:Kill()
		end
		self.tweent_list = {}
	end
end

function SymbolMishiView:OnClickOne()
	if not self.enough_consume1 then
		if self.consume_score then
			local cunsume_name = Language.Symbol.ConsumeType[1]
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.NoEnoughItem, cunsume_name))
		else
			-- TipsCtrl.Instance:ShowLackDiamondView()
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotEnoughIten)
		end
		return
	end

	local item_empty_num = ItemData.Instance:GetEmptyNum()
	if item_empty_num < 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
		return
	end
	if not self.is_use_gold then
		self:StartTween(false, 1)
		return
	end
	local func = function()
		self:StartTween(true, 1)
	end

	if self.is_free then
		func()
	else
		local other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
		local tips = string.format(Language.Symbol.MishiChoujiangOne, other_cfg.one_chou_need_gold)
		-- TipsCtrl.Instance:ShowCommonTip(func, nil, tips, nil, nil, true, nil, "symbol_mishi_1", 
		-- 		nil, nil, nil, true, nil, nil, Language.Common.Cancel)
		TipsCtrl.Instance:ShowCommonTip(func, nil, tips, nil, no_func, false, nil, "", 
				nil, nil, nil, true, nil, nil, Language.Common.Cancel)
	end
end

function SymbolMishiView:OnClickTen()
	if not self.enough_consume10 then
		if self.consume_score then
			local cunsume_name = Language.Symbol.ConsumeType[1]
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.NoEnoughItem, cunsume_name))
		else
			-- TipsCtrl.Instance:ShowLackDiamondView()
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotEnoughIten)
		end
		return
	end

	local item_empty_num = ItemData.Instance:GetEmptyNum()
	if item_empty_num < 10 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
		return
	end
	if not self.is_use_gold then
		self:StartTween(false, 10)
		return
	end
	local func = function()
		self:StartTween(true, 10)
	end

	local other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	local tips = string.format(Language.Symbol.MishiChoujiangTen, other_cfg.ten_chou_need_gold)
	-- TipsCtrl.Instance:ShowCommonTip(func, nil, tips, nil, nil, true, nil, "symbol_mishi_10", 
	-- 		nil, nil, nil, true, nil, nil, Language.Common.Cancel)

	TipsCtrl.Instance:ShowCommonTip(func, nil, tips, nil, no_func, false, nil, "", 
			nil, nil, nil, true, nil, nil, Language.Common.Cancel)
end

function SymbolMishiView:StartTween(is_use_gold, count, index)
	if is_use_gold then
		local gold = GameVoManager.Instance:GetMainRoleVo().gold or 0
		local other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
		if other_cfg then
			local need_gold = count == 1 and other_cfg.one_chou_need_gold or other_cfg.ten_chou_need_gold
			if gold < need_gold then
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			end
		end
	end
	if self.is_moving and nil == index then return end
	index = index or 1
	if index > 1 or self.node_list["ImgCheckBox"].toggle.isOn then
		local use_score = self.consume_score and 1 or 0
		-- local prefs_key = count == 1 and "symbol_mishi_1" or "symbol_mishi_10"
		-- local is_use_gold = SettingData.Instance:GetCommonTipkey(prefs_key) and 1 or 0
		local has_use_gold = is_use_gold and 1 or 0
		SymbolCtrl.Instance:SendChoujiangElementHeartReq(count, use_score, has_use_gold)
		self.is_moving = false
		self:SetButtonStated(not self.is_moving)
		self.tweent_list = {}
		return
	end

	self.is_moving = true
	self:SetButtonStated(not self.is_moving)

	local random = math.random(max_count, max_count + 5)
	for k,v in ipairs(self.gift_list) do
		local path = {}

		for i = 1, random do
			if self.gift_list[k + i] then
				table.insert(path, self.gift_list[k + i].position)
			elseif (k + i - #self.gift_list) % max_count ~= 0 then
				table.insert(path, self.gift_list[(k + i - #self.gift_list) % max_count].position)
			else
				table.insert(path, self.gift_list[max_count].position)
			end
		end

		local rotate_self = v:DOLocalRotate(
			Vector3(0, 0, 360 * random), TWEEN_TIME, DG.Tweening.RotateMode.FastBeyond360)
		local move_center = v:DOPath(
			path,
			TWEEN_TIME,
			DG.Tweening.PathType.Linear,			--Linear直来直往的, CatmullRom平滑的（一般是在转弯的时候）
			DG.Tweening.PathMode.TopDown2D,
			1)
		local sequence = DG.Tweening.DOTween.Sequence()
		sequence:Append(move_center)
		sequence:Insert(0, rotate_self)
		sequence:SetEase(DG.Tweening.Ease.InOutQuad)

		if k == #self.gift_list then
			sequence:AppendCallback(BindTool.Bind(self.StartTween, self, is_use_gold, count, index + 1))
		end
		self.tweent_list[k] = sequence
	end
end

function SymbolMishiView:DoFallTween(item_id)
	if self.node_list["MishCell"].gameObject.activeSelf then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		local icon = self.node_table:Find("ImgItem")
		icon = U3DObject(icon.gameObject, icon.transform, self)
		icon.image:LoadSprite(ResPath.GetItemIcon(item_cfg.icon_id))
	end
	self.node_list["MishCell"]:SetActive(true)
	self.node_list["MishCell"].transform:SetLocalScale(0.1, 0.1, 0.1)
	local pos = self.node_list["MishCell"].transform.localPosition
	self.node_list["MishCell"].transform:SetLocalPosition(pos.x, fall_item_y, pos.z)
	local rotate_self = self.node_list["MishCell"].transform:DOLocalRotate(
		Vector3(0, 0, 360), 1, DG.Tweening.RotateMode.FastBeyond360)
	local move_self = self.node_list["MishCell"].transform:DOLocalMoveY(fall_item_y - 30, 1)
	local scale_self = self.node_list["MishCell"].transform:DOScale(Vector3(1, 1, 1), 1)

	local sequence = DG.Tweening.DOTween.Sequence()
	sequence:Append(move_self)
	sequence:Insert(0, rotate_self)
	sequence:Insert(0, scale_self)
	sequence:SetEase(DG.Tweening.Ease.InOutQuad)
	sequence:AppendCallback(function ()
		self.node_list["MishCell"]:SetActive(false)
	end)
end

function SymbolMishiView:OnClickMask()
	self.node_list["ImgYes"]:SetActive(self.node_list["ImgCheckBox"].toggle.isOn)
end

function SymbolMishiView:OnClickConsumeScore()
	-- self.consume_score = not self.consume_score
	-- self:SetActiveOrShow()
	-- self:FlushBtnText()
	self.is_use_gold = not self.is_use_gold
end

function SymbolMishiView:OnClickAddScore()
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.KF_FARMHUNTING)
end

function SymbolMishiView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "chou_reward" then
			self:DoFallTween(v.item_id)
		end
	end

	if nil ~= self.node_list["ListView"].list_view and self.node_list["ListView"].list_view.isActiveAndEnabled then
		self.bag_data_list = SymbolData.Instance:GetAllElementItemList()
		self.node_list["ListView"].list_view:JumpToIndex(0)
		self.node_list["ListView"].list_view:Reload()
	end
	self:FlushBtnText()
end

function SymbolMishiView:FlushBtnText()
	local score = SymbolData.Instance:GetPastureScore()
	local free_times = SymbolData.Instance:GetMishiFreeTimes()
	--self.node_list["TxtJiFen"].text.text = score

	local other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	local str1 = ""
	local str2 = ""
	local color = ""
	if self.consume_score then
		color = score < other_cfg.one_chou_need_score and "#ff0000" or "#ffff00"
		str1 = string.format(Language.Symbol.OneConsume, color, other_cfg.one_chou_need_score, Language.Symbol.ConsumeType[1])
		color = score < other_cfg.ten_chou_need_score and "#ff0000" or "#ffff00"
		str2 = string.format(Language.Symbol.OneConsume, color, other_cfg.ten_chou_need_score, Language.Symbol.ConsumeType[1])
		self.enough_consume1 = score >= other_cfg.one_chou_need_score
		self.enough_consume10 = score >= other_cfg.one_chou_need_score
	else
		-- local gold = PlayerData.Instance:GetRoleVo().gold
		-- color = gold < other_cfg.one_chou_need_gold and "#ff0000" or "#fde45c"
		-- str1 = "    " .. string.format(Language.Symbol.OneConsume, color, other_cfg.one_chou_need_gold, Language.Symbol.ConsumeType[2])
		-- color = gold < other_cfg.ten_chou_need_gold and "#ff0000" or "#fde45c"
		-- str2 = "    " .. string.format(Language.Symbol.OneConsume, color, other_cfg.ten_chou_need_gold, Language.Symbol.ConsumeType[2])
		local num1 = ItemData.Instance:GetItemNumInBagById(self.one_chou_item_id) or 0
		str1 = num1 > 0 and ToColorStr(num1, TEXT_COLOR.GREEN_4) or ToColorStr(num1, TEXT_COLOR.RED)
		local num2 = ItemData.Instance:GetItemNumInBagById(self.ten_chou_item_id) or 0
		str2 = num2 > 0 and ToColorStr(num2, TEXT_COLOR.GREEN_4) or ToColorStr(num2, TEXT_COLOR.RED)
		-- self.enough_consume1 = gold >= other_cfg.one_chou_need_gold
		-- self.enough_consume10 = gold >= other_cfg.ten_chou_need_gold
		self.enough_consume1 = num1 > 0
		self.enough_consume10 = num2 > 0
	end

	self.is_free = other_cfg.one_chou_free_chou_times - free_times > 0
	self:SetActiveOrShow()
	self.node_list["Txt1"]:SetActive(other_cfg.one_chou_free_chou_times - free_times <= 0)

	if other_cfg.one_chou_free_chou_times - free_times > 0 then
		self.enough_consume1 = true
		str1 = string.format(Language.Symbol.FreeTimes, other_cfg.one_chou_free_chou_times - free_times)
	end
	self.node_list["Txt1"]:SetActive(not self.is_free and not self.consume_score)
	self.node_list["Txt2"]:SetActive(not self.consume_score)
	self.node_list["TxtJifenOne"]:SetActive(not self.is_free and self.consume_score)
	self.node_list["TxtJifenTen"]:SetActive(self.consume_score)
	self.node_list["Txt1"].text.text = str1
	self.node_list["Txt2"].text.text = str2
	self.node_list["TxtJifenOne"].text.text = str1
	self.node_list["TxtJifenTen"].text.text = str2
	self.node_list["TxtGold"].text.text = str1
	self.node_list["RedPoint"]:SetActive(self.is_free or ItemData.Instance:GetItemNumInBagById(self.one_chou_item_id) > 0)
	self.node_list["RedPointTen"]:SetActive(ItemData.Instance:GetItemNumInBagById(self.ten_chou_item_id) > 0)
end

--控制物体的显示隐藏
function SymbolMishiView:SetActiveOrShow()
	-- self.node_list["ImgCheck"]:SetActive(self.consume_score)
	self.node_list["ImgGold"]:SetActive(not self.is_free and not self.consume_score)
	self.node_list["ImgGold2"]:SetActive(not self.consume_score)

	self.node_list["ImgGold"]:SetActive(not self.is_free and not self.consume_score)
	self.node_list["TxtGold"]:SetActive(self.is_free)
end

--设置按钮是否可点
function SymbolMishiView:SetButtonStated(is_enable)
	UI:SetButtonEnabled(self.node_list["BtnOne"], is_enable)
	UI:SetButtonEnabled(self.node_list["BtnTen"], is_enable)
end
