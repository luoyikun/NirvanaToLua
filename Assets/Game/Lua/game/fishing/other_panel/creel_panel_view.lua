-- 鱼篓面板
CreelPanelView = CreelPanelView or BaseClass(BaseView)

function CreelPanelView:__init()
	self.ui_config = {
		{"uis/views/fishing_prefab", "TopCreelPanel"}
	}
	self.view_layer = UiLayer.MainUILow
	self.is_modal = true
	self.open_tween = UITween.ShowFadeUp
	self.close_tween = UITween.HideFadeUp
end

function CreelPanelView:__delete()

end

function CreelPanelView:ReleaseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.fishing_creel_cell_list then
		for k,v in pairs(self.fishing_creel_cell_list) do
			v:DeleteMe()
		end
	end
	self.fishing_creel_cell_list = nil

	if self.fishing_creel_log_cell_list then
		for k,v in pairs(self.fishing_creel_log_cell_list) do
			v:DeleteMe()
		end
	end
	self.fishing_creel_log_cell_list = nil
	self.creel_listview_data = nil
end

function CreelPanelView:LoadCallBack()
		-- 列表生成滚动条
	self.fishing_creel_cell_list = {}
	self.creel_listview_data = {}
	local creel_list_delegate = self.node_list["CreelListView"].list_simple_delegate
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))


	creel_list_delegate.NumberOfCellsDel = function()
		return #self.creel_listview_data or 0
	end
	creel_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingCreelListView, self)

	-- 列表生成日志滚动条
	self.fishing_creel_log_cell_list = {}
	self.creel_log_listview_data = {}
	local creel_log_list_delegate = self.node_list["CreelLogListView"].list_simple_delegate
	creel_log_list_delegate.NumberOfCellsDel = function()
		return #self.creel_log_listview_data or 0
	end
	creel_log_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingCreelLogListView, self)
	self:Flush()
	self:ShowIndexCallBack()
end

function CreelPanelView:CloseWindow()
	FishingCtrl.Instance:OnOpenCreelHandler()
	self:Close()
end

function CreelPanelView:OnFlush(param_list)

	--设置我的鱼篓
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT - 1 do
		if self.node_list["TxtFish" .. i] then
			self.node_list["TxtFish" .. i].text.text = CrossFishingData.Instance:GetFishingUserInfo().fish_num_list[i + 1]
		end
	end

	-- 设置list数据
	local combination_cfg = TableCopy(CrossFishingData.Instance:GetFishingCombinationCfg())
	table.insert(combination_cfg, 1, combination_cfg[0])
	combination_cfg[0] = nil
	self.creel_listview_data = combination_cfg
	if self.node_list["CreelListView"].scroller.isActiveAndEnabled then
		self.node_list["CreelListView"].scroller:ReloadData(0)
	end

	-- 设置日志list数据
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
	if fishing_user_info.news_list then
		self.creel_log_listview_data = fishing_user_info.news_list
		if self.node_list["CreelLogListView"].scroller.isActiveAndEnabled then
			self.node_list["CreelLogListView"].scroller:ReloadData(0)
		end
	end
end

function CreelPanelView:ShowIndexCallBack()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING)
	if activity_info then
		local diff_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
		self:SetActTime(diff_time)
	end
end

-- 活动倒计时
function CreelPanelView:SetActTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			self.node_list["TxtTime"].text.text = TimeUtil.FormatSecond2Str(left_time)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end


-- 列表listview
function CreelPanelView:RefreshFishingCreelListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local creel_cell = self.fishing_creel_cell_list[cell]
	if creel_cell == nil then
		creel_cell = FishingCreelPanelItemRender.New(cell.gameObject)
		self.fishing_creel_cell_list[cell] = creel_cell
	end
	creel_cell:SetIndex(data_index)
	creel_cell:SetData(self.creel_listview_data[data_index])
end

-- 日志列表listview
function CreelPanelView:RefreshFishingCreelLogListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local creel_log_cell = self.fishing_creel_log_cell_list[cell]
	if creel_log_cell == nil then
		creel_log_cell = FishingCreelLogItemRender.New(cell.gameObject)
		self.fishing_creel_log_cell_list[cell] = creel_log_cell
	end
	creel_log_cell:SetIndex(data_index)
	creel_log_cell:SetData(self.creel_log_listview_data[data_index])
end

----------------------------------------------------------------------------
--FishingCreelPanelItemRender	鱼篓itemder
----------------------------------------------------------------------------
FishingCreelPanelItemRender = FishingCreelPanelItemRender or BaseClass(BaseCell)
function FishingCreelPanelItemRender:__init()
	self.lbl_fish_num = {}

	self.fish = CrossFishingData.Instance:GetFishingFishCfg()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.node_list["BtnExchange"].button:AddClickListener(BindTool.Bind(self.OnBtnExchangeHandler, self))

	self.myfishing_num = {}
end

function FishingCreelPanelItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.fish = nil
	self.myfishing_num = nil
	self.lbl_fish_num = nil
end

function FishingCreelPanelItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	for i = 1, #self.fish do
		self.lbl_fish_num[i] = self.data["fish_type_" .. i]
	end
	if self.item_cell then
		self.item_cell:SetData(self.data.reward_item)
	end

	local can_reward = true
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT - 1 do
		local myfishing_num = CrossFishingData.Instance:GetFishingUserInfo().fish_num_list[i + 1]
		if self.data["fish_type_" .. i] and myfishing_num >= self.data["fish_type_" .. i]  then
			self.myfishing_num[i] = ToColorStr(myfishing_num, TEXT_COLOR.GREEN_4)
		else
			if nil ~= self.data["fish_type_" .. i] then
				can_reward = false
			end
			self.myfishing_num[i] = ToColorStr(myfishing_num, TEXT_COLOR.RED_4)
		end
	end
	for i = 1, #self.fish do
		self.lbl_fish_num[i] = self.data["fish_type_" .. i]
		self.node_list["Fish" .. i]:SetActive(self.lbl_fish_num[i] > 0)
		self.node_list["TxtFish" .. i].text.text = self.myfishing_num[i] .. " / " ..self.lbl_fish_num[i]
	end
	self.node_list["ImgRedPoint"]:SetActive(can_reward)
end

function FishingCreelPanelItemRender:OnBtnExchangeHandler()
	if not self.data or not next(self.data) then return end
	FishingCtrl.Instance:SendFishingExchange(self.data.index)
end

function  FishingCreelPanelItemRender:OnTimeHandler()
	CrossFishingData.Instance:SetCreelViewtime(1)
end

----------------------------------------------------------------------------
--FishingCreelLogItemRender	鱼篓日志itemder
----------------------------------------------------------------------------
FishingCreelLogItemRender = FishingCreelLogItemRender or BaseClass(BaseCell)
function FishingCreelLogItemRender:__init()

end

function FishingCreelLogItemRender:__delete()
end

function FishingCreelLogItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	if self.node_list["Text"] then
		local str = ""
		local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(self.data.fish_type)
		if fish_cfg then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local item_name = ToColorStr(fish_cfg.name, ITEM_COLOR[fish_cfg.color])
			if self.data.news_type == FISHING_NEWS_TYPE.FISHING_NEWS_TYPE_STEAL then
				-- if self.data.fish_type >= 4 then
				-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelStealXiYou, main_role_vo.name, self.data.user_name, fish_cfg.name))
				-- end
				str = string.format(Language.Fishing.LabelFishingSteal, self.data.user_name, item_name, self.data.fish_num)
			elseif self.data.news_type == FISHING_NEWS_TYPE.FISHING_NEWS_TYPE_BE_STEAL then
				-- if self.data.fish_type >= 4 then
				-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fishing.LabelStealXiYou, self.data.user_name, main_role_vo.name, fish_cfg.name))
				-- end
				str = string.format(Language.Fishing.LabelFishingBeSteal, self.data.user_name, item_name, self.data.fish_num)
			end
		end
		self.node_list["Text"].text.text = str
	end
end
