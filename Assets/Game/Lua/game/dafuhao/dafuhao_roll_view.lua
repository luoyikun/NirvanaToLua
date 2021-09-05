DaFuHaoRollView = DaFuHaoRollView or BaseClass(BaseView)

local CellCount = 8          				-- 转盘上面的奖励格子数量

function DaFuHaoRollView:__init()
	self.ui_config =  {{"uis/views/dafuhaoview_prefab", "DaFuHaoRollView"}}
	self.high_light = {}
	self.reward_cells = {}
	self.view_layer = UiLayer.Pop
	self.is_rolling = false
	self.is_send = false
	self.turn_complete = true
	self.active_close = false
	self.is_modal = true
end

function DaFuHaoRollView:LoadCallBack()
	for i = 1, CellCount do
		self.reward_cells[i] = ItemCell.New()
		self.reward_cells[i]:SetInstanceParent(self.node_list["Reward"..i])
		self.reward_cells[i].node_list["Background"]:SetActive(false)
		self.reward_cells[i]:ShowQuality(false)
		self.reward_cells[i]:ShowNumBerBg(false)
	end
	self.node_list["BtnStart"].button:AddClickListener(BindTool.Bind(self.OnClickStart, self))
	-- self.node_list["Satr"].button:AddClickListener(BindTool.Bind(self.OnClickStart, self))
	self.node_list["Close"].button:AddClickListener(BindTool.Bind(self.OnClickClose, self))

end

function DaFuHaoRollView:OnClickClose()
	self:Close()
end

function DaFuHaoRollView:OpenCallBack()
	self.node_list["Satr"]:SetActive(true)
	for i = 1, CellCount do
		self.node_list["Highilght" .. i]:SetActive(false)
	end
	self.is_rolling = false
	self:Flush()
end

function DaFuHaoRollView:CloseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_send = false
end

function DaFuHaoRollView:__delete()
	self.is_rolling = nil
	self.is_send = nil
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end
	self.reward_cells = {}
end

-- 控制奖励栏的高亮
function DaFuHaoRollView:OpenHighLight(index)  -- index = 0  全灭
	for i = 1, CellCount do
		-- self.reward_cells[i]:ShowHighLight(i == index)
		self.node_list["Highilght" .. i]:SetActive(i == index)
	end
	self.node_list["Reward" .. index].image.enabled = false
end

-- function DaFuHaoRollView:SetImgeHidden(enabled)
-- 	self.node_list["Reward" .. i].image.enabled = enabled
-- end

function DaFuHaoRollView:CloseRollView()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.root_node:SetActive(false)
	self.turn_complete = true

	self:Close()
end

-- 点击开始
function DaFuHaoRollView:OnClickStart()
	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
	local gather_total_times = dafuhao_info.gather_total_times 

	if gather_total_times and gather_total_times < 10 then
		TipsCtrl.Instance:ShowSystemMsg(Language.DaFuHao.NoTurnTime)
		return 
	end

	if self.is_rolling or DaFuHaoData.Instance:GetDaFuHaoInfo().is_turn == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.DaFuHao.NoTurnTime)
		return
	end
	DaFuHaoCtrl.Instance:SetDaFuHaoIcon()
	self.node_list["Satr"]:SetActive(false)

	self.turn_complete = false
	self.is_rolling = true
	GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, false)
	local time = 0
	local tween = self.node_list["BtnStart"].transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if not self.is_send then
			DaFuHaoCtrl.Instance:SendTurnTableOperaReq(GameEnum.TURNTABLE_OPERA_TYPE, 1)
			self.is_send = true
		end
		if time >= 2 then
			if DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index then
				tween:Pause()
				local angle = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index * - 45
				local tween1 = self.node_list["BtnStart"].transform:DORotate(
						Vector3(0, 0, -360 * 3 + angle),
						3,
						DG.Tweening.RotateMode.FastBeyond360)
				tween1:OnComplete(function ()
					self.is_rolling = false
					self:OpenHighLight(DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index + 1)
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 3)
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKYROLL)
					GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index == 0)
				end)
			end
		end
	end)
	tween:OnComplete(function ()
		print_error("No Received Server Agreement :", DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index)
			self.is_rolling = false
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 3)
		end)
end

function DaFuHaoRollView:OnFlush()
	for k, v in pairs(self.reward_cells) do
		if k == (DaFuHaoData.Instance:GetTurnTableCfg()[k].item_index + 1) and k > 1 then
			v:SetData(DaFuHaoData.Instance:GetTurnTableCfg()[k].reward_item)
		end
	end
end

function DaFuHaoRollView:GetIsTrunComplete()
	return self.turn_complete
end