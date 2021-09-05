FindView = FindView or BaseClass(BaseRender)

local CurrencyName = {
		[1] = "bind_coin",
		[2] = "xianhun",
		[3] = "gongxian",
		[4] = "exp",
		[5] = "yuanli",
		[6] = "honor",
		[7] = "nvwashi",
		[8] = "guild_gongxian",
		[9] = "cross_honor",
		[10] = "mo_jing",
	}

function FindView:__init()
	self.cell_list = {}
	self.scroller_data = {}
	self.item_cell_list = {}
	self.free_item_cell_list = {}
	self.selet_cell_index = 1
	self.cost_count = 0

	self:InitScroller()

	self.node_list["BtnAllFreeFindClick"].button:AddClickListener(BindTool.Bind(self.AllFindClick, self, 0))
	self.node_list["BtnAllUseGoldFindClick"].button:AddClickListener(BindTool.Bind(self.AllFindClick, self, 1))

	self.select_big_type = -1
	self.select_type = -1
	
	self:Flush()
end

function FindView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cost_count = 0
	self.item_cell_list = nil
	self.free_item_cell_list = nil
end

function FindView:Flush()
	self.node_list["TxtStr"].text.text = Language.Welfare.FindStr

	local have_reward = nil ~= self.scroller_data and nil ~= next(self.scroller_data) and #self.scroller_data > 0
	self.node_list["ImgHaveReward"]:SetActive(not have_reward)
	self.node_list["TxtHaveReward1"]:SetActive(not have_reward)
	UI:SetButtonEnabled(self.node_list["BtnAllFreeFindClick"], have_reward)
	UI:SetButtonEnabled(self.node_list["BtnAllUseGoldFindClick"], have_reward)

	if self.scroller_data == nil or next(self.scroller_data) == nil then
		self.node_list["TxtAllCost"].text.text = 0
		return
	end

	local cost_count = 0
	self.cost_count = 0
	for k,v in ipairs(self.scroller_data) do
		if v and v.gold_need then
			self.cost_count = self.cost_count + v.gold_need
		end
	end
	self.node_list["TxtAllCost"].text.text = self.cost_count
end
--刷新滚动条
function FindView:FlushScroller()
	self.selet_cell_index = 1
	self.scroller_data = WelfareData.Instance:GetFindData()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
	UI:SetButtonEnabled(self.node_list["BtnAllFreeFindClick"], false)
	for k,v in pairs(self.scroller_data) do
		if v.vo and v.vo.is_open == 2 then
			UI:SetButtonEnabled(self.node_list["BtnAllFreeFindClick"], true)
			return
		end
	end
end
--初始化滚动条
function FindView:InitScroller()
	self.scroller_data = WelfareData.Instance:GetFindData()
	self.cell_list = {}
	self.scroller = self.node_list["Scroller"]

	self.list_view_delegate = ListViewDelegate()

	local async_loader = AllocAsyncLoader(self, "scroller_loader")
	async_loader:Load("uis/views/welfare_prefab", "FindItem", function (prefab)
		if IsNil(prefab) then
			return
		end

		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end
--滚动条数量
function FindView:GetNumberOfCells()
	if self.scroller_data == nil or next(self.scroller_data) == nil then
		return 0
	end
	return #self.scroller_data
end
--滚动条大小
function FindView:GetCellSize()
	return 154
end
--滚动条刷新
function FindView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1

	local lua_cell = self.cell_list[cell_view]
	if nil == lua_cell then
		self.cell_list[cell_view] = FindScrollerCell.New(cell_view.gameObject)
		lua_cell = self.cell_list[cell_view]
		lua_cell.mother_view = self
	end
	local cell_data = self.scroller_data[data_index]
	if cell_data == nil and nil == next(cell_data) then
		return
	end
	cell_data.data_index = data_index
	lua_cell:SetData(cell_data)

	return cell_view
end
--单个找回
-- function FindView:SingleFindClick(find_type)
-- 	if self.select_type < 0 then
-- 		TipsCtrl.Instance:ShowSystemMsg("没有选择任何奖励")
-- 		return
-- 	end
-- 	if self.select_big_type == 0 then
-- 		WelfareCtrl.Instance:SendGetFindReward(self.select_type, find_type)
-- 	else
-- 		if find_type == 0 then
-- 			find_type = 1
-- 		else
-- 			find_type = 0
-- 		end
-- 		WelfareCtrl.Instance:SendGetActivityFindReward(self.select_type, find_type)
-- 	end
-- 	self.select_type = -1
-- end

function FindView:AllFind(find_type)
	if next(self.scroller_data) == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Welfare.NoFind)
	end
	local acitvity_find_type = 0
	if find_type == 0 then
		acitvity_find_type = 1
	end

	for k,v in pairs(self.scroller_data) do
		if v and v.total_type then
			if v.total_type == 0 then
				WelfareCtrl.Instance:SendGetFindReward(v.find_type, find_type)
			else
				if v.vo and v.vo.find_type then
					WelfareCtrl.Instance:SendGetActivityFindReward(v.vo.find_type, acitvity_find_type)
				end
			end
		end
	end
	self.select_type = -1
end

function FindView:AllFindClick(find_type)
	-- local function free_callback()
	-- 	self:AllFind(0)
	-- end

	-- local function cost_callback()
	-- 	self:AllFind(1)
	-- end

	-- self:DataContrl()
	-- WelfareCtrl.Instance:ShowFindTips(self.cost_count, self.free_item_cell_list, self.item_cell_list, free_callback, cost_callback)
	if find_type == 1 then 			-- 用金钱的
		local gold = GameVoManager.Instance:GetMainRoleVo().gold or 0
		if gold < self.cost_count then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	end
	local ok_callback = function()
		self:AllFind(find_type)
	end
	local describe = find_type == 0 and Language.Welfare.WelfareFindDes[find_type] or string.format(Language.Welfare.WelfareFindDes[find_type], self.cost_count)
	TipsCtrl.Instance:ShowCommonAutoView("", describe, ok_callback)
end

function FindView:DataContrl()
	local percent = 0
	local data = WelfareData.Instance:GetFindData()
	self.item_cell_list = {}
	self.free_item_cell_list = {}
	if nil == data then return end
	for i,j in pairs(data) do
		local base_vo = j.vo or {}
		if j.total_type == 0 then
			--日常找回
			local daily_find_list = WelfareData.Instance:GetWelfareCfg().daily_find_list
			for k,v in pairs(daily_find_list) do
				if v.type == j.find_type then
					j.cfg = v
					percent = v.free_percent
					break
				end
			end
		else
			local activity_find = WelfareData.Instance:GetWelfareCfg().activity_find
			for k,v in pairs(activity_find) do
				if base_vo.name == v.name then
					percent = v.free_find_percent
				end
			end
		end 

		--虚拟币奖励
		for k,v in pairs(CurrencyName) do
			if j[v] ~= nil and j[v] ~= 0 then
				local data = {}
				data.num = j[v] * percent / 100
				data.item_id = ResPath.GetCurrencyID(v)
				data.is_bind = true
				local free_data = {}
				free_data.num = j[v] * percent / 100
				free_data.item_id = ResPath.GetCurrencyID(v)
				free_data.is_bind = true
				if j.vo and j.vo.is_open == 2 then --2种找回都可以
					data.num = j[v] * (percent / 100)
					free_data.num = j[v] * percent / 100
				elseif j.vo and j.vo.is_open == 1 then
					data.num = j[v]
					free_data.num = 0
				end
				if free_data.num > 0 then
					table.insert(self.free_item_cell_list, free_data)
				end
				if data.num > 0 then
					table.insert(self.item_cell_list, data)
				end
			end
		end
		--道具奖励
		for k,v in pairs(j.item_list) do
			if v ~= nil then
				local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
				local reward_list = {}
				if big_type == GameEnum.ITEM_BIGTYPE_GIF then
					if item_cfg.rand_num ~= 1 then
						reward_list = ItemData.Instance:GetGiftItemListByProf(v.item_id)
					end
				end

				local rat_num = 1

				local function func(item_data)
					local new_data = {}
					new_data.item_id = item_data.item_id
					new_data.num = item_data.num * rat_num * percent / 100
					new_data.is_bind = item_data.is_bind

					if j.vo and j.vo.is_open == 2 then --2种找回都可以
						new_data.num = item_data.num * rat_num * percent / 100
					elseif j.vo and j.vo.is_open == 1 then
						new_data.num = item_data.num * rat_num
					end
					if new_data.num > 0 then
						table.insert(self.item_cell_list, new_data)
					end
					if big_type == GameEnum.ITEM_BIGTYPE_GIF and v.num == 1 then
						return
					else
						local free_new_data = {}
						free_new_data.item_id = item_data.item_id
						free_new_data.num = item_data.num * rat_num * percent / 100
						free_new_data.is_bind = item_data.is_bind
						if j.vo and j.vo.is_open == 2 then --2种找回都可以
							free_new_data.num = item_data.num * rat_num * percent / 100
						elseif j.vo and j.vo.is_open == 1 then
							free_new_data.num = 0
						end
						if free_new_data.num > 0 then
							table.insert(self.free_item_cell_list, free_new_data)
						end
					end
				end
				if next(reward_list) then
					for k2, v2 in ipairs(reward_list) do
						rat_num = v.num or 1
						func(v2)
					end
				else
					func(v)
				end
			end
		end
	end
end

---------------------------------------------------------------
--滚动条格子
FindScrollerCell = FindScrollerCell or BaseClass(BaseCell)

function FindScrollerCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.node_list["BtnFindFree"].button:AddClickListener(BindTool.Bind(self.ClickFind, self, 0 ))
	self.node_list["BtnFindCost"].button:AddClickListener(BindTool.Bind(self.ClickFind, self, 1 ))

	self.node_list["TxtCost"].text.text = 0

	self.item_cell_list = {}
	self.percent = {}
	self.cost = 0
	local obj_group = self.node_list["ItemManager"]
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "ItemCell") ~= nil then
			self.item_cell_list[count] = ItemCell.New()
			self.item_cell_list[count]:SetInstanceParent(obj)
			count = count + 1
		end
	end
end

function FindScrollerCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
end

function FindScrollerCell:OnFlush()
	if nil == self.data then return end
	self.count = 1
	self.currency_count = 1
	local base_vo = self.data.vo or {}
	if self.data.total_type == 0 then
		--日常找回
		local daily_find_list = WelfareData.Instance:GetWelfareCfg().daily_find_list
		for k,v in pairs(daily_find_list) do
			if v.type == self.data.find_type then
				self.data.cfg = v
				self.percent = v.free_percent
				break
			end
		end
		if self.data.cfg then
			self.node_list["TxtName"].text.text = self.data.cfg.name 
		end
	else
		--活动找回
		self.node_list["TxtName"].text.text = base_vo.name or ""
		local activity_find = WelfareData.Instance:GetWelfareCfg().activity_find
		for k,v in pairs(activity_find) do
			if base_vo.name == v.name then
				self.percent = v.free_find_percent
			end
		end 
	end
	--虚拟币奖励
	for k,v in pairs(CurrencyName) do
		if self.data[v] ~= nil and self.data[v] ~= 0 then
			local data = {}
			data.num = self.data[v]
			data.item_id = ResPath.GetCurrencyID(v)
			data.is_bind = true
			self.item_cell_list[self.count]:SetActive(true)
			self.item_cell_list[self.count]:SetData(data)
			self.item_cell_list[self.count]:ListenClick()
			self.count = self.count + 1
			self.currency_count = self.currency_count + 1
		end
	end
	--道具奖励

	if self.data.item_list then
		for k,v in pairs(self.data.item_list) do
			if v ~= nil then
				if self.count > #self.item_cell_list then
					break
				end
				if v.item_id > 0 then
					local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
					local reward_list = {}
					if big_type == GameEnum.ITEM_BIGTYPE_GIF then
						if item_cfg.rand_num ~= 1 then
							reward_list = ItemData.Instance:GetGiftItemListByProf(v.item_id)
						end
					end

					local rat_num = 1

					local function func(item_data)
						if self.count > #self.item_cell_list then
							return
						end
						local new_data = {}
						new_data.item_id = item_data.item_id
						new_data.num = item_data.num * rat_num
						new_data.is_bind = item_data.is_bind
						self.item_cell_list[self.count]:SetActive(true)
						self.item_cell_list[self.count]:SetData(new_data)
						self.item_cell_list[self.count]:ListenClick()
						self.count = self.count + 1
					end
					if next(reward_list) then
						for k2, v2 in ipairs(reward_list) do
							rat_num = v.num or 1
							func(v2)
						end
					else
						func(v)
					end
				end
			end
		end
	end

	if 0 == self.data.is_self then
		self.count = 1
		for k, v in pairs(self.item_cell_list) do
			if self.data.show_retrieve and self.data.show_retrieve[k - 1] then
				v:SetData(self.data.show_retrieve[k - 1])
				v:SetActive(true)
				self.count = self.count + 1
			end
		end
	end


	-- --写死3个
	-- if self.count > 3 then
	-- 	self.count = 3
	-- end
	--隐藏没有数据的格子
	if self.count <= #self.item_cell_list then
		for i = self.count, #self.item_cell_list do
			self.item_cell_list[i]:SetActive(false)
			self.item_cell_list[i]:SetData(nil)
			self.item_cell_list[i]:ListenClick()
		end
	end
	self.node_list["TxtCost"].text.text = self.data.gold_need
	self.cost = self.data.gold_need
	UI:SetButtonEnabled(self.node_list["BtnFindFree"], true)
	if self.data and self.data.vo then
		if self.data.vo.is_open == 1 then
			UI:SetButtonEnabled(self.node_list["BtnFindFree"], false)
		end
	end
end
function FindScrollerCell:ClickFind(find_type)
	-- local function free_callback()
	-- 	self:ClickFindMakeSure(0)
	-- end

	-- local function cost_callback()
	-- 	self:ClickFindMakeSure(1)
	-- end
	-- local reward_list = {}
	-- local free_reward_list = {}
	-- for k,v in ipairs(self.item_cell_list) do
	-- 	if nil ~= v:GetData() and nil ~= v:GetData().num then
	-- 		local temp = {}
	-- 		local num = v:GetData().num
	-- 		temp.num = num * self.percent / 100  			 --奖励找回百分比
	-- 		temp.item_id = v:GetData().item_id
	-- 		temp.is_bind = v:GetData().is_bind
	-- 		reward_list[k] = temp
	-- 		free_reward_list[k] = temp
	-- 	end
	-- end
	-- for k,v in pairs(self.data.item_list) do
	-- 	local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
	-- 	if big_type == GameEnum.ITEM_BIGTYPE_GIF then
	-- 		if v.num == 1 then
	-- 			for i = self.currency_count, #free_reward_list do
	-- 				free_reward_list[i] = {}
	-- 				reward_list[i].num = reward_list[i].num / (self.percent / 100)
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if self.data and self.data.vo then
	-- 	if self.data.vo.is_open == 1 then 						--不能免费找回
	-- 		free_reward_list = {}
	-- 		for k,v in pairs(self.item_cell_list) do
	-- 			if nil ~= v:GetData() and nil ~= v:GetData().num then
	-- 				local temp = {}
	-- 				temp.num = v:GetData().num
	-- 				temp.item_id = v:GetData().item_id
	-- 				temp.is_bind = v:GetData().is_bind
	-- 				reward_list[k] = temp
	-- 			end
	-- 		end
	-- 	elseif self.data.vo.is_open == 2 then 					--2种找回都OK
	-- 		free_reward_list = free_reward_list
	-- 		reward_list = reward_list
	-- 	end
	-- end
	-- WelfareCtrl.Instance:ShowFindTips(self.cost,free_reward_list, reward_list, free_callback, cost_callback)
	-- local ok_callback = function()
		self:ClickFindMakeSure(find_type)
	-- end
	-- local describe = find_type == 0 and Language.Welfare.WelfareFindDes[find_type] or string.format(Language.Welfare.WelfareFindDes[find_type], self.cost)
	-- TipsCtrl.Instance:ShowCommonAutoView("", describe, ok_callback)
end
function FindScrollerCell:ClickFindMakeSure(find_type)
	local acitvity_find_type = 0
	if find_type == 0 then
		acitvity_find_type = 1
	end
	if self.data.total_type == 0 then
		WelfareCtrl.Instance:SendGetFindReward(self.data.find_type, find_type)
	else
		WelfareCtrl.Instance:SendGetActivityFindReward(self.data.vo.find_type, acitvity_find_type)
	end
end