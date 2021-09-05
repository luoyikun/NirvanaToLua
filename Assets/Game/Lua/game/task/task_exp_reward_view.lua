local time = 8
TaskExpRewardView = TaskExpRewardView or BaseClass(BaseView)
function TaskExpRewardView:__init()
	self.ui_config = {
		{"uis/views/commonwidgets_prefab", "BaseThreePanel"},
		{"uis/views/taskview_prefab", "ExpTaskReward"}}
	self.is_modal = true
	-- self.is_any_click_close = true
	self.index = 0
	self.is_reach_vip = false
end

function TaskExpRewardView:__delete()

end

function TaskExpRewardView:ReleaseCallBack()
	self:RemoveTimer()

	if nil ~= self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil
	end
end

function TaskExpRewardView:LoadCallBack()
	self.node_list["BtnClose"].button:AddClickListener(BindTool.Bind(self.CloseWindow, self))
	self.node_list["Txt"].text.text = Language.Common.TaskStr
	self.node_list["Bg"].rect.sizeDelta = Vector3(622,400,0)
	self.node_list["Reward1"].button:AddClickListener(BindTool.Bind(self.OnReward, self, 1)) 		--单倍
	self.node_list["Reward2"].button:AddClickListener(BindTool.Bind(self.OnReward, self, 2))		--双倍
	self.node_list["SelectToggle"].toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))

	local exp_factor = TaskData.Instance:GetExpFactor(TASK_TYPE.RI)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local exp = PlayerData.Instance:GetFBExpByLevel(level) or 0
	exp = exp * exp_factor
	self.reward_cell = ItemCell.New()
	self.reward_cell:SetInstanceParent(self.node_list["ItemCell1"])
	local reward_item = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP, num = exp, is_bind = 1}
	self.reward_cell:SetData(reward_item)

	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local cfg_vip_level = TaskData.Instance:GetFreeVipLevel()
	if cfg_vip_level then
		self.is_reach_vip = vip_level >= cfg_vip_level
	end

	self.node_list["SelectToggle"].toggle.isOn = TaskData.Instance:GetExpSelect()
end

function TaskExpRewardView:SetData(index)
	self.index = index
	if self:IsOpen() then
		self:Flush()
	else
		self:Open()
	end
end

function TaskExpRewardView:CloseWindow()
	self:RemoveTimer()
	local index = 1
	if TaskData.Instance:GetExpSelect() then
		index = 2
	end
	local player_had_gold = PlayerData.Instance:GetRoleAllGold()
	if player_had_gold >= TaskData.Instance:GetQuickPrice(TASK_TYPE.RI) then
		self:OnReward(index)
	else
		self:OnReward(1)
	end
	self:Close()
end

function TaskExpRewardView:OpenCallBack()
	self:RemoveTimer()
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	TaskCtrl.Instance:SetIsOpenView(true)
	self:Flush()
end

function TaskExpRewardView:CloseCallBack()
	TaskCtrl.Instance:SetIsOpenView(false)
	self:RemoveTimer()
end

function TaskExpRewardView:RemoveTimer()
	if nil ~= self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TaskExpRewardView:CountDown(elapse_time, total_time)
	if self.node_list["TimeText"] then
		self.node_list["TimeText"].text.text = string.format(Language.Task.ExpRewardTime, math.ceil(total_time - elapse_time))
		if elapse_time >= total_time then
			self:CloseWindow()
		end
	end
end

function TaskExpRewardView:OnFlush()
	local color = TEXT_COLOR.GREEN
	local cur_gold = PlayerData.Instance:GetRoleAllGold()
	local need_gold = TaskData.Instance:GetQuickPrice(TASK_TYPE.RI)
	if cur_gold < need_gold then
		color = TEXT_COLOR.RED
	end
	if self.is_reach_vip then
		-- self.node_list["Text1"]:SetActive(false)
		self.node_list["GoldText"].text.text = string.format("<color=%s>%s</color>", color, need_gold)
		self.node_list["BtnText1"].text.text = Language.Task.ExpRewardBtnText[2]
		self.node_list["BtnText2"].text.text = Language.Task.ExpRewardBtnText[3]
		self.node_list["SelectText"].text.text = string.format(Language.Task.ExpAuto, 3)
	else
		self.node_list["BtnText1"].text.text = Language.Task.ExpRewardBtnText[1]
		self.node_list["BtnText2"].text.text = Language.Task.ExpRewardBtnText[2]
		self.node_list["SelectText"].text.text = string.format(Language.Task.ExpAuto, 2)
		self.node_list["GoldText"].text.text = string.format(Language.Task.ExpViptipsText2, color, need_gold, TaskData.Instance:GetFreeVipLevel())
	end
	self.node_list["TopText"].text.text = string.format(Language.Task.ExpTopText, self.index + 1)
end

function TaskExpRewardView:OnReward(index)
	local num = TASK_EXP_REWARD.ONE
	local callback = function()
		self:SendReward(num)
		self:Close()
	end
	if index == 2 then
		if self.is_reach_vip then
			num = TASK_EXP_REWARD.THREE
		else
			num = TASK_EXP_REWARD.TWO
		end
		local player_had_gold = PlayerData.Instance:GetRoleAllGold()
		if player_had_gold >= TaskData.Instance:GetQuickPrice(TASK_TYPE.RI) then
			-- local str = string.format(Language.Task.ExpGoldTips, TaskData.Instance:GetQuickPrice(TASK_TYPE.RI), num)
			-- TipsCtrl.Instance:ShowCommonAutoView("", str, callback)
			callback()
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoBindGold)
		end
	else
		if self.is_reach_vip then
			num = TASK_EXP_REWARD.TWO
		else
			num = TASK_EXP_REWARD.ONE
		end
		callback()
	end
end

function TaskExpRewardView:SendReward(num)
	TaskCtrl.Instance:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_FETCH_REWARD, self.index, num)
end

function TaskExpRewardView:OnSelectToggleChange(isOn)
	TaskData.Instance:SetExpSelect(isOn)
end