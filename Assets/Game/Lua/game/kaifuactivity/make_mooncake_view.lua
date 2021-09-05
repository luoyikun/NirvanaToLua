MakeMoonCakeView = MakeMoonCakeView or BaseClass(BaseRender)
-- 集月饼活动 单身伴侣
local MAX_MOOM_CAKE_TYPE = 5
function MakeMoonCakeView:__init(instance)
	self.activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAKE_MOONCAKE
	self.moon_data_list = {}
	self.select_index = 1

	self.cell_list = {}
	-- self.list_delegate = self.node_list["ListView"].list_simple_delegate
	self.list = self.node_list["ListView"]
	self.list_delegate = self.list.list_simple_delegate
	self.list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.item_list = {}
	self.text_list = {}
	for i = 1, 4 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self.node_list["Item" .. i])
		self.text_list[i] = self.node_list["Text"..i]
	end
	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self.node_list["RewardItem"])

	self.node_list["GetButton"].button:AddClickListener(BindTool.Bind(self.OnClickMake, self))
	self.node_list["GetMaterialsButton"].button:AddClickListener(BindTool.Bind(self.ClickYeWaiGuaJi, self))
end

function MakeMoonCakeView:__delete()
	self.activity_type = nil
	self.moon_data_list = nil
	self.list = nil
	self.list_delegate = nil

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	-- if self.count_down then
 --        CountDown.Instance:RemoveCountDown(self.count_down)
 --        self.count_down = nil
 --    end
end

function MakeMoonCakeView:OpenCallBack()
	self.select_index = 1

	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(self.activity_type)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
	end)
	self:Flush()

end

function MakeMoonCakeView:CloseCallBack()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

end

function MakeMoonCakeView:SetTime(rest_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" and k ~= "hour" then
	-- 		if v < 10 then
	-- 			v = tostring('0'..v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end
	-- local str = ""
	-- if temp.day > 0 then
	-- 	str = string.format(Language.Activity.ActivityTime13, temp.day, temp.hour)
	-- else
	-- 	str = string.format(Language.Activity.ActivityTime12, temp.hour, temp.min,temp.s)
	-- end
	str = TimeUtil.FormatSecond(rest_time, 10)
	self.node_list["CountDownTime"].text.text = str
end

function MakeMoonCakeView:GetNumberOfCells()
	local count = 0
	count = #self.moon_data_list 
	return count
end

function MakeMoonCakeView:RefreshCell(cell, data_index)
	local data_list = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection_2
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = MoonCakeItem.New(cell.gameObject)
		cell_item:SetToggleGroup(self.list.toggle_group)
		cell_item:SetClickCallBack(BindTool.Bind(self.OnChooseMoonType, self))
		self.cell_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(data_list[data_index])
	cell_item:SetHighLight(data_index == self.select_index)
end

function MakeMoonCakeView:GetMoonCakeDataList()
	self.moon_data_list = PlayerData.Instance:GetCurrentRandActivityConfig().item_collection_2
end

--选择月饼类型
function MakeMoonCakeView:OnChooseMoonType(cell)
	if cell == nil then return end

	local index = cell:GetIndex()
	if index == self.select_index then return end
	self.select_index = index
	self:FlushMoonCakeItem()
	self:FlushAllHightLight()
	self:SetRedPoint()
end

function MakeMoonCakeView:FlushAllHightLight()
	for k,v in pairs(self.cell_list) do
		local index = v:GetIndex()
		v:SetHighLight(index == self.select_index)
	end
end

--制作按钮
function MakeMoonCakeView:OnClickMake()
	local index = self.moon_data_list[self.select_index].seq
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.activity_type, RA_ITEM_COLLECTION_SECOND_OPERA_TYPE.RA_ITEM_COLLECTION_SECOND_OPERA_TYPE_EXCHANGE, index)
end

function MakeMoonCakeView:OnFlush(param_t)
	self.list.scroller:RefreshAndReloadActiveCellViews(false)
	for k,v in pairs(param_t) do
		if k ~= "make_moon_cake" then
			-- self.select_index = 1
			self:FlushAllHightLight()
		end
	end
	self:GetMoonCakeDataList()
	self:FlushMoonCakeItem()
	self:SetRedPoint()

	-- 刷新倒计时
	-- local activity_end_time = FestivalActivityData.Instance:GetActivityActTimeLeftById(self.activity_type)
 --    if self.count_down then
 --        CountDown.Instance:RemoveCountDown(self.count_down)
 --        self.count_down = nil
 --    end

 --    self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
 --        activity_end_time = activity_end_time - 1
 --        self.node_list["CountDownTime"].text.text = TimeUtil.FormatBySituation(activity_end_time)
 --    end)

    self:FlushRedPoint()
end

function MakeMoonCakeView:FlushMoonCakeItem()
	if next(self.moon_data_list) ~= nil then
		local data = self.moon_data_list[self.select_index]
		if data == nil then return end
		local time_t = KaifuActivityData.Instance:GetCollectMoonExchangeInfo()
		local times = time_t[data.seq + 1] or 0
		local count = math.max(data.exchange_times_limit  - times, 0)
		self.node_list["ExchangeCount"].text.text = string.format(Language.Common.ExchangeTimes, count)
		self.node_list["ShowItem2"]:SetActive(true)
		self.node_list["ShowItemImage2"]:SetActive(true)
		self.node_list["ShowItem3"]:SetActive(true)
		self.node_list["ShowItemImage3"]:SetActive(true)
		self.node_list["ShowItem4"]:SetActive(true)
		self.node_list["ShowItemImage4"]:SetActive(true)

		self.reward_item:SetData(data.reward_item)
		self.reward_item:IsDestoryActivityEffect(data.item_special == 0)
		self.reward_item:SetActivityEffect()
		local can_reward = true
		local index = 1
		local text_str = ""
		local stuff_id = "stuff_id"
		for i = 1, 4 do
			if data[stuff_id .. i] and data[stuff_id .. i].item_id > 0 and self.item_list[index] then
				local num = ItemData.Instance:GetItemNumInBagById(data[stuff_id .. i].item_id)
				if num < data[stuff_id .. i].num then
					can_reward = false
				end
				self.item_list[index]:SetData({item_id = data[stuff_id .. i].item_id})					
				if num >= data[stuff_id..i].num then
					text_str = string.format("%s / %s", ToColorStr(num, TEXT_COLOR.GREEN_4), data[stuff_id..i].num)
				else
					text_str = string.format("%s / %s", ToColorStr(num, TEXT_COLOR.RED), data[stuff_id..i].num)
				end
				self.text_list[index].text.text = text_str
				index = index + 1
			end
		end
		if index <= 4 then
			for i = index, 4 do
				if self.node_list["ShowItem" .. i] then
					self.node_list["ShowItem" .. i]:SetActive(false)
					self.node_list["ShowItemImage" .. i]:SetActive(false)
				end
			end
		end
		UI:SetButtonEnabled(self.node_list["GetButton"], can_reward)

		-- self.node_list["ExchangeBtnEnble2"]:SetActive(can_reward)
	end
end

function MakeMoonCakeView:FlushRedPoint()
	self:FlushMoonCakeItem()
	self.list.scroller:RefreshAndReloadActiveCellViews(false)
	self:SetRedPoint()
end

function MakeMoonCakeView:SetRedPoint()
	local index = self.select_index - 1
	local can_get = KaifuActivityData.Instance:SingleMakeMoonCakeRedPoint(index)
	self.node_list["ShowRedPoint"]:SetActive(can_get)
end

function MakeMoonCakeView:ClickYeWaiGuaJi()
	local ok_fun = function ()
		local guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex()
		local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(guaiwuIndex)
		YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
	end

	local des = Language.DanShenBanNv.HuoDe
	TipsCtrl.Instance:ShowCommonAutoView("guaji", des, ok_fun, nil, nil, nil, nil, nil, nil, true, false)
	-- ViewManager.Instance:Open(ViewName.YewaiGuajiView)
end

--------------------MoonCakeItem--------------------------------------
MoonCakeItem = MoonCakeItem or BaseClass(BaseCell)

function MoonCakeItem:__init(instance)

	self.node_list["onclick"].toggle:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function MoonCakeItem:__delete()

end

function MoonCakeItem:SetData(data)
	if data == nil then return end
	-- local str_type = FestivalActivityData.Instance:GetBgCfg()
	-- self.node_list["image"].image:LoadSprite(ResPath.GetMoonCakeTypeImage(str_type.str_type, data.item_id))
	-- self.node_list["name"].image:LoadSprite(ResPath.GetMoonCakeTypeName(str_type.str_type, data.reward_name_id))
	local bundle, asset = ResPath.GetMoonCakeTypeImage(data.item_id)
	self.node_list["image"].image:LoadSprite(bundle, asset, function()
		self.node_list["image"].image:SetNativeSize()
	end)
    local bundle_1, asset_1 = ResPath.GetMoonCakeTypeName(data.reward_name_id)
    self.node_list["name"].image:LoadSprite(bundle_1, asset_1, function()
		self.node_list["name"].image:SetNativeSize()
	end)

	local can_get = KaifuActivityData.Instance:SingleMakeMoonCakeRedPoint(data.seq)
	self.node_list["ShowRedPoint"]:SetActive(can_get)
end

function MoonCakeItem:OnFlush()

end

function MoonCakeItem:OnClick(handler)
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function MoonCakeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MoonCakeItem:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end