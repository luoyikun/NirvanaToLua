MainUIViewTask = MainUIViewTask or BaseClass(BaseRender)

local DELAY_TIME = 0.25
local INTERVAL_TIME = 1
local ListViewDelegate = ListViewDelegate
MainUIViewTask.SHOW_GUIDE_ARROW = false
local CAN_SHOW_ZHU_ARROW = false	-- 显示主线箭头
local CAN_SHOW_ZHI_ARROW = true 	-- 显示支线箭头
local CAN_SHOW_GUILD_ARROW = false 	-- 显示公会箭头
local CUR_TASK = 0 					-- 当前任务
local CUR_ZHI_TASK = 99999  		-- 当前支线
local HAS_ZHI_TASK = false 			-- 是否存在支线
local HAS_GUILD_TASK = nil 			-- 是否存在公会任务
local HAS_RI_TASK = false 			-- 是否存在日常任务
local CAN_DO_ZHU_TASK = false 		-- 是否可做主线
local CLICK_EFFECT_TASK = 0 		-- 最后点击的特效任务ID
local ARROW_TASK_ID = 0
local HAS_HUG_TASK = 0 				-- 是否有抱东西任务
function MainUIViewTask:__init()
	self.is_load = true
	self.is_move = false
	self.task_data = {}
	self.cell_list = {}

	self.node_list["NormalTask"]:SetActive(false)
	self.node_list["GuideArrow"]:SetActive(false)
	self.toggle_group = self.node_list["TaskList"].toggle_group
	self.toggles = {}

	self.node_list["BtnBgDoTask"].button:AddClickListener(BindTool.Bind(self.OnTouchChapterTask, self))
	self.node_list["BtnDoTask"].button:AddClickListener(BindTool.Bind(self.OnTouchChapterTask, self))

	self.list_view_delegate = ListViewDelegate()

	local res_async_loader = AllocResAsyncLoader(self, "item_res_async_loader")
	res_async_loader:Load("uis/views/mainui_prefab", "TaskInfo", nil, function (obj)
		if nil == obj then
			return
		end

		self.enhanced_cell_type = obj:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.node_list["TaskList"].scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = function()
			return #self.task_data
		end
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
		self.node_list["TaskList"].scroller.scrollerScrollingChanged = function ()
			self:ReSetBtnVisible()
		end
	end)
	MainUIData.Instance:SetTaskData(self.task_data)

	-- 监听系统消息
	self:BindGlobalEvent(OtherEventType.TASK_CHANGE,
		BindTool.Bind(self.OnTaskChange, self))
	self:BindGlobalEvent(ObjectEventType.LEVEL_CHANGE,
		BindTool.Bind(self.MainRoleLevelChange, self))
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE,
		BindTool.Bind(self.DayCountChange, self))
	self:BindGlobalEvent(OtherEventType.VIRTUAL_TASK_CHANGE,
		BindTool.Bind(self.VirtualTaskChange, self))
	self:BindGlobalEvent(
		MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE,
		BindTool.Bind(self.ClearToggle, self))

	self.remind_change = BindTool.Bind(self.VirtualTaskChange, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.MoLongMiBao)

	self.player_data_listen = BindTool.Bind(self.PlayerDataListen, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_listen)

	self.delay_sort_task_fun = BindTool.Bind(self.DelaySortTask, self)
	self.last_move_time = 0
	self.auto_zhu_task = true		-- 自动做主线

	-- 初始化
	self:OnTaskChange()

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Main, self.get_ui_callback)
	self.move_cell = self.node_list["MoveCell"]
	self.cur_move = self.move_cell:GetComponent(typeof(CurveMove))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.move_cell)
	self.move_cell:SetActive(false)
	-- 修复每日必做消失的bug(暂时没有找到原因，使用的是update检测的办法)
	self:FixDailyBug()
end

function MainUIViewTask:SetTime(time)
	if self.node_list["TxtTime"] then
		self.node_list["TxtTime"].text.text = time
	end
end

function MainUIViewTask:__delete()
	self.item_cell:DeleteMe()

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if nil ~= self.delay_sort_task_timer then
		GlobalTimerQuest:CancelQuest(self.delay_sort_task_timer)
		self.delay_sort_task_timer = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.Main, self.get_ui_callback)
	end
	self.effect_flag_cfg = nil
	self:RemoveDailyBugCountDown()

	if self.player_data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_listen)
		self.player_data_listen = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_load = false
end

function MainUIViewTask:SetAutoTaskState(state)
	if not state and self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	self.auto_zhu_task = state

	if state then
		if PlayerData.Instance:GetRoleVo().level <= 150  -- 151级前恢复时才自动做任务
			and self:IsCanAutoExecuteTask() then
			self:AutoExecuteTask()
		end
	else
		if GuajiCache.guaji_type ~= GuajiType.Auto then
			GuajiCtrl.Instance:StopGuaji()
		end
	end
end

function MainUIViewTask:IsPauseAutoTask()
	return not self.auto_zhu_task
end

function MainUIViewTask:ShowGuideArrow()
	if not MainUIViewTask.SHOW_GUIDE_ARROW then
		self.node_list["GuideArrow"]:SetActive(true)
		MainUIViewTask.SHOW_GUIDE_ARROW  = true
	end
end

--设置按钮是否可见
function MainUIViewTask:ReSetBtnVisible()
	local position = self.node_list["TaskList"].scroller.ScrollPosition
	local disable_height = self.node_list["TaskList"].scroller.ScrollSize						--listview不可见的画布长度
	self.node_list["NodeDownArrow"]:SetActive(false)
end

--滚动条刷新
function MainUIViewTask:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	local cell = self.cell_list[cell_view]

	if cell == nil then
		self.cell_list[cell_view] = MainUIViewTaskInfo.New(cell_view)
		cell = self.cell_list[cell_view]
		cell.sell_view = self
		self.toggles[data_index] = cell.root_node:GetComponent("Toggle")
		cell:SetHandle(self)
		cell:ListenClick(self)
		cell:ListenQuickDone(self)
		cell:SetToggle(self.toggle_group)
	end
	local data = self.task_data[data_index + 1]
	cell.root_node.toggle.isOn = data and CUR_TASK == data.task_id
	cell:SetIndex(data_index + 1)
	cell:SetData(data)
	return cell_view
end

function MainUIViewTask:RefrechCell(task_id)
	local task_data = nil
	for _, v in ipairs(self.task_data) do
		if v.task_id == task_id then
			task_data = v
			break
		end
	end

	if nil == task_data then
		return
	end

	for _, v in pairs(self.cell_list) do
		if v:GetTaskId() == task_id then
			v:SetData(task_data)
			break
		end
	end
end

function MainUIViewTask:GetCellSize(data_index)
	local data = self.task_data[data_index + 1]
	if nil == data then
		return 0
	end
	-- local config = TaskData.Instance:GetTaskConfig(data.task_id)
	-- if config then
	-- 	if config.task_type == TASK_TYPE.RI or config.task_type == TASK_TYPE.GUILD then
	-- 		return 102
	-- 	end
	-- end
	return 80
end

function MainUIViewTask:OnTaskChange(task_event_type, task_id)
	if Scene.Instance:GetSceneId() == 1130 then
		--皇陵探险中不需要这个功能
		return
	end
	if task_event_type == "completed_add" then
		self.last_task_id = task_id
		self:CompletedSceneEventLogic(task_id)
	end
	self:CompletedTreeTask(task_id)
	-- 是否是任务数量型的变化
	local is_num_change_reason = "accepted_update" == task_event_type and not TaskData.Instance:GetTaskIsCanCommint(task_id)

	-- 新手的章节任务
	local chapter_cfg = TaskData.Instance:GetCurrentChapterCfg()
	if nil ~= chapter_cfg then
		self:RefreshChapterTask(chapter_cfg)
	else
		-- 普通任务
		-- if "accepted_update" == task_event_type and not TaskData.Instance:GetTaskIsCanCommint(task_id) then
		-- 	self:RefrechCell(task_id)
		-- else
		--	self:SortTask()
		-- end

		-- 策划反馈有时任务不刷新，先不优化成针对性刷新，而是直接刷新整个list
		self:SortTask()
	end

	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if task_cfg and task_cfg.task_type == TASK_TYPE.ZHU and self:IsCanAutoExecuteTask() then
		self:AutoExecuteTask()
	end

	if task_cfg and task_cfg.task_type == TASK_TYPE.HUAN and TASK_HUAN_AUTO then
		self:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
	end

	if task_cfg and TASK_RI_AUTO and task_cfg.task_type == TASK_TYPE.RI then
		TaskCtrl.Instance:DoTask(task_id)
	end
end

function MainUIViewTask:CompletedTreeTask(task_id)
	local tesk_tree_info = TaskData.Instance:GetTreeTask(task_id)
	if tesk_tree_info then
		Scene.Instance:SceneTreeTask()
	end
end


function MainUIViewTask:MainRoleLevelChange()
	self:SortTask()
end

function MainUIViewTask:IsCanAutoExecuteTask()
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.Common then
			if GuajiCache.guaji_type ~= GuajiType.Auto and GuajiCache.guaji_type ~= GuajiType.None and self.auto_zhu_task then
				return true
			end
		end
	end
	return false
end

function MainUIViewTask:AutoExecuteTask()
	if not self.auto_zhu_task then return end
	local task_id = TaskData.Instance:GetCurTaskId()
	if not task_id or task_id == 0 then
		if TASK_GUILD_AUTO then
			if TaskData.Instance:GetGuildTaskInfo().task_id then
				task_id = TaskData.Instance:GetGuildTaskInfo().task_id
			end
		elseif TASK_RI_AUTO then
			if TaskData.Instance:GetDailyTaskInfo() then
				task_id = TaskData.Instance:GetDailyTaskInfo().task_id
			end
		elseif TASK_HUAN_AUTO then
			if TaskData.Instance:GetPaohuanTaskInfo() then
				task_id = TaskData.Instance:GetPaohuanTaskInfo().task_id
			end
		elseif TaskData.Instance:GetNextZhuTaskConfig() then
			task_id = TaskData.Instance:GetNextZhuTaskConfig().task_id
		end
	end
	if task_id and task_id ~= 0 then
		if TASK_RI_AUTO or TASK_HUAN_AUTO then
			self.last_task_id = task_id
			local state = TaskData.Instance:GetTaskStatus(task_id)
			if state == TASK_STATUS.COMMIT then
				self:DoTask(task_id, state)
			else
				self:DoTask(task_id, TASK_STATUS.ACCEPT_PROCESS)
			end
			if self.node_list["TaskList"] and self.node_list["TaskList"].gameObject.activeInHierarchy then
				self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		else
			self.last_task_id = task_id
			self:DoTask(task_id, TaskData.Instance:GetTaskStatus(task_id))
		end
	else
		GuajiCtrl.Instance:ClearTaskOperate()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	end
end

function MainUIViewTask:ClearToggle()
	self.toggle_group:SetAllTogglesOff()
	CUR_TASK = 0
end

--继续护送任务
function MainUIViewTask:ClickGo()
	TaskData.Instance:GoOnHuSong()
end

function MainUIViewTask:OnClickAuditTask(data)
	if data then
		self:OnTaskCellClick(data)
	end
end

function MainUIViewTask:OnTaskCellClick(data)
	CUR_TASK = data.task_id
	if data.task_id == -1 then --加入公会任务提示框
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if(vo.guild_id <= 0) then
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_request)
		else
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
		end
		return
	end
	if nil == data then
		print_warning("配置表为空")
		return
	end
	if not Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		print_warning("CantDoMove")
		self:ClearToggle()
		return
	end
	if TaskData.IsZhiTask(data) and data.task_status == TASK_STATUS.COMMIT and self.package_btn then
		if self.count_down == nil then
			self:RewardFlyToBag(data)
			self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self))
		end
		return
	end

	if data.task_type == TASK_TYPE.ZHUANZHI then
		ZhuanZhiData.Instance:SetZhuanZhiTaskData(data)
		local zhuanzhi_task_status = TaskData.Instance:GetTaskStatus(data.task_id)
		if data.condition ~= TASK_COMPLETE_CONDITION.PASS_FB_LAYE and zhuanzhi_task_status ~= TASK_STATUS.COMMIT then
			local _, zhuan = PlayerData.Instance:GetRoleBaseProf()
			if zhuan < 5 then
				local task_cfg = TaskData.Instance:GetTaskConfig(data.task_id)
				if data.task_status == TASK_STATUS.ACCEPT_PROCESS then
					if task_cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then
						local target = Scene.Instance:SelectMinDisMonster(task_cfg.target_obj[1].id, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
						if target then
							local x, y = target:GetLogicPos()
							target = {scene = Scene.Instance:GetSceneId(), x = x, y = y, id = task_cfg.target_obj[1].id}
						else
							target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
						end
						self:MoveToTarget(target, MoveEndType.FightByMonsterId, data.task_id, is_active)
						GuajiCache.monster_id = target.id
						GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
					elseif task_cfg.condition == TASK_COMPLETE_CONDITION.TASK_COMPLETE_CONDITION_16 then
						TaskData.Instance.shang_rand_monst_id = 0
						local temp_monst_id = TaskData.Instance:GetRandomMonstID(task_cfg.a_param1, task_cfg.a_param2)
						if temp_monst_id > 0 then
							local temp_monst_cfg = TaskData.Instance:GetMonstTargetCfgList(temp_monst_id)
							if temp_monst_cfg ~= nil then
								local target = {scene = temp_monst_cfg.scene_id, x = temp_monst_cfg.monst_x, y = temp_monst_cfg.monst_y, id = temp_monst_id}
								self:MoveToTarget(target, MoveEndType.FightByMonsterId, data.task_id, is_active)
								GuajiCache.monster_id = target.id
								GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
							end
						end
					elseif task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB_LAYE then
						if TaskData:GetIsXinMoTaskZhuanZhi(data.task_id) then
							ViewManager.Instance:Open(ViewName.Player, TabIndex.role_zhuanzhi)
						else
							GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
							FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ZHUANZHI_FB, 0)
						end
					elseif task_cfg.condition == TASK_COMPLETE_CONDITION.REACH_STATE then
						ViewManager.Instance:Open(ViewName.Player, TabIndex.role_zhuanzhi)
					end
				else
					ViewManager.Instance:Open(ViewName.Player, TabIndex.role_zhuanzhi)
				end
				TASK_ZHUANZHI_AUTO = true
			else
				ViewManager.Instance:Open(ViewName.Player, TabIndex.role_juexing)
			end
			return
		end
	end

	for k,v in pairs(self.cell_list) do
		if v:IsShowArrowEff() then
			v:SetShowArrowEff(false)
			if v.data and v.data.task_type == TASK_TYPE.ZHU then
				CAN_SHOW_ZHU_ARROW = false
			elseif v.data and v.data.task_type == TASK_TYPE.GUILD then
				CAN_SHOW_GUILD_ARROW = false
			else
				CAN_SHOW_ZHI_ARROW = false
			end
		end
	end

	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	if config then
		local role_level = PlayerData.Instance:GetRoleVo().level
		if config.min_level > role_level then -- 如果等级没打达到
			self:ClearToggle()
			-- ViewManager.Instance:Open(ViewName.YewaiGuajiView)
			ViewManager.Instance:Open(ViewName.BaoJu)
			-- local guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex()
			-- local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(guaiwuIndex)
			-- YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
			return
		end
		if config.task_type == TASK_TYPE.GUILD then
			TASK_GUILD_AUTO = true
		else
			TASK_GUILD_AUTO = false
		end
		if config.task_type == TASK_TYPE.RI then
			TASK_RI_AUTO = true
		else
			TASK_RI_AUTO = false
		end
		if config.task_type == TASK_TYPE.HUAN then
			TASK_HUAN_AUTO = true
		else
			TASK_HUAN_AUTO = false
		end
		TASK_ZHUANZHI_AUTO = false
	end
	--更新选中状态
	self:OperateTask(data)
end

function MainUIViewTask:OnClickQuickDone(data)
	if nil == data then
		return
	end
	local config = TaskData.Instance:GetTaskConfig(data.task_id)
	local price = 0
	local count = 0
	if config then
		price = TaskData.Instance:GetQuickPrice(config.task_type)
		count = TaskData.Instance:GetTaskCount(tonumber(config.task_type))
	end
	local vip_power_id = 0
	local tips_str = ""
	if config.task_type == TASK_TYPE.RI then
		vip_power_id = VIPPOWER.KEY_DIALY_TASK
		tips_str = Language.Task.KeyExpTaskTips
	elseif config.task_type == TASK_TYPE.GUILD then
		vip_power_id = VIPPOWER.KEY_GUILD_TASK
		tips_str = Language.Task.KeyGuildTaskTips
	elseif config.task_type == TASK_TYPE.HUAN then
		vip_power_id = VIPPOWER.KEY_HUAN_TASK
		tips_str = Language.Task.KeyHuanTaskTips
	end

	if vip_power_id > 0 and VipPower.Instance:GetParam(vip_power_id) < 1 then
		local limit_level = VipPower.Instance:GetMinVipLevelLimit(vip_power_id) or 0
		TipsCtrl.Instance:ShowSystemMsg(string.format(tips_str, limit_level))
		return
	end


	local describe = string.format(Language.Daily.YiJianRenWu, ToColorStr(tostring(price * count), TEXT_COLOR.GREEN))
	describe = string.format(describe, price * count)
	-- TipsCtrl.Instance:ShowTwoOptionView(describe, yes_func, nil, "确定", "取消")

	local call_back = function ()
		local gold = PlayerData.Instance:GetRoleAllGold()
		if gold < price * count then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE, "one_key", data)
	end
	local red_text = Language.Task.DoubleReward
	if config.task_type ~= TASK_TYPE.RI then
		red_text = config.task_type == TASK_TYPE.GUILD and Language.Task.YouXianBindGold or ""
	end

	if config.task_type == TASK_TYPE.HUAN then
		local call_back_two = function ()
			MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_PAOHUAN_TASK, -1)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back_two, nil, true, nil, nil, red_text)
		return
	end
	if config.task_type == TASK_TYPE.RI then
		local free_double_vip = TaskData.Instance:GetFreeVipLevel()
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		if free_double_vip <= vip_level then
			describe = describe .. Language.Daily.YiJianRenWu_3
		else
			describe = describe .. Language.Daily.YiJianRenWu_2
		end
	end
	TipsCtrl.Instance:ShowCommonAutoView("", describe, call_back, nil, true, nil, nil, red_text)
end

function MainUIViewTask:SendQuickDone(task_type, task_id)
	TaskCtrl.Instance:SendQuickDone(task_type, task_id)
end

function MainUIViewTask:OperateTask(data)
	TaskData.Instance:SetCurTaskId(data.task_id)
	self:DoTask(data.task_id, data.task_status, true)
end

--任务排序(各种原因引起的任务变化可能短时间内来好几个，延迟一点时间)
function MainUIViewTask:SortTask()
	if nil ~= self.delay_sort_task_timer then
		return
	end

	self.delay_sort_task_timer = GlobalTimerQuest:AddDelayTimer(self.delay_sort_task_fun, 0.5)
end

local old_can_commit_num = 0
function MainUIViewTask:DelaySortTask()
	self.delay_sort_task_timer = nil

	self.task_data = {}
	local task_cfg = nil
	local task_accepted_info_list = TaskData.Instance:GetTaskAcceptedInfoList()
	local task_can_accept_id_list = TaskData.Instance:GetTaskCapAcceptedIdList()

	--主线任务
	local zhu_task_list = TaskData.Instance:GetTaskListIdByType(TASK_TYPE.ZHU)
	local zhu_task_cfg = TaskData.Instance:GetTaskConfig(zhu_task_list[1])

	--若服务端没发来则自己取下一个主线任务
	if zhu_task_cfg == nil then
		zhu_task_cfg = TaskData.Instance:GetNextZhuTaskConfig()
	end

	-- 挂机任务修改成160就出现
	-- local virtual_guaji_task_cfg = nil
	local role_level = PlayerData.Instance:GetRoleVo().level
	if role_level >= 160 then
		virtual_guaji_task_cfg = TaskData.Instance:GetVirtualGuajiTask()
	end

	local virtual_xiulian_task_cfg = nil
	-- local max_chapter = PersonalGoalsData.Instance:GetMaxChapter()
	-- local cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
	-- if OpenFunData.Instance:CheckIsHide("mieshizhizhan") and cur_chapter < max_chapter then
	-- 	virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualXiuLianTask()
	-- end

	if self:CheckIsShowDailyTask() then
		virtual_xiulian_task_cfg = TaskData.Instance:GetVirtualDaliyTask()
	end

	local virtual_begod_task_cfg = nil
	-- if OpenFunData.Instance:CheckIsHide("molongmibaoview") and MolongMibaoData.Instance:IsShowMolongMibao() then
	-- 	virtual_begod_task_cfg = TaskData.Instance:GetVirtualBeGodTask()
	-- end

	-- local virtual_wabao_task_cfg = nil
	-- if WaBaoData.Instance:GetIsShowWaBao() then
	-- 	virtual_wabao_task_cfg = WaBaoData.Instance:GetVirtualWaBaoTask()
	-- end

	local virtual_ling_task_cfg = nil
	if PlayerData.Instance:GetRoleVo().jinghua_husong_status > 0 then
		virtual_ling_task_cfg = TaskData.Instance:GetVirtualLingTask()
	end

	HAS_HUG_TASK = false
	--可提交
	local can_commit_list = {}
	for k,v in pairs(task_accepted_info_list) do
		if v.is_complete ~= 0 then
			task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
			if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
				can_commit_list[#can_commit_list + 1] = task_cfg
			end
			if task_cfg and task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then
				HAS_HUG_TASK = true
			end
		end
	end

	local order_list = {}
	--进行中
	for k,v in pairs(task_accepted_info_list) do
		if v.is_complete == 0 then
			task_cfg = TaskData.Instance:GetTaskConfig(v.task_id)
			if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
				order_list[#order_list + 1] = task_cfg
			end
			if task_cfg and task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then
				HAS_HUG_TASK = true
			end
		end
	end
	-- 可接
	-- 手动加入护送任务
	task_can_accept_id_list[YunbiaoData.Instance.task_ids] = nil
	local max_count = YunbiaoData.Instance:GetHusongRemainTimes() or 0
	-- local commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
	if max_count > 0 then
		local yunbiao_task_cfg = TaskData.Instance:GetTaskConfig(YunbiaoData.Instance.task_ids)
		if yunbiao_task_cfg then
			if yunbiao_task_cfg.min_level <= GameVoManager.Instance:GetMainRoleVo().level then
				if not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids) then
					task_can_accept_id_list[YunbiaoData.Instance.task_ids] = 1
				end
			end
		end
	end
	
	for k,v in pairs(task_can_accept_id_list) do
		task_cfg = TaskData.Instance:GetTaskConfig(k)
		if task_cfg ~= nil and task_cfg.task_type ~= TASK_TYPE.ZHU then
			order_list[#order_list + 1] = task_cfg
		end
	end

	if virtual_xiulian_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_xiulian_task_cfg
	end

	-- if virtual_wabao_task_cfg ~= nil then
	-- 	order_list[#order_list + 1] = virtual_wabao_task_cfg
	-- end

	if virtual_begod_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_begod_task_cfg
	end

	if virtual_guaji_task_cfg ~= nil then
		order_list[#order_list + 1] = virtual_guaji_task_cfg
	end

	--对可提交进行排序
	if #can_commit_list ~= 0 then
		table.sort(can_commit_list, function(a, b) return self:GetSortIndexByConfig(a) < self:GetSortIndexByConfig(b) end)
	end

	--对其他进行排序order_list
	if #order_list ~= 0 then
		table.sort(order_list, function(a, b) return self:GetSortIndexByConfig(a) < self:GetSortIndexByConfig(b) end)
	end
	--合并连接(主线，可提交，其他)
	--主线任务放最前
	if zhu_task_cfg ~= nil then
		local task_id = zhu_task_cfg.task_id
		local task_status = TaskData.Instance:GetTaskStatus(task_id)
		local progress_num
		local task_info = TaskData.Instance:GetTaskInfo(task_id)
		if task_info then
			progress_num = task_info.progress_num
		end
		if TaskData.Instance:GetCurTaskId() and TaskData.Instance:GetCurTaskId() == 0 and (not TASK_GUILD_AUTO or not TASK_RI_AUTO) then
			if self.last_task_id then
				local config = TaskData.Instance:GetTaskConfig(self.last_task_id)
				if config then
					if config.task_type == TASK_TYPE.ZHU then
						TaskData.Instance:SetCurTaskId(task_id)
					end
				end
			end
		end

		self.task_data[1] = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
	end

	if virtual_ling_task_cfg ~= nil then
		self.task_data[#self.task_data + 1] = virtual_ling_task_cfg
	end
	
	local min_zhi_task_id = 99999
	local old_has_guild_task = HAS_GUILD_TASK

	HAS_RI_TASK = false

	local can_commit_num = 0
	for k,v in pairs(can_commit_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
			can_commit_num = can_commit_num + 1
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		elseif v.task_type == TASK_TYPE.GUILD then
			HAS_GUILD_TASK = true
		else
			can_commit_num = can_commit_num + 1
		end
	end
	for k,v in pairs(order_list) do
		if TaskData.IsZhiTask(v) and v.task_id < min_zhi_task_id then
			min_zhi_task_id = v.task_id
		end
		if v.task_type == TASK_TYPE.RI then
			HAS_RI_TASK = true
		end
		if v.task_type == TASK_TYPE.GUILD then
			HAS_GUILD_TASK = true
		end
	end

	HAS_GUILD_TASK = not HAS_RI_TASK and HAS_GUILD_TASK

	if old_has_guild_task == false and HAS_GUILD_TASK then
		CAN_SHOW_GUILD_ARROW = true
	end

	-- if CUR_ZHI_TASK ~= 99999 and CUR_ZHI_TASK ~= min_zhi_task_id and self.package_btn then
	-- 	self:RewardFlyToBag()
	-- end
	local role_level = PlayerData.Instance:GetRoleVo().level
	local old_zhi_task = CUR_ZHI_TASK
	if min_zhi_task_id ~= 99999 then
		CUR_ZHI_TASK = min_zhi_task_id
		local config = TaskData.Instance:GetTaskConfig(CUR_ZHI_TASK)
		local base_prof = PlayerData.Instance:GetRoleBaseProf()
		local reward_list = config["prof_list" .. base_prof]
		local reward = reward_list[0]
		local is_show_eff = false
		if config.exp and CUR_ZHI_TASK <= 17021 then
			reward = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP, num = config.exp, is_bind = 1}
			is_show_eff = true
		end
		self.item_cell:SetData(reward)
		self.item_cell:ShowExtremeEffect(is_show_eff, 10, 5)
	end
	if min_zhi_task_id == 99999 then
		CUR_ZHI_TASK = min_zhi_task_id
	end

	if old_zhi_task ~= CUR_ZHI_TASK then
		CAN_SHOW_ZHI_ARROW = true
	end
	HAS_ZHI_TASK = min_zhi_task_id ~= 99999

	for k,v in ipairs(can_commit_list) do
		local task_id = v.task_id
		local task_status = TASK_STATUS.COMMIT
		local progress_num = TaskData.Instance:GetTaskInfo(task_id).progress_num
		local many_zhi_task = true
		if role_level < GameEnum.MULTI_ZHI_LEVEL then
			many_zhi_task = (v.task_id == min_zhi_task_id and TaskData.IsZhiTask(v))
		else
			many_zhi_task = TaskData.IsZhiTask(v)
		end
		if many_zhi_task or not TaskData.IsZhiTask(v) then
			-- if not HAS_RI_TASK or v.task_type ~= TASK_TYPE.GUILD then
				self.task_data[#self.task_data + 1] = MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
			-- end
		end
	end
	for k,v in ipairs(order_list) do
		local task_id = v.task_id
		local task_status = TaskData.Instance:GetTaskStatus(v.task_id)
		local progress_num
		local info = TaskData.Instance:GetTaskInfo(task_id)
		if info then
			progress_num = info.progress_num
		end
		local many_zhi_task = true
		if role_level < GameEnum.MULTI_ZHI_LEVEL then
			many_zhi_task = (v.task_id == min_zhi_task_id and TaskData.IsZhiTask(v))
		else
			many_zhi_task = TaskData.IsZhiTask(v)
		end
		if v.task_type == TASK_TYPE.LINK or v.task_type == TASK_TYPE.DALIY then
			self.task_data[#self.task_data + 1] = v
		elseif many_zhi_task or not TaskData.IsZhiTask(v) then
			-- if not HAS_RI_TASK or v.task_type ~= TASK_TYPE.GUILD then
				self.task_data[#self.task_data + 1] = MainUIViewTask.TaskCellInfo(v.task_id, task_status, progress_num)
			-- end
		end
	end
	self:SortTaskToFirst()
	if self.is_load and nil == TaskData.Instance:GetCurrentChapterCfg() then
		if self.node_list["NormalTask"] then
			self.node_list["NormalTask"]:SetActive(true)
		end
		if self.node_list["TabButtons"] then
			self.node_list["TabButtons"]:SetActive(true)
		end
		if self.node_list["ShrinkButtons"] then
			self.node_list["ShrinkButtons"]:SetActive(true)
		end
		if self.node_list["TaskButton"] then
			self.node_list["TaskButton"]:SetActive(true)
		end
		if self.node_list["ChapterTask"] then
			self.node_list["ChapterTask"]:SetActive(false)
		end
		if self.node_list["NodeChapterStep"] then
			self.node_list["NodeChapterStep"]:SetActive(false)
		end
		if self.node_list["TaskList"] and self.node_list["TaskList"].gameObject.activeInHierarchy then
			if old_can_commit_num < can_commit_num then --可提交数量有变时跳到最上面
				self.node_list["TaskList"].scroller:ReloadData(0)
			else
				self.node_list["TaskList"].scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
		old_can_commit_num = can_commit_num
	end
	MainUIData.Instance:SetTaskData(self.task_data)
	IosAuditSender:UpdateTaskData()
	
end

function MainUIViewTask:RewardFlyToBag(data)
	if self.is_move == true then return end
	self.move_cell:SetActive(true)
	if not IsNil(self.item_cell.root_node.gameObject) then
		self.item_cell.root_node.rect.sizeDelta = Vector2(67, 67)
	end

	local UILayer = GameObject.Find("GameRoot/UILayer")

	local old_parent = self.move_cell.transform.parent
	local old_pos = self.move_cell.transform.localPosition
	self.move_cell.transform:SetParent(UILayer.transform, true)

	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, self.package_btn.transform.position)

	--转换屏幕坐标为本地坐标
	local rect = UILayer:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))

	local target_pos = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)

	local close_view = function()
		self.move_cell.transform:SetParent(old_parent.transform, false)
		self.move_cell.transform.localPosition = old_pos
		self.move_cell:SetActive(false)
		self.is_move = false
		-- ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZHIXIAN_TASK_REWARD)
		self:OperateTask(data)
	end
	self.is_move = true
	self.cur_move:MoveTo(target_pos, 1.7, close_view)
end

-- 倒计时函数
function MainUIViewTask:CountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewTask:SetPackage(package_btn)
	self.package_btn = package_btn
end

function MainUIViewTask:RefreshChapterTask(chapter_cfg)
	if nil == chapter_cfg then
		return
	end
	self.node_list["NormalTask"]:SetActive(false)
	-- self.node_list["TeamButton"]:SetActive(false)
	self.node_list["TabButtons"]:SetActive(false)
	self.node_list["ShrinkButtons"]:SetActive(false)
	self.node_list["TaskButton"]:SetActive(false)
	self.node_list["ChapterTask"]:SetActive(true)
	self.node_list["NodeChapterStep"]:SetActive(true)
	

	local task_cfg = TaskData.Instance:GetZhuTaskConfig()
	local end_task_cfg = TaskData.Instance:GetTaskConfig(chapter_cfg.end_taskid)

	if nil == task_cfg or nil == end_task_cfg or "" == task_cfg.now_index then
		return
	end

	self.node_list["TxtChapterName"].text.text = chapter_cfg.name
	self.node_list["TxtChapterStep"].text.text = string.format(Language.Mainui.ChapterStep, CommonDataManager.GetDaXie(chapter_cfg.zhangjie))
	self.node_list["TxtTaskDesc"].text.text = task_cfg.task_desc

	local percent = (task_cfg.now_index - 1) / end_task_cfg.now_index
	self.node_list["Slider"].slider.value = percent
	self.node_list["TxtChapterPercent"].text.text = math.floor(percent * 100) .. "%"

	local state = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
	if TASK_STATUS.CAN_ACCEPT == state or TASK_STATUS.NONE == state then
		self.node_list["TxtTaskCondition"].text.text = task_cfg.accept_desc
		self.node_list["TxtBtn"].text.text = Language.Task.task_status[1]

	elseif TASK_STATUS.ACCEPT_PROCESS == state then
		self.node_list["TxtBtn"].text.text = Language.Task.task_status[2]

		if(task_cfg.c_param2 == 0) then
			self.node_list["TxtTaskCondition"].text.text = task_cfg.progress_desc
		else
			local current_count = TaskData.Instance:GetProgressNum(task_cfg.task_id)
			self.node_list["TxtTaskCondition"].text.text = MainUIViewTask.ChangeTaskProgressString(task_cfg.progress_desc, current_count, task_cfg.c_param2)
		end

	elseif TASK_STATUS.COMMIT == state then
		self.node_list["TxtBtn"].text.text = Language.Task.task_status[3]
		self.node_list["TxtTaskCondition"].text.text = task_cfg.commit_desc

	else
		self.node_list["TxtTaskCondition"].text.text = "error"
	end
end

function MainUIViewTask:OnTouchChapterTask()
	local task_cfg = TaskData.Instance:GetZhuTaskConfig()
	if nil == task_cfg then
		return
	end

	local task_status = TaskData.Instance:GetTaskStatus(task_cfg.task_id)
	self:OperateTask(MainUIViewTask.TaskCellInfo(task_cfg.task_id, task_status, 0))
end

-- 改变任务进程的字符串
local color = "#ffffff"
function MainUIViewTask.ChangeTaskProgressString(old_string, current_count, total_count)
	color = current_count < total_count and TEXT_COLOR.RED or TEXT_COLOR.GREEN
	old_string = string.gsub(old_string, "<per>1", "<color=" .. color .. ">" ..current_count)
	old_string = string.gsub(old_string, "10</per>", total_count .. "</color>")
	return old_string
end


--把转职任务放在第一位
function MainUIViewTask:SortTaskToFirst()
	local zhu_task_data = nil
	local role_level = PlayerData.Instance:GetRoleVo().level
	if self.task_data[1] and self.task_data[1].task_type == TASK_TYPE.ZHU then
		local config = TaskData.Instance:GetTaskConfig(self.task_data[1].task_id)
		if config and config.min_level > role_level then
			zhu_task_data = self.task_data[1]
			table.remove(self.task_data, 1)
			if TaskData.Instance:GetTaskCount(TASK_TYPE.RI) > 0 then
				CAN_SHOW_ZHU_ARROW = true
			end
		end
	end
	local zhi_key = nil
	local zhi_task_cfg = nil
	for k, v in pairs(self.task_data) do
		if TaskData.IsZhiTask(v) then
			zhi_key = k
			zhi_task_cfg = v
			break
		end
	end

	if role_level < GameEnum.NOVICE_LEVEL and nil ~= zhi_key and nil ~= zhi_task_cfg then
		table.remove(self.task_data, zhi_key)
		table.insert(self.task_data, 1, zhi_task_cfg)
	end
	
	local zhuan_key = nil
	local zhuan_task_cfg = nil
	for k1,v1 in pairs(self.task_data) do
		if v1.task_type == TASK_TYPE.ZHUANZHI then
			zhuan_key = k1
			zhuan_task_cfg = v1
			break
		end
	end
	if nil ~= zhuan_key and nil ~= zhuan_task_cfg then
		table.remove(self.task_data, zhuan_key)
		table.insert(self.task_data, 1, zhuan_task_cfg)
	end

	local daily_virtual_key = nil
	if zhu_task_data then
		for k, v in ipairs(self.task_data) do
			if v.task_type == TASK_TYPE.RI or
				v.task_type == TASK_TYPE.GUILD or
				v.task_type == TASK_TYPE.LINK or
				v.task_type == TASK_TYPE.HUAN or
				v.task_type == TASK_TYPE.DALIY then
				if daily_virtual_key == nil or daily_virtual_key < k then
					daily_virtual_key = k
				end
			end
		end
	end

	if zhu_task_data then
		local index = 0
		if daily_virtual_key then
			index = math.min(daily_virtual_key + 1, #self.task_data + 1)
		else
			index = math.min(2, #self.task_data + 1)
		end
		table.insert(self.task_data, index, zhu_task_data)
	end

	--功能开启,如果未加入公会则增加加入公会一列
	if OpenFunData.Instance:CheckIsHide("guild_task") then
		if GameVoManager.Instance:GetMainRoleVo().guild_id == 0 then
			local data = {}
			data.task_id = -1
			table.insert(self.task_data, data)
		end
	end
end

--为任务增加排序索引，勿模防,
--主线、日常、仙盟、护送、支线
function MainUIViewTask:GetSortIndexByConfig(task_cfg)
	if task_cfg and task_cfg.order_index == nil then
		if task_cfg.task_type == TASK_TYPE.ZHU then      --主线
			return 1000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.ZHI then  --支线
			return 6000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.RI then   --日常
			return 4000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.GUILD then  --仙盟
			return 8000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HU then 		--护送
			return 9000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.CAMP then 	--阵营
			return 2000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.HUAN then 	--跑环
			return 5000000 + task_cfg.task_id
		elseif task_cfg.task_type == TASK_TYPE.LINK then 	--打开面板
			if task_cfg.task_id == 999996 then
				return 9100000 + task_cfg.task_id 			-- 挂机任务放在最后
			else
				return 7000000 + task_cfg.task_id
			end

		else
			return 0
		end
	end
	return 0
end

-- 停止任务
function MainUIViewTask:StopTask()
	GuajiCtrl.Instance:StopGuaji()
end

-- 执行任务
function MainUIViewTask:DoTask(task_id, task_status, is_active)
	if Scene.Instance:GetSceneType() ~= SceneType.Common or MarriageData.Instance:GetOwnIsXunyou() then
		return
	end
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if nil == task_cfg then
		task_cfg = TaskData.Instance:GetVirtualTaskCfg(task_id)
	end

	if nil == task_cfg then
		return
	end
	CUR_TASK = task_id
	GuajiType.IsManualState = false
	if task_cfg.task_type == TASK_TYPE.LINK then
		if task_cfg.open_panel_name == ViewName.YewaiGuajiView then
			local guaiwuIndex = YewaiGuajiData.Instance:GetGuaiwuIndex()
			local guaji_pos = YewaiGuajiData.Instance:GetGuajiPos(guaiwuIndex)
			local callback = function()
				YewaiGuajiCtrl.Instance:GoGuaji(guaji_pos[1],guaji_pos[2],guaji_pos[3])
			end
			callback()
			GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
			return
		end
		ViewManager.Instance:Open(task_cfg.open_panel_name)
		return
	end

	if task_cfg.task_type == TASK_TYPE.DALIY then
		local daily_data = ZhiBaoData.Instance:GetFirstTask()
		if daily_data then
			if ZhiBaoData.Instance:GetActiveDegreeListByIndex(daily_data.type) >= daily_data.max_times then
				ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
			else
				ActiveDegreeScrollCell.OnGoClick(daily_data)
			end
		else
			ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
		end
		return
	end

	TaskData.Instance:SetCurTaskId(task_id)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	if nil == task_cfg then
		print_warning("cfg为空")
		return
	end
	if task_cfg.task_type == TASK_TYPE.ZHU then
		self.node_list["GuideArrow"]:SetActive(false)
		MainUIViewTask.SHOW_GUIDE_ARROW = false
	end
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if task_cfg.min_level > level then
		if TASK_STATUS.CAN_ACCEPT == task_status then
			if GuajiCache.guaji_type == GuajiType.HalfAuto then
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			end
		end
		return
	end
	-- local mainr_role = Scene.Instance:GetMainRole()

	if self.move_task_deily then
		GlobalTimerQuest:CancelQuest(self.move_task_deily)
		self.move_task_deily = nil
	end
	if task_status == TASK_STATUS.CAN_ACCEPT and task_cfg.task_type ~= TASK_TYPE.GUILD then
		-- 护送任务无视vip等级传送
		if task_cfg.task_type == TASK_TYPE.HU then
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
		elseif task_cfg.task_type == TASK_TYPE.ZHUANZHI then
			TaskCtrl.SendTaskAccept(task_cfg.task_id)
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
		end
	elseif task_status == TASK_STATUS.ACCEPT_PROCESS or (task_cfg.task_type == TASK_TYPE.GUILD and task_status == TASK_STATUS.CAN_ACCEPT) then
		-- 功能开启副本
		-- if StoryCtrl.Instance:GetFunOpenFbTypeByTaskId(task_id) > 0 then
		-- 	local cfg = StoryCtrl.Instance:GetFbCfg(task_id)
		--  	if next(cfg) then
		--  		-- 移动到传送门
		--  		GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
		-- 		MoveCache.end_type = MoveEndType.DoNothing
		-- 		GuajiCtrl.Instance:MoveToPos(cfg.door_scene_id, cfg.door_x, cfg.door_y, 2, 0)
		-- 	end
		-- 	return
		-- end
		if task_id == FAkE_TRUCK then
			local list = {}
			if task_cfg.c_param3 and task_cfg.c_param3 ~= "" and task_cfg.c_param3 > 0 then
				list = ConfigManager.Instance:GetSceneConfig(task_cfg.c_param3).npcs or {}
			end
			local target = {}
			for k,v in pairs(list) do
				if v.id == task_cfg.c_param1 then
					target.id = v.id
					target.scene = task_cfg.c_param3
					target.x = v.x
					target.y = v.y
				end
			end
			if next(target) then
				self:MoveToTarget(target, MoveEndType.NpcTask, task_id, is_active)
			end
			return
		end

		if TASK_ACCEPT_OP.ENTER_FB == task_cfg.accept_op and "" ~= task_cfg.a_param1 and "" ~= task_cfg.a_param2 then  -- 进入副本
			FuBenCtrl.Instance:SendEnterFBReq(task_cfg.a_param1, task_cfg.a_param2)
			return
		end

		if TASK_ACCEPT_OP.OPEN_GUIDE_FB_ENTRANCE == task_cfg.accept_op then -- 进入引导副本
			StoryCtrl.Instance:OpenEntranceView(GameEnum.FB_CHECK_TYPE.FBCT_GUIDE, task_id)
			return
		end

		if TASK_ACCEPT_OP.ENTER_DAILY_TASKFB == task_cfg.accept_op then -- 进入日常任务副本
			self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
			return
		end

		if task_cfg.open_panel_name ~= "" then
			local open_param_t = Split(task_cfg.open_panel_name, "#")
			if open_param_t and open_param_t[1] then
				local index = open_param_t[2] and TabIndex[open_param_t[2]]
				if open_param_t[1]  == ViewName.SpiritView and nil ~= open_param_t[3] then
					SpiritData.Instance:SetOpenParam(open_param_t[3])
				end
				local param_t = open_param_t[1]
				local tab_index = index
				if open_param_t[1] == ViewName.Guild and index == TabIndex.guild_altar then
					local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
					if guild_id < 1 then
						tab_index = TabIndex.guild_request
					end
				end

				if open_param_t[1] == ViewName.Player and nil == open_param_t[2] then
					ViewManager.Instance:Open(param_t, tab_index, "select_equip", {true})
				elseif open_param_t[1] == ViewName.FuBen and nil ~= open_param_t[3] then
					ViewManager.Instance:Open(param_t, tab_index, "task_fb_phase", {open_param_t[3]})
				elseif open_param_t[1] == ViewName.Forge and nil ~= open_param_t[3] then
					ViewManager.Instance:Open(param_t, tab_index, "task_forge_advance", {open_param_t[3]})
				else
					ViewManager.Instance:Open(param_t, tab_index)
				end
				-- self:StopTask()
			end
			return
		end

		if type(task_cfg.target_obj) ~= "table" then
			self:ClearToggle()
			SysMsgCtrl.Instance:ErrorRemind("任务表配置的target_obj是null")
			return
		end
		local first_target = task_cfg.target_obj[1]
		if nil == first_target and task_cfg.condition ~= TASK_COMPLETE_CONDITION.HUG and task_cfg.condition ~= TASK_COMPLETE_CONDITION.PASS_FB_LAYE 
			and task_cfg.condition ~= TASK_COMPLETE_CONDITION.TASK_COMPLETE_CONDITION_16 and task_cfg.condition ~= TASK_COMPLETE_CONDITION.REACH_STATE then
			return
		end
		if task_cfg.condition == TASK_COMPLETE_CONDITION.NPC_TALK or (task_cfg.condition == TASK_COMPLETE_CONDITION.HUG and task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.CHANGE_MODE_TASK_TYPE_FLY) then			-- 与npc对话任务
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			if task_cfg.accept_op ~= 2 or (task_cfg.commit_npc and task_cfg.commit_npc.scene == Scene.Instance:GetSceneId()) then
				self:MoveToTarget(first_target, MoveEndType.NpcTask, task_id, is_active)
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, first_target, MoveEndType.NpcTask, task_id), 0.5)
			end
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.HUG then			-- 抱东西
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			local list = {}
			local move_end_type = nil
			if task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.GATHER then
				list = ConfigManager.Instance:GetSceneConfig(task_cfg.c_param3).gathers or {}
				move_end_type = MoveEndType.GatherById
			elseif task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.TALK_TO_NPC then
				list = ConfigManager.Instance:GetSceneConfig(task_cfg.c_param3).npcs or {}
				move_end_type = MoveEndType.NpcTask
			elseif task_cfg.c_param1 == CHANGE_MODE_TASK_TYPE.TALK_IMAGE and task_cfg.commit_npc ~= "" and task_cfg.commit_npc ~= 0 then
				if task_cfg.task_type == TASK_TYPE.RI then
					self:MoveToTarget(task_cfg.accept_npc, MoveEndType.NpcTask, task_id, is_active)
				else
					self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
				end
				return
			end
			local target = {}
			for k,v in pairs(list) do
				if v.id == task_cfg.c_param2 then
					target.id = v.id
					target.scene = task_cfg.c_param3
					target.x = v.x
					target.y = v.y
				end
			end
			if next(target) then
				if task_cfg.c_param3 == Scene.Instance:GetSceneId() then
					self:MoveToTarget(target, move_end_type, task_id, is_active)
				else
					self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, target, move_end_type, task_id), 0.5)
				end
			end	
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then	-- 打怪任务
			if GuajiCache.guaji_type == GuajiType.Monster and GuajiCache.monster_id == first_target.id and not is_active then
				return
			end
			local target = Scene.Instance:SelectMinDisMonster(task_cfg.target_obj[1].id, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
			if target then
				local x, y = target:GetLogicPos()
				target = {scene = Scene.Instance:GetSceneId(), x = x, y = y, id = task_cfg.target_obj[1].id}
			else
				target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]
			end

			GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
			GuajiCache.monster_id = target.id

			self:MoveToTarget(target, MoveEndType.FightByMonsterId, task_id, is_active)
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.GATHER then		-- 采集任务
				GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
				local target = task_cfg.target_obj[math.floor(math.random(1, #task_cfg.target_obj))]

				local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[target.id]
				if gather_cfg and gather_cfg.is_animation and gather_cfg.is_animation == 1 then
					local rand_list = GameMath.RandList(1, #task_cfg.target_obj, #task_cfg.target_obj)
					for k,v in pairs(rand_list) do
						local cur_target = task_cfg.target_obj[v]
						local is_exist = TaskData.Instance:GetEmptyGatherIsExist(cur_target)
						if not is_exist then
							target = cur_target
							if not (nil ~= self.last_target and target.x == self.last_target.x and target.y == self.last_target.y) then
								break
							end
						end
					end
					self.last_target = target
				end
				self:MoveToTarget(target, MoveEndType.GatherById, task_id, is_active)
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.PASS_FB_LAYE then		-- 通关副本层数
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_ZHUANZHI_FB, 0)
		elseif task_cfg.condition == TASK_COMPLETE_CONDITION.TASK_COMPLETE_CONDITION_16 then		-- 收集物品
			TaskData.Instance.shang_rand_monst_id = 0
			local temp_monst_id = TaskData.Instance:GetRandomMonstID(task_cfg.a_param1, task_cfg.a_param2)
			if temp_monst_id > 0 then
				local temp_monst_cfg = TaskData.Instance:GetMonstTargetCfgList(temp_monst_id)
				if temp_monst_cfg ~= nil then
					local target = {scene = temp_monst_cfg.scene_id, x = temp_monst_cfg.monst_x, y = temp_monst_cfg.monst_y, id = temp_monst_id}
					self:MoveToTarget(target, MoveEndType.FightByMonsterId, task_id, is_active)
					GuajiCache.monster_id = target.id
					GuajiCtrl.Instance:SetGuajiType(GuajiType.Monster)
				end
			end
		end
	elseif task_status == TASK_STATUS.COMMIT then
		if task_cfg.task_type == TASK_TYPE.RI and task_cfg.condition ~= TASK_COMPLETE_CONDITION.HUG and task_id ~= FAkE_TRUCK then
			TaskCtrl.SendTaskCommit(task_id)
			-- ViewManager.Instance:OpenViewByName(ViewName.Daily, TabIndex.daily_renwu)
		elseif task_cfg.commit_npc == "" or task_cfg.commit_npc == 0 or nil == task_cfg.commit_npc.scene then		-- 没配npc直接完成
			TaskCtrl.SendTaskCommit(task_id)
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			
			if task_cfg.task_type == TASK_TYPE.ZHUANZHI then
				ViewManager.Instance:CloseAll()
			end

			if task_cfg.accept_op ~= 2 or (task_cfg.commit_npc and task_cfg.commit_npc.scene == Scene.Instance:GetSceneId()) then
				-- if mainr_role and mainr_role:IsAtk() then
				-- 	mainr_role:ChangeToCommonState()
				-- 	if not self.delay_dotask_timer then
				-- 		local func = function()
				-- 			self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
				-- 			if self.delay_dotask_timer then
				-- 				GlobalTimerQuest:CancelQuest(self.delay_dotask_timer)
				-- 				self.delay_dotask_timer = nil
				-- 			end
				-- 		end
				-- 		self.delay_dotask_timer = GlobalTimerQuest:AddDelayTimer(func, 2)
				-- 	end
				-- else
					self:MoveToTarget(task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active)
				-- end
			else
				self.move_task_deily = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.MoveToTarget, self, task_cfg.commit_npc, MoveEndType.NpcTask, task_id, is_active), 0.5)
			end
		end
	end
end

function MainUIViewTask:MoveToTarget(target, end_type, task_id, is_active)
	if is_active then
		local main_role = Scene.Instance:GetMainRole()
		if main_role and main_role:IsMove()
			and (MoveCache.end_type == end_type or (MoveCache.end_type == MoveEndType.ClickNpc and end_type == MoveEndType.NpcTask))
			and MoveCache.task_id == task_id then
			return
		end
	end
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() ~= SceneType.Common then
			self:ClearToggle()
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end
	end
	if nil ~= target and type(target) == "table" then
		local callback = function()
			GuajiCtrl.Instance:ClearAllOperate()
			GuajiCtrl.Instance:CancelSelect()
			MoveCache.end_type = end_type
			MoveCache.param1 = target.id
			MoveCache.task_id = task_id
			GuajiCache.target_obj_id = target.id
			local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
			-- 采集距离有问题先临时处理一下
			local range = 4
			if end_type == MoveEndType.GatherById then
				range = 1
			elseif end_type == MoveEndType.FightByMonsterId then
				range = SkillData.Instance:GetProfSkillRange()
			end
			GuajiCtrl.Instance:MoveToPos(target.scene, target.x, target.y, range, 2, false, scene_key)
		end
		callback()
		GuajiCtrl.Instance:SetMoveToPosCallBack(callback)
	end
end

-- 构造任务数据
function MainUIViewTask.TaskCellInfo(task_id, task_status, progress_num)
	local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
	return {
		task_id = task_id,
		task_name = task_cfg and task_cfg.task_name or "",
		task_type = task_cfg and task_cfg.task_type or 0,
		task_status = task_status,
		progress_num = progress_num,
	}
end

function MainUIViewTask:DayCountChange(day_counter_id)
	-- 护送完成次数
	if DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT == day_counter_id or day_counter_id == -1 then
		self:SortTask()
	end
end

function MainUIViewTask:VirtualTaskChange()
	self:SortTask()
end

function MainUIViewTask:GetUiCallBack(ui_name)
	if ui_name == GuideUIName.TaskZhiItem then
		for _, v in pairs(self.cell_list) do
			local task_data = v:GetData() or {}
			if task_data.task_type == TASK_TYPE.ZHI then
				if v.root_node.transform.gameObject.activeInHierarchy then
					self.guide_task_id = task_data.task_id
					return v.root_node, BindTool.Bind(self.OpenGuideTaskZhiview, self)
				end
			end
		end
	end
	return nil
end

function MainUIViewTask:OpenGuideTaskZhiview()
	if nil == self.guide_task_id then return end
	local task_cfg = TaskData.Instance:GetTaskConfig(self.guide_task_id)
	if task_cfg and task_cfg.open_panel_name ~= "" then
		local open_param_t = Split(task_cfg.open_panel_name, "#")
		if open_param_t and open_param_t[1] then
			local index = open_param_t[2] and TabIndex[open_param_t[2]]
			local param_t = open_param_t[1]
			local tab_index = index
			ViewManager.Instance:Open(param_t, tab_index)
		end
	end
end

function MainUIViewTask:CheckIsShowDailyTask()
	if OpenFunData.Instance:CheckIsHide("daily") and ZhiBaoData.Instance:GetFirstTask() and TaskData.Instance:GetTaskCount(TASK_TYPE.RI) <= 0 then
		return true
	else
		return false
	end
end

-- 修复每日必做消失的bug
--（暂时没有找到原因）
function MainUIViewTask:FixDailyBug()
	self:RemoveDailyBugCountDown()
	self.daily_bug_count_down = CountDown.Instance:AddCountDown(60, 2, BindTool.Bind(self.UpdateFixDailyBug, self))
end

function MainUIViewTask:UpdateFixDailyBug(elapse_time, total_time)
	local has_daily_task = false
	for k,v in pairs(self.task_data) do
		if v.task_type == TASK_TYPE.DALIY then
			has_daily_task = true
			break
		end
	end
	if has_daily_task then
		self:RemoveDailyBugCountDown()
		return
	end
	-- 如果满足每日必做的条件，但是任务列表里面又不存在，则强制刷新任务列表
	if self:CheckIsShowDailyTask() then
		self:SortTask()
	end
end

function MainUIViewTask:RemoveDailyBugCountDown()
	if self.daily_bug_count_down then
		CountDown.Instance:RemoveCountDown(self.daily_bug_count_down)
		self.daily_bug_count_down = nil
	end
end

function MainUIViewTask:PlayerDataListen(attr_name)
	if attr_name == "guild_id" then
		self:SortTask()
	end
end

function MainUIViewTask:CompletedSceneEventLogic(task_id)
	if TaskData.Instance:GetShiQiaoShowTask() == task_id then
		Scene.Instance:SetShiqiaoIsShield(Scene.Instance:GetSceneId())
	elseif TaskData.Instance:GetMountTaskId() == task_id then
		Scene.Instance:SetMountNpcIsShield()
	end
end
--------------------------------------------------------------- MainUIViewTaskInfo ------------------------------------------------------------

MainUIViewTaskInfo = MainUIViewTaskInfo or BaseClass(BaseCell)

function MainUIViewTaskInfo:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.node_list["ItemCell"])
	self.is_show_arrow = false
	self.data_index = 0
	self.effect_task = 0
end

function MainUIViewTaskInfo:__delete()
	self.item_cell:DeleteMe()
	self:RemoveCountDown()
end

function MainUIViewTaskInfo:ListenClick(handler)
	self.node_list["ToggleTaskInfo"].toggle:AddClickListener(function()
			handler:OnTaskCellClick(self.data)
			if self.effect_task > 0 then
				CLICK_EFFECT_TASK = self.effect_task
			end
			self.node_list["Effect"]:SetActive(false)
		end)
end

function MainUIViewTaskInfo:ListenQuickDone(handler)
	self.node_list["BtnQuickDone"].button:AddClickListener(function() handler:OnClickQuickDone(self.data) end)
end

function MainUIViewTaskInfo:SetHandle(handler)
	self.handler = handler
end

function MainUIViewTaskInfo:IsShowArrowEff()
	return self.is_show_arrow
end

function MainUIViewTaskInfo:SetShowArrowEff(is_show)
	if is_show then
		ARROW_TASK_ID = self.data.task_id
	elseif ARROW_TASK_ID == self.data.task_id then
		ARROW_TASK_ID = 0
	end
	if nil == self.data or self.is_show_arrow == is_show then return end
	self.is_show_arrow = is_show
	self.node_list["ImgTaskArrow"]:SetActive(is_show)
end

function MainUIViewTaskInfo:SetIndex(index)
	self.data_index = index
end

function MainUIViewTaskInfo:GetTaskId()
	return nil ~= self.data and self.data.task_id or 0
end

function MainUIViewTaskInfo:OnFlush()
	self.node_list["BtnQuickDone"]:SetActive(false)
	self.node_list["NodeShowItem"]:SetActive(false)
	self.node_list["Effect"]:SetActive(false)
	self:SetTaskEffectFlag()
	if nil == self.data then
		return
	end

	local data = self.data
	if data.task_id == -1 then --提示加入公会领取任务
		local bundle, asset =  ResPath.GetMainUI("tasktype_" .. 4)
		self.node_list["TxtTaskType"].image:LoadSpriteAsync(bundle, asset)

		self.node_list["TxtName"].text.text = Language.Task.task_title[4]
		self.node_list["TxtDesc"].text.text = Language.Task.JoinGuild
		return
	end
	if self.node_list["BtnQuickDone"] then
		self.node_list["BtnQuickDone"].image:LoadSpriteAsync(ResPath.GetMainUI("btn_quick"))
	end
	local role_level = PlayerData.Instance:GetRoleVo().level
	local config = TaskData.Instance:GetTaskConfig(data.task_id)

	if role_level <= GameEnum.NOVICE_LEVEL and (ARROW_TASK_ID <= 0 or ARROW_TASK_ID == data.task_id) and
		((data.task_type == TASK_TYPE.ZHU and config and config.min_level <= role_level and CAN_SHOW_ZHU_ARROW)
		or (TaskData.IsArrowZhiTask(data.task_id) and CAN_SHOW_ZHI_ARROW)
		or data.task_type == TASK_TYPE.GUILD and CAN_SHOW_GUILD_ARROW) --第一个支线
		 then

		self:SetShowArrowEff(true)
	else
		self:SetShowArrowEff(false)
	end

	if data.task_type == TASK_TYPE.ZHU then
		if role_level <= GameEnum.NOVICE_LEVEL and CAN_DO_ZHU_TASK and config and config.min_level > role_level then
			TaskData.Instance:SetCurTaskId(0)
			TASK_RI_AUTO = true
			TaskCtrl.Instance:SetAutoTalkState(true)
		end
		CAN_DO_ZHU_TASK = config and config.min_level <= role_level or false
	end
	local bundle, asset = ResPath.GetMainUI("tasktype_" .. data.task_type or 1)
	self.node_list["TxtTaskType"].image:LoadSpriteAsync(bundle, asset)

	local task_pre_str = ""
	if data.task_type == TASK_TYPE.RI or data.task_type == TASK_TYPE.GUILD or data.task_type == TASK_TYPE.HUAN or
	 (data.task_type == TASK_TYPE.HU and not TaskData.Instance:GetTaskIsAccepted(YunbiaoData.Instance.task_ids)) then
		local commit_count = 0
		local max_count = 0
		if data.task_type == TASK_TYPE.RI then
			max_count = MAX_DAILY_TASK_COUNT
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_COMMIT_DAILY_TASK_COUNT) + 1, max_count)
			

			local free_double_vip = TaskData.Instance:GetFreeVipLevel()
			local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
			local bundle, asset = "", ""
			if free_double_vip <= vip_level then
				self.node_list["BtnQuickDone"]:SetActive(true)
				bundle, asset = ResPath.GetMainUI("btn_san")
				self.node_list["BtnQuickDone"].image:LoadSpriteAsync(bundle, asset)
			-- else
			-- 	bundle, asset =  ResPath.GetMainUI("btn_double")
			end
			
		elseif data.task_type == TASK_TYPE.HUAN then
			max_count = TaskData.Instance:GetMaxPaohuanTaskCount()
			commit_count = TaskData.Instance:GetPaohuanTaskInfo().commit_times or 0
			local skip_paohuan_task_limit_level = TaskData.Instance:GetQuickCompletionMinLevel()
			local  level = PlayerData.Instance:GetRoleVo().level
			if max_count - commit_count > 0 and level >= skip_paohuan_task_limit_level then
				self.node_list["BtnQuickDone"]:SetActive(true)
			end
			-- 自动提交任务
			if data.task_status == TASK_STATUS.COMMIT then
				TaskCtrl.SendTaskCommit(data.task_id)
			end
			-- if data.task_status == TASK_STATUS.ACCEPT_PROCESS and TASK_HUAN_AUTO then
			-- 	TaskCtrl.Instance:DoTask(data.task_id, TASK_STATUS.CAN_ACCEPT)
			-- end
		elseif data.task_type == TASK_TYPE.GUILD then
			max_count = TaskData.Instance:GetMaxGuildTaskCount()
			commit_count = math.min(DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) + 1, max_count)
			self.node_list["BtnQuickDone"]:SetActive(true)
		elseif data.task_type == TASK_TYPE.HU then
			max_count = YunbiaoData.Instance:GetHusongRemainTimes() + YunbiaoData.Instance:GetLingQuCishu()
			commit_count = YunbiaoData.Instance:GetLingQuCishu() or 0
		end
		task_pre_str = "(<color=#ffffff>" .. commit_count .. "/" .. max_count.. "</color>)"
	end

	if config then
		if TaskData.IsZhiTask(data) then
			local base_prof = PlayerData.Instance:GetRoleBaseProf()
			local reward_list = config["prof_list" .. base_prof]
			local reward = reward_list[0]
			local is_show_eff = false
			if config.exp and data.task_id <= 17021 then -- 支线前面几个特殊显示
				reward = {item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP, num = config.exp, is_bind = 1}
				is_show_eff = true
			end
			self.item_cell:SetData(reward)
			self.item_cell:ShowExtremeEffect(is_show_eff, 10, 5)
			self.node_list["NodeShowItem"]:SetActive(nil ~= reward_list[0])
		end
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if config.min_level > role_level then
			self.node_list["Effect"]:SetActive(false)
			self.node_list["TxtName"].text.text = ToColorStr(data.task_name .. task_pre_str)
			self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.GoOn, PlayerData.GetLevelString(config.min_level, true)), COLOR.WHITE)
		else
			self.node_list["TxtName"].text.text = data.task_name .. task_pre_str
			if data.task_type == TASK_TYPE.RI and TaskData.DoDailyTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				-- local reward_cfg = TaskData.Instance:GetTaskReward(data.task_type)
				local factor = TaskData.Instance:GetExpFactor(data.task_type)
				factor = factor or 1
				local level = GameVoManager.Instance:GetMainRoleVo().level
				local cfg_exp = PlayerData.Instance:GetFBExpByLevel(level)
				local exp = cfg_exp and cfg_exp * factor or 0
				self.node_list["TxtDesc"].text.text = string.format(Language.Task.FinishExp, CommonDataManager.ConverExp2(exp * MAX_DAILY_TASK_COUNT))
			elseif data.task_type == TASK_TYPE.GUILD and TaskData.DoGuildTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				local reward_cfg = TaskData.Instance:GetTaskReward(data.task_type)
				local gongxian = 0
				if reward_cfg and reward_cfg.gongxian > 0 then
					gongxian = reward_cfg.gongxian
				end
				self.node_list["TxtDesc"].text.text = string.format(Language.Task.FinishXianMengGongXian, CommonDataManager.ConverNum(gongxian * TaskData.Instance:GetMaxGuildTaskCount()))
			elseif data.task_type == TASK_TYPE.HUAN and TaskData.DoHuanTaskTime > 60 and data.task_status ~= TASK_STATUS.COMMIT then
				local factor = TaskData.Instance:GetExpFactor(data.task_type)
				factor = factor or 1
				local level = GameVoManager.Instance:GetMainRoleVo().level
				local cfg_exp = PlayerData.Instance:GetFBExpByLevel(level)
				local exp = cfg_exp and cfg_exp * factor or 0
				self.node_list["TxtDesc"].text.text = string.format(Language.Task.FinishExp, CommonDataManager.ConverExp(exp * TaskData.Instance:GetPaoHuanNum()))				
			elseif(data.task_status == TASK_STATUS.CAN_ACCEPT) then
				self.node_list["TxtDesc"].text.text = config.accept_desc
			elseif(data.task_status == TASK_STATUS.ACCEPT_PROCESS) then
				if(config.c_param2 == 0) then
					self.node_list["TxtDesc"].text.text = config.progress_desc
				else
					local current_count = TaskData.Instance:GetProgressNum(data.task_id)
					local str = MainUIViewTask.ChangeTaskProgressString(config.progress_desc, current_count, config.c_param2)
					self.node_list["TxtDesc"].text.text = str
				end
			elseif(data.task_status == TASK_STATUS.COMMIT) then
				local color = data.task_type == TASK_TYPE.ZHI and TEXT_COLOR.GREEN or TEXT_COLOR.WHITE
				self.node_list["TxtDesc"].text.text = ToColorStr(config.commit_desc, color)
			else
				self.node_list["TxtDesc"].text.text = Language.Common.WuFaLingQu
			end
		end
	else
		if data.task_type == TASK_TYPE.LINK then
			local bundle, asset =  ResPath.GetMainUI("tasktype_" .. data.task_type or 1)
			self.node_list["TxtTaskType"].image:LoadSpriteAsync(bundle, asset)

			self.node_list["TxtName"].text.text = Language.Task.link_title[self.data.decs_index]
			self.node_list["TxtDesc"].text.text = string.format(Language.Task.link_desc[self.data.decs_index], 0 , 0 , 0)
			local cur_chapter, total_num, finish_num = 0, 0, 0
			if self.data.decs_index == 1 then
				-- cur_chapter = PersonalGoalsData.Instance:GetOldChapter()
				-- total_num = PersonalGoalsData.Instance:GetCurChapterTotalNum()
				-- finish_num = PersonalGoalsData.Instance:GetCurchapterFinishNum()
				-- self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], cur_chapter + 1 , finish_num , total_num), TEXT_COLOR.WHITE)
			elseif self.data.decs_index == 2 then
				cur_chapter, finish_num, total_num = MolongMibaoData.Instance:GetCurChapterState()
				local chapter_name = MolongMibaoData.Instance:GetMibaoChapterName(cur_chapter)
				self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], chapter_name, finish_num , total_num), TEXT_COLOR.WHITE)
			elseif self.data.decs_index == 3 then
				local num = 0
				local info = WaBaoData.Instance:GetWaBaoInfo()
				if next(info) then
					num = info.baotu_count
				end
				local format_color = num > 0 and Language.Mount.ShowGreenNum or Language.Mount.ShowRedNum
				local num_text = string.format(format_color, num)
				self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], num_text), TEXT_COLOR.WHITE)
			elseif self.data.decs_index == 4 then
				self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.link_desc[self.data.decs_index], num_text), TEXT_COLOR.WHITE)
				local bundle, asset =  ResPath.GetMainUI("tasktype_" .. TASK_TYPE.GUAJI or 1)
				self.node_list["TxtTaskType"].image:LoadSpriteAsync(bundle, asset)
			end

			if finish_num >= total_num and self.data.decs_index ~= 3 then
				self.node_list["TxtDesc"].text.text = ToColorStr(Language.Task.link_desc[self.data.decs_index], num_text, TEXT_COLOR.WHITE)
			end
		end

		if data.task_type == TASK_TYPE.DALIY then
			local bundle, asset =  ResPath.GetMainUI("tasktype_" .. data.task_type or 1)
			self.node_list["TxtTaskType"].image:LoadSpriteAsync(bundle, asset)

			self.node_list["TxtName"].text.text = Language.Task.task_title[self.data.task_type]
			local total_num, finish_num = 0, 0
			total_num = self.data.total_num
			finish_num = self.data.finish_num

			self.node_list["TxtDesc"].text.text = ToColorStr(self.data.des.."("..finish_num.."/"..total_num..")", TEXT_COLOR.WHITE)
			if finish_num >= total_num then
				self.node_list["TxtDesc"].text.text = ToColorStr(string.format(Language.Task.GetReward), TEXT_COLOR.GREEN)
			end
		end


	end
	self:RemoveCountDown()
	local end_time = TaskData.Instance:GetTaskEndTime(data.task_id)
	if end_time then
		local time = end_time - TimeCtrl.Instance:GetServerTime()
		if time > 0 then
			self.node_list["TxtTime"]:SetActive(true)
			local rest_of_time = math.ceil(time)
			self.node_list["TxtTime"].text.text = self:TimeToString(rest_of_time)
			self.sell_view:SetTime(self:TimeToString(rest_of_time))

			self:CountDown(rest_of_time)
		else
			self.node_list["TxtTime"]:SetActive(false)
		end
	else
		self.node_list["TxtTime"]:SetActive(false)
	end
end

function MainUIViewTaskInfo:SetToggle(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MainUIViewTaskInfo:CountDown(time)
	if not time or time < 1 then return end
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.UpdateTime, self, nil))
end

function MainUIViewTaskInfo:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MainUIViewTaskInfo:UpdateTime(callback, elapse_time, total_time)
	local time = math.floor(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		if callback then
			callback()
		end
	end
	self.node_list["TxtTime"].text.text = self:TimeToString(time)
	self.sell_view:SetTime(self:TimeToString(time))
end

function MainUIViewTaskInfo:TimeToString(time)
	-- 1小时之内
	if time > 3600 then return end
	local min = math.floor(time / 60)
	local sec = time % 60
	if sec < 10 then sec = 0 .. sec end
	if min < 10 then min = 0 .. min end
	return (min .. ":" .. sec)
end

function MainUIViewTaskInfo:GetData()
	return self.data
end

function MainUIViewTaskInfo:SetTaskEffectFlag()
	local effect_flag = false
	self.effect_task = 0
	if self.data then
		local config = TaskData.Instance:GetTaskConfig(self.data.task_id)
		if config and self.data_index == 1 and not self.root_node.toggle.isOn then
			local role_level = PlayerData.Instance:GetRoleVo().level
			if config.min_level and config.min_level <= role_level then
				effect_flag = true
			end
		end
		if effect_flag then
			self.effect_task = self.data.task_id
		end
	end
	if effect_flag then
		self.node_list["Effect"]:SetActive(self.effect_task ~= CLICK_EFFECT_TASK or (self.effect_task > 0 and self.data.task_status == TASK_STATUS.COMMIT))
		-- self.node_list["Effect"]:SetActive(false)
	else
		self.node_list["Effect"]:SetActive(false)
	end
end

function MainUIViewTaskInfo:SetToggleSwitch(switch)
	self.root_node.toggle.isOn = switch or false
	self:SetTaskEffectFlag()
end