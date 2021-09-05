RuneTreasureView = RuneTreasureView or BaseClass(BaseRender)

local COLUMN = 3
local MOVE_TIME = 0.5
local TEN_COUNT = 10
local FIFTY_COUNT = 50

function RuneTreasureView:UIsMove()
	UITween.AlpahShowPanel(self.node_list["Top"] , true , MOVE_TIME , DG.Tweening.Ease.InExpo)
end

function RuneTreasureView:__init()
	self.other_cfg = RuneData.Instance:GetOtherCfg()
	self.free_count_down = nil

	self.list_data = {}
	self.high_quality_list = {}
	self.cell_list = {}
	local scroller_delegate = self.node_list["ListView"].list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self.node_list["BtnZhanHunBag"].button:AddClickListener(BindTool.Bind(self.OpenBag, self))
	self.node_list["BtnZhanHun"].button:AddClickListener(BindTool.Bind(self.OpenExchange, self))
	self.node_list["BtnMingKe1"].button:AddClickListener(BindTool.Bind(self.TreasureOne, self))
	self.node_list["BtnMingKe10"].button:AddClickListener(BindTool.Bind(self.TreasureTen, self))
	self.node_list["PlayAniToggle"].toggle:AddClickListener(BindTool.Bind(self.OnClickPlayAniToggle, self))
	for i = 1, 2 do
		self.node_list["Item" .. i].button:AddClickListener(BindTool.Bind(self.OnClickItem, self, i))
	end
end

function RuneTreasureView:LoadCallBack()
	self:SetYiZheJumpTwo()
end

-- 寻宝钥匙，一折抢购跳转
function RuneTreasureView:SetYiZheJumpTwo()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	if other_cfg then
		local key_item_id_one = other_cfg.xunbao_consume_itemid or 0
		local select_list, index, phase = DisCountData.Instance:GetListNumByItemIdTwo(key_item_id_one)

		if not phase then
			return
		end

		local info = DisCountData.Instance:GetDiscountInfoByType(phase, true)
		if not info then
			return
		end

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level < info.active_level then
			return
		end

		if info.close_timestamp then
			if info.close_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
				local callback = function(node_list)
					node_list["BtnYiZhe"].button:AddClickListener(function()
					ViewManager.Instance:CloseAll()
					ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {index})
					end)
					self:StartCountDown(info, node_list)
				end
				CommonDataManager.SetYiZheBtnJumpTwo(self, self.node_list["BtnYiZheJumpTwo"], callback)
			end
		end
	end
end

-- 寻宝钥匙，一折抢购跳转
function RuneTreasureView:StartCountDown(data, node_list)
	self:StopCountDownTwo()
	if nil == data then
		return
	end

	local close_timestamp = data.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = ""

	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)

		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDownTwo()
				if self.node_list["BtnYiZheJump"] then
					self.node_list["BtnYiZheJump"]:SetActive(false)
				end
				return
			end

			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times, 13)
			node_list["TextCountDown"].text.text = time_des
		end

		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
		
	end

	time_des = TimeUtil.FormatSecond(left_times, 13)		
	node_list["TextCountDown"].text.text = time_des
	node_list["TextCountDown"]:SetActive(left_times > 0)
end

-- 寻宝钥匙，一折抢购跳转
function RuneTreasureView:StopCountDownTwo()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function RuneTreasureView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self:StopCountDown()
	self:StopCountDownTwo()
	self.high_quality_list = nil
end

function RuneTreasureView:InitView()
	UITween.MoveShowPanel(self.node_list["Title"], Vector3(-54, 106, 0))
	UITween.MoveShowPanel(self.node_list["Center"], Vector3(-54, -600, 0))
	UITween.MoveShowPanel(self.node_list["LeftPanle"], Vector3(-280, 0, 0))
	UITween.MoveShowPanel(self.node_list["RightPanle"], Vector3(400, -0, 0))
	--GlobalTimerQuest:AddDelayTimer(function()
		local pass_layer = RuneData.Instance:GetPassLayer()
		self.list_data = RuneData.Instance:GetRuneListByLayer(pass_layer)
		self:FlushView()
	--end, 0)
end

function RuneTreasureView:FlushView()
	local pass_layer = RuneData.Instance:GetPassLayer()
	-- local need_pass_layer = self.other_cfg.rune_compose_need_layer
	-- self.node_list["RuneShuiJing"]:SetActive(pass_layer >= need_pass_layer)

	local rune_suipian_num_low = self.other_cfg.rune_suipian_num_low
	local rune_suipian_num_high = self.other_cfg.rune_suipian_num_high
	local suipian_des = rune_suipian_num_low .. "-" .. rune_suipian_num_high
	self.node_list["SuiPianDes"].text.text = suipian_des
	-- self.node_list["RuneShuiJingText"].text.text = self.other_cfg.xunbao_one_magic_crystal

	local have_num = ItemData.Instance:GetItemNumInBagById(self.other_cfg.xunbao_consume_itemid)
	local one_consume_num = self.other_cfg.xunbao_one_consume_num
	local one_color = TEXT_COLOR.GREEN
	if have_num < one_consume_num then
		one_color = TEXT_COLOR.RED
	end
	local str = ToColorStr(have_num, one_color)
	self.node_list["OneText"].text.text = str .. " / " .. one_consume_num

	local ten_consume_num = self.other_cfg.xunbao_ten_consume_num
	local ten_color = TEXT_COLOR.GREEN
	if have_num < ten_consume_num then
		ten_color = TEXT_COLOR.RED
	end
	str = ToColorStr(have_num, ten_color)
	self.node_list["TenText"].text.text  =  str .. " / " .. ten_consume_num

	self:StarCountDown()
	
	local list = RuneData.Instance:GetRuneListByLayer(pass_layer)
	self.list_data = {}
	local last_layer = -1
	local index = 0
	local count = 1
	local types = -1
	self.high_quality_list = {} 
	table.sort(list, SortTools.KeyUpperSorter("type"))
	for k,v in ipairs(list) do
		if v and v.item_id ~= 23994 and v.item_id ~= 23995 then 			-- 屏蔽2个无视一击
			if v.treasure_show == 1 then
				-- if v.in_layer_open ~= last_layer then
				-- 	index = index + 1
				-- 	self.list_data[index] = {}
				-- 	last_layer = v.in_layer_open
				-- 	count = 1
				-- else
				-- 	if count > COLUMN then
				-- 		index = index + 1
				-- 		self.list_data[index] = {}
				-- 		count = 1
				-- 	end
				-- end
				if v.type == types then
					index = index
				else
					types = v.type
					index = index + 1
					count = 1
				end
				if nil == self.list_data[index] then
					self.list_data[index] = {}
				end
				if count > 3 then
					count = 3
				end
				self.list_data[index][count] = v
				count = count + 1
			end
		else
			if v.treasure_show == 1 then
				table.insert(self.high_quality_list, v)
				SortTools.SortAsc(self.high_quality_list, "quality")
			end
		end
	end

	for i,v in ipairs(self.list_data) do
		SortTools.SortAsc(v, "quality")
	end

	for i,v in ipairs(self.high_quality_list) do
	end
	self.total_count = index
	self.node_list["ListView"].scroller:ReloadData(0)

	for i = 1, 2 do
		if self.high_quality_list[i] and self.high_quality_list[i].item_id and self.high_quality_list[i].item_id > 0 then
			self.node_list["ImgIcon" .. i].image:LoadSprite(ResPath.GetItemIcon(self.high_quality_list[i].item_id))
		end
	end

	self:SetTreasurCount()
end

function RuneTreasureView:SetTreasurCount()
	local total_xunbao_times = RuneData.Instance:GetXunBaoTimes()
	local ten_xunbao_times = TEN_COUNT - total_xunbao_times % TEN_COUNT
	local fifty_xunbao_times = FIFTY_COUNT - total_xunbao_times % FIFTY_COUNT
	self.node_list["ImgOpenTen"]:SetActive(ten_xunbao_times == 1)
	self.node_list["CountOpenTen"]:SetActive(ten_xunbao_times ~= 1)
	self.node_list["ImgOpenFifty"]:SetActive(fifty_xunbao_times == 1)
	self.node_list["CountOpenFifty"]:SetActive(fifty_xunbao_times ~= 1)
	
	if ten_xunbao_times > 10 and ten_xunbao_times < 20 then
		self.node_list["ShiWeiTen"]:SetActive(false)
		self.node_list["ShiTen"]:SetActive(true)
		self.node_list["GeWeiTen"]:SetActive(true)
		local bundle, asset = ResPath.GetRuneTreasureCount(ten_xunbao_times % 10)
		self.node_list["GeWeiTen"].image:LoadSprite(bundle, asset)
	elseif ten_xunbao_times >= 20 then
		self.node_list["ShiWeiTen"]:SetActive(true)
		self.node_list["ShiTen"]:SetActive(true)
		local bundle, asset = ResPath.GetRuneTreasureCount(ten_xunbao_times % 10)
		local bundle1, asset1 = ResPath.GetRuneTreasureCount(math.floor(ten_xunbao_times / 10))
		self.node_list["GeWeiTen"]:SetActive(false)
		if ten_xunbao_times % 10 ~= 0 then
			self.node_list["GeWeiTen"]:SetActive(true)
			self.node_list["GeWeiTen"].image:LoadSprite(bundle, asset)
		end
		self.node_list["GeWeiTen"].image:LoadSprite(bundle, asset)
		self.node_list["ShiWeiTen"].image:LoadSprite(bundle1, asset1)
	else
		self.node_list["GeWeiTen"]:SetActive(true)
		self.node_list["ShiWeiTen"]:SetActive(false)
		self.node_list["ShiTen"]:SetActive(false)
		local bundle, asset = ResPath.GetRuneTreasureCount(ten_xunbao_times)
		self.node_list["GeWeiTen"].image:LoadSprite(bundle, asset)
	end

	if fifty_xunbao_times > 10 and fifty_xunbao_times < 20 then
		self.node_list["ShiWeiFifty"]:SetActive(false)
		self.node_list["ShiFifty"]:SetActive(true)
		self.node_list["GeWeiFifty"]:SetActive(true)
		local bundle, asset = ResPath.GetRuneTreasureCount(fifty_xunbao_times % 10)
		self.node_list["GeWeiFifty"].image:LoadSprite(bundle, asset)
	elseif fifty_xunbao_times >= 20 then
		self.node_list["ShiWeiFifty"]:SetActive(true)
		self.node_list["ShiFifty"]:SetActive(true)
		local bundle, asset = ResPath.GetRuneTreasureCount(fifty_xunbao_times % 10)
		local bundle1, asset1 = ResPath.GetRuneTreasureCount(math.floor(fifty_xunbao_times / 10))
		self.node_list["GeWeiFifty"]:SetActive(false)
		if fifty_xunbao_times % 10 ~= 0 then
			self.node_list["GeWeiFifty"]:SetActive(true)
			self.node_list["GeWeiFifty"].image:LoadSprite(bundle, asset)
		end
		self.node_list["ShiWeiFifty"].image:LoadSprite(bundle1, asset1)
	else
		self.node_list["GeWeiFifty"]:SetActive(true)
		self.node_list["ShiWeiFifty"]:SetActive(false)
		self.node_list["ShiFifty"]:SetActive(false)
		local bundle, asset = ResPath.GetRuneTreasureCount(fifty_xunbao_times)
		self.node_list["GeWeiFifty"].image:LoadSprite(bundle, asset)
	end


end
function RuneTreasureView:OnClickItem(i)
	if i and self.high_quality_list[i] then
		local function callback()
			self.node_list["HL" .. i]:SetActive(false)
		end
		self.node_list["HL" .. i]:SetActive(true)
		RuneCtrl.Instance:SetTipsData(self.high_quality_list[i])
		RuneCtrl.Instance:SetTipsCallBack(callback)
		ViewManager.Instance:Open(ViewName.RuneItemTips)
	end
end

function RuneTreasureView:StopCountDown()
	if self.free_count_down then
		CountDown.Instance:RemoveCountDown(self.free_count_down)
		self.free_count_down = nil
	end
end

function RuneTreasureView:StarCountDown()
	self:StopCountDown()
	local next_free_xunbao_timestamp = RuneData.Instance:GetNextFreeXunBaoTimestamp()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local diff_time = next_free_xunbao_timestamp - server_time
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StopCountDown()
			self.node_list["FreeText"].text.text = ""
			return
		end
		local temp_diff_time = math.ceil(total_time - elapse_time)
		local time_str = TimeUtil.FormatSecond(temp_diff_time, 3)
		time_str = string.format(Language.Rune.FreeDes, time_str)
		self.node_list["FreeText"].text.text = time_str
	end
	if diff_time > 0 then
		diff_time = math.ceil(diff_time)
		self.free_count_down = CountDown.Instance:AddCountDown(diff_time, 1, timer_func)
		local time_str = TimeUtil.FormatSecond(diff_time, 3)
		time_str = string.format(Language.Rune.FreeDes, time_str)
		self.node_list["FreeText"].text.text = time_str
		self.node_list["IsFreeImg"]:SetActive(false)
		self.node_list["Effect"]:SetActive(false)
		self.node_list["OneText"]:SetActive(true)
		self.node_list["Free"]:SetActive(false)
	else
		self.node_list["IsFreeImg"]:SetActive(true)
		self.node_list["Effect"]:SetActive(true)
		self.node_list["OneText"]:SetActive(false)
		self.node_list["Free"]:SetActive(true)
		self.node_list["FreeText"].text.text = ""
	end
end

function RuneTreasureView:OpenBag()
	RuneCtrl.Instance:SetSlotIndex(0)
	ViewManager.Instance:Open(ViewName.RuneBag)
end

function RuneTreasureView:OpenExchange()
	ViewManager.Instance:Open(ViewName.Rune, TabIndex.rune_exchange)
end

function RuneTreasureView:OnClickPlayAniToggle()
	RuneData.Instance:SetPlayTreasureAni(self.node_list["PlayAniToggle"].toggle.isOn)
end

function RuneTreasureView:TreasureOne()
	if RuneData.Instance:GetFreeTimes() > 0 then
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE)
		return
	end
	local item_id = self.other_cfg.xunbao_consume_itemid
	local one_consume_num = self.other_cfg.xunbao_one_consume_num
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local count = RuneData.Instance:GetBagNum()
	if count >= one_consume_num then
		if num >= one_consume_num then
			--物品充足
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE)
		else
			--物品不足
			local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
			if not shop_data then
				return
			end
			local function ok_callback()
				RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_ONE, 1)
			end
			local differ_num = one_consume_num - num
			local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
			local color = item_cfg.color or 1
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or ""
			local cost = shop_data.gold * differ_num
			local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
			TipsCtrl.Instance:ShowCommonAutoView("rune_one_xunbao", des, ok_callback)
		end
	else
		self:AnalyToTreasure()
	end
end

function RuneTreasureView:TreasureTen()
	local item_id = self.other_cfg.xunbao_consume_itemid
	local ten_consume_num = self.other_cfg.xunbao_ten_consume_num
	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local count = RuneData.Instance:GetBagNum()
	if count > ten_consume_num then
		if num >= ten_consume_num then
			--物品充足
			RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN)
		else
			--物品不足
			local shop_data = ShopData.Instance:GetShopItemCfg(item_id)
			if not shop_data then
				return
			end
			local function ok_callback()
				RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_XUNBAO_TEN, 1)
			end
			local differ_num = ten_consume_num - num
			local item_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
			local color = item_cfg.color or 1
			local color_str = ITEM_COLOR[color]
			local name = item_cfg.name or ""
			local cost = shop_data.gold * differ_num
			local des = string.format(Language.Rune.NotEnoughDes, color_str, name, cost)
			TipsCtrl.Instance:ShowCommonAutoView("rune_ten_xunbao", des, ok_callback,nil, nil, nil, nil, nil, true)
		end
	else
		self:AnalyToTreasure()
	end
end

function RuneTreasureView:AnalyToTreasure()
		local des = Language.Rune.describe
		local function dis_callback()
			self:AnalyJingHua()
		end
		TipsCtrl.Instance:ShowCommonAutoView("rune_ten", des, dis_callback, nil,nil, nil, nil, nil, true)
end

function RuneTreasureView:AnalyJingHua()
	local list_data = RuneData.Instance:GetAnalyList()
	local data_list = {}
	for k, v in ipairs(list_data) do
		if v.type == GameEnum.RUNE_JINGHUA_TYPE or v.quality == 0 or v.quality == 1 then
			if not data_list[v.index] then
				data_list[v.index] = v
			end
		end
	end

	if not next(data_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rune.NotSelectRune)
		return
	end

	local tbl = {}
	for k, v in pairs(data_list) do
		table.insert(tbl, k)
	end
	SortTools.SortAsc(tbl)
	local max_count = #tbl
	RuneCtrl.Instance:SendOneKeyAnalyze(max_count, tbl)
end

function RuneTreasureView:GetCellNumber()
	return self.total_count
end

function RuneTreasureView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneAnalyzeGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local data_list = self.list_data[data_index + 1] or {}
	for i = 1, COLUMN do
		local data = data_list[i]
		if data then
			local item_data = TableCopy(data)
			item_data.panel = 0
			group_cell:SetActive(i, true)
			group_cell:SetData(i, item_data)
			group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
		else
			group_cell:SetActive(i, false)
		end
	end
end

function RuneTreasureView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	RuneCtrl.Instance:SetTipsData(data)
	RuneCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.RuneItemTips)
end