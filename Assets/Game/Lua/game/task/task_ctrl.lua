require("game/task/task_data")
require("game/task/task_dialog_view")
require("game/task/task_weather_eff")
require("game/task/task_exp_reward_view")

-- 任务
TaskCtrl = TaskCtrl or BaseClass(BaseController)
function TaskCtrl:__init()
	if TaskCtrl.Instance then
		print_error("[TaskCtrl] Attemp to create a singleton twice !")
	end
	TaskCtrl.Instance = self

	self.task_data = TaskData.New()
	self.task_weather_eff = TaskWeatherEff.New()
	self.task_dialog_view = TaskDialogView.New(ViewName.TaskDialog)
	self.task_exp_reward = TaskExpRewardView.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.VIEW_CLOSE, BindTool.Bind(self.HasViewClose, self))
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self.not_auto_task_panel = false --打开一些面板时不设置自动任务
end

function TaskCtrl:__delete()
	TaskCtrl.Instance = nil

	self.task_dialog_view:DeleteMe()
	self.task_dialog_view = nil

	self.task_data:DeleteMe()
	self.task_data = nil

	self.task_exp_reward:DeleteMe()
	self.task_exp_reward = nil

	self.task_weather_eff:DeleteMe()
	self.task_weather_eff = nil

	if self.no_fly_timer then
		GlobalTimerQuest:CancelQuest(self.no_fly_timer) --取消延时
		self.no_fly_timer = nil
	end

	self:RemoveDelayTime()
end

function TaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTaskListAck, "OnTaskListAck")
	self:RegisterProtocol(SCTaskInfo, "OnTaskInfo")
	self:RegisterProtocol(SCTaskRecorderList, "OnTaskRecorderList")
	self:RegisterProtocol(SCTaskRecorderInfo, "OnTaskRecorderInfo")
	self:RegisterProtocol(SCAccpetableTaskList, "OnAccpetableTaskList")
	self:RegisterProtocol(SCTuMoTaskInfo, "OnTuMoTaskInfo")
	self:RegisterProtocol(SCGuildTaskInfo, "OnGuildTaskInfo")
	self:RegisterProtocol(SCPaohuanTaskInfo, "OnPaohuanTaskInfo")
	self:RegisterProtocol(SCTaskRollReward, "OnTaskRollInfo")

	self:RegisterProtocol(CSTaskGiveup)
	self:RegisterProtocol(CSFlyByShoe)
	self:RegisterProtocol(CSTaskAccept)
	self:RegisterProtocol(CSTaskCommit)
	-- self:RegisterProtocol(CSTumoFetchCompleteAllReward)
	self:RegisterProtocol(CSTuMoTaskOpera)
end

-- 设置日常任务信息
function TaskCtrl:OnTuMoTaskInfo(protocol)
	self.task_data:SetDailyTaskInfo(protocol)

	MainUICtrl.Instance:FlushExpBall()
	local can_fetch_flag = bit:d2b(protocol.daily_task_can_fetch_flag)  -- 日常任务可领取标记
	local fetch_flag = bit:d2b(protocol.daily_task_fetch_flag)			-- 日常任务领取标记

	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local cfg_vip_level = TaskData.Instance:GetFreeVipLevel()
	local ison = TaskData.Instance:GetExpSelect()
	local player_had_gold = PlayerData.Instance:GetRoleAllGold()

	local num = TASK_EXP_REWARD.TWO
	if cfg_vip_level then
		if vip_level >= cfg_vip_level then
			num = TASK_EXP_REWARD.THREE
		end
	end
	if protocol.notify_reason ~= TUMO_NOTIFY_REASON_TYPE.TUMO_ONE_KEY_COMPLETION then
		for i = 0, 9 do
			if can_fetch_flag[32 - i] == 1 and fetch_flag[32 - i] == 0 then
				if self.task_exp_reward then
					-- if ison and player_had_gold >= TaskData.Instance:GetQuickPrice(TASK_TYPE.RI) then
					-- 	TaskCtrl.Instance:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_FETCH_REWARD, i, num)
					-- else
						self.task_exp_reward:SetData(i)
					-- end
				end
			end
		end
	end
end

-- 设置公会任务信息
function TaskCtrl:OnGuildTaskInfo(protocol)
	self.task_data:SetGuildTaskInfo(protocol)
end


-- 设置跑环任务信息
function TaskCtrl:OnPaohuanTaskInfo(protocol)
	self.task_data:SetPaohuanTaskInfo(protocol)
end

function TaskCtrl:OnTaskRollInfo(protocol)
	self.task_data:SetRewardRollInfo(protocol)
	if protocol.is_finish ~= 0 then
		local list = TaskData.Instance:GetRewardRollList(protocol.list[1].type)
		ItemData.Instance:SetNormalRewardList(list)
		if protocol ~= nil then 
			if protocol.task_type == TASK_TYPE.RI or protocol.task_type == TASK_TYPE.GUILD or protocol.task_type == TASK_TYPE.HUAN then
				if not ViewManager.Instance:IsOpen(ViewName.TreasureReward) then 
					TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE)
				end
			else
				TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_NORMAL_REWARD_MODE)
			end
		end
	end
end

-- 请求已接任务列表返回
function TaskCtrl:OnTaskListAck(protocol)
	self.task_data:SetTaskAcceptedInfoList(protocol.task_accepted_list)
	YunbiaoCtrl.Instance:FlushHuSong()
	Scene.Instance:GetMainRole():ChangeFakeTruck()
end

-- 单条已接任务信息
function TaskCtrl:OnTaskInfo(protocol)
	self.task_data:SetTaskInfo(protocol)
	if self.task_dialog_view:IsOpen() then
		self.task_dialog_view:Flush()
	end
	Scene.Instance:GetMainRole():ChangeFakeTruck()
end

-- 已完成任务列表返回
function TaskCtrl:OnTaskRecorderList(protocol)
	self.task_data:SetTaskCompletedIdList(protocol.task_completed_id_list)
end

-- 任务记录列表数据改变
function TaskCtrl:OnTaskRecorderInfo(protocol)
	self.task_data:SetTaskCompleted(protocol.completed_task_id)
end

-- 返回可接受列表
function TaskCtrl:OnAccpetableTaskList(protocol)
	self.task_data:SetTaskCapAcceptedIdList(protocol.task_can_accept_id_list)
end

-- 放弃任务
function TaskCtrl.SendTaskGiveup(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskGiveup)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 接任务
function TaskCtrl.SendTaskAccept(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskAccept)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 交任务
function TaskCtrl.SendTaskCommit(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskCommit)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

-- 飞行到某地
function TaskCtrl:SendFlyByShoe(scene_id, pos_x, pos_y, scene_key, ignore_shot, not_clear_jump_cache, auto_buy)
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
		return
	end
	local main_role = Scene.Instance:GetMainRole()
	if main_role and main_role:IsQingGong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.QingGong.NoDeliveryQingGong)
		return
	end

	if main_role and main_role:IsFightState() and main_role.vo.attack_mode ~= GameEnum.ATTACK_MODE_PEACE then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFlyInFight)
		return
	end

	if not not_clear_jump_cache then
		Scene.Instance:GetMainRole():ClearJumpCache()
	end
	
	local cur_scene_id = Scene.Instance:GetSceneId()
	if cur_scene_id == scene_id then
		self:SendFly(scene_id, pos_x, pos_y, scene_key, ignore_shot, auto_buy)
		return
	end

	if main_role then
		main_role:PlayFlyUpEffect(function()
			self:SendFly(scene_id, pos_x, pos_y, scene_key, ignore_shot, auto_buy)
		end)
	end

	if self.no_fly_timer then
		GlobalTimerQuest:CancelQuest(self.no_fly_timer) --取消延时
		self.no_fly_timer = nil
	end
	self.no_fly_timer = GlobalTimerQuest:AddDelayTimer(function()--7秒后没反应则恢复
		if main_role and main_role:IsDelivering() then
			main_role:PlayFlyDownEffect()
		end
	end, 7)
end

function TaskCtrl:SendFly(scene_id, pos_x, pos_y, scene_key, ignore_shot, auto_buy)
	local fly_shot = MapData.Instance:GetFlyShoeId() or 0
	local protocol = ProtocolPool.Instance:GetProtocol(CSFlyByShoe)
	protocol.scene_id = scene_id
	protocol.scene_key = scene_key or -1
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol.item_index = (auto_buy or TipsCommonBuyView.AUTO_LIST[fly_shot])and 1 or 0
	protocol.is_force = ignore_shot and 1 or 0
	protocol:EncodeAndSend()
end

local cache_npc_obj_id = nil
local cache_npc_id = nil
function TaskCtrl:HasViewClose(view)
	if view.view_name == ViewName.TaskDialog then
		cache_npc_obj_id = nil
		cache_npc_id = nil
		return
	end
	if SceneType.Common == Scene.Instance:GetSceneType() and cache_npc_obj_id and cache_npc_id and not ViewManager.Instance:HasOpenView() then
		self:SendNpcTalkReq(cache_npc_obj_id, cache_npc_id)
		cache_npc_obj_id = nil
		cache_npc_id = nil
	end
end

function TaskCtrl:MainuiOpenCreate()
	TaskCtrl.Instance:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_GET_INFO)
end

function TaskCtrl:SendNpcTalkReq(npc_obj_id, npc_id)
	if not Scene.Instance:GetMainRoleIsMove() then
		return
	end
	if nil ~= npc_obj_id then
		if ViewManager.Instance:IsOpen(ViewName.Map) then
			ViewManager.Instance:Close(ViewName.Map)
		end
		local npc_obj = Scene.Instance:GetObjectByObjId(npc_obj_id)
		if npc_obj then
			local npc_vo = npc_obj:GetVo()
			if npc_vo then
				npc_id = npc_vo.npc_id
			end
			local obj = npc_obj:GetRoot()
			if obj then
				local towards = Scene.Instance:GetMainRole():GetRoot().transform.position
				towards = u3d.vec3(towards.x, obj.transform.position.y, towards.z)
				obj.transform:DOLookAt(towards, 0.5)
			end

			Scene.Instance:GetMainRole():SetDirectionByXY(npc_obj:GetLogicPos())

			if npc_obj:IsWalkNpc() then
				npc_obj:Stop()
			end
		end
	end

	if nil ~= npc_id then
		if npc_id == 208 then
			return
		end

		--结婚NPC
		if npc_id == COMMON_CONSTS.NPC_MARRY_ID then
			ViewManager.Instance:Open(ViewName.MarryNpcMe)
			return
		end
		--护送NPC
		if npc_id == COMMON_CONSTS.NPC_HUSONG_RECEIVE_ID then
			ViewManager.Instance:Open(ViewName.YunbiaoView)
			return
		end
		local guild_yunbiao_cfg = GuildData.Instance:GetGuildYunBiaoConfig()
		local npc_cfg_id = guild_yunbiao_cfg.accept_npc_id

		if npc_id == npc_cfg_id then
			local act_id = ACTIVITY_TYPE.GUILD_BONFIRE
			local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
			local post = GuildData.Instance:GetGuildPost()
			if not ActivityData.Instance:GetActivityIsOpen(act_id) then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
				return
			end
			if guild_id < 1 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
				ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
				return
			end

			local status = GuildCtrl.Instance.has_yunbiao and true or false
			local flag = post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG
			local index = flag and true or false
			ActivityCtrl.Instance:ShowGuildYunBiaoButton(index, status)
			return
		end

		--领土战NPC
		if ClashTerritoryData.Instance:IsTerritoryWarNpc(npc_id) then
			ViewManager.Instance:Open(ViewName.ClashTerritoryShop)
			return
		end
		if ViewManager.Instance:HasOpenView() then
			cache_npc_obj_id = npc_obj_id
			cache_npc_id = npc_id
			return
		end
		self.task_dialog_view:SetNpcId(npc_id, npc_obj_id)
		self.task_dialog_view:Open()
		GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
	end
end

--通知服务端与NPC对话
function TaskCtrl.SendTaskTalkToNpc(npc_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskTalkToNpc)
	protocol.npc_id = npc_id
	protocol:EncodeAndSend()
end

--取消正在执行的任务
function TaskCtrl:CancelTask()
	local task_id = TaskData.Instance:GetCurTaskId()
	TaskData.Instance:SetCurTaskId(nil)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if nil ~= task_id then
		MainUICtrl.Instance:OnTaskRefreshActiveCellViews()
	end
end

function TaskCtrl:SendQuickDone(task_type, task_id)
	if not task_type then
		return
	end
	if task_type == TASK_TYPE.GUILD then
		local protocol = ProtocolPool.Instance:GetProtocol(CSFinishAllGuildTask)
		protocol:EncodeAndSend()
	elseif task_type == TASK_TYPE.RI then
		if not task_id then
			return
		end
		-- local protocol = ProtocolPool.Instance:GetProtocol(CSTumoCommitTask)
		-- protocol.commit_all = 1
		-- protocol.task_id = task_id
		-- protocol.is_force_max_star = 0
		-- protocol:EncodeAndSend()

		self:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_COMMIT_TASK, task_id, 1)
	end
end

function TaskCtrl:AutoDoTaskState(state)
	local task_view = MainUICtrl.Instance:GetTaskView()
	if task_view then
		task_view:SetAutoTaskState(state)
		if self.task_dialog_view then
			self.task_dialog_view:SetAutoDoTask(state)
		end
	end
end

function TaskCtrl:SetIsOpenView(bool)
	self.not_auto_task_panel = bool
	self:SetAutoTalkState(not bool)
end

function TaskCtrl:SetAutoTalkState(state)
	if self.not_auto_task_panel and state then
		return
	end
	self:RemoveDelayTime()
	if state then
		--当调用自动做任务时延迟0.5秒后做任务（防止任务比引导快）
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
			self:AutoDoTaskState(state)
			if PlayerData.Instance:GetRoleVo().level <= 170 or TASK_GUILD_AUTO or TASK_RI_AUTO or TASK_HUAN_AUTO then
				self:DoTask()
			end
		end, 0.5)
	else
		self:AutoDoTaskState(state)
	end
end

function TaskCtrl:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function TaskCtrl:CloseWindow()
	if self.task_dialog_view then
		self.task_dialog_view:HandleClose()
	end
end

function TaskCtrl:StopTaskDialogAudio()
	if self.task_dialog_view then
		self.task_dialog_view:StopTaskDialogAudio()
	end
end

function TaskCtrl:DoTask(task_id)
	if task_id then
		TaskData.Instance:SetCurTaskId(task_id)
	end
	local task_view = MainUICtrl.Instance:GetTaskView()
	if task_view then
		task_view:AutoExecuteTask()
	end
end

function TaskCtrl:DoZhuanZhiTask(task_id, task_status)
	if task_id then
		TaskData.Instance:SetCurTaskId(task_id)
	end
	local task_view = MainUICtrl.Instance:GetTaskView()
	if task_view then
		task_view:OperateTask(MainUIViewTask.TaskCellInfo(task_id, task_status))
	end
end

function TaskCtrl:SendGetTaskReward()
	self:SendTuMoTaskOpera(TUMO_OPERA_TYPE.TUMO_OPERA_TYPE_FETCH_COMPLETE_ALL_REWARD)
end

--一键完成
function TaskCtrl:SendCSSkipReq(type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSkipReq)
	protocol.type = type
	protocol.param = param or -1
	protocol:EncodeAndSend()
end

function TaskCtrl:SetGuideFbEff(index)
	if self.task_weather_eff and index and index > 0 then
		self.task_weather_eff:SetGuideFbEff(index)
	end
end

function TaskCtrl:SendTuMoTaskOpera(opera_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTuMoTaskOpera)
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end