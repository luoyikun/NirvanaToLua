-- require("game/gold_hunt/gold_hunt_quick_flush_view")

local QUALITY_TO_INDEX = 
{
	[0] = 1,
	[1] = 1,
	[2] = 2,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6,
}

GoldHuntView = GoldHuntView or BaseClass(BaseView)


function GoldHuntView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour"},
		{"uis/views/goldhuntview_prefab", "GoldHuntView"},
	}
	self.full_screen = false
	self.play_audio = true
	self.timer_t = {}

	self.is_modal = true
	
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function GoldHuntView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClose, self))
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/goldhuntview/images_atlas","gold_title.png")
	-- self.node_list["ImgTitle"].image:SetNativeSize()

	self.node_list["Name"].text.text = Language.Title.GoldLie

	self.node_list["ExchangeBtn"].button:AddClickListener(BindTool.Bind(self.OnExchangeClick, self))
	self.node_list["LeftArrow"].button:AddClickListener(BindTool.Bind(self.OnLeftClick, self))
	self.node_list["RightArrow"].button:AddClickListener(BindTool.Bind(self.OnRightClick, self))
	self.node_list["FlushBtn"].button:AddClickListener(BindTool.Bind(self.OnFlushClick, self))
	self.node_list["ButtonHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["FlushQuickBtn"].button:AddClickListener(BindTool.Bind(self.OnQuickClick, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.cell_list = {}
	self.list_view_delegate = self.node_list["list_view"].list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.item_cell_list = {}

	self.items_list_view_delegate = self.node_list["items_list_view"].list_simple_delegate
	self.items_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetItemsNumberOfCells, self)
	self.items_list_view_delegate.CellRefreshDel = BindTool.Bind(self.ItemsRefreshView, self)

	self.ore_list = {}
	for i = 1, 8 do
		local ore_cell = GoldHuntOreCell.New(self.node_list["ore_" .. i])
		ore_cell.parent = self
		ore_cell:SetIndex(i)
		table.insert(self.ore_list, ore_cell)
	end

	self.is_auto = false
end

function GoldHuntView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.ore_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end

	self:CancelCountDown()
	self.item_list = {}
	self.list_view = nil
	self.list_view_delegate = nil
	self.items_list_view_delegate = nil
end

function GoldHuntView:OpenCallBack()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	if is_open then
		GoldHuntCtrl.Instance:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_TYPE_QUERY_INFO)
	end

	self.cur_index = 1
	self:Flush("items_flush")
end

function GoldHuntView:SetTxtState(state)
	self.node_list["Text"]:SetActive(state)
	self.node_list["Text1"]:SetActive(not state)
end



function GoldHuntView:OnClose()
	GoldHuntCtrl.Instance:Restore()
	self:Close()
end

function GoldHuntView:CloseCallBack()
	for k,v in pairs(self.timer_t) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.timer_t = {}
	for k,v in pairs(self.ore_list) do
		v:SetMove(false)
	end
	GoldHuntCtrl.Instance:Restore()
end

function GoldHuntView:PetMove(index, cell)
	if self.timer_t[index] then return end
	local gold_hunt_info = GoldHuntData.Instance:GetHuntInfo()
	local time = nil
	if gold_hunt_info.mine_cur_type_list and gold_hunt_info.mine_cur_type_list[index] ~= 0 and math.random(10) == 1 then
		cell:SetMove(true)
	end
end

function GoldHuntView:MoveCompare(index, cell)
	self.timer_t[index] = nil
	cell:SetMove(false)
end


function GoldHuntView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "items_flush" then
			self:FlushArrow()
			self:FlushHuntText()
			self:FlushAllHl()
		elseif k == "flush_all_hl" then
			self:FlushAllHl()
		else
			self:FlushHuntInfo()
			self:FlushOreList()
			self.node_list["list_view"].scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function GoldHuntView:OnQuickClick()
	local is_auto = GoldHuntCtrl.Instance:GetAuto()
	if is_auto then
		GoldHuntCtrl.Instance:Restore()
	else
		ViewManager.Instance:Open(ViewName.QuickFlushView)
	end
end

function GoldHuntView:GetNumberOfCells()
	return GoldHuntData.Instance:GetRewardCfgCount()
end

function GoldHuntView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
end

function GoldHuntView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntCell.New(cell.gameObject)
		the_cell.root_node.toggle.group = self.node_list["list_view"].toggle_group
		the_cell.parent = self
		self.cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	local data = GoldHuntData.Instance:GetReturnReward()
	the_cell:SetData(data[data_index])
	-- the_cell:SetData(GoldHuntData.Instance:GetRewardCfgList()[data_index].reward_item)
end

--物品格子list_view
function GoldHuntView:GetItemsNumberOfCells()
	return math.ceil(GoldHuntData.Instance:GetHuntInfoCfgCount()/2)
end

function GoldHuntView:ItemsRefreshView(cell, data_index)
	data_index = data_index + 1
	local the_cell = self.item_cell_list[cell]
	if the_cell == nil then
		the_cell = GoldHuntItemCell.New(cell.gameObject)
		the_cell.parent = self
		self.item_cell_list[cell] = the_cell
	end
	the_cell:SetIndex(data_index)
	the_cell:SetData(CommonDataManager.GetCellIndexList(data_index, 2, 2))
end

function GoldHuntView:GetCurListViewIndex()
	local position = self.node_list["list_view"].scroller.ScrollPosition
	return self.node_list["list_view"].scroller:GetCellViewIndexAtPosition(position)
end

function GoldHuntView:OnLeftClick()
	local jump_index = 0
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["items_list_view"].scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = nil
	self.node_list["items_list_view"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoldHuntView:OnRightClick()
	local jump_index = 1
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.node_list["items_list_view"].scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = nil
	self.node_list["items_list_view"].scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoldHuntView:OnFlushClick()
	local flush_price = GoldHuntData.Instance:GetFlushPrice()
	local vo_money = GameVoManager.Instance:GetMainRoleVo().gold
	if vo_money >= flush_price then
		function call_back(is_auto)
			self.is_auto = is_auto
			TipsCtrl.Instance:ChangeAutoViewAuto(is_auto)
			if not is_auto then
				TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = nil
			else
				TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = {is_auto_buy = is_auto}
			end

			GoldHuntCtrl.Instance:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_REFRESH)
		end

		function confirm()
			TipsCtrl.Instance:ChangeAutoViewAuto(self.is_auto)
			GlobalTimerQuest:AddDelayTimer(function ()
					local describe = string.format(Language.Common.FlushGoldHunt, flush_price)
					TipsCommonAutoView.AUTO_VIEW_STR_T["FlushHunt"] = nil
					TipsCtrl.Instance:ShowCommonAutoView("FlushHunt", describe, call_back, nil, nil, nil, nil, nil, true, nil)
			end, 0)
			
		end
		local has_rare = false
		local mine_info = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list
		for k,v in pairs(mine_info) do
			if v >= 15 then
				has_rare = true
				break
			end
		end
		if has_rare then
			TipsCommonAutoView.AUTO_VIEW_STR_T[""] = nil
			TipsCtrl.Instance:ShowCommonAutoView("", Language.Common.FlushTip, confirm, nil, nil, nil, nil, nil, true, nil)
		else
			confirm()
		end
	else
		TipsCtrl.Instance:ShowLackDiamondView()
	end
end

function GoldHuntView:OnExchangeClick()
	TipsCtrl.Instance:OpenGoldHuntExchangeView()
end

function GoldHuntView:FlushArrow()

end

function GoldHuntView:ClickHelp()
	local tips_id = 213
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GoldHuntView:SetCurIndex(cur_index)
	self.cur_index = cur_index
end

function GoldHuntView:GetCurIndex()
	return self.cur_index
end

--刷新猎场信息
function GoldHuntView:FlushHuntInfo()
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	if not next(hunt_info) then
		return
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	local time_diff = hunt_info.next_refresh_time - server_time
	local time_table = TimeUtil.Timediff(hunt_info.next_refresh_time, server_time)
	local str = string.format("%02d:%02d:%02d", time_table.hour, time_table.min, time_table.sec)
	str = ToColorStr(str, COLOR.GREEN)
	self.node_list["HunFlushTime"].text.text = string.format(Language.Common.FlushHuntTime, str)
	local free_count = nil
	if hunt_info.free_gather_times == 0 then
		free_count = ToColorStr(hunt_info.free_gather_times, COLOR.RED) ..ToColorStr(("/".. gold_hunt_data:GetMaxFreeHuntCountCfg()), COLOR.GREEN)
	else
		free_count = ToColorStr((hunt_info.free_gather_times .. "/".. gold_hunt_data:GetMaxFreeHuntCountCfg()), COLOR.GREEN)
	end
	self.node_list["FreeHunCount"].text.text = string.format(Language.Common.FreeHuntCount, free_count)

	self.node_list["Price"].text.text = gold_hunt_data:GetFlushPrice()
	self:CancelCountDown()
	self.count_down = CountDown.Instance:AddCountDown(time_diff, 1, BindTool.Bind(self.CountDown, self))


	self.node_list["RedPoint"]:SetActive(gold_hunt_data:CanExchange())
end

function GoldHuntView:FlushHuntText()
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	if not next(hunt_info) then
		return
	end

	local free_count = nil
	if hunt_info.free_gather_times == 0 then
		free_count = ToColorStr(hunt_info.free_gather_times, COLOR.RED) ..ToColorStr(("/".. gold_hunt_data:GetMaxFreeHuntCountCfg()), COLOR.GREEN)
	else
		free_count = ToColorStr((hunt_info.free_gather_times .. "/".. gold_hunt_data:GetMaxFreeHuntCountCfg()), COLOR.GREEN)
	end
	self.node_list["FreeHunCount"].text.text = string.format(Language.Common.FreeHuntCount, free_count)

end

function GoldHuntView:CountDown(elapse_time, total_time)
	local gold_hunt_data = GoldHuntData.Instance
	local hunt_info = gold_hunt_data:GetHuntInfo()
	local gold_hunt_data = GoldHuntData.Instance
	if not next(hunt_info) then
		return
	end

	local time_table = TimeUtil.Timediff(hunt_info.next_refresh_time, server_time)
	local str = TimeUtil.FormatSecond(total_time - elapse_time)
	str = ToColorStr(str, COLOR.GREEN)
	self.node_list["HunFlushTime"].text.text = string.format(Language.Common.FlushHuntTime, str)
	if elapse_time >= total_time then
		self:CancelCountDown()
	end
end

function GoldHuntView:CancelCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GoldHuntView:FlushAllHl()

end

function GoldHuntView:FlushOreList()
	for i = 1, 8 do
		self.ore_list[i]:Flush()
	end
end
-------------------------------------------------------------------------
GoldHuntCell = GoldHuntCell or BaseClass(BaseCell)

function GoldHuntCell:__init()
	self.item_cell = ItemCell.New()

	self.item_cell:SetInstanceParent(self.node_list["item"])

	self.node_list["GoldHuntCell"].toggle:AddClickListener(handler or BindTool.Bind(self.OnItemClick, self))
end

function GoldHuntCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
	self.parent = nil
	self.show_point = nil
	self.show_gray = nil
	self.vip_text = nil
	self.arrive_reward_count = nil
end

function GoldHuntCell:OnItemClick(is_click)
	if is_click then
		self.parent:SetCurIndex(self.index)
		self.parent:Flush("items_flush")
		self.parent:Flush("flush_all_hl")
	end
	local seq = self.data.cfg.seq
	GoldHuntCtrl.Instance:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_FETCH_SERVER_REWARD, seq)
end

function GoldHuntCell:OnFlush()
	local reward_cfg = self.data.cfg
	local hunt_info = GoldHuntData.Instance:GetHuntInfo()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if vip_level ~= nil and hunt_info ~= nil and reward_cfg ~= nil then
		self.item_cell:SetData(self.data.cfg.reward_item)

		self.node_list["VipText"].text.text = Language.Common.VIP .. reward_cfg.mine_server_reward_vip_limit

		self.node_list["RewardCount"].text.text = hunt_info.role_refresh_times.."/"..reward_cfg.total_refresh_times

	if vip_level >= reward_cfg.mine_server_reward_vip_limit then
		if hunt_info.role_refresh_times >= reward_cfg.total_refresh_times then
			self.node_list["TextGet"]:SetActive(self.data.fetch_flag == 0)
			self.node_list["SelectFrame"]:SetActive(self.data.fetch_flag == 0)
			self.node_list["TextPanel"]:SetActive(false)
		else
			self.node_list["TextGet"]:SetActive(false)
			self.node_list["TextPanel"]:SetActive(true)
			self.node_list["SelectFrame"]:SetActive(false)
		end
	end

	-- self.node_list["GreyMask"]:SetActive(1 == GoldHuntData.Instance:GetFetchRewardFlag(self.index - 1))
	self.node_list["GreyMask"]:SetActive(self.data.fetch_flag == 1)
	end

end

-------------------------------------------------------------------------
GoldHuntOreCell = GoldHuntOreCell or BaseClass(BaseCell)

function GoldHuntOreCell:__init()

	self.img_index = 0
	self.is_move = false
	self.count_flag = 0
	self.model = RoleModel.New()
	self.model:SetDisplay(self.node_list["Display"].ui3d_display, MODEL_CAMERA_TYPE.BASE)
	self.model:SetRotation(Vector3(0, -30, 0))

	self.node_list["Ore"].button:AddClickListener(BindTool.Bind(self.OnClickKuangShi, self))
end

function GoldHuntOreCell:__delete()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end
	self.parent = nil
	self:CancelQuest()
end

function GoldHuntOreCell:OnClickKuangShi()
	local gold_hunt_data = GoldHuntData.Instance
	local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index]
	if gather_index == 0 then
		return
	end

	local free_time = gold_hunt_data:GetHuntInfo().free_gather_times
	function call_back()
		GoldHuntCtrl.Instance:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_GATHER, self.index - 1)
	end
	if free_time > 0 then
		call_back()
	else
		local gather_index = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型

		local price = gold_hunt_data:GetHuntPrice(gather_index)
		local describe = string.format(Language.Common.ToGoldHunt, price)
		TipsCtrl.Instance:ShowCommonAutoView("Hunt", describe, call_back, nil, nil, nil, nil, nil, true, nil)
	end
end

function GoldHuntOreCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index]
	self.root_node:SetActive(gather_index ~= 0)
	if gather_index == 0 then
		self:CancelQuest()
		self.node_list["Ore"]:SetActive(false)
	else
		local gather_index = gold_hunt_data:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型
		local name = gold_hunt_data:GetMineralInfo(gather_index)
		local quality_num = QUALITY_TO_INDEX[gather_index]
		self.node_list["QualityBG"].image:LoadSprite(ResPath.GetGoldHuntQualityPic(quality_num))
		self.node_list["Name"].text.text = name

		self.node_list["Bubble"]:SetActive(gather_index >= 5)
		if self.timer_quest == nil then
			-- self.img_index = self:GetNextImgIndex()
			if gather_index >= 0 then
				self.node_list["Ore"]:SetActive(true)
				self:SetModelImg(gather_index)
			end
			self:StartQuest()
		else
			self:SetModelImg(gather_index)
		end
	end
end
function GoldHuntOreCell:SetModelImg(gather_index)
	local res_id = GoldHuntData.Instance:GetHuntModelId(gather_index)
	local bundle, asset = ResPath.GetLittlePetModel(res_id)
	self.model:SetMainAsset(bundle, asset)
end

function GoldHuntOreCell:SetMove(value)
	if self.is_move ~= value then
		self.is_move = value
-- 		self.img_index = 0
		self:OnFlush()
	end
end

function GoldHuntOreCell:StartQuest()
	self.count_flag = self.count_flag == 0 and 1 or 0
	local gather_index = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list[self.index] - 10  -- 服务器说要减10后才是真正的猎场类型
	if gather_index >= 0 and (self.is_move or self.count_flag == 1) then

		self.node_list["Ore"]:SetActive(true)
		self:SetModelImg(gather_index)
	end
end

function GoldHuntOreCell:CancelQuest()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

-------------------------------------------------------------------------
GoldHuntItemCell = GoldHuntItemCell or BaseClass(BaseCell)

function GoldHuntItemCell:__init()
	self.item_list = {}
	self.show_item_list = {}
	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.node_list["item" .. i])
		table.insert(self.item_list, item_cell)

	end
end

function GoldHuntItemCell:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.parent = nil
	self.show_item_list = {}
end

function GoldHuntItemCell:OnFlush()
	local gold_hunt_data = GoldHuntData.Instance
	local info_cfg = gold_hunt_data:GetHuntInfoCfg()
	if not info_cfg then return end
	for i = 1, 2 do
		local data = gold_hunt_data:GetExchangeShowItems(self.data[i])
		self.item_list[i]:ShowQuality(data ~= nil)
		if data and next(data) then
			self.item_list[i]:SetData(data)
		end
	end
end
