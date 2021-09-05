DaFuHaoInfoView = DaFuHaoInfoView or BaseClass(BaseRender)

function DaFuHaoInfoView:__init(instance)
	self.rewards = {}
	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self.node_list["NormalItem" .. i])
	end

	self.cur_collect_num = 0
	self.max_collect_num = 0

	self.is_dafuhao = false
	self.is_trun_complete = false
	self.is_trun = false

	self.node_list["DaFuHaoIcon"].button:AddClickListener(BindTool.Bind(self.OnOpenRollView, self))
end

function DaFuHaoInfoView:__delete()
	for k,v in pairs(self.rewards) do
		if v then
			v:DeleteMe()
		end
	end
	self.rewards = {}


	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.gather_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.gather_count_down)
		self.gather_count_down = nil
	end

	if self.turn_complete ~= nil then
		GlobalEventSystem:UnBind(self.turn_complete)
		self.turn_complete = nil
	end
end

function DaFuHaoInfoView:OnOpenRollView()
	ViewManager.Instance:Open(ViewName.DaFuHaoRoll)
end

function DaFuHaoInfoView:OpenCallBack()
	self.turn_complete = GlobalEventSystem:Bind(OtherEventType.TURN_COMPLETE, BindTool.Bind(self.TrunComplete, self))
	if MainUICtrl.Instance:GetMenuToggleState() then
		if self.node_list["TaskAnimator"] then
			self.node_list["TaskAnimator"].canvas_group.alpha = 0
		end
	else
		if self.node_list["TaskAnimator"] then
			self.node_list["TaskAnimator"].canvas_group.alpha = 1
		end
	end
	self:Flush()
end

function DaFuHaoInfoView:OnFlush()
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	if dafuhao_info and dafuhao_info.is_turn then
		self.node_list["DaFuHaoIcon"]:SetActive(dafuhao_info.is_turn ~= 1)
	end
	if MainUICtrl.Instance:GetMenuToggleState() then
		if self.node_list["TaskAnimator"] then
			self.node_list["TaskAnimator"].canvas_group.alpha = 0
		end
	else
		if self.node_list["TaskAnimator"] then
			self.node_list["TaskAnimator"].canvas_group.alpha = 1
		end
	end
end

function DaFuHaoInfoView:CloseCallBack()
	self.diff_time = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.gather_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.gather_count_down)
		self.gather_count_down = nil
	end

	if self.turn_complete ~= nil then
		GlobalEventSystem:UnBind(self.turn_complete)
		self.turn_complete = nil
	end
end

-- 设置活动时间
function DaFuHaoInfoView:SetActivityCountDown()
	local activity_data = ActivityData.Instance:GetActivityStatuByType(DaFuHaoDataActivityId.ID)
	local diff_time = (activity_data and activity_data.next_time or 0) - TimeCtrl.Instance:GetServerTime()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down == nil and diff_time > 0 then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)

			self.node_list["TxtTime"].text.text = string.format(Language.Activity.DaFuHaoRemaintime, left_min, left_sec)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function DaFuHaoInfoView:TrunComplete(is_dafuhao)
	local gather_total_times = DaFuHaoData.Instance:GetDaFuHaoInfo().gather_total_times
	local reward_index = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index or -1

	self.is_trun = true
	self.is_dafuhao = is_dafuhao

	self.is_trun_complete = is_dafuhao
end

function DaFuHaoInfoView:Flush( ... )
	BaseRender.Flush(self, ...)
	self:SetActivityCountDown()
	local cfg = DaFuHaoData.Instance:GetDaFuHaoSpecialRewardCfg()
	for k, v in pairs(self.rewards) do
		if cfg then
			v:SetActive(nil ~= cfg["item"..k] and cfg["item"..k].item_id and cfg["item"..k].item_id > 0)
			if cfg["item"..k] then
				self.node_list["NormalItem" .. k]:SetActive(true)
				v:SetData(cfg["item"..k])
			else
				self.node_list["NormalItem" .. k]:SetActive(false)
			end
		end
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local millionare_type = vo.millionare_type and (vo.millionare_type == 1) or false
	local reward_index = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index or -1
	if (not self.is_trun and millionare_type) then
		reward_index = 0
	end
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	local gather_total_times = dafuhao_info.gather_total_times
	if reward_index == -1 then
		reward_index = dafuhao_info.reward_index or -1
	end


	-- if gather_total_times and gather_total_times >= 10 and not self.is_trun then

	-- end

	if gather_total_times then
		self.cur_collect_num = gather_total_times
		self:JudgeState(gather_total_times < 10)
	end
	self.max_collect_num = DaFuHaoData.Instance:GetDaFuHaoOtherCfg().role_gather_max_time
	self.node_list["TxtNum"].text.text = string.format(Language.Activity.DaFuHaoGatherTime, self.cur_collect_num, self.max_collect_num)
	if cfg then
		self.node_list["TxtShowTen"].text.text = string.format(Language.Activity.DaFuHaoExtraReward, cfg.extra_index)
	end
end

function DaFuHaoInfoView:JudgeState(ShowTenDes)
	self.node_list["TxtTenDesc"]:SetActive(ShowTenDes)
	self.node_list["TxtShowTen"]:SetActive(not ShowTenDes)
	self.node_list["Items1"]:SetActive(not ShowTenDes)
	-- self.node_list["DaFuHaoIcon"]:SetActive(ShowTenDes)
	self.node_list["TxtTitle"]:SetActive(ShowTenDes)
end

function DaFuHaoInfoView:GetTime(time)
	local index = string.find(time, ":")
	local next_index = string.find(string.sub(time, index + 1, -1), ":")
	if next_index ~= nil then
		return string.sub(time, 1, index - 1), string.sub(string.sub(time, index + 1, -1), 1, next_index - 1),
				string.sub(string.sub(time, index + 1, -1), next_index + 1, -1)
	end
	return string.sub(time, 1, index - 1), string.sub(time, index + 1, -1)
end