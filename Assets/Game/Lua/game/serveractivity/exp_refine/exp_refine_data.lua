ExpRefineData = ExpRefineData or BaseClass()

local BUBBLESHOWTIME = 5 			--气泡框显示时间
local BUBBLEELAPSETIME = 300 		--气泡框提示间隔时间

function ExpRefineData:__init()
	if ExpRefineData.Instance ~= nil then
		ErrorLog("[ExpRefineData] Attemp to create a singleton twice !")
	end
	ExpRefineData.Instance = self

	-- 经验炼制信息
	self.exp_refine_info = {
		refine_today_buy_time = 0,				-- 每日炼制次数
		refine_reward_gold = 0,					-- 总奖励金额
	}
	RemindManager.Instance:Register(RemindName.ExpRefine, BindTool.Bind(self.GetExpRefineRemind, self))
	RemindManager.Instance:Register(RemindName.ExpRefineBubble, BindTool.Bind(self.GetShowEff, self))
	self.is_show_eff = false

	self.main_role_level_change = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE, BindTool.Bind(self.MainRoleLevelChange, self))
end

function ExpRefineData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ExpRefine)
	RemindManager.Instance:UnRegister(RemindName.ExpRefineBubble)

	self:CancelCoutDown()
	self:CancelCoutDown2()
	if self.main_role_level_change then
		GlobalEventSystem:UnBind(self.main_role_level_change)
		self.main_role_level_change = nil
	end
	
	ExpRefineData.Instance = nil
end

function ExpRefineData:MainRoleLevelChange()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level >= 125 then
		local max_buy_num = self:GetRAExpRefineCfgMaxNum()
		local is_active = self:GetExpRefineIsOpen() and not (self.exp_refine_info.refine_today_buy_time >= max_buy_num)
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.ExpRefine, is_active)
		self.is_show_eff = true
		ExpRefineCtrl.Instance:FlushMainViewBubble()
	end
end

function ExpRefineData:SetRAExpRefineInfo(protocol)
	self.exp_refine_info.refine_today_buy_time = protocol.refine_today_buy_time or 0
	self.exp_refine_info.refine_reward_gold = protocol.refine_reward_gold or 0
end

function ExpRefineData:GetRAExpRefineInfo()
	return self.exp_refine_info
end

function ExpRefineData:GetExpRefineBuyTimes()
	if self.exp_refine_info ~= nil then
		return self.exp_refine_info.refine_today_buy_time
	else
		return 0
	end
end

function ExpRefineData:GetRAExpRefineCfgMaxNum()
	local num = 0
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if config and config.exp_refine then
		local cur_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
		for k, v in pairs(config.exp_refine) do
			if v.activity_day == cur_day then
				num = num + 1
			end
		end
	end
	return num
end

function ExpRefineData:GetIsRefineTimes()
	local times = self:GetRAExpRefineCfgMaxNum()
	if self.exp_refine_info.refine_today_buy_time >= times then
		return false
	end
	return true
end

function ExpRefineData:GetRAExpRefineCfgBySeq(seq)
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local cur_day = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
	if config and config.exp_refine then
		for k,v in pairs(config.exp_refine) do
			if v.activity_day == cur_day and v.seq == seq then
				return v
			end
		end
	end
end

-- 获取经验炼制活动是否还在开启中(哪怕已经过了时间，但只要奖励没领取就一直显示)
function ExpRefineData:GetExpRefineIsOpen()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status == ACTIVITY_STATUS.OPEN or self.exp_refine_info.refine_reward_gold > 0 then
		local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE)
		local level = PlayerData.Instance.role_vo.level
		if act_cfg and act_cfg.min_level <= level then
			return true
		end
	end
	return false
end

function ExpRefineData:GetExpRefineRemind()
	return self:GetExpRefineRedPoint() and 1 or 0
end

function ExpRefineData:GetExpRefineRedPoint()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXP_REFINE) or {}
	if act_info.status ~= ACTIVITY_STATUS.OPEN and self.exp_refine_info.refine_reward_gold > 0 then
		return true
	end
	return false
end

function ExpRefineData:SetCountDown()
	self:CancelCoutDown()
	self.count_down = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CountDownTime, self), BUBBLEELAPSETIME)
end

function ExpRefineData:SetCountDown2()
	self:CancelCoutDown2()
	self.count_down2 = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.CountDownTime2, self), BUBBLESHOWTIME)
end

function ExpRefineData:CountDownTime()
	self:SetIsShowBubble(true)
	ExpRefineCtrl.Instance:FlushMainViewBubble()
	self:CancelCoutDown()
	if RemindManager.Instance:RemindToday(RemindName.ExpRefineBubble) then
		return
	end
	self:SetCountDown2()
end

function ExpRefineData:CountDownTime2(elapse_time, total_time)	
	self:SetIsShowBubble(false)
	ExpRefineCtrl.Instance:FlushMainViewBubble()
	self:CancelCoutDown2()
	self:SetCountDown()
end

function ExpRefineData:CancelCoutDown()
	if self.count_down ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
end

function ExpRefineData:CancelCoutDown2()
	if self.count_down2 ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down2)
		self.count_down2 = nil
	end
end

function ExpRefineData:SetIsShowEff(bool)
	self.is_show_eff = bool
end

function ExpRefineData:GetIsShowEff()
	if RemindManager.Instance:RemindToday(RemindName.ExpRefineBubble) then
		self.is_show_eff = false
	end
	return self.is_show_eff
end

function ExpRefineData:SetIsShowBubble(bool)
	if RemindManager.Instance:RemindToday(RemindName.ExpRefineBubble) then
		self.is_show_bubble = false
		return
	end
	self.is_show_bubble = bool
end

function ExpRefineData:GetIsShowBubble()
	return self.is_show_bubble
end

function ExpRefineData:GetShowEff()
	return 0
end