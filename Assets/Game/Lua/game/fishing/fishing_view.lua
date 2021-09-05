require("game/fishing/other_panel/creel_panel_view")
require("game/fishing/other_panel/fishing_table_panel")

CrossFishingView = CrossFishingView or BaseClass(BaseView)
local progress_length = 650

local Line_Rank = {
	[1] = {[1] = 0.474, [2] = 0.662},
	[2] = {[1] = 0.623, [2] = 0.739},
	[3] = {[1] = 0.502, [2] = 0.659},
}

local Text_Transform = {
	[1] = {position = Vector3(-71, 190, 0), rotation = Vector3(0, 0, 0)},
	[2] = {position = Vector3(-40, 186, 0), rotation = Vector3(0, 0, -20)},
	[3] = {position = Vector3(-67, 190, 0), rotation = Vector3(0, 0, -2)},
}
function CrossFishingView:__init()
	self.ui_config = {
		{"uis/views/fishing_prefab", "FishingView"}
	}
	self.camera_mode = UICameraMode.UICameraLow
	self.view_layer = UiLayer.MainUILow
	self.m_is_open_creel_valua = false
	self.m_is_open_fish_bait_valua = false

	self.active_close = false
	self.m_is_start_fishing = false								-- 是否开始钓鱼
	self.m_is_role_move = false									-- 角色是否移动中
	self.fishing_effect_list = {}								-- 钓鱼的特效列表
	self.is_safe_area_adapter = true
	self.is_first_find_way = true
	self.perfect_type = 0
	self.num = 1
end

function CrossFishingView:__delete()
end

function CrossFishingView:ReleaseCallBack()
	self:CancelFlushTimer()
	self:RemoveEventCountDown()

	if self.table_view then
		self.table_view:DeleteMe()
		self.table_view = nil
	end

	if self.btn_fishing then
		self.btn_fishing:DeleteMe()
		self.btn_fishing = nil
	end

	self:RemoveProgressCountDown()

	if self.pull_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pull_count_down)
		self.pull_count_down = nil
		-- if self.node_list["TxtPullRodTime"] then
		-- 	self.node_list["TxtPullRodTime"].text.text = ""
		-- end
	end

	if self.creel_panel_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.creel_panel_count_down)
		self.creel_panel_count_down = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	if self.count_down_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_time)
		self.count_down_time = nil
	end

	if self.count_down_time1 ~= nil then
		GlobalTimerQuest:CancelQuest(self.count_down_time1)
		self.count_down_time1 = nil
	end

	for k,v in pairs(self.fishing_effect_list) do
		v:Destroy()
		v:DeleteMe()
	end
	self.fishing_effect_list = {}

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	if self.bait_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.bait_timer)
		self.bait_timer = nil
	end

	if self.now_fishing_request then
		GlobalTimerQuest:CancelQuest(self.now_fishing_request)
		self.now_fishing_request = nil
	end

	if self.show_delay_timer then
		GlobalTimerQuest:CancelQuest(self.show_delay_timer)
		self.show_delay_timer = nil
	end

	if self.pass_delay_timer then
		GlobalTimerQuest:CancelQuest(self.pass_delay_timer)
		self.pass_delay_timer = nil
	end
	self:DeleteFishBait()
	self:DeleteFishSucc()

	self.is_open_fish_succ = nil
	self.is_start_fishing = nil
	self.is_fishing_area = nil
	self.is_countdown_show = nil
	self.gather_fil = nil
	self.original = nil
	self.anchor = nil
	self.progress_bg = nil
	self.progress_bar = nil

	self:ClearTimer()
end

function CrossFishingView:LoadCallBack()
	--监听UI事件
	self.node_list["BtnCreel"].button:AddClickListener(BindTool.Bind(self.OnOpenCreelHandler, self))
	self.node_list["BtnQiuckRod"].button:AddClickListener(BindTool.Bind(self.OnQiuckRodHandler, self))
	self.node_list["BtnAuto"].button:AddClickListener(BindTool.Bind(self.OnAutoFishingHandler, self))
	self.node_list["BtnFishing"].button:AddClickListener(BindTool.Bind(self.OnBtnFishingHandler, self))
	self.node_list["BtnSceneFishing"].button:AddClickListener(BindTool.Bind(self.OnStartFishingHandler, self))
	self.node_list["BtnGoFishing"].button:AddClickListener(BindTool.Bind(self.OnAutoGoFishingHandler, self))

	for i = 0, 2 do
		self.node_list["BtnSkill" .. i].button:AddClickListener(BindTool.Bind(self.OnBtnGearHandler, self, i))
	end
	self.node_list["ImgBg"]:SetActive(false)
	-- self.node_list["TxtPullRodTime"].text.text = ""
	self:ClearTimer()
	self.timer_quest = 	GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.Time, self), 1)

	self.is_open_fish_succ = false
	self.is_start_fishing = true
	self.is_fishing_area = true
	self.is_open_table = true

	-- 积分面板
	self.table_view = FishingTablePanelView.New(self.node_list["TablePanel"])

	self.gather_fil = self.node_list["Buoy"]
	self.original = self.gather_fil.rect.anchoredPosition3D
	self.anchor = self.node_list["Anchor"]
	self.progress_bg = self.node_list["ProgressBg"]
	self.progress_bar = self.node_list["ProgressBar"]

	self:InitFishBait()				-- 初始化鱼饵面板信息
	self:InitFishSucc()				-- 初始化钓鱼成功面板信息

	local fish_config = CrossFishingData.Instance:GetFishingOtherCfg()
	self.width = fish_config.perfect_area * progress_length / 100
	self.node_list["Accurate"].rect.sizeDelta = Vector3(self.width,16,0)
	self.node_list["EffectFish"]:SetActive(true)
	self:OnMainRolePosChangeHandler()
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FishingView, BindTool.Bind(self.GetUiCallBack, self))
end

function CrossFishingView:OpenCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听玩家移动
	if self.role_pos_change == nil then
		self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeHandler, self))
	end
	-- 监听玩家移动
	if self.role_move_end == nil then
		self.role_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEndHandler, self))
	end

	-- 请求钓鱼排行榜信息
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_RANK_INFO)
end

function CrossFishingView:CloseCallBack()
	--移除物品回调
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	
	if nil ~= self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end
	if nil ~= self.role_move_end then
		GlobalEventSystem:UnBind(self.role_move_end)
		self.role_move_end = nil
	end
end

--决定显示那个界面
function CrossFishingView:ShowIndexCallBack(index)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING)
	if activity_info then
		local diff_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()  
		self:SetActTime(diff_time)
	end

	-- CrossFishingData.Instance:SetAutoFishing(0)

	-- self.node_list["TxtBtnAuto"].text.text = Language.Fishing.LabelAutoFishing[2]
	-- self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[0]
	self:Flush()
end

function CrossFishingView:OnFlush(param_list)
	self:FlushEffect()
	for k, v in pairs(param_list) do
		if k == "all" then
			self:FlushFishBait()
		elseif k == "flush_fish_bait_view" then					-- 鱼饵面板
			self:FlushFishBait()
		elseif k == "flush_table_view" then						-- 积分面板
			if self.table_view then
				self.table_view:Flush(v)
			end
		elseif k == "flush_rod_time" then						-- 刷新拉杆倒计时
			self:SetRodTime()
		elseif k == "flush_fish_succ" then						-- 刷新钓鱼成功
			self:FlushFishSucc()
			self.is_open_fish_succ = false
			self:FlushFishing()
		elseif k == "flush_fish_steal" then						-- 刷新偷鱼成功
			self:CancelFlushTimer()
			-- self.is_open_fish_succ = true
			self:FlushFishing()
			self:FlushFishSteal()
			-- self.flush_timer = GlobalTimerQuest:AddDelayTimer(
			-- 	function()
			-- 		self.is_open_fish_succ = false
			-- 		self:FlushFishing()
			-- 	end, 2)
		elseif k == "flush_use_gear" then						-- 刷新法宝使用成功
			self:FlushUseGear()
		elseif k == "flush_fish_result" then
			self.is_open_fish_succ = true
			self:FlushFishResult()
			self.flush_timer1 = GlobalTimerQuest:AddDelayTimer(
				function()
					self.is_open_fish_succ = false
					self:FlushFishing()
				end, 2)
		elseif k == "flush_fishing_area" then
			local main_role = Scene.Instance:GetMainRole()
			local m_fishing_area = main_role:IsFishing()
			-- 是否在钓鱼区域中
			self.is_fishing_area = m_fishing_area

			-- 获取信息
			local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
			local fishing_auto_go = CrossFishingData.Instance:GetAutoGoFishing()
			self.m_is_start_fishing = fishing_user_info.fishing_status > 0
			self.is_start_fishing = self.m_is_start_fishing and m_fishing_area
			self:FlushFishing()
			if fishing_auto_go and m_fishing_area then
				main_role:StopMove()
				GuajiCtrl.Instance:StopGuaji()
			end
		elseif k == "flush_fishing_lagan_btn" then				-- 刷新拉杆按钮
			self.node_list["EffectFish"]:SetActive(false)
			local bundle, asset = ResPath.GetFishingRes("lagan")
			self.node_list["ImgFishing"].image:LoadSprite(bundle, asset)
			self.node_list["TxtFishing"].text.text = Language.Fishing.LaGan
		elseif k == "flush_fishing_paogan_btn" then				-- 刷新抛竿按钮
			self.node_list["EffectFish"]:SetActive(true)
			local bundle1, asset1 = ResPath.GetFishingRes("paogan")
			self.node_list["ImgFishing"].image:LoadSprite(bundle1, asset1)
			self.node_list["TxtFishing"].text.text = Language.Fishing.PaoGan
			if CrossFishingData.Instance:GetAutoFishing() == 0 then
				self.node_list["TxtBtnAuto"].text.text = Language.Fishing.LabelAutoFishing[2]
				self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[0]
			end
		elseif k == "fishing_bait_num" then 					-- 刷新鱼饵不足
			if nil == self.bait_timer then
				self.bait_timer = GlobalTimerQuest:AddDelayTimer(function()
					SysMsgCtrl.Instance:ErrorRemind(Language.Fishing.BaitBuZu)
					CrossFishingData.Instance:SetAutoFishing(0)
					FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
				end,2)
			end
		elseif k == "open_act_flush" then
			self:FlushFishing()
		end
	end
end

function CrossFishingView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.StartFishing then
		local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
		if fishing_user_info and fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_CAST then
			return NextGuideStepFlag
		end

		local callback = BindTool.Bind(self.OnBtnFishingHandler, self)
		return self.node_list["BtnFishing"], callback
	end
end

function CrossFishingView:CancelFlushTimer()
	-- if self.flush_timer ~= nil then
	-- 	GlobalTimerQuest:CancelQuest(self.flush_timer)
	-- 	self.flush_timer = nil
	-- end

	if self.flush_timer1 ~= nil then
		GlobalTimerQuest:CancelQuest(self.flush_timer1)
		self.flush_timer1 = nil
	end

	if self.flush_timer3 ~= nil then
		GlobalTimerQuest:CancelQuest(self.flush_timer3)
		self.flush_timer3 = nil
	end
end

function CrossFishingView:HideFishing(is_on)
	self.is_open_fish_succ = is_on
	self:FlushFishing()
end

function CrossFishingView:FlushFishing()
	local act_is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.CROSS_ACTIVITY_TYPE_FISHING)

	self.node_list["PanelBtn"]:SetActive((not self.is_open_fish_succ) and (not self.is_countdown_show))
	self.node_list["Silder"]:SetActive(not self.is_open_fish_succ)
	self.node_list["BtnSceneFishing"]:SetActive((not self.is_start_fishing) and self.is_fishing_area and (not self.is_open_fish_succ) and act_is_open)
	self.node_list["BtnGoFishing"]:SetActive((not self.is_start_fishing) and (not self.is_fishing_area) and (not self.is_open_fish_succ) and act_is_open)
	self.node_list["PanelBottom"]:SetActive(self.is_start_fishing and self.is_fishing_area and self.is_open_table)
	self.node_list["PanelFishRod"]:SetActive(self.is_start_fishing and self.is_fishing_area and self.is_open_table)
	-- self.node_list["EffectFish"]:SetActive(self.is_countdown_show)
	-- local main_view = MainUICtrl.Instance:GetView()
	-- if main_view then
	-- 	main_view.node_list["CameraMode"]:SetActive(not self.is_start_fishing)
	-- end
	if not self.is_start_fishing or not self.is_fishing_area then			-- 在钓鱼界面等待抛竿
		self:SetIsFishingNow(false)
	end
end

function CrossFishingView:SetIsFishingNow(enble)
	self.node_list["IsFishing"]:SetActive(enble)
	if enble then
		if nil == self.now_fishing_request then
			local i = 0
			self.now_fishing_request = GlobalTimerQuest:AddRunQuest(function()
				i = i + 1
				if i == 1 then
					self.node_list["TxtDian"].text.text = " ."
				elseif i == 2 then
					self.node_list["TxtDian"].text.text = " . ."
				elseif i == 3 then
					self.node_list["TxtDian"].text.text = " . . ."
				elseif i == 4 then
					i = 1
					self.node_list["TxtDian"].text.text = " ."
				end
			end, 1)
		end
	else
		if self.now_fishing_request then
			GlobalTimerQuest:CancelQuest(self.now_fishing_request)
			self.now_fishing_request = nil
		end
	end
end
function CrossFishingView:FlushEffect()
	self.node_list["Effect"]:SetActive(CrossFishingData.Instance:IsCanExchange())
end

function CrossFishingView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushFishBait()
end

function CrossFishingView:GetMagicCount()
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo() or nil	
	if fishing_user_info then
		for i = 1,3 do
			self.node_list["TxtCount" .. i].text.text = fishing_user_info.gear_num_list[i]
			if fishing_user_info.gear_num_list[i] > 0 then
				self.node_list["Effect" .. i]:SetActive(true)
			else
				self.node_list["Effect" .. i]:SetActive(false)
			end
		end
	end
end

function CrossFishingView:OnOpenCreelHandler()
	ViewManager.Instance:Open(ViewName.CreelPanel)
	self.m_is_open_creel_valua = not self.m_is_open_creel_valua
	if self.m_is_open_creel_valua == true then
		self:SetCloseCreelTime()
	end
end

-- 设置鱼篓关闭界面倒计时
function CrossFishingView:SetCloseCreelTime()
	if self.creel_panel_count_down == nil then
		local count_down_time = CrossFishingData.Instance:GetFishingCreelTimeCfg()
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(count_down_time - elapse_time + 0.5)
			if CrossFishingData.Instance:GetCreelViewtime() == 1 then
				CountDown.Instance:SetElapseTime(self.creel_panel_count_down, 0)
				CrossFishingData.Instance:SetCreelViewtime(0)
			end
			if left_time <= 0 or not self.m_is_open_creel_valua then
				if self.creel_panel_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.creel_panel_count_down)
					self.creel_panel_count_down = nil
					self.m_is_open_creel_valua = false
					ViewManager.Instance:Close(ViewName.CreelPanel)
				end
				return
			end
			-- self.node_list["TxtPullRodTime"].text.text = string.format(Language.Fishing.LabelPullRodTime, TimeUtil.FormatSecond2Str(left_time))
		end

		diff_time_func(0, count_down_time)
		self.creel_panel_count_down = CountDown.Instance:AddCountDown(count_down_time, 0.5, diff_time_func)
	end
end



-- 活动倒计时
function CrossFishingView:SetActTime(diff_time)
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
		end
		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end

-- 拉杆倒计时处理函数
function CrossFishingView:SetRodTime()
	local is_fast_fishing = CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	local fish_config = CrossFishingData.Instance:GetFishingOtherCfg()
	if self.pull_count_down == nil then
		-- local pull_count_down_time = CrossFishingData.Instance:GetFishingOtherCfg().pull_count_down_s or 0
		self.is_countdown_show = true
		self:FlushFishing()
		self:Start()
		self.node_list["EffectFish"]:SetActive(true)

		-- local flag = true
		-- local pull_count_down_startpos = self.node_list["Buoy"].transform.localPosition
		-- local perfet_area_startpos = self.node_list["Accurate"].transform.localPosition
		-- local time = 0
		-- local time_part = 0
		-- local timer =  pull_count_down_time / 3																	--游标转圈次数
		-- local perfect_area_percent1 = 0
		-- local perfect_area_percent2 = 0
		-- local area = 0
		-- if fish_config then
		-- 	perfet_area_minpercent = fish_config.perfect_min or 0
		-- 	perfet_area_maxpercent = fish_config.perfect_max or 0
		-- 	perfect_area_percet = fish_config.perfect_area or 0
		-- end

		-- local perfect_area_length = progress_length * (perfet_area_maxpercent - perfet_area_minpercent) / 100
		-- local location = {
		-- -perfect_area_length/8 - perfect_area_length/4,
		-- -perfect_area_length/8,
		-- perfect_area_length/8,
		-- perfect_area_length/8 + perfect_area_length/4
		-- }
		-- local random = math.floor(math.random(1, 4))
		-- function diff_time_func(elapse_time, total_time)
		-- 	self.node_list["Accurate"]:SetActive(true)
		-- 	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
		-- 	if time > timer then
		-- 		flag = false
		-- 	elseif time < 0 then
		-- 		flag = true
		-- 	end
		-- 	if flag then
		-- 		time = time + (elapse_time - time_part)
		-- 	else
		-- 		time = time - (elapse_time - time_part)
		-- 	end
			
		-- 	local length = progress_length / timer * time
		-- 	self.node_list["Buoy"].transform.localPosition = pull_count_down_startpos + Vector3(length, 0, 0)
		-- 	local left_time = math.floor(total_time - elapse_time)

		-- 	self.node_list["Accurate"].transform.localPosition = Vector3(location[random], 0, 0)

			
		-- 	if bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 2)) == 1 and (self.node_list["Buoy"].transform.localPosition.x >= self.node_list["Accurate"].transform.localPosition.x - self.width/2)
		-- 	or (bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 1)) == 1 and is_auto_fishing == 1 and left_time <= 0) or 
		-- 		fishing_user_info.fishing_status ~= FISHING_STATUS.FISHING_STATUS_HOOKED or left_time <= 0 then				--倒计时小于0或者状态改变
		-- 		if self.pull_count_down ~= nil then
		-- 			CountDown.Instance:RemoveCountDown(self.pull_count_down)
		-- 			self.pull_count_down = nil
		-- 			if self.node_list["Buoy"].transform.localPosition.x <= self.node_list["Accurate"].transform.localPosition.x + self.width /2
		-- 				and self.node_list["Buoy"].transform.localPosition.x >= self.node_list["Accurate"].transform.localPosition.x - self.width/2 then
		-- 				self.perfect_type = 1
		-- 			else
		-- 				self.perfect_type = 0
		-- 			end
		-- 			self.flush_timer3 = GlobalTimerQuest:AddDelayTimer(
		-- 				function()
		-- 					self.node_list["ImgBg"]:SetActive(false)
		-- 					self.node_list["TxtPullRodTime"].text.text = ""
		-- 					self.node_list["Buoy"].transform.localPosition = pull_count_down_startpos
		-- 					self.node_list["Accurate"].transform.localPosition = perfet_area_startpos
		-- 					self.is_countdown_show = false
		-- 					self:FlushFishing()
		-- 					if CrossFishingData.Instance:GetAutoFishing() == 1 then
		-- 						FishingCtrl.Instance:SendFishingPerfect(self.perfect_type)
		-- 					end
		-- 				end, 0.5)
		-- 		end
		-- 		return
		-- 	end
		-- 	self.node_list["ImgBg"]:SetActive(true)
		-- 	self.node_list["TxtPullRodTime"].text.text = string.format(Language.Fishing.LabelPullRodTime, TimeUtil.FormatSecond2Str(left_time))
		-- 	time_part = elapse_time
		-- end

		-- diff_time_func(0, pull_count_down_time)
		-- self.pull_count_down = CountDown.Instance:AddCountDown(pull_count_down_time, 0.01, diff_time_func)
	end
end

-- 快速拉杆
function CrossFishingView:OnQiuckRodHandler()
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 1 then
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
		self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[0]
		return
	end
	local other_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
	if other_cfg then
		local des = string.format(Language.Fishing.IsBuyAutoQiuckRod, other_cfg.auto_fishing_need_gold)
		local is_consumed_auto_fishing = CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing

		local ok_fun = function ()
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local gold_str = main_vo.gold + main_vo.bind_gold
			local other_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
			if other_cfg  and other_cfg.auto_fishing_need_gold then
				local lagan_price = other_cfg.auto_fishing_need_gold
				if tonumber(gold_str) < tonumber(lagan_price) then
					TipsCtrl.Instance:ShowLackDiamondView()
					return
				end
			end
			FishingCtrl.Instance:SendAutoFishing(1, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
			local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
			if is_auto_fishing == 0 then
				self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[1]
			else
				self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[0]
			end
			FishingCtrl.Instance.view:OnFishingHandler()
		end

		if is_consumed_auto_fishing == 1 then
			ok_fun()
		else
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, des, nil, nil, true, false)
		end
	end
end

-- 自动钓鱼
function CrossFishingView:OnAutoFishingHandler()
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 0 then
		FishingCtrl.Instance:SendAutoFishing(1, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING)
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		self.node_list["TxtBtnAuto"].text.text = Language.Fishing.LabelAutoFishing[1]
	else
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING)
		self.node_list["TxtBtnAuto"].text.text = Language.Fishing.LabelAutoFishing[2]
	end
	self:OnFishingHandler()
end

function CrossFishingView:OnFishingHandler()
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	local fish_bait = CrossFishingData.Instance:GetBaitFishing(0)
	if fish_bait <= 0 and is_auto_fishing == 0 then
		FishingCtrl.Instance:SendFishing(0)
		return
	end
	if is_auto_fishing == 0 then
		-- 设置自动钓鱼
		CrossFishingData.Instance:SetAutoFishing(1)
		-- 使用0普通鱼饵
		if CrossFishingData.Instance:GetFishingUserInfo().fishing_status == FISHING_STATUS.FISHING_STATUS_WAITING then
			 FishingCtrl.Instance:SendFishing(0)
	 		local vo = GameVoManager.Instance:GetMainRoleVo()
			local obj = Scene.Instance:GetObj(vo.obj_id)
			if obj then
				local num = math.random(1, 5)
				self.count_down_time = GlobalTimerQuest:AddDelayTimer(
					function()
						obj:GetFollowUi():ShowBubble()
						obj:GetFollowUi():ChangeBubble(Language.Fishing.PaoGanText[num], 2)
					end, 1.5)

				self.count_down_time1 = GlobalTimerQuest:AddDelayTimer(
					function()
						local num1 = math.random(1, 5)
						if num1 == num then
							num1 = num1 + 1 >= 6 and 1 or num1 + 1
						end
						obj:GetFollowUi():ShowBubble()
						obj:GetFollowUi():ChangeBubble(Language.Fishing.PaoGanText[num1], 2)
					end, 3.5)
			end
		end
	else
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
	end
end


--自动寻路
function CrossFishingView:OnAutoGoFishingHandler()
	local fishing_location_cfg = CrossFishingData.Instance:GetFishinglocationCfg()
	local rand_index = 1
	if self.is_first_find_way then
		rand_index = math.random(1, GetListNum(fishing_location_cfg))
		self.is_first_find_way = false
	else
		rand_index = CrossFishingData.Instance:FindNearPosIndex()
	end

	local cfg = fishing_location_cfg[rand_index]
	if cfg then
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg.x, cfg.y)
		CrossFishingData.Instance:SetAutoGoFishing(true)
	end
end

-- 钓鱼抛竿
function CrossFishingView:OnBtnFishingHandler()
	local fish_bait = CrossFishingData.Instance:GetBaitFishing(0)
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
	if fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_WAITING then			-- 在钓鱼界面等待抛竿
		-- 使用0普通鱼饵
		self.node_list["EffectFish"]:SetActive(false)
		FishingCtrl.Instance:SendFishing(0)
		-- self.node_list["Accurate"]:SetActive(false)
		if fish_bait > 0 then
			local vo = GameVoManager.Instance:GetMainRoleVo()
			local obj = Scene.Instance:GetObj(vo.obj_id)
			if obj then
				local num = math.random(1, 5)
				self.count_down_time = GlobalTimerQuest:AddDelayTimer(
					function()
						obj:GetFollowUi():ShowBubble()
						obj:GetFollowUi():ChangeBubble(Language.Fishing.PaoGanText[num], 2)
					end, 1.5)

				self.count_down_time1 = GlobalTimerQuest:AddDelayTimer(
					function()
						local num1 = math.random(1, 5)
						if num1 == num then
							num1 = num1 + 1 >= 6 and 1 or num1 + 1
 						end
						obj:GetFollowUi():ShowBubble()
						obj:GetFollowUi():ChangeBubble(Language.Fishing.PaoGanText[num1], 2)
					end, 3.5)
			end
			self:SetIsFishingNow(true)
		end
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_CAST then			-- 已经抛竿，等待触发事件
		-- self.node_list["EffectFish"]:SetActive(false)
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishing.FishNoHookTips)
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_HOOKED then		-- 已经触发事件，等待拉杆
		if self.progress_bar.image.fillAmount <= Line_Rank[self.num][2] and self.progress_bar.image.fillAmount >= Line_Rank[self.num][1] then
			self.perfect_type = 1
		else
			self.perfect_type = 0
		end
		self:SetIsFishingNow(false)
		FishingCtrl.Instance:SendFishingPerfect(self.perfect_type)
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_PULLED then		-- 已经拉杆，等待玩家做选择
	end
end


-- 法宝按钮
function CrossFishingView:OnBtnGearHandler(gear_type)
	FishingCtrl.Instance:SendUseGear(gear_type)
end

-- 请求钓鱼状态
function CrossFishingView:OnStartFishingHandler()
	local uuid = CrossFishingData.Instance:GetFishingUserInfo().uuid
	local is_guide_fishing = PlayerPrefsUtil.GetInt(uuid .. "_start_fishing_guide") or 0
	if is_guide_fishing <= 0 then
		local guide_cfg = FunctionGuide.Instance:GetGuideCfgByTrigger(GuideTriggerType.ClickUi, GuideUIName.FishingBtn)
		if guide_cfg then
			FunctionGuide.Instance:SetCurrentGuideCfg(guide_cfg)
			PlayerPrefsUtil.SetInt(uuid .. "_start_fishing_guide", 1)
		end
	end
	FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
	CrossFishingData.Instance:SetAutoFishing(0)
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
	CrossFishingData.Instance:SetIsPassTime(true)
end

-- 角色移动处理函数
function CrossFishingView:OnMainRolePosChangeHandler(x, y)
	self.m_is_role_move = true
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 1 then
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
		self.node_list["TxtPullRod"].text.text = Language.Fishing.LabelAutoFishing[0]
		return
	end
	if self.m_is_start_fishing and (self.self_x ~= x or self.self_y ~= y) then
		-- 取消钓鱼状态
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_STOP_FISHING)
		CrossFishingData.Instance:SetAutoFishing(0)
		CrossFishingData.Instance:SetIsPassTime(false)
	end
	self:Flush("flush_fishing_area")
end

-- 角色移动结束处理函数
function CrossFishingView:OnMainRoleMoveEndHandler()
	self.m_is_role_move = false
	CrossFishingData.Instance:SetAutoGoFishing(false)
	self:Flush("flush_fishing_area")
end

function CrossFishingView:RemoveFishingEffect(role_id)
	if nil ~= self.fishing_effect_list[role_id] then
		self.fishing_effect_list[role_id]:Destroy()
		self.fishing_effect_list[role_id]:DeleteMe()
		self.fishing_effect_list[role_id] = nil
	end
end

function CrossFishingView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function CrossFishingView:Time()
	-- 剩余时间
	local user_info = CrossFishingData.Instance:GetFishingUserInfo()
	if user_info and user_info.special_status_oil_end_timestamp then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local Timetext = user_info.special_status_oil_end_timestamp
		local time_up_text = Timetext - server_time
		local str = TimeUtil.FormatSecond(time_up_text, 2)
		self.node_list["TxtTimeUp"].text.text = str
		self.node_list["TxtTimeUp"]:SetActive(true)
		self.node_list["ImgTime"]:SetActive(true)
		if time_up_text <= 0 then
			self.node_list["TxtTimeUp"]:SetActive(false)
			self.node_list["ImgTime"]:SetActive(false)
		end
	end
end

function CrossFishingView:PortraitToggleChange(state)
	self.is_open_table = state
	self.node_list["TablePanel"]:SetActive(state)
	self.node_list["PanelTopLeft"]:SetActive(state)
	self.node_list["PanelFishSucc"]:SetActive(state)
	self:FlushFishing()
end

function CrossFishingView:Start()
	local x = 0
	local y = 0
	local r = 0  		--半径  
	local w = 0.5 		--角度  
	local speed = 0.025
	local first = true
	local reverse = true
	local total = CrossFishingData.Instance:GetFishingOtherCfg().pull_count_down_s or 15
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	-- self.progress_bg = nil
	self.progress_bar.image.fillAmount = 1
	-- self.gather_bar.value = 0
	self.gather_fil.rect.anchoredPosition3D = self.original

	r = Vector3.Distance(self.gather_fil.rect.anchoredPosition3D, self.anchor.rect.anchoredPosition3D)

	function diff_time_func(elapse_time, total_time)
		local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
		local delta_time = UnityEngine.Time.deltaTime
		if reverse then
			w = w + speed + delta_time
		else
			w = w + speed - delta_time
		end

		if first then
			w = 0.96
			first = false
		end

		x = Mathf.Cos(w) * r
		y = Mathf.Sin(w) * r
		local rotation = self:GetAngle(0, 0, x, y)

		self.gather_fil.transform.localRotation = Quaternion.Euler(0, 0, rotation - 90)
		self.gather_fil.rect.anchoredPosition3D = Vector3(x, y, self.gather_fil.rect.anchoredPosition3D.z)

		if x < 0 and rotation < 0 then --x < 0的时候角度转成正的来计算
			rotation = 360 + rotation
		end 
		
		if (rotation >= 255 and y <= 0) or (rotation <= 53 and not reverse) then
			speed = -speed
			w = w
			reverse = not reverse
		elseif rotation >= 0 then
			w = w
		elseif rotation >= 180 then
			w = -w
		end
		-- self.progress_bar.image.fillAmount = math.abs(202 - rotation) / 180
		self.progress_bar.image.fillAmount = (202 - rotation) / 180
		local left_time = math.floor(total_time - elapse_time)
		if bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 2)) == 1 and (self.progress_bar.image.fillAmount <= Line_Rank[self.num][2]) and is_auto_fishing == 1 or 
			(bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 1)) == 1 and is_auto_fishing == 1 and left_time <= 0) or 
				fishing_user_info.fishing_status ~= FISHING_STATUS.FISHING_STATUS_HOOKED or left_time <= 0 then				--倒计时小于0或者状态改变

				self:RemoveProgressCountDown()
				if self.progress_bar.image.fillAmount <= Line_Rank[self.num][2] and self.progress_bar.image.fillAmount >= Line_Rank[self.num][1] then
					self.perfect_type = 1
				else
					self.perfect_type = 0
				end

				self.flush_timer3 = GlobalTimerQuest:AddDelayTimer(function()
					self.progress_bar.image.fillAmount = 1
					self.gather_fil.transform.localRotation = Quaternion.Euler(0, 0, 319.24)
					self.gather_fil.rect.anchoredPosition3D = Vector3(77, 89, 0)
					self.is_countdown_show = false
					self:FlushFishing()

					self.num = math.random(1, 3)
					local name_line = "line_" .. self.num
					local name_prog = "progress_bg_" .. self.num
					local bundle,asset = ResPath.GetFishingRes(name_line)
					local bundle1,asset1 = ResPath.GetFishingRes(name_prog)
					self.node_list["ProgressBar"].image:LoadSprite(bundle1,asset1)
					self.node_list["Line"].image:LoadSprite(bundle,asset)
					self.node_list["TxtPerfect"].transform.localPosition = Text_Transform[self.num].position
					self.node_list["TxtPerfect"].transform.eulerAngles = Text_Transform[self.num].rotation
					if CrossFishingData.Instance:GetAutoFishing() == 1 then
						FishingCtrl.Instance:SendFishingPerfect(self.perfect_type)
					end
				end,0.5)
		end
	end
	
	self:RemoveProgressCountDown()
	self.progress_count_down = CountDown.Instance:AddCountDown(total, 0.01, diff_time_func)
end

function CrossFishingView:RemoveProgressCountDown()
	if self.progress_count_down then
		CountDown.Instance:RemoveCountDown(self.progress_count_down)
		self.progress_count_down = nil
	end
end

--两点的夹角
function CrossFishingView:GetAngle(px1, py1, px2, py2) 
	local p = {}
	p.x = px2 - px1
	p.y = py2 - py1
	local r = math.atan2(p.y, p.x) * 180 / math.pi  
	return r
end
