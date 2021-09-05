TreasureBowlView = TreasureBowlView or BaseClass(BaseView)

function TreasureBowlView:__init()
	self.ui_config = {{"uis/views/treasurebowlview_prefab", "TreasureBowlView"}}
end

function TreasureBowlView:ReleaseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
end

function TreasureBowlView:Timer()
	time_list = Language.Common.TimeList
	--发奖励剩余时间
	self.reward_left_sec = self.reward_left_sec - 1
	local h, m, s = WelfareData.Instance:TimeFormat(self.reward_left_sec)
	self.node_list["TXtRight"].text.text = string.format(Language.TreasureBowl.RewardTips, h .. time_list.h .. m .. time_list.min)
	--活动剩余时间
	self.activity_left_sec = self.activity_left_sec - 1
	local day, hour = WelfareData.Instance:TimeFormatWithDay(self.activity_left_sec)
	self.node_list["TxtTopTips"].text.text = string.format(Language.TreasureBowl.FlushTips, day .. time_list.d .. hour .. time_list.h)
end

function TreasureBowlView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.OnClosen, self))
	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.SetHelpPlaneVisibel, self))
	self.node_list["Btn01"].button:AddClickListener(BindTool.Bind(self.UseMoneyClick, self))

	self.reward_list = {}
	local obj_group = self.node_list["ObjGroup"]
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "RewardBox") ~= nil then
			self.reward_list[count] = TreasureBowlRewardBox.New(obj)
			count = count + 1
		end
	end

	local box_data = TreasureBowlData.Instance:GetTotalJuBaoRewardInfo()
	for i = 1, #self.reward_list do
		self.reward_list[i]:SetData(box_data[i])
	end

	self:InitScroller()
	self:Flush()

	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	--本日0点开始已经过了多少秒
	local today_pass_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	--本日结束还剩多少秒
	self.reward_left_sec = 86400 - today_pass_time
	--活动结束还剩多少秒
	local left_days_sec = TreasureBowlData.Instance:GetActivityLeftDays() * 86400
	self.activity_left_sec = self.reward_left_sec + left_days_sec
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
end

function TreasureBowlView:OnClosen()
	self:Close()
end

function TreasureBowlView:SetHelpPlaneVisibel(is_show)
	TipsCtrl.Instance:ShowHelpTipView(Language.TreasureBowl.Tips)
end

function TreasureBowlView:UseMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TreasureBowlView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2154, 0, 0, 0)
end

function TreasureBowlView:InitScroller()
	self.cell_list = {}
	self.scroller_data = TreasureBowlData.Instance:GetTaskScrollerData()

	local delegate = self.node_list["Scroller"].list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = TreasureBowlScrollerCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.scroller_data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

function TreasureBowlView:Flush()
	if not self:IsLoaded() then
		return
	end
	local data = TreasureBowlData.Instance:GetTreasureBowlInfo()
	if data == nil then
		return
	end
	local diamond_percent = TreasureBowlData.Instance:GetDiamondPercent()
	local max_total_jubao_value =  TreasureBowlData.Instance:GetMaxTotalJuBaoValue()
	local my_rechange = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local fanli = TreasureBowlData.Instance:GetChongzhiFanli()

	self.node_list["SliderProgress"].slider.value = data.total_cornucopia_value / max_total_jubao_value
	self.node_list["TxtChongzhi"].text.text = string.format(Language.TreasureBowl.TotalRecharge, data.total_cornucopia_value)
	self.node_list["TxtLayout"].text.text = string.format(Language.TreasureBowl.MyRecharge, my_rechange)
	self.node_list["TxtRewardDiamond"].text.text = string.format(Language.TreasureBowl.BindGoldAdd, diamond_percent)

	local the_reward_diamond = my_rechange * (fanli / 100 + diamond_percent / 100)
	self.node_list["TxtValue"].text.text = math.ceil(the_reward_diamond)

	self.node_list["Txt"].text.text = string.format(Language.TreasureBowl.Return, fanli)

	for k,v in pairs(self.reward_list) do
		v:OnFlush()
	end
end

function TreasureBowlView:OnSeverInfoChange()
	if not self:IsLoaded() then
		return
	end
	self:Flush()
	self.node_list["Scroller"].scroller:RefreshActiveCellViews()
end

---------------------------------------------------------------
--滚动条格子

TreasureBowlScrollerCell = TreasureBowlScrollerCell or BaseClass(BaseCell)

function TreasureBowlScrollerCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self.node_list["TBScrollerItem"].button:AddClickListener(BindTool.Bind(self.OnItemClick, self))
end

function TreasureBowlScrollerCell:__delete()

end

function TreasureBowlScrollerCell:OnFlush()
	UI:SetGraphicGrey(self.node_list["ImgIcon"], self.data.process_value >= self.data.task_value)

	local bundle, asset = "uis/views/baoju", self.data.icon_id
	self.node_list["ImgIcon"].image:LoadSprite(bundle, asset .. ".png")
	self.node_list["Txt"].text.text = self.data.description

	local text = ""
	if self.data.process_value >= self.data.task_value - 1 then
		text = self.data.process_value
	else
		text = ToColorStr(self.data.process_value, TEXT_COLOR.RED)
	end

	if self.data.data_index == 1 then
		self.node_list["TxtCount"].text.text = text .. " / " .. self.data.task_value - 1
	else
		self.node_list["TxtCount"].text.text = text .. " / " .. self.data.task_value
	end

	self.node_list["Txt2"].text.text = self.data.add_percent .. "%"
end

function TreasureBowlScrollerCell:OnItemClick()
	if self.data.data_index == TREASURE_BOWL_ITEM_TYPE.DAILY_TASK then
		local count = TaskData.Instance:GetTaskTotalCount(TASK_TYPE.RI) - YunbiaoData.Instance:GetHusongRemainTimes()
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
		if count == 0 or task_id == 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.TreasureBowl.DoneRemind)
			return
		end
		if task_id > 0 then
			TaskCtrl.Instance:DoTask(task_id)
			TreasureBowlCtrl.Instance:CloseView()
		end
	elseif self.data.data_index == TREASURE_BOWL_ITEM_TYPE.GUILD_TASK then
		local guild_task = TaskData.Instance:GetNextGuildTaskConfig()
		if guild_task then
			local task_cfg = TaskData.Instance:GetTaskConfig(guild_task.task_id)
			local level = GameVoManager.Instance:GetMainRoleVo().level
			if task_cfg.min_level > level or task_cfg.max_level < level then
				TipsCtrl.Instance:ShowSystemMsg(Language.TreasureBowl.LevelRemind)
				return
			else
				TaskCtrl.Instance:DoTask(guild_task.task_id)
				TreasureBowlCtrl.Instance:CloseView()
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.TreasureBowl.TaskRemind)
		end
	elseif self.data.data_index == TREASURE_BOWL_ITEM_TYPE.HUSONG then
		GuajiCtrl.Instance:MoveToNpc(400, nil, 103)
		TreasureBowlCtrl.Instance:CloseView()
	else
		local view_list = TreasureBowlData.Instance:GetOpenViewName(self.data.data_index)
		ViewManager.Instance:Open(view_list.view_name, view_list.tab_index)
		TreasureBowlCtrl.Instance:CloseView()
	end
end
---------------------------------------------------------------
--奖励箱子格子
TreasureBowlRewardBox = TreasureBowlRewardBox or BaseClass(BaseCell)

function TreasureBowlRewardBox:__init()
	self.node_list["BtnRewardBox"].button:AddClickListener(BindTool.Bind(self.OnClick, self))
end

function TreasureBowlRewardBox:__delete()

end

function TreasureBowlRewardBox:OnFlush()
	if self.data == nil then
		return
	end

	self.node_list["ImgBoxNormal"]:SetActive(not self.data.have_got)
	self.node_list["ImgBoxOpen"]:SetActive(self.data.have_got)
	self.node_list["ImgCanGetEff"]:SetActive(self.data.can_get and (not self.data.have_got))

	self.node_list["Txt"].text.text = string.format(Language.TreasureBowl.ServerAll, self.data.cornucopia_value)

	UI:SetGraphicGrey(self.node_list["ImgBoxNormal"], self.data.can_get)
	self.node_list["ImgCanGetEff"]:SetActive(self.data.can_get and (not self.data.have_got))
end

function TreasureBowlRewardBox:OnClick()
	if self.data.can_get and not self.data.have_got then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_CORNUCOPIA, 1, self.data.seq)
	end
end