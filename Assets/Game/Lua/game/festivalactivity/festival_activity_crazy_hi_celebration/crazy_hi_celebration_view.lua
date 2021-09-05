-- 狂嗨庆典-CrazyHiCelebrationView
CrazyHiCelebrationView = CrazyHiCelebrationView or BaseClass(BaseRender)

local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_KUANG_HAI_QING_DIAN
function CrazyHiCelebrationView:__init()

	--左边奖励列表
	self.cell_list = {}
	self.left_list = self.node_list["LeftListView"]
	local left_list_delegate = self.left_list.list_simple_delegate
	left_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	left_list_delegate.CellRefreshDel = BindTool.Bind(self.RewardRefreshCell, self)
	--右边任务列表
	self.task_list = {}
	self.right_list = self.node_list["RightListView"]
	local right_list_delegate = self.right_list.list_simple_delegate
	right_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTaskNumberOfCells, self)
	right_list_delegate.CellRefreshDel = BindTool.Bind(self.TaskRefreshCell, self)

	self.node_list["BtnHelp"].button:AddClickListener(BindTool.Bind(self.OnClickHelp, self))
end

function CrazyHiCelebrationView:__delete()
	self.cell_list = nil
	self.task_list = nil

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CrazyHiCelebrationView:OpenCallBack()
	CrazyHiCelebrationCtrl.Instance:SendActivityInfoReq()
	self:Flush()
end

function CrazyHiCelebrationView:CloseCallBack()

end

--左边列表
function CrazyHiCelebrationView:FlushRewardInfo()
	self.left_reward_list = CrazyHiCelebrationData.Instance:GetTidyRewardInfoList()
end

function CrazyHiCelebrationView:GetNumberOfCells()
	return #self.left_reward_list or 0
end

function CrazyHiCelebrationView:RewardRefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.cell_list[cell]
	if cell_item == nil then
		cell_item = CrazyRewardCell.New(cell.gameObject)
		self.cell_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(self.left_reward_list[data_index])
end

--右边列表
function CrazyHiCelebrationView:GetRightListCfg()
	self.right_data_list = CrazyHiCelebrationData.Instance:GetCrazyHiCelebrationInfoList()
end

function CrazyHiCelebrationView:GetTaskNumberOfCells()
	return #self.right_data_list or 0
end

function CrazyHiCelebrationView:TaskRefreshCell(cell, data_index)
	data_index = data_index + 1
	local cell_item = self.task_list[cell]
	if cell_item == nil then
		cell_item = CrazyHiCelebrationCell.New(cell.gameObject)
		self.task_list[cell] = cell_item
	end
	cell_item:SetIndex(data_index)
	cell_item:SetData(self.right_data_list[data_index])
end


function CrazyHiCelebrationView:OnFlush()
	self:FlushRewardInfo()
	self:GetRightListCfg()
	self.right_list.scroller:RefreshAndReloadActiveCellViews(false)
	self.left_list.scroller:RefreshAndReloadActiveCellViews(false)
	self:FlushTime()
	local total_score = CrazyHiCelebrationData.Instance:GetCurrentScore()
	self.node_list["total_score"].text.text = string.format(Language.CrazyHiCelebration.TotalScore, total_score)
end

function CrazyHiCelebrationView:FlushTime()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(activity_type)
	local activity_end_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self:ClearTimeDelay(activity_end_time)
	self.count_down = CountDown.Instance:AddCountDown(activity_end_time, 1, function ()
		activity_end_time = activity_end_time - 1
	   self.node_list["CountDown"].text.text = string.format(Language.CrazyHiCelebration.ShengYuTime, TimeUtil.FormatSecond(activity_end_time, 10))
	end)
end

-- 用于取消计时器延迟1s显示
function CrazyHiCelebrationView:ClearTimeDelay(activity_end_time)
	activity_end_time = activity_end_time - 1
	self.node_list["CountDown"].text.text = string.format(Language.CrazyHiCelebration.ShengYuTime, TimeUtil.FormatSecond(activity_end_time, 10))
end

function CrazyHiCelebrationView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(326)
end

-------------------------CrazyRewardCell-----------------------------------
-- CrazyHiCelebrationRewardItem
CrazyRewardCell = CrazyRewardCell or BaseClass(BaseCell)

function CrazyRewardCell:__init()
	self.reward_item_list = {}
	for i = 1, 4 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self.node_list["item_" .. i])
	end
	self.node_list["show_fetch_button"].button:AddClickListener(BindTool.Bind(self.OnClickGet, self))
end

function CrazyRewardCell:__delete()
end

function CrazyRewardCell:SetData(data)
	self.data = data
	if self.data == nil then return end
	self.node_list["TextNeed_score"].text.text = string.format(Language.CrazyHiCelebration.ActivityTips, self.data.need_score or 0)
	--奖励
	for i = 1, 4 do
		if self.data.reward_item[i - 1] ~= nil then
			self.reward_item_list[i]:SetParentActive(true)
			self.reward_item_list[i]:SetData(self.data.reward_item[i - 1])
		else
			self.reward_item_list[i]:SetParentActive(false)
		end
	end
	--红点
	self.node_list["show_red_point"]:SetActive(self.data.can_fetch_flag == 1 and self.data.had_fetch_flag == 0)
	--按钮
	-- self.node_list["can_fetch_reward"]:SetActive(self.data.can_fetch_flag == 0 and self.data.had_fetch_flag == 0)
	self.node_list["had_fetch_reward"]:SetActive(self.data.had_fetch_flag == 1)
	self.node_list["show_fetch_button"]:SetActive(self.data.had_fetch_flag ~= 1)
	self.node_list["Text"].text.text = self.data.can_fetch_flag ~= 0 and Language.Common.LingQu or Language.Common.WEIDACHENG
	UI:SetButtonEnabled(self.node_list["show_fetch_button"], self.data.can_fetch_flag ~= 0)
end

function CrazyRewardCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_KUANG_HAI_OPERA_TYPE.RA_KUANG_HAI_OPERA_TYPE_FETCH_REWARD, self.data.reward_seq)
end

-------------------------CrazyHiCelebrationCell-----------------------------------
-- CrazyHiCelebrationPointItem
CrazyHiCelebrationCell = CrazyHiCelebrationCell or BaseClass(BaseCell)
function CrazyHiCelebrationCell:__init()
	self.node_list["FetchButton "].button:AddClickListener(BindTool.Bind(self.OnClickGoto, self))
end

function CrazyHiCelebrationCell:__delete()
end

function CrazyHiCelebrationCell:SetData(data)
	self.data = data
	if self.data == nil then return end
	local desc_str_1 = self.data.task_desc or ""
	local desc_str_2 = ""
	local get_score = self.data.score or 0
	local max_score = self.data.max_score or 0
	if get_score < max_score then
		desc_str_2 = string.format("%s / %s", ToColorStr(get_score, TEXT_COLOR.RED), max_score)
	else
		desc_str_2 = string.format("%s / %s", get_score, max_score)
	end
	
	self.node_list["details"].text.text = string.format(Language.CrazyHiCelebration.TaskDesc, desc_str_1, desc_str_2) or ""
	local is_complete = self.data.score == self.data.max_score
	self.node_list["FetchButton "]:SetActive(not is_complete)
	self.node_list["IconComplete"]:SetActive(is_complete)
end

function CrazyHiCelebrationCell:OnFlush()

end

function CrazyHiCelebrationCell:OnClickGoto()
	if nil == self.data then return end
	if self.data.open_param ~= "" then
		--仙盟任务
		if self.data.open_param == "GuildTask" then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo and vo.guild_id <= 0 then
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
				return
			end
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.FestivalView)
			return
		--经验任务
		elseif self.data.open_param == "DailyTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			print("task_id:  "..task_id)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.CrazyHiCelebration.NotDailyTask)
				return
			end
			TaskCtrl.Instance:AutoDoTaskState(true)
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.FestivalView)
			return
		--护送仙女
		elseif self.data.open_param == "HuSong" then
			ViewManager.Instance:Close(ViewName.FestivalView)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		--竞技场
		elseif self.data.open_param == "ArenaActivityView" then
			ViewManager.Instance:Close(ViewName.FestivalView)
			ViewManager.Instance:Open(ViewName.ArenaActivityView)
			return
		--跨服六界
		elseif self.data.open_param == "KF_GUILDBATTLE" then
			ViewManager.Instance:Close(ViewName.FestivalView)
			ViewManager.Instance:Open(ViewName.KuaFuBattle)
			return
		elseif self.data.open_param == "treasure" then
			ViewManager.Instance:Close(ViewName.FestivalView)
			ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
			return
		elseif self.data.open_param == "Login" then
			TipsCtrl.Instance:ShowSystemMsg(Language.CrazyHiCelebration.HadLogin)
			return
		elseif self.data.open_param == "MojingTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.HUAN)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.CrazyHiCelebration.NotMoJingTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.FestivalView)
			return
		end
		local t = Split(self.data.open_param, "#")
		local view_name = t[1]
		local tab_index = t[2]
		--版本活动
		if view_name == "FestivalView" then
			if tab_index == "ErnieActivity" then
				if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2) then
					local panel_index = FestivalActivityData.Instance:GetActivityTypeToIndex(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2)
					ViewManager.Instance:Open(ViewName.FestivalView, panel_index)
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.CrazyHiCelebration.ErineActivity)
				end
				return
			elseif tab_index == "ExpenseNiceGift" then
				if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT) then
					local panel_index = FestivalActivityData.Instance:GetActivityTypeToIndex(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT)
					ViewManager.Instance:Open(ViewName.FestivalView, panel_index)
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.CrazyHiCelebration.ActivityNotOpen)
				end
				return
			end
		end
		ViewManager.Instance:Close(ViewName.FestivalView)
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			if tab_index == "KF_TUANZHAN" then
				ViewManager.Instance:Close(ViewName.FestivalView)
				ViewManager.Instance:Open(ViewName.KuaFuBattle, TabIndex.activity_tuanzhan)
				return
			else
				ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
				return
			end
		elseif view_name == "EnterScene" then
			GuajiCtrl.Instance:MoveToScene(tonumber(tab_index))
			return
		--充值任务
		elseif view_name == "VipView" then
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
			ViewManager.Instance:Open(ViewName.VipView)
			return
		elseif view_name == "EnterAct" then
			local scene_type = Scene.Instance:GetSceneType()
			if scene_type ~= SceneType.Common or GuajiCtrl.Instance:IsSpecialCommonScene() then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
				return
			end
			ActivityCtrl.Instance:SendActivityEnterReq(tab_index, 0)
			return
		end
		ViewManager.Instance:Open(view_name, TabIndex[tab_index])
	end
end