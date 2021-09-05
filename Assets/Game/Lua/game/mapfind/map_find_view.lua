MapFindView = MapFindView or BaseClass(BaseView)

local MapFindFlushSlideMaxNumber = 0

function MapFindView:__init()
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_1"},
		{"uis/views/commonwidgets_prefab", "BaseActivityPanelFour_2"},
		{"uis/views/mapfind_prefab", "MapFind"},
		
	}
	self.play_audio = true
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function MapFindView:LoadCallBack()
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["RewardItem"])
	self.flush_item = {}
	for i = 1, 6 do
		self.flush_item[i] = MapFlushItem.New(self.node_list["Item" .. i])
	end

	self.find_item = {}
	for i = 1, 3 do
		self.find_item[i] = FindItem.New(self.node_list["FindItem" .. i], self)
	end
	-- self.node_list["ImgTitle"].image:LoadSprite("uis/views/mapfind/images_atlas","mapfind_title_text.png")
	self.node_list["Name"].text.text = Language.MapFind.Title
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseView, self))
	self.node_list["BtnFlush"].button:AddClickListener(BindTool.Bind(self.ClickRushFlush, self))
	self.node_list["BtnJiangLi"].button:AddClickListener(BindTool.Bind(self.ClickReward, self))
	self.node_list["BtnFlushMap"].button:AddClickListener(BindTool.Bind(self.ClickFlush, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.ClickHelp, self))
	self.node_list["BtnLucky"].button:AddClickListener(BindTool.Bind(self.OnClickLog, self))

	self.cell_list = {}
	local list_simple_delegate = self.node_list["List"].list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function MapFindView:ReleaseCallBack()
	self.day_range = nil
	if self.reward_item then
		self.reward_item:DeleteMe()
	end
	self.reward_item = nil

	for k, v in pairs(self.flush_item) do
		v:DeleteMe()
	end
	self.flush_item = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.find_item) do
		v:DeleteMe()
	end
	self.find_item = {}

	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
		self.count = nil
	end

	if self.count1 then
		CountDown.Instance:RemoveCountDown(self.count1)
		self.count1 = nil
	end

	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
end

function MapFindView:OpenCallBack()
	MapFindCtrl.Instance:SendInfo()
	self.in_rush = false
	self.is_show_reward = false
	self.node_list["List"].scroller:RefreshAndReloadActiveCellViews(true)
end

function MapFindView:CloseCallBack()
end

function MapFindView:OnFlush()
	self:ConstructData()
end

function MapFindView:OnClickLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT)
end

function MapFindView:GetNumberOfCells()
	return MapFindData.Instance:GetRouteNumber()
end

--滚动条刷新
function MapFindView:RefreshView(cell, data_index)
	local left_cell = self.cell_list[cell]
	if left_cell == nil then
		left_cell = MapRewardItem.New(cell.gameObject)
		self.cell_list[cell] = left_cell
	end
	left_cell:SetIndex(data_index)
	left_cell:SetData(self.day_range)
end

function MapFindView:CloseView()
	self:Close()
end

function MapFindView:OnItemDataChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_MAP_HUNT_BAST_REWARD then
		local get_num = new_num - old_num
		TipsCtrl.Instance:OpenGuildRewardView({item_id = change_item_id, num = get_num})
	end
end

function MapFindView:ClickRushFlush()
	if self.in_rush then
		MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH, MapFindData.Instance:GetSelect(), 0)
		MapFindCtrl.Instance:EndRush() 
	else
		local flag = MapFindData.Instance:HasRareItemNotBuy()
		if flag then
			local yes_func = function()
				ViewManager.Instance:Open(ViewName.MapfindRushView)
			end
			local tips = Language.TreasureBusinessman.HasRare
			local ok_des = Language.TreasureBusinessman.KeepRefreh
			TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, ok_des, nil, nil, nil, true)
		else
			ViewManager.Instance:Open(ViewName.MapfindRushView)
		end
	end
end

function MapFindView:ClickReward()
	ViewManager.Instance:Open(ViewName.MapFindRewardView)
end

function MapFindView:ClickFlush()
	local flag = MapFindData.Instance:HasRareItemNotBuy()
	local flush_spend = MapFindData.Instance:GetMapFlushSpend()
	local str = string.format(Language.MapFind.FlushSpend, flush_spend)
	local func = function()
		MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH)
	end
	if flag then
		local end_func = function()
			TipsCtrl.Instance:ShowCommonAutoView("map_find_flush_spend", str, func)
			if self.count_show_tip then
				 CountDown.Instance:RemoveCountDown(self.count_show_tip)
				 self.count_show_tip = nil
			end
		end
		local yes_func = function()
			if not self.count_show_tip then
				self.count_show_tip = CountDown.Instance:AddCountDown(0.5, 1, end_func)
			end
		end
		local tips = Language.TreasureBusinessman.HasRare
		local ok_des = Language.TreasureBusinessman.KeepRefreh
		TipsCtrl.Instance:ShowCommonAutoView("", tips, yes_func, nil, nil, ok_des, nil, nil, nil, true)
	else
		TipsCtrl.Instance:ShowCommonAutoView("map_find_flush_spend", str, func)
	end

	-- local flush_spend = MapFindData.Instance:GetMapFlushSpend()
	-- local str = string.format(Language.MapFind.FlushSpend, flush_spend)
	-- TipsCtrl.Instance:ShowCommonAutoView("map_find_flush_spend", str, function ()
	-- 	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH)
	-- end）
end

function MapFindView:ClickHelp()
	local tips_id = 211
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MapFindView:ConstructData()
	local data = MapFindData.Instance
	self.city_route = data:GetMapCampDataByDayRange(data:GetRouteIndex())
	-- MapFindFlushSlideMaxNumber = self.flush_items_data[#self.flush_items_data].need_flush_count
	-- MapFindFlushSlideMaxNumber = MapFindFlushSlideMaxNumber + MapFindFlushSlideMaxNumber * 0.2
	self.free_times = data:GetFreeTimes()
	self.next_time_flush = data:GetNextFlushTime()
	self.route_info = data:GetRouteInfo()
	local now_time = TimeCtrl.Instance:GetServerTime()
	self.end_time = ActivityData.Instance:GetActivityStatus()[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT].end_time - now_time
	self:SetDataView()
	self.node_list["TxtGold1"].text.text = data:GetMapFlushSpend()

	local player_had_gold = PlayerData.Instance:GetRoleVo().gold
	if player_had_gold < data:GetMapFlushSpend() then
		self.in_rush = false
		self.node_list["TxtBtnFlush"]:SetActive(true)
		self.node_list["TxtBtnFushDelete"]:SetActive(false)
	end

	if self.in_rush then
		MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH)
	end
end

function MapFindView:GetFreeFindTime()
	return self.free_times
end

function MapFindView:SetDataView()
	self.reward_item:SetData(self.city_route.reward_item)
	self:SetSlider()
	self:FlushDataView()
	for i = 1, 3 do
		local bundle, asset = ResPath.GetMapImg(self.city_route["city_" .. i])
		self.node_list["Note" .. i].image:LoadSprite(bundle, asset .. ".png", function() 
				self.node_list["Note" .. i].image:SetNativeSize() 
				end)
		self.node_list["Text" .. i].text.text = MapFindData.Instance:GetNameById(self.city_route["city_" .. i])
	end

	for k, v in pairs(self.find_item) do
		v:SetData(k)
	end
	if self.count then
		CountDown.Instance:RemoveCountDown(self.count)
	end
	self.count = nil
	if self.count1 then
		CountDown.Instance:RemoveCountDown(self.count1)
	end
	self.count1 = nil
	self.count1 = CountDown.Instance:AddCountDown(self.end_time, 1, function ()
		self.end_time = self.end_time - 1
		local end_time = TimeUtil.FormatSecond(self.end_time - 1, 6)
		self.node_list["TxtImg2"].text.text = string.format(Language.MapFind.EndTime, end_time)
	end)


	self.count = CountDown.Instance:AddCountDown(self.next_time_flush, 1, function ()
		self.next_time_flush = self.next_time_flush - 1
		local next_time_flush = TimeUtil.FormatSecond(self.next_time_flush - 1)
		self.node_list["TxtTime"].text.text = string.format(Language.MapFind.FlushTime, next_time_flush)
	end)
	self.node_list["TxtBtnFlush"]:SetActive(not self.in_rush)
	self.node_list["TxtBtnFushDelete"]:SetActive(self.in_rush)
	self:ShowView()
end

function MapFindView:ShowView()
	self.node_list["TxtCount"]:SetActive(self.free_times ~= 0)
	self.node_list["TxtImg2"]:SetActive(self.free_times == 0)
	if self.free_times == 0 then
		self.node_list["TxtImg3"].text.text = string.format(Language.MapFind.FindSpend, MapFindData.Instance:GetMapFindSpend())
	else
		self.node_list["TxtCount"].text.text = string.format(Language.MapFind.FreeTime, self.free_times)
	end

	for i = 1, 3 do
		if MapFindData.Instance:GetActiveFlag(i) == 1 then
			UI:SetGraphicGrey(self.node_list["Note" .. i],false)
			else
			UI:SetGraphicGrey(self.node_list["Note" .. i],true)
		end
		-- UI:SetGraphicGrey(self.node_list["Note" .. i], MapFindData.Instance:GetActiveFlag(i) == 1)
	end
	if MapFindData.Instance:GetActiveFlag(3) == 1 then
		self.reward_item:ShowSpecialEffect(true)
		local bunble, asset = ResPath.GetItemActivityEffect()
		self.reward_item:SetSpecialEffect(bunble, asset)
	else
		self.reward_item:ShowSpecialEffect(false)
	end
end

function MapFindView:SetSlider()
	self.flush_items_data = MapFindData.Instance:GetFlushDataByOpenday()
	local data = MapFindData.Instance
	local flush_times = data:GetFlushTimes()
	local length = 20
	local total_length = 140
	local fill_length = 0
	local last_count = 0
	for k, v in pairs(self.flush_items_data) do
		if flush_times < v.need_flush_count then
			fill_length = (flush_times - last_count) / (v. need_flush_count - last_count) * length + fill_length
			break
		else
			last_count = v.need_flush_count
			fill_length = fill_length + length
		end
	end
	if flush_times > self.flush_items_data[#self.flush_items_data].need_flush_count then
		fill_length = (flush_times - last_count) / (1.1 * last_count) * length + fill_length
	end

	self.node_list["Progress"].slider.value = (fill_length / total_length)
	self.node_list["SliderNumber"].text.text = ToColorStr(flush_times, TEXT_COLOR.GREEN)
end


function MapFindView:FlushDataView()
	self.flush_items_data = MapFindData.Instance:GetFlushDataByOpenday()
	self:SetFlushDataView()
end

function MapFindView:SetFlushDataView()
	local flush_times = MapFindData.Instance:GetFlushTimes()
	for i, v in ipairs(self.flush_item) do
		v:SetData(self.flush_items_data[i])
		if flush_times >= self.flush_items_data[i].need_flush_count then
			v:ShowView(true)
		else
			v:ShowView(false)
		end
	end
end


-------------------------地图奖励-----------
MapRewardItem = MapRewardItem or BaseClass(BaseCell)

function MapRewardItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.node_list["Item"])
end

function MapRewardItem:__delete()
	self.item:DeleteMe()
	self.item = nil
end

function MapRewardItem:SetData(day_range)
	local data_index = self:GetIndex()
	local data = MapFindData.Instance:GetMapCampDataByDayRange(data_index + 1)

	for i = 1, 3 do
		local bundle, asset = ResPath.GetMapImg(data["city_" .. i])
		self.node_list["GameObject" .. i].image:LoadSprite(bundle, asset .. ".png", function() 
				self.node_list["GameObject" .. i].image:SetNativeSize()
				end)
		self.node_list["Txt" .. i].text.text = MapFindData.Instance:GetNameById(data["city_" .. i])
	end

	self.item:SetData(data.reward_item)
end


----------------------------地图累刷------------

MapFlushItem = MapFlushItem or BaseClass(BaseRender)

function MapFlushItem:__init()
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self.root_node)

	self.is_show_eff = false
	self.is_have_got = false

	self.node_list["BtnCanget"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function MapFlushItem:__delete()
	self.item:DeleteMe()
end

function MapFlushItem:SetData(data)
	self.reward_item = data.reward_item
	self.item:SetData(data.reward_item)
	self.item.root_node.transform:SetSiblingIndex(0)
	-- self.node_list["Text"].text.text = string.format("/%s", data.need_flush_count)
	self.index = data.index
	-- local width = self.root_node.transform.parent.rect.width
	-- local pos_x = (data.need_flush_count / MapFindFlushSlideMaxNumber) * width
	-- local pos = self.root_node.rect.anchoredPosition3D
	-- pos.x = pos_x
	-- self.root_node.rect.anchoredPosition3D = pos
end

function MapFlushItem:ShowView(show_eff)
	self:SetShowEff(show_eff)
	if MapFindData.Instance:GotReward(self.index) == 1 then
		self:SetShowEff(false)
		self:ShowHaveGot(true)
		self.item:ClearItemEvent()
	else
		self:ShowHaveGot(false)
		local click_func = nil
		if show_eff then
			click_func = function()
				self.item:SetHighLight(false)
				MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FETCH_RETURN_REWARD, self.index)
				AudioService.Instance:PlayRewardAudio()
			end
		else
			click_func = function()
				TipsCtrl.Instance:OpenItem(self.reward_item)
				self.item:SetHighLight(false)
			end
		end
		self.item:ListenClick(click_func)
	end
end

function MapFlushItem:OnClickGet()
	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FETCH_RETURN_REWARD, self.index)
end

function MapFlushItem:SetShowEff(is_show)
	self.is_show_eff = is_show
	-- self.node_list["Image3"]:SetActive(self.is_show_eff)
	-- self.node_list["Text"]:SetActive((not self.is_show_eff) and not self.is_have_got)
	self.node_list["Image"]:SetActive(self.is_show_eff)
	-- self.node_list["Text1"]:SetActive(self.is_show_eff)
	-- self.node_list["Text2"]:SetActive((not self.is_show_eff) and not self.is_have_got)
	self.node_list["BtnCanget"]:SetActive(self.is_show_eff)
end

function MapFlushItem:ShowHaveGot(is_show)
	self.is_have_got = is_show
	-- self.node_list["Text"]:SetActive(not self.is_show_eff and not self.is_have_got)
	self.node_list["Image2"]:SetActive(self.is_have_got)
	-- self.node_list["Text2"]:SetActive(not self.is_show_eff and not self.is_have_got)
	self.node_list["Image1"]:SetActive(self.is_have_got)
end

------------------------寻找奖励
FindItem = FindItem or BaseClass(BaseRender)

function FindItem:__init(instance, parent)
	self.parent = parent
	self.index = 0
	self.node_list["Img3"].button:AddClickListener(BindTool.Bind(self.ClickFind, self))
end

function FindItem:__delete()
	self.parent = nil
end

function FindItem:SetData(data)
	local route_info = MapFindData.Instance:GetRouteInfo()
	if route_info then
		self.index = route_info.city_list[data]
		local bundle, asset = ResPath.GetMapImg(route_info.city_list[data])
		self.node_list["Img"].image:LoadSprite(bundle, asset .. ".png", function() 
				self.node_list["Img"].image:SetNativeSize()
				end)
		self.node_list["Text"].text.text = MapFindData.Instance:GetNameById(route_info.city_list[data])

		local reward_cfg = MapFindData.Instance:GetMapRewardCfg()
		for i = 1, #reward_cfg do
			local cur_select = MapFindData.Instance:GetSelect()
			if cur_select[i] then
				local temp = MapFindData.Instance:GetMapRewardData(cur_select[i])
				if temp == nil or MapFindData.Instance:GetNameById(route_info.city_list[data]) == temp.name then
					MapFindData.Instance.is_find = true
					MapFindCtrl.Instance:EndRush()
					break
				end
			end
		end

		local fetch = MapFindData.Instance:GetFetchFlag(data)
		UI:SetButtonEnabled(self.node_list["Img3"], fetch ~= 1)
		local is_rare = MapFindData.Instance:IsRareMap(self.index)

		local find_times = self.parent:GetFreeFindTime() or 0
		self.node_list["Effect"]:SetActive((find_times > 0 and fetch ~= 1) or (is_rare and fetch ~= 1))
	end
end

function FindItem:ClickFind()
	MapFindCtrl.Instance:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_HUNT, self.index)
end
