ExtremeChallengeView = ExtremeChallengeView or BaseClass(BaseRender)

function ExtremeChallengeView:__init()
	self.cell_list = {}
	local list_delegate = self.node_list["ListView"].list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.final_reward_item_list = {}
	for i=1,2 do
		self.final_reward_item_list[i] = ItemCell.New()
		self.final_reward_item_list[i]:SetInstanceParent(self.node_list["ItemCell".. i])
	end
	self.node_list["Button"].button:AddClickListener(BindTool.Bind(self.OnClcikFinalReward, self))
	self.node_list["QuestionBtn"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function ExtremeChallengeView:__delete()
	self.cell_list = nil

	for k, v in pairs(self.final_reward_item_list) do
		v:DeleteMe()
	end
	self.final_reward_item_list = {}

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ExtremeChallengeView:OpenCallBack()
	ExtremeChallengeCtrl.Instance:SendExtremeChallengeInfo()
	self.is_first = true
	self:Flush()
end

function ExtremeChallengeView:CloseCallBack()

end

function ExtremeChallengeView:GetNumberOfCells()
	local count = ExtremeChallengeData.Instance:GetTaskCount() or 0
	return count
end

function ExtremeChallengeView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = ExtremeChallengeCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	local data_list = ExtremeChallengeData.Instance:GetTaskInfoList()
	cell_item:SetIndex(data_index)
	local data = data_list[data_index]
	cell_item:SetData(data_list[data_index], data_index)
end

function ExtremeChallengeView:OnFlush()
	self.node_list["ListView"].scroller:RefreshAndReloadActiveCellViews(false)
	self:FlushBottomInfo()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function ExtremeChallengeView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_tab = TimeUtil.Format2TableDHMS(time)

	local time_str = nil
	if time_tab.day >= 1 then
		time_str = string.format(Language.Activity.ActivityTime8, time_tab.day, time_tab.hour)
	else
		time_str = string.format(Language.Activity.ActivityTime9, time_tab.hour, time_tab.min, time_tab.s)
	end
	self.node_list["Time"].text.text = time_str

end



function ExtremeChallengeView:FlushBottomInfo()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	if nil == cfg then
		return
	end
	local final_reward = cfg.extreme_challenge_finish_all_task_reward
	for i = 1, 2 do
		if final_reward[i - 1] ~= nil then
			self.final_reward_item_list[i]:SetParentActive(true)
			self.final_reward_item_list[i]:SetData(final_reward[i - 1])
		else
			self.final_reward_item_list[i]:SetParentActive(false)
		end
	end
	local total_task_num = ExtremeChallengeData.Instance:GetTaskCount() or 0
	local complete_task_num = ExtremeChallengeData.Instance:GetCompleteTaskNum() or 0
	local text_str = ""
	if complete_task_num == total_task_num then
		text_str = string.format("%s / %s", ToColorStr(complete_task_num, TEXT_COLOR.GREEN_4), total_task_num)
	else
		text_str = string.format("%s / %s", ToColorStr(complete_task_num, TEXT_COLOR.RED), total_task_num)
	end
	self.node_list["TaskTxt"].text.text =  text_str
	local had_fetch_flag = ExtremeChallengeData.Instance:GetFetchUltimateRewardFlag()
	local is_Active_Btn = total_task_num == complete_task_num and had_fetch_flag == 0
	-- UI:SetGraphicGrey(self.node_list["Button"], not (is_Active_Btn))
	UI:SetButtonEnabled(self.node_list["Button"], is_Active_Btn)
	UI:SetGraphicGrey(self.node_list["BtnTxt"], not (is_Active_Btn))
	self.node_list["RedPoint"]:SetActive(is_Active_Btn)

	local btn_text = ""
	if had_fetch_flag == 0 then
		btn_text = Language.ExtremeChallenge.Fetch
		self.node_list["BtnTxt"].text.text = btn_text
	elseif had_fetch_flag ~= nil then
		btn_text = Language.ExtremeChallenge.HadFetch
		self.node_list["BtnTxt"].text.text = btn_text
	end
end

function ExtremeChallengeView:OnClcikFinalReward()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, EXTREMECHALLENGE.EXTREMECHALLENGE_FETCH_ULTIMATE_REWARD)
end

function ExtremeChallengeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(285)
end

-------------------------ExtremeChallengeCell-----------------------------------
ExtremeChallengeCell = ExtremeChallengeCell or BaseClass(BaseCell)

function ExtremeChallengeCell:__init()
	self.reward_item_list = {}
	for i=1,2 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["ItemCell"..i])
	end

	self.node_list["FetchButton"].button:AddClickListener(BindTool.Bind(self.OnClickFetch, self))
	self.node_list["FlushButton"].button:AddClickListener(BindTool.Bind(self.OnClickFlush, self))
end

function ExtremeChallengeCell:__delete()
	-- self.item_cell:DeleteMe()
end

function ExtremeChallengeCell:LoadCallBack(instance)
	self.node_list["Effet"]:SetActive(true)
end

function ExtremeChallengeCell:SetData(data,index)
	self.data = data
	if self.data == nil then 
		return 
	end
	local task_id = self.data.task_id
	local task_type = self.data.task_type
	local task_info = ExtremeChallengeData.Instance:GetRewardCfgByTaskId(task_id)
	if task_info == nil or next(task_info) == nil then 
		return 
	end
	local task_des = task_info.param1
	local task_plan = self.data.task_plan
	if task_type == 2 and task_info.param1 ~= nil and self.data.task_plan ~= nil then           --任务类型2 配置秒，显示小时
		task_des = math.floor(task_info.param1 / 3600)
		task_plan = math.floor(self.data.task_plan / 3600)
		-- self.node_list["TopImageText2"].text.text = task_info.task_description .. task_des .. Language.Common.Hour
	end
	self.node_list["TopImageText2"].text.text = string.format(task_info.task_description, task_des)
	local bundle, asset = ResPath.GetExtremeChallngeIndex(index)
	self.node_list["TopImage"].image:LoadSprite(bundle, asset)


	self.node_list["SliderNumber "].text.text = string.format("%s/%s", task_plan, task_des)
	--进度条 

	self.node_list["ProgressBG "].slider.value = task_plan / task_des
	-- if self.is_first then
	-- 	self.is_first = false
	-- 	self.prog_value:InitValue(task_plan / task_des)
	-- else
	-- 	self.prog_value:SetValue(task_plan / task_des)
	-- end
	--按钮状态 

	self.node_list["FlushButton"]:SetActive(self.data.is_finish == 0)
	self.node_list["FetchButton"]:SetActive(self.data.is_finish == 1 and self.data.is_already_fetch == 0)
	self.node_list["BottomImage"]:SetActive(self.data.is_finish == 1 and self.data.is_already_fetch == 1)
	--奖励
	for i = 1, 2 do
		if task_info.reward_item[i - 1] ~= nil then
			self.reward_item_list[i]:SetParentActive(true)
			self.reward_item_list[i]:SetData(task_info.reward_item[i - 1])
		else
			self.reward_item_list[i]:SetParentActive(false)
		end
	end
	--红点
	local red_point_flag = ExtremeChallengeData.Instance:GetRedPointStateByTaskId(self.data.task_id)
	self.node_list["FetchImage"]:SetActive(red_point_flag == 1)
end

function ExtremeChallengeCell:OnFlush()

end

function ExtremeChallengeCell:OnClickFetch()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, EXTREMECHALLENGE.EXTREMECHALLENGE_FETCH_REWARD,self.data.task_id)
end

function ExtremeChallengeCell:OnClickFlush()
	local need_gold = ExtremeChallengeData.Instance:GetFlushNeedGold() or 0
	local call_back = function()
		self.is_click_ok = true
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXTREME_CHALLENGE, EXTREMECHALLENGE.EXTREMECHALLENGE_REFRESH_TASK,self.data.task_id)
	end
	local tip_text = string.format(Language.ExtremeChallenge.FlushOnce, need_gold)
	TipsCtrl.Instance:ShowCommonAutoView("extreme_gold", tip_text, call_back, nil, nil, nil, nil, nil, true, true)
end